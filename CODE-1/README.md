# 8086 Assembly — Larger of Two Decimal Digits

> **Processor:** Intel 8086 | **Emulator:** EMU8086 | **Interrupt:** INT 21H

---

## Program Overview

This program accepts two decimal digits from the keyboard, compares them, and displays the larger of the two using DOS INT 21H services.

```
Input   →  Two decimal digits (e.g., 3 and 7)
Process →  Compare using CMP + conditional jump JAE
Output  →  THE LARGER OF 3 AND 7 IS 7
```

---

## Registers Used

| Register | Full Name                | Purpose in This Program                           |
|----------|--------------------------|---------------------------------------------------|
| `AX`     | Accumulator (16-bit)     | DOS functions & ASCII conversion                  |
| `AH`     | Accumulator High (8-bit) | Stores DOS function number (01H, 02H, 09H, 4CH)   |
| `AL`     | Accumulator Low (8-bit)  | Stores input character and larger digit result    |
| `CL`     | Counter Low (8-bit)      | Stores first digit (numeric after ASCII convert)  |
| `CH`     | Counter High (8-bit)     | Stores second digit (numeric after ASCII convert) |
| `DX`     | Data Register (16-bit)   | Holds address of string message for INT 21H       |
| `DL`     | Data Low (8-bit)         | Holds individual character for display            |
| `DS`     | Data Segment Register    | Points to the .DATA segment in memory             |

---

## DOS Functions Used (INT 21H)

| AH Value | Function          | Description                                              |
|----------|-------------------|----------------------------------------------------------|
| `01H`    | Read Character    | Reads a single key from keyboard; returns ASCII in AL    |
| `02H`    | Display Character | Displays character stored in DL to screen                |
| `09H`    | Display String    | Displays string at address in DX, stops at `$` character |
| `4CH`    | Terminate Program | Ends program and returns control to DOS                  |

---

## Statement-by-Statement Explanation

### 1. `.MODEL SMALL`

**Purpose:**
Tells the assembler to use the SMALL memory model — one Code Segment and one Data Segment, each up to 64KB. Simplifies memory organization and is the standard for 8086 lab programs.

**If we don't use it:**
You must manually define all segments using `SEGMENT`/`ENDS` directives, making the program longer, harder to read, and more error-prone.

**Alternatives:**

| Model            | Code Segments | Data Segments | When to Use                         |
|------------------|--------------|---------------|-------------------------------------|
| `.MODEL TINY`    | 1 (shared)   | 1 (same)      | Very small .COM programs (max 64KB) |
| `.MODEL SMALL`   | 1            | 1             | Standard lab/academic programs ✅   |
| `.MODEL MEDIUM`  | Many         | 1             | Large code, small data              |
| `.MODEL COMPACT` | 1            | Many          | Small code, large data              |
| `.MODEL LARGE`   | Many         | Many          | Full-scale applications             |
| Manual `SEGMENT` | Custom       | Custom        | Advanced programs without models    |

---

### 2. `.STACK 100H`

**Purpose:**
Allocates `100H` (256 decimal) bytes of stack memory for the Stack Segment (SS). Required by `PUSH`/`POP`, `INT` calls, and `CALL`/`RET` operations.

**If we don't use it:**
`PUSH`, `POP`, `CALL`, `RET`, and `INT` instructions behave unpredictably or crash — even simple `INT 21H` calls use the stack internally.

**Alternatives / Size choices:**

| Size    | Decimal   | When to Use                                      |
|---------|-----------|--------------------------------------------------|
| `40H`   | 64 bytes  | Extremely simple programs, no interrupts         |
| `80H`   | 128 bytes | Light usage, few PUSH/POP operations             |
| `100H`  | 256 bytes | Standard for all 8086 lab programs ✅            |
| `200H`  | 512 bytes | Programs with multiple procedures                |
| `400H`  | 1024 bytes| Nested calls, recursion, many interrupts         |

---

### 3. `.DATA`

**Purpose:**
Marks the beginning of the Data Segment where all variables, constants, and string messages are declared. The assembler allocates memory for these items sequentially.

**If we don't use it:**
You must manually write `DATA SEGMENT ... DATA ENDS` and initialize DS yourself. The program cannot safely store or reference named variables.

**Alternatives:**
Use `.CONST` for read-only data, or manually declare named `SEGMENT` blocks for advanced programs with multiple data areas. For all standard lab programs, `.DATA` is the correct choice.

