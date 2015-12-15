`timescale 1ns / 1ps

/**
 * @brief 分支预测单元
 * @author whz
 *
 * 采用 1 位有效位, 1 位预测位, 直接映射, 直接替换策略
 * 一般来说, PC 的 [27:2] 是足够用来区分一条指令的,
 * 但是这依然是一个很大的数字, 所以拟采用 [9:2] 作为标签.
 * 由于是直接映射, 所以标签直接作为检索下标.
 *
 * 有效位的含义是判断是否采用存储的 PC 作为下一条指令的 PC,
 * 有效位无效的时候采用 current_pc_4 作为下一条地址.
 * 有效位在第一次被置 1 后即不会恢复为 0. 有效位置 1 时存储的一定是跳转指令的目标地址.
 * 之后靠预测位来决策地址的修正
 *
 * 预测位在为 0 时一定会更新目标地址, 同时自增 1, 在 1 的时候给错误预测留有缓冲的机会
 *
 * 对于跳转指令, 存储 PC 表明的可以是跳转地址, 也可以是顺序执行地址
 * 为了减少延迟槽的 nop 指令带来的性能损失, 顺序执行地址存储的是 PC + 8
 * 由于标签的位宽有限, 所以会有碰撞的情况出现, 在 MEM 段修正后 PC + 4 也可以存储到里面
 */

// 标签位宽
`define TAG_WIDTH 6
// 地址线宽度
`define PC_WIDTH 32
// 预测表条目长度
`define ENTRY_WIDTH 32
// 预测表条目数
`define NR_SLOT (2 ** `TAG_WIDTH)

// 总线
`define PC_BUS       (`PC_WIDTH - 1)  : 0
`define VALID_PC_BUS (`PC_WIDTH - 3)  : 0
`define VALID_SLICE  (`PC_WIDTH - 1)  : 2
`define INDEX_BUS    (`NR_SLOT - 1)   : 0
`define TAG_BUS      (`TAG_WIDTH - 1) : 0

module bpu(
    input clk,
    input reset,
    input bpu_w_en,                    // 写使能, 驱动 bpu 进行状态更新
    input [`PC_BUS] current_pc,        // 当前用来查询下一条指令的PC
    input [`PC_BUS] tag_pc,            // 用来获取标签的PC
    input [`PC_BUS] next_pc,           // 标签PC对应的下一条执行指令的PC
    output reg [`PC_BUS] predicted_pc  // 预测 PC
);

reg [`VALID_PC_BUS] bpu_pc [`INDEX_BUS]; // 存储预测pc
reg bpu_valid [`INDEX_BUS];              // 存储有效位, 指示是否使用预测pc
reg bpu_predict [`INDEX_BUS];            // 存储预测位, 指示预测pc是否可以修改

integer i;
initial begin
    for (i = 0; i < `NR_SLOT; i = i + 1) begin
        bpu_pc[i] = 0;
        bpu_valid[i] = 0;
        bpu_predict[i] = 0;
    end
end

wire [`VALID_PC_BUS] valid_current_pc = current_pc[`VALID_SLICE];
wire [`VALID_PC_BUS] valid_tag_pc = tag_pc[`VALID_SLICE];

// 预测逻辑
wire [`TAG_BUS] predict_tag = valid_current_pc[`TAG_BUS];

always @(*) begin
   if (bpu_valid[predict_tag] == 1'b1) begin
       predicted_pc = { bpu_pc[predict_tag], 2'd0 };
   end
   else begin
       predicted_pc = { valid_current_pc + 1, 2'd0 };
   end
end

// 更新逻辑
wire [`TAG_BUS] update_tag = tag_pc[`TAG_BUS];
wire update_predict = bpu_predict[update_tag];
always @(negedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < `NR_SLOT; i = i + 1) begin
            bpu_pc[i] <= 0;
            bpu_valid[i] <= 0;
            bpu_predict[i] <= 0;
        end
    end
    else if (bpu_w_en) begin
        // 有效位有效后一直有效
        bpu_valid[update_tag] <= 1'b1;
        // 预测位为 0 时立即更新, 之后容忍一次错误
        if (update_predict == 1'b0) begin
            bpu_pc[update_tag] <= next_pc[`VALID_SLICE];
        end
        // 翻转预测位, 因为只有一位, 相当于加一
        bpu_predict[update_tag] <= ~update_predict;
    end
    else begin
        // 预测正确的情况, 将预测位维持在 1, 只有有效的slot的预测位才采取这一行为
        bpu_predict[update_tag] <= 1'b1 & bpu_valid[update_tag];
    end
end

endmodule

`undef PC_BUS
`undef VALID_PC_BUS
`undef VALID_SLICE
`undef INDEX_BUS
`undef TAG_BUS
