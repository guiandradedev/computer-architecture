.data
    msg: .asciiz "Digite o valor de N (tamanho da matriz NxN): \n"
    msg_num: .asciiz "Digite um numero para a matriz A["
    msg_num2: .asciiz "]["
    msg_num3: .asciiz "]: "
    N_invalido_msg: .asciiz "Erro: N deve ser maior que 0 \n"
    gauss_valido_msg: .asciiz "Matriz inversa calculada: \n"
    gauss_invalido_msg: .asciiz "Erro: Não e possivel calcular a matriz inversa dessa matriz. \n"
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
    li $v0, 9                 # syscall para alocação da matriz identidade
    syscall
    move $s1, $v0             # $s1 = endereço da matriz identidade alocada

    move $a0, $t0
    move $a1, $s0
    jal read_matrix            # Executa a funcão de printa matriz
    jal print_matrix

    li $v0, 4
    la $a0, newline
    syscall
    
    move $a0, $t0
    move $a1, $s1
    jal create_identity
    jal print_matrix

    li $v0, 4
    la $a0, newline
    syscall

    move $a0, $t0
    move $a1, $s0
    move $a2, $s1
    jal gauss_jordan

    bne $v0, $zero, gauss_valido
    li $v0, 4
    la $a0, gauss_invalido_msg
    syscall
    j end_prog

    gauss_valido:
    li $v0, 4
    la $a0, gauss_valido_msg
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    move $a0, $t0
    move $a1, $s0
    jal print_matrix

    li $v0, 4
    la $a0, newline
    syscall

    move $a0, $t0
    move $a1, $s1
    jal print_matrix

    end_prog:
    li   $v0,10                # Encerra o programa
    syscall

N_invalido:
    li $v0, 4                 # Chamada para print string
    la $a0, N_invalido_msg    # Carrega o endereço da string msg
    syscall
    
    j end_prog                # Finaliza o programa caso N <= 0

#----------------------------------------- Leitura de matriz
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

    li.s $f1, 1.0         # Carrega o valor 1.0 no registrador de ponto flutuante $f1

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

            # Exibição da mensagem de leitura
            li $v0, 4
            la $a0, msg_num # "Digite um numero para a matriz A["
            syscall

            li $v0, 1
            move $a0, $t0 # i
            syscall

            li $v0, 4
            la $a0, msg_num2 # "]["
            syscall

            li $v0, 1
            move $a0, $t1 # j
            syscall

            li $v0, 4
            la $a0, msg_num3 # "]: "
            syscall

            li $v0, 6 # Le o digito
            syscall

            swc1 $f0, 0($t2)   # Insiro $t4 (valor teste) na memória

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
    
#----------------------------------------------- Printa matriz
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
            lwc1 $f12, 0($t2)   # Insiro $t4 (valor teste) na memória
            li   $v0, 2            # syscall print_int
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
    addi $sp, $sp, 28         # Desaloca o espaço na pilha
    jr $ra                   # Retorna para o chamador

#-------------------------------------------------------- Criação da Matriz Identidade
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

                li.s $f12, 0.0
                j identity_insert_memory

            identity_i_equals_j:
                li.s $f12, 1.0

            identity_insert_memory:

            # Aqui ja tenho o endereço de memória que vou inserir o elemento
            swc1 $f12, 0($t2)   # Insiro $t4 (valor teste) na memória

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
    addi $sp, $sp, 28         # Desaloca o espaço na pilha
    jr $ra                   # Retorna para o chamador

