`define MWRITE 2'b01
`define MREAD 2'b10
`define MNONE 2'b00

module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
  input [3:0] KEY;
  input [9:0] SW;
  output [9:0] LEDR; 
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

  wire[15:0] dout, din, write_data, read_data;
  wire [8:0] mem_addr, PC;
  wire [7:0] read_address = mem_addr[7:0];
  wire [7:0] write_address = mem_addr[7:0];
  wire [4:0] state;
  wire [1:0] mem_cmd;
  wire wout, rout, msel, write, tri_s, tri_sw; 				
 		
  wire clk = ~KEY[0];
  wire reset = ~KEY[1];

  RAM MEM(clk, read_address, write_address, write, din, dout);
  assign din = write_data;				// RAM, din
  assign read_data = tri_s ? dout : {16{1'bz}};		// RAM, dout - tristate
  assign tri_s = (mem_cmd == `MREAD) && (mem_addr[8] == 1'b0); //sets the enable for the tristate buffer connected to output of dout
  assign write = (mem_cmd ==`MWRITE) && (mem_addr[8] == 0); //tells whether or not we are writing


  assign tri_sw = ((mem_cmd == `MREAD)&&(mem_addr == 9'h140)); //connects the input switches to read_data
  assign read_data[7:0] = tri_sw ? SW[7:0] : {8{1'bz}}; //tristate, read_data

  cpu CPU(clk, reset, read_data, write_data, N, V, Z, w, mem_addr, mem_cmd, PC, state);
  Comp #(2) MW(2'b01, mem_cmd, weq); 	// write comparator
  Comp #(2) MR(2'b10, mem_cmd, req); 	// read(tri-state) comparator
  Comp #(1) MS(1'b0, mem_addr[8], msel); 	// 1'b0(tri-state) comparator

  

 endmodule


// Memory, SS11
module RAM(clk, read_address, write_address, write, din, dout);
  parameter data_width = 16;
  parameter addr_width = 8;
  parameter filename = "data.txt";

  input     clk, write;
  input     [7:0] read_address, write_address;
  input     [15:0] din;
  output    [15:0] dout;
  reg       [15:0] dout;

  reg       [15:0] mem [2**7:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; 
  end
endmodule


// Comparator, SS8
module Comp(a, b, eq) ;
  parameter k=8;
  input     [k-1:0] a,b;
  output    eq;
  wire      eq;

  assign eq = (a==b) ;
endmodule


// Hex 
module sseg(in,segs);
  input [5:0] in;
  output reg [6:0] segs;

  always@(*) begin
    case(in)
      6'b000000: segs = 7'b1000000; // 0
      6'b000001: segs = 7'b1111001; // 1
      6'b000010: segs = 7'b0100100; // 2
      6'b000011: segs = 7'b0110000; // 3
      6'b000100: segs = 7'b0011001; // 4
      6'b000101: segs = 7'b0010010; // 5
      6'b000110: segs = 7'b0000010; // 6
      6'b000111: segs = 7'b1111000; // 7
      6'b001000: segs = 7'b0000000; // 8
      6'b001001: segs = 7'b0011000; // 9
      6'b001010: segs = 7'b0001000; // A (10)
      6'b001011: segs = 7'b0000011; // B (11)
      6'b001100: segs = 7'b1000110; // C (12)
      6'b001101: segs = 7'b0100001; // D (13)
      6'b001110: segs = 7'b0000110; // E (14)
      6'b001111: segs = 7'b0001110; // F (15)
      6'b100000: segs = 7'b0000010; // G
      6'b100001: segs = 7'b0001001; // H
      6'b100010: segs = 7'b1111001; // I
      6'b100011: segs = 7'b1110001; // J
      6'b100100: segs = 7'b0001001; // K
      6'b100101: segs = 7'b1000111; // L
      6'b100110: segs = 7'b1111111; // M - WHAT?
      6'b100111: segs = 7'b1001000; // N
      6'b101000: segs = 7'b1000000; // O
      6'b101001: segs = 7'b0001100; // P
      6'b101010: segs = 7'b0011000; // Q
      6'b101011: segs = 7'b1001110; // R
      6'b101100: segs = 7'b0010010; // S
      6'b101101: segs = 7'b0000111; // T
      6'b101110: segs = 7'b1000001; // U
      6'b101111: segs = 7'b1100011; // V
      6'b110000: segs = 7'b1111111; // W - WHAT?
      6'b110001: segs = 7'b0101101; // X
      6'b110010: segs = 7'b0011001; // Y
      6'b110011: segs = 7'b0100100; // Z
      6'b111111: segs = 7'b1111111; //
   default: segs = 7'b1000000; //displays nothing
    endcase
  end
endmodule





