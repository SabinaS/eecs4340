#ifndef _AES_H
#define	_AES_H

void aes_encrypt_block( unsigned char* buf, unsigned char* key );
void aes_decrypt_block( unsigned char* buf, unsigned char* key );

int	getSBoxValue(int num);
void	KeyExpansion( void );
void 	invKeyExpansion(void);
void	AddRoundKey(int round);
void	SubBytes( void );
void	ShiftRows( void );
void	MixColumns( void );
void	Cipher( void );
int	main_example( void );
void 	main_example2( void);
int 	getSBoxInvert(int num);
void	InvShiftRows(void);
void 	InvSubBytes(void);
void 	InvMixColumns(void);
void	InvCipher(void);

#endif
