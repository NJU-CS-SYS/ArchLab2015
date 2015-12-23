`include "Define.v"
module store_shifter(
	input [1:0]addr,
	input [2:0]store_sel,
	input [31:0]rt_data,
	output [31:0]real_rt_data
);
reg [5:0]sw_sel;
reg [31:0]in_tmp;
integer Shift_amount;
always@(*) begin
	case(load_sel)
	   0:sw_sel=`SB;
	   1:sw_sel=`SH;
	   2:sw_sel=`SWL;
	   3:sw_sel=`SW;
	   6:sw_sel=`SWR;
	endcase
	case(sw_sel)
		`SW:real_rt_data=rt_data;
		`SB: begin
			Shift_amount=addr*8;
			if(Shitf_amount==32)
				in_tmp=32'b0;
			else begin
				for(i=31,j=31-Shift_amount;i>=Shift_amount;i=i-1,j=j-1)
                			in_tmp[i]=rt_data[j];
				if(Shift_amonut!=0) begin
				for(i=Shift_amount-1;i>=0;i=i-1)
                			in_tmp[i]=1'b0;
				end
			end
			real_rt_data=in_tmp;
		end
		`SH: begin
			Shift_amount=addr*16;
			if(Shitf_amount==32)
				in_tmp=32'b0;
			else begin
				for(i=31,j=31-Shift_amount;i>=Shift_amount;i=i-1,j=j-1)
                			in_tmp[i]=rt_data[j];
				if(Shift_amonut!=0) begin
				for(i=Shift_amount-1;i>=0;i=i-1)
                			in_tmp[i]=1'b0;
				end
			end
			real_rt_data=in_tmp;
		end
		`SWL: begin
			Shift_amount=addr;
			if(Shitf_amount==32)
				in_tmp=32'b0;
			else begin
				for(i=31-Shift_amount,j=31;i>=0;i=i-1,j=j-1)
                    			in_tmp[i]=rt_data[j];
				if(Shift_amount!=0)
				    for(i=31;i>=32-Shift_amount;i=i-1)
		                        in_tmp[i]=1'b0; 
			end
			real_rt_data=in_tmp;
		end
		`SWR: begin
			Shift_amount=addr;
			else begin
				for(i=31,j=31-Shift_amount;i>=Shift_amount;i=i-1,j=j-1)
                			in_tmp[i]=rt_data[j];
				if(Shift_amonut!=0) begin
				for(i=Shift_amount-1;i>=0;i=i-1)
                			in_tmp[i]=1'b0;
				end
			end
			real_rt_data=~in_tmp;
		end
	endcase
end
endmodule
