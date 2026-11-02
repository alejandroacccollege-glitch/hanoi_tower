.text

main:

    #Parámetros para Hanoi
    addi s0, zero, 1 # n
    addi a0, s0, 0 # n como parámetro de la función
    addi a1, zero, 1 # origen
    addi a2, zero, 2 # destino
    addi a3, zero, 3 # auxiliar
    addi t0, zero, 1 # 1 que se va a usar para la 
    # evaluación de la condición base
    jal ra, Hanoi
    jalr zero, ra, 0

Hanoi:
    addi s1, zero, 5 # Número de elementos a reservar en el stack
    addi s2, zero, 4 # Espacio que se va a reservar por 
    jal ra, stack_reserve # Reserva espacio en el Stack
    
    sw ra, 20(sp)
    sw a0, 16(sp) # n como parámetro de la función
    sw a1, 12(sp) # origen
    sw a2, 8(sp) # destino
    sw a3, 4(sp) # auxiliar
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

    addi s1, zero, 5 # Número de elementos a reservar en el stack
    addi s2, zero, 4 # Espacio que se va a reservar por
    jal ra, stack_free
    
    jalr zero, ra, 0

stack_reserve:
# Parámetros para stack_reserve
    addi a4, s1, 0 # Parametro1: Número de elementos que se desea reservar en el Stack (elements)    
    addi a5, s2, 0 # Parametro2: Espacio que se va a reservar para cada elemento (memorySize)

    addi t1, zero, 0 # i = 0
    addi s3, zero, 8 # El que se va a usar para determinar su multiplicidad
    mul t2, a4, a5 # elements * memorySize
    
    rem t3, t2, s3 # multiplicity = mulResult % 8

    bne t3, 0, else_reserve # if (multiplicity != 0)
    addi t2, t2, 0 # (multiplicity += 0) Si es multiplo se conserva
    jal zero, end_if_reserve
else_reserve:
    addi t2, t2, 4 # (multiplicity += 4) Si no es multiplo se le suma 4
end_if_reserve:
    div t4, t2, 4 # (iterations = multiplicity/4) Se divide entre 4 para saber el número de veces a iterar
for_reserve:
    bge t1, t4, end_for_reserve # (i >= iterations)
    addi sp, sp, -4 
    addi t1, t1, 1 # i++;
    jal zero, for_reserve
end_for_reserve:
    jalr zero, ra, 0

stack_free:
# Parámetros para stack_free
    addi a4, s1, 0 # Parametro1: Número de elementos que se desea restaurar en el Stack (elements)    
    addi a5, s2, 0 # Parametro2: Espacio que se va a restaurar para cada elemento (memorySize)

    addi t1, zero, 0 # i = 0
    addi s3, zero, 8 # El que se va a usar para determinar su multiplicidad
    mul t2, a4, a5 # elements * memorySize
    
    rem t3, t2, s3 # multiplicity = mulResult % 8

    bne t3, 0, else_free # if (multiplicity != 0)
    addi t2, t2, 0 # (multiplicity += 0) Si es multiplo se conserva
    jal zero, end_if_free
else_free:
    addi t2, t2, 4 # (multiplicity += 4) Si no es multiplo se le suma 4
end_if_free:
    div t4, t2, 4 # (iterations = multiplicity/4) Se divide entre 4 para saber el número de veces a iterar
for_free:
    bge t1, t4, end_for_free # (i >= iterations)
    addi sp, sp, 4 
    addi t1, t1, 1 # i++;
    jal zero, for_free
end_for_free:
    jalr zero, ra, 0