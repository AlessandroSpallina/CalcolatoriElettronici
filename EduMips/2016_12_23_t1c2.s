; Copyright (C) 2017 by Spallina Ind.
.data
str: .space 160
a: .space 32
n: .space 32

str1: .asciiz "Inserire una stringa\n"
str2: .asciiz "A[%d]= %d\n"
addr_str: .space 8
val1: .space 8
val2: .space 8

descr: .word 0
addr_letto: .space 8
sizeof: .word 40

stack: .space 88

.code
daddi $sp, r0, stack
daddi $sp, $sp, 88

; $s0 -> i for str (++:40)
; $s1 -> i for int (++:8)
daddi $s0, r0, 0
daddi $s1, r0, 0

for1:
slti $t0, $s1, 32
beq $t0, r0, endfor1

daddi $t0, r0, str1
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

daddi $t0, $s0, str
sd $t0, addr_letto(r0)
daddi r14, r0, descr
syscall 3

sd r1, n($s1)

daddi $s0, $s0, 40
daddi $s1, $s1, 8
j for1

endfor1:
; $s0 -> i for str (++:40)
; $s1 -> i for int (++:8)
daddi $s0, r0, 0
daddi $s1, r0, 0

for2:
slti $t0, $s1, 16
beq $t0, r0, endfor2

; $s2 -> n[i]
; $s3 -> n[i+2]
ld $s2, n($s1)
daddi $t0, $s1, 16
ld $s3, n($t0)
slt $t0, $s3, $s2
beq $t0, r0, else
; $a0 -> str1 (str[i])
; $a1 -> str2 (str[i+2])
; $a2 -> n[i]
daddi $a0, $s0, str
daddi $t0, $s0, 80
daddi $a1, $t0, str
ld $a2, n($s1)
jal scambia
; $s3 -> ris
; $s4 -> tmp
daddi $s3, r1, 0
daddi $t0, $s1, 16
ld $s4, n($t0)
ld $t1, n($s1)
sd $t1, n($t0)
sd $s4, n($s1)
j continue

else:
daddi $s3, r0, 0

continue:
sd $s3, a($s1)
daddi $t0, $s1, 16
ld $t1, n($t0)
dsub $t1, $t1, $s3
sd $t1, a($t0)

daddi $s0, $s0, 40
daddi $s1, $s1, 8
j for2

endfor2:
daddi $s0, r0, 0 ; i -> index only (++:1)
daddi $s1, r0, 0 ; i -> int (++:8)

for3:
slti $t0, $s0, 4
beq $t0, r0, endfor3
sd $s0, val1(r0)
ld $t1, a($s1)
sd $t1, val2(r0)
daddi $t0, r0, str2
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5
daddi $s0, $s0, 1
daddi $s1, $s1, 8
j for3

endfor3:
syscall 0

scambia:
daddi $sp, $sp, -32
sd $s0, 0($sp)
sd $s1, 8($sp)
sd $s2, 16($sp)
sd $s3, 24($sp)

; $a0 -> str1 (str[i])
; $a1 -> str2 (str[i+2])
; $a2 -> n[i]

; using $s0 -> conta
; using $s1 -> i char (++:1)
; using $s2 -> tmp
daddi $s0, r0, 0
daddi $s1, r0, 0

forfunct:
slt $t0, $s1, $a2
beq $t0, r0, endforfunct
dadd $t0, $s1, $a1
lb $s2, 0($t0)
dadd $t1, $a0, $s1
lb $t2, 0($t1)
sb $t2, 0($t0) ; in $t2 -> str2
sb $s2, 0($t1) ; in $s2 -> tmp = str1

slt $t0, $t2, $s2
beq $t0, r0, continuefunct
daddi $s0, $s0, 1

continuefunct:
daddi $s1, $s1, 1
j forfunct

endforfunct:
daddi r1, $s0, 0
ld $s0, 0($sp)
ld $s1, 8($sp)
ld $s2, 16($sp)
ld $s3, 24($sp)
daddi $sp, $sp, 32
jr $ra
