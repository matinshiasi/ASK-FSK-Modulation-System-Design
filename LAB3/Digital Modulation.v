
module Digital_Modulation(input FPGAclk, rst, send, mode, init, input [4:0]message, input [2:0] pl, output out);
	
	wire SM, F1_clk, F2_clk, clk,  pwmsel;
	wire [7:0] DDSout, pwmin;
	Message_Process MP(clk, rst, send, message, SM);
	frequency_divider F1 (FPGAclk, rst, {1'b1 , pl ,5'b0}, init, F1_clk);
	frequency_divider F2 (FPGAclk, rst, {1'b0 , pl ,5'b0}, init, F2_clk);
	assign clk = SM ? F2_clk : F1_clk;
	DDS dds(clk, rst, DDSout);
	assign pwmsel = mode || SM;
	assign pwmin = pwmsel ? DDSout : 8'd0;
	PWM pwm(clk, rst, pwmin, out);

endmodule