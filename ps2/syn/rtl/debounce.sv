`timescale 1ns/1ns

module debounce(
	clk, button, result
);

/* Inputs */
input clk;
input button;

/* Outputs */
output logic result;

/* Variables */
wire [4:0] counter_size = 5'h13;		/* values passed in from ps2_top */
logic [1:0] flipflops;
logic counter_set;
logic [19:0] counter_out;

/* Behavior */
always_ff @(posedge clk) begin
	counter_set <= flipflops[0] ^ flipflops[1];

	if(clk) begin
		flipflops[0] <= button;
		flipflops[1] <= flipflops[0];
		if(counter_set == '1) begin
			counter_out <= '0;
		end else if(counter_out[counter_size] == '0) begin
			counter_out <= counter_out + 1;
		end else begin 
			result <= flipflops[1];
		end
	end
end

endmodule
