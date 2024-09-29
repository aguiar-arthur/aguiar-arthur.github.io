---
layout: post
title:  "Data Accessing Methods - Addressing Modes"
date:   2024-09-28 23:30:00
categories: ["Computer Science"]
tags: ["Assembly"]
---

Working directly with assembly, is fun, but you need to be efficient we should take care of our data access. To tackle this, we need to know about **Addressing Modes.** 

Addressing nodes are techniques to access data from memory and registers. 
The way this memory in interpreted and used is specified by the chosen addressing mode, and this means flexibility. 
~~Flexibility means more options, and more options means more fun.~~ 

All the assembly code used here is **X86.**

### Immediate Addressing

We embed our operation directly in the instruction. For example, to move a value to a register, instead to pass an address to read from, we pass the value directly to the register. 

- `MOV AX, 5` *(The operand (5) is embedded directly in the instruction.)*

 *Good for small constants or fixed values*.

### Register Addressing

In this one, the operand is stored in a register, and the instruction refers to that register.

- `MOV AX, BX` *(Operands are registers; `AX` is the destination, and `BX` is the source.)*

### Direct Addressing

We pass the memory address that should be accessed by the instruction. The values in the address are copied to the register. 

- `MOV AX, [1000h]`

### Indirect Addressing

The instruction specifies a register or memory location that holds the address of the operand.

- `MOV AX, [BX]`

### Indexed Addressing

Uses a base register, and an **offset** (or displacement) is added to that register to form the final memory address. The offset can be used to access elements in an array or data structure.

*Useful for accessing array elements.*

### How It Works:

- **Base register**: Holds a starting address or pointer.
- **Offset**: A constant value that is added to the base register to calculate the effective memory address.

### A better example:

Assume:

- The base address of the array is stored in `BX`.
- Each element in the array is 2 bytes (e.g., 16-bit integers).
- You want to load the 3rd element of the array into `AX`.

```nasm
MOV BX, 2000h    ; Load the base address of the array into BX
MOV AX, [BX + 4] ; Load the 3rd element (offset = 2 bytes * 2 = 4) into AX
```

### Breakdown:

- **Base Register** (`BX`): This holds the base address of the array (`2000h`).
- **Offset** (`4`): This is calculated based on the size of each element (in this case, 2 bytes). To access the 3rd element, you need an offset of `4` (because `2 * (3 - 1) = 4`).
- The effective address is `2000h + 4 = 2004h`. The content at memory address `2004h` is moved into `AX`.

### Base-Indexed Addressing

Combines the base address from a register and an index from another register to determine the effective address.

*Useful for complex data structures like multi-dimensional arrays.*

### Some examples

***Even though I reviewed this, this example section was made with AI, so use this with caution.***

### Structure of Base-Indexed Addressing

In x86, the effective address is computed as:

```
Effective Address = Base Register + (Index Register * Scale) + Displacement
```

Where:

- **Base Register**: Holds the starting address (e.g., the base of an array).
- **Index Register**: Often used to iterate through elements of an array.
- **Scale (optional)**: Multiplies the index register by a constant (1, 2, 4, or 8) to account for data size (e.g., `sizeof(int)` or `sizeof(double)`).
- **Displacement (optional)**: A constant offset that can be added to the address for flexibility.

### Example 1: Base + Index Addressing

In this example, we'll consider a simple array of integers (where each integer is 4 bytes), and we want to load the value at the 3rd index of the array into a register.

```nasm
MOV EBX, 2000h      ; Load the base address of the array into EBX
MOV ESI, 2          ; Load the index (for the 3rd element) into ESI
MOV EAX, [EBX + ESI * 4] ; Load the 3rd element (EBX + 2 * 4 = 2008h) into EAX
```

### Breakdown:

- **EBX** (Base Register): Contains the base address `2000h`.
- **ESI** (Index Register): Contains the index of the array element we want to access, which is 2 (for the 3rd element since indexing starts at 0).
- **4 (Scale)**: Since each element is 4 bytes, the index register is multiplied by 4 to account for this.
- The effective address becomes `2000h + (2 * 4) = 2008h`, which is the memory location of the 3rd element in the array. The value at address `2008h` is loaded into `EAX`.

### Example 2: Base + Index + Displacement Addressing

This example introduces a **displacement** (offset) into the calculation, which is useful for accessing a field inside a structure.

Consider a structure like this:

```c
struct {
    int x;
    int y;
    int z;
} Point;
```

The size of each field is 4 bytes. If we want to access the `y` value of the 3rd `Point` in an array of `Point` structures, we can use **base-indexed** addressing with displacement:

```nasm
MOV EBX, 2000h      ; Load the base address of the array into EBX
MOV ESI, 2          ; Index for the 3rd Point (index 2)
MOV EAX, [EBX + ESI * 12 + 4] ; Load the 'y' field of the 3rd Point into EAX
```

### Breakdown:

- **EBX** (Base Register): Contains the base address `2000h`.
- **ESI** (Index Register): The index is `2` for the 3rd element.
- **12 (Scale)**: Since each `Point` structure is 12 bytes (3 fields of 4 bytes), we multiply the index by 12 to calculate the correct offset for the 3rd `Point`.
- **4 (Displacement)**: Since the `y` field is the second field in the structure, it has an offset of 4 bytes from the base of the structure.
- The effective address is `2000h + (2 * 12) + 4 = 2020h`. The content at `2020h`, which corresponds to the `y` value of the 3rd `Point`, is loaded into `EAX`.

### Example 3: Base + Index without Scale

This example shows a case where no scale factor is used, which can occur when dealing with byte arrays (where each element is 1 byte).

```nasm
MOV EBX, 2000h       ; Load the base address of the byte array into EBX
MOV ESI, 3           ; Load the index for the 4th byte (index 3) into ESI
MOV AL, [EBX + ESI]  ; Load the 4th byte (EBX + 3) into AL
```

### Breakdown:

- **EBX** (Base Register): Contains the base address `2000h`.
- **ESI** (Index Register): Contains the index `3` (for the 4th byte).
- No scaling factor is applied because each element is 1 byte.
- The effective address becomes `2000h + 3 = 2003h`, and the value at address `2003h` is loaded into the `AL` register. The effective address becomes `2000h + 3 = 2003h`, and the value at address `2003h` is loaded into the `AL` register.

## References:

- SCHILDT, Herbert. *STL Programming from the Ground Up*. New York: McGraw-Hill, 1999.
- [GeeksforGeeks: Addressing Modes](https://www.geeksforgeeks.org/addressing-modes/)
- [CS Regina: Addressing Modes Lecture](https://www.labs.cs.uregina.ca/201/SPIM-AddressingMode/lecture.php)
