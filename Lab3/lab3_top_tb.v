module lab3_top_tb();

  reg [3:0] SW;
  reg [3:0] KEY;
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
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

  lab3_top dut(SW,KEY,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,LEDR);

initial begin // clk inputs
  KEY[0] = 1; #5;
  forever begin
    KEY[0] = 0; #5;
    KEY[0] = 1; #5;
  end
end


initial begin 
// state machine

// check reset
KEY[3] = 0;
SW = 4'b0000;
err = 1'b0;
#10;
if (lab3_top_tb.dut.state !== `W0) begin
	err = 1'b1;
end
$display("Checking Open lock:");
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W0);
KEY[3] = 1;


// *Comments of each state changes & test condiditons are extensively displayed in the transcript!


// Checking OPEN lock sequence.
$display("Checking `W0 -> `W1");
SW = 4'b0110; 
#10;
if (lab3_top_tb.dut.state !== `W1) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W1);

$display("Checking `W1 -> `W2");
SW = 4'b1001; 
#10;
if (lab3_top_tb.dut.state !== `W2) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W2);

$display("Checking `W2 -> `W3");
SW = 4'b0011; 
#10;
if (lab3_top_tb.dut.state !== `W3) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W3);

$display("Checking `W3 -> `W4");
SW = 4'b0000; 
#10;
if (lab3_top_tb.dut.state !== `W4) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W4);

$display("Checking `W4 -> `W5");
SW = 4'b0000; 
#10;
if (lab3_top_tb.dut.state !== `W5) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W5);

$display("Checking `W5 -> `S1");
SW = 4'b0010; 
#10;
if (lab3_top_tb.dut.state !== `S1) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `S1);
// Open lock test ends.




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);





//Checking OPEN HEXs.
$display("Checking OPEN HEXs:");
if (lab3_top_tb.dut.HEX0 !== 7'b0101011) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b0101011);
if (lab3_top_tb.dut.HEX1 !== 7'b0000110) begin
	err = 1'b1;
end
$display("Curruent HEX1 value is %b, expected %b", lab3_top_tb.dut.HEX1, 7'b0000110);
if (lab3_top_tb.dut.HEX2 !== 7'b0001100) begin
	err = 1'b1;
end
$display("Curruent HEX2 value is %b, expected %b", lab3_top_tb.dut.HEX2, 7'b0001100);

if (lab3_top_tb.dut.HEX3 !== 7'b1000000) begin
	err = 1'b1;
end
$display("Curruent HEX3 value is %b, expected %b", lab3_top_tb.dut.HEX3, 7'b1000000);




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);




 //Checking CLOSED lock sequences.
	// First, wrong key inputs from a OPEN lock state.
$display("Checking wroing key input states:");
$display("Checking `W0 -> `W6");
lab3_top_tb.dut.state = `W0;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (lab3_top_tb.dut.state !== `W6) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W6);

$display("Checking `W1 -> `W7");
lab3_top_tb.dut.state = `W1;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (lab3_top_tb.dut.state !== `W7) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W7);

$display("Checking `W2 -> `W8");
lab3_top_tb.dut.state = `W2;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (lab3_top_tb.dut.state !== `W8) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W8);

$display("Checking `W3 -> `W9");
lab3_top_tb.dut.state = `W3;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (lab3_top_tb.dut.state !== `W9) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W9);

$display("Checking `W4 -> `W10");
lab3_top_tb.dut.state = `W4;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (lab3_top_tb.dut.state !== `W10) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W10);

