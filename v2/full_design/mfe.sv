`timescale 1ns/1ns
`include "_parameter.v"

// Multimedia File Encryption (Top Level)
module mfe (mfe_ifc.dut d);

    //TODO
    
    //for modexp
    logic reset;
    logic startInpu; 
    logic startCompute;
    logic getResult;
    logic [`DATA_WIDTH - 1 : 0] m_buf;  
    logic [`DATA_WIDTH - 1 : 0] e_buf;
    logic [3 : 0] state;
    logic [4 : 0] exp_state;  
    logic [`DATA_WIDTH - 1 : 0] res_out;
    
    ModExp mod(.*);



    logic reset_n;
    logic avalanche_noise;
    logic cs;
    logic we;
    logic [11 : 0] address;
    logic [31 : 0] write_data;
    logic [31 : 0] read_data;
    logic error;

    logic [7 : 0] debug;
    logic debug_update;

    logic security_error;


    trng trng(.*);

endmodule
