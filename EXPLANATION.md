# Compiler and Interpreter Explanation

This project follows the pipeline from the PDF:

```text
simplified C source -> compiler -> assembly -> encoded assembly -> interpreter output
```

## 1. Lexical Analysis

`compiler.lex` is the lexer. It reads characters and returns tokens to Bison.

Examples:

- `int` becomes `tINT`
- `main` becomes `tMAIN`
- `printf` becomes `tPRINTF`
- variable names like `total_1` become `tID`
- numbers like `42` or `1e3` become `tNB`
- operators like `+`, `-`, `*`, `/`, `=`, `<`, `>`, `==` become operator tokens

The lexer does not understand the grammar. It only recognizes words, numbers, symbols, and separators.

## 2. Syntax Analysis

`compiler.y` is the parser. It describes the grammar of the simplified C language.

The accepted program shape is:

```c
main() {
    declarations;
    instructions;
}
```

It also accepts `int main()` because that is common C syntax.

Declarations must appear before instructions, as required by the PDF:

```c
int i, j, result;
const c = 2;
i = 3;
```

The parser understands assignments, arithmetic expressions, comparisons, `printf(x);`, and simple `if`, `else`, and `while`.

## 3. Symbol Table

`symbol_table.c` stores declared variables and constants. Each name receives a memory address:

```text
i -> address 1
j -> address 2
result -> address 3
```

The generated assembly works with memory addresses, not variable names. This is why the compiler needs the symbol table.

The symbol table reports semantic errors such as using an undeclared variable, declaring the same variable twice, or assigning a new value to a `const`.

## 4. Assembly Generation

`asm_output.c` writes two output files:

- `target.asm`: readable assembly
- `target_encoded.asm`: numeric assembly for the interpreter

Example:

```text
AFC 5 3
COP 1 5
```

This means:

- `AFC 5 3`: put constant value `3` in memory address `5`
- `COP 1 5`: copy the value at address `5` into address `1`

Expressions use temporary memory addresses. For `r = (i + j) * (i + k / j);`, the compiler computes intermediate results in temporary addresses, then copies the final result into `r`.

## 5. Instruction Set

| Code | Name | Meaning |
| --- | --- | --- |
| 1 | ADD | addition |
| 2 | MUL | multiplication |
| 3 | SOU | subtraction |
| 4 | DIV | division |
| 5 | COP | copy memory value |
| 6 | AFC | assign constant |
| 7 | JMP | unconditional jump |
| 8 | JMF | jump if false |
| 9 | INF | lower-than comparison |
| 10 | SUP | greater-than comparison |
| 11 | EQU | equality comparison |
| 12 | PRI | print value |

Readable assembly uses names like `ADD`; encoded assembly uses numbers like `1`.

## 6. Interpreter

The interpreter is made from `interp.lex`, `interp.y`, and `interp_backend.c`.

It reads `target_encoded.asm`, stores the instructions in memory, then executes them one by one with a program counter `pc`.

It also has a data memory array:

```c
int data_mem[MAX_MEM];
```

Example encoded program:

```text
6 1 3
12 1
```

Opcode `6` is `AFC`, so memory address `1` receives value `3`. Opcode `12` is `PRI`, so the interpreter prints memory address `1`.

Output:

```text
3
```

## 7. How To Test

Run:

```bash
make test
```

This compiles the compiler and interpreter, runs required examples, compares interpreter output with expected files, and checks that a semantic error is rejected.

The main required test is `test_required.c`, based on the PDF example. It should print:

```text
35
3
1002
```

## 8. Professor Questions

**Why use Lex/Flex?**

To split the source text into tokens. It turns `int x = 3;` into meaningful pieces like `tINT`, `tID`, `tASSIGN`, `tNB`, `tSEMI`.

**Why use Yacc/Bison?**

To check that the token sequence follows the grammar, and to run C actions when grammar rules are recognized.

**Why do we need a symbol table?**

Because the source program uses variable names, but the assembly uses memory addresses.

**Why generate two assembly files?**

The readable file is for humans. The encoded file is easier for the interpreter because every instruction is represented by a number.

**What does `JMF` do?**

`JMF condition target` jumps to `target` only if the condition value is `0`, meaning false.

**How does `while` work?**

The compiler remembers the line where the condition starts, emits a `JMF` to leave the loop when false, emits the loop body, then emits a `JMP` back to the condition.

**What happens when there is an error?**

Syntax errors are reported by Bison. Semantic errors, such as undeclared variables or assigning to a `const`, are reported by the compiler and cause a non-zero exit code.
