    // version 1.0 05/22/2022 //
#ifndef MYMAIN_S
#else
    .arch   armv6
    .arm
    .fpu    vfp
    .syntax unified

    // imports
    #include "main.h"
    #include "rdbuf.h"
    #include "setup.h"
    #include "cipher.h"
    .extern fwrite
    .extern stdin
    .extern stdout
    .extern stderr

    .section .rodata
    // do not change these error messages
.Lbdrd:  .string "%s: read failed\n"
.Lbdwr:  .string "%s: write failed\n"

    .text

    //
    // encrypter [-d | -e] -b bookfile
    //
    // int main(int argc, char **argv)
    // int main(r0=argc, r1=argv)

    .global main
    .type   main, %function

    //
    // stack frame layout
    //
    // TODO PA9: complete the following stack frame design
    // You can change or delete any comments in this file
    //
    .equ    FP_OFF,     32          // fp offset in main stack frame
    .equ    FPBOOK,     4+FP_OFF            // FILE * to book file
    .equ    IOBUF,      BUFSZ+FPBOOK            // buffer for input file
    .equ    MODE,       4+IOBUF            // decrypt or encrypt mode
    .equ    BOOKBUF,    BUFSZ+MODE            // buffer for book file
    .equ    ARGV0,      4+BOOKBUF            // save argv[0] for error printing
    //
    // add your local variables here if you need them:
    // NOTICE: Adjust PAD so FRMADD + FP_OFF + 4 divides by 8 EVENLY!
    //
    .equ    PAD,       4+ARGV0             // Stack frame PAD
    .equ    OARG5,     4+PAD             // output arg5 must be at bottom
    .equ    FRMADD,    OARG5-FP_OFF // space in frame for locals+passed args

    // TODO PA9: list how you are using the preserved registers
    // preserved register use
    // r4 
    // r5 
    // r6 
    // r7
    // r8 
    // r9 
    // r10

main:
    push    {r4-r10, fp, lr}        // push all the usable preserved registers
    add     fp, sp, FP_OFF          // set frame pointer to frame base
    ldr     r3, =FRMADD             // get space needed for locals+passed args
    sub     sp, sp, r3              // allocate space for locals and passed args 
    ldr     r8, [r1]
    str     r8, [fp, -ARGV0]
    ldr     r4, =FPBOOK
    sub     r4, fp, r4
    ldr     r5, =IOBUF
    sub     r5, fp, r5
    ldr     r6, =MODE
    sub     r6, fp, r6
    ldr     r7, =BOOKBUF
    sub     r7, fp, r7
    mov     r2, r6
    mov     r3, r4
    bl      setup
    cmp     r0, EXIT_FAILURE
    beq     .Lf
    ldr     r6, =MODE
    ldr     r6, [fp, -r6]
    // save argv[0] in argv0
    // at the entry to main() argc is in r0 and argv is in r1.
    // call int setup(r0=argc, r1=argv, r2=*mode, r3=*FPBOOK)
    // r2 and r2 are output parameters. Put the address of where mode
    // and FPBOOK are located on main()'s stack and put these in r2 and r3
    // so setup can fill them in (passing a pointer to a local variable in r2,r3)
    // if setup fails, put EXIT_FAIL in r0 and then branch to .Lexit

    // set up for main loop
    // save the variables you need in the preserved registers as you will be making
    // function calls in the loop body below and r0-r3 will be used for that

.Lloop:
    ldr     r0, =stdin
    ldr     r0, [r0]
    ldr     r1, [r4]
    ldr     r2, =BUFSZ
    mov     r3, r5
    ldr     r9, =OARG5
    str     r7, [fp, -r9]
    bl      rdbuf
    mov     r9, r0
    cmp     r9, 0
    beq     .Ldone
    blt     .Lr
    cmp     r6, ENCRYPT_MODE
    bne     .Lde
    mov     r0, r5
    mov     r1, r7
    mov     r2, r9
    bl      encrypt
    mov     r9, r0
    b       .Lendmodeif
.Lde:
    mov     r0, r5
    mov     r1, r7
    mov     r2, r9
    bl      decrypt
    mov     r9, r0
.Lendmodeif:
    mov     r0, r5
    mov     r1, 1
    mov     r2, r9
    ldr     r3, =stdout
    ldr     r3, [r3]
    bl      fwrite
    cmp     r0, r9
    bne     .Lw
    b       .Lloop
    // this is a loop that runs until rdbuf indicates the EOF on stdin
    // was reached or there was an error.
    // int rdbuf(r0=stdin, r1=fpbook, r2=BUFSZ, r3=iobuf,OARG5=bookbuf)
    // NOTICE that the 5th arg is on the stack so you need to str the 
    // address of bookbuf at offset OARG5 on the stack
    // if r0 on return from rdbuf has a 0 in r0 we are done, branch to .Ldone
    // if return less than 0, error print to stderr .Lbdrd, and go to .Ldone

    // check the mode flag and call either encrypt or decrypt
    // int XXcrypt(r0=char *iobuf, r1=char *bookbuf, r2=int cnt)
    // encrypt or decrypt 
    // returns cnt

    // make sure to save cnt so we can check that fwrite wrote cnt characters
    // fwrite returns number of characters it wrote.
    // fwrite(r0=iobuf, r1=1, r2=cnt, r3=*stdout)
    // if cnt characters written go to .Lloop (write is ok)
    // othewise error, print to stderr .Lbdwr and fall through to .Ldone
.Lf:
    mov     r0, EXIT_FAILURE
    b       .Lexit
.Lr:
    ldr     r0, [r4]
    bl      fclose
    ldr     r0, =stderr
    ldr     r0, [r0]
    ldr     r1, =.Lbdrd
    mov     r2, r8
    bl      fprintf
    b       .Lf
.Lw:
    ldr     r0, =stderr
    ldr     r0, [r0]
    ldr     r1, =.Lbdwr
    mov     r2, r8
    bl      fprintf
    mov     r0, r4
    bl      fclose
    b       .Lf
.Ldone:
    ldr     r0, [r4]
    bl      fclose
    mov     r0, EXIT_SUCCESS
    // normal exit, call fclose of fpbook and fall through
    // to .Lexit

.Lexit:
    sub     sp, fp, FP_OFF
    pop     {r4-r10, fp, lr}
    bx      lr

    .size   main, (. - main)
    .section .note.GNU-stack,"",%progbits
.end
#endif
