// Testbench module.
module regfile_tb();
  reg [2:0] writenum, readnum;
  reg write, clk;
  reg [15:0] data_in;
  wire [15:0] data_out;

  reg err;

  // Instanciate regfile module. 
  regfile dut(data_in, writenum, write, readnum, clk, data_out);

initial begin
  clk = 1'b0;
  err = 0;
 
  // Test registers from 0~7 (in order) with changing data_in's.
  //MOV R0
  data_in = 16'b0000000000000001; 	// 1
  writenum = 3'b000;			// R0
  write = 1'b1;				// write
  #1

  clk = 1'b1;
  #1
  clk = 0'b0;
  write = 1'b0;
  
  readnum = 3'b000;			// read R0

  if (data_out != 16'b0000000000000001) begin
	err = 1;
  end

  #5

 //MOV R1
  data_in = 16'b0000000000000011; 	// Shift data_in 1 left and let LSF to be 1. This is to ensure visibuility of the different tests. 
  writenum = 3'b001;			// ^
  write = 1'b1;				// ^
  #1

  clk = 1'b1;
  #1
  clk = 0'b0;
  write = 1'b0;
  readnum = 3'b001;			// ^
  #1

  if (data_out != 16'b0000000000000011) begin
	err = 1;
  end

  #5

  //MOV R2
  data_in = 16'b0000000000000111; 	// ^
  writenum = 3'b010;			// ^	
  write = 1'b1;				// ^
  #1

  clk = 1'b1;
  #1
  clk = 0'b0;
  write = 1'b0;
  readnum = 3'b010;			// ^
  #1

  if (data_out != 16'b0000000000000111) begin
	err = 1;
  end

  #5

  //MOV R3
  data_in = 16'b0000000000001111; 	// ^
  writenum = 3'b010;			// ^	
  write = 1'b1;				// ^
  #1

  clk = 1'b1;
  #1
  clk = 0'b0;
  write = 1'b0;
  readnum = 3'b010;			// ^
  #1

  if (data_out != 16'b0000000000001111) begin
	err = 1;
  end

  #5

  //MOV R4
  data_in = 16'b0000000000011111; 	// ^
  writenum = 3'b100;			// ^	
  write = 1'b1;				// ^
  #1

  clk = 1'b1;
  #1
  clk = 0'b0;
  write = 1'b0;
  readnum = 3'b100;			// ^
  #1


  if (data_out != 16'b0000000000011111) begin
	err = 1;
  end

  #5
  //MOV R5
  data_in = 16'b0000000000111111; 	// ^
  writenum = 3'b101;			// ^	
  write = 1'b1;				// ^
  #1

  clk = 1'b1;
  #1
  clk = 0'b0;
  write = 1'b0;
  readnum = 3'b101;			// ^
  #1



  if (data_out != 16'b0000000000111111) begin
	err = 1;
  end

  #5

  //MOV R6
  data_in = 16'b0000000001111111; 	// ^
  writenum = 3'b110;			// ^	
  write = 1'b1;				// ^
  #1

  clk = 1'b1;
  #1
  clk = 0'b0;
  write = 1'b0;
  readnum = 3'b110;			// ^
  #1

  if (data_out != 16'b0000000001111111) begin
	err = 1;
  end

  #5
  //MOV R7
  data_in = 16'b0000000111111111; 	// ^
  writenum = 3'b111;			// ^	
  write = 1'b1;				// ^
  #1

  clk = 1'b1;
  #1
  clk = 0'b0;
  write = 1'b0;
  readnum = 3'b111;			// ^
  #1

  if (data_out != 16'b0000000111111111) begin
	err = 1;
  end

  #5
 

  // Error.
  if (err != 1) begin
  $display("all test passed!");
  end

$stop;

end
endmodule










  
