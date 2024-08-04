.section .data
.global brk_inicial
.global brk_atual

brk_inicial: .quad 0
brk_atual: .quad 0

.section .text
.global setup_brk                   # função que obtém o endereço de brk
.global dismiss_brk                 # função que restaura o endereço de brk
.global memory_alloc                # função para alocar um bloco de memória, retorna o endereço do bloco alocado
.global memory_free                 # função para marcar um bloco ocupado como livre

setup_brk:
    movq $12, %rax                  # código da syscall para chamar a brk
    movq $0, %rdi                   # retorna o valor atual de brk em %rax
    syscall                         # chama a syscall
    movq %rax, brk_inicial          # salva o começo da heap em brk_inicial
    movq %rax, brk_atual            # salva o começo da heap em brk_atual
    ret

dismiss_brk:
    movq $12, %rax                  # código da syscall para chamar brk
    movq brk_inicial, %rdi          # volta a brk para o início
    syscall                         # chama a syscall
    movq brk_inicial, %rax          # salva o endereço original da brk em %rax
    movq %rax, brk_atual            # endereço atual da brk é o início
    ret

memory_alloc:
    movq brk_inicial, %r8           # salva o início da brk em %r8
    movq brk_atual, %r9             # salva o lugar da brk atual em %r9
    movq %rdi, %r10                 # salva o tamanho da alocação em %r10
    cmpq %r8, %r9                  # compara se é a primeira alocação
    je .aloca_bloco_novo           # se é a primeira, vai para a função de alocar novo bloco

.encontra_bloco_livre:
    movq %r8, %r11                 # %r11 vai salvar o endereço do primeiro bloco
    movq $0, %r14                  # %r14 vai salvar o endereço do bloco a ser alocado
    movq $9223372036854775807, %r15 # %r15 vai salvar o tamanho do menor bloco (inicialmente infinito)
    
.loop:
    cmpq $0, (%r11)                # verifica se o bloco está livre
    jne .proximo                   # se não está livre, vai para o próximo bloco
    cmpq %r10, 8(%r11)             # verifica se o tamanho do bloco livre é suficiente
    jg .proximo                    # se não for suficiente, vai para o próximo bloco
    cmpq 8(%r11), %r15             # verifica se o tamanho do bloco é menor que o menor encontrado
    jge .proximo                   # se não for menor, vai para o próximo bloco
    movq 8(%r11), %r15             # salva o tamanho do bloco em %r15
    movq %r11, %r14                # salva o endereço do bloco

.proximo:
    addq 8(%r11), %r11             # adiciona o tamanho do bloco para ir para o próximo
    addq $16, %r11                 # %r11 é o início do próximo bloco
    cmpq %r9, %r11                 # se %r11 é menor que %r9, então não chegou na brk atual
    jl .loop                       # volta ao loop
    cmpq $0, %r14                  # se não achou um bloco para alocar, aloca um novo bloco
    je .aloca_bloco_novo           # realiza a alocação de um novo bloco
    jmp .aloca_bloco_existente     # realiza a alocação no bloco existente

.aloca_bloco_novo:
    addq $16, %r9                  # ajusta o endereço para o novo bloco
    movq %r9, %r12                 # salva o início do bloco
    addq %rdi, %r9                 # ajusta a brk para o novo bloco
    movq %r9, %rdi                 # chama syscall com o novo valor da brk
    movq $12, %rax                 # código da syscall para brk
    syscall                        # faz a syscall
    movq brk_atual, %r8            # salva o início do bloco
    movq $1, (%r8)                 # marca o bloco como alocado
    movq %r10, 8(%r8)              # define o tamanho do bloco
    movq %r9, brk_atual            # atualiza o valor da brk atual
    movq %r12, %rax                # retorna o endereço do bloco
    ret

.aloca_bloco_existente:
    movq $1, (%r14)                # marca o bloco como alocado
    movq %r15, %r12                # %r12 = tamanho do bloco disponível
    subq %r10, %r12                # %r12 = tamanho do bloco restante
    cmpq $16, %r12                 # verifica se pode dividir o bloco
    jl .aloca_inteiro              # se não puder dividir, aloca o bloco inteiro
    movq %r10, 8(%r14)             # define o tamanho do bloco alocado
    addq $16, %r14                 # ajusta o endereço para o início do novo bloco
    movq %r14, %r13                # salva o início do novo bloco
    addq %r10, %r14                # ajusta o endereço para o tamanho do novo bloco
    movq $0, (%r14)                # marca o novo bloco como livre
    movq %r12, 8(%r14)             # define o tamanho do novo bloco
    movq %r13, %rax                # retorna o endereço do bloco alocado
    ret

.aloca_inteiro:
    addq $16, %r14                 # ajusta o endereço para o início do bloco
    movq %r14, %rax                # retorna o endereço do bloco
    ret

memory_free:
    cmpq brk_atual, %rdi           # verifica se o argumento está dentro da área da heap
    jge .fora_heap                 # se fora da área da heap, não pode liberar
    cmpq brk_inicial, %rdi         # verifica se o argumento está dentro da área da heap
    jl .fora_heap                  # se fora da área da heap, não pode liberar
    subq $16, %rdi                 # ajusta o endereço para o início do bloco
    movq $0, (%rdi)                # marca o bloco como livre
    ret

.fora_heap:
    movq $0, %rax                  # retorna 0 se fora da área da heap
    ret
