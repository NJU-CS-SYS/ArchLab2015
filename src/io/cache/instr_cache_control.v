`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/07 19:47:56
// Design Name: 
// Module Name: instr_cache_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "status.vh"

module cache_control(
    dc_read_in, dc_write_in, ic_word_sel_in, dc_word_sel_in, dc_byte_w_en_in,/*external input*/
    ic_hit_in, ic_valid_in, /*ic's output*/
    dc_hit_in, dc_dirty_in, dc_valid_in,/*dc's output*/
    status_in, counter_in, /*status info*/
    ic_enable_out, ic_word_sel_out, ic_cmp_out, ic_write_out, ic_data_sel, ic_byte_w_en, ic_valid_out,
    dc_enable_out, dc_word_sel_out, dc_cmp_out, dc_write_out, dc_data_sel, dc_byte_w_en, dc_valid_out,
    ram_addr_sel, ram_en_out, ram_write_out,
    status_next, counter_next
);
input dc_read_in, dc_write_in, ic_hit_in, ic_valid_in, dc_hit_in, dc_dirty_in, dc_valid_in;
input [2:0] status_in,counter_in;
input [2:0] ic_word_sel_in, dc_word_sel_in;
input [3:0] dc_byte_w_en_in;

output ic_enable_out, ic_cmp_out, ic_write_out, ic_data_sel, ic_valid_out,
    dc_enable_out, dc_cmp_out, dc_write_out, dc_data_sel, dc_valid_out,
    ram_en_out, ram_write_out;
output [1:0] ram_addr_sel;
output [2:0] status_next,counter_next;
output [2:0] ic_word_sel_out, dc_word_sel_out;
output [3:0] ic_byte_w_en, dc_byte_w_en;

reg ic_enable_reg, ic_cmp_reg, ic_write_reg, ic_data_sel_reg, ic_valid_reg,
    dc_enable_reg, dc_cmp_reg, dc_write_reg, dc_data_sel_reg, dc_valid_reg,
    ram_en_out, ram_write_out;
reg [1:0] ram_addr_sel_reg;
reg [2:0] ic_word_sel_reg, dc_word_sel_reg, status_next_reg, counter_next_reg;
reg [3:0] ic_byte_w_en_reg, dc_byte_w_en_reg;

assign ic_enable_out = ic_enable_reg;
assign ic_cmp_out = ic_cmp_reg;
assign ic_write_out = ic_write_reg;
assign ic_data_sel = ic_data_sel_reg;
assign ic_valid_out = ic_valid_reg;

assign dc_enable_out = dc_enable_reg;
assign dc_cmp_out = dc_cmp_reg;
assign dc_write_out = dc_write_reg;
assign dc_data_sel = dc_data_sel_reg;
assign dc_valid_out = dc_valid_reg;

assign ic_word_sel_out = ic_word_sel_reg;
assign dc_word_sel_out = dc_word_sel_reg;
assign status_next = status_next_reg;
assign counter_next = counter_next_reg;
assign ic_byte_w_en = ic_byte_w_en_reg;
assign dc_byte_w_en = dc_byte_w_en_reg;
assign ram_addr_sel = ram_addr_sel_reg;



always @(*) begin
    case(status_in)
        `STAT_IC_MISS:
        begin
            ic_enable_reg = 1;
            ic_cmp_reg = 0;
            ic_write_reg = 1;
            ic_data_sel_reg = 1;//from ram
            ic_valid_reg = 1;
            ic_word_sel_reg = counter_in;
            ic_byte_w_en_reg = 4'b1111;

            dc_enable_reg = 0;
            dc_cmp_reg = 0;
            dc_write_reg = 0;
            dc_data_sel_reg = 0;
            dc_valid_reg = 0;
            dc_word_sel_reg = dc_word_sel_in;
            dc_byte_w_en_reg = dc_byte_w_en_in;

            ram_addr_sel_reg = 2'b00;
            ram_en_out = 1;
            ram_write_out = 0;

            if(counter_in == 3'd7) begin
                status_next_reg = `STAT_NORMAL;
                counter_next_reg = 3'd7;
            end
            else begin
                status_next_reg = `STAT_IC_MISS;
                if(counter_in == 3'd0) counter_next_reg = 3'd1;
                else if(counter_in == 3'd1) counter_next_reg = 3'd2;
                else if(counter_in == 3'd2) counter_next_reg = 3'd3;
                else if(counter_in == 3'd3) counter_next_reg = 3'd4;
                else if(counter_in == 3'd4) counter_next_reg = 3'd5;
                else if(counter_in == 3'd5) counter_next_reg = 3'd6;
                else counter_next_reg = 3'd7;
            end

        end
        `STAT_DC_MISS:
        begin
            ic_enable_reg = 0;
            ic_cmp_reg = 0;
            ic_write_reg = 0;
            ic_data_sel_reg = 0;
            ic_valid_reg = 0;
            ic_word_sel_reg = counter_in;
            ic_byte_w_en_reg = 4'b1111;

            dc_enable_reg = 1;
            dc_cmp_reg = 0;
            dc_write_reg = 1;
            dc_data_sel_reg = 1;//from ram
            dc_valid_reg = 1;
            dc_word_sel_reg = counter_in;
            dc_byte_w_en_reg = 4'b1111;

            ram_addr_sel_reg = 2'b01;
            ram_en_out = 1;
            ram_write_out = 0;

            if(counter_in == 3'd7) begin
                status_next_reg = `STAT_NORMAL;
                counter_next_reg = 3'd7;
            end
            else begin
                status_next_reg = `STAT_DC_MISS;
                if(counter_in == 3'd0) counter_next_reg = 3'd1;
                else if(counter_in == 3'd1) counter_next_reg = 3'd2;
                else if(counter_in == 3'd2) counter_next_reg = 3'd3;
                else if(counter_in == 3'd3) counter_next_reg = 3'd4;
                else if(counter_in == 3'd4) counter_next_reg = 3'd5;
                else if(counter_in == 3'd5) counter_next_reg = 3'd6;
                else counter_next_reg = 3'd7;
            end
        end
        `STAT_DC_MISS_D:
        begin
            ic_enable_reg = 0;
            ic_cmp_reg = 0;
            ic_write_reg = 0;
            ic_data_sel_reg = 0;
            ic_valid_reg = 0;
            ic_word_sel_reg = counter_in;
            ic_byte_w_en_reg = 4'b1111;

            dc_enable_reg = 1;
            dc_cmp_reg = 0;
            dc_write_reg = 0;
            dc_data_sel_reg = 0;
            dc_valid_reg = 1;
            dc_word_sel_reg = counter_in;
            dc_byte_w_en_reg = 4'b0000;

            ram_addr_sel_reg = 2'b11;
            ram_en_out = 1;
            ram_write_out = 1;

            if(counter_in == 3'd7) begin
                status_next_reg = `STAT_DC_MISS;
                counter_next_reg = 3'd0;
            end
            else begin
                status_next_reg = `STAT_DC_MISS_D;
                if(counter_in == 3'd0) counter_next_reg = 3'd1;
                else if(counter_in == 3'd1) counter_next_reg = 3'd2;
                else if(counter_in == 3'd2) counter_next_reg = 3'd3;
                else if(counter_in == 3'd3) counter_next_reg = 3'd4;
                else if(counter_in == 3'd4) counter_next_reg = 3'd5;
                else if(counter_in == 3'd5) counter_next_reg = 3'd6;
                else counter_next_reg = 3'd7;
            end
        end
        `STAT_DOUBLE_MISS:
        begin
            ic_enable_reg = 1;
            ic_cmp_reg = 0;
            ic_write_reg = 1;
            ic_data_sel_reg = 1;
            ic_valid_reg = 1;
            ic_word_sel_reg = counter_in;
            ic_byte_w_en_reg = 4'b1111;

            dc_enable_reg = 0;
            dc_cmp_reg = 0;
            dc_write_reg = 0;
            dc_data_sel_reg = 0;
            dc_valid_reg = 0;
            dc_word_sel_reg = dc_word_sel_in;
            dc_byte_w_en_reg = 4'b0000;

            ram_addr_sel_reg = 2'b00;
            ram_en_out = 1;
            ram_write_out = 0;

            if(counter_in == 3'd7) begin
                status_next_reg = `STAT_DC_MISS;
                counter_next_reg = 3'd0;
            end
            else begin
                status_next_reg = `STAT_DOUBLE_MISS;
                if(counter_in == 3'd0) counter_next_reg = 3'd1;
                else if(counter_in == 3'd1) counter_next_reg = 3'd2;
                else if(counter_in == 3'd2) counter_next_reg = 3'd3;
                else if(counter_in == 3'd3) counter_next_reg = 3'd4;
                else if(counter_in == 3'd4) counter_next_reg = 3'd5;
                else if(counter_in == 3'd5) counter_next_reg = 3'd6;
                else counter_next_reg = 3'd7;
            end
        end
        `STAT_DOUBLE_MISS_D:
        begin
            ic_enable_reg = 0;
            ic_cmp_reg = 0;
            ic_write_reg = 0;
            ic_data_sel_reg = 0;
            ic_valid_reg = 0;
            ic_word_sel_reg = counter_in;
            ic_byte_w_en_reg = 4'b1111;

            dc_enable_reg = 1;
            dc_cmp_reg = 0;
            dc_write_reg = 0;
            dc_data_sel_reg = 0;
            dc_valid_reg = 1;
            dc_word_sel_reg = counter_in;
            dc_byte_w_en_reg = 4'b0000;

            ram_addr_sel_reg = 2'b11;
            ram_en_out = 1;
            ram_write_out = 1;

            if(counter_in == 3'd7) begin
                status_next_reg = `STAT_DOUBLE_MISS;
                counter_next_reg = 3'd0;
            end
            else begin
                status_next_reg = `STAT_DOUBLE_MISS_D;
                if(counter_in == 3'd0) counter_next_reg = 3'd1;
                else if(counter_in == 3'd1) counter_next_reg = 3'd2;
                else if(counter_in == 3'd2) counter_next_reg = 3'd3;
                else if(counter_in == 3'd3) counter_next_reg = 3'd4;
                else if(counter_in == 3'd4) counter_next_reg = 3'd5;
                else if(counter_in == 3'd5) counter_next_reg = 3'd6;
                else counter_next_reg = 3'd7;
            end
        end
        default: /*normal*/
        begin
            ic_enable_reg = 1;
            ic_cmp_reg = 1;
            ic_write_reg = 0;
            ic_data_sel_reg = 0;
            ic_valid_reg = ic_valid_in;
            ic_word_sel_reg = ic_word_sel_in;
            ic_byte_w_en_reg = 4'b0000;

            dc_enable_reg = dc_read_in | dc_write_in;
            dc_cmp_reg = 1;
            dc_write_reg = dc_write_in;
            dc_data_sel_reg = 0;//from reg
            dc_valid_reg = dc_valid_in;
            dc_word_sel_reg = dc_word_sel_in;
            dc_byte_w_en_reg = dc_byte_w_en_in;

            ram_addr_sel_reg = 2'b00;
            ram_en_out = 0;
            ram_write_out = 0;

            if(dc_enable_reg && !(dc_hit_in && dc_valid_in)) begin //dc miss
                if(!(ic_hit_in && ic_valid_in)) begin //ic miss
                    if(dc_dirty_in) begin //dirty
                        status_next_reg = `STAT_DOUBLE_MISS_D;
                        counter_next_reg = 3'b000;
                    end
                    else begin
                        status_next_reg = `STAT_DOUBLE_MISS;
                        counter_next_reg = 3'b000;
                    end
                end
                else begin
                    if(dc_dirty_in) begin //dirty
                        status_next_reg = `STAT_DC_MISS_D;
                        counter_next_reg = 3'b000;
                    end
                    else begin
                        status_next_reg = `STAT_DC_MISS;
                        counter_next_reg = 3'b000;
                    end
                end
            end
            else begin
                if(!(ic_hit_in && ic_valid_in)) begin
                    status_next_reg = `STAT_IC_MISS;
                    counter_next_reg = 3'b000;
                end
                else begin
                    status_next_reg = `STAT_NORMAL;
                    counter_next_reg = 3'b111;
                end
            end
        end
    endcase 
end

endmodule
