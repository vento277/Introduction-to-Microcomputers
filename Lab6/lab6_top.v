// INSTRUCTIONS:
//
// You can use this file to demo your Lab6 on your DE1-SoC.  
// 
// You will need to fill in the sseg module as by default it will just print
// F's on HEX0 through HEX3.  YOU SHOULD NOT need to change the signal names
// inside the lab6_top module because the auto-grader will assume the same
// interface.


// DE1-SOC INTERFACE SPECIFICATION for lab6_top.v code in this file:
//
// clk input to datpath has rising edge when KEY0 is *pressed* 
//
// HEX5 contains the status register output on the top (Z), middle (N) and
// bottom (V) segment.
//
// HEX3, HEX2, HEX1, HEX0 are wired to out which should show the contents
// of your register C.
//
// When SW[9] is set to 0, SW[7:0] changes the lower 8 bits of the 16-bit 
// input "in". LEDR[8:0] will show the upper 8-bits of 16-bit input "in".
//
// When SW[9] is set to 1, SW[7:0] changes the upper 8 bits of the 16-bit
// input "in". LEDR[8:0] will show the lower 8-bits of 16-bit input "in".
//
// The rising edge of clk occurs at the moment when you press KEY0.
// The input reset is 1 as long as you press (and hold) KEY1.
// The input s is 1 as long as you press (and hold) KEY2.
// The input load is 1 as long as you press (and hold) KEY3.

module lab6_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);
  input [3:0] KEY;
  input [9:0] SW;
  output [9:0] LEDR; 
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  input CLOCK_50;

  wire [15:0] out, ir;
  input_iface IN(CLOCK_50, SW, ir, LEDR[7:0]);

  wire Z, N, V;
  cpu U( .clk   (~KEY[0]), // recall from Lab 4 that KEY0 is 1 when NOT pushed
         .reset (~KEY[1]), 
         .s     (~KEY[2]),
         .load  (~KEY[3]),
         .in    (ir),
         .out   (out),
         .Z     (Z),
         .N     (N),
         .V     (V),
         .w     (LEDR[9]) );

  assign HEX5[0] = ~Z;
  assign HEX5[6] = ~N;
  assign HEX5[3] = ~V;

  // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
  sseg H0(out[3:0],   HEX0);
  sseg H1(out[7:4],   HEX1);
  sseg H2(out[11:8],  HEX2);
  sseg H3(out[15:12], HEX3);
  assign HEX4 = 7'b1111111;
  assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled
  assign LEDR[8] = 1'b0;
endmodule

module input_iface(clk, SW, ir, LEDR);
  input clk;
  input [9:0] SW;
  output [15:0] ir;
  output [7:0] LEDR;
  wire sel_sw = SW[9];  
  wire [15:0] ir_next = sel_sw ? {SW[7:0],ir[7:0]} : {ir[15:8],SW[7:0]};
  vDFF #(16) REG(clk,ir_next,ir);
  assign LEDR = sel_sw ? ir[7:0] : ir[15:8];  
endmodule         

module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;
  always @(posedge clk)
    Q <= D;
endmodule

// The sseg module below can be used to display the value of datpath_out on
// the hex LEDS the input is a 4-bit value representing numbers between 0 and
// 15 the output is a 7-bit value that will print a hexadecimal digit.  You
// may want to look at the code in Figure 7.20 and 7.21 in Dally but note this
// code will not work with the DE1-SoC because the order of segments used in
// the book is not the same as on the DE1-SoC (see comments below).

module sseg(in,segs);
  input [3:0] in;
  output reg [6:0] segs;

always@(*) begin
  case(in)
   4'b0000: segs = 7'b1000000; //displays 0
   4'b0001: segs = 7'b1111001; //displays 1
   4'b0010: segs = 7'b0100100; //displays 2
   4'b0011: segs = 7'b0110000; //displays 3
   4'b0100: segs = 7'b0011001; //displays 4
   4'b0101: segs = 7'b0010010; //displays 5
   4'b0110: segs = 7'b0000010; //displays 6
   4'b0111: segs = 7'b1111000; //displays 7
   4'b1000: segs = 7'b0000000; //displays 8
   4'b1001: segs = 7'b0010000; //displays 9
   4'b1010: segs = 7'b0001000; //displays A
   4'b1011: segs = 7'b0000011; //displays b
   4'b1100: segs = 7'b1000110; //displays C
   4'b1101: segs = 7'b0100001; //displays d
   4'b1110: segs = 7'b0000110; //displays E
   4'b1111: segs = 7'b0001110; //displays F
   default: segs = 7'b1000000; //displays nothing
  endcase
end


endmodule
