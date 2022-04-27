module cpu(clk,reset,read_data,out,N,V,Z,w,mem_addr,mem_cmd, PC, state);
  input [15:0]    read_data; // connection from top to instruction register
  input           clk, reset;
  output [15:0]   out;
  output          N, V, Z, w;

  // Lab 7 
  output [1:0] mem_cmd; // FSM -> RAM
  output [8:0] mem_addr, PC; // cpu -> RAM
  output [4:0] state;  
  wire         loada, loadb, asel, bsel, loadc, loads, write, load_ir;   
  wire [1:0]   vsel, op, ALUop, shift;  
  wire [2:0]   nsel, opcode, readnum, writenum, stat_out; 
  wire [8:0]   PC;
  wire [15:0]  sximm5, sximm8,  datapath_out, irout;

  // Program counter
  wire            reset_pc, load_pc, addr_sel, load_addr; 
  wire [8:0]      data_address;
  wire [8:0]      add_pc = PC + 1'b1; 				// adds one to PC
  wire [8:0]      next_pc = reset_pc ? 9'b0 : add_pc; // if reset pc asserted next_pc = 0

  assign mem_addr = addr_sel ? PC : data_address; // selects address

  // Instantiations
  vDFFE #(16) IR(clk, load_ir, read_data, irout); // input changed to read_data
  vDFFE #(9) PCR(clk, load_pc, next_pc, PC); // instantiate pc
  vDFFE #(9) DAR(clk, load_addr, datapath_out[8:0], data_address); // instantiate data address register

  instruction_decoder ID(irout, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);

  FSM SM(clk, reset, opcode, op, vsel, loada, loadb, asel, bsel, loadc, loads, write, nsel, w,
                   load_ir, load_pc, load_addr, addr_sel, reset_pc, mem_cmd, state);

  datapath DP(clk, readnum , vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads,
              writenum, write, read_data, sximm8, PC, sximm5, stat_out, datapath_out); // pls check

  // Status output
  assign Z = stat_out[0]; // Check code matches
  assign N = stat_out[1]; // Check code matches
  assign V = stat_out[2]; // Check code matches

  // Output
  assign out = datapath_out;
endmodule

// Instruction Decoder, decodes 16bit input into different parts of the instruction. 
module instruction_decoder (irout, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);
  input [15:0]      irout;
  input [2:0]       nsel;
  output [15:0]     sximm5, sximm8;
  output [2:0]      opcode, readnum, writenum;
  output [1:0]      op, ALUop;
  output reg [1:0]  shift;

  // Follow the diagram provided.
  wire [7:0] imm8 = irout[7:0];
  wire [4:0] imm5 = irout [4:0];
  wire [2:0] Rn = irout[10:8];
  wire [2:0] Rd = irout[7:5];
  wire [2:0] Rm = irout[2:0];

  Mux3 #(3) muxn(Rn, Rd, Rm, nsel, writenum);

  assign opcode = irout[15:13];
  assign op = irout[12:11];
  assign ALUop = irout[12:11];
  assign sximm5 = {{11{imm5[4]}}, imm5};
  assign sximm8 = {{8{imm8[7]}},imm8};

  always @(*) begin
    if (({opcode,op} == 5'b01100) | ({opcode,op} == 5'b10000)) shift = 2'b00;
    else shift = irout[4:3];
  end

  assign readnum = writenum;
endmodule

