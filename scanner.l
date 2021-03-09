%{
// Declarations 	
#include <stdio.h>
#include<string.h>
#include<stdlib.h>

#include "token-types.h"
#include "table.h"

int flagTernary = 0;
int ternaryCount = 0;
int yylineno = 0;

%}

/* required definitions */
alphabet [A-Za-z]
alphanumeral [A-Za-z0-9]
hex [0-9a-f]
digit [0-9]
identifier ({alphabet}|_)({alphabet}|{digit}|_){0,31}
whitespaces  [ \t\r\f\v]+

/* Exclusive states */
%x HEADERFILESTATE
%x MACROSTATE
%x MULCOMMENTSTATE
%x TERNARYSTATE
%x STRINGCONSTSTATE

/* REGULAR EXPRESSION FOR LEXEMS =  */
%%

"#"[ ]*"include"[ ]*	{BEGIN HEADERFILESTATE;}
<HEADERFILESTATE>("<"{alphabet}+".h>")(" "*)("\n")	{yytext[yyleng-2] = '\0'; printf("%d:\t%-20s : %3s\n", yylineno, yytext, "header file <>"); ++yylineno; BEGIN INITIAL;}
<HEADERFILESTATE>(["]{alphabet}+".h"["])(" "*)("\n")	{yytext[yyleng-2] = '\0'; printf("%d:\t%-20s : %3s\n", yylineno, yytext, "header file \"\""); ++yylineno; BEGIN INITIAL;}
<HEADERFILESTATE>.*	{printf("%d:\t \t\t     : %s\n", yylineno, "Error in header" ); BEGIN INITIAL;}

"#"[ ]*"define"[ ]*	{BEGIN MACROSTATE;}
<MACROSTATE>({alphanumeral}+[ ]+{alphanumeral}+)([ ]*)"\n"	{printf("Preprocessor-macros: Correct Macro\n");}
<MACROSTATE>.*	{printf("%d:\t \t\t     : %s\n", yylineno, "Error in marco" ); BEGIN INITIAL;}


"//".*"\n"?	{printf( "%d:\t \t\t     : %s\n", yylineno, "Single line Comment" ); ++yylineno;}

"/*"	{printf( "%d:\t \t\t     : %s\n", yylineno, "Multi-line comments begins" ); BEGIN MULCOMMENTSTATE;}
<MULCOMMENTSTATE>("\n")	{++yylineno;}
<MULCOMMENTSTATE>(.)	;
<MULCOMMENTSTATE>"/*"	{printf("%d:\t \t\t     : %s\n", yylineno, "Error nested multiline comments" ); BEGIN INITIAL;}
<MULCOMMENTSTATE>"*/"	{printf( "%d:\t \t\t     : %s\n", yylineno, "Multi-line comments ends" ); BEGIN INITIAL;}


"int"			{printf("%d:\t%-20s : %3d\n", yylineno, yytext, INT);       insert_table(yytext, "KW", INT);}
"long"			{printf("%d:\t%-20s : %3d\n", yylineno, yytext, LONG);      insert_table(yytext, "KW", LONG);}
"short"			{printf("%d:\t%-20s : %3d\n", yylineno, yytext, SHORT);     insert_table(yytext, "KW", SHORT);}
"long long"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, LONG_LONG); insert_table(yytext, "KW", LONG_LONG);}
"char"			{printf("%d:\t%-20s : %3d\n", yylineno, yytext, CHAR);      insert_table(yytext, "KW", CHAR);}
"signed"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, SIGNED);    insert_table(yytext, "KW", SIGNED);}
"unsigned"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, UNSIGNED);  insert_table(yytext, "KW", UNSIGNED);}
"float"			{printf("%d:\t%-20s : %3d\n", yylineno, yytext, FLOAT);     insert_table(yytext, "KW", FLOAT);}
"double"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, DOUBLE);    insert_table(yytext, "KW", DOUBLE);}
"for"			{printf("%d:\t%-20s : %3d\n", yylineno, yytext, FOR);       insert_table(yytext, "KW", FOR);}
"while"			{printf("%d:\t%-20s : %3d\n", yylineno, yytext, WHILE);     insert_table(yytext, "KW", WHILE);}
"if"			{printf("%d:\t%-20s : %3d\n", yylineno, yytext, IF);        insert_table(yytext, "KW", IF);}
"else"			{printf("%d:\t%-20s : %3d\n", yylineno, yytext, ELSE);      insert_table(yytext, "KW", ELSE);}
"else if"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, ELSE_IF);   insert_table(yytext, "KW", ELSE_IF);}
"continue"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, CONTINUE);  insert_table(yytext, "KW", CONTINUE);}
"break"			{printf("%d:\t%-20s : %3d\n", yylineno, yytext, BREAK);     insert_table(yytext, "KW",BREAK);}
"return"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, RETURN);    insert_table(yytext, "KW", RETURN);}

