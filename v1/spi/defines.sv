// The speed of the system clock
`define CLK_MHZ 50
// The width of the device communication with the FAT32 module. Must evenly divide RW_BUF_SIZE
`define BUS_WIDTH 128

// The number of cycles to wait to toggle sclk in normal operation; targeting 25 MHz
`define SPI_CYCLE (`CLK_MHZ*1000000)/25000000
// The number of cycles elapsed in CLK_MHZ to wait to toggle sclk during initialization
`define SPI_CYCLE_INIT (`CLK_MHZ*1000000)/400000
// The number of bits needed to represent SPI_CYCLE_INIT
`define SPI_CYCLE_INIT_WIDTH $clog2(`SPI_CYCLE_INIT+1)

// The number of cycles to toggle SCLK for during initialization
`define SCLK_WAIT 74
// The number of bits needed to represent SCLK_WAIT
`define SCLK_WAIT_WIDTH $clog2(`SCLK_WAIT+1)

// The number of cycles to wait for a millisecond to elapse..
`define CYCLE_MILLISECOND (`CLK_MHZ*1000000)/1000
// The number of bytes needed to represent MILLISECOND_MHZ
`define CYCLE_MILLISECOND_WDITH $clog2(`CYCLE_MILLISECOND+1)

// TIMEOUT after 10 ms
`define TIMEOUT (`CLK_MHZ*1000000)/100
`define TIMEOUT_WIDTH $clog2(`TIMEOUT+1)

`define R1_SIZE 8
`define R1_SIZE_WIDTH $clog2(`R1_SIZE+1)

`define R3_SIZE 8*5
`define R3_SIZE_WIDTH $clog2(`R3_SIZE+1)

`define COMMAND_SIZE 8*6
`define COMMAND_SIZE_WIDTH $clog2(`COMMAND_SIZE+1)

`define RW_ADDRESS_SIZE 23
`define RW_AMOUNT_SIZE 22
`define RW_ADDRESS_START 0
`define RW_ADDRESS_END `RW_ADDRESS_START+`RW_ADDRESS_SIZE-1
`define RW_AMOUNT_START `RW_ADDRESS_END+1
`define RW_AMOUNT_END `RW_AMOUNT_START+`RW_AMOUNT_SIZE-1

`define SD_BLOCK_SIZE 512*8
`define SD_BLOCK_SIZE_WIDTH $clog2(`SD_BLOCK_SIZE+1)
`define BB_SLOTS (`SD_BLOCK_SIZE/`BUS_WIDTH)
`define BB_SLOTS_WIDTH $clog2(`BB_SLOTS+1)
`define RW_BUF_COUNT 8
`define RW_BUF_COUNT_WIDTH $clog2(`RW_BUF_COUNT+1)
`define RW_BUF_SIZE (`SD_BLOCK_SIZE*`RW_BUF_COUNT)
`define RW_BUF_SIZE_WDITH $clog2(`RW_BUF_SIZE+1)

`define START_TOKEN_SIZE 8
`define START_TOKEN_SIZE_WIDTH $clog2(`START_TOKEN_SIZE+1)
`define DAT_RSP_SIZE 4
`define DAT_RSP_SIZE_WIDTH $clog2(`DAT_RSP_SIZE+1)

`define START_TOKEN_NOT_MULT_WRITE 8'hfe;
