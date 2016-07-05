module DDRControlModule(input clk, input reset,
    input  io_init_calib_complete,
    input  io_mig_data_valid,
    input  io_mig_rdy,
    input  io_mig_wdf_rdy,
    input [127:0] io_data_from_mig,
    input  io_ram_en,
    input  io_ram_write,
    input [29:0] io_ram_addr,
    input [255:0] io_data_to_ram,
    output[2:0] io_cmd_to_mig,
    output io_app_en,
    output io_ram_rdy,
    output io_app_wdf_wren,
    output io_app_wdf_end,
    output[26:0] io_addr_to_mig,
    output[127:0] io_data_to_mig,
    output[255:0] io_data_to_cpu,
    output[3:0] io_state_to_cpu
);

  reg [3:0] state;
  wire[3:0] T93;
  wire[3:0] T0;
  wire[3:0] T1;
  wire[3:0] T2;
  wire[3:0] T3;
  wire[3:0] T4;
  wire[3:0] T5;
  wire[3:0] T6;
  wire[3:0] T7;
  wire[3:0] T8;
  wire[3:0] T9;
  wire T10;
  wire T11;
  wire T12;
  wire T13;
  wire T14;
  wire not_move;
  wire T15;
  wire T16;
  reg  ram_write_old;
  wire T94;
  wire T17;
  wire T18;
  wire T19;
  reg [29:0] ram_addr_old;
  wire[29:0] T95;
  wire[29:0] T20;
  wire T21;
  wire T22;
  wire T23;
  wire T24;
  wire T25;
  wire T26;
  wire T27;
  wire T28;
  wire T29;
  wire T30;
  wire T31;
  wire T32;
  wire T33;
  wire T34;
  wire T35;
  wire T36;
  wire T37;
  wire T38;
  wire T39;
  wire T40;
  wire T41;
  wire T42;
  wire T43;
  wire T44;
  wire T45;
  wire T46;
  wire T47;
  wire T48;
  wire T49;
  wire T50;
  wire T51;
  wire T52;
  wire T53;
  reg [255:0] buffer;
  wire[255:0] T96;
  wire[256:0] T97;
  wire[256:0] T54;
  wire[256:0] T98;
  wire[255:0] T55;
  wire[255:0] T56;
  wire[255:0] T99;
  wire[127:0] T57;
  wire[127:0] T58;
  wire[255:0] T59;
  wire[255:0] T100;
  wire[128:0] T60;
  wire[128:0] T61;
  wire[126:0] T101;
  wire T102;
  wire[256:0] T62;
  wire[256:0] T103;
  wire[255:0] T63;
  wire[127:0] T64;
  wire[256:0] T65;
  wire[256:0] T66;
  wire[256:0] T67;
  wire[256:0] T104;
  wire[127:0] T68;
  wire[127:0] T69;
  wire[127:0] T70;
  wire[127:0] T71;
  wire[26:0] T105;
  wire[27:0] T72;
  wire[27:0] T73;
  wire[27:0] T74;
  wire[27:0] T75;
  wire[27:0] T76;
  wire[22:0] T77;
  wire[27:0] T78;
  wire[22:0] T79;
  wire[27:0] T80;
  wire[22:0] T81;
  wire[27:0] T82;
  wire[22:0] T83;
  wire T84;
  wire T85;
  wire T86;
  wire T87;
  wire T88;
  wire T89;
  wire T90;
  wire[2:0] T106;
  wire T91;
  wire T92;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    state = {1{$random}};
    ram_write_old = {1{$random}};
    ram_addr_old = {1{$random}};
    buffer = {8{$random}};
  end
