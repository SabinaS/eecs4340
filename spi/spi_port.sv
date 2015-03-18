`timescale 1ns/1ns
module spi_port (
          spi_ifc.dut d
       );

spi_core spi_core
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
