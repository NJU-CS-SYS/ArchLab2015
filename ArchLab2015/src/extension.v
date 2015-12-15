`timescale 1ns / 1ps

/**
 * @brief 符号扩展模块
 * @author whz
 *   0 - 无符号扩展
 *   1 - 有符号扩展
 *   2 - LUI
 *   3 - 常数4, 为后面计算 JAL 指令的返回地址 PC + 8 做准备
 */

`define IMM_WIDTH 16
`define IMM_BUS (`IMM_WIDTH - 1):0
`define EXT_SEL_BUS 1:0
`define DATA_WIDTH 32
`define DATA_BUS (`DATA_WIDTH - 1):0

module extension(
    input [`IMM_BUS] ifid_imm,
    input [`EXT_SEL_BUS] id_imm_ext,
    output reg [`DATA_BUS] imm_ext
    );

    parameter UNSIGN_EXT = 0;
    parameter SIGN_EXT   = 1;
    parameter LUI        = 2;
    parameter CONST_4    = 3;

    always @(*) begin
        case (id_imm_ext)
        SIGN_EXT: imm_ext = { {`IMM_WIDTH{ifid_imm[`IMM_WIDTH - 1]}}, ifid_imm};
        UNSIGN_EXT: imm_ext = { {`IMM_WIDTH{1'b0}}, ifid_imm };
        LUI: imm_ext = { ifid_imm, `IMM_WIDTH'd0 };
        CONST_4: imm_ext = `DATA_WIDTH'd4;
        endcase
    end

endmodule

`undef IMM_WIDTH
`undef IMM_BUS
`undef EXT_SEL_BUS
`undef DATA_WIDTH
`undef DATA_BUS
