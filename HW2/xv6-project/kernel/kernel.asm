
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	86013103          	ld	sp,-1952(sp) # 80008860 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	0ad050ef          	jal	ra,800058c2 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
//   release(&kmem.lock);
// }

void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	e79d                	bnez	a5,8000005a <kfree+0x3e>
    8000002e:	84aa                	mv	s1,a0
    80000030:	00126797          	auipc	a5,0x126
    80000034:	21078793          	addi	a5,a5,528 # 80126240 <end>
    80000038:	02f56163          	bltu	a0,a5,8000005a <kfree+0x3e>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	00f57d63          	bgeu	a0,a5,8000005a <kfree+0x3e>
    panic("kfree");

  // call decrease_reference_cnt() retroactively until the reference counter becomes --->>> 0
  if (decrease_reference_cnt((uint64) pa)) { 
    80000044:	00005097          	auipc	ra,0x5
    80000048:	756080e7          	jalr	1878(ra) # 8000579a <decrease_reference_cnt>
    8000004c:	cd19                	beqz	a0,8000006a <kfree+0x4e>

  acquire(&kmem.lock);  // unlock
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);  // lock 
}
    8000004e:	60e2                	ld	ra,24(sp)
    80000050:	6442                	ld	s0,16(sp)
    80000052:	64a2                	ld	s1,8(sp)
    80000054:	6902                	ld	s2,0(sp)
    80000056:	6105                	addi	sp,sp,32
    80000058:	8082                	ret
    panic("kfree");
    8000005a:	00008517          	auipc	a0,0x8
    8000005e:	fb650513          	addi	a0,a0,-74 # 80008010 <etext+0x10>
    80000062:	00006097          	auipc	ra,0x6
    80000066:	d10080e7          	jalr	-752(ra) # 80005d72 <panic>
  memset(pa, 1, PGSIZE);
    8000006a:	6605                	lui	a2,0x1
    8000006c:	4585                	li	a1,1
    8000006e:	8526                	mv	a0,s1
    80000070:	00000097          	auipc	ra,0x0
    80000074:	150080e7          	jalr	336(ra) # 800001c0 <memset>
  acquire(&kmem.lock);  // unlock
    80000078:	00009917          	auipc	s2,0x9
    8000007c:	fb890913          	addi	s2,s2,-72 # 80009030 <kmem>
    80000080:	854a                	mv	a0,s2
    80000082:	00006097          	auipc	ra,0x6
    80000086:	23a080e7          	jalr	570(ra) # 800062bc <acquire>
  r->next = kmem.freelist;
    8000008a:	01893783          	ld	a5,24(s2)
    8000008e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000090:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);  // lock 
    80000094:	854a                	mv	a0,s2
    80000096:	00006097          	auipc	ra,0x6
    8000009a:	2da080e7          	jalr	730(ra) # 80006370 <release>
    8000009e:	bf45                	j	8000004e <kfree+0x32>

00000000800000a0 <freerange>:
{
    800000a0:	7179                	addi	sp,sp,-48
    800000a2:	f406                	sd	ra,40(sp)
    800000a4:	f022                	sd	s0,32(sp)
    800000a6:	ec26                	sd	s1,24(sp)
    800000a8:	e84a                	sd	s2,16(sp)
    800000aa:	e44e                	sd	s3,8(sp)
    800000ac:	e052                	sd	s4,0(sp)
    800000ae:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800000b0:	6785                	lui	a5,0x1
    800000b2:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800000b6:	9526                	add	a0,a0,s1
    800000b8:	74fd                	lui	s1,0xfffff
    800000ba:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    800000bc:	97a6                	add	a5,a5,s1
    800000be:	02f5e463          	bltu	a1,a5,800000e6 <freerange+0x46>
    800000c2:	892e                	mv	s2,a1
    800000c4:	6a05                	lui	s4,0x1
    800000c6:	6989                	lui	s3,0x2
      increase_reference_cnt((uint64)p); // iniatialize reference counter equal with -->> 1 
    800000c8:	8526                	mv	a0,s1
    800000ca:	00005097          	auipc	ra,0x5
    800000ce:	67c080e7          	jalr	1660(ra) # 80005746 <increase_reference_cnt>
      kfree(p);
    800000d2:	8526                	mv	a0,s1
    800000d4:	00000097          	auipc	ra,0x0
    800000d8:	f48080e7          	jalr	-184(ra) # 8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    800000dc:	87a6                	mv	a5,s1
    800000de:	94d2                	add	s1,s1,s4
    800000e0:	97ce                	add	a5,a5,s3
    800000e2:	fef973e3          	bgeu	s2,a5,800000c8 <freerange+0x28>
}
    800000e6:	70a2                	ld	ra,40(sp)
    800000e8:	7402                	ld	s0,32(sp)
    800000ea:	64e2                	ld	s1,24(sp)
    800000ec:	6942                	ld	s2,16(sp)
    800000ee:	69a2                	ld	s3,8(sp)
    800000f0:	6a02                	ld	s4,0(sp)
    800000f2:	6145                	addi	sp,sp,48
    800000f4:	8082                	ret

00000000800000f6 <kinit>:
{
    800000f6:	1141                	addi	sp,sp,-16
    800000f8:	e406                	sd	ra,8(sp)
    800000fa:	e022                	sd	s0,0(sp)
    800000fc:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800000fe:	00008597          	auipc	a1,0x8
    80000102:	f1a58593          	addi	a1,a1,-230 # 80008018 <etext+0x18>
    80000106:	00009517          	auipc	a0,0x9
    8000010a:	f2a50513          	addi	a0,a0,-214 # 80009030 <kmem>
    8000010e:	00006097          	auipc	ra,0x6
    80000112:	11e080e7          	jalr	286(ra) # 8000622c <initlock>
  freerange(end, (void*)PHYSTOP);
    80000116:	45c5                	li	a1,17
    80000118:	05ee                	slli	a1,a1,0x1b
    8000011a:	00126517          	auipc	a0,0x126
    8000011e:	12650513          	addi	a0,a0,294 # 80126240 <end>
    80000122:	00000097          	auipc	ra,0x0
    80000126:	f7e080e7          	jalr	-130(ra) # 800000a0 <freerange>
}
    8000012a:	60a2                	ld	ra,8(sp)
    8000012c:	6402                	ld	s0,0(sp)
    8000012e:	0141                	addi	sp,sp,16
    80000130:	8082                	ret

0000000080000132 <kalloc>:
//   return (void*)r;
// }

void *
kalloc(void)
{
    80000132:	1101                	addi	sp,sp,-32
    80000134:	ec06                	sd	ra,24(sp)
    80000136:	e822                	sd	s0,16(sp)
    80000138:	e426                	sd	s1,8(sp)
    8000013a:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock); // unlock
    8000013c:	00009497          	auipc	s1,0x9
    80000140:	ef448493          	addi	s1,s1,-268 # 80009030 <kmem>
    80000144:	8526                	mv	a0,s1
    80000146:	00006097          	auipc	ra,0x6
    8000014a:	176080e7          	jalr	374(ra) # 800062bc <acquire>
  // critical section
  r = kmem.freelist;
    8000014e:	6c84                	ld	s1,24(s1)
  if(r)
    80000150:	cc95                	beqz	s1,8000018c <kalloc+0x5a>
    kmem.freelist = r->next;
    80000152:	609c                	ld	a5,0(s1)
    80000154:	00009517          	auipc	a0,0x9
    80000158:	edc50513          	addi	a0,a0,-292 # 80009030 <kmem>
    8000015c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock); // lock
    8000015e:	00006097          	auipc	ra,0x6
    80000162:	212080e7          	jalr	530(ra) # 80006370 <release>

  if(reference_cnt(((uint64)r))==0){   // current page -->> if reference counter = 0
    80000166:	8526                	mv	a0,s1
    80000168:	00005097          	auipc	ra,0x5
    8000016c:	692080e7          	jalr	1682(ra) # 800057fa <reference_cnt>
    80000170:	c131                	beqz	a0,800001b4 <kalloc+0x82>
    increase_reference_cnt((uint64)r); // initialize page reference counter equal with 1 
  }
  

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000172:	6605                	lui	a2,0x1
    80000174:	4595                	li	a1,5
    80000176:	8526                	mv	a0,s1
    80000178:	00000097          	auipc	ra,0x0
    8000017c:	048080e7          	jalr	72(ra) # 800001c0 <memset>
  return (void*)r;
}
    80000180:	8526                	mv	a0,s1
    80000182:	60e2                	ld	ra,24(sp)
    80000184:	6442                	ld	s0,16(sp)
    80000186:	64a2                	ld	s1,8(sp)
    80000188:	6105                	addi	sp,sp,32
    8000018a:	8082                	ret
  release(&kmem.lock); // lock
    8000018c:	00009517          	auipc	a0,0x9
    80000190:	ea450513          	addi	a0,a0,-348 # 80009030 <kmem>
    80000194:	00006097          	auipc	ra,0x6
    80000198:	1dc080e7          	jalr	476(ra) # 80006370 <release>
  if(reference_cnt(((uint64)r))==0){   // current page -->> if reference counter = 0
    8000019c:	4501                	li	a0,0
    8000019e:	00005097          	auipc	ra,0x5
    800001a2:	65c080e7          	jalr	1628(ra) # 800057fa <reference_cnt>
    800001a6:	fd69                	bnez	a0,80000180 <kalloc+0x4e>
    increase_reference_cnt((uint64)r); // initialize page reference counter equal with 1 
    800001a8:	4501                	li	a0,0
    800001aa:	00005097          	auipc	ra,0x5
    800001ae:	59c080e7          	jalr	1436(ra) # 80005746 <increase_reference_cnt>
  if(r)
    800001b2:	b7f9                	j	80000180 <kalloc+0x4e>
    increase_reference_cnt((uint64)r); // initialize page reference counter equal with 1 
    800001b4:	8526                	mv	a0,s1
    800001b6:	00005097          	auipc	ra,0x5
    800001ba:	590080e7          	jalr	1424(ra) # 80005746 <increase_reference_cnt>
  if(r)
    800001be:	bf55                	j	80000172 <kalloc+0x40>

00000000800001c0 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    800001c0:	1141                	addi	sp,sp,-16
    800001c2:	e422                	sd	s0,8(sp)
    800001c4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800001c6:	ce09                	beqz	a2,800001e0 <memset+0x20>
    800001c8:	87aa                	mv	a5,a0
    800001ca:	fff6071b          	addiw	a4,a2,-1
    800001ce:	1702                	slli	a4,a4,0x20
    800001d0:	9301                	srli	a4,a4,0x20
    800001d2:	0705                	addi	a4,a4,1
    800001d4:	972a                	add	a4,a4,a0
    cdst[i] = c;
    800001d6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800001da:	0785                	addi	a5,a5,1
    800001dc:	fee79de3          	bne	a5,a4,800001d6 <memset+0x16>
  }
  return dst;
}
    800001e0:	6422                	ld	s0,8(sp)
    800001e2:	0141                	addi	sp,sp,16
    800001e4:	8082                	ret

00000000800001e6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800001e6:	1141                	addi	sp,sp,-16
    800001e8:	e422                	sd	s0,8(sp)
    800001ea:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800001ec:	ca05                	beqz	a2,8000021c <memcmp+0x36>
    800001ee:	fff6069b          	addiw	a3,a2,-1
    800001f2:	1682                	slli	a3,a3,0x20
    800001f4:	9281                	srli	a3,a3,0x20
    800001f6:	0685                	addi	a3,a3,1
    800001f8:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800001fa:	00054783          	lbu	a5,0(a0)
    800001fe:	0005c703          	lbu	a4,0(a1)
    80000202:	00e79863          	bne	a5,a4,80000212 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000206:	0505                	addi	a0,a0,1
    80000208:	0585                	addi	a1,a1,1
  while(n-- > 0){
    8000020a:	fed518e3          	bne	a0,a3,800001fa <memcmp+0x14>
  }

  return 0;
    8000020e:	4501                	li	a0,0
    80000210:	a019                	j	80000216 <memcmp+0x30>
      return *s1 - *s2;
    80000212:	40e7853b          	subw	a0,a5,a4
}
    80000216:	6422                	ld	s0,8(sp)
    80000218:	0141                	addi	sp,sp,16
    8000021a:	8082                	ret
  return 0;
    8000021c:	4501                	li	a0,0
    8000021e:	bfe5                	j	80000216 <memcmp+0x30>

0000000080000220 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000220:	1141                	addi	sp,sp,-16
    80000222:	e422                	sd	s0,8(sp)
    80000224:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000226:	ca0d                	beqz	a2,80000258 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000228:	00a5f963          	bgeu	a1,a0,8000023a <memmove+0x1a>
    8000022c:	02061693          	slli	a3,a2,0x20
    80000230:	9281                	srli	a3,a3,0x20
    80000232:	00d58733          	add	a4,a1,a3
    80000236:	02e56463          	bltu	a0,a4,8000025e <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000023a:	fff6079b          	addiw	a5,a2,-1
    8000023e:	1782                	slli	a5,a5,0x20
    80000240:	9381                	srli	a5,a5,0x20
    80000242:	0785                	addi	a5,a5,1
    80000244:	97ae                	add	a5,a5,a1
    80000246:	872a                	mv	a4,a0
      *d++ = *s++;
    80000248:	0585                	addi	a1,a1,1
    8000024a:	0705                	addi	a4,a4,1
    8000024c:	fff5c683          	lbu	a3,-1(a1)
    80000250:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000254:	fef59ae3          	bne	a1,a5,80000248 <memmove+0x28>

  return dst;
}
    80000258:	6422                	ld	s0,8(sp)
    8000025a:	0141                	addi	sp,sp,16
    8000025c:	8082                	ret
    d += n;
    8000025e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000260:	fff6079b          	addiw	a5,a2,-1
    80000264:	1782                	slli	a5,a5,0x20
    80000266:	9381                	srli	a5,a5,0x20
    80000268:	fff7c793          	not	a5,a5
    8000026c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    8000026e:	177d                	addi	a4,a4,-1
    80000270:	16fd                	addi	a3,a3,-1
    80000272:	00074603          	lbu	a2,0(a4)
    80000276:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    8000027a:	fef71ae3          	bne	a4,a5,8000026e <memmove+0x4e>
    8000027e:	bfe9                	j	80000258 <memmove+0x38>

0000000080000280 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000280:	1141                	addi	sp,sp,-16
    80000282:	e406                	sd	ra,8(sp)
    80000284:	e022                	sd	s0,0(sp)
    80000286:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	f98080e7          	jalr	-104(ra) # 80000220 <memmove>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	addi	sp,sp,16
    80000296:	8082                	ret

0000000080000298 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000298:	1141                	addi	sp,sp,-16
    8000029a:	e422                	sd	s0,8(sp)
    8000029c:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    8000029e:	ce11                	beqz	a2,800002ba <strncmp+0x22>
    800002a0:	00054783          	lbu	a5,0(a0)
    800002a4:	cf89                	beqz	a5,800002be <strncmp+0x26>
    800002a6:	0005c703          	lbu	a4,0(a1)
    800002aa:	00f71a63          	bne	a4,a5,800002be <strncmp+0x26>
    n--, p++, q++;
    800002ae:	367d                	addiw	a2,a2,-1
    800002b0:	0505                	addi	a0,a0,1
    800002b2:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    800002b4:	f675                	bnez	a2,800002a0 <strncmp+0x8>
  if(n == 0)
    return 0;
    800002b6:	4501                	li	a0,0
    800002b8:	a809                	j	800002ca <strncmp+0x32>
    800002ba:	4501                	li	a0,0
    800002bc:	a039                	j	800002ca <strncmp+0x32>
  if(n == 0)
    800002be:	ca09                	beqz	a2,800002d0 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    800002c0:	00054503          	lbu	a0,0(a0)
    800002c4:	0005c783          	lbu	a5,0(a1)
    800002c8:	9d1d                	subw	a0,a0,a5
}
    800002ca:	6422                	ld	s0,8(sp)
    800002cc:	0141                	addi	sp,sp,16
    800002ce:	8082                	ret
    return 0;
    800002d0:	4501                	li	a0,0
    800002d2:	bfe5                	j	800002ca <strncmp+0x32>

00000000800002d4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800002d4:	1141                	addi	sp,sp,-16
    800002d6:	e422                	sd	s0,8(sp)
    800002d8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800002da:	872a                	mv	a4,a0
    800002dc:	8832                	mv	a6,a2
    800002de:	367d                	addiw	a2,a2,-1
    800002e0:	01005963          	blez	a6,800002f2 <strncpy+0x1e>
    800002e4:	0705                	addi	a4,a4,1
    800002e6:	0005c783          	lbu	a5,0(a1)
    800002ea:	fef70fa3          	sb	a5,-1(a4)
    800002ee:	0585                	addi	a1,a1,1
    800002f0:	f7f5                	bnez	a5,800002dc <strncpy+0x8>
    ;
  while(n-- > 0)
    800002f2:	00c05d63          	blez	a2,8000030c <strncpy+0x38>
    800002f6:	86ba                	mv	a3,a4
    *s++ = 0;
    800002f8:	0685                	addi	a3,a3,1
    800002fa:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800002fe:	fff6c793          	not	a5,a3
    80000302:	9fb9                	addw	a5,a5,a4
    80000304:	010787bb          	addw	a5,a5,a6
    80000308:	fef048e3          	bgtz	a5,800002f8 <strncpy+0x24>
  return os;
}
    8000030c:	6422                	ld	s0,8(sp)
    8000030e:	0141                	addi	sp,sp,16
    80000310:	8082                	ret

0000000080000312 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000312:	1141                	addi	sp,sp,-16
    80000314:	e422                	sd	s0,8(sp)
    80000316:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000318:	02c05363          	blez	a2,8000033e <safestrcpy+0x2c>
    8000031c:	fff6069b          	addiw	a3,a2,-1
    80000320:	1682                	slli	a3,a3,0x20
    80000322:	9281                	srli	a3,a3,0x20
    80000324:	96ae                	add	a3,a3,a1
    80000326:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000328:	00d58963          	beq	a1,a3,8000033a <safestrcpy+0x28>
    8000032c:	0585                	addi	a1,a1,1
    8000032e:	0785                	addi	a5,a5,1
    80000330:	fff5c703          	lbu	a4,-1(a1)
    80000334:	fee78fa3          	sb	a4,-1(a5)
    80000338:	fb65                	bnez	a4,80000328 <safestrcpy+0x16>
    ;
  *s = 0;
    8000033a:	00078023          	sb	zero,0(a5)
  return os;
}
    8000033e:	6422                	ld	s0,8(sp)
    80000340:	0141                	addi	sp,sp,16
    80000342:	8082                	ret

0000000080000344 <strlen>:

int
strlen(const char *s)
{
    80000344:	1141                	addi	sp,sp,-16
    80000346:	e422                	sd	s0,8(sp)
    80000348:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    8000034a:	00054783          	lbu	a5,0(a0)
    8000034e:	cf91                	beqz	a5,8000036a <strlen+0x26>
    80000350:	0505                	addi	a0,a0,1
    80000352:	87aa                	mv	a5,a0
    80000354:	4685                	li	a3,1
    80000356:	9e89                	subw	a3,a3,a0
    80000358:	00f6853b          	addw	a0,a3,a5
    8000035c:	0785                	addi	a5,a5,1
    8000035e:	fff7c703          	lbu	a4,-1(a5)
    80000362:	fb7d                	bnez	a4,80000358 <strlen+0x14>
    ;
  return n;
}
    80000364:	6422                	ld	s0,8(sp)
    80000366:	0141                	addi	sp,sp,16
    80000368:	8082                	ret
  for(n = 0; s[n]; n++)
    8000036a:	4501                	li	a0,0
    8000036c:	bfe5                	j	80000364 <strlen+0x20>

000000008000036e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    8000036e:	1141                	addi	sp,sp,-16
    80000370:	e406                	sd	ra,8(sp)
    80000372:	e022                	sd	s0,0(sp)
    80000374:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000376:	00001097          	auipc	ra,0x1
    8000037a:	bae080e7          	jalr	-1106(ra) # 80000f24 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000037e:	00009717          	auipc	a4,0x9
    80000382:	c8270713          	addi	a4,a4,-894 # 80009000 <started>
  if(cpuid() == 0){
    80000386:	c139                	beqz	a0,800003cc <main+0x5e>
    while(started == 0)
    80000388:	431c                	lw	a5,0(a4)
    8000038a:	2781                	sext.w	a5,a5
    8000038c:	dff5                	beqz	a5,80000388 <main+0x1a>
      ;
    __sync_synchronize();
    8000038e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000392:	00001097          	auipc	ra,0x1
    80000396:	b92080e7          	jalr	-1134(ra) # 80000f24 <cpuid>
    8000039a:	85aa                	mv	a1,a0
    8000039c:	00008517          	auipc	a0,0x8
    800003a0:	c9c50513          	addi	a0,a0,-868 # 80008038 <etext+0x38>
    800003a4:	00006097          	auipc	ra,0x6
    800003a8:	a18080e7          	jalr	-1512(ra) # 80005dbc <printf>
    kvminithart();    // turn on paging
    800003ac:	00000097          	auipc	ra,0x0
    800003b0:	0d8080e7          	jalr	216(ra) # 80000484 <kvminithart>
    trapinithart();   // install kernel trap vector
    800003b4:	00001097          	auipc	ra,0x1
    800003b8:	7e8080e7          	jalr	2024(ra) # 80001b9c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800003bc:	00005097          	auipc	ra,0x5
    800003c0:	d84080e7          	jalr	-636(ra) # 80005140 <plicinithart>
  }

  scheduler();        
    800003c4:	00001097          	auipc	ra,0x1
    800003c8:	096080e7          	jalr	150(ra) # 8000145a <scheduler>
    consoleinit();
    800003cc:	00006097          	auipc	ra,0x6
    800003d0:	8b8080e7          	jalr	-1864(ra) # 80005c84 <consoleinit>
    printfinit();
    800003d4:	00006097          	auipc	ra,0x6
    800003d8:	bce080e7          	jalr	-1074(ra) # 80005fa2 <printfinit>
    printf("\n");
    800003dc:	00008517          	auipc	a0,0x8
    800003e0:	c6c50513          	addi	a0,a0,-916 # 80008048 <etext+0x48>
    800003e4:	00006097          	auipc	ra,0x6
    800003e8:	9d8080e7          	jalr	-1576(ra) # 80005dbc <printf>
    printf("xv6 kernel is booting\n");
    800003ec:	00008517          	auipc	a0,0x8
    800003f0:	c3450513          	addi	a0,a0,-972 # 80008020 <etext+0x20>
    800003f4:	00006097          	auipc	ra,0x6
    800003f8:	9c8080e7          	jalr	-1592(ra) # 80005dbc <printf>
    printf("\n");
    800003fc:	00008517          	auipc	a0,0x8
    80000400:	c4c50513          	addi	a0,a0,-948 # 80008048 <etext+0x48>
    80000404:	00006097          	auipc	ra,0x6
    80000408:	9b8080e7          	jalr	-1608(ra) # 80005dbc <printf>
    kinit();         // physical page allocator
    8000040c:	00000097          	auipc	ra,0x0
    80000410:	cea080e7          	jalr	-790(ra) # 800000f6 <kinit>
    kvminit();       // create kernel page table
    80000414:	00000097          	auipc	ra,0x0
    80000418:	322080e7          	jalr	802(ra) # 80000736 <kvminit>
    kvminithart();   // turn on paging
    8000041c:	00000097          	auipc	ra,0x0
    80000420:	068080e7          	jalr	104(ra) # 80000484 <kvminithart>
    procinit();      // process table
    80000424:	00001097          	auipc	ra,0x1
    80000428:	a50080e7          	jalr	-1456(ra) # 80000e74 <procinit>
    trapinit();      // trap vectors
    8000042c:	00001097          	auipc	ra,0x1
    80000430:	748080e7          	jalr	1864(ra) # 80001b74 <trapinit>
    trapinithart();  // install kernel trap vector
    80000434:	00001097          	auipc	ra,0x1
    80000438:	768080e7          	jalr	1896(ra) # 80001b9c <trapinithart>
    plicinit();      // set up interrupt controller
    8000043c:	00005097          	auipc	ra,0x5
    80000440:	cee080e7          	jalr	-786(ra) # 8000512a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000444:	00005097          	auipc	ra,0x5
    80000448:	cfc080e7          	jalr	-772(ra) # 80005140 <plicinithart>
    binit();         // buffer cache
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	ee2080e7          	jalr	-286(ra) # 8000232e <binit>
    iinit();         // inode table
    80000454:	00002097          	auipc	ra,0x2
    80000458:	572080e7          	jalr	1394(ra) # 800029c6 <iinit>
    fileinit();      // file table
    8000045c:	00003097          	auipc	ra,0x3
    80000460:	51c080e7          	jalr	1308(ra) # 80003978 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000464:	00005097          	auipc	ra,0x5
    80000468:	dfe080e7          	jalr	-514(ra) # 80005262 <virtio_disk_init>
    userinit();      // first user process
    8000046c:	00001097          	auipc	ra,0x1
    80000470:	dbc080e7          	jalr	-580(ra) # 80001228 <userinit>
    __sync_synchronize();
    80000474:	0ff0000f          	fence
    started = 1;
    80000478:	4785                	li	a5,1
    8000047a:	00009717          	auipc	a4,0x9
    8000047e:	b8f72323          	sw	a5,-1146(a4) # 80009000 <started>
    80000482:	b789                	j	800003c4 <main+0x56>

0000000080000484 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000484:	1141                	addi	sp,sp,-16
    80000486:	e422                	sd	s0,8(sp)
    80000488:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000048a:	00009797          	auipc	a5,0x9
    8000048e:	b7e7b783          	ld	a5,-1154(a5) # 80009008 <kernel_pagetable>
    80000492:	83b1                	srli	a5,a5,0xc
    80000494:	577d                	li	a4,-1
    80000496:	177e                	slli	a4,a4,0x3f
    80000498:	8fd9                	or	a5,a5,a4
// supervisor address translation and protection;
// holds the address of the page table.
static inline void 
w_satp(uint64 x)
{
  asm volatile("csrw satp, %0" : : "r" (x));
    8000049a:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000049e:	12000073          	sfence.vma
  sfence_vma();
}
    800004a2:	6422                	ld	s0,8(sp)
    800004a4:	0141                	addi	sp,sp,16
    800004a6:	8082                	ret

00000000800004a8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800004a8:	7139                	addi	sp,sp,-64
    800004aa:	fc06                	sd	ra,56(sp)
    800004ac:	f822                	sd	s0,48(sp)
    800004ae:	f426                	sd	s1,40(sp)
    800004b0:	f04a                	sd	s2,32(sp)
    800004b2:	ec4e                	sd	s3,24(sp)
    800004b4:	e852                	sd	s4,16(sp)
    800004b6:	e456                	sd	s5,8(sp)
    800004b8:	e05a                	sd	s6,0(sp)
    800004ba:	0080                	addi	s0,sp,64
    800004bc:	84aa                	mv	s1,a0
    800004be:	89ae                	mv	s3,a1
    800004c0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800004c2:	57fd                	li	a5,-1
    800004c4:	83e9                	srli	a5,a5,0x1a
    800004c6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800004c8:	4b31                	li	s6,12
  if(va >= MAXVA)
    800004ca:	04b7f263          	bgeu	a5,a1,8000050e <walk+0x66>
    panic("walk");
    800004ce:	00008517          	auipc	a0,0x8
    800004d2:	b8250513          	addi	a0,a0,-1150 # 80008050 <etext+0x50>
    800004d6:	00006097          	auipc	ra,0x6
    800004da:	89c080e7          	jalr	-1892(ra) # 80005d72 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800004de:	060a8663          	beqz	s5,8000054a <walk+0xa2>
    800004e2:	00000097          	auipc	ra,0x0
    800004e6:	c50080e7          	jalr	-944(ra) # 80000132 <kalloc>
    800004ea:	84aa                	mv	s1,a0
    800004ec:	c529                	beqz	a0,80000536 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800004ee:	6605                	lui	a2,0x1
    800004f0:	4581                	li	a1,0
    800004f2:	00000097          	auipc	ra,0x0
    800004f6:	cce080e7          	jalr	-818(ra) # 800001c0 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800004fa:	00c4d793          	srli	a5,s1,0xc
    800004fe:	07aa                	slli	a5,a5,0xa
    80000500:	0017e793          	ori	a5,a5,1
    80000504:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000508:	3a5d                	addiw	s4,s4,-9
    8000050a:	036a0063          	beq	s4,s6,8000052a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000050e:	0149d933          	srl	s2,s3,s4
    80000512:	1ff97913          	andi	s2,s2,511
    80000516:	090e                	slli	s2,s2,0x3
    80000518:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000051a:	00093483          	ld	s1,0(s2)
    8000051e:	0014f793          	andi	a5,s1,1
    80000522:	dfd5                	beqz	a5,800004de <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000524:	80a9                	srli	s1,s1,0xa
    80000526:	04b2                	slli	s1,s1,0xc
    80000528:	b7c5                	j	80000508 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000052a:	00c9d513          	srli	a0,s3,0xc
    8000052e:	1ff57513          	andi	a0,a0,511
    80000532:	050e                	slli	a0,a0,0x3
    80000534:	9526                	add	a0,a0,s1
}
    80000536:	70e2                	ld	ra,56(sp)
    80000538:	7442                	ld	s0,48(sp)
    8000053a:	74a2                	ld	s1,40(sp)
    8000053c:	7902                	ld	s2,32(sp)
    8000053e:	69e2                	ld	s3,24(sp)
    80000540:	6a42                	ld	s4,16(sp)
    80000542:	6aa2                	ld	s5,8(sp)
    80000544:	6b02                	ld	s6,0(sp)
    80000546:	6121                	addi	sp,sp,64
    80000548:	8082                	ret
        return 0;
    8000054a:	4501                	li	a0,0
    8000054c:	b7ed                	j	80000536 <walk+0x8e>

000000008000054e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA){ 
    8000054e:	57fd                	li	a5,-1
    80000550:	83e9                	srli	a5,a5,0x1a
    80000552:	00b7f463          	bgeu	a5,a1,8000055a <walkaddr+0xc>
    return 0; 
    80000556:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000558:	8082                	ret
{
    8000055a:	1141                	addi	sp,sp,-16
    8000055c:	e406                	sd	ra,8(sp)
    8000055e:	e022                	sd	s0,0(sp)
    80000560:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000562:	4601                	li	a2,0
    80000564:	00000097          	auipc	ra,0x0
    80000568:	f44080e7          	jalr	-188(ra) # 800004a8 <walk>
  if(pte == 0)
    8000056c:	c105                	beqz	a0,8000058c <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000056e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000570:	0117f693          	andi	a3,a5,17
    80000574:	4745                	li	a4,17
    return 0;
    80000576:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000578:	00e68663          	beq	a3,a4,80000584 <walkaddr+0x36>
}
    8000057c:	60a2                	ld	ra,8(sp)
    8000057e:	6402                	ld	s0,0(sp)
    80000580:	0141                	addi	sp,sp,16
    80000582:	8082                	ret
  pa = PTE2PA(*pte);
    80000584:	00a7d513          	srli	a0,a5,0xa
    80000588:	0532                	slli	a0,a0,0xc
  return pa;
    8000058a:	bfcd                	j	8000057c <walkaddr+0x2e>
    return 0;
    8000058c:	4501                	li	a0,0
    8000058e:	b7fd                	j	8000057c <walkaddr+0x2e>

0000000080000590 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000590:	715d                	addi	sp,sp,-80
    80000592:	e486                	sd	ra,72(sp)
    80000594:	e0a2                	sd	s0,64(sp)
    80000596:	fc26                	sd	s1,56(sp)
    80000598:	f84a                	sd	s2,48(sp)
    8000059a:	f44e                	sd	s3,40(sp)
    8000059c:	f052                	sd	s4,32(sp)
    8000059e:	ec56                	sd	s5,24(sp)
    800005a0:	e85a                	sd	s6,16(sp)
    800005a2:	e45e                	sd	s7,8(sp)
    800005a4:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800005a6:	c205                	beqz	a2,800005c6 <mappages+0x36>
    800005a8:	8aaa                	mv	s5,a0
    800005aa:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800005ac:	77fd                	lui	a5,0xfffff
    800005ae:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800005b2:	15fd                	addi	a1,a1,-1
    800005b4:	00c589b3          	add	s3,a1,a2
    800005b8:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800005bc:	8952                	mv	s2,s4
    800005be:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800005c2:	6b85                	lui	s7,0x1
    800005c4:	a015                	j	800005e8 <mappages+0x58>
    panic("mappages: size");
    800005c6:	00008517          	auipc	a0,0x8
    800005ca:	a9250513          	addi	a0,a0,-1390 # 80008058 <etext+0x58>
    800005ce:	00005097          	auipc	ra,0x5
    800005d2:	7a4080e7          	jalr	1956(ra) # 80005d72 <panic>
      panic("mappages: remap");
    800005d6:	00008517          	auipc	a0,0x8
    800005da:	a9250513          	addi	a0,a0,-1390 # 80008068 <etext+0x68>
    800005de:	00005097          	auipc	ra,0x5
    800005e2:	794080e7          	jalr	1940(ra) # 80005d72 <panic>
    a += PGSIZE;
    800005e6:	995e                	add	s2,s2,s7
  for(;;){
    800005e8:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800005ec:	4605                	li	a2,1
    800005ee:	85ca                	mv	a1,s2
    800005f0:	8556                	mv	a0,s5
    800005f2:	00000097          	auipc	ra,0x0
    800005f6:	eb6080e7          	jalr	-330(ra) # 800004a8 <walk>
    800005fa:	cd19                	beqz	a0,80000618 <mappages+0x88>
    if(*pte & PTE_V)
    800005fc:	611c                	ld	a5,0(a0)
    800005fe:	8b85                	andi	a5,a5,1
    80000600:	fbf9                	bnez	a5,800005d6 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80000602:	80b1                	srli	s1,s1,0xc
    80000604:	04aa                	slli	s1,s1,0xa
    80000606:	0164e4b3          	or	s1,s1,s6
    8000060a:	0014e493          	ori	s1,s1,1
    8000060e:	e104                	sd	s1,0(a0)
    if(a == last)
    80000610:	fd391be3          	bne	s2,s3,800005e6 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    80000614:	4501                	li	a0,0
    80000616:	a011                	j	8000061a <mappages+0x8a>
      return -1;
    80000618:	557d                	li	a0,-1
}
    8000061a:	60a6                	ld	ra,72(sp)
    8000061c:	6406                	ld	s0,64(sp)
    8000061e:	74e2                	ld	s1,56(sp)
    80000620:	7942                	ld	s2,48(sp)
    80000622:	79a2                	ld	s3,40(sp)
    80000624:	7a02                	ld	s4,32(sp)
    80000626:	6ae2                	ld	s5,24(sp)
    80000628:	6b42                	ld	s6,16(sp)
    8000062a:	6ba2                	ld	s7,8(sp)
    8000062c:	6161                	addi	sp,sp,80
    8000062e:	8082                	ret

0000000080000630 <kvmmap>:
{
    80000630:	1141                	addi	sp,sp,-16
    80000632:	e406                	sd	ra,8(sp)
    80000634:	e022                	sd	s0,0(sp)
    80000636:	0800                	addi	s0,sp,16
    80000638:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000063a:	86b2                	mv	a3,a2
    8000063c:	863e                	mv	a2,a5
    8000063e:	00000097          	auipc	ra,0x0
    80000642:	f52080e7          	jalr	-174(ra) # 80000590 <mappages>
    80000646:	e509                	bnez	a0,80000650 <kvmmap+0x20>
}
    80000648:	60a2                	ld	ra,8(sp)
    8000064a:	6402                	ld	s0,0(sp)
    8000064c:	0141                	addi	sp,sp,16
    8000064e:	8082                	ret
    panic("kvmmap");
    80000650:	00008517          	auipc	a0,0x8
    80000654:	a2850513          	addi	a0,a0,-1496 # 80008078 <etext+0x78>
    80000658:	00005097          	auipc	ra,0x5
    8000065c:	71a080e7          	jalr	1818(ra) # 80005d72 <panic>

0000000080000660 <kvmmake>:
{
    80000660:	1101                	addi	sp,sp,-32
    80000662:	ec06                	sd	ra,24(sp)
    80000664:	e822                	sd	s0,16(sp)
    80000666:	e426                	sd	s1,8(sp)
    80000668:	e04a                	sd	s2,0(sp)
    8000066a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	ac6080e7          	jalr	-1338(ra) # 80000132 <kalloc>
    80000674:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000676:	6605                	lui	a2,0x1
    80000678:	4581                	li	a1,0
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	b46080e7          	jalr	-1210(ra) # 800001c0 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80000682:	4719                	li	a4,6
    80000684:	6685                	lui	a3,0x1
    80000686:	10000637          	lui	a2,0x10000
    8000068a:	100005b7          	lui	a1,0x10000
    8000068e:	8526                	mv	a0,s1
    80000690:	00000097          	auipc	ra,0x0
    80000694:	fa0080e7          	jalr	-96(ra) # 80000630 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80000698:	4719                	li	a4,6
    8000069a:	6685                	lui	a3,0x1
    8000069c:	10001637          	lui	a2,0x10001
    800006a0:	100015b7          	lui	a1,0x10001
    800006a4:	8526                	mv	a0,s1
    800006a6:	00000097          	auipc	ra,0x0
    800006aa:	f8a080e7          	jalr	-118(ra) # 80000630 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800006ae:	4719                	li	a4,6
    800006b0:	004006b7          	lui	a3,0x400
    800006b4:	0c000637          	lui	a2,0xc000
    800006b8:	0c0005b7          	lui	a1,0xc000
    800006bc:	8526                	mv	a0,s1
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	f72080e7          	jalr	-142(ra) # 80000630 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800006c6:	00008917          	auipc	s2,0x8
    800006ca:	93a90913          	addi	s2,s2,-1734 # 80008000 <etext>
    800006ce:	4729                	li	a4,10
    800006d0:	80008697          	auipc	a3,0x80008
    800006d4:	93068693          	addi	a3,a3,-1744 # 8000 <_entry-0x7fff8000>
    800006d8:	4605                	li	a2,1
    800006da:	067e                	slli	a2,a2,0x1f
    800006dc:	85b2                	mv	a1,a2
    800006de:	8526                	mv	a0,s1
    800006e0:	00000097          	auipc	ra,0x0
    800006e4:	f50080e7          	jalr	-176(ra) # 80000630 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800006e8:	4719                	li	a4,6
    800006ea:	46c5                	li	a3,17
    800006ec:	06ee                	slli	a3,a3,0x1b
    800006ee:	412686b3          	sub	a3,a3,s2
    800006f2:	864a                	mv	a2,s2
    800006f4:	85ca                	mv	a1,s2
    800006f6:	8526                	mv	a0,s1
    800006f8:	00000097          	auipc	ra,0x0
    800006fc:	f38080e7          	jalr	-200(ra) # 80000630 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80000700:	4729                	li	a4,10
    80000702:	6685                	lui	a3,0x1
    80000704:	00007617          	auipc	a2,0x7
    80000708:	8fc60613          	addi	a2,a2,-1796 # 80007000 <_trampoline>
    8000070c:	040005b7          	lui	a1,0x4000
    80000710:	15fd                	addi	a1,a1,-1
    80000712:	05b2                	slli	a1,a1,0xc
    80000714:	8526                	mv	a0,s1
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	f1a080e7          	jalr	-230(ra) # 80000630 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000071e:	8526                	mv	a0,s1
    80000720:	00000097          	auipc	ra,0x0
    80000724:	6be080e7          	jalr	1726(ra) # 80000dde <proc_mapstacks>
}
    80000728:	8526                	mv	a0,s1
    8000072a:	60e2                	ld	ra,24(sp)
    8000072c:	6442                	ld	s0,16(sp)
    8000072e:	64a2                	ld	s1,8(sp)
    80000730:	6902                	ld	s2,0(sp)
    80000732:	6105                	addi	sp,sp,32
    80000734:	8082                	ret

0000000080000736 <kvminit>:
{
    80000736:	1141                	addi	sp,sp,-16
    80000738:	e406                	sd	ra,8(sp)
    8000073a:	e022                	sd	s0,0(sp)
    8000073c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000073e:	00000097          	auipc	ra,0x0
    80000742:	f22080e7          	jalr	-222(ra) # 80000660 <kvmmake>
    80000746:	00009797          	auipc	a5,0x9
    8000074a:	8ca7b123          	sd	a0,-1854(a5) # 80009008 <kernel_pagetable>
}
    8000074e:	60a2                	ld	ra,8(sp)
    80000750:	6402                	ld	s0,0(sp)
    80000752:	0141                	addi	sp,sp,16
    80000754:	8082                	ret

0000000080000756 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000756:	715d                	addi	sp,sp,-80
    80000758:	e486                	sd	ra,72(sp)
    8000075a:	e0a2                	sd	s0,64(sp)
    8000075c:	fc26                	sd	s1,56(sp)
    8000075e:	f84a                	sd	s2,48(sp)
    80000760:	f44e                	sd	s3,40(sp)
    80000762:	f052                	sd	s4,32(sp)
    80000764:	ec56                	sd	s5,24(sp)
    80000766:	e85a                	sd	s6,16(sp)
    80000768:	e45e                	sd	s7,8(sp)
    8000076a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000076c:	03459793          	slli	a5,a1,0x34
    80000770:	e795                	bnez	a5,8000079c <uvmunmap+0x46>
    80000772:	8a2a                	mv	s4,a0
    80000774:	892e                	mv	s2,a1
    80000776:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000778:	0632                	slli	a2,a2,0xc
    8000077a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000077e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000780:	6b05                	lui	s6,0x1
    80000782:	0735e863          	bltu	a1,s3,800007f2 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80000786:	60a6                	ld	ra,72(sp)
    80000788:	6406                	ld	s0,64(sp)
    8000078a:	74e2                	ld	s1,56(sp)
    8000078c:	7942                	ld	s2,48(sp)
    8000078e:	79a2                	ld	s3,40(sp)
    80000790:	7a02                	ld	s4,32(sp)
    80000792:	6ae2                	ld	s5,24(sp)
    80000794:	6b42                	ld	s6,16(sp)
    80000796:	6ba2                	ld	s7,8(sp)
    80000798:	6161                	addi	sp,sp,80
    8000079a:	8082                	ret
    panic("uvmunmap: not aligned");
    8000079c:	00008517          	auipc	a0,0x8
    800007a0:	8e450513          	addi	a0,a0,-1820 # 80008080 <etext+0x80>
    800007a4:	00005097          	auipc	ra,0x5
    800007a8:	5ce080e7          	jalr	1486(ra) # 80005d72 <panic>
      panic("uvmunmap: walk");
    800007ac:	00008517          	auipc	a0,0x8
    800007b0:	8ec50513          	addi	a0,a0,-1812 # 80008098 <etext+0x98>
    800007b4:	00005097          	auipc	ra,0x5
    800007b8:	5be080e7          	jalr	1470(ra) # 80005d72 <panic>
      panic("uvmunmap: not mapped");
    800007bc:	00008517          	auipc	a0,0x8
    800007c0:	8ec50513          	addi	a0,a0,-1812 # 800080a8 <etext+0xa8>
    800007c4:	00005097          	auipc	ra,0x5
    800007c8:	5ae080e7          	jalr	1454(ra) # 80005d72 <panic>
      panic("uvmunmap: not a leaf");
    800007cc:	00008517          	auipc	a0,0x8
    800007d0:	8f450513          	addi	a0,a0,-1804 # 800080c0 <etext+0xc0>
    800007d4:	00005097          	auipc	ra,0x5
    800007d8:	59e080e7          	jalr	1438(ra) # 80005d72 <panic>
      uint64 pa = PTE2PA(*pte);
    800007dc:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800007de:	0532                	slli	a0,a0,0xc
    800007e0:	00000097          	auipc	ra,0x0
    800007e4:	83c080e7          	jalr	-1988(ra) # 8000001c <kfree>
    *pte = 0;
    800007e8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800007ec:	995a                	add	s2,s2,s6
    800007ee:	f9397ce3          	bgeu	s2,s3,80000786 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800007f2:	4601                	li	a2,0
    800007f4:	85ca                	mv	a1,s2
    800007f6:	8552                	mv	a0,s4
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	cb0080e7          	jalr	-848(ra) # 800004a8 <walk>
    80000800:	84aa                	mv	s1,a0
    80000802:	d54d                	beqz	a0,800007ac <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80000804:	6108                	ld	a0,0(a0)
    80000806:	00157793          	andi	a5,a0,1
    8000080a:	dbcd                	beqz	a5,800007bc <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000080c:	3ff57793          	andi	a5,a0,1023
    80000810:	fb778ee3          	beq	a5,s7,800007cc <uvmunmap+0x76>
    if(do_free){
    80000814:	fc0a8ae3          	beqz	s5,800007e8 <uvmunmap+0x92>
    80000818:	b7d1                	j	800007dc <uvmunmap+0x86>

000000008000081a <cow_f>:
uint64 cow_f(pagetable_t pagetable, uint64 va) {
    8000081a:	7139                	addi	sp,sp,-64
    8000081c:	fc06                	sd	ra,56(sp)
    8000081e:	f822                	sd	s0,48(sp)
    80000820:	f426                	sd	s1,40(sp)
    80000822:	f04a                	sd	s2,32(sp)
    80000824:	ec4e                	sd	s3,24(sp)
    80000826:	e852                	sd	s4,16(sp)
    80000828:	e456                	sd	s5,8(sp)
    8000082a:	e05a                	sd	s6,0(sp)
    8000082c:	0080                	addi	s0,sp,64
  if (va >= MAXVA){ // if virtual address isn't valid  --->> stop! 
    8000082e:	57fd                	li	a5,-1
    80000830:	83e9                	srli	a5,a5,0x1a
    return 0;   // Error
    80000832:	4901                	li	s2,0
  if (va >= MAXVA){ // if virtual address isn't valid  --->> stop! 
    80000834:	00b7fd63          	bgeu	a5,a1,8000084e <cow_f+0x34>
}
    80000838:	854a                	mv	a0,s2
    8000083a:	70e2                	ld	ra,56(sp)
    8000083c:	7442                	ld	s0,48(sp)
    8000083e:	74a2                	ld	s1,40(sp)
    80000840:	7902                	ld	s2,32(sp)
    80000842:	69e2                	ld	s3,24(sp)
    80000844:	6a42                	ld	s4,16(sp)
    80000846:	6aa2                	ld	s5,8(sp)
    80000848:	6b02                	ld	s6,0(sp)
    8000084a:	6121                	addi	sp,sp,64
    8000084c:	8082                	ret
    8000084e:	89aa                	mv	s3,a0
    80000850:	84ae                	mv	s1,a1
  if ((pte = walk(pagetable, va, 0))==0){ // find pte 
    80000852:	4601                	li	a2,0
    80000854:	00000097          	auipc	ra,0x0
    80000858:	c54080e7          	jalr	-940(ra) # 800004a8 <walk>
    8000085c:	8aaa                	mv	s5,a0
    8000085e:	cd25                	beqz	a0,800008d6 <cow_f+0xbc>
  if ((*pte & PTE_V) == 0){  // if pte isn't valid  --->> stop -> error!  
    80000860:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0){  // if pte isn't user level -->> stop -> error! 
    80000862:	0117f693          	andi	a3,a5,17
    80000866:	4745                	li	a4,17
    return 0;
    80000868:	4901                	li	s2,0
  if ((*pte & PTE_U) == 0){  // if pte isn't user level -->> stop -> error! 
    8000086a:	fce697e3          	bne	a3,a4,80000838 <cow_f+0x1e>
  pa = PTE2PA(*pte); 
    8000086e:	00a7d913          	srli	s2,a5,0xa
    80000872:	0932                	slli	s2,s2,0xc
  if ((*pte & PTE_W) == 0) { // we want pte without PTE_W flag  --->>> read only 
    80000874:	0047fa13          	andi	s4,a5,4
    80000878:	fc0a10e3          	bnez	s4,80000838 <cow_f+0x1e>
    if ((*pte & PTE_COW) == 0) { // if PTE_COW flags equal with 0 --->>> stop
    8000087c:	2007f793          	andi	a5,a5,512
    80000880:	e399                	bnez	a5,80000886 <cow_f+0x6c>
        return 0;
    80000882:	893e                	mv	s2,a5
    80000884:	bf55                	j	80000838 <cow_f+0x1e>
    if ((mem = kalloc()) == 0) {
    80000886:	00000097          	auipc	ra,0x0
    8000088a:	8ac080e7          	jalr	-1876(ra) # 80000132 <kalloc>
    8000088e:	8b2a                	mv	s6,a0
    80000890:	c529                	beqz	a0,800008da <cow_f+0xc0>
    memmove(mem, (void*)pa, PGSIZE);  
    80000892:	6605                	lui	a2,0x1
    80000894:	85ca                	mv	a1,s2
    80000896:	00000097          	auipc	ra,0x0
    8000089a:	98a080e7          	jalr	-1654(ra) # 80000220 <memmove>
    flags = PTE_FLAGS(*pte);
    8000089e:	000aba83          	ld	s5,0(s5)
    flags &= (~PTE_COW); // Reset
    800008a2:	1ffafa93          	andi	s5,s5,511
    uvmunmap(pagetable, PGROUNDDOWN(va), 1, 1); // PGROUNDUP is macro to round the address sent to a multiple of the PGSIZE.
    800008a6:	77fd                	lui	a5,0xfffff
    800008a8:	8cfd                	and	s1,s1,a5
    800008aa:	4685                	li	a3,1
    800008ac:	4605                	li	a2,1
    800008ae:	85a6                	mv	a1,s1
    800008b0:	854e                	mv	a0,s3
    800008b2:	00000097          	auipc	ra,0x0
    800008b6:	ea4080e7          	jalr	-348(ra) # 80000756 <uvmunmap>
    if (mappages(pagetable, PGROUNDDOWN(va), PGSIZE, (uint64)mem, flags) != 0) { 
    800008ba:	895a                	mv	s2,s6
    800008bc:	004ae713          	ori	a4,s5,4
    800008c0:	86da                	mv	a3,s6
    800008c2:	6605                	lui	a2,0x1
    800008c4:	85a6                	mv	a1,s1
    800008c6:	854e                	mv	a0,s3
    800008c8:	00000097          	auipc	ra,0x0
    800008cc:	cc8080e7          	jalr	-824(ra) # 80000590 <mappages>
    800008d0:	d525                	beqz	a0,80000838 <cow_f+0x1e>
      return 0;
    800008d2:	8952                	mv	s2,s4
    800008d4:	b795                	j	80000838 <cow_f+0x1e>
      return 0;
    800008d6:	4901                	li	s2,0
    800008d8:	b785                	j	80000838 <cow_f+0x1e>
      return 0;
    800008da:	8952                	mv	s2,s4
    800008dc:	bfb1                	j	80000838 <cow_f+0x1e>

00000000800008de <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800008de:	1101                	addi	sp,sp,-32
    800008e0:	ec06                	sd	ra,24(sp)
    800008e2:	e822                	sd	s0,16(sp)
    800008e4:	e426                	sd	s1,8(sp)
    800008e6:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800008e8:	00000097          	auipc	ra,0x0
    800008ec:	84a080e7          	jalr	-1974(ra) # 80000132 <kalloc>
    800008f0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800008f2:	c519                	beqz	a0,80000900 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800008f4:	6605                	lui	a2,0x1
    800008f6:	4581                	li	a1,0
    800008f8:	00000097          	auipc	ra,0x0
    800008fc:	8c8080e7          	jalr	-1848(ra) # 800001c0 <memset>
  return pagetable;
}
    80000900:	8526                	mv	a0,s1
    80000902:	60e2                	ld	ra,24(sp)
    80000904:	6442                	ld	s0,16(sp)
    80000906:	64a2                	ld	s1,8(sp)
    80000908:	6105                	addi	sp,sp,32
    8000090a:	8082                	ret

000000008000090c <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000090c:	7179                	addi	sp,sp,-48
    8000090e:	f406                	sd	ra,40(sp)
    80000910:	f022                	sd	s0,32(sp)
    80000912:	ec26                	sd	s1,24(sp)
    80000914:	e84a                	sd	s2,16(sp)
    80000916:	e44e                	sd	s3,8(sp)
    80000918:	e052                	sd	s4,0(sp)
    8000091a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000091c:	6785                	lui	a5,0x1
    8000091e:	04f67863          	bgeu	a2,a5,8000096e <uvminit+0x62>
    80000922:	8a2a                	mv	s4,a0
    80000924:	89ae                	mv	s3,a1
    80000926:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80000928:	00000097          	auipc	ra,0x0
    8000092c:	80a080e7          	jalr	-2038(ra) # 80000132 <kalloc>
    80000930:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000932:	6605                	lui	a2,0x1
    80000934:	4581                	li	a1,0
    80000936:	00000097          	auipc	ra,0x0
    8000093a:	88a080e7          	jalr	-1910(ra) # 800001c0 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000093e:	4779                	li	a4,30
    80000940:	86ca                	mv	a3,s2
    80000942:	6605                	lui	a2,0x1
    80000944:	4581                	li	a1,0
    80000946:	8552                	mv	a0,s4
    80000948:	00000097          	auipc	ra,0x0
    8000094c:	c48080e7          	jalr	-952(ra) # 80000590 <mappages>
  memmove(mem, src, sz);
    80000950:	8626                	mv	a2,s1
    80000952:	85ce                	mv	a1,s3
    80000954:	854a                	mv	a0,s2
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	8ca080e7          	jalr	-1846(ra) # 80000220 <memmove>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret
    panic("inituvm: more than a page");
    8000096e:	00007517          	auipc	a0,0x7
    80000972:	76a50513          	addi	a0,a0,1898 # 800080d8 <etext+0xd8>
    80000976:	00005097          	auipc	ra,0x5
    8000097a:	3fc080e7          	jalr	1020(ra) # 80005d72 <panic>

000000008000097e <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000097e:	1101                	addi	sp,sp,-32
    80000980:	ec06                	sd	ra,24(sp)
    80000982:	e822                	sd	s0,16(sp)
    80000984:	e426                	sd	s1,8(sp)
    80000986:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80000988:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000098a:	00b67d63          	bgeu	a2,a1,800009a4 <uvmdealloc+0x26>
    8000098e:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80000990:	6785                	lui	a5,0x1
    80000992:	17fd                	addi	a5,a5,-1
    80000994:	00f60733          	add	a4,a2,a5
    80000998:	767d                	lui	a2,0xfffff
    8000099a:	8f71                	and	a4,a4,a2
    8000099c:	97ae                	add	a5,a5,a1
    8000099e:	8ff1                	and	a5,a5,a2
    800009a0:	00f76863          	bltu	a4,a5,800009b0 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800009a4:	8526                	mv	a0,s1
    800009a6:	60e2                	ld	ra,24(sp)
    800009a8:	6442                	ld	s0,16(sp)
    800009aa:	64a2                	ld	s1,8(sp)
    800009ac:	6105                	addi	sp,sp,32
    800009ae:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800009b0:	8f99                	sub	a5,a5,a4
    800009b2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800009b4:	4685                	li	a3,1
    800009b6:	0007861b          	sext.w	a2,a5
    800009ba:	85ba                	mv	a1,a4
    800009bc:	00000097          	auipc	ra,0x0
    800009c0:	d9a080e7          	jalr	-614(ra) # 80000756 <uvmunmap>
    800009c4:	b7c5                	j	800009a4 <uvmdealloc+0x26>

00000000800009c6 <uvmalloc>:
  if(newsz < oldsz)
    800009c6:	0ab66163          	bltu	a2,a1,80000a68 <uvmalloc+0xa2>
{
    800009ca:	7139                	addi	sp,sp,-64
    800009cc:	fc06                	sd	ra,56(sp)
    800009ce:	f822                	sd	s0,48(sp)
    800009d0:	f426                	sd	s1,40(sp)
    800009d2:	f04a                	sd	s2,32(sp)
    800009d4:	ec4e                	sd	s3,24(sp)
    800009d6:	e852                	sd	s4,16(sp)
    800009d8:	e456                	sd	s5,8(sp)
    800009da:	0080                	addi	s0,sp,64
    800009dc:	8aaa                	mv	s5,a0
    800009de:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800009e0:	6985                	lui	s3,0x1
    800009e2:	19fd                	addi	s3,s3,-1
    800009e4:	95ce                	add	a1,a1,s3
    800009e6:	79fd                	lui	s3,0xfffff
    800009e8:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800009ec:	08c9f063          	bgeu	s3,a2,80000a6c <uvmalloc+0xa6>
    800009f0:	894e                	mv	s2,s3
    mem = kalloc();
    800009f2:	fffff097          	auipc	ra,0xfffff
    800009f6:	740080e7          	jalr	1856(ra) # 80000132 <kalloc>
    800009fa:	84aa                	mv	s1,a0
    if(mem == 0){
    800009fc:	c51d                	beqz	a0,80000a2a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800009fe:	6605                	lui	a2,0x1
    80000a00:	4581                	li	a1,0
    80000a02:	fffff097          	auipc	ra,0xfffff
    80000a06:	7be080e7          	jalr	1982(ra) # 800001c0 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80000a0a:	4779                	li	a4,30
    80000a0c:	86a6                	mv	a3,s1
    80000a0e:	6605                	lui	a2,0x1
    80000a10:	85ca                	mv	a1,s2
    80000a12:	8556                	mv	a0,s5
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	b7c080e7          	jalr	-1156(ra) # 80000590 <mappages>
    80000a1c:	e905                	bnez	a0,80000a4c <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000a1e:	6785                	lui	a5,0x1
    80000a20:	993e                	add	s2,s2,a5
    80000a22:	fd4968e3          	bltu	s2,s4,800009f2 <uvmalloc+0x2c>
  return newsz;
    80000a26:	8552                	mv	a0,s4
    80000a28:	a809                	j	80000a3a <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80000a2a:	864e                	mv	a2,s3
    80000a2c:	85ca                	mv	a1,s2
    80000a2e:	8556                	mv	a0,s5
    80000a30:	00000097          	auipc	ra,0x0
    80000a34:	f4e080e7          	jalr	-178(ra) # 8000097e <uvmdealloc>
      return 0;
    80000a38:	4501                	li	a0,0
}
    80000a3a:	70e2                	ld	ra,56(sp)
    80000a3c:	7442                	ld	s0,48(sp)
    80000a3e:	74a2                	ld	s1,40(sp)
    80000a40:	7902                	ld	s2,32(sp)
    80000a42:	69e2                	ld	s3,24(sp)
    80000a44:	6a42                	ld	s4,16(sp)
    80000a46:	6aa2                	ld	s5,8(sp)
    80000a48:	6121                	addi	sp,sp,64
    80000a4a:	8082                	ret
      kfree(mem);
    80000a4c:	8526                	mv	a0,s1
    80000a4e:	fffff097          	auipc	ra,0xfffff
    80000a52:	5ce080e7          	jalr	1486(ra) # 8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80000a56:	864e                	mv	a2,s3
    80000a58:	85ca                	mv	a1,s2
    80000a5a:	8556                	mv	a0,s5
    80000a5c:	00000097          	auipc	ra,0x0
    80000a60:	f22080e7          	jalr	-222(ra) # 8000097e <uvmdealloc>
      return 0;
    80000a64:	4501                	li	a0,0
    80000a66:	bfd1                	j	80000a3a <uvmalloc+0x74>
    return oldsz;
    80000a68:	852e                	mv	a0,a1
}
    80000a6a:	8082                	ret
  return newsz;
    80000a6c:	8532                	mv	a0,a2
    80000a6e:	b7f1                	j	80000a3a <uvmalloc+0x74>

0000000080000a70 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80000a70:	7179                	addi	sp,sp,-48
    80000a72:	f406                	sd	ra,40(sp)
    80000a74:	f022                	sd	s0,32(sp)
    80000a76:	ec26                	sd	s1,24(sp)
    80000a78:	e84a                	sd	s2,16(sp)
    80000a7a:	e44e                	sd	s3,8(sp)
    80000a7c:	e052                	sd	s4,0(sp)
    80000a7e:	1800                	addi	s0,sp,48
    80000a80:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000a82:	84aa                	mv	s1,a0
    80000a84:	6905                	lui	s2,0x1
    80000a86:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000a88:	4985                	li	s3,1
    80000a8a:	a821                	j	80000aa2 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000a8c:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80000a8e:	0532                	slli	a0,a0,0xc
    80000a90:	00000097          	auipc	ra,0x0
    80000a94:	fe0080e7          	jalr	-32(ra) # 80000a70 <freewalk>
      pagetable[i] = 0;
    80000a98:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000a9c:	04a1                	addi	s1,s1,8
    80000a9e:	03248163          	beq	s1,s2,80000ac0 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80000aa2:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000aa4:	00f57793          	andi	a5,a0,15
    80000aa8:	ff3782e3          	beq	a5,s3,80000a8c <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000aac:	8905                	andi	a0,a0,1
    80000aae:	d57d                	beqz	a0,80000a9c <freewalk+0x2c>
      panic("freewalk: leaf");
    80000ab0:	00007517          	auipc	a0,0x7
    80000ab4:	64850513          	addi	a0,a0,1608 # 800080f8 <etext+0xf8>
    80000ab8:	00005097          	auipc	ra,0x5
    80000abc:	2ba080e7          	jalr	698(ra) # 80005d72 <panic>
    }
  }
  kfree((void*)pagetable);
    80000ac0:	8552                	mv	a0,s4
    80000ac2:	fffff097          	auipc	ra,0xfffff
    80000ac6:	55a080e7          	jalr	1370(ra) # 8000001c <kfree>
}
    80000aca:	70a2                	ld	ra,40(sp)
    80000acc:	7402                	ld	s0,32(sp)
    80000ace:	64e2                	ld	s1,24(sp)
    80000ad0:	6942                	ld	s2,16(sp)
    80000ad2:	69a2                	ld	s3,8(sp)
    80000ad4:	6a02                	ld	s4,0(sp)
    80000ad6:	6145                	addi	sp,sp,48
    80000ad8:	8082                	ret

0000000080000ada <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80000ada:	1101                	addi	sp,sp,-32
    80000adc:	ec06                	sd	ra,24(sp)
    80000ade:	e822                	sd	s0,16(sp)
    80000ae0:	e426                	sd	s1,8(sp)
    80000ae2:	1000                	addi	s0,sp,32
    80000ae4:	84aa                	mv	s1,a0
  if(sz > 0)
    80000ae6:	e999                	bnez	a1,80000afc <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80000ae8:	8526                	mv	a0,s1
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	f86080e7          	jalr	-122(ra) # 80000a70 <freewalk>
}
    80000af2:	60e2                	ld	ra,24(sp)
    80000af4:	6442                	ld	s0,16(sp)
    80000af6:	64a2                	ld	s1,8(sp)
    80000af8:	6105                	addi	sp,sp,32
    80000afa:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80000afc:	6605                	lui	a2,0x1
    80000afe:	167d                	addi	a2,a2,-1
    80000b00:	962e                	add	a2,a2,a1
    80000b02:	4685                	li	a3,1
    80000b04:	8231                	srli	a2,a2,0xc
    80000b06:	4581                	li	a1,0
    80000b08:	00000097          	auipc	ra,0x0
    80000b0c:	c4e080e7          	jalr	-946(ra) # 80000756 <uvmunmap>
    80000b10:	bfe1                	j	80000ae8 <uvmfree+0xe>

0000000080000b12 <uvmcopy>:
//   return -1;
// }

int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    80000b12:	715d                	addi	sp,sp,-80
    80000b14:	e486                	sd	ra,72(sp)
    80000b16:	e0a2                	sd	s0,64(sp)
    80000b18:	fc26                	sd	s1,56(sp)
    80000b1a:	f84a                	sd	s2,48(sp)
    80000b1c:	f44e                	sd	s3,40(sp)
    80000b1e:	f052                	sd	s4,32(sp)
    80000b20:	ec56                	sd	s5,24(sp)
    80000b22:	e85a                	sd	s6,16(sp)
    80000b24:	e45e                	sd	s7,8(sp)
    80000b26:	0880                	addi	s0,sp,80
  pte_t *pte;   // pte_t -->> cast: typedef uint64 pte_t; (riscv.h -> line: 365).And uint64 -->> cast: typedef unsigned long uint64; (types.h -> line: 8)
  uint64 pa, i; // uint64 -->> unsigned long 
  uint flags;   // uint -->> cast: typedef unsigned int uint; (types.h -> line: 1)
  //   char *mem;   -->>> not useful -> kalloc() is not used

  for(i = 0; i < sz; i += PGSIZE){ // PGSIZE -->> defibe PGSIZE 4096 -> bytes per page (riscv.h -> line 335) 
    80000b28:	ca55                	beqz	a2,80000bdc <uvmcopy+0xca>
    80000b2a:	8aaa                	mv	s5,a0
    80000b2c:	8a2e                	mv	s4,a1
    80000b2e:	89b2                	mv	s3,a2
    80000b30:	4481                	li	s1,0
    flags = PTE_FLAGS(*pte); 
    // mark the child page table entry and mark the parent page table entry  
    // read only
    flags &= (~PTE_W); // Reset flag. flag W  -->>> 0
    flags |=PTE_COW; // Set 
    *pte=PA2PTE(pa) |flags;   // change the old pte with the new pte
    80000b32:	7b7d                	lui	s6,0xfffff
    80000b34:	002b5b13          	srli	s6,s6,0x2
    if((pte = walk(old, i, 0)) == 0)  // Find PTE
    80000b38:	4601                	li	a2,0
    80000b3a:	85a6                	mv	a1,s1
    80000b3c:	8556                	mv	a0,s5
    80000b3e:	00000097          	auipc	ra,0x0
    80000b42:	96a080e7          	jalr	-1686(ra) # 800004a8 <walk>
    80000b46:	c529                	beqz	a0,80000b90 <uvmcopy+0x7e>
    if((*pte & PTE_V) == 0)    // PTE is not present
    80000b48:	611c                	ld	a5,0(a0)
    80000b4a:	0017f713          	andi	a4,a5,1
    80000b4e:	cb29                	beqz	a4,80000ba0 <uvmcopy+0x8e>
    pa = PTE2PA(*pte);    // shift a physical address to the right place for a PTE.
    80000b50:	00a7d913          	srli	s2,a5,0xa
    80000b54:	0932                	slli	s2,s2,0xc
    flags &= (~PTE_W); // Reset flag. flag W  -->>> 0
    80000b56:	3fb7f713          	andi	a4,a5,1019
    *pte=PA2PTE(pa) |flags;   // change the old pte with the new pte
    80000b5a:	0167f7b3          	and	a5,a5,s6
    80000b5e:	20076693          	ori	a3,a4,512
    80000b62:	8fd5                	or	a5,a5,a3
    80000b64:	e11c                	sd	a5,0(a0)
    // we don't want to allocate new page -->> so we comment on these lines which following
    // if((mem = kalloc()) == 0)
    //   goto err;
    // memmove(mem, (char*)pa, PGSIZE);
    
     if(mappages(new, i, PGSIZE, pa, flags) != 0){
    80000b66:	8736                	mv	a4,a3
    80000b68:	86ca                	mv	a3,s2
    80000b6a:	6605                	lui	a2,0x1
    80000b6c:	85a6                	mv	a1,s1
    80000b6e:	8552                	mv	a0,s4
    80000b70:	00000097          	auipc	ra,0x0
    80000b74:	a20080e7          	jalr	-1504(ra) # 80000590 <mappages>
    80000b78:	8baa                	mv	s7,a0
    80000b7a:	e91d                	bnez	a0,80000bb0 <uvmcopy+0x9e>
    //   kfree(mem);
       goto err;     // Error 
     }
    increase_reference_cnt(pa); // increase reference counter
    80000b7c:	854a                	mv	a0,s2
    80000b7e:	00005097          	auipc	ra,0x5
    80000b82:	bc8080e7          	jalr	-1080(ra) # 80005746 <increase_reference_cnt>
  for(i = 0; i < sz; i += PGSIZE){ // PGSIZE -->> defibe PGSIZE 4096 -> bytes per page (riscv.h -> line 335) 
    80000b86:	6785                	lui	a5,0x1
    80000b88:	94be                	add	s1,s1,a5
    80000b8a:	fb34e7e3          	bltu	s1,s3,80000b38 <uvmcopy+0x26>
    80000b8e:	a81d                	j	80000bc4 <uvmcopy+0xb2>
      panic("uvmcopy: pte should exist");  // Error 
    80000b90:	00007517          	auipc	a0,0x7
    80000b94:	57850513          	addi	a0,a0,1400 # 80008108 <etext+0x108>
    80000b98:	00005097          	auipc	ra,0x5
    80000b9c:	1da080e7          	jalr	474(ra) # 80005d72 <panic>
      panic("uvmcopy: page not present");
    80000ba0:	00007517          	auipc	a0,0x7
    80000ba4:	58850513          	addi	a0,a0,1416 # 80008128 <etext+0x128>
    80000ba8:	00005097          	auipc	ra,0x5
    80000bac:	1ca080e7          	jalr	458(ra) # 80005d72 <panic>
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1); // uvmunmap() use walk to find PTE and kfree to free the physical memory they refer to
    80000bb0:	4685                	li	a3,1
    80000bb2:	00c4d613          	srli	a2,s1,0xc
    80000bb6:	4581                	li	a1,0
    80000bb8:	8552                	mv	a0,s4
    80000bba:	00000097          	auipc	ra,0x0
    80000bbe:	b9c080e7          	jalr	-1124(ra) # 80000756 <uvmunmap>
  return -1;
    80000bc2:	5bfd                	li	s7,-1
}
    80000bc4:	855e                	mv	a0,s7
    80000bc6:	60a6                	ld	ra,72(sp)
    80000bc8:	6406                	ld	s0,64(sp)
    80000bca:	74e2                	ld	s1,56(sp)
    80000bcc:	7942                	ld	s2,48(sp)
    80000bce:	79a2                	ld	s3,40(sp)
    80000bd0:	7a02                	ld	s4,32(sp)
    80000bd2:	6ae2                	ld	s5,24(sp)
    80000bd4:	6b42                	ld	s6,16(sp)
    80000bd6:	6ba2                	ld	s7,8(sp)
    80000bd8:	6161                	addi	sp,sp,80
    80000bda:	8082                	ret
  return 0;
    80000bdc:	4b81                	li	s7,0
    80000bde:	b7dd                	j	80000bc4 <uvmcopy+0xb2>

0000000080000be0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000be0:	1141                	addi	sp,sp,-16
    80000be2:	e406                	sd	ra,8(sp)
    80000be4:	e022                	sd	s0,0(sp)
    80000be6:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000be8:	4601                	li	a2,0
    80000bea:	00000097          	auipc	ra,0x0
    80000bee:	8be080e7          	jalr	-1858(ra) # 800004a8 <walk>
  if(pte == 0)
    80000bf2:	c901                	beqz	a0,80000c02 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000bf4:	611c                	ld	a5,0(a0)
    80000bf6:	9bbd                	andi	a5,a5,-17
    80000bf8:	e11c                	sd	a5,0(a0)
}
    80000bfa:	60a2                	ld	ra,8(sp)
    80000bfc:	6402                	ld	s0,0(sp)
    80000bfe:	0141                	addi	sp,sp,16
    80000c00:	8082                	ret
    panic("uvmclear");
    80000c02:	00007517          	auipc	a0,0x7
    80000c06:	54650513          	addi	a0,a0,1350 # 80008148 <etext+0x148>
    80000c0a:	00005097          	auipc	ra,0x5
    80000c0e:	168080e7          	jalr	360(ra) # 80005d72 <panic>

0000000080000c12 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000c12:	c6bd                	beqz	a3,80000c80 <copyout+0x6e>
{
    80000c14:	715d                	addi	sp,sp,-80
    80000c16:	e486                	sd	ra,72(sp)
    80000c18:	e0a2                	sd	s0,64(sp)
    80000c1a:	fc26                	sd	s1,56(sp)
    80000c1c:	f84a                	sd	s2,48(sp)
    80000c1e:	f44e                	sd	s3,40(sp)
    80000c20:	f052                	sd	s4,32(sp)
    80000c22:	ec56                	sd	s5,24(sp)
    80000c24:	e85a                	sd	s6,16(sp)
    80000c26:	e45e                	sd	s7,8(sp)
    80000c28:	e062                	sd	s8,0(sp)
    80000c2a:	0880                	addi	s0,sp,80
    80000c2c:	8b2a                	mv	s6,a0
    80000c2e:	8c2e                	mv	s8,a1
    80000c30:	8a32                	mv	s4,a2
    80000c32:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000c34:	7bfd                	lui	s7,0xfffff
    pa0 = cow_f(pagetable, va0);  // cow handler
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0); 
    80000c36:	6a85                	lui	s5,0x1
    80000c38:	a015                	j	80000c5c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000c3a:	9562                	add	a0,a0,s8
    80000c3c:	0004861b          	sext.w	a2,s1
    80000c40:	85d2                	mv	a1,s4
    80000c42:	41250533          	sub	a0,a0,s2
    80000c46:	fffff097          	auipc	ra,0xfffff
    80000c4a:	5da080e7          	jalr	1498(ra) # 80000220 <memmove>

    len -= n;
    80000c4e:	409989b3          	sub	s3,s3,s1
    src += n;
    80000c52:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80000c54:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000c58:	02098263          	beqz	s3,80000c7c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80000c5c:	017c7933          	and	s2,s8,s7
    pa0 = cow_f(pagetable, va0);  // cow handler
    80000c60:	85ca                	mv	a1,s2
    80000c62:	855a                	mv	a0,s6
    80000c64:	00000097          	auipc	ra,0x0
    80000c68:	bb6080e7          	jalr	-1098(ra) # 8000081a <cow_f>
    if(pa0 == 0)
    80000c6c:	cd01                	beqz	a0,80000c84 <copyout+0x72>
    n = PGSIZE - (dstva - va0); 
    80000c6e:	418904b3          	sub	s1,s2,s8
    80000c72:	94d6                	add	s1,s1,s5
    if(n > len)
    80000c74:	fc99f3e3          	bgeu	s3,s1,80000c3a <copyout+0x28>
    80000c78:	84ce                	mv	s1,s3
    80000c7a:	b7c1                	j	80000c3a <copyout+0x28>
  }
  return 0;
    80000c7c:	4501                	li	a0,0
    80000c7e:	a021                	j	80000c86 <copyout+0x74>
    80000c80:	4501                	li	a0,0
}
    80000c82:	8082                	ret
      return -1;
    80000c84:	557d                	li	a0,-1
}
    80000c86:	60a6                	ld	ra,72(sp)
    80000c88:	6406                	ld	s0,64(sp)
    80000c8a:	74e2                	ld	s1,56(sp)
    80000c8c:	7942                	ld	s2,48(sp)
    80000c8e:	79a2                	ld	s3,40(sp)
    80000c90:	7a02                	ld	s4,32(sp)
    80000c92:	6ae2                	ld	s5,24(sp)
    80000c94:	6b42                	ld	s6,16(sp)
    80000c96:	6ba2                	ld	s7,8(sp)
    80000c98:	6c02                	ld	s8,0(sp)
    80000c9a:	6161                	addi	sp,sp,80
    80000c9c:	8082                	ret

0000000080000c9e <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000c9e:	c6bd                	beqz	a3,80000d0c <copyin+0x6e>
{
    80000ca0:	715d                	addi	sp,sp,-80
    80000ca2:	e486                	sd	ra,72(sp)
    80000ca4:	e0a2                	sd	s0,64(sp)
    80000ca6:	fc26                	sd	s1,56(sp)
    80000ca8:	f84a                	sd	s2,48(sp)
    80000caa:	f44e                	sd	s3,40(sp)
    80000cac:	f052                	sd	s4,32(sp)
    80000cae:	ec56                	sd	s5,24(sp)
    80000cb0:	e85a                	sd	s6,16(sp)
    80000cb2:	e45e                	sd	s7,8(sp)
    80000cb4:	e062                	sd	s8,0(sp)
    80000cb6:	0880                	addi	s0,sp,80
    80000cb8:	8b2a                	mv	s6,a0
    80000cba:	8a2e                	mv	s4,a1
    80000cbc:	8c32                	mv	s8,a2
    80000cbe:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000cc0:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000cc2:	6a85                	lui	s5,0x1
    80000cc4:	a015                	j	80000ce8 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000cc6:	9562                	add	a0,a0,s8
    80000cc8:	0004861b          	sext.w	a2,s1
    80000ccc:	412505b3          	sub	a1,a0,s2
    80000cd0:	8552                	mv	a0,s4
    80000cd2:	fffff097          	auipc	ra,0xfffff
    80000cd6:	54e080e7          	jalr	1358(ra) # 80000220 <memmove>

    len -= n;
    80000cda:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000cde:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000ce0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000ce4:	02098263          	beqz	s3,80000d08 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80000ce8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000cec:	85ca                	mv	a1,s2
    80000cee:	855a                	mv	a0,s6
    80000cf0:	00000097          	auipc	ra,0x0
    80000cf4:	85e080e7          	jalr	-1954(ra) # 8000054e <walkaddr>
    if(pa0 == 0)
    80000cf8:	cd01                	beqz	a0,80000d10 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80000cfa:	418904b3          	sub	s1,s2,s8
    80000cfe:	94d6                	add	s1,s1,s5
    if(n > len)
    80000d00:	fc99f3e3          	bgeu	s3,s1,80000cc6 <copyin+0x28>
    80000d04:	84ce                	mv	s1,s3
    80000d06:	b7c1                	j	80000cc6 <copyin+0x28>
  }
  return 0;
    80000d08:	4501                	li	a0,0
    80000d0a:	a021                	j	80000d12 <copyin+0x74>
    80000d0c:	4501                	li	a0,0
}
    80000d0e:	8082                	ret
      return -1;
    80000d10:	557d                	li	a0,-1
}
    80000d12:	60a6                	ld	ra,72(sp)
    80000d14:	6406                	ld	s0,64(sp)
    80000d16:	74e2                	ld	s1,56(sp)
    80000d18:	7942                	ld	s2,48(sp)
    80000d1a:	79a2                	ld	s3,40(sp)
    80000d1c:	7a02                	ld	s4,32(sp)
    80000d1e:	6ae2                	ld	s5,24(sp)
    80000d20:	6b42                	ld	s6,16(sp)
    80000d22:	6ba2                	ld	s7,8(sp)
    80000d24:	6c02                	ld	s8,0(sp)
    80000d26:	6161                	addi	sp,sp,80
    80000d28:	8082                	ret

0000000080000d2a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000d2a:	c6c5                	beqz	a3,80000dd2 <copyinstr+0xa8>
{
    80000d2c:	715d                	addi	sp,sp,-80
    80000d2e:	e486                	sd	ra,72(sp)
    80000d30:	e0a2                	sd	s0,64(sp)
    80000d32:	fc26                	sd	s1,56(sp)
    80000d34:	f84a                	sd	s2,48(sp)
    80000d36:	f44e                	sd	s3,40(sp)
    80000d38:	f052                	sd	s4,32(sp)
    80000d3a:	ec56                	sd	s5,24(sp)
    80000d3c:	e85a                	sd	s6,16(sp)
    80000d3e:	e45e                	sd	s7,8(sp)
    80000d40:	0880                	addi	s0,sp,80
    80000d42:	8a2a                	mv	s4,a0
    80000d44:	8b2e                	mv	s6,a1
    80000d46:	8bb2                	mv	s7,a2
    80000d48:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80000d4a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000d4c:	6985                	lui	s3,0x1
    80000d4e:	a035                	j	80000d7a <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000d50:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000d54:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000d56:	0017b793          	seqz	a5,a5
    80000d5a:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000d5e:	60a6                	ld	ra,72(sp)
    80000d60:	6406                	ld	s0,64(sp)
    80000d62:	74e2                	ld	s1,56(sp)
    80000d64:	7942                	ld	s2,48(sp)
    80000d66:	79a2                	ld	s3,40(sp)
    80000d68:	7a02                	ld	s4,32(sp)
    80000d6a:	6ae2                	ld	s5,24(sp)
    80000d6c:	6b42                	ld	s6,16(sp)
    80000d6e:	6ba2                	ld	s7,8(sp)
    80000d70:	6161                	addi	sp,sp,80
    80000d72:	8082                	ret
    srcva = va0 + PGSIZE;
    80000d74:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80000d78:	c8a9                	beqz	s1,80000dca <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80000d7a:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000d7e:	85ca                	mv	a1,s2
    80000d80:	8552                	mv	a0,s4
    80000d82:	fffff097          	auipc	ra,0xfffff
    80000d86:	7cc080e7          	jalr	1996(ra) # 8000054e <walkaddr>
    if(pa0 == 0)
    80000d8a:	c131                	beqz	a0,80000dce <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80000d8c:	41790833          	sub	a6,s2,s7
    80000d90:	984e                	add	a6,a6,s3
    if(n > max)
    80000d92:	0104f363          	bgeu	s1,a6,80000d98 <copyinstr+0x6e>
    80000d96:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80000d98:	955e                	add	a0,a0,s7
    80000d9a:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80000d9e:	fc080be3          	beqz	a6,80000d74 <copyinstr+0x4a>
    80000da2:	985a                	add	a6,a6,s6
    80000da4:	87da                	mv	a5,s6
      if(*p == '\0'){
    80000da6:	41650633          	sub	a2,a0,s6
    80000daa:	14fd                	addi	s1,s1,-1
    80000dac:	9b26                	add	s6,s6,s1
    80000dae:	00f60733          	add	a4,a2,a5
    80000db2:	00074703          	lbu	a4,0(a4)
    80000db6:	df49                	beqz	a4,80000d50 <copyinstr+0x26>
        *dst = *p;
    80000db8:	00e78023          	sb	a4,0(a5)
      --max;
    80000dbc:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80000dc0:	0785                	addi	a5,a5,1
    while(n > 0){
    80000dc2:	ff0796e3          	bne	a5,a6,80000dae <copyinstr+0x84>
      dst++;
    80000dc6:	8b42                	mv	s6,a6
    80000dc8:	b775                	j	80000d74 <copyinstr+0x4a>
    80000dca:	4781                	li	a5,0
    80000dcc:	b769                	j	80000d56 <copyinstr+0x2c>
      return -1;
    80000dce:	557d                	li	a0,-1
    80000dd0:	b779                	j	80000d5e <copyinstr+0x34>
  int got_null = 0;
    80000dd2:	4781                	li	a5,0
  if(got_null){
    80000dd4:	0017b793          	seqz	a5,a5
    80000dd8:	40f00533          	neg	a0,a5
}
    80000ddc:	8082                	ret

0000000080000dde <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80000dde:	7139                	addi	sp,sp,-64
    80000de0:	fc06                	sd	ra,56(sp)
    80000de2:	f822                	sd	s0,48(sp)
    80000de4:	f426                	sd	s1,40(sp)
    80000de6:	f04a                	sd	s2,32(sp)
    80000de8:	ec4e                	sd	s3,24(sp)
    80000dea:	e852                	sd	s4,16(sp)
    80000dec:	e456                	sd	s5,8(sp)
    80000dee:	e05a                	sd	s6,0(sp)
    80000df0:	0080                	addi	s0,sp,64
    80000df2:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000df4:	00008497          	auipc	s1,0x8
    80000df8:	68c48493          	addi	s1,s1,1676 # 80009480 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000dfc:	8b26                	mv	s6,s1
    80000dfe:	00007a97          	auipc	s5,0x7
    80000e02:	202a8a93          	addi	s5,s5,514 # 80008000 <etext>
    80000e06:	04000937          	lui	s2,0x4000
    80000e0a:	197d                	addi	s2,s2,-1
    80000e0c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e0e:	0000ea17          	auipc	s4,0xe
    80000e12:	072a0a13          	addi	s4,s4,114 # 8000ee80 <tickslock>
    char *pa = kalloc();
    80000e16:	fffff097          	auipc	ra,0xfffff
    80000e1a:	31c080e7          	jalr	796(ra) # 80000132 <kalloc>
    80000e1e:	862a                	mv	a2,a0
    if(pa == 0)
    80000e20:	c131                	beqz	a0,80000e64 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80000e22:	416485b3          	sub	a1,s1,s6
    80000e26:	858d                	srai	a1,a1,0x3
    80000e28:	000ab783          	ld	a5,0(s5)
    80000e2c:	02f585b3          	mul	a1,a1,a5
    80000e30:	2585                	addiw	a1,a1,1
    80000e32:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000e36:	4719                	li	a4,6
    80000e38:	6685                	lui	a3,0x1
    80000e3a:	40b905b3          	sub	a1,s2,a1
    80000e3e:	854e                	mv	a0,s3
    80000e40:	fffff097          	auipc	ra,0xfffff
    80000e44:	7f0080e7          	jalr	2032(ra) # 80000630 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e48:	16848493          	addi	s1,s1,360
    80000e4c:	fd4495e3          	bne	s1,s4,80000e16 <proc_mapstacks+0x38>
  }
}
    80000e50:	70e2                	ld	ra,56(sp)
    80000e52:	7442                	ld	s0,48(sp)
    80000e54:	74a2                	ld	s1,40(sp)
    80000e56:	7902                	ld	s2,32(sp)
    80000e58:	69e2                	ld	s3,24(sp)
    80000e5a:	6a42                	ld	s4,16(sp)
    80000e5c:	6aa2                	ld	s5,8(sp)
    80000e5e:	6b02                	ld	s6,0(sp)
    80000e60:	6121                	addi	sp,sp,64
    80000e62:	8082                	ret
      panic("kalloc");
    80000e64:	00007517          	auipc	a0,0x7
    80000e68:	2f450513          	addi	a0,a0,756 # 80008158 <etext+0x158>
    80000e6c:	00005097          	auipc	ra,0x5
    80000e70:	f06080e7          	jalr	-250(ra) # 80005d72 <panic>

0000000080000e74 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80000e74:	7139                	addi	sp,sp,-64
    80000e76:	fc06                	sd	ra,56(sp)
    80000e78:	f822                	sd	s0,48(sp)
    80000e7a:	f426                	sd	s1,40(sp)
    80000e7c:	f04a                	sd	s2,32(sp)
    80000e7e:	ec4e                	sd	s3,24(sp)
    80000e80:	e852                	sd	s4,16(sp)
    80000e82:	e456                	sd	s5,8(sp)
    80000e84:	e05a                	sd	s6,0(sp)
    80000e86:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000e88:	00007597          	auipc	a1,0x7
    80000e8c:	2d858593          	addi	a1,a1,728 # 80008160 <etext+0x160>
    80000e90:	00008517          	auipc	a0,0x8
    80000e94:	1c050513          	addi	a0,a0,448 # 80009050 <pid_lock>
    80000e98:	00005097          	auipc	ra,0x5
    80000e9c:	394080e7          	jalr	916(ra) # 8000622c <initlock>
  initlock(&wait_lock, "wait_lock");
    80000ea0:	00007597          	auipc	a1,0x7
    80000ea4:	2c858593          	addi	a1,a1,712 # 80008168 <etext+0x168>
    80000ea8:	00008517          	auipc	a0,0x8
    80000eac:	1c050513          	addi	a0,a0,448 # 80009068 <wait_lock>
    80000eb0:	00005097          	auipc	ra,0x5
    80000eb4:	37c080e7          	jalr	892(ra) # 8000622c <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000eb8:	00008497          	auipc	s1,0x8
    80000ebc:	5c848493          	addi	s1,s1,1480 # 80009480 <proc>
      initlock(&p->lock, "proc");
    80000ec0:	00007b17          	auipc	s6,0x7
    80000ec4:	2b8b0b13          	addi	s6,s6,696 # 80008178 <etext+0x178>
      p->kstack = KSTACK((int) (p - proc));
    80000ec8:	8aa6                	mv	s5,s1
    80000eca:	00007a17          	auipc	s4,0x7
    80000ece:	136a0a13          	addi	s4,s4,310 # 80008000 <etext>
    80000ed2:	04000937          	lui	s2,0x4000
    80000ed6:	197d                	addi	s2,s2,-1
    80000ed8:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000eda:	0000e997          	auipc	s3,0xe
    80000ede:	fa698993          	addi	s3,s3,-90 # 8000ee80 <tickslock>
      initlock(&p->lock, "proc");
    80000ee2:	85da                	mv	a1,s6
    80000ee4:	8526                	mv	a0,s1
    80000ee6:	00005097          	auipc	ra,0x5
    80000eea:	346080e7          	jalr	838(ra) # 8000622c <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80000eee:	415487b3          	sub	a5,s1,s5
    80000ef2:	878d                	srai	a5,a5,0x3
    80000ef4:	000a3703          	ld	a4,0(s4)
    80000ef8:	02e787b3          	mul	a5,a5,a4
    80000efc:	2785                	addiw	a5,a5,1
    80000efe:	00d7979b          	slliw	a5,a5,0xd
    80000f02:	40f907b3          	sub	a5,s2,a5
    80000f06:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f08:	16848493          	addi	s1,s1,360
    80000f0c:	fd349be3          	bne	s1,s3,80000ee2 <procinit+0x6e>
  }
}
    80000f10:	70e2                	ld	ra,56(sp)
    80000f12:	7442                	ld	s0,48(sp)
    80000f14:	74a2                	ld	s1,40(sp)
    80000f16:	7902                	ld	s2,32(sp)
    80000f18:	69e2                	ld	s3,24(sp)
    80000f1a:	6a42                	ld	s4,16(sp)
    80000f1c:	6aa2                	ld	s5,8(sp)
    80000f1e:	6b02                	ld	s6,0(sp)
    80000f20:	6121                	addi	sp,sp,64
    80000f22:	8082                	ret

0000000080000f24 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000f24:	1141                	addi	sp,sp,-16
    80000f26:	e422                	sd	s0,8(sp)
    80000f28:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000f2a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000f2c:	2501                	sext.w	a0,a0
    80000f2e:	6422                	ld	s0,8(sp)
    80000f30:	0141                	addi	sp,sp,16
    80000f32:	8082                	ret

0000000080000f34 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80000f34:	1141                	addi	sp,sp,-16
    80000f36:	e422                	sd	s0,8(sp)
    80000f38:	0800                	addi	s0,sp,16
    80000f3a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000f3c:	2781                	sext.w	a5,a5
    80000f3e:	079e                	slli	a5,a5,0x7
  return c;
}
    80000f40:	00008517          	auipc	a0,0x8
    80000f44:	14050513          	addi	a0,a0,320 # 80009080 <cpus>
    80000f48:	953e                	add	a0,a0,a5
    80000f4a:	6422                	ld	s0,8(sp)
    80000f4c:	0141                	addi	sp,sp,16
    80000f4e:	8082                	ret

0000000080000f50 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80000f50:	1101                	addi	sp,sp,-32
    80000f52:	ec06                	sd	ra,24(sp)
    80000f54:	e822                	sd	s0,16(sp)
    80000f56:	e426                	sd	s1,8(sp)
    80000f58:	1000                	addi	s0,sp,32
  push_off();
    80000f5a:	00005097          	auipc	ra,0x5
    80000f5e:	316080e7          	jalr	790(ra) # 80006270 <push_off>
    80000f62:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000f64:	2781                	sext.w	a5,a5
    80000f66:	079e                	slli	a5,a5,0x7
    80000f68:	00008717          	auipc	a4,0x8
    80000f6c:	0e870713          	addi	a4,a4,232 # 80009050 <pid_lock>
    80000f70:	97ba                	add	a5,a5,a4
    80000f72:	7b84                	ld	s1,48(a5)
  pop_off();
    80000f74:	00005097          	auipc	ra,0x5
    80000f78:	39c080e7          	jalr	924(ra) # 80006310 <pop_off>
  return p;
}
    80000f7c:	8526                	mv	a0,s1
    80000f7e:	60e2                	ld	ra,24(sp)
    80000f80:	6442                	ld	s0,16(sp)
    80000f82:	64a2                	ld	s1,8(sp)
    80000f84:	6105                	addi	sp,sp,32
    80000f86:	8082                	ret

0000000080000f88 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e406                	sd	ra,8(sp)
    80000f8c:	e022                	sd	s0,0(sp)
    80000f8e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000f90:	00000097          	auipc	ra,0x0
    80000f94:	fc0080e7          	jalr	-64(ra) # 80000f50 <myproc>
    80000f98:	00005097          	auipc	ra,0x5
    80000f9c:	3d8080e7          	jalr	984(ra) # 80006370 <release>

  if (first) {
    80000fa0:	00008797          	auipc	a5,0x8
    80000fa4:	8707a783          	lw	a5,-1936(a5) # 80008810 <first.1681>
    80000fa8:	eb89                	bnez	a5,80000fba <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80000faa:	00001097          	auipc	ra,0x1
    80000fae:	c0a080e7          	jalr	-1014(ra) # 80001bb4 <usertrapret>
}
    80000fb2:	60a2                	ld	ra,8(sp)
    80000fb4:	6402                	ld	s0,0(sp)
    80000fb6:	0141                	addi	sp,sp,16
    80000fb8:	8082                	ret
    first = 0;
    80000fba:	00008797          	auipc	a5,0x8
    80000fbe:	8407ab23          	sw	zero,-1962(a5) # 80008810 <first.1681>
    fsinit(ROOTDEV);
    80000fc2:	4505                	li	a0,1
    80000fc4:	00002097          	auipc	ra,0x2
    80000fc8:	982080e7          	jalr	-1662(ra) # 80002946 <fsinit>
    80000fcc:	bff9                	j	80000faa <forkret+0x22>

0000000080000fce <allocpid>:
allocpid() {
    80000fce:	1101                	addi	sp,sp,-32
    80000fd0:	ec06                	sd	ra,24(sp)
    80000fd2:	e822                	sd	s0,16(sp)
    80000fd4:	e426                	sd	s1,8(sp)
    80000fd6:	e04a                	sd	s2,0(sp)
    80000fd8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000fda:	00008917          	auipc	s2,0x8
    80000fde:	07690913          	addi	s2,s2,118 # 80009050 <pid_lock>
    80000fe2:	854a                	mv	a0,s2
    80000fe4:	00005097          	auipc	ra,0x5
    80000fe8:	2d8080e7          	jalr	728(ra) # 800062bc <acquire>
  pid = nextpid;
    80000fec:	00008797          	auipc	a5,0x8
    80000ff0:	82878793          	addi	a5,a5,-2008 # 80008814 <nextpid>
    80000ff4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000ff6:	0014871b          	addiw	a4,s1,1
    80000ffa:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000ffc:	854a                	mv	a0,s2
    80000ffe:	00005097          	auipc	ra,0x5
    80001002:	372080e7          	jalr	882(ra) # 80006370 <release>
}
    80001006:	8526                	mv	a0,s1
    80001008:	60e2                	ld	ra,24(sp)
    8000100a:	6442                	ld	s0,16(sp)
    8000100c:	64a2                	ld	s1,8(sp)
    8000100e:	6902                	ld	s2,0(sp)
    80001010:	6105                	addi	sp,sp,32
    80001012:	8082                	ret

0000000080001014 <proc_pagetable>:
{
    80001014:	1101                	addi	sp,sp,-32
    80001016:	ec06                	sd	ra,24(sp)
    80001018:	e822                	sd	s0,16(sp)
    8000101a:	e426                	sd	s1,8(sp)
    8000101c:	e04a                	sd	s2,0(sp)
    8000101e:	1000                	addi	s0,sp,32
    80001020:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001022:	00000097          	auipc	ra,0x0
    80001026:	8bc080e7          	jalr	-1860(ra) # 800008de <uvmcreate>
    8000102a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000102c:	c121                	beqz	a0,8000106c <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000102e:	4729                	li	a4,10
    80001030:	00006697          	auipc	a3,0x6
    80001034:	fd068693          	addi	a3,a3,-48 # 80007000 <_trampoline>
    80001038:	6605                	lui	a2,0x1
    8000103a:	040005b7          	lui	a1,0x4000
    8000103e:	15fd                	addi	a1,a1,-1
    80001040:	05b2                	slli	a1,a1,0xc
    80001042:	fffff097          	auipc	ra,0xfffff
    80001046:	54e080e7          	jalr	1358(ra) # 80000590 <mappages>
    8000104a:	02054863          	bltz	a0,8000107a <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    8000104e:	4719                	li	a4,6
    80001050:	05893683          	ld	a3,88(s2)
    80001054:	6605                	lui	a2,0x1
    80001056:	020005b7          	lui	a1,0x2000
    8000105a:	15fd                	addi	a1,a1,-1
    8000105c:	05b6                	slli	a1,a1,0xd
    8000105e:	8526                	mv	a0,s1
    80001060:	fffff097          	auipc	ra,0xfffff
    80001064:	530080e7          	jalr	1328(ra) # 80000590 <mappages>
    80001068:	02054163          	bltz	a0,8000108a <proc_pagetable+0x76>
}
    8000106c:	8526                	mv	a0,s1
    8000106e:	60e2                	ld	ra,24(sp)
    80001070:	6442                	ld	s0,16(sp)
    80001072:	64a2                	ld	s1,8(sp)
    80001074:	6902                	ld	s2,0(sp)
    80001076:	6105                	addi	sp,sp,32
    80001078:	8082                	ret
    uvmfree(pagetable, 0);
    8000107a:	4581                	li	a1,0
    8000107c:	8526                	mv	a0,s1
    8000107e:	00000097          	auipc	ra,0x0
    80001082:	a5c080e7          	jalr	-1444(ra) # 80000ada <uvmfree>
    return 0;
    80001086:	4481                	li	s1,0
    80001088:	b7d5                	j	8000106c <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000108a:	4681                	li	a3,0
    8000108c:	4605                	li	a2,1
    8000108e:	040005b7          	lui	a1,0x4000
    80001092:	15fd                	addi	a1,a1,-1
    80001094:	05b2                	slli	a1,a1,0xc
    80001096:	8526                	mv	a0,s1
    80001098:	fffff097          	auipc	ra,0xfffff
    8000109c:	6be080e7          	jalr	1726(ra) # 80000756 <uvmunmap>
    uvmfree(pagetable, 0);
    800010a0:	4581                	li	a1,0
    800010a2:	8526                	mv	a0,s1
    800010a4:	00000097          	auipc	ra,0x0
    800010a8:	a36080e7          	jalr	-1482(ra) # 80000ada <uvmfree>
    return 0;
    800010ac:	4481                	li	s1,0
    800010ae:	bf7d                	j	8000106c <proc_pagetable+0x58>

00000000800010b0 <proc_freepagetable>:
{
    800010b0:	1101                	addi	sp,sp,-32
    800010b2:	ec06                	sd	ra,24(sp)
    800010b4:	e822                	sd	s0,16(sp)
    800010b6:	e426                	sd	s1,8(sp)
    800010b8:	e04a                	sd	s2,0(sp)
    800010ba:	1000                	addi	s0,sp,32
    800010bc:	84aa                	mv	s1,a0
    800010be:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800010c0:	4681                	li	a3,0
    800010c2:	4605                	li	a2,1
    800010c4:	040005b7          	lui	a1,0x4000
    800010c8:	15fd                	addi	a1,a1,-1
    800010ca:	05b2                	slli	a1,a1,0xc
    800010cc:	fffff097          	auipc	ra,0xfffff
    800010d0:	68a080e7          	jalr	1674(ra) # 80000756 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800010d4:	4681                	li	a3,0
    800010d6:	4605                	li	a2,1
    800010d8:	020005b7          	lui	a1,0x2000
    800010dc:	15fd                	addi	a1,a1,-1
    800010de:	05b6                	slli	a1,a1,0xd
    800010e0:	8526                	mv	a0,s1
    800010e2:	fffff097          	auipc	ra,0xfffff
    800010e6:	674080e7          	jalr	1652(ra) # 80000756 <uvmunmap>
  uvmfree(pagetable, sz);
    800010ea:	85ca                	mv	a1,s2
    800010ec:	8526                	mv	a0,s1
    800010ee:	00000097          	auipc	ra,0x0
    800010f2:	9ec080e7          	jalr	-1556(ra) # 80000ada <uvmfree>
}
    800010f6:	60e2                	ld	ra,24(sp)
    800010f8:	6442                	ld	s0,16(sp)
    800010fa:	64a2                	ld	s1,8(sp)
    800010fc:	6902                	ld	s2,0(sp)
    800010fe:	6105                	addi	sp,sp,32
    80001100:	8082                	ret

0000000080001102 <freeproc>:
{
    80001102:	1101                	addi	sp,sp,-32
    80001104:	ec06                	sd	ra,24(sp)
    80001106:	e822                	sd	s0,16(sp)
    80001108:	e426                	sd	s1,8(sp)
    8000110a:	1000                	addi	s0,sp,32
    8000110c:	84aa                	mv	s1,a0
  if(p->trapframe)
    8000110e:	6d28                	ld	a0,88(a0)
    80001110:	c509                	beqz	a0,8000111a <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001112:	fffff097          	auipc	ra,0xfffff
    80001116:	f0a080e7          	jalr	-246(ra) # 8000001c <kfree>
  p->trapframe = 0;
    8000111a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    8000111e:	68a8                	ld	a0,80(s1)
    80001120:	c511                	beqz	a0,8000112c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001122:	64ac                	ld	a1,72(s1)
    80001124:	00000097          	auipc	ra,0x0
    80001128:	f8c080e7          	jalr	-116(ra) # 800010b0 <proc_freepagetable>
  p->pagetable = 0;
    8000112c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001130:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001134:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001138:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    8000113c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001140:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001144:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001148:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    8000114c:	0004ac23          	sw	zero,24(s1)
}
    80001150:	60e2                	ld	ra,24(sp)
    80001152:	6442                	ld	s0,16(sp)
    80001154:	64a2                	ld	s1,8(sp)
    80001156:	6105                	addi	sp,sp,32
    80001158:	8082                	ret

000000008000115a <allocproc>:
{
    8000115a:	1101                	addi	sp,sp,-32
    8000115c:	ec06                	sd	ra,24(sp)
    8000115e:	e822                	sd	s0,16(sp)
    80001160:	e426                	sd	s1,8(sp)
    80001162:	e04a                	sd	s2,0(sp)
    80001164:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001166:	00008497          	auipc	s1,0x8
    8000116a:	31a48493          	addi	s1,s1,794 # 80009480 <proc>
    8000116e:	0000e917          	auipc	s2,0xe
    80001172:	d1290913          	addi	s2,s2,-750 # 8000ee80 <tickslock>
    acquire(&p->lock);
    80001176:	8526                	mv	a0,s1
    80001178:	00005097          	auipc	ra,0x5
    8000117c:	144080e7          	jalr	324(ra) # 800062bc <acquire>
    if(p->state == UNUSED) {
    80001180:	4c9c                	lw	a5,24(s1)
    80001182:	cf81                	beqz	a5,8000119a <allocproc+0x40>
      release(&p->lock);
    80001184:	8526                	mv	a0,s1
    80001186:	00005097          	auipc	ra,0x5
    8000118a:	1ea080e7          	jalr	490(ra) # 80006370 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000118e:	16848493          	addi	s1,s1,360
    80001192:	ff2492e3          	bne	s1,s2,80001176 <allocproc+0x1c>
  return 0;
    80001196:	4481                	li	s1,0
    80001198:	a889                	j	800011ea <allocproc+0x90>
  p->pid = allocpid();
    8000119a:	00000097          	auipc	ra,0x0
    8000119e:	e34080e7          	jalr	-460(ra) # 80000fce <allocpid>
    800011a2:	d888                	sw	a0,48(s1)
  p->state = USED;
    800011a4:	4785                	li	a5,1
    800011a6:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800011a8:	fffff097          	auipc	ra,0xfffff
    800011ac:	f8a080e7          	jalr	-118(ra) # 80000132 <kalloc>
    800011b0:	892a                	mv	s2,a0
    800011b2:	eca8                	sd	a0,88(s1)
    800011b4:	c131                	beqz	a0,800011f8 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    800011b6:	8526                	mv	a0,s1
    800011b8:	00000097          	auipc	ra,0x0
    800011bc:	e5c080e7          	jalr	-420(ra) # 80001014 <proc_pagetable>
    800011c0:	892a                	mv	s2,a0
    800011c2:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800011c4:	c531                	beqz	a0,80001210 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    800011c6:	07000613          	li	a2,112
    800011ca:	4581                	li	a1,0
    800011cc:	06048513          	addi	a0,s1,96
    800011d0:	fffff097          	auipc	ra,0xfffff
    800011d4:	ff0080e7          	jalr	-16(ra) # 800001c0 <memset>
  p->context.ra = (uint64)forkret;
    800011d8:	00000797          	auipc	a5,0x0
    800011dc:	db078793          	addi	a5,a5,-592 # 80000f88 <forkret>
    800011e0:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800011e2:	60bc                	ld	a5,64(s1)
    800011e4:	6705                	lui	a4,0x1
    800011e6:	97ba                	add	a5,a5,a4
    800011e8:	f4bc                	sd	a5,104(s1)
}
    800011ea:	8526                	mv	a0,s1
    800011ec:	60e2                	ld	ra,24(sp)
    800011ee:	6442                	ld	s0,16(sp)
    800011f0:	64a2                	ld	s1,8(sp)
    800011f2:	6902                	ld	s2,0(sp)
    800011f4:	6105                	addi	sp,sp,32
    800011f6:	8082                	ret
    freeproc(p);
    800011f8:	8526                	mv	a0,s1
    800011fa:	00000097          	auipc	ra,0x0
    800011fe:	f08080e7          	jalr	-248(ra) # 80001102 <freeproc>
    release(&p->lock);
    80001202:	8526                	mv	a0,s1
    80001204:	00005097          	auipc	ra,0x5
    80001208:	16c080e7          	jalr	364(ra) # 80006370 <release>
    return 0;
    8000120c:	84ca                	mv	s1,s2
    8000120e:	bff1                	j	800011ea <allocproc+0x90>
    freeproc(p);
    80001210:	8526                	mv	a0,s1
    80001212:	00000097          	auipc	ra,0x0
    80001216:	ef0080e7          	jalr	-272(ra) # 80001102 <freeproc>
    release(&p->lock);
    8000121a:	8526                	mv	a0,s1
    8000121c:	00005097          	auipc	ra,0x5
    80001220:	154080e7          	jalr	340(ra) # 80006370 <release>
    return 0;
    80001224:	84ca                	mv	s1,s2
    80001226:	b7d1                	j	800011ea <allocproc+0x90>

0000000080001228 <userinit>:
{
    80001228:	1101                	addi	sp,sp,-32
    8000122a:	ec06                	sd	ra,24(sp)
    8000122c:	e822                	sd	s0,16(sp)
    8000122e:	e426                	sd	s1,8(sp)
    80001230:	1000                	addi	s0,sp,32
  p = allocproc();
    80001232:	00000097          	auipc	ra,0x0
    80001236:	f28080e7          	jalr	-216(ra) # 8000115a <allocproc>
    8000123a:	84aa                	mv	s1,a0
  initproc = p;
    8000123c:	00008797          	auipc	a5,0x8
    80001240:	dca7ba23          	sd	a0,-556(a5) # 80009010 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001244:	03400613          	li	a2,52
    80001248:	00007597          	auipc	a1,0x7
    8000124c:	5d858593          	addi	a1,a1,1496 # 80008820 <initcode>
    80001250:	6928                	ld	a0,80(a0)
    80001252:	fffff097          	auipc	ra,0xfffff
    80001256:	6ba080e7          	jalr	1722(ra) # 8000090c <uvminit>
  p->sz = PGSIZE;
    8000125a:	6785                	lui	a5,0x1
    8000125c:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    8000125e:	6cb8                	ld	a4,88(s1)
    80001260:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001264:	6cb8                	ld	a4,88(s1)
    80001266:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001268:	4641                	li	a2,16
    8000126a:	00007597          	auipc	a1,0x7
    8000126e:	f1658593          	addi	a1,a1,-234 # 80008180 <etext+0x180>
    80001272:	15848513          	addi	a0,s1,344
    80001276:	fffff097          	auipc	ra,0xfffff
    8000127a:	09c080e7          	jalr	156(ra) # 80000312 <safestrcpy>
  p->cwd = namei("/");
    8000127e:	00007517          	auipc	a0,0x7
    80001282:	f1250513          	addi	a0,a0,-238 # 80008190 <etext+0x190>
    80001286:	00002097          	auipc	ra,0x2
    8000128a:	0ee080e7          	jalr	238(ra) # 80003374 <namei>
    8000128e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001292:	478d                	li	a5,3
    80001294:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001296:	8526                	mv	a0,s1
    80001298:	00005097          	auipc	ra,0x5
    8000129c:	0d8080e7          	jalr	216(ra) # 80006370 <release>
}
    800012a0:	60e2                	ld	ra,24(sp)
    800012a2:	6442                	ld	s0,16(sp)
    800012a4:	64a2                	ld	s1,8(sp)
    800012a6:	6105                	addi	sp,sp,32
    800012a8:	8082                	ret

00000000800012aa <growproc>:
{
    800012aa:	1101                	addi	sp,sp,-32
    800012ac:	ec06                	sd	ra,24(sp)
    800012ae:	e822                	sd	s0,16(sp)
    800012b0:	e426                	sd	s1,8(sp)
    800012b2:	e04a                	sd	s2,0(sp)
    800012b4:	1000                	addi	s0,sp,32
    800012b6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800012b8:	00000097          	auipc	ra,0x0
    800012bc:	c98080e7          	jalr	-872(ra) # 80000f50 <myproc>
    800012c0:	892a                	mv	s2,a0
  sz = p->sz;
    800012c2:	652c                	ld	a1,72(a0)
    800012c4:	0005861b          	sext.w	a2,a1
  if(n > 0){
    800012c8:	00904f63          	bgtz	s1,800012e6 <growproc+0x3c>
  } else if(n < 0){
    800012cc:	0204cc63          	bltz	s1,80001304 <growproc+0x5a>
  p->sz = sz;
    800012d0:	1602                	slli	a2,a2,0x20
    800012d2:	9201                	srli	a2,a2,0x20
    800012d4:	04c93423          	sd	a2,72(s2)
  return 0;
    800012d8:	4501                	li	a0,0
}
    800012da:	60e2                	ld	ra,24(sp)
    800012dc:	6442                	ld	s0,16(sp)
    800012de:	64a2                	ld	s1,8(sp)
    800012e0:	6902                	ld	s2,0(sp)
    800012e2:	6105                	addi	sp,sp,32
    800012e4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    800012e6:	9e25                	addw	a2,a2,s1
    800012e8:	1602                	slli	a2,a2,0x20
    800012ea:	9201                	srli	a2,a2,0x20
    800012ec:	1582                	slli	a1,a1,0x20
    800012ee:	9181                	srli	a1,a1,0x20
    800012f0:	6928                	ld	a0,80(a0)
    800012f2:	fffff097          	auipc	ra,0xfffff
    800012f6:	6d4080e7          	jalr	1748(ra) # 800009c6 <uvmalloc>
    800012fa:	0005061b          	sext.w	a2,a0
    800012fe:	fa69                	bnez	a2,800012d0 <growproc+0x26>
      return -1;
    80001300:	557d                	li	a0,-1
    80001302:	bfe1                	j	800012da <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001304:	9e25                	addw	a2,a2,s1
    80001306:	1602                	slli	a2,a2,0x20
    80001308:	9201                	srli	a2,a2,0x20
    8000130a:	1582                	slli	a1,a1,0x20
    8000130c:	9181                	srli	a1,a1,0x20
    8000130e:	6928                	ld	a0,80(a0)
    80001310:	fffff097          	auipc	ra,0xfffff
    80001314:	66e080e7          	jalr	1646(ra) # 8000097e <uvmdealloc>
    80001318:	0005061b          	sext.w	a2,a0
    8000131c:	bf55                	j	800012d0 <growproc+0x26>

000000008000131e <fork>:
{
    8000131e:	7179                	addi	sp,sp,-48
    80001320:	f406                	sd	ra,40(sp)
    80001322:	f022                	sd	s0,32(sp)
    80001324:	ec26                	sd	s1,24(sp)
    80001326:	e84a                	sd	s2,16(sp)
    80001328:	e44e                	sd	s3,8(sp)
    8000132a:	e052                	sd	s4,0(sp)
    8000132c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000132e:	00000097          	auipc	ra,0x0
    80001332:	c22080e7          	jalr	-990(ra) # 80000f50 <myproc>
    80001336:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001338:	00000097          	auipc	ra,0x0
    8000133c:	e22080e7          	jalr	-478(ra) # 8000115a <allocproc>
    80001340:	10050b63          	beqz	a0,80001456 <fork+0x138>
    80001344:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001346:	04893603          	ld	a2,72(s2)
    8000134a:	692c                	ld	a1,80(a0)
    8000134c:	05093503          	ld	a0,80(s2)
    80001350:	fffff097          	auipc	ra,0xfffff
    80001354:	7c2080e7          	jalr	1986(ra) # 80000b12 <uvmcopy>
    80001358:	04054663          	bltz	a0,800013a4 <fork+0x86>
  np->sz = p->sz;
    8000135c:	04893783          	ld	a5,72(s2)
    80001360:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001364:	05893683          	ld	a3,88(s2)
    80001368:	87b6                	mv	a5,a3
    8000136a:	0589b703          	ld	a4,88(s3)
    8000136e:	12068693          	addi	a3,a3,288
    80001372:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001376:	6788                	ld	a0,8(a5)
    80001378:	6b8c                	ld	a1,16(a5)
    8000137a:	6f90                	ld	a2,24(a5)
    8000137c:	01073023          	sd	a6,0(a4)
    80001380:	e708                	sd	a0,8(a4)
    80001382:	eb0c                	sd	a1,16(a4)
    80001384:	ef10                	sd	a2,24(a4)
    80001386:	02078793          	addi	a5,a5,32
    8000138a:	02070713          	addi	a4,a4,32
    8000138e:	fed792e3          	bne	a5,a3,80001372 <fork+0x54>
  np->trapframe->a0 = 0;
    80001392:	0589b783          	ld	a5,88(s3)
    80001396:	0607b823          	sd	zero,112(a5)
    8000139a:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    8000139e:	15000a13          	li	s4,336
    800013a2:	a03d                	j	800013d0 <fork+0xb2>
    freeproc(np);
    800013a4:	854e                	mv	a0,s3
    800013a6:	00000097          	auipc	ra,0x0
    800013aa:	d5c080e7          	jalr	-676(ra) # 80001102 <freeproc>
    release(&np->lock);
    800013ae:	854e                	mv	a0,s3
    800013b0:	00005097          	auipc	ra,0x5
    800013b4:	fc0080e7          	jalr	-64(ra) # 80006370 <release>
    return -1;
    800013b8:	5a7d                	li	s4,-1
    800013ba:	a069                	j	80001444 <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    800013bc:	00002097          	auipc	ra,0x2
    800013c0:	64e080e7          	jalr	1614(ra) # 80003a0a <filedup>
    800013c4:	009987b3          	add	a5,s3,s1
    800013c8:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    800013ca:	04a1                	addi	s1,s1,8
    800013cc:	01448763          	beq	s1,s4,800013da <fork+0xbc>
    if(p->ofile[i])
    800013d0:	009907b3          	add	a5,s2,s1
    800013d4:	6388                	ld	a0,0(a5)
    800013d6:	f17d                	bnez	a0,800013bc <fork+0x9e>
    800013d8:	bfcd                	j	800013ca <fork+0xac>
  np->cwd = idup(p->cwd);
    800013da:	15093503          	ld	a0,336(s2)
    800013de:	00001097          	auipc	ra,0x1
    800013e2:	7a2080e7          	jalr	1954(ra) # 80002b80 <idup>
    800013e6:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800013ea:	4641                	li	a2,16
    800013ec:	15890593          	addi	a1,s2,344
    800013f0:	15898513          	addi	a0,s3,344
    800013f4:	fffff097          	auipc	ra,0xfffff
    800013f8:	f1e080e7          	jalr	-226(ra) # 80000312 <safestrcpy>
  pid = np->pid;
    800013fc:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001400:	854e                	mv	a0,s3
    80001402:	00005097          	auipc	ra,0x5
    80001406:	f6e080e7          	jalr	-146(ra) # 80006370 <release>
  acquire(&wait_lock);
    8000140a:	00008497          	auipc	s1,0x8
    8000140e:	c5e48493          	addi	s1,s1,-930 # 80009068 <wait_lock>
    80001412:	8526                	mv	a0,s1
    80001414:	00005097          	auipc	ra,0x5
    80001418:	ea8080e7          	jalr	-344(ra) # 800062bc <acquire>
  np->parent = p;
    8000141c:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001420:	8526                	mv	a0,s1
    80001422:	00005097          	auipc	ra,0x5
    80001426:	f4e080e7          	jalr	-178(ra) # 80006370 <release>
  acquire(&np->lock);
    8000142a:	854e                	mv	a0,s3
    8000142c:	00005097          	auipc	ra,0x5
    80001430:	e90080e7          	jalr	-368(ra) # 800062bc <acquire>
  np->state = RUNNABLE;
    80001434:	478d                	li	a5,3
    80001436:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000143a:	854e                	mv	a0,s3
    8000143c:	00005097          	auipc	ra,0x5
    80001440:	f34080e7          	jalr	-204(ra) # 80006370 <release>
}
    80001444:	8552                	mv	a0,s4
    80001446:	70a2                	ld	ra,40(sp)
    80001448:	7402                	ld	s0,32(sp)
    8000144a:	64e2                	ld	s1,24(sp)
    8000144c:	6942                	ld	s2,16(sp)
    8000144e:	69a2                	ld	s3,8(sp)
    80001450:	6a02                	ld	s4,0(sp)
    80001452:	6145                	addi	sp,sp,48
    80001454:	8082                	ret
    return -1;
    80001456:	5a7d                	li	s4,-1
    80001458:	b7f5                	j	80001444 <fork+0x126>

000000008000145a <scheduler>:
{
    8000145a:	7139                	addi	sp,sp,-64
    8000145c:	fc06                	sd	ra,56(sp)
    8000145e:	f822                	sd	s0,48(sp)
    80001460:	f426                	sd	s1,40(sp)
    80001462:	f04a                	sd	s2,32(sp)
    80001464:	ec4e                	sd	s3,24(sp)
    80001466:	e852                	sd	s4,16(sp)
    80001468:	e456                	sd	s5,8(sp)
    8000146a:	e05a                	sd	s6,0(sp)
    8000146c:	0080                	addi	s0,sp,64
    8000146e:	8792                	mv	a5,tp
  int id = r_tp();
    80001470:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001472:	00779a93          	slli	s5,a5,0x7
    80001476:	00008717          	auipc	a4,0x8
    8000147a:	bda70713          	addi	a4,a4,-1062 # 80009050 <pid_lock>
    8000147e:	9756                	add	a4,a4,s5
    80001480:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001484:	00008717          	auipc	a4,0x8
    80001488:	c0470713          	addi	a4,a4,-1020 # 80009088 <cpus+0x8>
    8000148c:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    8000148e:	498d                	li	s3,3
        p->state = RUNNING;
    80001490:	4b11                	li	s6,4
        c->proc = p;
    80001492:	079e                	slli	a5,a5,0x7
    80001494:	00008a17          	auipc	s4,0x8
    80001498:	bbca0a13          	addi	s4,s4,-1092 # 80009050 <pid_lock>
    8000149c:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000149e:	0000e917          	auipc	s2,0xe
    800014a2:	9e290913          	addi	s2,s2,-1566 # 8000ee80 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800014a6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800014aa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800014ae:	10079073          	csrw	sstatus,a5
    800014b2:	00008497          	auipc	s1,0x8
    800014b6:	fce48493          	addi	s1,s1,-50 # 80009480 <proc>
    800014ba:	a03d                	j	800014e8 <scheduler+0x8e>
        p->state = RUNNING;
    800014bc:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    800014c0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800014c4:	06048593          	addi	a1,s1,96
    800014c8:	8556                	mv	a0,s5
    800014ca:	00000097          	auipc	ra,0x0
    800014ce:	640080e7          	jalr	1600(ra) # 80001b0a <swtch>
        c->proc = 0;
    800014d2:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    800014d6:	8526                	mv	a0,s1
    800014d8:	00005097          	auipc	ra,0x5
    800014dc:	e98080e7          	jalr	-360(ra) # 80006370 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800014e0:	16848493          	addi	s1,s1,360
    800014e4:	fd2481e3          	beq	s1,s2,800014a6 <scheduler+0x4c>
      acquire(&p->lock);
    800014e8:	8526                	mv	a0,s1
    800014ea:	00005097          	auipc	ra,0x5
    800014ee:	dd2080e7          	jalr	-558(ra) # 800062bc <acquire>
      if(p->state == RUNNABLE) {
    800014f2:	4c9c                	lw	a5,24(s1)
    800014f4:	ff3791e3          	bne	a5,s3,800014d6 <scheduler+0x7c>
    800014f8:	b7d1                	j	800014bc <scheduler+0x62>

00000000800014fa <sched>:
{
    800014fa:	7179                	addi	sp,sp,-48
    800014fc:	f406                	sd	ra,40(sp)
    800014fe:	f022                	sd	s0,32(sp)
    80001500:	ec26                	sd	s1,24(sp)
    80001502:	e84a                	sd	s2,16(sp)
    80001504:	e44e                	sd	s3,8(sp)
    80001506:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001508:	00000097          	auipc	ra,0x0
    8000150c:	a48080e7          	jalr	-1464(ra) # 80000f50 <myproc>
    80001510:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001512:	00005097          	auipc	ra,0x5
    80001516:	d30080e7          	jalr	-720(ra) # 80006242 <holding>
    8000151a:	c93d                	beqz	a0,80001590 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000151c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000151e:	2781                	sext.w	a5,a5
    80001520:	079e                	slli	a5,a5,0x7
    80001522:	00008717          	auipc	a4,0x8
    80001526:	b2e70713          	addi	a4,a4,-1234 # 80009050 <pid_lock>
    8000152a:	97ba                	add	a5,a5,a4
    8000152c:	0a87a703          	lw	a4,168(a5)
    80001530:	4785                	li	a5,1
    80001532:	06f71763          	bne	a4,a5,800015a0 <sched+0xa6>
  if(p->state == RUNNING)
    80001536:	4c98                	lw	a4,24(s1)
    80001538:	4791                	li	a5,4
    8000153a:	06f70b63          	beq	a4,a5,800015b0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000153e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001542:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001544:	efb5                	bnez	a5,800015c0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001546:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001548:	00008917          	auipc	s2,0x8
    8000154c:	b0890913          	addi	s2,s2,-1272 # 80009050 <pid_lock>
    80001550:	2781                	sext.w	a5,a5
    80001552:	079e                	slli	a5,a5,0x7
    80001554:	97ca                	add	a5,a5,s2
    80001556:	0ac7a983          	lw	s3,172(a5)
    8000155a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000155c:	2781                	sext.w	a5,a5
    8000155e:	079e                	slli	a5,a5,0x7
    80001560:	00008597          	auipc	a1,0x8
    80001564:	b2858593          	addi	a1,a1,-1240 # 80009088 <cpus+0x8>
    80001568:	95be                	add	a1,a1,a5
    8000156a:	06048513          	addi	a0,s1,96
    8000156e:	00000097          	auipc	ra,0x0
    80001572:	59c080e7          	jalr	1436(ra) # 80001b0a <swtch>
    80001576:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001578:	2781                	sext.w	a5,a5
    8000157a:	079e                	slli	a5,a5,0x7
    8000157c:	97ca                	add	a5,a5,s2
    8000157e:	0b37a623          	sw	s3,172(a5)
}
    80001582:	70a2                	ld	ra,40(sp)
    80001584:	7402                	ld	s0,32(sp)
    80001586:	64e2                	ld	s1,24(sp)
    80001588:	6942                	ld	s2,16(sp)
    8000158a:	69a2                	ld	s3,8(sp)
    8000158c:	6145                	addi	sp,sp,48
    8000158e:	8082                	ret
    panic("sched p->lock");
    80001590:	00007517          	auipc	a0,0x7
    80001594:	c0850513          	addi	a0,a0,-1016 # 80008198 <etext+0x198>
    80001598:	00004097          	auipc	ra,0x4
    8000159c:	7da080e7          	jalr	2010(ra) # 80005d72 <panic>
    panic("sched locks");
    800015a0:	00007517          	auipc	a0,0x7
    800015a4:	c0850513          	addi	a0,a0,-1016 # 800081a8 <etext+0x1a8>
    800015a8:	00004097          	auipc	ra,0x4
    800015ac:	7ca080e7          	jalr	1994(ra) # 80005d72 <panic>
    panic("sched running");
    800015b0:	00007517          	auipc	a0,0x7
    800015b4:	c0850513          	addi	a0,a0,-1016 # 800081b8 <etext+0x1b8>
    800015b8:	00004097          	auipc	ra,0x4
    800015bc:	7ba080e7          	jalr	1978(ra) # 80005d72 <panic>
    panic("sched interruptible");
    800015c0:	00007517          	auipc	a0,0x7
    800015c4:	c0850513          	addi	a0,a0,-1016 # 800081c8 <etext+0x1c8>
    800015c8:	00004097          	auipc	ra,0x4
    800015cc:	7aa080e7          	jalr	1962(ra) # 80005d72 <panic>

00000000800015d0 <yield>:
{
    800015d0:	1101                	addi	sp,sp,-32
    800015d2:	ec06                	sd	ra,24(sp)
    800015d4:	e822                	sd	s0,16(sp)
    800015d6:	e426                	sd	s1,8(sp)
    800015d8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800015da:	00000097          	auipc	ra,0x0
    800015de:	976080e7          	jalr	-1674(ra) # 80000f50 <myproc>
    800015e2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800015e4:	00005097          	auipc	ra,0x5
    800015e8:	cd8080e7          	jalr	-808(ra) # 800062bc <acquire>
  p->state = RUNNABLE;
    800015ec:	478d                	li	a5,3
    800015ee:	cc9c                	sw	a5,24(s1)
  sched();
    800015f0:	00000097          	auipc	ra,0x0
    800015f4:	f0a080e7          	jalr	-246(ra) # 800014fa <sched>
  release(&p->lock);
    800015f8:	8526                	mv	a0,s1
    800015fa:	00005097          	auipc	ra,0x5
    800015fe:	d76080e7          	jalr	-650(ra) # 80006370 <release>
}
    80001602:	60e2                	ld	ra,24(sp)
    80001604:	6442                	ld	s0,16(sp)
    80001606:	64a2                	ld	s1,8(sp)
    80001608:	6105                	addi	sp,sp,32
    8000160a:	8082                	ret

000000008000160c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000160c:	7179                	addi	sp,sp,-48
    8000160e:	f406                	sd	ra,40(sp)
    80001610:	f022                	sd	s0,32(sp)
    80001612:	ec26                	sd	s1,24(sp)
    80001614:	e84a                	sd	s2,16(sp)
    80001616:	e44e                	sd	s3,8(sp)
    80001618:	1800                	addi	s0,sp,48
    8000161a:	89aa                	mv	s3,a0
    8000161c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000161e:	00000097          	auipc	ra,0x0
    80001622:	932080e7          	jalr	-1742(ra) # 80000f50 <myproc>
    80001626:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001628:	00005097          	auipc	ra,0x5
    8000162c:	c94080e7          	jalr	-876(ra) # 800062bc <acquire>
  release(lk);
    80001630:	854a                	mv	a0,s2
    80001632:	00005097          	auipc	ra,0x5
    80001636:	d3e080e7          	jalr	-706(ra) # 80006370 <release>

  // Go to sleep.
  p->chan = chan;
    8000163a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000163e:	4789                	li	a5,2
    80001640:	cc9c                	sw	a5,24(s1)

  sched();
    80001642:	00000097          	auipc	ra,0x0
    80001646:	eb8080e7          	jalr	-328(ra) # 800014fa <sched>

  // Tidy up.
  p->chan = 0;
    8000164a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000164e:	8526                	mv	a0,s1
    80001650:	00005097          	auipc	ra,0x5
    80001654:	d20080e7          	jalr	-736(ra) # 80006370 <release>
  acquire(lk);
    80001658:	854a                	mv	a0,s2
    8000165a:	00005097          	auipc	ra,0x5
    8000165e:	c62080e7          	jalr	-926(ra) # 800062bc <acquire>
}
    80001662:	70a2                	ld	ra,40(sp)
    80001664:	7402                	ld	s0,32(sp)
    80001666:	64e2                	ld	s1,24(sp)
    80001668:	6942                	ld	s2,16(sp)
    8000166a:	69a2                	ld	s3,8(sp)
    8000166c:	6145                	addi	sp,sp,48
    8000166e:	8082                	ret

0000000080001670 <wait>:
{
    80001670:	715d                	addi	sp,sp,-80
    80001672:	e486                	sd	ra,72(sp)
    80001674:	e0a2                	sd	s0,64(sp)
    80001676:	fc26                	sd	s1,56(sp)
    80001678:	f84a                	sd	s2,48(sp)
    8000167a:	f44e                	sd	s3,40(sp)
    8000167c:	f052                	sd	s4,32(sp)
    8000167e:	ec56                	sd	s5,24(sp)
    80001680:	e85a                	sd	s6,16(sp)
    80001682:	e45e                	sd	s7,8(sp)
    80001684:	e062                	sd	s8,0(sp)
    80001686:	0880                	addi	s0,sp,80
    80001688:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000168a:	00000097          	auipc	ra,0x0
    8000168e:	8c6080e7          	jalr	-1850(ra) # 80000f50 <myproc>
    80001692:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001694:	00008517          	auipc	a0,0x8
    80001698:	9d450513          	addi	a0,a0,-1580 # 80009068 <wait_lock>
    8000169c:	00005097          	auipc	ra,0x5
    800016a0:	c20080e7          	jalr	-992(ra) # 800062bc <acquire>
    havekids = 0;
    800016a4:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800016a6:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    800016a8:	0000d997          	auipc	s3,0xd
    800016ac:	7d898993          	addi	s3,s3,2008 # 8000ee80 <tickslock>
        havekids = 1;
    800016b0:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800016b2:	00008c17          	auipc	s8,0x8
    800016b6:	9b6c0c13          	addi	s8,s8,-1610 # 80009068 <wait_lock>
    havekids = 0;
    800016ba:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800016bc:	00008497          	auipc	s1,0x8
    800016c0:	dc448493          	addi	s1,s1,-572 # 80009480 <proc>
    800016c4:	a0bd                	j	80001732 <wait+0xc2>
          pid = np->pid;
    800016c6:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800016ca:	000b0e63          	beqz	s6,800016e6 <wait+0x76>
    800016ce:	4691                	li	a3,4
    800016d0:	02c48613          	addi	a2,s1,44
    800016d4:	85da                	mv	a1,s6
    800016d6:	05093503          	ld	a0,80(s2)
    800016da:	fffff097          	auipc	ra,0xfffff
    800016de:	538080e7          	jalr	1336(ra) # 80000c12 <copyout>
    800016e2:	02054563          	bltz	a0,8000170c <wait+0x9c>
          freeproc(np);
    800016e6:	8526                	mv	a0,s1
    800016e8:	00000097          	auipc	ra,0x0
    800016ec:	a1a080e7          	jalr	-1510(ra) # 80001102 <freeproc>
          release(&np->lock);
    800016f0:	8526                	mv	a0,s1
    800016f2:	00005097          	auipc	ra,0x5
    800016f6:	c7e080e7          	jalr	-898(ra) # 80006370 <release>
          release(&wait_lock);
    800016fa:	00008517          	auipc	a0,0x8
    800016fe:	96e50513          	addi	a0,a0,-1682 # 80009068 <wait_lock>
    80001702:	00005097          	auipc	ra,0x5
    80001706:	c6e080e7          	jalr	-914(ra) # 80006370 <release>
          return pid;
    8000170a:	a09d                	j	80001770 <wait+0x100>
            release(&np->lock);
    8000170c:	8526                	mv	a0,s1
    8000170e:	00005097          	auipc	ra,0x5
    80001712:	c62080e7          	jalr	-926(ra) # 80006370 <release>
            release(&wait_lock);
    80001716:	00008517          	auipc	a0,0x8
    8000171a:	95250513          	addi	a0,a0,-1710 # 80009068 <wait_lock>
    8000171e:	00005097          	auipc	ra,0x5
    80001722:	c52080e7          	jalr	-942(ra) # 80006370 <release>
            return -1;
    80001726:	59fd                	li	s3,-1
    80001728:	a0a1                	j	80001770 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    8000172a:	16848493          	addi	s1,s1,360
    8000172e:	03348463          	beq	s1,s3,80001756 <wait+0xe6>
      if(np->parent == p){
    80001732:	7c9c                	ld	a5,56(s1)
    80001734:	ff279be3          	bne	a5,s2,8000172a <wait+0xba>
        acquire(&np->lock);
    80001738:	8526                	mv	a0,s1
    8000173a:	00005097          	auipc	ra,0x5
    8000173e:	b82080e7          	jalr	-1150(ra) # 800062bc <acquire>
        if(np->state == ZOMBIE){
    80001742:	4c9c                	lw	a5,24(s1)
    80001744:	f94781e3          	beq	a5,s4,800016c6 <wait+0x56>
        release(&np->lock);
    80001748:	8526                	mv	a0,s1
    8000174a:	00005097          	auipc	ra,0x5
    8000174e:	c26080e7          	jalr	-986(ra) # 80006370 <release>
        havekids = 1;
    80001752:	8756                	mv	a4,s5
    80001754:	bfd9                	j	8000172a <wait+0xba>
    if(!havekids || p->killed){
    80001756:	c701                	beqz	a4,8000175e <wait+0xee>
    80001758:	02892783          	lw	a5,40(s2)
    8000175c:	c79d                	beqz	a5,8000178a <wait+0x11a>
      release(&wait_lock);
    8000175e:	00008517          	auipc	a0,0x8
    80001762:	90a50513          	addi	a0,a0,-1782 # 80009068 <wait_lock>
    80001766:	00005097          	auipc	ra,0x5
    8000176a:	c0a080e7          	jalr	-1014(ra) # 80006370 <release>
      return -1;
    8000176e:	59fd                	li	s3,-1
}
    80001770:	854e                	mv	a0,s3
    80001772:	60a6                	ld	ra,72(sp)
    80001774:	6406                	ld	s0,64(sp)
    80001776:	74e2                	ld	s1,56(sp)
    80001778:	7942                	ld	s2,48(sp)
    8000177a:	79a2                	ld	s3,40(sp)
    8000177c:	7a02                	ld	s4,32(sp)
    8000177e:	6ae2                	ld	s5,24(sp)
    80001780:	6b42                	ld	s6,16(sp)
    80001782:	6ba2                	ld	s7,8(sp)
    80001784:	6c02                	ld	s8,0(sp)
    80001786:	6161                	addi	sp,sp,80
    80001788:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000178a:	85e2                	mv	a1,s8
    8000178c:	854a                	mv	a0,s2
    8000178e:	00000097          	auipc	ra,0x0
    80001792:	e7e080e7          	jalr	-386(ra) # 8000160c <sleep>
    havekids = 0;
    80001796:	b715                	j	800016ba <wait+0x4a>

0000000080001798 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001798:	7139                	addi	sp,sp,-64
    8000179a:	fc06                	sd	ra,56(sp)
    8000179c:	f822                	sd	s0,48(sp)
    8000179e:	f426                	sd	s1,40(sp)
    800017a0:	f04a                	sd	s2,32(sp)
    800017a2:	ec4e                	sd	s3,24(sp)
    800017a4:	e852                	sd	s4,16(sp)
    800017a6:	e456                	sd	s5,8(sp)
    800017a8:	0080                	addi	s0,sp,64
    800017aa:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800017ac:	00008497          	auipc	s1,0x8
    800017b0:	cd448493          	addi	s1,s1,-812 # 80009480 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800017b4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800017b6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800017b8:	0000d917          	auipc	s2,0xd
    800017bc:	6c890913          	addi	s2,s2,1736 # 8000ee80 <tickslock>
    800017c0:	a821                	j	800017d8 <wakeup+0x40>
        p->state = RUNNABLE;
    800017c2:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    800017c6:	8526                	mv	a0,s1
    800017c8:	00005097          	auipc	ra,0x5
    800017cc:	ba8080e7          	jalr	-1112(ra) # 80006370 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d0:	16848493          	addi	s1,s1,360
    800017d4:	03248463          	beq	s1,s2,800017fc <wakeup+0x64>
    if(p != myproc()){
    800017d8:	fffff097          	auipc	ra,0xfffff
    800017dc:	778080e7          	jalr	1912(ra) # 80000f50 <myproc>
    800017e0:	fea488e3          	beq	s1,a0,800017d0 <wakeup+0x38>
      acquire(&p->lock);
    800017e4:	8526                	mv	a0,s1
    800017e6:	00005097          	auipc	ra,0x5
    800017ea:	ad6080e7          	jalr	-1322(ra) # 800062bc <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800017ee:	4c9c                	lw	a5,24(s1)
    800017f0:	fd379be3          	bne	a5,s3,800017c6 <wakeup+0x2e>
    800017f4:	709c                	ld	a5,32(s1)
    800017f6:	fd4798e3          	bne	a5,s4,800017c6 <wakeup+0x2e>
    800017fa:	b7e1                	j	800017c2 <wakeup+0x2a>
    }
  }
}
    800017fc:	70e2                	ld	ra,56(sp)
    800017fe:	7442                	ld	s0,48(sp)
    80001800:	74a2                	ld	s1,40(sp)
    80001802:	7902                	ld	s2,32(sp)
    80001804:	69e2                	ld	s3,24(sp)
    80001806:	6a42                	ld	s4,16(sp)
    80001808:	6aa2                	ld	s5,8(sp)
    8000180a:	6121                	addi	sp,sp,64
    8000180c:	8082                	ret

000000008000180e <reparent>:
{
    8000180e:	7179                	addi	sp,sp,-48
    80001810:	f406                	sd	ra,40(sp)
    80001812:	f022                	sd	s0,32(sp)
    80001814:	ec26                	sd	s1,24(sp)
    80001816:	e84a                	sd	s2,16(sp)
    80001818:	e44e                	sd	s3,8(sp)
    8000181a:	e052                	sd	s4,0(sp)
    8000181c:	1800                	addi	s0,sp,48
    8000181e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001820:	00008497          	auipc	s1,0x8
    80001824:	c6048493          	addi	s1,s1,-928 # 80009480 <proc>
      pp->parent = initproc;
    80001828:	00007a17          	auipc	s4,0x7
    8000182c:	7e8a0a13          	addi	s4,s4,2024 # 80009010 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001830:	0000d997          	auipc	s3,0xd
    80001834:	65098993          	addi	s3,s3,1616 # 8000ee80 <tickslock>
    80001838:	a029                	j	80001842 <reparent+0x34>
    8000183a:	16848493          	addi	s1,s1,360
    8000183e:	01348d63          	beq	s1,s3,80001858 <reparent+0x4a>
    if(pp->parent == p){
    80001842:	7c9c                	ld	a5,56(s1)
    80001844:	ff279be3          	bne	a5,s2,8000183a <reparent+0x2c>
      pp->parent = initproc;
    80001848:	000a3503          	ld	a0,0(s4)
    8000184c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000184e:	00000097          	auipc	ra,0x0
    80001852:	f4a080e7          	jalr	-182(ra) # 80001798 <wakeup>
    80001856:	b7d5                	j	8000183a <reparent+0x2c>
}
    80001858:	70a2                	ld	ra,40(sp)
    8000185a:	7402                	ld	s0,32(sp)
    8000185c:	64e2                	ld	s1,24(sp)
    8000185e:	6942                	ld	s2,16(sp)
    80001860:	69a2                	ld	s3,8(sp)
    80001862:	6a02                	ld	s4,0(sp)
    80001864:	6145                	addi	sp,sp,48
    80001866:	8082                	ret

0000000080001868 <exit>:
{
    80001868:	7179                	addi	sp,sp,-48
    8000186a:	f406                	sd	ra,40(sp)
    8000186c:	f022                	sd	s0,32(sp)
    8000186e:	ec26                	sd	s1,24(sp)
    80001870:	e84a                	sd	s2,16(sp)
    80001872:	e44e                	sd	s3,8(sp)
    80001874:	e052                	sd	s4,0(sp)
    80001876:	1800                	addi	s0,sp,48
    80001878:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000187a:	fffff097          	auipc	ra,0xfffff
    8000187e:	6d6080e7          	jalr	1750(ra) # 80000f50 <myproc>
    80001882:	89aa                	mv	s3,a0
  if(p == initproc)
    80001884:	00007797          	auipc	a5,0x7
    80001888:	78c7b783          	ld	a5,1932(a5) # 80009010 <initproc>
    8000188c:	0d050493          	addi	s1,a0,208
    80001890:	15050913          	addi	s2,a0,336
    80001894:	02a79363          	bne	a5,a0,800018ba <exit+0x52>
    panic("init exiting");
    80001898:	00007517          	auipc	a0,0x7
    8000189c:	94850513          	addi	a0,a0,-1720 # 800081e0 <etext+0x1e0>
    800018a0:	00004097          	auipc	ra,0x4
    800018a4:	4d2080e7          	jalr	1234(ra) # 80005d72 <panic>
      fileclose(f);
    800018a8:	00002097          	auipc	ra,0x2
    800018ac:	1b4080e7          	jalr	436(ra) # 80003a5c <fileclose>
      p->ofile[fd] = 0;
    800018b0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800018b4:	04a1                	addi	s1,s1,8
    800018b6:	01248563          	beq	s1,s2,800018c0 <exit+0x58>
    if(p->ofile[fd]){
    800018ba:	6088                	ld	a0,0(s1)
    800018bc:	f575                	bnez	a0,800018a8 <exit+0x40>
    800018be:	bfdd                	j	800018b4 <exit+0x4c>
  begin_op();
    800018c0:	00002097          	auipc	ra,0x2
    800018c4:	cd0080e7          	jalr	-816(ra) # 80003590 <begin_op>
  iput(p->cwd);
    800018c8:	1509b503          	ld	a0,336(s3)
    800018cc:	00001097          	auipc	ra,0x1
    800018d0:	4ac080e7          	jalr	1196(ra) # 80002d78 <iput>
  end_op();
    800018d4:	00002097          	auipc	ra,0x2
    800018d8:	d3c080e7          	jalr	-708(ra) # 80003610 <end_op>
  p->cwd = 0;
    800018dc:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800018e0:	00007497          	auipc	s1,0x7
    800018e4:	78848493          	addi	s1,s1,1928 # 80009068 <wait_lock>
    800018e8:	8526                	mv	a0,s1
    800018ea:	00005097          	auipc	ra,0x5
    800018ee:	9d2080e7          	jalr	-1582(ra) # 800062bc <acquire>
  reparent(p);
    800018f2:	854e                	mv	a0,s3
    800018f4:	00000097          	auipc	ra,0x0
    800018f8:	f1a080e7          	jalr	-230(ra) # 8000180e <reparent>
  wakeup(p->parent);
    800018fc:	0389b503          	ld	a0,56(s3)
    80001900:	00000097          	auipc	ra,0x0
    80001904:	e98080e7          	jalr	-360(ra) # 80001798 <wakeup>
  acquire(&p->lock);
    80001908:	854e                	mv	a0,s3
    8000190a:	00005097          	auipc	ra,0x5
    8000190e:	9b2080e7          	jalr	-1614(ra) # 800062bc <acquire>
  p->xstate = status;
    80001912:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001916:	4795                	li	a5,5
    80001918:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000191c:	8526                	mv	a0,s1
    8000191e:	00005097          	auipc	ra,0x5
    80001922:	a52080e7          	jalr	-1454(ra) # 80006370 <release>
  sched();
    80001926:	00000097          	auipc	ra,0x0
    8000192a:	bd4080e7          	jalr	-1068(ra) # 800014fa <sched>
  panic("zombie exit");
    8000192e:	00007517          	auipc	a0,0x7
    80001932:	8c250513          	addi	a0,a0,-1854 # 800081f0 <etext+0x1f0>
    80001936:	00004097          	auipc	ra,0x4
    8000193a:	43c080e7          	jalr	1084(ra) # 80005d72 <panic>

000000008000193e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000193e:	7179                	addi	sp,sp,-48
    80001940:	f406                	sd	ra,40(sp)
    80001942:	f022                	sd	s0,32(sp)
    80001944:	ec26                	sd	s1,24(sp)
    80001946:	e84a                	sd	s2,16(sp)
    80001948:	e44e                	sd	s3,8(sp)
    8000194a:	1800                	addi	s0,sp,48
    8000194c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000194e:	00008497          	auipc	s1,0x8
    80001952:	b3248493          	addi	s1,s1,-1230 # 80009480 <proc>
    80001956:	0000d997          	auipc	s3,0xd
    8000195a:	52a98993          	addi	s3,s3,1322 # 8000ee80 <tickslock>
    acquire(&p->lock);
    8000195e:	8526                	mv	a0,s1
    80001960:	00005097          	auipc	ra,0x5
    80001964:	95c080e7          	jalr	-1700(ra) # 800062bc <acquire>
    if(p->pid == pid){
    80001968:	589c                	lw	a5,48(s1)
    8000196a:	01278d63          	beq	a5,s2,80001984 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000196e:	8526                	mv	a0,s1
    80001970:	00005097          	auipc	ra,0x5
    80001974:	a00080e7          	jalr	-1536(ra) # 80006370 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001978:	16848493          	addi	s1,s1,360
    8000197c:	ff3491e3          	bne	s1,s3,8000195e <kill+0x20>
  }
  return -1;
    80001980:	557d                	li	a0,-1
    80001982:	a829                	j	8000199c <kill+0x5e>
      p->killed = 1;
    80001984:	4785                	li	a5,1
    80001986:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001988:	4c98                	lw	a4,24(s1)
    8000198a:	4789                	li	a5,2
    8000198c:	00f70f63          	beq	a4,a5,800019aa <kill+0x6c>
      release(&p->lock);
    80001990:	8526                	mv	a0,s1
    80001992:	00005097          	auipc	ra,0x5
    80001996:	9de080e7          	jalr	-1570(ra) # 80006370 <release>
      return 0;
    8000199a:	4501                	li	a0,0
}
    8000199c:	70a2                	ld	ra,40(sp)
    8000199e:	7402                	ld	s0,32(sp)
    800019a0:	64e2                	ld	s1,24(sp)
    800019a2:	6942                	ld	s2,16(sp)
    800019a4:	69a2                	ld	s3,8(sp)
    800019a6:	6145                	addi	sp,sp,48
    800019a8:	8082                	ret
        p->state = RUNNABLE;
    800019aa:	478d                	li	a5,3
    800019ac:	cc9c                	sw	a5,24(s1)
    800019ae:	b7cd                	j	80001990 <kill+0x52>

00000000800019b0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800019b0:	7179                	addi	sp,sp,-48
    800019b2:	f406                	sd	ra,40(sp)
    800019b4:	f022                	sd	s0,32(sp)
    800019b6:	ec26                	sd	s1,24(sp)
    800019b8:	e84a                	sd	s2,16(sp)
    800019ba:	e44e                	sd	s3,8(sp)
    800019bc:	e052                	sd	s4,0(sp)
    800019be:	1800                	addi	s0,sp,48
    800019c0:	84aa                	mv	s1,a0
    800019c2:	892e                	mv	s2,a1
    800019c4:	89b2                	mv	s3,a2
    800019c6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800019c8:	fffff097          	auipc	ra,0xfffff
    800019cc:	588080e7          	jalr	1416(ra) # 80000f50 <myproc>
  if(user_dst){
    800019d0:	c08d                	beqz	s1,800019f2 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800019d2:	86d2                	mv	a3,s4
    800019d4:	864e                	mv	a2,s3
    800019d6:	85ca                	mv	a1,s2
    800019d8:	6928                	ld	a0,80(a0)
    800019da:	fffff097          	auipc	ra,0xfffff
    800019de:	238080e7          	jalr	568(ra) # 80000c12 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800019e2:	70a2                	ld	ra,40(sp)
    800019e4:	7402                	ld	s0,32(sp)
    800019e6:	64e2                	ld	s1,24(sp)
    800019e8:	6942                	ld	s2,16(sp)
    800019ea:	69a2                	ld	s3,8(sp)
    800019ec:	6a02                	ld	s4,0(sp)
    800019ee:	6145                	addi	sp,sp,48
    800019f0:	8082                	ret
    memmove((char *)dst, src, len);
    800019f2:	000a061b          	sext.w	a2,s4
    800019f6:	85ce                	mv	a1,s3
    800019f8:	854a                	mv	a0,s2
    800019fa:	fffff097          	auipc	ra,0xfffff
    800019fe:	826080e7          	jalr	-2010(ra) # 80000220 <memmove>
    return 0;
    80001a02:	8526                	mv	a0,s1
    80001a04:	bff9                	j	800019e2 <either_copyout+0x32>

0000000080001a06 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001a06:	7179                	addi	sp,sp,-48
    80001a08:	f406                	sd	ra,40(sp)
    80001a0a:	f022                	sd	s0,32(sp)
    80001a0c:	ec26                	sd	s1,24(sp)
    80001a0e:	e84a                	sd	s2,16(sp)
    80001a10:	e44e                	sd	s3,8(sp)
    80001a12:	e052                	sd	s4,0(sp)
    80001a14:	1800                	addi	s0,sp,48
    80001a16:	892a                	mv	s2,a0
    80001a18:	84ae                	mv	s1,a1
    80001a1a:	89b2                	mv	s3,a2
    80001a1c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001a1e:	fffff097          	auipc	ra,0xfffff
    80001a22:	532080e7          	jalr	1330(ra) # 80000f50 <myproc>
  if(user_src){
    80001a26:	c08d                	beqz	s1,80001a48 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80001a28:	86d2                	mv	a3,s4
    80001a2a:	864e                	mv	a2,s3
    80001a2c:	85ca                	mv	a1,s2
    80001a2e:	6928                	ld	a0,80(a0)
    80001a30:	fffff097          	auipc	ra,0xfffff
    80001a34:	26e080e7          	jalr	622(ra) # 80000c9e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001a38:	70a2                	ld	ra,40(sp)
    80001a3a:	7402                	ld	s0,32(sp)
    80001a3c:	64e2                	ld	s1,24(sp)
    80001a3e:	6942                	ld	s2,16(sp)
    80001a40:	69a2                	ld	s3,8(sp)
    80001a42:	6a02                	ld	s4,0(sp)
    80001a44:	6145                	addi	sp,sp,48
    80001a46:	8082                	ret
    memmove(dst, (char*)src, len);
    80001a48:	000a061b          	sext.w	a2,s4
    80001a4c:	85ce                	mv	a1,s3
    80001a4e:	854a                	mv	a0,s2
    80001a50:	ffffe097          	auipc	ra,0xffffe
    80001a54:	7d0080e7          	jalr	2000(ra) # 80000220 <memmove>
    return 0;
    80001a58:	8526                	mv	a0,s1
    80001a5a:	bff9                	j	80001a38 <either_copyin+0x32>

0000000080001a5c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001a5c:	715d                	addi	sp,sp,-80
    80001a5e:	e486                	sd	ra,72(sp)
    80001a60:	e0a2                	sd	s0,64(sp)
    80001a62:	fc26                	sd	s1,56(sp)
    80001a64:	f84a                	sd	s2,48(sp)
    80001a66:	f44e                	sd	s3,40(sp)
    80001a68:	f052                	sd	s4,32(sp)
    80001a6a:	ec56                	sd	s5,24(sp)
    80001a6c:	e85a                	sd	s6,16(sp)
    80001a6e:	e45e                	sd	s7,8(sp)
    80001a70:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001a72:	00006517          	auipc	a0,0x6
    80001a76:	5d650513          	addi	a0,a0,1494 # 80008048 <etext+0x48>
    80001a7a:	00004097          	auipc	ra,0x4
    80001a7e:	342080e7          	jalr	834(ra) # 80005dbc <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a82:	00008497          	auipc	s1,0x8
    80001a86:	b5648493          	addi	s1,s1,-1194 # 800095d8 <proc+0x158>
    80001a8a:	0000d917          	auipc	s2,0xd
    80001a8e:	54e90913          	addi	s2,s2,1358 # 8000efd8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a92:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001a94:	00006997          	auipc	s3,0x6
    80001a98:	76c98993          	addi	s3,s3,1900 # 80008200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    80001a9c:	00006a97          	auipc	s5,0x6
    80001aa0:	76ca8a93          	addi	s5,s5,1900 # 80008208 <etext+0x208>
    printf("\n");
    80001aa4:	00006a17          	auipc	s4,0x6
    80001aa8:	5a4a0a13          	addi	s4,s4,1444 # 80008048 <etext+0x48>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001aac:	00006b97          	auipc	s7,0x6
    80001ab0:	794b8b93          	addi	s7,s7,1940 # 80008240 <states.1718>
    80001ab4:	a00d                	j	80001ad6 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80001ab6:	ed86a583          	lw	a1,-296(a3)
    80001aba:	8556                	mv	a0,s5
    80001abc:	00004097          	auipc	ra,0x4
    80001ac0:	300080e7          	jalr	768(ra) # 80005dbc <printf>
    printf("\n");
    80001ac4:	8552                	mv	a0,s4
    80001ac6:	00004097          	auipc	ra,0x4
    80001aca:	2f6080e7          	jalr	758(ra) # 80005dbc <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001ace:	16848493          	addi	s1,s1,360
    80001ad2:	03248163          	beq	s1,s2,80001af4 <procdump+0x98>
    if(p->state == UNUSED)
    80001ad6:	86a6                	mv	a3,s1
    80001ad8:	ec04a783          	lw	a5,-320(s1)
    80001adc:	dbed                	beqz	a5,80001ace <procdump+0x72>
      state = "???";
    80001ade:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001ae0:	fcfb6be3          	bltu	s6,a5,80001ab6 <procdump+0x5a>
    80001ae4:	1782                	slli	a5,a5,0x20
    80001ae6:	9381                	srli	a5,a5,0x20
    80001ae8:	078e                	slli	a5,a5,0x3
    80001aea:	97de                	add	a5,a5,s7
    80001aec:	6390                	ld	a2,0(a5)
    80001aee:	f661                	bnez	a2,80001ab6 <procdump+0x5a>
      state = "???";
    80001af0:	864e                	mv	a2,s3
    80001af2:	b7d1                	j	80001ab6 <procdump+0x5a>
  }
}
    80001af4:	60a6                	ld	ra,72(sp)
    80001af6:	6406                	ld	s0,64(sp)
    80001af8:	74e2                	ld	s1,56(sp)
    80001afa:	7942                	ld	s2,48(sp)
    80001afc:	79a2                	ld	s3,40(sp)
    80001afe:	7a02                	ld	s4,32(sp)
    80001b00:	6ae2                	ld	s5,24(sp)
    80001b02:	6b42                	ld	s6,16(sp)
    80001b04:	6ba2                	ld	s7,8(sp)
    80001b06:	6161                	addi	sp,sp,80
    80001b08:	8082                	ret

0000000080001b0a <swtch>:
    80001b0a:	00153023          	sd	ra,0(a0)
    80001b0e:	00253423          	sd	sp,8(a0)
    80001b12:	e900                	sd	s0,16(a0)
    80001b14:	ed04                	sd	s1,24(a0)
    80001b16:	03253023          	sd	s2,32(a0)
    80001b1a:	03353423          	sd	s3,40(a0)
    80001b1e:	03453823          	sd	s4,48(a0)
    80001b22:	03553c23          	sd	s5,56(a0)
    80001b26:	05653023          	sd	s6,64(a0)
    80001b2a:	05753423          	sd	s7,72(a0)
    80001b2e:	05853823          	sd	s8,80(a0)
    80001b32:	05953c23          	sd	s9,88(a0)
    80001b36:	07a53023          	sd	s10,96(a0)
    80001b3a:	07b53423          	sd	s11,104(a0)
    80001b3e:	0005b083          	ld	ra,0(a1)
    80001b42:	0085b103          	ld	sp,8(a1)
    80001b46:	6980                	ld	s0,16(a1)
    80001b48:	6d84                	ld	s1,24(a1)
    80001b4a:	0205b903          	ld	s2,32(a1)
    80001b4e:	0285b983          	ld	s3,40(a1)
    80001b52:	0305ba03          	ld	s4,48(a1)
    80001b56:	0385ba83          	ld	s5,56(a1)
    80001b5a:	0405bb03          	ld	s6,64(a1)
    80001b5e:	0485bb83          	ld	s7,72(a1)
    80001b62:	0505bc03          	ld	s8,80(a1)
    80001b66:	0585bc83          	ld	s9,88(a1)
    80001b6a:	0605bd03          	ld	s10,96(a1)
    80001b6e:	0685bd83          	ld	s11,104(a1)
    80001b72:	8082                	ret

0000000080001b74 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001b74:	1141                	addi	sp,sp,-16
    80001b76:	e406                	sd	ra,8(sp)
    80001b78:	e022                	sd	s0,0(sp)
    80001b7a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001b7c:	00006597          	auipc	a1,0x6
    80001b80:	6f458593          	addi	a1,a1,1780 # 80008270 <states.1718+0x30>
    80001b84:	0000d517          	auipc	a0,0xd
    80001b88:	2fc50513          	addi	a0,a0,764 # 8000ee80 <tickslock>
    80001b8c:	00004097          	auipc	ra,0x4
    80001b90:	6a0080e7          	jalr	1696(ra) # 8000622c <initlock>
}
    80001b94:	60a2                	ld	ra,8(sp)
    80001b96:	6402                	ld	s0,0(sp)
    80001b98:	0141                	addi	sp,sp,16
    80001b9a:	8082                	ret

0000000080001b9c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001b9c:	1141                	addi	sp,sp,-16
    80001b9e:	e422                	sd	s0,8(sp)
    80001ba0:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001ba2:	00003797          	auipc	a5,0x3
    80001ba6:	4ce78793          	addi	a5,a5,1230 # 80005070 <kernelvec>
    80001baa:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001bae:	6422                	ld	s0,8(sp)
    80001bb0:	0141                	addi	sp,sp,16
    80001bb2:	8082                	ret

0000000080001bb4 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001bb4:	1141                	addi	sp,sp,-16
    80001bb6:	e406                	sd	ra,8(sp)
    80001bb8:	e022                	sd	s0,0(sp)
    80001bba:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001bbc:	fffff097          	auipc	ra,0xfffff
    80001bc0:	394080e7          	jalr	916(ra) # 80000f50 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001bc4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001bc8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001bca:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80001bce:	00005617          	auipc	a2,0x5
    80001bd2:	43260613          	addi	a2,a2,1074 # 80007000 <_trampoline>
    80001bd6:	00005697          	auipc	a3,0x5
    80001bda:	42a68693          	addi	a3,a3,1066 # 80007000 <_trampoline>
    80001bde:	8e91                	sub	a3,a3,a2
    80001be0:	040007b7          	lui	a5,0x4000
    80001be4:	17fd                	addi	a5,a5,-1
    80001be6:	07b2                	slli	a5,a5,0xc
    80001be8:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001bea:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001bee:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001bf0:	180026f3          	csrr	a3,satp
    80001bf4:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001bf6:	6d38                	ld	a4,88(a0)
    80001bf8:	6134                	ld	a3,64(a0)
    80001bfa:	6585                	lui	a1,0x1
    80001bfc:	96ae                	add	a3,a3,a1
    80001bfe:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001c00:	6d38                	ld	a4,88(a0)
    80001c02:	00000697          	auipc	a3,0x0
    80001c06:	13868693          	addi	a3,a3,312 # 80001d3a <usertrap>
    80001c0a:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001c0c:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c0e:	8692                	mv	a3,tp
    80001c10:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c12:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001c16:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001c1a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c1e:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001c22:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001c24:	6f18                	ld	a4,24(a4)
    80001c26:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001c2a:	692c                	ld	a1,80(a0)
    80001c2c:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80001c2e:	00005717          	auipc	a4,0x5
    80001c32:	46270713          	addi	a4,a4,1122 # 80007090 <userret>
    80001c36:	8f11                	sub	a4,a4,a2
    80001c38:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80001c3a:	577d                	li	a4,-1
    80001c3c:	177e                	slli	a4,a4,0x3f
    80001c3e:	8dd9                	or	a1,a1,a4
    80001c40:	02000537          	lui	a0,0x2000
    80001c44:	157d                	addi	a0,a0,-1
    80001c46:	0536                	slli	a0,a0,0xd
    80001c48:	9782                	jalr	a5
}
    80001c4a:	60a2                	ld	ra,8(sp)
    80001c4c:	6402                	ld	s0,0(sp)
    80001c4e:	0141                	addi	sp,sp,16
    80001c50:	8082                	ret

0000000080001c52 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001c52:	1101                	addi	sp,sp,-32
    80001c54:	ec06                	sd	ra,24(sp)
    80001c56:	e822                	sd	s0,16(sp)
    80001c58:	e426                	sd	s1,8(sp)
    80001c5a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80001c5c:	0000d497          	auipc	s1,0xd
    80001c60:	22448493          	addi	s1,s1,548 # 8000ee80 <tickslock>
    80001c64:	8526                	mv	a0,s1
    80001c66:	00004097          	auipc	ra,0x4
    80001c6a:	656080e7          	jalr	1622(ra) # 800062bc <acquire>
  ticks++;
    80001c6e:	00007517          	auipc	a0,0x7
    80001c72:	3aa50513          	addi	a0,a0,938 # 80009018 <ticks>
    80001c76:	411c                	lw	a5,0(a0)
    80001c78:	2785                	addiw	a5,a5,1
    80001c7a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80001c7c:	00000097          	auipc	ra,0x0
    80001c80:	b1c080e7          	jalr	-1252(ra) # 80001798 <wakeup>
  release(&tickslock);
    80001c84:	8526                	mv	a0,s1
    80001c86:	00004097          	auipc	ra,0x4
    80001c8a:	6ea080e7          	jalr	1770(ra) # 80006370 <release>
}
    80001c8e:	60e2                	ld	ra,24(sp)
    80001c90:	6442                	ld	s0,16(sp)
    80001c92:	64a2                	ld	s1,8(sp)
    80001c94:	6105                	addi	sp,sp,32
    80001c96:	8082                	ret

0000000080001c98 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001c98:	1101                	addi	sp,sp,-32
    80001c9a:	ec06                	sd	ra,24(sp)
    80001c9c:	e822                	sd	s0,16(sp)
    80001c9e:	e426                	sd	s1,8(sp)
    80001ca0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001ca2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80001ca6:	00074d63          	bltz	a4,80001cc0 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80001caa:	57fd                	li	a5,-1
    80001cac:	17fe                	slli	a5,a5,0x3f
    80001cae:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80001cb0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80001cb2:	06f70363          	beq	a4,a5,80001d18 <devintr+0x80>
  }
}
    80001cb6:	60e2                	ld	ra,24(sp)
    80001cb8:	6442                	ld	s0,16(sp)
    80001cba:	64a2                	ld	s1,8(sp)
    80001cbc:	6105                	addi	sp,sp,32
    80001cbe:	8082                	ret
     (scause & 0xff) == 9){
    80001cc0:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80001cc4:	46a5                	li	a3,9
    80001cc6:	fed792e3          	bne	a5,a3,80001caa <devintr+0x12>
    int irq = plic_claim();
    80001cca:	00003097          	auipc	ra,0x3
    80001cce:	4ae080e7          	jalr	1198(ra) # 80005178 <plic_claim>
    80001cd2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001cd4:	47a9                	li	a5,10
    80001cd6:	02f50763          	beq	a0,a5,80001d04 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80001cda:	4785                	li	a5,1
    80001cdc:	02f50963          	beq	a0,a5,80001d0e <devintr+0x76>
    return 1;
    80001ce0:	4505                	li	a0,1
    } else if(irq){
    80001ce2:	d8f1                	beqz	s1,80001cb6 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80001ce4:	85a6                	mv	a1,s1
    80001ce6:	00006517          	auipc	a0,0x6
    80001cea:	59250513          	addi	a0,a0,1426 # 80008278 <states.1718+0x38>
    80001cee:	00004097          	auipc	ra,0x4
    80001cf2:	0ce080e7          	jalr	206(ra) # 80005dbc <printf>
      plic_complete(irq);
    80001cf6:	8526                	mv	a0,s1
    80001cf8:	00003097          	auipc	ra,0x3
    80001cfc:	4a4080e7          	jalr	1188(ra) # 8000519c <plic_complete>
    return 1;
    80001d00:	4505                	li	a0,1
    80001d02:	bf55                	j	80001cb6 <devintr+0x1e>
      uartintr();
    80001d04:	00004097          	auipc	ra,0x4
    80001d08:	4d8080e7          	jalr	1240(ra) # 800061dc <uartintr>
    80001d0c:	b7ed                	j	80001cf6 <devintr+0x5e>
      virtio_disk_intr();
    80001d0e:	00004097          	auipc	ra,0x4
    80001d12:	96e080e7          	jalr	-1682(ra) # 8000567c <virtio_disk_intr>
    80001d16:	b7c5                	j	80001cf6 <devintr+0x5e>
    if(cpuid() == 0){
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	20c080e7          	jalr	524(ra) # 80000f24 <cpuid>
    80001d20:	c901                	beqz	a0,80001d30 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80001d22:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80001d26:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80001d28:	14479073          	csrw	sip,a5
    return 2;
    80001d2c:	4509                	li	a0,2
    80001d2e:	b761                	j	80001cb6 <devintr+0x1e>
      clockintr();
    80001d30:	00000097          	auipc	ra,0x0
    80001d34:	f22080e7          	jalr	-222(ra) # 80001c52 <clockintr>
    80001d38:	b7ed                	j	80001d22 <devintr+0x8a>

0000000080001d3a <usertrap>:
{
    80001d3a:	1101                	addi	sp,sp,-32
    80001d3c:	ec06                	sd	ra,24(sp)
    80001d3e:	e822                	sd	s0,16(sp)
    80001d40:	e426                	sd	s1,8(sp)
    80001d42:	e04a                	sd	s2,0(sp)
    80001d44:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d46:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001d4a:	1007f793          	andi	a5,a5,256
    80001d4e:	e3b9                	bnez	a5,80001d94 <usertrap+0x5a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001d50:	00003797          	auipc	a5,0x3
    80001d54:	32078793          	addi	a5,a5,800 # 80005070 <kernelvec>
    80001d58:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();  // is the process that generated the page fault
    80001d5c:	fffff097          	auipc	ra,0xfffff
    80001d60:	1f4080e7          	jalr	500(ra) # 80000f50 <myproc>
    80001d64:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc(); // is the program counter when it created the page fault 
    80001d66:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d68:	14102773          	csrr	a4,sepc
    80001d6c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d6e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){ // Environment call
    80001d72:	47a1                	li	a5,8
    80001d74:	02f70863          	beq	a4,a5,80001da4 <usertrap+0x6a>
    80001d78:	14202773          	csrr	a4,scause
  } else if(r_scause() == 15) { // Store/AMO page fault
    80001d7c:	47bd                	li	a5,15
    80001d7e:	06f70563          	beq	a4,a5,80001de8 <usertrap+0xae>
  } else if((which_dev = devintr()) != 0){
    80001d82:	00000097          	auipc	ra,0x0
    80001d86:	f16080e7          	jalr	-234(ra) # 80001c98 <devintr>
    80001d8a:	892a                	mv	s2,a0
    80001d8c:	c145                	beqz	a0,80001e2c <usertrap+0xf2>
  if(p->killed)
    80001d8e:	549c                	lw	a5,40(s1)
    80001d90:	cfe9                	beqz	a5,80001e6a <usertrap+0x130>
    80001d92:	a0f9                	j	80001e60 <usertrap+0x126>
    panic("usertrap: not from user mode");
    80001d94:	00006517          	auipc	a0,0x6
    80001d98:	50450513          	addi	a0,a0,1284 # 80008298 <states.1718+0x58>
    80001d9c:	00004097          	auipc	ra,0x4
    80001da0:	fd6080e7          	jalr	-42(ra) # 80005d72 <panic>
    if(p->killed) 
    80001da4:	551c                	lw	a5,40(a0)
    80001da6:	eb9d                	bnez	a5,80001ddc <usertrap+0xa2>
    p->trapframe->epc += 4;
    80001da8:	6cb8                	ld	a4,88(s1)
    80001daa:	6f1c                	ld	a5,24(a4)
    80001dac:	0791                	addi	a5,a5,4
    80001dae:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001db0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001db4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001db8:	10079073          	csrw	sstatus,a5
    syscall();
    80001dbc:	00000097          	auipc	ra,0x0
    80001dc0:	304080e7          	jalr	772(ra) # 800020c0 <syscall>
  if(p->killed)
    80001dc4:	549c                	lw	a5,40(s1)
    80001dc6:	ebd5                	bnez	a5,80001e7a <usertrap+0x140>
  usertrapret();
    80001dc8:	00000097          	auipc	ra,0x0
    80001dcc:	dec080e7          	jalr	-532(ra) # 80001bb4 <usertrapret>
}
    80001dd0:	60e2                	ld	ra,24(sp)
    80001dd2:	6442                	ld	s0,16(sp)
    80001dd4:	64a2                	ld	s1,8(sp)
    80001dd6:	6902                	ld	s2,0(sp)
    80001dd8:	6105                	addi	sp,sp,32
    80001dda:	8082                	ret
      exit(-1);
    80001ddc:	557d                	li	a0,-1
    80001dde:	00000097          	auipc	ra,0x0
    80001de2:	a8a080e7          	jalr	-1398(ra) # 80001868 <exit>
    80001de6:	b7c9                	j	80001da8 <usertrap+0x6e>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001de8:	143025f3          	csrr	a1,stval
    if (cow_f(p->pagetable, r_stval()) == 0) { // r_stval() --> is the virtual address that created this page fault 
    80001dec:	6928                	ld	a0,80(a0)
    80001dee:	fffff097          	auipc	ra,0xfffff
    80001df2:	a2c080e7          	jalr	-1492(ra) # 8000081a <cow_f>
    80001df6:	f579                	bnez	a0,80001dc4 <usertrap+0x8a>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001df8:	142025f3          	csrr	a1,scause
      printf("usertrap(): unexpected scause: %p  pid=%d\n", r_scause(), p->pid);
    80001dfc:	5890                	lw	a2,48(s1)
    80001dfe:	00006517          	auipc	a0,0x6
    80001e02:	4ba50513          	addi	a0,a0,1210 # 800082b8 <states.1718+0x78>
    80001e06:	00004097          	auipc	ra,0x4
    80001e0a:	fb6080e7          	jalr	-74(ra) # 80005dbc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e0e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e12:	14302673          	csrr	a2,stval
      printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001e16:	00006517          	auipc	a0,0x6
    80001e1a:	4d250513          	addi	a0,a0,1234 # 800082e8 <states.1718+0xa8>
    80001e1e:	00004097          	auipc	ra,0x4
    80001e22:	f9e080e7          	jalr	-98(ra) # 80005dbc <printf>
      p->killed = 1;
    80001e26:	4785                	li	a5,1
    80001e28:	d49c                	sw	a5,40(s1)
    80001e2a:	a815                	j	80001e5e <usertrap+0x124>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e2c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause: %p  pid=%d\n", r_scause(), p->pid);
    80001e30:	5890                	lw	a2,48(s1)
    80001e32:	00006517          	auipc	a0,0x6
    80001e36:	48650513          	addi	a0,a0,1158 # 800082b8 <states.1718+0x78>
    80001e3a:	00004097          	auipc	ra,0x4
    80001e3e:	f82080e7          	jalr	-126(ra) # 80005dbc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e42:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e46:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001e4a:	00006517          	auipc	a0,0x6
    80001e4e:	49e50513          	addi	a0,a0,1182 # 800082e8 <states.1718+0xa8>
    80001e52:	00004097          	auipc	ra,0x4
    80001e56:	f6a080e7          	jalr	-150(ra) # 80005dbc <printf>
    p->killed = 1; // if p->killed = 1 -->>> releases "kills" the process because memory is not enough.
    80001e5a:	4785                	li	a5,1
    80001e5c:	d49c                	sw	a5,40(s1)
{
    80001e5e:	4901                	li	s2,0
    exit(-1);
    80001e60:	557d                	li	a0,-1
    80001e62:	00000097          	auipc	ra,0x0
    80001e66:	a06080e7          	jalr	-1530(ra) # 80001868 <exit>
  if(which_dev == 2)
    80001e6a:	4789                	li	a5,2
    80001e6c:	f4f91ee3          	bne	s2,a5,80001dc8 <usertrap+0x8e>
    yield();
    80001e70:	fffff097          	auipc	ra,0xfffff
    80001e74:	760080e7          	jalr	1888(ra) # 800015d0 <yield>
    80001e78:	bf81                	j	80001dc8 <usertrap+0x8e>
  if(p->killed)
    80001e7a:	4901                	li	s2,0
    80001e7c:	b7d5                	j	80001e60 <usertrap+0x126>

0000000080001e7e <kerneltrap>:
{
    80001e7e:	7179                	addi	sp,sp,-48
    80001e80:	f406                	sd	ra,40(sp)
    80001e82:	f022                	sd	s0,32(sp)
    80001e84:	ec26                	sd	s1,24(sp)
    80001e86:	e84a                	sd	s2,16(sp)
    80001e88:	e44e                	sd	s3,8(sp)
    80001e8a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e8c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e90:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e94:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001e98:	1004f793          	andi	a5,s1,256
    80001e9c:	cb85                	beqz	a5,80001ecc <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e9e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ea2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001ea4:	ef85                	bnez	a5,80001edc <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80001ea6:	00000097          	auipc	ra,0x0
    80001eaa:	df2080e7          	jalr	-526(ra) # 80001c98 <devintr>
    80001eae:	cd1d                	beqz	a0,80001eec <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001eb0:	4789                	li	a5,2
    80001eb2:	06f50a63          	beq	a0,a5,80001f26 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001eb6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001eba:	10049073          	csrw	sstatus,s1
}
    80001ebe:	70a2                	ld	ra,40(sp)
    80001ec0:	7402                	ld	s0,32(sp)
    80001ec2:	64e2                	ld	s1,24(sp)
    80001ec4:	6942                	ld	s2,16(sp)
    80001ec6:	69a2                	ld	s3,8(sp)
    80001ec8:	6145                	addi	sp,sp,48
    80001eca:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001ecc:	00006517          	auipc	a0,0x6
    80001ed0:	43c50513          	addi	a0,a0,1084 # 80008308 <states.1718+0xc8>
    80001ed4:	00004097          	auipc	ra,0x4
    80001ed8:	e9e080e7          	jalr	-354(ra) # 80005d72 <panic>
    panic("kerneltrap: interrupts enabled");
    80001edc:	00006517          	auipc	a0,0x6
    80001ee0:	45450513          	addi	a0,a0,1108 # 80008330 <states.1718+0xf0>
    80001ee4:	00004097          	auipc	ra,0x4
    80001ee8:	e8e080e7          	jalr	-370(ra) # 80005d72 <panic>
    printf("scause %p\n", scause);
    80001eec:	85ce                	mv	a1,s3
    80001eee:	00006517          	auipc	a0,0x6
    80001ef2:	46250513          	addi	a0,a0,1122 # 80008350 <states.1718+0x110>
    80001ef6:	00004097          	auipc	ra,0x4
    80001efa:	ec6080e7          	jalr	-314(ra) # 80005dbc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001efe:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001f02:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001f06:	00006517          	auipc	a0,0x6
    80001f0a:	45a50513          	addi	a0,a0,1114 # 80008360 <states.1718+0x120>
    80001f0e:	00004097          	auipc	ra,0x4
    80001f12:	eae080e7          	jalr	-338(ra) # 80005dbc <printf>
    panic("kerneltrap");
    80001f16:	00006517          	auipc	a0,0x6
    80001f1a:	46250513          	addi	a0,a0,1122 # 80008378 <states.1718+0x138>
    80001f1e:	00004097          	auipc	ra,0x4
    80001f22:	e54080e7          	jalr	-428(ra) # 80005d72 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	02a080e7          	jalr	42(ra) # 80000f50 <myproc>
    80001f2e:	d541                	beqz	a0,80001eb6 <kerneltrap+0x38>
    80001f30:	fffff097          	auipc	ra,0xfffff
    80001f34:	020080e7          	jalr	32(ra) # 80000f50 <myproc>
    80001f38:	4d18                	lw	a4,24(a0)
    80001f3a:	4791                	li	a5,4
    80001f3c:	f6f71de3          	bne	a4,a5,80001eb6 <kerneltrap+0x38>
    yield();
    80001f40:	fffff097          	auipc	ra,0xfffff
    80001f44:	690080e7          	jalr	1680(ra) # 800015d0 <yield>
    80001f48:	b7bd                	j	80001eb6 <kerneltrap+0x38>

0000000080001f4a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001f4a:	1101                	addi	sp,sp,-32
    80001f4c:	ec06                	sd	ra,24(sp)
    80001f4e:	e822                	sd	s0,16(sp)
    80001f50:	e426                	sd	s1,8(sp)
    80001f52:	1000                	addi	s0,sp,32
    80001f54:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f56:	fffff097          	auipc	ra,0xfffff
    80001f5a:	ffa080e7          	jalr	-6(ra) # 80000f50 <myproc>
  switch (n) {
    80001f5e:	4795                	li	a5,5
    80001f60:	0497e163          	bltu	a5,s1,80001fa2 <argraw+0x58>
    80001f64:	048a                	slli	s1,s1,0x2
    80001f66:	00006717          	auipc	a4,0x6
    80001f6a:	44a70713          	addi	a4,a4,1098 # 800083b0 <states.1718+0x170>
    80001f6e:	94ba                	add	s1,s1,a4
    80001f70:	409c                	lw	a5,0(s1)
    80001f72:	97ba                	add	a5,a5,a4
    80001f74:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001f76:	6d3c                	ld	a5,88(a0)
    80001f78:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001f7a:	60e2                	ld	ra,24(sp)
    80001f7c:	6442                	ld	s0,16(sp)
    80001f7e:	64a2                	ld	s1,8(sp)
    80001f80:	6105                	addi	sp,sp,32
    80001f82:	8082                	ret
    return p->trapframe->a1;
    80001f84:	6d3c                	ld	a5,88(a0)
    80001f86:	7fa8                	ld	a0,120(a5)
    80001f88:	bfcd                	j	80001f7a <argraw+0x30>
    return p->trapframe->a2;
    80001f8a:	6d3c                	ld	a5,88(a0)
    80001f8c:	63c8                	ld	a0,128(a5)
    80001f8e:	b7f5                	j	80001f7a <argraw+0x30>
    return p->trapframe->a3;
    80001f90:	6d3c                	ld	a5,88(a0)
    80001f92:	67c8                	ld	a0,136(a5)
    80001f94:	b7dd                	j	80001f7a <argraw+0x30>
    return p->trapframe->a4;
    80001f96:	6d3c                	ld	a5,88(a0)
    80001f98:	6bc8                	ld	a0,144(a5)
    80001f9a:	b7c5                	j	80001f7a <argraw+0x30>
    return p->trapframe->a5;
    80001f9c:	6d3c                	ld	a5,88(a0)
    80001f9e:	6fc8                	ld	a0,152(a5)
    80001fa0:	bfe9                	j	80001f7a <argraw+0x30>
  panic("argraw");
    80001fa2:	00006517          	auipc	a0,0x6
    80001fa6:	3e650513          	addi	a0,a0,998 # 80008388 <states.1718+0x148>
    80001faa:	00004097          	auipc	ra,0x4
    80001fae:	dc8080e7          	jalr	-568(ra) # 80005d72 <panic>

0000000080001fb2 <fetchaddr>:
{
    80001fb2:	1101                	addi	sp,sp,-32
    80001fb4:	ec06                	sd	ra,24(sp)
    80001fb6:	e822                	sd	s0,16(sp)
    80001fb8:	e426                	sd	s1,8(sp)
    80001fba:	e04a                	sd	s2,0(sp)
    80001fbc:	1000                	addi	s0,sp,32
    80001fbe:	84aa                	mv	s1,a0
    80001fc0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001fc2:	fffff097          	auipc	ra,0xfffff
    80001fc6:	f8e080e7          	jalr	-114(ra) # 80000f50 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80001fca:	653c                	ld	a5,72(a0)
    80001fcc:	02f4f863          	bgeu	s1,a5,80001ffc <fetchaddr+0x4a>
    80001fd0:	00848713          	addi	a4,s1,8
    80001fd4:	02e7e663          	bltu	a5,a4,80002000 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001fd8:	46a1                	li	a3,8
    80001fda:	8626                	mv	a2,s1
    80001fdc:	85ca                	mv	a1,s2
    80001fde:	6928                	ld	a0,80(a0)
    80001fe0:	fffff097          	auipc	ra,0xfffff
    80001fe4:	cbe080e7          	jalr	-834(ra) # 80000c9e <copyin>
    80001fe8:	00a03533          	snez	a0,a0
    80001fec:	40a00533          	neg	a0,a0
}
    80001ff0:	60e2                	ld	ra,24(sp)
    80001ff2:	6442                	ld	s0,16(sp)
    80001ff4:	64a2                	ld	s1,8(sp)
    80001ff6:	6902                	ld	s2,0(sp)
    80001ff8:	6105                	addi	sp,sp,32
    80001ffa:	8082                	ret
    return -1;
    80001ffc:	557d                	li	a0,-1
    80001ffe:	bfcd                	j	80001ff0 <fetchaddr+0x3e>
    80002000:	557d                	li	a0,-1
    80002002:	b7fd                	j	80001ff0 <fetchaddr+0x3e>

0000000080002004 <fetchstr>:
{
    80002004:	7179                	addi	sp,sp,-48
    80002006:	f406                	sd	ra,40(sp)
    80002008:	f022                	sd	s0,32(sp)
    8000200a:	ec26                	sd	s1,24(sp)
    8000200c:	e84a                	sd	s2,16(sp)
    8000200e:	e44e                	sd	s3,8(sp)
    80002010:	1800                	addi	s0,sp,48
    80002012:	892a                	mv	s2,a0
    80002014:	84ae                	mv	s1,a1
    80002016:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002018:	fffff097          	auipc	ra,0xfffff
    8000201c:	f38080e7          	jalr	-200(ra) # 80000f50 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002020:	86ce                	mv	a3,s3
    80002022:	864a                	mv	a2,s2
    80002024:	85a6                	mv	a1,s1
    80002026:	6928                	ld	a0,80(a0)
    80002028:	fffff097          	auipc	ra,0xfffff
    8000202c:	d02080e7          	jalr	-766(ra) # 80000d2a <copyinstr>
  if(err < 0)
    80002030:	00054763          	bltz	a0,8000203e <fetchstr+0x3a>
  return strlen(buf);
    80002034:	8526                	mv	a0,s1
    80002036:	ffffe097          	auipc	ra,0xffffe
    8000203a:	30e080e7          	jalr	782(ra) # 80000344 <strlen>
}
    8000203e:	70a2                	ld	ra,40(sp)
    80002040:	7402                	ld	s0,32(sp)
    80002042:	64e2                	ld	s1,24(sp)
    80002044:	6942                	ld	s2,16(sp)
    80002046:	69a2                	ld	s3,8(sp)
    80002048:	6145                	addi	sp,sp,48
    8000204a:	8082                	ret

000000008000204c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    8000204c:	1101                	addi	sp,sp,-32
    8000204e:	ec06                	sd	ra,24(sp)
    80002050:	e822                	sd	s0,16(sp)
    80002052:	e426                	sd	s1,8(sp)
    80002054:	1000                	addi	s0,sp,32
    80002056:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002058:	00000097          	auipc	ra,0x0
    8000205c:	ef2080e7          	jalr	-270(ra) # 80001f4a <argraw>
    80002060:	c088                	sw	a0,0(s1)
  return 0;
}
    80002062:	4501                	li	a0,0
    80002064:	60e2                	ld	ra,24(sp)
    80002066:	6442                	ld	s0,16(sp)
    80002068:	64a2                	ld	s1,8(sp)
    8000206a:	6105                	addi	sp,sp,32
    8000206c:	8082                	ret

000000008000206e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    8000206e:	1101                	addi	sp,sp,-32
    80002070:	ec06                	sd	ra,24(sp)
    80002072:	e822                	sd	s0,16(sp)
    80002074:	e426                	sd	s1,8(sp)
    80002076:	1000                	addi	s0,sp,32
    80002078:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000207a:	00000097          	auipc	ra,0x0
    8000207e:	ed0080e7          	jalr	-304(ra) # 80001f4a <argraw>
    80002082:	e088                	sd	a0,0(s1)
  return 0;
}
    80002084:	4501                	li	a0,0
    80002086:	60e2                	ld	ra,24(sp)
    80002088:	6442                	ld	s0,16(sp)
    8000208a:	64a2                	ld	s1,8(sp)
    8000208c:	6105                	addi	sp,sp,32
    8000208e:	8082                	ret

0000000080002090 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002090:	1101                	addi	sp,sp,-32
    80002092:	ec06                	sd	ra,24(sp)
    80002094:	e822                	sd	s0,16(sp)
    80002096:	e426                	sd	s1,8(sp)
    80002098:	e04a                	sd	s2,0(sp)
    8000209a:	1000                	addi	s0,sp,32
    8000209c:	84ae                	mv	s1,a1
    8000209e:	8932                	mv	s2,a2
  *ip = argraw(n);
    800020a0:	00000097          	auipc	ra,0x0
    800020a4:	eaa080e7          	jalr	-342(ra) # 80001f4a <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    800020a8:	864a                	mv	a2,s2
    800020aa:	85a6                	mv	a1,s1
    800020ac:	00000097          	auipc	ra,0x0
    800020b0:	f58080e7          	jalr	-168(ra) # 80002004 <fetchstr>
}
    800020b4:	60e2                	ld	ra,24(sp)
    800020b6:	6442                	ld	s0,16(sp)
    800020b8:	64a2                	ld	s1,8(sp)
    800020ba:	6902                	ld	s2,0(sp)
    800020bc:	6105                	addi	sp,sp,32
    800020be:	8082                	ret

00000000800020c0 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    800020c0:	1101                	addi	sp,sp,-32
    800020c2:	ec06                	sd	ra,24(sp)
    800020c4:	e822                	sd	s0,16(sp)
    800020c6:	e426                	sd	s1,8(sp)
    800020c8:	e04a                	sd	s2,0(sp)
    800020ca:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800020cc:	fffff097          	auipc	ra,0xfffff
    800020d0:	e84080e7          	jalr	-380(ra) # 80000f50 <myproc>
    800020d4:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800020d6:	05853903          	ld	s2,88(a0)
    800020da:	0a893783          	ld	a5,168(s2)
    800020de:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800020e2:	37fd                	addiw	a5,a5,-1
    800020e4:	4751                	li	a4,20
    800020e6:	00f76f63          	bltu	a4,a5,80002104 <syscall+0x44>
    800020ea:	00369713          	slli	a4,a3,0x3
    800020ee:	00006797          	auipc	a5,0x6
    800020f2:	2da78793          	addi	a5,a5,730 # 800083c8 <syscalls>
    800020f6:	97ba                	add	a5,a5,a4
    800020f8:	639c                	ld	a5,0(a5)
    800020fa:	c789                	beqz	a5,80002104 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800020fc:	9782                	jalr	a5
    800020fe:	06a93823          	sd	a0,112(s2)
    80002102:	a839                	j	80002120 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002104:	15848613          	addi	a2,s1,344
    80002108:	588c                	lw	a1,48(s1)
    8000210a:	00006517          	auipc	a0,0x6
    8000210e:	28650513          	addi	a0,a0,646 # 80008390 <states.1718+0x150>
    80002112:	00004097          	auipc	ra,0x4
    80002116:	caa080e7          	jalr	-854(ra) # 80005dbc <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000211a:	6cbc                	ld	a5,88(s1)
    8000211c:	577d                	li	a4,-1
    8000211e:	fbb8                	sd	a4,112(a5)
  }
}
    80002120:	60e2                	ld	ra,24(sp)
    80002122:	6442                	ld	s0,16(sp)
    80002124:	64a2                	ld	s1,8(sp)
    80002126:	6902                	ld	s2,0(sp)
    80002128:	6105                	addi	sp,sp,32
    8000212a:	8082                	ret

000000008000212c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000212c:	1101                	addi	sp,sp,-32
    8000212e:	ec06                	sd	ra,24(sp)
    80002130:	e822                	sd	s0,16(sp)
    80002132:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002134:	fec40593          	addi	a1,s0,-20
    80002138:	4501                	li	a0,0
    8000213a:	00000097          	auipc	ra,0x0
    8000213e:	f12080e7          	jalr	-238(ra) # 8000204c <argint>
    return -1;
    80002142:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002144:	00054963          	bltz	a0,80002156 <sys_exit+0x2a>
  exit(n);
    80002148:	fec42503          	lw	a0,-20(s0)
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	71c080e7          	jalr	1820(ra) # 80001868 <exit>
  return 0;  // not reached
    80002154:	4781                	li	a5,0
}
    80002156:	853e                	mv	a0,a5
    80002158:	60e2                	ld	ra,24(sp)
    8000215a:	6442                	ld	s0,16(sp)
    8000215c:	6105                	addi	sp,sp,32
    8000215e:	8082                	ret

0000000080002160 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002160:	1141                	addi	sp,sp,-16
    80002162:	e406                	sd	ra,8(sp)
    80002164:	e022                	sd	s0,0(sp)
    80002166:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	de8080e7          	jalr	-536(ra) # 80000f50 <myproc>
}
    80002170:	5908                	lw	a0,48(a0)
    80002172:	60a2                	ld	ra,8(sp)
    80002174:	6402                	ld	s0,0(sp)
    80002176:	0141                	addi	sp,sp,16
    80002178:	8082                	ret

000000008000217a <sys_fork>:

uint64
sys_fork(void)
{
    8000217a:	1141                	addi	sp,sp,-16
    8000217c:	e406                	sd	ra,8(sp)
    8000217e:	e022                	sd	s0,0(sp)
    80002180:	0800                	addi	s0,sp,16
  return fork();
    80002182:	fffff097          	auipc	ra,0xfffff
    80002186:	19c080e7          	jalr	412(ra) # 8000131e <fork>
}
    8000218a:	60a2                	ld	ra,8(sp)
    8000218c:	6402                	ld	s0,0(sp)
    8000218e:	0141                	addi	sp,sp,16
    80002190:	8082                	ret

0000000080002192 <sys_wait>:

uint64
sys_wait(void)
{
    80002192:	1101                	addi	sp,sp,-32
    80002194:	ec06                	sd	ra,24(sp)
    80002196:	e822                	sd	s0,16(sp)
    80002198:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    8000219a:	fe840593          	addi	a1,s0,-24
    8000219e:	4501                	li	a0,0
    800021a0:	00000097          	auipc	ra,0x0
    800021a4:	ece080e7          	jalr	-306(ra) # 8000206e <argaddr>
    800021a8:	87aa                	mv	a5,a0
    return -1;
    800021aa:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800021ac:	0007c863          	bltz	a5,800021bc <sys_wait+0x2a>
  return wait(p);
    800021b0:	fe843503          	ld	a0,-24(s0)
    800021b4:	fffff097          	auipc	ra,0xfffff
    800021b8:	4bc080e7          	jalr	1212(ra) # 80001670 <wait>
}
    800021bc:	60e2                	ld	ra,24(sp)
    800021be:	6442                	ld	s0,16(sp)
    800021c0:	6105                	addi	sp,sp,32
    800021c2:	8082                	ret

00000000800021c4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800021c4:	7179                	addi	sp,sp,-48
    800021c6:	f406                	sd	ra,40(sp)
    800021c8:	f022                	sd	s0,32(sp)
    800021ca:	ec26                	sd	s1,24(sp)
    800021cc:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800021ce:	fdc40593          	addi	a1,s0,-36
    800021d2:	4501                	li	a0,0
    800021d4:	00000097          	auipc	ra,0x0
    800021d8:	e78080e7          	jalr	-392(ra) # 8000204c <argint>
    800021dc:	87aa                	mv	a5,a0
    return -1;
    800021de:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    800021e0:	0207c063          	bltz	a5,80002200 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	d6c080e7          	jalr	-660(ra) # 80000f50 <myproc>
    800021ec:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    800021ee:	fdc42503          	lw	a0,-36(s0)
    800021f2:	fffff097          	auipc	ra,0xfffff
    800021f6:	0b8080e7          	jalr	184(ra) # 800012aa <growproc>
    800021fa:	00054863          	bltz	a0,8000220a <sys_sbrk+0x46>
    return -1;
  return addr;
    800021fe:	8526                	mv	a0,s1
}
    80002200:	70a2                	ld	ra,40(sp)
    80002202:	7402                	ld	s0,32(sp)
    80002204:	64e2                	ld	s1,24(sp)
    80002206:	6145                	addi	sp,sp,48
    80002208:	8082                	ret
    return -1;
    8000220a:	557d                	li	a0,-1
    8000220c:	bfd5                	j	80002200 <sys_sbrk+0x3c>

000000008000220e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000220e:	7139                	addi	sp,sp,-64
    80002210:	fc06                	sd	ra,56(sp)
    80002212:	f822                	sd	s0,48(sp)
    80002214:	f426                	sd	s1,40(sp)
    80002216:	f04a                	sd	s2,32(sp)
    80002218:	ec4e                	sd	s3,24(sp)
    8000221a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    8000221c:	fcc40593          	addi	a1,s0,-52
    80002220:	4501                	li	a0,0
    80002222:	00000097          	auipc	ra,0x0
    80002226:	e2a080e7          	jalr	-470(ra) # 8000204c <argint>
    return -1;
    8000222a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000222c:	06054563          	bltz	a0,80002296 <sys_sleep+0x88>
  acquire(&tickslock);
    80002230:	0000d517          	auipc	a0,0xd
    80002234:	c5050513          	addi	a0,a0,-944 # 8000ee80 <tickslock>
    80002238:	00004097          	auipc	ra,0x4
    8000223c:	084080e7          	jalr	132(ra) # 800062bc <acquire>
  ticks0 = ticks;
    80002240:	00007917          	auipc	s2,0x7
    80002244:	dd892903          	lw	s2,-552(s2) # 80009018 <ticks>
  while(ticks - ticks0 < n){
    80002248:	fcc42783          	lw	a5,-52(s0)
    8000224c:	cf85                	beqz	a5,80002284 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000224e:	0000d997          	auipc	s3,0xd
    80002252:	c3298993          	addi	s3,s3,-974 # 8000ee80 <tickslock>
    80002256:	00007497          	auipc	s1,0x7
    8000225a:	dc248493          	addi	s1,s1,-574 # 80009018 <ticks>
    if(myproc()->killed){
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	cf2080e7          	jalr	-782(ra) # 80000f50 <myproc>
    80002266:	551c                	lw	a5,40(a0)
    80002268:	ef9d                	bnez	a5,800022a6 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000226a:	85ce                	mv	a1,s3
    8000226c:	8526                	mv	a0,s1
    8000226e:	fffff097          	auipc	ra,0xfffff
    80002272:	39e080e7          	jalr	926(ra) # 8000160c <sleep>
  while(ticks - ticks0 < n){
    80002276:	409c                	lw	a5,0(s1)
    80002278:	412787bb          	subw	a5,a5,s2
    8000227c:	fcc42703          	lw	a4,-52(s0)
    80002280:	fce7efe3          	bltu	a5,a4,8000225e <sys_sleep+0x50>
  }
  release(&tickslock);
    80002284:	0000d517          	auipc	a0,0xd
    80002288:	bfc50513          	addi	a0,a0,-1028 # 8000ee80 <tickslock>
    8000228c:	00004097          	auipc	ra,0x4
    80002290:	0e4080e7          	jalr	228(ra) # 80006370 <release>
  return 0;
    80002294:	4781                	li	a5,0
}
    80002296:	853e                	mv	a0,a5
    80002298:	70e2                	ld	ra,56(sp)
    8000229a:	7442                	ld	s0,48(sp)
    8000229c:	74a2                	ld	s1,40(sp)
    8000229e:	7902                	ld	s2,32(sp)
    800022a0:	69e2                	ld	s3,24(sp)
    800022a2:	6121                	addi	sp,sp,64
    800022a4:	8082                	ret
      release(&tickslock);
    800022a6:	0000d517          	auipc	a0,0xd
    800022aa:	bda50513          	addi	a0,a0,-1062 # 8000ee80 <tickslock>
    800022ae:	00004097          	auipc	ra,0x4
    800022b2:	0c2080e7          	jalr	194(ra) # 80006370 <release>
      return -1;
    800022b6:	57fd                	li	a5,-1
    800022b8:	bff9                	j	80002296 <sys_sleep+0x88>

00000000800022ba <sys_kill>:

uint64
sys_kill(void)
{
    800022ba:	1101                	addi	sp,sp,-32
    800022bc:	ec06                	sd	ra,24(sp)
    800022be:	e822                	sd	s0,16(sp)
    800022c0:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800022c2:	fec40593          	addi	a1,s0,-20
    800022c6:	4501                	li	a0,0
    800022c8:	00000097          	auipc	ra,0x0
    800022cc:	d84080e7          	jalr	-636(ra) # 8000204c <argint>
    800022d0:	87aa                	mv	a5,a0
    return -1;
    800022d2:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800022d4:	0007c863          	bltz	a5,800022e4 <sys_kill+0x2a>
  return kill(pid);
    800022d8:	fec42503          	lw	a0,-20(s0)
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	662080e7          	jalr	1634(ra) # 8000193e <kill>
}
    800022e4:	60e2                	ld	ra,24(sp)
    800022e6:	6442                	ld	s0,16(sp)
    800022e8:	6105                	addi	sp,sp,32
    800022ea:	8082                	ret

00000000800022ec <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800022ec:	1101                	addi	sp,sp,-32
    800022ee:	ec06                	sd	ra,24(sp)
    800022f0:	e822                	sd	s0,16(sp)
    800022f2:	e426                	sd	s1,8(sp)
    800022f4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800022f6:	0000d517          	auipc	a0,0xd
    800022fa:	b8a50513          	addi	a0,a0,-1142 # 8000ee80 <tickslock>
    800022fe:	00004097          	auipc	ra,0x4
    80002302:	fbe080e7          	jalr	-66(ra) # 800062bc <acquire>
  xticks = ticks;
    80002306:	00007497          	auipc	s1,0x7
    8000230a:	d124a483          	lw	s1,-750(s1) # 80009018 <ticks>
  release(&tickslock);
    8000230e:	0000d517          	auipc	a0,0xd
    80002312:	b7250513          	addi	a0,a0,-1166 # 8000ee80 <tickslock>
    80002316:	00004097          	auipc	ra,0x4
    8000231a:	05a080e7          	jalr	90(ra) # 80006370 <release>
  return xticks;
}
    8000231e:	02049513          	slli	a0,s1,0x20
    80002322:	9101                	srli	a0,a0,0x20
    80002324:	60e2                	ld	ra,24(sp)
    80002326:	6442                	ld	s0,16(sp)
    80002328:	64a2                	ld	s1,8(sp)
    8000232a:	6105                	addi	sp,sp,32
    8000232c:	8082                	ret

000000008000232e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000232e:	7179                	addi	sp,sp,-48
    80002330:	f406                	sd	ra,40(sp)
    80002332:	f022                	sd	s0,32(sp)
    80002334:	ec26                	sd	s1,24(sp)
    80002336:	e84a                	sd	s2,16(sp)
    80002338:	e44e                	sd	s3,8(sp)
    8000233a:	e052                	sd	s4,0(sp)
    8000233c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000233e:	00006597          	auipc	a1,0x6
    80002342:	13a58593          	addi	a1,a1,314 # 80008478 <syscalls+0xb0>
    80002346:	0000d517          	auipc	a0,0xd
    8000234a:	b5250513          	addi	a0,a0,-1198 # 8000ee98 <bcache>
    8000234e:	00004097          	auipc	ra,0x4
    80002352:	ede080e7          	jalr	-290(ra) # 8000622c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002356:	00015797          	auipc	a5,0x15
    8000235a:	b4278793          	addi	a5,a5,-1214 # 80016e98 <bcache+0x8000>
    8000235e:	00015717          	auipc	a4,0x15
    80002362:	da270713          	addi	a4,a4,-606 # 80017100 <bcache+0x8268>
    80002366:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000236a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000236e:	0000d497          	auipc	s1,0xd
    80002372:	b4248493          	addi	s1,s1,-1214 # 8000eeb0 <bcache+0x18>
    b->next = bcache.head.next;
    80002376:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002378:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000237a:	00006a17          	auipc	s4,0x6
    8000237e:	106a0a13          	addi	s4,s4,262 # 80008480 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002382:	2b893783          	ld	a5,696(s2)
    80002386:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002388:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000238c:	85d2                	mv	a1,s4
    8000238e:	01048513          	addi	a0,s1,16
    80002392:	00001097          	auipc	ra,0x1
    80002396:	4bc080e7          	jalr	1212(ra) # 8000384e <initsleeplock>
    bcache.head.next->prev = b;
    8000239a:	2b893783          	ld	a5,696(s2)
    8000239e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800023a0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800023a4:	45848493          	addi	s1,s1,1112
    800023a8:	fd349de3          	bne	s1,s3,80002382 <binit+0x54>
  }
}
    800023ac:	70a2                	ld	ra,40(sp)
    800023ae:	7402                	ld	s0,32(sp)
    800023b0:	64e2                	ld	s1,24(sp)
    800023b2:	6942                	ld	s2,16(sp)
    800023b4:	69a2                	ld	s3,8(sp)
    800023b6:	6a02                	ld	s4,0(sp)
    800023b8:	6145                	addi	sp,sp,48
    800023ba:	8082                	ret

00000000800023bc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800023bc:	7179                	addi	sp,sp,-48
    800023be:	f406                	sd	ra,40(sp)
    800023c0:	f022                	sd	s0,32(sp)
    800023c2:	ec26                	sd	s1,24(sp)
    800023c4:	e84a                	sd	s2,16(sp)
    800023c6:	e44e                	sd	s3,8(sp)
    800023c8:	1800                	addi	s0,sp,48
    800023ca:	89aa                	mv	s3,a0
    800023cc:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800023ce:	0000d517          	auipc	a0,0xd
    800023d2:	aca50513          	addi	a0,a0,-1334 # 8000ee98 <bcache>
    800023d6:	00004097          	auipc	ra,0x4
    800023da:	ee6080e7          	jalr	-282(ra) # 800062bc <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800023de:	00015497          	auipc	s1,0x15
    800023e2:	d724b483          	ld	s1,-654(s1) # 80017150 <bcache+0x82b8>
    800023e6:	00015797          	auipc	a5,0x15
    800023ea:	d1a78793          	addi	a5,a5,-742 # 80017100 <bcache+0x8268>
    800023ee:	02f48f63          	beq	s1,a5,8000242c <bread+0x70>
    800023f2:	873e                	mv	a4,a5
    800023f4:	a021                	j	800023fc <bread+0x40>
    800023f6:	68a4                	ld	s1,80(s1)
    800023f8:	02e48a63          	beq	s1,a4,8000242c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800023fc:	449c                	lw	a5,8(s1)
    800023fe:	ff379ce3          	bne	a5,s3,800023f6 <bread+0x3a>
    80002402:	44dc                	lw	a5,12(s1)
    80002404:	ff2799e3          	bne	a5,s2,800023f6 <bread+0x3a>
      b->refcnt++;
    80002408:	40bc                	lw	a5,64(s1)
    8000240a:	2785                	addiw	a5,a5,1
    8000240c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000240e:	0000d517          	auipc	a0,0xd
    80002412:	a8a50513          	addi	a0,a0,-1398 # 8000ee98 <bcache>
    80002416:	00004097          	auipc	ra,0x4
    8000241a:	f5a080e7          	jalr	-166(ra) # 80006370 <release>
      acquiresleep(&b->lock);
    8000241e:	01048513          	addi	a0,s1,16
    80002422:	00001097          	auipc	ra,0x1
    80002426:	466080e7          	jalr	1126(ra) # 80003888 <acquiresleep>
      return b;
    8000242a:	a8b9                	j	80002488 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000242c:	00015497          	auipc	s1,0x15
    80002430:	d1c4b483          	ld	s1,-740(s1) # 80017148 <bcache+0x82b0>
    80002434:	00015797          	auipc	a5,0x15
    80002438:	ccc78793          	addi	a5,a5,-820 # 80017100 <bcache+0x8268>
    8000243c:	00f48863          	beq	s1,a5,8000244c <bread+0x90>
    80002440:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002442:	40bc                	lw	a5,64(s1)
    80002444:	cf81                	beqz	a5,8000245c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002446:	64a4                	ld	s1,72(s1)
    80002448:	fee49de3          	bne	s1,a4,80002442 <bread+0x86>
  panic("bget: no buffers");
    8000244c:	00006517          	auipc	a0,0x6
    80002450:	03c50513          	addi	a0,a0,60 # 80008488 <syscalls+0xc0>
    80002454:	00004097          	auipc	ra,0x4
    80002458:	91e080e7          	jalr	-1762(ra) # 80005d72 <panic>
      b->dev = dev;
    8000245c:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002460:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002464:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002468:	4785                	li	a5,1
    8000246a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000246c:	0000d517          	auipc	a0,0xd
    80002470:	a2c50513          	addi	a0,a0,-1492 # 8000ee98 <bcache>
    80002474:	00004097          	auipc	ra,0x4
    80002478:	efc080e7          	jalr	-260(ra) # 80006370 <release>
      acquiresleep(&b->lock);
    8000247c:	01048513          	addi	a0,s1,16
    80002480:	00001097          	auipc	ra,0x1
    80002484:	408080e7          	jalr	1032(ra) # 80003888 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002488:	409c                	lw	a5,0(s1)
    8000248a:	cb89                	beqz	a5,8000249c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000248c:	8526                	mv	a0,s1
    8000248e:	70a2                	ld	ra,40(sp)
    80002490:	7402                	ld	s0,32(sp)
    80002492:	64e2                	ld	s1,24(sp)
    80002494:	6942                	ld	s2,16(sp)
    80002496:	69a2                	ld	s3,8(sp)
    80002498:	6145                	addi	sp,sp,48
    8000249a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000249c:	4581                	li	a1,0
    8000249e:	8526                	mv	a0,s1
    800024a0:	00003097          	auipc	ra,0x3
    800024a4:	f06080e7          	jalr	-250(ra) # 800053a6 <virtio_disk_rw>
    b->valid = 1;
    800024a8:	4785                	li	a5,1
    800024aa:	c09c                	sw	a5,0(s1)
  return b;
    800024ac:	b7c5                	j	8000248c <bread+0xd0>

00000000800024ae <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800024ae:	1101                	addi	sp,sp,-32
    800024b0:	ec06                	sd	ra,24(sp)
    800024b2:	e822                	sd	s0,16(sp)
    800024b4:	e426                	sd	s1,8(sp)
    800024b6:	1000                	addi	s0,sp,32
    800024b8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800024ba:	0541                	addi	a0,a0,16
    800024bc:	00001097          	auipc	ra,0x1
    800024c0:	466080e7          	jalr	1126(ra) # 80003922 <holdingsleep>
    800024c4:	cd01                	beqz	a0,800024dc <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800024c6:	4585                	li	a1,1
    800024c8:	8526                	mv	a0,s1
    800024ca:	00003097          	auipc	ra,0x3
    800024ce:	edc080e7          	jalr	-292(ra) # 800053a6 <virtio_disk_rw>
}
    800024d2:	60e2                	ld	ra,24(sp)
    800024d4:	6442                	ld	s0,16(sp)
    800024d6:	64a2                	ld	s1,8(sp)
    800024d8:	6105                	addi	sp,sp,32
    800024da:	8082                	ret
    panic("bwrite");
    800024dc:	00006517          	auipc	a0,0x6
    800024e0:	fc450513          	addi	a0,a0,-60 # 800084a0 <syscalls+0xd8>
    800024e4:	00004097          	auipc	ra,0x4
    800024e8:	88e080e7          	jalr	-1906(ra) # 80005d72 <panic>

00000000800024ec <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800024ec:	1101                	addi	sp,sp,-32
    800024ee:	ec06                	sd	ra,24(sp)
    800024f0:	e822                	sd	s0,16(sp)
    800024f2:	e426                	sd	s1,8(sp)
    800024f4:	e04a                	sd	s2,0(sp)
    800024f6:	1000                	addi	s0,sp,32
    800024f8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800024fa:	01050913          	addi	s2,a0,16
    800024fe:	854a                	mv	a0,s2
    80002500:	00001097          	auipc	ra,0x1
    80002504:	422080e7          	jalr	1058(ra) # 80003922 <holdingsleep>
    80002508:	c92d                	beqz	a0,8000257a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000250a:	854a                	mv	a0,s2
    8000250c:	00001097          	auipc	ra,0x1
    80002510:	3d2080e7          	jalr	978(ra) # 800038de <releasesleep>

  acquire(&bcache.lock);
    80002514:	0000d517          	auipc	a0,0xd
    80002518:	98450513          	addi	a0,a0,-1660 # 8000ee98 <bcache>
    8000251c:	00004097          	auipc	ra,0x4
    80002520:	da0080e7          	jalr	-608(ra) # 800062bc <acquire>
  b->refcnt--;
    80002524:	40bc                	lw	a5,64(s1)
    80002526:	37fd                	addiw	a5,a5,-1
    80002528:	0007871b          	sext.w	a4,a5
    8000252c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000252e:	eb05                	bnez	a4,8000255e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002530:	68bc                	ld	a5,80(s1)
    80002532:	64b8                	ld	a4,72(s1)
    80002534:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002536:	64bc                	ld	a5,72(s1)
    80002538:	68b8                	ld	a4,80(s1)
    8000253a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000253c:	00015797          	auipc	a5,0x15
    80002540:	95c78793          	addi	a5,a5,-1700 # 80016e98 <bcache+0x8000>
    80002544:	2b87b703          	ld	a4,696(a5)
    80002548:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000254a:	00015717          	auipc	a4,0x15
    8000254e:	bb670713          	addi	a4,a4,-1098 # 80017100 <bcache+0x8268>
    80002552:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002554:	2b87b703          	ld	a4,696(a5)
    80002558:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000255a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000255e:	0000d517          	auipc	a0,0xd
    80002562:	93a50513          	addi	a0,a0,-1734 # 8000ee98 <bcache>
    80002566:	00004097          	auipc	ra,0x4
    8000256a:	e0a080e7          	jalr	-502(ra) # 80006370 <release>
}
    8000256e:	60e2                	ld	ra,24(sp)
    80002570:	6442                	ld	s0,16(sp)
    80002572:	64a2                	ld	s1,8(sp)
    80002574:	6902                	ld	s2,0(sp)
    80002576:	6105                	addi	sp,sp,32
    80002578:	8082                	ret
    panic("brelse");
    8000257a:	00006517          	auipc	a0,0x6
    8000257e:	f2e50513          	addi	a0,a0,-210 # 800084a8 <syscalls+0xe0>
    80002582:	00003097          	auipc	ra,0x3
    80002586:	7f0080e7          	jalr	2032(ra) # 80005d72 <panic>

000000008000258a <bpin>:

void
bpin(struct buf *b) {
    8000258a:	1101                	addi	sp,sp,-32
    8000258c:	ec06                	sd	ra,24(sp)
    8000258e:	e822                	sd	s0,16(sp)
    80002590:	e426                	sd	s1,8(sp)
    80002592:	1000                	addi	s0,sp,32
    80002594:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002596:	0000d517          	auipc	a0,0xd
    8000259a:	90250513          	addi	a0,a0,-1790 # 8000ee98 <bcache>
    8000259e:	00004097          	auipc	ra,0x4
    800025a2:	d1e080e7          	jalr	-738(ra) # 800062bc <acquire>
  b->refcnt++;
    800025a6:	40bc                	lw	a5,64(s1)
    800025a8:	2785                	addiw	a5,a5,1
    800025aa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800025ac:	0000d517          	auipc	a0,0xd
    800025b0:	8ec50513          	addi	a0,a0,-1812 # 8000ee98 <bcache>
    800025b4:	00004097          	auipc	ra,0x4
    800025b8:	dbc080e7          	jalr	-580(ra) # 80006370 <release>
}
    800025bc:	60e2                	ld	ra,24(sp)
    800025be:	6442                	ld	s0,16(sp)
    800025c0:	64a2                	ld	s1,8(sp)
    800025c2:	6105                	addi	sp,sp,32
    800025c4:	8082                	ret

00000000800025c6 <bunpin>:

void
bunpin(struct buf *b) {
    800025c6:	1101                	addi	sp,sp,-32
    800025c8:	ec06                	sd	ra,24(sp)
    800025ca:	e822                	sd	s0,16(sp)
    800025cc:	e426                	sd	s1,8(sp)
    800025ce:	1000                	addi	s0,sp,32
    800025d0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800025d2:	0000d517          	auipc	a0,0xd
    800025d6:	8c650513          	addi	a0,a0,-1850 # 8000ee98 <bcache>
    800025da:	00004097          	auipc	ra,0x4
    800025de:	ce2080e7          	jalr	-798(ra) # 800062bc <acquire>
  b->refcnt--;
    800025e2:	40bc                	lw	a5,64(s1)
    800025e4:	37fd                	addiw	a5,a5,-1
    800025e6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800025e8:	0000d517          	auipc	a0,0xd
    800025ec:	8b050513          	addi	a0,a0,-1872 # 8000ee98 <bcache>
    800025f0:	00004097          	auipc	ra,0x4
    800025f4:	d80080e7          	jalr	-640(ra) # 80006370 <release>
}
    800025f8:	60e2                	ld	ra,24(sp)
    800025fa:	6442                	ld	s0,16(sp)
    800025fc:	64a2                	ld	s1,8(sp)
    800025fe:	6105                	addi	sp,sp,32
    80002600:	8082                	ret

0000000080002602 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002602:	1101                	addi	sp,sp,-32
    80002604:	ec06                	sd	ra,24(sp)
    80002606:	e822                	sd	s0,16(sp)
    80002608:	e426                	sd	s1,8(sp)
    8000260a:	e04a                	sd	s2,0(sp)
    8000260c:	1000                	addi	s0,sp,32
    8000260e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002610:	00d5d59b          	srliw	a1,a1,0xd
    80002614:	00015797          	auipc	a5,0x15
    80002618:	f607a783          	lw	a5,-160(a5) # 80017574 <sb+0x1c>
    8000261c:	9dbd                	addw	a1,a1,a5
    8000261e:	00000097          	auipc	ra,0x0
    80002622:	d9e080e7          	jalr	-610(ra) # 800023bc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002626:	0074f713          	andi	a4,s1,7
    8000262a:	4785                	li	a5,1
    8000262c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002630:	14ce                	slli	s1,s1,0x33
    80002632:	90d9                	srli	s1,s1,0x36
    80002634:	00950733          	add	a4,a0,s1
    80002638:	05874703          	lbu	a4,88(a4)
    8000263c:	00e7f6b3          	and	a3,a5,a4
    80002640:	c69d                	beqz	a3,8000266e <bfree+0x6c>
    80002642:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002644:	94aa                	add	s1,s1,a0
    80002646:	fff7c793          	not	a5,a5
    8000264a:	8ff9                	and	a5,a5,a4
    8000264c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80002650:	00001097          	auipc	ra,0x1
    80002654:	118080e7          	jalr	280(ra) # 80003768 <log_write>
  brelse(bp);
    80002658:	854a                	mv	a0,s2
    8000265a:	00000097          	auipc	ra,0x0
    8000265e:	e92080e7          	jalr	-366(ra) # 800024ec <brelse>
}
    80002662:	60e2                	ld	ra,24(sp)
    80002664:	6442                	ld	s0,16(sp)
    80002666:	64a2                	ld	s1,8(sp)
    80002668:	6902                	ld	s2,0(sp)
    8000266a:	6105                	addi	sp,sp,32
    8000266c:	8082                	ret
    panic("freeing free block");
    8000266e:	00006517          	auipc	a0,0x6
    80002672:	e4250513          	addi	a0,a0,-446 # 800084b0 <syscalls+0xe8>
    80002676:	00003097          	auipc	ra,0x3
    8000267a:	6fc080e7          	jalr	1788(ra) # 80005d72 <panic>

000000008000267e <balloc>:
{
    8000267e:	711d                	addi	sp,sp,-96
    80002680:	ec86                	sd	ra,88(sp)
    80002682:	e8a2                	sd	s0,80(sp)
    80002684:	e4a6                	sd	s1,72(sp)
    80002686:	e0ca                	sd	s2,64(sp)
    80002688:	fc4e                	sd	s3,56(sp)
    8000268a:	f852                	sd	s4,48(sp)
    8000268c:	f456                	sd	s5,40(sp)
    8000268e:	f05a                	sd	s6,32(sp)
    80002690:	ec5e                	sd	s7,24(sp)
    80002692:	e862                	sd	s8,16(sp)
    80002694:	e466                	sd	s9,8(sp)
    80002696:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002698:	00015797          	auipc	a5,0x15
    8000269c:	ec47a783          	lw	a5,-316(a5) # 8001755c <sb+0x4>
    800026a0:	cbd1                	beqz	a5,80002734 <balloc+0xb6>
    800026a2:	8baa                	mv	s7,a0
    800026a4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800026a6:	00015b17          	auipc	s6,0x15
    800026aa:	eb2b0b13          	addi	s6,s6,-334 # 80017558 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800026ae:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800026b0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800026b2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800026b4:	6c89                	lui	s9,0x2
    800026b6:	a831                	j	800026d2 <balloc+0x54>
    brelse(bp);
    800026b8:	854a                	mv	a0,s2
    800026ba:	00000097          	auipc	ra,0x0
    800026be:	e32080e7          	jalr	-462(ra) # 800024ec <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800026c2:	015c87bb          	addw	a5,s9,s5
    800026c6:	00078a9b          	sext.w	s5,a5
    800026ca:	004b2703          	lw	a4,4(s6)
    800026ce:	06eaf363          	bgeu	s5,a4,80002734 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800026d2:	41fad79b          	sraiw	a5,s5,0x1f
    800026d6:	0137d79b          	srliw	a5,a5,0x13
    800026da:	015787bb          	addw	a5,a5,s5
    800026de:	40d7d79b          	sraiw	a5,a5,0xd
    800026e2:	01cb2583          	lw	a1,28(s6)
    800026e6:	9dbd                	addw	a1,a1,a5
    800026e8:	855e                	mv	a0,s7
    800026ea:	00000097          	auipc	ra,0x0
    800026ee:	cd2080e7          	jalr	-814(ra) # 800023bc <bread>
    800026f2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800026f4:	004b2503          	lw	a0,4(s6)
    800026f8:	000a849b          	sext.w	s1,s5
    800026fc:	8662                	mv	a2,s8
    800026fe:	faa4fde3          	bgeu	s1,a0,800026b8 <balloc+0x3a>
      m = 1 << (bi % 8);
    80002702:	41f6579b          	sraiw	a5,a2,0x1f
    80002706:	01d7d69b          	srliw	a3,a5,0x1d
    8000270a:	00c6873b          	addw	a4,a3,a2
    8000270e:	00777793          	andi	a5,a4,7
    80002712:	9f95                	subw	a5,a5,a3
    80002714:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002718:	4037571b          	sraiw	a4,a4,0x3
    8000271c:	00e906b3          	add	a3,s2,a4
    80002720:	0586c683          	lbu	a3,88(a3)
    80002724:	00d7f5b3          	and	a1,a5,a3
    80002728:	cd91                	beqz	a1,80002744 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000272a:	2605                	addiw	a2,a2,1
    8000272c:	2485                	addiw	s1,s1,1
    8000272e:	fd4618e3          	bne	a2,s4,800026fe <balloc+0x80>
    80002732:	b759                	j	800026b8 <balloc+0x3a>
  panic("balloc: out of blocks");
    80002734:	00006517          	auipc	a0,0x6
    80002738:	d9450513          	addi	a0,a0,-620 # 800084c8 <syscalls+0x100>
    8000273c:	00003097          	auipc	ra,0x3
    80002740:	636080e7          	jalr	1590(ra) # 80005d72 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002744:	974a                	add	a4,a4,s2
    80002746:	8fd5                	or	a5,a5,a3
    80002748:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000274c:	854a                	mv	a0,s2
    8000274e:	00001097          	auipc	ra,0x1
    80002752:	01a080e7          	jalr	26(ra) # 80003768 <log_write>
        brelse(bp);
    80002756:	854a                	mv	a0,s2
    80002758:	00000097          	auipc	ra,0x0
    8000275c:	d94080e7          	jalr	-620(ra) # 800024ec <brelse>
  bp = bread(dev, bno);
    80002760:	85a6                	mv	a1,s1
    80002762:	855e                	mv	a0,s7
    80002764:	00000097          	auipc	ra,0x0
    80002768:	c58080e7          	jalr	-936(ra) # 800023bc <bread>
    8000276c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000276e:	40000613          	li	a2,1024
    80002772:	4581                	li	a1,0
    80002774:	05850513          	addi	a0,a0,88
    80002778:	ffffe097          	auipc	ra,0xffffe
    8000277c:	a48080e7          	jalr	-1464(ra) # 800001c0 <memset>
  log_write(bp);
    80002780:	854a                	mv	a0,s2
    80002782:	00001097          	auipc	ra,0x1
    80002786:	fe6080e7          	jalr	-26(ra) # 80003768 <log_write>
  brelse(bp);
    8000278a:	854a                	mv	a0,s2
    8000278c:	00000097          	auipc	ra,0x0
    80002790:	d60080e7          	jalr	-672(ra) # 800024ec <brelse>
}
    80002794:	8526                	mv	a0,s1
    80002796:	60e6                	ld	ra,88(sp)
    80002798:	6446                	ld	s0,80(sp)
    8000279a:	64a6                	ld	s1,72(sp)
    8000279c:	6906                	ld	s2,64(sp)
    8000279e:	79e2                	ld	s3,56(sp)
    800027a0:	7a42                	ld	s4,48(sp)
    800027a2:	7aa2                	ld	s5,40(sp)
    800027a4:	7b02                	ld	s6,32(sp)
    800027a6:	6be2                	ld	s7,24(sp)
    800027a8:	6c42                	ld	s8,16(sp)
    800027aa:	6ca2                	ld	s9,8(sp)
    800027ac:	6125                	addi	sp,sp,96
    800027ae:	8082                	ret

00000000800027b0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800027b0:	7179                	addi	sp,sp,-48
    800027b2:	f406                	sd	ra,40(sp)
    800027b4:	f022                	sd	s0,32(sp)
    800027b6:	ec26                	sd	s1,24(sp)
    800027b8:	e84a                	sd	s2,16(sp)
    800027ba:	e44e                	sd	s3,8(sp)
    800027bc:	e052                	sd	s4,0(sp)
    800027be:	1800                	addi	s0,sp,48
    800027c0:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800027c2:	47ad                	li	a5,11
    800027c4:	04b7fe63          	bgeu	a5,a1,80002820 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800027c8:	ff45849b          	addiw	s1,a1,-12
    800027cc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800027d0:	0ff00793          	li	a5,255
    800027d4:	0ae7e363          	bltu	a5,a4,8000287a <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800027d8:	08052583          	lw	a1,128(a0)
    800027dc:	c5ad                	beqz	a1,80002846 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800027de:	00092503          	lw	a0,0(s2)
    800027e2:	00000097          	auipc	ra,0x0
    800027e6:	bda080e7          	jalr	-1062(ra) # 800023bc <bread>
    800027ea:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800027ec:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800027f0:	02049593          	slli	a1,s1,0x20
    800027f4:	9181                	srli	a1,a1,0x20
    800027f6:	058a                	slli	a1,a1,0x2
    800027f8:	00b784b3          	add	s1,a5,a1
    800027fc:	0004a983          	lw	s3,0(s1)
    80002800:	04098d63          	beqz	s3,8000285a <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80002804:	8552                	mv	a0,s4
    80002806:	00000097          	auipc	ra,0x0
    8000280a:	ce6080e7          	jalr	-794(ra) # 800024ec <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000280e:	854e                	mv	a0,s3
    80002810:	70a2                	ld	ra,40(sp)
    80002812:	7402                	ld	s0,32(sp)
    80002814:	64e2                	ld	s1,24(sp)
    80002816:	6942                	ld	s2,16(sp)
    80002818:	69a2                	ld	s3,8(sp)
    8000281a:	6a02                	ld	s4,0(sp)
    8000281c:	6145                	addi	sp,sp,48
    8000281e:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80002820:	02059493          	slli	s1,a1,0x20
    80002824:	9081                	srli	s1,s1,0x20
    80002826:	048a                	slli	s1,s1,0x2
    80002828:	94aa                	add	s1,s1,a0
    8000282a:	0504a983          	lw	s3,80(s1)
    8000282e:	fe0990e3          	bnez	s3,8000280e <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80002832:	4108                	lw	a0,0(a0)
    80002834:	00000097          	auipc	ra,0x0
    80002838:	e4a080e7          	jalr	-438(ra) # 8000267e <balloc>
    8000283c:	0005099b          	sext.w	s3,a0
    80002840:	0534a823          	sw	s3,80(s1)
    80002844:	b7e9                	j	8000280e <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80002846:	4108                	lw	a0,0(a0)
    80002848:	00000097          	auipc	ra,0x0
    8000284c:	e36080e7          	jalr	-458(ra) # 8000267e <balloc>
    80002850:	0005059b          	sext.w	a1,a0
    80002854:	08b92023          	sw	a1,128(s2)
    80002858:	b759                	j	800027de <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000285a:	00092503          	lw	a0,0(s2)
    8000285e:	00000097          	auipc	ra,0x0
    80002862:	e20080e7          	jalr	-480(ra) # 8000267e <balloc>
    80002866:	0005099b          	sext.w	s3,a0
    8000286a:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000286e:	8552                	mv	a0,s4
    80002870:	00001097          	auipc	ra,0x1
    80002874:	ef8080e7          	jalr	-264(ra) # 80003768 <log_write>
    80002878:	b771                	j	80002804 <bmap+0x54>
  panic("bmap: out of range");
    8000287a:	00006517          	auipc	a0,0x6
    8000287e:	c6650513          	addi	a0,a0,-922 # 800084e0 <syscalls+0x118>
    80002882:	00003097          	auipc	ra,0x3
    80002886:	4f0080e7          	jalr	1264(ra) # 80005d72 <panic>

000000008000288a <iget>:
{
    8000288a:	7179                	addi	sp,sp,-48
    8000288c:	f406                	sd	ra,40(sp)
    8000288e:	f022                	sd	s0,32(sp)
    80002890:	ec26                	sd	s1,24(sp)
    80002892:	e84a                	sd	s2,16(sp)
    80002894:	e44e                	sd	s3,8(sp)
    80002896:	e052                	sd	s4,0(sp)
    80002898:	1800                	addi	s0,sp,48
    8000289a:	89aa                	mv	s3,a0
    8000289c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000289e:	00015517          	auipc	a0,0x15
    800028a2:	cda50513          	addi	a0,a0,-806 # 80017578 <itable>
    800028a6:	00004097          	auipc	ra,0x4
    800028aa:	a16080e7          	jalr	-1514(ra) # 800062bc <acquire>
  empty = 0;
    800028ae:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800028b0:	00015497          	auipc	s1,0x15
    800028b4:	ce048493          	addi	s1,s1,-800 # 80017590 <itable+0x18>
    800028b8:	00016697          	auipc	a3,0x16
    800028bc:	76868693          	addi	a3,a3,1896 # 80019020 <log>
    800028c0:	a039                	j	800028ce <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800028c2:	02090b63          	beqz	s2,800028f8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800028c6:	08848493          	addi	s1,s1,136
    800028ca:	02d48a63          	beq	s1,a3,800028fe <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800028ce:	449c                	lw	a5,8(s1)
    800028d0:	fef059e3          	blez	a5,800028c2 <iget+0x38>
    800028d4:	4098                	lw	a4,0(s1)
    800028d6:	ff3716e3          	bne	a4,s3,800028c2 <iget+0x38>
    800028da:	40d8                	lw	a4,4(s1)
    800028dc:	ff4713e3          	bne	a4,s4,800028c2 <iget+0x38>
      ip->ref++;
    800028e0:	2785                	addiw	a5,a5,1
    800028e2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800028e4:	00015517          	auipc	a0,0x15
    800028e8:	c9450513          	addi	a0,a0,-876 # 80017578 <itable>
    800028ec:	00004097          	auipc	ra,0x4
    800028f0:	a84080e7          	jalr	-1404(ra) # 80006370 <release>
      return ip;
    800028f4:	8926                	mv	s2,s1
    800028f6:	a03d                	j	80002924 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800028f8:	f7f9                	bnez	a5,800028c6 <iget+0x3c>
    800028fa:	8926                	mv	s2,s1
    800028fc:	b7e9                	j	800028c6 <iget+0x3c>
  if(empty == 0)
    800028fe:	02090c63          	beqz	s2,80002936 <iget+0xac>
  ip->dev = dev;
    80002902:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002906:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000290a:	4785                	li	a5,1
    8000290c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002910:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002914:	00015517          	auipc	a0,0x15
    80002918:	c6450513          	addi	a0,a0,-924 # 80017578 <itable>
    8000291c:	00004097          	auipc	ra,0x4
    80002920:	a54080e7          	jalr	-1452(ra) # 80006370 <release>
}
    80002924:	854a                	mv	a0,s2
    80002926:	70a2                	ld	ra,40(sp)
    80002928:	7402                	ld	s0,32(sp)
    8000292a:	64e2                	ld	s1,24(sp)
    8000292c:	6942                	ld	s2,16(sp)
    8000292e:	69a2                	ld	s3,8(sp)
    80002930:	6a02                	ld	s4,0(sp)
    80002932:	6145                	addi	sp,sp,48
    80002934:	8082                	ret
    panic("iget: no inodes");
    80002936:	00006517          	auipc	a0,0x6
    8000293a:	bc250513          	addi	a0,a0,-1086 # 800084f8 <syscalls+0x130>
    8000293e:	00003097          	auipc	ra,0x3
    80002942:	434080e7          	jalr	1076(ra) # 80005d72 <panic>

0000000080002946 <fsinit>:
fsinit(int dev) {
    80002946:	7179                	addi	sp,sp,-48
    80002948:	f406                	sd	ra,40(sp)
    8000294a:	f022                	sd	s0,32(sp)
    8000294c:	ec26                	sd	s1,24(sp)
    8000294e:	e84a                	sd	s2,16(sp)
    80002950:	e44e                	sd	s3,8(sp)
    80002952:	1800                	addi	s0,sp,48
    80002954:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002956:	4585                	li	a1,1
    80002958:	00000097          	auipc	ra,0x0
    8000295c:	a64080e7          	jalr	-1436(ra) # 800023bc <bread>
    80002960:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002962:	00015997          	auipc	s3,0x15
    80002966:	bf698993          	addi	s3,s3,-1034 # 80017558 <sb>
    8000296a:	02000613          	li	a2,32
    8000296e:	05850593          	addi	a1,a0,88
    80002972:	854e                	mv	a0,s3
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	8ac080e7          	jalr	-1876(ra) # 80000220 <memmove>
  brelse(bp);
    8000297c:	8526                	mv	a0,s1
    8000297e:	00000097          	auipc	ra,0x0
    80002982:	b6e080e7          	jalr	-1170(ra) # 800024ec <brelse>
  if(sb.magic != FSMAGIC)
    80002986:	0009a703          	lw	a4,0(s3)
    8000298a:	102037b7          	lui	a5,0x10203
    8000298e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002992:	02f71263          	bne	a4,a5,800029b6 <fsinit+0x70>
  initlog(dev, &sb);
    80002996:	00015597          	auipc	a1,0x15
    8000299a:	bc258593          	addi	a1,a1,-1086 # 80017558 <sb>
    8000299e:	854a                	mv	a0,s2
    800029a0:	00001097          	auipc	ra,0x1
    800029a4:	b4c080e7          	jalr	-1204(ra) # 800034ec <initlog>
}
    800029a8:	70a2                	ld	ra,40(sp)
    800029aa:	7402                	ld	s0,32(sp)
    800029ac:	64e2                	ld	s1,24(sp)
    800029ae:	6942                	ld	s2,16(sp)
    800029b0:	69a2                	ld	s3,8(sp)
    800029b2:	6145                	addi	sp,sp,48
    800029b4:	8082                	ret
    panic("invalid file system");
    800029b6:	00006517          	auipc	a0,0x6
    800029ba:	b5250513          	addi	a0,a0,-1198 # 80008508 <syscalls+0x140>
    800029be:	00003097          	auipc	ra,0x3
    800029c2:	3b4080e7          	jalr	948(ra) # 80005d72 <panic>

00000000800029c6 <iinit>:
{
    800029c6:	7179                	addi	sp,sp,-48
    800029c8:	f406                	sd	ra,40(sp)
    800029ca:	f022                	sd	s0,32(sp)
    800029cc:	ec26                	sd	s1,24(sp)
    800029ce:	e84a                	sd	s2,16(sp)
    800029d0:	e44e                	sd	s3,8(sp)
    800029d2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800029d4:	00006597          	auipc	a1,0x6
    800029d8:	b4c58593          	addi	a1,a1,-1204 # 80008520 <syscalls+0x158>
    800029dc:	00015517          	auipc	a0,0x15
    800029e0:	b9c50513          	addi	a0,a0,-1124 # 80017578 <itable>
    800029e4:	00004097          	auipc	ra,0x4
    800029e8:	848080e7          	jalr	-1976(ra) # 8000622c <initlock>
  for(i = 0; i < NINODE; i++) {
    800029ec:	00015497          	auipc	s1,0x15
    800029f0:	bb448493          	addi	s1,s1,-1100 # 800175a0 <itable+0x28>
    800029f4:	00016997          	auipc	s3,0x16
    800029f8:	63c98993          	addi	s3,s3,1596 # 80019030 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800029fc:	00006917          	auipc	s2,0x6
    80002a00:	b2c90913          	addi	s2,s2,-1236 # 80008528 <syscalls+0x160>
    80002a04:	85ca                	mv	a1,s2
    80002a06:	8526                	mv	a0,s1
    80002a08:	00001097          	auipc	ra,0x1
    80002a0c:	e46080e7          	jalr	-442(ra) # 8000384e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002a10:	08848493          	addi	s1,s1,136
    80002a14:	ff3498e3          	bne	s1,s3,80002a04 <iinit+0x3e>
}
    80002a18:	70a2                	ld	ra,40(sp)
    80002a1a:	7402                	ld	s0,32(sp)
    80002a1c:	64e2                	ld	s1,24(sp)
    80002a1e:	6942                	ld	s2,16(sp)
    80002a20:	69a2                	ld	s3,8(sp)
    80002a22:	6145                	addi	sp,sp,48
    80002a24:	8082                	ret

0000000080002a26 <ialloc>:
{
    80002a26:	715d                	addi	sp,sp,-80
    80002a28:	e486                	sd	ra,72(sp)
    80002a2a:	e0a2                	sd	s0,64(sp)
    80002a2c:	fc26                	sd	s1,56(sp)
    80002a2e:	f84a                	sd	s2,48(sp)
    80002a30:	f44e                	sd	s3,40(sp)
    80002a32:	f052                	sd	s4,32(sp)
    80002a34:	ec56                	sd	s5,24(sp)
    80002a36:	e85a                	sd	s6,16(sp)
    80002a38:	e45e                	sd	s7,8(sp)
    80002a3a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002a3c:	00015717          	auipc	a4,0x15
    80002a40:	b2872703          	lw	a4,-1240(a4) # 80017564 <sb+0xc>
    80002a44:	4785                	li	a5,1
    80002a46:	04e7fa63          	bgeu	a5,a4,80002a9a <ialloc+0x74>
    80002a4a:	8aaa                	mv	s5,a0
    80002a4c:	8bae                	mv	s7,a1
    80002a4e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002a50:	00015a17          	auipc	s4,0x15
    80002a54:	b08a0a13          	addi	s4,s4,-1272 # 80017558 <sb>
    80002a58:	00048b1b          	sext.w	s6,s1
    80002a5c:	0044d593          	srli	a1,s1,0x4
    80002a60:	018a2783          	lw	a5,24(s4)
    80002a64:	9dbd                	addw	a1,a1,a5
    80002a66:	8556                	mv	a0,s5
    80002a68:	00000097          	auipc	ra,0x0
    80002a6c:	954080e7          	jalr	-1708(ra) # 800023bc <bread>
    80002a70:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002a72:	05850993          	addi	s3,a0,88
    80002a76:	00f4f793          	andi	a5,s1,15
    80002a7a:	079a                	slli	a5,a5,0x6
    80002a7c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002a7e:	00099783          	lh	a5,0(s3)
    80002a82:	c785                	beqz	a5,80002aaa <ialloc+0x84>
    brelse(bp);
    80002a84:	00000097          	auipc	ra,0x0
    80002a88:	a68080e7          	jalr	-1432(ra) # 800024ec <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002a8c:	0485                	addi	s1,s1,1
    80002a8e:	00ca2703          	lw	a4,12(s4)
    80002a92:	0004879b          	sext.w	a5,s1
    80002a96:	fce7e1e3          	bltu	a5,a4,80002a58 <ialloc+0x32>
  panic("ialloc: no inodes");
    80002a9a:	00006517          	auipc	a0,0x6
    80002a9e:	a9650513          	addi	a0,a0,-1386 # 80008530 <syscalls+0x168>
    80002aa2:	00003097          	auipc	ra,0x3
    80002aa6:	2d0080e7          	jalr	720(ra) # 80005d72 <panic>
      memset(dip, 0, sizeof(*dip));
    80002aaa:	04000613          	li	a2,64
    80002aae:	4581                	li	a1,0
    80002ab0:	854e                	mv	a0,s3
    80002ab2:	ffffd097          	auipc	ra,0xffffd
    80002ab6:	70e080e7          	jalr	1806(ra) # 800001c0 <memset>
      dip->type = type;
    80002aba:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002abe:	854a                	mv	a0,s2
    80002ac0:	00001097          	auipc	ra,0x1
    80002ac4:	ca8080e7          	jalr	-856(ra) # 80003768 <log_write>
      brelse(bp);
    80002ac8:	854a                	mv	a0,s2
    80002aca:	00000097          	auipc	ra,0x0
    80002ace:	a22080e7          	jalr	-1502(ra) # 800024ec <brelse>
      return iget(dev, inum);
    80002ad2:	85da                	mv	a1,s6
    80002ad4:	8556                	mv	a0,s5
    80002ad6:	00000097          	auipc	ra,0x0
    80002ada:	db4080e7          	jalr	-588(ra) # 8000288a <iget>
}
    80002ade:	60a6                	ld	ra,72(sp)
    80002ae0:	6406                	ld	s0,64(sp)
    80002ae2:	74e2                	ld	s1,56(sp)
    80002ae4:	7942                	ld	s2,48(sp)
    80002ae6:	79a2                	ld	s3,40(sp)
    80002ae8:	7a02                	ld	s4,32(sp)
    80002aea:	6ae2                	ld	s5,24(sp)
    80002aec:	6b42                	ld	s6,16(sp)
    80002aee:	6ba2                	ld	s7,8(sp)
    80002af0:	6161                	addi	sp,sp,80
    80002af2:	8082                	ret

0000000080002af4 <iupdate>:
{
    80002af4:	1101                	addi	sp,sp,-32
    80002af6:	ec06                	sd	ra,24(sp)
    80002af8:	e822                	sd	s0,16(sp)
    80002afa:	e426                	sd	s1,8(sp)
    80002afc:	e04a                	sd	s2,0(sp)
    80002afe:	1000                	addi	s0,sp,32
    80002b00:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002b02:	415c                	lw	a5,4(a0)
    80002b04:	0047d79b          	srliw	a5,a5,0x4
    80002b08:	00015597          	auipc	a1,0x15
    80002b0c:	a685a583          	lw	a1,-1432(a1) # 80017570 <sb+0x18>
    80002b10:	9dbd                	addw	a1,a1,a5
    80002b12:	4108                	lw	a0,0(a0)
    80002b14:	00000097          	auipc	ra,0x0
    80002b18:	8a8080e7          	jalr	-1880(ra) # 800023bc <bread>
    80002b1c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002b1e:	05850793          	addi	a5,a0,88
    80002b22:	40c8                	lw	a0,4(s1)
    80002b24:	893d                	andi	a0,a0,15
    80002b26:	051a                	slli	a0,a0,0x6
    80002b28:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80002b2a:	04449703          	lh	a4,68(s1)
    80002b2e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80002b32:	04649703          	lh	a4,70(s1)
    80002b36:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80002b3a:	04849703          	lh	a4,72(s1)
    80002b3e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80002b42:	04a49703          	lh	a4,74(s1)
    80002b46:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80002b4a:	44f8                	lw	a4,76(s1)
    80002b4c:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002b4e:	03400613          	li	a2,52
    80002b52:	05048593          	addi	a1,s1,80
    80002b56:	0531                	addi	a0,a0,12
    80002b58:	ffffd097          	auipc	ra,0xffffd
    80002b5c:	6c8080e7          	jalr	1736(ra) # 80000220 <memmove>
  log_write(bp);
    80002b60:	854a                	mv	a0,s2
    80002b62:	00001097          	auipc	ra,0x1
    80002b66:	c06080e7          	jalr	-1018(ra) # 80003768 <log_write>
  brelse(bp);
    80002b6a:	854a                	mv	a0,s2
    80002b6c:	00000097          	auipc	ra,0x0
    80002b70:	980080e7          	jalr	-1664(ra) # 800024ec <brelse>
}
    80002b74:	60e2                	ld	ra,24(sp)
    80002b76:	6442                	ld	s0,16(sp)
    80002b78:	64a2                	ld	s1,8(sp)
    80002b7a:	6902                	ld	s2,0(sp)
    80002b7c:	6105                	addi	sp,sp,32
    80002b7e:	8082                	ret

0000000080002b80 <idup>:
{
    80002b80:	1101                	addi	sp,sp,-32
    80002b82:	ec06                	sd	ra,24(sp)
    80002b84:	e822                	sd	s0,16(sp)
    80002b86:	e426                	sd	s1,8(sp)
    80002b88:	1000                	addi	s0,sp,32
    80002b8a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002b8c:	00015517          	auipc	a0,0x15
    80002b90:	9ec50513          	addi	a0,a0,-1556 # 80017578 <itable>
    80002b94:	00003097          	auipc	ra,0x3
    80002b98:	728080e7          	jalr	1832(ra) # 800062bc <acquire>
  ip->ref++;
    80002b9c:	449c                	lw	a5,8(s1)
    80002b9e:	2785                	addiw	a5,a5,1
    80002ba0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002ba2:	00015517          	auipc	a0,0x15
    80002ba6:	9d650513          	addi	a0,a0,-1578 # 80017578 <itable>
    80002baa:	00003097          	auipc	ra,0x3
    80002bae:	7c6080e7          	jalr	1990(ra) # 80006370 <release>
}
    80002bb2:	8526                	mv	a0,s1
    80002bb4:	60e2                	ld	ra,24(sp)
    80002bb6:	6442                	ld	s0,16(sp)
    80002bb8:	64a2                	ld	s1,8(sp)
    80002bba:	6105                	addi	sp,sp,32
    80002bbc:	8082                	ret

0000000080002bbe <ilock>:
{
    80002bbe:	1101                	addi	sp,sp,-32
    80002bc0:	ec06                	sd	ra,24(sp)
    80002bc2:	e822                	sd	s0,16(sp)
    80002bc4:	e426                	sd	s1,8(sp)
    80002bc6:	e04a                	sd	s2,0(sp)
    80002bc8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002bca:	c115                	beqz	a0,80002bee <ilock+0x30>
    80002bcc:	84aa                	mv	s1,a0
    80002bce:	451c                	lw	a5,8(a0)
    80002bd0:	00f05f63          	blez	a5,80002bee <ilock+0x30>
  acquiresleep(&ip->lock);
    80002bd4:	0541                	addi	a0,a0,16
    80002bd6:	00001097          	auipc	ra,0x1
    80002bda:	cb2080e7          	jalr	-846(ra) # 80003888 <acquiresleep>
  if(ip->valid == 0){
    80002bde:	40bc                	lw	a5,64(s1)
    80002be0:	cf99                	beqz	a5,80002bfe <ilock+0x40>
}
    80002be2:	60e2                	ld	ra,24(sp)
    80002be4:	6442                	ld	s0,16(sp)
    80002be6:	64a2                	ld	s1,8(sp)
    80002be8:	6902                	ld	s2,0(sp)
    80002bea:	6105                	addi	sp,sp,32
    80002bec:	8082                	ret
    panic("ilock");
    80002bee:	00006517          	auipc	a0,0x6
    80002bf2:	95a50513          	addi	a0,a0,-1702 # 80008548 <syscalls+0x180>
    80002bf6:	00003097          	auipc	ra,0x3
    80002bfa:	17c080e7          	jalr	380(ra) # 80005d72 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002bfe:	40dc                	lw	a5,4(s1)
    80002c00:	0047d79b          	srliw	a5,a5,0x4
    80002c04:	00015597          	auipc	a1,0x15
    80002c08:	96c5a583          	lw	a1,-1684(a1) # 80017570 <sb+0x18>
    80002c0c:	9dbd                	addw	a1,a1,a5
    80002c0e:	4088                	lw	a0,0(s1)
    80002c10:	fffff097          	auipc	ra,0xfffff
    80002c14:	7ac080e7          	jalr	1964(ra) # 800023bc <bread>
    80002c18:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002c1a:	05850593          	addi	a1,a0,88
    80002c1e:	40dc                	lw	a5,4(s1)
    80002c20:	8bbd                	andi	a5,a5,15
    80002c22:	079a                	slli	a5,a5,0x6
    80002c24:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002c26:	00059783          	lh	a5,0(a1)
    80002c2a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002c2e:	00259783          	lh	a5,2(a1)
    80002c32:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002c36:	00459783          	lh	a5,4(a1)
    80002c3a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002c3e:	00659783          	lh	a5,6(a1)
    80002c42:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002c46:	459c                	lw	a5,8(a1)
    80002c48:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002c4a:	03400613          	li	a2,52
    80002c4e:	05b1                	addi	a1,a1,12
    80002c50:	05048513          	addi	a0,s1,80
    80002c54:	ffffd097          	auipc	ra,0xffffd
    80002c58:	5cc080e7          	jalr	1484(ra) # 80000220 <memmove>
    brelse(bp);
    80002c5c:	854a                	mv	a0,s2
    80002c5e:	00000097          	auipc	ra,0x0
    80002c62:	88e080e7          	jalr	-1906(ra) # 800024ec <brelse>
    ip->valid = 1;
    80002c66:	4785                	li	a5,1
    80002c68:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002c6a:	04449783          	lh	a5,68(s1)
    80002c6e:	fbb5                	bnez	a5,80002be2 <ilock+0x24>
      panic("ilock: no type");
    80002c70:	00006517          	auipc	a0,0x6
    80002c74:	8e050513          	addi	a0,a0,-1824 # 80008550 <syscalls+0x188>
    80002c78:	00003097          	auipc	ra,0x3
    80002c7c:	0fa080e7          	jalr	250(ra) # 80005d72 <panic>

0000000080002c80 <iunlock>:
{
    80002c80:	1101                	addi	sp,sp,-32
    80002c82:	ec06                	sd	ra,24(sp)
    80002c84:	e822                	sd	s0,16(sp)
    80002c86:	e426                	sd	s1,8(sp)
    80002c88:	e04a                	sd	s2,0(sp)
    80002c8a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002c8c:	c905                	beqz	a0,80002cbc <iunlock+0x3c>
    80002c8e:	84aa                	mv	s1,a0
    80002c90:	01050913          	addi	s2,a0,16
    80002c94:	854a                	mv	a0,s2
    80002c96:	00001097          	auipc	ra,0x1
    80002c9a:	c8c080e7          	jalr	-884(ra) # 80003922 <holdingsleep>
    80002c9e:	cd19                	beqz	a0,80002cbc <iunlock+0x3c>
    80002ca0:	449c                	lw	a5,8(s1)
    80002ca2:	00f05d63          	blez	a5,80002cbc <iunlock+0x3c>
  releasesleep(&ip->lock);
    80002ca6:	854a                	mv	a0,s2
    80002ca8:	00001097          	auipc	ra,0x1
    80002cac:	c36080e7          	jalr	-970(ra) # 800038de <releasesleep>
}
    80002cb0:	60e2                	ld	ra,24(sp)
    80002cb2:	6442                	ld	s0,16(sp)
    80002cb4:	64a2                	ld	s1,8(sp)
    80002cb6:	6902                	ld	s2,0(sp)
    80002cb8:	6105                	addi	sp,sp,32
    80002cba:	8082                	ret
    panic("iunlock");
    80002cbc:	00006517          	auipc	a0,0x6
    80002cc0:	8a450513          	addi	a0,a0,-1884 # 80008560 <syscalls+0x198>
    80002cc4:	00003097          	auipc	ra,0x3
    80002cc8:	0ae080e7          	jalr	174(ra) # 80005d72 <panic>

0000000080002ccc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002ccc:	7179                	addi	sp,sp,-48
    80002cce:	f406                	sd	ra,40(sp)
    80002cd0:	f022                	sd	s0,32(sp)
    80002cd2:	ec26                	sd	s1,24(sp)
    80002cd4:	e84a                	sd	s2,16(sp)
    80002cd6:	e44e                	sd	s3,8(sp)
    80002cd8:	e052                	sd	s4,0(sp)
    80002cda:	1800                	addi	s0,sp,48
    80002cdc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002cde:	05050493          	addi	s1,a0,80
    80002ce2:	08050913          	addi	s2,a0,128
    80002ce6:	a021                	j	80002cee <itrunc+0x22>
    80002ce8:	0491                	addi	s1,s1,4
    80002cea:	01248d63          	beq	s1,s2,80002d04 <itrunc+0x38>
    if(ip->addrs[i]){
    80002cee:	408c                	lw	a1,0(s1)
    80002cf0:	dde5                	beqz	a1,80002ce8 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002cf2:	0009a503          	lw	a0,0(s3)
    80002cf6:	00000097          	auipc	ra,0x0
    80002cfa:	90c080e7          	jalr	-1780(ra) # 80002602 <bfree>
      ip->addrs[i] = 0;
    80002cfe:	0004a023          	sw	zero,0(s1)
    80002d02:	b7dd                	j	80002ce8 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002d04:	0809a583          	lw	a1,128(s3)
    80002d08:	e185                	bnez	a1,80002d28 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002d0a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002d0e:	854e                	mv	a0,s3
    80002d10:	00000097          	auipc	ra,0x0
    80002d14:	de4080e7          	jalr	-540(ra) # 80002af4 <iupdate>
}
    80002d18:	70a2                	ld	ra,40(sp)
    80002d1a:	7402                	ld	s0,32(sp)
    80002d1c:	64e2                	ld	s1,24(sp)
    80002d1e:	6942                	ld	s2,16(sp)
    80002d20:	69a2                	ld	s3,8(sp)
    80002d22:	6a02                	ld	s4,0(sp)
    80002d24:	6145                	addi	sp,sp,48
    80002d26:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002d28:	0009a503          	lw	a0,0(s3)
    80002d2c:	fffff097          	auipc	ra,0xfffff
    80002d30:	690080e7          	jalr	1680(ra) # 800023bc <bread>
    80002d34:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002d36:	05850493          	addi	s1,a0,88
    80002d3a:	45850913          	addi	s2,a0,1112
    80002d3e:	a811                	j	80002d52 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80002d40:	0009a503          	lw	a0,0(s3)
    80002d44:	00000097          	auipc	ra,0x0
    80002d48:	8be080e7          	jalr	-1858(ra) # 80002602 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80002d4c:	0491                	addi	s1,s1,4
    80002d4e:	01248563          	beq	s1,s2,80002d58 <itrunc+0x8c>
      if(a[j])
    80002d52:	408c                	lw	a1,0(s1)
    80002d54:	dde5                	beqz	a1,80002d4c <itrunc+0x80>
    80002d56:	b7ed                	j	80002d40 <itrunc+0x74>
    brelse(bp);
    80002d58:	8552                	mv	a0,s4
    80002d5a:	fffff097          	auipc	ra,0xfffff
    80002d5e:	792080e7          	jalr	1938(ra) # 800024ec <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002d62:	0809a583          	lw	a1,128(s3)
    80002d66:	0009a503          	lw	a0,0(s3)
    80002d6a:	00000097          	auipc	ra,0x0
    80002d6e:	898080e7          	jalr	-1896(ra) # 80002602 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002d72:	0809a023          	sw	zero,128(s3)
    80002d76:	bf51                	j	80002d0a <itrunc+0x3e>

0000000080002d78 <iput>:
{
    80002d78:	1101                	addi	sp,sp,-32
    80002d7a:	ec06                	sd	ra,24(sp)
    80002d7c:	e822                	sd	s0,16(sp)
    80002d7e:	e426                	sd	s1,8(sp)
    80002d80:	e04a                	sd	s2,0(sp)
    80002d82:	1000                	addi	s0,sp,32
    80002d84:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002d86:	00014517          	auipc	a0,0x14
    80002d8a:	7f250513          	addi	a0,a0,2034 # 80017578 <itable>
    80002d8e:	00003097          	auipc	ra,0x3
    80002d92:	52e080e7          	jalr	1326(ra) # 800062bc <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002d96:	4498                	lw	a4,8(s1)
    80002d98:	4785                	li	a5,1
    80002d9a:	02f70363          	beq	a4,a5,80002dc0 <iput+0x48>
  ip->ref--;
    80002d9e:	449c                	lw	a5,8(s1)
    80002da0:	37fd                	addiw	a5,a5,-1
    80002da2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002da4:	00014517          	auipc	a0,0x14
    80002da8:	7d450513          	addi	a0,a0,2004 # 80017578 <itable>
    80002dac:	00003097          	auipc	ra,0x3
    80002db0:	5c4080e7          	jalr	1476(ra) # 80006370 <release>
}
    80002db4:	60e2                	ld	ra,24(sp)
    80002db6:	6442                	ld	s0,16(sp)
    80002db8:	64a2                	ld	s1,8(sp)
    80002dba:	6902                	ld	s2,0(sp)
    80002dbc:	6105                	addi	sp,sp,32
    80002dbe:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002dc0:	40bc                	lw	a5,64(s1)
    80002dc2:	dff1                	beqz	a5,80002d9e <iput+0x26>
    80002dc4:	04a49783          	lh	a5,74(s1)
    80002dc8:	fbf9                	bnez	a5,80002d9e <iput+0x26>
    acquiresleep(&ip->lock);
    80002dca:	01048913          	addi	s2,s1,16
    80002dce:	854a                	mv	a0,s2
    80002dd0:	00001097          	auipc	ra,0x1
    80002dd4:	ab8080e7          	jalr	-1352(ra) # 80003888 <acquiresleep>
    release(&itable.lock);
    80002dd8:	00014517          	auipc	a0,0x14
    80002ddc:	7a050513          	addi	a0,a0,1952 # 80017578 <itable>
    80002de0:	00003097          	auipc	ra,0x3
    80002de4:	590080e7          	jalr	1424(ra) # 80006370 <release>
    itrunc(ip);
    80002de8:	8526                	mv	a0,s1
    80002dea:	00000097          	auipc	ra,0x0
    80002dee:	ee2080e7          	jalr	-286(ra) # 80002ccc <itrunc>
    ip->type = 0;
    80002df2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002df6:	8526                	mv	a0,s1
    80002df8:	00000097          	auipc	ra,0x0
    80002dfc:	cfc080e7          	jalr	-772(ra) # 80002af4 <iupdate>
    ip->valid = 0;
    80002e00:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002e04:	854a                	mv	a0,s2
    80002e06:	00001097          	auipc	ra,0x1
    80002e0a:	ad8080e7          	jalr	-1320(ra) # 800038de <releasesleep>
    acquire(&itable.lock);
    80002e0e:	00014517          	auipc	a0,0x14
    80002e12:	76a50513          	addi	a0,a0,1898 # 80017578 <itable>
    80002e16:	00003097          	auipc	ra,0x3
    80002e1a:	4a6080e7          	jalr	1190(ra) # 800062bc <acquire>
    80002e1e:	b741                	j	80002d9e <iput+0x26>

0000000080002e20 <iunlockput>:
{
    80002e20:	1101                	addi	sp,sp,-32
    80002e22:	ec06                	sd	ra,24(sp)
    80002e24:	e822                	sd	s0,16(sp)
    80002e26:	e426                	sd	s1,8(sp)
    80002e28:	1000                	addi	s0,sp,32
    80002e2a:	84aa                	mv	s1,a0
  iunlock(ip);
    80002e2c:	00000097          	auipc	ra,0x0
    80002e30:	e54080e7          	jalr	-428(ra) # 80002c80 <iunlock>
  iput(ip);
    80002e34:	8526                	mv	a0,s1
    80002e36:	00000097          	auipc	ra,0x0
    80002e3a:	f42080e7          	jalr	-190(ra) # 80002d78 <iput>
}
    80002e3e:	60e2                	ld	ra,24(sp)
    80002e40:	6442                	ld	s0,16(sp)
    80002e42:	64a2                	ld	s1,8(sp)
    80002e44:	6105                	addi	sp,sp,32
    80002e46:	8082                	ret

0000000080002e48 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002e48:	1141                	addi	sp,sp,-16
    80002e4a:	e422                	sd	s0,8(sp)
    80002e4c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002e4e:	411c                	lw	a5,0(a0)
    80002e50:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002e52:	415c                	lw	a5,4(a0)
    80002e54:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002e56:	04451783          	lh	a5,68(a0)
    80002e5a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002e5e:	04a51783          	lh	a5,74(a0)
    80002e62:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002e66:	04c56783          	lwu	a5,76(a0)
    80002e6a:	e99c                	sd	a5,16(a1)
}
    80002e6c:	6422                	ld	s0,8(sp)
    80002e6e:	0141                	addi	sp,sp,16
    80002e70:	8082                	ret

0000000080002e72 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002e72:	457c                	lw	a5,76(a0)
    80002e74:	0ed7e963          	bltu	a5,a3,80002f66 <readi+0xf4>
{
    80002e78:	7159                	addi	sp,sp,-112
    80002e7a:	f486                	sd	ra,104(sp)
    80002e7c:	f0a2                	sd	s0,96(sp)
    80002e7e:	eca6                	sd	s1,88(sp)
    80002e80:	e8ca                	sd	s2,80(sp)
    80002e82:	e4ce                	sd	s3,72(sp)
    80002e84:	e0d2                	sd	s4,64(sp)
    80002e86:	fc56                	sd	s5,56(sp)
    80002e88:	f85a                	sd	s6,48(sp)
    80002e8a:	f45e                	sd	s7,40(sp)
    80002e8c:	f062                	sd	s8,32(sp)
    80002e8e:	ec66                	sd	s9,24(sp)
    80002e90:	e86a                	sd	s10,16(sp)
    80002e92:	e46e                	sd	s11,8(sp)
    80002e94:	1880                	addi	s0,sp,112
    80002e96:	8baa                	mv	s7,a0
    80002e98:	8c2e                	mv	s8,a1
    80002e9a:	8ab2                	mv	s5,a2
    80002e9c:	84b6                	mv	s1,a3
    80002e9e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002ea0:	9f35                	addw	a4,a4,a3
    return 0;
    80002ea2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002ea4:	0ad76063          	bltu	a4,a3,80002f44 <readi+0xd2>
  if(off + n > ip->size)
    80002ea8:	00e7f463          	bgeu	a5,a4,80002eb0 <readi+0x3e>
    n = ip->size - off;
    80002eac:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002eb0:	0a0b0963          	beqz	s6,80002f62 <readi+0xf0>
    80002eb4:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80002eb6:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002eba:	5cfd                	li	s9,-1
    80002ebc:	a82d                	j	80002ef6 <readi+0x84>
    80002ebe:	020a1d93          	slli	s11,s4,0x20
    80002ec2:	020ddd93          	srli	s11,s11,0x20
    80002ec6:	05890613          	addi	a2,s2,88
    80002eca:	86ee                	mv	a3,s11
    80002ecc:	963a                	add	a2,a2,a4
    80002ece:	85d6                	mv	a1,s5
    80002ed0:	8562                	mv	a0,s8
    80002ed2:	fffff097          	auipc	ra,0xfffff
    80002ed6:	ade080e7          	jalr	-1314(ra) # 800019b0 <either_copyout>
    80002eda:	05950d63          	beq	a0,s9,80002f34 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002ede:	854a                	mv	a0,s2
    80002ee0:	fffff097          	auipc	ra,0xfffff
    80002ee4:	60c080e7          	jalr	1548(ra) # 800024ec <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002ee8:	013a09bb          	addw	s3,s4,s3
    80002eec:	009a04bb          	addw	s1,s4,s1
    80002ef0:	9aee                	add	s5,s5,s11
    80002ef2:	0569f763          	bgeu	s3,s6,80002f40 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80002ef6:	000ba903          	lw	s2,0(s7)
    80002efa:	00a4d59b          	srliw	a1,s1,0xa
    80002efe:	855e                	mv	a0,s7
    80002f00:	00000097          	auipc	ra,0x0
    80002f04:	8b0080e7          	jalr	-1872(ra) # 800027b0 <bmap>
    80002f08:	0005059b          	sext.w	a1,a0
    80002f0c:	854a                	mv	a0,s2
    80002f0e:	fffff097          	auipc	ra,0xfffff
    80002f12:	4ae080e7          	jalr	1198(ra) # 800023bc <bread>
    80002f16:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f18:	3ff4f713          	andi	a4,s1,1023
    80002f1c:	40ed07bb          	subw	a5,s10,a4
    80002f20:	413b06bb          	subw	a3,s6,s3
    80002f24:	8a3e                	mv	s4,a5
    80002f26:	2781                	sext.w	a5,a5
    80002f28:	0006861b          	sext.w	a2,a3
    80002f2c:	f8f679e3          	bgeu	a2,a5,80002ebe <readi+0x4c>
    80002f30:	8a36                	mv	s4,a3
    80002f32:	b771                	j	80002ebe <readi+0x4c>
      brelse(bp);
    80002f34:	854a                	mv	a0,s2
    80002f36:	fffff097          	auipc	ra,0xfffff
    80002f3a:	5b6080e7          	jalr	1462(ra) # 800024ec <brelse>
      tot = -1;
    80002f3e:	59fd                	li	s3,-1
  }
  return tot;
    80002f40:	0009851b          	sext.w	a0,s3
}
    80002f44:	70a6                	ld	ra,104(sp)
    80002f46:	7406                	ld	s0,96(sp)
    80002f48:	64e6                	ld	s1,88(sp)
    80002f4a:	6946                	ld	s2,80(sp)
    80002f4c:	69a6                	ld	s3,72(sp)
    80002f4e:	6a06                	ld	s4,64(sp)
    80002f50:	7ae2                	ld	s5,56(sp)
    80002f52:	7b42                	ld	s6,48(sp)
    80002f54:	7ba2                	ld	s7,40(sp)
    80002f56:	7c02                	ld	s8,32(sp)
    80002f58:	6ce2                	ld	s9,24(sp)
    80002f5a:	6d42                	ld	s10,16(sp)
    80002f5c:	6da2                	ld	s11,8(sp)
    80002f5e:	6165                	addi	sp,sp,112
    80002f60:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002f62:	89da                	mv	s3,s6
    80002f64:	bff1                	j	80002f40 <readi+0xce>
    return 0;
    80002f66:	4501                	li	a0,0
}
    80002f68:	8082                	ret

0000000080002f6a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002f6a:	457c                	lw	a5,76(a0)
    80002f6c:	10d7e863          	bltu	a5,a3,8000307c <writei+0x112>
{
    80002f70:	7159                	addi	sp,sp,-112
    80002f72:	f486                	sd	ra,104(sp)
    80002f74:	f0a2                	sd	s0,96(sp)
    80002f76:	eca6                	sd	s1,88(sp)
    80002f78:	e8ca                	sd	s2,80(sp)
    80002f7a:	e4ce                	sd	s3,72(sp)
    80002f7c:	e0d2                	sd	s4,64(sp)
    80002f7e:	fc56                	sd	s5,56(sp)
    80002f80:	f85a                	sd	s6,48(sp)
    80002f82:	f45e                	sd	s7,40(sp)
    80002f84:	f062                	sd	s8,32(sp)
    80002f86:	ec66                	sd	s9,24(sp)
    80002f88:	e86a                	sd	s10,16(sp)
    80002f8a:	e46e                	sd	s11,8(sp)
    80002f8c:	1880                	addi	s0,sp,112
    80002f8e:	8b2a                	mv	s6,a0
    80002f90:	8c2e                	mv	s8,a1
    80002f92:	8ab2                	mv	s5,a2
    80002f94:	8936                	mv	s2,a3
    80002f96:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80002f98:	00e687bb          	addw	a5,a3,a4
    80002f9c:	0ed7e263          	bltu	a5,a3,80003080 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002fa0:	00043737          	lui	a4,0x43
    80002fa4:	0ef76063          	bltu	a4,a5,80003084 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002fa8:	0c0b8863          	beqz	s7,80003078 <writei+0x10e>
    80002fac:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80002fae:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002fb2:	5cfd                	li	s9,-1
    80002fb4:	a091                	j	80002ff8 <writei+0x8e>
    80002fb6:	02099d93          	slli	s11,s3,0x20
    80002fba:	020ddd93          	srli	s11,s11,0x20
    80002fbe:	05848513          	addi	a0,s1,88
    80002fc2:	86ee                	mv	a3,s11
    80002fc4:	8656                	mv	a2,s5
    80002fc6:	85e2                	mv	a1,s8
    80002fc8:	953a                	add	a0,a0,a4
    80002fca:	fffff097          	auipc	ra,0xfffff
    80002fce:	a3c080e7          	jalr	-1476(ra) # 80001a06 <either_copyin>
    80002fd2:	07950263          	beq	a0,s9,80003036 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002fd6:	8526                	mv	a0,s1
    80002fd8:	00000097          	auipc	ra,0x0
    80002fdc:	790080e7          	jalr	1936(ra) # 80003768 <log_write>
    brelse(bp);
    80002fe0:	8526                	mv	a0,s1
    80002fe2:	fffff097          	auipc	ra,0xfffff
    80002fe6:	50a080e7          	jalr	1290(ra) # 800024ec <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002fea:	01498a3b          	addw	s4,s3,s4
    80002fee:	0129893b          	addw	s2,s3,s2
    80002ff2:	9aee                	add	s5,s5,s11
    80002ff4:	057a7663          	bgeu	s4,s7,80003040 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80002ff8:	000b2483          	lw	s1,0(s6)
    80002ffc:	00a9559b          	srliw	a1,s2,0xa
    80003000:	855a                	mv	a0,s6
    80003002:	fffff097          	auipc	ra,0xfffff
    80003006:	7ae080e7          	jalr	1966(ra) # 800027b0 <bmap>
    8000300a:	0005059b          	sext.w	a1,a0
    8000300e:	8526                	mv	a0,s1
    80003010:	fffff097          	auipc	ra,0xfffff
    80003014:	3ac080e7          	jalr	940(ra) # 800023bc <bread>
    80003018:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000301a:	3ff97713          	andi	a4,s2,1023
    8000301e:	40ed07bb          	subw	a5,s10,a4
    80003022:	414b86bb          	subw	a3,s7,s4
    80003026:	89be                	mv	s3,a5
    80003028:	2781                	sext.w	a5,a5
    8000302a:	0006861b          	sext.w	a2,a3
    8000302e:	f8f674e3          	bgeu	a2,a5,80002fb6 <writei+0x4c>
    80003032:	89b6                	mv	s3,a3
    80003034:	b749                	j	80002fb6 <writei+0x4c>
      brelse(bp);
    80003036:	8526                	mv	a0,s1
    80003038:	fffff097          	auipc	ra,0xfffff
    8000303c:	4b4080e7          	jalr	1204(ra) # 800024ec <brelse>
  }

  if(off > ip->size)
    80003040:	04cb2783          	lw	a5,76(s6)
    80003044:	0127f463          	bgeu	a5,s2,8000304c <writei+0xe2>
    ip->size = off;
    80003048:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000304c:	855a                	mv	a0,s6
    8000304e:	00000097          	auipc	ra,0x0
    80003052:	aa6080e7          	jalr	-1370(ra) # 80002af4 <iupdate>

  return tot;
    80003056:	000a051b          	sext.w	a0,s4
}
    8000305a:	70a6                	ld	ra,104(sp)
    8000305c:	7406                	ld	s0,96(sp)
    8000305e:	64e6                	ld	s1,88(sp)
    80003060:	6946                	ld	s2,80(sp)
    80003062:	69a6                	ld	s3,72(sp)
    80003064:	6a06                	ld	s4,64(sp)
    80003066:	7ae2                	ld	s5,56(sp)
    80003068:	7b42                	ld	s6,48(sp)
    8000306a:	7ba2                	ld	s7,40(sp)
    8000306c:	7c02                	ld	s8,32(sp)
    8000306e:	6ce2                	ld	s9,24(sp)
    80003070:	6d42                	ld	s10,16(sp)
    80003072:	6da2                	ld	s11,8(sp)
    80003074:	6165                	addi	sp,sp,112
    80003076:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003078:	8a5e                	mv	s4,s7
    8000307a:	bfc9                	j	8000304c <writei+0xe2>
    return -1;
    8000307c:	557d                	li	a0,-1
}
    8000307e:	8082                	ret
    return -1;
    80003080:	557d                	li	a0,-1
    80003082:	bfe1                	j	8000305a <writei+0xf0>
    return -1;
    80003084:	557d                	li	a0,-1
    80003086:	bfd1                	j	8000305a <writei+0xf0>

0000000080003088 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003088:	1141                	addi	sp,sp,-16
    8000308a:	e406                	sd	ra,8(sp)
    8000308c:	e022                	sd	s0,0(sp)
    8000308e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003090:	4639                	li	a2,14
    80003092:	ffffd097          	auipc	ra,0xffffd
    80003096:	206080e7          	jalr	518(ra) # 80000298 <strncmp>
}
    8000309a:	60a2                	ld	ra,8(sp)
    8000309c:	6402                	ld	s0,0(sp)
    8000309e:	0141                	addi	sp,sp,16
    800030a0:	8082                	ret

00000000800030a2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800030a2:	7139                	addi	sp,sp,-64
    800030a4:	fc06                	sd	ra,56(sp)
    800030a6:	f822                	sd	s0,48(sp)
    800030a8:	f426                	sd	s1,40(sp)
    800030aa:	f04a                	sd	s2,32(sp)
    800030ac:	ec4e                	sd	s3,24(sp)
    800030ae:	e852                	sd	s4,16(sp)
    800030b0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800030b2:	04451703          	lh	a4,68(a0)
    800030b6:	4785                	li	a5,1
    800030b8:	00f71a63          	bne	a4,a5,800030cc <dirlookup+0x2a>
    800030bc:	892a                	mv	s2,a0
    800030be:	89ae                	mv	s3,a1
    800030c0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800030c2:	457c                	lw	a5,76(a0)
    800030c4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800030c6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800030c8:	e79d                	bnez	a5,800030f6 <dirlookup+0x54>
    800030ca:	a8a5                	j	80003142 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800030cc:	00005517          	auipc	a0,0x5
    800030d0:	49c50513          	addi	a0,a0,1180 # 80008568 <syscalls+0x1a0>
    800030d4:	00003097          	auipc	ra,0x3
    800030d8:	c9e080e7          	jalr	-866(ra) # 80005d72 <panic>
      panic("dirlookup read");
    800030dc:	00005517          	auipc	a0,0x5
    800030e0:	4a450513          	addi	a0,a0,1188 # 80008580 <syscalls+0x1b8>
    800030e4:	00003097          	auipc	ra,0x3
    800030e8:	c8e080e7          	jalr	-882(ra) # 80005d72 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800030ec:	24c1                	addiw	s1,s1,16
    800030ee:	04c92783          	lw	a5,76(s2)
    800030f2:	04f4f763          	bgeu	s1,a5,80003140 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800030f6:	4741                	li	a4,16
    800030f8:	86a6                	mv	a3,s1
    800030fa:	fc040613          	addi	a2,s0,-64
    800030fe:	4581                	li	a1,0
    80003100:	854a                	mv	a0,s2
    80003102:	00000097          	auipc	ra,0x0
    80003106:	d70080e7          	jalr	-656(ra) # 80002e72 <readi>
    8000310a:	47c1                	li	a5,16
    8000310c:	fcf518e3          	bne	a0,a5,800030dc <dirlookup+0x3a>
    if(de.inum == 0)
    80003110:	fc045783          	lhu	a5,-64(s0)
    80003114:	dfe1                	beqz	a5,800030ec <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003116:	fc240593          	addi	a1,s0,-62
    8000311a:	854e                	mv	a0,s3
    8000311c:	00000097          	auipc	ra,0x0
    80003120:	f6c080e7          	jalr	-148(ra) # 80003088 <namecmp>
    80003124:	f561                	bnez	a0,800030ec <dirlookup+0x4a>
      if(poff)
    80003126:	000a0463          	beqz	s4,8000312e <dirlookup+0x8c>
        *poff = off;
    8000312a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000312e:	fc045583          	lhu	a1,-64(s0)
    80003132:	00092503          	lw	a0,0(s2)
    80003136:	fffff097          	auipc	ra,0xfffff
    8000313a:	754080e7          	jalr	1876(ra) # 8000288a <iget>
    8000313e:	a011                	j	80003142 <dirlookup+0xa0>
  return 0;
    80003140:	4501                	li	a0,0
}
    80003142:	70e2                	ld	ra,56(sp)
    80003144:	7442                	ld	s0,48(sp)
    80003146:	74a2                	ld	s1,40(sp)
    80003148:	7902                	ld	s2,32(sp)
    8000314a:	69e2                	ld	s3,24(sp)
    8000314c:	6a42                	ld	s4,16(sp)
    8000314e:	6121                	addi	sp,sp,64
    80003150:	8082                	ret

0000000080003152 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003152:	711d                	addi	sp,sp,-96
    80003154:	ec86                	sd	ra,88(sp)
    80003156:	e8a2                	sd	s0,80(sp)
    80003158:	e4a6                	sd	s1,72(sp)
    8000315a:	e0ca                	sd	s2,64(sp)
    8000315c:	fc4e                	sd	s3,56(sp)
    8000315e:	f852                	sd	s4,48(sp)
    80003160:	f456                	sd	s5,40(sp)
    80003162:	f05a                	sd	s6,32(sp)
    80003164:	ec5e                	sd	s7,24(sp)
    80003166:	e862                	sd	s8,16(sp)
    80003168:	e466                	sd	s9,8(sp)
    8000316a:	1080                	addi	s0,sp,96
    8000316c:	84aa                	mv	s1,a0
    8000316e:	8b2e                	mv	s6,a1
    80003170:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003172:	00054703          	lbu	a4,0(a0)
    80003176:	02f00793          	li	a5,47
    8000317a:	02f70363          	beq	a4,a5,800031a0 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000317e:	ffffe097          	auipc	ra,0xffffe
    80003182:	dd2080e7          	jalr	-558(ra) # 80000f50 <myproc>
    80003186:	15053503          	ld	a0,336(a0)
    8000318a:	00000097          	auipc	ra,0x0
    8000318e:	9f6080e7          	jalr	-1546(ra) # 80002b80 <idup>
    80003192:	89aa                	mv	s3,a0
  while(*path == '/')
    80003194:	02f00913          	li	s2,47
  len = path - s;
    80003198:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    8000319a:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000319c:	4c05                	li	s8,1
    8000319e:	a865                	j	80003256 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800031a0:	4585                	li	a1,1
    800031a2:	4505                	li	a0,1
    800031a4:	fffff097          	auipc	ra,0xfffff
    800031a8:	6e6080e7          	jalr	1766(ra) # 8000288a <iget>
    800031ac:	89aa                	mv	s3,a0
    800031ae:	b7dd                	j	80003194 <namex+0x42>
      iunlockput(ip);
    800031b0:	854e                	mv	a0,s3
    800031b2:	00000097          	auipc	ra,0x0
    800031b6:	c6e080e7          	jalr	-914(ra) # 80002e20 <iunlockput>
      return 0;
    800031ba:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800031bc:	854e                	mv	a0,s3
    800031be:	60e6                	ld	ra,88(sp)
    800031c0:	6446                	ld	s0,80(sp)
    800031c2:	64a6                	ld	s1,72(sp)
    800031c4:	6906                	ld	s2,64(sp)
    800031c6:	79e2                	ld	s3,56(sp)
    800031c8:	7a42                	ld	s4,48(sp)
    800031ca:	7aa2                	ld	s5,40(sp)
    800031cc:	7b02                	ld	s6,32(sp)
    800031ce:	6be2                	ld	s7,24(sp)
    800031d0:	6c42                	ld	s8,16(sp)
    800031d2:	6ca2                	ld	s9,8(sp)
    800031d4:	6125                	addi	sp,sp,96
    800031d6:	8082                	ret
      iunlock(ip);
    800031d8:	854e                	mv	a0,s3
    800031da:	00000097          	auipc	ra,0x0
    800031de:	aa6080e7          	jalr	-1370(ra) # 80002c80 <iunlock>
      return ip;
    800031e2:	bfe9                	j	800031bc <namex+0x6a>
      iunlockput(ip);
    800031e4:	854e                	mv	a0,s3
    800031e6:	00000097          	auipc	ra,0x0
    800031ea:	c3a080e7          	jalr	-966(ra) # 80002e20 <iunlockput>
      return 0;
    800031ee:	89d2                	mv	s3,s4
    800031f0:	b7f1                	j	800031bc <namex+0x6a>
  len = path - s;
    800031f2:	40b48633          	sub	a2,s1,a1
    800031f6:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800031fa:	094cd463          	bge	s9,s4,80003282 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800031fe:	4639                	li	a2,14
    80003200:	8556                	mv	a0,s5
    80003202:	ffffd097          	auipc	ra,0xffffd
    80003206:	01e080e7          	jalr	30(ra) # 80000220 <memmove>
  while(*path == '/')
    8000320a:	0004c783          	lbu	a5,0(s1)
    8000320e:	01279763          	bne	a5,s2,8000321c <namex+0xca>
    path++;
    80003212:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003214:	0004c783          	lbu	a5,0(s1)
    80003218:	ff278de3          	beq	a5,s2,80003212 <namex+0xc0>
    ilock(ip);
    8000321c:	854e                	mv	a0,s3
    8000321e:	00000097          	auipc	ra,0x0
    80003222:	9a0080e7          	jalr	-1632(ra) # 80002bbe <ilock>
    if(ip->type != T_DIR){
    80003226:	04499783          	lh	a5,68(s3)
    8000322a:	f98793e3          	bne	a5,s8,800031b0 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000322e:	000b0563          	beqz	s6,80003238 <namex+0xe6>
    80003232:	0004c783          	lbu	a5,0(s1)
    80003236:	d3cd                	beqz	a5,800031d8 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003238:	865e                	mv	a2,s7
    8000323a:	85d6                	mv	a1,s5
    8000323c:	854e                	mv	a0,s3
    8000323e:	00000097          	auipc	ra,0x0
    80003242:	e64080e7          	jalr	-412(ra) # 800030a2 <dirlookup>
    80003246:	8a2a                	mv	s4,a0
    80003248:	dd51                	beqz	a0,800031e4 <namex+0x92>
    iunlockput(ip);
    8000324a:	854e                	mv	a0,s3
    8000324c:	00000097          	auipc	ra,0x0
    80003250:	bd4080e7          	jalr	-1068(ra) # 80002e20 <iunlockput>
    ip = next;
    80003254:	89d2                	mv	s3,s4
  while(*path == '/')
    80003256:	0004c783          	lbu	a5,0(s1)
    8000325a:	05279763          	bne	a5,s2,800032a8 <namex+0x156>
    path++;
    8000325e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003260:	0004c783          	lbu	a5,0(s1)
    80003264:	ff278de3          	beq	a5,s2,8000325e <namex+0x10c>
  if(*path == 0)
    80003268:	c79d                	beqz	a5,80003296 <namex+0x144>
    path++;
    8000326a:	85a6                	mv	a1,s1
  len = path - s;
    8000326c:	8a5e                	mv	s4,s7
    8000326e:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003270:	01278963          	beq	a5,s2,80003282 <namex+0x130>
    80003274:	dfbd                	beqz	a5,800031f2 <namex+0xa0>
    path++;
    80003276:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003278:	0004c783          	lbu	a5,0(s1)
    8000327c:	ff279ce3          	bne	a5,s2,80003274 <namex+0x122>
    80003280:	bf8d                	j	800031f2 <namex+0xa0>
    memmove(name, s, len);
    80003282:	2601                	sext.w	a2,a2
    80003284:	8556                	mv	a0,s5
    80003286:	ffffd097          	auipc	ra,0xffffd
    8000328a:	f9a080e7          	jalr	-102(ra) # 80000220 <memmove>
    name[len] = 0;
    8000328e:	9a56                	add	s4,s4,s5
    80003290:	000a0023          	sb	zero,0(s4)
    80003294:	bf9d                	j	8000320a <namex+0xb8>
  if(nameiparent){
    80003296:	f20b03e3          	beqz	s6,800031bc <namex+0x6a>
    iput(ip);
    8000329a:	854e                	mv	a0,s3
    8000329c:	00000097          	auipc	ra,0x0
    800032a0:	adc080e7          	jalr	-1316(ra) # 80002d78 <iput>
    return 0;
    800032a4:	4981                	li	s3,0
    800032a6:	bf19                	j	800031bc <namex+0x6a>
  if(*path == 0)
    800032a8:	d7fd                	beqz	a5,80003296 <namex+0x144>
  while(*path != '/' && *path != 0)
    800032aa:	0004c783          	lbu	a5,0(s1)
    800032ae:	85a6                	mv	a1,s1
    800032b0:	b7d1                	j	80003274 <namex+0x122>

00000000800032b2 <dirlink>:
{
    800032b2:	7139                	addi	sp,sp,-64
    800032b4:	fc06                	sd	ra,56(sp)
    800032b6:	f822                	sd	s0,48(sp)
    800032b8:	f426                	sd	s1,40(sp)
    800032ba:	f04a                	sd	s2,32(sp)
    800032bc:	ec4e                	sd	s3,24(sp)
    800032be:	e852                	sd	s4,16(sp)
    800032c0:	0080                	addi	s0,sp,64
    800032c2:	892a                	mv	s2,a0
    800032c4:	8a2e                	mv	s4,a1
    800032c6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800032c8:	4601                	li	a2,0
    800032ca:	00000097          	auipc	ra,0x0
    800032ce:	dd8080e7          	jalr	-552(ra) # 800030a2 <dirlookup>
    800032d2:	e93d                	bnez	a0,80003348 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800032d4:	04c92483          	lw	s1,76(s2)
    800032d8:	c49d                	beqz	s1,80003306 <dirlink+0x54>
    800032da:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800032dc:	4741                	li	a4,16
    800032de:	86a6                	mv	a3,s1
    800032e0:	fc040613          	addi	a2,s0,-64
    800032e4:	4581                	li	a1,0
    800032e6:	854a                	mv	a0,s2
    800032e8:	00000097          	auipc	ra,0x0
    800032ec:	b8a080e7          	jalr	-1142(ra) # 80002e72 <readi>
    800032f0:	47c1                	li	a5,16
    800032f2:	06f51163          	bne	a0,a5,80003354 <dirlink+0xa2>
    if(de.inum == 0)
    800032f6:	fc045783          	lhu	a5,-64(s0)
    800032fa:	c791                	beqz	a5,80003306 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800032fc:	24c1                	addiw	s1,s1,16
    800032fe:	04c92783          	lw	a5,76(s2)
    80003302:	fcf4ede3          	bltu	s1,a5,800032dc <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003306:	4639                	li	a2,14
    80003308:	85d2                	mv	a1,s4
    8000330a:	fc240513          	addi	a0,s0,-62
    8000330e:	ffffd097          	auipc	ra,0xffffd
    80003312:	fc6080e7          	jalr	-58(ra) # 800002d4 <strncpy>
  de.inum = inum;
    80003316:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000331a:	4741                	li	a4,16
    8000331c:	86a6                	mv	a3,s1
    8000331e:	fc040613          	addi	a2,s0,-64
    80003322:	4581                	li	a1,0
    80003324:	854a                	mv	a0,s2
    80003326:	00000097          	auipc	ra,0x0
    8000332a:	c44080e7          	jalr	-956(ra) # 80002f6a <writei>
    8000332e:	872a                	mv	a4,a0
    80003330:	47c1                	li	a5,16
  return 0;
    80003332:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003334:	02f71863          	bne	a4,a5,80003364 <dirlink+0xb2>
}
    80003338:	70e2                	ld	ra,56(sp)
    8000333a:	7442                	ld	s0,48(sp)
    8000333c:	74a2                	ld	s1,40(sp)
    8000333e:	7902                	ld	s2,32(sp)
    80003340:	69e2                	ld	s3,24(sp)
    80003342:	6a42                	ld	s4,16(sp)
    80003344:	6121                	addi	sp,sp,64
    80003346:	8082                	ret
    iput(ip);
    80003348:	00000097          	auipc	ra,0x0
    8000334c:	a30080e7          	jalr	-1488(ra) # 80002d78 <iput>
    return -1;
    80003350:	557d                	li	a0,-1
    80003352:	b7dd                	j	80003338 <dirlink+0x86>
      panic("dirlink read");
    80003354:	00005517          	auipc	a0,0x5
    80003358:	23c50513          	addi	a0,a0,572 # 80008590 <syscalls+0x1c8>
    8000335c:	00003097          	auipc	ra,0x3
    80003360:	a16080e7          	jalr	-1514(ra) # 80005d72 <panic>
    panic("dirlink");
    80003364:	00005517          	auipc	a0,0x5
    80003368:	33c50513          	addi	a0,a0,828 # 800086a0 <syscalls+0x2d8>
    8000336c:	00003097          	auipc	ra,0x3
    80003370:	a06080e7          	jalr	-1530(ra) # 80005d72 <panic>

0000000080003374 <namei>:

struct inode*
namei(char *path)
{
    80003374:	1101                	addi	sp,sp,-32
    80003376:	ec06                	sd	ra,24(sp)
    80003378:	e822                	sd	s0,16(sp)
    8000337a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000337c:	fe040613          	addi	a2,s0,-32
    80003380:	4581                	li	a1,0
    80003382:	00000097          	auipc	ra,0x0
    80003386:	dd0080e7          	jalr	-560(ra) # 80003152 <namex>
}
    8000338a:	60e2                	ld	ra,24(sp)
    8000338c:	6442                	ld	s0,16(sp)
    8000338e:	6105                	addi	sp,sp,32
    80003390:	8082                	ret

0000000080003392 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003392:	1141                	addi	sp,sp,-16
    80003394:	e406                	sd	ra,8(sp)
    80003396:	e022                	sd	s0,0(sp)
    80003398:	0800                	addi	s0,sp,16
    8000339a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000339c:	4585                	li	a1,1
    8000339e:	00000097          	auipc	ra,0x0
    800033a2:	db4080e7          	jalr	-588(ra) # 80003152 <namex>
}
    800033a6:	60a2                	ld	ra,8(sp)
    800033a8:	6402                	ld	s0,0(sp)
    800033aa:	0141                	addi	sp,sp,16
    800033ac:	8082                	ret

00000000800033ae <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800033ae:	1101                	addi	sp,sp,-32
    800033b0:	ec06                	sd	ra,24(sp)
    800033b2:	e822                	sd	s0,16(sp)
    800033b4:	e426                	sd	s1,8(sp)
    800033b6:	e04a                	sd	s2,0(sp)
    800033b8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800033ba:	00016917          	auipc	s2,0x16
    800033be:	c6690913          	addi	s2,s2,-922 # 80019020 <log>
    800033c2:	01892583          	lw	a1,24(s2)
    800033c6:	02892503          	lw	a0,40(s2)
    800033ca:	fffff097          	auipc	ra,0xfffff
    800033ce:	ff2080e7          	jalr	-14(ra) # 800023bc <bread>
    800033d2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800033d4:	02c92683          	lw	a3,44(s2)
    800033d8:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800033da:	02d05763          	blez	a3,80003408 <write_head+0x5a>
    800033de:	00016797          	auipc	a5,0x16
    800033e2:	c7278793          	addi	a5,a5,-910 # 80019050 <log+0x30>
    800033e6:	05c50713          	addi	a4,a0,92
    800033ea:	36fd                	addiw	a3,a3,-1
    800033ec:	1682                	slli	a3,a3,0x20
    800033ee:	9281                	srli	a3,a3,0x20
    800033f0:	068a                	slli	a3,a3,0x2
    800033f2:	00016617          	auipc	a2,0x16
    800033f6:	c6260613          	addi	a2,a2,-926 # 80019054 <log+0x34>
    800033fa:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800033fc:	4390                	lw	a2,0(a5)
    800033fe:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003400:	0791                	addi	a5,a5,4
    80003402:	0711                	addi	a4,a4,4
    80003404:	fed79ce3          	bne	a5,a3,800033fc <write_head+0x4e>
  }
  bwrite(buf);
    80003408:	8526                	mv	a0,s1
    8000340a:	fffff097          	auipc	ra,0xfffff
    8000340e:	0a4080e7          	jalr	164(ra) # 800024ae <bwrite>
  brelse(buf);
    80003412:	8526                	mv	a0,s1
    80003414:	fffff097          	auipc	ra,0xfffff
    80003418:	0d8080e7          	jalr	216(ra) # 800024ec <brelse>
}
    8000341c:	60e2                	ld	ra,24(sp)
    8000341e:	6442                	ld	s0,16(sp)
    80003420:	64a2                	ld	s1,8(sp)
    80003422:	6902                	ld	s2,0(sp)
    80003424:	6105                	addi	sp,sp,32
    80003426:	8082                	ret

0000000080003428 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003428:	00016797          	auipc	a5,0x16
    8000342c:	c247a783          	lw	a5,-988(a5) # 8001904c <log+0x2c>
    80003430:	0af05d63          	blez	a5,800034ea <install_trans+0xc2>
{
    80003434:	7139                	addi	sp,sp,-64
    80003436:	fc06                	sd	ra,56(sp)
    80003438:	f822                	sd	s0,48(sp)
    8000343a:	f426                	sd	s1,40(sp)
    8000343c:	f04a                	sd	s2,32(sp)
    8000343e:	ec4e                	sd	s3,24(sp)
    80003440:	e852                	sd	s4,16(sp)
    80003442:	e456                	sd	s5,8(sp)
    80003444:	e05a                	sd	s6,0(sp)
    80003446:	0080                	addi	s0,sp,64
    80003448:	8b2a                	mv	s6,a0
    8000344a:	00016a97          	auipc	s5,0x16
    8000344e:	c06a8a93          	addi	s5,s5,-1018 # 80019050 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003452:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003454:	00016997          	auipc	s3,0x16
    80003458:	bcc98993          	addi	s3,s3,-1076 # 80019020 <log>
    8000345c:	a035                	j	80003488 <install_trans+0x60>
      bunpin(dbuf);
    8000345e:	8526                	mv	a0,s1
    80003460:	fffff097          	auipc	ra,0xfffff
    80003464:	166080e7          	jalr	358(ra) # 800025c6 <bunpin>
    brelse(lbuf);
    80003468:	854a                	mv	a0,s2
    8000346a:	fffff097          	auipc	ra,0xfffff
    8000346e:	082080e7          	jalr	130(ra) # 800024ec <brelse>
    brelse(dbuf);
    80003472:	8526                	mv	a0,s1
    80003474:	fffff097          	auipc	ra,0xfffff
    80003478:	078080e7          	jalr	120(ra) # 800024ec <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000347c:	2a05                	addiw	s4,s4,1
    8000347e:	0a91                	addi	s5,s5,4
    80003480:	02c9a783          	lw	a5,44(s3)
    80003484:	04fa5963          	bge	s4,a5,800034d6 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003488:	0189a583          	lw	a1,24(s3)
    8000348c:	014585bb          	addw	a1,a1,s4
    80003490:	2585                	addiw	a1,a1,1
    80003492:	0289a503          	lw	a0,40(s3)
    80003496:	fffff097          	auipc	ra,0xfffff
    8000349a:	f26080e7          	jalr	-218(ra) # 800023bc <bread>
    8000349e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800034a0:	000aa583          	lw	a1,0(s5)
    800034a4:	0289a503          	lw	a0,40(s3)
    800034a8:	fffff097          	auipc	ra,0xfffff
    800034ac:	f14080e7          	jalr	-236(ra) # 800023bc <bread>
    800034b0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800034b2:	40000613          	li	a2,1024
    800034b6:	05890593          	addi	a1,s2,88
    800034ba:	05850513          	addi	a0,a0,88
    800034be:	ffffd097          	auipc	ra,0xffffd
    800034c2:	d62080e7          	jalr	-670(ra) # 80000220 <memmove>
    bwrite(dbuf);  // write dst to disk
    800034c6:	8526                	mv	a0,s1
    800034c8:	fffff097          	auipc	ra,0xfffff
    800034cc:	fe6080e7          	jalr	-26(ra) # 800024ae <bwrite>
    if(recovering == 0)
    800034d0:	f80b1ce3          	bnez	s6,80003468 <install_trans+0x40>
    800034d4:	b769                	j	8000345e <install_trans+0x36>
}
    800034d6:	70e2                	ld	ra,56(sp)
    800034d8:	7442                	ld	s0,48(sp)
    800034da:	74a2                	ld	s1,40(sp)
    800034dc:	7902                	ld	s2,32(sp)
    800034de:	69e2                	ld	s3,24(sp)
    800034e0:	6a42                	ld	s4,16(sp)
    800034e2:	6aa2                	ld	s5,8(sp)
    800034e4:	6b02                	ld	s6,0(sp)
    800034e6:	6121                	addi	sp,sp,64
    800034e8:	8082                	ret
    800034ea:	8082                	ret

00000000800034ec <initlog>:
{
    800034ec:	7179                	addi	sp,sp,-48
    800034ee:	f406                	sd	ra,40(sp)
    800034f0:	f022                	sd	s0,32(sp)
    800034f2:	ec26                	sd	s1,24(sp)
    800034f4:	e84a                	sd	s2,16(sp)
    800034f6:	e44e                	sd	s3,8(sp)
    800034f8:	1800                	addi	s0,sp,48
    800034fa:	892a                	mv	s2,a0
    800034fc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800034fe:	00016497          	auipc	s1,0x16
    80003502:	b2248493          	addi	s1,s1,-1246 # 80019020 <log>
    80003506:	00005597          	auipc	a1,0x5
    8000350a:	09a58593          	addi	a1,a1,154 # 800085a0 <syscalls+0x1d8>
    8000350e:	8526                	mv	a0,s1
    80003510:	00003097          	auipc	ra,0x3
    80003514:	d1c080e7          	jalr	-740(ra) # 8000622c <initlock>
  log.start = sb->logstart;
    80003518:	0149a583          	lw	a1,20(s3)
    8000351c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000351e:	0109a783          	lw	a5,16(s3)
    80003522:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003524:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003528:	854a                	mv	a0,s2
    8000352a:	fffff097          	auipc	ra,0xfffff
    8000352e:	e92080e7          	jalr	-366(ra) # 800023bc <bread>
  log.lh.n = lh->n;
    80003532:	4d3c                	lw	a5,88(a0)
    80003534:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003536:	02f05563          	blez	a5,80003560 <initlog+0x74>
    8000353a:	05c50713          	addi	a4,a0,92
    8000353e:	00016697          	auipc	a3,0x16
    80003542:	b1268693          	addi	a3,a3,-1262 # 80019050 <log+0x30>
    80003546:	37fd                	addiw	a5,a5,-1
    80003548:	1782                	slli	a5,a5,0x20
    8000354a:	9381                	srli	a5,a5,0x20
    8000354c:	078a                	slli	a5,a5,0x2
    8000354e:	06050613          	addi	a2,a0,96
    80003552:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80003554:	4310                	lw	a2,0(a4)
    80003556:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80003558:	0711                	addi	a4,a4,4
    8000355a:	0691                	addi	a3,a3,4
    8000355c:	fef71ce3          	bne	a4,a5,80003554 <initlog+0x68>
  brelse(buf);
    80003560:	fffff097          	auipc	ra,0xfffff
    80003564:	f8c080e7          	jalr	-116(ra) # 800024ec <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003568:	4505                	li	a0,1
    8000356a:	00000097          	auipc	ra,0x0
    8000356e:	ebe080e7          	jalr	-322(ra) # 80003428 <install_trans>
  log.lh.n = 0;
    80003572:	00016797          	auipc	a5,0x16
    80003576:	ac07ad23          	sw	zero,-1318(a5) # 8001904c <log+0x2c>
  write_head(); // clear the log
    8000357a:	00000097          	auipc	ra,0x0
    8000357e:	e34080e7          	jalr	-460(ra) # 800033ae <write_head>
}
    80003582:	70a2                	ld	ra,40(sp)
    80003584:	7402                	ld	s0,32(sp)
    80003586:	64e2                	ld	s1,24(sp)
    80003588:	6942                	ld	s2,16(sp)
    8000358a:	69a2                	ld	s3,8(sp)
    8000358c:	6145                	addi	sp,sp,48
    8000358e:	8082                	ret

0000000080003590 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003590:	1101                	addi	sp,sp,-32
    80003592:	ec06                	sd	ra,24(sp)
    80003594:	e822                	sd	s0,16(sp)
    80003596:	e426                	sd	s1,8(sp)
    80003598:	e04a                	sd	s2,0(sp)
    8000359a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000359c:	00016517          	auipc	a0,0x16
    800035a0:	a8450513          	addi	a0,a0,-1404 # 80019020 <log>
    800035a4:	00003097          	auipc	ra,0x3
    800035a8:	d18080e7          	jalr	-744(ra) # 800062bc <acquire>
  while(1){
    if(log.committing){
    800035ac:	00016497          	auipc	s1,0x16
    800035b0:	a7448493          	addi	s1,s1,-1420 # 80019020 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800035b4:	4979                	li	s2,30
    800035b6:	a039                	j	800035c4 <begin_op+0x34>
      sleep(&log, &log.lock);
    800035b8:	85a6                	mv	a1,s1
    800035ba:	8526                	mv	a0,s1
    800035bc:	ffffe097          	auipc	ra,0xffffe
    800035c0:	050080e7          	jalr	80(ra) # 8000160c <sleep>
    if(log.committing){
    800035c4:	50dc                	lw	a5,36(s1)
    800035c6:	fbed                	bnez	a5,800035b8 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800035c8:	509c                	lw	a5,32(s1)
    800035ca:	0017871b          	addiw	a4,a5,1
    800035ce:	0007069b          	sext.w	a3,a4
    800035d2:	0027179b          	slliw	a5,a4,0x2
    800035d6:	9fb9                	addw	a5,a5,a4
    800035d8:	0017979b          	slliw	a5,a5,0x1
    800035dc:	54d8                	lw	a4,44(s1)
    800035de:	9fb9                	addw	a5,a5,a4
    800035e0:	00f95963          	bge	s2,a5,800035f2 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800035e4:	85a6                	mv	a1,s1
    800035e6:	8526                	mv	a0,s1
    800035e8:	ffffe097          	auipc	ra,0xffffe
    800035ec:	024080e7          	jalr	36(ra) # 8000160c <sleep>
    800035f0:	bfd1                	j	800035c4 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800035f2:	00016517          	auipc	a0,0x16
    800035f6:	a2e50513          	addi	a0,a0,-1490 # 80019020 <log>
    800035fa:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800035fc:	00003097          	auipc	ra,0x3
    80003600:	d74080e7          	jalr	-652(ra) # 80006370 <release>
      break;
    }
  }
}
    80003604:	60e2                	ld	ra,24(sp)
    80003606:	6442                	ld	s0,16(sp)
    80003608:	64a2                	ld	s1,8(sp)
    8000360a:	6902                	ld	s2,0(sp)
    8000360c:	6105                	addi	sp,sp,32
    8000360e:	8082                	ret

0000000080003610 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003610:	7139                	addi	sp,sp,-64
    80003612:	fc06                	sd	ra,56(sp)
    80003614:	f822                	sd	s0,48(sp)
    80003616:	f426                	sd	s1,40(sp)
    80003618:	f04a                	sd	s2,32(sp)
    8000361a:	ec4e                	sd	s3,24(sp)
    8000361c:	e852                	sd	s4,16(sp)
    8000361e:	e456                	sd	s5,8(sp)
    80003620:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003622:	00016497          	auipc	s1,0x16
    80003626:	9fe48493          	addi	s1,s1,-1538 # 80019020 <log>
    8000362a:	8526                	mv	a0,s1
    8000362c:	00003097          	auipc	ra,0x3
    80003630:	c90080e7          	jalr	-880(ra) # 800062bc <acquire>
  log.outstanding -= 1;
    80003634:	509c                	lw	a5,32(s1)
    80003636:	37fd                	addiw	a5,a5,-1
    80003638:	0007891b          	sext.w	s2,a5
    8000363c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000363e:	50dc                	lw	a5,36(s1)
    80003640:	efb9                	bnez	a5,8000369e <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80003642:	06091663          	bnez	s2,800036ae <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80003646:	00016497          	auipc	s1,0x16
    8000364a:	9da48493          	addi	s1,s1,-1574 # 80019020 <log>
    8000364e:	4785                	li	a5,1
    80003650:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003652:	8526                	mv	a0,s1
    80003654:	00003097          	auipc	ra,0x3
    80003658:	d1c080e7          	jalr	-740(ra) # 80006370 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000365c:	54dc                	lw	a5,44(s1)
    8000365e:	06f04763          	bgtz	a5,800036cc <end_op+0xbc>
    acquire(&log.lock);
    80003662:	00016497          	auipc	s1,0x16
    80003666:	9be48493          	addi	s1,s1,-1602 # 80019020 <log>
    8000366a:	8526                	mv	a0,s1
    8000366c:	00003097          	auipc	ra,0x3
    80003670:	c50080e7          	jalr	-944(ra) # 800062bc <acquire>
    log.committing = 0;
    80003674:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003678:	8526                	mv	a0,s1
    8000367a:	ffffe097          	auipc	ra,0xffffe
    8000367e:	11e080e7          	jalr	286(ra) # 80001798 <wakeup>
    release(&log.lock);
    80003682:	8526                	mv	a0,s1
    80003684:	00003097          	auipc	ra,0x3
    80003688:	cec080e7          	jalr	-788(ra) # 80006370 <release>
}
    8000368c:	70e2                	ld	ra,56(sp)
    8000368e:	7442                	ld	s0,48(sp)
    80003690:	74a2                	ld	s1,40(sp)
    80003692:	7902                	ld	s2,32(sp)
    80003694:	69e2                	ld	s3,24(sp)
    80003696:	6a42                	ld	s4,16(sp)
    80003698:	6aa2                	ld	s5,8(sp)
    8000369a:	6121                	addi	sp,sp,64
    8000369c:	8082                	ret
    panic("log.committing");
    8000369e:	00005517          	auipc	a0,0x5
    800036a2:	f0a50513          	addi	a0,a0,-246 # 800085a8 <syscalls+0x1e0>
    800036a6:	00002097          	auipc	ra,0x2
    800036aa:	6cc080e7          	jalr	1740(ra) # 80005d72 <panic>
    wakeup(&log);
    800036ae:	00016497          	auipc	s1,0x16
    800036b2:	97248493          	addi	s1,s1,-1678 # 80019020 <log>
    800036b6:	8526                	mv	a0,s1
    800036b8:	ffffe097          	auipc	ra,0xffffe
    800036bc:	0e0080e7          	jalr	224(ra) # 80001798 <wakeup>
  release(&log.lock);
    800036c0:	8526                	mv	a0,s1
    800036c2:	00003097          	auipc	ra,0x3
    800036c6:	cae080e7          	jalr	-850(ra) # 80006370 <release>
  if(do_commit){
    800036ca:	b7c9                	j	8000368c <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800036cc:	00016a97          	auipc	s5,0x16
    800036d0:	984a8a93          	addi	s5,s5,-1660 # 80019050 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800036d4:	00016a17          	auipc	s4,0x16
    800036d8:	94ca0a13          	addi	s4,s4,-1716 # 80019020 <log>
    800036dc:	018a2583          	lw	a1,24(s4)
    800036e0:	012585bb          	addw	a1,a1,s2
    800036e4:	2585                	addiw	a1,a1,1
    800036e6:	028a2503          	lw	a0,40(s4)
    800036ea:	fffff097          	auipc	ra,0xfffff
    800036ee:	cd2080e7          	jalr	-814(ra) # 800023bc <bread>
    800036f2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800036f4:	000aa583          	lw	a1,0(s5)
    800036f8:	028a2503          	lw	a0,40(s4)
    800036fc:	fffff097          	auipc	ra,0xfffff
    80003700:	cc0080e7          	jalr	-832(ra) # 800023bc <bread>
    80003704:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003706:	40000613          	li	a2,1024
    8000370a:	05850593          	addi	a1,a0,88
    8000370e:	05848513          	addi	a0,s1,88
    80003712:	ffffd097          	auipc	ra,0xffffd
    80003716:	b0e080e7          	jalr	-1266(ra) # 80000220 <memmove>
    bwrite(to);  // write the log
    8000371a:	8526                	mv	a0,s1
    8000371c:	fffff097          	auipc	ra,0xfffff
    80003720:	d92080e7          	jalr	-622(ra) # 800024ae <bwrite>
    brelse(from);
    80003724:	854e                	mv	a0,s3
    80003726:	fffff097          	auipc	ra,0xfffff
    8000372a:	dc6080e7          	jalr	-570(ra) # 800024ec <brelse>
    brelse(to);
    8000372e:	8526                	mv	a0,s1
    80003730:	fffff097          	auipc	ra,0xfffff
    80003734:	dbc080e7          	jalr	-580(ra) # 800024ec <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003738:	2905                	addiw	s2,s2,1
    8000373a:	0a91                	addi	s5,s5,4
    8000373c:	02ca2783          	lw	a5,44(s4)
    80003740:	f8f94ee3          	blt	s2,a5,800036dc <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003744:	00000097          	auipc	ra,0x0
    80003748:	c6a080e7          	jalr	-918(ra) # 800033ae <write_head>
    install_trans(0); // Now install writes to home locations
    8000374c:	4501                	li	a0,0
    8000374e:	00000097          	auipc	ra,0x0
    80003752:	cda080e7          	jalr	-806(ra) # 80003428 <install_trans>
    log.lh.n = 0;
    80003756:	00016797          	auipc	a5,0x16
    8000375a:	8e07ab23          	sw	zero,-1802(a5) # 8001904c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000375e:	00000097          	auipc	ra,0x0
    80003762:	c50080e7          	jalr	-944(ra) # 800033ae <write_head>
    80003766:	bdf5                	j	80003662 <end_op+0x52>

0000000080003768 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003768:	1101                	addi	sp,sp,-32
    8000376a:	ec06                	sd	ra,24(sp)
    8000376c:	e822                	sd	s0,16(sp)
    8000376e:	e426                	sd	s1,8(sp)
    80003770:	e04a                	sd	s2,0(sp)
    80003772:	1000                	addi	s0,sp,32
    80003774:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003776:	00016917          	auipc	s2,0x16
    8000377a:	8aa90913          	addi	s2,s2,-1878 # 80019020 <log>
    8000377e:	854a                	mv	a0,s2
    80003780:	00003097          	auipc	ra,0x3
    80003784:	b3c080e7          	jalr	-1220(ra) # 800062bc <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003788:	02c92603          	lw	a2,44(s2)
    8000378c:	47f5                	li	a5,29
    8000378e:	06c7c563          	blt	a5,a2,800037f8 <log_write+0x90>
    80003792:	00016797          	auipc	a5,0x16
    80003796:	8aa7a783          	lw	a5,-1878(a5) # 8001903c <log+0x1c>
    8000379a:	37fd                	addiw	a5,a5,-1
    8000379c:	04f65e63          	bge	a2,a5,800037f8 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800037a0:	00016797          	auipc	a5,0x16
    800037a4:	8a07a783          	lw	a5,-1888(a5) # 80019040 <log+0x20>
    800037a8:	06f05063          	blez	a5,80003808 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800037ac:	4781                	li	a5,0
    800037ae:	06c05563          	blez	a2,80003818 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800037b2:	44cc                	lw	a1,12(s1)
    800037b4:	00016717          	auipc	a4,0x16
    800037b8:	89c70713          	addi	a4,a4,-1892 # 80019050 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800037bc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800037be:	4314                	lw	a3,0(a4)
    800037c0:	04b68c63          	beq	a3,a1,80003818 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800037c4:	2785                	addiw	a5,a5,1
    800037c6:	0711                	addi	a4,a4,4
    800037c8:	fef61be3          	bne	a2,a5,800037be <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800037cc:	0621                	addi	a2,a2,8
    800037ce:	060a                	slli	a2,a2,0x2
    800037d0:	00016797          	auipc	a5,0x16
    800037d4:	85078793          	addi	a5,a5,-1968 # 80019020 <log>
    800037d8:	963e                	add	a2,a2,a5
    800037da:	44dc                	lw	a5,12(s1)
    800037dc:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800037de:	8526                	mv	a0,s1
    800037e0:	fffff097          	auipc	ra,0xfffff
    800037e4:	daa080e7          	jalr	-598(ra) # 8000258a <bpin>
    log.lh.n++;
    800037e8:	00016717          	auipc	a4,0x16
    800037ec:	83870713          	addi	a4,a4,-1992 # 80019020 <log>
    800037f0:	575c                	lw	a5,44(a4)
    800037f2:	2785                	addiw	a5,a5,1
    800037f4:	d75c                	sw	a5,44(a4)
    800037f6:	a835                	j	80003832 <log_write+0xca>
    panic("too big a transaction");
    800037f8:	00005517          	auipc	a0,0x5
    800037fc:	dc050513          	addi	a0,a0,-576 # 800085b8 <syscalls+0x1f0>
    80003800:	00002097          	auipc	ra,0x2
    80003804:	572080e7          	jalr	1394(ra) # 80005d72 <panic>
    panic("log_write outside of trans");
    80003808:	00005517          	auipc	a0,0x5
    8000380c:	dc850513          	addi	a0,a0,-568 # 800085d0 <syscalls+0x208>
    80003810:	00002097          	auipc	ra,0x2
    80003814:	562080e7          	jalr	1378(ra) # 80005d72 <panic>
  log.lh.block[i] = b->blockno;
    80003818:	00878713          	addi	a4,a5,8
    8000381c:	00271693          	slli	a3,a4,0x2
    80003820:	00016717          	auipc	a4,0x16
    80003824:	80070713          	addi	a4,a4,-2048 # 80019020 <log>
    80003828:	9736                	add	a4,a4,a3
    8000382a:	44d4                	lw	a3,12(s1)
    8000382c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000382e:	faf608e3          	beq	a2,a5,800037de <log_write+0x76>
  }
  release(&log.lock);
    80003832:	00015517          	auipc	a0,0x15
    80003836:	7ee50513          	addi	a0,a0,2030 # 80019020 <log>
    8000383a:	00003097          	auipc	ra,0x3
    8000383e:	b36080e7          	jalr	-1226(ra) # 80006370 <release>
}
    80003842:	60e2                	ld	ra,24(sp)
    80003844:	6442                	ld	s0,16(sp)
    80003846:	64a2                	ld	s1,8(sp)
    80003848:	6902                	ld	s2,0(sp)
    8000384a:	6105                	addi	sp,sp,32
    8000384c:	8082                	ret

000000008000384e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000384e:	1101                	addi	sp,sp,-32
    80003850:	ec06                	sd	ra,24(sp)
    80003852:	e822                	sd	s0,16(sp)
    80003854:	e426                	sd	s1,8(sp)
    80003856:	e04a                	sd	s2,0(sp)
    80003858:	1000                	addi	s0,sp,32
    8000385a:	84aa                	mv	s1,a0
    8000385c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000385e:	00005597          	auipc	a1,0x5
    80003862:	d9258593          	addi	a1,a1,-622 # 800085f0 <syscalls+0x228>
    80003866:	0521                	addi	a0,a0,8
    80003868:	00003097          	auipc	ra,0x3
    8000386c:	9c4080e7          	jalr	-1596(ra) # 8000622c <initlock>
  lk->name = name;
    80003870:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003874:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003878:	0204a423          	sw	zero,40(s1)
}
    8000387c:	60e2                	ld	ra,24(sp)
    8000387e:	6442                	ld	s0,16(sp)
    80003880:	64a2                	ld	s1,8(sp)
    80003882:	6902                	ld	s2,0(sp)
    80003884:	6105                	addi	sp,sp,32
    80003886:	8082                	ret

0000000080003888 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003888:	1101                	addi	sp,sp,-32
    8000388a:	ec06                	sd	ra,24(sp)
    8000388c:	e822                	sd	s0,16(sp)
    8000388e:	e426                	sd	s1,8(sp)
    80003890:	e04a                	sd	s2,0(sp)
    80003892:	1000                	addi	s0,sp,32
    80003894:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003896:	00850913          	addi	s2,a0,8
    8000389a:	854a                	mv	a0,s2
    8000389c:	00003097          	auipc	ra,0x3
    800038a0:	a20080e7          	jalr	-1504(ra) # 800062bc <acquire>
  while (lk->locked) {
    800038a4:	409c                	lw	a5,0(s1)
    800038a6:	cb89                	beqz	a5,800038b8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800038a8:	85ca                	mv	a1,s2
    800038aa:	8526                	mv	a0,s1
    800038ac:	ffffe097          	auipc	ra,0xffffe
    800038b0:	d60080e7          	jalr	-672(ra) # 8000160c <sleep>
  while (lk->locked) {
    800038b4:	409c                	lw	a5,0(s1)
    800038b6:	fbed                	bnez	a5,800038a8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800038b8:	4785                	li	a5,1
    800038ba:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800038bc:	ffffd097          	auipc	ra,0xffffd
    800038c0:	694080e7          	jalr	1684(ra) # 80000f50 <myproc>
    800038c4:	591c                	lw	a5,48(a0)
    800038c6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800038c8:	854a                	mv	a0,s2
    800038ca:	00003097          	auipc	ra,0x3
    800038ce:	aa6080e7          	jalr	-1370(ra) # 80006370 <release>
}
    800038d2:	60e2                	ld	ra,24(sp)
    800038d4:	6442                	ld	s0,16(sp)
    800038d6:	64a2                	ld	s1,8(sp)
    800038d8:	6902                	ld	s2,0(sp)
    800038da:	6105                	addi	sp,sp,32
    800038dc:	8082                	ret

00000000800038de <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800038de:	1101                	addi	sp,sp,-32
    800038e0:	ec06                	sd	ra,24(sp)
    800038e2:	e822                	sd	s0,16(sp)
    800038e4:	e426                	sd	s1,8(sp)
    800038e6:	e04a                	sd	s2,0(sp)
    800038e8:	1000                	addi	s0,sp,32
    800038ea:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800038ec:	00850913          	addi	s2,a0,8
    800038f0:	854a                	mv	a0,s2
    800038f2:	00003097          	auipc	ra,0x3
    800038f6:	9ca080e7          	jalr	-1590(ra) # 800062bc <acquire>
  lk->locked = 0;
    800038fa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800038fe:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003902:	8526                	mv	a0,s1
    80003904:	ffffe097          	auipc	ra,0xffffe
    80003908:	e94080e7          	jalr	-364(ra) # 80001798 <wakeup>
  release(&lk->lk);
    8000390c:	854a                	mv	a0,s2
    8000390e:	00003097          	auipc	ra,0x3
    80003912:	a62080e7          	jalr	-1438(ra) # 80006370 <release>
}
    80003916:	60e2                	ld	ra,24(sp)
    80003918:	6442                	ld	s0,16(sp)
    8000391a:	64a2                	ld	s1,8(sp)
    8000391c:	6902                	ld	s2,0(sp)
    8000391e:	6105                	addi	sp,sp,32
    80003920:	8082                	ret

0000000080003922 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003922:	7179                	addi	sp,sp,-48
    80003924:	f406                	sd	ra,40(sp)
    80003926:	f022                	sd	s0,32(sp)
    80003928:	ec26                	sd	s1,24(sp)
    8000392a:	e84a                	sd	s2,16(sp)
    8000392c:	e44e                	sd	s3,8(sp)
    8000392e:	1800                	addi	s0,sp,48
    80003930:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003932:	00850913          	addi	s2,a0,8
    80003936:	854a                	mv	a0,s2
    80003938:	00003097          	auipc	ra,0x3
    8000393c:	984080e7          	jalr	-1660(ra) # 800062bc <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003940:	409c                	lw	a5,0(s1)
    80003942:	ef99                	bnez	a5,80003960 <holdingsleep+0x3e>
    80003944:	4481                	li	s1,0
  release(&lk->lk);
    80003946:	854a                	mv	a0,s2
    80003948:	00003097          	auipc	ra,0x3
    8000394c:	a28080e7          	jalr	-1496(ra) # 80006370 <release>
  return r;
}
    80003950:	8526                	mv	a0,s1
    80003952:	70a2                	ld	ra,40(sp)
    80003954:	7402                	ld	s0,32(sp)
    80003956:	64e2                	ld	s1,24(sp)
    80003958:	6942                	ld	s2,16(sp)
    8000395a:	69a2                	ld	s3,8(sp)
    8000395c:	6145                	addi	sp,sp,48
    8000395e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003960:	0284a983          	lw	s3,40(s1)
    80003964:	ffffd097          	auipc	ra,0xffffd
    80003968:	5ec080e7          	jalr	1516(ra) # 80000f50 <myproc>
    8000396c:	5904                	lw	s1,48(a0)
    8000396e:	413484b3          	sub	s1,s1,s3
    80003972:	0014b493          	seqz	s1,s1
    80003976:	bfc1                	j	80003946 <holdingsleep+0x24>

0000000080003978 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003978:	1141                	addi	sp,sp,-16
    8000397a:	e406                	sd	ra,8(sp)
    8000397c:	e022                	sd	s0,0(sp)
    8000397e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003980:	00005597          	auipc	a1,0x5
    80003984:	c8058593          	addi	a1,a1,-896 # 80008600 <syscalls+0x238>
    80003988:	00015517          	auipc	a0,0x15
    8000398c:	7e050513          	addi	a0,a0,2016 # 80019168 <ftable>
    80003990:	00003097          	auipc	ra,0x3
    80003994:	89c080e7          	jalr	-1892(ra) # 8000622c <initlock>
}
    80003998:	60a2                	ld	ra,8(sp)
    8000399a:	6402                	ld	s0,0(sp)
    8000399c:	0141                	addi	sp,sp,16
    8000399e:	8082                	ret

00000000800039a0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800039a0:	1101                	addi	sp,sp,-32
    800039a2:	ec06                	sd	ra,24(sp)
    800039a4:	e822                	sd	s0,16(sp)
    800039a6:	e426                	sd	s1,8(sp)
    800039a8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800039aa:	00015517          	auipc	a0,0x15
    800039ae:	7be50513          	addi	a0,a0,1982 # 80019168 <ftable>
    800039b2:	00003097          	auipc	ra,0x3
    800039b6:	90a080e7          	jalr	-1782(ra) # 800062bc <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800039ba:	00015497          	auipc	s1,0x15
    800039be:	7c648493          	addi	s1,s1,1990 # 80019180 <ftable+0x18>
    800039c2:	00016717          	auipc	a4,0x16
    800039c6:	75e70713          	addi	a4,a4,1886 # 8001a120 <ftable+0xfb8>
    if(f->ref == 0){
    800039ca:	40dc                	lw	a5,4(s1)
    800039cc:	cf99                	beqz	a5,800039ea <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800039ce:	02848493          	addi	s1,s1,40
    800039d2:	fee49ce3          	bne	s1,a4,800039ca <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800039d6:	00015517          	auipc	a0,0x15
    800039da:	79250513          	addi	a0,a0,1938 # 80019168 <ftable>
    800039de:	00003097          	auipc	ra,0x3
    800039e2:	992080e7          	jalr	-1646(ra) # 80006370 <release>
  return 0;
    800039e6:	4481                	li	s1,0
    800039e8:	a819                	j	800039fe <filealloc+0x5e>
      f->ref = 1;
    800039ea:	4785                	li	a5,1
    800039ec:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800039ee:	00015517          	auipc	a0,0x15
    800039f2:	77a50513          	addi	a0,a0,1914 # 80019168 <ftable>
    800039f6:	00003097          	auipc	ra,0x3
    800039fa:	97a080e7          	jalr	-1670(ra) # 80006370 <release>
}
    800039fe:	8526                	mv	a0,s1
    80003a00:	60e2                	ld	ra,24(sp)
    80003a02:	6442                	ld	s0,16(sp)
    80003a04:	64a2                	ld	s1,8(sp)
    80003a06:	6105                	addi	sp,sp,32
    80003a08:	8082                	ret

0000000080003a0a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003a0a:	1101                	addi	sp,sp,-32
    80003a0c:	ec06                	sd	ra,24(sp)
    80003a0e:	e822                	sd	s0,16(sp)
    80003a10:	e426                	sd	s1,8(sp)
    80003a12:	1000                	addi	s0,sp,32
    80003a14:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003a16:	00015517          	auipc	a0,0x15
    80003a1a:	75250513          	addi	a0,a0,1874 # 80019168 <ftable>
    80003a1e:	00003097          	auipc	ra,0x3
    80003a22:	89e080e7          	jalr	-1890(ra) # 800062bc <acquire>
  if(f->ref < 1)
    80003a26:	40dc                	lw	a5,4(s1)
    80003a28:	02f05263          	blez	a5,80003a4c <filedup+0x42>
    panic("filedup");
  f->ref++;
    80003a2c:	2785                	addiw	a5,a5,1
    80003a2e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003a30:	00015517          	auipc	a0,0x15
    80003a34:	73850513          	addi	a0,a0,1848 # 80019168 <ftable>
    80003a38:	00003097          	auipc	ra,0x3
    80003a3c:	938080e7          	jalr	-1736(ra) # 80006370 <release>
  return f;
}
    80003a40:	8526                	mv	a0,s1
    80003a42:	60e2                	ld	ra,24(sp)
    80003a44:	6442                	ld	s0,16(sp)
    80003a46:	64a2                	ld	s1,8(sp)
    80003a48:	6105                	addi	sp,sp,32
    80003a4a:	8082                	ret
    panic("filedup");
    80003a4c:	00005517          	auipc	a0,0x5
    80003a50:	bbc50513          	addi	a0,a0,-1092 # 80008608 <syscalls+0x240>
    80003a54:	00002097          	auipc	ra,0x2
    80003a58:	31e080e7          	jalr	798(ra) # 80005d72 <panic>

0000000080003a5c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003a5c:	7139                	addi	sp,sp,-64
    80003a5e:	fc06                	sd	ra,56(sp)
    80003a60:	f822                	sd	s0,48(sp)
    80003a62:	f426                	sd	s1,40(sp)
    80003a64:	f04a                	sd	s2,32(sp)
    80003a66:	ec4e                	sd	s3,24(sp)
    80003a68:	e852                	sd	s4,16(sp)
    80003a6a:	e456                	sd	s5,8(sp)
    80003a6c:	0080                	addi	s0,sp,64
    80003a6e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003a70:	00015517          	auipc	a0,0x15
    80003a74:	6f850513          	addi	a0,a0,1784 # 80019168 <ftable>
    80003a78:	00003097          	auipc	ra,0x3
    80003a7c:	844080e7          	jalr	-1980(ra) # 800062bc <acquire>
  if(f->ref < 1)
    80003a80:	40dc                	lw	a5,4(s1)
    80003a82:	06f05163          	blez	a5,80003ae4 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80003a86:	37fd                	addiw	a5,a5,-1
    80003a88:	0007871b          	sext.w	a4,a5
    80003a8c:	c0dc                	sw	a5,4(s1)
    80003a8e:	06e04363          	bgtz	a4,80003af4 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003a92:	0004a903          	lw	s2,0(s1)
    80003a96:	0094ca83          	lbu	s5,9(s1)
    80003a9a:	0104ba03          	ld	s4,16(s1)
    80003a9e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003aa2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003aa6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003aaa:	00015517          	auipc	a0,0x15
    80003aae:	6be50513          	addi	a0,a0,1726 # 80019168 <ftable>
    80003ab2:	00003097          	auipc	ra,0x3
    80003ab6:	8be080e7          	jalr	-1858(ra) # 80006370 <release>

  if(ff.type == FD_PIPE){
    80003aba:	4785                	li	a5,1
    80003abc:	04f90d63          	beq	s2,a5,80003b16 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003ac0:	3979                	addiw	s2,s2,-2
    80003ac2:	4785                	li	a5,1
    80003ac4:	0527e063          	bltu	a5,s2,80003b04 <fileclose+0xa8>
    begin_op();
    80003ac8:	00000097          	auipc	ra,0x0
    80003acc:	ac8080e7          	jalr	-1336(ra) # 80003590 <begin_op>
    iput(ff.ip);
    80003ad0:	854e                	mv	a0,s3
    80003ad2:	fffff097          	auipc	ra,0xfffff
    80003ad6:	2a6080e7          	jalr	678(ra) # 80002d78 <iput>
    end_op();
    80003ada:	00000097          	auipc	ra,0x0
    80003ade:	b36080e7          	jalr	-1226(ra) # 80003610 <end_op>
    80003ae2:	a00d                	j	80003b04 <fileclose+0xa8>
    panic("fileclose");
    80003ae4:	00005517          	auipc	a0,0x5
    80003ae8:	b2c50513          	addi	a0,a0,-1236 # 80008610 <syscalls+0x248>
    80003aec:	00002097          	auipc	ra,0x2
    80003af0:	286080e7          	jalr	646(ra) # 80005d72 <panic>
    release(&ftable.lock);
    80003af4:	00015517          	auipc	a0,0x15
    80003af8:	67450513          	addi	a0,a0,1652 # 80019168 <ftable>
    80003afc:	00003097          	auipc	ra,0x3
    80003b00:	874080e7          	jalr	-1932(ra) # 80006370 <release>
  }
}
    80003b04:	70e2                	ld	ra,56(sp)
    80003b06:	7442                	ld	s0,48(sp)
    80003b08:	74a2                	ld	s1,40(sp)
    80003b0a:	7902                	ld	s2,32(sp)
    80003b0c:	69e2                	ld	s3,24(sp)
    80003b0e:	6a42                	ld	s4,16(sp)
    80003b10:	6aa2                	ld	s5,8(sp)
    80003b12:	6121                	addi	sp,sp,64
    80003b14:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003b16:	85d6                	mv	a1,s5
    80003b18:	8552                	mv	a0,s4
    80003b1a:	00000097          	auipc	ra,0x0
    80003b1e:	34c080e7          	jalr	844(ra) # 80003e66 <pipeclose>
    80003b22:	b7cd                	j	80003b04 <fileclose+0xa8>

0000000080003b24 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003b24:	715d                	addi	sp,sp,-80
    80003b26:	e486                	sd	ra,72(sp)
    80003b28:	e0a2                	sd	s0,64(sp)
    80003b2a:	fc26                	sd	s1,56(sp)
    80003b2c:	f84a                	sd	s2,48(sp)
    80003b2e:	f44e                	sd	s3,40(sp)
    80003b30:	0880                	addi	s0,sp,80
    80003b32:	84aa                	mv	s1,a0
    80003b34:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003b36:	ffffd097          	auipc	ra,0xffffd
    80003b3a:	41a080e7          	jalr	1050(ra) # 80000f50 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003b3e:	409c                	lw	a5,0(s1)
    80003b40:	37f9                	addiw	a5,a5,-2
    80003b42:	4705                	li	a4,1
    80003b44:	04f76763          	bltu	a4,a5,80003b92 <filestat+0x6e>
    80003b48:	892a                	mv	s2,a0
    ilock(f->ip);
    80003b4a:	6c88                	ld	a0,24(s1)
    80003b4c:	fffff097          	auipc	ra,0xfffff
    80003b50:	072080e7          	jalr	114(ra) # 80002bbe <ilock>
    stati(f->ip, &st);
    80003b54:	fb840593          	addi	a1,s0,-72
    80003b58:	6c88                	ld	a0,24(s1)
    80003b5a:	fffff097          	auipc	ra,0xfffff
    80003b5e:	2ee080e7          	jalr	750(ra) # 80002e48 <stati>
    iunlock(f->ip);
    80003b62:	6c88                	ld	a0,24(s1)
    80003b64:	fffff097          	auipc	ra,0xfffff
    80003b68:	11c080e7          	jalr	284(ra) # 80002c80 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003b6c:	46e1                	li	a3,24
    80003b6e:	fb840613          	addi	a2,s0,-72
    80003b72:	85ce                	mv	a1,s3
    80003b74:	05093503          	ld	a0,80(s2)
    80003b78:	ffffd097          	auipc	ra,0xffffd
    80003b7c:	09a080e7          	jalr	154(ra) # 80000c12 <copyout>
    80003b80:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003b84:	60a6                	ld	ra,72(sp)
    80003b86:	6406                	ld	s0,64(sp)
    80003b88:	74e2                	ld	s1,56(sp)
    80003b8a:	7942                	ld	s2,48(sp)
    80003b8c:	79a2                	ld	s3,40(sp)
    80003b8e:	6161                	addi	sp,sp,80
    80003b90:	8082                	ret
  return -1;
    80003b92:	557d                	li	a0,-1
    80003b94:	bfc5                	j	80003b84 <filestat+0x60>

0000000080003b96 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003b96:	7179                	addi	sp,sp,-48
    80003b98:	f406                	sd	ra,40(sp)
    80003b9a:	f022                	sd	s0,32(sp)
    80003b9c:	ec26                	sd	s1,24(sp)
    80003b9e:	e84a                	sd	s2,16(sp)
    80003ba0:	e44e                	sd	s3,8(sp)
    80003ba2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003ba4:	00854783          	lbu	a5,8(a0)
    80003ba8:	c3d5                	beqz	a5,80003c4c <fileread+0xb6>
    80003baa:	84aa                	mv	s1,a0
    80003bac:	89ae                	mv	s3,a1
    80003bae:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003bb0:	411c                	lw	a5,0(a0)
    80003bb2:	4705                	li	a4,1
    80003bb4:	04e78963          	beq	a5,a4,80003c06 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003bb8:	470d                	li	a4,3
    80003bba:	04e78d63          	beq	a5,a4,80003c14 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003bbe:	4709                	li	a4,2
    80003bc0:	06e79e63          	bne	a5,a4,80003c3c <fileread+0xa6>
    ilock(f->ip);
    80003bc4:	6d08                	ld	a0,24(a0)
    80003bc6:	fffff097          	auipc	ra,0xfffff
    80003bca:	ff8080e7          	jalr	-8(ra) # 80002bbe <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003bce:	874a                	mv	a4,s2
    80003bd0:	5094                	lw	a3,32(s1)
    80003bd2:	864e                	mv	a2,s3
    80003bd4:	4585                	li	a1,1
    80003bd6:	6c88                	ld	a0,24(s1)
    80003bd8:	fffff097          	auipc	ra,0xfffff
    80003bdc:	29a080e7          	jalr	666(ra) # 80002e72 <readi>
    80003be0:	892a                	mv	s2,a0
    80003be2:	00a05563          	blez	a0,80003bec <fileread+0x56>
      f->off += r;
    80003be6:	509c                	lw	a5,32(s1)
    80003be8:	9fa9                	addw	a5,a5,a0
    80003bea:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003bec:	6c88                	ld	a0,24(s1)
    80003bee:	fffff097          	auipc	ra,0xfffff
    80003bf2:	092080e7          	jalr	146(ra) # 80002c80 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003bf6:	854a                	mv	a0,s2
    80003bf8:	70a2                	ld	ra,40(sp)
    80003bfa:	7402                	ld	s0,32(sp)
    80003bfc:	64e2                	ld	s1,24(sp)
    80003bfe:	6942                	ld	s2,16(sp)
    80003c00:	69a2                	ld	s3,8(sp)
    80003c02:	6145                	addi	sp,sp,48
    80003c04:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003c06:	6908                	ld	a0,16(a0)
    80003c08:	00000097          	auipc	ra,0x0
    80003c0c:	3c8080e7          	jalr	968(ra) # 80003fd0 <piperead>
    80003c10:	892a                	mv	s2,a0
    80003c12:	b7d5                	j	80003bf6 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003c14:	02451783          	lh	a5,36(a0)
    80003c18:	03079693          	slli	a3,a5,0x30
    80003c1c:	92c1                	srli	a3,a3,0x30
    80003c1e:	4725                	li	a4,9
    80003c20:	02d76863          	bltu	a4,a3,80003c50 <fileread+0xba>
    80003c24:	0792                	slli	a5,a5,0x4
    80003c26:	00015717          	auipc	a4,0x15
    80003c2a:	4a270713          	addi	a4,a4,1186 # 800190c8 <devsw>
    80003c2e:	97ba                	add	a5,a5,a4
    80003c30:	639c                	ld	a5,0(a5)
    80003c32:	c38d                	beqz	a5,80003c54 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80003c34:	4505                	li	a0,1
    80003c36:	9782                	jalr	a5
    80003c38:	892a                	mv	s2,a0
    80003c3a:	bf75                	j	80003bf6 <fileread+0x60>
    panic("fileread");
    80003c3c:	00005517          	auipc	a0,0x5
    80003c40:	9e450513          	addi	a0,a0,-1564 # 80008620 <syscalls+0x258>
    80003c44:	00002097          	auipc	ra,0x2
    80003c48:	12e080e7          	jalr	302(ra) # 80005d72 <panic>
    return -1;
    80003c4c:	597d                	li	s2,-1
    80003c4e:	b765                	j	80003bf6 <fileread+0x60>
      return -1;
    80003c50:	597d                	li	s2,-1
    80003c52:	b755                	j	80003bf6 <fileread+0x60>
    80003c54:	597d                	li	s2,-1
    80003c56:	b745                	j	80003bf6 <fileread+0x60>

0000000080003c58 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003c58:	715d                	addi	sp,sp,-80
    80003c5a:	e486                	sd	ra,72(sp)
    80003c5c:	e0a2                	sd	s0,64(sp)
    80003c5e:	fc26                	sd	s1,56(sp)
    80003c60:	f84a                	sd	s2,48(sp)
    80003c62:	f44e                	sd	s3,40(sp)
    80003c64:	f052                	sd	s4,32(sp)
    80003c66:	ec56                	sd	s5,24(sp)
    80003c68:	e85a                	sd	s6,16(sp)
    80003c6a:	e45e                	sd	s7,8(sp)
    80003c6c:	e062                	sd	s8,0(sp)
    80003c6e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003c70:	00954783          	lbu	a5,9(a0)
    80003c74:	10078663          	beqz	a5,80003d80 <filewrite+0x128>
    80003c78:	892a                	mv	s2,a0
    80003c7a:	8aae                	mv	s5,a1
    80003c7c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003c7e:	411c                	lw	a5,0(a0)
    80003c80:	4705                	li	a4,1
    80003c82:	02e78263          	beq	a5,a4,80003ca6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003c86:	470d                	li	a4,3
    80003c88:	02e78663          	beq	a5,a4,80003cb4 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003c8c:	4709                	li	a4,2
    80003c8e:	0ee79163          	bne	a5,a4,80003d70 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003c92:	0ac05d63          	blez	a2,80003d4c <filewrite+0xf4>
    int i = 0;
    80003c96:	4981                	li	s3,0
    80003c98:	6b05                	lui	s6,0x1
    80003c9a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80003c9e:	6b85                	lui	s7,0x1
    80003ca0:	c00b8b9b          	addiw	s7,s7,-1024
    80003ca4:	a861                	j	80003d3c <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80003ca6:	6908                	ld	a0,16(a0)
    80003ca8:	00000097          	auipc	ra,0x0
    80003cac:	22e080e7          	jalr	558(ra) # 80003ed6 <pipewrite>
    80003cb0:	8a2a                	mv	s4,a0
    80003cb2:	a045                	j	80003d52 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003cb4:	02451783          	lh	a5,36(a0)
    80003cb8:	03079693          	slli	a3,a5,0x30
    80003cbc:	92c1                	srli	a3,a3,0x30
    80003cbe:	4725                	li	a4,9
    80003cc0:	0cd76263          	bltu	a4,a3,80003d84 <filewrite+0x12c>
    80003cc4:	0792                	slli	a5,a5,0x4
    80003cc6:	00015717          	auipc	a4,0x15
    80003cca:	40270713          	addi	a4,a4,1026 # 800190c8 <devsw>
    80003cce:	97ba                	add	a5,a5,a4
    80003cd0:	679c                	ld	a5,8(a5)
    80003cd2:	cbdd                	beqz	a5,80003d88 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80003cd4:	4505                	li	a0,1
    80003cd6:	9782                	jalr	a5
    80003cd8:	8a2a                	mv	s4,a0
    80003cda:	a8a5                	j	80003d52 <filewrite+0xfa>
    80003cdc:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003ce0:	00000097          	auipc	ra,0x0
    80003ce4:	8b0080e7          	jalr	-1872(ra) # 80003590 <begin_op>
      ilock(f->ip);
    80003ce8:	01893503          	ld	a0,24(s2)
    80003cec:	fffff097          	auipc	ra,0xfffff
    80003cf0:	ed2080e7          	jalr	-302(ra) # 80002bbe <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003cf4:	8762                	mv	a4,s8
    80003cf6:	02092683          	lw	a3,32(s2)
    80003cfa:	01598633          	add	a2,s3,s5
    80003cfe:	4585                	li	a1,1
    80003d00:	01893503          	ld	a0,24(s2)
    80003d04:	fffff097          	auipc	ra,0xfffff
    80003d08:	266080e7          	jalr	614(ra) # 80002f6a <writei>
    80003d0c:	84aa                	mv	s1,a0
    80003d0e:	00a05763          	blez	a0,80003d1c <filewrite+0xc4>
        f->off += r;
    80003d12:	02092783          	lw	a5,32(s2)
    80003d16:	9fa9                	addw	a5,a5,a0
    80003d18:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003d1c:	01893503          	ld	a0,24(s2)
    80003d20:	fffff097          	auipc	ra,0xfffff
    80003d24:	f60080e7          	jalr	-160(ra) # 80002c80 <iunlock>
      end_op();
    80003d28:	00000097          	auipc	ra,0x0
    80003d2c:	8e8080e7          	jalr	-1816(ra) # 80003610 <end_op>

      if(r != n1){
    80003d30:	009c1f63          	bne	s8,s1,80003d4e <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80003d34:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003d38:	0149db63          	bge	s3,s4,80003d4e <filewrite+0xf6>
      int n1 = n - i;
    80003d3c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80003d40:	84be                	mv	s1,a5
    80003d42:	2781                	sext.w	a5,a5
    80003d44:	f8fb5ce3          	bge	s6,a5,80003cdc <filewrite+0x84>
    80003d48:	84de                	mv	s1,s7
    80003d4a:	bf49                	j	80003cdc <filewrite+0x84>
    int i = 0;
    80003d4c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003d4e:	013a1f63          	bne	s4,s3,80003d6c <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003d52:	8552                	mv	a0,s4
    80003d54:	60a6                	ld	ra,72(sp)
    80003d56:	6406                	ld	s0,64(sp)
    80003d58:	74e2                	ld	s1,56(sp)
    80003d5a:	7942                	ld	s2,48(sp)
    80003d5c:	79a2                	ld	s3,40(sp)
    80003d5e:	7a02                	ld	s4,32(sp)
    80003d60:	6ae2                	ld	s5,24(sp)
    80003d62:	6b42                	ld	s6,16(sp)
    80003d64:	6ba2                	ld	s7,8(sp)
    80003d66:	6c02                	ld	s8,0(sp)
    80003d68:	6161                	addi	sp,sp,80
    80003d6a:	8082                	ret
    ret = (i == n ? n : -1);
    80003d6c:	5a7d                	li	s4,-1
    80003d6e:	b7d5                	j	80003d52 <filewrite+0xfa>
    panic("filewrite");
    80003d70:	00005517          	auipc	a0,0x5
    80003d74:	8c050513          	addi	a0,a0,-1856 # 80008630 <syscalls+0x268>
    80003d78:	00002097          	auipc	ra,0x2
    80003d7c:	ffa080e7          	jalr	-6(ra) # 80005d72 <panic>
    return -1;
    80003d80:	5a7d                	li	s4,-1
    80003d82:	bfc1                	j	80003d52 <filewrite+0xfa>
      return -1;
    80003d84:	5a7d                	li	s4,-1
    80003d86:	b7f1                	j	80003d52 <filewrite+0xfa>
    80003d88:	5a7d                	li	s4,-1
    80003d8a:	b7e1                	j	80003d52 <filewrite+0xfa>

0000000080003d8c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003d8c:	7179                	addi	sp,sp,-48
    80003d8e:	f406                	sd	ra,40(sp)
    80003d90:	f022                	sd	s0,32(sp)
    80003d92:	ec26                	sd	s1,24(sp)
    80003d94:	e84a                	sd	s2,16(sp)
    80003d96:	e44e                	sd	s3,8(sp)
    80003d98:	e052                	sd	s4,0(sp)
    80003d9a:	1800                	addi	s0,sp,48
    80003d9c:	84aa                	mv	s1,a0
    80003d9e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003da0:	0005b023          	sd	zero,0(a1)
    80003da4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003da8:	00000097          	auipc	ra,0x0
    80003dac:	bf8080e7          	jalr	-1032(ra) # 800039a0 <filealloc>
    80003db0:	e088                	sd	a0,0(s1)
    80003db2:	c551                	beqz	a0,80003e3e <pipealloc+0xb2>
    80003db4:	00000097          	auipc	ra,0x0
    80003db8:	bec080e7          	jalr	-1044(ra) # 800039a0 <filealloc>
    80003dbc:	00aa3023          	sd	a0,0(s4)
    80003dc0:	c92d                	beqz	a0,80003e32 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003dc2:	ffffc097          	auipc	ra,0xffffc
    80003dc6:	370080e7          	jalr	880(ra) # 80000132 <kalloc>
    80003dca:	892a                	mv	s2,a0
    80003dcc:	c125                	beqz	a0,80003e2c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80003dce:	4985                	li	s3,1
    80003dd0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003dd4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003dd8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003ddc:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003de0:	00005597          	auipc	a1,0x5
    80003de4:	86058593          	addi	a1,a1,-1952 # 80008640 <syscalls+0x278>
    80003de8:	00002097          	auipc	ra,0x2
    80003dec:	444080e7          	jalr	1092(ra) # 8000622c <initlock>
  (*f0)->type = FD_PIPE;
    80003df0:	609c                	ld	a5,0(s1)
    80003df2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003df6:	609c                	ld	a5,0(s1)
    80003df8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003dfc:	609c                	ld	a5,0(s1)
    80003dfe:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003e02:	609c                	ld	a5,0(s1)
    80003e04:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003e08:	000a3783          	ld	a5,0(s4)
    80003e0c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003e10:	000a3783          	ld	a5,0(s4)
    80003e14:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003e18:	000a3783          	ld	a5,0(s4)
    80003e1c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003e20:	000a3783          	ld	a5,0(s4)
    80003e24:	0127b823          	sd	s2,16(a5)
  return 0;
    80003e28:	4501                	li	a0,0
    80003e2a:	a025                	j	80003e52 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003e2c:	6088                	ld	a0,0(s1)
    80003e2e:	e501                	bnez	a0,80003e36 <pipealloc+0xaa>
    80003e30:	a039                	j	80003e3e <pipealloc+0xb2>
    80003e32:	6088                	ld	a0,0(s1)
    80003e34:	c51d                	beqz	a0,80003e62 <pipealloc+0xd6>
    fileclose(*f0);
    80003e36:	00000097          	auipc	ra,0x0
    80003e3a:	c26080e7          	jalr	-986(ra) # 80003a5c <fileclose>
  if(*f1)
    80003e3e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003e42:	557d                	li	a0,-1
  if(*f1)
    80003e44:	c799                	beqz	a5,80003e52 <pipealloc+0xc6>
    fileclose(*f1);
    80003e46:	853e                	mv	a0,a5
    80003e48:	00000097          	auipc	ra,0x0
    80003e4c:	c14080e7          	jalr	-1004(ra) # 80003a5c <fileclose>
  return -1;
    80003e50:	557d                	li	a0,-1
}
    80003e52:	70a2                	ld	ra,40(sp)
    80003e54:	7402                	ld	s0,32(sp)
    80003e56:	64e2                	ld	s1,24(sp)
    80003e58:	6942                	ld	s2,16(sp)
    80003e5a:	69a2                	ld	s3,8(sp)
    80003e5c:	6a02                	ld	s4,0(sp)
    80003e5e:	6145                	addi	sp,sp,48
    80003e60:	8082                	ret
  return -1;
    80003e62:	557d                	li	a0,-1
    80003e64:	b7fd                	j	80003e52 <pipealloc+0xc6>

0000000080003e66 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003e66:	1101                	addi	sp,sp,-32
    80003e68:	ec06                	sd	ra,24(sp)
    80003e6a:	e822                	sd	s0,16(sp)
    80003e6c:	e426                	sd	s1,8(sp)
    80003e6e:	e04a                	sd	s2,0(sp)
    80003e70:	1000                	addi	s0,sp,32
    80003e72:	84aa                	mv	s1,a0
    80003e74:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003e76:	00002097          	auipc	ra,0x2
    80003e7a:	446080e7          	jalr	1094(ra) # 800062bc <acquire>
  if(writable){
    80003e7e:	02090d63          	beqz	s2,80003eb8 <pipeclose+0x52>
    pi->writeopen = 0;
    80003e82:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003e86:	21848513          	addi	a0,s1,536
    80003e8a:	ffffe097          	auipc	ra,0xffffe
    80003e8e:	90e080e7          	jalr	-1778(ra) # 80001798 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003e92:	2204b783          	ld	a5,544(s1)
    80003e96:	eb95                	bnez	a5,80003eca <pipeclose+0x64>
    release(&pi->lock);
    80003e98:	8526                	mv	a0,s1
    80003e9a:	00002097          	auipc	ra,0x2
    80003e9e:	4d6080e7          	jalr	1238(ra) # 80006370 <release>
    kfree((char*)pi);
    80003ea2:	8526                	mv	a0,s1
    80003ea4:	ffffc097          	auipc	ra,0xffffc
    80003ea8:	178080e7          	jalr	376(ra) # 8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003eac:	60e2                	ld	ra,24(sp)
    80003eae:	6442                	ld	s0,16(sp)
    80003eb0:	64a2                	ld	s1,8(sp)
    80003eb2:	6902                	ld	s2,0(sp)
    80003eb4:	6105                	addi	sp,sp,32
    80003eb6:	8082                	ret
    pi->readopen = 0;
    80003eb8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003ebc:	21c48513          	addi	a0,s1,540
    80003ec0:	ffffe097          	auipc	ra,0xffffe
    80003ec4:	8d8080e7          	jalr	-1832(ra) # 80001798 <wakeup>
    80003ec8:	b7e9                	j	80003e92 <pipeclose+0x2c>
    release(&pi->lock);
    80003eca:	8526                	mv	a0,s1
    80003ecc:	00002097          	auipc	ra,0x2
    80003ed0:	4a4080e7          	jalr	1188(ra) # 80006370 <release>
}
    80003ed4:	bfe1                	j	80003eac <pipeclose+0x46>

0000000080003ed6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003ed6:	7159                	addi	sp,sp,-112
    80003ed8:	f486                	sd	ra,104(sp)
    80003eda:	f0a2                	sd	s0,96(sp)
    80003edc:	eca6                	sd	s1,88(sp)
    80003ede:	e8ca                	sd	s2,80(sp)
    80003ee0:	e4ce                	sd	s3,72(sp)
    80003ee2:	e0d2                	sd	s4,64(sp)
    80003ee4:	fc56                	sd	s5,56(sp)
    80003ee6:	f85a                	sd	s6,48(sp)
    80003ee8:	f45e                	sd	s7,40(sp)
    80003eea:	f062                	sd	s8,32(sp)
    80003eec:	ec66                	sd	s9,24(sp)
    80003eee:	1880                	addi	s0,sp,112
    80003ef0:	84aa                	mv	s1,a0
    80003ef2:	8aae                	mv	s5,a1
    80003ef4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003ef6:	ffffd097          	auipc	ra,0xffffd
    80003efa:	05a080e7          	jalr	90(ra) # 80000f50 <myproc>
    80003efe:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003f00:	8526                	mv	a0,s1
    80003f02:	00002097          	auipc	ra,0x2
    80003f06:	3ba080e7          	jalr	954(ra) # 800062bc <acquire>
  while(i < n){
    80003f0a:	0d405163          	blez	s4,80003fcc <pipewrite+0xf6>
    80003f0e:	8ba6                	mv	s7,s1
  int i = 0;
    80003f10:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003f12:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003f14:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003f18:	21c48c13          	addi	s8,s1,540
    80003f1c:	a08d                	j	80003f7e <pipewrite+0xa8>
      release(&pi->lock);
    80003f1e:	8526                	mv	a0,s1
    80003f20:	00002097          	auipc	ra,0x2
    80003f24:	450080e7          	jalr	1104(ra) # 80006370 <release>
      return -1;
    80003f28:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003f2a:	854a                	mv	a0,s2
    80003f2c:	70a6                	ld	ra,104(sp)
    80003f2e:	7406                	ld	s0,96(sp)
    80003f30:	64e6                	ld	s1,88(sp)
    80003f32:	6946                	ld	s2,80(sp)
    80003f34:	69a6                	ld	s3,72(sp)
    80003f36:	6a06                	ld	s4,64(sp)
    80003f38:	7ae2                	ld	s5,56(sp)
    80003f3a:	7b42                	ld	s6,48(sp)
    80003f3c:	7ba2                	ld	s7,40(sp)
    80003f3e:	7c02                	ld	s8,32(sp)
    80003f40:	6ce2                	ld	s9,24(sp)
    80003f42:	6165                	addi	sp,sp,112
    80003f44:	8082                	ret
      wakeup(&pi->nread);
    80003f46:	8566                	mv	a0,s9
    80003f48:	ffffe097          	auipc	ra,0xffffe
    80003f4c:	850080e7          	jalr	-1968(ra) # 80001798 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003f50:	85de                	mv	a1,s7
    80003f52:	8562                	mv	a0,s8
    80003f54:	ffffd097          	auipc	ra,0xffffd
    80003f58:	6b8080e7          	jalr	1720(ra) # 8000160c <sleep>
    80003f5c:	a839                	j	80003f7a <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003f5e:	21c4a783          	lw	a5,540(s1)
    80003f62:	0017871b          	addiw	a4,a5,1
    80003f66:	20e4ae23          	sw	a4,540(s1)
    80003f6a:	1ff7f793          	andi	a5,a5,511
    80003f6e:	97a6                	add	a5,a5,s1
    80003f70:	f9f44703          	lbu	a4,-97(s0)
    80003f74:	00e78c23          	sb	a4,24(a5)
      i++;
    80003f78:	2905                	addiw	s2,s2,1
  while(i < n){
    80003f7a:	03495d63          	bge	s2,s4,80003fb4 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80003f7e:	2204a783          	lw	a5,544(s1)
    80003f82:	dfd1                	beqz	a5,80003f1e <pipewrite+0x48>
    80003f84:	0289a783          	lw	a5,40(s3)
    80003f88:	fbd9                	bnez	a5,80003f1e <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003f8a:	2184a783          	lw	a5,536(s1)
    80003f8e:	21c4a703          	lw	a4,540(s1)
    80003f92:	2007879b          	addiw	a5,a5,512
    80003f96:	faf708e3          	beq	a4,a5,80003f46 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003f9a:	4685                	li	a3,1
    80003f9c:	01590633          	add	a2,s2,s5
    80003fa0:	f9f40593          	addi	a1,s0,-97
    80003fa4:	0509b503          	ld	a0,80(s3)
    80003fa8:	ffffd097          	auipc	ra,0xffffd
    80003fac:	cf6080e7          	jalr	-778(ra) # 80000c9e <copyin>
    80003fb0:	fb6517e3          	bne	a0,s6,80003f5e <pipewrite+0x88>
  wakeup(&pi->nread);
    80003fb4:	21848513          	addi	a0,s1,536
    80003fb8:	ffffd097          	auipc	ra,0xffffd
    80003fbc:	7e0080e7          	jalr	2016(ra) # 80001798 <wakeup>
  release(&pi->lock);
    80003fc0:	8526                	mv	a0,s1
    80003fc2:	00002097          	auipc	ra,0x2
    80003fc6:	3ae080e7          	jalr	942(ra) # 80006370 <release>
  return i;
    80003fca:	b785                	j	80003f2a <pipewrite+0x54>
  int i = 0;
    80003fcc:	4901                	li	s2,0
    80003fce:	b7dd                	j	80003fb4 <pipewrite+0xde>

0000000080003fd0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003fd0:	715d                	addi	sp,sp,-80
    80003fd2:	e486                	sd	ra,72(sp)
    80003fd4:	e0a2                	sd	s0,64(sp)
    80003fd6:	fc26                	sd	s1,56(sp)
    80003fd8:	f84a                	sd	s2,48(sp)
    80003fda:	f44e                	sd	s3,40(sp)
    80003fdc:	f052                	sd	s4,32(sp)
    80003fde:	ec56                	sd	s5,24(sp)
    80003fe0:	e85a                	sd	s6,16(sp)
    80003fe2:	0880                	addi	s0,sp,80
    80003fe4:	84aa                	mv	s1,a0
    80003fe6:	892e                	mv	s2,a1
    80003fe8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003fea:	ffffd097          	auipc	ra,0xffffd
    80003fee:	f66080e7          	jalr	-154(ra) # 80000f50 <myproc>
    80003ff2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003ff4:	8b26                	mv	s6,s1
    80003ff6:	8526                	mv	a0,s1
    80003ff8:	00002097          	auipc	ra,0x2
    80003ffc:	2c4080e7          	jalr	708(ra) # 800062bc <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004000:	2184a703          	lw	a4,536(s1)
    80004004:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004008:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000400c:	02f71463          	bne	a4,a5,80004034 <piperead+0x64>
    80004010:	2244a783          	lw	a5,548(s1)
    80004014:	c385                	beqz	a5,80004034 <piperead+0x64>
    if(pr->killed){
    80004016:	028a2783          	lw	a5,40(s4)
    8000401a:	ebc1                	bnez	a5,800040aa <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000401c:	85da                	mv	a1,s6
    8000401e:	854e                	mv	a0,s3
    80004020:	ffffd097          	auipc	ra,0xffffd
    80004024:	5ec080e7          	jalr	1516(ra) # 8000160c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004028:	2184a703          	lw	a4,536(s1)
    8000402c:	21c4a783          	lw	a5,540(s1)
    80004030:	fef700e3          	beq	a4,a5,80004010 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004034:	09505263          	blez	s5,800040b8 <piperead+0xe8>
    80004038:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000403a:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    8000403c:	2184a783          	lw	a5,536(s1)
    80004040:	21c4a703          	lw	a4,540(s1)
    80004044:	02f70d63          	beq	a4,a5,8000407e <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004048:	0017871b          	addiw	a4,a5,1
    8000404c:	20e4ac23          	sw	a4,536(s1)
    80004050:	1ff7f793          	andi	a5,a5,511
    80004054:	97a6                	add	a5,a5,s1
    80004056:	0187c783          	lbu	a5,24(a5)
    8000405a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000405e:	4685                	li	a3,1
    80004060:	fbf40613          	addi	a2,s0,-65
    80004064:	85ca                	mv	a1,s2
    80004066:	050a3503          	ld	a0,80(s4)
    8000406a:	ffffd097          	auipc	ra,0xffffd
    8000406e:	ba8080e7          	jalr	-1112(ra) # 80000c12 <copyout>
    80004072:	01650663          	beq	a0,s6,8000407e <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004076:	2985                	addiw	s3,s3,1
    80004078:	0905                	addi	s2,s2,1
    8000407a:	fd3a91e3          	bne	s5,s3,8000403c <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000407e:	21c48513          	addi	a0,s1,540
    80004082:	ffffd097          	auipc	ra,0xffffd
    80004086:	716080e7          	jalr	1814(ra) # 80001798 <wakeup>
  release(&pi->lock);
    8000408a:	8526                	mv	a0,s1
    8000408c:	00002097          	auipc	ra,0x2
    80004090:	2e4080e7          	jalr	740(ra) # 80006370 <release>
  return i;
}
    80004094:	854e                	mv	a0,s3
    80004096:	60a6                	ld	ra,72(sp)
    80004098:	6406                	ld	s0,64(sp)
    8000409a:	74e2                	ld	s1,56(sp)
    8000409c:	7942                	ld	s2,48(sp)
    8000409e:	79a2                	ld	s3,40(sp)
    800040a0:	7a02                	ld	s4,32(sp)
    800040a2:	6ae2                	ld	s5,24(sp)
    800040a4:	6b42                	ld	s6,16(sp)
    800040a6:	6161                	addi	sp,sp,80
    800040a8:	8082                	ret
      release(&pi->lock);
    800040aa:	8526                	mv	a0,s1
    800040ac:	00002097          	auipc	ra,0x2
    800040b0:	2c4080e7          	jalr	708(ra) # 80006370 <release>
      return -1;
    800040b4:	59fd                	li	s3,-1
    800040b6:	bff9                	j	80004094 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800040b8:	4981                	li	s3,0
    800040ba:	b7d1                	j	8000407e <piperead+0xae>

00000000800040bc <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800040bc:	df010113          	addi	sp,sp,-528
    800040c0:	20113423          	sd	ra,520(sp)
    800040c4:	20813023          	sd	s0,512(sp)
    800040c8:	ffa6                	sd	s1,504(sp)
    800040ca:	fbca                	sd	s2,496(sp)
    800040cc:	f7ce                	sd	s3,488(sp)
    800040ce:	f3d2                	sd	s4,480(sp)
    800040d0:	efd6                	sd	s5,472(sp)
    800040d2:	ebda                	sd	s6,464(sp)
    800040d4:	e7de                	sd	s7,456(sp)
    800040d6:	e3e2                	sd	s8,448(sp)
    800040d8:	ff66                	sd	s9,440(sp)
    800040da:	fb6a                	sd	s10,432(sp)
    800040dc:	f76e                	sd	s11,424(sp)
    800040de:	0c00                	addi	s0,sp,528
    800040e0:	84aa                	mv	s1,a0
    800040e2:	dea43c23          	sd	a0,-520(s0)
    800040e6:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800040ea:	ffffd097          	auipc	ra,0xffffd
    800040ee:	e66080e7          	jalr	-410(ra) # 80000f50 <myproc>
    800040f2:	892a                	mv	s2,a0

  begin_op();
    800040f4:	fffff097          	auipc	ra,0xfffff
    800040f8:	49c080e7          	jalr	1180(ra) # 80003590 <begin_op>

  if((ip = namei(path)) == 0){
    800040fc:	8526                	mv	a0,s1
    800040fe:	fffff097          	auipc	ra,0xfffff
    80004102:	276080e7          	jalr	630(ra) # 80003374 <namei>
    80004106:	c92d                	beqz	a0,80004178 <exec+0xbc>
    80004108:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000410a:	fffff097          	auipc	ra,0xfffff
    8000410e:	ab4080e7          	jalr	-1356(ra) # 80002bbe <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004112:	04000713          	li	a4,64
    80004116:	4681                	li	a3,0
    80004118:	e5040613          	addi	a2,s0,-432
    8000411c:	4581                	li	a1,0
    8000411e:	8526                	mv	a0,s1
    80004120:	fffff097          	auipc	ra,0xfffff
    80004124:	d52080e7          	jalr	-686(ra) # 80002e72 <readi>
    80004128:	04000793          	li	a5,64
    8000412c:	00f51a63          	bne	a0,a5,80004140 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004130:	e5042703          	lw	a4,-432(s0)
    80004134:	464c47b7          	lui	a5,0x464c4
    80004138:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000413c:	04f70463          	beq	a4,a5,80004184 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004140:	8526                	mv	a0,s1
    80004142:	fffff097          	auipc	ra,0xfffff
    80004146:	cde080e7          	jalr	-802(ra) # 80002e20 <iunlockput>
    end_op();
    8000414a:	fffff097          	auipc	ra,0xfffff
    8000414e:	4c6080e7          	jalr	1222(ra) # 80003610 <end_op>
  }
  return -1;
    80004152:	557d                	li	a0,-1
}
    80004154:	20813083          	ld	ra,520(sp)
    80004158:	20013403          	ld	s0,512(sp)
    8000415c:	74fe                	ld	s1,504(sp)
    8000415e:	795e                	ld	s2,496(sp)
    80004160:	79be                	ld	s3,488(sp)
    80004162:	7a1e                	ld	s4,480(sp)
    80004164:	6afe                	ld	s5,472(sp)
    80004166:	6b5e                	ld	s6,464(sp)
    80004168:	6bbe                	ld	s7,456(sp)
    8000416a:	6c1e                	ld	s8,448(sp)
    8000416c:	7cfa                	ld	s9,440(sp)
    8000416e:	7d5a                	ld	s10,432(sp)
    80004170:	7dba                	ld	s11,424(sp)
    80004172:	21010113          	addi	sp,sp,528
    80004176:	8082                	ret
    end_op();
    80004178:	fffff097          	auipc	ra,0xfffff
    8000417c:	498080e7          	jalr	1176(ra) # 80003610 <end_op>
    return -1;
    80004180:	557d                	li	a0,-1
    80004182:	bfc9                	j	80004154 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004184:	854a                	mv	a0,s2
    80004186:	ffffd097          	auipc	ra,0xffffd
    8000418a:	e8e080e7          	jalr	-370(ra) # 80001014 <proc_pagetable>
    8000418e:	8baa                	mv	s7,a0
    80004190:	d945                	beqz	a0,80004140 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004192:	e7042983          	lw	s3,-400(s0)
    80004196:	e8845783          	lhu	a5,-376(s0)
    8000419a:	c7ad                	beqz	a5,80004204 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000419c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000419e:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    800041a0:	6c85                	lui	s9,0x1
    800041a2:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800041a6:	def43823          	sd	a5,-528(s0)
    800041aa:	a42d                	j	800043d4 <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800041ac:	00004517          	auipc	a0,0x4
    800041b0:	49c50513          	addi	a0,a0,1180 # 80008648 <syscalls+0x280>
    800041b4:	00002097          	auipc	ra,0x2
    800041b8:	bbe080e7          	jalr	-1090(ra) # 80005d72 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800041bc:	8756                	mv	a4,s5
    800041be:	012d86bb          	addw	a3,s11,s2
    800041c2:	4581                	li	a1,0
    800041c4:	8526                	mv	a0,s1
    800041c6:	fffff097          	auipc	ra,0xfffff
    800041ca:	cac080e7          	jalr	-852(ra) # 80002e72 <readi>
    800041ce:	2501                	sext.w	a0,a0
    800041d0:	1aaa9963          	bne	s5,a0,80004382 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    800041d4:	6785                	lui	a5,0x1
    800041d6:	0127893b          	addw	s2,a5,s2
    800041da:	77fd                	lui	a5,0xfffff
    800041dc:	01478a3b          	addw	s4,a5,s4
    800041e0:	1f897163          	bgeu	s2,s8,800043c2 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    800041e4:	02091593          	slli	a1,s2,0x20
    800041e8:	9181                	srli	a1,a1,0x20
    800041ea:	95ea                	add	a1,a1,s10
    800041ec:	855e                	mv	a0,s7
    800041ee:	ffffc097          	auipc	ra,0xffffc
    800041f2:	360080e7          	jalr	864(ra) # 8000054e <walkaddr>
    800041f6:	862a                	mv	a2,a0
    if(pa == 0)
    800041f8:	d955                	beqz	a0,800041ac <exec+0xf0>
      n = PGSIZE;
    800041fa:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800041fc:	fd9a70e3          	bgeu	s4,s9,800041bc <exec+0x100>
      n = sz - i;
    80004200:	8ad2                	mv	s5,s4
    80004202:	bf6d                	j	800041bc <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004204:	4901                	li	s2,0
  iunlockput(ip);
    80004206:	8526                	mv	a0,s1
    80004208:	fffff097          	auipc	ra,0xfffff
    8000420c:	c18080e7          	jalr	-1000(ra) # 80002e20 <iunlockput>
  end_op();
    80004210:	fffff097          	auipc	ra,0xfffff
    80004214:	400080e7          	jalr	1024(ra) # 80003610 <end_op>
  p = myproc();
    80004218:	ffffd097          	auipc	ra,0xffffd
    8000421c:	d38080e7          	jalr	-712(ra) # 80000f50 <myproc>
    80004220:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004222:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004226:	6785                	lui	a5,0x1
    80004228:	17fd                	addi	a5,a5,-1
    8000422a:	993e                	add	s2,s2,a5
    8000422c:	757d                	lui	a0,0xfffff
    8000422e:	00a977b3          	and	a5,s2,a0
    80004232:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004236:	6609                	lui	a2,0x2
    80004238:	963e                	add	a2,a2,a5
    8000423a:	85be                	mv	a1,a5
    8000423c:	855e                	mv	a0,s7
    8000423e:	ffffc097          	auipc	ra,0xffffc
    80004242:	788080e7          	jalr	1928(ra) # 800009c6 <uvmalloc>
    80004246:	8b2a                	mv	s6,a0
  ip = 0;
    80004248:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000424a:	12050c63          	beqz	a0,80004382 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000424e:	75f9                	lui	a1,0xffffe
    80004250:	95aa                	add	a1,a1,a0
    80004252:	855e                	mv	a0,s7
    80004254:	ffffd097          	auipc	ra,0xffffd
    80004258:	98c080e7          	jalr	-1652(ra) # 80000be0 <uvmclear>
  stackbase = sp - PGSIZE;
    8000425c:	7c7d                	lui	s8,0xfffff
    8000425e:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004260:	e0043783          	ld	a5,-512(s0)
    80004264:	6388                	ld	a0,0(a5)
    80004266:	c535                	beqz	a0,800042d2 <exec+0x216>
    80004268:	e9040993          	addi	s3,s0,-368
    8000426c:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004270:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004272:	ffffc097          	auipc	ra,0xffffc
    80004276:	0d2080e7          	jalr	210(ra) # 80000344 <strlen>
    8000427a:	2505                	addiw	a0,a0,1
    8000427c:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004280:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004284:	13896363          	bltu	s2,s8,800043aa <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004288:	e0043d83          	ld	s11,-512(s0)
    8000428c:	000dba03          	ld	s4,0(s11)
    80004290:	8552                	mv	a0,s4
    80004292:	ffffc097          	auipc	ra,0xffffc
    80004296:	0b2080e7          	jalr	178(ra) # 80000344 <strlen>
    8000429a:	0015069b          	addiw	a3,a0,1
    8000429e:	8652                	mv	a2,s4
    800042a0:	85ca                	mv	a1,s2
    800042a2:	855e                	mv	a0,s7
    800042a4:	ffffd097          	auipc	ra,0xffffd
    800042a8:	96e080e7          	jalr	-1682(ra) # 80000c12 <copyout>
    800042ac:	10054363          	bltz	a0,800043b2 <exec+0x2f6>
    ustack[argc] = sp;
    800042b0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800042b4:	0485                	addi	s1,s1,1
    800042b6:	008d8793          	addi	a5,s11,8
    800042ba:	e0f43023          	sd	a5,-512(s0)
    800042be:	008db503          	ld	a0,8(s11)
    800042c2:	c911                	beqz	a0,800042d6 <exec+0x21a>
    if(argc >= MAXARG)
    800042c4:	09a1                	addi	s3,s3,8
    800042c6:	fb3c96e3          	bne	s9,s3,80004272 <exec+0x1b6>
  sz = sz1;
    800042ca:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800042ce:	4481                	li	s1,0
    800042d0:	a84d                	j	80004382 <exec+0x2c6>
  sp = sz;
    800042d2:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800042d4:	4481                	li	s1,0
  ustack[argc] = 0;
    800042d6:	00349793          	slli	a5,s1,0x3
    800042da:	f9040713          	addi	a4,s0,-112
    800042de:	97ba                	add	a5,a5,a4
    800042e0:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800042e4:	00148693          	addi	a3,s1,1
    800042e8:	068e                	slli	a3,a3,0x3
    800042ea:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800042ee:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800042f2:	01897663          	bgeu	s2,s8,800042fe <exec+0x242>
  sz = sz1;
    800042f6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800042fa:	4481                	li	s1,0
    800042fc:	a059                	j	80004382 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800042fe:	e9040613          	addi	a2,s0,-368
    80004302:	85ca                	mv	a1,s2
    80004304:	855e                	mv	a0,s7
    80004306:	ffffd097          	auipc	ra,0xffffd
    8000430a:	90c080e7          	jalr	-1780(ra) # 80000c12 <copyout>
    8000430e:	0a054663          	bltz	a0,800043ba <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004312:	058ab783          	ld	a5,88(s5)
    80004316:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000431a:	df843783          	ld	a5,-520(s0)
    8000431e:	0007c703          	lbu	a4,0(a5)
    80004322:	cf11                	beqz	a4,8000433e <exec+0x282>
    80004324:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004326:	02f00693          	li	a3,47
    8000432a:	a039                	j	80004338 <exec+0x27c>
      last = s+1;
    8000432c:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004330:	0785                	addi	a5,a5,1
    80004332:	fff7c703          	lbu	a4,-1(a5)
    80004336:	c701                	beqz	a4,8000433e <exec+0x282>
    if(*s == '/')
    80004338:	fed71ce3          	bne	a4,a3,80004330 <exec+0x274>
    8000433c:	bfc5                	j	8000432c <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    8000433e:	4641                	li	a2,16
    80004340:	df843583          	ld	a1,-520(s0)
    80004344:	158a8513          	addi	a0,s5,344
    80004348:	ffffc097          	auipc	ra,0xffffc
    8000434c:	fca080e7          	jalr	-54(ra) # 80000312 <safestrcpy>
  oldpagetable = p->pagetable;
    80004350:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004354:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004358:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000435c:	058ab783          	ld	a5,88(s5)
    80004360:	e6843703          	ld	a4,-408(s0)
    80004364:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004366:	058ab783          	ld	a5,88(s5)
    8000436a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000436e:	85ea                	mv	a1,s10
    80004370:	ffffd097          	auipc	ra,0xffffd
    80004374:	d40080e7          	jalr	-704(ra) # 800010b0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004378:	0004851b          	sext.w	a0,s1
    8000437c:	bbe1                	j	80004154 <exec+0x98>
    8000437e:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004382:	e0843583          	ld	a1,-504(s0)
    80004386:	855e                	mv	a0,s7
    80004388:	ffffd097          	auipc	ra,0xffffd
    8000438c:	d28080e7          	jalr	-728(ra) # 800010b0 <proc_freepagetable>
  if(ip){
    80004390:	da0498e3          	bnez	s1,80004140 <exec+0x84>
  return -1;
    80004394:	557d                	li	a0,-1
    80004396:	bb7d                	j	80004154 <exec+0x98>
    80004398:	e1243423          	sd	s2,-504(s0)
    8000439c:	b7dd                	j	80004382 <exec+0x2c6>
    8000439e:	e1243423          	sd	s2,-504(s0)
    800043a2:	b7c5                	j	80004382 <exec+0x2c6>
    800043a4:	e1243423          	sd	s2,-504(s0)
    800043a8:	bfe9                	j	80004382 <exec+0x2c6>
  sz = sz1;
    800043aa:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800043ae:	4481                	li	s1,0
    800043b0:	bfc9                	j	80004382 <exec+0x2c6>
  sz = sz1;
    800043b2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800043b6:	4481                	li	s1,0
    800043b8:	b7e9                	j	80004382 <exec+0x2c6>
  sz = sz1;
    800043ba:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800043be:	4481                	li	s1,0
    800043c0:	b7c9                	j	80004382 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800043c2:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800043c6:	2b05                	addiw	s6,s6,1
    800043c8:	0389899b          	addiw	s3,s3,56
    800043cc:	e8845783          	lhu	a5,-376(s0)
    800043d0:	e2fb5be3          	bge	s6,a5,80004206 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800043d4:	2981                	sext.w	s3,s3
    800043d6:	03800713          	li	a4,56
    800043da:	86ce                	mv	a3,s3
    800043dc:	e1840613          	addi	a2,s0,-488
    800043e0:	4581                	li	a1,0
    800043e2:	8526                	mv	a0,s1
    800043e4:	fffff097          	auipc	ra,0xfffff
    800043e8:	a8e080e7          	jalr	-1394(ra) # 80002e72 <readi>
    800043ec:	03800793          	li	a5,56
    800043f0:	f8f517e3          	bne	a0,a5,8000437e <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    800043f4:	e1842783          	lw	a5,-488(s0)
    800043f8:	4705                	li	a4,1
    800043fa:	fce796e3          	bne	a5,a4,800043c6 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    800043fe:	e4043603          	ld	a2,-448(s0)
    80004402:	e3843783          	ld	a5,-456(s0)
    80004406:	f8f669e3          	bltu	a2,a5,80004398 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000440a:	e2843783          	ld	a5,-472(s0)
    8000440e:	963e                	add	a2,a2,a5
    80004410:	f8f667e3          	bltu	a2,a5,8000439e <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004414:	85ca                	mv	a1,s2
    80004416:	855e                	mv	a0,s7
    80004418:	ffffc097          	auipc	ra,0xffffc
    8000441c:	5ae080e7          	jalr	1454(ra) # 800009c6 <uvmalloc>
    80004420:	e0a43423          	sd	a0,-504(s0)
    80004424:	d141                	beqz	a0,800043a4 <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    80004426:	e2843d03          	ld	s10,-472(s0)
    8000442a:	df043783          	ld	a5,-528(s0)
    8000442e:	00fd77b3          	and	a5,s10,a5
    80004432:	fba1                	bnez	a5,80004382 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004434:	e2042d83          	lw	s11,-480(s0)
    80004438:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000443c:	f80c03e3          	beqz	s8,800043c2 <exec+0x306>
    80004440:	8a62                	mv	s4,s8
    80004442:	4901                	li	s2,0
    80004444:	b345                	j	800041e4 <exec+0x128>

0000000080004446 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004446:	7179                	addi	sp,sp,-48
    80004448:	f406                	sd	ra,40(sp)
    8000444a:	f022                	sd	s0,32(sp)
    8000444c:	ec26                	sd	s1,24(sp)
    8000444e:	e84a                	sd	s2,16(sp)
    80004450:	1800                	addi	s0,sp,48
    80004452:	892e                	mv	s2,a1
    80004454:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004456:	fdc40593          	addi	a1,s0,-36
    8000445a:	ffffe097          	auipc	ra,0xffffe
    8000445e:	bf2080e7          	jalr	-1038(ra) # 8000204c <argint>
    80004462:	04054063          	bltz	a0,800044a2 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004466:	fdc42703          	lw	a4,-36(s0)
    8000446a:	47bd                	li	a5,15
    8000446c:	02e7ed63          	bltu	a5,a4,800044a6 <argfd+0x60>
    80004470:	ffffd097          	auipc	ra,0xffffd
    80004474:	ae0080e7          	jalr	-1312(ra) # 80000f50 <myproc>
    80004478:	fdc42703          	lw	a4,-36(s0)
    8000447c:	01a70793          	addi	a5,a4,26
    80004480:	078e                	slli	a5,a5,0x3
    80004482:	953e                	add	a0,a0,a5
    80004484:	611c                	ld	a5,0(a0)
    80004486:	c395                	beqz	a5,800044aa <argfd+0x64>
    return -1;
  if(pfd)
    80004488:	00090463          	beqz	s2,80004490 <argfd+0x4a>
    *pfd = fd;
    8000448c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004490:	4501                	li	a0,0
  if(pf)
    80004492:	c091                	beqz	s1,80004496 <argfd+0x50>
    *pf = f;
    80004494:	e09c                	sd	a5,0(s1)
}
    80004496:	70a2                	ld	ra,40(sp)
    80004498:	7402                	ld	s0,32(sp)
    8000449a:	64e2                	ld	s1,24(sp)
    8000449c:	6942                	ld	s2,16(sp)
    8000449e:	6145                	addi	sp,sp,48
    800044a0:	8082                	ret
    return -1;
    800044a2:	557d                	li	a0,-1
    800044a4:	bfcd                	j	80004496 <argfd+0x50>
    return -1;
    800044a6:	557d                	li	a0,-1
    800044a8:	b7fd                	j	80004496 <argfd+0x50>
    800044aa:	557d                	li	a0,-1
    800044ac:	b7ed                	j	80004496 <argfd+0x50>

00000000800044ae <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800044ae:	1101                	addi	sp,sp,-32
    800044b0:	ec06                	sd	ra,24(sp)
    800044b2:	e822                	sd	s0,16(sp)
    800044b4:	e426                	sd	s1,8(sp)
    800044b6:	1000                	addi	s0,sp,32
    800044b8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800044ba:	ffffd097          	auipc	ra,0xffffd
    800044be:	a96080e7          	jalr	-1386(ra) # 80000f50 <myproc>
    800044c2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800044c4:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7fed8e90>
    800044c8:	4501                	li	a0,0
    800044ca:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800044cc:	6398                	ld	a4,0(a5)
    800044ce:	cb19                	beqz	a4,800044e4 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800044d0:	2505                	addiw	a0,a0,1
    800044d2:	07a1                	addi	a5,a5,8
    800044d4:	fed51ce3          	bne	a0,a3,800044cc <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800044d8:	557d                	li	a0,-1
}
    800044da:	60e2                	ld	ra,24(sp)
    800044dc:	6442                	ld	s0,16(sp)
    800044de:	64a2                	ld	s1,8(sp)
    800044e0:	6105                	addi	sp,sp,32
    800044e2:	8082                	ret
      p->ofile[fd] = f;
    800044e4:	01a50793          	addi	a5,a0,26
    800044e8:	078e                	slli	a5,a5,0x3
    800044ea:	963e                	add	a2,a2,a5
    800044ec:	e204                	sd	s1,0(a2)
      return fd;
    800044ee:	b7f5                	j	800044da <fdalloc+0x2c>

00000000800044f0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800044f0:	715d                	addi	sp,sp,-80
    800044f2:	e486                	sd	ra,72(sp)
    800044f4:	e0a2                	sd	s0,64(sp)
    800044f6:	fc26                	sd	s1,56(sp)
    800044f8:	f84a                	sd	s2,48(sp)
    800044fa:	f44e                	sd	s3,40(sp)
    800044fc:	f052                	sd	s4,32(sp)
    800044fe:	ec56                	sd	s5,24(sp)
    80004500:	0880                	addi	s0,sp,80
    80004502:	89ae                	mv	s3,a1
    80004504:	8ab2                	mv	s5,a2
    80004506:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004508:	fb040593          	addi	a1,s0,-80
    8000450c:	fffff097          	auipc	ra,0xfffff
    80004510:	e86080e7          	jalr	-378(ra) # 80003392 <nameiparent>
    80004514:	892a                	mv	s2,a0
    80004516:	12050f63          	beqz	a0,80004654 <create+0x164>
    return 0;

  ilock(dp);
    8000451a:	ffffe097          	auipc	ra,0xffffe
    8000451e:	6a4080e7          	jalr	1700(ra) # 80002bbe <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004522:	4601                	li	a2,0
    80004524:	fb040593          	addi	a1,s0,-80
    80004528:	854a                	mv	a0,s2
    8000452a:	fffff097          	auipc	ra,0xfffff
    8000452e:	b78080e7          	jalr	-1160(ra) # 800030a2 <dirlookup>
    80004532:	84aa                	mv	s1,a0
    80004534:	c921                	beqz	a0,80004584 <create+0x94>
    iunlockput(dp);
    80004536:	854a                	mv	a0,s2
    80004538:	fffff097          	auipc	ra,0xfffff
    8000453c:	8e8080e7          	jalr	-1816(ra) # 80002e20 <iunlockput>
    ilock(ip);
    80004540:	8526                	mv	a0,s1
    80004542:	ffffe097          	auipc	ra,0xffffe
    80004546:	67c080e7          	jalr	1660(ra) # 80002bbe <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000454a:	2981                	sext.w	s3,s3
    8000454c:	4789                	li	a5,2
    8000454e:	02f99463          	bne	s3,a5,80004576 <create+0x86>
    80004552:	0444d783          	lhu	a5,68(s1)
    80004556:	37f9                	addiw	a5,a5,-2
    80004558:	17c2                	slli	a5,a5,0x30
    8000455a:	93c1                	srli	a5,a5,0x30
    8000455c:	4705                	li	a4,1
    8000455e:	00f76c63          	bltu	a4,a5,80004576 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80004562:	8526                	mv	a0,s1
    80004564:	60a6                	ld	ra,72(sp)
    80004566:	6406                	ld	s0,64(sp)
    80004568:	74e2                	ld	s1,56(sp)
    8000456a:	7942                	ld	s2,48(sp)
    8000456c:	79a2                	ld	s3,40(sp)
    8000456e:	7a02                	ld	s4,32(sp)
    80004570:	6ae2                	ld	s5,24(sp)
    80004572:	6161                	addi	sp,sp,80
    80004574:	8082                	ret
    iunlockput(ip);
    80004576:	8526                	mv	a0,s1
    80004578:	fffff097          	auipc	ra,0xfffff
    8000457c:	8a8080e7          	jalr	-1880(ra) # 80002e20 <iunlockput>
    return 0;
    80004580:	4481                	li	s1,0
    80004582:	b7c5                	j	80004562 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80004584:	85ce                	mv	a1,s3
    80004586:	00092503          	lw	a0,0(s2)
    8000458a:	ffffe097          	auipc	ra,0xffffe
    8000458e:	49c080e7          	jalr	1180(ra) # 80002a26 <ialloc>
    80004592:	84aa                	mv	s1,a0
    80004594:	c529                	beqz	a0,800045de <create+0xee>
  ilock(ip);
    80004596:	ffffe097          	auipc	ra,0xffffe
    8000459a:	628080e7          	jalr	1576(ra) # 80002bbe <ilock>
  ip->major = major;
    8000459e:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800045a2:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800045a6:	4785                	li	a5,1
    800045a8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800045ac:	8526                	mv	a0,s1
    800045ae:	ffffe097          	auipc	ra,0xffffe
    800045b2:	546080e7          	jalr	1350(ra) # 80002af4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800045b6:	2981                	sext.w	s3,s3
    800045b8:	4785                	li	a5,1
    800045ba:	02f98a63          	beq	s3,a5,800045ee <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800045be:	40d0                	lw	a2,4(s1)
    800045c0:	fb040593          	addi	a1,s0,-80
    800045c4:	854a                	mv	a0,s2
    800045c6:	fffff097          	auipc	ra,0xfffff
    800045ca:	cec080e7          	jalr	-788(ra) # 800032b2 <dirlink>
    800045ce:	06054b63          	bltz	a0,80004644 <create+0x154>
  iunlockput(dp);
    800045d2:	854a                	mv	a0,s2
    800045d4:	fffff097          	auipc	ra,0xfffff
    800045d8:	84c080e7          	jalr	-1972(ra) # 80002e20 <iunlockput>
  return ip;
    800045dc:	b759                	j	80004562 <create+0x72>
    panic("create: ialloc");
    800045de:	00004517          	auipc	a0,0x4
    800045e2:	08a50513          	addi	a0,a0,138 # 80008668 <syscalls+0x2a0>
    800045e6:	00001097          	auipc	ra,0x1
    800045ea:	78c080e7          	jalr	1932(ra) # 80005d72 <panic>
    dp->nlink++;  // for ".."
    800045ee:	04a95783          	lhu	a5,74(s2)
    800045f2:	2785                	addiw	a5,a5,1
    800045f4:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800045f8:	854a                	mv	a0,s2
    800045fa:	ffffe097          	auipc	ra,0xffffe
    800045fe:	4fa080e7          	jalr	1274(ra) # 80002af4 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004602:	40d0                	lw	a2,4(s1)
    80004604:	00004597          	auipc	a1,0x4
    80004608:	07458593          	addi	a1,a1,116 # 80008678 <syscalls+0x2b0>
    8000460c:	8526                	mv	a0,s1
    8000460e:	fffff097          	auipc	ra,0xfffff
    80004612:	ca4080e7          	jalr	-860(ra) # 800032b2 <dirlink>
    80004616:	00054f63          	bltz	a0,80004634 <create+0x144>
    8000461a:	00492603          	lw	a2,4(s2)
    8000461e:	00004597          	auipc	a1,0x4
    80004622:	06258593          	addi	a1,a1,98 # 80008680 <syscalls+0x2b8>
    80004626:	8526                	mv	a0,s1
    80004628:	fffff097          	auipc	ra,0xfffff
    8000462c:	c8a080e7          	jalr	-886(ra) # 800032b2 <dirlink>
    80004630:	f80557e3          	bgez	a0,800045be <create+0xce>
      panic("create dots");
    80004634:	00004517          	auipc	a0,0x4
    80004638:	05450513          	addi	a0,a0,84 # 80008688 <syscalls+0x2c0>
    8000463c:	00001097          	auipc	ra,0x1
    80004640:	736080e7          	jalr	1846(ra) # 80005d72 <panic>
    panic("create: dirlink");
    80004644:	00004517          	auipc	a0,0x4
    80004648:	05450513          	addi	a0,a0,84 # 80008698 <syscalls+0x2d0>
    8000464c:	00001097          	auipc	ra,0x1
    80004650:	726080e7          	jalr	1830(ra) # 80005d72 <panic>
    return 0;
    80004654:	84aa                	mv	s1,a0
    80004656:	b731                	j	80004562 <create+0x72>

0000000080004658 <sys_dup>:
{
    80004658:	7179                	addi	sp,sp,-48
    8000465a:	f406                	sd	ra,40(sp)
    8000465c:	f022                	sd	s0,32(sp)
    8000465e:	ec26                	sd	s1,24(sp)
    80004660:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004662:	fd840613          	addi	a2,s0,-40
    80004666:	4581                	li	a1,0
    80004668:	4501                	li	a0,0
    8000466a:	00000097          	auipc	ra,0x0
    8000466e:	ddc080e7          	jalr	-548(ra) # 80004446 <argfd>
    return -1;
    80004672:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004674:	02054363          	bltz	a0,8000469a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80004678:	fd843503          	ld	a0,-40(s0)
    8000467c:	00000097          	auipc	ra,0x0
    80004680:	e32080e7          	jalr	-462(ra) # 800044ae <fdalloc>
    80004684:	84aa                	mv	s1,a0
    return -1;
    80004686:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004688:	00054963          	bltz	a0,8000469a <sys_dup+0x42>
  filedup(f);
    8000468c:	fd843503          	ld	a0,-40(s0)
    80004690:	fffff097          	auipc	ra,0xfffff
    80004694:	37a080e7          	jalr	890(ra) # 80003a0a <filedup>
  return fd;
    80004698:	87a6                	mv	a5,s1
}
    8000469a:	853e                	mv	a0,a5
    8000469c:	70a2                	ld	ra,40(sp)
    8000469e:	7402                	ld	s0,32(sp)
    800046a0:	64e2                	ld	s1,24(sp)
    800046a2:	6145                	addi	sp,sp,48
    800046a4:	8082                	ret

00000000800046a6 <sys_read>:
{
    800046a6:	7179                	addi	sp,sp,-48
    800046a8:	f406                	sd	ra,40(sp)
    800046aa:	f022                	sd	s0,32(sp)
    800046ac:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800046ae:	fe840613          	addi	a2,s0,-24
    800046b2:	4581                	li	a1,0
    800046b4:	4501                	li	a0,0
    800046b6:	00000097          	auipc	ra,0x0
    800046ba:	d90080e7          	jalr	-624(ra) # 80004446 <argfd>
    return -1;
    800046be:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800046c0:	04054163          	bltz	a0,80004702 <sys_read+0x5c>
    800046c4:	fe440593          	addi	a1,s0,-28
    800046c8:	4509                	li	a0,2
    800046ca:	ffffe097          	auipc	ra,0xffffe
    800046ce:	982080e7          	jalr	-1662(ra) # 8000204c <argint>
    return -1;
    800046d2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800046d4:	02054763          	bltz	a0,80004702 <sys_read+0x5c>
    800046d8:	fd840593          	addi	a1,s0,-40
    800046dc:	4505                	li	a0,1
    800046de:	ffffe097          	auipc	ra,0xffffe
    800046e2:	990080e7          	jalr	-1648(ra) # 8000206e <argaddr>
    return -1;
    800046e6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800046e8:	00054d63          	bltz	a0,80004702 <sys_read+0x5c>
  return fileread(f, p, n);
    800046ec:	fe442603          	lw	a2,-28(s0)
    800046f0:	fd843583          	ld	a1,-40(s0)
    800046f4:	fe843503          	ld	a0,-24(s0)
    800046f8:	fffff097          	auipc	ra,0xfffff
    800046fc:	49e080e7          	jalr	1182(ra) # 80003b96 <fileread>
    80004700:	87aa                	mv	a5,a0
}
    80004702:	853e                	mv	a0,a5
    80004704:	70a2                	ld	ra,40(sp)
    80004706:	7402                	ld	s0,32(sp)
    80004708:	6145                	addi	sp,sp,48
    8000470a:	8082                	ret

000000008000470c <sys_write>:
{
    8000470c:	7179                	addi	sp,sp,-48
    8000470e:	f406                	sd	ra,40(sp)
    80004710:	f022                	sd	s0,32(sp)
    80004712:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004714:	fe840613          	addi	a2,s0,-24
    80004718:	4581                	li	a1,0
    8000471a:	4501                	li	a0,0
    8000471c:	00000097          	auipc	ra,0x0
    80004720:	d2a080e7          	jalr	-726(ra) # 80004446 <argfd>
    return -1;
    80004724:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004726:	04054163          	bltz	a0,80004768 <sys_write+0x5c>
    8000472a:	fe440593          	addi	a1,s0,-28
    8000472e:	4509                	li	a0,2
    80004730:	ffffe097          	auipc	ra,0xffffe
    80004734:	91c080e7          	jalr	-1764(ra) # 8000204c <argint>
    return -1;
    80004738:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000473a:	02054763          	bltz	a0,80004768 <sys_write+0x5c>
    8000473e:	fd840593          	addi	a1,s0,-40
    80004742:	4505                	li	a0,1
    80004744:	ffffe097          	auipc	ra,0xffffe
    80004748:	92a080e7          	jalr	-1750(ra) # 8000206e <argaddr>
    return -1;
    8000474c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000474e:	00054d63          	bltz	a0,80004768 <sys_write+0x5c>
  return filewrite(f, p, n);
    80004752:	fe442603          	lw	a2,-28(s0)
    80004756:	fd843583          	ld	a1,-40(s0)
    8000475a:	fe843503          	ld	a0,-24(s0)
    8000475e:	fffff097          	auipc	ra,0xfffff
    80004762:	4fa080e7          	jalr	1274(ra) # 80003c58 <filewrite>
    80004766:	87aa                	mv	a5,a0
}
    80004768:	853e                	mv	a0,a5
    8000476a:	70a2                	ld	ra,40(sp)
    8000476c:	7402                	ld	s0,32(sp)
    8000476e:	6145                	addi	sp,sp,48
    80004770:	8082                	ret

0000000080004772 <sys_close>:
{
    80004772:	1101                	addi	sp,sp,-32
    80004774:	ec06                	sd	ra,24(sp)
    80004776:	e822                	sd	s0,16(sp)
    80004778:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000477a:	fe040613          	addi	a2,s0,-32
    8000477e:	fec40593          	addi	a1,s0,-20
    80004782:	4501                	li	a0,0
    80004784:	00000097          	auipc	ra,0x0
    80004788:	cc2080e7          	jalr	-830(ra) # 80004446 <argfd>
    return -1;
    8000478c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000478e:	02054463          	bltz	a0,800047b6 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80004792:	ffffc097          	auipc	ra,0xffffc
    80004796:	7be080e7          	jalr	1982(ra) # 80000f50 <myproc>
    8000479a:	fec42783          	lw	a5,-20(s0)
    8000479e:	07e9                	addi	a5,a5,26
    800047a0:	078e                	slli	a5,a5,0x3
    800047a2:	97aa                	add	a5,a5,a0
    800047a4:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800047a8:	fe043503          	ld	a0,-32(s0)
    800047ac:	fffff097          	auipc	ra,0xfffff
    800047b0:	2b0080e7          	jalr	688(ra) # 80003a5c <fileclose>
  return 0;
    800047b4:	4781                	li	a5,0
}
    800047b6:	853e                	mv	a0,a5
    800047b8:	60e2                	ld	ra,24(sp)
    800047ba:	6442                	ld	s0,16(sp)
    800047bc:	6105                	addi	sp,sp,32
    800047be:	8082                	ret

00000000800047c0 <sys_fstat>:
{
    800047c0:	1101                	addi	sp,sp,-32
    800047c2:	ec06                	sd	ra,24(sp)
    800047c4:	e822                	sd	s0,16(sp)
    800047c6:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800047c8:	fe840613          	addi	a2,s0,-24
    800047cc:	4581                	li	a1,0
    800047ce:	4501                	li	a0,0
    800047d0:	00000097          	auipc	ra,0x0
    800047d4:	c76080e7          	jalr	-906(ra) # 80004446 <argfd>
    return -1;
    800047d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800047da:	02054563          	bltz	a0,80004804 <sys_fstat+0x44>
    800047de:	fe040593          	addi	a1,s0,-32
    800047e2:	4505                	li	a0,1
    800047e4:	ffffe097          	auipc	ra,0xffffe
    800047e8:	88a080e7          	jalr	-1910(ra) # 8000206e <argaddr>
    return -1;
    800047ec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800047ee:	00054b63          	bltz	a0,80004804 <sys_fstat+0x44>
  return filestat(f, st);
    800047f2:	fe043583          	ld	a1,-32(s0)
    800047f6:	fe843503          	ld	a0,-24(s0)
    800047fa:	fffff097          	auipc	ra,0xfffff
    800047fe:	32a080e7          	jalr	810(ra) # 80003b24 <filestat>
    80004802:	87aa                	mv	a5,a0
}
    80004804:	853e                	mv	a0,a5
    80004806:	60e2                	ld	ra,24(sp)
    80004808:	6442                	ld	s0,16(sp)
    8000480a:	6105                	addi	sp,sp,32
    8000480c:	8082                	ret

000000008000480e <sys_link>:
{
    8000480e:	7169                	addi	sp,sp,-304
    80004810:	f606                	sd	ra,296(sp)
    80004812:	f222                	sd	s0,288(sp)
    80004814:	ee26                	sd	s1,280(sp)
    80004816:	ea4a                	sd	s2,272(sp)
    80004818:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000481a:	08000613          	li	a2,128
    8000481e:	ed040593          	addi	a1,s0,-304
    80004822:	4501                	li	a0,0
    80004824:	ffffe097          	auipc	ra,0xffffe
    80004828:	86c080e7          	jalr	-1940(ra) # 80002090 <argstr>
    return -1;
    8000482c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000482e:	10054e63          	bltz	a0,8000494a <sys_link+0x13c>
    80004832:	08000613          	li	a2,128
    80004836:	f5040593          	addi	a1,s0,-176
    8000483a:	4505                	li	a0,1
    8000483c:	ffffe097          	auipc	ra,0xffffe
    80004840:	854080e7          	jalr	-1964(ra) # 80002090 <argstr>
    return -1;
    80004844:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004846:	10054263          	bltz	a0,8000494a <sys_link+0x13c>
  begin_op();
    8000484a:	fffff097          	auipc	ra,0xfffff
    8000484e:	d46080e7          	jalr	-698(ra) # 80003590 <begin_op>
  if((ip = namei(old)) == 0){
    80004852:	ed040513          	addi	a0,s0,-304
    80004856:	fffff097          	auipc	ra,0xfffff
    8000485a:	b1e080e7          	jalr	-1250(ra) # 80003374 <namei>
    8000485e:	84aa                	mv	s1,a0
    80004860:	c551                	beqz	a0,800048ec <sys_link+0xde>
  ilock(ip);
    80004862:	ffffe097          	auipc	ra,0xffffe
    80004866:	35c080e7          	jalr	860(ra) # 80002bbe <ilock>
  if(ip->type == T_DIR){
    8000486a:	04449703          	lh	a4,68(s1)
    8000486e:	4785                	li	a5,1
    80004870:	08f70463          	beq	a4,a5,800048f8 <sys_link+0xea>
  ip->nlink++;
    80004874:	04a4d783          	lhu	a5,74(s1)
    80004878:	2785                	addiw	a5,a5,1
    8000487a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000487e:	8526                	mv	a0,s1
    80004880:	ffffe097          	auipc	ra,0xffffe
    80004884:	274080e7          	jalr	628(ra) # 80002af4 <iupdate>
  iunlock(ip);
    80004888:	8526                	mv	a0,s1
    8000488a:	ffffe097          	auipc	ra,0xffffe
    8000488e:	3f6080e7          	jalr	1014(ra) # 80002c80 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004892:	fd040593          	addi	a1,s0,-48
    80004896:	f5040513          	addi	a0,s0,-176
    8000489a:	fffff097          	auipc	ra,0xfffff
    8000489e:	af8080e7          	jalr	-1288(ra) # 80003392 <nameiparent>
    800048a2:	892a                	mv	s2,a0
    800048a4:	c935                	beqz	a0,80004918 <sys_link+0x10a>
  ilock(dp);
    800048a6:	ffffe097          	auipc	ra,0xffffe
    800048aa:	318080e7          	jalr	792(ra) # 80002bbe <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800048ae:	00092703          	lw	a4,0(s2)
    800048b2:	409c                	lw	a5,0(s1)
    800048b4:	04f71d63          	bne	a4,a5,8000490e <sys_link+0x100>
    800048b8:	40d0                	lw	a2,4(s1)
    800048ba:	fd040593          	addi	a1,s0,-48
    800048be:	854a                	mv	a0,s2
    800048c0:	fffff097          	auipc	ra,0xfffff
    800048c4:	9f2080e7          	jalr	-1550(ra) # 800032b2 <dirlink>
    800048c8:	04054363          	bltz	a0,8000490e <sys_link+0x100>
  iunlockput(dp);
    800048cc:	854a                	mv	a0,s2
    800048ce:	ffffe097          	auipc	ra,0xffffe
    800048d2:	552080e7          	jalr	1362(ra) # 80002e20 <iunlockput>
  iput(ip);
    800048d6:	8526                	mv	a0,s1
    800048d8:	ffffe097          	auipc	ra,0xffffe
    800048dc:	4a0080e7          	jalr	1184(ra) # 80002d78 <iput>
  end_op();
    800048e0:	fffff097          	auipc	ra,0xfffff
    800048e4:	d30080e7          	jalr	-720(ra) # 80003610 <end_op>
  return 0;
    800048e8:	4781                	li	a5,0
    800048ea:	a085                	j	8000494a <sys_link+0x13c>
    end_op();
    800048ec:	fffff097          	auipc	ra,0xfffff
    800048f0:	d24080e7          	jalr	-732(ra) # 80003610 <end_op>
    return -1;
    800048f4:	57fd                	li	a5,-1
    800048f6:	a891                	j	8000494a <sys_link+0x13c>
    iunlockput(ip);
    800048f8:	8526                	mv	a0,s1
    800048fa:	ffffe097          	auipc	ra,0xffffe
    800048fe:	526080e7          	jalr	1318(ra) # 80002e20 <iunlockput>
    end_op();
    80004902:	fffff097          	auipc	ra,0xfffff
    80004906:	d0e080e7          	jalr	-754(ra) # 80003610 <end_op>
    return -1;
    8000490a:	57fd                	li	a5,-1
    8000490c:	a83d                	j	8000494a <sys_link+0x13c>
    iunlockput(dp);
    8000490e:	854a                	mv	a0,s2
    80004910:	ffffe097          	auipc	ra,0xffffe
    80004914:	510080e7          	jalr	1296(ra) # 80002e20 <iunlockput>
  ilock(ip);
    80004918:	8526                	mv	a0,s1
    8000491a:	ffffe097          	auipc	ra,0xffffe
    8000491e:	2a4080e7          	jalr	676(ra) # 80002bbe <ilock>
  ip->nlink--;
    80004922:	04a4d783          	lhu	a5,74(s1)
    80004926:	37fd                	addiw	a5,a5,-1
    80004928:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000492c:	8526                	mv	a0,s1
    8000492e:	ffffe097          	auipc	ra,0xffffe
    80004932:	1c6080e7          	jalr	454(ra) # 80002af4 <iupdate>
  iunlockput(ip);
    80004936:	8526                	mv	a0,s1
    80004938:	ffffe097          	auipc	ra,0xffffe
    8000493c:	4e8080e7          	jalr	1256(ra) # 80002e20 <iunlockput>
  end_op();
    80004940:	fffff097          	auipc	ra,0xfffff
    80004944:	cd0080e7          	jalr	-816(ra) # 80003610 <end_op>
  return -1;
    80004948:	57fd                	li	a5,-1
}
    8000494a:	853e                	mv	a0,a5
    8000494c:	70b2                	ld	ra,296(sp)
    8000494e:	7412                	ld	s0,288(sp)
    80004950:	64f2                	ld	s1,280(sp)
    80004952:	6952                	ld	s2,272(sp)
    80004954:	6155                	addi	sp,sp,304
    80004956:	8082                	ret

0000000080004958 <sys_unlink>:
{
    80004958:	7151                	addi	sp,sp,-240
    8000495a:	f586                	sd	ra,232(sp)
    8000495c:	f1a2                	sd	s0,224(sp)
    8000495e:	eda6                	sd	s1,216(sp)
    80004960:	e9ca                	sd	s2,208(sp)
    80004962:	e5ce                	sd	s3,200(sp)
    80004964:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004966:	08000613          	li	a2,128
    8000496a:	f3040593          	addi	a1,s0,-208
    8000496e:	4501                	li	a0,0
    80004970:	ffffd097          	auipc	ra,0xffffd
    80004974:	720080e7          	jalr	1824(ra) # 80002090 <argstr>
    80004978:	18054163          	bltz	a0,80004afa <sys_unlink+0x1a2>
  begin_op();
    8000497c:	fffff097          	auipc	ra,0xfffff
    80004980:	c14080e7          	jalr	-1004(ra) # 80003590 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004984:	fb040593          	addi	a1,s0,-80
    80004988:	f3040513          	addi	a0,s0,-208
    8000498c:	fffff097          	auipc	ra,0xfffff
    80004990:	a06080e7          	jalr	-1530(ra) # 80003392 <nameiparent>
    80004994:	84aa                	mv	s1,a0
    80004996:	c979                	beqz	a0,80004a6c <sys_unlink+0x114>
  ilock(dp);
    80004998:	ffffe097          	auipc	ra,0xffffe
    8000499c:	226080e7          	jalr	550(ra) # 80002bbe <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800049a0:	00004597          	auipc	a1,0x4
    800049a4:	cd858593          	addi	a1,a1,-808 # 80008678 <syscalls+0x2b0>
    800049a8:	fb040513          	addi	a0,s0,-80
    800049ac:	ffffe097          	auipc	ra,0xffffe
    800049b0:	6dc080e7          	jalr	1756(ra) # 80003088 <namecmp>
    800049b4:	14050a63          	beqz	a0,80004b08 <sys_unlink+0x1b0>
    800049b8:	00004597          	auipc	a1,0x4
    800049bc:	cc858593          	addi	a1,a1,-824 # 80008680 <syscalls+0x2b8>
    800049c0:	fb040513          	addi	a0,s0,-80
    800049c4:	ffffe097          	auipc	ra,0xffffe
    800049c8:	6c4080e7          	jalr	1732(ra) # 80003088 <namecmp>
    800049cc:	12050e63          	beqz	a0,80004b08 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800049d0:	f2c40613          	addi	a2,s0,-212
    800049d4:	fb040593          	addi	a1,s0,-80
    800049d8:	8526                	mv	a0,s1
    800049da:	ffffe097          	auipc	ra,0xffffe
    800049de:	6c8080e7          	jalr	1736(ra) # 800030a2 <dirlookup>
    800049e2:	892a                	mv	s2,a0
    800049e4:	12050263          	beqz	a0,80004b08 <sys_unlink+0x1b0>
  ilock(ip);
    800049e8:	ffffe097          	auipc	ra,0xffffe
    800049ec:	1d6080e7          	jalr	470(ra) # 80002bbe <ilock>
  if(ip->nlink < 1)
    800049f0:	04a91783          	lh	a5,74(s2)
    800049f4:	08f05263          	blez	a5,80004a78 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800049f8:	04491703          	lh	a4,68(s2)
    800049fc:	4785                	li	a5,1
    800049fe:	08f70563          	beq	a4,a5,80004a88 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80004a02:	4641                	li	a2,16
    80004a04:	4581                	li	a1,0
    80004a06:	fc040513          	addi	a0,s0,-64
    80004a0a:	ffffb097          	auipc	ra,0xffffb
    80004a0e:	7b6080e7          	jalr	1974(ra) # 800001c0 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004a12:	4741                	li	a4,16
    80004a14:	f2c42683          	lw	a3,-212(s0)
    80004a18:	fc040613          	addi	a2,s0,-64
    80004a1c:	4581                	li	a1,0
    80004a1e:	8526                	mv	a0,s1
    80004a20:	ffffe097          	auipc	ra,0xffffe
    80004a24:	54a080e7          	jalr	1354(ra) # 80002f6a <writei>
    80004a28:	47c1                	li	a5,16
    80004a2a:	0af51563          	bne	a0,a5,80004ad4 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80004a2e:	04491703          	lh	a4,68(s2)
    80004a32:	4785                	li	a5,1
    80004a34:	0af70863          	beq	a4,a5,80004ae4 <sys_unlink+0x18c>
  iunlockput(dp);
    80004a38:	8526                	mv	a0,s1
    80004a3a:	ffffe097          	auipc	ra,0xffffe
    80004a3e:	3e6080e7          	jalr	998(ra) # 80002e20 <iunlockput>
  ip->nlink--;
    80004a42:	04a95783          	lhu	a5,74(s2)
    80004a46:	37fd                	addiw	a5,a5,-1
    80004a48:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004a4c:	854a                	mv	a0,s2
    80004a4e:	ffffe097          	auipc	ra,0xffffe
    80004a52:	0a6080e7          	jalr	166(ra) # 80002af4 <iupdate>
  iunlockput(ip);
    80004a56:	854a                	mv	a0,s2
    80004a58:	ffffe097          	auipc	ra,0xffffe
    80004a5c:	3c8080e7          	jalr	968(ra) # 80002e20 <iunlockput>
  end_op();
    80004a60:	fffff097          	auipc	ra,0xfffff
    80004a64:	bb0080e7          	jalr	-1104(ra) # 80003610 <end_op>
  return 0;
    80004a68:	4501                	li	a0,0
    80004a6a:	a84d                	j	80004b1c <sys_unlink+0x1c4>
    end_op();
    80004a6c:	fffff097          	auipc	ra,0xfffff
    80004a70:	ba4080e7          	jalr	-1116(ra) # 80003610 <end_op>
    return -1;
    80004a74:	557d                	li	a0,-1
    80004a76:	a05d                	j	80004b1c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80004a78:	00004517          	auipc	a0,0x4
    80004a7c:	c3050513          	addi	a0,a0,-976 # 800086a8 <syscalls+0x2e0>
    80004a80:	00001097          	auipc	ra,0x1
    80004a84:	2f2080e7          	jalr	754(ra) # 80005d72 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004a88:	04c92703          	lw	a4,76(s2)
    80004a8c:	02000793          	li	a5,32
    80004a90:	f6e7f9e3          	bgeu	a5,a4,80004a02 <sys_unlink+0xaa>
    80004a94:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004a98:	4741                	li	a4,16
    80004a9a:	86ce                	mv	a3,s3
    80004a9c:	f1840613          	addi	a2,s0,-232
    80004aa0:	4581                	li	a1,0
    80004aa2:	854a                	mv	a0,s2
    80004aa4:	ffffe097          	auipc	ra,0xffffe
    80004aa8:	3ce080e7          	jalr	974(ra) # 80002e72 <readi>
    80004aac:	47c1                	li	a5,16
    80004aae:	00f51b63          	bne	a0,a5,80004ac4 <sys_unlink+0x16c>
    if(de.inum != 0)
    80004ab2:	f1845783          	lhu	a5,-232(s0)
    80004ab6:	e7a1                	bnez	a5,80004afe <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004ab8:	29c1                	addiw	s3,s3,16
    80004aba:	04c92783          	lw	a5,76(s2)
    80004abe:	fcf9ede3          	bltu	s3,a5,80004a98 <sys_unlink+0x140>
    80004ac2:	b781                	j	80004a02 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80004ac4:	00004517          	auipc	a0,0x4
    80004ac8:	bfc50513          	addi	a0,a0,-1028 # 800086c0 <syscalls+0x2f8>
    80004acc:	00001097          	auipc	ra,0x1
    80004ad0:	2a6080e7          	jalr	678(ra) # 80005d72 <panic>
    panic("unlink: writei");
    80004ad4:	00004517          	auipc	a0,0x4
    80004ad8:	c0450513          	addi	a0,a0,-1020 # 800086d8 <syscalls+0x310>
    80004adc:	00001097          	auipc	ra,0x1
    80004ae0:	296080e7          	jalr	662(ra) # 80005d72 <panic>
    dp->nlink--;
    80004ae4:	04a4d783          	lhu	a5,74(s1)
    80004ae8:	37fd                	addiw	a5,a5,-1
    80004aea:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004aee:	8526                	mv	a0,s1
    80004af0:	ffffe097          	auipc	ra,0xffffe
    80004af4:	004080e7          	jalr	4(ra) # 80002af4 <iupdate>
    80004af8:	b781                	j	80004a38 <sys_unlink+0xe0>
    return -1;
    80004afa:	557d                	li	a0,-1
    80004afc:	a005                	j	80004b1c <sys_unlink+0x1c4>
    iunlockput(ip);
    80004afe:	854a                	mv	a0,s2
    80004b00:	ffffe097          	auipc	ra,0xffffe
    80004b04:	320080e7          	jalr	800(ra) # 80002e20 <iunlockput>
  iunlockput(dp);
    80004b08:	8526                	mv	a0,s1
    80004b0a:	ffffe097          	auipc	ra,0xffffe
    80004b0e:	316080e7          	jalr	790(ra) # 80002e20 <iunlockput>
  end_op();
    80004b12:	fffff097          	auipc	ra,0xfffff
    80004b16:	afe080e7          	jalr	-1282(ra) # 80003610 <end_op>
  return -1;
    80004b1a:	557d                	li	a0,-1
}
    80004b1c:	70ae                	ld	ra,232(sp)
    80004b1e:	740e                	ld	s0,224(sp)
    80004b20:	64ee                	ld	s1,216(sp)
    80004b22:	694e                	ld	s2,208(sp)
    80004b24:	69ae                	ld	s3,200(sp)
    80004b26:	616d                	addi	sp,sp,240
    80004b28:	8082                	ret

0000000080004b2a <sys_open>:

uint64
sys_open(void)
{
    80004b2a:	7131                	addi	sp,sp,-192
    80004b2c:	fd06                	sd	ra,184(sp)
    80004b2e:	f922                	sd	s0,176(sp)
    80004b30:	f526                	sd	s1,168(sp)
    80004b32:	f14a                	sd	s2,160(sp)
    80004b34:	ed4e                	sd	s3,152(sp)
    80004b36:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80004b38:	08000613          	li	a2,128
    80004b3c:	f5040593          	addi	a1,s0,-176
    80004b40:	4501                	li	a0,0
    80004b42:	ffffd097          	auipc	ra,0xffffd
    80004b46:	54e080e7          	jalr	1358(ra) # 80002090 <argstr>
    return -1;
    80004b4a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80004b4c:	0c054163          	bltz	a0,80004c0e <sys_open+0xe4>
    80004b50:	f4c40593          	addi	a1,s0,-180
    80004b54:	4505                	li	a0,1
    80004b56:	ffffd097          	auipc	ra,0xffffd
    80004b5a:	4f6080e7          	jalr	1270(ra) # 8000204c <argint>
    80004b5e:	0a054863          	bltz	a0,80004c0e <sys_open+0xe4>

  begin_op();
    80004b62:	fffff097          	auipc	ra,0xfffff
    80004b66:	a2e080e7          	jalr	-1490(ra) # 80003590 <begin_op>

  if(omode & O_CREATE){
    80004b6a:	f4c42783          	lw	a5,-180(s0)
    80004b6e:	2007f793          	andi	a5,a5,512
    80004b72:	cbdd                	beqz	a5,80004c28 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80004b74:	4681                	li	a3,0
    80004b76:	4601                	li	a2,0
    80004b78:	4589                	li	a1,2
    80004b7a:	f5040513          	addi	a0,s0,-176
    80004b7e:	00000097          	auipc	ra,0x0
    80004b82:	972080e7          	jalr	-1678(ra) # 800044f0 <create>
    80004b86:	892a                	mv	s2,a0
    if(ip == 0){
    80004b88:	c959                	beqz	a0,80004c1e <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004b8a:	04491703          	lh	a4,68(s2)
    80004b8e:	478d                	li	a5,3
    80004b90:	00f71763          	bne	a4,a5,80004b9e <sys_open+0x74>
    80004b94:	04695703          	lhu	a4,70(s2)
    80004b98:	47a5                	li	a5,9
    80004b9a:	0ce7ec63          	bltu	a5,a4,80004c72 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004b9e:	fffff097          	auipc	ra,0xfffff
    80004ba2:	e02080e7          	jalr	-510(ra) # 800039a0 <filealloc>
    80004ba6:	89aa                	mv	s3,a0
    80004ba8:	10050263          	beqz	a0,80004cac <sys_open+0x182>
    80004bac:	00000097          	auipc	ra,0x0
    80004bb0:	902080e7          	jalr	-1790(ra) # 800044ae <fdalloc>
    80004bb4:	84aa                	mv	s1,a0
    80004bb6:	0e054663          	bltz	a0,80004ca2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004bba:	04491703          	lh	a4,68(s2)
    80004bbe:	478d                	li	a5,3
    80004bc0:	0cf70463          	beq	a4,a5,80004c88 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004bc4:	4789                	li	a5,2
    80004bc6:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004bca:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004bce:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004bd2:	f4c42783          	lw	a5,-180(s0)
    80004bd6:	0017c713          	xori	a4,a5,1
    80004bda:	8b05                	andi	a4,a4,1
    80004bdc:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004be0:	0037f713          	andi	a4,a5,3
    80004be4:	00e03733          	snez	a4,a4
    80004be8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004bec:	4007f793          	andi	a5,a5,1024
    80004bf0:	c791                	beqz	a5,80004bfc <sys_open+0xd2>
    80004bf2:	04491703          	lh	a4,68(s2)
    80004bf6:	4789                	li	a5,2
    80004bf8:	08f70f63          	beq	a4,a5,80004c96 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80004bfc:	854a                	mv	a0,s2
    80004bfe:	ffffe097          	auipc	ra,0xffffe
    80004c02:	082080e7          	jalr	130(ra) # 80002c80 <iunlock>
  end_op();
    80004c06:	fffff097          	auipc	ra,0xfffff
    80004c0a:	a0a080e7          	jalr	-1526(ra) # 80003610 <end_op>

  return fd;
}
    80004c0e:	8526                	mv	a0,s1
    80004c10:	70ea                	ld	ra,184(sp)
    80004c12:	744a                	ld	s0,176(sp)
    80004c14:	74aa                	ld	s1,168(sp)
    80004c16:	790a                	ld	s2,160(sp)
    80004c18:	69ea                	ld	s3,152(sp)
    80004c1a:	6129                	addi	sp,sp,192
    80004c1c:	8082                	ret
      end_op();
    80004c1e:	fffff097          	auipc	ra,0xfffff
    80004c22:	9f2080e7          	jalr	-1550(ra) # 80003610 <end_op>
      return -1;
    80004c26:	b7e5                	j	80004c0e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80004c28:	f5040513          	addi	a0,s0,-176
    80004c2c:	ffffe097          	auipc	ra,0xffffe
    80004c30:	748080e7          	jalr	1864(ra) # 80003374 <namei>
    80004c34:	892a                	mv	s2,a0
    80004c36:	c905                	beqz	a0,80004c66 <sys_open+0x13c>
    ilock(ip);
    80004c38:	ffffe097          	auipc	ra,0xffffe
    80004c3c:	f86080e7          	jalr	-122(ra) # 80002bbe <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004c40:	04491703          	lh	a4,68(s2)
    80004c44:	4785                	li	a5,1
    80004c46:	f4f712e3          	bne	a4,a5,80004b8a <sys_open+0x60>
    80004c4a:	f4c42783          	lw	a5,-180(s0)
    80004c4e:	dba1                	beqz	a5,80004b9e <sys_open+0x74>
      iunlockput(ip);
    80004c50:	854a                	mv	a0,s2
    80004c52:	ffffe097          	auipc	ra,0xffffe
    80004c56:	1ce080e7          	jalr	462(ra) # 80002e20 <iunlockput>
      end_op();
    80004c5a:	fffff097          	auipc	ra,0xfffff
    80004c5e:	9b6080e7          	jalr	-1610(ra) # 80003610 <end_op>
      return -1;
    80004c62:	54fd                	li	s1,-1
    80004c64:	b76d                	j	80004c0e <sys_open+0xe4>
      end_op();
    80004c66:	fffff097          	auipc	ra,0xfffff
    80004c6a:	9aa080e7          	jalr	-1622(ra) # 80003610 <end_op>
      return -1;
    80004c6e:	54fd                	li	s1,-1
    80004c70:	bf79                	j	80004c0e <sys_open+0xe4>
    iunlockput(ip);
    80004c72:	854a                	mv	a0,s2
    80004c74:	ffffe097          	auipc	ra,0xffffe
    80004c78:	1ac080e7          	jalr	428(ra) # 80002e20 <iunlockput>
    end_op();
    80004c7c:	fffff097          	auipc	ra,0xfffff
    80004c80:	994080e7          	jalr	-1644(ra) # 80003610 <end_op>
    return -1;
    80004c84:	54fd                	li	s1,-1
    80004c86:	b761                	j	80004c0e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80004c88:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004c8c:	04691783          	lh	a5,70(s2)
    80004c90:	02f99223          	sh	a5,36(s3)
    80004c94:	bf2d                	j	80004bce <sys_open+0xa4>
    itrunc(ip);
    80004c96:	854a                	mv	a0,s2
    80004c98:	ffffe097          	auipc	ra,0xffffe
    80004c9c:	034080e7          	jalr	52(ra) # 80002ccc <itrunc>
    80004ca0:	bfb1                	j	80004bfc <sys_open+0xd2>
      fileclose(f);
    80004ca2:	854e                	mv	a0,s3
    80004ca4:	fffff097          	auipc	ra,0xfffff
    80004ca8:	db8080e7          	jalr	-584(ra) # 80003a5c <fileclose>
    iunlockput(ip);
    80004cac:	854a                	mv	a0,s2
    80004cae:	ffffe097          	auipc	ra,0xffffe
    80004cb2:	172080e7          	jalr	370(ra) # 80002e20 <iunlockput>
    end_op();
    80004cb6:	fffff097          	auipc	ra,0xfffff
    80004cba:	95a080e7          	jalr	-1702(ra) # 80003610 <end_op>
    return -1;
    80004cbe:	54fd                	li	s1,-1
    80004cc0:	b7b9                	j	80004c0e <sys_open+0xe4>

0000000080004cc2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004cc2:	7175                	addi	sp,sp,-144
    80004cc4:	e506                	sd	ra,136(sp)
    80004cc6:	e122                	sd	s0,128(sp)
    80004cc8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004cca:	fffff097          	auipc	ra,0xfffff
    80004cce:	8c6080e7          	jalr	-1850(ra) # 80003590 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004cd2:	08000613          	li	a2,128
    80004cd6:	f7040593          	addi	a1,s0,-144
    80004cda:	4501                	li	a0,0
    80004cdc:	ffffd097          	auipc	ra,0xffffd
    80004ce0:	3b4080e7          	jalr	948(ra) # 80002090 <argstr>
    80004ce4:	02054963          	bltz	a0,80004d16 <sys_mkdir+0x54>
    80004ce8:	4681                	li	a3,0
    80004cea:	4601                	li	a2,0
    80004cec:	4585                	li	a1,1
    80004cee:	f7040513          	addi	a0,s0,-144
    80004cf2:	fffff097          	auipc	ra,0xfffff
    80004cf6:	7fe080e7          	jalr	2046(ra) # 800044f0 <create>
    80004cfa:	cd11                	beqz	a0,80004d16 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004cfc:	ffffe097          	auipc	ra,0xffffe
    80004d00:	124080e7          	jalr	292(ra) # 80002e20 <iunlockput>
  end_op();
    80004d04:	fffff097          	auipc	ra,0xfffff
    80004d08:	90c080e7          	jalr	-1780(ra) # 80003610 <end_op>
  return 0;
    80004d0c:	4501                	li	a0,0
}
    80004d0e:	60aa                	ld	ra,136(sp)
    80004d10:	640a                	ld	s0,128(sp)
    80004d12:	6149                	addi	sp,sp,144
    80004d14:	8082                	ret
    end_op();
    80004d16:	fffff097          	auipc	ra,0xfffff
    80004d1a:	8fa080e7          	jalr	-1798(ra) # 80003610 <end_op>
    return -1;
    80004d1e:	557d                	li	a0,-1
    80004d20:	b7fd                	j	80004d0e <sys_mkdir+0x4c>

0000000080004d22 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004d22:	7135                	addi	sp,sp,-160
    80004d24:	ed06                	sd	ra,152(sp)
    80004d26:	e922                	sd	s0,144(sp)
    80004d28:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004d2a:	fffff097          	auipc	ra,0xfffff
    80004d2e:	866080e7          	jalr	-1946(ra) # 80003590 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004d32:	08000613          	li	a2,128
    80004d36:	f7040593          	addi	a1,s0,-144
    80004d3a:	4501                	li	a0,0
    80004d3c:	ffffd097          	auipc	ra,0xffffd
    80004d40:	354080e7          	jalr	852(ra) # 80002090 <argstr>
    80004d44:	04054a63          	bltz	a0,80004d98 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80004d48:	f6c40593          	addi	a1,s0,-148
    80004d4c:	4505                	li	a0,1
    80004d4e:	ffffd097          	auipc	ra,0xffffd
    80004d52:	2fe080e7          	jalr	766(ra) # 8000204c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004d56:	04054163          	bltz	a0,80004d98 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80004d5a:	f6840593          	addi	a1,s0,-152
    80004d5e:	4509                	li	a0,2
    80004d60:	ffffd097          	auipc	ra,0xffffd
    80004d64:	2ec080e7          	jalr	748(ra) # 8000204c <argint>
     argint(1, &major) < 0 ||
    80004d68:	02054863          	bltz	a0,80004d98 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004d6c:	f6841683          	lh	a3,-152(s0)
    80004d70:	f6c41603          	lh	a2,-148(s0)
    80004d74:	458d                	li	a1,3
    80004d76:	f7040513          	addi	a0,s0,-144
    80004d7a:	fffff097          	auipc	ra,0xfffff
    80004d7e:	776080e7          	jalr	1910(ra) # 800044f0 <create>
     argint(2, &minor) < 0 ||
    80004d82:	c919                	beqz	a0,80004d98 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004d84:	ffffe097          	auipc	ra,0xffffe
    80004d88:	09c080e7          	jalr	156(ra) # 80002e20 <iunlockput>
  end_op();
    80004d8c:	fffff097          	auipc	ra,0xfffff
    80004d90:	884080e7          	jalr	-1916(ra) # 80003610 <end_op>
  return 0;
    80004d94:	4501                	li	a0,0
    80004d96:	a031                	j	80004da2 <sys_mknod+0x80>
    end_op();
    80004d98:	fffff097          	auipc	ra,0xfffff
    80004d9c:	878080e7          	jalr	-1928(ra) # 80003610 <end_op>
    return -1;
    80004da0:	557d                	li	a0,-1
}
    80004da2:	60ea                	ld	ra,152(sp)
    80004da4:	644a                	ld	s0,144(sp)
    80004da6:	610d                	addi	sp,sp,160
    80004da8:	8082                	ret

0000000080004daa <sys_chdir>:

uint64
sys_chdir(void)
{
    80004daa:	7135                	addi	sp,sp,-160
    80004dac:	ed06                	sd	ra,152(sp)
    80004dae:	e922                	sd	s0,144(sp)
    80004db0:	e526                	sd	s1,136(sp)
    80004db2:	e14a                	sd	s2,128(sp)
    80004db4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004db6:	ffffc097          	auipc	ra,0xffffc
    80004dba:	19a080e7          	jalr	410(ra) # 80000f50 <myproc>
    80004dbe:	892a                	mv	s2,a0
  
  begin_op();
    80004dc0:	ffffe097          	auipc	ra,0xffffe
    80004dc4:	7d0080e7          	jalr	2000(ra) # 80003590 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004dc8:	08000613          	li	a2,128
    80004dcc:	f6040593          	addi	a1,s0,-160
    80004dd0:	4501                	li	a0,0
    80004dd2:	ffffd097          	auipc	ra,0xffffd
    80004dd6:	2be080e7          	jalr	702(ra) # 80002090 <argstr>
    80004dda:	04054b63          	bltz	a0,80004e30 <sys_chdir+0x86>
    80004dde:	f6040513          	addi	a0,s0,-160
    80004de2:	ffffe097          	auipc	ra,0xffffe
    80004de6:	592080e7          	jalr	1426(ra) # 80003374 <namei>
    80004dea:	84aa                	mv	s1,a0
    80004dec:	c131                	beqz	a0,80004e30 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80004dee:	ffffe097          	auipc	ra,0xffffe
    80004df2:	dd0080e7          	jalr	-560(ra) # 80002bbe <ilock>
  if(ip->type != T_DIR){
    80004df6:	04449703          	lh	a4,68(s1)
    80004dfa:	4785                	li	a5,1
    80004dfc:	04f71063          	bne	a4,a5,80004e3c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004e00:	8526                	mv	a0,s1
    80004e02:	ffffe097          	auipc	ra,0xffffe
    80004e06:	e7e080e7          	jalr	-386(ra) # 80002c80 <iunlock>
  iput(p->cwd);
    80004e0a:	15093503          	ld	a0,336(s2)
    80004e0e:	ffffe097          	auipc	ra,0xffffe
    80004e12:	f6a080e7          	jalr	-150(ra) # 80002d78 <iput>
  end_op();
    80004e16:	ffffe097          	auipc	ra,0xffffe
    80004e1a:	7fa080e7          	jalr	2042(ra) # 80003610 <end_op>
  p->cwd = ip;
    80004e1e:	14993823          	sd	s1,336(s2)
  return 0;
    80004e22:	4501                	li	a0,0
}
    80004e24:	60ea                	ld	ra,152(sp)
    80004e26:	644a                	ld	s0,144(sp)
    80004e28:	64aa                	ld	s1,136(sp)
    80004e2a:	690a                	ld	s2,128(sp)
    80004e2c:	610d                	addi	sp,sp,160
    80004e2e:	8082                	ret
    end_op();
    80004e30:	ffffe097          	auipc	ra,0xffffe
    80004e34:	7e0080e7          	jalr	2016(ra) # 80003610 <end_op>
    return -1;
    80004e38:	557d                	li	a0,-1
    80004e3a:	b7ed                	j	80004e24 <sys_chdir+0x7a>
    iunlockput(ip);
    80004e3c:	8526                	mv	a0,s1
    80004e3e:	ffffe097          	auipc	ra,0xffffe
    80004e42:	fe2080e7          	jalr	-30(ra) # 80002e20 <iunlockput>
    end_op();
    80004e46:	ffffe097          	auipc	ra,0xffffe
    80004e4a:	7ca080e7          	jalr	1994(ra) # 80003610 <end_op>
    return -1;
    80004e4e:	557d                	li	a0,-1
    80004e50:	bfd1                	j	80004e24 <sys_chdir+0x7a>

0000000080004e52 <sys_exec>:

uint64
sys_exec(void)
{
    80004e52:	7145                	addi	sp,sp,-464
    80004e54:	e786                	sd	ra,456(sp)
    80004e56:	e3a2                	sd	s0,448(sp)
    80004e58:	ff26                	sd	s1,440(sp)
    80004e5a:	fb4a                	sd	s2,432(sp)
    80004e5c:	f74e                	sd	s3,424(sp)
    80004e5e:	f352                	sd	s4,416(sp)
    80004e60:	ef56                	sd	s5,408(sp)
    80004e62:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80004e64:	08000613          	li	a2,128
    80004e68:	f4040593          	addi	a1,s0,-192
    80004e6c:	4501                	li	a0,0
    80004e6e:	ffffd097          	auipc	ra,0xffffd
    80004e72:	222080e7          	jalr	546(ra) # 80002090 <argstr>
    return -1;
    80004e76:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80004e78:	0c054a63          	bltz	a0,80004f4c <sys_exec+0xfa>
    80004e7c:	e3840593          	addi	a1,s0,-456
    80004e80:	4505                	li	a0,1
    80004e82:	ffffd097          	auipc	ra,0xffffd
    80004e86:	1ec080e7          	jalr	492(ra) # 8000206e <argaddr>
    80004e8a:	0c054163          	bltz	a0,80004f4c <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80004e8e:	10000613          	li	a2,256
    80004e92:	4581                	li	a1,0
    80004e94:	e4040513          	addi	a0,s0,-448
    80004e98:	ffffb097          	auipc	ra,0xffffb
    80004e9c:	328080e7          	jalr	808(ra) # 800001c0 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004ea0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004ea4:	89a6                	mv	s3,s1
    80004ea6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004ea8:	02000a13          	li	s4,32
    80004eac:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004eb0:	00391513          	slli	a0,s2,0x3
    80004eb4:	e3040593          	addi	a1,s0,-464
    80004eb8:	e3843783          	ld	a5,-456(s0)
    80004ebc:	953e                	add	a0,a0,a5
    80004ebe:	ffffd097          	auipc	ra,0xffffd
    80004ec2:	0f4080e7          	jalr	244(ra) # 80001fb2 <fetchaddr>
    80004ec6:	02054a63          	bltz	a0,80004efa <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80004eca:	e3043783          	ld	a5,-464(s0)
    80004ece:	c3b9                	beqz	a5,80004f14 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004ed0:	ffffb097          	auipc	ra,0xffffb
    80004ed4:	262080e7          	jalr	610(ra) # 80000132 <kalloc>
    80004ed8:	85aa                	mv	a1,a0
    80004eda:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004ede:	cd11                	beqz	a0,80004efa <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004ee0:	6605                	lui	a2,0x1
    80004ee2:	e3043503          	ld	a0,-464(s0)
    80004ee6:	ffffd097          	auipc	ra,0xffffd
    80004eea:	11e080e7          	jalr	286(ra) # 80002004 <fetchstr>
    80004eee:	00054663          	bltz	a0,80004efa <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80004ef2:	0905                	addi	s2,s2,1
    80004ef4:	09a1                	addi	s3,s3,8
    80004ef6:	fb491be3          	bne	s2,s4,80004eac <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004efa:	10048913          	addi	s2,s1,256
    80004efe:	6088                	ld	a0,0(s1)
    80004f00:	c529                	beqz	a0,80004f4a <sys_exec+0xf8>
    kfree(argv[i]);
    80004f02:	ffffb097          	auipc	ra,0xffffb
    80004f06:	11a080e7          	jalr	282(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f0a:	04a1                	addi	s1,s1,8
    80004f0c:	ff2499e3          	bne	s1,s2,80004efe <sys_exec+0xac>
  return -1;
    80004f10:	597d                	li	s2,-1
    80004f12:	a82d                	j	80004f4c <sys_exec+0xfa>
      argv[i] = 0;
    80004f14:	0a8e                	slli	s5,s5,0x3
    80004f16:	fc040793          	addi	a5,s0,-64
    80004f1a:	9abe                	add	s5,s5,a5
    80004f1c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80004f20:	e4040593          	addi	a1,s0,-448
    80004f24:	f4040513          	addi	a0,s0,-192
    80004f28:	fffff097          	auipc	ra,0xfffff
    80004f2c:	194080e7          	jalr	404(ra) # 800040bc <exec>
    80004f30:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f32:	10048993          	addi	s3,s1,256
    80004f36:	6088                	ld	a0,0(s1)
    80004f38:	c911                	beqz	a0,80004f4c <sys_exec+0xfa>
    kfree(argv[i]);
    80004f3a:	ffffb097          	auipc	ra,0xffffb
    80004f3e:	0e2080e7          	jalr	226(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f42:	04a1                	addi	s1,s1,8
    80004f44:	ff3499e3          	bne	s1,s3,80004f36 <sys_exec+0xe4>
    80004f48:	a011                	j	80004f4c <sys_exec+0xfa>
  return -1;
    80004f4a:	597d                	li	s2,-1
}
    80004f4c:	854a                	mv	a0,s2
    80004f4e:	60be                	ld	ra,456(sp)
    80004f50:	641e                	ld	s0,448(sp)
    80004f52:	74fa                	ld	s1,440(sp)
    80004f54:	795a                	ld	s2,432(sp)
    80004f56:	79ba                	ld	s3,424(sp)
    80004f58:	7a1a                	ld	s4,416(sp)
    80004f5a:	6afa                	ld	s5,408(sp)
    80004f5c:	6179                	addi	sp,sp,464
    80004f5e:	8082                	ret

0000000080004f60 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004f60:	7139                	addi	sp,sp,-64
    80004f62:	fc06                	sd	ra,56(sp)
    80004f64:	f822                	sd	s0,48(sp)
    80004f66:	f426                	sd	s1,40(sp)
    80004f68:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004f6a:	ffffc097          	auipc	ra,0xffffc
    80004f6e:	fe6080e7          	jalr	-26(ra) # 80000f50 <myproc>
    80004f72:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80004f74:	fd840593          	addi	a1,s0,-40
    80004f78:	4501                	li	a0,0
    80004f7a:	ffffd097          	auipc	ra,0xffffd
    80004f7e:	0f4080e7          	jalr	244(ra) # 8000206e <argaddr>
    return -1;
    80004f82:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80004f84:	0e054063          	bltz	a0,80005064 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80004f88:	fc840593          	addi	a1,s0,-56
    80004f8c:	fd040513          	addi	a0,s0,-48
    80004f90:	fffff097          	auipc	ra,0xfffff
    80004f94:	dfc080e7          	jalr	-516(ra) # 80003d8c <pipealloc>
    return -1;
    80004f98:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004f9a:	0c054563          	bltz	a0,80005064 <sys_pipe+0x104>
  fd0 = -1;
    80004f9e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004fa2:	fd043503          	ld	a0,-48(s0)
    80004fa6:	fffff097          	auipc	ra,0xfffff
    80004faa:	508080e7          	jalr	1288(ra) # 800044ae <fdalloc>
    80004fae:	fca42223          	sw	a0,-60(s0)
    80004fb2:	08054c63          	bltz	a0,8000504a <sys_pipe+0xea>
    80004fb6:	fc843503          	ld	a0,-56(s0)
    80004fba:	fffff097          	auipc	ra,0xfffff
    80004fbe:	4f4080e7          	jalr	1268(ra) # 800044ae <fdalloc>
    80004fc2:	fca42023          	sw	a0,-64(s0)
    80004fc6:	06054863          	bltz	a0,80005036 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004fca:	4691                	li	a3,4
    80004fcc:	fc440613          	addi	a2,s0,-60
    80004fd0:	fd843583          	ld	a1,-40(s0)
    80004fd4:	68a8                	ld	a0,80(s1)
    80004fd6:	ffffc097          	auipc	ra,0xffffc
    80004fda:	c3c080e7          	jalr	-964(ra) # 80000c12 <copyout>
    80004fde:	02054063          	bltz	a0,80004ffe <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004fe2:	4691                	li	a3,4
    80004fe4:	fc040613          	addi	a2,s0,-64
    80004fe8:	fd843583          	ld	a1,-40(s0)
    80004fec:	0591                	addi	a1,a1,4
    80004fee:	68a8                	ld	a0,80(s1)
    80004ff0:	ffffc097          	auipc	ra,0xffffc
    80004ff4:	c22080e7          	jalr	-990(ra) # 80000c12 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004ff8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004ffa:	06055563          	bgez	a0,80005064 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80004ffe:	fc442783          	lw	a5,-60(s0)
    80005002:	07e9                	addi	a5,a5,26
    80005004:	078e                	slli	a5,a5,0x3
    80005006:	97a6                	add	a5,a5,s1
    80005008:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000500c:	fc042503          	lw	a0,-64(s0)
    80005010:	0569                	addi	a0,a0,26
    80005012:	050e                	slli	a0,a0,0x3
    80005014:	9526                	add	a0,a0,s1
    80005016:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    8000501a:	fd043503          	ld	a0,-48(s0)
    8000501e:	fffff097          	auipc	ra,0xfffff
    80005022:	a3e080e7          	jalr	-1474(ra) # 80003a5c <fileclose>
    fileclose(wf);
    80005026:	fc843503          	ld	a0,-56(s0)
    8000502a:	fffff097          	auipc	ra,0xfffff
    8000502e:	a32080e7          	jalr	-1486(ra) # 80003a5c <fileclose>
    return -1;
    80005032:	57fd                	li	a5,-1
    80005034:	a805                	j	80005064 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005036:	fc442783          	lw	a5,-60(s0)
    8000503a:	0007c863          	bltz	a5,8000504a <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    8000503e:	01a78513          	addi	a0,a5,26
    80005042:	050e                	slli	a0,a0,0x3
    80005044:	9526                	add	a0,a0,s1
    80005046:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    8000504a:	fd043503          	ld	a0,-48(s0)
    8000504e:	fffff097          	auipc	ra,0xfffff
    80005052:	a0e080e7          	jalr	-1522(ra) # 80003a5c <fileclose>
    fileclose(wf);
    80005056:	fc843503          	ld	a0,-56(s0)
    8000505a:	fffff097          	auipc	ra,0xfffff
    8000505e:	a02080e7          	jalr	-1534(ra) # 80003a5c <fileclose>
    return -1;
    80005062:	57fd                	li	a5,-1
}
    80005064:	853e                	mv	a0,a5
    80005066:	70e2                	ld	ra,56(sp)
    80005068:	7442                	ld	s0,48(sp)
    8000506a:	74a2                	ld	s1,40(sp)
    8000506c:	6121                	addi	sp,sp,64
    8000506e:	8082                	ret

0000000080005070 <kernelvec>:
    80005070:	7111                	addi	sp,sp,-256
    80005072:	e006                	sd	ra,0(sp)
    80005074:	e40a                	sd	sp,8(sp)
    80005076:	e80e                	sd	gp,16(sp)
    80005078:	ec12                	sd	tp,24(sp)
    8000507a:	f016                	sd	t0,32(sp)
    8000507c:	f41a                	sd	t1,40(sp)
    8000507e:	f81e                	sd	t2,48(sp)
    80005080:	fc22                	sd	s0,56(sp)
    80005082:	e0a6                	sd	s1,64(sp)
    80005084:	e4aa                	sd	a0,72(sp)
    80005086:	e8ae                	sd	a1,80(sp)
    80005088:	ecb2                	sd	a2,88(sp)
    8000508a:	f0b6                	sd	a3,96(sp)
    8000508c:	f4ba                	sd	a4,104(sp)
    8000508e:	f8be                	sd	a5,112(sp)
    80005090:	fcc2                	sd	a6,120(sp)
    80005092:	e146                	sd	a7,128(sp)
    80005094:	e54a                	sd	s2,136(sp)
    80005096:	e94e                	sd	s3,144(sp)
    80005098:	ed52                	sd	s4,152(sp)
    8000509a:	f156                	sd	s5,160(sp)
    8000509c:	f55a                	sd	s6,168(sp)
    8000509e:	f95e                	sd	s7,176(sp)
    800050a0:	fd62                	sd	s8,184(sp)
    800050a2:	e1e6                	sd	s9,192(sp)
    800050a4:	e5ea                	sd	s10,200(sp)
    800050a6:	e9ee                	sd	s11,208(sp)
    800050a8:	edf2                	sd	t3,216(sp)
    800050aa:	f1f6                	sd	t4,224(sp)
    800050ac:	f5fa                	sd	t5,232(sp)
    800050ae:	f9fe                	sd	t6,240(sp)
    800050b0:	dcffc0ef          	jal	ra,80001e7e <kerneltrap>
    800050b4:	6082                	ld	ra,0(sp)
    800050b6:	6122                	ld	sp,8(sp)
    800050b8:	61c2                	ld	gp,16(sp)
    800050ba:	7282                	ld	t0,32(sp)
    800050bc:	7322                	ld	t1,40(sp)
    800050be:	73c2                	ld	t2,48(sp)
    800050c0:	7462                	ld	s0,56(sp)
    800050c2:	6486                	ld	s1,64(sp)
    800050c4:	6526                	ld	a0,72(sp)
    800050c6:	65c6                	ld	a1,80(sp)
    800050c8:	6666                	ld	a2,88(sp)
    800050ca:	7686                	ld	a3,96(sp)
    800050cc:	7726                	ld	a4,104(sp)
    800050ce:	77c6                	ld	a5,112(sp)
    800050d0:	7866                	ld	a6,120(sp)
    800050d2:	688a                	ld	a7,128(sp)
    800050d4:	692a                	ld	s2,136(sp)
    800050d6:	69ca                	ld	s3,144(sp)
    800050d8:	6a6a                	ld	s4,152(sp)
    800050da:	7a8a                	ld	s5,160(sp)
    800050dc:	7b2a                	ld	s6,168(sp)
    800050de:	7bca                	ld	s7,176(sp)
    800050e0:	7c6a                	ld	s8,184(sp)
    800050e2:	6c8e                	ld	s9,192(sp)
    800050e4:	6d2e                	ld	s10,200(sp)
    800050e6:	6dce                	ld	s11,208(sp)
    800050e8:	6e6e                	ld	t3,216(sp)
    800050ea:	7e8e                	ld	t4,224(sp)
    800050ec:	7f2e                	ld	t5,232(sp)
    800050ee:	7fce                	ld	t6,240(sp)
    800050f0:	6111                	addi	sp,sp,256
    800050f2:	10200073          	sret
    800050f6:	00000013          	nop
    800050fa:	00000013          	nop
    800050fe:	0001                	nop

0000000080005100 <timervec>:
    80005100:	34051573          	csrrw	a0,mscratch,a0
    80005104:	e10c                	sd	a1,0(a0)
    80005106:	e510                	sd	a2,8(a0)
    80005108:	e914                	sd	a3,16(a0)
    8000510a:	6d0c                	ld	a1,24(a0)
    8000510c:	7110                	ld	a2,32(a0)
    8000510e:	6194                	ld	a3,0(a1)
    80005110:	96b2                	add	a3,a3,a2
    80005112:	e194                	sd	a3,0(a1)
    80005114:	4589                	li	a1,2
    80005116:	14459073          	csrw	sip,a1
    8000511a:	6914                	ld	a3,16(a0)
    8000511c:	6510                	ld	a2,8(a0)
    8000511e:	610c                	ld	a1,0(a0)
    80005120:	34051573          	csrrw	a0,mscratch,a0
    80005124:	30200073          	mret
	...

000000008000512a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000512a:	1141                	addi	sp,sp,-16
    8000512c:	e422                	sd	s0,8(sp)
    8000512e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005130:	0c0007b7          	lui	a5,0xc000
    80005134:	4705                	li	a4,1
    80005136:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005138:	c3d8                	sw	a4,4(a5)
}
    8000513a:	6422                	ld	s0,8(sp)
    8000513c:	0141                	addi	sp,sp,16
    8000513e:	8082                	ret

0000000080005140 <plicinithart>:

void
plicinithart(void)
{
    80005140:	1141                	addi	sp,sp,-16
    80005142:	e406                	sd	ra,8(sp)
    80005144:	e022                	sd	s0,0(sp)
    80005146:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005148:	ffffc097          	auipc	ra,0xffffc
    8000514c:	ddc080e7          	jalr	-548(ra) # 80000f24 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005150:	0085171b          	slliw	a4,a0,0x8
    80005154:	0c0027b7          	lui	a5,0xc002
    80005158:	97ba                	add	a5,a5,a4
    8000515a:	40200713          	li	a4,1026
    8000515e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005162:	00d5151b          	slliw	a0,a0,0xd
    80005166:	0c2017b7          	lui	a5,0xc201
    8000516a:	953e                	add	a0,a0,a5
    8000516c:	00052023          	sw	zero,0(a0)
}
    80005170:	60a2                	ld	ra,8(sp)
    80005172:	6402                	ld	s0,0(sp)
    80005174:	0141                	addi	sp,sp,16
    80005176:	8082                	ret

0000000080005178 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005178:	1141                	addi	sp,sp,-16
    8000517a:	e406                	sd	ra,8(sp)
    8000517c:	e022                	sd	s0,0(sp)
    8000517e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005180:	ffffc097          	auipc	ra,0xffffc
    80005184:	da4080e7          	jalr	-604(ra) # 80000f24 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005188:	00d5179b          	slliw	a5,a0,0xd
    8000518c:	0c201537          	lui	a0,0xc201
    80005190:	953e                	add	a0,a0,a5
  return irq;
}
    80005192:	4148                	lw	a0,4(a0)
    80005194:	60a2                	ld	ra,8(sp)
    80005196:	6402                	ld	s0,0(sp)
    80005198:	0141                	addi	sp,sp,16
    8000519a:	8082                	ret

000000008000519c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000519c:	1101                	addi	sp,sp,-32
    8000519e:	ec06                	sd	ra,24(sp)
    800051a0:	e822                	sd	s0,16(sp)
    800051a2:	e426                	sd	s1,8(sp)
    800051a4:	1000                	addi	s0,sp,32
    800051a6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800051a8:	ffffc097          	auipc	ra,0xffffc
    800051ac:	d7c080e7          	jalr	-644(ra) # 80000f24 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800051b0:	00d5151b          	slliw	a0,a0,0xd
    800051b4:	0c2017b7          	lui	a5,0xc201
    800051b8:	97aa                	add	a5,a5,a0
    800051ba:	c3c4                	sw	s1,4(a5)
}
    800051bc:	60e2                	ld	ra,24(sp)
    800051be:	6442                	ld	s0,16(sp)
    800051c0:	64a2                	ld	s1,8(sp)
    800051c2:	6105                	addi	sp,sp,32
    800051c4:	8082                	ret

00000000800051c6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800051c6:	1141                	addi	sp,sp,-16
    800051c8:	e406                	sd	ra,8(sp)
    800051ca:	e022                	sd	s0,0(sp)
    800051cc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800051ce:	479d                	li	a5,7
    800051d0:	06a7c963          	blt	a5,a0,80005242 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800051d4:	00016797          	auipc	a5,0x16
    800051d8:	e2c78793          	addi	a5,a5,-468 # 8001b000 <disk>
    800051dc:	00a78733          	add	a4,a5,a0
    800051e0:	6789                	lui	a5,0x2
    800051e2:	97ba                	add	a5,a5,a4
    800051e4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800051e8:	e7ad                	bnez	a5,80005252 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800051ea:	00451793          	slli	a5,a0,0x4
    800051ee:	00018717          	auipc	a4,0x18
    800051f2:	e1270713          	addi	a4,a4,-494 # 8001d000 <disk+0x2000>
    800051f6:	6314                	ld	a3,0(a4)
    800051f8:	96be                	add	a3,a3,a5
    800051fa:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800051fe:	6314                	ld	a3,0(a4)
    80005200:	96be                	add	a3,a3,a5
    80005202:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005206:	6314                	ld	a3,0(a4)
    80005208:	96be                	add	a3,a3,a5
    8000520a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000520e:	6318                	ld	a4,0(a4)
    80005210:	97ba                	add	a5,a5,a4
    80005212:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005216:	00016797          	auipc	a5,0x16
    8000521a:	dea78793          	addi	a5,a5,-534 # 8001b000 <disk>
    8000521e:	97aa                	add	a5,a5,a0
    80005220:	6509                	lui	a0,0x2
    80005222:	953e                	add	a0,a0,a5
    80005224:	4785                	li	a5,1
    80005226:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000522a:	00018517          	auipc	a0,0x18
    8000522e:	dee50513          	addi	a0,a0,-530 # 8001d018 <disk+0x2018>
    80005232:	ffffc097          	auipc	ra,0xffffc
    80005236:	566080e7          	jalr	1382(ra) # 80001798 <wakeup>
}
    8000523a:	60a2                	ld	ra,8(sp)
    8000523c:	6402                	ld	s0,0(sp)
    8000523e:	0141                	addi	sp,sp,16
    80005240:	8082                	ret
    panic("free_desc 1");
    80005242:	00003517          	auipc	a0,0x3
    80005246:	4a650513          	addi	a0,a0,1190 # 800086e8 <syscalls+0x320>
    8000524a:	00001097          	auipc	ra,0x1
    8000524e:	b28080e7          	jalr	-1240(ra) # 80005d72 <panic>
    panic("free_desc 2");
    80005252:	00003517          	auipc	a0,0x3
    80005256:	4a650513          	addi	a0,a0,1190 # 800086f8 <syscalls+0x330>
    8000525a:	00001097          	auipc	ra,0x1
    8000525e:	b18080e7          	jalr	-1256(ra) # 80005d72 <panic>

0000000080005262 <virtio_disk_init>:
{
    80005262:	1101                	addi	sp,sp,-32
    80005264:	ec06                	sd	ra,24(sp)
    80005266:	e822                	sd	s0,16(sp)
    80005268:	e426                	sd	s1,8(sp)
    8000526a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000526c:	00003597          	auipc	a1,0x3
    80005270:	49c58593          	addi	a1,a1,1180 # 80008708 <syscalls+0x340>
    80005274:	00018517          	auipc	a0,0x18
    80005278:	eb450513          	addi	a0,a0,-332 # 8001d128 <disk+0x2128>
    8000527c:	00001097          	auipc	ra,0x1
    80005280:	fb0080e7          	jalr	-80(ra) # 8000622c <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005284:	100017b7          	lui	a5,0x10001
    80005288:	4398                	lw	a4,0(a5)
    8000528a:	2701                	sext.w	a4,a4
    8000528c:	747277b7          	lui	a5,0x74727
    80005290:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005294:	0ef71163          	bne	a4,a5,80005376 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005298:	100017b7          	lui	a5,0x10001
    8000529c:	43dc                	lw	a5,4(a5)
    8000529e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800052a0:	4705                	li	a4,1
    800052a2:	0ce79a63          	bne	a5,a4,80005376 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800052a6:	100017b7          	lui	a5,0x10001
    800052aa:	479c                	lw	a5,8(a5)
    800052ac:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800052ae:	4709                	li	a4,2
    800052b0:	0ce79363          	bne	a5,a4,80005376 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800052b4:	100017b7          	lui	a5,0x10001
    800052b8:	47d8                	lw	a4,12(a5)
    800052ba:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800052bc:	554d47b7          	lui	a5,0x554d4
    800052c0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800052c4:	0af71963          	bne	a4,a5,80005376 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800052c8:	100017b7          	lui	a5,0x10001
    800052cc:	4705                	li	a4,1
    800052ce:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800052d0:	470d                	li	a4,3
    800052d2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800052d4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800052d6:	c7ffe737          	lui	a4,0xc7ffe
    800052da:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47ed851f>
    800052de:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800052e0:	2701                	sext.w	a4,a4
    800052e2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800052e4:	472d                	li	a4,11
    800052e6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800052e8:	473d                	li	a4,15
    800052ea:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800052ec:	6705                	lui	a4,0x1
    800052ee:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800052f0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800052f4:	5bdc                	lw	a5,52(a5)
    800052f6:	2781                	sext.w	a5,a5
  if(max == 0)
    800052f8:	c7d9                	beqz	a5,80005386 <virtio_disk_init+0x124>
  if(max < NUM)
    800052fa:	471d                	li	a4,7
    800052fc:	08f77d63          	bgeu	a4,a5,80005396 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005300:	100014b7          	lui	s1,0x10001
    80005304:	47a1                	li	a5,8
    80005306:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005308:	6609                	lui	a2,0x2
    8000530a:	4581                	li	a1,0
    8000530c:	00016517          	auipc	a0,0x16
    80005310:	cf450513          	addi	a0,a0,-780 # 8001b000 <disk>
    80005314:	ffffb097          	auipc	ra,0xffffb
    80005318:	eac080e7          	jalr	-340(ra) # 800001c0 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000531c:	00016717          	auipc	a4,0x16
    80005320:	ce470713          	addi	a4,a4,-796 # 8001b000 <disk>
    80005324:	00c75793          	srli	a5,a4,0xc
    80005328:	2781                	sext.w	a5,a5
    8000532a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000532c:	00018797          	auipc	a5,0x18
    80005330:	cd478793          	addi	a5,a5,-812 # 8001d000 <disk+0x2000>
    80005334:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005336:	00016717          	auipc	a4,0x16
    8000533a:	d4a70713          	addi	a4,a4,-694 # 8001b080 <disk+0x80>
    8000533e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005340:	00017717          	auipc	a4,0x17
    80005344:	cc070713          	addi	a4,a4,-832 # 8001c000 <disk+0x1000>
    80005348:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000534a:	4705                	li	a4,1
    8000534c:	00e78c23          	sb	a4,24(a5)
    80005350:	00e78ca3          	sb	a4,25(a5)
    80005354:	00e78d23          	sb	a4,26(a5)
    80005358:	00e78da3          	sb	a4,27(a5)
    8000535c:	00e78e23          	sb	a4,28(a5)
    80005360:	00e78ea3          	sb	a4,29(a5)
    80005364:	00e78f23          	sb	a4,30(a5)
    80005368:	00e78fa3          	sb	a4,31(a5)
}
    8000536c:	60e2                	ld	ra,24(sp)
    8000536e:	6442                	ld	s0,16(sp)
    80005370:	64a2                	ld	s1,8(sp)
    80005372:	6105                	addi	sp,sp,32
    80005374:	8082                	ret
    panic("could not find virtio disk");
    80005376:	00003517          	auipc	a0,0x3
    8000537a:	3a250513          	addi	a0,a0,930 # 80008718 <syscalls+0x350>
    8000537e:	00001097          	auipc	ra,0x1
    80005382:	9f4080e7          	jalr	-1548(ra) # 80005d72 <panic>
    panic("virtio disk has no queue 0");
    80005386:	00003517          	auipc	a0,0x3
    8000538a:	3b250513          	addi	a0,a0,946 # 80008738 <syscalls+0x370>
    8000538e:	00001097          	auipc	ra,0x1
    80005392:	9e4080e7          	jalr	-1564(ra) # 80005d72 <panic>
    panic("virtio disk max queue too short");
    80005396:	00003517          	auipc	a0,0x3
    8000539a:	3c250513          	addi	a0,a0,962 # 80008758 <syscalls+0x390>
    8000539e:	00001097          	auipc	ra,0x1
    800053a2:	9d4080e7          	jalr	-1580(ra) # 80005d72 <panic>

00000000800053a6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800053a6:	7159                	addi	sp,sp,-112
    800053a8:	f486                	sd	ra,104(sp)
    800053aa:	f0a2                	sd	s0,96(sp)
    800053ac:	eca6                	sd	s1,88(sp)
    800053ae:	e8ca                	sd	s2,80(sp)
    800053b0:	e4ce                	sd	s3,72(sp)
    800053b2:	e0d2                	sd	s4,64(sp)
    800053b4:	fc56                	sd	s5,56(sp)
    800053b6:	f85a                	sd	s6,48(sp)
    800053b8:	f45e                	sd	s7,40(sp)
    800053ba:	f062                	sd	s8,32(sp)
    800053bc:	ec66                	sd	s9,24(sp)
    800053be:	e86a                	sd	s10,16(sp)
    800053c0:	1880                	addi	s0,sp,112
    800053c2:	892a                	mv	s2,a0
    800053c4:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800053c6:	00c52c83          	lw	s9,12(a0)
    800053ca:	001c9c9b          	slliw	s9,s9,0x1
    800053ce:	1c82                	slli	s9,s9,0x20
    800053d0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800053d4:	00018517          	auipc	a0,0x18
    800053d8:	d5450513          	addi	a0,a0,-684 # 8001d128 <disk+0x2128>
    800053dc:	00001097          	auipc	ra,0x1
    800053e0:	ee0080e7          	jalr	-288(ra) # 800062bc <acquire>
  for(int i = 0; i < 3; i++){
    800053e4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800053e6:	4c21                	li	s8,8
      disk.free[i] = 0;
    800053e8:	00016b97          	auipc	s7,0x16
    800053ec:	c18b8b93          	addi	s7,s7,-1000 # 8001b000 <disk>
    800053f0:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    800053f2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800053f4:	8a4e                	mv	s4,s3
    800053f6:	a051                	j	8000547a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    800053f8:	00fb86b3          	add	a3,s7,a5
    800053fc:	96da                	add	a3,a3,s6
    800053fe:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80005402:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80005404:	0207c563          	bltz	a5,8000542e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005408:	2485                	addiw	s1,s1,1
    8000540a:	0711                	addi	a4,a4,4
    8000540c:	25548063          	beq	s1,s5,8000564c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80005410:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80005412:	00018697          	auipc	a3,0x18
    80005416:	c0668693          	addi	a3,a3,-1018 # 8001d018 <disk+0x2018>
    8000541a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    8000541c:	0006c583          	lbu	a1,0(a3)
    80005420:	fde1                	bnez	a1,800053f8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005422:	2785                	addiw	a5,a5,1
    80005424:	0685                	addi	a3,a3,1
    80005426:	ff879be3          	bne	a5,s8,8000541c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000542a:	57fd                	li	a5,-1
    8000542c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000542e:	02905a63          	blez	s1,80005462 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005432:	f9042503          	lw	a0,-112(s0)
    80005436:	00000097          	auipc	ra,0x0
    8000543a:	d90080e7          	jalr	-624(ra) # 800051c6 <free_desc>
      for(int j = 0; j < i; j++)
    8000543e:	4785                	li	a5,1
    80005440:	0297d163          	bge	a5,s1,80005462 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005444:	f9442503          	lw	a0,-108(s0)
    80005448:	00000097          	auipc	ra,0x0
    8000544c:	d7e080e7          	jalr	-642(ra) # 800051c6 <free_desc>
      for(int j = 0; j < i; j++)
    80005450:	4789                	li	a5,2
    80005452:	0097d863          	bge	a5,s1,80005462 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005456:	f9842503          	lw	a0,-104(s0)
    8000545a:	00000097          	auipc	ra,0x0
    8000545e:	d6c080e7          	jalr	-660(ra) # 800051c6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005462:	00018597          	auipc	a1,0x18
    80005466:	cc658593          	addi	a1,a1,-826 # 8001d128 <disk+0x2128>
    8000546a:	00018517          	auipc	a0,0x18
    8000546e:	bae50513          	addi	a0,a0,-1106 # 8001d018 <disk+0x2018>
    80005472:	ffffc097          	auipc	ra,0xffffc
    80005476:	19a080e7          	jalr	410(ra) # 8000160c <sleep>
  for(int i = 0; i < 3; i++){
    8000547a:	f9040713          	addi	a4,s0,-112
    8000547e:	84ce                	mv	s1,s3
    80005480:	bf41                	j	80005410 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80005482:	20058713          	addi	a4,a1,512
    80005486:	00471693          	slli	a3,a4,0x4
    8000548a:	00016717          	auipc	a4,0x16
    8000548e:	b7670713          	addi	a4,a4,-1162 # 8001b000 <disk>
    80005492:	9736                	add	a4,a4,a3
    80005494:	4685                	li	a3,1
    80005496:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000549a:	20058713          	addi	a4,a1,512
    8000549e:	00471693          	slli	a3,a4,0x4
    800054a2:	00016717          	auipc	a4,0x16
    800054a6:	b5e70713          	addi	a4,a4,-1186 # 8001b000 <disk>
    800054aa:	9736                	add	a4,a4,a3
    800054ac:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800054b0:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800054b4:	7679                	lui	a2,0xffffe
    800054b6:	963e                	add	a2,a2,a5
    800054b8:	00018697          	auipc	a3,0x18
    800054bc:	b4868693          	addi	a3,a3,-1208 # 8001d000 <disk+0x2000>
    800054c0:	6298                	ld	a4,0(a3)
    800054c2:	9732                	add	a4,a4,a2
    800054c4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800054c6:	6298                	ld	a4,0(a3)
    800054c8:	9732                	add	a4,a4,a2
    800054ca:	4541                	li	a0,16
    800054cc:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800054ce:	6298                	ld	a4,0(a3)
    800054d0:	9732                	add	a4,a4,a2
    800054d2:	4505                	li	a0,1
    800054d4:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800054d8:	f9442703          	lw	a4,-108(s0)
    800054dc:	6288                	ld	a0,0(a3)
    800054de:	962a                	add	a2,a2,a0
    800054e0:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7fed7dce>

  disk.desc[idx[1]].addr = (uint64) b->data;
    800054e4:	0712                	slli	a4,a4,0x4
    800054e6:	6290                	ld	a2,0(a3)
    800054e8:	963a                	add	a2,a2,a4
    800054ea:	05890513          	addi	a0,s2,88
    800054ee:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800054f0:	6294                	ld	a3,0(a3)
    800054f2:	96ba                	add	a3,a3,a4
    800054f4:	40000613          	li	a2,1024
    800054f8:	c690                	sw	a2,8(a3)
  if(write)
    800054fa:	140d0063          	beqz	s10,8000563a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800054fe:	00018697          	auipc	a3,0x18
    80005502:	b026b683          	ld	a3,-1278(a3) # 8001d000 <disk+0x2000>
    80005506:	96ba                	add	a3,a3,a4
    80005508:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000550c:	00016817          	auipc	a6,0x16
    80005510:	af480813          	addi	a6,a6,-1292 # 8001b000 <disk>
    80005514:	00018517          	auipc	a0,0x18
    80005518:	aec50513          	addi	a0,a0,-1300 # 8001d000 <disk+0x2000>
    8000551c:	6114                	ld	a3,0(a0)
    8000551e:	96ba                	add	a3,a3,a4
    80005520:	00c6d603          	lhu	a2,12(a3)
    80005524:	00166613          	ori	a2,a2,1
    80005528:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000552c:	f9842683          	lw	a3,-104(s0)
    80005530:	6110                	ld	a2,0(a0)
    80005532:	9732                	add	a4,a4,a2
    80005534:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005538:	20058613          	addi	a2,a1,512
    8000553c:	0612                	slli	a2,a2,0x4
    8000553e:	9642                	add	a2,a2,a6
    80005540:	577d                	li	a4,-1
    80005542:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005546:	00469713          	slli	a4,a3,0x4
    8000554a:	6114                	ld	a3,0(a0)
    8000554c:	96ba                	add	a3,a3,a4
    8000554e:	03078793          	addi	a5,a5,48
    80005552:	97c2                	add	a5,a5,a6
    80005554:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80005556:	611c                	ld	a5,0(a0)
    80005558:	97ba                	add	a5,a5,a4
    8000555a:	4685                	li	a3,1
    8000555c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000555e:	611c                	ld	a5,0(a0)
    80005560:	97ba                	add	a5,a5,a4
    80005562:	4809                	li	a6,2
    80005564:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80005568:	611c                	ld	a5,0(a0)
    8000556a:	973e                	add	a4,a4,a5
    8000556c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005570:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80005574:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005578:	6518                	ld	a4,8(a0)
    8000557a:	00275783          	lhu	a5,2(a4)
    8000557e:	8b9d                	andi	a5,a5,7
    80005580:	0786                	slli	a5,a5,0x1
    80005582:	97ba                	add	a5,a5,a4
    80005584:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80005588:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000558c:	6518                	ld	a4,8(a0)
    8000558e:	00275783          	lhu	a5,2(a4)
    80005592:	2785                	addiw	a5,a5,1
    80005594:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005598:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000559c:	100017b7          	lui	a5,0x10001
    800055a0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800055a4:	00492703          	lw	a4,4(s2)
    800055a8:	4785                	li	a5,1
    800055aa:	02f71163          	bne	a4,a5,800055cc <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    800055ae:	00018997          	auipc	s3,0x18
    800055b2:	b7a98993          	addi	s3,s3,-1158 # 8001d128 <disk+0x2128>
  while(b->disk == 1) {
    800055b6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800055b8:	85ce                	mv	a1,s3
    800055ba:	854a                	mv	a0,s2
    800055bc:	ffffc097          	auipc	ra,0xffffc
    800055c0:	050080e7          	jalr	80(ra) # 8000160c <sleep>
  while(b->disk == 1) {
    800055c4:	00492783          	lw	a5,4(s2)
    800055c8:	fe9788e3          	beq	a5,s1,800055b8 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    800055cc:	f9042903          	lw	s2,-112(s0)
    800055d0:	20090793          	addi	a5,s2,512
    800055d4:	00479713          	slli	a4,a5,0x4
    800055d8:	00016797          	auipc	a5,0x16
    800055dc:	a2878793          	addi	a5,a5,-1496 # 8001b000 <disk>
    800055e0:	97ba                	add	a5,a5,a4
    800055e2:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800055e6:	00018997          	auipc	s3,0x18
    800055ea:	a1a98993          	addi	s3,s3,-1510 # 8001d000 <disk+0x2000>
    800055ee:	00491713          	slli	a4,s2,0x4
    800055f2:	0009b783          	ld	a5,0(s3)
    800055f6:	97ba                	add	a5,a5,a4
    800055f8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800055fc:	854a                	mv	a0,s2
    800055fe:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005602:	00000097          	auipc	ra,0x0
    80005606:	bc4080e7          	jalr	-1084(ra) # 800051c6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000560a:	8885                	andi	s1,s1,1
    8000560c:	f0ed                	bnez	s1,800055ee <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000560e:	00018517          	auipc	a0,0x18
    80005612:	b1a50513          	addi	a0,a0,-1254 # 8001d128 <disk+0x2128>
    80005616:	00001097          	auipc	ra,0x1
    8000561a:	d5a080e7          	jalr	-678(ra) # 80006370 <release>
}
    8000561e:	70a6                	ld	ra,104(sp)
    80005620:	7406                	ld	s0,96(sp)
    80005622:	64e6                	ld	s1,88(sp)
    80005624:	6946                	ld	s2,80(sp)
    80005626:	69a6                	ld	s3,72(sp)
    80005628:	6a06                	ld	s4,64(sp)
    8000562a:	7ae2                	ld	s5,56(sp)
    8000562c:	7b42                	ld	s6,48(sp)
    8000562e:	7ba2                	ld	s7,40(sp)
    80005630:	7c02                	ld	s8,32(sp)
    80005632:	6ce2                	ld	s9,24(sp)
    80005634:	6d42                	ld	s10,16(sp)
    80005636:	6165                	addi	sp,sp,112
    80005638:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000563a:	00018697          	auipc	a3,0x18
    8000563e:	9c66b683          	ld	a3,-1594(a3) # 8001d000 <disk+0x2000>
    80005642:	96ba                	add	a3,a3,a4
    80005644:	4609                	li	a2,2
    80005646:	00c69623          	sh	a2,12(a3)
    8000564a:	b5c9                	j	8000550c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000564c:	f9042583          	lw	a1,-112(s0)
    80005650:	20058793          	addi	a5,a1,512
    80005654:	0792                	slli	a5,a5,0x4
    80005656:	00016517          	auipc	a0,0x16
    8000565a:	a5250513          	addi	a0,a0,-1454 # 8001b0a8 <disk+0xa8>
    8000565e:	953e                	add	a0,a0,a5
  if(write)
    80005660:	e20d11e3          	bnez	s10,80005482 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80005664:	20058713          	addi	a4,a1,512
    80005668:	00471693          	slli	a3,a4,0x4
    8000566c:	00016717          	auipc	a4,0x16
    80005670:	99470713          	addi	a4,a4,-1644 # 8001b000 <disk>
    80005674:	9736                	add	a4,a4,a3
    80005676:	0a072423          	sw	zero,168(a4)
    8000567a:	b505                	j	8000549a <virtio_disk_rw+0xf4>

000000008000567c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000567c:	1101                	addi	sp,sp,-32
    8000567e:	ec06                	sd	ra,24(sp)
    80005680:	e822                	sd	s0,16(sp)
    80005682:	e426                	sd	s1,8(sp)
    80005684:	e04a                	sd	s2,0(sp)
    80005686:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005688:	00018517          	auipc	a0,0x18
    8000568c:	aa050513          	addi	a0,a0,-1376 # 8001d128 <disk+0x2128>
    80005690:	00001097          	auipc	ra,0x1
    80005694:	c2c080e7          	jalr	-980(ra) # 800062bc <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005698:	10001737          	lui	a4,0x10001
    8000569c:	533c                	lw	a5,96(a4)
    8000569e:	8b8d                	andi	a5,a5,3
    800056a0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800056a2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800056a6:	00018797          	auipc	a5,0x18
    800056aa:	95a78793          	addi	a5,a5,-1702 # 8001d000 <disk+0x2000>
    800056ae:	6b94                	ld	a3,16(a5)
    800056b0:	0207d703          	lhu	a4,32(a5)
    800056b4:	0026d783          	lhu	a5,2(a3)
    800056b8:	06f70163          	beq	a4,a5,8000571a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800056bc:	00016917          	auipc	s2,0x16
    800056c0:	94490913          	addi	s2,s2,-1724 # 8001b000 <disk>
    800056c4:	00018497          	auipc	s1,0x18
    800056c8:	93c48493          	addi	s1,s1,-1732 # 8001d000 <disk+0x2000>
    __sync_synchronize();
    800056cc:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800056d0:	6898                	ld	a4,16(s1)
    800056d2:	0204d783          	lhu	a5,32(s1)
    800056d6:	8b9d                	andi	a5,a5,7
    800056d8:	078e                	slli	a5,a5,0x3
    800056da:	97ba                	add	a5,a5,a4
    800056dc:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800056de:	20078713          	addi	a4,a5,512
    800056e2:	0712                	slli	a4,a4,0x4
    800056e4:	974a                	add	a4,a4,s2
    800056e6:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800056ea:	e731                	bnez	a4,80005736 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800056ec:	20078793          	addi	a5,a5,512
    800056f0:	0792                	slli	a5,a5,0x4
    800056f2:	97ca                	add	a5,a5,s2
    800056f4:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800056f6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800056fa:	ffffc097          	auipc	ra,0xffffc
    800056fe:	09e080e7          	jalr	158(ra) # 80001798 <wakeup>

    disk.used_idx += 1;
    80005702:	0204d783          	lhu	a5,32(s1)
    80005706:	2785                	addiw	a5,a5,1
    80005708:	17c2                	slli	a5,a5,0x30
    8000570a:	93c1                	srli	a5,a5,0x30
    8000570c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005710:	6898                	ld	a4,16(s1)
    80005712:	00275703          	lhu	a4,2(a4)
    80005716:	faf71be3          	bne	a4,a5,800056cc <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000571a:	00018517          	auipc	a0,0x18
    8000571e:	a0e50513          	addi	a0,a0,-1522 # 8001d128 <disk+0x2128>
    80005722:	00001097          	auipc	ra,0x1
    80005726:	c4e080e7          	jalr	-946(ra) # 80006370 <release>
}
    8000572a:	60e2                	ld	ra,24(sp)
    8000572c:	6442                	ld	s0,16(sp)
    8000572e:	64a2                	ld	s1,8(sp)
    80005730:	6902                	ld	s2,0(sp)
    80005732:	6105                	addi	sp,sp,32
    80005734:	8082                	ret
      panic("virtio_disk_intr status");
    80005736:	00003517          	auipc	a0,0x3
    8000573a:	04250513          	addi	a0,a0,66 # 80008778 <syscalls+0x3b0>
    8000573e:	00000097          	auipc	ra,0x0
    80005742:	634080e7          	jalr	1588(ra) # 80005d72 <panic>

0000000080005746 <increase_reference_cnt>:
  uint8 reference_count;
} cow_array[(PHYSTOP - KERNBASE)/PGSIZE];   // (Book p.32) (PHYSTOP - KERNBASE) shift right devision 2^12=4096-bytepage directory 

// increase the reference count
void increase_reference_cnt(uint64 pa){
  if (pa < KERNBASE) {  
    80005746:	800007b7          	lui	a5,0x80000
    8000574a:	fff7c793          	not	a5,a5
    8000574e:	00a7e363          	bltu	a5,a0,80005754 <increase_reference_cnt+0xe>
    80005752:	8082                	ret
void increase_reference_cnt(uint64 pa){
    80005754:	1101                	addi	sp,sp,-32
    80005756:	ec06                	sd	ra,24(sp)
    80005758:	e822                	sd	s0,16(sp)
    8000575a:	e426                	sd	s1,8(sp)
    8000575c:	1000                	addi	s0,sp,32
    return;
  }
  // move 12 bits to the right to get the physical page reference count where the physical address is located
  pa = (pa - KERNBASE)/PGSIZE;   
    8000575e:	800004b7          	lui	s1,0x80000
    80005762:	94aa                	add	s1,s1,a0
    80005764:	80b1                	srli	s1,s1,0xc
  acquire(&cow_array[pa].lock);  // unlock
    80005766:	0496                	slli	s1,s1,0x5
    80005768:	00019517          	auipc	a0,0x19
    8000576c:	89850513          	addi	a0,a0,-1896 # 8001e000 <cow_array>
    80005770:	94aa                	add	s1,s1,a0
    80005772:	8526                	mv	a0,s1
    80005774:	00001097          	auipc	ra,0x1
    80005778:	b48080e7          	jalr	-1208(ra) # 800062bc <acquire>
  ++cow_array[pa].reference_count;
    8000577c:	0184c783          	lbu	a5,24(s1) # ffffffff80000018 <end+0xfffffffeffed9dd8>
    80005780:	2785                	addiw	a5,a5,1
    80005782:	00f48c23          	sb	a5,24(s1)
  release(&cow_array[pa].lock); // lock
    80005786:	8526                	mv	a0,s1
    80005788:	00001097          	auipc	ra,0x1
    8000578c:	be8080e7          	jalr	-1048(ra) # 80006370 <release>
}
    80005790:	60e2                	ld	ra,24(sp)
    80005792:	6442                	ld	s0,16(sp)
    80005794:	64a2                	ld	s1,8(sp)
    80005796:	6105                	addi	sp,sp,32
    80005798:	8082                	ret

000000008000579a <decrease_reference_cnt>:

// decrease the reference count
uint8 decrease_reference_cnt(uint64 pa){
    8000579a:	1101                	addi	sp,sp,-32
    8000579c:	ec06                	sd	ra,24(sp)
    8000579e:	e822                	sd	s0,16(sp)
    800057a0:	e426                	sd	s1,8(sp)
    800057a2:	e04a                	sd	s2,0(sp)
    800057a4:	1000                	addi	s0,sp,32
  uint8 temp;
  if (pa < KERNBASE) {
    800057a6:	800007b7          	lui	a5,0x80000
    800057aa:	fff7c793          	not	a5,a5
    return 0;
    800057ae:	4901                	li	s2,0
  if (pa < KERNBASE) {
    800057b0:	00a7e963          	bltu	a5,a0,800057c2 <decrease_reference_cnt+0x28>
  pa = (pa - KERNBASE)/PGSIZE;
  acquire(&cow_array[pa].lock); //unlock 
  temp = --cow_array[pa].reference_count;
  release(&cow_array[pa].lock); // lock
  return temp;
}
    800057b4:	854a                	mv	a0,s2
    800057b6:	60e2                	ld	ra,24(sp)
    800057b8:	6442                	ld	s0,16(sp)
    800057ba:	64a2                	ld	s1,8(sp)
    800057bc:	6902                	ld	s2,0(sp)
    800057be:	6105                	addi	sp,sp,32
    800057c0:	8082                	ret
  pa = (pa - KERNBASE)/PGSIZE;
    800057c2:	800004b7          	lui	s1,0x80000
    800057c6:	94aa                	add	s1,s1,a0
    800057c8:	80b1                	srli	s1,s1,0xc
  acquire(&cow_array[pa].lock); //unlock 
    800057ca:	0496                	slli	s1,s1,0x5
    800057cc:	00019517          	auipc	a0,0x19
    800057d0:	83450513          	addi	a0,a0,-1996 # 8001e000 <cow_array>
    800057d4:	94aa                	add	s1,s1,a0
    800057d6:	8526                	mv	a0,s1
    800057d8:	00001097          	auipc	ra,0x1
    800057dc:	ae4080e7          	jalr	-1308(ra) # 800062bc <acquire>
  temp = --cow_array[pa].reference_count;
    800057e0:	0184c903          	lbu	s2,24(s1) # ffffffff80000018 <end+0xfffffffeffed9dd8>
    800057e4:	397d                	addiw	s2,s2,-1
    800057e6:	0ff97913          	andi	s2,s2,255
    800057ea:	01248c23          	sb	s2,24(s1)
  release(&cow_array[pa].lock); // lock
    800057ee:	8526                	mv	a0,s1
    800057f0:	00001097          	auipc	ra,0x1
    800057f4:	b80080e7          	jalr	-1152(ra) # 80006370 <release>
  return temp;
    800057f8:	bf75                	j	800057b4 <decrease_reference_cnt+0x1a>

00000000800057fa <reference_cnt>:

uint8 reference_cnt(uint64 pa){
    800057fa:	1101                	addi	sp,sp,-32
    800057fc:	ec06                	sd	ra,24(sp)
    800057fe:	e822                	sd	s0,16(sp)
    80005800:	e426                	sd	s1,8(sp)
    80005802:	e04a                	sd	s2,0(sp)
    80005804:	1000                	addi	s0,sp,32
  uint8 temp;
  if (pa < KERNBASE) { 
    80005806:	800007b7          	lui	a5,0x80000
    8000580a:	fff7c793          	not	a5,a5
    return 0;
    8000580e:	4901                	li	s2,0
  if (pa < KERNBASE) { 
    80005810:	00a7e963          	bltu	a5,a0,80005822 <reference_cnt+0x28>
  pa = (pa - KERNBASE)/PGSIZE;
  acquire(&cow_array[pa].lock); //unlock 
  temp = cow_array[pa].reference_count;
  release(&cow_array[pa].lock); // lock
  return temp;
}
    80005814:	854a                	mv	a0,s2
    80005816:	60e2                	ld	ra,24(sp)
    80005818:	6442                	ld	s0,16(sp)
    8000581a:	64a2                	ld	s1,8(sp)
    8000581c:	6902                	ld	s2,0(sp)
    8000581e:	6105                	addi	sp,sp,32
    80005820:	8082                	ret
  pa = (pa - KERNBASE)/PGSIZE;
    80005822:	800004b7          	lui	s1,0x80000
    80005826:	94aa                	add	s1,s1,a0
    80005828:	80b1                	srli	s1,s1,0xc
  acquire(&cow_array[pa].lock); //unlock 
    8000582a:	0496                	slli	s1,s1,0x5
    8000582c:	00018517          	auipc	a0,0x18
    80005830:	7d450513          	addi	a0,a0,2004 # 8001e000 <cow_array>
    80005834:	94aa                	add	s1,s1,a0
    80005836:	8526                	mv	a0,s1
    80005838:	00001097          	auipc	ra,0x1
    8000583c:	a84080e7          	jalr	-1404(ra) # 800062bc <acquire>
  temp = cow_array[pa].reference_count;
    80005840:	0184c903          	lbu	s2,24(s1) # ffffffff80000018 <end+0xfffffffeffed9dd8>
  release(&cow_array[pa].lock); // lock
    80005844:	8526                	mv	a0,s1
    80005846:	00001097          	auipc	ra,0x1
    8000584a:	b2a080e7          	jalr	-1238(ra) # 80006370 <release>
  return temp;
    8000584e:	b7d9                	j	80005814 <reference_cnt+0x1a>

0000000080005850 <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    80005850:	1141                	addi	sp,sp,-16
    80005852:	e422                	sd	s0,8(sp)
    80005854:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80005856:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    8000585a:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000585e:	0037979b          	slliw	a5,a5,0x3
    80005862:	02004737          	lui	a4,0x2004
    80005866:	97ba                	add	a5,a5,a4
    80005868:	0200c737          	lui	a4,0x200c
    8000586c:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80005870:	000f4637          	lui	a2,0xf4
    80005874:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80005878:	95b2                	add	a1,a1,a2
    8000587a:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    8000587c:	00269713          	slli	a4,a3,0x2
    80005880:	9736                	add	a4,a4,a3
    80005882:	00371693          	slli	a3,a4,0x3
    80005886:	00118717          	auipc	a4,0x118
    8000588a:	77a70713          	addi	a4,a4,1914 # 8011e000 <timer_scratch>
    8000588e:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    80005890:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    80005892:	f310                	sd	a2,32(a4)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80005894:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80005898:	00000797          	auipc	a5,0x0
    8000589c:	86878793          	addi	a5,a5,-1944 # 80005100 <timervec>
    800058a0:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    800058a4:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    800058a8:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800058ac:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    800058b0:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    800058b4:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    800058b8:	30479073          	csrw	mie,a5
}
    800058bc:	6422                	ld	s0,8(sp)
    800058be:	0141                	addi	sp,sp,16
    800058c0:	8082                	ret

00000000800058c2 <start>:
{
    800058c2:	1141                	addi	sp,sp,-16
    800058c4:	e406                	sd	ra,8(sp)
    800058c6:	e022                	sd	s0,0(sp)
    800058c8:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    800058ca:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    800058ce:	7779                	lui	a4,0xffffe
    800058d0:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fed85bf>
    800058d4:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800058d6:	6705                	lui	a4,0x1
    800058d8:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800058dc:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800058de:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800058e2:	ffffb797          	auipc	a5,0xffffb
    800058e6:	a8c78793          	addi	a5,a5,-1396 # 8000036e <main>
    800058ea:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800058ee:	4781                	li	a5,0
    800058f0:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800058f4:	67c1                	lui	a5,0x10
    800058f6:	17fd                	addi	a5,a5,-1
    800058f8:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800058fc:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80005900:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80005904:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80005908:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    8000590c:	57fd                	li	a5,-1
    8000590e:	83a9                	srli	a5,a5,0xa
    80005910:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80005914:	47bd                	li	a5,15
    80005916:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    8000591a:	00000097          	auipc	ra,0x0
    8000591e:	f36080e7          	jalr	-202(ra) # 80005850 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80005922:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80005926:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80005928:	823e                	mv	tp,a5
  asm volatile("mret");
    8000592a:	30200073          	mret
}
    8000592e:	60a2                	ld	ra,8(sp)
    80005930:	6402                	ld	s0,0(sp)
    80005932:	0141                	addi	sp,sp,16
    80005934:	8082                	ret

0000000080005936 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80005936:	715d                	addi	sp,sp,-80
    80005938:	e486                	sd	ra,72(sp)
    8000593a:	e0a2                	sd	s0,64(sp)
    8000593c:	fc26                	sd	s1,56(sp)
    8000593e:	f84a                	sd	s2,48(sp)
    80005940:	f44e                	sd	s3,40(sp)
    80005942:	f052                	sd	s4,32(sp)
    80005944:	ec56                	sd	s5,24(sp)
    80005946:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80005948:	04c05663          	blez	a2,80005994 <consolewrite+0x5e>
    8000594c:	8a2a                	mv	s4,a0
    8000594e:	84ae                	mv	s1,a1
    80005950:	89b2                	mv	s3,a2
    80005952:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80005954:	5afd                	li	s5,-1
    80005956:	4685                	li	a3,1
    80005958:	8626                	mv	a2,s1
    8000595a:	85d2                	mv	a1,s4
    8000595c:	fbf40513          	addi	a0,s0,-65
    80005960:	ffffc097          	auipc	ra,0xffffc
    80005964:	0a6080e7          	jalr	166(ra) # 80001a06 <either_copyin>
    80005968:	01550c63          	beq	a0,s5,80005980 <consolewrite+0x4a>
      break;
    uartputc(c);
    8000596c:	fbf44503          	lbu	a0,-65(s0)
    80005970:	00000097          	auipc	ra,0x0
    80005974:	78e080e7          	jalr	1934(ra) # 800060fe <uartputc>
  for(i = 0; i < n; i++){
    80005978:	2905                	addiw	s2,s2,1
    8000597a:	0485                	addi	s1,s1,1
    8000597c:	fd299de3          	bne	s3,s2,80005956 <consolewrite+0x20>
  }

  return i;
}
    80005980:	854a                	mv	a0,s2
    80005982:	60a6                	ld	ra,72(sp)
    80005984:	6406                	ld	s0,64(sp)
    80005986:	74e2                	ld	s1,56(sp)
    80005988:	7942                	ld	s2,48(sp)
    8000598a:	79a2                	ld	s3,40(sp)
    8000598c:	7a02                	ld	s4,32(sp)
    8000598e:	6ae2                	ld	s5,24(sp)
    80005990:	6161                	addi	sp,sp,80
    80005992:	8082                	ret
  for(i = 0; i < n; i++){
    80005994:	4901                	li	s2,0
    80005996:	b7ed                	j	80005980 <consolewrite+0x4a>

0000000080005998 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80005998:	7119                	addi	sp,sp,-128
    8000599a:	fc86                	sd	ra,120(sp)
    8000599c:	f8a2                	sd	s0,112(sp)
    8000599e:	f4a6                	sd	s1,104(sp)
    800059a0:	f0ca                	sd	s2,96(sp)
    800059a2:	ecce                	sd	s3,88(sp)
    800059a4:	e8d2                	sd	s4,80(sp)
    800059a6:	e4d6                	sd	s5,72(sp)
    800059a8:	e0da                	sd	s6,64(sp)
    800059aa:	fc5e                	sd	s7,56(sp)
    800059ac:	f862                	sd	s8,48(sp)
    800059ae:	f466                	sd	s9,40(sp)
    800059b0:	f06a                	sd	s10,32(sp)
    800059b2:	ec6e                	sd	s11,24(sp)
    800059b4:	0100                	addi	s0,sp,128
    800059b6:	8b2a                	mv	s6,a0
    800059b8:	8aae                	mv	s5,a1
    800059ba:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    800059bc:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    800059c0:	00120517          	auipc	a0,0x120
    800059c4:	78050513          	addi	a0,a0,1920 # 80126140 <cons>
    800059c8:	00001097          	auipc	ra,0x1
    800059cc:	8f4080e7          	jalr	-1804(ra) # 800062bc <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800059d0:	00120497          	auipc	s1,0x120
    800059d4:	77048493          	addi	s1,s1,1904 # 80126140 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800059d8:	89a6                	mv	s3,s1
    800059da:	00120917          	auipc	s2,0x120
    800059de:	7fe90913          	addi	s2,s2,2046 # 801261d8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800059e2:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800059e4:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800059e6:	4da9                	li	s11,10
  while(n > 0){
    800059e8:	07405863          	blez	s4,80005a58 <consoleread+0xc0>
    while(cons.r == cons.w){
    800059ec:	0984a783          	lw	a5,152(s1)
    800059f0:	09c4a703          	lw	a4,156(s1)
    800059f4:	02f71463          	bne	a4,a5,80005a1c <consoleread+0x84>
      if(myproc()->killed){
    800059f8:	ffffb097          	auipc	ra,0xffffb
    800059fc:	558080e7          	jalr	1368(ra) # 80000f50 <myproc>
    80005a00:	551c                	lw	a5,40(a0)
    80005a02:	e7b5                	bnez	a5,80005a6e <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    80005a04:	85ce                	mv	a1,s3
    80005a06:	854a                	mv	a0,s2
    80005a08:	ffffc097          	auipc	ra,0xffffc
    80005a0c:	c04080e7          	jalr	-1020(ra) # 8000160c <sleep>
    while(cons.r == cons.w){
    80005a10:	0984a783          	lw	a5,152(s1)
    80005a14:	09c4a703          	lw	a4,156(s1)
    80005a18:	fef700e3          	beq	a4,a5,800059f8 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    80005a1c:	0017871b          	addiw	a4,a5,1
    80005a20:	08e4ac23          	sw	a4,152(s1)
    80005a24:	07f7f713          	andi	a4,a5,127
    80005a28:	9726                	add	a4,a4,s1
    80005a2a:	01874703          	lbu	a4,24(a4)
    80005a2e:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80005a32:	079c0663          	beq	s8,s9,80005a9e <consoleread+0x106>
    cbuf = c;
    80005a36:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005a3a:	4685                	li	a3,1
    80005a3c:	f8f40613          	addi	a2,s0,-113
    80005a40:	85d6                	mv	a1,s5
    80005a42:	855a                	mv	a0,s6
    80005a44:	ffffc097          	auipc	ra,0xffffc
    80005a48:	f6c080e7          	jalr	-148(ra) # 800019b0 <either_copyout>
    80005a4c:	01a50663          	beq	a0,s10,80005a58 <consoleread+0xc0>
    dst++;
    80005a50:	0a85                	addi	s5,s5,1
    --n;
    80005a52:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80005a54:	f9bc1ae3          	bne	s8,s11,800059e8 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80005a58:	00120517          	auipc	a0,0x120
    80005a5c:	6e850513          	addi	a0,a0,1768 # 80126140 <cons>
    80005a60:	00001097          	auipc	ra,0x1
    80005a64:	910080e7          	jalr	-1776(ra) # 80006370 <release>

  return target - n;
    80005a68:	414b853b          	subw	a0,s7,s4
    80005a6c:	a811                	j	80005a80 <consoleread+0xe8>
        release(&cons.lock);
    80005a6e:	00120517          	auipc	a0,0x120
    80005a72:	6d250513          	addi	a0,a0,1746 # 80126140 <cons>
    80005a76:	00001097          	auipc	ra,0x1
    80005a7a:	8fa080e7          	jalr	-1798(ra) # 80006370 <release>
        return -1;
    80005a7e:	557d                	li	a0,-1
}
    80005a80:	70e6                	ld	ra,120(sp)
    80005a82:	7446                	ld	s0,112(sp)
    80005a84:	74a6                	ld	s1,104(sp)
    80005a86:	7906                	ld	s2,96(sp)
    80005a88:	69e6                	ld	s3,88(sp)
    80005a8a:	6a46                	ld	s4,80(sp)
    80005a8c:	6aa6                	ld	s5,72(sp)
    80005a8e:	6b06                	ld	s6,64(sp)
    80005a90:	7be2                	ld	s7,56(sp)
    80005a92:	7c42                	ld	s8,48(sp)
    80005a94:	7ca2                	ld	s9,40(sp)
    80005a96:	7d02                	ld	s10,32(sp)
    80005a98:	6de2                	ld	s11,24(sp)
    80005a9a:	6109                	addi	sp,sp,128
    80005a9c:	8082                	ret
      if(n < target){
    80005a9e:	000a071b          	sext.w	a4,s4
    80005aa2:	fb777be3          	bgeu	a4,s7,80005a58 <consoleread+0xc0>
        cons.r--;
    80005aa6:	00120717          	auipc	a4,0x120
    80005aaa:	72f72923          	sw	a5,1842(a4) # 801261d8 <cons+0x98>
    80005aae:	b76d                	j	80005a58 <consoleread+0xc0>

0000000080005ab0 <consputc>:
{
    80005ab0:	1141                	addi	sp,sp,-16
    80005ab2:	e406                	sd	ra,8(sp)
    80005ab4:	e022                	sd	s0,0(sp)
    80005ab6:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005ab8:	10000793          	li	a5,256
    80005abc:	00f50a63          	beq	a0,a5,80005ad0 <consputc+0x20>
    uartputc_sync(c);
    80005ac0:	00000097          	auipc	ra,0x0
    80005ac4:	564080e7          	jalr	1380(ra) # 80006024 <uartputc_sync>
}
    80005ac8:	60a2                	ld	ra,8(sp)
    80005aca:	6402                	ld	s0,0(sp)
    80005acc:	0141                	addi	sp,sp,16
    80005ace:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005ad0:	4521                	li	a0,8
    80005ad2:	00000097          	auipc	ra,0x0
    80005ad6:	552080e7          	jalr	1362(ra) # 80006024 <uartputc_sync>
    80005ada:	02000513          	li	a0,32
    80005ade:	00000097          	auipc	ra,0x0
    80005ae2:	546080e7          	jalr	1350(ra) # 80006024 <uartputc_sync>
    80005ae6:	4521                	li	a0,8
    80005ae8:	00000097          	auipc	ra,0x0
    80005aec:	53c080e7          	jalr	1340(ra) # 80006024 <uartputc_sync>
    80005af0:	bfe1                	j	80005ac8 <consputc+0x18>

0000000080005af2 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005af2:	1101                	addi	sp,sp,-32
    80005af4:	ec06                	sd	ra,24(sp)
    80005af6:	e822                	sd	s0,16(sp)
    80005af8:	e426                	sd	s1,8(sp)
    80005afa:	e04a                	sd	s2,0(sp)
    80005afc:	1000                	addi	s0,sp,32
    80005afe:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005b00:	00120517          	auipc	a0,0x120
    80005b04:	64050513          	addi	a0,a0,1600 # 80126140 <cons>
    80005b08:	00000097          	auipc	ra,0x0
    80005b0c:	7b4080e7          	jalr	1972(ra) # 800062bc <acquire>

  switch(c){
    80005b10:	47d5                	li	a5,21
    80005b12:	0af48663          	beq	s1,a5,80005bbe <consoleintr+0xcc>
    80005b16:	0297ca63          	blt	a5,s1,80005b4a <consoleintr+0x58>
    80005b1a:	47a1                	li	a5,8
    80005b1c:	0ef48763          	beq	s1,a5,80005c0a <consoleintr+0x118>
    80005b20:	47c1                	li	a5,16
    80005b22:	10f49a63          	bne	s1,a5,80005c36 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80005b26:	ffffc097          	auipc	ra,0xffffc
    80005b2a:	f36080e7          	jalr	-202(ra) # 80001a5c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80005b2e:	00120517          	auipc	a0,0x120
    80005b32:	61250513          	addi	a0,a0,1554 # 80126140 <cons>
    80005b36:	00001097          	auipc	ra,0x1
    80005b3a:	83a080e7          	jalr	-1990(ra) # 80006370 <release>
}
    80005b3e:	60e2                	ld	ra,24(sp)
    80005b40:	6442                	ld	s0,16(sp)
    80005b42:	64a2                	ld	s1,8(sp)
    80005b44:	6902                	ld	s2,0(sp)
    80005b46:	6105                	addi	sp,sp,32
    80005b48:	8082                	ret
  switch(c){
    80005b4a:	07f00793          	li	a5,127
    80005b4e:	0af48e63          	beq	s1,a5,80005c0a <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80005b52:	00120717          	auipc	a4,0x120
    80005b56:	5ee70713          	addi	a4,a4,1518 # 80126140 <cons>
    80005b5a:	0a072783          	lw	a5,160(a4)
    80005b5e:	09872703          	lw	a4,152(a4)
    80005b62:	9f99                	subw	a5,a5,a4
    80005b64:	07f00713          	li	a4,127
    80005b68:	fcf763e3          	bltu	a4,a5,80005b2e <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80005b6c:	47b5                	li	a5,13
    80005b6e:	0cf48763          	beq	s1,a5,80005c3c <consoleintr+0x14a>
      consputc(c);
    80005b72:	8526                	mv	a0,s1
    80005b74:	00000097          	auipc	ra,0x0
    80005b78:	f3c080e7          	jalr	-196(ra) # 80005ab0 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80005b7c:	00120797          	auipc	a5,0x120
    80005b80:	5c478793          	addi	a5,a5,1476 # 80126140 <cons>
    80005b84:	0a07a703          	lw	a4,160(a5)
    80005b88:	0017069b          	addiw	a3,a4,1
    80005b8c:	0006861b          	sext.w	a2,a3
    80005b90:	0ad7a023          	sw	a3,160(a5)
    80005b94:	07f77713          	andi	a4,a4,127
    80005b98:	97ba                	add	a5,a5,a4
    80005b9a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80005b9e:	47a9                	li	a5,10
    80005ba0:	0cf48563          	beq	s1,a5,80005c6a <consoleintr+0x178>
    80005ba4:	4791                	li	a5,4
    80005ba6:	0cf48263          	beq	s1,a5,80005c6a <consoleintr+0x178>
    80005baa:	00120797          	auipc	a5,0x120
    80005bae:	62e7a783          	lw	a5,1582(a5) # 801261d8 <cons+0x98>
    80005bb2:	0807879b          	addiw	a5,a5,128
    80005bb6:	f6f61ce3          	bne	a2,a5,80005b2e <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80005bba:	863e                	mv	a2,a5
    80005bbc:	a07d                	j	80005c6a <consoleintr+0x178>
    while(cons.e != cons.w &&
    80005bbe:	00120717          	auipc	a4,0x120
    80005bc2:	58270713          	addi	a4,a4,1410 # 80126140 <cons>
    80005bc6:	0a072783          	lw	a5,160(a4)
    80005bca:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80005bce:	00120497          	auipc	s1,0x120
    80005bd2:	57248493          	addi	s1,s1,1394 # 80126140 <cons>
    while(cons.e != cons.w &&
    80005bd6:	4929                	li	s2,10
    80005bd8:	f4f70be3          	beq	a4,a5,80005b2e <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80005bdc:	37fd                	addiw	a5,a5,-1
    80005bde:	07f7f713          	andi	a4,a5,127
    80005be2:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005be4:	01874703          	lbu	a4,24(a4)
    80005be8:	f52703e3          	beq	a4,s2,80005b2e <consoleintr+0x3c>
      cons.e--;
    80005bec:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005bf0:	10000513          	li	a0,256
    80005bf4:	00000097          	auipc	ra,0x0
    80005bf8:	ebc080e7          	jalr	-324(ra) # 80005ab0 <consputc>
    while(cons.e != cons.w &&
    80005bfc:	0a04a783          	lw	a5,160(s1)
    80005c00:	09c4a703          	lw	a4,156(s1)
    80005c04:	fcf71ce3          	bne	a4,a5,80005bdc <consoleintr+0xea>
    80005c08:	b71d                	j	80005b2e <consoleintr+0x3c>
    if(cons.e != cons.w){
    80005c0a:	00120717          	auipc	a4,0x120
    80005c0e:	53670713          	addi	a4,a4,1334 # 80126140 <cons>
    80005c12:	0a072783          	lw	a5,160(a4)
    80005c16:	09c72703          	lw	a4,156(a4)
    80005c1a:	f0f70ae3          	beq	a4,a5,80005b2e <consoleintr+0x3c>
      cons.e--;
    80005c1e:	37fd                	addiw	a5,a5,-1
    80005c20:	00120717          	auipc	a4,0x120
    80005c24:	5cf72023          	sw	a5,1472(a4) # 801261e0 <cons+0xa0>
      consputc(BACKSPACE);
    80005c28:	10000513          	li	a0,256
    80005c2c:	00000097          	auipc	ra,0x0
    80005c30:	e84080e7          	jalr	-380(ra) # 80005ab0 <consputc>
    80005c34:	bded                	j	80005b2e <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80005c36:	ee048ce3          	beqz	s1,80005b2e <consoleintr+0x3c>
    80005c3a:	bf21                	j	80005b52 <consoleintr+0x60>
      consputc(c);
    80005c3c:	4529                	li	a0,10
    80005c3e:	00000097          	auipc	ra,0x0
    80005c42:	e72080e7          	jalr	-398(ra) # 80005ab0 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80005c46:	00120797          	auipc	a5,0x120
    80005c4a:	4fa78793          	addi	a5,a5,1274 # 80126140 <cons>
    80005c4e:	0a07a703          	lw	a4,160(a5)
    80005c52:	0017069b          	addiw	a3,a4,1
    80005c56:	0006861b          	sext.w	a2,a3
    80005c5a:	0ad7a023          	sw	a3,160(a5)
    80005c5e:	07f77713          	andi	a4,a4,127
    80005c62:	97ba                	add	a5,a5,a4
    80005c64:	4729                	li	a4,10
    80005c66:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005c6a:	00120797          	auipc	a5,0x120
    80005c6e:	56c7a923          	sw	a2,1394(a5) # 801261dc <cons+0x9c>
        wakeup(&cons.r);
    80005c72:	00120517          	auipc	a0,0x120
    80005c76:	56650513          	addi	a0,a0,1382 # 801261d8 <cons+0x98>
    80005c7a:	ffffc097          	auipc	ra,0xffffc
    80005c7e:	b1e080e7          	jalr	-1250(ra) # 80001798 <wakeup>
    80005c82:	b575                	j	80005b2e <consoleintr+0x3c>

0000000080005c84 <consoleinit>:

void
consoleinit(void)
{
    80005c84:	1141                	addi	sp,sp,-16
    80005c86:	e406                	sd	ra,8(sp)
    80005c88:	e022                	sd	s0,0(sp)
    80005c8a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005c8c:	00003597          	auipc	a1,0x3
    80005c90:	b0458593          	addi	a1,a1,-1276 # 80008790 <syscalls+0x3c8>
    80005c94:	00120517          	auipc	a0,0x120
    80005c98:	4ac50513          	addi	a0,a0,1196 # 80126140 <cons>
    80005c9c:	00000097          	auipc	ra,0x0
    80005ca0:	590080e7          	jalr	1424(ra) # 8000622c <initlock>

  uartinit();
    80005ca4:	00000097          	auipc	ra,0x0
    80005ca8:	330080e7          	jalr	816(ra) # 80005fd4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005cac:	00013797          	auipc	a5,0x13
    80005cb0:	41c78793          	addi	a5,a5,1052 # 800190c8 <devsw>
    80005cb4:	00000717          	auipc	a4,0x0
    80005cb8:	ce470713          	addi	a4,a4,-796 # 80005998 <consoleread>
    80005cbc:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005cbe:	00000717          	auipc	a4,0x0
    80005cc2:	c7870713          	addi	a4,a4,-904 # 80005936 <consolewrite>
    80005cc6:	ef98                	sd	a4,24(a5)
}
    80005cc8:	60a2                	ld	ra,8(sp)
    80005cca:	6402                	ld	s0,0(sp)
    80005ccc:	0141                	addi	sp,sp,16
    80005cce:	8082                	ret

0000000080005cd0 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80005cd0:	7179                	addi	sp,sp,-48
    80005cd2:	f406                	sd	ra,40(sp)
    80005cd4:	f022                	sd	s0,32(sp)
    80005cd6:	ec26                	sd	s1,24(sp)
    80005cd8:	e84a                	sd	s2,16(sp)
    80005cda:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80005cdc:	c219                	beqz	a2,80005ce2 <printint+0x12>
    80005cde:	08054663          	bltz	a0,80005d6a <printint+0x9a>
    x = -xx;
  else
    x = xx;
    80005ce2:	2501                	sext.w	a0,a0
    80005ce4:	4881                	li	a7,0
    80005ce6:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005cea:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80005cec:	2581                	sext.w	a1,a1
    80005cee:	00003617          	auipc	a2,0x3
    80005cf2:	ad260613          	addi	a2,a2,-1326 # 800087c0 <digits>
    80005cf6:	883a                	mv	a6,a4
    80005cf8:	2705                	addiw	a4,a4,1
    80005cfa:	02b577bb          	remuw	a5,a0,a1
    80005cfe:	1782                	slli	a5,a5,0x20
    80005d00:	9381                	srli	a5,a5,0x20
    80005d02:	97b2                	add	a5,a5,a2
    80005d04:	0007c783          	lbu	a5,0(a5)
    80005d08:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80005d0c:	0005079b          	sext.w	a5,a0
    80005d10:	02b5553b          	divuw	a0,a0,a1
    80005d14:	0685                	addi	a3,a3,1
    80005d16:	feb7f0e3          	bgeu	a5,a1,80005cf6 <printint+0x26>

  if(sign)
    80005d1a:	00088b63          	beqz	a7,80005d30 <printint+0x60>
    buf[i++] = '-';
    80005d1e:	fe040793          	addi	a5,s0,-32
    80005d22:	973e                	add	a4,a4,a5
    80005d24:	02d00793          	li	a5,45
    80005d28:	fef70823          	sb	a5,-16(a4)
    80005d2c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80005d30:	02e05763          	blez	a4,80005d5e <printint+0x8e>
    80005d34:	fd040793          	addi	a5,s0,-48
    80005d38:	00e784b3          	add	s1,a5,a4
    80005d3c:	fff78913          	addi	s2,a5,-1
    80005d40:	993a                	add	s2,s2,a4
    80005d42:	377d                	addiw	a4,a4,-1
    80005d44:	1702                	slli	a4,a4,0x20
    80005d46:	9301                	srli	a4,a4,0x20
    80005d48:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80005d4c:	fff4c503          	lbu	a0,-1(s1)
    80005d50:	00000097          	auipc	ra,0x0
    80005d54:	d60080e7          	jalr	-672(ra) # 80005ab0 <consputc>
  while(--i >= 0)
    80005d58:	14fd                	addi	s1,s1,-1
    80005d5a:	ff2499e3          	bne	s1,s2,80005d4c <printint+0x7c>
}
    80005d5e:	70a2                	ld	ra,40(sp)
    80005d60:	7402                	ld	s0,32(sp)
    80005d62:	64e2                	ld	s1,24(sp)
    80005d64:	6942                	ld	s2,16(sp)
    80005d66:	6145                	addi	sp,sp,48
    80005d68:	8082                	ret
    x = -xx;
    80005d6a:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80005d6e:	4885                	li	a7,1
    x = -xx;
    80005d70:	bf9d                	j	80005ce6 <printint+0x16>

0000000080005d72 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80005d72:	1101                	addi	sp,sp,-32
    80005d74:	ec06                	sd	ra,24(sp)
    80005d76:	e822                	sd	s0,16(sp)
    80005d78:	e426                	sd	s1,8(sp)
    80005d7a:	1000                	addi	s0,sp,32
    80005d7c:	84aa                	mv	s1,a0
  pr.locking = 0;
    80005d7e:	00120797          	auipc	a5,0x120
    80005d82:	4807a123          	sw	zero,1154(a5) # 80126200 <pr+0x18>
  printf("panic: ");
    80005d86:	00003517          	auipc	a0,0x3
    80005d8a:	a1250513          	addi	a0,a0,-1518 # 80008798 <syscalls+0x3d0>
    80005d8e:	00000097          	auipc	ra,0x0
    80005d92:	02e080e7          	jalr	46(ra) # 80005dbc <printf>
  printf(s);
    80005d96:	8526                	mv	a0,s1
    80005d98:	00000097          	auipc	ra,0x0
    80005d9c:	024080e7          	jalr	36(ra) # 80005dbc <printf>
  printf("\n");
    80005da0:	00002517          	auipc	a0,0x2
    80005da4:	2a850513          	addi	a0,a0,680 # 80008048 <etext+0x48>
    80005da8:	00000097          	auipc	ra,0x0
    80005dac:	014080e7          	jalr	20(ra) # 80005dbc <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005db0:	4785                	li	a5,1
    80005db2:	00003717          	auipc	a4,0x3
    80005db6:	26f72523          	sw	a5,618(a4) # 8000901c <panicked>
  for(;;)
    80005dba:	a001                	j	80005dba <panic+0x48>

0000000080005dbc <printf>:
{
    80005dbc:	7131                	addi	sp,sp,-192
    80005dbe:	fc86                	sd	ra,120(sp)
    80005dc0:	f8a2                	sd	s0,112(sp)
    80005dc2:	f4a6                	sd	s1,104(sp)
    80005dc4:	f0ca                	sd	s2,96(sp)
    80005dc6:	ecce                	sd	s3,88(sp)
    80005dc8:	e8d2                	sd	s4,80(sp)
    80005dca:	e4d6                	sd	s5,72(sp)
    80005dcc:	e0da                	sd	s6,64(sp)
    80005dce:	fc5e                	sd	s7,56(sp)
    80005dd0:	f862                	sd	s8,48(sp)
    80005dd2:	f466                	sd	s9,40(sp)
    80005dd4:	f06a                	sd	s10,32(sp)
    80005dd6:	ec6e                	sd	s11,24(sp)
    80005dd8:	0100                	addi	s0,sp,128
    80005dda:	8a2a                	mv	s4,a0
    80005ddc:	e40c                	sd	a1,8(s0)
    80005dde:	e810                	sd	a2,16(s0)
    80005de0:	ec14                	sd	a3,24(s0)
    80005de2:	f018                	sd	a4,32(s0)
    80005de4:	f41c                	sd	a5,40(s0)
    80005de6:	03043823          	sd	a6,48(s0)
    80005dea:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80005dee:	00120d97          	auipc	s11,0x120
    80005df2:	412dad83          	lw	s11,1042(s11) # 80126200 <pr+0x18>
  if(locking)
    80005df6:	020d9b63          	bnez	s11,80005e2c <printf+0x70>
  if (fmt == 0)
    80005dfa:	040a0263          	beqz	s4,80005e3e <printf+0x82>
  va_start(ap, fmt);
    80005dfe:	00840793          	addi	a5,s0,8
    80005e02:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005e06:	000a4503          	lbu	a0,0(s4)
    80005e0a:	16050263          	beqz	a0,80005f6e <printf+0x1b2>
    80005e0e:	4481                	li	s1,0
    if(c != '%'){
    80005e10:	02500a93          	li	s5,37
    switch(c){
    80005e14:	07000b13          	li	s6,112
  consputc('x');
    80005e18:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005e1a:	00003b97          	auipc	s7,0x3
    80005e1e:	9a6b8b93          	addi	s7,s7,-1626 # 800087c0 <digits>
    switch(c){
    80005e22:	07300c93          	li	s9,115
    80005e26:	06400c13          	li	s8,100
    80005e2a:	a82d                	j	80005e64 <printf+0xa8>
    acquire(&pr.lock);
    80005e2c:	00120517          	auipc	a0,0x120
    80005e30:	3bc50513          	addi	a0,a0,956 # 801261e8 <pr>
    80005e34:	00000097          	auipc	ra,0x0
    80005e38:	488080e7          	jalr	1160(ra) # 800062bc <acquire>
    80005e3c:	bf7d                	j	80005dfa <printf+0x3e>
    panic("null fmt");
    80005e3e:	00003517          	auipc	a0,0x3
    80005e42:	96a50513          	addi	a0,a0,-1686 # 800087a8 <syscalls+0x3e0>
    80005e46:	00000097          	auipc	ra,0x0
    80005e4a:	f2c080e7          	jalr	-212(ra) # 80005d72 <panic>
      consputc(c);
    80005e4e:	00000097          	auipc	ra,0x0
    80005e52:	c62080e7          	jalr	-926(ra) # 80005ab0 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005e56:	2485                	addiw	s1,s1,1
    80005e58:	009a07b3          	add	a5,s4,s1
    80005e5c:	0007c503          	lbu	a0,0(a5)
    80005e60:	10050763          	beqz	a0,80005f6e <printf+0x1b2>
    if(c != '%'){
    80005e64:	ff5515e3          	bne	a0,s5,80005e4e <printf+0x92>
    c = fmt[++i] & 0xff;
    80005e68:	2485                	addiw	s1,s1,1
    80005e6a:	009a07b3          	add	a5,s4,s1
    80005e6e:	0007c783          	lbu	a5,0(a5)
    80005e72:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80005e76:	cfe5                	beqz	a5,80005f6e <printf+0x1b2>
    switch(c){
    80005e78:	05678a63          	beq	a5,s6,80005ecc <printf+0x110>
    80005e7c:	02fb7663          	bgeu	s6,a5,80005ea8 <printf+0xec>
    80005e80:	09978963          	beq	a5,s9,80005f12 <printf+0x156>
    80005e84:	07800713          	li	a4,120
    80005e88:	0ce79863          	bne	a5,a4,80005f58 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80005e8c:	f8843783          	ld	a5,-120(s0)
    80005e90:	00878713          	addi	a4,a5,8
    80005e94:	f8e43423          	sd	a4,-120(s0)
    80005e98:	4605                	li	a2,1
    80005e9a:	85ea                	mv	a1,s10
    80005e9c:	4388                	lw	a0,0(a5)
    80005e9e:	00000097          	auipc	ra,0x0
    80005ea2:	e32080e7          	jalr	-462(ra) # 80005cd0 <printint>
      break;
    80005ea6:	bf45                	j	80005e56 <printf+0x9a>
    switch(c){
    80005ea8:	0b578263          	beq	a5,s5,80005f4c <printf+0x190>
    80005eac:	0b879663          	bne	a5,s8,80005f58 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80005eb0:	f8843783          	ld	a5,-120(s0)
    80005eb4:	00878713          	addi	a4,a5,8
    80005eb8:	f8e43423          	sd	a4,-120(s0)
    80005ebc:	4605                	li	a2,1
    80005ebe:	45a9                	li	a1,10
    80005ec0:	4388                	lw	a0,0(a5)
    80005ec2:	00000097          	auipc	ra,0x0
    80005ec6:	e0e080e7          	jalr	-498(ra) # 80005cd0 <printint>
      break;
    80005eca:	b771                	j	80005e56 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80005ecc:	f8843783          	ld	a5,-120(s0)
    80005ed0:	00878713          	addi	a4,a5,8
    80005ed4:	f8e43423          	sd	a4,-120(s0)
    80005ed8:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80005edc:	03000513          	li	a0,48
    80005ee0:	00000097          	auipc	ra,0x0
    80005ee4:	bd0080e7          	jalr	-1072(ra) # 80005ab0 <consputc>
  consputc('x');
    80005ee8:	07800513          	li	a0,120
    80005eec:	00000097          	auipc	ra,0x0
    80005ef0:	bc4080e7          	jalr	-1084(ra) # 80005ab0 <consputc>
    80005ef4:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005ef6:	03c9d793          	srli	a5,s3,0x3c
    80005efa:	97de                	add	a5,a5,s7
    80005efc:	0007c503          	lbu	a0,0(a5)
    80005f00:	00000097          	auipc	ra,0x0
    80005f04:	bb0080e7          	jalr	-1104(ra) # 80005ab0 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005f08:	0992                	slli	s3,s3,0x4
    80005f0a:	397d                	addiw	s2,s2,-1
    80005f0c:	fe0915e3          	bnez	s2,80005ef6 <printf+0x13a>
    80005f10:	b799                	j	80005e56 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    80005f12:	f8843783          	ld	a5,-120(s0)
    80005f16:	00878713          	addi	a4,a5,8
    80005f1a:	f8e43423          	sd	a4,-120(s0)
    80005f1e:	0007b903          	ld	s2,0(a5)
    80005f22:	00090e63          	beqz	s2,80005f3e <printf+0x182>
      for(; *s; s++)
    80005f26:	00094503          	lbu	a0,0(s2)
    80005f2a:	d515                	beqz	a0,80005e56 <printf+0x9a>
        consputc(*s);
    80005f2c:	00000097          	auipc	ra,0x0
    80005f30:	b84080e7          	jalr	-1148(ra) # 80005ab0 <consputc>
      for(; *s; s++)
    80005f34:	0905                	addi	s2,s2,1
    80005f36:	00094503          	lbu	a0,0(s2)
    80005f3a:	f96d                	bnez	a0,80005f2c <printf+0x170>
    80005f3c:	bf29                	j	80005e56 <printf+0x9a>
        s = "(null)";
    80005f3e:	00003917          	auipc	s2,0x3
    80005f42:	86290913          	addi	s2,s2,-1950 # 800087a0 <syscalls+0x3d8>
      for(; *s; s++)
    80005f46:	02800513          	li	a0,40
    80005f4a:	b7cd                	j	80005f2c <printf+0x170>
      consputc('%');
    80005f4c:	8556                	mv	a0,s5
    80005f4e:	00000097          	auipc	ra,0x0
    80005f52:	b62080e7          	jalr	-1182(ra) # 80005ab0 <consputc>
      break;
    80005f56:	b701                	j	80005e56 <printf+0x9a>
      consputc('%');
    80005f58:	8556                	mv	a0,s5
    80005f5a:	00000097          	auipc	ra,0x0
    80005f5e:	b56080e7          	jalr	-1194(ra) # 80005ab0 <consputc>
      consputc(c);
    80005f62:	854a                	mv	a0,s2
    80005f64:	00000097          	auipc	ra,0x0
    80005f68:	b4c080e7          	jalr	-1204(ra) # 80005ab0 <consputc>
      break;
    80005f6c:	b5ed                	j	80005e56 <printf+0x9a>
  if(locking)
    80005f6e:	020d9163          	bnez	s11,80005f90 <printf+0x1d4>
}
    80005f72:	70e6                	ld	ra,120(sp)
    80005f74:	7446                	ld	s0,112(sp)
    80005f76:	74a6                	ld	s1,104(sp)
    80005f78:	7906                	ld	s2,96(sp)
    80005f7a:	69e6                	ld	s3,88(sp)
    80005f7c:	6a46                	ld	s4,80(sp)
    80005f7e:	6aa6                	ld	s5,72(sp)
    80005f80:	6b06                	ld	s6,64(sp)
    80005f82:	7be2                	ld	s7,56(sp)
    80005f84:	7c42                	ld	s8,48(sp)
    80005f86:	7ca2                	ld	s9,40(sp)
    80005f88:	7d02                	ld	s10,32(sp)
    80005f8a:	6de2                	ld	s11,24(sp)
    80005f8c:	6129                	addi	sp,sp,192
    80005f8e:	8082                	ret
    release(&pr.lock);
    80005f90:	00120517          	auipc	a0,0x120
    80005f94:	25850513          	addi	a0,a0,600 # 801261e8 <pr>
    80005f98:	00000097          	auipc	ra,0x0
    80005f9c:	3d8080e7          	jalr	984(ra) # 80006370 <release>
}
    80005fa0:	bfc9                	j	80005f72 <printf+0x1b6>

0000000080005fa2 <printfinit>:
    ;
}

void
printfinit(void)
{
    80005fa2:	1101                	addi	sp,sp,-32
    80005fa4:	ec06                	sd	ra,24(sp)
    80005fa6:	e822                	sd	s0,16(sp)
    80005fa8:	e426                	sd	s1,8(sp)
    80005faa:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005fac:	00120497          	auipc	s1,0x120
    80005fb0:	23c48493          	addi	s1,s1,572 # 801261e8 <pr>
    80005fb4:	00003597          	auipc	a1,0x3
    80005fb8:	80458593          	addi	a1,a1,-2044 # 800087b8 <syscalls+0x3f0>
    80005fbc:	8526                	mv	a0,s1
    80005fbe:	00000097          	auipc	ra,0x0
    80005fc2:	26e080e7          	jalr	622(ra) # 8000622c <initlock>
  pr.locking = 1;
    80005fc6:	4785                	li	a5,1
    80005fc8:	cc9c                	sw	a5,24(s1)
}
    80005fca:	60e2                	ld	ra,24(sp)
    80005fcc:	6442                	ld	s0,16(sp)
    80005fce:	64a2                	ld	s1,8(sp)
    80005fd0:	6105                	addi	sp,sp,32
    80005fd2:	8082                	ret

0000000080005fd4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80005fd4:	1141                	addi	sp,sp,-16
    80005fd6:	e406                	sd	ra,8(sp)
    80005fd8:	e022                	sd	s0,0(sp)
    80005fda:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005fdc:	100007b7          	lui	a5,0x10000
    80005fe0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80005fe4:	f8000713          	li	a4,-128
    80005fe8:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005fec:	470d                	li	a4,3
    80005fee:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005ff2:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005ff6:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005ffa:	469d                	li	a3,7
    80005ffc:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80006000:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80006004:	00002597          	auipc	a1,0x2
    80006008:	7d458593          	addi	a1,a1,2004 # 800087d8 <digits+0x18>
    8000600c:	00120517          	auipc	a0,0x120
    80006010:	1fc50513          	addi	a0,a0,508 # 80126208 <uart_tx_lock>
    80006014:	00000097          	auipc	ra,0x0
    80006018:	218080e7          	jalr	536(ra) # 8000622c <initlock>
}
    8000601c:	60a2                	ld	ra,8(sp)
    8000601e:	6402                	ld	s0,0(sp)
    80006020:	0141                	addi	sp,sp,16
    80006022:	8082                	ret

0000000080006024 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80006024:	1101                	addi	sp,sp,-32
    80006026:	ec06                	sd	ra,24(sp)
    80006028:	e822                	sd	s0,16(sp)
    8000602a:	e426                	sd	s1,8(sp)
    8000602c:	1000                	addi	s0,sp,32
    8000602e:	84aa                	mv	s1,a0
  push_off();
    80006030:	00000097          	auipc	ra,0x0
    80006034:	240080e7          	jalr	576(ra) # 80006270 <push_off>

  if(panicked){
    80006038:	00003797          	auipc	a5,0x3
    8000603c:	fe47a783          	lw	a5,-28(a5) # 8000901c <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80006040:	10000737          	lui	a4,0x10000
  if(panicked){
    80006044:	c391                	beqz	a5,80006048 <uartputc_sync+0x24>
    for(;;)
    80006046:	a001                	j	80006046 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80006048:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000604c:	0ff7f793          	andi	a5,a5,255
    80006050:	0207f793          	andi	a5,a5,32
    80006054:	dbf5                	beqz	a5,80006048 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80006056:	0ff4f793          	andi	a5,s1,255
    8000605a:	10000737          	lui	a4,0x10000
    8000605e:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80006062:	00000097          	auipc	ra,0x0
    80006066:	2ae080e7          	jalr	686(ra) # 80006310 <pop_off>
}
    8000606a:	60e2                	ld	ra,24(sp)
    8000606c:	6442                	ld	s0,16(sp)
    8000606e:	64a2                	ld	s1,8(sp)
    80006070:	6105                	addi	sp,sp,32
    80006072:	8082                	ret

0000000080006074 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80006074:	00003717          	auipc	a4,0x3
    80006078:	fac73703          	ld	a4,-84(a4) # 80009020 <uart_tx_r>
    8000607c:	00003797          	auipc	a5,0x3
    80006080:	fac7b783          	ld	a5,-84(a5) # 80009028 <uart_tx_w>
    80006084:	06e78c63          	beq	a5,a4,800060fc <uartstart+0x88>
{
    80006088:	7139                	addi	sp,sp,-64
    8000608a:	fc06                	sd	ra,56(sp)
    8000608c:	f822                	sd	s0,48(sp)
    8000608e:	f426                	sd	s1,40(sp)
    80006090:	f04a                	sd	s2,32(sp)
    80006092:	ec4e                	sd	s3,24(sp)
    80006094:	e852                	sd	s4,16(sp)
    80006096:	e456                	sd	s5,8(sp)
    80006098:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000609a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000609e:	00120a17          	auipc	s4,0x120
    800060a2:	16aa0a13          	addi	s4,s4,362 # 80126208 <uart_tx_lock>
    uart_tx_r += 1;
    800060a6:	00003497          	auipc	s1,0x3
    800060aa:	f7a48493          	addi	s1,s1,-134 # 80009020 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800060ae:	00003997          	auipc	s3,0x3
    800060b2:	f7a98993          	addi	s3,s3,-134 # 80009028 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800060b6:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    800060ba:	0ff7f793          	andi	a5,a5,255
    800060be:	0207f793          	andi	a5,a5,32
    800060c2:	c785                	beqz	a5,800060ea <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800060c4:	01f77793          	andi	a5,a4,31
    800060c8:	97d2                	add	a5,a5,s4
    800060ca:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    800060ce:	0705                	addi	a4,a4,1
    800060d0:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800060d2:	8526                	mv	a0,s1
    800060d4:	ffffb097          	auipc	ra,0xffffb
    800060d8:	6c4080e7          	jalr	1732(ra) # 80001798 <wakeup>
    
    WriteReg(THR, c);
    800060dc:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800060e0:	6098                	ld	a4,0(s1)
    800060e2:	0009b783          	ld	a5,0(s3)
    800060e6:	fce798e3          	bne	a5,a4,800060b6 <uartstart+0x42>
  }
}
    800060ea:	70e2                	ld	ra,56(sp)
    800060ec:	7442                	ld	s0,48(sp)
    800060ee:	74a2                	ld	s1,40(sp)
    800060f0:	7902                	ld	s2,32(sp)
    800060f2:	69e2                	ld	s3,24(sp)
    800060f4:	6a42                	ld	s4,16(sp)
    800060f6:	6aa2                	ld	s5,8(sp)
    800060f8:	6121                	addi	sp,sp,64
    800060fa:	8082                	ret
    800060fc:	8082                	ret

00000000800060fe <uartputc>:
{
    800060fe:	7179                	addi	sp,sp,-48
    80006100:	f406                	sd	ra,40(sp)
    80006102:	f022                	sd	s0,32(sp)
    80006104:	ec26                	sd	s1,24(sp)
    80006106:	e84a                	sd	s2,16(sp)
    80006108:	e44e                	sd	s3,8(sp)
    8000610a:	e052                	sd	s4,0(sp)
    8000610c:	1800                	addi	s0,sp,48
    8000610e:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    80006110:	00120517          	auipc	a0,0x120
    80006114:	0f850513          	addi	a0,a0,248 # 80126208 <uart_tx_lock>
    80006118:	00000097          	auipc	ra,0x0
    8000611c:	1a4080e7          	jalr	420(ra) # 800062bc <acquire>
  if(panicked){
    80006120:	00003797          	auipc	a5,0x3
    80006124:	efc7a783          	lw	a5,-260(a5) # 8000901c <panicked>
    80006128:	c391                	beqz	a5,8000612c <uartputc+0x2e>
    for(;;)
    8000612a:	a001                	j	8000612a <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000612c:	00003797          	auipc	a5,0x3
    80006130:	efc7b783          	ld	a5,-260(a5) # 80009028 <uart_tx_w>
    80006134:	00003717          	auipc	a4,0x3
    80006138:	eec73703          	ld	a4,-276(a4) # 80009020 <uart_tx_r>
    8000613c:	02070713          	addi	a4,a4,32
    80006140:	02f71b63          	bne	a4,a5,80006176 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    80006144:	00120a17          	auipc	s4,0x120
    80006148:	0c4a0a13          	addi	s4,s4,196 # 80126208 <uart_tx_lock>
    8000614c:	00003497          	auipc	s1,0x3
    80006150:	ed448493          	addi	s1,s1,-300 # 80009020 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80006154:	00003917          	auipc	s2,0x3
    80006158:	ed490913          	addi	s2,s2,-300 # 80009028 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000615c:	85d2                	mv	a1,s4
    8000615e:	8526                	mv	a0,s1
    80006160:	ffffb097          	auipc	ra,0xffffb
    80006164:	4ac080e7          	jalr	1196(ra) # 8000160c <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80006168:	00093783          	ld	a5,0(s2)
    8000616c:	6098                	ld	a4,0(s1)
    8000616e:	02070713          	addi	a4,a4,32
    80006172:	fef705e3          	beq	a4,a5,8000615c <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80006176:	00120497          	auipc	s1,0x120
    8000617a:	09248493          	addi	s1,s1,146 # 80126208 <uart_tx_lock>
    8000617e:	01f7f713          	andi	a4,a5,31
    80006182:	9726                	add	a4,a4,s1
    80006184:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    80006188:	0785                	addi	a5,a5,1
    8000618a:	00003717          	auipc	a4,0x3
    8000618e:	e8f73f23          	sd	a5,-354(a4) # 80009028 <uart_tx_w>
      uartstart();
    80006192:	00000097          	auipc	ra,0x0
    80006196:	ee2080e7          	jalr	-286(ra) # 80006074 <uartstart>
      release(&uart_tx_lock);
    8000619a:	8526                	mv	a0,s1
    8000619c:	00000097          	auipc	ra,0x0
    800061a0:	1d4080e7          	jalr	468(ra) # 80006370 <release>
}
    800061a4:	70a2                	ld	ra,40(sp)
    800061a6:	7402                	ld	s0,32(sp)
    800061a8:	64e2                	ld	s1,24(sp)
    800061aa:	6942                	ld	s2,16(sp)
    800061ac:	69a2                	ld	s3,8(sp)
    800061ae:	6a02                	ld	s4,0(sp)
    800061b0:	6145                	addi	sp,sp,48
    800061b2:	8082                	ret

00000000800061b4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800061b4:	1141                	addi	sp,sp,-16
    800061b6:	e422                	sd	s0,8(sp)
    800061b8:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800061ba:	100007b7          	lui	a5,0x10000
    800061be:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800061c2:	8b85                	andi	a5,a5,1
    800061c4:	cb91                	beqz	a5,800061d8 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800061c6:	100007b7          	lui	a5,0x10000
    800061ca:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800061ce:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800061d2:	6422                	ld	s0,8(sp)
    800061d4:	0141                	addi	sp,sp,16
    800061d6:	8082                	ret
    return -1;
    800061d8:	557d                	li	a0,-1
    800061da:	bfe5                	j	800061d2 <uartgetc+0x1e>

00000000800061dc <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800061dc:	1101                	addi	sp,sp,-32
    800061de:	ec06                	sd	ra,24(sp)
    800061e0:	e822                	sd	s0,16(sp)
    800061e2:	e426                	sd	s1,8(sp)
    800061e4:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800061e6:	54fd                	li	s1,-1
    int c = uartgetc();
    800061e8:	00000097          	auipc	ra,0x0
    800061ec:	fcc080e7          	jalr	-52(ra) # 800061b4 <uartgetc>
    if(c == -1)
    800061f0:	00950763          	beq	a0,s1,800061fe <uartintr+0x22>
      break;
    consoleintr(c);
    800061f4:	00000097          	auipc	ra,0x0
    800061f8:	8fe080e7          	jalr	-1794(ra) # 80005af2 <consoleintr>
  while(1){
    800061fc:	b7f5                	j	800061e8 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800061fe:	00120497          	auipc	s1,0x120
    80006202:	00a48493          	addi	s1,s1,10 # 80126208 <uart_tx_lock>
    80006206:	8526                	mv	a0,s1
    80006208:	00000097          	auipc	ra,0x0
    8000620c:	0b4080e7          	jalr	180(ra) # 800062bc <acquire>
  uartstart();
    80006210:	00000097          	auipc	ra,0x0
    80006214:	e64080e7          	jalr	-412(ra) # 80006074 <uartstart>
  release(&uart_tx_lock);
    80006218:	8526                	mv	a0,s1
    8000621a:	00000097          	auipc	ra,0x0
    8000621e:	156080e7          	jalr	342(ra) # 80006370 <release>
}
    80006222:	60e2                	ld	ra,24(sp)
    80006224:	6442                	ld	s0,16(sp)
    80006226:	64a2                	ld	s1,8(sp)
    80006228:	6105                	addi	sp,sp,32
    8000622a:	8082                	ret

000000008000622c <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    8000622c:	1141                	addi	sp,sp,-16
    8000622e:	e422                	sd	s0,8(sp)
    80006230:	0800                	addi	s0,sp,16
  lk->name = name;
    80006232:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80006234:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80006238:	00053823          	sd	zero,16(a0)
}
    8000623c:	6422                	ld	s0,8(sp)
    8000623e:	0141                	addi	sp,sp,16
    80006240:	8082                	ret

0000000080006242 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80006242:	411c                	lw	a5,0(a0)
    80006244:	e399                	bnez	a5,8000624a <holding+0x8>
    80006246:	4501                	li	a0,0
  return r;
}
    80006248:	8082                	ret
{
    8000624a:	1101                	addi	sp,sp,-32
    8000624c:	ec06                	sd	ra,24(sp)
    8000624e:	e822                	sd	s0,16(sp)
    80006250:	e426                	sd	s1,8(sp)
    80006252:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80006254:	6904                	ld	s1,16(a0)
    80006256:	ffffb097          	auipc	ra,0xffffb
    8000625a:	cde080e7          	jalr	-802(ra) # 80000f34 <mycpu>
    8000625e:	40a48533          	sub	a0,s1,a0
    80006262:	00153513          	seqz	a0,a0
}
    80006266:	60e2                	ld	ra,24(sp)
    80006268:	6442                	ld	s0,16(sp)
    8000626a:	64a2                	ld	s1,8(sp)
    8000626c:	6105                	addi	sp,sp,32
    8000626e:	8082                	ret

0000000080006270 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80006270:	1101                	addi	sp,sp,-32
    80006272:	ec06                	sd	ra,24(sp)
    80006274:	e822                	sd	s0,16(sp)
    80006276:	e426                	sd	s1,8(sp)
    80006278:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000627a:	100024f3          	csrr	s1,sstatus
    8000627e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80006282:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80006284:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80006288:	ffffb097          	auipc	ra,0xffffb
    8000628c:	cac080e7          	jalr	-852(ra) # 80000f34 <mycpu>
    80006290:	5d3c                	lw	a5,120(a0)
    80006292:	cf89                	beqz	a5,800062ac <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80006294:	ffffb097          	auipc	ra,0xffffb
    80006298:	ca0080e7          	jalr	-864(ra) # 80000f34 <mycpu>
    8000629c:	5d3c                	lw	a5,120(a0)
    8000629e:	2785                	addiw	a5,a5,1
    800062a0:	dd3c                	sw	a5,120(a0)
}
    800062a2:	60e2                	ld	ra,24(sp)
    800062a4:	6442                	ld	s0,16(sp)
    800062a6:	64a2                	ld	s1,8(sp)
    800062a8:	6105                	addi	sp,sp,32
    800062aa:	8082                	ret
    mycpu()->intena = old;
    800062ac:	ffffb097          	auipc	ra,0xffffb
    800062b0:	c88080e7          	jalr	-888(ra) # 80000f34 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800062b4:	8085                	srli	s1,s1,0x1
    800062b6:	8885                	andi	s1,s1,1
    800062b8:	dd64                	sw	s1,124(a0)
    800062ba:	bfe9                	j	80006294 <push_off+0x24>

00000000800062bc <acquire>:
{
    800062bc:	1101                	addi	sp,sp,-32
    800062be:	ec06                	sd	ra,24(sp)
    800062c0:	e822                	sd	s0,16(sp)
    800062c2:	e426                	sd	s1,8(sp)
    800062c4:	1000                	addi	s0,sp,32
    800062c6:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800062c8:	00000097          	auipc	ra,0x0
    800062cc:	fa8080e7          	jalr	-88(ra) # 80006270 <push_off>
  if(holding(lk))
    800062d0:	8526                	mv	a0,s1
    800062d2:	00000097          	auipc	ra,0x0
    800062d6:	f70080e7          	jalr	-144(ra) # 80006242 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800062da:	4705                	li	a4,1
  if(holding(lk))
    800062dc:	e115                	bnez	a0,80006300 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800062de:	87ba                	mv	a5,a4
    800062e0:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800062e4:	2781                	sext.w	a5,a5
    800062e6:	ffe5                	bnez	a5,800062de <acquire+0x22>
  __sync_synchronize();
    800062e8:	0ff0000f          	fence
  lk->cpu = mycpu();
    800062ec:	ffffb097          	auipc	ra,0xffffb
    800062f0:	c48080e7          	jalr	-952(ra) # 80000f34 <mycpu>
    800062f4:	e888                	sd	a0,16(s1)
}
    800062f6:	60e2                	ld	ra,24(sp)
    800062f8:	6442                	ld	s0,16(sp)
    800062fa:	64a2                	ld	s1,8(sp)
    800062fc:	6105                	addi	sp,sp,32
    800062fe:	8082                	ret
    panic("acquire");
    80006300:	00002517          	auipc	a0,0x2
    80006304:	4e050513          	addi	a0,a0,1248 # 800087e0 <digits+0x20>
    80006308:	00000097          	auipc	ra,0x0
    8000630c:	a6a080e7          	jalr	-1430(ra) # 80005d72 <panic>

0000000080006310 <pop_off>:

void
pop_off(void)
{
    80006310:	1141                	addi	sp,sp,-16
    80006312:	e406                	sd	ra,8(sp)
    80006314:	e022                	sd	s0,0(sp)
    80006316:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80006318:	ffffb097          	auipc	ra,0xffffb
    8000631c:	c1c080e7          	jalr	-996(ra) # 80000f34 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006320:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80006324:	8b89                	andi	a5,a5,2
  if(intr_get())
    80006326:	e78d                	bnez	a5,80006350 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80006328:	5d3c                	lw	a5,120(a0)
    8000632a:	02f05b63          	blez	a5,80006360 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    8000632e:	37fd                	addiw	a5,a5,-1
    80006330:	0007871b          	sext.w	a4,a5
    80006334:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80006336:	eb09                	bnez	a4,80006348 <pop_off+0x38>
    80006338:	5d7c                	lw	a5,124(a0)
    8000633a:	c799                	beqz	a5,80006348 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000633c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80006340:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80006344:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80006348:	60a2                	ld	ra,8(sp)
    8000634a:	6402                	ld	s0,0(sp)
    8000634c:	0141                	addi	sp,sp,16
    8000634e:	8082                	ret
    panic("pop_off - interruptible");
    80006350:	00002517          	auipc	a0,0x2
    80006354:	49850513          	addi	a0,a0,1176 # 800087e8 <digits+0x28>
    80006358:	00000097          	auipc	ra,0x0
    8000635c:	a1a080e7          	jalr	-1510(ra) # 80005d72 <panic>
    panic("pop_off");
    80006360:	00002517          	auipc	a0,0x2
    80006364:	4a050513          	addi	a0,a0,1184 # 80008800 <digits+0x40>
    80006368:	00000097          	auipc	ra,0x0
    8000636c:	a0a080e7          	jalr	-1526(ra) # 80005d72 <panic>

0000000080006370 <release>:
{
    80006370:	1101                	addi	sp,sp,-32
    80006372:	ec06                	sd	ra,24(sp)
    80006374:	e822                	sd	s0,16(sp)
    80006376:	e426                	sd	s1,8(sp)
    80006378:	1000                	addi	s0,sp,32
    8000637a:	84aa                	mv	s1,a0
  if(!holding(lk))
    8000637c:	00000097          	auipc	ra,0x0
    80006380:	ec6080e7          	jalr	-314(ra) # 80006242 <holding>
    80006384:	c115                	beqz	a0,800063a8 <release+0x38>
  lk->cpu = 0;
    80006386:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    8000638a:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    8000638e:	0f50000f          	fence	iorw,ow
    80006392:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80006396:	00000097          	auipc	ra,0x0
    8000639a:	f7a080e7          	jalr	-134(ra) # 80006310 <pop_off>
}
    8000639e:	60e2                	ld	ra,24(sp)
    800063a0:	6442                	ld	s0,16(sp)
    800063a2:	64a2                	ld	s1,8(sp)
    800063a4:	6105                	addi	sp,sp,32
    800063a6:	8082                	ret
    panic("release");
    800063a8:	00002517          	auipc	a0,0x2
    800063ac:	46050513          	addi	a0,a0,1120 # 80008808 <digits+0x48>
    800063b0:	00000097          	auipc	ra,0x0
    800063b4:	9c2080e7          	jalr	-1598(ra) # 80005d72 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
