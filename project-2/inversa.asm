.data
    msg: .asciiz "Digite o valor de N (tamanho da matriz NxN): \n"
    msg_num: .asciiz "Digite um numero para a matriz: \n"
    N_invalido_msg: .asciiz "Erro: N deve ser maior que 0 \n"
    newline: .asciiz "\n"
    matrix_prompt: .asciiz "Matriz preenchida: \n"
    
.text
    .globl main

main:
    # Solicita o valor de N
    li $v0, 4                 # Chamada para print string
    la $a0, msg               # Carrega o endereço da string msg
    syscall

    # Lê o valor de N
    li $v0, 5                 # Chamada para ler inteiro
    syscall
    move $t0, $v0             # Armazena o valor de N em $t0

    # Verifica se 0 >= N 
    slt $t1, $zero, $t0
    beq $t1, $zero, N_invalido

    mul $a0, $t0, $t0         # $a0 = N * N
    sll $a0, $a0, 2           # $a0 *= 4

    # Alocação da matriz
    li $v0, 9                 # syscall para alocação dinâmica da matriz
    syscall
    move $s0, $v0             # $s0 = endereço inicial alocado

    # Alocação da matriz identidade
    #li $v0, 9                 # syscall para alocação da matriz identidade
    #syscall
    #move $s1, $v0             # $s1 = endereço da matriz identidade alocada

    move $a0, $t0
    move $a1, $s0
    #jal read_matrix            # Executa a funcão de printa matriz
    jal create_identity
    jal print_matrix

    end_prog:
    li   $v0,10                # Encerra o programa
    syscall

N_invalido:
    li $v0, 4                 # Chamada para print string
    la $a0, N_invalido_msg    # Carrega o endereço da string msg
    syscall
    
    j end_prog                # Finaliza o programa caso N <= 0

read_matrix:
    addi $sp, $sp, -28        # Separa na pilha a quantidade de elementos que vai inserir
    sw $ra, 24($sp)           # Endereço de retorno da função
    sw $a1, 20($sp)           # Endereço inicial da matriz
    sw $a0, 16($sp)           # Valor de N original
    sw $s0, 12($sp)           # Variável temporária para armazenar N

    # Registradores temporários utilizados na função
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)

    move $s0, $a0             # $s0 = N

    or $t0, $zero, $zero      # Zera o contador (int i=0)
    or $t1, $zero, $zero      # Zera o contador (int j=0)

    or $t4, $zero, $zero      # Valor teste para input

    for_i_read:
        slt $t2, $t0, $s0      # $t2 = $t0 < $s0 => $t2 = i < N
        beq $t2, $zero, end_for_i_read_matrix # Se i >= N sai do loop

        or $t1, $zero, $zero  # Zera o contador de j para a nova iteração

        # Acesso a matriz via (end. inicial + ((i * N) + j) * 4)
        for_j_read:
            slt $t2, $t1, $s0     # $t2 = $t1 < $s0 => $t2 = j < N
            beq $t2, $zero, end_for_j_read_matrix

            mul $t2, $t0, $s0 # $t2 = i * N
            add $t2, $t2, $t1 # $t2 += $t1 => $t2 (aka i*N) += j
            sll $t2, $t2, 2   # ((i * N) + j) * 4

            add $t2, $t2, $a1 # $t2 += end. inicial da matriz

            # Aqui ja tenho o endereço de memória que vou inserir o elemento
            sw $t4, 0($t2)   # Insiro $t4 (valor teste) na memória

            addi $t4, $t4, 1       # t4++ (valor teste)
            addi $t1, $t1, 1       # j++
            
            j for_j_read

        end_for_j_read_matrix:
        
        # Incrementar i
        addi $t0, $t0, 1         # i++

        j for_i_read                  # Volta para o for de i

    end_for_i_read_matrix:
    lw $ra, 24($sp)           # Endereço de retorno da função
    lw $a1, 20($sp)           # Endereço inicial da matriz
    lw $a0, 16($sp)           # Valor de N original
    lw $s0, 12($sp)           # Variável temporária para armazenar N

    # Registradores temporários utilizados na função
    lw $t0, 8($sp)
    lw $t1, 4($sp)
    lw $t2, 0($sp)
    addi $sp, $sp, 24         # Desaloca o espaço na pilha
    jr $ra                   # Retorna para o chamador
    
