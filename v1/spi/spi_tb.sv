`include "directives.sv"
class transaction;
// vars
rand bit reset;

// Checking the reset functionality
function bit check_reset(logic [2:0] to_slave_o, logic ready_o,
      logic valid_o, logic ack_o, logic dat);

   to_slave_o = '0;
   ready_o = '0;
   valid_o = '0;
   ack_o = '0;

   return((to_slave_o == '0) && (ready_o == '0) && (valid_o == '0)
      && (ack_o == '0) && (dat == '0));

endfunction


function void golden_result();
   // TODO later
endfunction


endclass



class testing_env;
rand int unsigned rn;

bit 				  reset;

int 				  reset_thresh;

int 				  iter;

function void read_config(string filename);
   int 			  file, chars_returned, seed, value;
   string 			  param;
   file = $fopen(filename, "r");

   while(!$feof(file)) begin
      chars_returned = $fscanf(file, "%s %0d", param, value);
      if("RANDOM_SEED" == param) begin
         seed = value;
         $srandom(seed);
      end
      else if("ITERATIONS" == param) begin
         iter = value;
      end
      else if("RESET_PROB" == param) begin
         reset_thresh = value;
      end
      else begin
         `display(("Invalid parameter"));
         $exit();
      end
   end
endfunction

function bit get_reset();
   return((rn%1000)<reset_thresh);
endfunction

endclass

class golden_crc_7;

logic [6:0] crc = 0;

function void update_crc(bit val);
   bit      inv = val ^ crc[6];
   crc[6] = crc[5];
   crc[5] = crc[4];
   crc[4] = crc[3];
   crc[3] = crc[2] ^ inv;
   crc[2] = crc[1];
   crc[1] = crc[0];
   crc[0] = inv;
endfunction

function void rst();
   crc = 0;
endfunction

endclass

class golden_crc_16;

logic [15:0] crc = 0;

function void update_crc(bit val);
   bit 	inv = val ^ crc[15];
   crc[15] = crc[14];
   crc[14] = crc[13];
   crc[13] = crc[12];
   crc[12] = crc[11] ^ inv;
   crc[11] <= crc[10];
   crc[10] = crc[9];
   crc[9]  = crc[8];
   crc[8]  = crc[7];
   crc[7]  = crc[6];
   crc[6]  = crc[5];
   crc[5]  = crc[4] ^ inv;
   crc[4]  = crc[3];
   crc[3]  = crc[2];
   crc[2]  = crc[1];
   crc[1]  = crc[0];
   crc[0]  = inv;
endfunction

function void rst();
   crc = 0;
endfunction

endclass

parameter CLK_MHZ               = 50;
parameter SCLK_WAIT             = 74;
parameter MILLISECOND_MHZ       = (CLK_MHZ * 1000000) / 1000;
parameter SPI_CYCLE_INIT        = (CLK_MHZ * 1000000) / 400000;

parameter COMMAND_SIZE          = 6 * 8;
parameter R1_SIZE               = 8;
parameter R3_SIZE               = 8 * 5;
program spi_tb (spi_ifc.bench ds);

transaction t;
testing_env v;
golden_crc_7 crc_7;
golden_crc_16 crc_16;

wire 	mosi, sclk, sclk_posedge, sclk_negedge, ss;
assign mosi = ds.cb.to_slave_o[1];
assign sclk = ds.cb.to_slave_o[0];
assign sclk_posedge = ds.cb.sclk_posedge_o;
assign sclk_negedge = ds.cb.sclk_negedge_o;
assign ss = ds.cb.to_slave_o[2];

int 		failures = 0;
int 		cmd_cnt = 0;

bit 		cmd0_done = 0;
bit 		cmd8_done = 0;
bit      acmd41_done = 0;
bit      acmd41_hcs = 0;
bit      acmd41_timeout = 0;
bit      cmd58_done = 0;
bit      cmd1_done = 0;
bit      do_cmd16 = 0;

bit 		prev_mosi = 1;

bit 		reset;

bit 		cmd_recv = 0;
bit 		cmd_rdy = 0;
bit 		init_complete = 0;

bit      cmd8_timeout = 0;
bit      cmd58_r1 = 0;

int      acmd41_r1_err_max = 1;
int      acmd41_r1_err_cnt = 0;
int      cmd1_r1_err_max = 2;
int      cmd1_r1_err_cnt = 0;

bit      complete_msg_disp = 0;

