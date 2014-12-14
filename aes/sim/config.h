#ifndef	_CONFIG_H
#define	_CONFIG_H

#include "types.h"

typedef struct
{
	bool sel;
	u8 key[16];

} config_t;

// new
void 	cfg_mode(bool sel);
void	cfg_setKey( u8* key );

extern config_t config;

#endif

