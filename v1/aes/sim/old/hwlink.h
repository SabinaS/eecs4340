#ifndef _HWLINK_H
#define	_HWLINK_H

#include "types.h"
#include "config.h"

#define	DUMP(a) \
	printf( "%-16s %08x\n", #a, a );


typedef struct
{
	bool rst;
	bool clk;

/*
	u32 flit_i;
	bool sop_i;
		
	bool cwr;
	u8 caddr;
	u8 cdata;
	
	u32 flit_o;
	bool sop_o;

*/

	aes_data data_in;
	aes_data data_out; 
	aes_data key;

	bool sel;

} ports_t;


extern ports_t sim;
extern ports_t dut;


bool	hwl_writeConfig( config_t* cfg );
bool	hwl_shiftPacket( u8* pkt );
void	hwl_dump( void );
void	hwl_writeRandomConfig( void );
void	hwl_shiftRandomPacket( void );
void	hwl_randomizeConfig( config_t* cfg );
void	hwl_randomizePacket( u8* buf );
bool	hwl_packetError( void );
bool	hwl_delay( int d );
void	hwl_reset( void );

#endif

