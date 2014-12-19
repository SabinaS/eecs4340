`timescale 1ns/1ns

/* 
 * Owner: Tim Paine
 */
module rsa_directed_test();

  logic clk;
  logic rst;
  logic stall;
  logic aes_valid_i, rsa_valid_i;
  logic aes_ready_o, rsa_ready_o;
  logic [127:0] aes_data_i, rsa_data_i;

  logic [7:0] ps2_data_i; 
  logic ps2_done, ps2_reset, ps2_valid_i;

  logic [127:0] out_data_o;
  logic out_valid_o;
  logic out_ready_i;

  logic led_pass_o, led_fail_o;
 
 integer i;

  rsa rsa_inst(.*);


  initial begin
    $vcdpluson();
    clk = 0;
    rst = 1;
    stall = 0;

    //reset   
    #1 clk = 1;
    #1 clk = 0;
    rst = 0;
    rsa_data_i = 128'h11111111111111111111111111111111;
    rsa_valid_i = 1;

    /* state 0 */
    for(i = 0;i<65;i=i+1) begin
    #1 clk = 1;
    #1 clk = 0;
    end

    rsa_data_i = 'b0;
    rsa_valid_i = 1'b0;

    /* state 1 */
    ps2_done = 1'b0;
    ps2_reset = 1'b0;
    ps2_data_i = 8'b00000000;
    ps2_valid_i = 1'b1;
    for(i=0;i<55;i=i+1) begin /* modify for corner cases */
    #1 clk = 1;
    #1 clk = 0;
    ps2_data_i = (ps2_data_i + 1'b00000001) % 8'b11111111;
    end

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
     $display("data \t valid ");
     $monitor("%h,%h", out_data_o, out_valid_o);
  end


endmodule


