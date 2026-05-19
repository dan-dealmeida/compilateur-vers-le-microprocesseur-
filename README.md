# C Compiler with Flex/Bison

A basic cross-compiler developed using Flex (lexical analyzer) and Bison (syntax analyzer). 
It translates a simplified C-like language into a custom Register-oriented assembly instruction set.

## Prerequisites
- `gcc`
- `flex`
- `bison` (installed via Homebrew: `/opt/homebrew/opt/bison/bin/bison`)

## Features
- Lexical analysis using `flex` recognizing operators, decimal/exponential integers, identifiers, and keywords.
- Syntax analysis using `bison` for a simplified C-like language.
- Symbol table management for variables, constants, and memory addresses.
- Assembly code generation with temporary storage allocation (`AFC`, `COP`, `ADD`, `MUL`, `DIV`, `SOU`, `PRI`, comparisons, jumps).
- Interpreter for the encoded assembly output.

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

3. **Run the required tests:**
   ```bash
   make test
   ```
   This builds the compiler and interpreter, runs example programs, compares interpreter output, and checks that a semantic error is rejected.

4. **Run the interpreter manually:**
   ```bash
   ./interpreter < target_encoded.asm
   ```

5. **Clean generated files:**
   ```bash
   make clean
   ```

## Explanation

See `EXPLANATION.md` for a simple walkthrough of how the lexer, parser, symbol table, assembly generation, and interpreter work.
