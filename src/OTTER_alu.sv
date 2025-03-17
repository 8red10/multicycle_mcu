`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/11/2025 02:50:32 PM
// Description: 
//      Arithmetic Logic Unit (ALU) for the OTTER. Essentially executes the 
//      operations selected by the instruction
// Dependencies: 
//      n/a
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - code is adapted from my 2022 CPE233 version
//////////////////////////////////////////////////////////////////////////////////

module OTTER_alu(
    input [3:0] ALU_FUN,
    input [31:0] A, B,
    output logic [31:0] sum
    );
    
    // Initializes variable for iterating for loops
    logic [4:0] i;
    
    // Executes the selected operation
    always_comb
    begin
        case(ALU_FUN)
            4'b0000: // add 
                sum = A + B;
            4'b1000: // sub
                sum = A + (~B + 1);
            4'b0110: // bitwise or
            begin
                for (int i = 0; i < 32; i++)
                    sum[i] = A[i] | B[i];
            end
            4'b0111: // bitwise and
            begin
                for (int i = 0; i < 32; i++)
                    sum[i] = A[i] & B[i];
            end
            4'b0100: // bitwise xor
            begin
                for (int i = 0; i < 32; i++)
                    sum[i] = A[i] ^ B[i];
            end
            4'b0101: // srl = bitshift right, inserts 0
            begin
                sum = A;
                for (int i = 0; i < B[4:0]; i++)
                    sum = {1'b0, sum[31:1]};
            end
            4'b0001: // sll = bitshift left, inserts 0
            begin
                sum = A;
                for (int i = 0; i < B[4:0]; i++)
                    sum = {sum[30:0], 1'b0};
            end
            4'b1101: // sra = bitshift right, inserts MSB
            begin
                sum = A;
                for (int i = 0; i < B[4:0]; i++)
                    sum = {sum[31], sum[31:1]};
            end
            4'b0010: // slt
            begin
                if (($signed(A)) < ($signed(B))) sum = 1;
                else sum = 0;            
            end
            4'b0011: // sltu
            begin
                if (A < B) sum = 1;
                else sum = 0;
            end
            4'b1001: // pass through
            begin
                sum = A;
            end
            default
            begin
                sum = A;
            end
        endcase // case statement for ALU operation
    end // always_comb block for executing ALU operation
endmodule
