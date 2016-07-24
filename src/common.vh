`ifndef __COMMON_VH__
`define __COMMON_VH__

`define IMM_WIDTH 16
`define IMM_BUS (`IMM_WIDTH - 1):0
`define EXT_SEL_BUS 1:0
`define DATA_WIDTH 32
`define DATA_BUS 31:0
`define PC_WIDTH 32
`define INSTR_WIDTH 32
`define PC_BUS 31:0
`define JMP_BUS 29:0
`define REG_ADDR_BUS 4:0
`define JMP_SLICE 25:0
`define JMP_HEAD_SLICE 31:28
`define RS_SLICE 25:21
`define RT_SLICE 20:16
`define RD_SLICE 15:11
`define IMM_SLICE 15:0

// 标签位宽
`define TAG_WIDTH 6
// 地址线宽度
`define PC_WIDTH 32
// 预测表条目长度
`define ENTRY_WIDTH 32
// 预测表条目数
`define NR_SLOT (2 ** `TAG_WIDTH)

`define VALID_PC_BUS (`PC_WIDTH - 3)  : 0
`define VALID_SLICE  (`PC_WIDTH - 1)  : 2
`define INDEX_BUS    (`NR_SLOT - 1)   : 0
`define TAG_BUS      (`TAG_WIDTH - 1) : 0

`endif
