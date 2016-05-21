// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : hex_to_seg.v
// Author        : zyy
// Created On    : 2016-05-04 23:01
// Last Modified : 2016-05-21 12:39
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

module hex_to_seg(
    input [3:0] hex,
    output reg [6:0] seg
);

always @(*) begin
    case(hex)
        4'h0: begin
            seg = 7'b0000001;
        end
        4'h1: begin
            seg = 7'b1001111;
        end
        4'h2: begin
            seg = 7'b0010010;
        end
        4'h3: begin
            seg = 7'b0000110;
        end
        4'h4: begin
            seg = 7'b1001100;
        end
        4'h5: begin
            seg = 7'b0100100;
        end
        4'h6: begin
            seg = 7'b0100000;
        end
        4'h7: begin
            seg = 7'b0001111;
        end
        4'h8: begin
            seg = 7'b0000000;
        end
        4'h9: begin
            seg = 7'b0000100;
        end
        4'ha: begin
            seg = 7'b0001000;
        end
        4'hb: begin
            seg = 7'b1100000;
        end
        4'hc: begin
            seg = 7'b0110001;
        end
        4'hd: begin
            seg = 7'b1000010;
        end
        4'he: begin
            seg = 7'b0110000;
        end
        4'hf: begin
            seg = 7'b0111000;
        end
    endcase
end

endmodule

