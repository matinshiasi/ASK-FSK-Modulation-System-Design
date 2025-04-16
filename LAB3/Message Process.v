
module Message_Process (
    input clk,
    input rst,
    input send,
    input [4:0] message,
    output out
);
	reg load, shift, cntload;
	wire co1 , co2;
        reg ps, ns;
	counter10bit cnt1(clk, rst,  co1);
	counter4bit cnt2(clk, rst, cntload , co1,4'b0110, co2);
	shiftRegister9bit shr(clk , rst , shift , load , message , out);


	always @(posedge clk, posedge rst) begin
	if (rst) ps <= 0;
	else ps = ns;
	end

	always @ (posedge clk ) begin
		ns =0;
		case (ps)
			0: ns = send? 0 : 1;
			1 : ns = co2 ? 0 : 1;
	endcase
	end
	always @(posedge clk) begin 
		case(ps)
		0: begin load = 1 ; cntload = 1 ; shift = 0;end
		1:begin load = 0; cntload = 0; shift = co1;end
		endcase	
	end

endmodule


module counter10bit (
    input clk, rst,
    output co
);
    reg [9:0] address;
    assign co = (address == 10'b1111111111);
    always @(posedge clk or posedge rst) begin
        if (rst) 
            address = 10'b0;
        else
            address = address + 1;
    end
endmodule

module counter4bit (
    input clk, rst,load , cnten , input[3:0] in,
    output co
);
    reg [3:0] address;
    assign co = (address == 4'b1111);
    
    always @(posedge clk or posedge rst) begin
        if (rst) 
            address = 4'b0;
	else if (load) address = in;
        else if(cnten)
            address = address + 1;
    end
endmodule


module shiftRegister9bit (input clk, input rst, input shift , input load , input[4:0] msg, output out);
  reg [8:0] temp;
  assign out = temp[8];
  
  always @(posedge clk, posedge rst) begin
    if (rst) temp = 9'b0;
    else if (load) temp = {4'b0101, msg};
     else if (shift)
        temp = {temp[7:0] ,1'b0 };
    end
 
endmodule