`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/06 21:04:24
// Design Name: 
// Module Name: victimway_sel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//   决定要被替换的路。
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// after a compare access, victimway will be invert
// during non-cmp access,victimway doesn't change
//////////////////////////////////////////////////////////////////////////////////


module victimway_sel(rst, enable, cmp, line0_valid, line1_valid, line0_dirty, line1_dirty, prev, v);

input rst;
input enable;
input cmp;
input line0_valid;
input line1_valid;
input line0_dirty;
input line1_dirty;
input prev;
output reg v;

assign go = ~rst & enable & cmp;

// 组合逻辑
always @(rst or prev or go or line0_valid or line0_dirty or line1_valid or line1_dirty) begin
    if(!go) begin
        if(rst) begin
            v = 0;
        end
        else begin
            v = prev;
        end
    end
    else begin
        if(!line0_valid && !line1_valid)begin // both invalid
            v = 0;
        end
        else begin
            if(line0_valid && line1_valid)begin // both valid
                if(!line0_dirty && !line1_dirty) begin // both no dirty
                    v = 0;
                end
                else begin
                    if(line0_dirty && line1_dirty)begin //both dirty
                        v = ~prev;  // ramdom here
                    end
                    else begin
                        if(line0_dirty)begin // line 0 dirty
                            v = 1;
                        end
                        else begin // line 1 dirty
                            v = 0;
                        end
                    end
                end
            end
            else begin
                if(line0_valid)begin //line 1 invalid
                    v = 1;
                end
                else begin //line 0 invalid
                    v = 0;
                end
            end
        end
    end
end

endmodule
