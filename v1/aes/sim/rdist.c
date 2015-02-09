#include "random.h"

// Note from Yipeng: as far as I can tell, rdist is no longer needed because the only call to it is in old code for injecting errors into packet headers
int rdist( int* wt )
{
	int sum = 0, i, n;
	
	for (i=0 ; wt[i]>=0 ; i++ )
		sum += wt[i];

	if ( sum == 0 )
		return RAND(0,i-1);

	int r = RAND(1,sum);

	sum=0;

	for (i=0 ; sum<r ; i++)
		sum += wt[i];

	return i-1;
}