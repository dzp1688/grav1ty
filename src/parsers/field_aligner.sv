`default_nettype none

import obu_parser_pkg::*;

module field_aligner (
    input  logic                                 clk,
    input  logic                                 rst_n,

    input  logic [PARSER_DATA_WIDTH-1:0]         data_in,

    input  logic                                 pop_in,
    input  logic                                 pad,
    input  logic [$clog2(PARSER_DATA_WIDTH)-1:0] pad_len,

    output logic [PARSER_DATA_WIDTH-1:0]         data_out,
    output logic                                 pop_out
);

    logic [$clog2(PARSER_DATA_WIDTH)-1:0] buffer_pad_len_right;
    logic [$clog2(PARSER_DATA_WIDTH)-1:0] buffer_pad_len_left;
    logic [PARSER_DATA_WIDTH-1:0]         buffer;

    // TODO: might need to optimize
    assign data_out = (data_in >> buffer_pad_len_right) | (buffer << buffer_pad_len_left);

    assign pop_in = pop_out;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            buffer_pad_len  <= '0;
            buffer_pad_mask <= '0;
            buffer <= '0;
        end else begin
            if (pad) begin
                buffer_pad_len_left  <= 'd32 - pad_len;
                buffer_pad_len_right  <= pad_len;
                buffer <= data_in;
            end
            if (pop) begin
                buffer <= data_in;
            end
        end
    end
endmodule

