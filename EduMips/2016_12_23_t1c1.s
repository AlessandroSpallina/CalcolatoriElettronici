; Copyright (C) 2017 by Spallina Ind.

.data
stringhe: .space 160
numeri: .space 40
a: .space 32
n: .space 32

str1: .asciiz "Inserire una stringa con almeno 5 caratteri\n"
str2: .asciiz "A[%d]= %d N[%d]= %d\n"
addr_str: .space 8
val1: .space 8
val2: .space 8
val3: .space 8
val4: .space 8

descr: .word 0
addr_letto: .space 8
sizeof: .word 40

stack: .space 80

.code
daddi $sp, r0, stack
daddi $sp, $sp, 80

; $s0 -> i for char (++:40)
; $s1 -> i for int (++:8)
daddi $s0, r0, 0
daddi $s1, r0, 0

for1:
slti $t0, $s1, 32
beq $t0, r0, endfor1
  do:
  daddi $t0, r0, str1
  sd $t0, addr_str(r0)
  daddi r14, r0, addr_str
  syscall 5
  daddi $t0, $s0, stringhe
  sd $t0, addr_letto(r0)
  daddi r14, r0, descr
  syscall 3
  sd r1, n($s1)
  slti $t0, r1, 5
  bne $t0, r0, do
daddi $s0, $s0, 40
daddi $s1, $s1, 8
j for1

endfor1:
daddi $s0, r0, 0 ; i for char (++:40)
daddi $s1, r0, 0 ; i for int (++:8)

for2:
slti $t0, $s1, 32
beq $t0, r0, endfor2
; $a0 -> numeri
; $a1 -> stringhe[i]
; $a2 -> n[i]
daddi $a0, r0, numeri
daddi $a1, $s0, stringhe
ld $a2, n($s1)

jal copianumeri
; using $s2 -> d
; using $s3 -> somma
; using $s4 -> j (++:1)
daddi $s2, r1, 0
daddi $s3, r0, 0
daddi $s4, r0, 0
  for3_innested:
  slt $t0, $s4, $s2
  beq $t0, r0, endfor3_innested
  lb $t0, numeri($s4)
  dadd $s3, $s3, $t0
  daddi $s4, $s4, 1
  j for3_innested
endfor3_innested:
sd $s3, a($s1)
daddi $s0, $s0, 40
daddi $s1, $s1, 8
j for2

endfor2:
daddi $s0, r0, 0 ; i for index only (++:1)
daddi $s1, r0, 0 ; i for int (++:8)

for4:
slti $t0, $s0, 4
beq $t0, r0, endfor4
sd $s0, val1(r0)
sd $s0, val3(r0)
ld $t0, a($s1)
sd $t0, val2(r0)
ld $t0, n($s1)
sd $t0, val4(r0)
daddi $t0, r0, str2
sd $t0, addr_str(r0)
daddi r14, r0, addr_str
syscall 5
daddi $s0, $s0, 1
daddi $s1, $s1, 8
j for4

endfor4:
syscall 0

copianumeri:
daddi $sp, $sp, -16
sd $s0, 0($sp)
sd $s1, 8($sp)
; $a0 -> numeri (dest)
; $a1 -> stringhe[i] (sorg)
; $a2 -> n[i] (d)
;
; using $s0 -> k
; using $s1 -> i (++:1)
daddi $s0, r0, 0
daddi $s1, r0, 0
  forfunct:
  slt $t0, $s1, $a2
  beq $t0, r0, return
  dadd $t1, $a1, $s1
  ; using $s2 to store sorg[i] value
  lb $s2, 0($t1)
  slti $t0, $s2, 58
  beq $t0, r0, else
  daddi $s2, $s2, -48
  dadd $t2, $a0, $s0
  sb $s2, 0($t2)
  daddi $s0, $s0, 1
  daddi $s1, $s1, 1
  j forfunct

  else:
  dadd $t2, $a0, $s1
  daddi $t0, r0, 0
  sb $t0, 0($t2)
  daddi $s1, $s1, 1
  j forfunct

  return:
  daddi r1, $s0, 0
  ld $s0, 0($sp)
  ld $s1, 8($sp)
  daddi $sp, $sp, 16
  jr $ra
