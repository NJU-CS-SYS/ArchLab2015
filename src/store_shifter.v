`timescale 1ns / 1ps

module store_shifter(
	input [1:0]addr,
	input [2:0]store_sel,
	input [31:0]rt_data,
	output [31:0]real_rt_data
);

reg [4:0] shamt;
reg [31:0] shift_mid;
reg [31:0] dout;

always @(*) begin
    case(store_sel)
        3'd0:begin
            shamt = addr << 3;
            dout = rt_data << shamt;
        end
        3'd1:begin
            shamt = addr[1] << 4;
            dout = rt_data << shamt;
        end
        3'd2:begin
            dout = rt_data ;
        end
        3'd3:begin
            shamt = addr << 3;
            dout = rt_data >> shamt;
        end
        default:begin
            shamt = (~addr) << 3;
            dout = rt_data << shamt;
        end
    endcase
end

assign real_rt_data = dout;

endmodule
