`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/08/2025 07:46:38 PM
// Description: 
//      Program counter module for the OTTER. Does not handle interrupts.
// Dependencies: 
//      n/a
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - code is adapted from my 2022 CPE233 version
//      - commented out interrupt functionality
//////////////////////////////////////////////////////////////////////////////////

module OTTER_pc(
    input clk,
    input [31:0] jalr,
    input [31:0] jal,
    input [31:0] branch,
//    input [31:0] mtvec,
//    input [31:0] mepc,
    input [2:0] pc_source,
    input reset,
    input pc_write,
    output [31:0] count,
    output [31:0] count_4
    );
    
    // Variables for advancing the PC
    logic [31:0] pc_next;
    logic [31:0] pc;
    
    // Advances PC to desired value
    always_ff @ (posedge clk)
    begin
		if (reset == 1)
			pc = 0;
        if (pc_write == 1)
            pc <= pc_next;
    end
    
    // Selects the desired PC value
    always_comb 
    begin 
        case (pc_source)
			0: pc_next <= pc + 4;
			1: pc_next <= jalr;
			2: pc_next <= branch;
			3: pc_next <= jal;
			4: pc_next <= pc + 4; //mtvec;
			5: pc_next <= pc + 4; //mepc;
			default:
				pc_next <= pc + 4;
        endcase
    end
	
	// Outputs the desired PC values
	assign count = pc;
	assign count_4 = pc + 4;
    
endmodule
