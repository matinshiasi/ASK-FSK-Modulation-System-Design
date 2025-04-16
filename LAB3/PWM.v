module PWM(
    input clk,
    input rst,
    input [7:0] duty,
    output  pwm_out1
);
    reg [7:0] counter;
    reg pwm_out;
    assign pwm_out1= pwm_out;
    always @(posedge clk or posedge rst) begin
        if (rst) begin 
            counter <= 8'b0;
            pwm_out <= 1'b0;
        end else begin 
            counter <= counter + 1;
            if (counter < duty)
                pwm_out <= 1'b1;
            else 
                pwm_out <= 1'b0;
        end 
    end
endmodule
