// version 1.0 11/12/2022
#include <stdio.h>
#include "cipher.h"

#ifdef MYENCRYPT_C
TODO("using Cencrypt.c");
/*
 * reverse each byte in iobuf and do an EOR with the corresponding byte in bookbuf
 * param iobuf: bytes to be encrypted
 * param bookbuf: encryption key
 * param cnt: number of bytes
 * return: cnt
 */
int
encrypt(char *iobuf, char *bookbuf, int cnt)
{
    unsigned int iobyte;                     //each byte of iobuf
    int num = cnt;                           //copy of cnt
    unsigned int reviobyte;                  //reverse of iobyte
    while (num > 0) {
	reviobyte = 0;
        iobyte = *iobuf;
	for (int i = 0; i < 8; i++) {
	    reviobyte = (reviobyte << 1) + (iobyte % 2);
	    iobyte = iobyte >> 1;
	}
	*iobuf = reviobyte ^ *bookbuf;
	bookbuf++;
	iobuf++;
	num--;
    }
    return cnt;
}

#elif defined MYENCRYPT_S
TODO("using encrypt.S");
#else
TODO("using solution encrypt");
#endif
