#ifndef	_PACKET_H
#define	_PACKET_H

#include "types.h"


#define	PKT_LEN		52
#define	PKT_FLITS	13

#define	HDR_VHL		0
#define	HDR_TOS		1
#define	HDR_LEN		2
#define	HDR_ZERO	4
#define	HDR_TTL		8
#define	HDR_PROTO	9
#define	HDR_CKSUM	10
#define	HDR_SRCADDR	12
#define	HDR_DSTADDR	16


typedef struct
{
	u8 vhl;
	u8 tos;
	u16 len;
	u32 zero;
	u8 ttl;
	u8 proto;
	u16 cksum;
	u32 srcaddr;
	u32 dstaddr;
	
	u8 data[0];
} hdr_t;

#define	PKT_DATA	(sizeof(hdr_t)-1)
#define	DATA_LEN	32


bool	parity( u32 d );
u16	pkt_cksum( u8* pkt );
int	pkt_error( u8* pkt );
bool	pkt_valid( u8* pkt );
void	pkt_dump( u8* pkt );
void	pkt_break( u8* pkt, int field );
void	pkt_reflect( u8* pkt );
void	pkt_randomize( u8* pkt );
void	pkt_sane( u8* pkt );

#endif

