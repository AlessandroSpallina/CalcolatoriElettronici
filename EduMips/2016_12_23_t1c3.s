; Copyright (C) 2017 by Spallina Ind.

.data
str: .space 160
a: .space 24
n: .space 32

str1: .asciiz "Inserire una stringa\n"
str2: .asciiz "Stringa di indice %d < della stringa di indice %d\n"
str3: .asciiz "Stringa di indice %d < stringa di indice %d\n"
str4: .asciiz "Stringa di indice %d = stringa di indice %d\n"
str5: .asciiz "A[%d]= %d\n"
addr_str: .space 8
val1: .space 8
val2: .space 8

descr: .word 0
addr_letto: .space 8
sizeof: .word 40

stack: .space 96

.code
daddi $sp, r0, stack
daddi $sp, $sp, 96

; USING:
; $s0 -> i for string (++:40)
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
; USING:
; $s0 -> i for string (++:40)
; $s1 -> i for int (++:8)
; $s2 -> i for index only (++:1)
daddi $s0, r0, 0
daddi $s1, r0, 0
daddi $s2, r0, 0

for2:
slti $t0, $s1, 24
beq $t0, r0, endfor2
; FUNCT ARGS:
; $a0 -> char *str1 (str[i])
; $a1 -> int d1 (n[i])
; $a2 -> char *str2 (str[i+1])
; $a3 -> int d2 (n[i+1])
daddi $a0, $s0, str
ld $a1, n($s1)
daddi $t0, $s0, 40
daddi $a2, $t0, str
daddi $t0, $s1, 8
ld $a3, n($t0)

jal confronta

sd r1, a($s1)

slti $t0, r1, 0
beq $t0, r0, else1

sd $s2, val1(r0)
daddi $t0, $s2, 1
sd $t0, val2(r0)
daddi $t0, r0, str2
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

daddi $s0, $s0, 40
daddi $s1, $s1, 8
daddi $s2, $s2, 1
j for2

else1:
beq r1, r0, else2

daddi $t0, $s2, 1
sd $t0, val1(r0)
sd $s2, val2(r0)
daddi $t0, r0, str3
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

daddi $s0, $s0, 40
daddi $s1, $s1, 8
daddi $s2, $s2, 1
j for2

else2:
sd $s2, val1(r0)
daddi $t0, $s2, 1
sd $t0, val2(r0)
daddi $t0, r0, str4
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

daddi $s0, $s0, 40
daddi $s1, $s1, 8
daddi $s2, $s2, 1
j for2

endfor2:
; USING:
; $s0 -> i for index only (++:1)
; $s1 -> i for int (++:8)
daddi $s0, r0, 0
daddi $s1, r0, 0

for3:
slti $t0, $s0, 3
beq $t0, r0, endfor3

sd $s0, val1(r0)
ld $t0, a($s1)
sd $t0, val2(r0)
daddi $t0, r0, str5
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

daddi $s0, $s0, 1
daddi $s1, $s1, 8
j for3

endfor3:
syscall 0

confronta:
; FUNCT ARGS:
; $a0 -> char *str1 (str[i])
; $a1 -> int d1 (n[i])
; $a2 -> char *str2 (str[i+1])
; $a3 -> int d2 (n[i+1])
daddi $sp, $sp, -24
sd $s0, 0($sp)
sd $s1, 8($sp)
sd $s2, 16($sp)
; USING:
; $s0 -> max
; $s1 -> i for char (++:1)
slt $t0, $a1, $a3
bne $t0, r0, maxd2
daddi $s0, $a1, 0
j initforfunct

maxd2:
daddi $s0, $a3, 0

initforfunct:
daddi $s1, r0, 0

forfunct:
slt $t0, $s1, $s0
beq $t0, r0, endforfunct

; $t0 -> str1[i]
; $t1 -> str2[i]
dadd $t2, $s1, $a0
lb $t0, 0($t2)
dadd $t2, $s1, $a2
lb $t1, 0($t2)

slt $t2, $t0, $t1
beq $t2, r0, elsefunct
daddi $t2, $s1, 1
daddi $t3, r0, -1
dmult $t3, $t2
mflo r1
j endfunct

elsefunct:
beq $t0, $t1, else2funct
daddi r1, $s1, 1
j endfunct

else2funct:
daddi $s1, $s1, 1
j forfunct

endforfunct:
daddi r1, r0, 0
j endfunct

endfunct:
ld $s0, 0($sp)
ld $s1, 8($sp)
ld $s2, 16($sp)
daddi $sp, $sp, 24
jr $ra
