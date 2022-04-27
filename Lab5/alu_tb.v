// Testbench module.
module ALU_tb();

  reg [15:0] Ain, Bin;
  reg[1:0] ALUop;
  wire [15:0] out;
  wire Z;

  reg err;


  alu U0(Ain, Bin, ALUop, out, Z);

  initial begin
    err = 0;
   
    // Autograder Test.
    Ain = 16'h42;
    Bin = 16'h13;
    ALUop = 2'b00;
    #5;
    if (Z != 1'b0) begin
	err = 1;
    end

    // Test all ALU operations with same A_in & B_in to simplify the comparison. 
    Ain = 16'b0000000000000001; //1
    Bin = 16'b0000000000000101; //5
    ALUop = 2'b00; 		//A+B
    #5;
    if (out != 16'b0000000000000110) begin
	err = 1;
        $display("error found!: 00");
    end

    if (Z != 1'b0) begin
	err = 1;
    end

    Ain = 16'b0000000000000101; //5
    Bin = 16'b0000000000000001; //1
    ALUop = 2'b01; 		//A-B
    #5;
    if (out != 16'b0000000000000100) begin
	err = 1;
     	$display("error found!: 01");
    end

    Ain = 16'b0000000000000101; //5
    Bin = 16'b0000000000000001; //1
    ALUop = 2'b10; 		// A AND B
    #5;
    if (out != 16'b000000000000001) begin
	err = 1;
     	$display("error found!: 10");
    end

    Ain = 16'b0000000000000101; //5
    Bin = 16'b0000000000000001; //1
    ALUop = 2'b11; 		//NOT B
    #5;
    if (out != 16'b1111111111111110) begin
	err = 1;
     	$display("error found!: 10");
    end

if (err != 1) begin
$display("all test passed!");
end

$stop;







  end
endmodule 