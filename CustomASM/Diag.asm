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
NOP
NOP
START:
CALL TEXT
CALL KEY
CALL DECODE
HLT
KEY:
	MOV ADDR, IO
	MOV R0, 0x0a 
	MOV ACC, reg[BUS]
	SUB
	JEZ CLR
	MOV R1, reg[ACC]
	JEZ SKIP
	MOV R2, reg[ACC]
SKIP:
	JMP KEY
CLR:
	MOV ADDR, TTY
	MOV BUS, 0x7
	MOV ADDR, IO
	RTN
TEXT:
	MOV ADDR, TTY
	MOV BUS, "C"
	MOV BUS, "H"
	MOV BUS, "O"
	MOV BUS, "O"
	MOV BUS, "S"
	MOV BUS, "E"
	MOV BUS, " "
	MOV BUS, "Y"
	MOV BUS, "O"
	MOV BUS, "U"
	MOV BUS, "R"
	MOV BUS, " "
	MOV BUS, "T"
	MOV BUS, "E"
	MOV BUS, "S"
	MOV BUS, "T"
	MOV BUS, 0x0a
	MOV BUS, "1"
	MOV BUS, ":"
	MOV BUS, " "
	MOV BUS, "R"
	MOV BUS, "A"
	MOV BUS, "M"
	MOV BUS, 0x0a
	MOV BUS, "2"
	MOV BUS, ":"
	MOV BUS, " "
	MOV BUS, "I"
	MOV BUS, "O"
	MOV BUS, 0x0a
	MOV BUS, "3"
	MOV BUS, ":"
	MOV BUS, " "
	MOV BUS, "R"
	MOV BUS, "E"
	MOV BUS, "G"
	MOV BUS, "I"
	MOV BUS, "S"
	MOV BUS, "T"
	MOV BUS, "E"
	MOV BUS, "R"
	MOV BUS, "S"
	MOV BUS, 0xa
	MOV BUS, "4"
	MOV BUS, ":"
	MOV BUS, " "
	MOV BUS, "S"
	MOV BUS, "T"
	MOV BUS, "A"
	MOV BUS, "C"
	MOV BUS, "K"
	RTN
DECODE:
	MOV ACC, reg[R2]
	MOV R0, "1"
	SUB
	JEZ RAMTEST
	MOV R0, "2"
	SUB
	JEZ IOTEST
	MOV R0, "3"
	SUB
	JEZ REGTEST
	MOV R0, "4"
	SUB
	JEZ STACKTEST

	RAMTEST:
		MOV RADDR, 0x0
		MOV RAM, "H"
		MOV RADDR, 0x1
		MOV RAM, "E"
		MOV RADDR, 0x2
		MOV RAM, "L"
		MOV RADDR, 0x3
		MOV RAM, "L"
		MOV RADDR, 0x4
		MOV RAM, "O"
		MOV ADDR, TTY
		MOV RADDR, 0x0
		MOV ACC, reg[RAM]
		MOV ACC, reg[RAM]
		MOV BUS, reg[ACC]
		MOV RADDR, 0x1
		MOV ACC, reg[RAM]
		MOV ACC, reg[RAM]
		MOV BUS, reg[ACC]
		MOV RADDR, 0x2
		MOV ACC, reg[RAM]
		MOV ACC, reg[RAM]
		MOV BUS, reg[ACC]
		MOV RADDR, 0x3
		MOV ACC, reg[RAM]
		MOV ACC, reg[RAM]
		MOV BUS, reg[ACC]
		MOV RADDR, 0x4
		MOV ACC, reg[RAM]
		MOV ACC, reg[RAM]
		MOV BUS, reg[ACC]
		RTN
	IOTEST:
		RTN
	REGTEST:
		RTN
	STACKTEST:
		MOV ACC, "O"
		PUSH
		MOV ACC, "L"
		PUSH
		MOV ACC, "L"
		PUSH
		MOV ACC, "E"
		PUSH
		MOV ACC, "H"
		PUSH
		MOV ADDR, TTY
		POP
		MOV BUS, reg[R1]
		POP
		MOV BUS, reg[R1]
		POP
		MOV BUS, reg[R1]
		POP
		MOV BUS, reg[R1]
		POP
		MOV BUS, reg[R1]
		RTN



	

	
