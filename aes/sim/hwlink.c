#include <string.h>
#include <stdio.h>

#include "hwlink.h"

#define QUEUE_LENGTH 37

ports_t sim;
ports_t dut;
config_t config;
aes_data queue[QUEUE_LENGTH];

void cfg_mode(bool sel) {
	config.sel = sel;
}

void cfg_setKey( u8* key ) {
	memcpy( config.key, key, 16 );
}

bool hwl_writeConfig (config_t * cfg) {
	sim.sel = cfg->sel;
	
	// TODO: check pointers
	sim.key.data_0 = cfg->key[0];
	sim.key.data_1 = cfg->key[1];
	sim.key.data_2 = cfg->key[2];
	sim.key.data_3 = cfg->key[3];
}

bool hwl_sendPacket () // TODO: Specify argument type
{
	unsigned char buf [16];
	memcpy(&buf[0], &sim.data_in.data_0, 4);
	printf("In hwlink.c: sim.data_in.data_0 = %X\n", sim.data_in.data_0);
	memcpy(&buf[4], &sim.data_in.data_1, 4);
	memcpy(&buf[8], &sim.data_in.data_2, 4);
	memcpy(&buf[12], &sim.data_in.data_3, 4);	

	unsigned char key [16];
	memcpy(&key[0], &sim.key.data_0, 4);
	memcpy(&key[4], &sim.key.data_1, 4);
	memcpy(&key[8], &sim.key.data_2, 4);
	memcpy(&key[12], &sim.key.data_3, 4);
			
	// Gather parameters to pass to encrypt block
	aes_encrypt_block ( buf, key );

	// Pop returned results from queue
	memcpy(&sim.data_out, &queue[QUEUE_LENGTH-1], sizeof(aes_data));

	// Move results along queue
	int i;
	for (i=QUEUE_LENGTH-1; i>0; i--) {
		// printf("i=%d\n",i);
		memcpy(&queue[i], &queue[i-1], sizeof(aes_data));
	}
	
	int j;
	for (j=0; j<4; j++) {		
		char tmp;
		tmp = buf[j*4+0];
		buf[j*4+0] = buf[j*4+3];
		buf[j*4+3] = tmp;
		tmp = buf[j*4+1];
		buf[j*4+1] = buf[j*4+2];
		buf[j*4+2] = tmp;		
	}

	// Add results to queue
	memcpy(&queue[0].data_0, &buf[0], 4);
	memcpy(&queue[0].data_1, &buf[4], 4);
	memcpy(&queue[0].data_2, &buf[8], 4);
	memcpy(&queue[0].data_3, &buf[12], 4);	
	
}

//Note from Yipeng: I think we still need this?
void hwl_reset()
{
	// pkt_n = 0;
	// cfg_n = 0;
	
	memset( &sim, 0, sizeof(sim) );
	memset( &dut, 0, sizeof(dut) );	
	memset( &config, 0, sizeof(config) );
	// memset( &pipe, 0, sizeof(pipe) );	
}
