#ifndef	_PIPE_H
#define	_PIPE_h

#include "flit.h"

#define	PIPE_LEN	55


typedef struct
{
	pipeflit_t flits[PIPE_LEN];
	int n;

} pipe_t;


pipeflit_t	pipe_shift(u32 in);
void	pipe_dump( void );
void	pipe_sop( void );
bool	pipe_newPacket( void );
void	pipe_handlePacket( void );
bool	pipe_isEmpty( void );


extern pipe_t pipe;

#endif // _PIPE_H

