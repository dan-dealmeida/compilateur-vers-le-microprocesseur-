#include <stdio.h>
#include <string.h>
#include "symbol_table.h"

static Symbol table[MAX_SYMBOLS];
static int symbol_count = 0;
static int next_addr = 0;   // next address for declared variables
static int temp_addr = 0;   // current temporary address pointer

static FuncSymbol func_table[MAX_FUNCTIONS];
static int func_count = 0;

void init_symbol_table(void) {
    symbol_count = 0;
    next_addr = 0;
    temp_addr = 0;
    func_count = 0;
}

void reset_local_symbol_table(void) {
    symbol_count = 0;
    // do NOT reset next_addr! Keep globally advancing.
    temp_addr = next_addr;
}

int add_symbol(const char *name, int is_const, int is_pointer) {
    // Check for redeclaration
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(table[i].name, name) == 0) {
            fprintf(stderr, "Error: symbol '%s' already declared\n", name);
            return -1;
        }
    }
    if (symbol_count >= MAX_SYMBOLS) {
        fprintf(stderr, "Error: symbol table full\n");
        return -1;
    }

    strncpy(table[symbol_count].name, name, 63);
    table[symbol_count].name[63] = '\0';
    table[symbol_count].address = next_addr;
    table[symbol_count].is_const = is_const;
    table[symbol_count].is_pointer = is_pointer;
    table[symbol_count].is_initialized = 0;
    symbol_count++;

    int addr = next_addr;
    next_addr++;
    // Keep temp zone above declared variables
    temp_addr = next_addr;
    return addr;
}

int lookup_symbol(const char *name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(table[i].name, name) == 0) {
            return table[i].address;
        }
    }
    fprintf(stderr, "Error: undeclared symbol '%s'\n", name);
    return -1;
}

int get_temp_addr(void) {
    return temp_addr++;
}

void free_temp_addr(void) {
    if (temp_addr > next_addr) {
        temp_addr--;
    }
}

int add_function(const char *name, int start_line, int return_address, int *param_opts, int num_params) {
    if (func_count >= MAX_FUNCTIONS) {
        fprintf(stderr, "Error: function table full\n");
        return -1;
    }
    for (int i = 0; i < func_count; i++) {
        if (strcmp(func_table[i].name, name) == 0) {
            fprintf(stderr, "Error: function '%s' already declared\n", name);
            return -1;
        }
    }
    strncpy(func_table[func_count].name, name, 63);
    func_table[func_count].name[63] = '\0';
    func_table[func_count].start_line = start_line;
    func_table[func_count].return_address = return_address;
    func_table[func_count].num_params = num_params;
    for(int i = 0; i < num_params; i++) {
        func_table[func_count].param_addresses[i] = param_opts[i];
    }
    func_count++;
    return 0;
}

FuncSymbol* lookup_function(const char *name) {
    for (int i = 0; i < func_count; i++) {
        if (strcmp(func_table[i].name, name) == 0) {
            return &func_table[i];
        }
    }
    fprintf(stderr, "Error: undeclared function '%s'\n", name);
    return NULL;
}