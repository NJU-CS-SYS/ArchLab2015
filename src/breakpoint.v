//
// This file defines Breakpoint module,
// which provide a hardware-level single
// break point support.
//

`timescale 1ns / 1ps

module Breakpoint (
    input valid,                // indicate whether the hit is taken.
    input sampler,              // drive the updating of break point
    input [2:0] digit_sel,      // select a digit to write in a 4-word address.
    input [3:0] hex_digit,      // hexadecimal digit to write.
    input [29:0] pc,            // the program counter to be compared, 4B-aligned.
    output [31:0] break_point,
    output hit
);

reg [31:0] bp_pc;

assign break_point = bp_pc;
assign hit = valid & (bp_pc == { pc, 2'b00 });

wire [4:0] bit_offset = { digit_sel, 2'b00 };

always @(posedge sampler) begin
    bp_pc[ bit_offset +: 4 ] <=  hex_digit;
end

endmodule
