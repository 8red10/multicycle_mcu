`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/11/2025 11:10:27 PM
// Description: 
//      Designed for the 4-digit seven segment display on a Basys3 board. Displays
//      a 16-bit hex value where each of the four bit portions of the value each 
//      correspond to a digit on the display. For example, the lower four bits of
//      the input hex value are output to the first (lowest) digit of the seven
//      segment display. 
//      The 4-digit seven segment display on the Basys3 board has common cathode
//      and common anode with both configured as negative logic such that 0s in 
//      cathode light up the corresponding segment for any digit with a 0 in their
//      respective place in anode.
//      Current flows from the common anode to each of the individual cathodes
//      (each of which are essentially an LED that controls a segment of the 
//      digit display), meaning that a segment will only light up if a zero is 
//      in the digit's location (anode is asserted = set low bc negative logic)
//      and a zero is asserted in the corresponding cathode.
//
//      CATHODES    = {dp,a,b,c,d,e,f,g} LSB here
//      ANODE       = {d4, d3, d2, d1}   LSB here
// Dependencies: 
//      100 MHz clock
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - adapted from Paul Hummel
//      - comments out clock divider and adds slow clock to input clock
//          connection for simulation
//////////////////////////////////////////////////////////////////////////////////

module cathode_driver(
    input CLK,
    input [15:0] HEX,
    output logic [7:0] CATHODES,
    output logic [3:0] ANODES
    );
    
    logic s_clk_500 = 1'b0;             // 250Hz refresh clock
    logic [1:0] r_disp_digit = 2'b00;   // current digit being displayed
    logic [19:0] clk_div_counter = 20'h00000;

    // Comment out the below always_ff block for simulation
    // Clock Divider to create 500 Hz refresh from 100 MHz clock
	always_ff @(posedge CLK) begin
        clk_div_counter = clk_div_counter + 1;
        
        // x186A0 = 1*10^5 = 1 ms toggle (x30D40)
        if ( clk_div_counter == 20'h186A0) begin
            clk_div_counter = 20'h00000;
            s_clk_500 = ~s_clk_500;   // toggle every 1 ms creates 500 Hz clock
        end
    end
    
    // Uncomment the below always_comb block for simulation
//    // For simulation, don't need the clock divider
//    always_comb
//    begin
//        // Connects input clock to slow clock for simulation
//        s_clk_500 = CLK;
//    end
    
    // Refresh seven segment display every 125 Hz, 1 cc per digit // 240 Hz ? idk?
    always_ff @(posedge s_clk_500) begin
        case (r_disp_digit)
            2'b00: // first (lowest) digit
            begin
                ANODES= 4'b1110;
                case (HEX[3:0])
                    4'b0000: CATHODES = 8'b10000001; //0
                    4'b0001: CATHODES = 8'b11001111; //1
                    4'b0010: CATHODES = 8'b10010010; //2
                    4'b0011: CATHODES = 8'b10000110; //3
                    4'b0100: CATHODES = 8'b11001100; //4
                    4'b0101: CATHODES = 8'b10100100; //5
                    4'b0110: CATHODES = 8'b10100000; //6
                    4'b0111: CATHODES = 8'b10001111; //7
                    4'b1000: CATHODES = 8'b10000000; //8
                    4'b1001: CATHODES = 8'b10001100; //9
                    4'b1010: CATHODES = 8'b10001000; //a
                    4'b1011: CATHODES = 8'b11100000; //b
                    4'b1100: CATHODES = 8'b10110001; //c
                    4'b1101: CATHODES = 8'b11000010; //d
                    4'b1110: CATHODES = 8'b10110000; //e
                    4'b1111: CATHODES = 8'b10111000; //f
                    default: CATHODES = 8'b11111111; // failsafe turn off
                endcase
            end
            2'b01: // second digit
            begin
                ANODES= 4'b1101;
                case (HEX[7:4])
                    4'b0000: CATHODES = 8'b10000001;
                    4'b0001: CATHODES = 8'b11001111;
                    4'b0010: CATHODES = 8'b10010010;
                    4'b0011: CATHODES = 8'b10000110;
                    4'b0100: CATHODES = 8'b11001100;
                    4'b0101: CATHODES = 8'b10100100;
                    4'b0110: CATHODES = 8'b10100000;
                    4'b0111: CATHODES = 8'b10001111;
                    4'b1000: CATHODES = 8'b10000000;
                    4'b1001: CATHODES = 8'b10001100;
                    4'b1010: CATHODES = 8'b10001000; //a
                    4'b1011: CATHODES = 8'b11100000;
                    4'b1100: CATHODES = 8'b10110001;
                    4'b1101: CATHODES = 8'b11000010;
                    4'b1110: CATHODES = 8'b10110000;
                    4'b1111: CATHODES = 8'b10111000;
                    default: CATHODES = 8'b11111111; // all off on error
                endcase
            end
            2'b10: // third digit
            begin
                ANODES= 4'b1011;
                case (HEX[11:8])
                    4'b0000: CATHODES = 8'b10000001;
                    4'b0001: CATHODES = 8'b11001111;
                    4'b0010: CATHODES = 8'b10010010;
                    4'b0011: CATHODES = 8'b10000110;
                    4'b0100: CATHODES = 8'b11001100;
                    4'b0101: CATHODES = 8'b10100100;
                    4'b0110: CATHODES = 8'b10100000;
                    4'b0111: CATHODES = 8'b10001111;
                    4'b1000: CATHODES = 8'b10000000;
                    4'b1001: CATHODES = 8'b10001100;
                    4'b1010: CATHODES = 8'b10001000; //a
                    4'b1011: CATHODES = 8'b11100000;
                    4'b1100: CATHODES = 8'b10110001;
                    4'b1101: CATHODES = 8'b11000010;
                    4'b1110: CATHODES = 8'b10110000;
                    4'b1111: CATHODES = 8'b10111000;
                    default: CATHODES = 8'b11111111; // all off on error
                endcase
            end
            2'b11: // fourth (highest) digit
            begin
                ANODES= 4'b0111;
                case (HEX[15:12])
                    4'b0000: CATHODES = 8'b10000001;
                    4'b0001: CATHODES = 8'b11001111;
                    4'b0010: CATHODES = 8'b10010010;
                    4'b0011: CATHODES = 8'b10000110;
                    4'b0100: CATHODES = 8'b11001100;
                    4'b0101: CATHODES = 8'b10100100;
                    4'b0110: CATHODES = 8'b10100000;
                    4'b0111: CATHODES = 8'b10001111;
                    4'b1000: CATHODES = 8'b10000000;
                    4'b1001: CATHODES = 8'b10001100;
                    4'b1010: CATHODES = 8'b10001000; //a
                    4'b1011: CATHODES = 8'b11100000;
                    4'b1100: CATHODES = 8'b10110001;
                    4'b1101: CATHODES = 8'b11000010;
                    4'b1110: CATHODES = 8'b10110000;
                    4'b1111: CATHODES = 8'b10111000;
                    default: CATHODES = 8'b11111111; // all off on error
                endcase
            end
            default: // digit error, turn everything off 
            begin
                ANODES = 4'hF;
                CATHODES = 8'hFF;
                r_disp_digit = 2'b00;
            end
        endcase
        // Move to the next digit, 2-bit variable wraps around on overflow
        r_disp_digit = r_disp_digit + 1;
    end // always_ff block for 500 Hz slow clock

endmodule
