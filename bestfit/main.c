#include <stdio.h>
#include <stdlib.h>

#include "memalloc.h" 							

extern void *brk_inicial;	/* Você precisa ter a variável global que armazena o valor de brk como um extern aqui. */

int main() { 

	printf("============================== ROTINAS DE TESTE ==============================\n");
	
	setup_brk();
	void *initial_brk = brk_inicial;
	void *first_pnt, *second_pnt, *third_pnt, *fourth_pnt, *fifth_pnt;

	// Aloca um bloco de memória de 100 bytes
	first_pnt = memory_alloc(100);
	printf("==>> ALOCANDO UM ESPAÇO DE 100 BYTES:\n");
	printf("\tLOCAL: %s\n", first_pnt - 16 == initial_brk ? "CORRETO!" : "INCORRETO!");
	printf("\tIND. DE USO: %s\n", *((long long*) (first_pnt - 16)) == 1 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (first_pnt - 8)) == 100 ? "CORRETO!" : "INCORRETO!");

	// Aloca um bloco de memória de 50 bytes
	second_pnt = memory_alloc(50);
	printf("==>> ALOCANDO UM ESPAÇO DE 50 BYTES:\n");
	printf("\tLOCAL: %s\n", second_pnt - 16 == initial_brk ? "CORRETO!" : "INCORRETO!");
	printf("\tIND. DE USO: %s\n", *((long long*) (second_pnt - 16)) == 1 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (second_pnt - 8)) == 50 ? "CORRETO!" : "INCORRETO!");

	// Aloca um bloco de memória de 25 bytes
	third_pnt = memory_alloc(25);
	printf("==>> ALOCANDO UM ESPAÇO DE 25 BYTES:\n");
	printf("\tLOCAL: %s\n", third_pnt - 16 == initial_brk ? "CORRETO!" : "INCORRETO!");
	printf("\tIND. DE USO: %s\n", *((long long*) (third_pnt - 16)) == 1 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (third_pnt - 8)) == 25 ? "CORRETO!" : "INCORRETO!");

	// Aloca um bloco de memória de 30 bytes
	fourth_pnt = memory_alloc(30);
	printf("==>> ALOCANDO UM ESPAÇO DE 30 BYTES:\n");
	printf("\tLOCAL: %s\n", fourth_pnt - 16 == initial_brk ? "CORRETO!" : "INCORRETO!");
	printf("\tIND. DE USO: %s\n", *((long long*) (fourth_pnt - 16)) == 1 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (fourth_pnt - 8)) == 30 ? "CORRETO!" : "INCORRETO!");

	// Aloca um bloco de memória de 10 bytes que deve ser alocado no bloco restante menor
	fifth_pnt = memory_alloc(10);
	printf("==>> ALOCANDO UM ESPAÇO DE 10 BYTES:\n");
	printf("\tLOCAL: %s\n", fifth_pnt - 16 == initial_brk ? "CORRETO!" : "INCORRETO!");
	printf("\tIND. DE USO: %s\n", *((long long*) (fifth_pnt - 16)) == 1 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (fifth_pnt - 8)) == 10 ? "CORRETO!" : "INCORRETO!");

	// Verifica fragmentação de memória
	printf("==> VERIFICANDO A FRAGMENTAÇÃO DE MEMÓRIA:\n");
	printf("\tIND. DE USO: %s\n", *((long long*) (first_pnt + 100)) == 0 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (first_pnt + 108)) == 50 ? "CORRETO!" : "INCORRETO!");

	printf("==>> DESALOCANDO TUDO:\n");
	memory_free(first_pnt);
	memory_free(second_pnt);
	memory_free(third_pnt);
	memory_free(fourth_pnt);
	memory_free(fifth_pnt);
	printf("\tIND. DE USO: %s\n", *((long long*) (first_pnt - 16)) == 0 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (first_pnt - 8)) == 100 ? "CORRETO!" : "INCORRETO!");
	printf("\tIND. DE USO: %s\n", *((long long*) (second_pnt - 16)) == 0 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (second_pnt - 8)) == 50 ? "CORRETO!" : "INCORRETO!");
	printf("\tIND. DE USO: %s\n", *((long long*) (third_pnt - 16)) == 0 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (third_pnt - 8)) == 25 ? "CORRETO!" : "INCORRETO!");
	printf("\tIND. DE USO: %s\n", *((long long*) (fourth_pnt - 16)) == 0 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (fourth_pnt - 8)) == 30 ? "CORRETO!" : "INCORRETO!");
	printf("\tIND. DE USO: %s\n", *((long long*) (fifth_pnt - 16)) == 0 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (fifth_pnt - 8)) == 10 ? "CORRETO!" : "INCORRETO!");

	printf("==>> DESALOCANDO A PILHA (ILEGAL):\n");
	unsigned long long stack_var = 0;
	unsigned int alloc_return = memory_free((void*) &stack_var);
	if (!alloc_return) printf("\tO RETORNO DA LIBERAÇÃO FOI NULL!\n");

	return 0;
}
