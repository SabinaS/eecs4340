#include "svdpi.h"
#include "svdpi_src.h"

#include <stdio.h>
#include <openssl/md5.h>
#include <openssl/rsa.h>
#include <openssl/engine.h>
#include <openssl/bn.h>

#include "aes.h"

void md5hash(char *src, char *res, int in_len) {
	MD5(src, in_len, res);
}

void aes_encrypt(char* key, char *src, char *res, int in_len /* bytes */) {
	memmove(res, src, in_len);

	/* in-place modification of res */
	aes_encrypt_block(res,key);
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

svLogicPackedArrRef retrieve_modulus() {
	return &modulus;
}

svLogicPackedArrRef retrieve_private_key() {
	return &private_key;
}
