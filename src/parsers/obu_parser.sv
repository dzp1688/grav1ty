`default_nettype none

// align non constant width fields to data width
// pad both the previous and next field to ensure
// non constant field and next field are both aligned

import obu_parser_pkg::*;

module obu_parser #(
) (
    input  logic                                 clk,
    input  logic                                 rst_n,

    input  logic [PARSER_DATA_WIDTH-1:0]         data,
    input  logic                                 avail,
    input  logic                                 start,
    input  logic                                 data_valid,
    input  logic [$clog2(PARSER_DATA_WIDTH)-1:0] end_len, // ignore til the last part that isn't 32-bit complete
    output logic                                 pop // pop from fifo

    // TODO: output data to downstream units
);
    typedef enum integer {
        IDLE, 
        SEQ_HDR, 
        FRAME_HDR, 
        TILE_INFO
    } state_t;
    
    state_t curr_state;
    state_t next_state;

    logic [31:0] aligned_data;
    
    // field_aligner f_a(
    //     .data_in(data),
    //     .data_out(aligned_data)
    //     .pad_enable(pad_enable)
    //     .pad_len(pad_len)
    // );

    // seq_hdr_parser(.start, .done, .data(), .data_out())
    // frame_hdr_parser
    // tile_info_parser 

    // state machine for controlling which hdr parser to go
    always_comb begin
        unique case (curr_state)
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
