`timescale 1ns/1ns
module spi_top (
    to_slave_o, dat, valid_o, ready_o, ack_o,
    from_slave_i, read_i, write_i, valid_i, ready_i
);
    parameter       CLK_MHZ = 50;
    parameter       BUS_WIDTH = 128;
    
    // The data bus for communicating with the FS module
    inout [BUS_WIDTH-1:0]   dat;
    // The wires connecting to the SPI slave of this master
    output [2:0]            to_slave_o;
    // ready_o: indicates to the fs module that this module is ready to receive
    //  a command
    // valid_o: indicates to the fs module that this module's data output is
    //  valid.
    // ack_o: acknowledges that a command has been received. Will be sent on the
    //  cycle following the first valid data input, and if not, the command was
    //  missed.
    output                  ready_o, valid_o, ack_o;
    /* from_slave_i: the MISO of the SPI protocol */
    /* read_i: asserted for a single cycle the fs module to begin a read
        operation. The first data token should be the address information */
    /* write_i: asserted for a single cycle (or more, but doesn't matter) by
        the fs module to begin a write operation. The first data token should
        be the address information. */
    /* valid_i: asserted by the fs module that the data on dat is valid */
    /* ready_i: asserted by the fs module if it is able to receive more data */
    input                   from_slave_i, read_i, write_i, valid_i, ready_i;
    
    // Some renaming
    assign wire MISO = from_slave_i;
    assign wire SCLK = to_slave_o[0];
    assign wire MOSI = to_slave_o[1];
    assign wire SS = to_slave_o[2];
    
    // Some registers

endmodule

