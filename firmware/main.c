/* 
 * Copyright (C) 2012 Chris McClelland
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *  
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include <util/delay_basic.h>
#include <avr/io.h>
#include <avr/wdt.h>
#include <avr/power.h>
#include <string.h>
#include <LUFA/Version.h>
#include <LUFA/Drivers/USB/USB.h>
//#include "makestuff/common.h"
#include "desc.h"
#include "usbio.h"

// sudo minicom -b 115200 -D /dev/ttyS0 -o -w -8
//#define DEBUG
#define DEBUG_MASK 0x08
#ifdef DEBUG
#define BAUD 45
void usartSendByte(uint8_t byte) {
	const uint8_t hi = PORTB | DEBUG_MASK;
	const uint8_t lo = PORTB & (~DEBUG_MASK);
	cli();
	PORTB = lo;
	_delay_loop_1(BAUD);
	PORTB = (byte & 0x01) ? hi : lo;
	_delay_loop_1(BAUD);
	PORTB = (byte & 0x02) ? hi : lo;
	_delay_loop_1(BAUD);
	PORTB = (byte & 0x04) ? hi : lo;
	_delay_loop_1(BAUD);
	PORTB = (byte & 0x08) ? hi : lo;
	_delay_loop_1(BAUD);
	PORTB = (byte & 0x10) ? hi : lo;
	_delay_loop_1(BAUD);
	PORTB = (byte & 0x20) ? hi : lo;
	_delay_loop_1(BAUD);
	PORTB = (byte & 0x40) ? hi : lo;
	_delay_loop_1(BAUD);
	PORTB = (byte & 0x80) ? hi : lo;
	_delay_loop_1(BAUD);
	PORTB = hi;
	_delay_loop_1(BAUD);
	sei();
}
void usartSendByteHex(uint8_t byte) {
	uint8_t ch;
	ch = (byte >> 4) & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
	ch = byte & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
}
void usartSendWordHex(uint16_t word) {
	uint8_t ch;
	ch = (word >> 12) & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
	ch = (word >> 8) & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
	ch = (word >> 4) & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
	ch = (word >> 0) & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
}
void usartSendLongHex(uint32_t word) {
	uint8_t ch;
	ch = (word >> 28) & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
	ch = (word >> 24) & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
	ch = (word >> 20) & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
	ch = (word >> 16) & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
	ch = (word >> 12) & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
	ch = (word >> 8) & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
	ch = (word >> 4) & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
	ch = (word >> 0) & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
}
void usartSendString(const char *s) {
	while ( *s ) {
		usartSendByte(*s++);
	}
}
void usartSendFlashString(const char *str) {
	char ch = pgm_read_byte(str);
	while ( ch ) {
		usartSendByte(ch);
		str++;
		ch = pgm_read_byte(str);
	}
}
#endif

static uint8_t channel;
static uint8_t command;
static uint8_t param1;
static uint8_t param2;
static union {
	uint16_t word;
	uint8_t bytes[2];
} dataLength;
static enum {
	GET_CHANNEL,      // fetch channel byte
	GET_COMMAND,      // fetch command byte
	GET_PARAM1,       // fetch first parameter byte
	GET_PARAM2,       // fetch second parameter byte
	GET_LENGTH_LOW,   // fetch data-length low byte
	GET_LENGTH_HIGH,  // fetch data-length low byte
	GET_DATA,         // fetch data bytes
	SEND_PREP,        // flip DDRD ready to send
	SEND_RETCODE,     // send response length
	SEND_LENGTH_LOW,  // send data-length low byte
	SEND_LENGTH_HIGH, // send data-length low byte
	SEND_DATA,        // send data bytes
	FINISH            // flip DDRD ready to receive again
} state;

static void ackByte(void) {
	cli();
	PORTC = 0x00;  // acknowledge transfer
	_delay_loop_1(21);  // 21 loops, 3 16MHz cycles each ~4us.
	if ( !(PINC & 0x04) ) {
		// The BBC's flag was not automatically cleared, so we're being reset
		sei();
		state = GET_CHANNEL;
		DDRD = 0x00;
		while ( !(PINC & 0x04) );
		PORTC = 0x10;
	} else {
		// The BBC's flag was automatically cleared
		PORTC = 0x10;
		sei();
	}
}

void doMessaging(void) {
	uint8_t ch;
	if ( PINC & 0x04 ) {
		return;  // nothing to do
	}
	switch ( state ) {
		case GET_CHANNEL:{
			channel = ch = PIND;
			state = GET_COMMAND;
			ackByte();
			#ifdef DEBUG
				usartSendByte('a');
				usartSendByteHex(ch);
				usartSendByte(',');
			#endif
			break;
		}
		case GET_COMMAND:{
			command = ch = PIND;
			state = GET_PARAM1;
			ackByte();
			#ifdef DEBUG
				usartSendByte('b');
				usartSendByteHex(ch);
				usartSendByte(',');
			#endif
			break;
		}
		case GET_PARAM1:{
			param1 = ch = PIND;
			state = GET_PARAM2;
			ackByte();
			#ifdef DEBUG
				usartSendByte('c');
				usartSendByteHex(ch);
				usartSendByte(',');
			#endif
			break;
		}
		case GET_PARAM2:{
			param2 = ch = PIND;
			state = GET_LENGTH_LOW;
			ackByte();
			#ifdef DEBUG
				usartSendByte('d');
				usartSendByteHex(ch);
				usartSendByte(',');
			#endif
			break;
		}
		case GET_LENGTH_LOW:{
			dataLength.bytes[0] = ch = PIND;
			state = GET_LENGTH_HIGH;
			ackByte();
			#ifdef DEBUG
				usartSendByte('e');
				usartSendByteHex(ch);
				usartSendByte(',');
			#endif
			break;
		}
		case GET_LENGTH_HIGH:{
			dataLength.bytes[1] = ch = PIND;
			if ( dataLength.word ) {
				state = GET_DATA;
			} else {
				state = SEND_PREP;
			}
			ackByte();
			usbSelectEndpoint(IN_ENDPOINT_ADDR);
			while ( !usbInPacketReady() );
			usbPutByte(channel);
			usbPutByte(command);
			usbPutByte(param1);
			usbPutByte(param2);
			usbPutByte(dataLength.bytes[0]);
			usbPutByte(dataLength.bytes[1]);
			#ifdef DEBUG
				usartSendByte('f');
				usartSendByteHex(ch);
				usartSendByte(',');
			#endif
			usbFlushPacket();  // send the request to the host
			if ( dataLength.word ) {
				while ( !usbInPacketReady() ); // wait for room for another packet
			}
			/*usartSendFlashString(PSTR("MSG("));
			usartSendByteHex(channel);
			usartSendByte(',');
			usartSendByteHex(command);
			usartSendByte(',');
			usartSendByteHex(param1);
			usartSendByte(',');
			usartSendByteHex(param2);
			usartSendByte(',');
			usartSendWordHex(dataLength.word);
			usartSendByte(')');
			usartSendByte('\r');*/
			break;
		}
		case GET_DATA:{
			ch = PIND;
			dataLength.word--;
			if ( !usbReadWriteAllowed() ) {
				usbFlushPacket();  // send a full packet
				while ( !usbInPacketReady() );
			}
			usbPutByte(ch);
			#ifdef DEBUG
				usartSendByte('g');
				usartSendByteHex(ch);
				usartSendByte(',');
			#endif
			if ( !dataLength.word ) {
				// last chunk
				usbFlushPacket();  // send the last few bytes
				state = SEND_PREP;
			}
			ackByte();
			break;
		}
		case SEND_PREP:{
			state = SEND_RETCODE;
			ackByte();         // wait until the BBC has definitely stopped driving
			DDRD = 0xFF;
			#ifdef DEBUG
				usartSendByte('h');
				usartSendByte(',');
			#endif
			break;
		}
		case SEND_RETCODE:{
			usbSelectEndpoint(OUT_ENDPOINT_ADDR);
			while ( !usbOutPacketReady() );       // wait for a response from the host
			PORTD = ch = usbRecvByte();           // return code
			state = SEND_LENGTH_LOW;
			ackByte();
			dataLength.bytes[0] = usbRecvByte();  // length LSB
			dataLength.bytes[1] = usbRecvByte();  // length MSB
			#ifdef DEBUG
				usartSendByte('i');
				usartSendByteHex(ch);
				usartSendByte(',');
			#endif
			break;
		}
		case SEND_LENGTH_LOW:{
			PORTD = ch = dataLength.bytes[0];
			state = SEND_LENGTH_HIGH;
			ackByte();
			#ifdef DEBUG
				usartSendByte('j');
				usartSendByteHex(ch);
				usartSendByte(',');
			#endif
			break;
		}
		case SEND_LENGTH_HIGH:{
			PORTD = ch = dataLength.bytes[1];
			if ( dataLength.word ) {
				state = SEND_DATA;
			} else {
				state = FINISH;
			}
			ackByte();
			#ifdef DEBUG
				usartSendByte('k');
				usartSendByteHex(ch);
				usartSendByte(',');
			#endif
			break;
		}
		case SEND_DATA:{
			PORTD = ch = usbRecvByte();
			dataLength.word--;
			if ( !dataLength.word ) {
				state = FINISH;
			}
			ackByte();
			#ifdef DEBUG
				usartSendByte('m');
				usartSendByteHex(ch);
				usartSendByte(',');
			#endif
			break;
		}
		case FINISH:{
			usbAckPacket();
			DDRD = 0x00;
			state = GET_CHANNEL;
			ackByte();
			#ifdef DEBUG
				usartSendByte('n');
				usartSendByte('\r');
			#endif
			break;
		}
	}
}

