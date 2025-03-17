`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/12/2025 11:28:04 AM
// Description: 
//      A FSM-based button debouncer with an integrated one-shot output. The 
//      one-shot output directly follows the successful completion of debouncing
//      the rising edge and then the falling edge of the input signal (button).
//      CLK should be a 50 MHz RAT clock. Debounced output occurs after button
//      has been released from the button press.
//      
//      Configurable parameters:
//          c_LOW_GOING_HIGH_CLOCKS = minimum # clocks for stable high input
//          c_HIGH_GOING_LOW_CLOCKS = minimum # clocks for stable low input
//          c_ONE_SHOT_CLOCKS       = length of one-shot output in clock cycles
// Dependencies: 
//      50 MHz RAT clock
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - adapted from Paul Hummel
//      - Paul Hummel adapted from Jeff Gerfen's VHDL
//////////////////////////////////////////////////////////////////////////////////

module debounce_button(
    input CLK,
    input BTN,
    output logic DB_BTN
    );
    
    // Debounce timing intervals
    const logic [7:0] c_LOW_GOING_HIGH_CLOCKS = 8'h19; // 25 clks
    const logic [7:0] c_HIGH_GOING_LOW_CLOCKS = 8'h33; // 50 clks
    const logic [7:0] c_ONE_SHOT_CLOCKS       = 8'h03; // 3 clks
    
    // State values 
    typedef enum { 
        ST_init,            // initialize FSM
        ST_BTN_low,         // wait for button press
        ST_BTN_low_to_high, // wait for high bounce to settle
        ST_BTN_high,        // wait for button release
        ST_BTN_high_to_low, // wait for low bounce to settle
        ST_one_shot         // button press complete, create output pulse
    } STATES;
    STATES NS, PS;
    
    // Debounce counting variables
    logic [7:0] s_db_count = 8'h00;
    logic s_count_rst, s_count_inc = 1'b0;
    
    // Counts number of clock cycles when enabled 
    always_ff @(posedge CLK) begin
        if (s_count_rst == 1'b1)
            s_db_count = 8'h00;
        else if (s_count_inc == 1'b1)
            s_db_count = s_db_count + 1;
    end
    
    // FSM state register 
    always_ff @(posedge CLK) begin
       PS = NS; 
    end
    
    // FSM state logic
    always_comb begin
        // Assigns default values to avoid latches
        NS = ST_init;
        DB_BTN = 1'b0;
        s_count_rst = 1'b0;
        s_count_inc = 1'b0;
        
        case (PS)
            ST_init: // initialize FSM
            begin
                NS = ST_BTN_low;    // wait for button press
                DB_BTN = 1'b0;      // initialize output low
                s_count_rst = 1'b1; // reset count
            end
            
            ST_BTN_low: // wait for button press
            begin
                if (BTN == 1'b1) // press detected
                begin
                    NS = ST_BTN_low_to_high;// wait for high bounce to settle
                    s_count_inc = 1'b1;     // start counting
                end
                else // nothing detected
                begin
                    NS = ST_BTN_low;    // wait for button press
                    s_count_rst = 1'b1; // reset count
                end
            end
            
            ST_BTN_low_to_high: // wait for high bounce to settle 
            begin
                if (BTN == 1'b1) // button is still high
                begin
                    // button stayed high for specified time
                    if (s_db_count == c_LOW_GOING_HIGH_CLOCKS)
                    begin 
                        NS = ST_BTN_high;   // wait for button release
                        s_count_rst = 1'b1; // reset count
                    end
                    else // button high, but not for long enough yet
                    begin
                        NS = ST_BTN_low_to_high;// wait for high bounce to settle
                        s_count_inc = 1'b1;     // keep counting
                    end
                end
                else // button low, so still bouncing
                begin
                    NS = ST_BTN_low;    // wait for button press (high value)
                    s_count_rst = 1'b1; // reset count
                end
            end
            
            ST_BTN_high: // wait for button release 
            begin
                if (BTN == 1'b1) // button still pressed
                begin 
                    NS = ST_BTN_high;   // wait for button release
                    s_count_rst = 1'b1; // reset count
                end
                else // button released 
                begin
                    NS = ST_BTN_high_to_low;// wait for low bounce to settle
                    s_count_inc = 1'b1;     // keep counting
                end
            end
            
            ST_BTN_high_to_low: // wait for low bounce to settle 
            begin
                if (BTN == 1'b0) // button still low
                begin
                    // button stayed low for specified time
                    if (s_db_count == c_HIGH_GOING_LOW_CLOCKS) 
                    begin 
                        NS = ST_one_shot;   // button press complete, create output
                        s_count_rst = 1'b1; // reset count
                    end
                    else // button low, but not for long enough yet
                    begin
                        NS = ST_BTN_high_to_low;// wait for low bounce to settle
                        s_count_inc = 1'b1;     // keep counting
                    end
                end
                else // button high, so sill bouncing
                begin
                    NS = ST_BTN_high;   // wait for button release
                    s_count_rst = 1'b1; // reset count
                end 
            end
            
            ST_one_shot: // button press complete, create a single output pulse
            begin
                // one shot pulse has been high for specified time
                if (s_db_count == c_ONE_SHOT_CLOCKS) 
                begin  
                    NS = ST_init;       // reset, initialize FSM
                    s_count_rst = 1'b1; // reset count
                    DB_BTN = 1'b0;      // reset output
                end
                else // output pulse incomplete
                begin
                    NS = ST_one_shot;   // continue output pulse
                    s_count_inc = 1'b1; // keep counting
                    DB_BTN = 1'b1;      // keep output high
                end
            end
            
            default: // failsafe 
            begin
                NS = ST_init;       // reset, intitialize FSM
                s_count_rst = 1'b1; // reset count
                s_count_inc = 1'b0; // stop counting
                DB_BTN = 1'b0;      // reset output
            end
        endcase // case statement for present state
    end // FSM state logic
    
endmodule
