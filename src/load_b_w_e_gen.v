`timescale 1ns / 1ps

module load_b_w_e_gen(
	input [1:0]addr,
	input [2:0]load_sel,
	output [3:0]b_w_en
);

reg [3:0] b_w_en_reg;

always@(*) begin
	case(load_sel)
		3'd5:
			case(addr)
				2'd0: b_w_en_reg=4'b1111;
				2'd1: b_w_en_reg=4'b1110;
				2'd2: b_w_en_reg=4'b1100;
				2'd3: b_w_en_reg=4'b1000;
			endcase
		3'd6:
			case(addr)
				2'd0: b_w_en_reg=4'b0001;
				2'd1: b_w_en_reg=4'b0011;
				2'd2: b_w_en_reg=4'b0111;
				2'd3: b_w_en_reg=4'b1111;
			endcase
        default: 
            b_w_en_reg = 4'b1111;
    endcase
end

assign b_w_en = b_w_en_reg;

endmodule
