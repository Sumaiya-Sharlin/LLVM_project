%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yylineno;
extern char* yytext;

void yyerror(const char* s) {
    fprintf(stderr, "Error: %s at line %d near '%s'\n", s, yylineno, yytext);
}
%}

%union {
    char* strval;
    double numval;
}

%token <strval> TOK_IDENTIFIER
%token <numval> TOK_NUMBER
%token TOK_PLUS TOK_MINUS TOK_MUL TOK_DIV
%token TOK_IF TOK_ELSE TOK_FOR
%token TOK_DOUBLE TOK_LPAREN TOK_RPAREN TOK_LBRACE TOK_RBRACE TOK_SEMICOLON
%token TOK_ASSIGN TOK_GREATER TOK_LESS TOK_PRINT TOK_UNKNOWN

%left TOK_PLUS TOK_MINUS
%left TOK_MUL TOK_DIV
%nonassoc TOK_GREATER TOK_LESS

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
    | print_statement
    ;

if_statement:
    TOK_IF TOK_LPAREN expression TOK_RPAREN TOK_LBRACE statement_list TOK_RBRACE
    | TOK_IF TOK_LPAREN expression TOK_RPAREN TOK_LBRACE statement_list TOK_RBRACE TOK_ELSE TOK_LBRACE statement_list TOK_RBRACE
    ;

for_statement:
    TOK_FOR TOK_LPAREN init_statement expression TOK_SEMICOLON update_statement TOK_RPAREN TOK_LBRACE statement_list TOK_RBRACE
    ;

print_statement:
    TOK_PRINT TOK_LPAREN expression TOK_RPAREN TOK_SEMICOLON
    ;

init_statement:
    TOK_DOUBLE TOK_IDENTIFIER TOK_ASSIGN expression TOK_SEMICOLON
    | TOK_IDENTIFIER TOK_ASSIGN expression TOK_SEMICOLON
    | /* empty */
    ;

update_statement:
    TOK_IDENTIFIER TOK_ASSIGN expression
    | /* empty */
    ;

expression:
    term
    | expression TOK_PLUS term
    | expression TOK_MINUS term
    | expression TOK_GREATER term
    | expression TOK_LESS term
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
