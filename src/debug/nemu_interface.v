//
// This module stores some runtime information specially for NEMU.
// We expect to view these output in the wave form.
// To use this interface, NEMU should store related value to the
// mapping address, from low address to high one.
//

module nemu_interface (
    input clk,
    input [29:0] addr,
    input [31:0] data,
    output not_used
);

(* mark_debug = "true" *) reg [31:0] counter;
(* mark_debug = "true" *) reg [31:0] eip;
(* mark_debug = "true" *) reg [79:0] binary;
(* mark_debug = "true" *) reg [255:0] str;

wire [7:0] tag = addr[29 -: 8];

reg [3:0] bin_ptr;
reg [6:0] str_ptr;

always @(posedge clk) begin
    case (tag)
        8'ha0: begin
            counter <= data;
            bin_ptr <= 0;
            str_ptr <= 0;
        end
        8'ha1: begin
            eip <= data;
            bin_ptr <= 0;
            str_ptr <= 0;
        end
        8'ha2: begin
            // As the address is aligned, we can expected the one-byte
            // data exactly resides on the lower 8 bits.
            binary[ bin_ptr+:8 ] <= data[7:0];
            bin_ptr <= bin_ptr + 1;
        end
        8'ha3: begin
            // See case 8'ha2
            str[ str_ptr+:8 ] <= data[7:0];
            str_ptr <= str_ptr + 1;
        end
        default: begin
            counter <= 0;
            eip <= 0;
            bin_ptr <= 0;
            str_ptr <= 0;
            str[0] <= 0;
            binary[0] <= 0;
        end
    endcase
end

assign not_used = (counter == 32'hffffffff) && (eip == counter) && (|binary) && (|str);

endmodule
