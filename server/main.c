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
#include <makestuff/libusbwrap.h>
#include <makestuff/liberror.h>
#include <sheitmann/libargtable2.h>

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

#define U32MAX 0xFFFFFFFFU

void executeRequest(const struct ReqHeader *reqHeader, const uint8 *reqBuffer, struct RspHeader *rspHeader, uint8 *rspBuffer) {
	int i;
	if ( reqHeader->channel == DEFAULT ) {
		switch ( reqHeader->command ) {
		case CALC:{
			printf("CALC(0x%02X, 0x%02X)\n", reqHeader->param1, reqHeader->param2);
			rspBuffer[0] = (uint8)(reqHeader->param1 + reqHeader->param2);
			rspBuffer[1] = (uint8)(reqHeader->param1 - reqHeader->param2);
			rspBuffer[2] = (uint8)(reqHeader->param1 * reqHeader->param2);
			rspBuffer[3] = (uint8)(reqHeader->param1 / reqHeader->param2);
			rspHeader->returnCode = RC_SUCCESS;
			rspHeader->length = 4;
			break;
		}

		case READ_BLOCK:{
			uint16 block = (uint16)(((reqBuffer[1] & 0x03) << 8) | reqBuffer[0]);
			uint16 numBytes = (uint16)((reqBuffer[3] << 8) | reqBuffer[2]);
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
			rspHeader->length = (uint16)fileLen;
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
	struct USBDevice *deviceHandle = NULL;
	USBStatus uStatus;
	int retVal = 0;
	const char *error = NULL;
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
		FAIL_RET(1, cleanup);
	}

	numErrors = arg_parse(argc, argv, argTable);

	if ( helpOpt->count > 0 ) {
		printf("UDFS Server Copyright (C) 2011 Chris McClelland\n\nUsage: %s", progName);
		arg_print_syntax(stdout, argTable, "\n");
		printf("\nServe a BBC Micro Disc Image.\n\n");
		arg_print_glossary(stdout, argTable,"  %-10s %s\n");
		FAIL_RET(0, cleanup);
	}

	if ( numErrors > 0 ) {
		arg_print_errors(stdout, endOpt, progName);
		printf("Try '%s --help' for more information.\n", progName);
		FAIL_RET(2, cleanup);
	}

	file = fopen(fileOpt->filename[0], "rb");
	fread(diskImage, 200*1024, 1, file);
	fclose(file);

	uStatus = usbInitialise(0, &error);
	CHECK_STATUS(uStatus, 3, cleanup);

	uStatus = usbOpenDevice(vpOpt->sval[0], 1, 0, 0, &deviceHandle, &error);
	CHECK_STATUS(uStatus, 4, cleanup);

	for ( ; ; ) {
		// Get request header
		do {
			uStatus = usbBulkRead(deviceHandle, 4, reqHeader.bytes, 6, 100, &error);
		} while ( uStatus == USB_TIMEOUT );
		CHECK_STATUS(uStatus, 6, cleanup);

		// Get request body
		if ( reqHeader.s.length ) {
			do {
				uStatus = usbBulkRead(deviceHandle, 4, reqBuffer, reqHeader.s.length, 60000, &error);
			} while ( uStatus == USB_TIMEOUT );
			CHECK_STATUS(uStatus, 7, cleanup);
		}

		// Execute the incoming request
		executeRequest(&reqHeader.s, reqBuffer, &rspHeader.s, rspBuffer);

		// Send response header
		uStatus = usbBulkWrite(deviceHandle, 2, rspHeader.bytes, 3, 5000, &error);
		CHECK_STATUS(uStatus, 8, cleanup);

		// Send response body
		if ( rspHeader.s.length ) {
			uStatus = usbBulkWrite(deviceHandle, 2, rspBuffer, rspHeader.s.length, 60000, &error);
			CHECK_STATUS(uStatus, 9, cleanup);
		}
	}

cleanup:
	if ( error ) {
		fprintf(stderr, "%s\n", error);
		errFree(error);
	}
	if ( deviceHandle ) {
		usbCloseDevice(deviceHandle, 0);
	}
	arg_freetable(argTable, sizeof(argTable)/sizeof(argTable[0]));
	return retVal;
}
