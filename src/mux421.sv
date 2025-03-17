`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/08/2025 06:59:23 PM
// Description: 
//      A 4 to 1 multiplexer with variable bit width input/output.
// Dependencies: 
//      N/A
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - code is adapted from my 2022 CPE233 version
//      - parameter input detaults to a 4 bit input/output
//      - parameter input should be the number of bits for the input/output
//////////////////////////////////////////////////////////////////////////////////


module mux421 # (parameter WIDTH = 4) (
    input [WIDTH-1:0] zero,
    input [WIDTH-1:0] one,
    input [WIDTH-1:0] two,
    input [WIDTH-1:0] three,
    input [1:0] SEL,
    output logic [WIDTH-1:0] F
    );
    
    always_comb
    begin
        case(SEL)
            2'b00: F = zero;
            2'b01: F = one;
            2'b10: F = two;
            2'b11: F = three;
            default: F = zero;
        endcase
    end
endmodule