---

### 4. `MSG1 DB 0DH,0AH,'THE LARGER OF $'`

**Purpose:**
Declares a byte string in memory. `DB` (Define Byte) stores each element sequentially:
- `0DH` → Carriage Return — moves cursor to start of line
- `0AH` → Line Feed — moves cursor to next line
- `$` → String terminator required by DOS function `09H`

**If we don't use it:**
The program cannot display the first part of the output. Without `$`, DOS function `09H` reads beyond the string and prints garbage characters until it randomly finds a `$` byte in memory.

**Why `0DH` + `0AH` together?**
`0DH` alone only resets the column. `0AH` alone only advances the line. Together they produce a proper DOS newline (beginning of the next line).

**Alternatives:**

| Alternative        | Description                           | When to Use                         |
|--------------------|---------------------------------------|-------------------------------------|
| Multiple DB lines  | Split into several DB statements      | When parts need runtime modification|
| `DW` (Define Word) | 16-bit storage per element            | For numeric constants, not strings  |
| Inline CR+LF split | `DB 0DH,0AH` then `DB 'TEXT$'` below | For clarity with very long messages |

---

### 5. `MSG2 DB ' AND $'` / `MSG3 DB ' IS $'`

**Purpose:**
Additional string segments that connect the two digits and the result into a readable sentence:

```
THE LARGER OF [digit1] AND [digit2] IS [result]
```

**If we don't use them:**
The output shows only raw digits with no connecting words. Since `09H` requires separate `LEA`/`INT` calls per string, each piece must be declared individually.

---

### 6. `.CODE`

**Purpose:**
Marks the beginning of the Code Segment — the area where all executable instructions are placed. The CPU's `CS` (Code Segment Register) points here at program start.

**If we don't use it:**
The assembler cannot distinguish data bytes from executable instructions. You would need to manually write `CODE SEGMENT ... CODE ENDS` and manage segment ordering yourself.

---

### 7. `MAIN PROC` / `MAIN ENDP` / `END MAIN`

**Purpose:**
- `MAIN PROC` — marks the start of a named procedure block
- `MAIN ENDP` — closes the procedure
- `END MAIN` — tells the linker that `MAIN` is the program's entry point (where execution begins)

**If we don't use them:**
Without `PROC`/`ENDP`, code structure and readability are lost. Without `END MAIN`, the linker may not know where execution starts, causing the program to fail or jump to a wrong address.

> **Note:** `MAIN` is a convention — you can name it anything, but the name after `END` must exactly match the entry `PROC` name.

---

### 8. `MOV AX,@DATA` / `MOV DS,AX`

**Purpose:**
Initializes `DS` to point to the `.DATA` section. `@DATA` is an assembler symbol holding the segment address of the data section. `DS` cannot be loaded from an immediate value directly, so `AX` is used as an intermediate.

```asm
MOV AX,@DATA     ; Load segment address into AX
MOV DS,AX        ; Transfer from AX to DS
```

**If we don't use it:**
`DS` points to the wrong memory location. Any access to `MSG1`, `MSG2`, `MSG3` returns garbage or crashes the program.

**Why not `MOV DS,@DATA` directly?**
The 8086 architecture does not allow loading a segment register (`DS`, `ES`, `SS`) from an immediate value. A general-purpose register (`AX`, `BX`, `CX`, or `DX`) must relay the value.

---

### 9. `CMP AL,CH` / `JAE FIRST_LARGER`

**Purpose:**
`CMP` subtracts `CH` from `AL` and sets the CPU flags (`CF`, `ZF`, `SF`) without modifying either operand. `JAE` (Jump if Above or Equal) reads those flags — if `AL >= CH`, execution jumps to `FIRST_LARGER`; otherwise it falls through to load the second digit.

```asm
CMP AL,CH          ; Sets flags based on AL - CH
JAE FIRST_LARGER   ; Jump if AL >= CH (unsigned comparison)
```

**If we don't use CMP:**
There is no way to make a decision between the two values — the program would always display one fixed digit regardless of input.

**Why `JAE` and not `JGE`?**
`JAE` is for **unsigned** comparison. `JGE` is for **signed** values. Since ASCII-derived digits (0–9) are always positive/unsigned, `JAE` is the correct and safe choice.

---

### 10. `PUSH AX` / `POP AX`

