/*
* 31    26|25    21|20    16|15                0|
*	FUNC	base 	 rt			offset
*FUNC rt,offset(base)
*GPR[rt]=memory[GPR[base]+offset]
*/
`define LB (6'b100000)
`define LBU (6'b10010)
`define LH (6'b100001)
`define LHU (6'b100101)
`define LW (6'b100011)
`define LWL (6'b100010)
`define LWR (6'b100110)

`define SB (6'b101000)
`define SH (6'b101001)
`define SW (6'b101011)
`define SWL (6'b101010)
`define SWR (6'b101110)
