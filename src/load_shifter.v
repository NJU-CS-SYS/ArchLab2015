`timescale 1ns / 1ps

module load_shifter(
	input [1:0]addr,
	input [2:0]load_sel,
	input [31:0]mem_data,
	output [31:0]data_to_reg
);
reg [31:0] dout;
reg [31:0] shift_mid;
reg [4:0] shamt;

always@(*) begin
    case(load_sel)
        3'd0:begin
            shamt = addr<<3;
            shift_mid = mem_data>>shamt;
            dout = {{24{shift_mid[7]}},shift_mid[7:0]};
        end
        3'd1:begin
            shamt = addr<<3;
            shift_mid = mem_data>>shamt;
            dout = {24'd0,shift_mid[7:0]};
        end
        3'd2:begin
            shamt = addr[1]<<4;
            shift_mid = mem_data>>shamt;
            dout = {{16{shift_mid[15]}},shift_mid[15:0]};
        end
        3'd3:begin
            shamt = addr[1]<<4;
            shift_mid = mem_data>>shamt;
            dout = {16'd0,shift_mid[15:0]};
        end
        3'd4:begin
            shift_mid = 32'd0;
            shamt = 5'd0;
            dout = mem_data;
        end
        3'd5:begin
            shift_mid = 32'd0;
            shamt = addr<<3;
            dout = mem_data<<shamt;
        end
        default:begin //lwr
            shift_mid = 32'd0;
            shamt = (~addr)<<3;
            dout = mem_data>>shamt;
        end
    endcase
end

assign data_to_reg = shift_mid;

endmodule
