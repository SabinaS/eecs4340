#ifndef	_FLIT_H
#define	_FLIT_H

#include "types.h"


typedef struct
{
	u32 flit;
	bool valid;
	bool error;
	u8 n; //what is n?

} pipeflit_t;


void	deflit( u8* buf, pipeflit_t* f );
void	reflit( pipeflit_t* f, u8* buf );


#endif

