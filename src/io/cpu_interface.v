`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/15 21:16:02
// Design Name: 
// Module Name: cpu_interface
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
// 0~128MB: main memory
// 0xc000000~ : vmem (Block RAM)
// 0xd000000~ : clock
// 0xe000000~ : keyboard
//////////////////////////////////////////////////////////////////////////////////

module cpu_interface(
    // ps2 interfaces
    input ps2_clk,
    input ps2_data,
    output kb_ready,
    output kb_overflow,

    // ddr Inouts
    inout [15:0] ddr2_dq,
    inout [1:0] ddr2_dqs_n,
    inout [1:0] ddr2_dqs_p,

    input rst,
    input [29:0] instr_addr,
    input dmem_read_in,
    input dmem_write_in,
    input [29:0] dmem_addr,
    input [31:0] data_from_reg,
    input [3:0] dmem_byte_w_en,
    input clk_to_ddr_pass,
    input clk_to_pixel_pass,
    input clk_pipeline,

    output ui_clk_from_ddr,
    (* mark_debug = "true" *) output reg [31:0] instr_data_out,
    (* mark_debug = "true" *) output reg [31:0] dmem_data_out,
    output mem_stall,

    // ddr Outputs
    output [12:0] ddr2_addr,
    output [2:0] ddr2_ba,
    output ddr2_ras_n,
    output ddr2_cas_n,
    output ddr2_we_n,
    output [0:0] ddr2_ck_p,
    output [0:0] ddr2_ck_n,
    output [0:0] ddr2_cke,
    output [0:0] ddr2_cs_n,
    output [1:0] ddr2_dm,
    output [0:0] ddr2_odt,

    //debug:
    output [127:0] data_to_mig,
    output [255:0] buffer_of_ddrctrl,
    output [26:0] addr_to_mig,
    output cache_stall,
    output reg trap_stall,
    output [31:0] dbg_que_low,

    // VGA outputs
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS,

    //flash i/o:
    output [5:0] flash_state,
    output flash_initiating,
    output reg flash_reading,
    output flash_read_done,
    output flash_s,
    output flash_c,
    inout [3:0] flash_dq
);

localparam VMEM_START   = 32'hc0000000;
localparam TIMER_START  = 32'hd0000000;
localparam KBD_START    = 32'he0000000;
localparam LOADER_START = 32'hf0000000;

wire ram_rdy;
wire ram_en;
wire ram_write;
wire [29:0] ram_addr;
wire [255:0] block_from_dc_to_ram;

wire [31:0] dc_data_out;
wire [31:0] ic_data_out;
wire [31:0] loader_instr;
wire [31:0] loader_data;
reg [29:0] ic_addr;

reg ic_read_in, dc_read_in, dc_write_in;
reg [3:0] loader_wen;  // accessing loader mapping area & writing request

// debug variables
wire [127:0] data_from_mig;

wire [2:0] cache_status;
wire [2:0] cache_counter;
wire mig_rdy;
wire mig_wdf_rdy;
wire mig_ddr_inited;
wire mig_data_end;
wire mig_data_valid;
wire mig_en;
wire mig_wren;

reg [127:0] debug_queue [63:0];
reg [5:0] dbg_que_start;
reg [5:0] dbg_que_end;
reg dbg_status;
wire [6:0] miss_count;
wire [4:0] ddr_ctrl_status;
wire [255:0] wb_buffer;
reg [255:0] wb_buffer_local;

assign miss_count = 0;

wire [127:0] que_input = {
    /*
    data_to_mig[63:32],
    data_from_mig[63:32],
    */
    data_to_mig[31:0],
    data_from_mig[31:0],

    5'd0,
    addr_to_mig,

    cache_status,
    cache_counter,
    mig_rdy,
    mig_wdf_rdy,
    mig_ddr_inited,
    mig_data_end,
    mig_data_valid,
    mig_en,
    mig_wren,
    miss_count,
    ddr_ctrl_status[3:0],
    8'd0
};

assign dbg_que_low = que_input[31:0];

reg loader_en;
// reg loaded;

//==-----------------------------------==
// Internal keyboard signal definitions.
//==-----------------------------------==

// Combinational logic to indicate whether the core is accessing
// the keyboard queue. High if is accessing, while low not.
reg kb_cpu_read;

// Get the 8 bits keyboard scancode. It will be filled to 32 bits
// word with leading zeros as the output.
wire [7:0] kb_keycode;

//==----------------------------------==
// VGA Definitions
//==----------------------------------==
reg vga_wen;
reg scroll_req;  // indicate the scroll request from cpu.
reg [14:0] vga_addr; // 2**15 is enough for vga mem
reg [7:0] char_to_vga;

wire vga_fifo_full, vga_fifo_empty, vga_fifo_valid;
wire [23:0] vga_request_in = { scroll_req, vga_addr, char_to_vga };

wire [23:0] vga_request_out;
wire        scroll_from_fifo    = vga_request_out[23] & vga_fifo_valid;
wire [14:0] char_addr_from_fifo = vga_request_out[22-:15];
wire [7:0]  char_from_fifo      = vga_request_out[0+:8];

vga_request_fifo vga_fifo (
    .full   ( vga_fifo_full     ),
    .din    ( vga_request_in    ),
    .wr_en  ( vga_wen           ),
    .empty  ( vga_fifo_empty    ),
    .valid  ( vga_fifo_valid    ),
    .dout   ( vga_request_out   ),
    .rd_en  ( 1                 ),
    .wr_clk ( ~clk_pipeline     ),
    .rd_clk ( clk_to_pixel_pass )
);

vga #(
    .DATA_ADDR_WIDTH( 15 ),

    // 108.0 MHz
    .h_pol          ( 1  ),
    .v_pol          ( 1  ),
    .h_disp         (1280),
    .h_front        ( 48 ),
    .h_sync         (112 ),
    .h_back         (248 ),
    .v_disp         (1024),
    .v_front        ( 1  ),
    .v_sync         ( 3  ),
    .v_back         ( 38 )

    /*
    .h_pol          ( 0  ),
    .v_pol          ( 1  ),
    .h_disp         (1680),
    .h_front        (104 ),
    .h_sync         (184 ),
    .h_back         (288 ),
    .v_disp         (1050),
    .v_front        ( 1  ),
    .v_sync         ( 3  ),
    .v_back         ( 33 )
    */
) vga0 (
    .RESET      ( rst                 ),
    .DATA_ADDR  ( char_addr_from_fifo ),
    .DATA_IN    ( char_from_fifo      ),
    .scroll     ( scroll_from_fifo    ),
    .WR_EN      ( vga_fifo_valid      ),
    .pixel_clk  ( clk_to_pixel_pass   ),
    .VGA_R      ( VGA_R               ),
    .VGA_G      ( VGA_G               ),
    .VGA_B      ( VGA_B               ),
    .VGA_HS     ( VGA_HS              ),
    .VGA_VS     ( VGA_VS              )
);

reg [23:0] flash_addr;
wire [31:0] flash_data;
reg [5:0] flash_counter;
reg read_finished;

spi_flash sf0(
    .clk(clk_pipeline),
    .rst(0),
    .send_dummy(1'b0),
    .spi_mode(2'b00),
    .read_or_write_sel(1'b1), // read
    .addr_in(flash_addr),
    .button(flash_reading), // posedge to evoke a read
    .read_done(flash_read_done),
    .write_done(),
    .EOS(),
    .dout2(),
    .word(flash_data),
    .debug_state(),
    .cnt_begin(flash_cnt_begin),
    .flash_initiating(flash_initiating),
    .state(flash_state),
    .s(flash_s),
    .c(flash_c),
    .DQ(flash_dq)
);

always @ (posedge clk_pipeline) begin
    if (!rst) begin
        flash_counter <= 5'd31;
        read_finished <= 1'b0;
    end
    else if (flash_reading) begin
        if (flash_reading && flash_counter == 5'd31) begin
            flash_counter <= 5'd0;
            read_finished <= 1'b0;
        end
        else if (flash_counter > 5'd10) begin
            if (flash_read_done) begin
                read_finished <= 1'b1;
                flash_counter <= 5'd31;
            end
        end
        else begin
            flash_counter <= flash_counter + 5'd1;
        end
    end
    else begin
        read_finished <= 0;
    end
end

wire flash_stall = (flash_reading && ~read_finished) || flash_initiating;
reg [3:0] dc_wen;

always @ (*) begin
    // data R/W redirect
    // default value, which have the least effects on the memory system.
    ic_read_in    = 1;
    dc_read_in    = 0;
    dc_write_in   = 0;
    dmem_data_out = 0;
    loader_wen    = 0;
    loader_en     = 0;
    trap_stall    = 0;
    kb_cpu_read   = 0;
    flash_addr = 0;
    flash_reading = 1'b0;
    dc_wen        = 0;
    scroll_req    = 0;
    vga_wen       = 0;

    if (dmem_addr[29:26] == 4'hb) begin
        if (dmem_read_in) begin
            flash_reading = 1'b1;
            dmem_data_out = flash_data;
            flash_addr = {dmem_addr[21:0], 2'b00};
        end
    end
    else if (dmem_addr[29:26] == 4'hc) begin // VMEM
        vga_wen = dmem_write_in;
        if (dmem_addr[25-:4] == 4'hf) begin
            scroll_req = dmem_write_in;
        end
    end
    else if (dmem_addr[29:26] == 4'hd) begin // timer
        // TODO dmem_data_out = timer_data
        // now use 0xdxxx to trap!
        if (dmem_addr[25:18] == 8'hdd) begin
            trap_stall = dmem_read_in | dmem_write_in;
        end
        else begin
            if (dmem_addr[25:0] == 26'h3000001) begin
                dmem_data_out = {26'd0, dbg_que_start};
            end
            else if (dmem_addr[25:0] == 26'h3000002) begin
                dmem_data_out = {26'd0, dbg_que_end};
            end
            else if (dmem_addr[25:18] == 8'hb0)begin
                case(dmem_addr[2:0])
                    0: dmem_data_out = buffer_of_ddrctrl[0*32 + 31 : 0*32];
                    1: dmem_data_out = buffer_of_ddrctrl[1*32 + 31 : 1*32];
                    2: dmem_data_out = buffer_of_ddrctrl[2*32 + 31 : 2*32];
                    3: dmem_data_out = buffer_of_ddrctrl[3*32 + 31 : 3*32];
                    4: dmem_data_out = buffer_of_ddrctrl[4*32 + 31 : 4*32];
                    5: dmem_data_out = buffer_of_ddrctrl[5*32 + 31 : 5*32];
                    6: dmem_data_out = buffer_of_ddrctrl[6*32 + 31 : 6*32];
                    7: dmem_data_out = buffer_of_ddrctrl[7*32 + 31 : 7*32];
                endcase
            end
            else if (dmem_addr[25:18] == 8'hb1)begin
                case(dmem_addr[2:0])
                    0: dmem_data_out = wb_buffer[0*32 + 31 : 0*32];
                    1: dmem_data_out = wb_buffer[1*32 + 31 : 1*32];
                    2: dmem_data_out = wb_buffer[2*32 + 31 : 2*32];
                    3: dmem_data_out = wb_buffer[3*32 + 31 : 3*32];
                    4: dmem_data_out = wb_buffer[4*32 + 31 : 4*32];
                    5: dmem_data_out = wb_buffer[5*32 + 31 : 5*32];
                    6: dmem_data_out = wb_buffer[6*32 + 31 : 6*32];
                    7: dmem_data_out = wb_buffer[7*32 + 31 : 7*32];
                endcase
            end
            else if (dmem_addr[25:18] == 8'hb2)begin
                case(dmem_addr[2:0])
                    0: dmem_data_out = wb_buffer_local[0*32 + 31 : 0*32];
                    1: dmem_data_out = wb_buffer_local[1*32 + 31 : 1*32];
                    2: dmem_data_out = wb_buffer_local[2*32 + 31 : 2*32];
                    3: dmem_data_out = wb_buffer_local[3*32 + 31 : 3*32];
                    4: dmem_data_out = wb_buffer_local[4*32 + 31 : 4*32];
                    5: dmem_data_out = wb_buffer_local[5*32 + 31 : 5*32];
                    6: dmem_data_out = wb_buffer_local[6*32 + 31 : 6*32];
                    7: dmem_data_out = wb_buffer_local[7*32 + 31 : 7*32];
                endcase
            end
            else begin
                if (dmem_addr[1:0] == 0) begin
                    dmem_data_out = debug_queue[dmem_addr[7:2]][31:0];
                end
                else if (dmem_addr[1:0] == 1) begin
                    dmem_data_out = debug_queue[dmem_addr[7:2]][63:32];
                end
                else if (dmem_addr[1:0] == 2) begin
                    dmem_data_out = debug_queue[dmem_addr[7:2]][95:64];
                end
                else begin
                    dmem_data_out = debug_queue[dmem_addr[7:2]][127:96];
                end
            end
        end
    end
    else if (dmem_addr[29:26] == 4'he) begin //keyborad
        kb_cpu_read = dmem_read_in;
        dmem_data_out = { 24'd0, kb_keycode };
    end
    else if (dmem_addr[29:26] == 4'hf) begin  // loader
        loader_en = 1;
        if (dmem_write_in) begin
            // TODO add short byte enable
            case (dmem_byte_w_en)
                4'b0001: loader_wen = 4'b1000;
                4'b0010: loader_wen = 4'b0100;
                4'b0100: loader_wen = 4'b0010;
                4'b1000: loader_wen = 4'b0001;
                4'b0011: loader_wen = 4'b1100;
                4'b1100: loader_wen = 4'b0011;
                default: loader_wen = 4'b1111;
            endcase
        end
        else loader_wen = 4'b0000;
        dmem_data_out = loader_data;
    end
    else begin  // data cache
        dc_read_in    = dmem_read_in;
        dc_write_in   = dmem_write_in;
        dmem_data_out = dc_data_out;
        case (dmem_byte_w_en)
            4'b0001: dc_wen = 4'b1000;
            4'b0010: dc_wen = 4'b0100;
            4'b0100: dc_wen = 4'b0010;
            4'b1000: dc_wen = 4'b0001;
            4'b0011: dc_wen = 4'b1100;
            4'b1100: dc_wen = 4'b0011;
            default: dc_wen = 4'b1111;
        endcase
    end

    // instruction fetch redirect
    ic_addr = instr_addr;
    instr_data_out = ic_data_out;
    if (instr_addr[29:26] == 4'hf) begin
        loader_en = 1;
        ic_read_in = 0;
        instr_data_out = loader_instr;
    end

    // vga ddr calculate

    vga_addr[14:2] = dmem_addr[12:0]; //dmem_addr is four byte aligned
    case(dmem_byte_w_en)
        4'b1000: begin
            vga_addr[1:0] = 2'd0;
            char_to_vga = data_from_reg[7:0];
        end
        4'b0100: begin
            vga_addr[1:0] = 2'd1;
            char_to_vga = data_from_reg[15:8];
        end
        4'b0010: begin
            vga_addr[1:0] = 2'd2;
            char_to_vga = data_from_reg[23:16];
        end
        4'b0001: begin
            vga_addr[1:0] = 2'd3;
            char_to_vga = data_from_reg[31:24];
        end
        default: begin // remove latch, but should never be encountered
            vga_addr[1:0] = 2'd3;
            char_to_vga = data_from_reg[31:24];
        end
    endcase
end

cache_manage_unit u_cm_0 (
    .clk             ( clk_pipeline         ),
    .rst             ( ~rst                 ), // !! make rst seem low active
    .ic_read_in      ( ic_read_in           ),
    .dc_read_in      ( dc_read_in           ),
    .dc_write_in     ( dc_write_in          ),
    .dc_byte_w_en_in ( dc_wen               ),
    .ic_addr         ( ic_addr              ),
    .dc_addr         ( dmem_addr            ),
    .data_from_reg   ( data_from_reg        ),

    .ram_ready       ( ram_rdy              ),
    .block_from_ram  ( buffer_of_ddrctrl    ),

    .mem_stall       ( cache_stall          ),
    .dc_data_out     ( dc_data_out          ),
    .ic_data_out     ( ic_data_out          ),

    .status          ( cache_status         ),
    .counter         ( cache_counter        ),
    .ram_en_out      ( ram_en               ),
    .ram_write_out   ( ram_write            ),
    .ram_addr_out    ( ram_addr             ),
    .dc_data_wb      ( block_from_dc_to_ram )
);

ddr_ctrl ddr_ctrl_0(

    // Inouts
    .ddr2_dq             ( ddr2_dq              ),
    .ddr2_dqs_n          ( ddr2_dqs_n           ),
    .ddr2_dqs_p          ( ddr2_dqs_p           ),
    // original signals
    .clk_from_ip         ( clk_to_ddr_pass      ),
    .clk_ci              ( clk_pipeline         ),
    .rst                 ( rst                  ),
    .ram_en              ( ram_en               ),
    .ram_write           ( ram_write            ),
    .ram_addr            ( ram_addr[29:0]       ),
    .data_to_ram         ( block_from_dc_to_ram ),
    .ram_rdy             ( ram_rdy              ),
    .ui_clk              ( ui_clk_from_ddr      ),
    // Outputs
    .ddr2_addr           ( ddr2_addr            ),
    .ddr2_ba             ( ddr2_ba              ),
    .ddr2_ras_n          ( ddr2_ras_n           ),
    .ddr2_cas_n          ( ddr2_cas_n           ),
    .ddr2_we_n           ( ddr2_we_n            ),
    .ddr2_ck_p           ( ddr2_ck_p            ),
    .ddr2_ck_n           ( ddr2_ck_n            ),
    .ddr2_cke            ( ddr2_cke             ),
    .ddr2_cs_n           ( ddr2_cs_n            ),
    .ddr2_dm             ( ddr2_dm              ),
    .ddr2_odt            ( ddr2_odt             ),
    // debug ports
    .go                  ( go                   ),
    .data_to_mig         ( data_to_mig          ),
    .data_from_mig       ( data_from_mig        ),
    .buffer              ( buffer_of_ddrctrl    ),
    .wb_buffer           ( wb_buffer            ),
    .addr_to_mig         ( addr_to_mig          ),
    .mig_rdy             ( mig_rdy              ),
    .mig_wdf_rdy         ( mig_wdf_rdy          ),
    .init_calib_complete ( mig_ddr_inited       ),
    .mig_data_end        ( mig_data_end         ),
    .mig_data_valid      ( mig_data_valid       ),
    .app_en              ( mig_en               ),
    .app_wdf_wren        ( mig_wren             ),
    .ddr_ctrl_status     ( ddr_ctrl_status      )
);


loader_mem loader (         // use dual port Block RAM
    // Data port
    .addra ( dmem_addr[12:0]    ),
    .dina  ( data_from_reg      ),
    .douta ( loader_data        ),
    .clka  ( clk_pipeline       ),
    .wea   ( loader_wen         ),
    // Instr port (read-only)
    .addrb ( instr_addr[12:0]   ), // lower 28 bits of initial address
                                   // must start at 0
    .dinb  ( 0                  ), // not used
    .doutb ( loader_instr       ),
    .clkb  ( clk_pipeline       ),
    .web   ( 0                  )  // not used
);

initial begin
    dbg_status <= 0;
    dbg_que_start <= 0;
    dbg_que_end <= 0;
end

always @ (negedge clk_pipeline) begin
    if (!rst) begin
        dbg_status <= 0;
        dbg_que_start <= 0;
        dbg_que_end <= 0;
        wb_buffer_local <= 0;
    end
    else begin
        if (!cache_stall) begin
            dbg_status <= 0; // update start only if status = 0
        end
        else begin
            if (!dbg_status) begin
                dbg_status <= 1;
                dbg_que_start <= dbg_que_end;
            end
            debug_queue[dbg_que_end] <= que_input;
            dbg_que_end <= dbg_que_end + 1;  //warning: always overwrite the last line
            // of last record!!
        end
        if (ram_en && ram_write) begin
            wb_buffer_local <= block_from_dc_to_ram;
        end
    end
end

Keyboard kb (
    .clk      ( clk_pipeline ),
    .clrn     ( rst          ),
    .ps2_clk  ( ps2_clk      ),
    .ps2_data ( ps2_data     ),
    .cpu_read ( kb_cpu_read  ),
    .ready    ( kb_ready     ),
    .overflow ( kb_overflow  ),
    .keycode  ( kb_keycode   )
);

//////////////////////////////
//
// NEMU INTERFACE
//
//////////////////////////////
nemu_interface nemu (
    .clk  ( clk_pipeline  ),
    .addr ( dmem_addr     ),
    .data ( data_from_reg ),
    .not_used ( not_used  )
);

assign mem_stall = cache_stall
| (vga_wen & vga_fifo_full)
| (kb_cpu_read & ~kb_ready)
| trap_stall
| flash_stall;

endmodule
