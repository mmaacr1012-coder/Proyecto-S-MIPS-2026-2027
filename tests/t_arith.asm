# t_arith.asm - instrucciones aritméticas, lógicas y con inmediato
#
# Instrucciones: add, sub, and, or, slt, slti, sll, srl, addi, addiu, addu,
#                andi, ori, lui, syscall (11 y 10).
# Casos de la tabla 3 que cubre:
#   add, sub   : operandos positivos y con al menos un operando negativo
#   and, or    : operandos con unos en los 16 bits altos
#   slt, slti  : resultado 1 y 0; -1 contra 1 (con signo y sin signo difieren)
#   sll, srl   : shamt = 0 y shamt != 0; srl sobre un valor negativo
#   addi       : inmediato negativo
#   addiu,addu : mediante las pseudoinstrucciones li (-2^15..2^15-1) y move
#   andi, ori  : inmediato con el bit 15 en 1 (extensión con ceros)
#   lui        : inmediato con el bit 15 en 1
#   $zero      : se escribe en $zero y se comprueba que sigue valiendo 0
# Salida: 5 líneas de 5 valores en hexadecimal (8 dígitos cada uno).

        .text
main:
        # ---- línea 1: add y sub
        li   $s0, 5
        li   $s1, 7
        add  $a0, $s0, $s1          # 5 + 7 = 0000000c
        jal  phx
        li   $s2, -5
        li   $s3, 3
        add  $a0, $s2, $s3          # -5 + 3 = fffffffe
        jal  phx
        sub  $a0, $s1, $s3          # 7 - 3 = 00000004
        jal  phx
        sub  $a0, $s3, $s1          # 3 - 7 = fffffffc
        jal  phx
        sub  $a0, $s0, $s2          # 5 - (-5) = 0000000a
        jal  phx
        jal  nl

        # ---- línea 2: and, or, slt
        li   $s0, 0xffff00ff
        li   $s1, 0x0ff0f0f0
        and  $a0, $s0, $s1          # 0ff000f0
        jal  phx
        or   $a0, $s0, $s1          # fffff0ff
        jal  phx
        li   $s2, -1
        li   $s3, 1
        slt  $a0, $s2, $s3          # -1 < 1 con signo -> 1 (sin signo daría 0)
        jal  phx
        slt  $a0, $s3, $s2          # 1 < -1 con signo -> 0
        jal  phx
        slti $a0, $s2, 1             # -1 < 1 -> 1
        jal  phx
        jal  nl

        # ---- línea 3: slti, sll, srl
        slti $a0, $s3, -1            # 1 < -1 con signo -> 0 (sin signo daría 1)
        jal  phx
        li   $s4, 0x12345678
        sll  $a0, $s4, 0             # 12345678
        jal  phx
        sll  $a0, $s4, 4             # 23456780
        jal  phx
        srl  $a0, $s4, 0             # 12345678
        jal  phx
        srl  $a0, $s4, 4             # 01234567
        jal  phx
        jal  nl

        # ---- línea 4: srl sobre negativo, addi negativo, li
        li   $s5, 0xf0000000
        srl  $a0, $s5, 4             # 0f000000 (entran ceros)
        jal  phx
        srl  $a0, $s2, 31            # -1 >> 31 = 00000001
        jal  phx
        addi $a0, $s3, -30           # 1 + (-30) = ffffffe3
        jal  phx
        li   $a0, 0x7fff              # 00007fff
        jal  phx
        li   $a0, -32768              # ffff8000
        jal  phx
        jal  nl

        # ---- línea 5: move, andi, ori, lui, $zero
        li   $s6, 0x1234
        move $a0, $s6                # 00001234
        jal  phx
        li   $s7, -1
        andi $a0, $s7, 0x8000        # 00008000 (extensión con ceros)
        jal  phx
        ori  $a0, $zero, 0x8000      # 00008000 (extensión con ceros)
        jal  phx
        lui  $a0, 0x8000              # 80000000
        jal  phx
        addi $zero, $zero, 5         # escribir en $zero no debe tener efecto
        move $a0, $zero              # 00000000
        jal  phx
        jal  nl

        li   $v0, 10
        syscall

# ---------------- subrutinas de salida (solo usan syscall 11) ----------------
# nl : imprime un salto de línea
# phx: imprime $a0 en hexadecimal (8 dígitos) seguido de un espacio.
#      Modifica $a0, $v0 y $t6-$t9. Los valores a conservar van en $s0-$s7 o $t0-$t5.
nl:     li   $a0, 10
        li   $v0, 11
        syscall
        jr   $ra
phx:    move $t6, $a0
        li   $t7, 8
phx_l:  srl  $t8, $t6, 28
        slti $t9, $t8, 10
        bne  $t9, $zero, phx_d
        addi $a0, $t8, 87          # 10..15 -> a..f
        j    phx_o
phx_d:  addi $a0, $t8, 48          # 0..9 -> 0..9
phx_o:  li   $v0, 11
        syscall
        sll  $t6, $t6, 4
        addi $t7, $t7, -1
        bne  $t7, $zero, phx_l
        li   $a0, 32
        li   $v0, 11
        syscall
        jr   $ra
