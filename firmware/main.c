/* 
 * Copyright (C) 2010 Chris McClelland
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
#include "makestuff.h"
#include "desc.h"

// sudo minicom -b 115200 -D /dev/ttyS0 -o -w -8
#define DEBUG_MASK 0x08
#ifdef DEBUG
#define BAUD 45
void usartSendByte(uint8 byte) {
	const uint8 hi = PORTB | DEBUG_MASK;
	const uint8 lo = PORTB & (~DEBUG_MASK);
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
void usartSendByteHex(uint8 byte) {
	uint8 ch;
	ch = (byte >> 4) & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
	ch = byte & 0x0F;
	ch += (ch < 10 ) ? '0' : 'A' - 10;
	usartSendByte(ch);
}
void usartSendWordHex(uint16 word) {
	uint8 ch;
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
void usartSendLongHex(uint32 word) {
	uint8 ch;
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

static uint8 recvBuf[64];
static uint8 sendBuf[64];
static uint8 channel;
static uint8 command;
static uint8 param1;
static uint8 param2;
static union {
	uint16 word;
	uint8 bytes[2];
} dataLength;
static uint8 index;
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
	uint8 ch;
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
			index = 0;
			Endpoint_SelectEndpoint(IN_ENDPOINT_ADDR);
			Endpoint_WaitUntilReady();
			Endpoint_Write_Stream_LE(&channel, 6, NULL);
			Endpoint_ClearIN();
			if ( dataLength.word ) {
				state = GET_DATA;
			} else {
				state = SEND_PREP;
			}
			ackByte();
			#ifdef DEBUG
				usartSendByte('f');
				usartSendByteHex(ch);
				usartSendByte(',');
			#endif
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
			recvBuf[index++] = ch = PIND;
			dataLength.word--;
			if ( !dataLength.word ) {
				// last chunk...send what we have
				Endpoint_SelectEndpoint(IN_ENDPOINT_ADDR);
				Endpoint_WaitUntilReady();
				Endpoint_Write_Stream_LE(recvBuf, index, NULL);
				Endpoint_ClearIN();
				state = SEND_PREP;
			} else {
				index &= 0x3F;
				if ( !index ) {
					// we filled a chunk...send it
					Endpoint_SelectEndpoint(IN_ENDPOINT_ADDR);
					Endpoint_WaitUntilReady();
					Endpoint_Write_Stream_LE(recvBuf, 64, NULL);
				}
			}
			ackByte();
			#ifdef DEBUG
				usartSendByte('g');
				usartSendByteHex(ch);
				usartSendByte(',');
			#endif
			break;
		}
		case SEND_PREP:{
			DDRD = 0xFF;
			state = SEND_RETCODE;
			ackByte();
			#ifdef DEBUG
				usartSendByte('h');
				usartSendByte(',');
			#endif
			break;
		}
		case SEND_RETCODE:{
			Endpoint_SelectEndpoint(OUT_ENDPOINT_ADDR);
			Endpoint_Read_Stream_LE(sendBuf, 3, NULL);
			Endpoint_ClearOUT();
			dataLength.bytes[0] = sendBuf[1];
			dataLength.bytes[1] = sendBuf[2];
			index = 0;
			PORTD = ch = sendBuf[0];  // Return code
			state = SEND_LENGTH_LOW;
			ackByte();
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
			index = 0;
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
			if ( index == 0 ) {
				Endpoint_SelectEndpoint(OUT_ENDPOINT_ADDR);
				if ( dataLength.word >= 64 ) {
					Endpoint_Read_Stream_LE(sendBuf, 64, NULL);
				} else {
					Endpoint_Read_Stream_LE(sendBuf, dataLength.word, NULL);
				}
				Endpoint_ClearOUT();
			}
			PORTD = ch = sendBuf[index++];
			dataLength.word--;
			if ( !dataLength.word ) {
				state = FINISH;
			} else {
				index &= 0x3F;
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
	if ( !(Endpoint_ConfigureEndpoint(OUT_ENDPOINT_ADDR,
	                                  EP_TYPE_BULK,
	                                  ENDPOINT_DIR_OUT,
	                                  ENDPOINT_SIZE,
	                                  ENDPOINT_BANK_SINGLE)) )
	{
		// Failed to config OUT endpoint
	}
	if ( !(Endpoint_ConfigureEndpoint(IN_ENDPOINT_ADDR,
	                                  EP_TYPE_BULK,
	                                  ENDPOINT_DIR_IN,
	                                  ENDPOINT_SIZE,
	                                  ENDPOINT_BANK_SINGLE)) )
	{
		// Failed to config IN endpoint
	}
}
