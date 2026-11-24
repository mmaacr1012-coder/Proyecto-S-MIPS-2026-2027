# t_syscall.asm - servicios de syscall 11 (imprimir carácter) y 10 (terminar)
#
# Instrucciones: syscall (11 y 10), li, move, addi, bne.
# Casos de la tabla 3 que cubre:
#   syscall: servicio 11 (varios caracteres, con $v0 cargado por li y por addi)
#            y servicio 10; después de syscall 10 hay instrucciones que imprimirían
#            una X: la CPU debe detenerse y no ejecutarlas
# Salida: 2 líneas de texto.

        .text
main:
        li   $s0, 65                  # 'A'
        li   $s1, 70                  # una pasada más allá de 'E'
loop:   move $a0, $s0
        li   $v0, 11
        syscall                       # imprime A B C D E
        addi $s0, $s0, 1
        bne  $s0, $s1, loop
        li   $a0, 10                  # salto de línea
        li   $v0, 11
        syscall

        addi $v0, $zero, 11          # $v0 cargado con addi
        li   $a0, 79                  # 'O'
        syscall
        li   $a0, 75                  # 'K'
        syscall                       # $v0 sigue valiendo 11
        li   $a0, 10
        syscall

        li   $v0, 10
        syscall                       # termina: nada de lo siguiente debe ejecutarse
        li   $a0, 88                  # 'X'
        li   $v0, 11
        syscall
        li   $v0, 10
        syscall
