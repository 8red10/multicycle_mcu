`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/10/2025 04:47:34 PM
// Description: 
//      Register file module for the OTTER. Holds 32 registers that each have 
//      32-bit width data. Allows for single input and dual output.
// Dependencies: 
//      n/a
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - code is adapted from my 2022 CPE233 version
//      - register 0 is tied to ground (all zeros)
//      - synchronous write = on clock edge
//      - asynchronous = independent of clock
//      - ternary operator format
//              (conditional statement) ? (result if true) : (result if false)
//      - necessary to initialize registers before simulation, possibly also 
//          neccessary before hardware implementation
//      - based on simulation: wd is written to the register on the falling edge 
//          of en (rf_write)
//////////////////////////////////////////////////////////////////////////////////

module OTTER_register_file(
    input [4:0] addr1, addr2, waddr,
    input [31:0] wd,
    input en,
    input clk,
    output [31:0] rs1, rs2
    );
    
    // Initializes a 32-bit width register block with 32 registers
    logic [31:0] registers [0:31];
    initial
    begin
        integer i;
        for(i = 0; i < 32; i++)
        begin
            registers[i] = 32'h0;
        end
    end
    
    // Allows synchronous write to RAM if write enabled
    always_ff @ (posedge clk)
    begin
        if (en == 1 && waddr != 0)
        begin
            registers[waddr] <= wd;
        end
    end
    
    // Allows asynchronous reads to RAM from two addresses
    assign rs1 = (addr1 != 0) ? registers[addr1] : 32'b0;
    assign rs2 = (addr2 != 0) ? registers[addr2] : 32'b0;
    
endmodule
