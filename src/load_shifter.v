
`include "Define.v"
module load_shifter(
	input [1:0]addr,
	input [2:0]load_sel,
	input [31:0]mem_data,
	output reg [31:0]data_to_reg
);
reg [5:0]ld_sel;
integer Shift_amount;
integer i,j;
reg [31:0]in_tmp;
always@(*) begin
   case(load_sel)
         0:ld_sel=`LB;
         1:ld_sel=`LH;
         2:ld_sel=`LWL;
         3:ld_sel=`LW;
         4:ld_sel=`LBU;
         5:ld_sel=`LHU;
         6:ld_sel=`LWR;
     endcase
     case(ld_sel)
		`LB: begin
			Shift_amount=addr*8;
			if(Shift_amount==32)
				in_tmp=32'b0;
			else begin
			    for(i=31-Shift_amount,j=31;i>=0;i=i-1,j=j-1)
			        in_tmp[i]=mem_data[j];
				if(Shift_amount!=0) begin
				    for(i=31;i>=32-Shift_amount;i=i-1)
					   in_tmp[i]=1'b0;
				end
			end
			for(i=31;i>=8;i=i+1) begin
				data_to_reg[i]=in_tmp[7];
			end
			data_to_reg[7:0]=in_tmp[7:0];
		end
		`LBU: begin
			Shift_amount=addr*8;
			if(Shift_amount==32)
				in_tmp=32'b0;
			else begin
			    for(i=31-Shift_amount,j=31;i>=0;i=i-1,j=j-1)
                    in_tmp[i]=mem_data[j];
				if(Shift_amount!=0)
				    for(i=31;i>=32-Shift_amount;i=i-1)
                        in_tmp[i]=1'b0; 
			end
			data_to_reg[31:8]=0;
			data_to_reg[7:0]=in_tmp[7:0];
		end
		`LH: begin
			Shift_amount=addr[1]*16;
			if(Shift_amount==32)
				in_tmp=32'b0;
			else begin
				for(i=31-Shift_amount,j=31;i>=0;i=i-1,j=j-1)
                    			in_tmp[i]=mem_data[j];
				if(Shift_amount!=0)
				    for(i=31;i>=32-Shift_amount;i=i-1)
		                        in_tmp[i]=1'b0; 
			end
			for(i=31;i>=16;i=i-1)
				data_to_reg[i]=in_tmp[15];
			data_to_reg[15:0]=in_tmp[15:0];
		end
		`LHU: begin
			Shift_amount=addr[1]*16;
			if(Shift_amount==32)
				in_tmp=32'b0;
			else begin
			    for(i=31-Shift_amount,j=31;i>=0;i=i-1,j=j-1)
                    in_tmp[i]=mem_data[j];
				if(Shift_amount!=0) 
				    for(i=31;i>=32-Shift_amount;i=i-1)
                        in_tmp[i]=1'b0;
			end
			data_to_reg[31:16]=0;
			data_to_reg[15:0]=in_tmp[15:0];
		end
		`LWL: begin
			Shift_amount=addr;
			for(i=31,j=31-Shift_amount;i>=Shift_amount;i=i-1,j=j-1)
                		in_tmp[i]=mem_data[j];
			if(Shift_amonut!=0) begin
		        	for(i=Shift_amount-1;i>=0;i=i-1)
                			in_tmp[i]=1'b0;
			end
			data_to_reg=in_tmp;
		end
		`LWR: begin
			Shift_amount=addr;
				for(i=31-Shift_amount,j=31;i>=0;i=i-1,j=j-1)
                        in_tmp[i]=mem_data[j];
                    for(i=31;i>=Shift_amount;i=i-1)
                        in_tmp[i]=1'b0;
			data_to_reg=~in_tmp;
		end
	endcase
end
endmodule
