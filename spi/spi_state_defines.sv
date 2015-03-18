// STATES. The different "states" represented by this device, though more similar to mode of operation. Multiple states can be active at the same time, most commonly, SCLK_ACTIVE_STATE and READ_STATE/WRITE_STATE. Due to this, enums don't suite our purpose
`define STATES 18
// The main states of SPI. A 1 means the state is currently active. At most one of these should be high at any time.
`define INIT_STATE 0
`define IDLE_STATE 1
`define READ_STATE 2
`define WRITE_STATE 3
// The SPI clock is active if this state is high
`define SCLK_ACTIVE_STATE 4
// A value of 1 in this state means 74 SPI cycles have elapsed
`define SCLK_WAIT_STATE 5
`define MILLISECOND_WAIT_STATE 6
`define DO_COMMAND 7
// Response processing
`define RECEIVE_R1_STATE 8
`define RECEIVE_R3_STATE 9
`define RECEIVE_R7_STATE 10
// The command flow of SPI initialization
`define INIT_CMD0_STATE 11
`define INIT_CMD8_STATE 12
`define INIT_ACMD41_STATE 13
`define INIT_CMD58_STATE 14
`define INIT_CMD1_STATE 15
`define INIT_CMD16_STATE 16
`define INIT_CMD8_TIMED_OUT 17

// For shifting in responses
`define R1_RESPONSE_SLOT 0
`define R37_RESPONSE_SLOT 1