// State Machine, going through the instructions. 
module FSM(clk, reset, opcode, op, vsel, loada, loadb, asel, bsel, loadc, loads, write, nsel, w,
                     load_ir, load_pc, load_addr, addr_sel, reset_pc, mem_cmd, ps);
    input clk, reset;
    input [2:0] opcode;
    input [1:0] op;

    output reg [1:0] vsel;
    output reg [2:0] nsel;
    output reg write, loada, loadb, asel, bsel, loadc, loads, w;
    output reg [4:0] ps;
    output reg [1:0]  mem_cmd;
    output reg load_ir, load_pc, load_addr, addr_sel, reset_pc;
    reg [4:0] ns;


    // Pre-define the write & read.
    `define MNONE 2'b00
    `define MWRITE 2'b01
    `define MREAD 2'b10

    // States needed in the given state machine.
    `define Reset 5'b00000	
    `define IF1 5'b00001
    `define IF2 5'b00010
    `define UpdatePC 5'b00100
    `define loadaddr 5'b01000
    `define OP 5'b10000
    `define LDR 5'b00011
    `define LDR1 5'b11000
    `define STR 5'b00101
    `define STR1 5'b00110
    `define STR2 5'b00111
    `define HALT 5'b01001
    `define Decode 5'b01010

     // Before lab 7
    `define GetA 5'b01110		
    `define GetB 5'b01100		
    `define CMP 5'b11111		
    `define AND 5'b01111
    `define MOV_SH 5'b10110
    `define MVN 5'b11110	
    `define Operate 5'b01011	
    `define WriteReg 5'b10001	
    `define WriteImm 5'b10011	

    // state logic and actions within a state
    always@(posedge clk) begin
  	if (reset) begin
		ns = `Reset;
		reset_pc = 1'b1;
		load_pc = 1'b1;
		end
  	else begin
	case(ps)

	// Control, where only states are determined mostly.
	`Reset: begin // Everything 0.
		ns = `IF1;
             	loada = 1'b0;loadb = 1'b0;loadc = 1'b0; loads = 1'b0;
            	asel = 1'b0;bsel = 1'b0;vsel = 2'b00;nsel = 3'b000;
             	write = 1'b0;
              	w = 1'b1;
		mem_cmd = 2'b00;
		load_ir = 1'b0;
		load_addr = 1'b0;
		addr_sel = 1'b0;
		end

	// Give the value according to the diagram provided. 
	// Also making sure that no other variables are touched during the first few stages before Decode.
	// (not needed, but used for easier debugging.) 
	`IF1: begin
		ns = `IF2;
		loada = 1'b0; loadb = 1'b0;loadc = 1'b0;loads = 1'b0;
                asel = 1'b0; bsel = 1'b0; vsel = 2'b00; nsel = 3'b000;
                write = 1'b0;
                w = 1'b1;
		reset_pc = 1'b0;
                load_pc = 1'b0;
                addr_sel = 1'b1;
                mem_cmd = `MREAD; 
		end

	`IF2: begin
                ns = `UpdatePC;
                loada = 1'b0; loadb = 1'b0;loadc = 1'b0;loads = 1'b0;
                asel = 1'b0; bsel = 1'b0; vsel = 2'b00; nsel = 3'b000;
                write = 1'b0;
                w = 1'b1;
		reset_pc = 1'b0;
                load_pc = 1'b0; load_ir = 1'b1;
                addr_sel = 1'b1;
                mem_cmd = `MREAD; 
              	end

        `UpdatePC: begin
               	ns = `Decode;
		loada = 1'b0; loadb = 1'b0;loadc = 1'b0;loads = 1'b0;
                asel = 1'b0; bsel = 1'b0; vsel = 2'b00; nsel = 3'b000;
                write = 1'b0;
                w = 1'b1;
		reset_pc = 1'b0;
                load_pc = 1'b1; load_ir = 1'b0;
                addr_sel = 1'b0;
                mem_cmd = `MNONE;
             	end

	 // Starts the operations. 
	`Decode: begin  
		load_pc = 1'b0; w = 1'b0;
		case({opcode,op})
		5'b11010: ns = `WriteImm; 
		5'b11000: ns = `GetB;
		5'b10111: ns = `GetB;
		5'b11100: ns = `HALT;
		default: ns = `GetA;
		endcase 
		end

	// Ssame approach for the previous functions with exceptions for some of its next_states. 
	`WriteImm: begin 
		nsel = 3'b100;  // Rn
            	vsel = 2'b10; 
            	write = 1'b1;
           	ns = `IF1;
		end

        `GetA: begin
                 nsel = 3'b100; // Rn
                 loada = 1'b1;	// A
                 ns = `GetB;
               end

	`GetB: begin
		 nsel = 3'b001; // Rm
                 loada = 1'b0;
                 loadb = 1'b1;	// B
		case({opcode, op})	// Which to perform via opcode & op.
		5'b10100: ns = `Operate;
		5'b11000: ns = `MOV_SH;
		5'b10101: ns = `CMP;
		5'b10110: ns = `AND;
		5'b10111: ns = `MVN;
		5'b01100: ns = `Operate;
		5'b10000: ns = `Operate;
		endcase
		end

	// States needed in the given state machine.
	`Operate: begin			
		case({opcode, op})
		5'b10100: begin
     			asel = 1'b0; 
                  	bsel = 1'b0; 
                  	loadb = 1'b0;
                  	loadc = 1'b1; end
		5'b01100: begin		//ldr
			asel = 1'b0; 
                  	bsel = 1'b1; 
                  	loadb = 1'b0;
                  	loadc = 1'b1; // out = C
                  	ns = `loadaddr; end
		5'b10000: begin		//str
           		asel = 1'b0; 
                  	bsel = 1'b1; 
                  	loadb = 1'b0;
                  	loadc = 1'b1;
                  	ns = `loadaddr; end
		endcase
		end

	// Stop.
	`HALT: ns = `HALT; 

// -----------------------------------------------------

	// Function states, where the operations are being held. 
	`loadaddr: begin
		load_addr = 1'b1; 
               	addr_sel = 1'b0; // data_address
              	loadc = 1'b0;
		case({opcode, op})
			5'b01100: ns = `LDR;
			5'b10000: ns = `STR;
			endcase
		end

	`CMP: begin
                asel = 1'b0; // A
                bsel = 1'b0; // B
                loadb = 1'b0;
                loadc = 1'b1;
                loads = 1'b1; // output status
                ns = `WriteReg;
              end
        `AND: begin
                asel = 1'b0; // A
                bsel = 1'b0; // B
                loadb = 1'b0;
                loadc = 1'b1;
                ns = `WriteReg;
              end
        `MVN: begin
                asel = 1'b1; 
                bsel = 1'b0; // B
                loadb = 1'b0;
                loadc = 1'b1;
                ns = `WriteReg;
              end
	`MOV_SH: begin
                  asel = 1'b1; 
                  bsel = 1'b0; // B
                  loadb = 1'b0;
                  loadc = 1'b1;
                  ns = `WriteReg;
                end

	// Lab 7 table 1 instruction
        `LDR: begin
                mem_cmd = `MREAD;
                load_addr = 1'b0;
                ns = `WriteReg;
              end

        `STR: begin
                load_addr = 1'b0;
                nsel = 3'b010; // Rd
                loadb = 1'b1;
                ns = `STR1;
              end
        `STR1: begin
                 asel = 1'b1;  // A
                 bsel = 1'b0;
                 loadb = 1'b0;
                 loadc = 1'b1; // C
                 ns = `STR2;
               end
        `STR2: begin
                 mem_cmd = `MWRITE;
                 ns = `IF1;
               end

	`WriteReg: begin
		case({opcode, op})
		5'b01100: begin
		       nsel = 3'b010; // Rd
                       vsel = 2'b11; // mdata
                       write = 1'b1;
                       ns = `IF1; end
		default: begin
		       nsel = 3'b010; // Rd
                       vsel = 2'b00; // datapath_out
                       write = 1'b1;
                       ns = `IF1; end
		endcase
		end 
      	endcase
    end
    ps = ns;
  end
endmodule






 


























		
