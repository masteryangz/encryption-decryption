// version 1.0 11/12/2022
#include <stdio.h>
#include "cipher.h"

#ifdef MYDECRYPT_C
TODO("using Cdecrypt.c");
/*
 * decrypt the iobuf
 * param iobuf: the encrypted string
 * param bookbuf: the book key
 * param cnt: number of bytes in iobuf
 * return: cnt
 */
int
decrypt(char *iobuf, char *bookbuf, int cnt)
{
    unsigned int iobyte;     //each byte in iobuf
    int num = cnt;           //number of bytes in iobuf
    unsigned int reviobyte;  //reversed byte of iobuf
    while (num > 0) {
        reviobyte = 0;
	iobyte = *iobuf ^ *bookbuf;
	for (int i = 0; i < 8; i++) {
	    reviobyte = (reviobyte << 1) + (iobyte % 2);
	    iobyte = iobyte >> 1;
	}
	*iobuf = reviobyte;
	bookbuf++;
	iobuf++;
	num--;
    }
    return cnt;
}

#elif defined MYDECRYPT_S
TODO("using decrypt.S");
#else
TODO("using solution decrypt");
#endif
