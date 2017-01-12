; Copyright (C) 2017 by Spallina Ind.

.data
str: .space 24
a: .space 24
n: .space 24

str1: .asciiz "Inserire una stringa con al massimo 7 char\n"
str2: .asciiz "A[%d] = %d, N[%d] = %d\n"
str3: .asciiz "Inserisci un numero < %d\n"
strdbg: .asciiz "QUI\n"
addr_str: .space 8
val1: .space 8
val2: .space 8
val3: .space 8
val4: .space 8

descr: .word 0
addr_letto: .space 8
sizeof: .word 8

stack: .space 64

.code
daddi $sp, r0, stack
daddi $sp, $sp, 64

; using $s0 -> i for str&int (++:8)
daddi $s0, r0, 0

for1:
slti $t0, $s0, 24
beqz $t0, endfor1

  do:
  daddi $t0, r0, str1
  sd $t0, addr_str(r0)
  daddi r14, r0, addr_str
  syscall 5

  daddi $t0, $s0, str
  sd $t0, addr_letto(r0)
  daddi r14, r0, descr
  syscall 3

  sd r1, n($s0)

  daddi $t1, r0, 8
  slt $t0, $t1, r1
  bnez $t0, do

daddi $s0, $s0, 8
j for1

endfor1:
; using $s0 -> i for str&int (++:8)
daddi $s0, r0, 0

for2:
slti $t0, $s0, 24
beqz $t0, endfor2
; FUNCTION
; $a0 -> str[i] (char *str)
; $a1 -> n[i] (int d)
daddi $a0, $s0, str
ld $a1, n($s0)

jal calcola

sd r1, a($s0)

daddi $s0, $s0, 8
j for2

endfor2:
; using $s0 -> i for str&int (++:8)
; using $s1 -> i for index only (++:1)
daddi $s0, r0, 0
daddi $s1, r0, 0

for3:
slti $t0, $s1, 3
beqz $t0, endfor3

sd $s1, val1(r0)
sd $s1, val3(r0)
ld $t0, a($s0)
sd $t0, val2(r0)
ld $t0, n($s0)
sd $t0, val4(r0)
daddi $t0, r0, str2
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

daddi $s0, $s0, 8
daddi $s1, $s1, 1
j for3

endfor3:
syscall 0
#include input_unsigned.s

calcola:
daddi $sp, $sp, -24
sd $s0, 0($sp)
sd $s1, 8($sp)
sd $ra, 16($sp)

; FUNCTION
; $a0 -> str[i] (char *str)
; $a1 -> n[i] (int d)
;
; $s0 -> ris
; $s1 -> sup
daddi $s0, r0, 0

dofunct:
sd $a1, val1(r0)
daddi $t0, r0, str3
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

jal input_unsigned

daddi $s1, r1, 0

slt $t0, $a1, $s1
bnez $t0, dofunct

; $s0 -> ris
; $s1 -> sup
; $s2 -> j for char (++:1)

daddi $s2, r0, 0

forfunct:
slt $t0, $s2, $s1
beqz $t0, endforfunct

dadd $t1, $a0, $s2
lb $t0, 0($t1)
slti $t2, $t0, 58
beqz $t2, else

; $t0 c'è il valore di str[j]
daddi $t0, $t0, -48
dadd $s0, $s0, $t0
j incrforfunct

else:
slti $t2, $t0, 91
beqz $t2, else2

daddi $t0, $t0, -65
dadd $s0, $s0, $t0
j incrforfunct

else2:
slti $t2, $t0, 123
beqz $t2, incrforfunct

daddi $t0, $t0, -97
dadd $s0, $s0, $t0
j incrforfunct

incrforfunct:
daddi $s2, $s2, 1
j forfunct

endforfunct:
daddi r1, $s0, 0

ld $s0, 0($sp)
ld $s1, 8($sp)
ld $ra, 16($sp)
daddi $sp, $sp, 24
jr $ra
