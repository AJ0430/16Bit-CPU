ORG 0x0000   ; start address of bootloader

MAIN:
    MOV ADDR, TTY  ; set IO address to TTY console
    MOV BUS, 'B'   ; print "BOOTING" message
    MOV RAM, BUS
    MOV BUS, 'O'
    MOV RAM, BUS
    MOV BUS, 'O'
    MOV RAM, BUS
    MOV BUS, 'T'
    MOV RAM, BUS
    MOV BUS, 'I'
    MOV RAM, BUS
    MOV BUS, 'N'
    MOV RAM, BUS
    MOV BUS, 'G'
    MOV RAM, BUS
    MOV BUS, 0x0A  ; print line feed character
    MOV RAM, BUS

    MOV RADDR, #0x1000  ; set the RAM address register to the start of the program
    MOV PC, RADDR       ; jump to the start of the program

; command prompt code starts here

COMMAND_PROMPT:
    MOV ADDR, TTY    ; set IO address to TTY console
    MOV BUS, '>'     ; print command prompt
    MOV RAM, BUS
    MOV BUS, ' '
    MOV RAM, BUS
    MOV BUS, 0x0A    ; print line feed character
    MOV RAM, BUS

    MOV ADDR, TTY    ; set IO address to TTY console
    CALL READ_STRING ; read user input into memory starting at 0x2000
    MOV RADDR, #0x2000 ; set the RAM address register to the start of the user input

    MOV R0, RAM      ; move first character of user input into R0

    CMP R0, 'H'      ; check if the user typed "HELLO"
    JE HELLO         ; if so, jump to HELLO label

    ; check for other commands here...

    JMP COMMAND_PROMPT ; if no recognized command was typed, print the prompt again and wait for more input

HELLO:
    MOV ADDR, TTY    ; set IO address to TTY console
    MOV BUS, 'H'     ; print greeting
    MOV RAM, BUS
    MOV BUS, 'E'
    MOV RAM, BUS
    MOV BUS, 'L'
    MOV RAM, BUS
    MOV BUS, 'L'
    MOV RAM, BUS
    MOV BUS, 'O'
    MOV RAM, BUS
    MOV BUS, 0x0A    ; print line feed character
    MOV RAM, BUS

    JMP COMMAND_PROMPT ; return to the command prompt

; subroutine for reading a string of characters from the TTY console and storing them in memory
READ_STRING:
    MOV R1, #0      ; initialize counter for number of characters read
    MOV R2, #0      ; initialize temporary variable for storing each character read
    MOV R3, #0      ; initialize temporary variable for converting from ASCII to binary

READ_LOOP:
    MOV ADDR, TTY   ; set IO address to TTY console
    MOV BUS, 0xFF   ; read a character from the console into the BUS
    MOV RAM, BUS
    MOV R2, BUS     ; move the character from the BUS into R2
    MOV R3, #0      ; clear R3 before using it to convert from ASCII to binary
    CMP R2, 0x0D    ; check if the character
