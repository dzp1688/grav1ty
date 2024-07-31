`default_nettype none

import obu_parser_pkg::*;

module obu_header_parser (
    input  logic clk,
    input  logic rst_n,

    input  logic [PARSER_DATA_WIDTH-1:0]         data_in,
    input  logic                                 avail,
    input  logic                                 start,

    output logic                                 done,
    output logic [55:0]                          obu_size,

    output logic                                 pad,
    output logic [PAD_LEN_WIDTH-1:0]             pad_len,
    output logic                                 pop
);
    logic started;
    logic done_word;
    logic stall;
    logic pop_buf;

    logic [7:0]  obu_size_data_in;
    logic [23:0] obu_size_data_in_buf;

    leb128_parser obu_size_parser (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .stall(stall),
        .data_in(obu_size_data_in),
        .data_out(obu_size),
        .done(done) // directly hooked to done since this is the last thing in the header
    );
    // 8 bits + var length leb

    assign done_word = (count == 'd2 || count == 'd6);
    assign pop = done_word && avail;
    assign stall = done_word && !avail;
    assign pad = !pop && done;
    assign pad_len = 'd32 - {count[1:0], 3'd0} + 'd8;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            started <= '0;
        end else if (start) begin
            started <= '1;
        end else if (done) begin
            started <= '0;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            pop_buf <= '0;
        end else begin
            pop_buf <= pop;
        end
    end

    always_comb begin
        if (start) begin
            obu_size_data_in = data_in[15:8];
        end else if (started && pop_buf) begin
            obu_size_data_in = data_in[7:0];
        end else begin
            obu_size_data_in = obu_size_data_in_buf[7:0];
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            obu_size_data_in <= '0;
            obu_size_data_in_buf <= '0;
        end else if (start) begin
            obu_size_data_in_buf <= {'0, data_in[31:16]};
        end else if (started && pop_buf)
            obu_size_data_in_buf <= data_in[23:8];
        else if (started) begin
            obu_size_data_in_buf <= {'0, obu_size_data_in_buf[23:8]};
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else if ((start || started) && !stall) begin
            count <= count + 'd1;
        end else if (done) begin
            count <= '0;
        end
    end

endmodule
