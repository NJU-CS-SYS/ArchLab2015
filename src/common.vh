`ifndef __COMMON_VH__
`define __COMMON_VH__

`define IMM_WIDTH 16
`define IMM_BUS (`IMM_WIDTH - 1):0
`define EXT_SEL_BUS 1:0
`define DATA_WIDTH 32
`define DATA_BUS (`DATA_WIDTH - 1):0
`define PC_WIDTH 32
`define INSTR_WIDTH 32
`define PC_BUS 31:0
`define DATA_BUS 31:0
`define JMP_BUS 31:0
`define REG_ADDR_BUS 4:0
`define IMM_BUS 15:0
`define JMP_SLICE 25:0
`define JMP_HEAD_SLICE 31:28
`define RS_SLICE 25:21
`define RT_SLICE 20:16
`define RD_SLICE 15:11
`define IMM_SLICE 15:0

`endif
