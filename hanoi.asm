###########################################################################
# Torres de Hanoi - RISC-V
# Integrantes:
#   - Angel Fernando Gaxiola Valades
#   - Angel Alejandro Castillo Chavez
#
# Representacion en el Data Segment (base 0x10010000):
#   Cada columna del data segment es un pilar:
#     Columna (+0) = Torre A (origen)
#     Columna (+4) = Torre B (auxiliar)
#     Columna (+8) = Torre C (destino)
#   Cada renglon mide 32 bytes (0x20). El renglon 0 es la parte de arriba,
#   asi que los discos chicos quedan arriba y los grandes abajo.
#   El disco 1 es el mas chico y el disco N el mas grande.
###########################################################################

.text

main:
    addi s0, zero, 3        # s0 = N = numero de discos (cambiar aqui)

    # Apuntadores a las 3 torres (columnas del data segment)
    lui  t0, 0x10010        # t0 = 0x10010000 (inicio del data segment)
    addi a1, t0, 0          # a1 = torre origen   (columna +0)
    addi a3, t0, 4          # a3 = torre auxiliar (columna +4)
    addi a2, t0, 8          # a2 = torre destino  (columna +8)

    # Inicializar la torre origen con los discos 1..N
    # El disco i se guarda en el renglon i-1 de la columna origen
    addi t1, a1, 0          # t1 = puntero al renglon 0 de la torre origen
    addi t2, zero, 1        # t2 = disco = 1
init_loop:
    blt  s0, t2, end_init   # Si N < disco, ya se colocaron todos
    sw   t2, 0(t1)          # Coloca el disco en el renglon actual
    addi t1, t1, 32         # Siguiente renglon (+0x20)
    addi t2, t2, 1          # disco++
    jal  zero, init_loop
end_init:

    addi a0, s0, 0          # a0 = N como parametro
    jal  ra, Hanoi          # Hanoi(N, origen, destino, auxiliar)

    # Terminar el programa
while:	jal zero, while

###########################################################################
# Hanoi(a0 = n, a1 = &origen, a2 = &destino, a3 = &auxiliar)
# a1, a2 y a3 son apuntadores a las columnas de las torres
###########################################################################
Hanoi:
    addi s1, zero, 5        # Numero de elementos a guardar en el stack
    addi s2, zero, 4        # Bytes por elemento (word = 4 bytes)
    jal  t5, stack_reserve  # Reserva espacio (enlace en t5 para no perder ra)

    sw ra, 20(sp)           # Direccion de retorno
    sw a0, 16(sp)           # n
    sw a1, 12(sp)           # apuntador a torre origen
    sw a2, 8(sp)            # apuntador a torre destino
    sw a3, 4(sp)            # apuntador a torre auxiliar

    addi t0, zero, 1        # Constante 1 para el caso base
    bne  a0, t0, caso_recursivo

    # Caso base (n == 1): mover el disco de origen a destino
    jal  t5, mover_disco    # Usa a1 = origen, a2 = destino
    jal  zero, end_hanoi

caso_recursivo:
    # 1) Hanoi(n-1, origen, auxiliar, destino)
    lw   a0, 16(sp)
    addi a0, a0, -1         # n-1
    lw   a1, 12(sp)         # origen se conserva
    lw   a2, 4(sp)          # nuevo destino = auxiliar
    lw   a3, 8(sp)          # nuevo auxiliar = destino
    jal  ra, Hanoi

    # 2) Mover el disco n de origen a destino
    #    Se recargan del stack porque la llamada anterior cambio a1 y a2
    lw   a1, 12(sp)         # origen
    lw   a2, 8(sp)          # destino
    jal  t5, mover_disco

    # 3) Hanoi(n-1, auxiliar, destino, origen)
    lw   a0, 16(sp)
    addi a0, a0, -1         # n-1
    lw   a1, 4(sp)          # nuevo origen = auxiliar
    lw   a2, 8(sp)          # destino se conserva
    lw   a3, 12(sp)         # nuevo auxiliar = origen
    jal  ra, Hanoi

end_hanoi:
    lw ra, 20(sp)           # Recupera direccion de retorno
    lw a0, 16(sp)           # n
    lw a1, 12(sp)           # origen
    lw a2, 8(sp)            # destino
    lw a3, 4(sp)            # auxiliar

    addi s1, zero, 5        # Numero de elementos a liberar
    addi s2, zero, 4        # Bytes por elemento
    jal  t5, stack_free     # Libera el stack (enlace en t5, ra intacto)

    jalr zero, ra, 0        # Regresa a quien llamo

