`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/07 19:47:56
// Design Name: 
// Module Name: cache_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//   负责生成 cache 的控制信号的组合逻辑，以及 cache 状态转移的次态逻辑（组合逻辑）
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "status.vh"

module cache_control(
    dc_read_in, dc_write_in, ic_word_sel_in, dc_word_sel_in, dc_byte_w_en_in,/*external input*/
    ic_hit_in, ic_valid_in, /*ic's output*/
    dc_hit_in, dc_dirty_in, dc_valid_in,/*dc's output*/
    status_in, counter_in, /*status info*/

    ic_enable_out, ic_word_sel_out, ic_cmp_out,
    ic_write_out, ic_byte_w_en, ic_valid_out,

    dc_enable_out, dc_word_sel_out, dc_cmp_out,
    dc_write_out, dc_byte_w_en, dc_valid_out,

    ram_addr_sel, ram_en_out, ram_write_out,
    status_next, counter_next
);
input dc_read_in, dc_write_in, ic_hit_in, ic_valid_in, dc_hit_in, dc_dirty_in, dc_valid_in;
input [2:0] status_in,counter_in;
input [2:0] ic_word_sel_in, dc_word_sel_in;
input [3:0] dc_byte_w_en_in;

output reg ic_enable_reg, ic_cmp_reg, ic_write_reg, ic_valid_reg,
    dc_enable_reg, dc_cmp_reg, dc_write_reg, dc_valid_reg,
    ram_en_out, ram_write_out;
output [1:0] ram_addr_sel;
output [2:0] status_next,counter_next;
output [2:0] ic_word_sel_out, dc_word_sel_out;
output [3:0] ic_byte_w_en, dc_byte_w_en;

// TODO 直接在 output 上加 reg 修饰，减少代码行数
/*
reg ic_enable_reg, ic_cmp_reg, ic_write_reg, ic_valid_reg,
    dc_enable_reg, dc_cmp_reg, dc_write_reg, dc_valid_reg,
    ram_en_out, ram_write_out;
*/
reg [1:0] ram_addr_sel_reg;
reg [2:0] ic_word_sel_reg, dc_word_sel_reg, status_next_reg, counter_next_reg;
reg [3:0] ic_byte_w_en_reg, dc_byte_w_en_reg;

assign ic_enable_out = ic_enable_reg;
assign ic_cmp_out = ic_cmp_reg;
assign ic_write_out = ic_write_reg;
assign ic_valid_out = ic_valid_reg;

assign dc_enable_out = dc_enable_reg;
assign dc_cmp_out = dc_cmp_reg;
assign dc_write_out = dc_write_reg;
assign dc_valid_out = dc_valid_reg;

assign ic_word_sel_out = ic_word_sel_reg;
assign dc_word_sel_out = dc_word_sel_reg;
assign status_next = status_next_reg;
assign counter_next = counter_next_reg;
assign ic_byte_w_en = ic_byte_w_en_reg;
assign dc_byte_w_en = dc_byte_w_en_reg;
assign ram_addr_sel = ram_addr_sel_reg;


// 下面的 always 块是一个根据当前周期 cache 状态的 switch-case 语句
// 每个 case 下的行为模式基本相似，即：
//   (1). 生成本周期的控制信号
//   (2). 决定下一周期状态
// 需要注意的是，在 NORMAL 状态下，在 (1) 与 (2) 之间，隐含着 cache_2way 的逻辑。
// 也就是说，在 (1) 控制信号生成后，需要等待 cache_2way 的延迟，(2) 所依赖的信号才有效。
// 此外，最终的状态转移时序电路，是在外部的 cache_manage_unit 完成的。

always @(*) begin
    case(status_in)
        `STAT_IC_MISS:
        begin
            // I-cache 写入控制设定
            ic_enable_reg = 1;
            ic_cmp_reg = 0;
            ic_write_reg = 1;
            ic_byte_w_en_reg = 4'b1111;

            // I-cache 写入内容设定
            ic_valid_reg = 1;
            ic_word_sel_reg = counter_in;

            //for data coherrence
            dc_enable_reg = 1;
            dc_cmp_reg = 1;
            dc_write_reg = 0;
            dc_valid_reg = 0;

            //dc_word_sel_reg = dc_word_sel_in;
            dc_word_sel_reg = counter_in;//it is meaningful while loading from dc
            dc_byte_w_en_reg = 4'b0000;  // DONE 反正写使能关了，字节写使能也无效吧

            // DONE 可以放后面吗？
            if(dc_hit_in && dc_valid_in)begin
                ram_en_out = 0;
            end
            else begin
                ram_en_out = 1;
            end

            // 设定对 ram 的访问行为，使用 ram_addr_ic, 只读
            ram_addr_sel_reg = 2'b00;  // TODO 常量符号化
                                        // zyy: 高位表示是否写回，低位表示是ic
                                        // 或是dc，对我来说是有语义的
                                        // 看cache_manage_unit ,Line: 127 
            ram_write_out = 0;

            if(counter_in ==  `COUNT_FINISH) begin
                status_next_reg = `STAT_NORMAL;
                counter_next_reg = 3'd7;
            end
            else begin
                status_next_reg = `STAT_IC_MISS;
                if(counter_in == 3'd0) counter_next_reg = 3'd1;
                else if(counter_in == 3'd1) counter_next_reg = 3'd2;
                else if(counter_in == 3'd2) counter_next_reg = 3'd3;
                else if(counter_in == 3'd3) counter_next_reg = 3'd4;
                else if(counter_in == 3'd4) counter_next_reg = 3'd5;
                else if(counter_in == 3'd5) counter_next_reg = 3'd6;
                else counter_next_reg = 3'd7;
            end

        end
        `STAT_DC_MISS:
        begin
            // 不使用 I-cache
            ic_enable_reg = 0;
            ic_cmp_reg = 0;
            ic_write_reg = 0;
            ic_valid_reg = 0;
            ic_word_sel_reg = counter_in;
            ic_byte_w_en_reg = 4'b0000;  // DONE 无效掉？
                                        // zyy: ...

            // 写 D-cache
            dc_enable_reg = 1;
            dc_cmp_reg = 0;
            dc_write_reg = 1;
            dc_valid_reg = 1;
            dc_word_sel_reg = counter_in;
            dc_byte_w_en_reg = 4'b1111;

            // 读 ram
            ram_addr_sel_reg = 2'b01;  // ram_addr_dc
            ram_en_out = 1;
            ram_write_out = 0;

            if(counter_in == `COUNT_FINISH) begin
                status_next_reg = `STAT_NORMAL;
                counter_next_reg = 3'd7;
            end
            else begin
                status_next_reg = `STAT_DC_MISS;
                if(counter_in == 3'd0) counter_next_reg = 3'd1;
                else if(counter_in == 3'd1) counter_next_reg = 3'd2;
                else if(counter_in == 3'd2) counter_next_reg = 3'd3;
                else if(counter_in == 3'd3) counter_next_reg = 3'd4;
                else if(counter_in == 3'd4) counter_next_reg = 3'd5;
                else if(counter_in == 3'd5) counter_next_reg = 3'd6;
                else counter_next_reg = 3'd7;
            end
        end
        `STAT_DC_MISS_D:
        begin
            // 不使用 I-cache
            ic_enable_reg = 0;
            ic_cmp_reg = 0;
            ic_write_reg = 0;
            ic_valid_reg = 0;
            ic_word_sel_reg = counter_in;
            ic_byte_w_en_reg = 4'b0000;  // DONE 无效掉？

            // 读 D-cache
            dc_enable_reg = 1;
            dc_cmp_reg = 0;
            dc_write_reg = 0;
            dc_valid_reg = 1;
            dc_word_sel_reg = counter_in;
            dc_byte_w_en_reg = 4'b0000;

            // 写 ram
            ram_addr_sel_reg = 2'b11;  // ram_addr_dc_wb
            ram_en_out = 1;
            ram_write_out = 1;

            if(counter_in == `COUNT_FINISH) begin
                status_next_reg = `STAT_DC_MISS;
                counter_next_reg = 3'd0;
            end
            else begin
                status_next_reg = `STAT_DC_MISS_D;
                if(counter_in == 3'd0) counter_next_reg = 3'd1;
                else if(counter_in == 3'd1) counter_next_reg = 3'd2;
                else if(counter_in == 3'd2) counter_next_reg = 3'd3;
                else if(counter_in == 3'd3) counter_next_reg = 3'd4;
                else if(counter_in == 3'd4) counter_next_reg = 3'd5;
                else if(counter_in == 3'd5) counter_next_reg = 3'd6;
                else counter_next_reg = 3'd7;
            end
        end
        `STAT_DOUBLE_MISS:
        begin
            // 写 I-cache
            ic_enable_reg = 1;
            ic_cmp_reg = 0;
            ic_write_reg = 1;
            ic_byte_w_en_reg = 4'b1111;

            ic_valid_reg = 1;
            ic_word_sel_reg = counter_in;

            // 读 D-cache
            dc_enable_reg = 1;
            dc_cmp_reg = 1;
            dc_write_reg = 0;
            dc_valid_reg = 0;
            dc_word_sel_reg = counter_in;
            dc_byte_w_en_reg = 4'b0000;

            // 读 ram
            ram_addr_sel_reg = 2'b00;  // ram_addr_ic
            ram_write_out = 0;

            // DONE 放后面？
            if (dc_hit_in && dc_valid_in) begin
                ram_en_out = 0;
            end
            else begin
                ram_en_out = 1;
            end
            if(counter_in == `COUNT_FINISH) begin
                status_next_reg = `STAT_DC_MISS;
                counter_next_reg = 3'd0;
            end

            else begin
                status_next_reg = `STAT_DOUBLE_MISS;
                if(counter_in == 3'd0) counter_next_reg = 3'd1;
                else if(counter_in == 3'd1) counter_next_reg = 3'd2;
                else if(counter_in == 3'd2) counter_next_reg = 3'd3;
                else if(counter_in == 3'd3) counter_next_reg = 3'd4;
                else if(counter_in == 3'd4) counter_next_reg = 3'd5;
                else if(counter_in == 3'd5) counter_next_reg = 3'd6;
                else counter_next_reg = 3'd7;
            end
        end
        `STAT_DOUBLE_MISS_D:
        begin
            // 不使用 I-cache
            ic_enable_reg = 0;
            ic_cmp_reg = 0;
            ic_write_reg = 0;
            ic_byte_w_en_reg = 4'b0000;  // DONE 无效化？
            ic_valid_reg = 0;
            ic_word_sel_reg = counter_in;

            // 读 D-cache
            dc_enable_reg = 1;
            dc_cmp_reg = 0;
            dc_write_reg = 0;
            dc_byte_w_en_reg = 4'b0000;
            dc_valid_reg = 1;
            dc_word_sel_reg = counter_in;

            // 写 ram
            ram_addr_sel_reg = 2'b11;  // ram_addr_dc_wb
            ram_en_out = 1;
            ram_write_out = 1;

            if(counter_in == `COUNT_FINISH) begin
                status_next_reg = `STAT_DOUBLE_MISS;
                counter_next_reg = 3'd0;
            end
            else begin
                status_next_reg = `STAT_DOUBLE_MISS_D;
                if(counter_in == 3'd0) counter_next_reg = 3'd1;
                else if(counter_in == 3'd1) counter_next_reg = 3'd2;
                else if(counter_in == 3'd2) counter_next_reg = 3'd3;
                else if(counter_in == 3'd3) counter_next_reg = 3'd4;
                else if(counter_in == 3'd4) counter_next_reg = 3'd5;
                else if(counter_in == 3'd5) counter_next_reg = 3'd6;
                else counter_next_reg = 3'd7;
            end
        end
        default: /*normal*/
        begin
            // Normal 状态下生成最常规的控制信号。

            ic_enable_reg = 1;                         // 由于流水线化，每个 CPU 周期 I-cache 都要被访问，所以 I-cache 持续使能。
            ic_cmp_reg = 1;
            ic_word_sel_reg = ic_word_sel_in;
            ic_write_reg = 0;                          // I-cache 不会由 CPU 写。
            ic_byte_w_en_reg = 4'b0000;

            dc_enable_reg = dc_read_in | dc_write_in;  // D-cache 的使能要根据具体的请求来设定。
            dc_cmp_reg = 1;
            dc_word_sel_reg = dc_word_sel_in;
            dc_write_reg = dc_write_in;
            dc_byte_w_en_reg = dc_byte_w_en_in;

            // 当前并不需要对 ram 进行操作
            ram_addr_sel_reg = 2'b00;
            ram_en_out = 0;
            ram_write_out = 0;

            /* cache_2way 响应 */

            ic_valid_reg = ic_valid_in;
            dc_valid_reg = dc_valid_in;

            // 根据访问结果，决定下一状态，先判断 D-cache miss, 再判断 I-cache miss, 最后判断 I-cache miss。
            if(dc_enable_reg && !(dc_hit_in && dc_valid_in)) begin //dc miss
                if(!(ic_hit_in && ic_valid_in)) begin //dc miss & ic miss
                    if(dc_dirty_in) begin //dc miss & ic miss & dc dirty
                        status_next_reg = `STAT_DOUBLE_MISS_D;
                        counter_next_reg = 3'b000;
                    end
                    else begin //dc miss & ic miss & dc not dirty
                        status_next_reg = `STAT_DOUBLE_MISS;
                        counter_next_reg = 3'b000;
                    end
                end
                else begin
                    if(dc_dirty_in) begin //dc miss & ic hit & dc dirty
                        status_next_reg = `STAT_DC_MISS_D;
                        counter_next_reg = 3'b000;
                    end
                    else begin //dc miss & ic hit & dc not dirty
                        status_next_reg = `STAT_DC_MISS;
                        counter_next_reg = 3'b000;
                    end
                end
            end
            else begin //dc hit & ic miss
                if(!(ic_hit_in && ic_valid_in)) begin
                    status_next_reg = `STAT_IC_MISS;
                    counter_next_reg = 3'b000;
                end
                else begin //dc hit & ic hit
                    status_next_reg = `STAT_NORMAL;
                    counter_next_reg = 3'b111;  // TODO 为什么是 7
                                                // zyy: 这个值无所谓的，以前的
                                                // 旧值是7，我就留着了
                end
            end
        end
    endcase 
end

endmodule
