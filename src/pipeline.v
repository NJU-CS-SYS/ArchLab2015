`timescale 1ns / 1ps

// File: pipeline.v
// The top module for the whole pipeline

`include "common.vh"

module pipeline (
    // PS2 Keyboard
    input PS2_CLK,
    input PS2_DATA,

    // ddr Inouts
    inout [15:0] ddr2_dq,
    inout [1:0] ddr2_dqs_n,
    inout [1:0] ddr2_dqs_p,
    // Just to simpilfy RTL generation,
    input [7:0] SW,
    input clk_in1,         // the global clock
    input manual_clk,
    input reset,       // the global reset
    input [3:0] debug_sel,
    //input [7:0] intr,   // 8 hardware interruption
    //output [31:0] mem_pc_out,
    output [15:0] led,

    // ddr Outputs
    output [12:0] ddr2_addr,
    output [2:0] ddr2_ba,
    output ddr2_ras_n,
    output ddr2_cas_n,
    output ddr2_we_n,
    output [0:0] ddr2_ck_p,
    output [0:0] ddr2_ck_n,
    output [0:0] ddr2_cke,
    //output [0:0]           ddr2_cs_n,
    output [1:0] ddr2_dm,
    output [0:0] ddr2_odt,
        
    // VGA outputs
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS,

    //flash
    output flash_s,
    inout [3:0] flash_dq,

    //debug
    output [6:0] seg_out,
    output [7:0] seg_ctrl
);

parameter DATA_WIDTH = 32;

////////////////////////////////////////////////////////////////////////////////
//
//
//  Signal declaration
//
////////////////////////////////////////////////////////////////////////////////

wire [DATA_WIDTH - 1 : 0] predicted_pc;
wire bpu_w_en;                        // Whether the PC in EX is expected
wire clk;

wire [DATA_WIDTH - 1 : 0] jmp;        // Absolute jump
wire [DATA_WIDTH - 1 : 0] jr;         // Jump to $31
wire [DATA_WIDTH - 1 : 0] cu_vector;  // Entry for exception handling
wire [DATA_WIDTH - 1 : 0] epc;        // Eret
wire [DATA_WIDTH - 1 : 0] target;     // Control harzard

reg [DATA_WIDTH - 1 : 0] pc_in;       // Next pc to go into the pipeline

wire [DATA_WIDTH - 1 : 0] pc_out;  // PC to fetch instruction

////////////////////////////////////////////////////////////////////////////
//  Instruction
//  I-cache and D-cache are implemented together, it will be instanciated
//  later.
////////////////////////////////////////////////////////////////////////////

wire [DATA_WIDTH - 1 : 0] ic_data_out;

wire [DATA_WIDTH - 1 : 0] ifid_pc, ifid_pc_4;
wire [DATA_WIDTH - 1 : 0] ifid_jump_addr;
wire [DATA_WIDTH - 1 : 0] ifid_instr;
wire [`REG_ADDR_BUS] ifid_rs_addr, ifid_rt_addr, ifid_rd_addr;
wire [`IMM_BUS] ifid_imm;

wire id_jr;
wire id_jump;
wire idex_syscall;
wire idex_eret;
wire [1:0] id_imm_ext;
wire idex_mem_w;
wire idex_mem_r;
wire idex_reg_w;
wire idex_branch;
wire [2:0] idex_condition;
wire idex_B_sel;
wire [3:0] idex_ALU_op;
wire [4:0] idex_shamt;
wire idex_shamt_sel;
wire [1:0] idex_shift_op;
wire [2:0] idex_load_sel;
wire [2:0] idex_store_sel;
wire [1:0] id_rd_addr_sel;
wire [4:0] idex_cp0_dest_addr;
wire id_rt_addr_sel;
wire id_rt_data_sel;
wire [`REG_ADDR_BUS] id_cp0_src_addr;
wire [2:0] idex_exres_sel;
wire idex_movn;
wire idex_movz;

reg [`REG_ADDR_BUS] id_rt_addr;

wire [DATA_WIDTH - 1 : 0] wb_data_in;
wire [DATA_WIDTH - 1 : 0] id_rs_out;
wire [DATA_WIDTH - 1 : 0] id_rt_out;

reg [`REG_ADDR_BUS] id_rd_addr;

wire [DATA_WIDTH - 1 : 0] id_gpr_rs = id_rs_out;  // For name consistence
reg [DATA_WIDTH - 1 : 0] id_gpr_rt;
wire [DATA_WIDTH - 1 : 0] cp0_data;

wire ex_movz;
wire ex_movn;
wire ex_mem_w;
wire ex_mem_r;
wire ex_reg_w;
wire ex_branch;
wire [2:0] ex_condition;
wire ex_of_w_disen;
wire [2:0] ex_exres_sel;
wire ex_B_sel;
wire [3:0] ex_ALU_op;
wire ex_shamt_sel;
wire [4:0] ex_shamt;
wire [1:0] ex_shift_op;
wire [`DATA_BUS] ex_imm_ext;
wire [`PC_BUS] ex_pc;
wire [`PC_BUS] ex_pc_4;
wire [`REG_ADDR_BUS] ex_rd_addr;
wire [2:0] ex_load_sel;
wire [2:0] ex_store_sel;
wire [`DATA_BUS] ex_op_A;
wire [`DATA_BUS] ex_op_B;
wire [`REG_ADDR_BUS] ex_rs_addr;
wire [`REG_ADDR_BUS] ex_rt_addr;
wire [`REG_ADDR_BUS] ex_cp0_dst_addr;
wire ex_cp0_w_en;
wire ex_syscall;
wire ex_eret;

