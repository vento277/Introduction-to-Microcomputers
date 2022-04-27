module shifter_tb();
  reg [15:0] in;
  reg [1:0] shift;
  reg [15:0] sout;

  reg err;

  always@(*) begin
    casex(shift)
	2'b00: sout = in;
	2'b01: sout = {in[14:0], 1'b0};
	2'b10: sout = {1'b0, in[15:1]};
	2'b11: sout = {in[15], in[15:1]};
    endcase
  end

  initial begin
  err = 0;

  // Test shifter with same in value to simplify the comparison
  in = 16'b1111000011001111; 
  shift = 2'b00;	// +	
  #1;
  if (sout != 16'b1111000011001111) begin
    err = 1;
    $display("error found!: 00");
  end

  #5;
  
  in = 16'b1111000011001111; 
  shift = 2'b01;	// Shift 1 L, LSB = 0
  #1;
  if (sout != 16'b1110000110011110) begin
    err = 1;
    $display("error found!: 01");
  end

  #5;

  in = 16'b1111000011001111; 
  shift = 2'b10;	// Shift 1 R, MSB = 0
  #1;
  if (sout != 16'b0111100001100111) begin
    err = 1;
    $display("error found!: 01");
  end

  #5;

  in = 16'b0111000011001111; 
  shift = 2'b11;	// Shift 1 R, MSB = B[15]
  #1;
  if (sout != 16'b1111100001100111) begin
    err = 1;
    $display("error found!: 01");
  end

  #5;

  if (err != 1) begin
  $display("all test passed!");
  end


$stop;


  end
endmodule
