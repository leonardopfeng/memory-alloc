#ifndef MEMALLOC_h
#define MEMALLOC_H




void setup_brk(); //Obtém o endereço de brk
void dismiss_brk(); //Restaura o endereço de brk
void* memory_alloc(unsigned long int bytes);
//1. Procura bloco livre com tamanho igual ou maior que a requisição
//2. Se encontrar, marca ocupação, utiliza os bytes necessários do bloco, retornando o endereço correspondente
//3. Se não encontrar, abre espaço para um novo bloco
int memory_free(void *pointer); //Marca um bloco ocupado como livre


extern void *brk_inicial;	
extern void *brk_atual;

#endif