wire [DATA_WIDTH - 1 : 0] imm_ext;

// Result after various selections
reg [`DATA_BUS] operand_A_after_forwarding;
reg [`DATA_BUS] operand_A_after_selection;
reg [`DATA_BUS] operand_B_after_forwarding;
reg [`DATA_BUS] operand_B_after_selection;
reg [`DATA_BUS] exec_result;
reg [4:0] shamt_after_sel;

// Exec result candidates
wire [`DATA_BUS] alu_out;
wire [`DATA_BUS] shifter_out;

wire ex_jr;  // JR indicator
wire [`PC_BUS] branch_addr = (ex_jr == 1) ? alu_out : ex_pc_4 + (ex_imm_ext<<2);

// Forwarding selectors
wire [1:0] A_sel;
wire [1:0] B_sel;
// Forwarding result
wire [`DATA_BUS] input_A;
wire [`DATA_BUS] input_B;

wire ex_less;      // High if A < B
wire ex_overflow;  // High if A op B > MAX or A op B < MIN
wire ex_zero;      // High if A op B == 0

wire [3:0] ex_reg_byte_w_en;
wire [3:0] ex_mem_byte_w_en;
wire [`DATA_BUS] ex_aligned_rt_data;

// MEM pc
wire [`PC_BUS] mem_pc;
wire [`PC_BUS] mem_pc_4;
// MEM enable
wire mem_mem_w;
wire mem_mem_r;
wire mem_reg_w;
wire [3:0] mem_reg_byte_w_en;
wire [3:0] mem_mem_byte_w_en;
// MEM register related
wire [`REG_ADDR_BUS] mem_rd_addr;
wire [`DATA_BUS] mem_alu_res;
// MEM memory related
wire [`REG_ADDR_BUS] mem_cp0_dst_addr;
// The data from EX, used in the MEM segment.
// It has been aligned in the EX segment, and will provide data to MEMWB and Memory when SW* is excuted.
wire [`DATA_BUS] mem_aligned_rt_data;
wire [`DATA_BUS] mem_aligned_mem_data ;
// MEM control
wire mem_branch;
wire mem_lf;
wire mem_zf;
wire [2:0] mem_load_sel;
wire [2:0] mem_condition;
wire [`PC_BUS] mem_target;
// MEM exception
wire mem_cp0_w_en;
wire mem_syscall;
wire mem_eret;

// Normal pipeline part
wire wb_mem_r;                    // High if read from memory
wire wb_reg_w;                    // High if can write to gpr
wire [3:0] wb_reg_byte_w_en;      // High if this byte can be written
wire [`DATA_BUS] wb_ex_data;      // Data from EX
wire [`DATA_BUS] wb_mem_data;     // Data from MEM
wire [`REG_ADDR_BUS] wb_rd_addr;  // Write to this register

// Exception part
wire [`REG_ADDR_BUS] wb_cp0_dst_addr;
wire wb_cp0_w_en;

// Output
wire [`DATA_BUS] memwb_data = (wb_mem_r) ? wb_mem_data : wb_ex_data;

wire [`PC_BUS] mem_final_target;  // output from final_target to control unit

wire [`DATA_BUS] mem_data;  // output from cpu_interface.data_out to load_shifter.mem_data

wire [3:0] id_md_op;
wire [3:0] ex_md_op;
wire [31:0] muldiv_out;
wire md_stall;

////////////////////////////////////////////////////////////////////////////
//
//  IF
//
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
//  BPU
////////////////////////////////////////////////////////////////////////////

