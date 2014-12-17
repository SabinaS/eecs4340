#include "svdpi.h"
#include "svdpi_src.h"

#include <stdio.h>
#include <stdlib.h>
#include <openssl/md5.h>
#include <openssl/rsa.h>
#include <openssl/engine.h>
#include <openssl/bn.h>

#include "aes.h"

#define MD5_OUT_SIZE 16

void md5hash(char *src, svLogicPackedArrRef res, int in_len) {
	char *res_char = malloc(sizeof *res_char * MD5_OUT_SIZE);
	MD5(src, in_len, res_char);

	SV_LOGIC_PACKED_ARRAY(128, res_log);
	memcpy(&res_log, res_char, MD5_OUT_SIZE);

	printf("MD5::\n");
	unsigned i;
	for (i = 0; i < in_len; ++i) {
		printf("%x ", ((char *)src)[i] & 0xff);
	}
	printf("\n");
	for (i = 0; i < MD5_OUT_SIZE; ++i) {
		printf("%x ", ((char *)res)[i] & 0xff);
	}
	printf("\n");

	res = res_log;

	free(res_char);
}

void aes_encrypt(svLogicPackedArrRef key, svLogicPackedArrRef src,
		svLogicPackedArrRef res, int in_len /* bytes */) {
printf("aes marker %p %p\n", key, src);
	char *key_char = malloc(sizeof *key_char * in_len);
	char *res_char = malloc(sizeof *res_char * in_len);
	memmove(key_char, key, in_len);
	memmove(res_char, src, in_len);

	/* in-place modification of res */
	aes_encrypt_block(res_char, key_char);
	/* copy it back to the register */
	SV_LOGIC_PACKED_ARRAY(4096, res_log);
	memcpy(&res_log, res_char, in_len);

	res = res_log;

	free(res_char);
	free(key_char);
}

RSA *rsa_info = NULL;
SV_LOGIC_PACKED_ARRAY(4096, modulus);
SV_LOGIC_PACKED_ARRAY(4096, private_key);

void generate_rsa_keys_lib(svLogicPackedArrRef modulus_out,
		svLogicPackedArrRef private_key_out) {
	if (rsa_info != NULL) {
		RSA_free(rsa_info);
		rsa_info = NULL;
	}
	rsa_info = RSA_generate_key(4096, 17 /* public exponent */, NULL, NULL);

	/* copy modulus */
	int num_bits_modulus = BN_num_bits(rsa_info->n);
	if (num_bits_modulus > 4096) {
		fprintf(stderr, "ERROR: %s: unexpected modulus size\n", "gen_rsa_keys");
		return;
	}

	memset(&private_key, 0, 512); /* 4096 / 8 */
	memcpy(&private_key, rsa_info->n->d, BN_num_bytes(rsa_info->n));


	/* copy private key */
	int num_bits_prk = BN_num_bits(rsa_info->d);
	if (num_bits_prk > 4096) {
		fprintf(stderr, "ERROR: %s: unexpected private key size\n", "gen_rsa_keys");
		return;
	}

	memset(&modulus, 0, 512); /* 4096 / 8 */
	memcpy(&private_key, rsa_info->d->d, BN_num_bytes(rsa_info->d));

	modulus_out = modulus;
	private_key_out = private_key;
}
