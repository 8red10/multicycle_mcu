`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/10/2025 04:58:06 PM
// Description: 
//      Control unit FSM for the OTTER. Handles outputs for each state of FSM.
// Dependencies: 
//      n/a
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - code is adapted from my 2022 CPE233 version
//      - commented out interrupt functionality
//      - cannot combine an initial block with an always_comb block because 
//          always_comb block does stuff during the same time that the initial
//          block executes its code
//      - trying to change where pc_write is set high to solve the load problem, 
//          from beginning of decode to - worked
//      - changed where pc_write set high, must be set high at the same time 
//          next state is set to INST_FETCH, so changed location from the 
//          beginning of decode state (would cause errors where a load inst
//          would enable a double pc_write) to all locations there is a 
//          ns = INST_FETCH
//////////////////////////////////////////////////////////////////////////////////

module OTTER_cu_fsm(
    input clk,
    input rst,
//    input INTR,
    input [6:0] ir,
    input [2:0] func,
    output logic pcWrite, regWrite, memWrite, memRead1, memRead2
//    output logic intrTaken//, csrWrite
    );
    
    // Assigns arbitrary bit values for states
    parameter [1:0]
        INST_FETCH      = 2'b00,
        DECODE_EXEC     = 2'b01,
        WRITE_BACK      = 2'b10,
        INTERUPT        = 2'b11;
    
    // Declares present state (ps) and next state (ns) variables
    logic [1:0] ns;
    logic [1:0] ps = INST_FETCH;
    
    // Sequential logic to change states
    always_ff @ (posedge clk)
    begin
        ps <= ns;
    end
    
//    // Initialize outputs
//    initial
//    begin
//        pcWrite = 0; regWrite = 0; memWrite = 0; memRead1 = 0; memRead2 = 0;
//    end
            
    // Combinatorial logic of FSM
    always_comb 
    begin
//        // Initialize outputs
//        pcWrite = 0; regWrite = 0; memWrite = 0; memRead1 = 0; memRead2 = 0;
////        intrTaken = 0;// csrWrite = 0;
        
        case (ps) 
            INST_FETCH:
            begin
                pcWrite = 0; 
                regWrite = 0; 
                memWrite = 0; 
                memRead1 = 1; 
                memRead2 = 0;
//                intrTaken = 0;
                //csrWrite = 0;
                if (rst)                    // Reset for button press
                begin
                    ns = INST_FETCH;
                end 
                else                        // Else go to decode and execute
                begin
                    ns = DECODE_EXEC;
                end
            end // IF state
            
            DECODE_EXEC:
            begin
//                pcWrite = 1; // moved to be next to where ns = INST_FETCH
                memRead1 = 0; 
//                intrTaken = 0;
                if (rst)                    // Reset for button press
                begin
                    ns = INST_FETCH;
                end 
                else                        // Else perform decode and execute
                begin
                    
                    case (ir)               // Sets vars based on instructions
                        7'b0110111:         // LUI
                        begin
                            pcWrite = 1; // moved here from beginning of DECODE
                            regWrite = 1;
                            memWrite = 0;
                            memRead2 = 0;
    //                        csrWrite = 0;
    //                        if (INTR) begin
    //                            NS = INTERUPT;
    //                        end else begin
    //                            NS = INST_FETCH;
    //                        end
                            ns = INST_FETCH;
                        end
                        
                        7'b0010111:         // AUIPC
                        begin
                            pcWrite = 1; // moved here from beginning of DECODE
                            regWrite = 1;
                            memWrite = 0;
                            memRead2 = 0;
    //                        csrWrite = 0;
    //                        if (INTR) begin
    //                            NS = INTERUPT;
    //                        end else begin
    //                            NS = INST_FETCH;
    //                        end
                            ns = INST_FETCH;
                        end
                        
                        7'b1101111:         // JAL
                        begin
                            pcWrite = 1; // moved here from beginning of DECODE
                            regWrite = 1;
                            memWrite = 0;
                            memRead2 = 0;
    //                        csrWrite = 0;
    //                        if (INTR) begin
    //                            NS = INTERUPT;
    //                        end else begin
    //                            NS = INST_FETCH;
    //                        end
                            ns = INST_FETCH;
                        end
                        
                        7'b1100111:         // JALR
                        begin
                            pcWrite = 1; // moved here from beginning of DECODE
                            regWrite = 1;
                            memWrite = 0;
                            memRead2 = 0;
    //                        csrWrite = 0;
    //                        if (INTR) begin
    //                            NS = INTERUPT;
    //                        end else begin
    //                            NS = INST_FETCH;
    //                        end
                            ns = INST_FETCH;
                        end
                        
                        7'b1100011:         // BRANCHES
                        begin
                            pcWrite = 1; // moved here from beginning of DECODE
                            regWrite = 0;
                            memWrite = 0;
                            memRead2 = 0;
    //                        csrWrite = 0;
    //                        if (INTR) begin
    //                            NS = INTERUPT;
    //                        end else begin
    //                            NS = INST_FETCH;
    //                        end 
                            ns = INST_FETCH;
                        end
                        
                        7'b0000011:         // LOADS
                        begin
                            regWrite = 0;
                            memWrite = 0;
                            memRead2 = 1;
    //                        csrWrite = 0;
                            ns = WRITE_BACK;    // Goes to write_back state for loads
                        end
                        
                        7'b0100011:         // STORES
                        begin
                            pcWrite = 1; // moved here from beginning of DECODE
                            regWrite = 0;
                            memWrite = 1;
                            memRead2 = 0;
    //                        csrWrite = 0;
    //                        if (INTR) begin
    //                            NS = INTERUPT;
    //                        end else begin
    //                            NS = INST_FETCH;
    //                        end
                            ns = INST_FETCH; 
                        end
                        
                        7'b0010011:         // OP w immediates
                        begin
                            pcWrite = 1; // moved here from beginning of DECODE
                            regWrite = 1;
                            memWrite = 0;
                            memRead2 = 0;
    //                        csrWrite = 0;
    //                        if (INTR) begin
    //                            NS = INTERUPT;
    //                        end else begin
    //                            NS = INST_FETCH;
    //                        end 
                            ns = INST_FETCH;
                        end
                        
                        7'b0110011:         // OP w/o immediates
                        begin
                            pcWrite = 1; // moved here from beginning of DECODE
                            regWrite = 1;
                            memWrite = 0;
                            memRead2 = 0;
    //                        csrWrite = 0;
    //                        if (INTR) begin
    //                            NS = INTERUPT;
    //                        end else begin
    //                            NS = INST_FETCH;
    //                        end 
                            ns = INST_FETCH;
                        end
                        
    //                    7'b1110011:         // CSR operations
    //                    begin
    //                        memWrite = 0;
    //                        memRead2 = 0;
    //                        if (func == 3'b001) begin  //csrrw
    //                            csrWrite = 1;
    //                            regWrite = 1;
    //                        end else begin              //mret
    //                            csrWrite = 0;
    //                            regWrite = 0;
    //                        end 
    //                        if (INTR) begin
    //                            NS = INTERUPT;
    //                        end else begin
    //                            NS = INST_FETCH;
    //                        end 
    //                    end 
                        
                        default:
                        begin
                            $display("Default of CU_FSM opcode case.");
                            pcWrite = 0; 
                            regWrite = 0; 
                            memWrite = 0; 
                            memRead1 = 0; 
                            memRead2 = 0;
//                            intrTaken = 0;
    //                        csrWrite = 0;
                            ns = INST_FETCH;
                        end
                    endcase
                
                end
            end
            
            WRITE_BACK:
            begin
                pcWrite = 1; // moved here from beginning of DECODE
                regWrite = 1;
                memWrite = 0;
                memRead2 = 0;
    //            csrWrite = 0;
    //            if (INTR) begin
    //                NS = INTERUPT;
    //            end else begin
    //                NS = INST_FETCH;
    //            end 
                ns = INST_FETCH;
            end
            
    //        INTERUPT: 
    //        begin
    //            pcWrite = 1;
    //            regWrite = 0;
    //            memWrite = 0;
    //            memRead2 = 0;
    //            intrTaken = 1;
    //            csrWrite = 0;
    //            NS = INST_FETCH;
    //        end 
            
            default:
            begin
                $display("Default of the CU_FSM state case.");
                ns = INST_FETCH;
            end 
        endcase // for ps
    end // always_comb block for FSM states
    
endmodule
