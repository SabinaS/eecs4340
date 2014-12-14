#include <string.h>
#include <stdio.h>

#include "hwlink.h"
#include "packet.h"
#include "config.h"
#include "flit.h"
#include "pipe.h"

#include "random.h"

ports_t sim;
ports_t dut;

int pkt_n;
int cfg_n;


bool hwl_writeConfig( config_t* cfg )
{
	static char buf[20];
	
	if ( cfg != NULL )
	{
		// endianness fix, convert to network order
		//cfg->addr = htonl(cfg->addr);

		memcpy( buf, cfg, sizeof(buf) );
		cfg_n=20;
		return true;
	}


	if (cfg_n > 0 && pipe_isEmpty())
	{
		//sim.caddr = (20-cfg_n);
		sim.cdata = buf[20-cfg_n];
		sim.cwr = true;

		printf( "config write\n" );
		cfg_n--;

		// config write is done... perform write on simulator
		if ( cfg_n == 0 )
		{
			config_t* cfg = (config_t*)buf;

			// back from network to host
			cfg->addr = ntohl(cfg->addr);

			cfg_write( cfg );
		}
	}
	else
	{
		sim.caddr = 0;
		sim.cdata = 0;
		sim.cwr = 0;
	}

	// busy if n != 0
	return cfg_n != 0;
}


bool hwl_shiftPacket( u8* pkt )
{
	static char buf[PKT_LEN];
	u32 flit=0;
	
	sim.sop_i = 0;

	//
	// changes interal state only
	//

	if ( pkt != NULL )
	{
		memcpy( buf, pkt, sizeof(buf) );
		pkt_n=PKT_FLITS;

		pipe_sop();

		return true;
	}


	//
	// input to pipe
	//

	if (pkt_n > 0)
	{
		printf( "flit write\n" );

		flit = htonl( *(u32*)&buf[(PKT_FLITS-pkt_n)*4] );

		if ( pkt_n == PKT_FLITS )
			sim.sop_i = true;

		pkt_n--;
	}

	sim.flit_i = flit;
	pipeflit_t pf;
	pf = pipe_shift( flit );
	
	//
	// output section
	//

	sim.flit_o = pf.flit;

	if ( pf.valid && pf.n == 0 )
		sim.sop_o = 1;
	else
		sim.sop_o = 0;

	return pkt_n != 0;
}


void hwl_dump()
{
	DUMP( sim.caddr );
	DUMP( sim.cdata );
	DUMP( sim.cwr );

	DUMP( sim.sop_i );
	DUMP( sim.flit_i );
	
	DUMP( sim.sop_o );
	DUMP( sim.flit_o );
}




void hwl_writeRandomConfig()
{
	config_t cfg;
	
	hwl_randomizeConfig( &cfg );
	hwl_writeConfig( &cfg );
}

void hwl_shiftRandomPacket()
{
	u8 pkt[PKT_LEN];
	pkt_randomize(pkt);
	hwl_shiftPacket(pkt);
}


void hwl_randomizeConfig( config_t* cfg )
{
	int i;
	
	// don't care about endianness... it's random
	cfg->addr = (RAND(0,0xffff)<<16) | RAND(0,0xffff);

	for (i=0 ; i<16 ; i++)
		cfg->key[i] = RAND(0,255);
}


bool hwl_packetError()
{
	pipeflit_t f = pipe.flits[PIPE_LEN-1];
	
	return ( f.valid && f.error );
}


bool hwl_delay( int d )
{
	static int n=0;
	
	if ( d > 0 )
	{
		n = d;
		return true;
	}

	if ( n-- > 0 )
		return true;

	return false;
}



void hwl_reset()
{
	pkt_n = 0;
	cfg_n = 0;
	
	memset( &config, 0, sizeof(config) );
	memset( &pipe, 0, sizeof(pipe) );	
}

