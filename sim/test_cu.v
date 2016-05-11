`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/07 21:28:11
// Design Name: 
// Module Name: test
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


module test(
    );
    
    reg id_ir;
    reg mem_stall;
    reg [4 :0] ifid_rs_addr;
    reg [4 : 0] real_rt_addr;
    reg [4 : 0] idex_rd_addr;
    reg idex_mem_read;
    reg [31 :0] predicted_idex_pc;
    reg [31 : 0] target_exmem_pc;
    reg cp0_intr;
    reg id_jump;
    reg exmem_eret;
    reg exmem_syscall;
    //stall
    wire [3 : 0]cu_pc_src;
    wire cu_pc_stall;
    wire cu_ifid_stall;
    wire cu_idex_stall;
    wire cu_exmem_stall;
    //flush
    wire cu_ifid_flush;
    wire cu_idex_flush;
    wire cu_exmem_flush;

    wire cu_cp0_w_en;
    wire [4 : 0] cu_exec_code;
    wire [31 : 0] cu_epc;
    wire [31 :0] cu_vector;
    wire bpu_write_en;
    
    initial 
    begin
    id_ir = 0;
    mem_stall = 0;
    ifid_rs_addr = 1;
    real_rt_addr = 4;
    idex_rd_addr = 4;
    idex_mem_read = 1;
    predicted_idex_pc = 32'hffff0000;
    target_exmem_pc = 32'hffff0000;
    cp0_intr = 0;
    id_jump = 0;
    exmem_eret = 0;
    exmem_syscall = 0;
    end
    
    
    control_unit un(
    .id_ir(id_ir),
    .mem_stall(mem_stall),
    .ifid_rs_addr(ifid_rs_addr),
    .real_rt_addr(real_rt_addr),
    .idex_rd_addr(idex_rd_addr),
    .idex_mem_read(idex_mem_read),
    .predicted_idex_pc(predicted_idex_pc),
    .target_exmem_pc(target_exmem_pc),
    .cp0_intr(cp0_intr),
    .id_jump(id_jump),
    .exmem_eret(exmem_eret),
    .exmem_syscall(exmem_syscall),
    //stall
    .cu_pc_src(cu_pc_src),
    .cu_pc_stall(cu_pc_stall),
    .cu_ifid_stall(cu_ifid_stall),
    .cu_idex_stall(cu_idex_stall),
    .cu_exmem_stall(cu_exmem_stall),
    //flush
    .cu_ifid_flush(cu_ifid_flush),
    .cu_idex_flush(cu_idex_flush),
    .cu_exmem_flush(cu_exmem_flush),

    .cu_cp0_w_en(cu_cp0_w_en),
    .cu_exec_code(cu_exec_code),
    .cu_epc(cu_epc),
    .cu_vector(cu_vector),
    .bpu_write_en(bpu_write_en)
    );
    

always 
begin
//load_use1 hazard
#20
begin idex_mem_read = 1'b1; idex_rd_addr = 32'hfcfc8e70; ifid_rs_addr = 32'hfcfc8e70; real_rt_addr = 32'h00000000; end

//load_use2 hazard
#20
begin idex_mem_read = 1'b1; idex_rd_addr = 32'hfcfc8e70; ifid_rs_addr = 32'h00000000; real_rt_addr = 32'hfcfc8e70; end

//branch hazard
#20 begin predicted_idex_pc = 32'hccffc8e70; target_exmem_pc = 32'hceffc8e70; cpo_intr = 1'b0; end

#20 begin id_jump = 1'b1; predicted_idex_pc = 32'hccffc8e70; target_exmem_pc = 32'hccffc8e70; end

#20 begin id_jr = 1'b1; predicted_idex_pc = 32'hccffc8e70; target_exmem_pc = 32'hccffc8e70; end

#20 begin exmem_syscall = 1'b1; end

#20 begin cp0_intr = 1'b1; predicted_idex_pc = 32'hccffc8e70; target_exmem_pc = 32'hceffc8e70; end

#20 begin cp0_intr = 1'b1; predicted_idex_pc = 32'hccffc8e70; target_exmem_pc = 32'hccffc8e70; end

#20 begin exmem_eret = 1'b1; end
end
endmodule

