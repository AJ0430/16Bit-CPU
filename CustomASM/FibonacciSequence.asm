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
    PUSH => 0x20000000
    POPD => 0x21000000
    POP => 0x23000000
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
}
#bits 32
; then you can use instructions like:

NOP
NOP
START:
    MOV R3, 0x0
    MOV R2, 0x1

LOOP:
    MOV ACC, reg[R3]
    MOV R0, reg[R2]
    ADD
    MOV ADDR, 0x3
    MOV BUS, reg[R1]
    MOV R2, reg[ACC]
    MOV R3, reg[R1]
    MOV R0, 0xB520
    MOV ACC, reg[R1]
    SUB
    JGZ LOOP
    MOV ADDR, 0x0
    MOV BUS, 0x4C 
    MOV BUS, 0x61 
    MOV BUS, 0x72 
    MOV BUS, 0x67 
    MOV BUS, 0x65 
    MOV BUS, 0x73 
    MOV BUS, 0x74 
    MOV BUS, 0x20 
    MOV BUS, 0x4E 
    MOV BUS, 0x75 
    MOV BUS, 0x6D 
    MOV BUS, 0x62 
    MOV BUS, 0x65 
    MOV BUS, 0x72 
    MOV BUS, 0x20 
    MOV BUS, 0x52 
    MOV BUS, 0x65 
    MOV BUS, 0x61 
    MOV BUS, 0x63 
    MOV BUS, 0x68 
    MOV BUS, 0x65 
    MOV BUS, 0x64
    HLT 
