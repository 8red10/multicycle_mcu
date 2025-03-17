`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/12/2025 12:13:26 PM
// Description: 
//      Divides the input clock to output a slow clock. The MAX_COUNT parameter 
//      enables this module to produce a variable output clock.
//      
//      output clock = input clock / (2 * parameter);
//      sclk = clk / (2 * MAX_COUNT);
//
// Dependencies: 
//      n/a
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - code is adpated from my 2022 CPE 233 version
//////////////////////////////////////////////////////////////////////////////////

module clock_divider # (parameter MAX_COUNT = 1) (
    input clk,
    output sclk
    );
    
    // Variables for dividing the clock
    logic tmp_clk = 0;
    integer count = 0;
    
    // Updates count at every positive edge of input clock
    always_ff @ (posedge clk)
    begin
        if (count == MAX_COUNT)
        begin
            tmp_clk = ~tmp_clk;   // toggle output clock
            count = 0;      // reset count
        end
        // Always increment count to keep clock division accurate
        //  otherwise would be off by 1
        count = count + 1;
    end
    
    // Maps output, fixes an error that occured with no intermediate variable
    assign sclk = tmp_clk;
    
endmodule
