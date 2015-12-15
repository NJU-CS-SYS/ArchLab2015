`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2015/12/07 20:52:29
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
    input id_jr,
    input mem_stall,
    input [4 :0] ifid_rs_addr,
    input [4 : 0] real_rt_addr,
    input [4 : 0] idex_rd_addr,
    input idex_mem_read,
    input [31 :0] predicted_idex_pc,
    input [31 : 0] target_exmem_pc,
    input cp0_intr,
    input id_jump,
    input exmem_eret,
    input exmem_syscall,
    //stall
    output reg [3 : 0]cu_pc_src,
    output reg cu_pc_stall,
    output reg cu_ifid_stall,
    output reg cu_idex_stall,
    output reg cu_exmem_stall,
    //flush
    output reg cu_ifid_flush,
    output reg cu_idex_flush,
    output reg cu_exmem_flush,

    output reg cu_cp0_w_en,
    output reg [4 : 0] cu_exec_code,
    output reg [31 : 0] cu_epc,
    output reg [31 :0] cu_vector,
    output reg bpu_write_en
    );



    wire load_use_hazard;
    wire branch_hazard;
    assign load_use_hazard = idex_mem_read & (idex_rd_addr == ifid_rs_addr | idex_rd_addr == real_rt_addr);
    assign branch_hazard = predicted_idex_pc != target_exmem_pc;


    always @(*) begin
        //initial
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
        cu_vector = 32'h80000180;
        bpu_write_en = 1'b0;

        //load_use  handle
        if(~branch_hazard  & load_use_hazard) begin
            cu_pc_stall = 1'b1;
            cu_ifid_stall = 1'b1;
            cu_idex_flush = 1'b1;
        end

        //branch_hazard handle
        if(branch_hazard) begin
            cu_ifid_flush = 1'b1;
          cu_idex_flush = 1'b1;
            cu_exmem_flush = 1'b1;
            if(~cp0_intr)
            begin
                cu_pc_src = 4;
            end
            bpu_write_en = 1'b1;
        end

        //j handle
        if(~branch_hazard & id_jump) begin
            cu_pc_src = 4'b0000;
            ifid_flush = 1;
        end

        //jr handle
        if(~branch_hazard & id_jr) begin
            cu_pc_src = 4'b0001;
            ifid_flush = 1;
        end

        //syscal handle
        if(exmem_syscall) begin
            cu_pc_src = 4'b0010;
            cu_cp0_w_en = 1'b1;
            cu_exec_code = 8;
            cu_epc = predicted_idex_pc;
        end



        //cp0 handle?????
        if(cp0_intr) begin
            cu_pc_src = 4'b0010;
            cu_cp0_w_en = 1'b1;
            cu_exec_code = 0;
            if(branch_hazard) begin
                cu_epc = target_exmem_pc;
            end
            else begin
                cu_epc = predicted_idex_pc;
            end
        end

        //eret/ret handle
        if(~branch_hazard & exmem_eret) begin
            cu_pc_src = 4'b0011;
        end
    end

endmodule
