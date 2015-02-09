`timescale 1ns/1ns
module spi_port #(
          parameter CLK_MHZ = 50,
          parameter BUS_WIDTH = 128,
          parameter SCLK_WAIT = 74,
          parameter COMMAND_WIDTH = 6 * 8,
          parameter INTERNAL_DAT_WIDTH = 8,
          parameter COMMAND_BUF_SIZE = INTERNAL_DAT_WIDTH
       ) (
          spi_ifc.dut d
       );

spi_core #(CLK_MHZ, BUS_WIDTH, SCLK_WAIT, COMMAND_WIDTH,
           INTERNAL_DAT_WIDTH, COMMAND_BUF_SIZE) spi_core
         (
            .clk(d.clk),
            .rst(d.rst),
            .from_slave_i(d.from_slave_i),
            .read_i(d.read_i),
            .write_i(d.write_i),
            .valid_i(d.valid_i),
            .ready_i(d.ready_i),
            .to_slave_o(d.to_slave_o),
            .ready_o(d.ready_o),
            .valid_o(d.valid_o),
            .ack_o(d.ack_o),
            .dat(d.dat),
            .sclk_posedge_o(d.sclk_posedge_o),
            .sclk_negedge_o(d.sclk_negedge_o)
         );

endmodule
