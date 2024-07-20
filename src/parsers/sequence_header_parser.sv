`default_nettype 

module sequence_header_parser (
    input  logic clk,
    input  logic rst_n,

    input  logic [PARSER_DATA_WIDTH-1:0]         data_in,
    input  logic                                 start,

    output logic                                 done,
    output logic                                 data_out // TODO: define struct for data_out
    output logic                                 pad, 
    output logic [$clog2(PARSER_DATA_WIDTH)-1:0] pad_len
    output logic                                 pop
)

endmodule