wire [`PC_BUS] if_pc_4;

BPU bpu (
    // Input
    .clk          ( clk              ),
    .reset        ( reset            ),
    .bpu_w_en     ( bpu_w_en         ),
    .current_pc   ( if_pc_4          ),  // When reseted, ifid is flushed, and ifid_pc_4 is zero.
    .tag_pc       ( mem_pc_4         ),
    .next_pc      ( mem_final_target ),
    // Output
    .predicted_pc ( predicted_pc     )
);

wire [3:0] cu_pc_src;  // Select pc source, get data from control unit.

always @(*) begin
    case (cu_pc_src)
    3'd0: pc_in = jmp;
    3'd1: pc_in = jr;
    3'd2: pc_in = cu_vector;
    3'd3: pc_in = epc;
    3'd4: pc_in = target;
    3'd5: pc_in = predicted_pc;
    default: pc_in = 0;
    endcase
end

assign target = mem_final_target;


////////////////////////////////////////////////////////////////////////////
//  PC register
////////////////////////////////////////////////////////////////////////////

wire cu_pc_stall;

PC PC (
    .clk    ( clk         ),
    .reset  ( reset       ),
    .stall  ( cu_pc_stall ),
    .pc_in  ( pc_in       ),
    .pc_out ( pc_out      )
);

////////////////////////////////////////////////////////////////////////////
//  IFID register
////////////////////////////////////////////////////////////////////////////

assign jmp = ifid_jump_addr;
assign jr = id_rs_out;
assign if_pc_4 = (reset) ? 0 : pc_out + 4;  // Start from zero

wire id_nop;  // Indicate that the current instr in ID is nop
              // The ifid does not have a input nop-indicator,
              // because PC is always right in the next cycle.

wire cu_ifid_stall;
wire cu_ifid_flush;

ifid_reg ifid (
    // Input
    .clk            ( clk            ),
    .reset          ( reset          ),
    .cu_stall       ( cu_ifid_stall  ),
    .cu_flush       ( cu_ifid_flush  ),
    .pc             ( pc_out         ),
    .pc_4           ( if_pc_4        ),
    .instr          ( ic_data_out    ),
    // Output
    .id_nop         ( id_nop         ),
    .ifid_pc        ( ifid_pc        ),
    .ifid_pc_4      ( ifid_pc_4      ),
    .ifid_instr     ( ifid_instr     ),
    .ifid_jump_addr ( ifid_jump_addr ),
    .ifid_rs_addr   ( ifid_rs_addr   ),
    .ifid_rt_addr   ( ifid_rt_addr   ),
    .ifid_rd_addr   ( ifid_rd_addr   ),
    .ifid_imm       ( ifid_imm       )
);

////////////////////////////////////////////////////////////////////////////
//
//  ID
//
////////////////////////////////////////////////////////////////////////////

wire idex_of_w_disen;
wire idex_cp0_w_en;

decoder decoder(
    // Input
    .ifid_instr         ( ifid_instr         ),
    // Output
    .idex_mem_w         ( idex_mem_w         ),
    .idex_mem_r         ( idex_mem_r         ),
    .idex_reg_w         ( idex_reg_w         ),
    .idex_branch        ( idex_branch        ),
    .idex_condition     ( idex_condition     ),
    .idex_B_sel         ( idex_B_sel         ),
    .idex_ALU_op        ( idex_ALU_op        ),
    .idex_shamt         ( idex_shamt         ),
    .idex_shamt_sel     ( idex_shamt_sel     ),
    .idex_shift_op      ( idex_shift_op      ),
    .idex_load_sel      ( idex_load_sel      ),
    .idex_store_sel     ( idex_store_sel     ),
    .idex_of_w_disen    ( idex_of_w_disen    ),
    .idex_cp0_dest_addr ( idex_cp0_dest_addr ),
    .idex_cp0_w_en      ( idex_cp0_w_en      ),
    .idex_syscall       ( idex_syscall       ),
    .idex_eret          ( idex_eret          ),
    .id_imm_ext         ( id_imm_ext         ),
    .id_jr              ( id_jr              ),
    .id_jump            ( id_jump            ),
    .id_rd_addr_sel     ( id_rd_addr_sel     ),
    .id_rt_addr_sel     ( id_rt_addr_sel     ),
    .id_rt_data_sel     ( id_rt_data_sel     ),
    .id_cp0_src_addr    ( id_cp0_src_addr    ),
    .idex_exres_sel     ( idex_exres_sel     ),
    .idex_movn          ( idex_movn          ),
    .idex_movz          ( idex_movz          ),
    .idex_div_mul       ( id_md_op           )
);

// $0 selector
always @(*) begin
    case (id_rt_addr_sel)
    1'b0: id_rt_addr = ifid_rt_addr;
    1'b1: id_rt_addr = 5'd0;
    endcase
end

////////////////////////////////////////////////////////////////////////////
//  GPR
////////////////////////////////////////////////////////////////////////////

wire [31:0] dbg_reg;

GPR gpr (
    .dbg_reg_addr ( SW[4:0]          ),
    .dbg_reg      ( dbg_reg          ),
    .clk          ( ~clk             ), // write in the wb cycle, not the next cycle
    .reset        ( reset            ),
    .write        ( wb_reg_w         ),
    .Rs_addr      ( ifid_rs_addr     ),
    .Rt_addr      ( id_rt_addr       ),
    .Rd_addr      ( wb_rd_addr       ),
    .Rd_in        ( wb_data_in       ),
    .Rd_Byte_w_en ( wb_reg_byte_w_en ),
    .Rs_out       ( id_rs_out        ),
    .Rt_out       ( id_rt_out        )
);

extension ext (
    .ifid_imm   ( ifid_imm   ),
    .id_imm_ext ( id_imm_ext ),
    .imm_ext    ( imm_ext    )
);

// Rd addr selector
always @(*) begin
    case (id_rd_addr_sel)
    2'd0: id_rd_addr = ifid_rt_addr;
    2'd1: id_rd_addr = ifid_rd_addr;
    2'd2: id_rd_addr = 5'b11111;
    default: id_rd_addr = 5'b00000;
    endcase
end

// Rt data selector
always @(*) begin
    case (id_rt_data_sel)
    1'b0: id_gpr_rt = cp0_data;
    1'b1: id_gpr_rt = id_rt_out;
    endcase
end

wire ex_nop;  // Indicate that the current instr in EX is nop
wire ex_jmp;  // Transfer jmp to ex -> mem to indicate CU
wire cu_idex_stall;
wire cu_idex_flush;

idex_reg idex_reg (
    // Input
    .clk                  ( clk             ),
    .reset                ( reset           ),
    .id_md_op             ( id_md_op        ),
    .id_nop               ( id_nop          ),
    .id_jmp               ( id_jump         ),
    .id_jr                ( id_jr           ),
    .cu_stall             ( cu_idex_stall   ),
    .cu_flush             ( cu_idex_flush   ),
    .idex_mem_r_in        ( idex_mem_r      ),
    .idex_mem_w_in        ( idex_mem_w      ),
    .idex_reg_w_in        ( idex_reg_w      ),
    .idex_branch_in       ( idex_branch     ),
    .idex_condition_in    ( idex_condition  ),
    .idex_of_w_disen_in   ( idex_of_w_disen ),
    .idex_exres_sel_in    ( idex_exres_sel  ),
    .idex_B_sel_in        ( idex_B_sel      ),
    .idex_ALU_op_in       ( idex_ALU_op     ),
    .idex_shamt_sel_in    ( idex_shamt_sel  ),
    .idex_shamt_in        ( idex_shamt      ),
    .idex_shift_op_in     ( idex_shift_op   ),
    .idex_imm_ext_in      ( imm_ext         ),
    .idex_rd_addr_in      ( id_rd_addr      ),
    .idex_pc_in           ( ifid_pc         ),
    .idex_pc_4_in         ( ifid_pc_4       ),
    .idex_load_sel_in     ( idex_load_sel   ),
    .idex_store_sel_in    ( idex_store_sel  ),
    .idex_op_A_in         ( id_gpr_rs       ),
    .idex_op_B_in         ( id_gpr_rt       ),
    .idex_rs_addr_in      ( ifid_rs_addr    ),
    .idex_rt_addr_in      ( id_rt_addr      ),
    .idex_cp0_dst_addr_in ( ifid_rd_addr    ),
    .idex_cp0_w_en_in     ( idex_cp0_w_en   ),
    .idex_syscall_in      ( idex_syscall    ),
    .idex_eret_in         ( idex_eret       ),
    .id_movz              ( idex_movz       ),
    .id_movn              ( idex_movn       ),
    // Output
    .idex_md_op           ( ex_md_op        ),
    .ex_nop               ( ex_nop          ),
    .ex_jmp               ( ex_jmp          ),
    .ex_jr                ( ex_jr           ),
    .idex_mem_w           ( ex_mem_w        ),
    .idex_mem_r           ( ex_mem_r        ),
    .idex_reg_w           ( ex_reg_w        ),
    .idex_branch          ( ex_branch       ),
    .idex_condition       ( ex_condition    ),
    .idex_of_w_disen      ( ex_of_w_disen   ),
    .idex_exres_sel       ( ex_exres_sel    ),
    .idex_B_sel           ( ex_B_sel        ),
    .idex_ALU_op          ( ex_ALU_op       ),
    .idex_shamt_sel       ( ex_shamt_sel    ),
    .idex_shamt           ( ex_shamt        ),
    .idex_shift_op        ( ex_shift_op     ),
    .idex_imm_ext         ( ex_imm_ext      ),
    .idex_rd_addr         ( ex_rd_addr      ),
    .idex_pc              ( ex_pc           ),
    .idex_pc_4            ( ex_pc_4         ),
    .idex_load_sel        ( ex_load_sel     ),
    .idex_store_sel       ( ex_store_sel    ),
    .idex_op_A            ( ex_op_A         ),
    .idex_op_B            ( ex_op_B         ),
    .idex_rs_addr         ( ex_rs_addr      ),
    .idex_rt_addr         ( ex_rt_addr      ),
    .idex_cp0_dst_addr    ( ex_cp0_dst_addr ),
    .idex_movz            ( ex_movz         ),
    .idex_movn            ( ex_movn         ),
    .idex_cp0_w_en        ( ex_cp0_w_en     ),
    .idex_syscall         ( ex_syscall      ),
    .idex_eret            ( ex_eret         )
);

////////////////////////////////////////////////////////////////////////////
//
//  EX
//
////////////////////////////////////////////////////////////////////////////

// If the instruction is movn or movz, this operand should be 0
// in order to perform the moving operation.
always @(*) begin
    case (ex_movz || ex_movn)
    1'b0: operand_A_after_selection = operand_A_after_forwarding;
    1'b1: operand_A_after_selection = `DATA_WIDTH'd0;
    endcase
end

// If the instruction is branch or lui, this operand should be immediate.
// When the instruction is `movn(z)' or `movz', RT, a.k.a ope_B acts as a conditon,
// while RS, a.k.a ope_A is where the data to be transfered from.
// As move operation is ADD RD <- RS, 0, the ope_B should be selected as constant zero.
always @(*) begin
    case (ex_B_sel)
    1'b0: operand_B_after_selection = (ex_movz || ex_movn) ? operand_A_after_forwarding
                                                           : operand_B_after_forwarding;
    1'b1: operand_B_after_selection = ex_imm_ext;
    endcase
end

// Select the source of the shift amount, from instruction or register.
always @(*) begin
    case (ex_shamt_sel)
    1'b0: shamt_after_sel = ex_shamt;
    1'b1: shamt_after_sel = operand_A_after_forwarding[4:0];
    endcase
end

// Forwarding
always @(*) begin
    case (A_sel)
    2'd0: operand_A_after_forwarding = ex_op_A;
    2'd1: operand_A_after_forwarding = mem_alu_res;
    2'd2: operand_A_after_forwarding = input_A;
    2'd3: operand_A_after_forwarding = 32'dx;
    endcase
end

always @(*) begin
    case (B_sel)
    2'd0: operand_B_after_forwarding = ex_op_B;
    2'd1: operand_B_after_forwarding = mem_alu_res;
    2'd2: operand_B_after_forwarding = input_B;
    2'd3: operand_B_after_forwarding = 32'dx;
    endcase
end

// Exec result selection
always @(*) begin
    case (ex_exres_sel)
    3'd0: exec_result = alu_out;
    3'd1: exec_result = shifter_out;
    3'd2: exec_result = branch_addr;
    3'd3: exec_result = operand_A_after_forwarding;
    3'd4: exec_result = muldiv_out;
    default: exec_result = 32'dx;
    endcase
end

alu alu (
    // Input
    .A       ( operand_A_after_selection ),
    .B       ( operand_B_after_selection ),
    .op      ( ex_ALU_op                 ),
    // Output
    .LF_out  ( ex_less                   ),
    .OF_out  ( ex_overflow               ),
    .ZF_out  ( ex_zero                   ),
    .alu_out ( alu_out                   )
);

barrel_shifter shifter (
    // Input
    .Shift_in     ( operand_B_after_forwarding ),
    .Shift_amount ( shamt_after_sel            ),
    .Shift_op     ( ex_shift_op                ),
    // Output
    .Shift_out    ( shifter_out                )
);

muldiv mul_div (
	//input
	.Md_op      ( ex_md_op                  ),
	.Rs_in      ( operand_A_after_selection ),
	.Rt_in      ( operand_B_after_selection ),
	.Clk        ( clk                       ),
	//output
	.Res_out    ( muldiv_out                ),
	.Md_stall ( md_stall                )
);

wire ex_reg_w_gened;  // The handled reg_w, often disenable for special cases

// When the instruction is `movn(z)' or `movn', the real RT data
// is not sent to ALU to get the ZF. So we should change the input
// ZF to generate exact write enable.
// zf_if_cond_mov := the zero flag if condtitional move
wire zf_if_cond_mov = (ex_movz || ex_movn) ? (operand_B_after_forwarding == 32'd0)
                                           : ex_zero;
reg_w_gen reg_w_gen (
    // Input
    .of              ( ex_overflow    ),
    .zf              ( zf_if_cond_mov ),
    .idex_movz       ( ex_movz        ),
    .idex_movnz      ( ex_movn        ),
    .idex_reg_w      ( ex_reg_w       ),
    .idex_of_w_disen ( ex_of_w_disen  ),
    // Output
    .new_reg_w       ( ex_reg_w_gened )
);

// Special load and store byte write enable
load_b_w_e_gen inst_load_b_w_e_gen (
    .addr     ( alu_out[1:0]     ),
    .load_sel ( ex_load_sel      ),
    .b_w_en   ( ex_reg_byte_w_en )
);

store_b_w_e_gen  inst_store_b_w_e_gen (
    .addr      ( alu_out[1:0]     ),
    .store_sel ( ex_store_sel     ),
    .b_w_en    ( ex_mem_byte_w_en )
);

store_shifter  inst_store_shifter (
    .addr         ( alu_out[1:0]               ),
    .store_sel    ( ex_store_sel               ),
    .rt_data      ( operand_B_after_forwarding ),
    .real_rt_data ( ex_aligned_rt_data         )
);

// Forwarding Unit

ForwardUnit FU (
    // Input from EX
    .rs_data       ( ex_op_A           ),
    .rt_data       ( ex_op_B           ),
    .rs_addr       ( ex_rs_addr        ),
    .rt_addr       ( ex_rt_addr        ),
    // Input from MEM
    .exmem_rd_addr ( mem_rd_addr       ),
    .exmem_byte_en ( mem_reg_byte_w_en ),
    .exmem_w_en    ( mem_reg_w         ),
    // Input from WB
    .memwb_data    ( memwb_data        ),
    .memwb_rd_addr ( wb_rd_addr        ),
    .memwb_byte_en ( wb_reg_byte_w_en  ),
    .memwb_w_en    ( wb_reg_w          ),
    // Output
    .input_A       ( input_A           ),
    .input_B       ( input_B           ),
    .A_sel         ( A_sel             ),
    .B_sel         ( B_sel             )
);


wire cu_exmem_stall;
wire cu_exmem_flush;
wire mem_nop;  // Indicate that the current instr in MEM is a nop.
wire mem_jmp;  // Transfer the jmp to mem to indicate CU

exmem_reg  inst_exmem_reg (
    // Input from global
    .clk                   ( clk                 ),
    .reset                 ( reset               ),
    // Input from Control Unit
    .cu_stall              ( cu_exmem_stall      ),
    .cu_flush              ( cu_exmem_flush      ),
    // Input from EX
    .ex_nop                ( ex_nop              ),
    .ex_jmp                ( ex_jmp              ),
    .idex_mem_w            ( ex_mem_w            ),
    .idex_mem_r            ( ex_mem_r            ),
    .idex_reg_w            ( ex_reg_w_gened      ),
    .idex_branch           ( ex_branch           ),
    .idex_condition        ( ex_condition        ),
    .addr_target           ( branch_addr         ),
    .alu_lf                ( ex_less             ),
    .alu_zf                ( ex_zero             ),
    .alu_of                ( ex_overflow         ),
    .ex_res                ( exec_result         ),
    .real_rd_addr          ( ex_rd_addr          ),
    .idex_load_sel         ( ex_load_sel         ),
    .reg_byte_w_en_in      ( ex_reg_byte_w_en    ),
    .mem_byte_w_en_in      ( ex_mem_byte_w_en    ),
    .idex_pc               ( ex_pc               ),
    .idex_pc_4             ( ex_pc_4             ),
    .aligned_rt_data       ( ex_aligned_rt_data  ),
    .idex_cp0_dst_addr     ( ex_cp0_dst_addr     ),
    .cp0_w_en_in           ( ex_cp0_w_en         ),
    .syscall_in            ( ex_syscall          ),
    .idex_eret             ( ex_eret             ),
    // Output to MEM
    .mem_nop               ( mem_nop             ),
    .mem_jmp               ( mem_jmp             ),
    .exmem_pc              ( mem_pc              ),
    .exmem_pc_4            ( mem_pc_4            ),
    .exmem_mem_w           ( mem_mem_w           ),
    .exmem_mem_r           ( mem_mem_r           ),
    .exmem_reg_w           ( mem_reg_w           ),
    .reg_byte_w_en_out     ( mem_reg_byte_w_en   ),
    .exmem_rd_addr         ( mem_rd_addr         ),
    .mem_byte_w_en_out     ( mem_mem_byte_w_en   ),
    .exmem_alu_res         ( mem_alu_res         ),
    .exmem_aligned_rt_data ( mem_aligned_rt_data ),
    .exmem_branch          ( mem_branch          ),
    .exmem_condition       ( mem_condition       ),
    .exmem_target          ( mem_target          ),
    .exmem_lf              ( mem_lf              ),
    .exmem_zf              ( mem_zf              ),
    .exmem_load_sel        ( mem_load_sel        ),
    .exmem_cp0_dst_addr    ( mem_cp0_dst_addr    ),
    .cp0_w_en_out          ( mem_cp0_w_en        ),
    .syscall_out           ( mem_syscall         ),
    .exmem_eret            ( mem_eret            )
);

////////////////////////////////////////////////////////////////////////////////
//
//  MEM
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//  Data Memory
//  Just wire here, see cpu_interface below.
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//  Branch unit
////////////////////////////////////////////////////////////////////////////////

final_target  inst_final_target (
    .Exmem_branch    ( mem_branch       ),
    .Exmem_condition ( mem_condition    ),
    .Exmem_target    ( mem_target       ),
    .Exmem_pc_4      ( mem_pc_4         ),
    .Exmem_lf        ( mem_lf           ),
    .Exmem_zf        ( mem_zf           ),
    .Final_target    ( mem_final_target )
);

////////////////////////////////////////////////////////////////////////////////
//  Load shifter
////////////////////////////////////////////////////////////////////////////////

load_shifter  inst_load_shifter (
   .addr        ( mem_alu_res[1:0]     ),
   .load_sel    ( mem_load_sel         ),
   .mem_data    ( mem_data             ),
   .data_to_reg ( mem_aligned_mem_data )
);

////////////////////////////////////////////////////////////////////////////////
//  MEMWB register
//  Output signals defined in the WB section.
////////////////////////////////////////////////////////////////////////////////

wire mem_stall;
wire [`DATA_BUS] wb_aligned_rt_data;

memwb_reg  inst_memwb_reg (
    // Global input
    .clk                 ( clk                  ),
    .reset               ( reset                ),
    .mem_stall           ( mem_stall            ),
    // Input from mem
    .exmem_mem_r         ( mem_mem_r            ),
    .exmem_reg_w         ( mem_reg_w            ),
    .reg_byte_w_en_in    ( mem_reg_byte_w_en    ),
    .exmem_rd_addr       ( mem_rd_addr          ),
    .mem_data            ( mem_aligned_mem_data ),
    .ex_data             ( mem_alu_res          ),
    .exmem_cp0_dst_addr  ( mem_cp0_dst_addr     ),
    .exmem_cp0_w_en      ( mem_cp0_w_en         ),
    // Output to wb
    .memwb_mem_r         ( wb_mem_r             ),
    .memwb_reg_w         ( wb_reg_w             ),
    .reg_byte_w_en_out   ( wb_reg_byte_w_en     ),
    .memwb_rd_addr       ( wb_rd_addr           ),
    .memwb_memdata       ( wb_mem_data          ),
    .memwb_exdata        ( wb_ex_data           ),
    .memwb_cp0_dst_addr  ( wb_cp0_dst_addr      ),
    .memwb_cp0_w_en      ( wb_cp0_w_en          )
);

////////////////////////////////////////////////////////////////////////////////
//
//  WB
//
////////////////////////////////////////////////////////////////////////////////

assign wb_data_in = (wb_mem_r) ? wb_mem_data : wb_ex_data;

////////////////////////////////////////////////////////////////////////////////
//
//  Control Unit
//
////////////////////////////////////////////////////////////////////////////////

wire cp0_intr;
wire cu_cp0_w_en;

wire [4:0] cu_exec_code;
wire [`PC_BUS] cu_epc;

control_unit  inst_control_unit (
    // Input
    .clk               ( clk                    ),
    .reset             ( reset                  ),
    .mem_stall         ( mem_stall | md_stall ),
    .mem_nop           ( mem_nop                ),
    .ex_nop            ( ex_nop                 ),
    .mem_jmp           ( mem_jmp                ),
    .ifid_rs_addr      ( ifid_rs_addr           ),
    .real_rt_addr      ( id_rt_addr             ),
    .idex_rd_addr      ( ex_rd_addr             ),
    .idex_mem_read     ( ex_mem_r               ),
    .predicted_idex_pc ( ex_pc                  ),
    .predicted_ifid_pc ( ifid_pc                ),
    .target_exmem_pc   ( mem_final_target       ),
    .mem_pc            ( mem_pc                 ),
    .cp0_intr          ( cp0_intr               ),
    .id_jump           ( id_jump                ),
    .exmem_eret        ( mem_eret               ),
    .exmem_syscall     ( mem_syscall            ),
    // Output
    .cu_pc_src         ( cu_pc_src              ),
    .cu_pc_stall       ( cu_pc_stall            ),
    .cu_ifid_stall     ( cu_ifid_stall          ),
    .cu_idex_stall     ( cu_idex_stall          ),
    .cu_exmem_stall    ( cu_exmem_stall         ),
    .cu_ifid_flush     ( cu_ifid_flush          ),
    .cu_idex_flush     ( cu_idex_flush          ),
    .cu_exmem_flush    ( cu_exmem_flush         ),
    .cu_cp0_w_en       ( cu_cp0_w_en            ),
    .cu_exec_code      ( cu_exec_code           ),
    .cu_epc            ( cu_epc                 ),
    .cu_vector         ( cu_vector              ),
    .bpu_write_en      ( bpu_w_en               )
);

////////////////////////////////////////////////////////////////////////////////
//
//  CP0
//
////////////////////////////////////////////////////////////////////////////////

cp0 inst_cp0 (
    .Wb_cp0_w_en     ( wb_cp0_w_en     ),
    .Cu_cp0_w_en     ( cu_cp0_w_en     ),
    .Epc             ( cu_epc          ),
    .Id_cp0_src_addr ( id_cp0_src_addr ),
    .Wb_cp0_dst_addr ( wb_cp0_dst_addr ),
    .Ex_data         ( wb_ex_data      ),
    .Cu_exec_code    ( cu_exec_code    ),
    //.Interrupt       ( intr            ),
    .Interrupt       ( {7'd0, SW[3]}   ),
    .Clk             ( clk             ),
    .Cp0_data        ( cp0_data        ),
    .Cp0_epc         ( epc             ),
    .Cp0_intr        ( cp0_intr        )
);

////////////////////////////////////////////////////////////////////////////////
//
//  Memory interface
//
////////////////////////////////////////////////////////////////////////////////

wire ui_clk_from_ddr;
wire [31:0] loader_data;
wire sync_manual_clk;

wire [26:0] addr_to_mig;
wire [255:0] buffer_of_ddrctrl;
wire [127:0] data_to_mig;
reg [31:0] part_of_buffer;
wire [31:0] ci_dbg_status;
wire clk_to_ddr_pass;
wire clk_to_pipixel_pass;

clock_control cc0(
    .clk_in1(clk_in1),
    .ui_clk_from_ddr(ui_clk_from_ddr),
    .SW(SW[7:6]),
    .manual_clk(manual_clk),
    .clk_to_ddr(clk_to_ddr_pass),
    .clk_to_pixel(clk_to_pixel_pass),
    .ui_clk_used(clk),
    .sync_manual_clk(sync_manual_clk)
);

//==--------------------------------==
// Singals indicating keyboard state.
//==--------------------------------==
wire kb_overflow;  // High if the keycode queue is overflow.
wire kb_ready;     // High if there are keycodes in the queue.

wire flash_read_done;
wire [2:0] flash_state;

cpu_interface inst_ci  (
    // PS2
    .ps2_clk           ( PS2_CLK             ),
    .ps2_data          ( PS2_DATA            ),
    // DDR Inouts
    .ddr2_dq           ( ddr2_dq             ),
    .ddr2_dqs_n        ( ddr2_dqs_n          ),
    .ddr2_dqs_p        ( ddr2_dqs_p          ),

    // DDR Outputs
    .ddr2_addr         ( ddr2_addr           ),
    .ddr2_ba           ( ddr2_ba             ),
    .ddr2_ras_n        ( ddr2_ras_n          ),
    .ddr2_cas_n        ( ddr2_cas_n          ),
    .ddr2_we_n         ( ddr2_we_n           ),
    .ddr2_ck_p         ( ddr2_ck_p           ),
    .ddr2_ck_n         ( ddr2_ck_n           ),
    .ddr2_cke          ( ddr2_cke            ),
    .ddr2_cs_n         (                     ),
    .ddr2_dm           ( ddr2_dm             ),
    .ddr2_odt          ( ddr2_odt            ),

    // VGA
    .VGA_R             ( VGA_R               ),
    .VGA_G             ( VGA_G               ),
    .VGA_B             ( VGA_B               ),
    .VGA_HS            ( VGA_HS              ),
    .VGA_VS            ( VGA_VS              ),

    .rst               ( ~reset              ), // reset is high active in this module
    .instr_addr        ( pc_out[31:2]        ),
    .dmem_read_in      ( mem_mem_r           ),
    .dmem_write_in     ( mem_mem_w           ),
    .dmem_addr         ( mem_alu_res[31:2]   ),
    .data_from_reg     ( mem_aligned_rt_data ),
    .dmem_byte_w_en    ( mem_mem_byte_w_en   ),
    .clk_to_ddr_pass   ( clk_to_ddr_pass     ), // 100 MHz
    .clk_to_pixel_pass ( clk_to_pixel_pass   ),
    .clk_pipeline      ( clk                 ),

    .ui_clk_from_ddr   ( ui_clk_from_ddr     ),
    .sync_manual_clk   ( sync_manual_clk     ),
    .instr_data_out    ( ic_data_out         ),
    .dmem_data_out     ( mem_data            ),
    .mem_stall         ( mem_stall           ),

    // debug
    .kb_overflow       ( kb_overflow         ),
    .kb_ready          ( kb_ready            ),
    .dbg_que_low       ( ci_dbg_status       ),
    .cache_stall       ( cache_stall         ),
    .trap_stall        ( trap_stall          ),
    .data_to_mig       ( data_to_mig         ),
    .buffer_of_ddrctrl ( buffer_of_ddrctrl   ),
    .addr_to_mig       ( addr_to_mig         ),
    // flash
    .flash_s(flash_s),
    .flash_dq(flash_dq),
    .flash_state(flash_state),
    .flash_cnt_begin(flash_cnt_begin),
    .flash_reading(flash_reading),
    .flash_read_done(flash_read_done)
);

reg [31:0] hex_to_seg;
// segs used to output instruction

seg_ctrl seg_ctrl0 (
    .clk           ( clk_in1           ),
    .hex1          ( hex_to_seg[3:0]   ),
    .hex2          ( hex_to_seg[7:4]   ),
    .hex3          ( hex_to_seg[11:8]  ),
    .hex4          ( hex_to_seg[15:12] ),
    .hex5          ( hex_to_seg[19:16] ),
    .hex6          ( hex_to_seg[23:20] ),
    .hex7          ( hex_to_seg[27:24] ),
    .hex8          ( hex_to_seg[31:28] ),
    .seg_out       ( seg_out           ),
    .seg_ctrl      ( seg_ctrl          )
);

always @ (*) begin
    case (SW[2:0])
        0: part_of_buffer = buffer_of_ddrctrl[1*32-1: 0*32];
        1: part_of_buffer = buffer_of_ddrctrl[2*32-1: 1*32];
        2: part_of_buffer = buffer_of_ddrctrl[3*32-1: 2*32];
        3: part_of_buffer = buffer_of_ddrctrl[4*32-1: 3*32];
        4: part_of_buffer = buffer_of_ddrctrl[5*32-1: 4*32];
        5: part_of_buffer = buffer_of_ddrctrl[6*32-1: 5*32];
        6: part_of_buffer = buffer_of_ddrctrl[7*32-1: 6*32];
        7: part_of_buffer = buffer_of_ddrctrl[8*32-1: 7*32];
    endcase
    case (debug_sel)
        4'b0000: hex_to_seg = ifid_instr;
        4'b0001: hex_to_seg = mem_pc;
        4'b0010: hex_to_seg = mem_alu_res;
        4'b0011: hex_to_seg = mem_aligned_rt_data;
        4'b0100: hex_to_seg = 32'd0;
        4'b0101: hex_to_seg = {5'd0, addr_to_mig};
        4'b0110: hex_to_seg = data_to_mig[31:0];
        4'b0111: hex_to_seg = part_of_buffer;
        4'b1000: hex_to_seg = dbg_reg;
        4'b1001: hex_to_seg = ci_dbg_status;
        default: hex_to_seg = mem_alu_res;
    endcase
end

//assign mem_pc_out = mem_pc;
assign led[0]       = mem_mem_w;
assign led[1]       = mem_mem_r;
assign led[2]       = mem_stall;
assign led[3]       = cache_stall;
assign led[4]       = flash_read_done;
assign led[5]       = kb_overflow;
assign led[6]       = kb_ready;
assign led[10:7]    = 0;
assign led[11]      = flash_reading;
assign led[12]      = flash_cnt_begin;
assign led[15:13]   = flash_state;

endmodule
