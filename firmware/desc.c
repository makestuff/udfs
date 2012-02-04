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
#include "desc.h"

static USBDeviceDescriptor PROGMEM deviceDescriptor = {
	.Header = {
		.Size = sizeof(USBDeviceDescriptor),
		.Type = DTYPE_Device
	},
	.USBSpecification = VERSION_BCD(01.10),
	.Class = 0xff,
	.SubClass = 0xff,
	.Protocol = 0xff,
	.Endpoint0Size = FIXED_CONTROL_ENDPOINT_SIZE,
	.VendorID = 0x03EB,
	.ProductID = 0x3002,
	.ReleaseNumber = 0x0000,
	.ManufacturerStrIndex = 0x01,
	.ProductStrIndex = 0x02,
	.SerialNumStrIndex = NO_DESCRIPTOR,
	.NumberOfConfigurations = FIXED_NUM_CONFIGURATIONS
};

static USBConfigurationDescriptor PROGMEM configurationDescriptor = {
	.ConfigurationHeader = {
		.Header = {
			.Size = sizeof(USBConfigurationDescriptorHeader),
			.Type = DTYPE_Configuration
		},
		.TotalConfigurationSize = sizeof(USBConfigurationDescriptor),
		.TotalInterfaces = 1,
		.ConfigurationNumber = 1,
		.ConfigurationStrIndex = NO_DESCRIPTOR,
		.ConfigAttributes = (USB_CONFIG_ATTR_BUSPOWERED | USB_CONFIG_ATTR_SELFPOWERED),
		.MaxPowerConsumption = USB_CONFIG_POWER_MA(100)
	},
	.Interface = {
		.Header = {
			.Size = sizeof(USBInterfaceDescriptor),
			.Type = DTYPE_Interface
		},
		.InterfaceNumber = 0,
		.AlternateSetting = 0,
		.TotalEndpoints = 2,
		.Class = 0xff,
		.SubClass = 0xff,
		.Protocol = 0xff,
		.InterfaceStrIndex = NO_DESCRIPTOR
	},
	.InEndpoint = {
		.Header = {
			.Size = sizeof(USBEndpointDescriptor),
			.Type = DTYPE_Endpoint
		},
		.EndpointAddress = (ENDPOINT_DESCRIPTOR_DIR_IN | IN_ENDPOINT_ADDR),
		.Attributes = (EP_TYPE_BULK | ENDPOINT_ATTR_NO_SYNC | ENDPOINT_USAGE_DATA),
		.EndpointSize = ENDPOINT_SIZE,
		.PollingIntervalMS = 0xFF
	},
	.OutEndpoint = {
		.Header = {
			.Size = sizeof(USBEndpointDescriptor),
			.Type = DTYPE_Endpoint
		},
		.EndpointAddress = (ENDPOINT_DESCRIPTOR_DIR_OUT | OUT_ENDPOINT_ADDR),
		.Attributes = (EP_TYPE_BULK | ENDPOINT_ATTR_NO_SYNC | ENDPOINT_USAGE_DATA),
		.EndpointSize = ENDPOINT_SIZE,
		.PollingIntervalMS = 0xFF
	}
};

static USBStringDescriptor PROGMEM languageString = {
	.Header = {
		.Size = USB_STRING_LEN(1),
		.Type = DTYPE_String
	},
	.UnicodeString = {LANGUAGE_ID_ENG}
};

static USBStringDescriptor PROGMEM manufacturerString = {
	.Header = {
		.Size = USB_STRING_LEN(18),
		.Type = DTYPE_String
	},
	.UnicodeString          = L"Swaton Electronics"
};

static USBStringDescriptor PROGMEM productString = {
	.Header = {
		.Size = USB_STRING_LEN(17),
		.Type = DTYPE_String
	},
	.UnicodeString          = L"NeroJTAG/AVR v1.0"
};

uint16_t CALLBACK_USB_GetDescriptor(const uint16_t wValue, const uint8_t wIndex, const void** const descriptorAddress) {
	const uint8_t descriptorType = (wValue >> 8);
	const uint8_t descriptorNumber = (wValue & 0xFF);

	void *address = NULL;
	uint16_t size = NO_DESCRIPTOR;

	switch ( descriptorType ) {
		case DTYPE_Device:
			address = (void*)&deviceDescriptor;
			size = sizeof(USBDeviceDescriptor);
			break;
		case DTYPE_Configuration: 
			address = (void*)&configurationDescriptor;
			size = sizeof(USBConfigurationDescriptor);
			break;
		case DTYPE_String: 
			switch ( descriptorNumber ) {
				case 0x00: 
					address = (void*)&languageString;
					size = pgm_read_byte(&languageString.Header.Size);
					break;
				case 0x01: 
					address = (void*)&manufacturerString;
					size = pgm_read_byte(&manufacturerString.Header.Size);
					break;
				case 0x02: 
					address = (void*)&productString;
					size = pgm_read_byte(&productString.Header.Size);
					break;
			}
			break;
	}
	
	*descriptorAddress = address;		
	return size;
}
