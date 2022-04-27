module lab3_top(SW,KEY,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,LEDR);

  input [9:0] SW;
  input [3:0] KEY;
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  output [9:0] LEDR; // optional: use these outputs for debugging on your DE1-SoC

  
  `define W 4 // Switch input. The first col is the state value it is representing and the second col is the numberical value of 4bit input that I used to debug the code. 
  `define W0 4'b0000 // 6	0
  `define W1 4'b0001 // 9	1
  `define W2 4'b0011 // 3	3
  `define W3 4'b0111 // 0	5
  `define W4 4'b1111 // 0	5 without a line. 
  `define W5 4'b1000 // 2	8
  `define W6 4'b1010 // x	0
  `define W7 4'b1001 // x	9
  `define W8 4'b0110 // x	6
  `define W9 4'b0101 //	x	5
  `define W10 4'b1100//		

  `define S0 4'b1100 // Final states where it decides if the lock is open or closed.
  `define S1 4'b1110

// regs and wires used in the code
  reg [`W-1:0] next, state; //define state and next_state
  reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  wire [3:0] SW;

// state machine with clk KEY[0] and reset KEY[3].
  always @(posedge KEY[0]) begin
    if (KEY[3]) begin // states to open the lock & states when incorrect combination in entered
      case (state) /*state, in*/
	`W0: if (SW == 4'b0110)
	state = `W1;
	else
	state = `W6;

	`W1: if (SW == 4'b1001)
	state = `W2;
	else
	state = `W7;

	`W2: if (SW == 4'b0011)
	state = `W3;
	else
	state = `W8;

	`W3: if (SW == 4'b0000)
	state = `W4;
	else
	state = `W9;

	`W4: if (SW == 4'b0000)
	state = `W5;
	else
	state = `W10;

	`W5: if (SW == 4'b0010)
	state = `S1;
	else
	state = `S0;

	`W6: if (SW >= 0) //states when incorrect combination in entered. 
	state = `W7;
	`W7: if (SW >= 0)
	state = `W8;
	`W8: if (SW >= 0)
	state = `W9;
	`W9: if (SW >= 0)
	state = `W10;
	`W10: if (SW >= 0)
	state = `S0;

	default: state = 4'bxxxx;
    endcase
  end

    else begin // reset.
      state = `W0;
    end
  end

  always@(*)begin //turn of all the HEX lights
	HEX0 = 7'b1111111;
	HEX1 = 7'b1111111;
	HEX2 = 7'b1111111;
	HEX3 = 7'b1111111;
	HEX4 = 7'b1111111;
	HEX5 = 7'b1111111;

    if (SW <= 9) begin //the inputs btw 0~9 is displayed on HEX's
	case(SW)
	4'b0000 :HEX0 = 7'b1000000; //0
	4'b0001 :HEX0 = 7'b1111001; //1
	4'b0010 :HEX0 = 7'b0100100; //2 
	4'b0011 :HEX0 = 7'b0110000; //3 
	4'b0100 :HEX0 = 7'b0011001; //4 
	4'b0101 :HEX0 = 7'b0010010; //5 
	4'b0110 :HEX0 = 7'b0000010; //6 
	4'b0111 :HEX0 = 7'b1111000; //7 
	4'b1000 :HEX0 = 7'b0000000; //8 
	4'b1001 :HEX0 = 7'b0010000; //9 
	default HEX0 = 7'b0000000;
	endcase
    end

    else if (SW > 9) begin // if 4-bit input > 9, Hex display's "error."
	HEX4 = 7'b0000110;
	HEX3 = 7'b0101111;
	HEX2 = 7'b0101111;
	HEX1 = 7'b1000000;
	HEX0 = 7'b0101111;
    end

    if (state == `S1) begin // at state S1, display 'open.'
    	HEX3 = 7'b1000000;
    	HEX2 = 7'b0001100;
    	HEX1 = 7'b0000110;
    	HEX0 = 7'b0101011;
    end

    else if (state == `S0) begin // at state S0, display 'closed.'
	HEX5 = 7'b1000110;
	HEX4 = 7'b1000111; 
	HEX3 = 7'b1000000; 
	HEX2 = 7'b0010010; 
	HEX1 = 7'b0000110; 
	HEX0 = 7'b0100001; 
    end
  end
endmodule
