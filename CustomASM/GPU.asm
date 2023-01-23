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

;NOTE - Black must be 0x0001 due to laziness
;Reads RGB and then ADDR
; then you can use instructions like:
NOP
NOP
MOV ADDR, 0x0
MOV RADDR, 0x0
START:
    MOV ACC, reg[RAM]
    MOV ACC, reg[RAM]
    MOV ADDR, reg[RADDR]
    MOV BUS, reg[ACC]
    MOV ACC, reg[RADDR]
    MOV R0, 0x1
    ADD
    MOV RADDR, reg[R1]
    JMP START

    





	

	
