`timescale 1ns/1ns

/* module for performing modular exponentiation */
module modexp(
	clk, rst, stall,
	exp, mod, key_i, start,
	key_o, done, valid
);
	input clk, rst, stall;
	input [4095:0] exp, mod; //would actually want to chunk this
	input [127:0] key_i;
	input start;
	output [127:0] key_o;
	output done, valid;


	logic [127:0] intermediate;
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
			intermediate <= 'b0;
			done <= 1'b0;
			valid <= 1'b0;
		end else begin
			if(run) begin
				if(i==4095) begin
					key_o <= intermediate;
					done <= 1'b1;
					valid <= 1'b1;
				end else begin
				/*  Input: M, e, n
					Output: M^e mod n
					Let e contain k bits
					if e[k-1] = 1 then C = M else C = 1
					for i=k-2 down to 0
					C = C*C
					If e_i = 1 then C = C*M
				*/
					if(i==4095) begin //first iteration
						if(exp[i] == 1'b1) begin
							intermediate <= key_i;
						end else begin
							intermediate <= 'b0001;
						end
					end else begin
						if(exp[i] == 1'b1) begin
							intermediate <= intermediate*intermediate*key_i;
						end else begin
							intermediate <= intermediate*intermediate;
						end
					end
				end
			end
		end
	end

endmodule