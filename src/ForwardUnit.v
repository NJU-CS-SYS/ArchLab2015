`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Tiancheng Jin 
// 
// Create Date: 2015/12/05 13:40:57
// Design Name: 
// Module Name: ForwardUnit
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


module ForwardUnit #(parameter DATA_WIDTH = 32,parameter ADDR_WIDTH = 5)(
    input [(DATA_WIDTH-1):0] rs_data,rt_data,memwb_data,
    input [(ADDR_WIDTH-1):0] rs_addr,rt_addr,exmem_rd_addr,memwb_rd_addr,
    input [3:0] exmem_byte_en,memwb_byte_en,
    
    output reg [(DATA_WIDTH-1):0] input_A,input_B,
    output reg [1:0] A_sel,B_sel
    );
    
    //change wb_data(input_A,input_B) due to rs_data/rt_data,memwb_data,memwb_byte_en;
    //caculator input_A
    always @ (*) begin
        input_A = rs_data;
        if(memwb_byte_en[3] == 1'b1) input_A[31:24] = memwb_data[31:24];
        if(memwb_byte_en[2] == 1'b1) input_A[23:16] = memwb_data[23:16];
        if(memwb_byte_en[1] == 1'b1) input_A[15:8] = memwb_data[15:8];
        if(memwb_byte_en[0] == 1'b1) input_A[7:0] = memwb_data[7:0];
    end
    
    //caculator input_B
    always @ (*) begin
        input_B = rt_data;
        if(memwb_byte_en[3] == 1'b1) input_B[31:24] = memwb_data[31:24];
        if(memwb_byte_en[2] == 1'b1) input_B[23:16] = memwb_data[23:16];
        if(memwb_byte_en[1] == 1'b1) input_B[15:8] = memwb_data[15:8];
        if(memwb_byte_en[0] == 1'b1) input_B[7:0] = memwb_data[7:0];        
    end
    
    //decide forward A_sel,occur together:Ex/Mem > Mem/Wb
    always @ (*) begin
        if(exmem_rd_addr == rs_addr && exmem_byte_en == 4'b1111)
            A_sel = 2'b01;
        else if(memwb_rd_addr == rs_addr && memwb_byte_en != 4'b0000)
            A_sel = 2'b10;
        else
            A_sel = 2'b00;
    end
    
    //decide forward B_sel,occur together:Ex/Mem > Mem/Wb
    always @ (*) begin
        if(exmem_rd_addr == rt_addr && exmem_byte_en == 4'b1111)
            B_sel = 2'b01;
        else if(memwb_rd_addr == rt_addr && memwb_byte_en != 4'b0000)
            B_sel = 2'b10;
        else
            B_sel = 2'b00;
    end
endmodule
