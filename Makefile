# Simple Makefile for the Lex/Yacc compiler
CC = gcc
LEX = flex
YACC = /opt/homebrew/opt/bison/bin/bison
TARGET = compiler

all: $(TARGET) interpreter

$(TARGET): compiler.tab.c lex.yy.c symbol_table.c symbol_table.h asm_output.c asm_output.h
	$(CC) compiler.tab.c lex.yy.c symbol_table.c asm_output.c -o $(TARGET)

interpreter: interp.tab.c lex.interp.c interp_backend.c
	$(CC) interp.tab.c lex.interp.c interp_backend.c -o interpreter

compiler.tab.c: compiler.y symbol_table.h
	$(YACC) -d compiler.y

compiler.tab.h: compiler.tab.c

lex.yy.c: compiler.lex compiler.tab.h
	$(LEX) compiler.lex

interp.tab.c: interp.y
	$(YACC) -d -p interp interp.y -o interp.tab.c

interp.tab.h: interp.tab.c

lex.interp.c: interp.lex interp.tab.h
	$(LEX) -P interp -o lex.interp.c interp.lex

test: all
	if ./$(TARGET) < test_semantic_error.c > /tmp/compiler_semantic_error.log 2>&1; then cat /tmp/compiler_semantic_error.log; exit 1; fi
	./$(TARGET) < test_control_flow.c > /tmp/compiler_control_flow.log
	./interpreter < target_encoded.asm > /tmp/control_flow_actual.out
	diff -u expected_control_flow.out /tmp/control_flow_actual.out
	./$(TARGET) < test_required.c > /tmp/compiler_required.log
	./interpreter < target_encoded.asm > /tmp/required_actual.out
	diff -u expected_required.out /tmp/required_actual.out
	@echo "All tests passed"

clean:
	rm -f $(TARGET) interpreter compiler.tab.c compiler.tab.h lex.yy.c interp.tab.c interp.tab.h lex.interp.c target.asm target_encoded.asm
