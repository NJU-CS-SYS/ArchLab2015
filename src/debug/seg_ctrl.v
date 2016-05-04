// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : seg_ctrl.v
// Author        : zyy
// Created On    : 2016-05-04 23:13
// Last Modified : 2016-05-05 00:08
// -------------------------------------------------------------------------------------------------
// Svn Info:
//   $Revision::                                                                                $:
//   $Author::                                                                                  $:
//   $Date::                                                                                    $:
//   $HeadURL::                                                                                 $:
// -------------------------------------------------------------------------------------------------
// Description:
//
//
// -FHDR--------------------------------------------------------------------------------------------

module seg_ctrl(
    input clk,
    input [3:0] hex1,
    input [3:0] hex2,
    input [3:0] hex3,
    input [3:0] hex4,
    input [3:0] hex5,
    input [3:0] hex6,
    input [3:0] hex7,
    input [3:0] hex8,
    output reg [6:0] seg_out,
    output reg [7:0] seg_ctrl
);

reg [16:0] count;
wire [6:0] seg [7:0];

initial begin
    count <= 17'd0;
end

always @(posedge clk) begin
    count <= count + 1;
end

always @(*) begin
    case(count[16:14]) 
        3'd0 : begin
            seg_out = seg[0];
            seg_ctrl = 8'b11111110;
        end
        3'd1 : begin
            seg_out = seg[1];
            seg_ctrl = 8'b11111101;
        end
        3'd2 : begin
            seg_out = seg[2];
            seg_ctrl = 8'b11111011;
        end
        3'd3 : begin
            seg_out = seg[3];
            seg_ctrl = 8'b11110111;
        end
        3'd4 : begin
            seg_out = seg[4];
            seg_ctrl = 8'b11101111;
        end
        3'd5 : begin
            seg_out = seg[5];
            seg_ctrl = 8'b11011111;
        end
        3'd6 : begin
            seg_out = seg[6];
            seg_ctrl = 8'b10111111;
        end
        3'd7 : begin
            seg_out = seg[7];
            seg_ctrl = 8'b01111111;
        end
    endcase
end

hex_to_seg hts0 (.hex(hex1), .seg(seg[0]));
hex_to_seg hts1 (.hex(hex2), .seg(seg[1]));
hex_to_seg hts2 (.hex(hex3), .seg(seg[2]));
hex_to_seg hts3 (.hex(hex4), .seg(seg[3]));
hex_to_seg hts4 (.hex(hex5), .seg(seg[4]));
hex_to_seg hts5 (.hex(hex6), .seg(seg[5]));
hex_to_seg hts6 (.hex(hex7), .seg(seg[6]));
hex_to_seg hts7 (.hex(hex8), .seg(seg[7]));

endmodule