#----------------------------------------- Gauss Jordan
gauss_jordan:
    addi $sp, $sp, -60
    sw $s0, 56($sp)
    sw $a0, 52($sp)
    sw $a1, 48($sp)
    sw $a2, 44($sp)

    sw $t0, 40($sp)
    sw $t1, 36($sp)
    sw $t2, 32($sp)
    sw $t3, 28($sp)
    sw $t4, 24($sp)
    sw $t5, 20($sp)
    sw $t6, 16($sp)
    sw $t7, 12($sp)

    swc1 $f0, 8($sp)
    swc1 $f1, 4($sp)
    swc1 $f2, 0($sp)

    # Pilha
    #$a0 = N
    #$a1 = Matriz
    #$a2 = Identidade

    #$t0 = i
    #$t1 = j
    #$t2 = Endereço de i * N
    #$t3 = livre
    #$t4 = livre
    #$t5
    #$t6
    #$t7
    #$f0 = 0
    #$f1
    #$f2

    # Cria a identidade aqui!


    # Declarações iniciais
    move $s0, $a0                                               # $s0 = N
    or $t0, $zero, $zero                                        # Zera o contador (int i=0)
    li.s   $f0, 0.0                                             # Define que $f0 = 0.0

    for_i_gauss_jordan:
        slt $t2, $t0, $s0                                       # Verifica se $t0 < $s0, ou seja, se i < N
        beq $t2, $zero, end_for_i_gauss_jordan_matrix           # Se i >= N sai do loop

        or $t1, $zero, $zero                                    # Zera o contador (int j=0)

        #--------------- Verifica se é possível calcular a matriz inversa
        # Calculo do endereço de M[i][i]
        mul $t2, $t0, $s0                                       # $t2 = i * N, offset de acesso a matriz [i][x]
        move $t3, $t2                                           # Coloca em $t3 o offset de [i] para evitar contas redundantes
        add $t3, $t3, $t0                                       # $t3 += $t0, ou seja, $t3 (aka i*N) += i
        sll $t3, $t3, 2                                         # $t3 = ((i * N) + i) * 4, endereço [i][j] sem o endereço base da matriz
        add $t3, $t3, $a1                                       # $t3 += end. inicial da matriz

        lwc1 $f1, 0($t3)                                        # Carrega na memória M[i][i]

        c.eq.s $f0, $f1                                         # Compara se $f0 (zero) != $f1 (M[i][i])
        bc1f valid_matrix

        # $f0 == $f1, finaliza a função retornando zero, ou seja, matriz inválida
        or $v0, $zero, $zero
        jr $ra


        #------------- Normalização da matriz com base no pivô (diagonal principal)
        valid_matrix:
        for_j_normalize_matrix:
            slt $t4, $t1, $s0                                   # $t4 = $t1 < $s0, ou seja $t4 = j < N
            beq $t4, $zero, end_for_j_normalize_matrix          # Se j >= N finaliza o loop

            add $t4, $t2, $t1                                   # $t4 = $t2 + $t0 => $t4 = (i*N) + j
            sll $t4, $t4, 2                                     # $t4 = ((i * N) + j) * 4, $t4 guarda o offset de [i][j] em uma matriz NxN

            # Normalizando a matriz do usuário 
            add $t3, $t4, $a1                                   # $t3 += end. inicial da matriz
            lwc1 $f2, 0($t3)                                    # $f2 = M[i][j]
            div.s $f2, $f2, $f1                                 # $f2 /= $f1 => M[i][j] /= M[i][i]
            swc1 $f2, 0($t3)                                    # Coloca na memória o resultado da divisão guardado em $f2

            # Normalizando a matriz identidade
            add $t3, $t4, $a2                                   # $t3 += end. inicial da matriz identidade
            lwc1 $f2, 0($t3)                                    # $f2 = I[i][j]
            div.s $f2, $f2, $f1                                 # $f2 /= $f1 => M[i][j] /= M[i][i]
            swc1 $f2, 0($t3)                                    # Coloca na memória o resultado da divisão guardado em $f2
            
            addi $t1, $t1, 1                                    # Incrementa j++

            j for_j_normalize_matrix                            # Retorna para a próxima iteração do loop
        
        end_for_j_normalize_matrix:

        #----------------------- Elimina os elementos acima e abaixo do pivô

        or $t1, $zero, $zero                                    # Zero o contador j

        for_j_eliminate_elements:
            slt $t4, $t1, $s0                                   # $t4 = $t1 < $s0, ou seja $t2 = j < N
            beq $t4, $zero, end_for_j_eliminate_elements        # Se j >= N finaliza o loop

            or $t3, $zero, $zero                                # Inicializa $t3 como contador k=0

            beq $t0, $t1, eliminate_elements_i_equals_j         # Verifica se i == j

            # Calcula o endereço A[j][i]
            mul $t4, $t1, $s0                                   # $t4 = (j * N), valor reutilizado mais pra frente
            add $t5, $t4, $t0                                   # $t5 = $t4 + $t0 => $t5 = (j*N) + i
            sll $t5, $t5, 2                                     # $t5 = ((j * N) + i) * 4 calcula o offset [j][i]
            add $t5, $t5, $a1                                   # Soma em $t5 o endereço base da matriz A

            lwc1 $f1, 0($t5)                                    # $f1 = A[j][i]   

            for_k_eliminate_elements:
                slt $t5, $t3, $s0                               # $t5 = $t3 < $s0, ou seja $t2 = k < N
                beq $t5, $zero, end_for_k_eliminate_elements    # Se k >= N finaliza o loop

                #--- Calculo de [j][k]
                add $t5, $t4, $t3                               # $t5 = (j * N) + k
                sll $t5, $t5, 2                                 # $t5 *= 4

                # Calculo de [i][k]
                add $t6, $t2, $t3                               # $t6 = (i * N) + k
                sll $t6, $t6, 2                                 # $t6 *= 4

                # A[j][k] -= A[i][k] * A[j][i];
                add $t7, $t6, $a1                               # Endereço de A[i][k]
                lwc1 $f2, 0($t7)                                # $f2 = A[i][k]
                mul.s $f2, $f2, $f1                             # A[i][k] * A[j][i]

                add $t7, $t5, $a1                               # Endereço de A[j][k]
                lwc1 $f3, 0($t7)                                # $f3 = A[j][k]
                sub.s $f3, $f3, $f2                             # $f3 -= $f2
                swc1 $f3, 0($t7)                                # Coloca na memória o resultado de $f3

                # I[j][k] -= I[i][k] * temp;
                add $t7, $t6, $a2                               # Endereço de I[i][k]
                lwc1 $f2, 0($t7)                                # $f2 = I[i][k]
                mul.s $f2, $f2, $f1                             # I[i][k] * I[j][i]

                add $t7, $t5, $a2                               # Endereço de I[j][k]
                lwc1 $f3, 0($t7)                                # $f3 = I[j][k]
                sub.s $f3, $f3, $f2                             # $f3 -= $f2
                swc1 $f3, 0($t7)                                # Coloca na memória o resultado de $f3

                addi $t3, $t3, 1                                # Incrementa o contador k++

                j for_k_eliminate_elements                      # Finaliza a iteração e volta para o loop

                end_for_k_eliminate_elements:

            eliminate_elements_i_equals_j:

            addi $t1, $t1, 1
            j for_j_eliminate_elements

        end_for_j_eliminate_elements:

        # Fim da iteração i
        addi $t0, $t0, 1
        j for_i_gauss_jordan

    end_for_i_gauss_jordan_matrix:

    ori $v0, $zero, 1
    lw $s0, 56($sp)
    lw $a0, 52($sp)
    lw $a1, 48($sp)
    lw $a2, 44($sp)

    lw $t0, 40($sp)
    lw $t1, 36($sp)
    lw $t2, 32($sp)
    lw $t3, 28($sp)
    lw $t4, 24($sp)
    lw $t5, 20($sp)
    lw $t6, 16($sp)
    lw $t7, 12($sp)

    lwc1 $f0, 8($sp)
    lwc1 $f1, 4($sp)
    lwc1 $f2, 0($sp)
    addi $sp, $sp, 60
    jr $ra