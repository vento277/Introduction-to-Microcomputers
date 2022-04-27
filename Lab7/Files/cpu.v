module cpu(clk, reset, read_data, out, N, V, Z, w, mem_addr, mem_cmd, PC, state);
    input clk, reset;
    input [15:0] read_data;	// instruction register
    output [15:0] out;
    output N,V,Z,w;
    output [15:0] PC; 

    // Lab 7 additions
    output [8:0]    mem_addr; // CPU - RAM
    output [1:0]    mem_cmd; // FSM - RAM
    output [4:0]    state; // HEX

    // instruction register to decoder
    wire [15:0] curr_inst;

    // decoder to fsm
    wire [2:0] opcode;
    wire [1:0] op;

    // fsm to decoder
    wire [2:0] nsel;

    // decoder to datapath
    wire [15:0] sximm5, sximm8;
    wire [2:0] readnum, writenum;
    wire [1:0] ALUop, shift;
    
    // fsm to datapath
    wire [1:0] vsel;
    wire write, loada, loadb, asel, bsel, loadc, loads;

    // data output
    wire [2:0] Z_out;
    wire [8:0] PC; 
    wire [15:0] C;
	 
    // Program counter
    wire reset_pc, load_pc, addr_sel, load_addr; 
    wire [8:0] data_address; 
    wire [8:0] added_pc = PC + 1'b1; // add one 
    wire [8:0] next_pc = reset_pc ? 9'b0 : added_pc; // 2but MUX, if reset pc asserted next_pc = 0
    assign mem_addr = addr_sel ? PC : data_address; // 2bit MUX, selects address

    RLE #(9) PCreg(next_pc, load_pc, clk, PC);	// program counter
    RLE #(9) Adressreg(C[8:0], load_addr, clk, data_address);		//mem_addr
    RLE InstructionR(read_data, load_ir, clk, curr_inst);	// instruction register
  	
    instruction_decoder ins_dec(curr_inst, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);

    FSM fsm(clk, reset, opcode, op, vsel, loada, loadb, asel, bsel, loadc, loads, write, nsel, w,
                     load_ir, load_pc, load_addr, addr_sel, reset_pc, mem_cmd, state);
    datapath DP(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, read_data, sximm8, PC, sximm5, Z_out, C);
 
    assign out = C;         // out is connected to C in datapath
    assign {N,V,Z} = Z_out; // Z_out[2] = N, Z_out[1] = V, Z_out[0] = Z
endmodule


module instruction_decoder(in, sel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);
    input [15:0] in;
    input [2:0] sel;

    output [15:0] sximm5, sximm8;
    output [2:0] readnum, writenum, opcode;
    output [1:0] ALUop, shift, op;

    assign opcode = in[15:13];  // first 3 bits of instruction
    assign op = in[12:11]; // next 2 bits of instruction

    assign ALUop = in[12:11];   // ALUop are bits 12 and 11
    assign sximm5 = {{11{in[4]}}, in[4:0]}; // bits 4 to 0, with the rest bits are copies of bit 4
    assign sximm8 = {{8{in[7]}}, in[7:0]}; // bits 7 to 0, with the rest bits are copies of bit 7
    assign shift = in[4:3]; // shift are bits 4 and 3
    assign readnum = (in[10:8] & {3{sel[0]}}) | (in[7:5] & {3{sel[1]}}) | (in[2:0] & {3{sel[2]}});  // select which of the 3 registers Rn, Rd, Rm should be used
    assign writenum = (in[10:8] & {3{sel[0]}}) | (in[7:5] & {3{sel[1]}}) | (in[2:0] & {3{sel[2]}}); // for both readnum and writenum
endmodule

