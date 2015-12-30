`timescale 1ns / 1ps

/*
 * @decoder 译码器模�?
 * @author XuanBaoQiong
 */
module decoder(
    input   [31:0] ifid_instr, output  reg idex_mem_w,
    output  reg idex_mem_r,
    output  reg idex_reg_w,
    output  reg idex_branch,
    output  reg [2:0] idex_condition,
    output  reg idex_B_sel,
    output  reg [3:0] idex_ALU_op,
    output  [4:0] idex_shamt,
    output  reg idex_shamt_sel,
    output  reg [1:0] idex_shift_op,
    output  reg [2:0] idex_load_sel,
    output  reg [2:0] idex_store_sel,
    output  reg idex_of_w_disen,
    output  [4:0] idex_cp0_dest_addr,
    output  reg idex_cp0_w_en,
    output  reg idex_syscall,
    output  reg idex_eret,
    output  reg [1:0] id_imm_ext,
    output  reg id_jr,
    output  reg id_jump,
    output  reg [1:0] id_rd_addr_sel,
    output  reg id_rt_addr_sel, // 0:instr[rt], 1:5'b0
    output  reg id_rt_data_sel, // 0:cp0_data, 1:Rt_data
    output  [4:0] id_cp0_src_addr,
    output  reg [2:0] idex_exres_sel,
    output  reg idex_movn,
    output  reg idex_movz,
	output  reg [3:0] idex_div_mul 
    );

    assign idex_shamt = ifid_instr[10:6];
    assign idex_rs_addr = ifid_instr[25:21];
    assign idex_rt_addr = ifid_instr[20:16];
    assign idex_cp0_dest_addr = ifid_instr[15:11];
    assign id_cp0_src_addr = ifid_instr[15:11];

    always@(*) begin
        /* NOP */
        if(ifid_instr == 0) begin
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 0; idex_mem_r = 0; idex_reg_w = 0;
            idex_branch = 0; idex_condition = 0;
            idex_of_w_disen = 0; idex_exres_sel = 0;
            idex_ALU_op = 0;
            idex_shamt_sel = 0;
            idex_shift_op = 0;
            idex_cp0_w_en = 0;
            idex_load_sel = 0; idex_store_sel = 0;
            idex_B_sel = 0;
            idex_eret = 0; idex_syscall = 0;
            id_imm_ext = 0;
            id_rd_addr_sel = 0;
            id_rt_addr_sel = 0;
            id_rt_data_sel = 1;
            id_jr = 0; id_jump = 0;
        end
        /* ADD ADDU SUB SUBU AND OR XOR NOR SLT SLTU */
        else if(ifid_instr[31:26] == 0 && ifid_instr[5:4] == 2'b10) begin
            /* same */
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_branch = 0; idex_condition = 0;    // unused
            idex_load_sel = 0; idex_store_sel = 0;  // unused
            idex_shamt_sel = 0; idex_shift_op = 0;  // unused
            id_imm_ext = 0; // unused
            idex_mem_w = 0; idex_mem_r = 0; idex_reg_w = 1;
            idex_cp0_w_en = 0;
            idex_eret = 0;
            idex_syscall = 0;
            id_rt_addr_sel = 0;
            id_rt_data_sel = 1;
            id_rd_addr_sel = 1;
            idex_B_sel = 0;
            idex_exres_sel = 0;  // choose ALU's result
            id_jr = 0; id_jump = 0;
            /* different */
            case(ifid_instr[3:0])
            // add
            4'b0000: begin
                idex_of_w_disen = 1;
                idex_ALU_op = 4'b1110;
            end
            // addu
            4'b0001: begin
                idex_of_w_disen = 0;
                idex_ALU_op = 4'b0000;
            end
            // sub
            4'b0010: begin
                idex_ALU_op = 4'b1111;
                idex_of_w_disen = 1;
            end
            // subu
            4'b0011: begin
                idex_ALU_op = 4'b0001;
                idex_of_w_disen = 0;
            end
            // and
            4'b0100: begin
                idex_ALU_op = 4'b0100;
                idex_of_w_disen = 0;
            end
            // or
            4'b0101: begin
                idex_ALU_op = 4'b0110;
                idex_of_w_disen = 0;
            end
            // xor
            4'b0110: begin
                idex_ALU_op = 4'b1001;
                idex_of_w_disen = 0;
            end
            // nor
            4'b0111: begin
                idex_ALU_op = 4'b1000;
                idex_of_w_disen = 0;
            end
            // slt
            4'b1010: begin
                idex_ALU_op = 4'b0101;
                idex_of_w_disen = 0;
            end
            // sltu
            4'b1011: begin
                idex_ALU_op = 4'b0111;
                idex_of_w_disen = 0;
            end
            default: begin
                idex_ALU_op = 4'b0111;
                idex_of_w_disen = 0;
            end
            endcase
        end
        /* SLL SLLV SRA SRAV SRL SRLV */
        else if(ifid_instr[31:26] == 0 && ifid_instr[5:3] == 3'b000) begin
            /* same */
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 0; idex_mem_r = 0; idex_reg_w = 1;
            idex_branch = 0; idex_condition = 0; // unused
            idex_load_sel = 0; idex_store_sel = 0; // unused
            idex_ALU_op = 0; idex_B_sel = 0; //unused
            idex_eret = 0; idex_syscall = 0;
            idex_of_w_disen = 0;
            idex_exres_sel = 1;
            idex_cp0_w_en = 0;
            id_imm_ext = 0; // unused
            id_rd_addr_sel = 1;
            id_rt_addr_sel = 0;
            id_rt_data_sel = 1;
            id_jr = 0; id_jump = 0;
            /* different */
            case(ifid_instr[2:0])
            // sll
            3'b000:
            begin
                idex_shamt_sel = 0;
                idex_shift_op = 2'b00;
            end
            // sllv
            3'b100:
            begin
                idex_shamt_sel = 1;
                idex_shift_op = 2'b00;
            end
            // sra
            3'b011:
            begin
                idex_shamt_sel = 0;
                idex_shift_op = 2'b10;
            end
            // srav
            3'b111:
            begin
                idex_shamt_sel = 1;
                idex_shift_op = 2'b10;
            end
            // srl
            3'b010:
            begin
                idex_shamt_sel = 0;
                idex_shift_op = 2'b01;
            end
            // srlv
            3'b110:
            begin
                idex_shamt_sel = 1;
                idex_shift_op = 2'b01;
            end
            default:
			begin
                idex_shamt_sel = 1;
				idex_shift_op = 2'b01;
            end
            endcase
        end
        /* SYSCALL JR MOVN MOVZ*/
        else if(ifid_instr[31:26] == 0 && ifid_instr[5:3] == 3'b001) begin
            /* same */
			idex_div_mul = 0;
            idex_mem_w = 0; idex_mem_r = 0;
            idex_condition = 0;
            idex_of_w_disen = 0;
            idex_exres_sel = 0;
            idex_ALU_op = 0;
            idex_shamt_sel = 0; idex_shift_op = 0;
            idex_cp0_w_en = 0;
            idex_load_sel = 0; idex_store_sel = 0;
            idex_B_sel = 0;
            idex_eret = 0;
            id_imm_ext = 0;
            id_rd_addr_sel = 1;
            id_rt_addr_sel = 0;
            id_rt_data_sel = 1;
            /* different */
            case(ifid_instr[2:0])
            // SYSCALL
            3'b100:
            begin
                idex_branch = 0;
                id_jump = 1;
                idex_syscall = 1;
                id_jr = 0;
                idex_reg_w = 0;
                idex_movn = 0;
                idex_movz = 0;
            end
            // JR
            3'b000:
            begin
                idex_branch = 1;
                id_jump = 0;
                idex_syscall = 0;
                id_jr = 1;
                idex_reg_w = 0;
                idex_movn = 0;
                idex_movz = 0;
            end
            // MOVN
            3'b011:
            begin
                idex_branch = 0;
                id_jump = 0;
                idex_syscall = 0;
                id_jr = 0;
                idex_reg_w = 1;
                idex_movn = 1;
                idex_movz = 0;
            end
            // MOVZ
            3'b010:
            begin
                idex_branch = 0;
                id_jump = 0;
                idex_syscall = 0;
                id_jr = 0;
                idex_reg_w = 1;
                idex_movn = 0;
                idex_movz = 1;
            end
            default:
			begin
                idex_branch = 0;
                id_jump = 0;
                idex_syscall = 0;
                id_jr = 0;
				idex_reg_w = 0;
                idex_movn = 0;
                idex_movz = 0;
            end
            endcase
        end
		/* MFHI MFLO MTHI MTLO */
		else if(ifid_instr[31:26] == 0 && ifid_instr[5:3] == 3'b010) begin
			 /* same */
			 idex_mem_w = 0; idex_mem_r = 0;
			 idex_branch = 0; idex_condition = 0; // unused
			 idex_of_w_disen = 0;
			 idex_exres_sel = 3'b100; // select the result of div/mul
			 idex_ALU_op = 0; // unused
			 idex_shamt_sel = 0; idex_shift_op = 0; // unused
			 idex_cp0_w_en = 0;
			 idex_load_sel = 0; idex_store_sel = 0;
			 idex_B_sel = 0;
			 idex_eret = 0; idex_syscall = 0;
			 idex_movn = 0; idex_movz = 0;
			 id_imm_ext = 0; // unused
			 id_rd_addr_sel = 1; // MFHI MFLO write rd
			 id_rt_addr_sel = 0;
			 id_rt_data_sel = 1;
			 id_jr = 0; id_jump = 0;
			 /* different */
			 case(ifid_instr[1:0])
				 // MFHI, rd <- hi
				 2'b00:
				 begin
					 idex_reg_w = 1;
					 idex_div_mul = 4'b0011;
				 end
				 // MFLO, rd <- lo
				 2'b10:
				 begin
					 idex_reg_w = 1;
					 idex_div_mul = 4'b0100;
				 end
				 // MTHI, rs -> hi
				 2'b01:
				 begin
					 idex_reg_w = 0;
					 idex_div_mul = 4'b0101;
				 end
				 // MTLO, rs -> lo
				 2'b11:
				 begin
					 idex_reg_w = 0;
					 idex_div_mul = 4'b0110;
				 end 
				 default:
				 begin
					 idex_reg_w = 0;
					 idex_div_mul = 0;
				 end
			 endcase
		end
		/* DIV DIVU MULT MULTU */
		else if(ifid_instr[31:26] == 0 && ifid_instr[5:3] == 3'b011) begin
			/* same */
			idex_mem_w = 0;
			idex_mem_r = 0;
			idex_reg_w = 0;
			idex_branch = 0; idex_condition = 0; // unused
			idex_of_w_disen = 0;
			idex_exres_sel = 3'b100; // select the result of mul/div
			idex_ALU_op = 0; // unused
			idex_shamt_sel = 0; idex_shift_op = 0; // unused
			idex_cp0_w_en = 0;
			idex_load_sel = 0; idex_store_sel = 0; // unused
			idex_B_sel = 0;
			idex_eret = 0; idex_syscall = 0;
			idex_movn = 0;
			idex_movz = 0;
			id_imm_ext = 0; // unused
			id_rd_addr_sel = 0; // unused
			id_rt_addr_sel = 0;
			id_rt_data_sel = 1;
			id_jr = 0;
			id_jump = 0;
			/* different */
			case(ifid_instr[1:0])
				// DIV
				2'b10:
					idex_div_mul = 4'b0001;
				// DIVU
				2'b11:
					idex_div_mul = 4'b0010;
				// MULT
				2'b00:
					idex_div_mul = 4'b1000;
				// MULTU
				2'b01:
					idex_div_mul = 4'b1001;
				default:
					idex_div_mul = 4'b0000;
			endcase
		end
        /* BGEZ BLTZ */
        else if(ifid_instr[31:26] == 1) begin
            /* same */
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 0; idex_mem_r = 0; idex_reg_w = 0;
            idex_branch = 1;
            idex_of_w_disen = 0;
            idex_exres_sel = 0;
            idex_ALU_op = 4'b0001;
            idex_shamt_sel = 0;
            idex_shift_op = 0;
            idex_cp0_w_en = 0;
            idex_load_sel = 0;
            idex_store_sel = 0;
            idex_B_sel = 0;
            idex_eret = 0;
            idex_syscall = 0;
            id_imm_ext = 1;
            id_rd_addr_sel = 0; // unused
            id_rt_addr_sel = 1;
            id_rt_data_sel = 1;
            id_jr = 0;
            id_jump = 0;
            /* different */
            case(ifid_instr[16])
            1'b1: idex_condition = 3'b011; // BGEZ
            1'b0: idex_condition = 3'b110; // BLTZ
            default:  idex_condition = 3'b000;
            endcase
        end
        /* CLO CLZ*/
        else if(ifid_instr[31:26] == 6'b011100 && ifid_instr[5] == 1) begin
            /* same */
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 0; idex_mem_r = 0; idex_reg_w = 1;
            idex_branch = 0; idex_condition = 0;
            idex_of_w_disen = 0;
            idex_exres_sel = 0;
            idex_shamt_sel = 0; idex_shift_op = 0;
            idex_cp0_w_en = 0;
            idex_load_sel = 0; idex_store_sel = 0;
            idex_B_sel = 0;
            idex_eret = 0;
            idex_syscall = 0;
            id_imm_ext = 0;
            id_rd_addr_sel = 1;
            id_rt_addr_sel = 0;
            id_rt_data_sel = 1;
            id_jr = 0;
            id_jump = 0;
            /* different */
            case(ifid_instr[0])
            1'b1: idex_ALU_op = 4'b0011; // CLO
            1'b0: idex_ALU_op = 4'b0010; // CLZ
            default: idex_ALU_op = 4'b0010;
            endcase
        end
		/* MUL, rd <- rs * rt */
		else if(ifid_instr[31:26] == 6'b011100 && ifid_instr[5] == 0) begin
			idex_mem_w = 0; idex_mem_r = 0;
			idex_reg_w = 1;
			idex_branch = 0; idex_condition = 0;
			idex_of_w_disen = 0;
			idex_exres_sel = 3'b100;
			idex_ALU_op = 0;
			idex_shamt_sel = 0; idex_shift_op = 0;
			idex_cp0_w_en = 0;
			idex_load_sel = 0;
			idex_store_sel = 0;
			idex_B_sel = 0;
			idex_eret = 0;
			idex_syscall = 0;
			idex_movn = 0;
			idex_movz = 0;
			idex_div_mul = 4'b0111;
			id_imm_ext = 0;
			id_rd_addr_sel = 1; 
			id_rt_addr_sel = 0;
			id_rt_data_sel = 1;
			id_jr = 0;
			id_jump = 0;
		end
        /* ERET MFC0 MTC0 */
        else if(ifid_instr[31:26] == 6'b010000) begin
            /* same */
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 0; idex_mem_r = 0;
            idex_branch = 0; idex_condition = 0;
            idex_of_w_disen = 0;
            idex_exres_sel = 0;
            idex_ALU_op = 0;
            idex_shamt_sel = 0; idex_shift_op = 0;
            idex_load_sel = 0; idex_store_sel = 0;
            idex_B_sel = 0;
            idex_syscall = 0;
            id_imm_ext = 0;
            id_rd_addr_sel = 0;
            id_rt_addr_sel = 0;
            id_jr = 0; id_jump = 0;
            /* different */
            case(ifid_instr[25:23])
            // ERET
            3'b100: begin
                idex_reg_w = 0;
                idex_cp0_w_en = 0;
                idex_eret = 1;
                id_rt_data_sel = 1;
            end
            // MFC0
            3'b000: begin
                idex_reg_w = 1;
                idex_cp0_w_en = 0;
                idex_eret = 0;
                id_rt_data_sel = 0;
            end
            // MTC0
            3'b001: begin
                idex_reg_w = 0;
                idex_cp0_w_en = 1;
                idex_eret = 0;
                id_rt_data_sel = 1;
            end
            default: begin
                idex_reg_w = 0;
                idex_cp0_w_en = 0;
                idex_eret = 0;
                id_rt_data_sel = 0;
            end
            endcase
        end
        /* LB LBU LH LHU LW LWL LWR */
        else if(ifid_instr[31:29] == 3'b100) begin
            /* same */
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 0;
            idex_mem_r = 1;
            idex_reg_w = 1;
            idex_branch = 0; idex_condition = 0;
            idex_exres_sel = 0;
            idex_ALU_op = 0;
            idex_of_w_disen = 0;
            idex_shamt_sel = 0; idex_shift_op = 0;
            idex_cp0_w_en = 0;
            idex_store_sel = 0;
            idex_B_sel = 1;
            idex_eret = 0;
            idex_syscall = 0;
            id_imm_ext = 1;
            id_rd_addr_sel = 0;
            id_rt_addr_sel = 0;
            id_rt_data_sel = 1;
            id_jr = 0;
            id_jump = 0;
            /* different */
            case(ifid_instr[28:26])
            3'b000: idex_load_sel = 3'b000; // LB
            3'b100: idex_load_sel = 3'b001; // LBU
            3'b001: idex_load_sel = 3'b010; // LH
            3'b101: idex_load_sel = 3'b011; // LHU
            3'b011: idex_load_sel = 3'b100; // LW
            3'b010: idex_load_sel = 3'b101; // LWL
            3'b110: idex_load_sel = 3'b110; // LWR
            default:  idex_load_sel = 3'b000;
            endcase
        end
        /* SB SH SW SWL SWR */
        else if(ifid_instr[31:29] == 3'b101)
        begin
            /* same */
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 1; idex_mem_r = 0; idex_reg_w = 0;
            idex_branch = 0; idex_condition = 0;
            idex_of_w_disen = 0;
            idex_exres_sel = 0;
            idex_ALU_op = 0;
            idex_shamt_sel = 0;
            idex_shift_op = 0;
            idex_cp0_w_en = 0;
            idex_load_sel = 0;
            idex_B_sel = 1;
            idex_eret = 0;
            idex_syscall = 0;
            id_imm_ext = 1;
            id_rd_addr_sel  = 0;
            id_rt_addr_sel = 0;
            id_rt_data_sel = 1;
            id_jr = 0; id_jump = 0;
            /* different */
            case(ifid_instr[28:26])
            3'b000: idex_store_sel = 3'b000; // SB
            3'b001: idex_store_sel = 3'b001; // SH
            3'b011: idex_store_sel = 3'b010; // SW
            3'b010: idex_store_sel = 3'b011; // SWL
            3'b110: idex_store_sel = 3'b100; // SWR
            default:  idex_store_sel = 3'b000;
            endcase
        end
        /* ADDI ADDIU ANDI ORI SLTI SLTIU XORI LUI*/
        else if(ifid_instr[31:29] == 3'b001)
        begin
            /* same */
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 0; idex_mem_r = 0; idex_reg_w = 1;
            idex_branch = 0; idex_condition = 0;
            idex_exres_sel = 0;
            idex_shamt_sel = 0; idex_shift_op = 0;
            idex_cp0_w_en = 0;
            idex_load_sel = 0; idex_store_sel = 0;
            idex_B_sel = 1;
            idex_eret = 0; idex_syscall = 0;
            id_rd_addr_sel = 0; // Rt
            id_rt_addr_sel = 0;
            id_rt_data_sel = 1;
            id_jr = 0; id_jump = 0;
            /* different */
            case(ifid_instr[28:26])
            // ADDI
            3'b000: begin
                idex_of_w_disen = 1;
                idex_ALU_op = 4'b1110;
                id_imm_ext = 1;
            end
            // ADDIU
            3'b001: begin
                idex_of_w_disen = 0;
                idex_ALU_op = 4'b0000;
                id_imm_ext = 1;
            end
            // ANDI
            3'b100: begin
                idex_of_w_disen = 0;
                idex_ALU_op = 4'b0100;
                id_imm_ext = 0;
            end
            // ORI
            3'b101: begin
                idex_of_w_disen = 0;
                idex_ALU_op = 4'b0110;
                id_imm_ext = 0;
            end
            // SLTI
            3'b010: begin
                idex_of_w_disen = 0;
                idex_ALU_op = 4'b0101;
                id_imm_ext = 1;
            end
            // SLTIU
            3'b011: begin
                idex_of_w_disen = 0;
                idex_ALU_op = 4'b0111;
                id_imm_ext = 1;
            end
            // XORI
            3'b110: begin
                idex_of_w_disen = 0;
                idex_ALU_op = 4'b1001;
                id_imm_ext = 0;
            end
            // LUI
            3'b111: begin
                idex_of_w_disen = 0;
                idex_ALU_op = 4'b0000;
                id_imm_ext = 2'b10;
            end
            default: begin
                idex_of_w_disen = 1;
                idex_ALU_op = 4'b1110;
                id_imm_ext = 1;
            end
            endcase
        end
        /* BEQ */
        else if(ifid_instr[31:26] == 6'b000100 || ifid_instr[31:26] == 6'b010100) begin
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 0; idex_mem_r = 0; idex_reg_w = 0;
            idex_branch = 1; idex_condition = 3'b001;
            idex_of_w_disen = 0;
            idex_exres_sel = 0;
            idex_ALU_op = 4'b0001;
            idex_shamt_sel = 0;
            idex_shift_op = 0;
            idex_cp0_w_en = 0;
            idex_load_sel = 0;
            idex_store_sel = 0;
            idex_B_sel = 0;
            idex_eret = 0;
            idex_syscall = 0;
            id_imm_ext = 1;
            id_rd_addr_sel = 0;
            id_rt_addr_sel = 0;
            id_rt_data_sel = 1;
            id_jr = 0;
            id_jump = 0;
        end
        /* BGTZ */
        else if(ifid_instr[31:26] == 6'b000111) begin
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 0; idex_mem_r = 0; idex_reg_w = 0;
            idex_branch = 1; idex_condition = 3'b100;
            idex_of_w_disen = 0;
            idex_exres_sel = 0;
            idex_ALU_op = 4'b0001;
            idex_shamt_sel = 0;
            idex_shift_op = 0;
            idex_cp0_w_en = 0;
            idex_load_sel = 0;
            idex_store_sel = 0;
            idex_B_sel = 0;
            idex_eret = 0;
            idex_syscall = 0;
            id_imm_ext = 1;
            id_rd_addr_sel = 0;
            id_rt_addr_sel = 1;
            id_rt_data_sel = 1;
            id_jr = 0;
            id_jump = 0;
        end
        /* BLEZ */
        else if(ifid_instr[31:26] == 6'b000110) begin
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 0; idex_mem_r = 0; idex_reg_w = 0;
            idex_branch = 1; idex_condition = 3'b101;
            idex_of_w_disen = 0;
            idex_exres_sel = 0;
            idex_ALU_op = 4'b0001;
            idex_shamt_sel = 0;
            idex_shift_op = 0;
            idex_cp0_w_en = 0;
            idex_load_sel = 0;
            idex_store_sel = 0;
            idex_B_sel = 0;
            idex_eret = 0;
            idex_syscall = 0;
            id_imm_ext = 1;
            id_rd_addr_sel = 0;
            id_rt_addr_sel = 1;
            id_rt_data_sel = 1;
            id_jr = 0;
            id_jump = 0;
        end
        /* BNE */
        else if(ifid_instr[31:26] == 6'b000101) begin
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 0; idex_mem_r = 0; idex_reg_w = 0;
            idex_branch = 1; idex_condition = 3'b010;
            idex_of_w_disen = 0;
            idex_exres_sel = 0;
            idex_ALU_op = 4'b0001;
            idex_shamt_sel = 0;
            idex_shift_op = 0;
            idex_cp0_w_en = 0;
            idex_load_sel = 0;
            idex_store_sel = 0;
            idex_B_sel = 0;
            idex_eret = 0;
            idex_syscall = 0;
            id_imm_ext = 1;
            id_rd_addr_sel = 0;
            id_rt_addr_sel = 0;
            id_rt_data_sel = 1;
            id_jr = 0;
            id_jump = 0;
        end
        /* J */
        else if(ifid_instr[31:26] == 6'b000010) begin
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 0; idex_mem_r = 0; idex_reg_w = 0;
            idex_branch = 0; idex_condition = 0;
            idex_of_w_disen = 0;
            idex_exres_sel = 0;
            idex_ALU_op = 4'b0000;
            idex_shamt_sel = 0;
            idex_shift_op = 0;
            idex_cp0_w_en = 0;
            idex_load_sel = 0;
            idex_store_sel = 0;
            idex_B_sel = 0;
            idex_eret = 0;
            idex_syscall = 0;
            id_imm_ext = 1;
            id_rd_addr_sel = 0;
            id_rt_addr_sel = 0;
            id_rt_data_sel = 1;
            id_jr = 0;
            id_jump = 1;
        end
        /* JAL */
        else if(ifid_instr[31:26] == 6'b000011) begin
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 0; idex_mem_r = 0; idex_reg_w = 1;
            idex_branch = 0; idex_condition = 0;
            idex_of_w_disen = 0;
            idex_exres_sel = 3'b010;
            idex_ALU_op = 4'b0000;
            idex_shamt_sel = 0;
            idex_shift_op = 0;
            idex_cp0_w_en = 0;
            idex_load_sel = 0;
            idex_store_sel = 0;
            idex_B_sel = 0;
            idex_eret = 0;
            idex_syscall = 0;
            id_imm_ext = 2'b11;
            id_rd_addr_sel = 2'b10;
            id_rt_addr_sel = 0;
            id_rt_data_sel = 1;
            id_jr = 0;
            id_jump = 1;
        end
        else begin
			idex_div_mul = 0;
            idex_movn = 0; idex_movz = 0;
            idex_mem_w = 0; idex_mem_r = 0; idex_reg_w = 0;
            idex_branch = 0; idex_condition = 0;
            idex_of_w_disen = 0; idex_exres_sel = 0;
            idex_ALU_op = 0;
            idex_shamt_sel = 0;
            idex_shift_op = 0;
            idex_cp0_w_en = 0;
            idex_load_sel = 0; idex_store_sel = 0;
            idex_B_sel = 0;
            idex_eret = 0; idex_syscall = 0;
            id_imm_ext = 0;
            id_rd_addr_sel = 0;
            id_rt_addr_sel = 0;
            id_rt_data_sel = 1;
            id_jr = 0; id_jump = 0;
        end
   end
endmodule
