`timescale 1ns/1ns

module md5 (
    input logic clk,
    input logic reset,
    input logic start,

    input logic write,
    input logic [31:0] writedata,
    input logic [3:0]  writeaddr,

    output logic [127:0] digest0,

    output logic done
);

//logic m_write;
//assign m_write = write;

logic [5:0] cc_iaddr;
logic [3:0] cc_gaddr;

//logic [127:0] cc_digest;
//assign digest0 = cc_digest;

logic [31:0] cc_mdata;
logic [4:0]  cc_sdata;
logic [31:0] cc_kdata;

md5_chunk_cruncher cc (
    .clk (clk),
    .reset (reset),
    .start (start),
    .done (done),
    .digest (digest0),
    .iaddr (cc_iaddr),
    .kdata (cc_kdata),
    .sdata (cc_sdata),
    .gaddr (cc_gaddr),
    .mdata (cc_mdata)
);

mdataram mram (
    .clock (clk),
    .data (writedata),
    .wraddress (writeaddr[3:0]),
    .wren (write),
    .rdaddress (cc_gaddr),
    .q (cc_mdata)
);


/* don't use second channel of memory */
logic [5:0] cc_iaddr_unused;
logic [3:0] cc_gaddr_unused;
logic [4:0]  cc_sdata_unused;
logic [31:0] cc_kdata_unused;
assign cc_iaddr_unused = 'b0;
assign cc_gaddr_unused = 'b0;
assign cc_sdata_unused = 'b0;
assign cc_kdata_unused = 'b0;

sdatarom srom (
    .clock (clk),
    .address_a (cc_iaddr),
    .address_b (cc_iaddr_unused), //unused
    .q_a (cc_sdata),
    .q_b (cc_sdata_unused) //unused
);

kdatarom krom (
    .clock (clk),
    .address_a (cc_iaddr),
    .address_b (cc_iaddr_unused), //unused
    .q_a (cc_kdata),
    .q_b (cc_kdata_unused) //unused
);

endmodule