`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Tiancheng Jin
// 
// Create Date: 2015/12/05 14:31:54
// Design Name: 
// Module Name: testFU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testFU();
    reg [31:0] rs_data,rt_data,memwb_data;
    reg [4:0] rs_addr,rt_addr,exmem_rd_addr,memwb_rd_addr;
    reg [3:0] exmem_byte_en,memwb_byte_en;
    
    wire [31:0] input_A,input_B;
    wire [1:0] A_sel,B_sel;
    
    ForwardUnit m0 (
    .rs_data(rs_data),
    .rt_data(rt_data),
    .memwb_data(memwb_data),
    .rs_addr(rs_addr),
    .rt_addr(rt_addr),
    .exmem_rd_addr(exmem_rd_addr),
    .memwb_rd_addr(memwb_rd_addr),
    .exmem_byte_en(exmem_byte_en),
    .memwb_byte_en(memwb_byte_en),
    .input_A(input_A),
    .input_B(input_B),
    .A_sel(A_sel),
    .B_sel(B_sel));
    
    initial begin
        rs_data = 32'h50505050;
        rt_data = 32'ha0a0a0a0;
        memwb_data = 32'h3c3c3c3c;
        exmem_rd_addr = 5'd0;
        memwb_rd_addr = 5'd0;
        
        exmem_byte_en = 4'b1111;
        memwb_byte_en = 4'b1111;
    end
    
    always begin
        //add $3,$2,$1;
        //sub $5,$3,$4;
        //should forward from Ex/Mem,A_sel = 2'01,B_sel = 2'b00
        rs_addr = 5'd3;  rt_addr = 5'd4; exmem_rd_addr = 5'd3; #20;
        
        
        //add $3,$2,$1;
        //or $6,$2,$1;
        //sub $5,$3,$4;
        //should forward from Mem/Wr,A_sel = 2'b10,B_sel = 2'b00;
        rs_addr = 5'd3; rt_addr = 5'd4; exmem_rd_addr = 5'd6; memwb_rd_addr = 5'd3;#20;
        
        
        //add $1,$1,$2;
        //add $1,$1,$3;
        //add $1,$1,$4;
        //should forward from Ex/Mem,A_sel = 2'b01,B_sel = 2'b00;
        rs_addr = 5'd1; rt_addr = 5'd4; exmem_rd_addr = 5'd1; memwb_rd_addr = 5'd1;#20;
        
        
        //add $1,$2,$3;
        //add $2,$3,$4;
        //Not forward,A_sel = 2'b00,B_sel = 2'b00;
        rs_addr = 5'd3; rt_addr = 5'd4; exmem_rd_addr = 5'd1; #20;
        
        
        //add $1,$2,$3;
        //add $4,$1,$3;
        //sub $5,$4,$1;
        //Two forward together,A_sel = 2'b01,B_sel = 2'b10;
        rs_addr = 5'd4; rt_addr = 5'd1; exmem_rd_addr = 5'd4; memwb_rd_addr = 5'd1;#40;
    end
    
    always begin
        exmem_byte_en = 4'b1111;memwb_byte_en = 4'b1111; #20;
        exmem_byte_en = 4'b1111;memwb_byte_en = 4'b1111; #20;
        exmem_byte_en = 4'b1111;memwb_byte_en = 4'b1010; #20;
        exmem_byte_en = 4'b1111;memwb_byte_en = 4'b0000; #20;
        exmem_byte_en = 4'b1111;memwb_byte_en = 4'b0011; #20;
        exmem_byte_en = 4'b1111;memwb_byte_en = 4'b0000; #20;
    end
    
endmodule
