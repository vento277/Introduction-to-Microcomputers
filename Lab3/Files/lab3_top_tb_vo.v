`timescale 1ps/1ps

module lab3_top_tb();

  reg [3:0] SW;
  reg [3:0] KEY;
  reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  wire [9:0] LEDR;

  reg err;
  
  `define W 4
  `define W0 4'b0000 // 6
  `define W1 4'b0001 // 9
  `define W2 4'b0011 // 3
  `define W3 4'b0111 // 0
  `define W4 4'b1111 // 0
  `define W5 4'b1000 // 2
  `define W6 4'b1010
  `define W7 4'b1001
  `define W8 4'b0110
  `define W9 4'b0101
  `define W10 4'b1100
  `define S0 4'b1100 // Final states where it decides if the lock is open or closed.
  `define S1 4'b1110
// regs and wires used in the code
  reg [`W-1:0] next, state; //define state and next_state

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

// state machine
initial begin // clk inputs
  KEY[0] = 1; #5;
  forever begin
    KEY[0] = 0; #5;
    KEY[0] = 1; #5;
  end
end

initial begin
// check reset
KEY[3] = 0;
SW = 4'b0000;
err = 1'b0;
#10;
if (state !== `W0) begin
	err = 1'b1;
end
$display("Checking Open lock:");
$display("Curruent state is %b, expected %b.", state, `W0);
KEY[3] = 1;


// *Comments of each state changes & test condiditons are extensively displayed in the transcript!


// Checking OPEN lock sequence.
$display("Checking `W0 -> `W1");
SW = 4'b0110; 
#10;
if (state !== `W1) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `W1);

$display("Checking `W1 -> `W2");
SW = 4'b1001; 
#10;
if (state !== `W2) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `W2);

$display("Checking `W2 -> `W3");
SW = 4'b0011; 
#10;
if (state !== `W3) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `W3);

$display("Checking `W3 -> `W4");
SW = 4'b0000; 
#10;
if (state !== `W4) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `W4);

$display("Checking `W4 -> `W5");
SW = 4'b0000; 
#10;
if (state !== `W5) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `W5);

$display("Checking `W5 -> `S1");
SW = 4'b0010; 
#10;
if (state !== `S1) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `S1);
// Open lock test ends.




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);





