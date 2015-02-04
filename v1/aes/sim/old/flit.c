#include "flit.h"
#include "types.h"
#include "packet.h"

void deflit( u8* buf, pipeflit_t* f )
{
	int i;
	
	for (i=0 ; i<PKT_FLITS ; i++ )
	{
		*(u32*)&buf[i*4] = ntohl( f[PKT_FLITS-1-i].flit );
	}
}

void reflit( pipeflit_t* f, u8* buf )
{
	int i;

	for (i=0 ; i<PKT_FLITS ; i++ )
	{
		f[PKT_FLITS-1-i].flit = htonl( *(u32*)&buf[i*4] );
	}
}


