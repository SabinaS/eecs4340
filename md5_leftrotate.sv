`timescale 1ns/1ns

module md5_leftrotate (
    input  logic [31:0] rotin,
    input  logic [4:0]  rotby,
    output logic [31:0] rotout
);

logic  [63:0] rotmid = ({rotin, rotin} << rotby);
assign rotout = rotmid[63:32];

endmodule