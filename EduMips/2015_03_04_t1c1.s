; Copyright (C) 2017 by Spallina Ind.

.data
s: .space 160
a: .space 32
b: .space 32
n: .space 32

str1: .asciiz "Inserisci un numero\n"
str2: .asciiz "Inserisce una stringa con almeno %d caratteri\n"
str3: .asciiz "Non sono stati inseriti numeri\n"
str4: .asciiz "Errore nell'inserimento\n"
str5: .asciiz "B[%d]= %d\n"
strdbg1: .asciiz "DBG: funct ret val: %d\n"
strdbg2: .asciiz "DBG: in main ret is: %d\n"
addr_str: .space 8
val1: .space 8
val2: .space 8

descr: .word 0
addr_letto: .space 8
sizeof: .word 40

stack: .space 64

.code
daddi $sp, r0, stack
daddi $sp, $sp, 64

; using $s0 -> i for string (++:40)
; using $s1 -> i for int (++:8)
daddi $s0, r0, 0
daddi $s1, r0, 0

for1:
slti $t0, $s0, 160
beqz $t0, endfor1

daddi $t0, r0, str1
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

jal input_unsigned
sd r1, a($s1)

sd r1, val1(r0)
daddi $t0, r0, str2
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

daddi $t0, $s0, s
sd $t0, addr_letto(r0)
daddi r14, r0, descr
syscall 3

sd r1, n($s1)

ld $t2, n($s1)
ld $t3, a($s1)

slt $t0, $t2, $t3
bnez $t0, else

; FUNCTION:
; $a0 -> char *s (s[i])
; $a1 -> int ni (n[i])
daddi $a0, $s0, s
ld $a1, n($s1)

jal elabora

sd r1, b($s1)
dadd $t6, r0, r1

bnez r1, incri

daddi $t0, r0, str3
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

incri:
daddi $s0, $s0, 40
daddi $s1, $s1, 8
j for1

else:
daddi $t0, r0, str4
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5
j for1

endfor1:
; using $s0 -> i for index only (++:1)
; using $s1 -> i for int (++:8)
daddi $s0, r0, 0
daddi $s1, r0, 0

for2:
slti $t0, $s0, 4
beqz $t0, endfor2

ld $t0, b($s1)
sd $s0, val1(r0)
sd $t0, val2(r0)
daddi $t0, r0, str5
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

daddi $s0, $s0, 1
daddi $s1, $s1, 8
j for2

endfor2:
syscall 0
#include input_unsigned.s

elabora:
daddi $sp, $sp, -16
sd $s0, 0($sp)
sd $s1, 8($sp)

; FUNCTION:
; $a0 -> char *s (s[i])
; $a1 -> int ni (n[i])
;
; $s0 -> t
; $s1 -> c
; $s2 -> j index for char (++:1)

daddi $s0, r0, 0
daddi $s1, r0, 0
daddi $s2, r0, 0

forfunct:
slt $t0, $s2, $a1
beqz $t0, endforfunct

dadd $t0, $a0, $s2
lb $t1, 0($t0) ; now $t1 is s[j] value

slti $t2, $t1, 48
slti $t3, $t1, 58
bnez $t2, incrifunct
beqz $t3, incrifunct

daddi $t1, $t1, -48
dadd $s0, $s0, $t1
daddi $s1, $s1, 1

incrifunct:
daddi $s2, $s2, 1
j forfunct

endforfunct:
daddi $t5, r0, 0
slt $t0, $t5, $s1
beqz $t0, return

ddiv $s0, $s1
mflo $s0

return:
daddi r1, $s0, 0

ld $s0, 0($sp)
ld $s1, 8($sp)
daddi $sp, $sp, 16

jr $ra
