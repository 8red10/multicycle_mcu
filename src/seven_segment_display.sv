`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/11/2025 11:35:33 PM
// Description: 
//      Display driver for the 4-digit seven segment display on a Basys3 board 
//      that has a common anode and common cathode. The 16-bit input can be 
//      displayed as a decimal or hex value depending on the mode input (0 for 
//      hex, 1 for decimal). In decimal mode, the full 16-bit range of cannot 
//      be displayed, so anything above 4 binary coded decimal digits is 
//      is truncated to fit the 4-digit decimal range. For exmaple, 12345 is 
//      truncated to 2345. Assumes input clock is 100 MHz.
// Dependencies: 
//      100 MHz clock
//      hex2bcd.sv
//          - converts hex value to binary coded decimal
//      cathode_driver.sv
//          - drives cathodes and anodes for seven segment display on Basys3
//          - depends on a 100 MHz clock
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - adapted from Paul Hummel
//////////////////////////////////////////////////////////////////////////////////


module seven_segment_display(
    input CLK,            // 100 MHz
    input MODE,           // 0 - Hex, 1 - Decimal
    input [15:0] DATA_IN,
    output [7:0] CATHODES,
    output [3:0] ANODES
    );

    // Intermediate variables for selecting between hex and bcd display values
    logic [15:0] BCD_Val;
    logic [15:0] Hex_Val;
    
    // Converts input hex values to binary coded decimal
    hex2bcd converter (.HEX(DATA_IN), .THOUSANDS(BCD_Val[15:12]),
        .HUNDREDS(BCD_Val[11:8]), .TENS(BCD_Val[7:4]), .ONES(BCD_Val[3:0]));
    
    // Displays value where each 4-bit interval corresponds to a digit
    cathode_driver driver (.HEX(Hex_Val), .CLK(CLK), .CATHODES(CATHODES),
        .ANODES(ANODES));
    
    // Selects hex or bcd as input to display driver, basically a mux
    always_comb begin
        if (MODE == 1'b1)
            Hex_Val = BCD_Val;
        else
            Hex_Val = DATA_IN;
    end
    
endmodule
