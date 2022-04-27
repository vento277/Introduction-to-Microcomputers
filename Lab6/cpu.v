module cpu(clk, reset, s, load, in, out, N, V, Z, w);
  input clk, reset, s, load;
  input [15:0] in;
  output [15:0] out;
  output N, V, Z, w;

  wire[15:0] ir_out, sximm5, sximm8, mdata, C;
  wire[7:0] PC;
  wire[2:0] opcode, readnum, writenum, nsel, status_out;
  wire[1:0] op, ALUop, shift, vsel;
  wire loada, loadb, loadc, loads, asel, bsel, write; 

`define W 4
`define W0 4'b0000	//wait
`define W1 4'b0001	//decode
`define W2 4'b0010	//instruction
`define W3 4'b0011	//writereg


  // Module Instanciation in order of the diagram
  vDFF_L ir(clk, load, in, ir_out);

  Instruction IR(ir_out, nsel, opcode, op, writenum, readnum, shift, sximm8, sximm5, ALUop);

  FSM SM(clk, s, reset, vsel, loada, loadb, loadc, loads, asel, bsel, write, nsel, w, opcode, op);

  datapath DP(vsel, writenum, write, readnum, clk, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, C, 
		mdata, sximm8, sximm5, PC, status_out);

  // assign status accordingly.
  assign N = status_out[0];
  assign Z = status_out[1];
  assign V = status_out[2];

  // assign out = C, previously datapath_in.
  assign out = C;

endmodule

// State Machine
module FSM(clk, s, reset, vsel, loada, loadb, loadc, loads, asel, bsel, write, nsel, w, opcode, op);
  input clk, s, reset;
  input[1:0] op;
  input[2:0] opcode;

  output loada, loadb, asel, bsel, loadc, loads, write, w;
  output[1:0] vsel;
  output[2:0] nsel;

  reg loada, loadb, asel, bsel, loadc, loads, write, w;
  reg[1:0] vsel;
  reg[2:0] nsel;
  reg[3:0] state, next_state;

 
    always @(posedge clk) begin
    if (reset) begin	// Reset, state = Wait. 
      state = `W0;
      next_state = `W0;
      vsel = 2'b00;
      loada = 1'b0;
      loadb = 1'b0;
      asel = 1'b0;
      bsel = 1'b0;
      loadc = 1'b0;
      loads = 1'b0;
      write = 1'b0;
      nsel = 3'b000;
      w = 1'b1;
    end

    else begin		// Else, go into FSM
      casex ({state, opcode, op})
        {`W0, 3'bxxx, 2'bxx}: if (s) begin
                 next_state = `W1;	// if s = 1, go to decode
                 vsel = 2'b00;
                 loada = 1'b0;
                 loadb = 1'b0;
                 asel = 1'b0;
                 bsel = 1'b0;
                 loadc = 1'b0;
                 loads = 1'b0;
                 write = 1'b0;
                 nsel = 3'b000;
                 w = 1'b0;
               end

               else begin		// if s = 0, go back to itself
                 next_state = `W0;
                 vsel = 2'b00;
                 loada = 1'b0;
                 loadb = 1'b0;
                 asel = 1'b0;
                 bsel = 1'b0;
                 loadc = 1'b0;
                 loads = 1'b0;
                 write = 1'b0;
                 nsel = 3'b000;
                 w = 1'b1;
               end

