.global _start
_start:

    MOV     R1, #0
    MOV     R2, #10
    MOV     R3, #0
    MOV     R4, #5

loop:
    SUBS    R5, R3, R4
    ADDLT   R0, R0, R2
    ADDLT   R3, R3, #1
    BLT     loop

    BL      func

func:
    STR     LR, [SP, #-4]!
    MOV     R4, #15
    MOV     R5, #10
    ADD     R6, R5, R4
    SUBS    R5, R3, R4
    B       func