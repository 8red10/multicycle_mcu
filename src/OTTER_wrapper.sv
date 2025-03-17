`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/12/2025 10:07:36 PM
// Description: 
//      Wrapper module for the OTTER to help interface the MCU with IO via MMIO.
//      For a multicycle OTTER MCU that can execute RISC-V 32-bit assembly code.
//      
// Dependencies: 
//      100 MHz clock
//      clock_divider.sv
//          - divides input clock by 2 * parameter input
//      OTTER_mcu.sv
//          - OTTER microcontroller module that handles RISC-V 32-bit instructions
//          - can also interface with MMIO as long as addresses are consistent
//              with addresses
//      seven_segment_display.sv
//          - display driver for the 4-digit seven segment display
//          - is designed for a 100 MHz clock input (for digit persistence) but 
//              can be changed for other clock frequencies
//      debounce_button.sv
//          - debounces the input button and outputs a stable pulse after the 
//              button press is released
//          - designed for a 50 MHz clock input for the debounce waiting states
//              but can be changed for other clock frequencies
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - adapted from my 2022 CPE 233 version
//      - originally adapted from Paul Hummel and Joseph Callenes
//////////////////////////////////////////////////////////////////////////////////

module OTTER_wrapper(
    input CLK,
    input BTNC,
    input logic [15:0] SWITCHES,
    output logic [15:0] LEDS,
    output [7:0] CATHODES,
    output [3:0] ANODES
    );
    
    // Input port IDs - keep MMIO addresses consistent with assembly code
    localparam SWITCHES_ADDR    = 32'h11000000;
    
    // Output port IDs - keep MMIO addresses consistent with assembly code
    localparam LEDS_ADDR        = 32'h11080000;
    localparam SSEG_ADDR        = 32'h110C0000;
    
    // MCU to wrapper connections
    logic sclk, mcu_reset;
    logic [15:0] SSEG;
    logic [31:0] IOBUS_out, IOBUS_in, IOBUS_addr;
    logic IOBUS_wr;
    
    // Clock divider module to divide input clock from 100 MHz to 50 MHz
    clock_divider # (1) mcu_clock_div ( .clk(CLK), .sclk(sclk) );
    
    // OTTER MCU module
    OTTER_mcu mcu ( .CLK(sclk), .RST(mcu_reset), .IOBUS_IN(IOBUS_in),
        .IOBUS_OUT(IOBUS_out), .IOBUS_ADDR(IOBUS_addr), .IOBUS_WR(IOBUS_wr) );
    
    // Seven segment display module
    seven_segment_display sseg_disp ( .CLK(CLK), .MODE(1'b1), .DATA_IN(SSEG),
        .CATHODES(CATHODES), .ANODES(ANODES));
    
    // Button debounce module for MCU reset button
    debounce_button db_mcu_reset ( .CLK(sclk), .BTN(BTNC), .DB_BTN(mcu_reset) );
    // As an alternative to the above, do the below:
    // assign mcu_reset = BTNC;
    
    // Connects MMIO outputs (board output peripherals) to MCU IOBUS
    always_ff @ (posedge sclk)
    begin
        if(IOBUS_wr) // I/O write enabled
        begin
            case(IOBUS_addr) // assigns data to desired output peripheral
                LEDS_ADDR:  LEDS    <= IOBUS_out[15:0];    
                SSEG_ADDR:  SSEG    <= IOBUS_out[15:0];
            endcase
        end
    end
    
    // Connects MMIO inputs (board input peripherals) to MCU IOBUS
    always_comb
    begin
        IOBUS_in = 32'b0; // should this be here ? yes b/c want to reset between inputs
        case(IOBUS_addr)
            SWITCHES_ADDR:  IOBUS_in[15:0]  = SWITCHES;
            default:        IOBUS_in        = 32'b0;
        endcase
    end
    
endmodule
