%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%%
"double"            { return TOK_DOUBLE; }
"if"                { return TOK_IF; }
"else"              { return TOK_ELSE; }
"for"               { return TOK_FOR; }
"("                 { return TOK_LPAREN; }
")"                 { return TOK_RPAREN; }
"{"                 { return TOK_LBRACE; }
"}"                 { return TOK_RBRACE; }
";"                 { return TOK_SEMICOLON; }
"="                 { return TOK_ASSIGN; }
">"                 { return TOK_GREATER; }
"<"                 { return TOK_LESS; }
"+"                 { return TOK_PLUS; }
"-"                 { return TOK_MINUS; }
"*"                 { return TOK_MUL; }
"/"                 { return TOK_DIV; }
"print"             { return TOK_PRINT; }


[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.strval = strdup(yytext);
    return TOK_IDENTIFIER;
}

[0-9]+(\.[0-9]+)? {
    yylval.numval = atof(yytext);
    return TOK_NUMBER;
}

[ \t\n]+            { /* Skip whitespace */ }
.                   { printf("Unknown character: %s\n", yytext); return TOK_UNKNOWN; }
%%