// synthesis translate_on
`endif

  assign io_state_to_cpu = state;
  assign T93 = reset ? 4'h0 : T0;
  assign T0 = T52 ? 4'h0 : T1;
  assign T1 = T49 ? 4'h9 : T2;
  assign T2 = T46 ? 4'h8 : T3;
  assign T3 = T43 ? 4'h7 : T4;
  assign T4 = T40 ? 4'h6 : T5;
  assign T5 = T36 ? 4'h9 : T6;
  assign T6 = T33 ? 4'h3 : T7;
  assign T7 = T29 ? 4'h2 : T8;
  assign T8 = T27 ? 4'h1 : T9;
  assign T9 = T10 ? 4'h5 : state;
  assign T10 = T13 & T11;
  assign T11 = io_ram_en & T12;
  assign T12 = ~ io_ram_write;
  assign T13 = T25 & T14;
  assign T14 = ~ not_move;
  assign not_move = T22 | T15;
  assign T15 = T18 & T16;
  assign T16 = ram_write_old == io_ram_write;
  assign T94 = reset ? 1'h0 : T17;
  assign T17 = T52 ? io_ram_write : ram_write_old;
  assign T18 = T21 & T19;
  assign T19 = ram_addr_old == io_ram_addr;
  assign T95 = reset ? 30'h0 : T20;
  assign T20 = T52 ? io_ram_addr : ram_addr_old;
  assign T21 = state == 4'h0;
  assign T22 = T24 & T23;
  assign T23 = io_ram_en == 1'h0;
  assign T24 = state == 4'h0;
  assign T25 = io_init_calib_complete & T26;
  assign T26 = state == 4'h0;
  assign T27 = T13 & T28;
  assign T28 = io_ram_en & io_ram_write;
  assign T29 = T31 & T30;
  assign T30 = io_mig_rdy & io_mig_wdf_rdy;
  assign T31 = io_init_calib_complete & T32;
  assign T32 = state == 4'h1;
  assign T33 = T34 & io_mig_rdy;
  assign T34 = io_init_calib_complete & T35;
  assign T35 = state == 4'h2;
  assign T36 = T38 & T37;
  assign T37 = io_mig_rdy & io_mig_wdf_rdy;
  assign T38 = io_init_calib_complete & T39;
  assign T39 = state == 4'h3;
  assign T40 = T41 & io_mig_rdy;
  assign T41 = io_init_calib_complete & T42;
  assign T42 = state == 4'h5;
  assign T43 = T44 & io_mig_data_valid;
  assign T44 = io_init_calib_complete & T45;
  assign T45 = state == 4'h6;
  assign T46 = T47 & io_mig_rdy;
  assign T47 = io_init_calib_complete & T48;
  assign T48 = state == 4'h7;
  assign T49 = T50 & io_mig_data_valid;
  assign T50 = io_init_calib_complete & T51;
  assign T51 = state == 4'h8;
  assign T52 = io_init_calib_complete & T53;
  assign T53 = state == 4'h9;
  assign io_data_to_cpu = buffer;
  assign T96 = T97[255:0];
  assign T97 = reset ? 257'h0 : T54;
  assign T54 = T49 ? T62 : T98;
  assign T98 = {1'h0, T55};
  assign T55 = T43 ? T56 : buffer;
  assign T56 = T59 | T99;
  assign T99 = {128'h0, T57};
  assign T57 = T58 << 1'h0;
  assign T58 = io_data_from_mig & 128'hffffffffffffffffffffffffffffffff;
  assign T59 = buffer & T100;
  assign T100 = {T101, T60};
  assign T60 = ~ T61;
  assign T61 = 129'hffffffffffffffffffffffffffffffff;
  assign T101 = T102 ? 127'h7fffffffffffffffffffffffffffffff : 127'h0;
  assign T102 = T60[128];
  assign T62 = T65 | T103;
  assign T103 = {1'h0, T63};
  assign T63 = T64 << 8'h80;
  assign T64 = io_data_from_mig & 128'hffffffffffffffffffffffffffffffff;
  assign T65 = T104 & T66;
  assign T66 = ~ T67;
  assign T67 = 257'hffffffffffffffffffffffffffffffff00000000000000000000000000000000;
  assign T104 = {1'h0, T55};
  assign io_data_to_mig = T68;
  assign T68 = T38 ? T71 : T69;
  assign T69 = T31 ? T70 : 128'h0;
  assign T70 = io_data_to_ram[127:0];
  assign T71 = io_data_to_ram[255:128];
  assign io_addr_to_mig = T105;
  assign T105 = T72[26:0];
  assign T72 = T47 ? T82 : T73;
  assign T73 = T41 ? T80 : T74;
  assign T74 = T38 ? T78 : T75;
  assign T75 = T31 ? T76 : 28'h0;
  assign T76 = {T77, 5'h0};
  assign T77 = io_ram_addr[25:3];
  assign T78 = {T79, 5'h10};
  assign T79 = io_ram_addr[25:3];
  assign T80 = {T81, 5'h0};
  assign T81 = io_ram_addr[25:3];
  assign T82 = {T83, 5'h10};
  assign T83 = io_ram_addr[25:3];
  assign io_app_wdf_end = T84;
  assign T84 = T38 ? 1'h1 : T31;
  assign io_app_wdf_wren = T85;
  assign T85 = T38 ? 1'h1 : T31;
  assign io_ram_rdy = T86;
  assign T86 = not_move | T87;
  assign T87 = state == 4'h9;
  assign io_app_en = T88;
  assign T88 = T47 ? 1'h1 : T89;
  assign T89 = T41 ? 1'h1 : T90;
  assign T90 = T38 ? 1'h1 : T31;
  assign io_cmd_to_mig = T106;
  assign T106 = {2'h0, T91};
  assign T91 = T38 ? 1'h0 : T92;
  assign T92 = T31 == 1'h0;

  always @(posedge clk) begin
    if(reset) begin
      state <= 4'h0;
    end else if(T52) begin
      state <= 4'h0;
    end else if(T49) begin
      state <= 4'h9;
    end else if(T46) begin
      state <= 4'h8;
    end else if(T43) begin
      state <= 4'h7;
    end else if(T40) begin
      state <= 4'h6;
    end else if(T36) begin
      state <= 4'h9;
    end else if(T33) begin
      state <= 4'h3;
    end else if(T29) begin
      state <= 4'h2;
    end else if(T27) begin
      state <= 4'h1;
    end else if(T10) begin
      state <= 4'h5;
    end
    if(reset) begin
      ram_write_old <= 1'h0;
    end else if(T52) begin
      ram_write_old <= io_ram_write;
    end
    if(reset) begin
      ram_addr_old <= 30'h0;
    end else if(T52) begin
      ram_addr_old <= io_ram_addr;
    end
    buffer <= T96;
  end
endmodule

