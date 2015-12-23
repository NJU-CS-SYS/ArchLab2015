`include "Define.v"
module load_b_w_e_gen(
	input [1:0]addr,
	input [2:0]load_sel,
	output reg [3:0]b_w_en
);
reg [5:0]ld_sel;
always@(*) begin
    case(load_sel)
        0:ld_sel=`LB;
        1:ld_sel=`LH;
        2:ld_sel=`LWL;
        3:ld_sel=`LW;
        4:ld_sel=`LBU;
        5:ld_sel=`LHU;
        6:ld_sel=`LWR;
    endcase
	case(ld_sel)
		`LB,`LBU,`LH,`LHU,`LW: b_w_en=4'b1111;
		`LWL:
			case(addr)
				2'b00: b_w_en=4'b1111;
				1: b_w_en=4'b1110;
				2: b_w_en=4'b1100;
				3: b_w_en=4'b1000;
			endcase
		`LWR:
			case(addr)
				0: b_w_en=4'b0001;
				1: b_w_en=4'b0011;
				2: b_w_en=4'b0111;
				3: b_w_en=4'b1111;
			endcase
	endcase
end
endmodule
