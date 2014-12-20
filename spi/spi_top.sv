`timescale 1ns/1ns
module spi_top;

    bit clk = 1;
    always #10 clk = ~clk;

   // command to generate the VCD dump file that you open with DVE
   initial $vcdpluson;

   spi_ifc IFC(clk); // instantiate the interface file
   spi_port dut (IFC.dut); 
   spi_tb bench (IFC.bench);
   // sd_model_port model (IFC.sdcard);

endmodule
