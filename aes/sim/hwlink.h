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
	bool sel;

	aes_data data_in;
	aes_data data_out; 
	aes_data key;

} ports_t;


extern ports_t sim;
extern ports_t dut;

bool hwl_writeConfig (config_t* cfg);
bool hwl_sendPacket (void);
void hwl_reset (void);

#endif

