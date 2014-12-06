`timescale 1ns/1ns

interface spi_ifc(input bit clk);

    logic               rst;

    logic               from_slave_i, read_i, write_i, valid_i, ready_i;
    logic [2:0]         to_slave_o;
    logic               ready_o, valid_o, ack_o;

    wire                dat;


    // note that the outputs and inputs are reversed from the dut
    clocking cb @(posedge clk);
        output from_slave_i, read_i, write_i, valid_i, ready_i;
        input  to_slave_o, ready_o, valid_o, ack_o;
        inout  dat;
    endclocking

    modport bench (clocking cb);

    modport dut (
        input  from_slave_i, read_i, write_i, valid_i, ready_i,
        output to_slave_o, ready_o, valid_o, ack_o,
        inout  dat
    );
endinterface
