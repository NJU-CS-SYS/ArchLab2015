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
  wire[3:0] T95;
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
  wire T96;
  wire T17;
  wire T18;
  wire T19;
  wire[22:0] T20;
  wire[22:0] T97;
  reg [21:0] ram_addr_old;
  wire[21:0] T98;
  wire[22:0] T99;
  wire[22:0] T21;
  wire[22:0] T100;
  wire[22:0] T22;
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
  wire T54;
  wire T55;
  reg [255:0] buffer;
  wire[255:0] T101;
  wire[256:0] T102;
  wire[256:0] T56;
  wire[256:0] T103;
  wire[255:0] T57;
  wire[255:0] T58;
  wire[255:0] T104;
  wire[127:0] T59;
  wire[127:0] T60;
  wire[255:0] T61;
  wire[255:0] T105;
  wire[128:0] T62;
  wire[128:0] T63;
  wire[126:0] T106;
  wire T107;
  wire[256:0] T64;
  wire[256:0] T108;
  wire[255:0] T65;
  wire[127:0] T66;
  wire[256:0] T67;
  wire[256:0] T68;
  wire[256:0] T69;
  wire[256:0] T109;
  wire[127:0] T70;
  wire[127:0] T71;
  wire[127:0] T72;
  wire[127:0] T73;
  wire[26:0] T110;
  wire[27:0] T74;
  wire[27:0] T75;
  wire[27:0] T76;
  wire[27:0] T77;
  wire[27:0] T78;
  wire[22:0] T79;
  wire[27:0] T80;
  wire[22:0] T81;
  wire[27:0] T82;
  wire[22:0] T83;
  wire[27:0] T84;
  wire[22:0] T85;
  wire T86;
  wire T87;
  wire T88;
  wire T89;
  wire T90;
  wire T91;
  wire T92;
  wire[2:0] T111;
  wire T93;
  wire T94;

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
  assign T95 = reset ? 4'h0 : T0;
  assign T0 = T54 ? 4'h0 : T1;
  assign T1 = T51 ? 4'h9 : T2;
  assign T2 = T48 ? 4'h8 : T3;
  assign T3 = T45 ? 4'h7 : T4;
  assign T4 = T42 ? 4'h6 : T5;
  assign T5 = T38 ? 4'h9 : T6;
  assign T6 = T35 ? 4'h3 : T7;
  assign T7 = T31 ? 4'h2 : T8;
  assign T8 = T29 ? 4'h1 : T9;
  assign T9 = T10 ? 4'h5 : state;
  assign T10 = T13 & T11;
  assign T11 = io_ram_en & T12;
  assign T12 = ~ io_ram_write;
  assign T13 = T27 & T14;
  assign T14 = ~ not_move;
  assign not_move = T24 | T15;
  assign T15 = T18 & T16;
  assign T16 = ram_write_old == io_ram_write;
  assign T96 = reset ? 1'h0 : T17;
  assign T17 = T54 ? io_ram_write : ram_write_old;
  assign T18 = T23 & T19;
  assign T19 = T97 == T20;
  assign T20 = io_ram_addr[25:3];
  assign T97 = {1'h0, ram_addr_old};
  assign T98 = T99[21:0];
  assign T99 = reset ? 23'h0 : T21;
  assign T21 = T54 ? T22 : T100;
  assign T100 = {1'h0, ram_addr_old};
  assign T22 = io_ram_addr[25:3];
  assign T23 = state == 4'h0;
  assign T24 = T26 & T25;
  assign T25 = io_ram_en == 1'h0;
  assign T26 = state == 4'h0;
  assign T27 = io_init_calib_complete & T28;
  assign T28 = state == 4'h0;
  assign T29 = T13 & T30;
  assign T30 = io_ram_en & io_ram_write;
  assign T31 = T33 & T32;
  assign T32 = io_mig_rdy & io_mig_wdf_rdy;
  assign T33 = io_init_calib_complete & T34;
  assign T34 = state == 4'h1;
  assign T35 = T36 & io_mig_rdy;
  assign T36 = io_init_calib_complete & T37;
  assign T37 = state == 4'h2;
  assign T38 = T40 & T39;
  assign T39 = io_mig_rdy & io_mig_wdf_rdy;
  assign T40 = io_init_calib_complete & T41;
  assign T41 = state == 4'h3;
  assign T42 = T43 & io_mig_rdy;
  assign T43 = io_init_calib_complete & T44;
  assign T44 = state == 4'h5;
  assign T45 = T46 & io_mig_data_valid;
  assign T46 = io_init_calib_complete & T47;
  assign T47 = state == 4'h6;
  assign T48 = T49 & io_mig_rdy;
  assign T49 = io_init_calib_complete & T50;
  assign T50 = state == 4'h7;
  assign T51 = T52 & io_mig_data_valid;
  assign T52 = io_init_calib_complete & T53;
  assign T53 = state == 4'h8;
  assign T54 = io_init_calib_complete & T55;
  assign T55 = state == 4'h9;
  assign io_data_to_cpu = buffer;
  assign T101 = T102[255:0];
  assign T102 = reset ? 257'h0 : T56;
  assign T56 = T51 ? T64 : T103;
  assign T103 = {1'h0, T57};
  assign T57 = T45 ? T58 : buffer;
  assign T58 = T61 | T104;
  assign T104 = {128'h0, T59};
  assign T59 = T60 << 1'h0;
  assign T60 = io_data_from_mig & 128'hffffffffffffffffffffffffffffffff;
  assign T61 = buffer & T105;
  assign T105 = {T106, T62};
  assign T62 = ~ T63;
  assign T63 = 129'hffffffffffffffffffffffffffffffff;
  assign T106 = T107 ? 127'h7fffffffffffffffffffffffffffffff : 127'h0;
  assign T107 = T62[128];
  assign T64 = T67 | T108;
  assign T108 = {1'h0, T65};
  assign T65 = T66 << 8'h80;
  assign T66 = io_data_from_mig & 128'hffffffffffffffffffffffffffffffff;
  assign T67 = T109 & T68;
  assign T68 = ~ T69;
  assign T69 = 257'hffffffffffffffffffffffffffffffff00000000000000000000000000000000;
  assign T109 = {1'h0, T57};
  assign io_data_to_mig = T70;
  assign T70 = T40 ? T73 : T71;
  assign T71 = T33 ? T72 : 128'h0;
  assign T72 = io_data_to_ram[127:0];
  assign T73 = io_data_to_ram[255:128];
  assign io_addr_to_mig = T110;
  assign T110 = T74[26:0];
  assign T74 = T49 ? T84 : T75;
  assign T75 = T43 ? T82 : T76;
  assign T76 = T40 ? T80 : T77;
  assign T77 = T33 ? T78 : 28'h0;
  assign T78 = {T79, 5'h0};
  assign T79 = io_ram_addr[25:3];
  assign T80 = {T81, 5'h10};
  assign T81 = io_ram_addr[25:3];
  assign T82 = {T83, 5'h0};
  assign T83 = io_ram_addr[25:3];
  assign T84 = {T85, 5'h10};
  assign T85 = io_ram_addr[25:3];
  assign io_app_wdf_end = T86;
  assign T86 = T40 ? 1'h1 : T33;
  assign io_app_wdf_wren = T87;
  assign T87 = T40 ? 1'h1 : T33;
  assign io_ram_rdy = T88;
  assign T88 = not_move | T89;
  assign T89 = state == 4'h9;
  assign io_app_en = T90;
  assign T90 = T49 ? 1'h1 : T91;
  assign T91 = T43 ? 1'h1 : T92;
  assign T92 = T40 ? 1'h1 : T33;
  assign io_cmd_to_mig = T111;
  assign T111 = {2'h0, T93};
  assign T93 = T40 ? 1'h0 : T94;
  assign T94 = T33 == 1'h0;

  always @(posedge clk) begin
    if(reset) begin
      state <= 4'h0;
    end else if(T54) begin
      state <= 4'h0;
    end else if(T51) begin
      state <= 4'h9;
    end else if(T48) begin
      state <= 4'h8;
    end else if(T45) begin
      state <= 4'h7;
    end else if(T42) begin
      state <= 4'h6;
    end else if(T38) begin
      state <= 4'h9;
    end else if(T35) begin
      state <= 4'h3;
    end else if(T31) begin
      state <= 4'h2;
    end else if(T29) begin
      state <= 4'h1;
    end else if(T10) begin
      state <= 4'h5;
    end
    if(reset) begin
      ram_write_old <= 1'h0;
    end else if(T54) begin
      ram_write_old <= io_ram_write;
    end
    ram_addr_old <= T98;
    buffer <= T101;
  end
endmodule

