`include "Define.v"
module store_b_w_e_gen(
	input [1:0]addr,
	input [2:0]store_sel,
	output reg[3:0]b_w_en
);
reg [5:0]sw_sel;
always@(*) begin
	case(store_sel)
	   0:sw_sel=`SB;
	   1:sw_sel=`SH;
	   2:sw_sel=`SWL;
	   3:sw_sel=`SW;
	   6:sw_sel=`SWR;
	endcase
	case(sw_sel)
		`SB:
			case(addr)
				0:b_w_en=4'b1000;
				1:b_w_en=4'b0100;
				2:b_w_en=4'b0010;
				3:b_w_en=4'b0001;
			endcase
		`SH:
			case(addr[1])
				1'b0:b_w_en=4'b1100;
				1'b1:b_w_en=4'b0011;
			endcase
		`SW: b_w_en=4'b1111;
		`SWL:
			case(addr)
				0:b_w_en=4'b1111;
				1:b_w_en=4'b0111;
				2:b_w_en=4'b0011;
				3:b_w_en=4'b0001;
			endcase
		`SWR:
			case(addr)
				0:b_w_en=4'b1000;
				1:b_w_en=4'b1100;
				2:b_w_en=4'b1110;
				3:b_w_en=4'b1111;
			endcase
	endcase
end
endmodule

