module spi_flash(
	input clk,
	input rst,
	input send_dummy,
	input [1:0] spi_mode,
	input read_or_write_sel,
    input [23:0] addr_in,
	input button,
	output reg read_done,
	output reg write_done,
	output EOS,
    output [7:0] dout2,
    output [31:0] word,
    output reg [2:0] debug_state,
	output reg cnt_begin,

	//flash memory device
	output s,
	output c,
	inout [3:0] DQ

	//test tri
	/*output [3:0] dq_o,
	output [3:0] dq_t,
	input [3:0] dq_i*/
    );
//------------------------------------------------------------------------------------------------
//-------------parameter definitions
	parameter ADDRESS_BYTE_NUMBER = 3;		//3bytes 24bits address
	parameter NUMBER_OF_DATA_TRANSMITTED = 4;
	
//------------------------------------------------------------------------------------------------
//-------------FSM state definitions
	parameter IDLE 					= 6'h0, 		//wait for start
                 READ_INSTRUCTION 	= 6'h1,		//read instruction
                 READ_START 			= 6'h2,		//read start
                 READ_DELAY_1			= 6'h3,		//wait a clock for genarating the start_out pluse
                 READ_SEND_ADDRESS	= 6'h4,		//send 24bit address 
                 READ_SEND_DUMMY		= 6'h5,
                 READ_RECEIVE_DATA	= 6'h6, 		//receive data----------接收数据长度？
                 READ_WAIT				= 6'h7,		//wait the end of the last transmission
                 READ_DELAY_2			= 6'h8,
                 
                 WRITE_ENABLE_INSTRUCTION	= 6'h9,
                 WRITE_ENABLE_START			= 6'ha,
                 WRITE_ENABLE_WAIT			= 6'hb,
                 WRITE_ENABLE_DELAY			= 6'hc,
                 
                 ERASE_INSTRUCTION			= 6'hd,
                 ERASE_START					= 6'he,
                 ERASE_DELAY_1					= 6'hf,
                 ERASE_SEND_ADDRESS			= 6'h10,
                 ERASE_WAIT						= 6'h11,
                 ERASE_DELAY_2					= 6'h12,                                                                                                                                   
                 
                 ERASE_READ_STATUS_INSTRUCTION	= 6'h13,
                 ERASE_READ_STATUS_START			= 6'h14,
                 ERASE_READ_STATUS_DELAY_1			= 6'h15,
                 ERASE_READ_STATUS_DATA				= 6'h16,
                 ERASE_READ_STATUS_DELAY_2			= 6'h17,
                 ERASE_READ_STATUS_WAIT				= 6'h18,
                 ERASE_READ_STATUS_DELAY_3			= 6'h19,
                 
                 WRITE_INSTRUCTION			= 6'h1a,
                 WRITE_START					= 6'h1b,
                 WRITE_DELAY_1					= 6'h1c,
                 WRITE_SEND_ADDRESS			= 6'h1d,
                 WRITE_SEND_DATA				= 6'h1e,
                 WRITE_WAIT						= 6'h1f,
                 WRITE_DELAY_2					= 6'h20,
                 
                 WRITE_READ_STATUS_INSTRUCTION	= 6'h21,
                 WRITE_READ_STATUS_START			= 6'h22,
                 WRITE_READ_STATUS_DELAY_1			= 6'h23,
                 WRITE_READ_STATUS_DATA				= 6'h24,
                 WRITE_READ_STATUS_DELAY_2			= 6'h25,
                 WRITE_READ_STATUS_WAIT				= 6'h26,
                 WRITE_READ_STATUS_DELAY_3			= 6'h27,
                 
                 RESET_INSTRUCTION = 6'h28,
                 RESET_START = 6'h29,
                 RESET_WAIT = 6'h2a,
                 RESET_DELAY = 6'h2b;
				 
				 
//---------------------------------------------------------------------------------------------	
//-----------Internal signals definitions
	reg [7:0] instruction = 8'b0;
	reg [ADDRESS_BYTE_NUMBER*8-1:0] address;
	reg [7:0] data;
	
	reg [5:0] state;
	reg start_transmission = 1'b0;
	reg rnw;													//read or write transmission select
	reg [2:0] address_send_counter = 3'b0;
	reg [31:0] transmission_bytes_counter = 9'b0;
	reg erase_done;
	reg [31:0] delay_count;
	
