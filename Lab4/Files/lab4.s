.include "address_map_arm.s"
.text
.globl binary_search

//R0 -> numbers
//R1 -> value to search (key)
//R2 -> length of the array
//R3 -> End of an array
//R4 -> middle_index
//R5 -> numbers[middle_index]
//R6 -> key_index
//R7 -> Key
//R8 -> NumCalls
//R9 -> LEDR
//R10 -> 
//R11 -> Start of an array
//R12 -> index for num calls
//R13 -> reversed num calls
//R14 -> link register


binary_search:
	MOV R11, #0						// Start
	SUB R3, R2, #1					// End index
	MOV R4, R3, LSR #1				// middle_index
	MOV R6, #-1						// key_index
	MOV R8, #1						// NumCalls
	
Loop:
	cmp R6, #-1						// start of the while loop: while (k == -1) 		
	BNE Return
	
	cmp R11, R3						// first if statement: if (s > e)
	BLE IF
	B Return

	
	IF:
		LDR R5, [R0, R4, LSL #2]	// initialize numbers[middle_index]
		cmp R5, R7
		BNE ELSE_IF					// first else_if statement else if (numbers[middle_index] == key)

		MOV R6, R4					// update key index
		
		MVN R13, R8					// reverse R8
		ADD R13, R13, #1			// adjust R13 value to match -1 continuum
		STR R13, [R0, R4, LSL #2]	// store R13 into numbers[middle_index]
		
		B L							// code after else statement

		
	ELSE_IF:
		LDR R5, [R0, R4, LSL #2]
		cmp R5, R7
		BLE ELSE					// second else_if statement else if (numbers[middle_index] > key)
			
		SUB R4, R4, #1				
		MOV R3, R4					// update end index
		
		ADD R12, R4, #1				// adjust R12 value to match the index
		MVN R13, R8					// ^
		ADD R13, R13, #1
		STR R13, [R0, R12, LSL #2]

		ADD R8, R8, #1				// increment R8

		B L							// ^


	ELSE:
		ADD R4, R4, #1				
		MOV R11, R4					// update start index

		SUB R12, R4, #1				// ^
		MVN R13, R8
		ADD R13, R13, #1
		STR R13, [R0, R12, LSL #2]

		ADD R8, R8, #1				// ^

		B L							// ^


	L:	
		SUB R10, R3, R11			
		ADD R4, R11, R10, LSR #1	// update middle_index = s + (e-s)/2

		B Loop						// continue while loop if not satisfied 
		
Return:	

	MOV R0, R6						// return R0
	MOV PC, LR						// return to function




