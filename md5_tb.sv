`timescale 1ns/1ns

/* Project: MFE
 * Directed TB for md5
 */
module md5_tb();

  logic clk,
  logic [1:0] reset,
  logic [1:0] start,

　logic write,
　logic [31:0] writedata,
　logic [4:0]  writeaddr,

  logic [127:0] digest0,
  logic [127:0] digest1,

  logic [1:0] done
 
  md5 md5_inst(.*);


  initial begin
    $vcdpluson();
    clk = 0;
    rst = 1;

    //reset   
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 clk = 0;
    #1 $finish;
  end

  initial  begin
     //$display("pay \tkey,\tdone");
     //$monitor("%h,%h,%h", key_o, pay_o, dne_o);
  end


endmodule