{whitespaces}	;

({identifier})				{printf("%d:\t%-20s : %3d\n", yylineno, yytext, ID); insert_table(yytext, "ID", ID);}


[+\-]?[0][x|X]{hex}+[lLuU]?	{printf("%d:\t%-20s : %3d\n", yylineno, yytext, HEX_CONST);}
[+\-]?{digit}+[lLuU]?		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, INT_CONST);}
[+\-]?{digit}+[.]{digit}+	{printf("%d:\t%-20s : %3d\n", yylineno, yytext, REAL_CONST);}
\"							{BEGIN STRINGCONSTSTATE;}
<STRINGCONSTSTATE>\"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, STRING_CONST); BEGIN INITIAL;}
<STRINGCONSTSTATE>\n		{printf("%d:\t \t\t     : %s\n", yylineno, "Error in string constant" ); ++yylineno; BEGIN INITIAL;}
<STRINGCONSTSTATE>.			;

({digit}+)({identifier})	{printf("%d:\t%-20s : %s\n", yylineno, yytext, "Error in identifier naming" );}

\n		{++yylineno;}

"-"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, SUBTRACTION);}
"+"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, ADDITION);}
"*"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, MULTIPLICATION);}
"/"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, DIVISION);}
"%"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, MODULO);}
"^"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, POWER);}

"=="	{printf("%d:\t%-20s : %3d\n", yylineno, yytext, EQUALS);}
"<="	{printf("%d:\t%-20s : %3d\n", yylineno, yytext, LESS_THAN_EQUAL_TO);}
">="	{printf("%d:\t%-20s : %3d\n", yylineno, yytext, GREATER_THAN_EQUAL_TO);}
"<"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, LESS_THAN);}
">"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, GREATER_THAN);}
"!="	{printf("%d:\t%-20s : %3d\n", yylineno, yytext, NOT_EQUAL);}

"="		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, ASSIGN);}

"&&"	{printf("%d:\t%-20s : %3d\n", yylineno, yytext, LOGICAL_AND);}
"||"	{printf("%d:\t%-20s : %3d\n", yylineno, yytext, LOGICAL_OR);}
"&"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, BITWISE_AND);}
"|"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, BITWISE_OR);}
"!"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, LOGICAL_NOT);}

"<<"	{printf("%d:\t%-20s : %3d\n", yylineno, yytext, LEFT_SHIFT);}
">>"	{printf("%d:\t%-20s : %3d\n", yylineno, yytext, RIGHT_SHIFT);}


";" {
			
		if (flagTernary > 0){
			printf("%d:\t \t\t     : %s\n", yylineno, "Error in CONDITIONAL OPERATOR" );
			ternaryCount = 0;
		} 
		for (int i=0;i<ternaryCount;i++){
			printf("%d:\t%-20s : %3d\n", yylineno, "?:", CONDITIONAL);
		}
		ternaryCount = 0;
		flagTernary = 0;
		printf("%d:\t%-20s : %3d\n", yylineno, yytext, SEMICOLON); 
	}
","		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, COMMA);}
"{" 	{printf("%d:\t%-20s : %3d\n", yylineno, yytext, O_BRACES);}
"}" 	{printf("%d:\t%-20s : %3d\n", yylineno, yytext, C_BRACES);}
"("		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, O_PARENTHESES);}
")"		{printf("%d:\t%-20s : %3d\n", yylineno, yytext, C_PARENTHESES);}
"[" 	{printf("%d:\t%-20s : %3d\n", yylineno, yytext, O_BRACKETS);}
"]" 	{printf("%d:\t%-20s : %3d\n", yylineno, yytext, C_BRACKETS);}

"?"   {flagTernary+= 1;++ternaryCount;}
":" {	
		flagTernary-= 1;
		if(flagTernary < 0){   
			printf("%d:\t \t\t     : %s\n", yylineno, "Error in CONDITIONAL OPERATOR" );
		} 

	}
.		{printf("%d:\t%-20s    : %s\n", yylineno, yytext, "Error invalid character" );};

%%

// auxiliary procedures 
int yywrap() {return 1;}

int main() {
	yylex(); 
	return 0;
}

