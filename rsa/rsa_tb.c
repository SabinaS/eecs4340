#include "svdpi.h"

#include <stdio.h>
#include <openssl/md5.h>

#include "aes.h"

void md5hash(char *src, char *res, int in_len) {
	MD5(src, in_len, res);
}

void aes_decrypt(char* key, char *src, char *res, int in_len /* bytes */) {
	memmove(res, src, in_len);

	/* in-place modification of res */
	aes_decrypt_block(res,key);
}
