%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"

// Required by the parser to call the lexer
extern int yylex();
extern int yylineno;
extern char* yytext;

// Error handling
void yyerror(const char* s) {
    fprintf(stderr, "Error: %s at line %d near '%s'\n", s, yylineno, yytext);
}
%}

%token TOK_PLUS TOK_MINUS TOK_MUL TOK_DIV
%token TOK_IF TOK_ELSE TOK_FOR
%token TOK_DOUBLE TOK_IDENTIFIER TOK_NUMBER
%token TOK_LPAREN TOK_RPAREN TOK_LBRACE TOK_RBRACE TOK_SEMICOLON
%token TOK_ASSIGN

%left TOK_PLUS TOK_MINUS
%left TOK_MUL TOK_DIV

%%
program:
    statement_list
    ;

statement_list:
    statement
    | statement_list statement
    ;

statement:
    TOK_DOUBLE TOK_IDENTIFIER TOK_ASSIGN expression TOK_SEMICOLON
    | TOK_IDENTIFIER TOK_ASSIGN expression TOK_SEMICOLON
    | if_statement
    | for_statement
    ;

if_statement:
    TOK_IF TOK_LPAREN expression TOK_RPAREN TOK_LBRACE statement_list TOK_RBRACE
    | TOK_IF TOK_LPAREN expression TOK_RPAREN TOK_LBRACE statement_list TOK_RBRACE TOK_ELSE TOK_LBRACE statement_list TOK_RBRACE
    ;

for_statement:
    TOK_FOR TOK_LPAREN statement expression TOK_SEMICOLON statement TOK_RPAREN TOK_LBRACE statement_list TOK_RBRACE
    ;

expression:
    term
    | expression TOK_PLUS term
    | expression TOK_MINUS term
    ;

term:
    factor
    | term TOK_MUL factor
    | term TOK_DIV factor
    ;

factor:
    TOK_NUMBER
    | TOK_IDENTIFIER
    | TOK_LPAREN expression TOK_RPAREN
    ;

%%
int main() {
    printf("Parsing started...\n");
    if (!yyparse()) {
        printf("Parsing completed successfully.\n");
    } else {
        printf("Parsing failed.\n");
    }
    return 0;
}
