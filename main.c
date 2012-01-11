/* 
 * Copyright (C) 2009 Chris McClelland
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
#include <libusbwrap.h>
#include <usb.h>
#include <argtable2.h>
#include <liberror.h>

struct ReqHeader {
	uint8 channel;
	uint8 command;
	uint8 param1;
	uint8 param2;
	uint16 length;
};

struct RspHeader {
	bitfield returnCode : 8;
	bitfield length : 16;
	bitfield padding : 8;
};

enum {
	DEFAULT = 0
};

enum {
	CALC = 0,
	READ_BLOCK,
	RW_FILE
};

enum {
	RC_SUCCESS = 0,
	RC_UNRECOGNISED_COMMAND,
	RC_UNRECOGNISED_CHANNEL
};

uint8 diskImage[200*1024];

void executeRequest(const struct ReqHeader *reqHeader, const uint8 *reqBuffer, struct RspHeader *rspHeader, uint8 *rspBuffer) {
	int i;
	if ( reqHeader->channel == DEFAULT ) {
		switch ( reqHeader->command ) {
		case CALC:{
			printf("CALC(0x%02X, 0x%02X)\n", reqHeader->param1, reqHeader->param2);
			rspBuffer[0] = reqHeader->param1 + reqHeader->param2;
			rspBuffer[1] = reqHeader->param1 - reqHeader->param2;
			rspBuffer[2] = reqHeader->param1 * reqHeader->param2;
			rspBuffer[3] = reqHeader->param1 / reqHeader->param2;
			rspHeader->returnCode = RC_SUCCESS;
			rspHeader->length = 4;
			break;
		}

		case READ_BLOCK:{
			int block = ((reqBuffer[1] & 0x03) << 8) | reqBuffer[0];
			int numBytes = (reqBuffer[3] << 8) | reqBuffer[2];
			const uint8 *src = diskImage + (256 * block);
			uint8 *dst = rspBuffer;
			printf("READ_BLOCK(0x%03X, 0x%04X)\n", block, numBytes);
			for ( i = 0; i < numBytes; i++ ) {
				*dst++ = *src++;
			}
			rspHeader->returnCode = RC_SUCCESS;
			rspHeader->length = numBytes;
			break;
		}

		case RW_FILE:{
			FILE *file = fopen("from_bbc.dat", "wb");
			size_t fileLen;
			fwrite(reqBuffer, 1, reqHeader->length, file);
			fclose(file);
			file = fopen("to_bbc.dat", "rb");
			fileLen = fread(rspBuffer, 1, 65536, file);
			fclose(file);
			printf("RW_FILE(0x%04X from BBC, 0x%04zX to BBC)\n", reqHeader->length, fileLen);
			rspHeader->returnCode = RC_SUCCESS;
			rspHeader->length = fileLen;
			break;
		}

		default:
			rspHeader->returnCode = RC_UNRECOGNISED_COMMAND;
			rspHeader->length = 0;
			break;
		}
	} else {
		rspHeader->returnCode = RC_UNRECOGNISED_CHANNEL;
		rspHeader->length = 0;
	}
}

void dumpSimple(const unsigned char *input, unsigned int length) {
	while ( length ) {
		printf(" %02X", *input++);
		--length;
	}
	printf("\n");
}

int main(int argc, char *argv[]) {

	struct arg_str *vpOpt  = arg_str1("v", "vidpid", "<VID:PID>", " vendor ID and product ID (e.g 04B4:8613)");
	struct arg_file *fileOpt = arg_file1(NULL, NULL, "<disk.ssd>", "             the disk image to load\n");
	struct arg_lit  *helpOpt = arg_lit0("h", "help", "             print this help and exit");
	struct arg_end  *endOpt  = arg_end(20);
	void* argTable[] = {helpOpt, vpOpt, fileOpt, endOpt};
	const char *progName = "poll";
	int numErrors;
	struct usb_dev_handle *deviceHandle = NULL;
	int returnCode = 0;
	const char *error;
	union {
		struct ReqHeader s;
		uint8 bytes[6];
	} reqHeader;
	union {
		struct RspHeader s;
		uint8 bytes[4];
	} rspHeader;
	uint8 reqBuffer[65536];
	uint8 rspBuffer[65536];
	FILE *file;

	if ( arg_nullcheck(argTable) != 0 ) {
		printf("%s: insufficient memory\n", progName);
		FAIL(1);
	}

	numErrors = arg_parse(argc, argv, argTable);

	if ( helpOpt->count > 0 ) {
		printf("UDFS Server Copyright (C) 2011 Chris McClelland\n\nUsage: %s", progName);
		arg_print_syntax(stdout, argTable, "\n");
		printf("\nServe a BBC Micro Disc Image.\n\n");
		arg_print_glossary(stdout, argTable,"  %-10s %s\n");
		FAIL(0);
	}

	if ( numErrors > 0 ) {
		arg_print_errors(stdout, endOpt, progName);
		printf("Try '%s --help' for more information.\n", progName);
		FAIL(2);
	}

	file = fopen(fileOpt->filename[0], "rb");
	fread(diskImage, 200*1024, 1, file);
	fclose(file);

	usbInitialise();
	returnCode = usbOpenDeviceVP(vpOpt->sval[0], 1, 0, 0, &deviceHandle, &error);
	if ( returnCode ) {
		fprintf(stderr, "usbOpenDevice() failed: %s\n", error);
		errFree(error);
		FAIL(6);
	}
	for ( ; ; ) {
		// Get request header
		do {
			returnCode = usb_bulk_read(deviceHandle, USB_ENDPOINT_IN | 4, (char*)reqHeader.bytes, 6, 100);
		} while ( returnCode < 0 );
		if ( returnCode != 6 ) {
			printf("Expected to read six bytes but actually read %d: %s\n", returnCode, usb_strerror());
			FAIL(7);
		}

		// Get request body
		if ( reqHeader.s.length ) {
			do {
				returnCode = usb_bulk_read(deviceHandle, USB_ENDPOINT_IN | 4, (char*)reqBuffer, reqHeader.s.length, 60000);
			} while ( returnCode < 0 );
			if ( returnCode != reqHeader.s.length ) {
				printf("Expected to read %d bytes but actually read %d: %s\n", reqHeader.s.length, returnCode, usb_strerror());
				FAIL(7);
			}
		}
		// Execute the incoming request
		executeRequest(&reqHeader.s, reqBuffer, &rspHeader.s, rspBuffer);

		// Send response header
		returnCode = usb_bulk_write(deviceHandle, USB_ENDPOINT_OUT | 2, (char*)rspHeader.bytes, 3, 5000);

		// Send response body
		if ( rspHeader.s.length ) {
			//printf("About to write %X bytes...\n", rspHeader.s.length);
			returnCode = usb_bulk_write(deviceHandle, USB_ENDPOINT_OUT | 2, (char*)rspBuffer, rspHeader.s.length, 60000);
			//printf("Write completed returnCode %d\n", returnCode);
		}
	}

cleanup:
	if ( deviceHandle ) {
		usb_release_interface(deviceHandle, 0);
		usb_close(deviceHandle);
	}
	arg_freetable(argTable, sizeof(argTable)/sizeof(argTable[0]));

	return returnCode;
}