**Purpose:**
`AL` holds the ASCII value of the larger digit after comparison. `PUSH AX` saves it onto the stack before `INT 21H` calls (which overwrite `AX`). `POP AX` restores it at the end so the larger digit can be printed last.

```asm
PUSH AX     ; Save AL (larger digit ASCII) before INT calls
...         ; Several INT 21H display calls (overwrite AX)
POP AX      ; Restore AL with the larger digit
```

**If we don't use PUSH/POP:**
`INT 21H` calls overwrite `AX` with their return values. By the final display step, `AL` contains the wrong value and the program prints an incorrect character.

---

### 11. `SUB CL,30H` / `ADD DL,30H` — ASCII Conversion

**Purpose:**
Keyboard input returns ASCII codes — the digit `'3'` arrives as byte `33H` (51 decimal), not the number `3`. Subtracting `30H` converts ASCII `'0'`–`'9'` to numeric `0`–`9` for comparison. Adding `30H` reverses this before display.

| Operation       | Direction       | Example                           |
|-----------------|-----------------|-----------------------------------|
| `SUB CL,30H`    | ASCII → Numeric | `'3'` (33H) → `3` (03H) for CMP  |
| `ADD DL,30H`    | Numeric → ASCII | `7` (07H) → `'7'` (37H) for display |

**If we don't convert:**
The `CMP` still gives the correct relative result for single digits, but the display step would print wrong characters if raw numeric values are output without adding `30H` back.

---

### 12. `LEA DX,MSG1` / `MOV AH,09H` / `INT 21H`

**Purpose:**
This three-instruction sequence prints a string. `LEA` loads the memory **address** of `MSG1` into `DX`. `MOV AH,09H` selects the DOS string-display function. `INT 21H` triggers the interrupt and DOS reads bytes from that address until it finds `$`.

```asm
LEA DX,MSG1   ; DX = address of MSG1 string
MOV AH,09H    ; Select DOS function 09H
INT 21H       ; DOS prints string at DX until '$'
```

**Why `LEA` and not `MOV`?**
`MOV DX,MSG1` would copy the **value stored at** MSG1 (the first bytes `0DH,0AH`) into `DX` — not the address. DOS would then try to print from memory location `0D0AH`, which is invalid and crashes the program. `LEA` loads the **address**, not the content.

---

### 13. `MOV AH,4CH` / `INT 21H` — Program Termination

**Purpose:**
Function `4CH` is the standard DOS program termination. It cleanly returns control to DOS, releases the program's memory, and sets the exit code. This is always the final instruction in a properly written DOS 8086 program.

**If we don't use it:**
The CPU continues executing whatever bytes follow in memory — causing undefined behavior, freezing, crashing, or data corruption.

**Alternative (older style):**
`INT 20H` also terminates but requires `CS` to point to the PSP (Program Segment Prefix). `MOV AH,4CH` + `INT 21H` is more flexible, reliable, and the modern standard.

---

## Program Execution Flow

| Step | Instructions | Action |
|------|-------------|--------|
| 1  | `MOV AX,@DATA` / `MOV DS,AX`             | Initialize DS to point to data segment        |
| 2  | `MOV DL,'?'` / `INT 21H`                 | Display prompt `?` to user                    |
| 3  | `INT 21H` / `MOV CL,AL` / `SUB CL,30H`  | Read first digit, store as numeric in CL      |
| 4  | `INT 21H` / `MOV CH,AL` / `SUB CH,30H`  | Read second digit, store as numeric in CH     |
| 5  | `MOV AL,CL` / `CMP AL,CH` / `JAE`       | Compare digits, jump if first >= second       |
| 6  | `MOV AL,CH` or `MOV AL,CL`              | Load larger digit into AL                     |
| 7  | `ADD AL,30H` / `PUSH AX`                | Convert result to ASCII, save on stack        |
| 8  | `INT 21H` calls for MSG1–MSG3 + digits  | Display the full output sentence              |
| 9  | `POP AX` / `MOV DL,AL` / `INT 21H`     | Restore and display the larger digit          |
| 10 | `MOV AH,4CH` / `INT 21H`               | Terminate program cleanly                     |

---

## How to Run

1. Open **EMU8086**
2. Load the `.asm` file
3. Click **Emulate** → then **Run**
4. Enter two single digits when prompted with `?`
5. Output will appear as: `THE LARGER OF x AND y IS z`
