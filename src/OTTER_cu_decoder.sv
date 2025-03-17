`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/10/2025 05:16:21 PM
// Description: 
//      Control unit decoder for the OTTER. Handles ALU control lines based on 
//      the input instruction.
// Dependencies: 
//      n/a
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - code is adapted from my 2022 CPE233 version
//      - commented out interrupt functionality
//      - commented out lines 56-57, not sure their purpose
//      - check the 'now yes' status if working ok - all set and fixedd
//      - rearranged some if statements formatting, hoping is ok
//      - rf_wr_sel output value 1 is for interrupts only, doesn't have any
//          other use
//////////////////////////////////////////////////////////////////////////////////

module OTTER_cu_decoder(
    input   [31:0] rs1,
    input   [31:0] rs2,
    input   [31:0] ir,
    //   input intr_taken,
    output  logic [3:0] alu_fun,
    output  logic alu_srcA,
    output  logic [1:0] alu_srcB,
    output  logic [2:0] pc_source,
    output  logic [1:0] rf_wr_sel
    );
    
    // Initialize variables for extracting instruction information
    logic [6:0] CU_OPCODE;
    logic [2:0] func;
    // Extract opcode and function information from instruction
    assign CU_OPCODE = ir[6:0];
    assign func = ir[14:12];
    
    // Enumerate opcode values 
    typedef enum logic [6:0] {
        LUI     = 7'b0110111, // u type
        AUIPC   = 7'b0010111, // u type
        JAL     = 7'b1101111, // j type
        JALR    = 7'b1100111, // i type
        BRANCH  = 7'b1100011, // b type
        LOAD    = 7'b0000011, // i type
        STORE   = 7'b0100011, // s type
        OP_IMM  = 7'b0010011, // i type
        OP      = 7'b0110011  // r type
        //       CSR     = 7'b1110011  // i type but doesn't really use 
    } opcode_t;
    // need this (below) ?
//    opcode_t OPCODE;
//    assign OPCODE = opcode_t'(CU_OPCODE);

    // Decoder assigns output values based on instruction opcode
    always_comb
    begin
//       if (intr_taken) begin                    //if interupt when allowed
//           alu_fun      = 4'b1111;  // don't care b/c not writing to reg or mem
//           alu_srcA     = 0;        // ALU input A
//           alu_srcB     = 1;        // i type
//           rf_wr_sel    = 1;        // CSR reg output
//           pc_source    = 4;        // mtvec
//       end
//       else begin                               //else continue normal combinatorial
        case (ir[6:0]) // case based on opcode
            LUI:                           
            begin
                alu_fun = 4'b1001;
                alu_srcA = 1;   // u type
                alu_srcB = 0;   // ?
                rf_wr_sel = 3;  // writing to reg
                pc_source = 0;
            end
            
            AUIPC:                              
            begin
                alu_fun = 4'b0000;  
                alu_srcA = 1;   // u type
                alu_srcB = 3;   // pc
                rf_wr_sel = 3;  // writing to reg
                pc_source = 0;  // pc + 4
            end
            
            JAL:                                
            begin
                alu_fun = 4'b1001;
                alu_srcA = 0;
                alu_srcB = 1;   // imm
                rf_wr_sel = 0;  // writing to reg
                pc_source = 3;  // jal
            end
            
            JALR:                               
            begin
                alu_fun = 4'b1001; 
                alu_srcA = 0;
                alu_srcB = 1;   // imm
                rf_wr_sel = 0;  // writing to reg
                pc_source = 1;  // jalr
            end
            
            BRANCH: // b type                   
            begin
                alu_fun = 4'b1001;
                alu_srcA = 0;
                alu_srcB = 0;
                rf_wr_sel = 0;
                pc_source = 0;
                case (func)
                    3'b000: // beq
                        if ($signed(rs1) == $signed(rs2)) pc_source = 2;
                    3'b001: // bneq
                        if ($signed(rs1) != $signed(rs2)) pc_source = 2;
                    3'b100: // blt
                        if ($signed(rs1) < $signed(rs2)) pc_source = 2;
                    3'b101: // bgt
                        if ($signed(rs1) >= $signed(rs2)) pc_source = 2;
                    3'b110: // bltu
                        if (rs1 < rs2) pc_source = 2;
                    3'b111: // bgeu
                        if (rs1 >= rs2) pc_source = 2;
                    default:
                        pc_source = 0;
                endcase
            end
            
            LOAD: // i type                     
            begin
                alu_fun = 4'b0000;
                alu_srcA = 0;
                alu_srcB = 1;
                rf_wr_sel = 2;  // load from mem
                pc_source = 0;
            end
            
            STORE: // s type                    
            begin
                alu_fun = 4'b0000;
                alu_srcA = 0;
                alu_srcB = 2;
                rf_wr_sel = 0;
                pc_source = 0;
            end
            
            OP_IMM: // i type                   
            begin
                alu_srcA = 0;
                alu_srcB = 1;
                rf_wr_sel = 3;   
                pc_source = 0;
                case (func)
                    3'b000: //addi
                        alu_fun = 4'b0000;
                    3'b001: //slli
                        alu_fun = 4'b0001;
                    3'b010: //slti
                        alu_fun = 4'b0010;
                    3'b011: //sltiu
                        alu_fun = 4'b0011;
                    3'b100: //xori
                        alu_fun = 4'b0100;
                    3'b101: // srli or srai
                        if (ir[31:25] == 8'b00000000) alu_fun = 4'b0101; //srli
                        else alu_fun = 4'b1101; //srai
                    3'b110: //ori
                        alu_fun = 4'b0110;
                    3'b111: //andi
                        alu_fun = 4'b0111;
                    default: 
                        alu_fun = 4'b0000; // copy
                endcase
            end 
                                        
            OP: // r type
            begin
                alu_srcA = 0;
                alu_srcB = 0;
                rf_wr_sel = 3;
                pc_source = 0;
                case (func)
                    3'b000: // add or sub
                        if (ir[31:25] == 8'b00000000) alu_fun = 4'b0000; //add
                        else alu_fun = 4'b1000; //sub
                    3'b001: //sll
                        alu_fun = 4'b0001;
                    3'b010: //slt
                        alu_fun = 4'b0010;
                    3'b011: //sltu
                        alu_fun = 4'b0011;
                    3'b100: //xor
                        alu_fun = 4'b0100;
                    3'b101: // srl or sra
                        if (ir[31:25] == 8'b00000000) alu_fun = 4'b0101; //srl
                        else alu_fun = 4'b1101; //sra
                    3'b110: //or
                        alu_fun = 4'b0110;
                    3'b111: //and
                        alu_fun = 4'b0111;
                    default:
                        alu_fun = 4'b0000; // copy
                endcase
            end
            //           CSR: // i type
            //               begin
            //               alu_fun = 4'b1001;   // pass through
            //               alu_srcA = 0;
            //               alu_srcB = 1;        // i type
            //               rf_wr_sel = 1;       // CSR reg out
            //               if (func == 3'b001) begin
            //                   pc_source = 0;   // pc_next
            //               end else begin
            //                   pc_source = 5;   // mepc
            //               end
            //               end
            default:
            begin
                alu_fun = 4'b1111;
                alu_srcA = 0;
                alu_srcB = 0;
                pc_source = 0;
                rf_wr_sel = 0;
            end
        endcase // case for decoding opcode
        //       end // if statement for interrupt handling
    end // always_comb block for assigning outputs based on opcode
endmodule
