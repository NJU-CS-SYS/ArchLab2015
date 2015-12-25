`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yh
// 
// Create Date: 2015/12/08 19:21:32
// Design Name: 
// Module Name: idex_reg
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


module idex_reg( 
    input clk,
    input reset,
    input cu_stall,
    input cu_flush,
    input id_nop,
    input [4:0] id_rd_addr,
    input idex_mem_w_in,
    input idex_mem_r_in,
    input idex_reg_w_in,
    input idex_branch_in,
    input [2:0] idex_condition_in,
    input idex_of_w_disen_in,
    input [1:0] idex_exres_sel_in,
    input idex_B_sel_in,
    input [3:0] idex_ALU_op_in,
    input idex_shamt_sel_in,
    input [4:0] idex_shamt_in,
    input [1:0] idex_shift_op_in,
    input [31:0] idex_imm_ext_in,
    input [4:0] idex_rd_addr_in,
    input [31:0] idex_pc_in,
    input [31:0] idex_pc_4_in,
    input [2:0] idex_load_sel_in,
    input [2:0] idex_store_sel_in,
    input [31:0] idex_op_A_in,
    input [31:0] idex_op_B_in,
    input [4:0] idex_rs_addr_in,
    input [4:0] idex_rt_addr_in,
    input [4:0] idex_cp0_dst_addr_in,
    input idex_cp0_w_en_in,
    input idex_syscall_in,
    input idex_eret_in,
    input id_movz,
    input id_movn,
    output reg ex_nop,
    output reg idex_mem_w,
    output reg idex_mem_r,
    output reg idex_reg_w,
    output reg idex_branch,
    output reg [2:0] idex_condition,
    output reg idex_of_w_disen,
    output reg [1:0] idex_exres_sel,
    output reg idex_B_sel,
    output reg [3:0] idex_ALU_op,
    output reg idex_shamt_sel,
    output reg [4:0] idex_shamt,
    output reg [1:0] idex_shift_op,
    output reg [31:0] idex_imm_ext,
    output reg [4:0] idex_rd_addr,
    output reg [31:0] idex_pc,
    output reg [31:0] idex_pc_4,
    output reg [2:0] idex_load_sel,
    output reg [2:0] idex_store_sel,
    output reg [31:0] idex_op_A,
    output reg [31:0] idex_op_B,
    output reg [4:0] idex_rs_addr,
    output reg [4:0] idex_rt_addr,
    output reg [4:0] idex_cp0_dst_addr,
    output reg idex_movz,
    output reg idex_movn,
    output reg idex_cp0_w_en,
    output reg idex_syscall,
    output reg idex_eret
    );
    
    always @(negedge clk or posedge reset) begin
        if(reset||(cu_flush && !cu_stall)) begin
            idex_mem_w <= 1'd0;
            idex_mem_r <= 1'd0;
            idex_reg_w <= 1'd0;
            idex_branch <= 1'd0;
            idex_condition <= 3'd0;
            idex_of_w_disen <= 1'd0;
            idex_exres_sel <= 2'd0;
            idex_B_sel <= 1'd0;
            idex_ALU_op <= 4'd0;
            idex_shamt_sel <= 1'd0;
            idex_shamt <= 5'd0;
            idex_shift_op <= 2'd0;
            idex_imm_ext <= 32'd0;
            idex_rd_addr <= 5'd0;
            idex_pc <= 32'd0;
            idex_pc_4 <= 32'd0;
            idex_load_sel <= 3'd0;
            idex_store_sel <= 3'd0;
            idex_op_A <= 32'd0;
            idex_op_B <= 32'd0;
            idex_rs_addr <= 5'd0;
            idex_rt_addr <= 5'd0;
            idex_cp0_dst_addr <= 5'd0;
            idex_cp0_w_en <= 1'd0;
            idex_syscall <= 1'd0;
            idex_eret <= 1'd0;
            idex_movz <= 1'b0;
            idex_movn <= 1'b0;
            ex_nop <= 1'b1;
        end
        else if(!cu_stall) begin
            idex_mem_w<= idex_mem_w_in;
            idex_mem_r<= idex_mem_r_in;
            idex_reg_w<=idex_reg_w_in;
            idex_branch<=idex_branch_in;
            idex_condition<=idex_condition_in;
            idex_of_w_disen<= idex_of_w_disen_in;
            idex_exres_sel<=idex_exres_sel_in;
            idex_B_sel<= idex_B_sel_in;
            idex_ALU_op<=idex_ALU_op_in;
            idex_shamt_sel<= idex_shamt_sel_in;
            idex_shamt<=idex_shamt_in;
            idex_shift_op<=idex_shift_op_in;
            idex_imm_ext<=idex_imm_ext_in;
            idex_rd_addr<= idex_rd_addr_in;
            idex_pc<= idex_pc_in;
            idex_pc_4<=idex_pc_4_in;
            idex_load_sel<= idex_load_sel_in;
            idex_store_sel<=idex_store_sel_in;
            idex_op_A<=idex_op_A_in;
            idex_op_B<=idex_op_B_in;
            idex_rs_addr<= idex_rs_addr_in;
            idex_rt_addr<= idex_rt_addr_in;
            idex_cp0_dst_addr<= idex_cp0_dst_addr_in;
            idex_cp0_w_en<=idex_cp0_w_en_in;
            idex_syscall<=idex_syscall_in;
            idex_eret<=idex_eret_in;
            idex_movz <= id_movz;
            idex_movn <= id_movn;
            ex_nop <= id_nop;
        end
    end
endmodule

