module datapath_tb();
reg[15:0] datapath_in;
reg [2:0] writenum, readnum;
reg [1:0] ALUop, shift;
reg write, clk, vsel, loada, loadb, bsel, asel, loadc, loads;
wire [15:0] datapath_out;
wire Z;


reg err;

datapath dut(datapath_in, vsel, writenum, write, readnum, clk, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, Z_out, datapath_out);

initial begin
  err = 0;

  //MOV R0, #7 ; this means, take the absolute number 7 and store it in R0
  //MOV R1, #2 ; this means, take the absolute number 2 and store it in R1
  //ADD R2, R1, R0, LSL#1 ; this means R2 = R1 + (R0 shifted left by 1) = 2+14=16

  vsel = 1'b1;
  datapath_in = 16'b0000000000000111; 	// 7
  writenum = 3'b000;			// MOV R0, #7
  write = 1'b1; #1
  clk = 1'b1; #1
  clk =1'b0;
  write = 1'b0;

  #3

  vsel = 1'b1;
  datapath_in = 16'b0000000000000010; 	// 2
  writenum = 3'b001;			// MOV R1, #2
  write = 1'b1; #1
  clk = 1'b1; #1
  clk =1'b0;
  write = 1'b0;

  #3

  readnum = 3'b000;			// loadb = 7
  loadb = 1'b1; #1
  clk = 1'b1; #1
  clk =1'b0;
  loadb = 1'b0;
  readnum = 3'b001;			// loada = 2
  loada = 1'b1; #1
  clk = 1'b1; #1
  clk =1'b0;
  loada = 1'b0;

  #3

  shift = 2'b01;			// shift by 1 to L 7 -> 14
  asel = 1'b0;				// a&b MUX
  bsel = 1'b0;

  ALUop = 2'b00;			// add 2+14
  loadc = 1'b1; #1			// c = 16
  loads = 1'b1; #1  

  clk = 1'b1; #1			// datapath_out = 16
  clk =1'b0;
  loadc = 1'b0;

  if (datapath_out != 16'b0000000000010000) begin
	err = 1; end
  
  #3

  vsel = 1'b0;
  writenum = 3'b010;			// MOV R2, #16
  write = 1'b1; #1
  clk = 1'b1; #1
  clk =1'b0;
  write = 1'b0;

  if (err != 1) begin
  $display("all test passed!");
  end

end
endmodule
