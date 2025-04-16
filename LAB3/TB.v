`timescale 1ns/1ns


module TestBench();
	wire out;
	reg FPGAclk, rst, send, mode, init;
	reg [4:0] message;
	reg [2:0] pl;

	Digital_Modulation uut(FPGAclk, rst, send, mode, init, message, pl, out);
	
	always  #5 FPGAclk = ~FPGAclk;
		
	initial begin 
	rst = 1; 
	send=1;
	FPGAclk = 0;
	#10 rst = 0;

	init = 1;
	pl = 3'b110;
	mode = 1;
	#20;
	init = 0;
	message = 5'b10101;
	#15;
	send = 0;



	#60000000;
	$stop;
	end

endmodule


module DDS_tb();
	wire [7:0] out;
	reg clk , rst;
	DDS uut( clk , rst , out);
	
	always  #5 clk = ~clk;
		
	initial begin rst = 1; clk = 0;
	#10 rst = 0;
	#100000;
	$stop;
	end

endmodule

module frequency_divider_tb;

    reg clk_in;
    reg reset;
    reg [8:0] divisor;
    reg load;
    wire clk_out;

    frequency_divider uut (
        .clk_in(clk_in),
        .reset(reset),
        .divisor(divisor),
        .load(load),
        .clk_out(clk_out)
    );

    initial begin
        clk_in = 0;
        forever #10 clk_in = ~clk_in;
    end

    initial begin
        reset = 1;
        load = 0;
        divisor = 9'd10;
        #50;

        reset = 0;
        #50;

        load = 1;
        divisor = 9'd20;
        #20;
        load = 0;
        #2000;
        $stop;
    end

endmodule

module message_process_tb();

    reg clk;
    reg rst;
    reg send;
    reg [4:0] message;

    Message_Process uut (
        .clk(clk),
        .rst(rst),
        .send(send),
        .message(message),
        .out(out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        send = 1;
        message = 5'b10101; 
        #50;

        rst = 0;
        #50;

        send = 0;

        #20;
        send = 1;
        #100000;

        $stop;
    end

endmodule
