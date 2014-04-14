// This code was tested with LLVM Clang 5.1 (c11) on Mac OS X

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Including limits.h to detect overflows
#include <limits.h>

#define INSTR_MAX_REG      3
#define INSTR_NAME_SIZE    64

#pragma mark Data structures declarations

// Forward declaration of VM.
struct VM;

// Signature of the function pointers.
typedef void (*instr_funct)(struct VM* p_vm, size_t reg_pos[INSTR_MAX_REG]);
typedef int* Memory;

typedef struct Instr{
  char          name[INSTR_NAME_SIZE];
  size_t        registers[INSTR_MAX_REG];
  instr_funct   funct;
} Instr;

typedef struct Progr{
  size_t        offset;
  Instr**       instructs;
} Progr;

typedef struct Processor{
  size_t        regs_size;
  int*          regs;
  Instr**       instr_pointer;
} Processor;

typedef enum VMState {
  kVMStateNoProgram,
  kVMStateProgramLoaded,
  kVMStateExecuting,
  kVMStateDone
} VMState;

typedef struct VM {
  Processor     proc;
  Memory        mem;
  size_t        mem_size;
  Progr         program;
  VMState       state;
} VM;

#pragma mark Utilitary methods

void check_overflow(int num1, int num2){
  if ((num2 > 0 && num1 > INT_MAX - num2) || (num2 < 0 && num1 < INT_MIN - num2)){
    puts("Warning: An addition over/under-flowed.");
  }
}

#pragma mark Virtual Machine Instructions functions

void do_add(VM* p_vm, size_t reg_pos[INSTR_MAX_REG]){
  int num1 = p_vm->proc.regs[reg_pos[0]];
  int num2 = p_vm->proc.regs[reg_pos[1]];

  // Let's log a warning in case of overflow.

  check_overflow(num1, num2);

  p_vm->proc.regs[reg_pos[2]] = num1 + num2;
}

void do_memwrite(VM* p_vm, size_t reg_pos[INSTR_MAX_REG]){
  p_vm->mem[reg_pos[1]] = p_vm->proc.regs[reg_pos[0]];
}

void do_memread(VM* p_vm, size_t reg_pos[INSTR_MAX_REG]){
  p_vm->proc.regs[reg_pos[1]] = p_vm->mem[reg_pos[0]];
}

#pragma mark Virtual Machine Instructions Constructors

Instr* create_add(size_t nb1, size_t nb2, size_t nb3){
  Instr* instr = malloc(sizeof(Instr));
  strcpy(instr->name, "ADD");

  instr->funct             = do_add;
  instr->registers[0]      = nb1;
  instr->registers[1]      = nb2;
  instr->registers[2]      = nb3;

  return instr;
}

Instr* create_write(size_t reg_nb, size_t where){
  Instr* instr = malloc(sizeof(Instr));
  strcpy(instr->name, "WRITE");

  instr->funct          = do_memwrite;
  instr->registers[0]   = reg_nb;
  instr->registers[1]   = where;

  return instr;
}

Instr* create_read(size_t where, size_t reg_nb){
  Instr* instr = malloc(sizeof(Instr));
  strcpy(instr->name, "READ");

  instr->funct          = do_memread;
  instr->registers[0]   = where;
  instr->registers[1]   = reg_nb;

  return instr;
}

#pragma mark Virtual Machine Runtime

void display_vm(VM* p_vm){
  puts("--------------------------------------------------");
  puts("Etat des registres :");

  for (size_t i = 0; i < p_vm->proc.regs_size; i += 1){
    if(p_vm->proc.regs[i] != 0)
      printf("%zu -> %d \n", i, p_vm->proc.regs[i]);
  }

  puts("--------------------------------------------------");
  puts("Pointeur d'instruction :");

  switch(p_vm->state){
    case kVMStateNoProgram:
      puts("Pas de programme chargé");
      break;

    case kVMStateDone:
      puts("L'execution du programme est finie");
      break;

    default:{
      Instr* i = *p_vm->proc.instr_pointer+1;
      printf("Vers %s(%zd, %zd, %zd)\n",  i->name,
                                          i->registers[0],
                                          i->registers[1],
                                          i->registers[2]);
      break;
    }
  }

  puts("--------------------------------------------------");
  puts("Etat de la mémoire :");

  int is = 1;

  for (size_t i = 0; i < p_vm->mem_size; i += 1){
    int value = p_vm->mem[i];

    if(i == 0){
      printf("%zd -> %zd\n", i, value);
    } else{
      if (value != 0){
        printf("%zd -> %zd\n", i, value);
        is = 1;
      } else{
        if(is == 1){
          puts("...");
        }
        is = 0;
      }
    }
  }
}

void exec_instr(VM* p_vm, Instr* p_i){
  puts("==================================================");
  printf("J'éxécute: %s(%zu, %zu, %zu)\n", p_i->name, p_i->registers[0], p_i->registers[1], p_i->registers[2]);

  p_i->funct(p_vm, p_i->registers);
}

void run(VM* p_vm){

  Instr* n_instructions = p_vm->program.instructs[p_vm->program.offset - 1];
  p_vm->state = kVMStateExecuting;

  for(;*p_vm->proc.instr_pointer < n_instructions; p_vm->proc.instr_pointer += 1){
    Instr* cur  = *p_vm->proc.instr_pointer;
    // Execute the instruction.
    exec_instr(p_vm, cur);
    // Display state
    display_vm(p_vm);
  }

  p_vm->proc.instr_pointer = NULL;

  exec_instr(p_vm, n_instructions);
  p_vm->state = kVMStateDone;
  display_vm(p_vm);
}

#pragma mark VM & Program constructors

VM* create_vm(size_t nb_regs, size_t mem_size){
  VM* vm              = malloc(sizeof(VM));

  vm->state           = kVMStateNoProgram;

  vm->mem             = malloc(sizeof(int) * mem_size);
  vm->mem_size        = mem_size;

  vm->proc.regs       = malloc(sizeof(int) * nb_regs);
  vm->proc.regs_size  = nb_regs;

  return vm;
}

Progr* create_progr(size_t offset){
  Progr* prog         = malloc(sizeof(Progr));
  prog->offset        = offset;
  prog->instructs     = malloc(sizeof(Instr) * offset);

  return prog;
}

void load_prog(VM* p_vm, Progr* progr){
  p_vm->program  = *progr;
  p_vm->state    = kVMStateProgramLoaded;
  p_vm->proc.instr_pointer = (progr->offset > 0)?&progr->instructs[0]:NULL;
}

void reclaim_memory(VM* p_vm, Progr* progr){
  free(p_vm->proc.regs);
  free(p_vm->mem);
  free(p_vm);

  for (size_t i = 0; i < progr->offset; i++){
    free(progr->instructs[i]);
  }

  free(progr->instructs);
  free(progr);
}

#pragma mark Main Execution

int main(void){
  VM* ma_vm = create_vm( 16, 2048);
  puts("==================================================");
  puts("Au départ :");
  display_vm(ma_vm);

  ma_vm->mem[44] = 427;
  ma_vm->mem[56] = 128;

  Progr* progr        = create_progr(4);
  progr->instructs[0] = create_read(44, 1);
  progr->instructs[1] = create_read(56, 2);
  progr->instructs[2] = create_add(1, 2, 3);
  progr->instructs[3] = create_write(3, 123);

  load_prog(ma_vm, progr);

  puts("==================================================");
  puts("Programme chargé et mémoire initialisée :");
  display_vm(ma_vm);

  run(ma_vm);

  reclaim_memory(ma_vm, progr);

  return 0;
}
