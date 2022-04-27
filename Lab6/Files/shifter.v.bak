module shifter(in,shift,sout);
  input [15:0] in;
  input [1:0] shift;
  output [15:0] sout;

  reg[15:0] sout;

  // Shifter instructions with according 2bit inputs. 
  always@(*) begin
    casex(shift)
	2'b00: sout = in;
	2'b01: sout = {in[14:0], 1'b0}; // LSB = 0
	2'b10: sout = {1'b0, in[15:1]}; // MSB = 0
	2'b11: sout = {in[15], in[15:1]}; //  MSB = in[15]
    endcase
  end
endmodule 