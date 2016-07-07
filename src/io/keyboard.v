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

assign overflow = r_ptr == (w_ptr + 3'd1);

// Write logic
always @(negedge ps2_clk) begin
    if (clrn == 0) begin
        count <= 0;
        w_ptr <= 0;
    end
    else begin
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

assign ready = (r_ptr != w_ptr);
assign keycode = fifo[r_ptr];

// Read logic:
// r_ptr refers to cpu state.
// As pipeline is driven by clk's negedge,
// we should keep consistent here.
always @(negedge clk) begin
    if (clrn == 0) begin
        r_ptr <= 0;
    end
    else if (cpu_read && ready) begin
        r_ptr <= r_ptr + 1;
    end
end

endmodule
