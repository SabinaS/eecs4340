`timescale 1ns/1ns
`include "_parameter.v"

// Multimedia File Encryption (Top Level)
module mfe (mfe_ifc.dut d);



    /*
     * States:
     * 1: wait for SPI
     * 2: read key from spi
     * 3: load n,r,t,nprime0 from software and e from key
     * 4: load m from software
     * 5: run modexp until done
     * 6: output result to software
     * 7: wait then loop to 4
     */

    //for modexp
    logic startInput; //input
    logic startCompute; //input
    logic loadNext;
    logic getResult; //input
    logic [`DATA_WIDTH - 1 : 0] m_buf;  //64 bits at a time
    logic [`DATA_WIDTH - 1 : 0] e_buf;   //64 bits at a time
    logic [`DATA_WIDTH - 1 : 0] n_buf;   //64 bits at a time
    logic [`DATA_WIDTH - 1 : 0] r_buf;   //64 bits at a time
    logic [`DATA_WIDTH - 1 : 0] t_buf;   //64 bits at a time
    logic nprime0_buf;   //64 bits at a time
    logic [3 : 0] state; //don't need to keep track of this
    logic [4 : 0] exp_state;  //don't need to keep track of this
    logic [`DATA_WIDTH - 1 : 0] res_out; //64 bits at a time
    
    modexp mod(.clk(d.clk), .reset(d.rst), .*);


endmodule
