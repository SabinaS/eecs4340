`timescale 1ns/1ns
module crc_16 (
    clk, rst,
    valid_i, dat_i,
    crc_o
);

input clk, rst;
input valid_i, dat_i;
output logic [15:0] crc_o;
// XOR required?
assign inv = dat_i ^ crc_o[15];
   
always @(posedge clk) begin
    if (rst) begin
      crc_o <= '0;
    end else begin
        crc_o[15] <= valid_i ? crc_o[14]       : crc_o[15];
        crc_o[14] <= valid_i ? crc_o[13]       : crc_o[14];
        crc_o[13] <= valid_i ? crc_o[12]       : crc_o[13];
        crc_o[12] <= valid_i ? crc_o[11] ^ inv : crc_o[12];
        crc_o[11] <= valid_i ? crc_o[10]       : crc_o[11];
        crc_o[10] <= valid_i ? crc_o[9]        : crc_o[10];
        crc_o[9]  <= valid_i ? crc_o[8]        : crc_o[9];
        crc_o[8]  <= valid_i ? crc_o[7]        : crc_o[8];
        crc_o[7]  <= valid_i ? crc_o[6]        : crc_o[7];
        crc_o[6]  <= valid_i ? crc_o[5]        : crc_o[6];
        crc_o[5]  <= valid_i ? crc_o[4] ^ inv  : crc_o[5];
        crc_o[4]  <= valid_i ? crc_o[3]        : crc_o[4];
        crc_o[3]  <= valid_i ? crc_o[2]        : crc_o[3];
        crc_o[2]  <= valid_i ? crc_o[1]        : crc_o[2];
        crc_o[1]  <= valid_i ? crc_o[0]        : crc_o[1];
        crc_o[0]  <= valid_i ? inv             : crc_o[0];
    end
end
   
endmodule