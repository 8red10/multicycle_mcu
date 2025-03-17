# RISC-V 32-bit Multicycle MCU

## Author 

By Jack Krammer on March 16, 2025 for Cal Poly CPE 233


## Introduction

A multicycle MCU capable of running assembly programs based on the 32-bit RISC-V ISA. This project utilizes SystemVerilog and RISC-V assembly code and was developed in Vivado for a Basys 3 Artix-7 FPGA board. The MCU also provides functionality to interact with board inputs and outputs via memory mapped IO.


## Description

### MCU Architecture Diagram

<div align='center'/>

<img src="images/mcu_architecture.png" alt="mcu architecture diagram" width="800">

**Figure 1.** MCU architecture with modules and connections.

</div>


### Memory Map

<div align='center'>

<img src="images/memory_map.png" alt="memory map" width="300">

**Figure 2.** Memory address range the MCU was designed to utilize.

</div>


### Module Hierarchy

- OTTER_wrapper.sv
    - clock_divider.sv
    - OTTER_mcu.sv
        - OTTER_pc.sv
        - OTTER_mem_byte.sv
            - multicycle_test_all.mem
        - OTTER_register_file.sv
        - OTTER_cu_fsm.sv
        - OTTER_cu_decoder.sv
        - OTTER_alu.sv
        - OTTER_value_gen.sv
        - mux421.sv
        - mux221.sv
    - seven_segment_display.sv
        - hex2bcd.sv
        - cathode_driver.sv
    - debounce_button.sv
- basys3constraints.xdc


### Module Descriptions

OTTER_wrapper.sv
- Top level wrapper module for the MCU to help interface with IO via MMIO. 

clock_divider.sv
- Divides the input clock to output a slow clock. The MAX_COUNT parameter enables this module to output a variable frequency clock.

OTTER_mcu.sv
- Assembles modules into a cohesive unit that can process RISC-V 32-bit assembly instructions.

OTTER_pc.sv
- Program counter module for the MCU.

OTTER_mem_byte.sv
- Dual port Memory module for the MCU. Contains both instruction memory and data memory.

multicycle_test_all.mem
- Assembly code memory file for testing all functionality of the MCU.

OTTER_register_file.sv
- Register file module for the MCU. Holds 32 registers that each have 32-bit width data. Allows for single input and dual output.

OTTER_cu_fsm.sv
- Control unit FSM for the MCU. Handles outputs for each state of FSM.

OTTER_cu_decoder.sv
- Control unit decoder for the MCU. Handles ALU control lines based on the input instruction.

OTTER_alu.sv
- Arithmetic Logic Unit (ALU) for the MCU. Essentially executes the operations selected by the instruction.

OTTER_value_gen.sv
- Value generator module for the MCU. Combines the immediate generator and the target generator (branch address generator) into one module.

mux421.sv
- A 4 to 1 multiplexer with variable bit width input/output.

mux221.sv
- A 2 to 1 multiplexer with a variable bit width input/output.

seven_segment_display.sv
- Display driver for the 4-digit seven segment display on a Basys3 board that has a common anode and common cathode. The 16-bit input can be displayed as a decimal or hex value depending on the mode input (0 for hex, 1 for decimal). In decimal mode, the full 16-bit range of cannot be displayed, so anything above 4 binary coded decimal digits is is truncated to fit the 4-digit decimal range. For exmaple, 12345 is truncated to 2345. Assumes input clock is 100 MHz.

hex2bcd.sv
- Converts a 16-bit number to a 4-digit binary coded decimal. The full 16-bit range cannot be converted to a 4-digit binary coded decimal, so anything above 4 binary coded decimal digits is truncated. For example, 12345 is truncated to 2345.

cathode_driver.sv
- Designed for the 4-digit seven segment display on a Basys3 board. Displays a 16-bit hex value where each of the four bit portions of the value each correspond to a digit on the display. For example, the lower four bits of the input hex value are output to the first (lowest) digit of the seven segment display. 
- The 4-digit seven segment display on the Basys3 board has common cathode and common anode with both configured as negative logic such that 0s in cathode light up the corresponding segment for any digit with a 0 in their respective place in anode.
- Current flows from the common anode to each of the individual cathodes (each of which are essentially an LED that controls a segment of the digit display), meaning that a segment will only light up if a zero is in the digit's location (anode is asserted = set low bc negative logic) and a zero is asserted in the corresponding cathode.

debounce_button.sv
- A FSM-based button debouncer with an integrated one-shot output. The one-shot output directly follows the successful completion of debouncing the rising edge and then the falling edge of the input signal (button). CLK should be a 50 MHz RAT clock. Debounced output occurs after button has been released from the button press.

basys3constraints.xdc
- Constraints file for the Basys 3 board to map board inputs, outputs, and clock to the OTTER_wrapper.sv inputs and outputs. Enables compatibility with hardware and functionality beyond simulation.


## Acknowledegments

This project was created with the guidance and help of Professor Joseph Callenes at Cal Poly for CPE 233 (Computer Design and Assembly Language Programming).

