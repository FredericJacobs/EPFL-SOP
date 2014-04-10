#include <stdio.h>
#include <stdlib.h>

#define INSTR_MAX_REG    3
#define INSTR_NAME_SIZE 64


void do_add(VM* p_vm,
            size_t reg_pos[INSTR_MAX_REG])
{
  /* certainement d'autres choses... */
  p_vm->proc.regs[reg_pos[2]] = 
      p_vm->proc.regs[reg_pos[0]]
    + p_vm->proc.regs[reg_pos[1]] ;
}

void do_memwrite(VM* p_vm, size_t reg_pos[INSTR_MAX_REG])
{
}

void do_memread(VM* p_vm, size_t reg_pos[INSTR_MAX_REG])
{
}

Instr* create_add(size_t nb1, size_t nb2, size_t nb3)
{
}


Instr* create_write(size_t reg_nb, size_t where)
{
}

Instr* create_read(size_t where, size_t reg_nb)
{
}

void exec_instr(VM* p_vm, Instr* p_i)
{
  puts("==================================================");
}

void display_vm(VM* p_vm)
{
  puts("--------------------------------------------------");
  puts("Etat des registres :");

  puts("--------------------------------------------------");
  puts("Pointeur d'instruction :");

  puts("--------------------------------------------------");
  puts("Etat de la mémoire :");

}

void run(VM* p_vm)
{
}

VM* create_vm(size_t nb_regs, size_t mem_size)
{
}

int main(void) {

  // A VM with 4 registers and 1 Ko of memory (!!)
  VM* ma_vm = create_vm( 4, 1024);
  puts("==================================================");
  puts("Au départ :");
  display_vm(ma_vm);


  puts("==================================================");
  puts("Programme chargé et mémoire initialisée :");
  display_vm(ma_vm);

  run(ma_vm);



  return 0;
}
