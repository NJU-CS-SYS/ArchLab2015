module Ps2_seg (B,H);
output reg [6:0] H;
input [7:0] B;
always @ (B)
	case (B)
		//数字
		8'h16: H = 7'b1111001; // 1
		8'h1e: H = 7'b0100100; // 2
		8'h26: H = 7'b0110000; // 3
		8'h25: H = 7'b0011001; // 4
		8'h2e: H = 7'b0010010; // 5
		8'h36: H = 7'b0000010; // 6
		8'h3d: H = 7'b1111000; // 7
		8'h3e: H = 7'b0000000; // 8
		8'h46: H = 7'b0010000; // 9
		8'h45: H = 7'b1000000; // 0
		//一部分字母，大写易于译码管表示的
		8'h1c: H = 7'b0001000; // A
		8'h21: H = 7'b1000110; // C
		8'h24: H = 7'b0000110; // E
		8'h2b: H = 7'b0001110; // F
		8'h33: H = 7'b0001001; // H
		8'h3b: H = 7'b1110001; // J
		8'h4b: H = 7'b1000111; // L
		8'h4d: H = 7'b0001100; // P
		8'h3c: H = 7'b1000001; // U
		default: H = 7'b1111111;	
	endcase
endmodule

module Keyboard(clk,clrn,ps2_clk,ps2_data,ready,overflow,count,oHEX0_D);
input clk,clrn,ps2_clk,ps2_data;
reg [7:0] data;
output ready;
reg ready;
output reg overflow;
output reg [3:0] count;
output [6:0] oHEX0_D;//译码管显示
reg [9:0] buffer;
reg [7:0] fifo[7:0];//缓存队列，二维数组
reg [2:0] w_ptr,r_ptr;//detect failing edge of ps2_clk
reg [2:0] ps2_clk_sync;
always@(posedge clk)
	begin
	ps2_clk_sync <= {ps2_clk_sync[1:0],ps2_clk};
	end
wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];
always@(posedge clk)
	begin
	if(clrn == 0)
		begin
		count <= 0;w_ptr <= 0;r_ptr <= 0;overflow <= 0;
		end
	else
		if(sampling)
		begin
			if(count == 4'd10)
			begin
				if(buffer[0] == 0 && ps2_data && (^buffer[9:1]))//结束符，起始符，奇偶校验
					begin
					fifo[w_ptr] <= buffer[8:1];
					w_ptr <= w_ptr + 3'b1;
					ready <= 1'b1;
					overflow <= overflow|(r_ptr == (w_ptr + 3'b1));
					end
				count <= 0;
			end
			else
				begin
				buffer[count] <= ps2_data;
				count <= count + 3'b1;
				end
		end
	if(ready)
		begin
		data = fifo[r_ptr];
		r_ptr <= r_ptr + 3'd1;
		ready <= 1'b0;
		end
	end
Ps2_seg digital0(data[7:0],oHEX0_D);

endmodule