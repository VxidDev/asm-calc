# asm-calc

Simple calculator made in pure assembly x86-64 code

## How to build the code

dependencies:
- nasm
- ld
- linux based system

```
nasm -f elf64 main.s -o main.o
ld main.o -o main
./main
```

## Operations Supported

- addition ('+')
- subtraction ('-')
- multiplication ('*')
- division ('/')

## Was it worth it?
no, writing this was an absolute torture. 1/10 dont recommend

## LoC
`> 350 lines of code`
