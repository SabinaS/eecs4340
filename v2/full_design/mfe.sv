`timescale 1ns/1ns
`include "_parameter.v"

// Multimedia File Encryption (Top Level)
module mfe (mfe_ifc.dut d);



    /*
     * States:
     * 0 wait for/read key from SD
     * 1 generate random number
     * 2 output key+random number
     * 3 wait for/read data from SW
     * 4 exponentiate data^random number with mont mult
     * 5 divide data_in/data^random number
     * 6 output result and go to 4
     *
     */




    //TODO
    
    //for modexp
    logic startInput; //input
    logic startCompute; //input
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

    logic avalanche_noise; //noise source input
    logic cs;   //input, unsure, 1 when writing and reading
    logic we;  //input write enable, 1 when writing, 0 when reading
    logic [11 : 0] address; //input
    logic [31 : 0] write_data; //input
    logic [31 : 0] read_data; //output read data at address //TODO WHERE?
    logic error; //output when error maybe need

    logic [7 : 0] debug; //output dont need
    logic debug_update; //output dont need

    logic security_error; //output maybe need


    trng trng(.clk(d.clk), .reset_n(d.rst), .*);

endmodule
