# C Compiler with Flex/Bison

A basic cross-compiler developed using Flex (lexical analyzer) and Bison (syntax analyzer). 
It translates a simplified C-like language into a custom Register-oriented assembly instruction set.

## Prerequisites
- `gcc`
- `flex`
- `bison` (installed via Homebrew: `/opt/homebrew/opt/bison/bin/bison`)

## Features
- Lexical analysis using `flex` recognizing operators, integers, identifiers, and basic keywords.
- Syntax analysis using `bison` generating an intermediate representation.
- Symbol table management for variables and assignments.
- Assembly code generation with correct temporary storage allocation (`AFC`, `COP`, `ADD`, `MUL`, `DIV`, `SOU`, `PRI`).

## Output Files
When you run the compiler, it generates two files:
1. `target.asm` - Plain-text human-readable assembly instructions using mnemonics.
2. `target_encoded.asm` - Encoded version of the assembly where opcodes are translated into their numeric representations.

## How to use

1. **Compile the compiler:**
   ```bash
   make
   ```

2. **Run the compiler on a C file:**
   ```bash
   ./compiler < your_source_file.c
   ```
   *Note: This will generate `target.asm` and `target_encoded.asm` in the current directory.*

3. **Run the built-in test program:**
   ```bash
   make test
   ```
   This will pass `test.c` into the compiler, outputting the generated assembly to the terminal, as well as generating the `target.asm` and `target_encoded.asm` files.

4. **Clean generated files:**
   ```bash
   make clean
   ```
