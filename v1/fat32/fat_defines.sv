`define CHF_NAME_SIZE 8
`define CHF_EXT_SIZE 3

`define AES_DAT_SIZE 128

`define MAX_BLOCK_SIZE 4096
`define MAX_BLOCK_SIZE_WIDTH $clog2(`MAX_BLOCK_SIZE+1)

`define BOOT_CODE_BITS 446*8
`define PART_ENTRY_BITS 16*8

`define PART_COUNT 4
`define PART_COUNT_WIDTH $clog2(`PART_COUNT+1)

`define LBA_BEGIN_SIZE 4*8

`define BPB_BytsPerSec_OFF 'h0B
`define BPB_SecPerClus_OFF 'h0D
`define BPB_RsvdSecCnt_OFF 'h0E
`define BPB_NumFATs_OFF 'h10
`define BPB_FATSz32_OFF 'h24
`define BPB_RootClus_OFF 'h2C

`define BPB_BytsPerSec_SIZE 16
`define BPB_SecPerClus_SIZE 8
`define BPB_RsvdSecCnt_SIZE 16
`define BPB_NumFATs_SIZE 8
`define BPB_FATSz32_SIZE 32
`define BPB_RootClus_SIZE 32

`define DIR_ENTRY_SIZE 32*8
`define DIR_Attr_OFF 'h0B
`define DIR_Attr_Dir_OFF 'h04
`define DIR_FstClusHI_OFF 'h14
`define DIR_FstClusLO_OFF 'h1A
