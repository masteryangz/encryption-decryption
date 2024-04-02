#ifndef MYDECRYPT_S
#else
// version 1.0 11/12/2022
    .arch armv6
    .arm
    .fpu vfp
    .syntax unified

    #include "cipher.h"

    .text     // start of text segment

    //////////////////////////////////////////////////
    // int decrypt(char *iobuf, char *bookbuf, int cnt)
    // decrypts iobuf using bookbuf; result in iobuf
    //////////////////////////////////////////////////
    .global decrypt
    .type   decrypt, %function
    .equ    FP_OFF, 28

decrypt:
    push    {r4-r9, fp, lr}
    add     fp, sp, FP_OFF
    // do not alter anything above this line
    // r0 contains char *iobuf
    // r1 contains char *bookbuf
    // r2 contains cnt
    // r3 is ok to use
    // r4-r9 preserved registers are ok to use

    cmp     r2, 0               // if buffer empty we are done
    ble     .Ldone
    mov    r4, r2
.Lwhile:
    cmp     r4, 0
    ble     .Ldone
    mov     r5, 0
    ldrb    r6, [r0]
    ldrb    r7, [r1]
    eor     r8, r6, r7
    mov     r9, 0
.Lfor:
    cmp     r9, 8
    bge     .Lendfor
    lsl     r5, r5, 1
    and     r3, r8, 1
    add     r5, r5, r3
    lsr     r8, r8, 1
    add     r9, r9, 1
    b       .Lfor
.Lendfor:
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

    .size decrypt, (. - decrypt)
    .section .note.GNU-stack,"",%progbits
.end
#endif
