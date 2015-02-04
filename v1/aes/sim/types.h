#ifndef _TYPES_H
#define _TYPES_H

#define	u64 unsigned long
#define	u32	unsigned int
#define	u16 unsigned short
#define	u8	unsigned char

#define	bool unsigned char

typedef struct
{
	u32 data_0;
	u32 data_1;
	u32 data_2;
	u32 data_3;

} aes_data;

#define true	1
#define false	0

#ifndef NULL
#define	NULL	((void*)0)
#endif

#endif


