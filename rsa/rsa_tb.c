#include "svdpi.h"
#include "svdpi_src.h"

#include <stdio.h>
#include <stdlib.h>
#include <openssl/evp.h>
#include <openssl/md5.h>
#include <openssl/rsa.h>
#include <openssl/engine.h>
#include <openssl/bn.h>

#include "aes.h"

#define MD5_OUT_SIZE 16

char *hash;

void md5hash(char *src, svBitPackedArrRef res, int in_len) {
	int i;
	char *src_cpy = malloc(in_len);
	
	memcpy(src_cpy, src, in_len);

	char *res_char = malloc(MD5_OUT_SIZE);
	memset(res_char, 0, MD5_OUT_SIZE);

	/* hash it doe */
	EVP_MD *md = EVP_md5();
	EVP_MD_CTX *ctx = EVP_MD_CTX_create();

	EVP_DigestInit_ex(ctx, md, NULL);
	EVP_DigestUpdate(ctx, src_cpy, in_len);
	EVP_DigestFinal_ex(ctx, res_char, NULL);

	EVP_MD_CTX_destroy(ctx);

	for (i = 0; i < MD5_OUT_SIZE; ++i) {
		printf("%02x ", ((char *)res_char)[i] & 0xff);
	}

	hash = malloc(MD5_OUT_SIZE);
	memcpy(hash, res_char, MD5_OUT_SIZE);

	/* byte ordering mess */
	for (i = 0; i < MD5_OUT_SIZE / 2; ++i) {
		char tmp = res_char[i];
		res_char[i] = res_char[MD5_OUT_SIZE - 1 - i];
		res_char[MD5_OUT_SIZE - 1 - i] = tmp;
	}

	memcpy(res, res_char, MD5_OUT_SIZE);

	printf("MD5::\n");
	for (i = 0; i < in_len; ++i) {
		printf("%02x ", ((char *)src)[i] & 0xff);
	}
	printf("\n");
	for (i = 0; i < MD5_OUT_SIZE; ++i) {
		printf("%02x ", ((char *)res)[i] & 0xff);
	}
	printf("\n");

	free(res_char);
}

void aes_encrypt(svBitPackedArrRef key, svBitPackedArrRef src,
		svLogicPackedArrRef res, int in_len /* bytes */) {
	char *key_char = malloc(sizeof *key_char * in_len);
	char *res_char = malloc(sizeof *res_char * in_len);
	memmove(key_char, key, in_len);
	memmove(res_char, src, in_len);

//	memmove(key_char, hash, in_len);
	//memmove(res_char, hash, in_len);
	int i;
	for (i = 0; i < in_len / 2; ++i) {
		char tmp = res_char[i];
		res_char[i] = res_char[in_len - 1 - i];
		res_char[in_len - 1 - i] = tmp;
	}

	for (i = 0; i < 16 / 2; ++i) {
		char tmp = key_char[i];
		key_char[i] = key_char[in_len - 1 - i];
		key_char[in_len - 1 - i] = tmp;
	}

	/* in-place modification of res */
	aes_encrypt_block(res_char, key_char);

	printf("AES::\n");
	for (i = 0; i < 16; ++i) {
		printf("%02x ", res_char[i] & 0xff);
	}
	printf("\n");

	for (i = 0; i < in_len / 2; ++i) {
		char tmp = res_char[i];
		res_char[i] = res_char[in_len - 1 - i];
		res_char[in_len - 1 - i] = tmp;
	}

	memcpy(res, res_char, in_len);

	free(res_char);
	free(key_char);
}

RSA *rsa_info = NULL;

void generate_rsa_keys_lib(svBitPackedArrRef modulus,
		svBitPackedArrRef private_key) {
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

	char* private_key_reverse = malloc(BN_num_bytes(rsa_info->n));
	memcpy(private_key_reverse, rsa_info->n->d, BN_num_bytes(rsa_info->n));

	/* BN_num_bytes has LSW first; CLIC is little endian*/
	int i;
	int total_bytes = BN_num_bytes(rsa_info->n);
	for (i = 0; i < total_bytes / 2; ++i) {
		char tmp = private_key_reverse[total_bytes - 1 - i];
		private_key_reverse[total_bytes - 1 - i] = private_key_reverse[i];
		private_key_reverse[i] = tmp;
	}

	memset(private_key, 0, 512); /* 4096 / 8 */
	memcpy(private_key, private_key_reverse, total_bytes);
	free(private_key_reverse);

	/* copy private key */
	int num_bits_prk = BN_num_bits(rsa_info->d);
	if (num_bits_prk > 4096) {
		fprintf(stderr, "ERROR: %s: unexpected private key size\n", "gen_rsa_keys");
		return;
	}
	char* mod_reverse = malloc(BN_num_bytes(rsa_info->d));
	memcpy(mod_reverse, rsa_info->d->d, BN_num_bytes(rsa_info->d));

	/* BN_num_bytes has LSW first; CLIC is little endian*/
	total_bytes = BN_num_bytes(rsa_info->d);
	for (i = 0; i < total_bytes / 2; ++i) {
		char tmp = mod_reverse[total_bytes - 1 - i];
		mod_reverse[total_bytes - 1 - i] = mod_reverse[i];
		mod_reverse[i] = tmp;
	}

	memset(modulus, 0, 512); /* 4096 / 8 */
	memcpy(modulus, mod_reverse, total_bytes);
	free(mod_reverse);
}

void rsa_encrypt(svBitPackedArrRef current_aes_key,
		svBitPackedArrRef encrypted_key) {
	if (rsa_info == NULL) {
		fprintf(stderr, "RSA ENCRYPTING WITHOUT RSA KEY. FAILURE.\n");
		exit(EXIT_FAILURE);
	}

	RSA_public_encrypt(128 / 8, current_aes_key, encrypted_key, rsa_info,
		RSA_NO_PADDING);
}

void printout_c (void *ptr, int len) {
	int i;
	for (i = 0; i < len; ++i) {
		printf("%02x ", ((char *)ptr)[i] & 0xff);
	}
	printf("\n");
}

#define printout(num) \
	void printout_##num(svBitPackedArrRef ptr) {\
		printf("\nentering printout_%s %p\n", #num, ptr); \
		printout_c(ptr, num / 8);\
	}

printout(128);
printout(256);
printout(384);
