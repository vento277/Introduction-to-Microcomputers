module alu(Ain, Bin, ALUop, out, status_out);
  input [15:0] Ain, Bin;
  input [1:0] ALUop;
  output [15:0] out;
  output [2:0] status_out; // Lab 6

  reg [15:0] out;
  
  // ALU instructions with according 2bit input. 
  always@(*) begin
    casex(ALUop)
	2'b00: out = Ain + Bin;
	2'b01: out = Ain - Bin;
	2'b10: out = Ain & Bin;
	2'b11: out = ~Bin;
	default out = 16'd0;
    endcase
  end

  assign status_out[0] = out[15];  	//negative,  	[N]
  assign status_out[1] = out ? 0 : 1; 	//zero,  	[Z]
  assign status_out[2] = Ain ^ Bin;  	//overflow,	[V]

endmodule























