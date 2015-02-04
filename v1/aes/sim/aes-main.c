#include <stdio.h>
#include <sys/stat.h>
#include <string.h>
#include <stdlib.h>
#include "hwlink.h"

//config_t config;

int main()
{

	int i,j;
	
	printf("\nAES Encryptor\n");
	printf("==================\n");
	
	{
		
		// TODO: ADD CONFIG LOGIC HERE

	FILE *fp; 
	int size_of_file;

	char * filename = "input.txt";

	struct stat file_stat; // to store file statistics	
	
	if(stat(filename, &file_stat) < 0)
	{	
		printf("File not found.\n");
		exit(1);
	}


	size_of_file = file_stat.st_size; // get size of file

	printf("Size of file: %d\n", size_of_file);
	
	fp = fopen(filename, "r"); // open file for reading
	
	if (fp == NULL)
	{
		printf("Could not open file.\n");
		exit(1);
	}

	unsigned char buf[16 + 1] = ""; // to store input
	//while (fgets(buf, 16, fp) != NULL)
		{
	//fgets(buf, 16, fp);
	for (i = 0; i < 16; i++)
	{
		fscanf(fp, "%02x", &buf[i]);
	}
	//printf("Last char: %02x\n", buf[15]);		
					

		//unsigned char buf[] = {0x6b,0xc1,0xbe,0xe2,0x2e,0x40,0x9f,0x96,0xe9,0x3d,0x7e,0x11,0x73,0x93,0x17,0x2a};
		unsigned char key[] = {0x2b,0x7e,0x15,0x16,0x28,0xae,0xd2,0xa6,0xab,0xf7,0x15,0x88,0x09,0xcf,0x4f,0x3c};

		printf("Size of buf: %d\n", strlen(buf));
		
		// print before encryption
		printf("Cleartext:\n");
		for (j=0 ; j<16 ; j++)
		{
			printf( "%02x", buf[j] );
			//printf("%c", buf[j]);
		}
			printf( "\n" );	

		printf("Key:\n");
		// print the key
		for (j=0 ; j<16 ; j++)
		{
			printf( "%02x", key[j] );
		}
			printf( "\n" );	
		

		aes_encrypt_block( buf, key );

		printf("Cyphertext:\n");
		for (j=0 ; j<16 ; j++)
		{
			printf( "%02x", buf[j] );
			//printf("%c", buf[j]);
		}
	
		printf( "\n" );

//unsigned char buf_temp[] = {0x39,0x25,0x84,0x1d,0x02,0xdc,0x09,0xfb,0xdc,0x11,0x85,0x97,0x19,0x6a,0x0b,0x32};		



		aes_decrypt_block(buf,key);

		printf("Cleartext:\n");
		for (j=0 ; j<16 ; j++)
		{
			printf( "%02x", buf[j] );
			//printf("%c", buf[j]);
		}
			printf( "\n\n" );	

		
		
		fclose(fp);
	}

}
	
	//	printf("In aes-main.c\n");
}

