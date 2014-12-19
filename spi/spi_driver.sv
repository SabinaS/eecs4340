`timescale 1ns/1ns
module spi_driver (
    clk, rst,
    to_slave_o, dat, valid_o, ready_o, ack_o,
    from_slave_i, read_i, write_i, valid_i, ready_i
);

// The speed of clk.
parameter CLK_MHZ               = 50;
// The width of the device communication with the FAT32 module
parameter BUS_WIDTH             = 128;
// The number of cycles to toggle SCLK for during initialization
parameter SCLK_WAIT             = 74;

// See spi_command.sv for definitions
parameter COMMAND_WIDTH         = 6 * 8;

// The number of bits needed to represent SCLK_WAIT
parameter SCLK_WAIT_WIDTH       = $clog2(SCLK_WAIT + 1);
// The number of cycles elapsed in CLK_MHZ to wait to toggle sclk during initialization
parameter SPI_CYCLE_INIT        = (CLK_MHZ * 1000000) / 400000;
// The number of cycles to wait to toggle sclk in normal operation
parameter SPI_CYCLE             = (CLK_MHZ * 1000000) / (25 * 1000000);
// The number of bits needed to represent SPI_CYCLE_INIT
parameter SPI_CYCLE_INIT_WIDTH  = $clog2(SPI_CYCLE_INIT + 1);
// The number of cycles to wait for a millisecond to elapse..
parameter MILLISECOND_MHZ       = (CLK_MHZ * 1000000) * (1 / 1000);
// The number of bytes needed to represent MILLISECOND_MHZ
parameter MILLISECOND_MHZ_WIDTH = $clog2(MILLISECOND_MHZ + 1);

/* the clock and reset signals */
input clk, rst;
/* from_slave_i: the MISO of the SPI protocol */
/* read_i: asserted for a single cycle the fs module to begin a read
    operation. The first data token should be the address information */
/* write_i: asserted for a single cycle (or more, but doesn't matter) by the fs
    module to begin a write operation. The first data token should be the
    address information. */
/* valid_i: asserted by the fs module that the data on dat is valid */
/* ready_i: asserted by the fs module if it is able to receive more data */
input from_slave_i, read_i, write_i, valid_i, ready_i;
// The wires connecting to the SPI slave of this master
output [2:0] to_slave_o;
/* ready_o: indicates to the fs module that this module is ready to receive a
    command */
/* valid_o: indicates to the fs module that this module's data output is valid.
    */
/* ack_o: acknowledges that a command has been received. Will be sent on the
    cycle following the first valid data input, and if not, the command was
    missed */
output ready_o, valid_o, ack_o;
/* The data bus for communicating with the FS module */
inout [BUS_WIDTH-1:0] dat;

// Some renaming for easier coding
logic sclk, mosi, ss;
wire miso, sclk_posedge;

// CRC. The modules get unfiltered access to the CRC modules, as they do buses, but this should also be fine as no two modules should be actively using a crc block.
wire crc7_valid, crc7_dat, crc7_rst;
wire crc16_valid, crc16_dat, crc16_rst;
wire [6:0] crc7_i;
wire [15:0] crc16_i;

crc_7 crc7   (.valid_i(crc7_valid),
              .dat_i(crc7_dat),
              .crc_o(crc7_i),
              .rst(crc7_rst),
              .*);
crc_16 crc16 (.valid_i(crc16_valid),
              .dat_i(crc16_dat),
              .crc_o(crc16_i),
              .rst(crc16_rst),
              .*);

// The read and write submodules are given unfiltered access to the data bus to avoid sharing logic, seeing as the driver is the one that ultimately initiates the module.
wire [BUS_WIDTH-1:0] read_bus, write_bus;
wire read_done, write_done;
logic do_read, do_write;

wire read_crc7_valid, read_crc7_dat, read_crc7_rst;
wire read_crc16_valid, read_crc16_dat, read_crc16_rst;

wire write_crc7_valid, write_crc7_dat, write_crc7_rst;
wire write_crc16_valid, write_crc16_dat, write_crc16_rst;

spi_read #(BUS_WIDTH) reader  (.bus_io(read_bus),
                               .read_done_o(read_done),
                               .read_i(do_read),
                               .crc7_valid_o(read_crc7_valid),
                               .crc7_dat_o(read_crc7_dat),
                               .crc7_rst_o(read_crc7_rst),
                               .crc16_valid_o(read_crc16_valid),
                               .crc16_dat_o(read_crc16_dat),
                               .crc16_rst_o(read_crc16_rst),
                               .*);
spi_write #(BUS_WIDTH) writer (.bus_io(write_bus),
                               .write_done_o(write_done),
                               .write_i(do_write),
                               .crc7_valid_o(write_crc7_valid),
                               .crc7_dat_o(write_crc7_dat),
                               .crc7_rst_o(write_crc7_rst),
                               .crc16_valid_o(write_crc16_valid),
                               .crc16_dat_o(write_crc16_dat),
                               .crc16_rst_o(write_crc16_rst),
                               .*);

// A register used to count up to 74 SPI cycles.
logic [SCLK_WAIT_WIDTH-1:0] spi_counter;
// For configuring the clock speed of the module. Since the lowest speed is SPI_CYCLE_INIT, we will need at most those bits to count and wait to toggle sclk. ss_toggle_value serves the purpose of dynamically setting the speed of sclk. Supports setting 
logic [SPI_CYCLE_INIT_WIDTH-1:0] ss_divider, ss_toggle_value;
// A register used to count up to the number of cycles needed to elapse for a a full millisecond at our clock speed.
logic [MILLISECOND_MHZ_WIDTH-1:0] ms_waiter;

// STATES. The different "states" represented by this device, though more similar to mode of operation. Multiple states can be active at the same time, most commonly, SCLK_ACTIVE_STATE and READ_STATE/WRITE_STATE. Due to this, enums don't suite our purpose
parameter STATES = 7;
// The main states of SPI. A 1 means the state is currently active. At most one of these should be high at any time.
parameter INIT_STATE = 0;
parameter READ_STATE = 1;
parameter WRITE_STATE = 2;
// The SPI clock is active if this state is high
parameter SCLK_ACTIVE_STATE = 3;
// A value of 1 in this state means 74 SPI cycles have elapsed
parameter SCLK_WAIT_STATE = 4;
// The command flow of SPI initialization
parameter INIT_CMD0_STATE = 5;
parameter INIT_CMD8_STATE = 6;
// The state register. Used to condence the numerous 1 bit logic check registers. Take a look at the variables ending with _STATE to see what the different positions correspond to.
logic [STATES-1:0] state;

// Assignmens
assign miso = from_slave_i;
assign to_slave_o[0] = sclk;
assign to_slave_o[1] = mosi;
assign to_slave_o[2] = ss;
// It's time to toggle the value of sclk, and sclk was previously low
assign sclk_posedge = (ss_divider == ss_toggle_value) && !sclk;

// The behavior
always_ff @(posedge clk) begin
    // init is asserted on reset
    if (rst) begin
        // State initialization
        state[INIT_STATE] <= 1'b1;
        state[READ_STATE] <= 1'b0;
        state[WRITE_STATE] <= 1'b0;
        state[SCLK_ACTIVE_STATE] <= 1'b0;
        state[SCLK_WAIT_STATE] <= 1'b0;
        state[INIT_CMD0_STATE] <= 1'b0;
        state[INIT_CMD8_STATE] <= 1'b0;

        // sclk values
        sclk <= '1;
        ss_divider <= '0;
        ss_toggle_value <= SPI_CYCLE_INIT;
        spi_counter <= '0;

        // Other initial states
        mosi <= '0;
        ss <= '0;
        ms_waiter <= '0;
        do_read <= '0;
        do_write <= '0;
    // Reset takes precedence. remainder of the behavior
    end else begin
        // Toggle sclk
        if (state[SCLK_ACTIVE_STATE]) begin
            // Time to toggle
            ss_divider <= ss_divider == ss_toggle_value ? '0 : ss_divider + 1'b1;
            sclk <= ~sclk;
        end

        // Initialization
        if (state[INIT_STATE]) begin
            // Phase 1: Wait a full millisecond
            if (ms_waiter != MILLISECOND_MHZ)
                ms_waiter <= ms_waiter + 1'b1;
            else begin
                // We're toggling the clock from now on
                state[SCLK_ACTIVE_STATE] <= '1;
                // Phase 2, wait 74 cycles
                if (!state[SCLK_WAIT_STATE]) begin
                    ss <= '1;
                    mosi <= '1;
                    // We haven't counted 74 cycles, and we're on the positive edge
                    if (spi_counter != SCLK_WAIT && sclk_posedge)
                        spi_counter <= spi_counter + 1'b1;
                    // We're done waiting
                    else if (spi_counter == SCLK_WAIT)
                        state[SCLK_WAIT_STATE] <= '1;
                // State 0: send command 0
                end else if (!state[INIT_CMD0_STATE]) begin

                end
            end
        end
    end
end

endmodule
