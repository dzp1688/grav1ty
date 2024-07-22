`default_nettype none

import obu_parser_pkg::*;

module sequence_header_parser (
    input  logic clk,
    input  logic rst_n,

    input  logic [PARSER_DATA_WIDTH-1:0]         data_in,
    input  logic                                 avail,
    input  logic                                 start,

    output logic                                 done,
    output logic                                 data_out, // TODO: define struct for data_out

    output logic                                 pad,
    output logic [PAD_LEN_WIDTH-1:0]             pad_len,
    output logic                                 pop
);

    typedef enum integer {
        OBU_HEADER,
        WIDTH_HEIGHT_BITS,
        WIDTH,
        HEIGHT,
        FEATURE_ENABLES_COLOR_CONFIG,
        COLOR_CONFIG_FILM_GRAIN_PARAMS
    } state_t;

    state_t curr_state;
    state_t next_state;

    logic obu_header_done;
    logic obu_header_pad;
    logic obu_header_pad_len;
    logic obu_header_pop;

    logic [55:0] obu_size;

    obu_header_parser o_h_p_I (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .avail(avail),
        .start(start),
        .done(obu_header_done),
        .obu_size(obu_size),
        .pad(obu_header_pad),
        .pad_len(obu_header_pad_len),
        .pop(obu_header_pop)
    );

    always_comb begin
        unique case (curr_state)
            OBU_HEADER: begin
                next_state = (obu_header_done) ? WIDTH_HEIGHT_BITS : OBU_HEADER;
            end
            WIDTH_HEIGHT_BITS: begin
                next_state = (avail) ? WIDTH : WIDTH_HEIGHT_BITS;
            end
            WIDTH: begin
                next_state = (avail) ? HEIGHT : WIDTH;
            end
            HEIGHT: begin
                next_state = (avail) ? FEATURE_ENABLES_COLOR_CONFIG : HEIGHT;
            end
            FEATURE_ENABLES_COLOR_CONFIG: begin
                next_state = (avail) ? COLOR_CONFIG_FILM_GRAIN_PARAMS : FEATURE_ENABLES_COLOR_CONFIG;
            end
            COLOR_CONFIG_FILM_GRAIN_PARAMS: begin
                next_state = (avail) ? IDLE : FILM_GRAIN_PARAMS;
            end
            default: ;
        endcase
    end

    always_comb begin
        done = '0;
        pad = '0;
        pad_len = '0;
        pop = '0;
        unique case (curr_state)
            OBU_HEADER: begin
                pad     = obu_header_pad;
                pad_len = obu_header_pad_len;
                pop     = obu_header_pop;
            end
            WIDTH_HEIGHT_BITS: begin
                if (avail) begin
                    pad = '1;
                    pad_len = 'd14;
                end
            end
            WIDTH: begin
                if (avail) begin
                    pad = '1;
                    pad_len = 'd32 - {2'b0, data_in[3:0]};
                end
            end
            HEIGHT: begin
                if (avail) begin
                    pad = '1;
                    pad_len = 'd32 - {2'b0, data_in[3:0]};
                end
            end
            FEATURE_ENABLES_COLOR_CONFIG: begin
                pop = avail;
            end
            COLOR_CONFIG_FILM_GRAIN_PARAMS: begin
                if (avail) begin
                    done = '1;
                    pad = '1;
                    pad_len = 'd29;
                end
            end
            default: ;
        endcase
    end

    always_ff @ (posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            curr_state <= IDLE;
        end else begin
            curr_state <= next_state;
        end
    end

endmodule