###########################################################################
# mover_disco: quita el disco de arriba de la torre a1 y lo pone
#              encima de la torre a2
# Entrada: a1 = &origen, a2 = &destino, s0 = N
# Regresa con: jalr zero, t5, 0
###########################################################################
mover_disco:
    # --- Buscar el disco de arriba en la torre origen ---
    # Se recorre la columna desde el renglon 0 hasta encontrar un valor != 0
    addi t1, a1, 0          # t1 = puntero al renglon 0 de origen
buscar_origen:
    lw   t3, 0(t1)          # t3 = valor del renglon actual
    bne  t3, zero, quitar_disco     # Si hay disco, ese es el de arriba
    addi t1, t1, 32         # Siguiente renglon
    jal  zero, buscar_origen
quitar_disco:
    sw   zero, 0(t1)        # Se quita el disco de la torre origen (t3 = disco)

    # --- Buscar donde colocarlo en la torre destino ---
    # Se recorre la columna hasta encontrar un disco o llegar al fondo (N renglones)
    addi t4, a2, 0          # t4 = puntero al renglon 0 de destino
    addi t2, zero, 0        # t2 = i = 0
buscar_destino:
    beq  t2, s0, colocar_disco      # Llego al fondo: la torre estaba vacia
    lw   t6, 0(t4)          # t6 = valor del renglon actual
    bne  t6, zero, colocar_disco    # Encontro el disco de arriba
    addi t4, t4, 32         # Siguiente renglon
    addi t2, t2, 1          # i++
    jal  zero, buscar_destino
colocar_disco:
    addi t4, t4, -32        # Renglon justo encima (o el fondo si estaba vacia)
    sw   t3, 0(t4)          # Coloca el disco en la torre destino

bp_mover:                   # Movimiento
    jalr zero, t5, 0

###########################################################################
# stack_reserve: baja sp (s1 * s2) bytes, redondeado a multiplo de 8
# Entrada: s1 = elementos, s2 = bytes por elemento
# Regresa con: jalr zero, t5, 0
###########################################################################
stack_reserve:
    addi a4, s1, 0          # elements
    addi a5, s2, 0          # memorySize

    # t2 = elements * memorySize (por sumas sucesivas)
    addi t2, zero, 0        # resultado = 0
    addi t6, zero, 0        # contador = 0
mul_reserve:
    bge  t6, a4, end_mul_reserve
    add  t2, t2, a5         # resultado += memorySize
    addi t6, t6, 1          # contador++
    jal  zero, mul_reserve
end_mul_reserve:

    andi t3, t2, 7          # multiplicity = resultado % 8
    beq  t3, zero, end_if_reserve   # Si ya es multiplo de 8, no se ajusta
    addi t2, t2, 4          # Si no, se suma 4 para alinear a 8
end_if_reserve:
    srli t4, t2, 2          # iterations = bytes / 4 

    addi t1, zero, 0        # i = 0
for_reserve:
    bge  t1, t4, end_for_reserve    # while (i < iterations)
    addi sp, sp, -4         # Reserva una palabra
    addi t1, t1, 1          # i++
    jal  zero, for_reserve
end_for_reserve:
    jalr zero, t5, 0

###########################################################################
# stack_free: sube sp (s1 * s2) bytes, redondeado a multiplo de 8
# Entrada: s1 = elementos, s2 = bytes por elemento
# Regresa con: jalr zero, t5, 0
###########################################################################
stack_free:
    addi a4, s1, 0          # elements
    addi a5, s2, 0          # memorySize

    addi t2, zero, 0        # resultado = 0
    addi t6, zero, 0        # contador = 0
mul_free:
    bge  t6, a4, end_mul_free
    add  t2, t2, a5
    addi t6, t6, 1
    jal  zero, mul_free
end_mul_free:

    andi t3, t2, 7          # resultado % 8
    beq  t3, zero, end_if_free
    addi t2, t2, 4
end_if_free:
    srli t4, t2, 2          # iterations = bytes / 4

    addi t1, zero, 0        # i = 0
for_free:
    bge  t1, t4, end_for_free
    addi sp, sp, 4          # Libera una palabra
    addi t1, t1, 1          # i++
    jal  zero, for_free
end_for_free:
    jalr zero, t5, 0