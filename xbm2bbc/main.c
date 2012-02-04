#include <stdio.h>
#include "mary.xbm"

unsigned char flip(unsigned char x) {
	unsigned char y = 0xFF;
	if ( x & 1 ) { y = y ^ 128; }
	if ( x & 2 ) { y = y ^ 64; }
	if ( x & 4 ) { y = y ^ 32; }
	if ( x & 8 ) { y = y ^ 16; }
	if ( x & 16 ) { y = y ^ 8; }
	if ( x & 32 ) { y = y ^ 4; }
	if ( x & 64 ) { y = y ^ 2; }
	if ( x & 128 ) { y = y ^ 1; }
	return y;
}

int main(void) {
	unsigned char convert[(mary_width/8)*mary_height];
	const unsigned char *src = mary_bits;
	unsigned char *dst = convert;
	int i, j;
	FILE *file = fopen("out.bin", "wb");

	for ( i = 0; i < 32; i++ ) {
		for ( j = 0; j < 40; j++ ) {
			*dst++ = flip(src[0*40]);
			*dst++ = flip(src[1*40]);
			*dst++ = flip(src[2*40]);
			*dst++ = flip(src[3*40]);
			*dst++ = flip(src[4*40]);
			*dst++ = flip(src[5*40]);
			*dst++ = flip(src[6*40]);
			*dst++ = flip(src[7*40]);
			src++;
		}
		src += 7*40;
	}
	printf("src - mary_bits = %d\n", src - mary_bits);
	printf("dst - convert = %d\n", dst - convert);
	fwrite(convert, 1, 10240, file);
	fclose(file);
}
