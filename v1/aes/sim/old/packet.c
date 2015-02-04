#include <stdio.h>
#include <string.h>

#include "packet.h"
#include "types.h"

#include "config.h"
#include "random.h"

#include "aes.h"

bool parity( u32 d )
{
	int i;
	
	int n=0;

	for (i=0 ; i<32 ; i++ )
	{
		if ( d & (1<<i) )
			n++;
	}

	// for even parity, if even (i.e. n%2 == 0 )
	// parity bit will be 0
	return n%2;
}


u16 pkt_cksum( u8* pkt )
{
	// checksum defined as calculated with checksum field set to 0
	u8 old[2] = { pkt[HDR_CKSUM], pkt[HDR_CKSUM+1] };	
	memset( &pkt[HDR_CKSUM], 0, 2 );

	u16 cksum = 0;
	
	int i;
	
	for (i=0 ; i<PKT_FLITS ; i++)
	{
		// don't have to worry about endianness
		cksum |= parity( *(u32*)&pkt[i*4] )<<i;
	}

	pkt[HDR_CKSUM]=old[0];
	pkt[HDR_CKSUM+1]=old[1];

	return cksum;
}



int pkt_error( u8* pkt )
{	
	hdr_t* hdr = (hdr_t*)pkt;

	// vhl 0x45
	if ( hdr->vhl != 0x45 )
		return 1;

	// TOS <= 2
	if ( hdr->tos > 2 )
		return 2;

	// len 52
	if ( hdr->len != htons(52) )
		return 3;
	
	// zeros
	if ( hdr->zero != 0 )
		return 4;

	// ttl != 0
	if ( hdr->ttl == 0 )
		return 5;

	// proto 6
	if ( hdr->proto != 6 )
		return 6;
		
	// cksum
	if ( ntohs(hdr->cksum) != pkt_cksum(pkt) )
		return 7;

	// dstaddr
	if ( ntohl(hdr->dstaddr) != config.addr )
		return 8;


	return 0;
}

bool pkt_valid( u8* pkt )
{
	return pkt_error(pkt) == 0;
}




void pkt_dump( u8* pkt )
{
	int i;
	
	for (i=0 ; i<PKT_LEN ; i++ )
	{
		if ( i%16 == 0 )
			printf( "%02d: ", i );
		
		printf( "%02x ", pkt[i] );

		if ( (i+1)%8 == 0 )
			printf( " " );	

		if ( (i+1)%16 == 0 || (i+1)==PKT_LEN )
			printf( "\n" );
	}
}


void pkt_break( u8* pkt, int field )
{
	hdr_t* hdr = (hdr_t*)pkt;

	u8* ptr;
	u16 len;

	switch ( field )
	{
		case HDR_VHL:
			len=1; break;
 		case HDR_TOS:	
 			hdr->tos = RAND(3,255); len=1; break;
 		case HDR_LEN:
 			len=2; break;
		case HDR_ZERO:
			len=4; break;

		// only way to reliably generate an error with ttl is to zero it
 		case HDR_TTL:
 			len=0; hdr->ttl = 0; break;
 			
 		case HDR_PROTO:
 			len=1; break;
 		case HDR_CKSUM:
 			len=2; break;
 		case HDR_SRCADDR:
 			len=4; break;
 		case HDR_DSTADDR:
 			len=4; break;
		case PKT_DATA:
			len=DATA_LEN; break;

		default:
			len=0; break;
	}

	if ( len == 0 )
		return;

	// 90%, flip a bit
	if ( RAND(1,10) < 10 )
	{
		int byte=RAND(0,len-1);
		int bit=RAND(0,7);

		pkt[field+byte] ^= (1<<bit);		
	}
	
	// 10%, randomize the whole field
	else
	{
		int i;
		for (i=0 ; i<len ; i++)
			pkt[field+i]=RAND(0,255);
	}
}




void pkt_reflect( u8* pkt )
{
	hdr_t* hdr = (hdr_t*)pkt;

	// vhl, tos, len, zero unchanged

	// decrement ttl (8-bit, no byte ordering concerns)
	hdr->ttl--;

	// proto unchanged
	
	// cksum to be calculated after encryption
	
	// change egress dst to ingress src,
	// egress src to local addr
	hdr->dstaddr = hdr->srcaddr;
	hdr->srcaddr = htonl(config.addr);

	// do encryption
	aes_encrypt_block( &hdr->data[0], config.key );
	aes_encrypt_block( &hdr->data[16], config.key );

	// fix checksum
	hdr->cksum = htons( pkt_cksum(pkt) );
}

void pkt_randomize( u8* pkt )
{
	hdr_t* hdr = (hdr_t*)pkt;
	
	pkt_sane(pkt);

	hdr->tos = RAND(0,2);
	hdr->ttl = RAND(1,255);
	hdr->srcaddr = RAND(0,0xffff)<<16 | RAND(0,0xffff);
	
	int i;
	for ( i=0 ; i<DATA_LEN ; i++ )
		hdr->data[i] = RAND(0,255);

	hdr->cksum = htons( pkt_cksum( pkt ) );
}


void pkt_sane( u8* pkt )
{
	hdr_t* hdr = (hdr_t*)pkt;
	
	hdr->vhl = 0x45;
	hdr->tos = 2;
	hdr->len = htons(52);
	hdr->zero = 0;
	hdr->ttl = 1;
	hdr->proto = 6;
	hdr->cksum = 0;
	hdr->srcaddr = htonl( 0x01020304 );
	hdr->dstaddr = htonl( config.addr );

	memset( hdr->data, 0, DATA_LEN );

	hdr->cksum = htons( pkt_cksum( pkt ) );
}