//-----------------------------------------------
//------------spi_tr8 signals
	reg dummy = 1'b0;;
	wire start_out;
	wire rnw_sel;
	wire [3:0] dummy_clks;
	wire [7:0] din;
	wire transmission_done;
	wire transmission_done_dly;
	wire done_for_wr;
	wire [3:0] dq_o;
    wire [3:0] dq_t;
    wire [3:0] dq_i;
    wire [7:0] dout;
	
//------------------------------------------------------------------------------------------------
//-------------button process
reg button_r0,button_r1;
always@(posedge clk) begin
    if(rst)begin
        button_r0 <= 0;
        button_r1 <= 0;
    end
    else begin
        button_r0 <= button;
        button_r1 <= button_r0;
    end
end
wire pos_button = button_r0 & (~button_r1);
reg pos_b_latch;

reg [10:0] cnt;
reg start;

always @ (posedge clk) begin
    if(rst)begin
        start <= 0;
        cnt_begin <=0;
        cnt<=0;
        debug_state <= 3'b100;
        pos_b_latch <= 0;
    end
    else begin
        pos_b_latch <= pos_button;
        start <= 0;
        debug_state <= 3'b000;
        if(pos_b_latch) begin
            debug_state <= 3'b001;
            start <= 1;
        end
        /*
        if(pos_button) begin
            debug_state <= 3'b000;
            cnt_begin <= 1'b1;
        end

        if(cnt < 11'd2)begin  //delay
            debug_state <= 3'b001;
            if(cnt_begin) begin
                debug_state <= 3'b010;
                cnt <= cnt + 1'b1;
            end
        end
        else begin
            debug_state <= 3'b011;
            start <= 1;
            cnt <= 0;
            cnt_begin <= 0;
        end
        */
    end
end