// Called once at startup
//
int main(void) {
	REGCR |= (1 << REGDIS);  // Disable regulator: using JTAG supply rail, which may be 3.3V.
	MCUSR &= ~(1 << WDRF);
	wdt_disable();
	clock_prescale_set(clock_div_1);
	PORTB = DEBUG_MASK;
	PORTC = 0x10;
	PORTD = 0x00;
	DDRB = DEBUG_MASK;  // PB3 output
	DDRC = 0x10;  // PC4 output
	DDRD = 0x00;  // BBC sends, I receive
	state = GET_CHANNEL;
	sei();
	#ifdef DEBUG
		usartSendFlashString(PSTR("MakeStuff UDFS\r"));
	#endif
	USB_Init();
	for ( ; ; ) {
		doMessaging();
		USB_USBTask();
	}
}

// Called when a vendor command is received
//
void EVENT_USB_Device_ControlRequest(void) {
	// Control request
}

void EVENT_USB_Device_Connect(void) {
	// Connected
}

void EVENT_USB_Device_Disconnect(void) { }

void EVENT_USB_Device_ConfigurationChanged(void) {
	if ( !(Endpoint_ConfigureEndpoint(ENDPOINT_DIR_OUT | OUT_ENDPOINT_ADDR,
	                                  EP_TYPE_BULK,
	                                  ENDPOINT_SIZE,
	                                  1)) )
	{
	#ifdef DEBUG
		usartSendFlashString(PSTR("Failed to config OUT endpoint\r"));
	#endif
	}
	if ( !(Endpoint_ConfigureEndpoint(ENDPOINT_DIR_IN | IN_ENDPOINT_ADDR,
	                                  EP_TYPE_BULK,
	                                  ENDPOINT_SIZE,
	                                  1)) )
	{
	#ifdef DEBUG
		usartSendFlashString(PSTR("Failed to config IN endpoint\r"));
	#endif
	}
}
