`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Jack Krammer
// 
// Create Date: 02/12/2025 12:32:28 PM
// Description: 
//      Assembles OTTER modules into a cohesive unit that can process RISC-V
//      32-bit instructions. 
// Dependencies: 
//      OTTER_pc.sv
//          - program counter module fetches instructions
//      OTTER_memory.sv
//          - holds OTTER memory, both instruction memory and data memory
//      OTTER_register_file.sv
//          - holds registers and register data, volatile data
//      OTTER_cu_fsm.sv
//          - control unit fsm outputs control lines based on instruction state
//      OTTER_cu_decoder.sv
//          - control unit decoder outputs control lines based on inst opcode
//      OTTER_alu.sv
//          - arithmetic logic unit executes instruction operation
//      OTTER_value_gen.sv
//          - combination immediate generator and target generator
//      mux421.sv
//          - 4 input to 1 output multiplexer with variable data bit width
//      mux221.sv
//          - 2 input to 1 output multiplexer with variable data bit width
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//      - code is adapted from my 2022 CPE 233 version
//      - commented out interrupt functionality
//////////////////////////////////////////////////////////////////////////////////

module OTTER_mcu(
    input CLK, 
//    input INTR,
    input RST,
    input [31:0] IOBUS_IN,
    output [31:0] IOBUS_OUT, 
    output [31:0] IOBUS_ADDR,
    output IOBUS_WR
    );
    
    // Program counter connecting variables
    logic pc_write;
    logic [2:0] pc_source;
    
    // Memory connecting variables
    logic [31:0] pc;
    logic mem_write, mem_read1, mem_read2;
    logic ERR;
    
    // rf_mux connecting variables
    logic [31:0] pc_4, mem_dout2, rf_wd; //,CSR_reg;
    logic [1:0] rf_wr_sel;
    
    // Register file connecting variables
    logic [31:0] ir, rf_dout1, rf_dout2;
    logic rf_write;
    
    // ALU connecting variables
    logic [3:0] alu_fun;
    logic alu_srcA_sel;
    logic [1:0] alu_srcB_sel;
    logic [31:0] alu_srcA_out, alu_srcB_out, alu_out; 
    
    // Value generator connecting variables
    logic [31:0] itype_imm, utype_imm, stype_imm, branch_pc, jal_pc, jalr_pc;
    
//    //CSR connecting variables
//    logic [31:0] mtvec, mepc;
//    logic csr_mie, csr_write, intr_taken;
    
//    //FSM interupt connecting variables
//    logic intr_allowed;
//    assign intr_allowed = INTR & csr_mie;
    
//    //CSR
//    CSR csr ( .CLK(CLK), .RST(RST), .INT_TAKEN(intr_taken), .ADDR(ir[31:20]), .PC(pc),
//                .WD(alu_out), .WR_EN(csr_write), .RD(CSR_reg), .CSR_MEPC(mepc),
//                .CSR_MTVEC(mtvec), .CSR_MIE(csr_mie) );
    
    // Program counter module includes pc_source mux inside
    OTTER_pc program_counter ( .clk(CLK), .jalr(jalr_pc), .jal(jal_pc), 
        .branch(branch_pc), .pc_source(pc_source), .reset(RST), .pc_write(pc_write), 
//        .mtvec(mtvec), .mepc(mepc), 
        .count(pc), .count_4(pc_4) );

    // Memory module port connections taken in as parameter inputs
    OTTER_mem_byte memory ( .MEM_CLK(CLK), .MEM_ADDR1(pc), .MEM_ADDR2(alu_out), 
        .MEM_DIN2(rf_dout2), .MEM_WRITE2(mem_write), .MEM_READ1(mem_read1), 
        .MEM_READ2(mem_read2), .ERR(ERR), .MEM_DOUT1(ir), .MEM_DOUT2(mem_dout2), 
        .IO_IN(IOBUS_IN), .IO_WR(IOBUS_WR), .MEM_SIZE(ir[13:12]), .MEM_SIGN(ir[14]) );

    // Mux module for data into register file
    mux421 # (32) rf_mux ( .zero(pc_4), .one(32'h0), .two(mem_dout2), //.one(CSR_reg),
        .three(alu_out), .SEL(rf_wr_sel), .F(rf_wd) );
    
    // Regsiter file module
    OTTER_register_file register_file ( .addr1(ir[19:15]), .addr2(ir[24:20]), 
        .waddr(ir[11:7]), .wd(rf_wd), .en(rf_write), .clk(CLK), .rs1(rf_dout1), 
        .rs2(rf_dout2) );
    
    // Control unit fsm module
    OTTER_cu_fsm cu_fsm ( .clk(CLK), .rst(RST), .ir(ir[6:0]), .func(ir[14:12]),
//        .INTR(intr_allowed), .csrWrite(csr_write), .intrTaken(intr_taken)
        .pcWrite(pc_write), .regWrite(rf_write), .memWrite(mem_write), 
        .memRead1(mem_read1), .memRead2(mem_read2) );
    
    // Control unit decoder module
    OTTER_cu_decoder cu_decoder ( .rs1(rf_dout1), .rs2(rf_dout2), .ir(ir), 
//        .intr_taken(intr_taken),
        .alu_fun(alu_fun), .alu_srcA(alu_srcA_sel), .alu_srcB(alu_srcB_sel),
        .pc_source(pc_source), .rf_wr_sel(rf_wr_sel) );
    
    // Mux module for ALU source A
    mux221 # (32) alu_srcA_mux ( .zero(rf_dout1), .one(utype_imm), .SEL(alu_srcA_sel),
        .F(alu_srcA_out) );
    
    // Mux module for ALU source B mux
    mux421 # (32) alu_srcB_mux ( .zero(rf_dout2), .one(itype_imm), .two(stype_imm),
        .three(pc), .SEL(alu_srcB_sel), .F(alu_srcB_out) );
    
    // ALU module
    OTTER_alu alu ( .ALU_FUN(alu_fun), .A(alu_srcA_out), .B(alu_srcB_out), 
        .sum(alu_out) );
    
    // Value generator module (combination immediate generator and target generator)
    OTTER_value_gen value_gen ( .pc(pc), .ir(ir), .reg_out(rf_dout1), 
        .I_immed(itype_imm), .U_immed(utype_imm), .S_immed(stype_imm), 
        .branch_pc(branch_pc), .jal_pc(jal_pc), .jalr_pc(jalr_pc) );
    
    // Maps I/O BUS outputs
    assign IOBUS_OUT = rf_dout2;
    assign IOBUS_ADDR = alu_out;

endmodule
