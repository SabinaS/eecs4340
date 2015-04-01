`timescale 1ns/1ns

`include "fat_defines.sv"
`include "../spi/defines.sv"

module fat_core (
   clk, rst,
   read_i, write_i, spi_read_o, spi_write_o,
   ready_o, ready_i, valid_o, valid_i, all_read_o,
   bus_io, aes_i, aes_o, aes_valid_i, aes_valid_o,
   fname_i, fext_i, fname_o, fext_o
);

   input clk, rst;
   // read_i: read the next fat file
   // write_i: write the given file name and data being sent
   input read_i, write_i;
   // ready_i: the upstream module accepted the data on the bus
   // valid_i: the upstream module has sent valid data on the bus
   input ready_i, valid_i, aes_valid_i;
   // fname_i: the file name of 8.3 format
   // fext_i: the file extension of 8.3 format
   input [`CHF_NAME_SIZE-1:0] fname_i;
   input [`CHF_EXT_SIZE-1:0] fext_i;
   // aes_i: data from the AES module to write to the SD card
   input [`AES_DAT_SIZE-1:0] aes_i;
   
   // spi_read_o: initiate a read to the card
   // spi_write_o: initiate a write to the card
   output logic spi_read_o, spi_write_o;
   // ready_o: I can accept data to write
   // valid_o: I have read data to give you
   output logic ready_o, valid_o, aes_valid_o;
   // ditto
   output logic [`CHF_NAME_SIZE-1:0] fname_o;
   output logic [`CHF_EXT_SIZE-1:0] fext_o;
   // aes_o: data from the SD card to the AES modules
   output logic [`AES_DAT_SIZE-1:0] aes_o;
   // No more files to read
   output logic all_read_o;
   
   // Communicating with the SD card
   inout [`BUS_WIDTH-1:0] bus_io;
   
   // Communicating with the SD card again
   logic do_io;
   logic [`BUS_WIDTH-1:0] bus_dat;
   
   // Root dir cache
   logic [`SD_BLOCK_SIZE-1:0] rdir_cache;
   logic [`SD_BLOCK_SIZE_WIDTH-1:0] rdir_cache_pos;
   logic [`LBA_BEGIN_SIZE-1:0] rdir_count;
   // Single block SD cache
   logic [`SD_BLOCK_SIZE-1:0] spi_buf;
   logic [`SD_BLOCK_SIZE_WIDTH-1:0] spi_buf_pos;
   // Single block FAT32 cache
   reg[7:0] block[`MAX_BLOCK_SIZE-1:0];
   logic [`MAX_BLOCK_SIZE_WIDTH-1:0] block_count;
   
   // initialization structures
   enum {READ_BS, AWAIT_BS, PARSE_BS, READ_BPR, AWAIT_BPR, PARSE_BPR, FINALIZE_VALUES, CALCULATE_ROOT_LBA, PULL_ROOT_DIR, AWAIT_ROOT_DIR, IIDLE, IFAIL} init;
   logic [`PART_COUNT_WIDTH-1:0] part_pos;
   logic [`LBA_BEGIN_SIZE-1:0] part_begin;
   logic [`BPB_BytsPerSec_SIZE-1:0] BPB_BytsPerSec;
   logic [`BPB_SecPerClus_SIZE-1:0] BPB_SecPerClus;
   logic [`BPB_RsvdSecCnt_SIZE-1:0] BPB_RsvdSecCnt;
   logic [`BPB_NumFATs_SIZE-1:0] BPB_NumFATs;
   logic [`BPB_FATSz32_SIZE-1:0] BPB_FATSz32;
   logic [`BPB_RootClus_SIZE-1:0] BPB_RootClus;
   
   // File location structures
   logic [`LBA_BEGIN_SIZE-1:0] calc_lba;
   logic [`LBA_BEGIN_SIZE-1:0] fat_begin_lba;
   logic [`LBA_BEGIN_SIZE-1:0] cluster_begin_lba;
   logic [`LBA_BEGIN_SIZE-1:0] root_dir_first_cluster;
   logic [7:0] sectors_per_cluster;
   
   // Read data structures
   enum {RIDLE, CALCULATE_READ_LBA, RREAD_LBA, RAWAIT_LBA, RRESPOND, RDONE} read_state;
   
   // Write data structures
   enum {WIDLE} write_state;
   
   always_ff @(posedge clk) begin
      if (rst) begin
         do_io <= '0;
         bus_dat <= '0;
         
         spi_read_o <= '0;
         spi_write_o <= '0;
         ready_o <= '1;
         valid_o <= '0;
         fname_o <= '0;
         fext_o <= '0;
         aes_o <= '0;
         all_read_o <= '0;
         
         block_count <= '0;
         spi_buf <= '0;
         spi_buf_pos <= '0;
         rdir_cache <= '0;
         rdir_cache_pos <= '0;
         rdir_count <= '0;
         
         init <= READ_BS;
         read_state <= RIDLE;
         write_state <= WIDLE;
         part_pos <= '0;
         part_begin <= '0;
      end
      else begin
         // Reading task
         if (init == IIDLE && read_state == RIDLE) begin
            if (read_i) begin
               read_state <= CALCULATE_READ_LBA;
            end
         end
         else if (read_state == CALCULATE_READ_LBA) begin
            // If the first byte of the current directory entry is zero, there's no more data
            if (rdir_cache[rdir_count*`DIR_ENTRY_SIZE+:8] == 8'b0) begin
               all_read_o <= '1;
               read_state <= RDONE;
            end
            // The current entry is unused
            else if (rdir_cache[rdir_count*`DIR_ENTRY_SIZE+:8] == 8'hE5) begin
               rdir_count++;
            end
            // Found a file
            else if (rdir_cache[rdir_count*`DIR_ENTRY_SIZE+`DIR_Attr_OFF+`DIR_Attr_Dir_OFF] == 'b0) begin
               calc_lba <= cluster_begin_lba + ({rdir_cache[rdir_count*`DIR_ENTRY_SIZE+`DIR_FstClusHI_OFF+:16], rdir_cache[rdir_count*`DIR_ENTRY_SIZE+`DIR_FstClusLO_OFF+:16]} - 'd2) * sectors_per_cluster;
               read_state <= RREAD_LBA;
            end
            // Go on to the next entry
            else begin
               rdir_count++;
            end
         end
         else if (read_state == RREAD_LBA) begin
            do_io <= '1;
            bus_dat[`RW_ADDRESS_END:`RW_ADDRESS_START] <= calc_lba;
            bus_dat[`RW_AMOUNT_END:`RW_AMOUNT_START] <= 'b1;
            spi_read_o <= '1;
            valid_o <= '1;
            read_state <= RAWAIT_LBA;
         end
         else if (read_state == RAWAIT_LBA) begin
            spi_read_o <= '0;
            valid_o <= '0;
            do_io <= '0;
            if (valid_i) begin
               spi_buf <= {bus_io, spi_buf[`SD_BLOCK_SIZE-`BUS_WIDTH-1:`BUS_WIDTH]};
               spi_buf_pos <= spi_buf_pos + `BUS_WIDTH;
            end
            // We're done
            if (spi_buf_pos == `SD_BLOCK_SIZE) begin
               read_state <= RRESPOND;
               spi_buf_pos <= '0;
            end
         end
         else if (read_state == RRESPOND) begin
            // If the upstream can accept our data, let's send it
            aes_o <= spi_buf[spi_buf_pos+:`BUS_WIDTH];
            spi_buf_pos <= spi_buf_pos + `BUS_WIDTH;
            // We just wrote the last piece of data
            if (spi_buf_pos + `BUS_WIDTH == `SD_BLOCK_SIZE) begin
               aes_valid_o <= '0;
               read_state <= RIDLE;
            end
            else
               aes_valid_o <= '1;
         end
       
         // Initialization task
         if (init == READ_BS) begin
            // Read the boot sector.
            do_io <= '1;
            bus_dat[`RW_ADDRESS_END:`RW_ADDRESS_START] <= 'b0;
            bus_dat[`RW_AMOUNT_END:`RW_AMOUNT_START] <= 'b1;
            spi_read_o <= '1;
            valid_o <= '1;
            init <= AWAIT_BS;
         end
         else if (init == AWAIT_BS) begin
            spi_read_o <= '0;
            valid_o <= '0;
            do_io <= '0;
            if (valid_i) begin
               spi_buf <= {bus_io, spi_buf[`SD_BLOCK_SIZE-`BUS_WIDTH-1:`BUS_WIDTH]};
               spi_buf_pos <= spi_buf_pos + `BUS_WIDTH;
            end
            // We're done
            if (spi_buf_pos == `SD_BLOCK_SIZE) begin
               init <= PARSE_BS;
               spi_buf_pos <= '0;
            end
         end
         else if (init == PARSE_BS) begin
            // If we've checked all partitions, then this card is not FAT formatted
            if (part_pos == `PART_COUNT) begin
               init <= IFAIL;
            end
            else
               part_pos++;
            // Check the 5th byte for the FAT sector code
            if (spi_buf[`BOOT_CODE_BITS+part_pos*`PART_ENTRY_BITS+4*8+:8] == 'hB
                || spi_buf[`BOOT_CODE_BITS+part_pos*`PART_ENTRY_BITS+4*8+:8] == 'hC) begin
               part_begin <= spi_buf[`BOOT_CODE_BITS+part_pos*`PART_ENTRY_BITS+8*8+:`LBA_BEGIN_SIZE];
               init <= READ_BPR;
            end
         end
         else if (init == READ_BPR) begin
            do_io <= '1;
            bus_dat[`RW_ADDRESS_END:`RW_ADDRESS_START] <= part_begin;
            bus_dat[`RW_AMOUNT_END:`RW_AMOUNT_START] <= 'b1;
            spi_read_o <= '1;
            valid_o <= '1;
            init <= AWAIT_BPR;
         end
         else if (init == AWAIT_BPR) begin
            spi_read_o <= '0;
            valid_o <= '0;
            do_io <= '0;
            if (valid_i) begin
               spi_buf <= {bus_io, spi_buf[`SD_BLOCK_SIZE-`BUS_WIDTH-1:`BUS_WIDTH]};
               spi_buf_pos <= spi_buf_pos + `BUS_WIDTH;
            end
            // We're done
            if (spi_buf_pos == `SD_BLOCK_SIZE) begin
               init <= PARSE_BPR;
               spi_buf_pos <= '0;
            end
         end
         else if (init == PARSE_BPR) begin
            // Assign the fundamental values
            BPB_BytsPerSec <= spi_buf[`BPB_BytsPerSec_OFF+:`BPB_BytsPerSec_SIZE];
            BPB_SecPerClus <= spi_buf[`BPB_SecPerClus_OFF+:`BPB_SecPerClus_SIZE];
            BPB_RsvdSecCnt <= spi_buf[`BPB_RsvdSecCnt_OFF+:`BPB_RsvdSecCnt_SIZE];
            BPB_NumFATs <= spi_buf[`BPB_NumFATs_OFF+:`BPB_NumFATs_SIZE];
            BPB_FATSz32 <= spi_buf[`BPB_FATSz32_OFF+:`BPB_FATSz32_SIZE];
            BPB_RootClus <= spi_buf[`BPB_RootClus_OFF+:`BPB_RootClus_SIZE];
            init <= FINALIZE_VALUES;
         end
         else if (init == FINALIZE_VALUES) begin
            sectors_per_cluster <= BPB_SecPerClus;
            root_dir_first_cluster <= BPB_RootClus;
            fat_begin_lba <= part_begin + BPB_RsvdSecCnt;
            cluster_begin_lba <= part_begin + BPB_RsvdSecCnt + BPB_NumFATs * BPB_FATSz32;
            init <= CALCULATE_ROOT_LBA;
         end
         else if (init == CALCULATE_ROOT_LBA) begin
            calc_lba <= cluster_begin_lba + (root_dir_first_cluster - 'd2) * sectors_per_cluster;
            init <= PULL_ROOT_DIR;
         end
         else if (init == PULL_ROOT_DIR) begin
            // Get just the first block of the root cluster
            do_io <= '1;
            bus_dat[`RW_ADDRESS_END:`RW_ADDRESS_START] <= calc_lba;
            bus_dat[`RW_AMOUNT_END:`RW_AMOUNT_START] <= 'b1;
            spi_read_o <= '1;
            valid_o <= '1;
            init <= AWAIT_ROOT_DIR;
         end
         else if (init == AWAIT_ROOT_DIR) begin
            spi_read_o <= '0;
            valid_o <= '0;
            do_io <= '0;
            if (valid_i) begin
               rdir_cache <= {bus_io, rdir_cache[`SD_BLOCK_SIZE-1:`BUS_WIDTH]};
               rdir_cache_pos <= rdir_cache_pos + `BUS_WIDTH;
            end
            // We're done
            if (rdir_cache_pos == `SD_BLOCK_SIZE) begin
               init <= PARSE_BPR;
               rdir_cache_pos <= '0;
            end
         end
      end
   end

   // Combinational logic
   assign bus_io = do_io ? bus_dat : 'z;
   
endmodule
