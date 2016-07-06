`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/27 17:21:29
// Design Name: 马浩杰
// Module Name: control_unit
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


module control_unit(
    input clk,
    input reset,
    input mem_stall,
    input [4 :0] ifid_rs_addr,
    input [4 : 0] real_rt_addr,
    input [4 : 0] idex_rd_addr,
    input idex_mem_read,
    input [31:0] predicted_idex_pc,
    input [31:0] predicted_ifid_pc,  // Used when a load-use hazard insert a nop
    input [31:0] target_exmem_pc,
    input [31:0] mem_pc,
    input cp0_intr,
    input id_jump,
    input mem_jmp,
    input exmem_eret,
    input exmem_syscall,
    input mem_nop,
    input ex_nop,
    // stall
    output reg [3 : 0]cu_pc_src,
    output reg cu_pc_stall,
    output reg cu_ifid_stall,
    output reg cu_idex_stall,
    output reg cu_exmem_stall,
    // flush
    output reg cu_ifid_flush,
    output reg cu_idex_flush,
    output reg cu_exmem_flush,

    output reg cu_cp0_w_en,
    output reg [4 : 0] cu_exec_code,
    output reg [31 : 0] cu_epc,
    output reg [31 :0] cu_vector,
    output reg bpu_write_en
);

    // Classic load use.
    wire load_use_hazard = idex_mem_read & (idex_rd_addr == ifid_rs_addr | idex_rd_addr == real_rt_addr);

    // Classic branch hazard, avoid the nop branch hazard handler inserted.
    // This will ignore the nop between load and use, but the use may be a wrong successor.
    wire classic_branch_hazard = !(ex_nop || mem_nop) && (predicted_idex_pc != target_exmem_pc);
    // Identify the load-use pipeline feature and check the prediction hazard.
    wire load_use_with_wrong_prediction_hazard = ex_nop && !mem_nop && !mem_jmp && (predicted_ifid_pc != target_exmem_pc);
    // Final branch hazard indicator.
    wire branch_hazard = classic_branch_hazard || load_use_with_wrong_prediction_hazard;

    reg [31:0] correct_pc;  // The pc for instruction that is sure to be executed.
    reg [31:0] clock_cnt;   // The number of clock cycles.
    reg [31:0] instr_cnt;   // The number of right instructions that have been executed.

    always @(negedge clk or posedge reset) begin: update_status
        if (reset) begin
            correct_pc <= 32'h00000000;
            clock_cnt <= 32'd0;
            instr_cnt <= 32'd0;
        end
        else begin
            if ( !mem_nop && !mem_stall ) begin
                correct_pc <= mem_pc;
                instr_cnt <= instr_cnt + 1;
            end
            clock_cnt <= clock_cnt + 1;
        end
    end

    always @(*) begin
        // initial
        cu_pc_src = 4'b0101;
        cu_pc_stall = 1'b0;
        cu_ifid_stall = 1'b0;
        cu_idex_stall = 1'b0;
        cu_exmem_stall = 1'b0;

        cu_ifid_flush = 1'b0;
        cu_idex_flush = 1'b0;
        cu_exmem_flush = 1'b0;

        cu_cp0_w_en = 1'b0;
        cu_exec_code = 5'b00000;
        cu_epc = 32'h00000000;
        // This value must be corresponded with `do_irq'
        // procedure address defined in `lib/start.S'.
        // As the start point of `_reset' in `lib/start.S' is 0xf00000,
        // and the code between `do_irq' and `_reset' is stable,
        // the address of `do_irq' might be fixed as assigned here.
        cu_vector = 32'hf000002c;
        bpu_write_en = 1'b0;

        // load_use  handle
        if (~branch_hazard  & load_use_hazard) begin
            cu_pc_stall = 1'b1;
            cu_ifid_stall = 1'b1;
            cu_idex_flush = 1'b1;
        end

        // branch_hazard handle
        if (branch_hazard) begin
            cu_ifid_flush = 1'b1;
            cu_idex_flush = 1'b1;
            cu_exmem_flush = 1'b1;

            if (~cp0_intr) begin 
                cu_pc_src = 4;
            end

            bpu_write_en = 1'b1;
        end

        // j handle
        if (~branch_hazard & id_jump) begin
            cu_pc_src = 4'b0000;
            cu_ifid_flush = 1;
        end

        // syscal handle
        if (exmem_syscall) begin
            cu_pc_src = 4'b0010;
            cu_cp0_w_en = 1'b1;
            cu_exec_code = 8;
            cu_epc = target_exmem_pc;
        end

        // cp0 handle
        if (cp0_intr) begin
            cu_pc_src = 4'b0010;
            cu_cp0_w_en = 1'b1;
            cu_exec_code = 0;
            if ( !mem_nop ) begin
                cu_epc = target_exmem_pc;  // target_exmem_pc is always the right one, except nop.
            end
            else begin
                cu_epc = correct_pc;
            end
        end

        // eret/ret handle
        if (exmem_eret) begin
            cu_ifid_flush = 1'b1;
            cu_idex_flush = 1'b1;
            cu_exmem_flush = 1'b1;
            cu_pc_src = 4'b0011;
        end

        if (mem_stall) begin
            cu_pc_stall = 1'b1;
            cu_ifid_stall = 1'b1;
            cu_idex_stall = 1'b1;
            cu_exmem_stall = 1'b1;
        end
    end

endmodule
