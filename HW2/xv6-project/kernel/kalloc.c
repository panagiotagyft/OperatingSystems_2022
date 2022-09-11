// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  freerange(end, (void*)PHYSTOP);
}

// void
// freerange(void *pa_start, void *pa_end)
// {
//   char *p;
//   p = (char*)PGROUNDUP((uint64)pa_start);
//   for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
//     kfree(p);
// }

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
      increase_reference_cnt((uint64)p); // iniatialize reference counter equal with -->> 1 
      kfree(p);
  }
}

// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)

// void
// kfree(void *pa)
// {
//   struct run *r;

//   if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
//     panic("kfree");
  
//   // Fill with junk to catch dangling refs.
//   memset(pa, 1, PGSIZE);

//   r = (struct run*)pa;

//   acquire(&kmem.lock);
//   r->next = kmem.freelist;
//   kmem.freelist = r;
//   release(&kmem.lock);
// }

void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // call decrease_reference_cnt() retroactively until the reference counter becomes --->>> 0
  if (decrease_reference_cnt((uint64) pa)) { 
    return;
  }

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

// The sequence of instructions between acquire and release is often called a critical section.
// The lock is typically said to be protecting list.

  acquire(&kmem.lock);  // unlock
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);  // lock 
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
// void *
// kalloc(void)
// {
//   struct run *r;

//   acquire(&kmem.lock);
//   r = kmem.freelist;
//   if(r)
//     kmem.freelist = r->next;
//   release(&kmem.lock);

//   if(r)
//     memset((char*)r, 5, PGSIZE); // fill with junk
//   return (void*)r;
// }

void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock); // unlock
  // critical section
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  release(&kmem.lock); // lock

  if(reference_cnt(((uint64)r))==0){   // current page -->> if reference counter = 0
    increase_reference_cnt((uint64)r); // initialize page reference counter equal with 1 
  }
  

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}