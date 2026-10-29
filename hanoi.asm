.text

main:
    addi a0, zero, 0 # n
    addi a1, zero, 0 # origen
    addi a2, zero, 0 # destino
    addi a3, zero, 0 # auxiliar

    jal ra, Hanoi
    jalr zero, ra, 0

Hanoi:
    addi sp, sp, -24
    sw ra, 20(sp)
    sw a0, 16(sp)
    sw a1, 12(sp)
    sw a2, 8(sp)
    sw a3, 4(sp)
    # Se reserva en el Stack tanto la 
    # dirección tanto de la función como sus parámetros

    beq a0, t0, end_hanoi # ¿n == 1?

    lw a0, 16(sp)
    addi a0, a0, -1 # n-1
    
    lw a1, 12(sp) # Se conserva tal cual el origen

    lw a2, 4(sp) # Se cambia el destino por el auxiliar

    lw a3, 8(sp) # Se cambia el auxiliar por el destino

    jal ra, Hanoi # Primera llamada recursiva

    lw a0, 16(sp) 
    addi a0, a0, -1 # n-1
    # Se carga nuevamente para la siguiente parte recursiva

    lw a1, 4(sp) # Se cambia el origen por el auxiliar

    lw a2, 8(sp) # Se cambia el auxiliar por el destino

    lw a3, 12(sp) # Se cambia el destino por el origen

    jal ra, Hanoi # Seguanda llamada recursiva

    jal zero, end_hanoi

end_hanoi:
    lw ra, 20(sp) # Dirección de memoria de la función
    lw a0, 16(sp) # n
    lw a1, 12(sp) # origen
    lw a2, 8(sp) # destino 
    lw a3, 4(sp) # auxiliar

    addi sp, sp, 24 # Restaura el espacio reservado en el Stack
    jalr zero, ra, 0
