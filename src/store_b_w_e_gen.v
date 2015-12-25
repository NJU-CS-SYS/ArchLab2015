`timescale 1ns / 1ps

module store_b_w_e_gen(
	input [1:0]addr,
	input [2:0]store_sel,
	output [3:0]b_w_en
);

reg [3:0] b_w_en_reg;

always@(*) begin
	case(store_sel)
		3'd0:
			case(addr)
				2'd0:b_w_en_reg = 4'b1000;
				2'd1:b_w_en_reg = 4'b0100;
				2'd2:b_w_en_reg = 4'b0010;
				2'd3:b_w_en_reg = 4'b0001;
			endcase
		3'd1:
			case(addr[1])
				1'b0:b_w_en_reg = 4'b1100;
				1'b1:b_w_en_reg = 4'b0011;
			endcase
		3'd2: b_w_en_reg = 4'b1111;
		3'd3:
			case(addr)
				2'd0:b_w_en_reg = 4'b1111;
				2'd1:b_w_en_reg = 4'b0111;
				2'd2:b_w_en_reg = 4'b0011;
				2'd3:b_w_en_reg = 4'b0001;
			endcase
		default:
			case(addr)
				2'd0:b_w_en_reg = 4'b1000;
				2'd1:b_w_en_reg = 4'b1100;
				2'd2:b_w_en_reg = 4'b1110;
				2'd3:b_w_en_reg = 4'b1111;
			endcase
	endcase
end

assign b_w_en = b_w_en_reg;

endmodule
