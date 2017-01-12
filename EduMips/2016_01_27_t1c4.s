; Copyright (C) 2017 by Spallina Ind.

.data
str: .space 24
p: .space 8
a: .space 24
n: .space 24

str1: .asciiz "Inserire una stringa con al massimo 7 char\n"
str2: .asciiz "Inserisci un numero <= %d\n"
str3: .asciiz "A[%d] = %d      N[%d] = %d\n"
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

; using $s0 -> i for int&str (++:8)
daddi $s0, r0, 0

for1:
slti $t0, $s0, 24
beqz $t0, endfor1

daddi $t0, r0, str1
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

daddi $t0, $s0, str
sd $t0, addr_letto(r0)
daddi r14, r0, descr
syscall 3

sd r1, n($s0)

daddi $s0, $s0, 8
j for1

endfor1:
; using $s0 -> i for int&str (++:8)
; using $s1 -> sup
daddi $s0, r0, 0

for2:
slti $t0, $s0, 24
beqz $t0, endfor2

ld $t1, n($s0)
sd $t1, val1(r0)
daddi $t0, r0, str2
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

daddi $t0, r0, p
sd $t0, addr_letto(r0)
daddi r14, r0, descr
syscall 3

; using $s0 -> i for int&str (++:8)
; using $s1 -> sup
lb $t0, p(r0)
daddi $s1, $t0, -48

; FUNCTION
; $a0 -> str[i] (char *str)
; $a1 -> sup (int d)

daddi $a0, $s0, str
daddi $a1, $s1, 0

jal somma

ddiv r1, $s1
mflo $t0
sd $t0, a($s0)

daddi $s0, $s0, 8
j for2

endfor2:
; using $s0 -> i for int&str (++:8)
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
daddi $t0, r0, str3
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

daddi $s0, $s0, 8
daddi $s1, $s1, 1
j for3

endfor3:
syscall 0

somma:
daddi $sp, $sp, -16
sd $s0, 0($sp)
sd $s1, 8($sp)

; FUNCTION
; $a0 -> str[i] (char *str)
; $a1 -> sup (int d)
;
; using $s0 -> ris
; using $s1 -> j index for char (++:1)
daddi $s0, r0, 0
daddi $s1, r0, 0

forfunct:
slt $t0, $s1, $a1
beqz $t0, endforfunct

dadd $t0, $s1, $a0 ; in $t0 now str[j] address
lb $t1, 0($t0) ; in $t1 now str[j] ascii value
slti $t2, $t1, 58
beqz $t2, elsefunct

daddi $t1, $t1, -48
dadd $s0, $s0, $t1
j incforfunct

elsefunct:
slti $t0, $t1, 91
beqz $t0, elsefunct2

daddi $t1, $t1, -65
dadd $s0, $s0, $t1
j incforfunct

elsefunct2:
slti $t0, $t1, 123
beqz $t0, incforfunct

daddi $t1, $t1, -97
dadd $s0, $s0, $t1

incforfunct:
daddi $s1, $s1, 1
j forfunct

endforfunct:
daddi r1, $s0, 0

ld $s0, 0($sp)
ld $s1, 8($sp)
daddi $sp, $sp, 16
jr $ra
