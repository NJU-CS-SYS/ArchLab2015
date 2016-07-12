`timescale 1ns / 1ps

module sim_flash();

wire [2:0] flash_state;
wire flash_cnt_begin;
reg flash_reading;
wire flash_read_done;
wire flash_s;
wire [3:0] flash_dq;
reg [23:0] flash_addr;
wire [31:0] flash_data;
reg [5:0] flash_counter;
reg read_finished;
reg clk_pipeline;
reg rst;


spi_flash sf0(
    .clk(clk_pipeline),
    .rst(~rst),
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
    .debug_state(flash_state),
    .cnt_begin(flash_cnt_begin),
    .s(flash_s),
    .c(),
    .DQ(flash_dq)
);

initial begin
    clk_pipeline = 0;
    rst = 1;
    #10;
    rst = 0;
    #10;
    rst = 1;
    flash_reading = 0;
    #10;
    flash_reading = 1;
end

always begin
    clk_pipeline = ~clk_pipeline;
    #5;
end

always @ (posedge clk_pipeline) begin
    if (rst) begin
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

wire flash_stall = flash_reading && ~read_finished;


endmodule