$display("Checking `W5 -> `S0");
lab3_top_tb.dut.state = `W5;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (lab3_top_tb.dut.state !== `S0) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `S0);
	//Wrong key ends.




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);





//Checking CLOSED HEXs.
$display("Checking CLOSED HEXs:");
if (lab3_top_tb.dut.HEX0 !== 7'b0100001) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b0100001);
if (lab3_top_tb.dut.HEX1 !== 7'b0000110) begin
	err = 1'b1;
end
$display("Curruent HEX1 value is %b, expected %b", lab3_top_tb.dut.HEX1, 7'b0000110);
if (lab3_top_tb.dut.HEX2 !== 7'b0010010) begin
	err = 1'b1;
end
$display("Curruent HEX2 value is %b, expected %b", lab3_top_tb.dut.HEX2, 7'b0010010);

if (lab3_top_tb.dut.HEX3 !== 7'b1000000) begin
	err = 1'b1;
end
$display("Curruent HEX3 value is %b, expected %b", lab3_top_tb.dut.HEX3, 7'b1000000);

if (lab3_top_tb.dut.HEX4 !== 7'b1000111) begin
	err = 1'b1;
end
$display("Curruent HEX4 value is %b, expected %b", lab3_top_tb.dut.HEX4, 7'b1000111);

if (lab3_top_tb.dut.HEX5 !== 7'b1000110) begin
	err = 1'b1;
end
$display("Curruent HEX5 value is %b, expected %b", lab3_top_tb.dut.HEX5, 7'b1000110);




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);





	// Second, any key inputs at CLOSED lock states. 
$display("Checking don't care states:");
$display("Checking `W6 -> `W7");
lab3_top_tb.dut.state = `W6;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (lab3_top_tb.dut.state !== `W7) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W7);

$display("Checking `W7 -> `W8");
lab3_top_tb.dut.state = `W7;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (lab3_top_tb.dut.state !== `W8) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W8);

$display("Checking `W8 -> `W9");
lab3_top_tb.dut.state = `W8;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (lab3_top_tb.dut.state !== `W9) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W9);

$display("Checking `W9 -> `W10");
lab3_top_tb.dut.state = `W9;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (lab3_top_tb.dut.state !== `W10) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `W10);

$display("Checking `W10 -> `S0");
lab3_top_tb.dut.state = `W10;
SW = 4'b1111; //using chosen input other than the keys.   
#10;
if (lab3_top_tb.dut.state !== `S0) begin
	err = 1'b1;
end
$display("Curruent state is %b, expected %b.", lab3_top_tb.dut.state, `S0);
	// Don't care check ends.
//Cloed lock check ends.




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);





//Checking CLOSED HEXs.
$display("Checking CLOSED HEXs:");
if (lab3_top_tb.dut.HEX0 !== 7'b0100001) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b0100001);
if (lab3_top_tb.dut.HEX1 !== 7'b0000110) begin
	err = 1'b1;
end
$display("Curruent HEX1 value is %b, expected %b", lab3_top_tb.dut.HEX1, 7'b0000110);
if (lab3_top_tb.dut.HEX2 !== 7'b0010010) begin
	err = 1'b1;
end
$display("Curruent HEX2 value is %b, expected %b", lab3_top_tb.dut.HEX2, 7'b0010010);

if (lab3_top_tb.dut.HEX3 !== 7'b1000000) begin
	err = 1'b1;
end
$display("Curruent HEX3 value is %b, expected %b", lab3_top_tb.dut.HEX3, 7'b1000000);

if (lab3_top_tb.dut.HEX4 !== 7'b1000111) begin
	err = 1'b1;
end
$display("Curruent HEX4 value is %b, expected %b", lab3_top_tb.dut.HEX4, 7'b1000111);

if (lab3_top_tb.dut.HEX5 !== 7'b1000110) begin
	err = 1'b1;
end
$display("Curruent HEX5 value is %b, expected %b", lab3_top_tb.dut.HEX5, 7'b1000110);




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);



// Checking HEX behavior to the switch changes.  
$display("Checking HEX0 behavior when SW < 0"); // When SW < 9
$display("Checking 0");
lab3_top_tb.dut.state = `W0; // reset the state
SW = 4'b0000; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (lab3_top_tb.dut.HEX0 !== 7'b1000000) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b1000000);

$display("Checking 1");
lab3_top_tb.dut.state = `W0; // reset the state
SW = 4'b0001; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (lab3_top_tb.dut.HEX0 !== 7'b1111001) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b1111001);

$display("Checking 2");
lab3_top_tb.dut.state = `W0; // reset the state
SW = 4'b0010; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (lab3_top_tb.dut.HEX0 !== 7'b0100100) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b0100100);

$display("Checking 3");
lab3_top_tb.dut.state = `W0; // reset the state
SW = 4'b0011; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (lab3_top_tb.dut.HEX0 !== 7'b0110000) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b0110000);

$display("Checking 4");
lab3_top_tb.dut.state = `W0; // reset the state
SW = 4'b0100; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (lab3_top_tb.dut.HEX0 !== 7'b0011001) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b0011001);

