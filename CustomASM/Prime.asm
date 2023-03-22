#bits 32
#subruledef register
{
    ACC => 0x0
	R0 => 0x1
	R1 => 0x2
	R2 => 0x3
	R3 => 0x4
	R4 => 0x5
	R5 => 0x6
	R6 => 0x7
	R7 => 0x8
	R8 => 0x9
	R9 => 0xa
	RADDR => 0xb
	ADDR => 0xc
	BUS => 0xd
	RAM => 0xe
}
#subruledef source
{
    {immediate: i16} => 0xf @ immediate
    mem[{address: i16}] => 0xc @ 0x0000
    reg[{r: register}] => r @ 0x0000
}
#subruledef branch
{
	{addr: i16} => 0xcf @ addr
}
#ruledef
{
	NOP => 0x00000000
	EMU => 0xFF000000
	JMP {addr: branch} => 0x80 @ addr @ 0x40000000
	JGZ {addr: branch} => 0x80 @ addr @ 0x41000000
	JNZ {addr: branch} => 0x80 @ addr @ 0x42000000
	JEZ {addr: branch} => 0x80 @ addr @ 0x43000000
	MOV {r: register}, {src: source} => 0x80 @ r @ src
	ADD  => 0xC0000000
	SUB => 0xC1000000
	MUL => 0xC2000000
	DIV => 0xC3000000
	SHIFT => 0xC4000000
	AND => 0xC5000000
	OR => 0xC6000000
	NOT => 0xC7000000
	HLT => 0x60000000
	PUSH => 0x20000000; Push value from ACC onto stack
	POP => 0x21000000; Pop value off the stack into REG1
	PEEK => 0x23000000; Pop value into REG1 without decrementing the stack pointer
	CALL {addr: branch} => asm{; Pushes PC onto stack and jumps to Subroutine
	MOV ADDR, 0xFFFF
	MOV ACC, reg[BUS]
	MOV R0, 0x7
	ADD
	MOV ACC, reg[R1]
	PUSH} @ 0x80 @ addr @ 0x40000000
	RTN => asm{; Pops PC value off the stack and jumps to next instruction
		POP
		MOV ADDR, reg[R1]
	} @ 0x40000000
}
; ADDRESSING MAP
;==================
TTY = 0x0; TTY Console
GPU = 0x1; - GPU
BCD = 0x3; - BCD to 7Seg
IO = 0xFFFE; - Keyboard/LEDS
PC = 0xFFFF; - PC

; MULTICORE MAP
;==================
CPU1 = 0x0000
CPU2 = 0xFFFF

; then you can use instructions like:

MAIN:
    MOV R0, 0x2      ; initialize R0 to 2, the first prime number
    MOV R1, 0x0      ; initialize R1 to 0, the counter for how many prime numbers we've found
    MOV R2, 0x0      ; initialize R2 to 0, a temporary variable for counting factors
    MOV R3, 0x0      ; initialize R3 to 0, a temporary variable for storing the current number being checked

LOOP:
    MOV R3, reg[R0]  ; move current number being checked into R3
    MOV R2, 0x0      ; reset factor counter to 0

CHECK_FACTOR:
    ADD R2, 0x1     ; increment factor counter
    MOV ACC, reg[R3]; move current number into ACC
    DIV             ; divide by potential factor
    JNZ NOT_FACTOR  ; if not a factor, continue checking
    JEZ FACTOR      ; if a factor, jump to factor label

NOT_FACTOR:
    MOV ACC, R2     ; move factor counter into ACC
    MOV R1, ACC     ; update counter for how many prime numbers we've found
    ADD R0, 0x1      ; increment potential factor
    JZ LOOP         ; if potential factor is 0, we've reached the end of our search

    CMP R0, 0x56    ; if we've checked all possible prime numbers (up to 255), halt
    JZ HALT

    JMP CHECK_FACTOR ; otherwise, continue checking for factors

FACTOR:
    CMP R0, R3      ; if the factor we found is equal to the current number being checked
    JNZ NOT_PRIME   ; if not equal, current number is not prime and we should continue checking
    PUSH            ; otherwise, push the current number onto the stack
    MOV ADDR, TTY   ; set IO address to TTY
    POP             ; pop the current number from the stack into R1
    CALL PRINT_DEC  ; print the current number to the TTY console
    MOV ADDR, TTY   ; set IO address to TTY
    MOV BUS, 0x0A   ; move line feed character into BUS
    MOV RAM, BUS    ; write line feed character to TTY console
    ADD R0, 0x1      ; increment potential factor
    JZ LOOP         ; if potential factor is 0, we've reached the end of our search
    JMP CHECK_FACTOR ; otherwise, continue checking for factors

NOT_PRIME:
    ADD R0, 0x1      ; increment potential factor
    JZ LOOP         ; if potential factor is 0, we've reached the end of our search
    JMP CHECK_FACTOR ; otherwise, continue checking for factors

PRINT_DEC:
    PUSH            ; push ACC onto stack
    MOV R4, 0x10     ; initialize R4 to 10
    MOV R5, 0x0      ; initialize R5 to 0, the counter for the number of digits
    MOV R6, 0x0      ; initialize R6 to 0, a temporary variable for storing the current digit
    DIV R4          ; divide ACC by 10
    JZ END_PRINT    ; if result is 0, we've printed all digits

PRINT_LOOP:
    MOV R6, ACC     ; move quotient into R6
    MUL R4          ; multiply quotient by 10
    SUB ACC, R4     ; subtract result from ACC to get
