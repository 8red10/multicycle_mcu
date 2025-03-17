`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/08/2025 07:25:29 PM 
// Description: 
//      A 2 to 1 multiplexer with a variable bit width input/output.
// Dependencies: 
//      N/A
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - code is adapted from my 2022 CPE233 version
//      - parameter input detaults to a 4 bit input/output
//      - parameter input should be the number of bits for the input/output
//////////////////////////////////////////////////////////////////////////////////


module mux221 # (parameter WIDTH = 4) (
    input [WIDTH-1:0] zero,
    input [WIDTH-1:0] one,
    input SEL,
    output logic [WIDTH-1:0] F
    );
    
    always_comb
    begin
        case(SEL)
            1'b0: F = zero;
            1'b1: F = one;
            default: F = zero;
        endcase
    end
endmodule
