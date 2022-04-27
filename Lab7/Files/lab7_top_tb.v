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
    $display("PC is %b, expected xxxxxxxxx", lab7_top_tb.DUT.CPU.PC);
    #10; // wait until next falling edge of clock
    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4
    $display("PC is %b, expected xxxxxxxxx", lab7_top_tb.DUT.CPU.PC);
    #10; // waiting for RST state to cause reset of PC
    $display("PC is %b, expected 000000000", lab7_top_tb.DUT.CPU.PC);
    // NOTE: your program counter register output should be called PC and be inside a module with instance name CPU
    if (DUT.CPU.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // PC = 1

    SW[7:0] = 8'b00000001;
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; expect PC set to 2 *before* executing MOV R0, SW_ BASE
    $display("PC is %b, expected 000000010", lab7_top_tb.DUT.CPU.PC);
    $display("Register 0 is %h", lab7_top_tb.DUT.CPU.DP.REGFILE.R0);
    if (DUT.CPU.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'h8) begin err = 1; $display("FAILED: R0 should be 8."); $stop; end  // because MOV R0, X should have occurred
    #95; //  wait 9 clocks

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; expect PC set to 3 *after* executing LDR R0, [R0]
    $display("PC is %b, expected 00000011", lab7_top_tb.DUT.CPU.PC);
    $display("Register 0 is %h", lab7_top_tb.DUT.CPU.DP.REGFILE.R0);
    if (DUT.CPU.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 3."); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'h140) begin err = 1; $display("FAILED: R0 should be h'140."); $stop; end


    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; expect PC set to 4 *after* executing LDR R2, [R0]
    $display("PC is %b, expected 000000100", lab7_top_tb.DUT.CPU.PC);
    $display("Register 2 is %h", lab7_top_tb.DUT.CPU.DP.REGFILE.R2);
    if (DUT.CPU.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 4."); $stop; end
    if (DUT.CPU.DP.REGFILE.R2 !== 16'h1) begin err = 1; $display("FAILED: R2 should be 1."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; expect PC set to 5 *after* executing MOV R3, R2, LSL #1
    $display("PC is %b, expected 000000101", lab7_top_tb.DUT.CPU.PC);
    $display("Register 1 is %h", lab7_top_tb.DUT.CPU.DP.REGFILE.R1);
    if (DUT.CPU.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 5."); $stop; end
    if (DUT.CPU.DP.REGFILE.R3 !== 16'h2) begin err = 1; $display("FAILED: R3 should be 2."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; expect PC set to 6 *after* executing MOV R1, LEDR_BASE
    $display("PC is %b, expected 000000110", lab7_top_tb.DUT.CPU.PC);
    $display("Register 1 is %h", lab7_top_tb.DUT.CPU.DP.REGFILE.R1);
    if (DUT.CPU.PC !== 9'h6) begin err = 1; $display("FAILED: PC should be 6."); $stop; end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'h9) begin err = 1; $display("FAILED: R1 should be h'"); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; expect PC set to 7 *after* executing LDR R1, [R1]
    $display("PC is %b, expected 000000111", lab7_top_tb.DUT.CPU.PC);
    // $display("Memory 6 is %h", lab7_top_tb.DUT.MEM.mem[6]);
    if (DUT.CPU.PC !== 9'h7) begin err = 1; $display("FAILED: PC should be 7."); $stop; end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'h100) begin err = 1; $display("FAILED: R1 should be h'100"); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; expect PC set to 8 *after* executing STR R3, [R1]
    $display("PC is %b, expected 000001000", lab7_top_tb.DUT.CPU.PC);
    // $display("Register 1 is %h", lab7_top_tb.DUT.CPU.DP.REGFILE.R1);
    if (DUT.CPU.PC !== 9'h8) begin err = 1; $display("FAILED: PC should be 8."); $stop; end
    // if (DUT.CPU.DP.REGFILE.R1 !== 16'h100) begin err = 1; $display("FAILED: R3 should be h'100"); $stop; end
    if (LEDR[7:0] !== 8'b00000010) begin err =1; $display("FAILED: Your LEDR output is not right."); $stop; end

    // NOTE: if HALT is working, PC won't change again...
    #10; // check for halt state

    if (~err) $display("INTERFACE OK");
    $stop;
  end
endmodule