assign dout2 = address[1] ? (address[0] ? word[31:24] : word[23:16]) :
(address[0] ? word[15:8] : word[7:0]);
//------------------------------------------------------------------------------------------------
//---------------main FSM
	always @(posedge clk)
		if(rst)begin
			read_done <= 1'b0;
			write_done <= 1'b0;
			state <= RESET_INSTRUCTION;
			erase_done <= 1'b0;
		end
		else
			case(state)
			RESET_INSTRUCTION:begin
			    delay_count <= 0;
			    rnw <= 1'b0;
			    instruction <= 8'hf0;
			    state <= RESET_START;
			end
			RESET_START:begin
			    start_transmission <= 1'b1;
			    state <= RESET_WAIT;
			end
			RESET_WAIT:begin
			    start_transmission <= 1'b0;
			    if(done_for_wr)
                    state <= RESET_DELAY;
                else
                    state <= RESET_WAIT;
            end
            RESET_DELAY:begin
                if(delay_count < 'd20000)
                    delay_count <= delay_count + 1'b1;
                else begin
                    delay_count <= 0;
                    state <= IDLE;
                end
            end 
			IDLE:begin
				start_transmission <= 1'b0;
				if(start)
					if(read_or_write_sel)
						state <= READ_INSTRUCTION;
					else
						state <= WRITE_ENABLE_INSTRUCTION;
				else
					state <= IDLE;
			end
			
	//-----------------------------------
	//------Read Flash
			READ_INSTRUCTION:begin
				rnw <= 1'b0;
				instruction <= 8'h03;
				state <= READ_START;
                read_done <= 1'b0;
			end
			READ_START:begin
				start_transmission <= 1'b1;
				state <= READ_DELAY_1;
			end
			READ_DELAY_1:begin
				state <= READ_SEND_ADDRESS;
			end
			READ_SEND_ADDRESS:begin
				if(address_send_counter == ADDRESS_BYTE_NUMBER)begin
					if(transmission_done) begin
						address_send_counter <= 3'b0;
						if(send_dummy)begin
							state <= READ_SEND_DUMMY;
							dummy <= 1'b1;
						end
						else begin
							state <= READ_RECEIVE_DATA;
							rnw <= 1'b1;
						end
					end
				end
                else if(transmission_done) begin
					address_send_counter <= address_send_counter + 1'b1;
                end
			end
			READ_SEND_DUMMY:begin
				dummy <= 1'b0;
				if(transmission_done) begin
					state <= READ_RECEIVE_DATA;
					rnw <= 1'b1;
				end
			end					
			READ_RECEIVE_DATA:begin
				if(transmission_bytes_counter == NUMBER_OF_DATA_TRANSMITTED-1) begin //number of transmitted bytes
					transmission_bytes_counter <= 9'b0;
					state <= READ_WAIT;  
				end
                else if(transmission_done) begin
					transmission_bytes_counter <= transmission_bytes_counter + 1'b1;
                end
			end
			READ_WAIT:begin
				start_transmission <= 1'b0;
				if(transmission_done)begin
					state <= READ_DELAY_2;
				end
				else
					state <= READ_WAIT;
			end
			READ_DELAY_2:begin
				if(done_for_wr)begin
					read_done <= 1'b1;
					state <= IDLE;
				end
			end
			
		//------------------------------------	
		//-------Write enable
			WRITE_ENABLE_INSTRUCTION:begin
				rnw <= 1'b0;
				instruction <= 8'h06;
				state <= WRITE_ENABLE_START;
			end
			WRITE_ENABLE_START:begin
				start_transmission <= 1'b1;
				state <= WRITE_ENABLE_WAIT;
			end
			WRITE_ENABLE_WAIT:begin
				start_transmission <= 1'b0;
				if(done_for_wr)
					state <= WRITE_ENABLE_DELAY;
				else
					state <= WRITE_ENABLE_WAIT;
			end
			WRITE_ENABLE_DELAY:begin
                if(erase_done)
                    state <= WRITE_INSTRUCTION;
                else
                    state <= ERASE_INSTRUCTION;
			end
				
		//-----------------------------------------	
		//--------Erase Flash
			ERASE_INSTRUCTION:begin
			    rnw <= 1'b0;
				instruction <= 8'hd8;				//sector erase
				state <= ERASE_START;
			end
			ERASE_START:begin
				start_transmission <= 1'b1;
				state <= ERASE_DELAY_1;
			end
			ERASE_DELAY_1:begin
					state <= ERASE_SEND_ADDRESS;
			end
			ERASE_SEND_ADDRESS:begin
				if(address_send_counter == ADDRESS_BYTE_NUMBER)begin
					address_send_counter <= 3'b0;
					state <= ERASE_WAIT;
				end
				else if(transmission_done)
					address_send_counter <= address_send_counter + 1'b1;
			end
			ERASE_WAIT:begin
				start_transmission <= 1'b0;
				if(transmission_done)
					state <= ERASE_DELAY_2;
				else
					state <= ERASE_WAIT;
			end
			ERASE_DELAY_2:begin
				if(done_for_wr)
					state <= ERASE_READ_STATUS_INSTRUCTION;
			end
			ERASE_READ_STATUS_INSTRUCTION:begin
				instruction <= 8'h05;							//read status register 1
				state <= ERASE_READ_STATUS_START;
			end
			ERASE_READ_STATUS_START:begin
				start_transmission <= 1'b1;
				state <= ERASE_READ_STATUS_DELAY_1;
			end
			ERASE_READ_STATUS_DELAY_1:begin
				rnw <= 1'b1;
				state <= ERASE_READ_STATUS_DATA;
			end
			ERASE_READ_STATUS_DATA:begin
				if(transmission_done)begin
					state <= ERASE_READ_STATUS_DELAY_2;
				end
			end
			ERASE_READ_STATUS_DELAY_2:begin
				if(transmission_done)
					state <= ERASE_READ_STATUS_WAIT;
			end
			ERASE_READ_STATUS_WAIT:begin
				if(dout[0]==0)
					if(transmission_done)begin
						start_transmission <= 1'b0;
						state <= ERASE_READ_STATUS_DELAY_3;
					end
					else
						state <= ERASE_READ_STATUS_WAIT;
			end
			ERASE_READ_STATUS_DELAY_3:begin
				if(done_for_wr)begin
					state <= WRITE_ENABLE_INSTRUCTION;
					erase_done <= 1'b1;
				end
			end
		
	//---------------------------------------------------------
	//-----------Write Flash
			WRITE_INSTRUCTION:begin
				rnw <= 1'b0;
				instruction <= 8'h02;				//page program
				state <= WRITE_START;
			end
			WRITE_START:begin
				start_transmission <= 1'b1;
				state <= WRITE_DELAY_1;
			end
			WRITE_DELAY_1:begin
				state <= WRITE_SEND_ADDRESS;
			end
			WRITE_SEND_ADDRESS:begin
				if(address_send_counter == ADDRESS_BYTE_NUMBER)begin
					if(transmission_done) begin
						address_send_counter <= 3'b0;
						state <= WRITE_SEND_DATA;
						end
					end
				else if(transmission_done)
					address_send_counter <= address_send_counter + 1'b1;
			end
			WRITE_SEND_DATA:begin
				if(transmission_bytes_counter == 9'd256-1)begin//NUMBER_OF_DATA_TRANSMITTED-1) begin //number of transmitted bytes
					transmission_bytes_counter <= 9'b0;
					state <= WRITE_WAIT;  
				end
				else if(transmission_done)
					transmission_bytes_counter <= transmission_bytes_counter + 1'b1;
			end
			WRITE_WAIT:begin
				start_transmission <= 1'b0;
				if(transmission_done)
					state <= WRITE_DELAY_2;
			end
			WRITE_DELAY_2:begin
				if(done_for_wr)
					state <= WRITE_READ_STATUS_INSTRUCTION;
			end
			
			WRITE_READ_STATUS_INSTRUCTION:begin
				instruction <= 8'h05;							//read status register 1
				state <= WRITE_READ_STATUS_START;
			end
			WRITE_READ_STATUS_START:begin
				start_transmission <= 1'b1;
				state <= WRITE_READ_STATUS_DELAY_1;
			end
			WRITE_READ_STATUS_DELAY_1:begin
				rnw <= 1'b1;
				state <= WRITE_READ_STATUS_DATA;
			end
			WRITE_READ_STATUS_DATA:begin
				if(transmission_done)begin								
					state <= WRITE_READ_STATUS_DELAY_2;		//wait the instruction transmission complete
				end
			end
			WRITE_READ_STATUS_DELAY_2:begin
				if(transmission_done)							//wait the first data transmission complete
					state <= WRITE_READ_STATUS_WAIT;
			end
			WRITE_READ_STATUS_WAIT:begin						//wait the last data transmission complete
				if(dout[0]==0)
					if(transmission_done)begin
						start_transmission <= 1'b0;
						state <= WRITE_READ_STATUS_DELAY_3;
					end
					else
						state <= WRITE_READ_STATUS_WAIT;
			end
			WRITE_READ_STATUS_DELAY_3:begin
				if(done_for_wr)begin
					write_done <= 1'b1;
					state <= IDLE;
				end
			end
			
			default: state <= IDLE;
		endcase
	
//---------------------------------------------------------------------------------------------------------
//----------transmission start control
	assign start_out = (state == READ_SEND_ADDRESS || state == READ_RECEIVE_DATA || state == READ_WAIT 
						  || state == ERASE_SEND_ADDRESS || state == ERASE_WAIT
						  || state == ERASE_READ_STATUS_DATA || state == ERASE_READ_STATUS_DELAY_2 || state == ERASE_READ_STATUS_WAIT
						  || state == WRITE_SEND_ADDRESS || state == WRITE_SEND_DATA || state == WRITE_WAIT
						  || state == WRITE_READ_STATUS_DATA || state == WRITE_READ_STATUS_DELAY_2 || state == WRITE_READ_STATUS_WAIT) 
						  ? (start_transmission & transmission_done_dly) : start_transmission;

//---------------------------------------------------------------------------------------------------------
//----------transmission data control
	assign din = (address_send_counter == 0) ?
    ((state == WRITE_SEND_DATA) ? data : instruction) :
    address[ADDRESS_BYTE_NUMBER*8-1:ADDRESS_BYTE_NUMBER*8-8];

//----------------------------------------------------------------------------------------------------------
//----------read or write transmission select
	assign rnw_sel = rnw || (state == READ_SEND_ADDRESS && address_send_counter == ADDRESS_BYTE_NUMBER && transmission_done) || (state == READ_SEND_DUMMY && transmission_done);
	
//----------------------------------------------------------------------------------------------------------
//----------address
	always@(posedge clk or posedge rst)
		if(rst)
            address <= addr_in;
		else begin
			if(address_send_counter == 0)
                address <= addr_in;
			else if(transmission_done)
				address <= address  << 8;
			else
				address <= address;
		end 

//----------------------------------------------------------------------------------------------------------
//----------data
	always@(posedge clk or posedge rst)
		if(rst)
            data <=  addr_in[7:0];
		else
			if(state == WRITE_SEND_DATA && transmission_done)
                data <=  addr_in[7:0];

//-----------------------------------------------------------------------------------------------------------
//----------instantiation				
	spi_tr8 spi_tr8_inst (
		.clk(clk), 
		.reset(rst), 
		.dummy(dummy), 
		.start_out(start_out), 
		.rnw(rnw_sel), 
		.div_rate(13'd10), 
		.dummy_clks(4'd8), 
		.mode(spi_mode), 
		.din(din), 
		.dout(dout), 
		.done(transmission_done), 
		.done_dly(transmission_done_dly),
		.done_for_wr(done_for_wr), 
		.dq_t_delayed(), 
		.c(c), 
		.s(s), 
		.dq_o(dq_o), 
		.dq_t(dq_t), 
		.dq_i(dq_i),
        .history_buffer(word)
	);
	
	IOBUF #(
          .DRIVE(12), // Specify the output drive strength
          .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
          .IOSTANDARD("LVCMOS33"), // Specify the I/O standard
          .SLEW("SLOW") // Specify the output slew rate
       ) IOBUF_inst_3 (
          .O(dq_i[3]),     // Buffer output
          .IO(DQ[3]),   // Buffer inout port (connect directly to top-level port)
          .I(dq_o[3]),     // Buffer input
          .T(dq_t[3])      // 3-state enable input, high=input, low=output
       );
       
    IOBUF #(
         .DRIVE(12), // Specify the output drive strength
         .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
         .IOSTANDARD("LVCMOS33"), // Specify the I/O standard
         .SLEW("SLOW") // Specify the output slew rate
      ) IOBUF_inst_2 (
         .O(dq_i[2]),     // Buffer output
         .IO(DQ[2]),   // Buffer inout port (connect directly to top-level port)
         .I(dq_o[2]),     // Buffer input
         .T(dq_t[2])      // 3-state enable input, high=input, low=output
      );
              
    IOBUF #(
        .DRIVE(12), // Specify the output drive strength
        .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
        .IOSTANDARD("LVCMOS33"), // Specify the I/O standard
        .SLEW("SLOW") // Specify the output slew rate
     ) IOBUF_inst_1 (
        .O(dq_i[1]),     // Buffer output
        .IO(DQ[1]),   // Buffer inout port (connect directly to top-level port)
        .I(dq_o[1]),     // Buffer input
        .T(dq_t[1])      // 3-state enable input, high=input, low=output
     );

    IOBUF #(
        .DRIVE(12), // Specify the output drive strength
        .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
        .IOSTANDARD("LVCMOS33"), // Specify the I/O standard
        .SLEW("SLOW") // Specify the output slew rate
        ) IOBUF_inst_0 (
        .O(dq_i[0]),     // Buffer output
        .IO(DQ[0]),   // Buffer inout port (connect directly to top-level port)
        .I(dq_o[0]),     // Buffer input
        .T(dq_t[0])      // 3-state enable input, high=input, low=output
        );
       	
	STARTUPE2 #(
          .PROG_USR("FALSE"),  // Activate program event security feature. Requires encrypted bitstreams.
          .SIM_CCLK_FREQ(0.0)  // Set the Configuration Clock Frequency(ns) for simulation.
       )
       
       STARTUPE2_inst (
          .CFGCLK(),       // 1-bit output: Configuration main clock output
          .CFGMCLK(),     // 1-bit output: Configuration internal oscillator clock output
          .EOS(EOS),             // 1-bit output: Active high output signal indicating the End Of Startup.
          .PREQ(),           // 1-bit output: PROGRAM request to fabric output
          .CLK(1'b0),             // 1-bit input: User start-up clock input
          .GSR(1'b0),             // 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
          .GTS(1'b0),             // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
          .KEYCLEARB(1'b0), // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
          .PACK(),           // 1-bit input: PROGRAM acknowledge input
          .USRCCLKO(c),         // 1-bit input: User CCLK input
          .USRCCLKTS(1'b0), // 1-bit input: User CCLK 3-state enable input
          .USRDONEO(1'b1),   // 1-bit input: User DONE pin output control
          .USRDONETS(1'b1)  // 1-bit input: User DONE 3-state enable output
       );
	

endmodule