logic [COMMAND_SIZE-1:0] command = 0;
int 			    cmd_pos = 0;

logic [R1_SIZE-1:0] 	    r1_response;
int 			    r1_pos = R1_SIZE - 1;
logic [R3_SIZE-1:0] 	    r37_response;
int 			    r37_pos = R3_SIZE - 1;

parameter R1_TYPE = 0;
parameter R3_TYPE = 1;
parameter R7_TYPE = 2;
logic [2:0] 		    rsp_type = 0;

initial begin
   t = new();
   v = new();
   crc_7 = new();
   crc_16 = new();
   // v.read_config("config.txt");

   ds.cb.rst <= 1'b1;
   ds.cb.from_slave_i <= '1;
   @(ds.cb);
   ds.cb.rst <= 1'b0;

   // `display(("tb: MILLISECOND_MHZ: %0d, SCLK_WAIT: %0d, CLK_MHZ: %0d, SPI_CYCLE_INIT: %0d", MILLISECOND_MHZ, SCLK_WAIT, CLK_MHZ, SPI_CYCLE_INIT));
   // repeat (SCLK_WAIT * SPI_CYCLE_INIT * 2 + MILLISECOND_MHZ + 48 * SPI_CYCLE_INIT * 2 + SPI_CYCLE_INIT * 2 * 8 + SPI_CYCLE_INIT * 48 * 2 + SPI_CYCLE_INIT * 40 * 3) begin
   while(1) begin
      // if ($time == SCLK_WAIT * SPI_CYCLE_INIT * 2 + MILLISECOND_MHZ)
      //     $vcdpluson;
      // mosi = ds.cb.to_slave_o[1];
      if (sclk_posedge) begin
         // Shift in a detected command
         if (cmd_recv && !cmd_rdy) begin
            if (cmd_pos < 47) begin
               if (cmd_pos < 39)
                  crc_7.update_crc(mosi);
               command = {command[COMMAND_SIZE-2:0], mosi};
               cmd_pos++;
            end
            else begin
               cmd_recv = 0;
               cmd_pos = 0;
               cmd_rdy = 1;
               `display(("command: %b, golden CRC7: %b", command, crc_7.crc));
            end
         end
         // Shift out a ready response
         if (rsp_type) begin
            if (rsp_type[R1_TYPE] && r1_pos >= 0) begin
               ds.cb.from_slave_i <= r1_response[r1_pos];
               r1_pos--;
            end
            else if (rsp_type[R3_TYPE] && r37_pos >= 0) begin
               ds.cb.from_slave_i <= r37_response[r37_pos];
               r37_pos--;
            end
            else if (rsp_type[R7_TYPE] && r37_pos >= 0) begin
               // `display(("R7 response"));
               // If we're above the crc position, update the crc
               if (r37_pos >= 8) begin
                  crc_7.update_crc(r37_response[r37_pos]);
               end
               // If we're within the crc positions, send the crc
               if (r37_pos <= 7 && r37_pos >= 1) begin
                  ds.cb.from_slave_i <= crc_7.crc[r37_pos-1];
               end
               else
                  ds.cb.from_slave_i <= r37_response[r37_pos];
               r37_pos--;
            end
            else begin
               ds.cb.from_slave_i <= 1;
               rsp_type = '0;
               r1_pos = R1_SIZE-1;
               r37_pos = R3_SIZE-1;
               crc_7.rst();
               `display(("rsp_type: response sent"));
            end
         end

         if (!init_complete) begin
            // CMD0, respond with R1
            if (!cmd0_done && cmd_rdy) begin
               if (command == {2'b01, 6'd0, 32'h0, crc_7.crc, 1'b1}) begin
                  crc_7.rst();
                  r1_response = 1;
                  rsp_type[R1_TYPE] = 1;
                  cmd_rdy = 0;
                  cmd0_done = 1;
               end
               else begin
                  `display(("command mismatch"));
                  $finish;
               end
            end
            else if (cmd0_done && !cmd8_done && cmd_rdy) begin
               if (command[47:46] == 2'b1 &&
                     command[45:40] == 6'd8 &&
                     command[39:20] == 20'b0 &&
                     command[19:16] == 4'b1 &&
                     command[7:0] == {crc_7.crc, 1'b1}) begin
                  crc_7.rst();
                  if (!cmd8_timeout) begin
                     r37_response = {2'b0, 6'b1000, 20'd0, 4'b1, command[15:8], 7'd0, 1'b1};
                     rsp_type[R7_TYPE] = 1;
                  end
                  cmd_rdy = 0;
                  cmd8_done = 1;
               end
               else begin
                  `display(("command mismatch"));
                  $finish;
               end
            end
            // ACMD41
            else if (cmd0_done && cmd8_done && !acmd41_done && cmd_rdy) begin
               if (command == {2'b01, 6'd41, 2'b01, 30'h0, crc_7.crc, 1'b1}) begin
                  if (acmd41_r1_err_cnt >= acmd41_r1_err_max) begin
                     r1_response = 0;
                     acmd41_done = 1;
                     acmd41_hcs = 1;
                  end else begin
                     r1_response = 1;
                     acmd41_r1_err_cnt++;
                  end
                  rsp_type[R1_TYPE] = 1;
                  cmd_rdy = 0;
                  crc_7.rst();
               end else if (command == {2'b01, 6'd41, 32'h0, crc_7.crc, 1'b1}) begin
                  if (acmd41_r1_err_cnt >= acmd41_r1_err_max) begin
                     if (!acmd41_timeout) begin
                        r1_response = 0;
                        rsp_type[R1_TYPE] = 1;
                     end
                     acmd41_done = 1;
                     do_cmd16 = 1;
                  end else begin
                     r1_response = 1;
                     acmd41_r1_err_cnt++;
                     rsp_type[R1_TYPE] = 1;
                  end
                  crc_7.rst();
                  cmd_rdy = 0;
               end
               else begin
                  `display(("command mismatch, expected %b, got %b", {2'b01, 6'd41, 2'b01, 30'h0, crc_7.crc, 1'b1}, command));
                  $finish;
               end
            end
            // We're taking the left path
            else if (cmd0_done && cmd8_done && acmd41_done && !cmd58_done && acmd41_hcs && cmd_rdy) begin
               if (command == {2'b01, 6'd58, 32'h0, crc_7.crc, 1'b1}) begin
                  crc_7.rst();
                  if (cmd58_r1)
                     r37_response = {9'b0, 1'b1, 30'b0};
                  else begin
                     r37_response = 0;
                     do_cmd16 = 1;
                  end
                  rsp_type[R3_TYPE] = 1;
                  cmd_rdy = 0;
                  cmd58_done = 1;
               end
               else begin
                  `display(("command mismatch, expected %b, got %b", {2'b01, 6'd58, 32'h0, crc_7.crc, 1'b1}, command));
                  $finish;
               end
            end
            // We're taking the right-most path, CMD1
            else if (cmd0_done && cmd8_done && acmd41_done && !cmd1_done && !acmd41_hcs && acmd41_timeout && cmd_rdy) begin
               if (command == {2'b01, 6'd1, 32'h0, crc_7.crc, 1'b1}) begin
                  if (cmd1_r1_err_cnt >= cmd1_r1_err_max) begin
                     r1_response = 0;
                     cmd1_done = 1;
                     do_cmd16 = 1;
                  end else begin
                     r1_response = 1;
                     cmd1_r1_err_cnt++;
                  end
                  crc_7.rst();
                  rsp_type[R1_TYPE] = 1;
                  cmd_rdy = 0;
               end
               else begin
                  `display(("command mismatch, expected %b, got %b", {2'b01, 6'd1, 32'h0, crc_7.crc, 1'b1}, command));
                  $finish;
               end
            end
            else if (do_cmd16 && cmd_rdy) begin
               if (command == {2'b01, 6'd16, 32'h200, crc_7.crc, 1'b1}) begin
                  crc_7.rst();
                  r1_response = 0;
                  rsp_type[R1_TYPE] = 1;
                  cmd_rdy = 0;
                  init_complete = 1;
               end
               else begin
                  `display(("command mismatch, expected %b, got %b", {2'b01, 6'd16, 32'h200, crc_7.crc, 1'b1}, command));
                  $finish;
               end
            end
         end
         else if (init_complete && !complete_msg_disp) begin
            `display(("INITIALIZATION COMPLETE"));
            complete_msg_disp = 1;
         end
      end
      @(ds.cb);
      if (!prev_mosi && mosi && !cmd_recv) begin
         cmd_cnt++;
         cmd_recv = 1;
         // We miss the starting bit of the new command. Assign it here
         command[0] = '0;
      end
      prev_mosi = mosi;
   end
end
endprogram
