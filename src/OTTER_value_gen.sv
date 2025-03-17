`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/11/2025 10:05:49 PM
// Description: 
//      Value generator module for the OTTER. Combines the immediate generator 
//      and the target generator (branch address generator) into one module.
// Dependencies: 
//      n/a
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - code is adapted from my 2022 CPE 233 OTTER
//////////////////////////////////////////////////////////////////////////////////

module OTTER_value_gen(
    input [31:0] pc, ir,
    input [31:0] reg_out,
    output logic [31:0] I_immed, U_immed, S_immed, branch_pc, jal_pc, jalr_pc
    );
    
    // Branch target generation
    assign branch_pc = pc + {{20{ir[31]}},ir[7],ir[30:25],ir[11:8],1'b0};
    // Jump and link target generation
    assign jal_pc = pc + {{12{ir[31]}},ir[19:12],ir[20],ir[30:21],1'b0};
    // Jump and link register target generation // is same as I_immed + reg_out
    assign jalr_pc = I_immed + reg_out;
    // I-type immediate value  
    assign I_immed = {{21{ir[31]}},ir[31:20]};
    // U-type immediate value  
    assign U_immed = {ir[31:12],12'b0};
    // S-type immediate value  
    assign S_immed = {{21{ir[31]}},ir[30:25],ir[11:7]};
    
endmodule
