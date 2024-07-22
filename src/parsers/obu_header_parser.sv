`default_nettype none

import obu_parser_pkg::*;

module obu_header_parser (
    input  logic clk,
    input  logic rst_n,

    input  logic [PARSER_DATA_WIDTH-1:0]         data_in,
    input  logic                                 avail,
    input  logic                                 start,

    output logic                                 done,
    output logic [55:0]                          obu_size, // TODO: define struct for data_out

    output logic                                 pad,
    output logic [PAD_LEN_WIDTH-1:0]             pad_len,
    output logic                                 pop
);
    logic        start;
    logic        started;
    logic        done_word;
    logic        stall;
    logic [7:0]  data_in;

    leb128_parser obu_size_parser (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .stall(stall),
        .data_in(data_in),
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
            count <= '0;
        end else if ((start || started) && !stall) begin
            count <= count + 'd1;
        end else if (done) begin
            count <= '0;
        end
    end

endmodule

