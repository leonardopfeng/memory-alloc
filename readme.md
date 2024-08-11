# Implementação de `malloc` em Assembly

Este projeto implementa uma versão customizada da função `malloc` em linguagem Assembly x86. Três diferentes técnicas de gerenciamento de memória na heap são abordadas: **Best Fit**, **Worst Fit** e **First Fit**.

## Técnicas de Gerenciamento da Heap

- **Best Fit**: Encontra o menor bloco de memória que seja grande o suficiente para atender ao pedido. Isso minimiza o desperdício de memória, mas pode causar fragmentação ao longo do tempo.
  
- **Worst Fit**: Seleciona o maior bloco de memória disponível. A ideia é deixar blocos menores disponíveis para futuras alocações, mas essa técnica também pode aumentar a fragmentação.

- **First Fit**: Escolhe o primeiro bloco de memória que seja grande o suficiente para atender ao pedido. Essa abordagem é geralmente mais rápida, mas pode resultar em fragmentação conforme o tempo passa.

## Estrutura do Projeto

- `bestfit/`: Implementação da técnica de **Best Fit** em Assembly.
- `worstfit/`: Implementação da técnica de **Worst Fit** em Assembly.
- `firstfit/`: Implementação da técnica de **First Fit** em Assembly.
## Como Executar

### Requisitos

- Linux
- GCC

### Passos para Compilação e Execução

1. Acesse no terminal uma das páginas relacionadas ao modo de execução do malloc
2. Digite make 
3. Digite ./main
