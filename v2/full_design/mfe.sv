`timescale 1ns/1ns
`include "../mont_mult/_parameter.v"

// Multimedia File Encryption (Top Level)
module mfe (mfe_ifc.dut d);

    //TODO
    
    //for modexp
    logic clk,
    logic reset,
    logic startInput,   // tell FPGA to start input 
    logic startCompute, // tell FPGA to start compute
    logic getResult,    // tell FPGA to output result
    logic [`DATA_WIDTH - 1 : 0] m_buf,  
    logic [`DATA_WIDTH - 1 : 0] e_buf, 
    logic [3 : 0] state,
    logic [4 : 0] exp_state,   //  for MonExp
    logic [`DATA_WIDTH - 1 : 0] res_out
    
    ModExp mod(.*);


endmodule
