module lab7_top_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;

  lab7_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

  initial forever begin
    KEY[0] = 1; #5;
    KEY[0] = 0; #5;
  end

  initial begin
    err = 0;
    KEY[1] = 1'b0; // reset asserted
    #10; // wait until next falling edge of clock
    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4
    #10; // waiting for RST state to cause reset of PC

    
    // NOTE: your program counter register output should be called PC and be inside a module with instance name CPU
    if (DUT.CPU.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R0, X

    if (DUT.CPU.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 2 *after* executing MOV R0, X...PC increment by 1.

	//MOV R2, #5
    if (DUT.CPU.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end
    if (DUT.CPU.DP.REGFILE.R2 !== 16'h5) begin err = 1; $display("FAILED: R2, #5."); $stop; end  
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // ^
	//MOV R3, R2
    if (DUT.CPU.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 3."); $stop; end
    if (DUT.CPU.DP.REGFILE.R3 !== 16'h5) begin err = 1; $display("FAILED: MOV R3, R2."); $stop; end  

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // ^
	//MOV R4, #10
    if (DUT.CPU.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 4."); $stop; end
    if (DUT.CPU.DP.REGFILE.R4 !== 16'hA) begin err = 1; $display("FAILED: MOV R4, #10."); $stop; end  

  @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // ^
	// CMP R2, R3
    if (DUT.CPU.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 5."); $stop; end
    if (DUT.CPU.stat_out !== 3'b001) begin err = 1; $display("FAILED: CMP R2, R3"); $stop; end  

  @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // ^
	// AND R6, R2, R3
    if (DUT.CPU.PC !== 9'h6) begin err = 1; $display("FAILED: PC should be 6."); $stop; end
    if (DUT.CPU.DP.REGFILE.R6 !== 16'h5) begin err = 1; $display("FAILED: AND R6, R2, R3"); $stop; end 


  @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // ^
	// MVN R7, R4, LSL#1
    if (DUT.CPU.PC !== 9'h7) begin err = 1; $display("FAILED: PC should be 7."); $stop; end
    if (DUT.CPU.DP.REGFILE.R7 !== 16'hFFEB) begin err = 1; $display("FAILED: MVN R7, R4, LSL#1"); $stop; end 


  @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // ^
	// LDR R2, [R3]
    if (DUT.CPU.PC !== 9'h8) begin err = 1; $display("FAILED: PC should be 8."); $stop; end
    if (DUT.CPU.DP.REGFILE.R2 !== 16'hB8EC) begin err = 1; $display("FAILED: LDR R2, [R3]"); $stop; end 

 @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // ^
	// LDR R3, [R4]
    if (DUT.CPU.PC !== 9'h9) begin err = 1; $display("FAILED: PC should be 9."); $stop; end
    if (DUT.CPU.DP.REGFILE.R3 !== 16'hE000) begin err = 1; $display("FAILED: LDR R3, [R4]"); $stop; end

 @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // ^
	// STR R4, [R5]
    if (DUT.CPU.PC !== 9'hA) begin err = 1; $display("FAILED: PC should be 10."); $stop; end
    if (DUT.MEM.mem[9] !== 16'h86A0) begin err = 1; $display("FAILED: STR R4, [R5]"); $stop; end 

 @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // ^
	// STR R4, [R5]
    if (DUT.CPU.PC !== 9'hB) begin err = 1; $display("FAILED: PC should be 11."); $stop; end
    if (DUT.MEM.mem[10] !== 16'hE000) begin err = 1; $display("FAILED: STR R5, [R6]"); $stop; end 



    // NOTE: if HALT is working, PC won't change again...

    if (~err) $display("All test passed (MOV, CMP, AND, MVN, LDR, STR)");
    $stop;
  end
endmodule


















