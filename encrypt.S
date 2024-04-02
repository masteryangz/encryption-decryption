#ifndef MYENCRYPT_S
#else
// version 1.0 11/12/2022
    .arch armv6
    .arm
    .fpu vfp
    .syntax unified

    #include "cipher.h"

    .text     // start of text segment

    //////////////////////////////////////////////////
    // int encrypt(char *iobuf, char *bookbuf, int cnt)
    // encrypts  iobuf with bookbuf; updating iobuf
    //////////////////////////////////////////////////
    .global encrypt
    .type   encrypt, %function
    .equ    FP_OFF, 28

encrypt:
    push    {r4-r9, fp, lr}
    add     fp, sp, FP_OFF
    // r0 contains char *iobuf
    // r1 contains char *bookbuf
    // r2 contains cnt
    // r3 is ok to use
    // r4-r9 preserved registers are ok to use

    cmp     r2, 0               // if buffer empty we are done
    ble     .Ldone
    mov     r4, r2
.Lwhile:
    cmp     r4, 0
    ble     .Ldone
    mov     r5, 0
    ldrb    r6, [r0]
    mov     r7, 0
.Lfor:
    cmp     r7, 8
    bge     .Lendfor
    lsl     r5, r5, 1
    and     r9, r6, 1
    add     r5, r5, r9
    lsr     r6, r6, 1
    add     r7, r7, 1
    b       .Lfor
.Lendfor:
    ldrb    r3, [r1]
    eor     r5, r5, r3
    strb    r5, [r0]
    add     r1, r1, 1
    add     r0, r0, 1
    sub     r4, r4, 1
    b       .Lwhile
.Ldone:
    mov     r0, r2              // return cnt processed
    sub     sp, fp, FP_OFF
    pop     {r4-r9, fp, lr}
    bx      lr

    .size encrypt, (. - encrypt)
    .section .note.GNU-stack,"",%progbits
.end
#endif
