`timescale 1ns/1ns

/* 
 * Owner: Tim Paine
 */
module mult_directed_test();

  logic clk;
  logic rst;
  logic [4096] a, b;
  logic [4096] o;
 

  multiplier multiplier_inst(.*);


  initial begin
    $vcdpluson();
    clk = 0;
    rst = 1;

    //reset   
    #1 clk = 1;
    #1 clk = 0;
    rst = 0;
    
    a = 'd02;
    b = 'd02;
    #1 clk = 1;
    #1 clk = 0;

    #1 clk = 1;
    #1 clk = 0;

    #1 clk = 1;
    #1 clk = 0;
    #1 $finish;
  end

  initial  begin
     $display("a\tb\to");
     $monitor("%d,%d,%d", a,b,o);
  end


endmodule


