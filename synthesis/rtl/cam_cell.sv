module cam_cell #(parameter DATA_WIDTH = 32)
(
	input clk,
	input rst,
	// WRITE
	input write_enable_i,
	input [DATA_WIDTH - 1 : 0] write_data_i,
	// READ
	input read_enable_i,
	output logic read_valid_o,
	output logic [DATA_WIDTH - 1 : 0] data_o,
	// SEARCH
	input search_enable_i,
	input [DATA_WIDTH - 1 : 0] search_data_i,
	output logic match_o
);

	reg [DATA_WIDTH - 1: 0 ] data;
	reg read_valid;

	always_comb begin
		read_valid_o = read_enable_i ? read_valid : 1'b0;
		data_o = read_enable_i ? data : 1'b0;

		if (search_enable_i)
			match_o = (search_data_i == data);
		else
			match_o = 1'b0;
	end

	eff #(.DATA_WIDTH(DATA_WIDTH)) ff (
		.clk(clk),
		.rst(rst),
		.write_enable_i(write_enable_i),
		.data_i(write_data_i),
		.read_valid_o(read_valid),
		.data_o(data)
	);

endmodule