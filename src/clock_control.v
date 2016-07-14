`timescale 1ns / 1ps


module clock_control(
    input clk_in1,
    input ui_clk_from_ddr,
    input [7:6] SW,
    input manual_clk,
    output clk_to_ddr,
    output clk_to_pixel,
    output reg ui_clk_used,
    output reg sync_manual_clk
);

ddr_clock_gen dcg(
    .clk_in1(clk_in1),
    .clk_out1(clk_to_ddr),
    .clk_out2(clk_to_pixel)
);

parameter CLK_MANUAL = 2'b00;
parameter CLK_SLOW   = 2'b01;
parameter CLK_FAST   = 2'b10;
parameter CLK_EX     = 2'b11;

reg slow_clk;  // 2^22 times slower than ui_clk_from_ddr
reg fast_clk;  // 2^2  times slower than ui_clk_from_ddr
reg [21:0] slow_clk_counter;
reg [1:0] fast_clk_counter;

always @ (posedge ui_clk_from_ddr) begin
    sync_manual_clk <= manual_clk;
    slow_clk_counter <= slow_clk_counter + 1;
    fast_clk_counter <= fast_clk_counter + 1;
    if (slow_clk_counter == 0) begin
        slow_clk <= ~slow_clk;
    end
    if (fast_clk_counter == 0) begin
        fast_clk <= ~fast_clk;
    end
end

always @(*) begin
    case (SW[7:6])
        CLK_MANUAL: ui_clk_used = sync_manual_clk;
        CLK_SLOW:   ui_clk_used = slow_clk;
        CLK_FAST:   ui_clk_used = fast_clk;
        CLK_EX:     ui_clk_used = ui_clk_from_ddr;
    endcase
end

endmodule
