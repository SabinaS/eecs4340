#ifndef	_RAND_H
#define	_RAND_H

#include <stdlib.h>

#define RAND(a,b) \
	(a+(rand()/(RAND_MAX/(b-a+1))))

#define	RAND_FLOAT(a,b) \
	(a+(b-a)*((float)rand()/RAND_MAX))

int	rdist( int* wt );

#endif

