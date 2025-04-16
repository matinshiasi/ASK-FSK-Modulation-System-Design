`timescale 1ns/1ns

module DDS (
    input clk,
    input rst,
    output [7:0] out
);
    wire PhasePosition;
    wire Signbit;
    wire [5:0] address;

    DDSdatapath dp (Signbit, PhasePosition, address, out);
    DDScontroller cu (clk, rst, PhasePosition, Signbit, address);

endmodule


module DDSdatapath(
    input SignBit,
    input PhasePosition,
    input [5:0] address,
    output [7:0] out
);
    wire [5:0] addressComplement, ROMaddress;
    wire [7:0] Magnitude;
    wire [7:0] MagnitudeMUXout;
    wire Magnitudeselect;

    assign Magnitudeselect = ((~|(address)) & PhasePosition);
    TwosComp Complement(address, addressComplement);
    MUX6bit ROMMUX(addressComplement, address, PhasePosition, ROMaddress);
    sin_ROM ROM(ROMaddress, Magnitude);
    MUX8bit MagnitudeMUX(8'b11111111, Magnitude, Magnitudeselect, MagnitudeMUXout);
    signMagTwosComp DDSout(SignBit, MagnitudeMUXout, out);

endmodule


module DDScontroller(
    input clk,
    input rst,
    output reg PhasePosition,
    output reg Signbit,
    output [5:0] address
);
    wire co;
    reg countrst; 
    counter6bit Counter(clk, rst, address, co);

    parameter [1:0] First = 2'b00, Second = 2'b01, Third = 2'b10, Fourth = 2'b11;
    reg [1:0] ps, ns;

    always @(posedge clk or posedge rst) begin 
        ns = 2'b00;
        case (ps)
            First: ns = co ? Second : First;
            Second: ns = co ? Third : Second;
            Third: ns = co ? Fourth : Third;
            Fourth: ns = co ? First : Fourth;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin 
            ps = First; 
            ns = First; 
        end else begin 
            ps = ns;
        end
    end

    always @( posedge clk) begin
        case (ps)
            First: begin PhasePosition = 0; Signbit = 0; end
            Second: begin PhasePosition = 1; Signbit = 0; end
            Third: begin PhasePosition = 0; Signbit = 1; end
            Fourth: begin PhasePosition = 1; Signbit = 1; end
        endcase
    end
endmodule


module TwosComp(
    input [5:0] in,
    output reg [5:0] out
);
    assign out = ~in + 1;
endmodule

module MUX8bit(
    input [7:0] a, b,
    input s,
    output reg [7:0] c
);
    assign c = s ? a : b;
endmodule

module MUX6bit(
    input [5:0] a, b,
    input s,
    output reg [5:0] c
);
    assign c = s ? a : b;
endmodule

module counter6bit (
    input clk, rst,
    output reg [5:0] address,
    output co
);
    assign co = (address == 6'b111111);
    always @(posedge clk or posedge rst) begin
        if (rst) 
            address = 6'b0;
        else
            address = address + 1;
    end
endmodule

module sin_ROM (
    input [5:0] address,
    output [7:0] data
);
    reg [7:0] ROM [0:63];
    initial begin
        $readmemb("sine.mem", ROM); 
    end
    assign data = ROM[address];
endmodule

module signMagTwosComp (
    input signbit,
    input [7:0] magnitude,
    output [7:0] out
    //output [8:0] out
);
    assign out = signbit ? (~magnitude + 1) : magnitude;
    //assign out = signbit ? {1'b1, (~magnitude + 1)} : {1'b0, magnitude};
endmodule