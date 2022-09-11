#include "types.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

struct {
  struct spinlock lock;
  uint8 reference_count;
} cow_array[(PHYSTOP - KERNBASE)/PGSIZE];   // (Book p.32) (PHYSTOP - KERNBASE) shift right devision 2^12=4096-bytepage directory 

// increase the reference count
void increase_reference_cnt(uint64 pa){
  if (pa < KERNBASE) {  
    return;
  }
  // move 12 bits to the right to get the physical page reference count where the physical address is located
  pa = (pa - KERNBASE)/PGSIZE;   
  acquire(&cow_array[pa].lock);  // unlock
  ++cow_array[pa].reference_count;
  release(&cow_array[pa].lock); // lock
}

// decrease the reference count
uint8 decrease_reference_cnt(uint64 pa){
  uint8 temp;
  if (pa < KERNBASE) {
    return 0;
  }
  pa = (pa - KERNBASE)/PGSIZE;
  acquire(&cow_array[pa].lock); //unlock 
  temp = --cow_array[pa].reference_count;
  release(&cow_array[pa].lock); // lock
  return temp;
}

uint8 reference_cnt(uint64 pa){
  uint8 temp;
  if (pa < KERNBASE) { 
    return 0;
  }
  pa = (pa - KERNBASE)/PGSIZE;
  acquire(&cow_array[pa].lock); //unlock 
  temp = cow_array[pa].reference_count;
  release(&cow_array[pa].lock); // lock
  return temp;
}