$display("Checking 5");
lab3_top_tb.dut.state = `W0; // reset the state
SW = 4'b0101; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (lab3_top_tb.dut.HEX0 !== 7'b0010010) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b0010010);

$display("Checking 6");
lab3_top_tb.dut.state = `W0; // reset the state
SW = 4'b0110; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (lab3_top_tb.dut.HEX0 !== 7'b0000010) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b0000010);

$display("Checking 7");
lab3_top_tb.dut.state = `W0; // reset the state
SW = 4'b0111; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (lab3_top_tb.dut.HEX0 !== 7'b1111000) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b1111000);

$display("Checking 8");
lab3_top_tb.dut.state = `W0; // reset the state
SW = 4'b1000; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (lab3_top_tb.dut.HEX0 !== 7'b0000000) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b0000000);

$display("Checking 9");
lab3_top_tb.dut.state = `W0; // reset the state
SW = 4'b1001; // 4bit switch input  in acceding order from 0 to 9.
#10;
if (lab3_top_tb.dut.HEX0 !== 7'b0010000) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b0010000);




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);




$display("Checking HEX0 behavior when SW > 9:"); // When SW > 9, 3 examples (10, 11, 15)
$display("Checking 10");
lab3_top_tb.dut.state = `W0; // reset the state
SW = 4'b1010; // 4bit switch input of 10.
#10;
if (lab3_top_tb.dut.HEX0 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b0101111);

if (lab3_top_tb.dut.HEX1 !== 7'b1000000) begin
	err = 1'b1;
end
$display("Curruent HEX1 value is %b, expected %b", lab3_top_tb.dut.HEX1, 7'b1000000);

if (lab3_top_tb.dut.HEX2 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX2 value is %b, expected %b", lab3_top_tb.dut.HEX2, 7'b0101111);

if (lab3_top_tb.dut.HEX3 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX3 value is %b, expected %b", lab3_top_tb.dut.HEX3, 7'b0101111);

if (lab3_top_tb.dut.HEX4 !== 7'b0000110) begin
	err = 1'b1;
end
$display("Curruent HEX4 value is %b, expected %b", lab3_top_tb.dut.HEX4, 7'b0000110);

$display("Checking 11");
lab3_top_tb.dut.state = `W0; // reset the state
SW = 4'b1011; // 4bit switch input of 11.
#10;
if (lab3_top_tb.dut.HEX0 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b0101111);

if (lab3_top_tb.dut.HEX1 !== 7'b1000000) begin
	err = 1'b1;
end
$display("Curruent HEX1 value is %b, expected %b", lab3_top_tb.dut.HEX1, 7'b1000000);

if (lab3_top_tb.dut.HEX2 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX2 value is %b, expected %b", lab3_top_tb.dut.HEX2, 7'b0101111);

if (lab3_top_tb.dut.HEX3 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX3 value is %b, expected %b", lab3_top_tb.dut.HEX3, 7'b0101111);

if (lab3_top_tb.dut.HEX4 !== 7'b0000110) begin
	err = 1'b1;
end
$display("Curruent HEX4 value is %b, expected %b", lab3_top_tb.dut.HEX4, 7'b0000110);

$display("Checking 15");
lab3_top_tb.dut.state = `W0; // reset the state
SW = 4'b1111; // 4bit switch input for 15.
#10;
if (lab3_top_tb.dut.HEX0 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX0 value is %b, expected %b", lab3_top_tb.dut.HEX0, 7'b0101111);

if (lab3_top_tb.dut.HEX1 !== 7'b1000000) begin
	err = 1'b1;
end
$display("Curruent HEX1 value is %b, expected %b", lab3_top_tb.dut.HEX1, 7'b1000000);

if (lab3_top_tb.dut.HEX2 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX2 value is %b, expected %b", lab3_top_tb.dut.HEX2, 7'b0101111);

if (lab3_top_tb.dut.HEX3 !== 7'b0101111) begin
	err = 1'b1;
end
$display("Curruent HEX3 value is %b, expected %b", lab3_top_tb.dut.HEX3, 7'b0101111);

if (lab3_top_tb.dut.HEX4 !== 7'b0000110) begin
	err = 1'b1;
end
$display("Curruent HEX4 value is %b, expected %b", lab3_top_tb.dut.HEX4, 7'b0000110);




// Check error.
$display("Curruent error %b, expected %b.\n", err, 1'b0);



// If no errors are detected, display that all tests are passed. 
if(err == 1'b0) begin
$display("All tests passed!");
end

$stop;

end
endmodule
