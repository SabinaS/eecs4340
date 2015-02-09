#ifndef	_CONFIG_H
#define	_CONFIG_H

#include "types.h"

typedef struct
{
	//u32 addr;
	bool sel;
	u8 key[16];

} config_t;

//void	cfg_setAddr( u32 addr );
void	cfg_write( config_t* cfg );
//void	cfg_dump( void );

// new
void 	cfg_mode(bool sel);
void	cfg_setKey( u8* key );


extern config_t config;

#endif

