# Microcomputer
University of British Columbia, Vancouver, Canada.

Boolean algebra; combinational and sequential circuits; organization and operation of microcomputers, memory addressing modes, representation of information, instruction sets, machine and assembly language programming, systems programs, I/O structures, I/O interfacing and I/O programming, introduction to digital system design using microcomputers.

## Lab 1 Combinational logic circuit.
Building a 2-input OR gate out of two NOT-gates, and a NAND gate, also with a NOT gate. Furthermore, building an optimized circuit for a complex Boolean function.

## Lab 2 Finite-state machine.
Building a finite state machine using Flip-Flop modules brought by the 74173 chip and a series of combinational logic made using NOT & NAND gates.

## Lab 3 FSM to DE1-SoC
Implementing a finite state machine to the DE1-SoC. Display the result via 7 segments LED, using a combinational logic block. More specifically, designing a combinational lock with some pre-set number, that, after the correct input from the user, ‘OPEN’ is displayed. Otherwise, the 7-seg LED remain displaying ‘CLOSED’.

## Lab 4 ARM Assembly
Implementing a recursive binary search function using ARM assembly code, provided with the ARM Cortex-A9 built into Cyclone V FPGA on the DE1-SoC.

## Lab 5 Simple RISC Machine I, Datapath
Building a datapath for the RISC such that it implements the state machine using registers, flip-flops, and mux which sets the control signals. The result should be displayed via the 7-seg display of the DE1-SoC.

## Lab 6 Simple RISC Machine II, FSM
Building a finite state machine that can automate the control instructions from the previous lab in combination with an instruction register. The instruction register is implemented before the instruction decoder, state machine and the datapath such that a 16-bit encoded signal can be passed through.

## Lab 7 Simple RISC Machine III, Memory and I/O
Building a read-write memory to the RISC machine that can hold data and allow external communications. LDR & STR is used to carry memory which is extended to enable memory-mapped I/O.
