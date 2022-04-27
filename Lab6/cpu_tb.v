module cpu_tb();
  reg [15:0]  in;
  reg         clk, reset, s, load;
  wire [15:0] out;
  wire        N,V,Z,w;

  reg         err;


  cpu DUT(clk, reset, s, load, in, out, N, V, Z, w);

  initial begin		//clk cycle.
    clk = 0; #5;
    forever begin
      clk = 1; #5;
      clk = 0; #5;
    end
  end


  initial begin
    err = 0;
    reset = 1; s = 0; load = 0; in = 16'b0;
    #10;
    reset = 0;
    #10;

    // Test all 4 operations.

    // 11010 000 00000001 	MOV R0, #1
    // 11000 00 001 01 000 	MOV R1, R0, LSL #1
    in = 16'b1101000000000001;	
    load = 1;
    #10
    load = 0;
    s = 1;
    #10
    s = 0;
 
    @(posedge w);
    #10;
    $display("R0: %b", cpu_tb.DUT.DP.REGFILE.R0);
    if (cpu_tb.DUT.DP.REGFILE.R0 !== 16'h1) begin
      err = 1;
      $display("FAILED: MOV R0");
      $stop;
    end

    in = 16'b1100000000101000;	
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0; 

    @(posedge w);
    #10;
    $display("R1: %b", cpu_tb.DUT.DP.REGFILE.R1);
    if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'h2) begin
      err = 1;
      $display("FAILED: MOV R1");
      $stop;
    end

    // 1010000101001000 ADD R2, R1, R0, LSL#1

    in = 16'b1010000101001000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;

    @(posedge w);
    #10;
    $display("ADD, R2: %b", cpu_tb.DUT.DP.REGFILE.R2);
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'h4) begin
      err = 1;
      $display("FAILED");
    end



    // 101 10 010 011 01 000 AND R3, R2, R0, LSL#1

    in = 16'b1011001001101000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;

    @(posedge w); 
    #10;
    $display("AND, R3: %b", cpu_tb.DUT.DP.REGFILE.R3);
    if (cpu_tb.DUT.DP.REGFILE.R3 !== 16'h0) begin
      err = 1;
      $display("FAILED");
    end


    // 10111 000 100 00 010 MVN R4, R2, LSL#1

    in = 16'b1011100010000010;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;

    @(posedge w);
    #10;
    $display("MVN, R4: %b", cpu_tb.DUT.DP.REGFILE.R4);
    if (cpu_tb.DUT.DP.REGFILE.R4 !== ~16'h4) begin
      err = 1;
      $display("FAILED");
    end

    // Zero
    // 10101 010 000 01 000 CMP R2, R2

    in = 16'b1010101000000010;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;

    @(posedge w); // wait for w to go high again
    #10;
    $display("CMP, zero_status: %b", cpu_tb.DUT.status_out);
    if (cpu_tb.DUT.status_out !== 3'b010) begin
      err = 1;
      $display("FAILED");
      $stop;
    end

    // Overflow
    // 11010 101 11111111 MOV R5, #127
    in = 16'b1101010111111111;
    load = 1;
    #10
    load = 0;
    s = 1;
    #10
    s = 0;

    @(posedge w); // wait for w to go high again
    #10
    $display("R5: %b", cpu_tb.DUT.DP.REGFILE.R5);


    // 10101 101 000 00 000 CMP R5, R0,
    in = 16'b1010110100000000 ;
    load = 1;
    #10
    load = 0;
    s = 1;
    #10
    s = 0;

    @(posedge w); // wait for w to go high again
    #10
    $display("CMP, ovf_status: %b", cpu_tb.DUT.status_out);
    if (cpu_tb.DUT.status_out !== 3'b100) begin
      err = 1;
    end
    

    // Negative
    // 10101 101 000 00 000 CMP R5, R0,
    in = 16'b1010110000000101 ;
    load = 1;
    #10
    load = 0;
    s = 1;
    #10
    s = 0;

    @(posedge w); // wait for w to go high again
    #10
    $display("CMP, neg_status: %b", cpu_tb.DUT.status_out);
    if (cpu_tb.DUT.status_out !== 3'b101) begin
      err = 1;
    end
    
 $stop;

  end
endmodule
