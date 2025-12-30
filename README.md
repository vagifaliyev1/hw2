# Methodology
Step-by-step Process

## Hex to Binary Conversion
The first step of the reverse engineering process was converting each hexadecimal instruction from the given dump into its 32-bit binary representation. This makes the individual ARM32 instruction fields visible and allows decoding using the formats presented in the lecture slides. An online number converter was used for this conversion.

## Instruction Type Identification
* 00 - Data Processing instructions
* 01 - Memory Access instructions
* 10 - Branch instructions

## Separation Breakdown

00 – Data Processing Instructions

cond | op | i |  cmd  | s |   Rn    |   Rd   | shamt5 | sh | 0 | Rm
1110 | 00 | 0 | 0010 | 1  |   0011 | 0101 | 00000  | 00 | 0 | 0100

01 - Memory Access instructions

cond | op | i | p | u | b | w | l | Rn   | Rd   | offset
1110 | 01 | 0 | 0 | 0 | 0 | 1 | 0 | 1101 | 1110 | 000000000100

10 - Branch instructions

cond | op | L | imm24
1011  |  10 | 0 | 111111111111111111111011  
How I Wrote This Code
So first of all the conversion process started and I used online converter to see the binary values instead of hexadecimal. You can see the list here:

### 00 – DATA PROCESSING (op = 00)

### Format (I = 1, immediate):
cond | 00 | I | cmd  | S | Rn   | Rd   | rot  | imm8

e3a01000
1110 | 00 | 1 | 1101 | 0 | 0000 | 0001 | 0000 | 00000000

e3a0200a
1110 | 00 | 1 | 1101 | 0 | 0000 | 0010 | 0000 | 00001010

e3a03000
1110 | 00 | 1 | 1101 | 0 | 0000 | 0011 | 0000 | 00000000

e3a04005
1110 | 00 | 1 | 1101 | 0 | 0000 | 0100 | 0000 | 00000101

b0800002
1011 | 00 | 1 | 0100 | 0 | 0000 | 0000 | 0000 | 00000010

b2833001
1011 | 00 | 1 | 0100 | 0 | 0011 | 0011 | 0000 | 00000001

e3a0400f
1110 | 00 | 1 | 1101 | 0 | 0000 | 0100 | 0000 | 00001111

e3a0500a
1110 | 00 | 1 | 1101 | 0 | 0000 | 0101 | 0000 | 00001010


### Format (I = 0, register):
cond | 00 | I | cmd  | S | Rn   | Rd   | shamt5 | sh | 0 | Rm

e0535004
1110 | 00 | 0 | 0010 | 1 | 0011 | 0101 | 00000  | 00 | 0 | 0100

e0856004
1110 | 00 | 0 | 0100 | 0 | 0101 | 0110 | 00000  | 00 | 0 | 0100

e0535004
1110 | 00 | 0 | 0010 | 1 | 0011 | 0101 | 00000  | 00 | 0 | 0100


### 01 – MEMORY ACCESS (op = 01)

Format:
cond | 01 | I | P | U | B | W | L | Rn   | Rd   | offset

e52de004
1110 | 01 | 0 | 0 | 0 | 0 | 1 | 0 | 1101 | 1110 | 000000000100


### 10 – BRANCH (op = 10)

Format:
cond | 10 | L | imm24

bafffffb
1011 | 10 | 0 | 111111111111111111111011

ebffffff
1110 | 10 | 1 | 111111111111111111111111

eafffff9
1110 | 10 | 0 | 111111111111111111111001      



### And then I just calculated everything to the assembly code:

e3a01000 – 1110 00 1 1101 0 0000 0001 000000000000 – data processing, immediate, MOV = MOV R1, #0

e3a0200a – 1110 00 1 1101 0 0000 0010 000000001010 – data processing, immediate, MOV = MOV R2, #10

e3a03000 – 1110 00 1 1101 0 0000 0011 000000000000 – data processing, immediate, MOV = MOV R3, #0

e3a04005 – 1110 00 1 1101 0 0000 0100 000000000101 – data processing, immediate, MOV = MOV R4, #5


e0535004 – 1110 00 0 0010 1 0011 0101 00000 00 0 0100 – data processing, register, SUBS = SUBS R5, R3, R4


b0800002 – 1011 00 1 0100 0 0000 0000 000000000010 – data processing, immediate, conditional (LT), ADD = ADDLT R0, R0, #2

b2833001 – 1011 00 1 0100 0 0011 0011 000000000001 – data processing, immediate, conditional (LT), ADD = ADDLT R3, R3, #1


bafffffb – 1011 10 0 111111111111111111111011 – branch, conditional (LT) = BLT loop

ebffffff – 1110 10 1 111111111111111111111111 – branch with link = BL func


e52de004 – 1110 01 0 0 0 0 1 0 1101 1110 000000000100 – memory, immediate, post-index, subtract offset, STR = STR LR, [SP, #-4]!


e3a0400f – 1110 00 1 1101 0 0000 0100 000000001111 – data processing, immediate, MOV = MOV R4, #15

e3a0500a – 1110 00 1 1101 0 0000 0101 000000001010 – data processing, immediate, MOV = MOV R5, #10


e0856004 – 1110 00 0 0100 0 0101 0110 00000 00 0 0100 – data processing, register, ADD = ADD R6, R5, R4

e0535004 – 1110 00 0 0010 1 0011 0101 00000 00 0 0100 – data processing, register, SUBS = SUBS R5, R3, R4


eafffff9 – 1110 10 0 111111111111111111111001 – branch, unconditional = B func


## Correct Logical Reconstruction of the Program:

Program Start and Initialization

MOV R1, #0
Initializes register R1 to zero. This register does not affect the control flow.

MOV R2, #10
Loads the constant value 10 into R2. This value is used to increment another register inside the loop.

MOV R3, #0
Initializes R3 to zero. This register is used as the loop counter.

MOV R4, #5
Loads the value 5 into R4. This register defines the loop limit used for comparison.

Loop Comparison and Condition Setup

SUBS R5, R3, R4
Subtracts R4 from R3 and stores the result in R5.
Updates the condition flags.
If R3 < R4, the LT (less than) condition becomes true.

Conditional Operations Inside the Loop

ADDLT R0, R0, R2
Executes only if the LT condition is true.
Adds the value 10 to R0, accumulating a total during each loop iteration.

ADDLT R3, R3, #1
Executes only if the LT condition is true.
Increments the loop counter R3 by 1.

Loop Control Branch

BLT loop
Branches back to the start of the loop if the LT condition is still true.
This instruction forms the loop structure.

Loop Termination

When R3 reaches the value 5, the subtraction result is no longer negative.

The LT condition becomes false.

Conditional instructions and the branch are skipped.

The loop terminates after exactly five iterations.

Function Call

BL func
Branches to the function labeled func.
The return address is stored in the Link Register (LR).

Function Prologue and Stack Usage

STR LR, [SP, #-4]!
Decrements the stack pointer by 4 bytes.
Saves the return address from LR onto the stack.
Indicates that the function is intended to return to the caller.

Function Body Operations

MOV R4, #15
Loads the value 15 into R4 for arithmetic use.

MOV R5, #10
Loads the value 10 into R5.

ADD R6, R5, R4
Adds R5 and R4 and stores the result (25) in R6.
This operation does not affect program control flow.

SUBS R5, R3, R4
Performs a subtraction and updates condition flags.
The flags set here are not used by any conditional instruction.

Infinite Loop and Crash Reason

B func
Unconditionally branches back to the start of the function.
The saved return address is never restored.
The function never returns to the caller.

