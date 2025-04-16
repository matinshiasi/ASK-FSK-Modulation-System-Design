
module frequency_divider (
    input wire clk_in,
    input wire reset,
    input wire [8:0] divisor,
    input wire load,
    output reg clk_out
);

    reg [8:0] counter;

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 9'b0;
            clk_out <= 1'b0;
        end else if (load) begin
            counter <= 9'b0;
        end else begin
            if (counter == divisor - 1) begin
                counter <= 9'b0;
                clk_out <= ~clk_out;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule