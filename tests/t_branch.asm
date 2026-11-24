# t_branch.asm - saltos y llamadas a procedimientos
#
# Instrucciones: beq, bne, j, jal, jr, addi, add, la (pseudo), syscall.
# Casos de la tabla 3 que cubre:
#   beq, bne : cada uno tomado y no tomado; un bne con salto hacia atrás (bucle)
#   j        : salto hacia adelante que se salta una instrucción
#   jal, jr  : un procedimiento (outer) que llama a otro (inner), guarda $ra en
#              la pila y retorna correctamente; jr con una dirección cargada con la
#              pseudoinstrucción la
#   $gp, $sp : se imprimen los valores iniciales (0x1800 y 0x3ffc) tras las llamadas
# Salida: 2 líneas de 5 valores en hexadecimal (8 dígitos cada uno).

        .text
main:
        li   $s0, 7
        li   $s1, 7
        li   $s2, 9

        # ---- línea 1: beq / bne, tomado y no tomado
        li   $a0, 0
        beq  $s0, $s1, b_t1            # tomado
        j    b_e1
b_t1:     li   $a0, 1
b_e1:     jal  phx                      # 00000001
        li   $a0, 1
        beq  $s0, $s2, b_e2            # no tomado
        li   $a0, 0
b_e2:     jal  phx                      # 00000000
        li   $a0, 0
        bne  $s0, $s2, b_t3            # tomado
        j    b_e3
b_t3:     li   $a0, 1
b_e3:     jal  phx                      # 00000001
        li   $a0, 1
        bne  $s0, $s1, b_e4            # no tomado
        li   $a0, 0
b_e4:     jal  phx                      # 00000000
        li   $s3, 0
        li   $s4, 5
loop:   add  $s3, $s3, $s4          # suma 5+4+3+2+1
        addi $s4, $s4, -1
        bne  $s4, $zero, loop        # salto hacia atrás
        move $a0, $s3                # 0000000f
        jal  phx
        jal  nl

        # ---- línea 2: j, jal/jr (procedimiento no hoja), jr, $sp y $gp
        li   $a0, 1
        j    skip
        li   $a0, 2                  # no se ejecuta
skip:   jal  phx                      # 00000001
        li   $a0, 3
        jal  outer
        move $a0, $v0                # 3*2 + 1 = 00000007
        jal  phx
        move $a0, $sp                # 00003ffc
        jal  phx
        move $a0, $gp                # 00001800
        jal  phx
        la   $t0, tgt
        jr   $t0                      # salta a tgt
        li   $a0, 99                 # no se ejecuta
tgt:    li   $a0, 5                  # 00000005
        jal  phx
        jal  nl

        li   $v0, 10
        syscall

# procedimiento no hoja: llama a inner y guarda $ra en la pila
outer:  addi $sp, $sp, -4
        sw   $ra, 0($sp)
        jal  inner
        addi $v0, $v0, 1
        lw   $ra, 0($sp)
        addi $sp, $sp, 4
        jr   $ra
inner:  add  $v0, $a0, $a0
        jr   $ra

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