/*
`define W 4
`define W0 4'b0000	//wait
`define W1 4'b0001	//decode
`define W2 4'b0010	//instruction
`define W3 4'b0011	//writereg
*/

	{`W1, 3'b110, 2'b10} : begin								// Write Imm
			nsel = 3'b100; 
                     	vsel = 2'b10; 
                    	write = 1'b1;
                     	next_state = `W0;  end

	{`W1, 3'b110, 2'b00} : begin								// MOV shift
			nsel = 3'b001;	//Rm
			loada = 1'b0;
			loadb = 1'b1;
			next_state = `W2;							// Operation state
				end


	{`W1, 3'b101, 2'b11} : begin								// MVN
			nsel = 3'b001;	//Rm
			loada = 1'b0;
			loadb = 1'b1;
			next_state = `W2;							// Operation state
				end

	{`W1, 3'b101, 2'b00} : begin								// ADD
			nsel = 3'b100;	//Rn
			loada = 1'b1;
			next_state = `W2;							// Operation state 
				end

	{`W1, 3'b101, 2'b01} : begin								// CMP
			nsel = 3'b100;	//Rn
			loada = 1'b1;
			next_state = `W2;							// Operation state 
				end

	{`W1, 3'b101, 2'b10} : begin								// AND
			nsel = 3'b100;	//Rn
			loada = 1'b1;
			next_state = `W2;							// Operation state 
				end




	{`W2, 3'bx1x, 2'bxx} : begin								// MOV Shifted
                  	asel = 1'b1; // zero
                  	bsel = 1'b0; // sel B
                  	loadb = 1'b0;
                  	loadc = 1'b1;
			next_state = `W3;
				end


	{`W2, 3'b101, 2'b11}: begin								// MVN
                	asel = 1'b1; // zero
                	bsel = 1'b0; // sel B
                	loadb = 1'b0;
                	loadc = 1'b1;
			next_state = `W3;
				end


	{`W2, 3'b101, 2'b00}: begin								// ADD
               		asel = 1'b0; // sel A
                	bsel = 1'b0; // sel B
                	loadb = 1'b0;
                	loadc = 1'b1;
			next_state = `W3;
				end

	{`W2, 3'b101, 2'b01}: begin								// CMP
               		asel = 1'b0; // sel A
                	bsel = 1'b0; // sel B
                	loadb = 1'b0;
                	loadc = 1'b1;
                	loads = 1'b1; 
			next_state = `W3;
				end

	{`W2, 3'b101, 2'b10}: begin								// AND
               	 	asel = 1'b0; // sel A
                	bsel = 1'b0; // sel B
                	loadb = 1'b0;
                	loadc = 1'b1;
			next_state = `W3;
				end


	{`W3, 3'bxxx, 2'bxx} : begin
                     	nsel = 3'b010; // sel Rd
                     	vsel = 2'b00;  // sel C
                     	write = 1'b1;
			next_state = `W0;
				end

	default: state = `W0;

  	endcase
    end
  state = next_state; // current state equals the next state. 
  end
endmodule 

// Instruction decoder
module Instruction(ir_out, nsel, opcode, op, writenum, readnum, shift, sximm8, sximm5, ALUop);
  input[15:0] ir_out;
  input[2:0] nsel;
  output [15:0] sximm5, sximm8;
  output[2:0] opcode, readnum, writenum;
  output[1:0] op, ALUop, shift;

  wire[2:0] Rn, Rd, Rm;
  reg[15:0] sximm8, sximm5;
  reg[2:0] readnum, writenum;

  // Assign input values matching the diagram given. 
  assign opcode = ir_out[15:13]; 
  assign op = ir_out[12:11];
  assign {Rn, Rd, Rm} = {ir_out[10:8], ir_out[7:5], ir_out[2:0]};
  assign shift = ir_out[4:3];
  assign ALUop = ir_out[12:11];

  // get imm5
  always @(*)begin
    case(ir_out[4])
      1'b0 : sximm5 = {11'b0,ir_out[4:0]};
      1'b1 : sximm5 = {11'b1,ir_out[4:0]};
    endcase


  // get imm8
    case (ir_out[7])
      1'b0 : sximm8 = {8'b0,ir_out[7:0]};
      1'b1 : sximm8 = {8'b1,ir_out[7:0]};
    endcase


  // get Rn, Rd, Rm with 3bit MUX
    case(nsel)
      3'b001 : {readnum,writenum}={ir_out[2:0], ir_out[2:0]};  	//Rm
      3'b010 : {readnum,writenum}={ir_out[7:5], ir_out[7:5]};  	//Rd
      3'b100 : {readnum,writenum}={ir_out[10:8], ir_out[10:8]};  //Rn
      default: {readnum,writenum}={3'bxx,3'bxx};
    endcase
  end

endmodule

























































