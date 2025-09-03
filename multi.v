`timescale 1ns/1ps

module multiplier (
    input wire clock,
    input wire reset,
    input wire [4:0] a,
    input wire [4:0] b,
    output reg [9:0] result
);
  reg [9:0] c;
  always @(*) begin
    result <= a * b;
  end
  always @(posedge clock or posedge reset) begin
    if(reset) begin
        c<=0;
    end
    else begin
        c <= result;
    end
  end
endmodule