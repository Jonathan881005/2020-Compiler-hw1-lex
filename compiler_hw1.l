/* Definition section */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define YY_NO_UNPUT
    #define YY_NO_INPUT

    int line_num = 0;
    int comment_num = 0;
    int quotachar_num = 0;
    int isbigcomment = 0;
    int islinecomment = 0;
%}
%x C_COMMENT QUOTA CPP_COMMENT

/* Define regular expression label */
letter [a-zA-Z_]
digit [0-9]

id {letter}+({letter}|{digit})*
inumber {digit}+
fnumber ({digit}*\.{digit}+)

/* Rules section */
%%

"+"         { printf("%-8s \t %s\n", yytext, "ADD"); }
"-"         { printf("%-8s \t %s\n", yytext, "SUB"); }
"*"         { printf("%-8s \t %s\n", yytext, "MUL"); }
"/"         { printf("%-8s \t %s\n", yytext, "QUO"); }
"%"         { printf("%-8s \t %s\n", yytext, "REM"); }
"++"         { printf("%-8s \t %s\n", yytext, "INC"); }
"--"         { printf("%-8s \t %s\n", yytext, "DEC"); }

">"         { printf("%-8s \t %s\n", yytext, "GTR"); }
"<"         { printf("%-8s \t %s\n", yytext, "LSS"); }
">="         { printf("%-8s \t %s\n", yytext, "GEQ"); }
"<="         { printf("%-8s \t %s\n", yytext, "LEQ"); }
"=="         { printf("%-8s \t %s\n", yytext, "EQL"); }
"!="         { printf("%-8s \t %s\n", yytext, "NEQ"); }
"="         { printf("%-8s \t %s\n", yytext, "ASSIGN"); }
"+="         { printf("%-8s \t %s\n", yytext, "ADD_ASSIGN"); }
"-="         { printf("%-8s \t %s\n", yytext, "SUB_ASSIGN"); }
"*="         { printf("%-8s \t %s\n", yytext, "MUL_ASSIGN"); }
"/="         { printf("%-8s \t %s\n", yytext, "QUO_ASSIGN"); }
"%="         { printf("%-8s \t %s\n", yytext, "REM_ASSIGN"); }

"&&"         { printf("%-8s \t %s\n", yytext, "LAND"); }
"||"         { printf("%-8s \t %s\n", yytext, "LOR"); }
"!"         { printf("%-8s \t %s\n", yytext, "NOT"); }
"("         { printf("%-8s \t %s\n", yytext, "LPAREN"); }
")"         { printf("%-8s \t %s\n", yytext, "RPAREN"); }
"["         { printf("%-8s \t %s\n", yytext, "LBRACK"); }
"]"         { printf("%-8s \t %s\n", yytext, "RBRACK"); }
"{"         { printf("%-8s \t %s\n", yytext, "LBRACE"); }
"}"         { printf("%-8s \t %s\n", yytext, "RBRACE"); }
";"         { printf("%-8s \t %s\n", yytext, "SEMICOLON"); }
","         { printf("%-8s \t %s\n", yytext, "COMMA"); }
"\n"         { printf("         \t %s\n",  "NEWLINE");  islinecomment = 0;  line_num++; }



"print"         { printf("%-8s \t %s\n", yytext, "PRINT"); }
"println"         { printf("%-8s \t %s\n", yytext, "PRINTLN"); }
"if"         { printf("%-8s \t %s\n", yytext, "IF"); }
"else"         { printf("%-8s \t %s\n", yytext, "ELSE"); }
"for"         { printf("%-8s \t %s\n", yytext, "FOR"); }

"int32"         { printf("%-8s \t %s\n", yytext, "INT"); }
"float32"         { printf("%-8s \t %s\n", yytext, "FLOAT"); }
"string"         { printf("%-8s \t %s\n", yytext, "STRING"); }
"bool"         { printf("%-8s \t %s\n", yytext, "BOOL"); }
"true"         { printf("%-8s \t %s\n", yytext, "TRUE"); }
"false"         { printf("%-8s \t %s\n", yytext, "FALSE"); }
"var"         { printf("%-8s \t %s\n", yytext, "VAR"); }

{inumber}         { printf("%-8s \t %s\n", yytext, "INT_LIT"); }
{fnumber}         { printf("%-8s \t %s\n", yytext, "FLOAT_LIT"); }
{id}        { printf("%-8s \t %s\n", yytext, "IDENT"); }

""

"\""         { printf("%-8s \t %s\n", yytext, "QUOTA");BEGIN(QUOTA); }
<QUOTA>"\"" {   quotachar_num = 8 - quotachar_num;
                while(quotachar_num--)printf(" ");
                quotachar_num = 0;
                printf(" \t %s\n",   "STRING"); 
                printf("%-8s \t %s\n",  yytext, "QUOTA");
                BEGIN(INITIAL); }
<QUOTA>"\n" { printf("          \t %s\n", "STRING"); }
<QUOTA>. { printf("%s", yytext); quotachar_num++; }


"/*"        { printf("%s", yytext); 
                if((!isbigcomment) && (!islinecomment))
                {
                    comment_num++; 
                    }
                isbigcomment = 1;
                BEGIN(C_COMMENT); }
<C_COMMENT>"*/" { printf("%-8s \t %s\n", yytext, "C Comment");
                    isbigcomment = 0; 
                    islinecomment = 1;
                    BEGIN(INITIAL); }
<C_COMMENT>"\n" { printf("\n        \t %s\n",  "C Comment"); 
                    line_num++;
                    comment_num++; }
<C_COMMENT>. { printf("%s", yytext); }


"//"        { printf("%s", yytext); 
                if((!isbigcomment) && (!islinecomment))
                {
                    comment_num++; }
                islinecomment = 1; 
                BEGIN(CPP_COMMENT); }
<CPP_COMMENT>"\n" { printf(" \t %s\n         \t %s\n", "C++ Comment", "NEWLINE"); 
                    line_num++;
                    islinecomment = 0; 
                    BEGIN(INITIAL); }
<CPP_COMMENT>. { printf("%s", yytext); }



<<EOF>>     { line_num++; yyterminate(); }
.           {;}

%%

/*  C Code section */
int yywrap(void)
{
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    yylex();
    printf("\nFinish scanning,\n");
    printf("total line: %d\n", line_num);
    printf("comment line: %d\n", comment_num);
    fclose(yyin);
    return 0;
}
