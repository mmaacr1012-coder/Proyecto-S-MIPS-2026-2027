# t_mem.asm - instrucciones de acceso a memoria
#
# Instrucciones: lw, sw, lb, lbu, sb, addi, la (pseudo), li (pseudo), syscall.
# Casos de la tabla 3 que cubre:
#   lw, sw : con desplazamiento positivo y con desplazamiento negativo
#   lb, lbu: sobre bytes con el bit 7 en 1, en tres posiciones distintas
#            de la palabra (d[1:0] = 0, 1 y 3)
#   sb     : en las cuatro posiciones de una misma palabra (d[1:0] = 0, 1, 2, 3),
#            comprobando después con lw que los otros bytes no cambiaron
# Salida: 4 líneas de valores en hexadecimal (8 dígitos cada uno).

        .data
buf:    .word 0, 0, 0, 0

        .text
main:
        la   $s0, buf                 # base de los datos (0x2000)

        # ---- línea 1: lw y sw con desplazamiento positivo y negativo
        li   $t0, 0x12345678
        sw   $t0, 4($s0)             # desplazamiento positivo
        lw   $a0, 4($s0)             # 12345678
        jal  phx
        addi $s1, $s0, 8             # s1 = buf + 8
        li   $t1, 0x9abcdef0
        sw   $t1, -8($s1)            # desplazamiento negativo: buf + 0
        lw   $a0, -8($s1)            # 9abcdef0
        jal  phx
        lw   $a0, -4($s1)            # buf + 4: 12345678
        jal  phx
        lw   $a0, 0($s0)             # buf + 0: 9abcdef0
        jal  phx
        lw   $a0, 8($s0)             # buf + 8 sin escribir: 00000000
        jal  phx
        jal  nl

        # ---- líneas 2 y 3: lb y lbu (bytes e1 f0 70 80, little-endian)
        li   $t0, 0x8070f0e1
        sw   $t0, 8($s0)
        lb   $a0, 8($s0)             # ffffffe1
        jal  phx
        lbu  $a0, 8($s0)             # 000000e1
        jal  phx
        lb   $a0, 9($s0)             # fffffff0
        jal  phx
        lbu  $a0, 9($s0)             # 000000f0
        jal  phx
        lb   $a0, 10($s0)            # 00000070
        jal  phx
        jal  nl
        lb   $a0, 11($s0)            # ffffff80
        jal  phx
        lbu  $a0, 11($s0)            # 00000080
        jal  phx
        jal  nl

        # ---- línea 4: sb en las cuatro posiciones de la palabra buf + 12
        li   $t0, 0x11223344
        sw   $t0, 12($s0)
        li   $t1, -86                 # ffffffaa: sb guarda solo el byte aa
        sb   $t1, 12($s0)
        lw   $a0, 12($s0)            # 112233aa
        jal  phx
        li   $t1, -69                 # ffffffbb
        sb   $t1, 13($s0)
        lw   $a0, 12($s0)            # 1122bbaa
        jal  phx
        li   $t1, -52                 # ffffffcc
        sb   $t1, 14($s0)
        lw   $a0, 12($s0)            # 11ccbbaa
        jal  phx
        li   $t1, -35                 # ffffffdd
        sb   $t1, 15($s0)
        lw   $a0, 12($s0)            # ddccbbaa
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
