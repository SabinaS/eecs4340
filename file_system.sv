module file_system (
	input clk,
	input rst,

	input valid_i,
	input [31:0] data_i,
	input eof_i,

	input read_i,
	input write_i,

	output valid_o,
	output [31:0] data_o,
	output ready_o,
	output eof_o,

	output writing_o,
	output reading_o,

	output [2:0] to_slave_o,
	input from_slave_i
);

endmodule
