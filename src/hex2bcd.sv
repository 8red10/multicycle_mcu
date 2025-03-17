`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/11/2025 10:58:39 PM
// Description: 
//      Converts a 16-bit number to a 4-digit binary coded decimal. The full
//      16-bit range cannot be converted to a 4-digit binary coded decimal, so
//      anything above 4 binary coded decimal digits is truncated. For example,
//      12345 is truncated to 2345.
// Dependencies: 
//      n/a
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - adapted from Paul Hummel
//////////////////////////////////////////////////////////////////////////////////

module hex2bcd(
    input [15:0] HEX,
    output logic [3:0] THOUSANDS,
    output logic [3:0] HUNDREDS,
    output logic [3:0] TENS,
    output logic [3:0] ONES
    );
    
    int i;
    
    /*
    logic block to convert binary to 4 digit BCD (0000 - 1001)
    start with MSB and shift each bit left to fit into each place value.
    THOUSANDS, HUNDREDS, TENS, and ONES.
    
    Each shift left is the equivalent of x 2, so if current value is 5 or
    greater, the next shift should increment the next place value.
    By adding 3 to the current place value will set this to occur on the
    next shift. See 2 examples below
            
    5 will shift a 1 to next place value and put 0 in the current place value
    to create 10 (5 x 2)
    0101 -> 1000 -> shift -> xxx1 000x
               
    7 will shift a 1 to the next place value and put 4 in current place value
    to create 14 (7 x 2)
    0111 -> 1010 -> shift -> xxx1 010x
    */
    
    always_comb begin
        THOUSANDS = 4'h0; // default all digits to 0
        HUNDREDS = 4'h0;
        TENS = 4'h0;
        ONES = 4'h0;
        
        // iterate through each bit, starting with MSB (bit 15)
        for (i=15; i>=0; i=i-1) begin
            
            // check for place values of 5 or greater
            if (THOUSANDS >= 5)
                THOUSANDS = THOUSANDS + 3;
            if (HUNDREDS >= 5)
                HUNDREDS = HUNDREDS + 3;
            if (TENS >= 5)
                TENS = TENS + 3;
            if (ONES >= 5)
                ONES = ONES + 3;
            
            // shift bits to the left
            THOUSANDS = {THOUSANDS[2:0],HUNDREDS[3]};
            HUNDREDS = {HUNDREDS[2:0],TENS[3]};
            TENS = {TENS[2:0],ONES[3]};
            ONES = {ONES[2:0],HEX[i]};
       end
   end
      
endmodule
