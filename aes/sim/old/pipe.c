#include <string.h>
#include <stdio.h>

#include "pipe.h"
#include "flit.h"
#include "packet.h"

pipe_t pipe;

pipeflit_t pipe_shift(u32 in)
{
	int i;
	
	pipeflit_t* f=pipe.flits;

	pipeflit_t out=f[PIPE_LEN-1];
	
	for (i=PIPE_LEN-1 ; i>0 ; i--)
		f[i] = f[i-1];

	memset( &f[0], 0, sizeof(f[0]) );

	f[0].flit = in;
	if ( pipe.n > 0 )
	{
		f[0].n = PKT_FLITS-pipe.n;
		f[0].valid = true;
		f[0].error = false;

		pipe.n--;
	}
	else
	{
		f[0].valid = false;
		f[0].n = 0;
	}

	if ( pipe_newPacket() )
	{
		pipe_handlePacket();
	}

	return out;
}



void pipe_dump()
{
	int i;
	
	pipeflit_t* f = pipe.flits;

	for (i=0 ; i<PIPE_LEN ; i++)
	{
		if ( i%4 == 0 )
			printf( "%02d: ", i );

		printf( "%08x %02d %c%c  ", f[i].flit, f[i].n, f[i].valid ? 'V' : 'v', f[i].error ? 'E' : 'e' );

		if ( (i+1)%4 == 0 || (i+1)==PIPE_LEN )
			printf( "\n" );
	}

}


void pipe_sop()
{
	pipe.n=PKT_FLITS;
}



bool pipe_newPacket()
{
	// examine 13th flit
	pipeflit_t* f = &pipe.flits[PKT_FLITS-1];

	return f->n == 0 && f->valid == true;
}



void pipe_handlePacket()
{
	u8 pkt[PKT_LEN];
	u8 e;
	
	deflit( pkt, &pipe.flits[0] );

	e = pkt_error(pkt);

	pkt_reflect( pkt );

	if ( e )
	{
		hdr_t* hdr = (hdr_t*)pkt;
		memset( hdr->data, 0, DATA_LEN );

		int i;
		
		for (i=0 ; i<PKT_FLITS ; i++)
			pipe.flits[i].error = 1;
	}
	
	reflit( &pipe.flits[0], pkt );		
}


bool pipe_isEmpty()
{
	int i;
	
	for (i=0 ; i<PIPE_LEN ; i++ )
	{
		if ( pipe.flits[i].valid )
			return false;
	}

	return true;
}
