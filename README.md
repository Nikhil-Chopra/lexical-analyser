
## Lexical analyser using FLEX
  download and install dependencies
    
    -- https://sourceforge.net/projects/gnuwin32/files/bison/
    -- https://sourceforge.net/projects/gnuwin32/files/flex/
    -- C compiler
    
    -- https://www.youtube.com/watch?v=0MUULWzswQE

## Usage

# Run
```
compile and run
flex scanner.l          // gives ==> lex.yy.c
gcc lex.yy.c            // gives ==> a.exe 
./a.exe                 // give input
