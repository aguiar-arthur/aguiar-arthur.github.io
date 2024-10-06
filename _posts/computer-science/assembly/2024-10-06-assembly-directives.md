---
layout: post
title:  "Assembler Directives / pseudo-operations"
date:   2024-10-06 17:30:00
categories: ["Computer Science"]
tags: ["Assembly"]
---

{% include coderay.html %}

Assembler directives are instructions to the assembler. They provide guidance on how to process code, organize memory, and manage resources. They do not produce machine code that gets executed.

All the assembly code used here is **X86.**

There are some categories of assembler directives:

### **Data Definition Directives**

These directives are used to define and allocate space for variables, constants, or arrays. They also initialize memory with values or reserve space for future use.

- **DB** (Define Byte): Allocates a byte (8 bits) and can initialize it with a value.
- **DW** (Define Word): Allocates a word (16 bits) of memory.
- **DD** (Define Doubleword): Allocates a double word (32 bits).
- **DQ** (Define Quadword): Allocates a quadword (64 bits).

```
message DB 'Hello', 0   ; Defines a byte array initialized with the string "Hello" and terminated by a null byte.
num     DW 12345        ; Defines a 16-bit word initialized to 12345.
```

### **Storage Reservation Directives**

These directives reserve memory for later use but do not initialize it with any specific value.

- **RESB** (Reserve Byte): Reserves a specified number of bytes.
- **RESW** (Reserve Word): Reserves a specified number of words (16 bits each).
- **RESD** (Reserve Doubleword): Reserves a specified number of doublewords (32 bits each).

```
buffer RESB 64  ; Reserves 64 bytes of memory.
```

### **Segment Definition Directives**

These directives are used to define different segments in memory, such as code, data, or stack segments. This is important in older architectures where memory is organized in segments.

- **SEGMENT**: Marks the beginning of a segment.
- **ENDS**: Marks the end of a segment.

```
DATA_SEG SEGMENT
    ; Data declarations go here
DATA_SEG ENDS
```

### **Control Directives**

Control directives help control the flow of assembly, the inclusion of external files, or even conditional assembly.

- **ORG**: Specifies the origin or starting address of the code or data.
- **INCLUDE**: Inserts the contents of another file into the current assembly file.
- **IF/ELSE/ENDIF**: Allows conditional assembly based on predefined conditions, often used to assemble different code based on configuration.

```
ORG 100h   ; Set the code origin to 0x100.
```

### **Macro Directives**

Macros in assembly allow you to define a set of instructions that can be reused multiple times. Macro directives handle the declaration and invocation of macros.

- **MACRO**: Defines the beginning of a macro.
- **ENDM**: Marks the end of a macro.

```
PRINT MACRO text
    MOV AH, 9
    LEA DX, text
    INT 21h
ENDM
```

### **Alignment Directives**

These directives are used to align data or code in memory to specific boundaries (for example, aligning data to a 4-byte boundary).

- **ALIGN**: Aligns the next instruction or data to a specified byte boundary.

```
ALIGN 4  ; Aligns the next instruction or data to a 4-byte boundary.
```

### **Equates and Constants**

These directives are used to define constants or symbolic names for values.

- **EQU**: Defines a constant or a symbolic name for a value.
- **%DEFINE**: Similar to `#define` in C, used to define macros.

### **Equates** (`EQU`)

```
MAX_VALUE EQU 255     ; Defines a constant named MAX_VALUE with a value of 255.
```

An **equate** is a directive used to define a constant value. The syntax of `EQU` (short for *equate*) assigns a symbolic name to a constant. The assembler replaces all occurrences of the symbol with the corresponding value during assembly, but no memory is allocated for it.

- Equates are resolved during assembly, not at runtime.
- They improve readability by replacing hard-coded values with meaningful names.
- No storage space is used since they are not variables, just symbolic names for values.

```
BUFFER_SIZE EQU 64
NEWLINE     EQU 0x0A

section .bss
buffer resb BUFFER_SIZE  ; Reserve 64 bytes of memory for buffer

section .text
_start:
    mov al, NEWLINE      ; Move the newline character (0x0A) into register AL
```

**`%define`** Used in NASM, similar to `EQU` .

```
%define MAX_SIZE 256
```

### Using almost everything in an example

```nasm
section .data           ; Data section
msg db 'Hello, world!', 0  ; String (symbol 'msg')

section .bss            ; Uninitialized data section
buffer resb 64          ; Reserve 64 bytes (symbol 'buffer')

section .text           ; Code section
global _start           ; Entry point (symbol '_start')

_start:
    mov eax, 4          ; Syscall number for write
    mov ebx, 1          ; File descriptor for stdout
    mov ecx, msg        ; Address of the message
    mov edx, 13         ; Length of the message
    int 0x80            ; Make the system call

    mov eax, 1          ; Syscall number for exit
    xor ebx, ebx        ; Status code 0
    int 0x80            ; Exit the program
```

Thanks, bye!

### References:

- SCHILDT, Herbert. *STL Programming from the Ground Up*. New York: McGraw-Hill, 1999.
- [PC Assembly Book](https://pacman128.github.io/pcasm/)
- [x86 Assembly Guide](https://www.cs.virginia.edu/~evans/cs216/guides/x86.html)
