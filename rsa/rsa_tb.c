#include "svdpi.h"

#include <stdio.h>
#include <openssl/md5.h>

long long md5hash(char *src, char *res, int in_len) {
	MD5(src, in_len, res);

	printf("%s\n%s\n", src, res);
}
