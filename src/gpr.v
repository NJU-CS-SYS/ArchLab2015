`timescale 1ns / 1ps

/**
 * @brief 通用寄存器组
 * @author whz
 */

module GPR
#(parameter ADDR_WIDTH=5, DATA_WIDTH=32)
(
    input clk,
    input reset,
    input write,
    input [(ADDR_WIDTH-1):0] Rs_addr, Rt_addr, Rd_addr,
    input [(DATA_WIDTH-1):0] Rd_in,
    input [3:0] Rd_Byte_w_en,

    // debug
    output [(DATA_WIDTH-1):0] s0,

    output [(DATA_WIDTH-1):0] Rs_out, Rt_out
);

    // Declare the register file
    reg [DATA_WIDTH-1:0] register[2**ADDR_WIDTH-1:1];
    integer i;
    integer reg_cnt;

    initial begin
        reg_cnt = 2**ADDR_WIDTH - 1;
        for (i = 0; i <= reg_cnt; i = i + 1)
            register[i] = 0;
    end

    `define BYTE_SLICE(idx) (7 + idx * 8) : (idx * 8)
    always @(negedge clk or posedge reset) begin
        if (reset) begin
            reg_cnt = 2**ADDR_WIDTH - 1;
            for (i = 1; i < reg_cnt; i = i + 1)
                register[i] = 0;
        end
        else if (Rd_addr != 0 && write) begin
            if (Rd_Byte_w_en[0] == 1)
                register[Rd_addr][`BYTE_SLICE(0)] <= Rd_in[`BYTE_SLICE(0)];
            if (Rd_Byte_w_en[1] == 1)
                register[Rd_addr][`BYTE_SLICE(1)] <= Rd_in[`BYTE_SLICE(1)];
            if (Rd_Byte_w_en[2] == 1)
                register[Rd_addr][`BYTE_SLICE(2)] <= Rd_in[`BYTE_SLICE(2)];
            if (Rd_Byte_w_en[3] == 1)
                register[Rd_addr][`BYTE_SLICE(3)] <= Rd_in[`BYTE_SLICE(3)];
        end
    end
    `undef BYTE_SLICE

    // Read
    assign Rs_out = register[Rs_addr];
    assign Rt_out = register[Rt_addr];
    assign s0 = register[16];
endmodule
