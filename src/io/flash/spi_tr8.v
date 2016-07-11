`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent RO
// Engineer: Mihaita Nagy
// 
// Create Date:    11:19:33 08/11/2010 
// Design Name: 
// Module Name:    spi_tr8 
// Project Name:   Quad-SPI IP Core
// Target Devices: Spartan 6
// Tool versions:  12.2
// Description: 
//
// Dependencies:   spi_fifo_send.v, spi_fifo_receive.v, spi_sf.v
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spi_tr8(	//-- signals from/to top-level module --
    input clk,
    input reset,
    input dummy,
    input start_out,
    input rnw,
    input [12:0] div_rate,
    input [3:0] dummy_clks,
    input [1:0] mode,
    input [7:0] din, //-- data in
    output reg [7:0] dout, //-- data out
    output reg done,
    output reg done_dly,
    output reg done_for_wr,
    output [3:0] dq_t_delayed,
    output reg [31:0] history_buffer,

                        //-- signals to/from StrataFlash --
                        output reg c, //-- serial clock
                        output reg s, //-- select
                        output reg [3:0] dq_o, //-- data out
                        output reg [3:0] dq_t, //-- buffer select
                    input [3:0] dq_i); //-- data in

//---------------------------------------------------------------------------------------------

wire dq_0_cmb;
wire dq_1_cmb;
wire dq_2_cmb;
wire dq_3_cmb;
wire c_cmb;
wire [3:0] dq_o_cmb;
wire [3:0] dq_t_cmb;
wire [7:0] dload_out;

wire activate_c;
wire s_dly;
reg s_delayed;

reg [13:0] count_c;
reg [3:0] count_dummy;
reg [3:0] count_send;
reg [3:0] count_read;

reg [2:0] state;
reg [2:0] next;
reg [1:0] state_clk;
reg [1:0] next_clk;
reg [1:0] stare;
reg [1:0] urm;
reg [1:0] cstate;
reg [1:0] nstate;

reg [2:0] state_delayed;

reg [7:0] dreg_out;
reg [7:0] dload_in;

wire pos_c;
wire poss_c;

wire trigger_edge;
wire [1:0] a;
wire [1:0] b;

wire done_for_dout;
//reg done_dly;
reg done_dly2;

reg [3:0] dq_t_delay;
reg [3:0] dq_t_delay2;

wire start;
reg start_mode2_div_rate2;
reg start_mode2_div_rate2_buf;
reg signal_start;


//---------------------------------------------------------------------------------------------

//main FSM states
parameter idle				= 3'b000,
idle_wait		= 3'b001,
send_dummy		= 3'b011,
send_data		= 3'b010,
read_data		= 3'b110;

//serial clock FSM states
parameter idle_clk 		= 2'b00,
gen_clk  		= 2'b01;

//done FSM states		 
parameter got 				= 2'b00,
buc     		= 2'b01,
sfarsit			= 2'b11;

//start signal FSM states
parameter trig_start		= 2'b00,
trig_posedge	= 2'b01,
preend_event 	= 2'b11,
end_event 		= 2'b10;


//-- SEND -------------------------------------------------------------------------------------

assign dload_out = (mode == 2'b00) ? din : //-- extended
(mode == 2'b01) ? {din[7],din[5],din[3],din[1],din[6],din[4],din[2],din[0]} : //-- dual
(mode == 2'b10) ? {din[7],din[3],din[6],din[2],din[5],din[1],din[4],din[0]} : 1'b1; //-- quad

assign dq_0_cmb = (mode == 2'b00) ? dreg_out[7] : //-- extended
(mode == 2'b01) ? dreg_out[3] : //-- dual
(mode == 2'b10) ? dreg_out[1] : 1'b1; //-- quad

assign dq_1_cmb = (mode == 2'b00) ? 1'b1 : //-- extended
(mode == 2'b01) ? dreg_out[7] : //-- dual
(mode == 2'b10) ? dreg_out[3] : 1'b1; //-- quad

assign dq_2_cmb = (mode == 2'b00) ? 1'b1 : //-- extended
(mode == 2'b01) ? 1'b1 : //-- dual
(mode == 2'b10) ? dreg_out[5] : 1'b1; //-- quad

assign dq_3_cmb = (mode == 2'b00) ? 1'b1 : //-- extended
(mode == 2'b01) ? 1'b1 : //-- dual
(mode == 2'b10) ? dreg_out[7] : 1'b1; //-- quad

//---------------------------------------------------------------------------------------------

//-- rising edge of c -------------------------------------------------------------------------

assign pos_c = (!s && (count_c == ((div_rate/2) - 1))) ? 1'b1 : 1'b0;

//---------------------------------------------------------------------------------------------

//-- falling edge of c ------------------------------------------------------------------------

assign poss_c = (count_c == (div_rate - 1)) ? 1'b1 : 1'b0;

//---------------------------------------------------------------------------------------------

//-- serial clock -----------------------------------------------------------------------------

assign c_cmb = (s || !activate_c || reset) ? 1'b1 : 
((state != idle) && (count_c >= ((div_rate/2) - 1)) && 
(count_c < (div_rate - 1))) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
    c <= c_cmb;
end

//---------------------------------------------------------------------------------------------

//-- data out to memory -----------------------------------------------------------------------

assign dq_o_cmb = (state == send_dummy) ? 4'bzzzz : {dq_3_cmb,dq_2_cmb,dq_1_cmb,dq_0_cmb};

always @ (posedge clk)
begin
    if (poss_c)
        dq_o <= dq_o_cmb;
end

//---------------------------------------------------------------------------------------------

//-- buffer control signal --------------------------------------------------------------------

assign dq_t_cmb = (state == read_data) ? 4'b1111 : 4'b0000;

always @ (posedge clk)
begin
    if (poss_c)
        dq_t <= dq_t_cmb;
end

//---------------------------------------------------------------------------------------------

//-- memory select signal ---------------------------------------------------------------------

assign s_dly = (state == idle) ? 1'b1 : 1'b0;

always @ (posedge clk)
begin
    s <= s_dly;
end

//---------------------------------------------------------------------------------------------

assign a = (div_rate <= 13'd2) ? 2'b10 : 2'b01;
assign b = (div_rate <= 13'd4) ? 2'b10 : 2'b01;

assign trigger_edge = (div_rate == 13'd4) ? poss_c : pos_c;

//---------------------------------------------------------------------------------------------

//-- initialize serial clock activation FSM ---------------------------------------------------

always @ (posedge clk)
begin
    if (reset)
        state_clk <= idle_clk;
    else
        state_clk <= next_clk;
end

//---------------------------------------------------------------------------------------------

//-- serial clock activation FSM --------------------------------------------------------------

assign activate_c = (state_clk == gen_clk) ? 1'b1 : 1'b0;

always @ *
begin
    next_clk = state_clk;
    case (state_clk)
        idle_clk:if (pos_c)
            next_clk = gen_clk;
        else
            next_clk = idle_clk;
        gen_clk:	if (s)
            next_clk = idle_clk;
        else
            next_clk = gen_clk;
    endcase
end

//---------------------------------------------------------------------------------------------

//-- clock divider ----------------------------------------------------------------------------

always @ (posedge clk)
begin
    if (reset || s || (count_c == (div_rate - 1)))
        count_c <= 14'b00000000000000;
    else
        count_c <= count_c + 14'b00000000000001;
end

//---------------------------------------------------------------------------------------------

//-- initialize FSM ---------------------------------------------------------------------------

always @ (posedge clk)
begin
    if (reset)
        state <= idle;
    else
        state <= next;
end

//---------------------------------------------------------------------------------------------

//-- main FSM ---------------------------------------------------------------------------------

always @ *
begin
    next = state;
    case (state)
        idle:			begin
            if (start_out && dummy)
                next = send_dummy;
            else if (start_out && rnw)
                next = read_data;
            else if (start_out && !rnw)
                next = send_data;
            else
                next = idle;
        end

        idle_wait:  begin
            if (poss_c)
                next = idle;
            else
                next = idle_wait;
        end

        send_dummy:	begin
            if (!start_out && done_dly)
                next = idle_wait;
            else if (start_out && rnw)
                next = read_data;
            else if (start_out && !rnw)
                next = send_data;
            else
                next = send_dummy;
        end

        send_data:	begin
            if (start_out && dummy)
                next = send_dummy;
            else if (start_out && rnw)
                next = read_data;
            else if (!start_out && done_dly)
                next = idle_wait;
            else
                next = send_data;
        end

        read_data:	begin
            if (start && dummy)
                next = send_dummy;
            else if (start && !rnw)
                next = send_data;
            else if (!start && done_dly)
                next = idle_wait;
            else
                next = read_data;
        end
    endcase
end

//---------------------------------------------------------------------------------------------

//-- shift data in from memory ----------------------------------------------------------------

always @ (posedge clk)
begin
    if ((state == read_data) && pos_c && dq_t)
    case (mode)
        2'b00:	dload_in <= {dload_in[6:0],dq_i[1]}; //-- extended
        2'b01:	dload_in <= {dload_in[6:4],dq_i[1],dload_in[2:0],dq_i[0]}; //-- dual
        2'b10:	dload_in <= {dload_in[6],dq_i[3],dload_in[4],dq_i[2],dload_in[2],dq_i[1],
        dload_in[0],dq_i[0]}; //-- quad
    endcase
end

//---------------------------------------------------------------------------------------------

//-- count dummies ----------------------------------------------------------------------------

always @ (posedge clk)
begin
    if (reset || (count_dummy == dummy_clks + 1))
        count_dummy <= 4'b0000;
    else if ((state == send_dummy) && pos_c)
        count_dummy <= count_dummy + 4'b0001;
end

//---------------------------------------------------------------------------------------------

//-- count sent items -------------------------------------------------------------------------

always @ (posedge clk)
begin
    if (start)
    case (mode)
        2'b00: count_send <= 4'b1000;
        2'b01: count_send <= 4'b0100;
        2'b10: count_send <= 4'b0010;
    endcase
    else if (reset)
        count_send <= 4'b0000;
    else if ((state == send_data) && pos_c)
        count_send <= count_send - 4'b0001;
end

//---------------------------------------------------------------------------------------------

//-- shift data out to the memory -------------------------------------------------------------

always @ (posedge clk)
begin
    if (start)
        dreg_out <= dload_out;
    else if ((state == send_data) && pos_c)
        dreg_out <= dreg_out << 1;
end

//---------------------------------------------------------------------------------------------

//-- count read items -------------------------------------------------------------------------

always @ (posedge clk)
begin
    if (start)
    case (mode)
        2'b00: count_read <= 4'b1000;
        2'b01: count_read <= 4'b0100;
        2'b10: count_read <= 4'b0010;
    endcase
    else if ((state == read_data) && pos_c && dq_t)
        count_read <= count_read - 4'b0001;
    else if (reset)
        count_read <= 4'b0000;
end

//---------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------

always @ (posedge clk)
begin
    if (done_for_dout && (state_delayed == read_data))
    case (mode)
        2'b00: 
        begin
            dout <= dload_in; //-- extended
            history_buffer <= {dload_in, history_buffer[31:8]};
        end
        2'b01: dout <= {dload_in[7], dload_in[3], dload_in[6], dload_in[2], dload_in[5], 
        dload_in[1], dload_in[4], dload_in[0]}; //-- dual
        2'b10: dout <= {dload_in[7], dload_in[5], dload_in[3], dload_in[1], dload_in[6], 
        dload_in[4], dload_in[2], dload_in[0]}; //-- quad
    endcase	
end

assign done_for_dout = (div_rate <= 13'd2) ? done_dly2 : done_dly;

//---------------------------------------------------------------------------------------------

//-- generate done control signal -------------------------------------------------------------

always @ (posedge clk)
begin
    if ((pos_c && (count_dummy == (dummy_clks - b)) && (state == send_dummy)) ||
        (trigger_edge && (count_send == a) && (state == send_data)) ||
    (pos_c && (count_read == a) && (state == read_data)))
    done <= 1'b1;
    else
        done <= 1'b0;
end

//---------------------------------------------------------------------------------------------

//-- delay state ------------------------------------------------------------------------------

always @ (posedge clk)
begin
    if (pos_c)
        state_delayed <= state;
end

//---------------------------------------------------------------------------------------------

//-- delay done signal ------------------------------------------------------------------------

always @ (posedge clk)
begin
    done_dly <= done;
    done_dly2 <= done_dly;
end

//---------------------------------------------------------------------------------------------

//-- delay dq_t -------------------------------------------------------------------------------

assign dq_t_delayed = (div_rate <= 13'd2) ? dq_t_delay2 : dq_t_delay;

always @ (posedge clk)
begin
    if (poss_c)
    begin
        dq_t_delay <= dq_t;
        dq_t_delay2 <= dq_t_delay;
    end
end

//---------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------

always @ (posedge clk)
begin
    if (reset)
    begin
        stare <= got;
        cstate <= trig_start;
    end
    else
    begin
        stare <= urm;
        cstate <= nstate;
    end
end

//---------------------------------------------------------------------------------------------

always @ *
begin
    urm = stare;
    case (stare)
        got:	if (done)
            urm = buc;
        else
            urm = got;
        buc:	if (poss_c)
            urm = sfarsit;
        else
            urm = buc;
        sfarsit:	urm = got;
    endcase
end

//---------------------------------------------------------------------------------------------

// -- Delay the start for the falling edge entry of C -----------------------------------------

always @ *
begin
    nstate = cstate;
    case (cstate)
        trig_start:	if (start_out && s)
            nstate = trig_posedge;
        else
            nstate = trig_start;
        trig_posedge:	if (pos_c)
            nstate = preend_event;
        else
            nstate = trig_posedge;
        preend_event:	nstate = trig_start;
    endcase
end

//---------------------------------------------------------------------------------------------

//-- start signal -----------------------------------------------------------------------------

assign start = (s_delayed && (div_rate <= 13'd2) && ((mode == 2'b10) || (mode == 2'b01))) ? 
start_mode2_div_rate2 : (!s) ? (signal_start | start_out) : 1'b0;

always @ (posedge clk)
begin
    s_delayed <= s;
end

//---------------------------------------------------------------------------------------------

always @ (posedge clk)
begin
    start_mode2_div_rate2_buf <= start_out;
    start_mode2_div_rate2 <= start_mode2_div_rate2_buf;
end

//---------------------------------------------------------------------------------------------

always @ (posedge clk)
begin
    if (nstate == preend_event)
        signal_start <= 1'b1;
    else
        signal_start <= 1'b0;
end

//---------------------------------------------------------------------------------------------

//-- control signal for write enable receive fifo ---------------------------------------------

always @ (posedge clk)
begin
    if (stare == sfarsit)
        done_for_wr <= 1'b1;
    else
        done_for_wr <= 1'b0;
end

//---------------------------------------------------------------------------------------------

endmodule
