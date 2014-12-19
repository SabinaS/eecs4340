`timescale 1ns/1ns

/* module for performing modular exponentiation */
module modexp(
	clk, rst, stall,
	exp, mod, key_i, start,
	key_o, done, valid
);
	input logic clk, rst, stall;
	input logic [4095:0] exp, mod; //would actually want to chunk this
	input logic [4095:0] key_i;
	input logic start;
	output logic [4095:0] key_o;
	output logic done, valid;


	logic [8191:0] intermediate;
	integer i;
	logic run;

	/*  Input: M, e, n
		Output: M^e mod n
		Let e contain k bits
		if e[k-1] = 1 then C = M else C = 1
		for i=k-2 down to 0
		C = C*C
		If e_i = 1 then C = C*M
	*/

	always_ff @(posedge clk) begin
		if(rst) begin
			run=1'b0;
			i<=4095;
		end else begin
			if(start) begin
				run<=1'b1;
			end
			if(run) begin
				if(i==0) begin
					i<=4095;
					run<=1'b0;
				end else begin
					i<=i-1;
				end
			end
		end
	end


	always_ff @(posedge clk) begin
		if(rst) begin
			intermediate <= 'b1;
			done <= 1'b0;
			valid <= 1'b0;
		end else if(!stall) begin
			if(run) begin
				if(i==0) begin
					key_o <= (intermediate * (exp[i] ? key_i: '1)) % mod;
					done <= 1'b1;
					valid <= 1'b1;
				end else begin
					if (exp[i]) begin
						intermediate <= ((intermediate * key_i) * (intermediate * key_i)) % mod;
					end else begin
						intermediate <= (intermediate * intermediate) % mod;
					end
				end
			end
		end
	end

endmodule
