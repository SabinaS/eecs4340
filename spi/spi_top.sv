`timescale 1ns/1ns
module spi_top (
    clk, rst,
    to_slave_o, dat, valid_o, ready_o, ack_o,
    from_slave_i, read_i, write_i, valid_i, ready_i
);
parameter CLK_MHZ = 50;
parameter BUS_WIDTH = 128;
parameter SPI_CYCLE_INIT = (CLK_MHZ * 1000000) / 400000;
parameter SPI_CYCLE_INIT_WIDTH = $clog2(SPI_CYCLE_INIT);
parameter MILLISECOND_MHZ = (CLK_MHZ * 1000000) * (1 / 1000);
parameter MILLISECOND_MHZ_WIDTH = $clog2(MILLISECOND_MHZ);

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
wire miso;
assign miso = from_slave_i;
assign to_slave_o[0] = sclk;
assign to_slave_o[1] = mosi;
assign to_slave_o[2] = ss;

// Some state registers, corresponding with the top level state machine
logic init, read, write;
logic [6:0] spi_counter;
// For configuring the clock speed of the module. Since the lowest
logic [SPI_CYCLE_INIT_WIDTH-1:0] ss_divider;
logic [MILLISECOND_MHZ_WIDTH-1:0] ms_waiter;

// The behavior
always_ff @(posedge clk) begin
    if (rst) begin
        sclk <= '0;
        mosi <= '0;
        ss <= '0;
        ss_divider <= '0;
        ms_waiter <= '0;
        init <= '1;
        read <= '0;
        write <= '0;
    end else begin
    end
    // Initialization
    if (init) begin
        // Phase 1: Wait a full millisecond
        if (ms_waiter != '1)
            ms_waiter <= ms_waiter + 1'b1;
    end
end

endmodule
