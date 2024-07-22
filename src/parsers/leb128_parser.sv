module leb128_parser (
    input  logic clk,
    input  logic rst_n,
    input  logic        start,
    input  logic        stall,
    input  logic [7:0]  data_in,

    output logic [55:0] data_out,
    output logic        done
);

    logic [5:0] count;
    logic       started;

    assign done = started && !stall && !data_in[7];

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            count <= '0;
        end else if (start | started) begin
            count <= count + 'd7;
        end else if (done) begin
            count <= '0;
        end
    end

    always_ff @ (posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            data_out <= '0;
            started  <= '0;
        end else if (start) begin
            data_out <= {49'd0, data_in[6:0]};
            started  <= 1'b1;
        end else if (started && !stall) begin
            if (data_in[7]) begin
                data_out <= data_out | (data_in[6:0] << count);
            end else begin
                started <= 1'b0;
            end
        end
    end


endmodule

