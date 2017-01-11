; Copyright (C) 2017 by Spallina Ind.

.data
s: .space 120
a: .space 24
b: .space 24
n: .space 24

str1: .asciiz "Inserisce una stringa con almeno 6 caratteri\n"
str2: .asciiz "Inserisci un numero positivo\n"
str3: .asciiz "B[%d]= %d\n"
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

; using $s0 -> i for int (++:8)
; usign $s1 -> i for string (++:40)
daddi $s0, r0, 0
daddi $s1, r0, 0

for:
slti $t0, $s0, 24
beq $t0, r0, endfor1

  do:
  daddi $t0, r0, str1
  sd $t0, addr_str(r0)
  daddi r14, r0, addr_str
  syscall 5

  daddi $t0, $s1, s
  sd $t0, addr_letto(r0)
  daddi r14, r0, descr
  syscall 3

  sd r1, n($s0)

  slti $t0, r1, 6
  bne $t0, r0, do

daddi $s0, $s0, 8
daddi $s1, $s1, 40
j for

endfor1:
; using $s0 -> i for int (++:8)
daddi $s0, r0, 0

for2:
slti $t0, $s0, 24
beq $t0, r0, endfor2

daddi $t0, r0, str2
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

jal input_unsigned
sd r1, a($s0)
;daddi $t0, $s0, a
;sd $t0, addr_letto(r0)
;daddi r14, r0, descr
;syscall 3

; se dopo la syscall 3 non viene svuotato addr_letto
; allora sto qui convertendo da ascii a int value in a[i]
;daddi $t1, $s0, a
;lwu $t0, 0($t1)
;daddi $t0, $t0, -48
;sw $t0, 0($t1)

; FUNCTION:
; $a0 -> a[i]
; $a1 -> n[i]
ld $a0, a($s0)
ld $a1, n($s0)
jal elabora

sd r1, b($s0)

daddi $s0, $s0, 8
j for2

endfor2:
; using $s0 -> i for int (++:8)
; using $s1 -> i for index only (++:1)
daddi $s0, r0, 0
daddi $s1, r0, 0

for3:
slti $t0, $s0, 24
beq $t0, r0, endfor3

sd $s1, val1(r0)
daddi $t0, $s0, b
ld $t1, 0($t0)
sd $t1, val2(r0)
daddi $t0, r0, str3
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5

daddi $s0, $s0, 8
daddi $s1, $s1, 1
j for3

endfor3:
syscall 0
#include input_unsigned.s

elabora:
daddi $sp, $sp, -16
sd $s0, 0($sp)
sd $s1, 8($sp)

; FUNCTION:
; $a0 -> a[i]
; $a1 -> n[i]

slti $t0, $a0, 5
slti $t1, $a1, 10
and $t2, $t0, $t1
beq $t2, r0, else

dadd $t0, $a0, $a1
daddi $t1, r0, 2
ddiv $t0, $t1
mflo $t0 ; qui ho il risultato della div (parte intera)
daddi r1, $t0, 0
j return

else:
slt $t0, $a1, $a0
beq $t0, r0, else2
daddi r1, $a0, 0
j return

else2:
daddi r1, $a1, 0

return:
ld $s0, 0($sp)
ld $s1, 8($sp)
daddi $sp, $sp, 16
jr $ra