//Checking OPEN HEXs.
$display("Checking OPEN HEXs:");
if (HEX0 !== 7'b0101011) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b0101011);
if (HEX1 !== 7'b0000110) begin
	err = 1'b1;
end
$display("Curruent HEX1 value is %b, expected %b", HEX1, 7'b0000110);
if (HEX2 !== 7'b0001100) begin
	err = 1'b1;
end
$display("Curruent HEX2 value is %b, expected %b", HEX2, 7'b0001100);

if (HEX3 !== 7'b1000000) begin
	err = 1'b1;
end
$display("Curruent HEX3 value is %b, expected %b", HEX3, 7'b1000000);




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);




 //Checking CLOSED lock sequences.
	// First, wrong key inputs from a OPEN lock state.
$display("Checking wroing key input states:");
$display("Checking `W0 -> `W6");
state = `W0;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (state !== `W6) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `W6);

$display("Checking `W1 -> `W7");
state = `W1;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (state !== `W7) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `W7);

$display("Checking `W2 -> `W8");
state = `W2;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (state !== `W8) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `W8);

$display("Checking `W3 -> `W9");
state = `W3;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (state !== `W9) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `W9);

$display("Checking `W4 -> `W10");
state = `W4;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (state !== `W10) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `W10);

$display("Checking `W5 -> `S0");
state = `W5;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (state !== `S0) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `S0);
	//Wrong key ends.




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);





//Checking CLOSED HEXs.
$display("Checking CLOSED HEXs:");
if (HEX0 !== 7'b0100001) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b0100001);
if (HEX1 !== 7'b0000110) begin
	err = 1'b1;
end
$display("Curruent HEX1 value is %b, expected %b", HEX1, 7'b0000110);
if (HEX2 !== 7'b0010010) begin
	err = 1'b1;
end
$display("Curruent HEX2 value is %b, expected %b", HEX2, 7'b0010010);

if (HEX3 !== 7'b1000000) begin
	err = 1'b1;
end
$display("Curruent HEX3 value is %b, expected %b",HEX3, 7'b1000000);

if (HEX4 !== 7'b1000111) begin
	err = 1'b1;
end
$display("Curruent HEX4 value is %b, expected %b", HEX4, 7'b1000111);

if (HEX5 !== 7'b1000110) begin
	err = 1'b1;
end
$display("Curruent HEX5 value is %b, expected %b", HEX5, 7'b1000110);




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);





	// Second, any key inputs at CLOSED lock states. 
$display("Checking don't care states:");
$display("Checking `W6 -> `W7");
state = `W6;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (state !== `W7) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `W7);

$display("Checking `W7 -> `W8");
state = `W7;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (state !== `W8) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `W8);

$display("Checking `W8 -> `W9");
state = `W8;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (state !== `W9) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `W9);

$display("Checking `W9 -> `W10");
state = `W9;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (state !== `W10) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `W10);

$display("Checking `W10 -> `S0");
state = `W10;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (state !== `S0) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", state, `S0);
	// Don't care check ends.
//Cloed lock check ends.




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);





//Checking CLOSED HEXs.
$display("Checking CLOSED HEXs:");
if (HEX0 !== 7'b0100001) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b0100001);
if (HEX1 !== 7'b0000110) begin
	err = 1'b1;
end
$display("Curruent HEX1 value is %b, expected %b", HEX1, 7'b0000110);
if (HEX2 !== 7'b0010010) begin
	err = 1'b1;
end
$display("Curruent HEX2 value is %b, expected %b", HEX2, 7'b0010010);

if (HEX3 !== 7'b1000000) begin
	err = 1'b1;
end
$display("Curruent HEX3 value is %b, expected %b", HEX3, 7'b1000000);

if (HEX4 !== 7'b1000111) begin
	err = 1'b1;
end
$display("Curruent HEX4 value is %b, expected %b", HEX4, 7'b1000111);

if (HEX5 !== 7'b1000110) begin
	err = 1'b1;
end
$display("Curruent HEX5 value is %b, expected %b", HEX5, 7'b1000110);




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);



// Checking HEX behavior to the switch changes.  
$display("Checking HEX0 behavior when SW < 0"); // When SW < 9
$display("Checking 0");
state = `W0; // reset the state
SW = 4'b0000; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (HEX0 !== 7'b1000000) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b1000000);

$display("Checking 1");
state = `W0; // reset the state
SW = 4'b0001; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (HEX0 !== 7'b1111001) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b1111001);

$display("Checking 2");
state = `W0; // reset the state
SW = 4'b0010; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (HEX0 !== 7'b0100100) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b0100100);

$display("Checking 3");
state = `W0; // reset the state
SW = 4'b0011; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (HEX0 !== 7'b0110000) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b0110000);

$display("Checking 4");
state = `W0; // reset the state
SW = 4'b0100; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (HEX0 !== 7'b0011001) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b0011001);

$display("Checking 5");
state = `W0; // reset the state
SW = 4'b0101; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (HEX0 !== 7'b0010010) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b0010010);

$display("Checking 6");
state = `W0; // reset the state
SW = 4'b0110; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (HEX0 !== 7'b0000010) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b0000010);

$display("Checking 7");
state = `W0; // reset the state
SW = 4'b0111; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (HEX0 !== 7'b1111000) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b1111000);

$display("Checking 8");
state = `W0; // reset the state
SW = 4'b1000; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (HEX0 !== 7'b0000000) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b0000000);

$display("Checking 9");
state = `W0; // reset the state
SW = 4'b1001; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (HEX0 !== 7'b0010000) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b0010000);




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);




$display("Checking HEX0 behavior when SW > 9:"); // When SW > 9, 3 examples (10, 11, 15)
$display("Checking 10");
state = `W0; // reset the state
SW = 4'b1010; // 4bit switch input of 10.
#10;
if (HEX0 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b0101111);

if (HEX1 !== 7'b1000000) begin
	err = 1'b1;
end
$display("Curruent HEX1 value is %b, expected %b", HEX1, 7'b1000000);

if (HEX2 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX2 value is %b, expected %b", HEX2, 7'b0101111);

if (HEX3 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX3 value is %b, expected %b", HEX3, 7'b0101111);

if (HEX4 !== 7'b0000110) begin
	err = 1'b1;
end
$display("Curruent HEX4 value is %b, expected %b", HEX4, 7'b0000110);

$display("Checking 11");
state = `W0; // reset the state
SW = 4'b1011; // 4bit switch input of 11.
#10;
if (HEX0 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b0101111);

if (HEX1 !== 7'b1000000) begin
	err = 1'b1;
end
$display("Curruent HEX1 value is %b, expected %b", HEX1, 7'b1000000);

if (HEX2 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX2 value is %b, expected %b", HEX2, 7'b0101111);

if (HEX3 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX3 value is %b, expected %b", HEX3, 7'b0101111);

if (HEX4 !== 7'b0000110) begin
	err = 1'b1;
end
$display("Curruent HEX4 value is %b, expected %b", HEX4, 7'b0000110);

$display("Checking 15");
state = `W0; // reset the state
SW = 4'b1111; // 4bit switch input for 15.
#10;
if (HEX0 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", HEX0, 7'b0101111);

if (HEX1 !== 7'b1000000) begin
	err = 1'b1;
end
$display("Curruent HEX1 value is %b, expected %b", HEX1, 7'b1000000);

if (HEX2 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX2 value is %b, expected %b", HEX2, 7'b0101111);

if (HEX3 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX3 value is %b, expected %b", HEX3, 7'b0101111);

if (HEX4 !== 7'b0000110) begin
	err = 1'b1;
end
$display("Curruent HEX4 value is %b, expected %b", HEX4, 7'b0000110);




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);



// If no errors are detected, display that all tests are passed. 
if(err == 1'b0) begin
$display("All tests passed!");
end

$stop;

end
endmodule