module FSM(clk, reset, opcode, op, vsel, loada, loadb, asel, bsel, loadc, loads, write, nsel, w,
                     load_ir, load_pc, load_addr, addr_sel, reset_pc, mem_cmd, state);
    input clk, reset;
    input [2:0] opcode;
    input [1:0] op;

    output reg [1:0] vsel;
    output reg [2:0] nsel;
    output reg write, loada, loadb, asel, bsel, loadc, loads, w;
    output reg [4:0] state;
    
    // lab 7 addition
    output reg [1:0]  mem_cmd;
    output reg        load_ir, load_pc, load_addr, addr_sel, reset_pc;

    `define MNONE 2'b00
    `define MWRITE 2'b01
    `define MREAD 2'b10

    `define Reset 5'b00000	
    `define IF 5'b00001
    `define IF2 5'b00010
    `define UpdatePC 5'b00100
    `define loadaddr 5'b01000
    `define OP 5'b10000
    `define LDR 5'b00011
    `define LDR1 5'b11000
    `define STR 5'b00101
    `define STR1 5'b00110
    `define STR2 5'b00111
    `define STR3 5'b11100
    `define HALT 5'b01001
    `define Decode 5'b01010


    `define GetA 5'b01110		//read to register A, nsel=001
    `define GetB 5'b01100		//read to register B, nsel=100
    `define Pass 5'b01101		//asel/loadc are 1, bsel 0, passes shifted B to C
    `define Sub 5'b01010	//loads is 1, load c is 0 so nothing is passed to C, asel/bsel are 0
    `define Operate 5'b01011	//load c is 1, asel/bsel are 0; result of an ALU operation is passed to C
    `define WriteReg 5'b10001	//write=1, nsel=010, vsel=00; writes C to a register
    `define WriteImm 5'b10011	//vsel=10, write=1, nsel=001; writes immediate input to a register

    // state logic and actions within a state
    always @(posedge clk) begin
        if (reset) begin
            state = `Reset;

	    reset_pc = 1'b1;
	    load_pc = 1'b1; 
	end
 
        else begin
            case(state)  
		`Reset: state = `IF;
		`IF: state = `IF2;
		`IF2: state = `UpdatePC;
		`UpdatePC: state = `Decode;   
             


	    `Decode: case(opcode)
               	3'b110: case(op)
         		2'b10: state = `WriteImm;   // MOV Rn,#<im8>
        		2'b00: state = `GetB;       // first state in MOV Rd, Rm{,<sh_op>}
                        default: state = 3'bxxx;
                        endcase
                3'b101: case(op)
                        2'b11: state = `GetB;       // MVN Rd,Rm{,<sh_op>}, no need to load A register
                        2'b00, 2'b01, 2'b10: state = `GetA; // load A register
                        default: state = 3'bxxx;
			endcase
		3'b011: case(op)
			2'b00: state = `LDR;
			endcase
		3'b100: case(op)
			2'b00: state = `STR;
			endcase
		3'b111: case(op)
			2'b00: state = `HALT;
                        endcase
               default: state = 3'bxxx;
               endcase

		`LDR: state = `loadaddr;
		`STR: state = `loadaddr;
	    	`HALT: state = `HALT;

		`loadaddr: case({opcode,op})
			5'b01100: state = `LDR1;
			5'b10000: state = `STR1;
			endcase
		`LDR1: state = `WriteReg;
		`STR1: state = `STR2;
		`STR2: state = `STR3;
		`STR3: state = `IF;

            `GetA: state = `GetB;   //always go to GetB when in GetA

            `GetB: case(opcode)
           	3'b110: state = `Pass;  // MOV instruction state
          	3'b101: case(op)
                        2'b01: state = `Sub;    // CMP Rn,Rm{,<sh_op>}
                        2'b00, 2'b10, 2'b11: state = `Operate; // go to operation state 
                        default: state = 3'bxxx;
                    	endcase
                default: state = 3'bxxx;
                endcase


             `Pass, `Operate, `LDR: state = `WriteReg; // Pass and Operate are followed by WriteReg
             `Sub, `WriteReg, `WriteImm: state = `IF;  // go to Wait state after Sub, WriteReg and WriteImm

	endcase
        end

        case(state)

	`Reset: begin 
		vsel = 2'b00; asel = 1'b0; bsel = 1'b0;
		loada = 1'b0; loadb = 1'b0; loadc = 1'b0; loads = 1'b0;
                write = 1'b0;
                nsel = 3'b000;
                w = 1'b1;

		mem_cmd = 2'b00;
		load_ir = 1'b0;
		load_addr = 1'b0;
		addr_sel = 1'b0; end

	`IF: begin 
                vsel = 2'b00; asel = 1'b0; bsel = 1'b0;
                loada = 1'b0; loadb = 1'b0; loadc = 1'b0; loads = 1'b0;
                write = 1'b0;
                nsel = 3'b000;
                w = 1'b1;

                reset_pc = 1'b0;
                load_pc = 1'b0;
                addr_sel = 1'b1;
                mem_cmd = 2'b10; // read next instruction
		end

	`IF2: begin 
		load_ir = 1'b1;
		end

      	`UpdatePC: begin 
          	load_ir = 1'b0;
          	addr_sel = 1'b0;
           	mem_cmd = 2'b00;
            	load_pc = 1'b1;
                   end

	`LDR: begin
		asel = 1'b0; // selects A
          	bsel = 1'b1; // selects B
           	loadb = 1'b0;
            	loadc = 1'b1; // enables C
		end

	`STR: begin
		asel = 1'b0; // selects A
        	bsel = 1'b1; // selects B
  		loadb = 1'b0;
       		loadc = 1'b1;
		end

	`loadaddr: begin
		load_addr = 1'b1; // enables data_address
           	addr_sel = 1'b0; // selects data_address
               	loadc = 1'b0;
		end

	`LDR1: begin
                mem_cmd = `MREAD;
                load_addr = 1'b0;           
              	end

	`STR1: begin
		load_addr = 1'b0;
                nsel = 3'b010; // selects Rd
                loadb = 1'b1;       
              	end

	`STR2: begin
               	asel = 1'b1;
              	bsel = 1'b0;
                loadb = 1'b0;
                loadc = 1'b1;
               	end

	`STR3: begin
		mem_cmd = `MWRITE;
		end
	

            `GetA: begin    // read register Rn into A
                nsel = 3'b001;  asel = 1'b0;
                vsel = 2'b00;   bsel = 1'b0;
                write = 1'b0;   loadc = 1'b0;
                loada = 1'b1;   loads = 1'b0;
                loadb = 1'b0;   w = 1'b0;
            end
            `GetB: begin    // read register Rm into B
                nsel = 3'b100;  asel = 1'b0;
                vsel = 2'b00;   bsel = 1'b0;
                write = 1'b0;   loadc = 1'b0;
                loada = 1'b0;   loads = 1'b0;
                loadb = 1'b1;   w = 1'b0;
            end
            `Pass: begin    // pass shifted value of B into C by adding value 0 instead of A
                nsel = 3'b000;  asel = 1'b1;
                vsel = 2'b00;   bsel = 1'b0;
                write = 1'b0;   loadc = 1'b1;
                loada = 1'b0;   loads = 1'b0;
                loadb = 1'b0;   w = 1'b0;
            end
            `Sub: begin     // does not update C, only update status register by setting loads = 1
                nsel = 3'b000;  asel = 1'b0;
                vsel = 2'b00;   bsel = 1'b0;
                write = 1'b0;   loadc = 1'b0;
                loada = 1'b0;   loads = 1'b1;
                loadb = 1'b0;   w = 1'b0;
            end
            `Operate: begin // load C register with result from ALU
                nsel = 3'b000;  asel = 1'b0;
                vsel = 2'b00;   bsel = 1'b0;
                write = 1'b0;   loadc = 1'b1;
                loada = 1'b0;   loads = 1'b0;
                loadb = 1'b0;   w = 1'b0;
            end
            `WriteReg: begin   // write data from C into Rd
                nsel = 3'b010;  asel = 1'b0;
                vsel = 2'b00;   bsel = 1'b0;
                write = 1'b1;   loadc = 1'b0;
                loada = 1'b0;   loads = 1'b0;
                loadb = 1'b0;   w = 1'b0;
            end
            `WriteImm: begin    // write immediate input into Rn
                nsel = 3'b001;  asel = 1'b0;
                vsel = 2'b10;   bsel = 1'b0;
                write = 1'b1;   loadc = 1'b0;
                loada = 1'b0;   loads = 1'b0;
                loadb = 1'b0;   w = 1'b0;
            end
	
            default: begin
                nsel = 3'bx;  asel = 1'bx;
                vsel = 2'bx;   bsel = 1'bx;
                write = 1'bx;   loadc = 1'bx;
                loada = 1'bx;   loads = 1'bx;
                loadb = 1'bx;   w = 1'bx;
            end
        endcase
    end
endmodule
