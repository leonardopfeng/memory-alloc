.section .data
.global brk_inicial 
.global brk_atual

brk_inicial: .quad 0
brk_atual: .quad 0

.section .text                      
.global setup_brk                   # funcao que obtem o endereco de brk
.global dismiss_brk                 # funcao que restaura o endereco de brk
.global memory_alloc                # funcao para alocar um bloco de memoria, retorna o endereco do bloco alocado
.global memory_free                 # funcao para marcar um bloco ocupado como livre

setup_brk:
    movq $12, %rax                  # codigo da syscall para chamar a brk
    movq $0, %rdi                   # retorna o valor atual de brk em %rax
    syscall                         # chama a syscall 
    movq %rax, brk_inicial         # salva o comeco da heap em brk_inicial (constante)
    movq %rax, brk_atual          # salva o comeco da heap em brk_atual (variavel)
    ret                             # retorna

dismiss_brk:
    movq $12, %rax                  # codigo da syscall para chamar brk
    movq brk_inicial, %rdi         # volta a brk para o inicio
    syscall                         # chama a syscall
    movq brk_inicial, %rax         # salva o endreco original da brk rax
    movq %rax, brk_atual          # endereco atual da brk eh o inicio
    ret

memory_alloc:
    movq brk_inicial, %r8          # salva o inicio da brk em %r8
    movq brk_atual, %r9           # salva o lugar da brk atual em %r9
    movq %rdi, %r10                 # salva o tamanho da alocacao em %r10
    cmpq %r8, %r9                   # compara de eh a primeira alocacao
    je .aloca_bloco_novo            # se eh a primeira, vai para func de alocar novo bloco

.encontra_bloco_livre:
    movq %r8, %r11                  # %r11 vai salvar o endereco do primeiro bloco
    movq $0, %r14                   # %r14 vai salvar o endereco do bloco a ser alocado
    movq $0, %r15                   # %r15 vai salvar o tamanho do bloco a ser alocado

.loop:
    cmpq $0, (%r11)                 # verifica se o bloco esta livre
    jne .proximo                    # se nao esta, entao vai para o proximo bloco
    cmpq 8(%r11), %r10              # verifica se o tamanho do bloco livre é suficiente
    jg .proximo                     # se nao for suficiente, vai para o proximo bloco
    movq 8(%r11), %r15              # foi encontrado o novo bloco, entao atribui em %r15
    movq %r11, %r14                 # salva o endereco do bloco
    jmp .aloca_bloco_existente

.proximo:    
    addq 8(%r11), %r11              # adiciona o tamanho do bloco para ir para o proximo
    addq $16, %r11                  # %r11 eh o inicio do proximo bloco
    cmpq %r9, %r11                  # se %r11 eh menor q %r9, entao nao chegou na brk current
    jl .loop                        # volta ao loop
    cmpq $0, %r14                   # se chegou na brk current, e nao achou um bloco pra alocar, entao aloca
    je .aloca_bloco_novo            # realiza a alocacao de um novo bloco se nao achou um bloco
    jmp .aloca_bloco_existente      # realiza a alocanao no bloco ja existente

.aloca_bloco_novo:
    addq $16, %r9                   # comeco do bloco, depois do registro de 16 Bytes
    movq %r9, %r12                  # salva o endereco do comeco do bloco em %r12
    addq %rdi, %r9                  # adiciona o tamanho da alocao em %r9
    movq %r9, %rdi                  # coloca o endereco para chamar a syscall
    movq $12, %rax                  # codigo da syscall para brk
    syscall                         # faz a syscall
    movq brk_atual, %r8           # pega o comeco do bloco, onde esta o registro e salva em %r8
    movq $1, (%r8)                  # coloca 1 para status de bloco alocado
    movq %r10, 8(%r8)               # coloca o tamanho do bloco alocado no registro
    movq %r9, brk_atual           # salva o valor atual da brk em current
    movq %r12, %rax                 # salva o endereco do comeco do bloco em %rax
    ret                             # retorna 

.aloca_bloco_existente:             # como vai alocar em bloco ja existente, eh necesserio ver se eh possivel dividir em mais de um bloco
    movq $1, (%r14)                 # coloca o byte de alocado no primeiro bloco
    movq %r15, %r12                 # %r12 = tamanho do bloco a ser alocado
    subq %r10, %r12                 # %r12 = tamanho do bloco total - tamanho a ser alocado
    cmpq $17, %r12                  # se o valor de %r12 >= 17, entao da pra divir em 2
    jl .aloca_inteiro                # aloca o bloco inteiro, ja que nao da pra dividir
    movq %r10, 8(%r14)              # coloca o tamanho do bloco
    addq $16, %r14                  # %r14 = inicio do bloco
    movq %r14, %r13                 # salva o endereco do primeiro bloco em %r13
    addq %r10, %r14                 # %r14 agora esta no comeco do registro do segundo bloco
    movq $0, (%r14)                 # seta o status como nao alocado
    subq $16, %r12                  # %r12 agora eh o tamanho disponivel que tem para alocacao
    movq %r12, 8(%r14)              # adiciona o tamanaho do segundo bloco
    movq %r13, %rax                 # coloca o endereco do primeiro bloco no %rax para retorno
    ret                             # retorna

.aloca_inteiro:
    addq $16, %r14                  # %r14 agora aponta pro comeco do bloco
    movq %r14, %rax                 # %rax = %r14 para retornar
    ret

memory_free:
    cmpq brk_atual, %rdi          # verifica se o argumento esta dentro da area da heap
    jge .fora_heap                  # se a entrada for maior que a area da heap, nao tem como dar free
    cmpq brk_inicial, %rdi         # verifica se o argumento esta dentro da area da heap
    jl .fora_heap                   # se a entrada for menor qeu a area da heap, nao tem como dar free
    subq $16, %rdi                  # ajusta o endereço para apontar para o início do bloco
    movq $0, (%rdi)                 # coloca 0 no status do bloco de alocado
    ret                             # retorna 

.fora_heap:
    movq $0, %rax                   # coloca 0 em %rax para retorno
    ret                             # retorna    
        