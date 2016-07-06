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

module Keyboard (
    input        clk,
    input        clrn,
    input        ps2_clk,
    input        ps2_data,
    input        cpu_read,
    output       ready,
    output       overflow,
    output [7:0] keycode
);

reg [3:0] count;
reg [9:0] buffer;        // buffer for one ps2 packet
reg [7:0] fifo [7:0];    // 缓存队列，二维数组
reg [2:0] w_ptr;
reg [2:0] r_ptr;
reg [2:0] ps2_clk_sync;  // detect failing edge of ps2_clk

always @(posedge clk) begin
    ps2_clk_sync <= { ps2_clk_sync[1:0], ps2_clk };
end

// TODO only use 2 bits of ps2_clk_sync to achieve the same result?
wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

assign overflow = r_ptr == (w_ptr + 3'd1);

// Write logic
always @(posedge clk) begin
    if (clrn == 0) begin
        count <= 0;
        w_ptr <= 0;
    end
    else if (sampling) begin
        if (count == 10) begin
            if (buffer[0] == 0 && ps2_data && (^buffer[9:1])) begin //结束符，起始符，奇偶校验
                if (!overflow) begin
                    fifo[w_ptr] <= buffer[8:1];
                    w_ptr <= w_ptr + 1;
                end
            end
            count <= 0;
        end
        else begin
            buffer[count] <= ps2_data;
            count <= count + 1;
        end
    end
end

assign keycode = fifo[r_ptr];
assign ready = (r_ptr != w_ptr);

// Read logic
always @(posedge clk) begin
    if (clrn == 0) begin
        r_ptr <= 0;
    end
    else if (cpu_read && ready) begin
        r_ptr <= r_ptr + 1;
    end
end

endmodule