print_matrix:
    addi $sp, $sp, -28        # Separa na pilha a quantidade de elementos que vai inserir
    sw $ra, 24($sp)           # Endereço de retorno da função
    sw $a1, 20($sp)           # Endereço inicial da matriz
    sw $a0, 16($sp)           # Valor de N original
    sw $s0, 12($sp)           # Variável temporária para armazenar N

    # Registradores temporários utilizados na função
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)

    move $s0, $a0             # $s0 = N

    or $t0, $zero, $zero      # Zera o contador (int i=0)
    or $t1, $zero, $zero      # Zera o contador (int j=0)

    for_i_print:
        slt $t2, $t0, $s0      # $t2 = $t0 < $s0 => $t2 = i < N
        beq $t2, $zero, end_for_i_print_matrix # Se i >= N sai do loop

        or $t1, $zero, $zero  # Zera o contador de j para a nova iteração

        # Acesso a matriz via (end. inicial + ((i * N) + j) * 4)
        for_j_print:
            slt $t2, $t1, $s0     # $t2 = $t1 < $s0 => $t2 = j < N
            beq $t2, $zero, end_for_j_print_matrix

            mul $t2, $t0, $s0 # $t2 = i * N
            add $t2, $t2, $t1 # $t2 += $t1 => $t2 (aka i*N) += j
            sll $t2, $t2, 2   # ((i * N) + j) * 4

            add $t2, $t2, $a1 # $t2 += end. inicial da matriz

            # Aqui ja tenho o endereço de memória que vou ler
            lw $a0, 0($t2)   # Insiro $t4 (valor teste) na memória
            li   $v0, 1            # syscall print_int
            syscall

            # imprime espaço
            li   $v0, 11
            li   $a0, 32
            syscall

            addi $t1, $t1, 1       # j++
            
            j for_j_print

        end_for_j_print_matrix:

        li $v0, 4
        la $a0, newline
        syscall
        
        # Incrementar i
        addi $t0, $t0, 1         # i++

        j for_i_print                  # Volta para o for de i

    end_for_i_print_matrix:
    lw $ra, 24($sp)           # Endereço de retorno da função
    lw $a1, 20($sp)           # Endereço inicial da matriz
    lw $a0, 16($sp)           # Valor de N original
    lw $s0, 12($sp)           # Variável temporária para armazenar N

    # Registradores temporários utilizados na função
    lw $t0, 8($sp)
    lw $t1, 4($sp)
    lw $t2, 0($sp)
    addi $sp, $sp, 24         # Desaloca o espaço na pilha
    jr $ra                   # Retorna para o chamador



create_identity:
    addi $sp, $sp, -28        # Separa na pilha a quantidade de elementos que vai inserir
    sw $ra, 24($sp)           # Endereço de retorno da função
    sw $a1, 20($sp)           # Endereço inicial da matriz
    sw $a0, 16($sp)           # Valor de N original
    sw $s0, 12($sp)           # Variável temporária para armazenar N

    # Registradores temporários utilizados na função
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)

    move $s0, $a0             # $s0 = N

    or $t0, $zero, $zero      # Zera o contador (int i=0)
    or $t1, $zero, $zero      # Zera o contador (int j=0)

    for_i_create_identity:
        slt $t2, $t0, $s0      # $t2 = $t0 < $s0 => $t2 = i < N
        beq $t2, $zero, end_for_i_create_identity_matrix # Se i >= N sai do loop

        or $t1, $zero, $zero  # Zera o contador de j para a nova iteração

        # Acesso a matriz via (end. inicial + ((i * N) + j) * 4)
        for_j_create_identity:
            slt $t2, $t1, $s0     # $t2 = $t1 < $s0 => $t2 = j < N
            beq $t2, $zero, end_for_j_create_identity_matrix

            mul $t2, $t0, $s0 # $t2 = i * N
            add $t2, $t2, $t1 # $t2 += $t1 => $t2 (aka i*N) += j
            sll $t2, $t2, 2   # ((i * N) + j) * 4

            add $t2, $t2, $a1 # $t2 += end. inicial da matriz

            beq $t0, $t1, identity_i_equals_j  # Se $t0 == $t1, vai para iguais

                or $a0, $zero, $zero # Se i != j, $a0 = 0
                j identity_insert_memory

            identity_i_equals_j:
                ori $a0, $zero, 1 # Se i == j, $a0 = 1

            identity_insert_memory:

            # Aqui ja tenho o endereço de memória que vou inserir o elemento
            sw $a0, 0($t2)   # Insiro $t4 (valor teste) na memória

            addi $t1, $t1, 1       # j++
            
            j for_j_create_identity

        end_for_j_create_identity_matrix:
        
        # Incrementar i
        addi $t0, $t0, 1         # i++

        j for_i_create_identity                  # Volta para o for de i

    end_for_i_create_identity_matrix:
    lw $ra, 24($sp)           # Endereço de retorno da função
    lw $a1, 20($sp)           # Endereço inicial da matriz
    lw $a0, 16($sp)           # Valor de N original
    lw $s0, 12($sp)           # Variável temporária para armazenar N

    # Registradores temporários utilizados na função
    lw $t0, 8($sp)
    lw $t1, 4($sp)
    lw $t2, 0($sp)
    addi $sp, $sp, 24         # Desaloca o espaço na pilha
    jr $ra                   # Retorna para o chamador