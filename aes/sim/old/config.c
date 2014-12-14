#include "config.h"
#include <stdio.h>
#include <string.h>


config_t config;

void cfg_setAddr( u32 addr )
{
	config.addr = addr;
}


void cfg_setKey( u8* key )
{
	int i;

	memcpy( config.key, key, 16 );
}


void cfg_write( config_t* cfg )
{
	printf( "config write addr=%08x key=", cfg->addr );

	int i;
	for ( i=0 ; i<20 ; i++ )
		printf( "%02x", cfg->key[i] );
	
	printf( "\n" );
	
	memcpy( &config, cfg, sizeof(config) );
}


void cfg_dump()
{
	int i;

	printf( "addr:%08x key:", ntohl(config.addr) );	

	for (i=0 ; i<16 ; i++ )
	{
		printf( "%02x", config.key[i] );
		if ( (i+1)%4 == 0 && (i+1)<16 )
			printf( "-" );
	}

	printf("\n");
}

