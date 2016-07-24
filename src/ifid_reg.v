`timescale 1ns / 1ps

/**
 * @brief ifid 流水段寄存器
 * @author whz
 */
 
`include "common.vh"

module ifid_reg(
    input clk,
    input reset,
    input cu_stall,
    input cu_flush,
    input [`PC_BUS] pc,
    input [`PC_BUS] pc_4,
    input [`DATA_BUS] instr,
    output reg id_nop,
    output reg [`PC_BUS] ifid_pc,
    output reg [`PC_BUS] ifid_pc_4,
    output reg [`DATA_BUS] ifid_instr,
    output [`JMP_BUS] ifid_jump_addr,
    output [`REG_ADDR_BUS] ifid_rs_addr,
    output [`REG_ADDR_BUS] ifid_rt_addr,
    output [`REG_ADDR_BUS] ifid_rd_addr,
    output [`IMM_BUS] ifid_imm
    );

    initial begin
        ifid_pc    = `PC_WIDTH'd0;
        ifid_pc_4  = `PC_WIDTH'd4;
        ifid_instr = `PC_WIDTH'd0;
    end

    assign ifid_jump_addr = { ifid_pc[`JMP_HEAD_SLICE], ifid_instr[`JMP_SLICE] };
    assign ifid_rs_addr   = ifid_instr[`RS_SLICE];
    assign ifid_rt_addr   = ifid_instr[`RT_SLICE];
    assign ifid_rd_addr   = ifid_instr[`RD_SLICE];
    assign ifid_imm       = ifid_instr[`IMM_SLICE];
    
    always @(negedge clk) begin
        if (reset || (!cu_stall && cu_flush)) begin
            ifid_pc    <= `PC_WIDTH'd0;
            ifid_pc_4  <= `PC_WIDTH'd4;
            ifid_instr <= `PC_WIDTH'd0;
            id_nop     <= 1'b1;
        end
        else if (cu_stall) begin
            ifid_pc    <= ifid_pc;
            ifid_pc_4  <= ifid_pc_4;
            ifid_instr <= ifid_instr;
            id_nop     <= id_nop;
        end
        else begin
            ifid_pc    <= pc;
            ifid_pc_4  <= pc_4;
            ifid_instr <= instr;
            id_nop     <= 1'b0;
        end
    end

endmodule
