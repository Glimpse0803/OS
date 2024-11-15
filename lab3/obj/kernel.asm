
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53660613          	addi	a2,a2,1334 # ffffffffc0211570 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	589030ef          	jal	ra,ffffffffc0203dd2 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	25258593          	addi	a1,a1,594 # ffffffffc02042a0 <etext+0x2>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	26a50513          	addi	a0,a0,618 # ffffffffc02042c0 <etext+0x22>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0fc000ef          	jal	ra,ffffffffc020015e <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	749000ef          	jal	ra,ffffffffc0200fae <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4d6000ef          	jal	ra,ffffffffc0200540 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	783010ef          	jal	ra,ffffffffc0201ff0 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	35e000ef          	jal	ra,ffffffffc02003d0 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	5fc020ef          	jal	ra,ffffffffc0202672 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	388000ef          	jal	ra,ffffffffc0200402 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	3cc000ef          	jal	ra,ffffffffc0200454 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	5bb030ef          	jal	ra,ffffffffc0203e68 <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	585030ef          	jal	ra,ffffffffc0203e68 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	a695                	j	ffffffffc0200454 <cons_putc>

ffffffffc02000f2 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f2:	1141                	addi	sp,sp,-16
ffffffffc02000f4:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f6:	392000ef          	jal	ra,ffffffffc0200488 <cons_getc>
ffffffffc02000fa:	dd75                	beqz	a0,ffffffffc02000f6 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fc:	60a2                	ld	ra,8(sp)
ffffffffc02000fe:	0141                	addi	sp,sp,16
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200102:	00011317          	auipc	t1,0x11
ffffffffc0200106:	3f630313          	addi	t1,t1,1014 # ffffffffc02114f8 <is_panic>
ffffffffc020010a:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020010e:	715d                	addi	sp,sp,-80
ffffffffc0200110:	ec06                	sd	ra,24(sp)
ffffffffc0200112:	e822                	sd	s0,16(sp)
ffffffffc0200114:	f436                	sd	a3,40(sp)
ffffffffc0200116:	f83a                	sd	a4,48(sp)
ffffffffc0200118:	fc3e                	sd	a5,56(sp)
ffffffffc020011a:	e0c2                	sd	a6,64(sp)
ffffffffc020011c:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020011e:	020e1a63          	bnez	t3,ffffffffc0200152 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200122:	4785                	li	a5,1
ffffffffc0200124:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200128:	8432                	mv	s0,a2
ffffffffc020012a:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020012c:	862e                	mv	a2,a1
ffffffffc020012e:	85aa                	mv	a1,a0
ffffffffc0200130:	00004517          	auipc	a0,0x4
ffffffffc0200134:	19850513          	addi	a0,a0,408 # ffffffffc02042c8 <etext+0x2a>
    va_start(ap, fmt);
ffffffffc0200138:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020013a:	f81ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc020013e:	65a2                	ld	a1,8(sp)
ffffffffc0200140:	8522                	mv	a0,s0
ffffffffc0200142:	f59ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc0200146:	00005517          	auipc	a0,0x5
ffffffffc020014a:	f3250513          	addi	a0,a0,-206 # ffffffffc0205078 <commands+0xb60>
ffffffffc020014e:	f6dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200152:	378000ef          	jal	ra,ffffffffc02004ca <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200156:	4501                	li	a0,0
ffffffffc0200158:	130000ef          	jal	ra,ffffffffc0200288 <kmonitor>
    while (1) {
ffffffffc020015c:	bfed                	j	ffffffffc0200156 <__panic+0x54>

ffffffffc020015e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020015e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200160:	00004517          	auipc	a0,0x4
ffffffffc0200164:	18850513          	addi	a0,a0,392 # ffffffffc02042e8 <etext+0x4a>
void print_kerninfo(void) {
ffffffffc0200168:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	f51ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020016e:	00000597          	auipc	a1,0x0
ffffffffc0200172:	ec458593          	addi	a1,a1,-316 # ffffffffc0200032 <kern_init>
ffffffffc0200176:	00004517          	auipc	a0,0x4
ffffffffc020017a:	19250513          	addi	a0,a0,402 # ffffffffc0204308 <etext+0x6a>
ffffffffc020017e:	f3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200182:	00004597          	auipc	a1,0x4
ffffffffc0200186:	11c58593          	addi	a1,a1,284 # ffffffffc020429e <etext>
ffffffffc020018a:	00004517          	auipc	a0,0x4
ffffffffc020018e:	19e50513          	addi	a0,a0,414 # ffffffffc0204328 <etext+0x8a>
ffffffffc0200192:	f29ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200196:	0000a597          	auipc	a1,0xa
ffffffffc020019a:	eaa58593          	addi	a1,a1,-342 # ffffffffc020a040 <ide>
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	1aa50513          	addi	a0,a0,426 # ffffffffc0204348 <etext+0xaa>
ffffffffc02001a6:	f15ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001aa:	00011597          	auipc	a1,0x11
ffffffffc02001ae:	3c658593          	addi	a1,a1,966 # ffffffffc0211570 <end>
ffffffffc02001b2:	00004517          	auipc	a0,0x4
ffffffffc02001b6:	1b650513          	addi	a0,a0,438 # ffffffffc0204368 <etext+0xca>
ffffffffc02001ba:	f01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001be:	00011597          	auipc	a1,0x11
ffffffffc02001c2:	7b158593          	addi	a1,a1,1969 # ffffffffc021196f <end+0x3ff>
ffffffffc02001c6:	00000797          	auipc	a5,0x0
ffffffffc02001ca:	e6c78793          	addi	a5,a5,-404 # ffffffffc0200032 <kern_init>
ffffffffc02001ce:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001d6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001dc:	95be                	add	a1,a1,a5
ffffffffc02001de:	85a9                	srai	a1,a1,0xa
ffffffffc02001e0:	00004517          	auipc	a0,0x4
ffffffffc02001e4:	1a850513          	addi	a0,a0,424 # ffffffffc0204388 <etext+0xea>
}
ffffffffc02001e8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ea:	bdc1                	j	ffffffffc02000ba <cprintf>

ffffffffc02001ec <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ec:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	1ca60613          	addi	a2,a2,458 # ffffffffc02043b8 <etext+0x11a>
ffffffffc02001f6:	04e00593          	li	a1,78
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	1d650513          	addi	a0,a0,470 # ffffffffc02043d0 <etext+0x132>
void print_stackframe(void) {
ffffffffc0200202:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200204:	effff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200208 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020020a:	00004617          	auipc	a2,0x4
ffffffffc020020e:	1de60613          	addi	a2,a2,478 # ffffffffc02043e8 <etext+0x14a>
ffffffffc0200212:	00004597          	auipc	a1,0x4
ffffffffc0200216:	1f658593          	addi	a1,a1,502 # ffffffffc0204408 <etext+0x16a>
ffffffffc020021a:	00004517          	auipc	a0,0x4
ffffffffc020021e:	1f650513          	addi	a0,a0,502 # ffffffffc0204410 <etext+0x172>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200224:	e97ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200228:	00004617          	auipc	a2,0x4
ffffffffc020022c:	1f860613          	addi	a2,a2,504 # ffffffffc0204420 <etext+0x182>
ffffffffc0200230:	00004597          	auipc	a1,0x4
ffffffffc0200234:	21858593          	addi	a1,a1,536 # ffffffffc0204448 <etext+0x1aa>
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	1d850513          	addi	a0,a0,472 # ffffffffc0204410 <etext+0x172>
ffffffffc0200240:	e7bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200244:	00004617          	auipc	a2,0x4
ffffffffc0200248:	21460613          	addi	a2,a2,532 # ffffffffc0204458 <etext+0x1ba>
ffffffffc020024c:	00004597          	auipc	a1,0x4
ffffffffc0200250:	22c58593          	addi	a1,a1,556 # ffffffffc0204478 <etext+0x1da>
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	1bc50513          	addi	a0,a0,444 # ffffffffc0204410 <etext+0x172>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200260:	60a2                	ld	ra,8(sp)
ffffffffc0200262:	4501                	li	a0,0
ffffffffc0200264:	0141                	addi	sp,sp,16
ffffffffc0200266:	8082                	ret

ffffffffc0200268 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200268:	1141                	addi	sp,sp,-16
ffffffffc020026a:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020026c:	ef3ff0ef          	jal	ra,ffffffffc020015e <print_kerninfo>
    return 0;
}
ffffffffc0200270:	60a2                	ld	ra,8(sp)
ffffffffc0200272:	4501                	li	a0,0
ffffffffc0200274:	0141                	addi	sp,sp,16
ffffffffc0200276:	8082                	ret

ffffffffc0200278 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200278:	1141                	addi	sp,sp,-16
ffffffffc020027a:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020027c:	f71ff0ef          	jal	ra,ffffffffc02001ec <print_stackframe>
    return 0;
}
ffffffffc0200280:	60a2                	ld	ra,8(sp)
ffffffffc0200282:	4501                	li	a0,0
ffffffffc0200284:	0141                	addi	sp,sp,16
ffffffffc0200286:	8082                	ret

ffffffffc0200288 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200288:	7115                	addi	sp,sp,-224
ffffffffc020028a:	ed5e                	sd	s7,152(sp)
ffffffffc020028c:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	00004517          	auipc	a0,0x4
ffffffffc0200292:	1fa50513          	addi	a0,a0,506 # ffffffffc0204488 <etext+0x1ea>
kmonitor(struct trapframe *tf) {
ffffffffc0200296:	ed86                	sd	ra,216(sp)
ffffffffc0200298:	e9a2                	sd	s0,208(sp)
ffffffffc020029a:	e5a6                	sd	s1,200(sp)
ffffffffc020029c:	e1ca                	sd	s2,192(sp)
ffffffffc020029e:	fd4e                	sd	s3,184(sp)
ffffffffc02002a0:	f952                	sd	s4,176(sp)
ffffffffc02002a2:	f556                	sd	s5,168(sp)
ffffffffc02002a4:	f15a                	sd	s6,160(sp)
ffffffffc02002a6:	e962                	sd	s8,144(sp)
ffffffffc02002a8:	e566                	sd	s9,136(sp)
ffffffffc02002aa:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ac:	e0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002b0:	00004517          	auipc	a0,0x4
ffffffffc02002b4:	20050513          	addi	a0,a0,512 # ffffffffc02044b0 <etext+0x212>
ffffffffc02002b8:	e03ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002bc:	000b8563          	beqz	s7,ffffffffc02002c6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002c0:	855e                	mv	a0,s7
ffffffffc02002c2:	468000ef          	jal	ra,ffffffffc020072a <print_trapframe>
ffffffffc02002c6:	00004c17          	auipc	s8,0x4
ffffffffc02002ca:	252c0c13          	addi	s8,s8,594 # ffffffffc0204518 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002ce:	00005917          	auipc	s2,0x5
ffffffffc02002d2:	5b290913          	addi	s2,s2,1458 # ffffffffc0205880 <commands+0x1368>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d6:	00004497          	auipc	s1,0x4
ffffffffc02002da:	20248493          	addi	s1,s1,514 # ffffffffc02044d8 <etext+0x23a>
        if (argc == MAXARGS - 1) {
ffffffffc02002de:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002e0:	00004b17          	auipc	s6,0x4
ffffffffc02002e4:	200b0b13          	addi	s6,s6,512 # ffffffffc02044e0 <etext+0x242>
        argv[argc ++] = buf;
ffffffffc02002e8:	00004a17          	auipc	s4,0x4
ffffffffc02002ec:	120a0a13          	addi	s4,s4,288 # ffffffffc0204408 <etext+0x16a>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002f2:	854a                	mv	a0,s2
ffffffffc02002f4:	6f7030ef          	jal	ra,ffffffffc02041ea <readline>
ffffffffc02002f8:	842a                	mv	s0,a0
ffffffffc02002fa:	dd65                	beqz	a0,ffffffffc02002f2 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002fc:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200300:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200302:	e1bd                	bnez	a1,ffffffffc0200368 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200304:	fe0c87e3          	beqz	s9,ffffffffc02002f2 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	6582                	ld	a1,0(sp)
ffffffffc020030a:	00004d17          	auipc	s10,0x4
ffffffffc020030e:	20ed0d13          	addi	s10,s10,526 # ffffffffc0204518 <commands>
        argv[argc ++] = buf;
ffffffffc0200312:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200314:	4401                	li	s0,0
ffffffffc0200316:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	287030ef          	jal	ra,ffffffffc0203d9e <strcmp>
ffffffffc020031c:	c919                	beqz	a0,ffffffffc0200332 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020031e:	2405                	addiw	s0,s0,1
ffffffffc0200320:	0b540063          	beq	s0,s5,ffffffffc02003c0 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	000d3503          	ld	a0,0(s10)
ffffffffc0200328:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020032a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020032c:	273030ef          	jal	ra,ffffffffc0203d9e <strcmp>
ffffffffc0200330:	f57d                	bnez	a0,ffffffffc020031e <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200332:	00141793          	slli	a5,s0,0x1
ffffffffc0200336:	97a2                	add	a5,a5,s0
ffffffffc0200338:	078e                	slli	a5,a5,0x3
ffffffffc020033a:	97e2                	add	a5,a5,s8
ffffffffc020033c:	6b9c                	ld	a5,16(a5)
ffffffffc020033e:	865e                	mv	a2,s7
ffffffffc0200340:	002c                	addi	a1,sp,8
ffffffffc0200342:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200346:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200348:	fa0555e3          	bgez	a0,ffffffffc02002f2 <kmonitor+0x6a>
}
ffffffffc020034c:	60ee                	ld	ra,216(sp)
ffffffffc020034e:	644e                	ld	s0,208(sp)
ffffffffc0200350:	64ae                	ld	s1,200(sp)
ffffffffc0200352:	690e                	ld	s2,192(sp)
ffffffffc0200354:	79ea                	ld	s3,184(sp)
ffffffffc0200356:	7a4a                	ld	s4,176(sp)
ffffffffc0200358:	7aaa                	ld	s5,168(sp)
ffffffffc020035a:	7b0a                	ld	s6,160(sp)
ffffffffc020035c:	6bea                	ld	s7,152(sp)
ffffffffc020035e:	6c4a                	ld	s8,144(sp)
ffffffffc0200360:	6caa                	ld	s9,136(sp)
ffffffffc0200362:	6d0a                	ld	s10,128(sp)
ffffffffc0200364:	612d                	addi	sp,sp,224
ffffffffc0200366:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200368:	8526                	mv	a0,s1
ffffffffc020036a:	253030ef          	jal	ra,ffffffffc0203dbc <strchr>
ffffffffc020036e:	c901                	beqz	a0,ffffffffc020037e <kmonitor+0xf6>
ffffffffc0200370:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200374:	00040023          	sb	zero,0(s0)
ffffffffc0200378:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020037a:	d5c9                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc020037c:	b7f5                	j	ffffffffc0200368 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020037e:	00044783          	lbu	a5,0(s0)
ffffffffc0200382:	d3c9                	beqz	a5,ffffffffc0200304 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200384:	033c8963          	beq	s9,s3,ffffffffc02003b6 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200388:	003c9793          	slli	a5,s9,0x3
ffffffffc020038c:	0118                	addi	a4,sp,128
ffffffffc020038e:	97ba                	add	a5,a5,a4
ffffffffc0200390:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200394:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200398:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039a:	e591                	bnez	a1,ffffffffc02003a6 <kmonitor+0x11e>
ffffffffc020039c:	b7b5                	j	ffffffffc0200308 <kmonitor+0x80>
ffffffffc020039e:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003a2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a4:	d1a5                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc02003a6:	8526                	mv	a0,s1
ffffffffc02003a8:	215030ef          	jal	ra,ffffffffc0203dbc <strchr>
ffffffffc02003ac:	d96d                	beqz	a0,ffffffffc020039e <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ae:	00044583          	lbu	a1,0(s0)
ffffffffc02003b2:	d9a9                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc02003b4:	bf55                	j	ffffffffc0200368 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003b6:	45c1                	li	a1,16
ffffffffc02003b8:	855a                	mv	a0,s6
ffffffffc02003ba:	d01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02003be:	b7e9                	j	ffffffffc0200388 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	00004517          	auipc	a0,0x4
ffffffffc02003c6:	13e50513          	addi	a0,a0,318 # ffffffffc0204500 <etext+0x262>
ffffffffc02003ca:	cf1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc02003ce:	b715                	j	ffffffffc02002f2 <kmonitor+0x6a>

ffffffffc02003d0 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02003d0:	8082                	ret

ffffffffc02003d2 <ide_device_valid>:
#define MAX_DISK_NSECS 56
// 定义内存数组作为模拟磁盘，SECTSIZE是每个扇区的大小，在fs.h里定义为512字节
static char ide[MAX_DISK_NSECS * SECTSIZE];

// 检查磁盘设备是否合法，看编号
bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02003d2:	00253513          	sltiu	a0,a0,2
ffffffffc02003d6:	8082                	ret

ffffffffc02003d8 <ide_device_size>:

// 获取磁盘设备大小（扇区数），ideno 是设备编号，但在这个函数中未使用，因为这里只模拟了一个磁盘。
size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02003d8:	03800513          	li	a0,56
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <ide_write_secs>:
}

// 将数据写入到模拟磁盘的指定扇区中
int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE; // 偏移
ffffffffc02003de:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02003e2:	0000a517          	auipc	a0,0xa
ffffffffc02003e6:	c5e50513          	addi	a0,a0,-930 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc02003ea:	1141                	addi	sp,sp,-16
ffffffffc02003ec:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02003ee:	953e                	add	a0,a0,a5
ffffffffc02003f0:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02003f4:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02003f6:	1ef030ef          	jal	ra,ffffffffc0203de4 <memcpy>
    return 0;
}
ffffffffc02003fa:	60a2                	ld	ra,8(sp)
ffffffffc02003fc:	4501                	li	a0,0
ffffffffc02003fe:	0141                	addi	sp,sp,16
ffffffffc0200400:	8082                	ret

ffffffffc0200402 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200402:	67e1                	lui	a5,0x18
ffffffffc0200404:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200408:	00011717          	auipc	a4,0x11
ffffffffc020040c:	10f73023          	sd	a5,256(a4) # ffffffffc0211508 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200410:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200414:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200416:	953e                	add	a0,a0,a5
ffffffffc0200418:	4601                	li	a2,0
ffffffffc020041a:	4881                	li	a7,0
ffffffffc020041c:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200420:	02000793          	li	a5,32
ffffffffc0200424:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200428:	00004517          	auipc	a0,0x4
ffffffffc020042c:	13850513          	addi	a0,a0,312 # ffffffffc0204560 <commands+0x48>
    ticks = 0;
ffffffffc0200430:	00011797          	auipc	a5,0x11
ffffffffc0200434:	0c07b823          	sd	zero,208(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b149                	j	ffffffffc02000ba <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	00011797          	auipc	a5,0x11
ffffffffc0200442:	0ca7b783          	ld	a5,202(a5) # ffffffffc0211508 <timebase>
ffffffffc0200446:	953e                	add	a0,a0,a5
ffffffffc0200448:	4581                	li	a1,0
ffffffffc020044a:	4601                	li	a2,0
ffffffffc020044c:	4881                	li	a7,0
ffffffffc020044e:	00000073          	ecall
ffffffffc0200452:	8082                	ret

ffffffffc0200454 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200454:	100027f3          	csrr	a5,sstatus
ffffffffc0200458:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020045a:	0ff57513          	zext.b	a0,a0
ffffffffc020045e:	e799                	bnez	a5,ffffffffc020046c <cons_putc+0x18>
ffffffffc0200460:	4581                	li	a1,0
ffffffffc0200462:	4601                	li	a2,0
ffffffffc0200464:	4885                	li	a7,1
ffffffffc0200466:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020046a:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020046c:	1101                	addi	sp,sp,-32
ffffffffc020046e:	ec06                	sd	ra,24(sp)
ffffffffc0200470:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200472:	058000ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc0200476:	6522                	ld	a0,8(sp)
ffffffffc0200478:	4581                	li	a1,0
ffffffffc020047a:	4601                	li	a2,0
ffffffffc020047c:	4885                	li	a7,1
ffffffffc020047e:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200482:	60e2                	ld	ra,24(sp)
ffffffffc0200484:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200486:	a83d                	j	ffffffffc02004c4 <intr_enable>

ffffffffc0200488 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200488:	100027f3          	csrr	a5,sstatus
ffffffffc020048c:	8b89                	andi	a5,a5,2
ffffffffc020048e:	eb89                	bnez	a5,ffffffffc02004a0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200490:	4501                	li	a0,0
ffffffffc0200492:	4581                	li	a1,0
ffffffffc0200494:	4601                	li	a2,0
ffffffffc0200496:	4889                	li	a7,2
ffffffffc0200498:	00000073          	ecall
ffffffffc020049c:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020049e:	8082                	ret
int cons_getc(void) {
ffffffffc02004a0:	1101                	addi	sp,sp,-32
ffffffffc02004a2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004a4:	026000ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc02004a8:	4501                	li	a0,0
ffffffffc02004aa:	4581                	li	a1,0
ffffffffc02004ac:	4601                	li	a2,0
ffffffffc02004ae:	4889                	li	a7,2
ffffffffc02004b0:	00000073          	ecall
ffffffffc02004b4:	2501                	sext.w	a0,a0
ffffffffc02004b6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004b8:	00c000ef          	jal	ra,ffffffffc02004c4 <intr_enable>
}
ffffffffc02004bc:	60e2                	ld	ra,24(sp)
ffffffffc02004be:	6522                	ld	a0,8(sp)
ffffffffc02004c0:	6105                	addi	sp,sp,32
ffffffffc02004c2:	8082                	ret

ffffffffc02004c4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004c4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004c8:	8082                	ret

ffffffffc02004ca <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ca:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004ce:	8082                	ret

ffffffffc02004d0 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004d0:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004d4:	1141                	addi	sp,sp,-16
ffffffffc02004d6:	e022                	sd	s0,0(sp)
ffffffffc02004d8:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004da:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004de:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004e2:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004e4:	05500613          	li	a2,85
ffffffffc02004e8:	c399                	beqz	a5,ffffffffc02004ee <pgfault_handler+0x1e>
ffffffffc02004ea:	04b00613          	li	a2,75
ffffffffc02004ee:	11843703          	ld	a4,280(s0)
ffffffffc02004f2:	47bd                	li	a5,15
ffffffffc02004f4:	05700693          	li	a3,87
ffffffffc02004f8:	00f70463          	beq	a4,a5,ffffffffc0200500 <pgfault_handler+0x30>
ffffffffc02004fc:	05200693          	li	a3,82
ffffffffc0200500:	00004517          	auipc	a0,0x4
ffffffffc0200504:	08050513          	addi	a0,a0,128 # ffffffffc0204580 <commands+0x68>
ffffffffc0200508:	bb3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020050c:	00011517          	auipc	a0,0x11
ffffffffc0200510:	03453503          	ld	a0,52(a0) # ffffffffc0211540 <check_mm_struct>
ffffffffc0200514:	c911                	beqz	a0,ffffffffc0200528 <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200516:	11043603          	ld	a2,272(s0)
ffffffffc020051a:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc020051e:	6402                	ld	s0,0(sp)
ffffffffc0200520:	60a2                	ld	ra,8(sp)
ffffffffc0200522:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200524:	0a40206f          	j	ffffffffc02025c8 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200528:	00004617          	auipc	a2,0x4
ffffffffc020052c:	07860613          	addi	a2,a2,120 # ffffffffc02045a0 <commands+0x88>
ffffffffc0200530:	07800593          	li	a1,120
ffffffffc0200534:	00004517          	auipc	a0,0x4
ffffffffc0200538:	08450513          	addi	a0,a0,132 # ffffffffc02045b8 <commands+0xa0>
ffffffffc020053c:	bc7ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200540 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200540:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200544:	00000797          	auipc	a5,0x0
ffffffffc0200548:	47c78793          	addi	a5,a5,1148 # ffffffffc02009c0 <__alltraps>
ffffffffc020054c:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200550:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200554:	000407b7          	lui	a5,0x40
ffffffffc0200558:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020055c:	8082                	ret

ffffffffc020055e <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020055e:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200560:	1141                	addi	sp,sp,-16
ffffffffc0200562:	e022                	sd	s0,0(sp)
ffffffffc0200564:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	06a50513          	addi	a0,a0,106 # ffffffffc02045d0 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc020056e:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200570:	b4bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200574:	640c                	ld	a1,8(s0)
ffffffffc0200576:	00004517          	auipc	a0,0x4
ffffffffc020057a:	07250513          	addi	a0,a0,114 # ffffffffc02045e8 <commands+0xd0>
ffffffffc020057e:	b3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200582:	680c                	ld	a1,16(s0)
ffffffffc0200584:	00004517          	auipc	a0,0x4
ffffffffc0200588:	07c50513          	addi	a0,a0,124 # ffffffffc0204600 <commands+0xe8>
ffffffffc020058c:	b2fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200590:	6c0c                	ld	a1,24(s0)
ffffffffc0200592:	00004517          	auipc	a0,0x4
ffffffffc0200596:	08650513          	addi	a0,a0,134 # ffffffffc0204618 <commands+0x100>
ffffffffc020059a:	b21ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc020059e:	700c                	ld	a1,32(s0)
ffffffffc02005a0:	00004517          	auipc	a0,0x4
ffffffffc02005a4:	09050513          	addi	a0,a0,144 # ffffffffc0204630 <commands+0x118>
ffffffffc02005a8:	b13ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005ac:	740c                	ld	a1,40(s0)
ffffffffc02005ae:	00004517          	auipc	a0,0x4
ffffffffc02005b2:	09a50513          	addi	a0,a0,154 # ffffffffc0204648 <commands+0x130>
ffffffffc02005b6:	b05ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ba:	780c                	ld	a1,48(s0)
ffffffffc02005bc:	00004517          	auipc	a0,0x4
ffffffffc02005c0:	0a450513          	addi	a0,a0,164 # ffffffffc0204660 <commands+0x148>
ffffffffc02005c4:	af7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005c8:	7c0c                	ld	a1,56(s0)
ffffffffc02005ca:	00004517          	auipc	a0,0x4
ffffffffc02005ce:	0ae50513          	addi	a0,a0,174 # ffffffffc0204678 <commands+0x160>
ffffffffc02005d2:	ae9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005d6:	602c                	ld	a1,64(s0)
ffffffffc02005d8:	00004517          	auipc	a0,0x4
ffffffffc02005dc:	0b850513          	addi	a0,a0,184 # ffffffffc0204690 <commands+0x178>
ffffffffc02005e0:	adbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02005e4:	642c                	ld	a1,72(s0)
ffffffffc02005e6:	00004517          	auipc	a0,0x4
ffffffffc02005ea:	0c250513          	addi	a0,a0,194 # ffffffffc02046a8 <commands+0x190>
ffffffffc02005ee:	acdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02005f2:	682c                	ld	a1,80(s0)
ffffffffc02005f4:	00004517          	auipc	a0,0x4
ffffffffc02005f8:	0cc50513          	addi	a0,a0,204 # ffffffffc02046c0 <commands+0x1a8>
ffffffffc02005fc:	abfff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200600:	6c2c                	ld	a1,88(s0)
ffffffffc0200602:	00004517          	auipc	a0,0x4
ffffffffc0200606:	0d650513          	addi	a0,a0,214 # ffffffffc02046d8 <commands+0x1c0>
ffffffffc020060a:	ab1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020060e:	702c                	ld	a1,96(s0)
ffffffffc0200610:	00004517          	auipc	a0,0x4
ffffffffc0200614:	0e050513          	addi	a0,a0,224 # ffffffffc02046f0 <commands+0x1d8>
ffffffffc0200618:	aa3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020061c:	742c                	ld	a1,104(s0)
ffffffffc020061e:	00004517          	auipc	a0,0x4
ffffffffc0200622:	0ea50513          	addi	a0,a0,234 # ffffffffc0204708 <commands+0x1f0>
ffffffffc0200626:	a95ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020062a:	782c                	ld	a1,112(s0)
ffffffffc020062c:	00004517          	auipc	a0,0x4
ffffffffc0200630:	0f450513          	addi	a0,a0,244 # ffffffffc0204720 <commands+0x208>
ffffffffc0200634:	a87ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200638:	7c2c                	ld	a1,120(s0)
ffffffffc020063a:	00004517          	auipc	a0,0x4
ffffffffc020063e:	0fe50513          	addi	a0,a0,254 # ffffffffc0204738 <commands+0x220>
ffffffffc0200642:	a79ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200646:	604c                	ld	a1,128(s0)
ffffffffc0200648:	00004517          	auipc	a0,0x4
ffffffffc020064c:	10850513          	addi	a0,a0,264 # ffffffffc0204750 <commands+0x238>
ffffffffc0200650:	a6bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200654:	644c                	ld	a1,136(s0)
ffffffffc0200656:	00004517          	auipc	a0,0x4
ffffffffc020065a:	11250513          	addi	a0,a0,274 # ffffffffc0204768 <commands+0x250>
ffffffffc020065e:	a5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200662:	684c                	ld	a1,144(s0)
ffffffffc0200664:	00004517          	auipc	a0,0x4
ffffffffc0200668:	11c50513          	addi	a0,a0,284 # ffffffffc0204780 <commands+0x268>
ffffffffc020066c:	a4fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200670:	6c4c                	ld	a1,152(s0)
ffffffffc0200672:	00004517          	auipc	a0,0x4
ffffffffc0200676:	12650513          	addi	a0,a0,294 # ffffffffc0204798 <commands+0x280>
ffffffffc020067a:	a41ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020067e:	704c                	ld	a1,160(s0)
ffffffffc0200680:	00004517          	auipc	a0,0x4
ffffffffc0200684:	13050513          	addi	a0,a0,304 # ffffffffc02047b0 <commands+0x298>
ffffffffc0200688:	a33ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020068c:	744c                	ld	a1,168(s0)
ffffffffc020068e:	00004517          	auipc	a0,0x4
ffffffffc0200692:	13a50513          	addi	a0,a0,314 # ffffffffc02047c8 <commands+0x2b0>
ffffffffc0200696:	a25ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020069a:	784c                	ld	a1,176(s0)
ffffffffc020069c:	00004517          	auipc	a0,0x4
ffffffffc02006a0:	14450513          	addi	a0,a0,324 # ffffffffc02047e0 <commands+0x2c8>
ffffffffc02006a4:	a17ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006a8:	7c4c                	ld	a1,184(s0)
ffffffffc02006aa:	00004517          	auipc	a0,0x4
ffffffffc02006ae:	14e50513          	addi	a0,a0,334 # ffffffffc02047f8 <commands+0x2e0>
ffffffffc02006b2:	a09ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006b6:	606c                	ld	a1,192(s0)
ffffffffc02006b8:	00004517          	auipc	a0,0x4
ffffffffc02006bc:	15850513          	addi	a0,a0,344 # ffffffffc0204810 <commands+0x2f8>
ffffffffc02006c0:	9fbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006c4:	646c                	ld	a1,200(s0)
ffffffffc02006c6:	00004517          	auipc	a0,0x4
ffffffffc02006ca:	16250513          	addi	a0,a0,354 # ffffffffc0204828 <commands+0x310>
ffffffffc02006ce:	9edff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006d2:	686c                	ld	a1,208(s0)
ffffffffc02006d4:	00004517          	auipc	a0,0x4
ffffffffc02006d8:	16c50513          	addi	a0,a0,364 # ffffffffc0204840 <commands+0x328>
ffffffffc02006dc:	9dfff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02006e0:	6c6c                	ld	a1,216(s0)
ffffffffc02006e2:	00004517          	auipc	a0,0x4
ffffffffc02006e6:	17650513          	addi	a0,a0,374 # ffffffffc0204858 <commands+0x340>
ffffffffc02006ea:	9d1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02006ee:	706c                	ld	a1,224(s0)
ffffffffc02006f0:	00004517          	auipc	a0,0x4
ffffffffc02006f4:	18050513          	addi	a0,a0,384 # ffffffffc0204870 <commands+0x358>
ffffffffc02006f8:	9c3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02006fc:	746c                	ld	a1,232(s0)
ffffffffc02006fe:	00004517          	auipc	a0,0x4
ffffffffc0200702:	18a50513          	addi	a0,a0,394 # ffffffffc0204888 <commands+0x370>
ffffffffc0200706:	9b5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020070a:	786c                	ld	a1,240(s0)
ffffffffc020070c:	00004517          	auipc	a0,0x4
ffffffffc0200710:	19450513          	addi	a0,a0,404 # ffffffffc02048a0 <commands+0x388>
ffffffffc0200714:	9a7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200718:	7c6c                	ld	a1,248(s0)
}
ffffffffc020071a:	6402                	ld	s0,0(sp)
ffffffffc020071c:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020071e:	00004517          	auipc	a0,0x4
ffffffffc0200722:	19a50513          	addi	a0,a0,410 # ffffffffc02048b8 <commands+0x3a0>
}
ffffffffc0200726:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200728:	ba49                	j	ffffffffc02000ba <cprintf>

ffffffffc020072a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020072a:	1141                	addi	sp,sp,-16
ffffffffc020072c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020072e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200730:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200732:	00004517          	auipc	a0,0x4
ffffffffc0200736:	19e50513          	addi	a0,a0,414 # ffffffffc02048d0 <commands+0x3b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020073a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020073c:	97fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200740:	8522                	mv	a0,s0
ffffffffc0200742:	e1dff0ef          	jal	ra,ffffffffc020055e <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200746:	10043583          	ld	a1,256(s0)
ffffffffc020074a:	00004517          	auipc	a0,0x4
ffffffffc020074e:	19e50513          	addi	a0,a0,414 # ffffffffc02048e8 <commands+0x3d0>
ffffffffc0200752:	969ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200756:	10843583          	ld	a1,264(s0)
ffffffffc020075a:	00004517          	auipc	a0,0x4
ffffffffc020075e:	1a650513          	addi	a0,a0,422 # ffffffffc0204900 <commands+0x3e8>
ffffffffc0200762:	959ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200766:	11043583          	ld	a1,272(s0)
ffffffffc020076a:	00004517          	auipc	a0,0x4
ffffffffc020076e:	1ae50513          	addi	a0,a0,430 # ffffffffc0204918 <commands+0x400>
ffffffffc0200772:	949ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200776:	11843583          	ld	a1,280(s0)
}
ffffffffc020077a:	6402                	ld	s0,0(sp)
ffffffffc020077c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	1b250513          	addi	a0,a0,434 # ffffffffc0204930 <commands+0x418>
}
ffffffffc0200786:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200788:	933ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc020078c <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020078c:	11853783          	ld	a5,280(a0)
ffffffffc0200790:	472d                	li	a4,11
ffffffffc0200792:	0786                	slli	a5,a5,0x1
ffffffffc0200794:	8385                	srli	a5,a5,0x1
ffffffffc0200796:	06f76c63          	bltu	a4,a5,ffffffffc020080e <interrupt_handler+0x82>
ffffffffc020079a:	00004717          	auipc	a4,0x4
ffffffffc020079e:	25e70713          	addi	a4,a4,606 # ffffffffc02049f8 <commands+0x4e0>
ffffffffc02007a2:	078a                	slli	a5,a5,0x2
ffffffffc02007a4:	97ba                	add	a5,a5,a4
ffffffffc02007a6:	439c                	lw	a5,0(a5)
ffffffffc02007a8:	97ba                	add	a5,a5,a4
ffffffffc02007aa:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007ac:	00004517          	auipc	a0,0x4
ffffffffc02007b0:	1fc50513          	addi	a0,a0,508 # ffffffffc02049a8 <commands+0x490>
ffffffffc02007b4:	907ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007b8:	00004517          	auipc	a0,0x4
ffffffffc02007bc:	1d050513          	addi	a0,a0,464 # ffffffffc0204988 <commands+0x470>
ffffffffc02007c0:	8fbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007c4:	00004517          	auipc	a0,0x4
ffffffffc02007c8:	18450513          	addi	a0,a0,388 # ffffffffc0204948 <commands+0x430>
ffffffffc02007cc:	8efff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	19850513          	addi	a0,a0,408 # ffffffffc0204968 <commands+0x450>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02007dc:	1141                	addi	sp,sp,-16
ffffffffc02007de:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02007e0:	c5bff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02007e4:	00011697          	auipc	a3,0x11
ffffffffc02007e8:	d1c68693          	addi	a3,a3,-740 # ffffffffc0211500 <ticks>
ffffffffc02007ec:	629c                	ld	a5,0(a3)
ffffffffc02007ee:	06400713          	li	a4,100
ffffffffc02007f2:	0785                	addi	a5,a5,1
ffffffffc02007f4:	02e7f733          	remu	a4,a5,a4
ffffffffc02007f8:	e29c                	sd	a5,0(a3)
ffffffffc02007fa:	cb19                	beqz	a4,ffffffffc0200810 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02007fc:	60a2                	ld	ra,8(sp)
ffffffffc02007fe:	0141                	addi	sp,sp,16
ffffffffc0200800:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200802:	00004517          	auipc	a0,0x4
ffffffffc0200806:	1d650513          	addi	a0,a0,470 # ffffffffc02049d8 <commands+0x4c0>
ffffffffc020080a:	8b1ff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc020080e:	bf31                	j	ffffffffc020072a <print_trapframe>
}
ffffffffc0200810:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200812:	06400593          	li	a1,100
ffffffffc0200816:	00004517          	auipc	a0,0x4
ffffffffc020081a:	1b250513          	addi	a0,a0,434 # ffffffffc02049c8 <commands+0x4b0>
}
ffffffffc020081e:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200820:	89bff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0200824 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200824:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200828:	1101                	addi	sp,sp,-32
ffffffffc020082a:	e822                	sd	s0,16(sp)
ffffffffc020082c:	ec06                	sd	ra,24(sp)
ffffffffc020082e:	e426                	sd	s1,8(sp)
ffffffffc0200830:	473d                	li	a4,15
ffffffffc0200832:	842a                	mv	s0,a0
ffffffffc0200834:	14f76a63          	bltu	a4,a5,ffffffffc0200988 <exception_handler+0x164>
ffffffffc0200838:	00004717          	auipc	a4,0x4
ffffffffc020083c:	3a870713          	addi	a4,a4,936 # ffffffffc0204be0 <commands+0x6c8>
ffffffffc0200840:	078a                	slli	a5,a5,0x2
ffffffffc0200842:	97ba                	add	a5,a5,a4
ffffffffc0200844:	439c                	lw	a5,0(a5)
ffffffffc0200846:	97ba                	add	a5,a5,a4
ffffffffc0200848:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020084a:	00004517          	auipc	a0,0x4
ffffffffc020084e:	37e50513          	addi	a0,a0,894 # ffffffffc0204bc8 <commands+0x6b0>
ffffffffc0200852:	869ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200856:	8522                	mv	a0,s0
ffffffffc0200858:	c79ff0ef          	jal	ra,ffffffffc02004d0 <pgfault_handler>
ffffffffc020085c:	84aa                	mv	s1,a0
ffffffffc020085e:	12051b63          	bnez	a0,ffffffffc0200994 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200862:	60e2                	ld	ra,24(sp)
ffffffffc0200864:	6442                	ld	s0,16(sp)
ffffffffc0200866:	64a2                	ld	s1,8(sp)
ffffffffc0200868:	6105                	addi	sp,sp,32
ffffffffc020086a:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc020086c:	00004517          	auipc	a0,0x4
ffffffffc0200870:	1bc50513          	addi	a0,a0,444 # ffffffffc0204a28 <commands+0x510>
}
ffffffffc0200874:	6442                	ld	s0,16(sp)
ffffffffc0200876:	60e2                	ld	ra,24(sp)
ffffffffc0200878:	64a2                	ld	s1,8(sp)
ffffffffc020087a:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc020087c:	83fff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc0200880:	00004517          	auipc	a0,0x4
ffffffffc0200884:	1c850513          	addi	a0,a0,456 # ffffffffc0204a48 <commands+0x530>
ffffffffc0200888:	b7f5                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc020088a:	00004517          	auipc	a0,0x4
ffffffffc020088e:	1de50513          	addi	a0,a0,478 # ffffffffc0204a68 <commands+0x550>
ffffffffc0200892:	b7cd                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200894:	00004517          	auipc	a0,0x4
ffffffffc0200898:	1ec50513          	addi	a0,a0,492 # ffffffffc0204a80 <commands+0x568>
ffffffffc020089c:	bfe1                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc020089e:	00004517          	auipc	a0,0x4
ffffffffc02008a2:	1f250513          	addi	a0,a0,498 # ffffffffc0204a90 <commands+0x578>
ffffffffc02008a6:	b7f9                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008a8:	00004517          	auipc	a0,0x4
ffffffffc02008ac:	20850513          	addi	a0,a0,520 # ffffffffc0204ab0 <commands+0x598>
ffffffffc02008b0:	80bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008b4:	8522                	mv	a0,s0
ffffffffc02008b6:	c1bff0ef          	jal	ra,ffffffffc02004d0 <pgfault_handler>
ffffffffc02008ba:	84aa                	mv	s1,a0
ffffffffc02008bc:	d15d                	beqz	a0,ffffffffc0200862 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008be:	8522                	mv	a0,s0
ffffffffc02008c0:	e6bff0ef          	jal	ra,ffffffffc020072a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008c4:	86a6                	mv	a3,s1
ffffffffc02008c6:	00004617          	auipc	a2,0x4
ffffffffc02008ca:	20260613          	addi	a2,a2,514 # ffffffffc0204ac8 <commands+0x5b0>
ffffffffc02008ce:	0ca00593          	li	a1,202
ffffffffc02008d2:	00004517          	auipc	a0,0x4
ffffffffc02008d6:	ce650513          	addi	a0,a0,-794 # ffffffffc02045b8 <commands+0xa0>
ffffffffc02008da:	829ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02008de:	00004517          	auipc	a0,0x4
ffffffffc02008e2:	20a50513          	addi	a0,a0,522 # ffffffffc0204ae8 <commands+0x5d0>
ffffffffc02008e6:	b779                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02008e8:	00004517          	auipc	a0,0x4
ffffffffc02008ec:	21850513          	addi	a0,a0,536 # ffffffffc0204b00 <commands+0x5e8>
ffffffffc02008f0:	fcaff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008f4:	8522                	mv	a0,s0
ffffffffc02008f6:	bdbff0ef          	jal	ra,ffffffffc02004d0 <pgfault_handler>
ffffffffc02008fa:	84aa                	mv	s1,a0
ffffffffc02008fc:	d13d                	beqz	a0,ffffffffc0200862 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008fe:	8522                	mv	a0,s0
ffffffffc0200900:	e2bff0ef          	jal	ra,ffffffffc020072a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200904:	86a6                	mv	a3,s1
ffffffffc0200906:	00004617          	auipc	a2,0x4
ffffffffc020090a:	1c260613          	addi	a2,a2,450 # ffffffffc0204ac8 <commands+0x5b0>
ffffffffc020090e:	0d400593          	li	a1,212
ffffffffc0200912:	00004517          	auipc	a0,0x4
ffffffffc0200916:	ca650513          	addi	a0,a0,-858 # ffffffffc02045b8 <commands+0xa0>
ffffffffc020091a:	fe8ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020091e:	00004517          	auipc	a0,0x4
ffffffffc0200922:	1fa50513          	addi	a0,a0,506 # ffffffffc0204b18 <commands+0x600>
ffffffffc0200926:	b7b9                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200928:	00004517          	auipc	a0,0x4
ffffffffc020092c:	21050513          	addi	a0,a0,528 # ffffffffc0204b38 <commands+0x620>
ffffffffc0200930:	b791                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200932:	00004517          	auipc	a0,0x4
ffffffffc0200936:	22650513          	addi	a0,a0,550 # ffffffffc0204b58 <commands+0x640>
ffffffffc020093a:	bf2d                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc020093c:	00004517          	auipc	a0,0x4
ffffffffc0200940:	23c50513          	addi	a0,a0,572 # ffffffffc0204b78 <commands+0x660>
ffffffffc0200944:	bf05                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200946:	00004517          	auipc	a0,0x4
ffffffffc020094a:	25250513          	addi	a0,a0,594 # ffffffffc0204b98 <commands+0x680>
ffffffffc020094e:	b71d                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200950:	00004517          	auipc	a0,0x4
ffffffffc0200954:	26050513          	addi	a0,a0,608 # ffffffffc0204bb0 <commands+0x698>
ffffffffc0200958:	f62ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020095c:	8522                	mv	a0,s0
ffffffffc020095e:	b73ff0ef          	jal	ra,ffffffffc02004d0 <pgfault_handler>
ffffffffc0200962:	84aa                	mv	s1,a0
ffffffffc0200964:	ee050fe3          	beqz	a0,ffffffffc0200862 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200968:	8522                	mv	a0,s0
ffffffffc020096a:	dc1ff0ef          	jal	ra,ffffffffc020072a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020096e:	86a6                	mv	a3,s1
ffffffffc0200970:	00004617          	auipc	a2,0x4
ffffffffc0200974:	15860613          	addi	a2,a2,344 # ffffffffc0204ac8 <commands+0x5b0>
ffffffffc0200978:	0ea00593          	li	a1,234
ffffffffc020097c:	00004517          	auipc	a0,0x4
ffffffffc0200980:	c3c50513          	addi	a0,a0,-964 # ffffffffc02045b8 <commands+0xa0>
ffffffffc0200984:	f7eff0ef          	jal	ra,ffffffffc0200102 <__panic>
            print_trapframe(tf);
ffffffffc0200988:	8522                	mv	a0,s0
}
ffffffffc020098a:	6442                	ld	s0,16(sp)
ffffffffc020098c:	60e2                	ld	ra,24(sp)
ffffffffc020098e:	64a2                	ld	s1,8(sp)
ffffffffc0200990:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200992:	bb61                	j	ffffffffc020072a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200994:	8522                	mv	a0,s0
ffffffffc0200996:	d95ff0ef          	jal	ra,ffffffffc020072a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020099a:	86a6                	mv	a3,s1
ffffffffc020099c:	00004617          	auipc	a2,0x4
ffffffffc02009a0:	12c60613          	addi	a2,a2,300 # ffffffffc0204ac8 <commands+0x5b0>
ffffffffc02009a4:	0f100593          	li	a1,241
ffffffffc02009a8:	00004517          	auipc	a0,0x4
ffffffffc02009ac:	c1050513          	addi	a0,a0,-1008 # ffffffffc02045b8 <commands+0xa0>
ffffffffc02009b0:	f52ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02009b4 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009b4:	11853783          	ld	a5,280(a0)
ffffffffc02009b8:	0007c363          	bltz	a5,ffffffffc02009be <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009bc:	b5a5                	j	ffffffffc0200824 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009be:	b3f9                	j	ffffffffc020078c <interrupt_handler>

ffffffffc02009c0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009c0:	14011073          	csrw	sscratch,sp
ffffffffc02009c4:	712d                	addi	sp,sp,-288
ffffffffc02009c6:	e406                	sd	ra,8(sp)
ffffffffc02009c8:	ec0e                	sd	gp,24(sp)
ffffffffc02009ca:	f012                	sd	tp,32(sp)
ffffffffc02009cc:	f416                	sd	t0,40(sp)
ffffffffc02009ce:	f81a                	sd	t1,48(sp)
ffffffffc02009d0:	fc1e                	sd	t2,56(sp)
ffffffffc02009d2:	e0a2                	sd	s0,64(sp)
ffffffffc02009d4:	e4a6                	sd	s1,72(sp)
ffffffffc02009d6:	e8aa                	sd	a0,80(sp)
ffffffffc02009d8:	ecae                	sd	a1,88(sp)
ffffffffc02009da:	f0b2                	sd	a2,96(sp)
ffffffffc02009dc:	f4b6                	sd	a3,104(sp)
ffffffffc02009de:	f8ba                	sd	a4,112(sp)
ffffffffc02009e0:	fcbe                	sd	a5,120(sp)
ffffffffc02009e2:	e142                	sd	a6,128(sp)
ffffffffc02009e4:	e546                	sd	a7,136(sp)
ffffffffc02009e6:	e94a                	sd	s2,144(sp)
ffffffffc02009e8:	ed4e                	sd	s3,152(sp)
ffffffffc02009ea:	f152                	sd	s4,160(sp)
ffffffffc02009ec:	f556                	sd	s5,168(sp)
ffffffffc02009ee:	f95a                	sd	s6,176(sp)
ffffffffc02009f0:	fd5e                	sd	s7,184(sp)
ffffffffc02009f2:	e1e2                	sd	s8,192(sp)
ffffffffc02009f4:	e5e6                	sd	s9,200(sp)
ffffffffc02009f6:	e9ea                	sd	s10,208(sp)
ffffffffc02009f8:	edee                	sd	s11,216(sp)
ffffffffc02009fa:	f1f2                	sd	t3,224(sp)
ffffffffc02009fc:	f5f6                	sd	t4,232(sp)
ffffffffc02009fe:	f9fa                	sd	t5,240(sp)
ffffffffc0200a00:	fdfe                	sd	t6,248(sp)
ffffffffc0200a02:	14002473          	csrr	s0,sscratch
ffffffffc0200a06:	100024f3          	csrr	s1,sstatus
ffffffffc0200a0a:	14102973          	csrr	s2,sepc
ffffffffc0200a0e:	143029f3          	csrr	s3,stval
ffffffffc0200a12:	14202a73          	csrr	s4,scause
ffffffffc0200a16:	e822                	sd	s0,16(sp)
ffffffffc0200a18:	e226                	sd	s1,256(sp)
ffffffffc0200a1a:	e64a                	sd	s2,264(sp)
ffffffffc0200a1c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a1e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a20:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a22:	f93ff0ef          	jal	ra,ffffffffc02009b4 <trap>

ffffffffc0200a26 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a26:	6492                	ld	s1,256(sp)
ffffffffc0200a28:	6932                	ld	s2,264(sp)
ffffffffc0200a2a:	10049073          	csrw	sstatus,s1
ffffffffc0200a2e:	14191073          	csrw	sepc,s2
ffffffffc0200a32:	60a2                	ld	ra,8(sp)
ffffffffc0200a34:	61e2                	ld	gp,24(sp)
ffffffffc0200a36:	7202                	ld	tp,32(sp)
ffffffffc0200a38:	72a2                	ld	t0,40(sp)
ffffffffc0200a3a:	7342                	ld	t1,48(sp)
ffffffffc0200a3c:	73e2                	ld	t2,56(sp)
ffffffffc0200a3e:	6406                	ld	s0,64(sp)
ffffffffc0200a40:	64a6                	ld	s1,72(sp)
ffffffffc0200a42:	6546                	ld	a0,80(sp)
ffffffffc0200a44:	65e6                	ld	a1,88(sp)
ffffffffc0200a46:	7606                	ld	a2,96(sp)
ffffffffc0200a48:	76a6                	ld	a3,104(sp)
ffffffffc0200a4a:	7746                	ld	a4,112(sp)
ffffffffc0200a4c:	77e6                	ld	a5,120(sp)
ffffffffc0200a4e:	680a                	ld	a6,128(sp)
ffffffffc0200a50:	68aa                	ld	a7,136(sp)
ffffffffc0200a52:	694a                	ld	s2,144(sp)
ffffffffc0200a54:	69ea                	ld	s3,152(sp)
ffffffffc0200a56:	7a0a                	ld	s4,160(sp)
ffffffffc0200a58:	7aaa                	ld	s5,168(sp)
ffffffffc0200a5a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a5c:	7bea                	ld	s7,184(sp)
ffffffffc0200a5e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a60:	6cae                	ld	s9,200(sp)
ffffffffc0200a62:	6d4e                	ld	s10,208(sp)
ffffffffc0200a64:	6dee                	ld	s11,216(sp)
ffffffffc0200a66:	7e0e                	ld	t3,224(sp)
ffffffffc0200a68:	7eae                	ld	t4,232(sp)
ffffffffc0200a6a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a6c:	7fee                	ld	t6,248(sp)
ffffffffc0200a6e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200a70:	10200073          	sret
	...

ffffffffc0200a80 <pa2page.part.0>:

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0200a80:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200a82:	00004617          	auipc	a2,0x4
ffffffffc0200a86:	19e60613          	addi	a2,a2,414 # ffffffffc0204c20 <commands+0x708>
ffffffffc0200a8a:	06500593          	li	a1,101
ffffffffc0200a8e:	00004517          	auipc	a0,0x4
ffffffffc0200a92:	1b250513          	addi	a0,a0,434 # ffffffffc0204c40 <commands+0x728>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0200a96:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200a98:	e6aff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200a9c <pte2page.part.0>:

static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }

static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }

static inline struct Page *pte2page(pte_t pte) {
ffffffffc0200a9c:	1141                	addi	sp,sp,-16
    if (!(pte & PTE_V)) {
        panic("pte2page called with invalid pte");
ffffffffc0200a9e:	00004617          	auipc	a2,0x4
ffffffffc0200aa2:	1b260613          	addi	a2,a2,434 # ffffffffc0204c50 <commands+0x738>
ffffffffc0200aa6:	07000593          	li	a1,112
ffffffffc0200aaa:	00004517          	auipc	a0,0x4
ffffffffc0200aae:	19650513          	addi	a0,a0,406 # ffffffffc0204c40 <commands+0x728>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0200ab2:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0200ab4:	e4eff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200ab8 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200ab8:	7139                	addi	sp,sp,-64
ffffffffc0200aba:	f426                	sd	s1,40(sp)
ffffffffc0200abc:	f04a                	sd	s2,32(sp)
ffffffffc0200abe:	ec4e                	sd	s3,24(sp)
ffffffffc0200ac0:	e852                	sd	s4,16(sp)
ffffffffc0200ac2:	e456                	sd	s5,8(sp)
ffffffffc0200ac4:	e05a                	sd	s6,0(sp)
ffffffffc0200ac6:	fc06                	sd	ra,56(sp)
ffffffffc0200ac8:	f822                	sd	s0,48(sp)
ffffffffc0200aca:	84aa                	mv	s1,a0
ffffffffc0200acc:	00011917          	auipc	s2,0x11
ffffffffc0200ad0:	a6490913          	addi	s2,s2,-1436 # ffffffffc0211530 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200ad4:	4a05                	li	s4,1
ffffffffc0200ad6:	00011a97          	auipc	s5,0x11
ffffffffc0200ada:	a8aa8a93          	addi	s5,s5,-1398 # ffffffffc0211560 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ade:	0005099b          	sext.w	s3,a0
ffffffffc0200ae2:	00011b17          	auipc	s6,0x11
ffffffffc0200ae6:	a5eb0b13          	addi	s6,s6,-1442 # ffffffffc0211540 <check_mm_struct>
ffffffffc0200aea:	a01d                	j	ffffffffc0200b10 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0200aec:	00093783          	ld	a5,0(s2)
ffffffffc0200af0:	6f9c                	ld	a5,24(a5)
ffffffffc0200af2:	9782                	jalr	a5
ffffffffc0200af4:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0200af6:	4601                	li	a2,0
ffffffffc0200af8:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200afa:	ec0d                	bnez	s0,ffffffffc0200b34 <alloc_pages+0x7c>
ffffffffc0200afc:	029a6c63          	bltu	s4,s1,ffffffffc0200b34 <alloc_pages+0x7c>
ffffffffc0200b00:	000aa783          	lw	a5,0(s5)
ffffffffc0200b04:	2781                	sext.w	a5,a5
ffffffffc0200b06:	c79d                	beqz	a5,ffffffffc0200b34 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b08:	000b3503          	ld	a0,0(s6)
ffffffffc0200b0c:	1e8020ef          	jal	ra,ffffffffc0202cf4 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b10:	100027f3          	csrr	a5,sstatus
ffffffffc0200b14:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0200b16:	8526                	mv	a0,s1
ffffffffc0200b18:	dbf1                	beqz	a5,ffffffffc0200aec <alloc_pages+0x34>
        intr_disable();
ffffffffc0200b1a:	9b1ff0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc0200b1e:	00093783          	ld	a5,0(s2)
ffffffffc0200b22:	8526                	mv	a0,s1
ffffffffc0200b24:	6f9c                	ld	a5,24(a5)
ffffffffc0200b26:	9782                	jalr	a5
ffffffffc0200b28:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200b2a:	99bff0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b2e:	4601                	li	a2,0
ffffffffc0200b30:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b32:	d469                	beqz	s0,ffffffffc0200afc <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200b34:	70e2                	ld	ra,56(sp)
ffffffffc0200b36:	8522                	mv	a0,s0
ffffffffc0200b38:	7442                	ld	s0,48(sp)
ffffffffc0200b3a:	74a2                	ld	s1,40(sp)
ffffffffc0200b3c:	7902                	ld	s2,32(sp)
ffffffffc0200b3e:	69e2                	ld	s3,24(sp)
ffffffffc0200b40:	6a42                	ld	s4,16(sp)
ffffffffc0200b42:	6aa2                	ld	s5,8(sp)
ffffffffc0200b44:	6b02                	ld	s6,0(sp)
ffffffffc0200b46:	6121                	addi	sp,sp,64
ffffffffc0200b48:	8082                	ret

ffffffffc0200b4a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b4a:	100027f3          	csrr	a5,sstatus
ffffffffc0200b4e:	8b89                	andi	a5,a5,2
ffffffffc0200b50:	e799                	bnez	a5,ffffffffc0200b5e <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0200b52:	00011797          	auipc	a5,0x11
ffffffffc0200b56:	9de7b783          	ld	a5,-1570(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200b5a:	739c                	ld	a5,32(a5)
ffffffffc0200b5c:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200b5e:	1101                	addi	sp,sp,-32
ffffffffc0200b60:	ec06                	sd	ra,24(sp)
ffffffffc0200b62:	e822                	sd	s0,16(sp)
ffffffffc0200b64:	e426                	sd	s1,8(sp)
ffffffffc0200b66:	842a                	mv	s0,a0
ffffffffc0200b68:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200b6a:	961ff0ef          	jal	ra,ffffffffc02004ca <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0200b6e:	00011797          	auipc	a5,0x11
ffffffffc0200b72:	9c27b783          	ld	a5,-1598(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200b76:	739c                	ld	a5,32(a5)
ffffffffc0200b78:	85a6                	mv	a1,s1
ffffffffc0200b7a:	8522                	mv	a0,s0
ffffffffc0200b7c:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0200b7e:	6442                	ld	s0,16(sp)
ffffffffc0200b80:	60e2                	ld	ra,24(sp)
ffffffffc0200b82:	64a2                	ld	s1,8(sp)
ffffffffc0200b84:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200b86:	93fff06f          	j	ffffffffc02004c4 <intr_enable>

ffffffffc0200b8a <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b8a:	100027f3          	csrr	a5,sstatus
ffffffffc0200b8e:	8b89                	andi	a5,a5,2
ffffffffc0200b90:	e799                	bnez	a5,ffffffffc0200b9e <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0200b92:	00011797          	auipc	a5,0x11
ffffffffc0200b96:	99e7b783          	ld	a5,-1634(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200b9a:	779c                	ld	a5,40(a5)
ffffffffc0200b9c:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200b9e:	1141                	addi	sp,sp,-16
ffffffffc0200ba0:	e406                	sd	ra,8(sp)
ffffffffc0200ba2:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200ba4:	927ff0ef          	jal	ra,ffffffffc02004ca <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0200ba8:	00011797          	auipc	a5,0x11
ffffffffc0200bac:	9887b783          	ld	a5,-1656(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200bb0:	779c                	ld	a5,40(a5)
ffffffffc0200bb2:	9782                	jalr	a5
ffffffffc0200bb4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200bb6:	90fff0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200bba:	60a2                	ld	ra,8(sp)
ffffffffc0200bbc:	8522                	mv	a0,s0
ffffffffc0200bbe:	6402                	ld	s0,0(sp)
ffffffffc0200bc0:	0141                	addi	sp,sp,16
ffffffffc0200bc2:	8082                	ret

ffffffffc0200bc4 <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200bc4:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0200bc8:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200bcc:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200bce:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200bd0:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200bd2:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200bd6:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200bd8:	f84a                	sd	s2,48(sp)
ffffffffc0200bda:	f44e                	sd	s3,40(sp)
ffffffffc0200bdc:	f052                	sd	s4,32(sp)
ffffffffc0200bde:	e486                	sd	ra,72(sp)
ffffffffc0200be0:	e0a2                	sd	s0,64(sp)
ffffffffc0200be2:	ec56                	sd	s5,24(sp)
ffffffffc0200be4:	e85a                	sd	s6,16(sp)
ffffffffc0200be6:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200be8:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200bec:	892e                	mv	s2,a1
ffffffffc0200bee:	8a32                	mv	s4,a2
ffffffffc0200bf0:	00011997          	auipc	s3,0x11
ffffffffc0200bf4:	93098993          	addi	s3,s3,-1744 # ffffffffc0211520 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200bf8:	efb5                	bnez	a5,ffffffffc0200c74 <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200bfa:	14060c63          	beqz	a2,ffffffffc0200d52 <get_pte+0x18e>
ffffffffc0200bfe:	4505                	li	a0,1
ffffffffc0200c00:	eb9ff0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0200c04:	842a                	mv	s0,a0
ffffffffc0200c06:	14050663          	beqz	a0,ffffffffc0200d52 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c0a:	00011b97          	auipc	s7,0x11
ffffffffc0200c0e:	91eb8b93          	addi	s7,s7,-1762 # ffffffffc0211528 <pages>
ffffffffc0200c12:	000bb503          	ld	a0,0(s7)
ffffffffc0200c16:	00005b17          	auipc	s6,0x5
ffffffffc0200c1a:	422b3b03          	ld	s6,1058(s6) # ffffffffc0206038 <error_string+0x38>
ffffffffc0200c1e:	00080ab7          	lui	s5,0x80
ffffffffc0200c22:	40a40533          	sub	a0,s0,a0
ffffffffc0200c26:	850d                	srai	a0,a0,0x3
ffffffffc0200c28:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200c2c:	00011997          	auipc	s3,0x11
ffffffffc0200c30:	8f498993          	addi	s3,s3,-1804 # ffffffffc0211520 <npage>
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200c34:	4785                	li	a5,1
ffffffffc0200c36:	0009b703          	ld	a4,0(s3)
ffffffffc0200c3a:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c3c:	9556                	add	a0,a0,s5
ffffffffc0200c3e:	00c51793          	slli	a5,a0,0xc
ffffffffc0200c42:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c44:	0532                	slli	a0,a0,0xc
ffffffffc0200c46:	14e7fd63          	bgeu	a5,a4,ffffffffc0200da0 <get_pte+0x1dc>
ffffffffc0200c4a:	00011797          	auipc	a5,0x11
ffffffffc0200c4e:	8ee7b783          	ld	a5,-1810(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0200c52:	6605                	lui	a2,0x1
ffffffffc0200c54:	4581                	li	a1,0
ffffffffc0200c56:	953e                	add	a0,a0,a5
ffffffffc0200c58:	17a030ef          	jal	ra,ffffffffc0203dd2 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c5c:	000bb683          	ld	a3,0(s7)
ffffffffc0200c60:	40d406b3          	sub	a3,s0,a3
ffffffffc0200c64:	868d                	srai	a3,a3,0x3
ffffffffc0200c66:	036686b3          	mul	a3,a3,s6
ffffffffc0200c6a:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200c6c:	06aa                	slli	a3,a3,0xa
ffffffffc0200c6e:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200c72:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200c74:	77fd                	lui	a5,0xfffff
ffffffffc0200c76:	068a                	slli	a3,a3,0x2
ffffffffc0200c78:	0009b703          	ld	a4,0(s3)
ffffffffc0200c7c:	8efd                	and	a3,a3,a5
ffffffffc0200c7e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200c82:	0ce7fa63          	bgeu	a5,a4,ffffffffc0200d56 <get_pte+0x192>
ffffffffc0200c86:	00011a97          	auipc	s5,0x11
ffffffffc0200c8a:	8b2a8a93          	addi	s5,s5,-1870 # ffffffffc0211538 <va_pa_offset>
ffffffffc0200c8e:	000ab403          	ld	s0,0(s5)
ffffffffc0200c92:	01595793          	srli	a5,s2,0x15
ffffffffc0200c96:	1ff7f793          	andi	a5,a5,511
ffffffffc0200c9a:	96a2                	add	a3,a3,s0
ffffffffc0200c9c:	00379413          	slli	s0,a5,0x3
ffffffffc0200ca0:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0200ca2:	6014                	ld	a3,0(s0)
ffffffffc0200ca4:	0016f793          	andi	a5,a3,1
ffffffffc0200ca8:	ebad                	bnez	a5,ffffffffc0200d1a <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200caa:	0a0a0463          	beqz	s4,ffffffffc0200d52 <get_pte+0x18e>
ffffffffc0200cae:	4505                	li	a0,1
ffffffffc0200cb0:	e09ff0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0200cb4:	84aa                	mv	s1,a0
ffffffffc0200cb6:	cd51                	beqz	a0,ffffffffc0200d52 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cb8:	00011b97          	auipc	s7,0x11
ffffffffc0200cbc:	870b8b93          	addi	s7,s7,-1936 # ffffffffc0211528 <pages>
ffffffffc0200cc0:	000bb503          	ld	a0,0(s7)
ffffffffc0200cc4:	00005b17          	auipc	s6,0x5
ffffffffc0200cc8:	374b3b03          	ld	s6,884(s6) # ffffffffc0206038 <error_string+0x38>
ffffffffc0200ccc:	00080a37          	lui	s4,0x80
ffffffffc0200cd0:	40a48533          	sub	a0,s1,a0
ffffffffc0200cd4:	850d                	srai	a0,a0,0x3
ffffffffc0200cd6:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200cda:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200cdc:	0009b703          	ld	a4,0(s3)
ffffffffc0200ce0:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ce2:	9552                	add	a0,a0,s4
ffffffffc0200ce4:	00c51793          	slli	a5,a0,0xc
ffffffffc0200ce8:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cea:	0532                	slli	a0,a0,0xc
ffffffffc0200cec:	08e7fd63          	bgeu	a5,a4,ffffffffc0200d86 <get_pte+0x1c2>
ffffffffc0200cf0:	000ab783          	ld	a5,0(s5)
ffffffffc0200cf4:	6605                	lui	a2,0x1
ffffffffc0200cf6:	4581                	li	a1,0
ffffffffc0200cf8:	953e                	add	a0,a0,a5
ffffffffc0200cfa:	0d8030ef          	jal	ra,ffffffffc0203dd2 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cfe:	000bb683          	ld	a3,0(s7)
ffffffffc0200d02:	40d486b3          	sub	a3,s1,a3
ffffffffc0200d06:	868d                	srai	a3,a3,0x3
ffffffffc0200d08:	036686b3          	mul	a3,a3,s6
ffffffffc0200d0c:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200d0e:	06aa                	slli	a3,a3,0xa
ffffffffc0200d10:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200d14:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200d16:	0009b703          	ld	a4,0(s3)
ffffffffc0200d1a:	068a                	slli	a3,a3,0x2
ffffffffc0200d1c:	757d                	lui	a0,0xfffff
ffffffffc0200d1e:	8ee9                	and	a3,a3,a0
ffffffffc0200d20:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200d24:	04e7f563          	bgeu	a5,a4,ffffffffc0200d6e <get_pte+0x1aa>
ffffffffc0200d28:	000ab503          	ld	a0,0(s5)
ffffffffc0200d2c:	00c95913          	srli	s2,s2,0xc
ffffffffc0200d30:	1ff97913          	andi	s2,s2,511
ffffffffc0200d34:	96aa                	add	a3,a3,a0
ffffffffc0200d36:	00391513          	slli	a0,s2,0x3
ffffffffc0200d3a:	9536                	add	a0,a0,a3
}
ffffffffc0200d3c:	60a6                	ld	ra,72(sp)
ffffffffc0200d3e:	6406                	ld	s0,64(sp)
ffffffffc0200d40:	74e2                	ld	s1,56(sp)
ffffffffc0200d42:	7942                	ld	s2,48(sp)
ffffffffc0200d44:	79a2                	ld	s3,40(sp)
ffffffffc0200d46:	7a02                	ld	s4,32(sp)
ffffffffc0200d48:	6ae2                	ld	s5,24(sp)
ffffffffc0200d4a:	6b42                	ld	s6,16(sp)
ffffffffc0200d4c:	6ba2                	ld	s7,8(sp)
ffffffffc0200d4e:	6161                	addi	sp,sp,80
ffffffffc0200d50:	8082                	ret
            return NULL;
ffffffffc0200d52:	4501                	li	a0,0
ffffffffc0200d54:	b7e5                	j	ffffffffc0200d3c <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200d56:	00004617          	auipc	a2,0x4
ffffffffc0200d5a:	f2260613          	addi	a2,a2,-222 # ffffffffc0204c78 <commands+0x760>
ffffffffc0200d5e:	10200593          	li	a1,258
ffffffffc0200d62:	00004517          	auipc	a0,0x4
ffffffffc0200d66:	f3e50513          	addi	a0,a0,-194 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0200d6a:	b98ff0ef          	jal	ra,ffffffffc0200102 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200d6e:	00004617          	auipc	a2,0x4
ffffffffc0200d72:	f0a60613          	addi	a2,a2,-246 # ffffffffc0204c78 <commands+0x760>
ffffffffc0200d76:	10f00593          	li	a1,271
ffffffffc0200d7a:	00004517          	auipc	a0,0x4
ffffffffc0200d7e:	f2650513          	addi	a0,a0,-218 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0200d82:	b80ff0ef          	jal	ra,ffffffffc0200102 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200d86:	86aa                	mv	a3,a0
ffffffffc0200d88:	00004617          	auipc	a2,0x4
ffffffffc0200d8c:	ef060613          	addi	a2,a2,-272 # ffffffffc0204c78 <commands+0x760>
ffffffffc0200d90:	10b00593          	li	a1,267
ffffffffc0200d94:	00004517          	auipc	a0,0x4
ffffffffc0200d98:	f0c50513          	addi	a0,a0,-244 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0200d9c:	b66ff0ef          	jal	ra,ffffffffc0200102 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200da0:	86aa                	mv	a3,a0
ffffffffc0200da2:	00004617          	auipc	a2,0x4
ffffffffc0200da6:	ed660613          	addi	a2,a2,-298 # ffffffffc0204c78 <commands+0x760>
ffffffffc0200daa:	0ff00593          	li	a1,255
ffffffffc0200dae:	00004517          	auipc	a0,0x4
ffffffffc0200db2:	ef250513          	addi	a0,a0,-270 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0200db6:	b4cff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200dba <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200dba:	1141                	addi	sp,sp,-16
ffffffffc0200dbc:	e022                	sd	s0,0(sp)
ffffffffc0200dbe:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200dc0:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200dc2:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200dc4:	e01ff0ef          	jal	ra,ffffffffc0200bc4 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0200dc8:	c011                	beqz	s0,ffffffffc0200dcc <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0200dca:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200dcc:	c511                	beqz	a0,ffffffffc0200dd8 <get_page+0x1e>
ffffffffc0200dce:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0200dd0:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200dd2:	0017f713          	andi	a4,a5,1
ffffffffc0200dd6:	e709                	bnez	a4,ffffffffc0200de0 <get_page+0x26>
}
ffffffffc0200dd8:	60a2                	ld	ra,8(sp)
ffffffffc0200dda:	6402                	ld	s0,0(sp)
ffffffffc0200ddc:	0141                	addi	sp,sp,16
ffffffffc0200dde:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0200de0:	078a                	slli	a5,a5,0x2
ffffffffc0200de2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200de4:	00010717          	auipc	a4,0x10
ffffffffc0200de8:	73c73703          	ld	a4,1852(a4) # ffffffffc0211520 <npage>
ffffffffc0200dec:	02e7f263          	bgeu	a5,a4,ffffffffc0200e10 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0200df0:	fff80537          	lui	a0,0xfff80
ffffffffc0200df4:	97aa                	add	a5,a5,a0
ffffffffc0200df6:	60a2                	ld	ra,8(sp)
ffffffffc0200df8:	6402                	ld	s0,0(sp)
ffffffffc0200dfa:	00379513          	slli	a0,a5,0x3
ffffffffc0200dfe:	97aa                	add	a5,a5,a0
ffffffffc0200e00:	078e                	slli	a5,a5,0x3
ffffffffc0200e02:	00010517          	auipc	a0,0x10
ffffffffc0200e06:	72653503          	ld	a0,1830(a0) # ffffffffc0211528 <pages>
ffffffffc0200e0a:	953e                	add	a0,a0,a5
ffffffffc0200e0c:	0141                	addi	sp,sp,16
ffffffffc0200e0e:	8082                	ret
ffffffffc0200e10:	c71ff0ef          	jal	ra,ffffffffc0200a80 <pa2page.part.0>

ffffffffc0200e14 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200e14:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e16:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200e18:	ec06                	sd	ra,24(sp)
ffffffffc0200e1a:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e1c:	da9ff0ef          	jal	ra,ffffffffc0200bc4 <get_pte>
    if (ptep != NULL) {
ffffffffc0200e20:	c511                	beqz	a0,ffffffffc0200e2c <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0200e22:	611c                	ld	a5,0(a0)
ffffffffc0200e24:	842a                	mv	s0,a0
ffffffffc0200e26:	0017f713          	andi	a4,a5,1
ffffffffc0200e2a:	e709                	bnez	a4,ffffffffc0200e34 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0200e2c:	60e2                	ld	ra,24(sp)
ffffffffc0200e2e:	6442                	ld	s0,16(sp)
ffffffffc0200e30:	6105                	addi	sp,sp,32
ffffffffc0200e32:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0200e34:	078a                	slli	a5,a5,0x2
ffffffffc0200e36:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200e38:	00010717          	auipc	a4,0x10
ffffffffc0200e3c:	6e873703          	ld	a4,1768(a4) # ffffffffc0211520 <npage>
ffffffffc0200e40:	06e7f563          	bgeu	a5,a4,ffffffffc0200eaa <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0200e44:	fff80737          	lui	a4,0xfff80
ffffffffc0200e48:	97ba                	add	a5,a5,a4
ffffffffc0200e4a:	00379513          	slli	a0,a5,0x3
ffffffffc0200e4e:	97aa                	add	a5,a5,a0
ffffffffc0200e50:	078e                	slli	a5,a5,0x3
ffffffffc0200e52:	00010517          	auipc	a0,0x10
ffffffffc0200e56:	6d653503          	ld	a0,1750(a0) # ffffffffc0211528 <pages>
ffffffffc0200e5a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0200e5c:	411c                	lw	a5,0(a0)
ffffffffc0200e5e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200e62:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200e64:	cb09                	beqz	a4,ffffffffc0200e76 <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200e66:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200e6a:	12000073          	sfence.vma
}
ffffffffc0200e6e:	60e2                	ld	ra,24(sp)
ffffffffc0200e70:	6442                	ld	s0,16(sp)
ffffffffc0200e72:	6105                	addi	sp,sp,32
ffffffffc0200e74:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e76:	100027f3          	csrr	a5,sstatus
ffffffffc0200e7a:	8b89                	andi	a5,a5,2
ffffffffc0200e7c:	eb89                	bnez	a5,ffffffffc0200e8e <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0200e7e:	00010797          	auipc	a5,0x10
ffffffffc0200e82:	6b27b783          	ld	a5,1714(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200e86:	739c                	ld	a5,32(a5)
ffffffffc0200e88:	4585                	li	a1,1
ffffffffc0200e8a:	9782                	jalr	a5
    if (flag) {
ffffffffc0200e8c:	bfe9                	j	ffffffffc0200e66 <page_remove+0x52>
        intr_disable();
ffffffffc0200e8e:	e42a                	sd	a0,8(sp)
ffffffffc0200e90:	e3aff0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc0200e94:	00010797          	auipc	a5,0x10
ffffffffc0200e98:	69c7b783          	ld	a5,1692(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200e9c:	739c                	ld	a5,32(a5)
ffffffffc0200e9e:	6522                	ld	a0,8(sp)
ffffffffc0200ea0:	4585                	li	a1,1
ffffffffc0200ea2:	9782                	jalr	a5
        intr_enable();
ffffffffc0200ea4:	e20ff0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc0200ea8:	bf7d                	j	ffffffffc0200e66 <page_remove+0x52>
ffffffffc0200eaa:	bd7ff0ef          	jal	ra,ffffffffc0200a80 <pa2page.part.0>

ffffffffc0200eae <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200eae:	7179                	addi	sp,sp,-48
ffffffffc0200eb0:	87b2                	mv	a5,a2
ffffffffc0200eb2:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200eb4:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200eb6:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200eb8:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200eba:	ec26                	sd	s1,24(sp)
ffffffffc0200ebc:	f406                	sd	ra,40(sp)
ffffffffc0200ebe:	e84a                	sd	s2,16(sp)
ffffffffc0200ec0:	e44e                	sd	s3,8(sp)
ffffffffc0200ec2:	e052                	sd	s4,0(sp)
ffffffffc0200ec4:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200ec6:	cffff0ef          	jal	ra,ffffffffc0200bc4 <get_pte>
    if (ptep == NULL) {
ffffffffc0200eca:	cd71                	beqz	a0,ffffffffc0200fa6 <page_insert+0xf8>
    page->ref += 1;
ffffffffc0200ecc:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0200ece:	611c                	ld	a5,0(a0)
ffffffffc0200ed0:	89aa                	mv	s3,a0
ffffffffc0200ed2:	0016871b          	addiw	a4,a3,1
ffffffffc0200ed6:	c018                	sw	a4,0(s0)
ffffffffc0200ed8:	0017f713          	andi	a4,a5,1
ffffffffc0200edc:	e331                	bnez	a4,ffffffffc0200f20 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ede:	00010797          	auipc	a5,0x10
ffffffffc0200ee2:	64a7b783          	ld	a5,1610(a5) # ffffffffc0211528 <pages>
ffffffffc0200ee6:	40f407b3          	sub	a5,s0,a5
ffffffffc0200eea:	878d                	srai	a5,a5,0x3
ffffffffc0200eec:	00005417          	auipc	s0,0x5
ffffffffc0200ef0:	14c43403          	ld	s0,332(s0) # ffffffffc0206038 <error_string+0x38>
ffffffffc0200ef4:	028787b3          	mul	a5,a5,s0
ffffffffc0200ef8:	00080437          	lui	s0,0x80
ffffffffc0200efc:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200efe:	07aa                	slli	a5,a5,0xa
ffffffffc0200f00:	8cdd                	or	s1,s1,a5
ffffffffc0200f02:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0200f06:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200f0a:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0200f0e:	4501                	li	a0,0
}
ffffffffc0200f10:	70a2                	ld	ra,40(sp)
ffffffffc0200f12:	7402                	ld	s0,32(sp)
ffffffffc0200f14:	64e2                	ld	s1,24(sp)
ffffffffc0200f16:	6942                	ld	s2,16(sp)
ffffffffc0200f18:	69a2                	ld	s3,8(sp)
ffffffffc0200f1a:	6a02                	ld	s4,0(sp)
ffffffffc0200f1c:	6145                	addi	sp,sp,48
ffffffffc0200f1e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0200f20:	00279713          	slli	a4,a5,0x2
ffffffffc0200f24:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f26:	00010797          	auipc	a5,0x10
ffffffffc0200f2a:	5fa7b783          	ld	a5,1530(a5) # ffffffffc0211520 <npage>
ffffffffc0200f2e:	06f77e63          	bgeu	a4,a5,ffffffffc0200faa <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f32:	fff807b7          	lui	a5,0xfff80
ffffffffc0200f36:	973e                	add	a4,a4,a5
ffffffffc0200f38:	00010a17          	auipc	s4,0x10
ffffffffc0200f3c:	5f0a0a13          	addi	s4,s4,1520 # ffffffffc0211528 <pages>
ffffffffc0200f40:	000a3783          	ld	a5,0(s4)
ffffffffc0200f44:	00371913          	slli	s2,a4,0x3
ffffffffc0200f48:	993a                	add	s2,s2,a4
ffffffffc0200f4a:	090e                	slli	s2,s2,0x3
ffffffffc0200f4c:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0200f4e:	03240063          	beq	s0,s2,ffffffffc0200f6e <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0200f52:	00092783          	lw	a5,0(s2)
ffffffffc0200f56:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200f5a:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0200f5e:	cb11                	beqz	a4,ffffffffc0200f72 <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200f60:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200f64:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200f68:	000a3783          	ld	a5,0(s4)
}
ffffffffc0200f6c:	bfad                	j	ffffffffc0200ee6 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0200f6e:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0200f70:	bf9d                	j	ffffffffc0200ee6 <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f72:	100027f3          	csrr	a5,sstatus
ffffffffc0200f76:	8b89                	andi	a5,a5,2
ffffffffc0200f78:	eb91                	bnez	a5,ffffffffc0200f8c <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0200f7a:	00010797          	auipc	a5,0x10
ffffffffc0200f7e:	5b67b783          	ld	a5,1462(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200f82:	739c                	ld	a5,32(a5)
ffffffffc0200f84:	4585                	li	a1,1
ffffffffc0200f86:	854a                	mv	a0,s2
ffffffffc0200f88:	9782                	jalr	a5
    if (flag) {
ffffffffc0200f8a:	bfd9                	j	ffffffffc0200f60 <page_insert+0xb2>
        intr_disable();
ffffffffc0200f8c:	d3eff0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc0200f90:	00010797          	auipc	a5,0x10
ffffffffc0200f94:	5a07b783          	ld	a5,1440(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200f98:	739c                	ld	a5,32(a5)
ffffffffc0200f9a:	4585                	li	a1,1
ffffffffc0200f9c:	854a                	mv	a0,s2
ffffffffc0200f9e:	9782                	jalr	a5
        intr_enable();
ffffffffc0200fa0:	d24ff0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc0200fa4:	bf75                	j	ffffffffc0200f60 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0200fa6:	5571                	li	a0,-4
ffffffffc0200fa8:	b7a5                	j	ffffffffc0200f10 <page_insert+0x62>
ffffffffc0200faa:	ad7ff0ef          	jal	ra,ffffffffc0200a80 <pa2page.part.0>

ffffffffc0200fae <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0200fae:	00005797          	auipc	a5,0x5
ffffffffc0200fb2:	ce278793          	addi	a5,a5,-798 # ffffffffc0205c90 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fb6:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0200fb8:	7159                	addi	sp,sp,-112
ffffffffc0200fba:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fbc:	00004517          	auipc	a0,0x4
ffffffffc0200fc0:	cf450513          	addi	a0,a0,-780 # ffffffffc0204cb0 <commands+0x798>
    pmm_manager = &default_pmm_manager;
ffffffffc0200fc4:	00010b97          	auipc	s7,0x10
ffffffffc0200fc8:	56cb8b93          	addi	s7,s7,1388 # ffffffffc0211530 <pmm_manager>
void pmm_init(void) {
ffffffffc0200fcc:	f486                	sd	ra,104(sp)
ffffffffc0200fce:	f0a2                	sd	s0,96(sp)
ffffffffc0200fd0:	eca6                	sd	s1,88(sp)
ffffffffc0200fd2:	e8ca                	sd	s2,80(sp)
ffffffffc0200fd4:	e4ce                	sd	s3,72(sp)
ffffffffc0200fd6:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0200fd8:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0200fdc:	e0d2                	sd	s4,64(sp)
ffffffffc0200fde:	fc56                	sd	s5,56(sp)
ffffffffc0200fe0:	f062                	sd	s8,32(sp)
ffffffffc0200fe2:	ec66                	sd	s9,24(sp)
ffffffffc0200fe4:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fe6:	8d4ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0200fea:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0200fee:	4445                	li	s0,17
ffffffffc0200ff0:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0200ff4:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0200ff6:	00010997          	auipc	s3,0x10
ffffffffc0200ffa:	54298993          	addi	s3,s3,1346 # ffffffffc0211538 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0200ffe:	00010497          	auipc	s1,0x10
ffffffffc0201002:	52248493          	addi	s1,s1,1314 # ffffffffc0211520 <npage>
    pmm_manager->init();
ffffffffc0201006:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201008:	57f5                	li	a5,-3
ffffffffc020100a:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc020100c:	07e006b7          	lui	a3,0x7e00
ffffffffc0201010:	01b41613          	slli	a2,s0,0x1b
ffffffffc0201014:	01591593          	slli	a1,s2,0x15
ffffffffc0201018:	00004517          	auipc	a0,0x4
ffffffffc020101c:	cb050513          	addi	a0,a0,-848 # ffffffffc0204cc8 <commands+0x7b0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201020:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201024:	896ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201028:	00004517          	auipc	a0,0x4
ffffffffc020102c:	cd050513          	addi	a0,a0,-816 # ffffffffc0204cf8 <commands+0x7e0>
ffffffffc0201030:	88aff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201034:	01b41693          	slli	a3,s0,0x1b
ffffffffc0201038:	16fd                	addi	a3,a3,-1
ffffffffc020103a:	07e005b7          	lui	a1,0x7e00
ffffffffc020103e:	01591613          	slli	a2,s2,0x15
ffffffffc0201042:	00004517          	auipc	a0,0x4
ffffffffc0201046:	cce50513          	addi	a0,a0,-818 # ffffffffc0204d10 <commands+0x7f8>
ffffffffc020104a:	870ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020104e:	777d                	lui	a4,0xfffff
ffffffffc0201050:	00011797          	auipc	a5,0x11
ffffffffc0201054:	51f78793          	addi	a5,a5,1311 # ffffffffc021256f <end+0xfff>
ffffffffc0201058:	8ff9                	and	a5,a5,a4
ffffffffc020105a:	00010b17          	auipc	s6,0x10
ffffffffc020105e:	4ceb0b13          	addi	s6,s6,1230 # ffffffffc0211528 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201062:	00088737          	lui	a4,0x88
ffffffffc0201066:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201068:	00fb3023          	sd	a5,0(s6)
ffffffffc020106c:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020106e:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201070:	4505                	li	a0,1
ffffffffc0201072:	fff805b7          	lui	a1,0xfff80
ffffffffc0201076:	a019                	j	ffffffffc020107c <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0201078:	000b3783          	ld	a5,0(s6)
ffffffffc020107c:	97b6                	add	a5,a5,a3
ffffffffc020107e:	07a1                	addi	a5,a5,8
ffffffffc0201080:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201084:	609c                	ld	a5,0(s1)
ffffffffc0201086:	0705                	addi	a4,a4,1
ffffffffc0201088:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc020108c:	00b78633          	add	a2,a5,a1
ffffffffc0201090:	fec764e3          	bltu	a4,a2,ffffffffc0201078 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201094:	000b3503          	ld	a0,0(s6)
ffffffffc0201098:	00379693          	slli	a3,a5,0x3
ffffffffc020109c:	96be                	add	a3,a3,a5
ffffffffc020109e:	fdc00737          	lui	a4,0xfdc00
ffffffffc02010a2:	972a                	add	a4,a4,a0
ffffffffc02010a4:	068e                	slli	a3,a3,0x3
ffffffffc02010a6:	96ba                	add	a3,a3,a4
ffffffffc02010a8:	c0200737          	lui	a4,0xc0200
ffffffffc02010ac:	64e6e463          	bltu	a3,a4,ffffffffc02016f4 <pmm_init+0x746>
ffffffffc02010b0:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc02010b4:	4645                	li	a2,17
ffffffffc02010b6:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010b8:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02010ba:	4ec6e263          	bltu	a3,a2,ffffffffc020159e <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02010be:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02010c2:	00010917          	auipc	s2,0x10
ffffffffc02010c6:	45690913          	addi	s2,s2,1110 # ffffffffc0211518 <boot_pgdir>
    pmm_manager->check();
ffffffffc02010ca:	7b9c                	ld	a5,48(a5)
ffffffffc02010cc:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02010ce:	00004517          	auipc	a0,0x4
ffffffffc02010d2:	c9250513          	addi	a0,a0,-878 # ffffffffc0204d60 <commands+0x848>
ffffffffc02010d6:	fe5fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02010da:	00008697          	auipc	a3,0x8
ffffffffc02010de:	f2668693          	addi	a3,a3,-218 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc02010e2:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02010e6:	c02007b7          	lui	a5,0xc0200
ffffffffc02010ea:	62f6e163          	bltu	a3,a5,ffffffffc020170c <pmm_init+0x75e>
ffffffffc02010ee:	0009b783          	ld	a5,0(s3)
ffffffffc02010f2:	8e9d                	sub	a3,a3,a5
ffffffffc02010f4:	00010797          	auipc	a5,0x10
ffffffffc02010f8:	40d7be23          	sd	a3,1052(a5) # ffffffffc0211510 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02010fc:	100027f3          	csrr	a5,sstatus
ffffffffc0201100:	8b89                	andi	a5,a5,2
ffffffffc0201102:	4c079763          	bnez	a5,ffffffffc02015d0 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201106:	000bb783          	ld	a5,0(s7)
ffffffffc020110a:	779c                	ld	a5,40(a5)
ffffffffc020110c:	9782                	jalr	a5
ffffffffc020110e:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201110:	6098                	ld	a4,0(s1)
ffffffffc0201112:	c80007b7          	lui	a5,0xc8000
ffffffffc0201116:	83b1                	srli	a5,a5,0xc
ffffffffc0201118:	62e7e663          	bltu	a5,a4,ffffffffc0201744 <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020111c:	00093503          	ld	a0,0(s2)
ffffffffc0201120:	60050263          	beqz	a0,ffffffffc0201724 <pmm_init+0x776>
ffffffffc0201124:	03451793          	slli	a5,a0,0x34
ffffffffc0201128:	5e079e63          	bnez	a5,ffffffffc0201724 <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020112c:	4601                	li	a2,0
ffffffffc020112e:	4581                	li	a1,0
ffffffffc0201130:	c8bff0ef          	jal	ra,ffffffffc0200dba <get_page>
ffffffffc0201134:	66051a63          	bnez	a0,ffffffffc02017a8 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201138:	4505                	li	a0,1
ffffffffc020113a:	97fff0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc020113e:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201140:	00093503          	ld	a0,0(s2)
ffffffffc0201144:	4681                	li	a3,0
ffffffffc0201146:	4601                	li	a2,0
ffffffffc0201148:	85d2                	mv	a1,s4
ffffffffc020114a:	d65ff0ef          	jal	ra,ffffffffc0200eae <page_insert>
ffffffffc020114e:	62051d63          	bnez	a0,ffffffffc0201788 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201152:	00093503          	ld	a0,0(s2)
ffffffffc0201156:	4601                	li	a2,0
ffffffffc0201158:	4581                	li	a1,0
ffffffffc020115a:	a6bff0ef          	jal	ra,ffffffffc0200bc4 <get_pte>
ffffffffc020115e:	60050563          	beqz	a0,ffffffffc0201768 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0201162:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201164:	0017f713          	andi	a4,a5,1
ffffffffc0201168:	5e070e63          	beqz	a4,ffffffffc0201764 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc020116c:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020116e:	078a                	slli	a5,a5,0x2
ffffffffc0201170:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201172:	56c7ff63          	bgeu	a5,a2,ffffffffc02016f0 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201176:	fff80737          	lui	a4,0xfff80
ffffffffc020117a:	97ba                	add	a5,a5,a4
ffffffffc020117c:	000b3683          	ld	a3,0(s6)
ffffffffc0201180:	00379713          	slli	a4,a5,0x3
ffffffffc0201184:	97ba                	add	a5,a5,a4
ffffffffc0201186:	078e                	slli	a5,a5,0x3
ffffffffc0201188:	97b6                	add	a5,a5,a3
ffffffffc020118a:	14fa18e3          	bne	s4,a5,ffffffffc0201ada <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc020118e:	000a2703          	lw	a4,0(s4)
ffffffffc0201192:	4785                	li	a5,1
ffffffffc0201194:	16f71fe3          	bne	a4,a5,ffffffffc0201b12 <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201198:	00093503          	ld	a0,0(s2)
ffffffffc020119c:	77fd                	lui	a5,0xfffff
ffffffffc020119e:	6114                	ld	a3,0(a0)
ffffffffc02011a0:	068a                	slli	a3,a3,0x2
ffffffffc02011a2:	8efd                	and	a3,a3,a5
ffffffffc02011a4:	00c6d713          	srli	a4,a3,0xc
ffffffffc02011a8:	14c779e3          	bgeu	a4,a2,ffffffffc0201afa <pmm_init+0xb4c>
ffffffffc02011ac:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011b0:	96e2                	add	a3,a3,s8
ffffffffc02011b2:	0006ba83          	ld	s5,0(a3)
ffffffffc02011b6:	0a8a                	slli	s5,s5,0x2
ffffffffc02011b8:	00fafab3          	and	s5,s5,a5
ffffffffc02011bc:	00cad793          	srli	a5,s5,0xc
ffffffffc02011c0:	66c7f463          	bgeu	a5,a2,ffffffffc0201828 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02011c4:	4601                	li	a2,0
ffffffffc02011c6:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011c8:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02011ca:	9fbff0ef          	jal	ra,ffffffffc0200bc4 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011ce:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02011d0:	63551c63          	bne	a0,s5,ffffffffc0201808 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc02011d4:	4505                	li	a0,1
ffffffffc02011d6:	8e3ff0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc02011da:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02011dc:	00093503          	ld	a0,0(s2)
ffffffffc02011e0:	46d1                	li	a3,20
ffffffffc02011e2:	6605                	lui	a2,0x1
ffffffffc02011e4:	85d6                	mv	a1,s5
ffffffffc02011e6:	cc9ff0ef          	jal	ra,ffffffffc0200eae <page_insert>
ffffffffc02011ea:	5c051f63          	bnez	a0,ffffffffc02017c8 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02011ee:	00093503          	ld	a0,0(s2)
ffffffffc02011f2:	4601                	li	a2,0
ffffffffc02011f4:	6585                	lui	a1,0x1
ffffffffc02011f6:	9cfff0ef          	jal	ra,ffffffffc0200bc4 <get_pte>
ffffffffc02011fa:	12050ce3          	beqz	a0,ffffffffc0201b32 <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc02011fe:	611c                	ld	a5,0(a0)
ffffffffc0201200:	0107f713          	andi	a4,a5,16
ffffffffc0201204:	72070f63          	beqz	a4,ffffffffc0201942 <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0201208:	8b91                	andi	a5,a5,4
ffffffffc020120a:	6e078c63          	beqz	a5,ffffffffc0201902 <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020120e:	00093503          	ld	a0,0(s2)
ffffffffc0201212:	611c                	ld	a5,0(a0)
ffffffffc0201214:	8bc1                	andi	a5,a5,16
ffffffffc0201216:	6c078663          	beqz	a5,ffffffffc02018e2 <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc020121a:	000aa703          	lw	a4,0(s5)
ffffffffc020121e:	4785                	li	a5,1
ffffffffc0201220:	5cf71463          	bne	a4,a5,ffffffffc02017e8 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201224:	4681                	li	a3,0
ffffffffc0201226:	6605                	lui	a2,0x1
ffffffffc0201228:	85d2                	mv	a1,s4
ffffffffc020122a:	c85ff0ef          	jal	ra,ffffffffc0200eae <page_insert>
ffffffffc020122e:	66051a63          	bnez	a0,ffffffffc02018a2 <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc0201232:	000a2703          	lw	a4,0(s4)
ffffffffc0201236:	4789                	li	a5,2
ffffffffc0201238:	64f71563          	bne	a4,a5,ffffffffc0201882 <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc020123c:	000aa783          	lw	a5,0(s5)
ffffffffc0201240:	62079163          	bnez	a5,ffffffffc0201862 <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201244:	00093503          	ld	a0,0(s2)
ffffffffc0201248:	4601                	li	a2,0
ffffffffc020124a:	6585                	lui	a1,0x1
ffffffffc020124c:	979ff0ef          	jal	ra,ffffffffc0200bc4 <get_pte>
ffffffffc0201250:	5e050963          	beqz	a0,ffffffffc0201842 <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc0201254:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201256:	00177793          	andi	a5,a4,1
ffffffffc020125a:	50078563          	beqz	a5,ffffffffc0201764 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc020125e:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201260:	00271793          	slli	a5,a4,0x2
ffffffffc0201264:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201266:	48d7f563          	bgeu	a5,a3,ffffffffc02016f0 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020126a:	fff806b7          	lui	a3,0xfff80
ffffffffc020126e:	97b6                	add	a5,a5,a3
ffffffffc0201270:	000b3603          	ld	a2,0(s6)
ffffffffc0201274:	00379693          	slli	a3,a5,0x3
ffffffffc0201278:	97b6                	add	a5,a5,a3
ffffffffc020127a:	078e                	slli	a5,a5,0x3
ffffffffc020127c:	97b2                	add	a5,a5,a2
ffffffffc020127e:	72fa1263          	bne	s4,a5,ffffffffc02019a2 <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201282:	8b41                	andi	a4,a4,16
ffffffffc0201284:	6e071f63          	bnez	a4,ffffffffc0201982 <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201288:	00093503          	ld	a0,0(s2)
ffffffffc020128c:	4581                	li	a1,0
ffffffffc020128e:	b87ff0ef          	jal	ra,ffffffffc0200e14 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201292:	000a2703          	lw	a4,0(s4)
ffffffffc0201296:	4785                	li	a5,1
ffffffffc0201298:	6cf71563          	bne	a4,a5,ffffffffc0201962 <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc020129c:	000aa783          	lw	a5,0(s5)
ffffffffc02012a0:	78079d63          	bnez	a5,ffffffffc0201a3a <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02012a4:	00093503          	ld	a0,0(s2)
ffffffffc02012a8:	6585                	lui	a1,0x1
ffffffffc02012aa:	b6bff0ef          	jal	ra,ffffffffc0200e14 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02012ae:	000a2783          	lw	a5,0(s4)
ffffffffc02012b2:	76079463          	bnez	a5,ffffffffc0201a1a <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc02012b6:	000aa783          	lw	a5,0(s5)
ffffffffc02012ba:	74079063          	bnez	a5,ffffffffc02019fa <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02012be:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02012c2:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02012c4:	000a3783          	ld	a5,0(s4)
ffffffffc02012c8:	078a                	slli	a5,a5,0x2
ffffffffc02012ca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012cc:	42c7f263          	bgeu	a5,a2,ffffffffc02016f0 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02012d0:	fff80737          	lui	a4,0xfff80
ffffffffc02012d4:	973e                	add	a4,a4,a5
ffffffffc02012d6:	00371793          	slli	a5,a4,0x3
ffffffffc02012da:	000b3503          	ld	a0,0(s6)
ffffffffc02012de:	97ba                	add	a5,a5,a4
ffffffffc02012e0:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc02012e2:	00f50733          	add	a4,a0,a5
ffffffffc02012e6:	4314                	lw	a3,0(a4)
ffffffffc02012e8:	4705                	li	a4,1
ffffffffc02012ea:	6ee69863          	bne	a3,a4,ffffffffc02019da <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02012ee:	4037d693          	srai	a3,a5,0x3
ffffffffc02012f2:	00005c97          	auipc	s9,0x5
ffffffffc02012f6:	d46cbc83          	ld	s9,-698(s9) # ffffffffc0206038 <error_string+0x38>
ffffffffc02012fa:	039686b3          	mul	a3,a3,s9
ffffffffc02012fe:	000805b7          	lui	a1,0x80
ffffffffc0201302:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201304:	00c69713          	slli	a4,a3,0xc
ffffffffc0201308:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020130a:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020130c:	6ac77b63          	bgeu	a4,a2,ffffffffc02019c2 <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201310:	0009b703          	ld	a4,0(s3)
ffffffffc0201314:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201316:	629c                	ld	a5,0(a3)
ffffffffc0201318:	078a                	slli	a5,a5,0x2
ffffffffc020131a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020131c:	3cc7fa63          	bgeu	a5,a2,ffffffffc02016f0 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201320:	8f8d                	sub	a5,a5,a1
ffffffffc0201322:	00379713          	slli	a4,a5,0x3
ffffffffc0201326:	97ba                	add	a5,a5,a4
ffffffffc0201328:	078e                	slli	a5,a5,0x3
ffffffffc020132a:	953e                	add	a0,a0,a5
ffffffffc020132c:	100027f3          	csrr	a5,sstatus
ffffffffc0201330:	8b89                	andi	a5,a5,2
ffffffffc0201332:	2e079963          	bnez	a5,ffffffffc0201624 <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201336:	000bb783          	ld	a5,0(s7)
ffffffffc020133a:	4585                	li	a1,1
ffffffffc020133c:	739c                	ld	a5,32(a5)
ffffffffc020133e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201340:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201344:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201346:	078a                	slli	a5,a5,0x2
ffffffffc0201348:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020134a:	3ae7f363          	bgeu	a5,a4,ffffffffc02016f0 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020134e:	fff80737          	lui	a4,0xfff80
ffffffffc0201352:	97ba                	add	a5,a5,a4
ffffffffc0201354:	000b3503          	ld	a0,0(s6)
ffffffffc0201358:	00379713          	slli	a4,a5,0x3
ffffffffc020135c:	97ba                	add	a5,a5,a4
ffffffffc020135e:	078e                	slli	a5,a5,0x3
ffffffffc0201360:	953e                	add	a0,a0,a5
ffffffffc0201362:	100027f3          	csrr	a5,sstatus
ffffffffc0201366:	8b89                	andi	a5,a5,2
ffffffffc0201368:	2a079263          	bnez	a5,ffffffffc020160c <pmm_init+0x65e>
ffffffffc020136c:	000bb783          	ld	a5,0(s7)
ffffffffc0201370:	4585                	li	a1,1
ffffffffc0201372:	739c                	ld	a5,32(a5)
ffffffffc0201374:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201376:	00093783          	ld	a5,0(s2)
ffffffffc020137a:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda90>
ffffffffc020137e:	100027f3          	csrr	a5,sstatus
ffffffffc0201382:	8b89                	andi	a5,a5,2
ffffffffc0201384:	26079a63          	bnez	a5,ffffffffc02015f8 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201388:	000bb783          	ld	a5,0(s7)
ffffffffc020138c:	779c                	ld	a5,40(a5)
ffffffffc020138e:	9782                	jalr	a5
ffffffffc0201390:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0201392:	73441463          	bne	s0,s4,ffffffffc0201aba <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201396:	00004517          	auipc	a0,0x4
ffffffffc020139a:	cca50513          	addi	a0,a0,-822 # ffffffffc0205060 <commands+0xb48>
ffffffffc020139e:	d1dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02013a2:	100027f3          	csrr	a5,sstatus
ffffffffc02013a6:	8b89                	andi	a5,a5,2
ffffffffc02013a8:	22079e63          	bnez	a5,ffffffffc02015e4 <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02013ac:	000bb783          	ld	a5,0(s7)
ffffffffc02013b0:	779c                	ld	a5,40(a5)
ffffffffc02013b2:	9782                	jalr	a5
ffffffffc02013b4:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013b6:	6098                	ld	a4,0(s1)
ffffffffc02013b8:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02013bc:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013be:	00c71793          	slli	a5,a4,0xc
ffffffffc02013c2:	6a05                	lui	s4,0x1
ffffffffc02013c4:	02f47c63          	bgeu	s0,a5,ffffffffc02013fc <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02013c8:	00c45793          	srli	a5,s0,0xc
ffffffffc02013cc:	00093503          	ld	a0,0(s2)
ffffffffc02013d0:	30e7f363          	bgeu	a5,a4,ffffffffc02016d6 <pmm_init+0x728>
ffffffffc02013d4:	0009b583          	ld	a1,0(s3)
ffffffffc02013d8:	4601                	li	a2,0
ffffffffc02013da:	95a2                	add	a1,a1,s0
ffffffffc02013dc:	fe8ff0ef          	jal	ra,ffffffffc0200bc4 <get_pte>
ffffffffc02013e0:	2c050b63          	beqz	a0,ffffffffc02016b6 <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02013e4:	611c                	ld	a5,0(a0)
ffffffffc02013e6:	078a                	slli	a5,a5,0x2
ffffffffc02013e8:	0157f7b3          	and	a5,a5,s5
ffffffffc02013ec:	2a879563          	bne	a5,s0,ffffffffc0201696 <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013f0:	6098                	ld	a4,0(s1)
ffffffffc02013f2:	9452                	add	s0,s0,s4
ffffffffc02013f4:	00c71793          	slli	a5,a4,0xc
ffffffffc02013f8:	fcf468e3          	bltu	s0,a5,ffffffffc02013c8 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02013fc:	00093783          	ld	a5,0(s2)
ffffffffc0201400:	639c                	ld	a5,0(a5)
ffffffffc0201402:	68079c63          	bnez	a5,ffffffffc0201a9a <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0201406:	4505                	li	a0,1
ffffffffc0201408:	eb0ff0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc020140c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020140e:	00093503          	ld	a0,0(s2)
ffffffffc0201412:	4699                	li	a3,6
ffffffffc0201414:	10000613          	li	a2,256
ffffffffc0201418:	85d6                	mv	a1,s5
ffffffffc020141a:	a95ff0ef          	jal	ra,ffffffffc0200eae <page_insert>
ffffffffc020141e:	64051e63          	bnez	a0,ffffffffc0201a7a <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0201422:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda90>
ffffffffc0201426:	4785                	li	a5,1
ffffffffc0201428:	62f71963          	bne	a4,a5,ffffffffc0201a5a <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020142c:	00093503          	ld	a0,0(s2)
ffffffffc0201430:	6405                	lui	s0,0x1
ffffffffc0201432:	4699                	li	a3,6
ffffffffc0201434:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201438:	85d6                	mv	a1,s5
ffffffffc020143a:	a75ff0ef          	jal	ra,ffffffffc0200eae <page_insert>
ffffffffc020143e:	48051263          	bnez	a0,ffffffffc02018c2 <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0201442:	000aa703          	lw	a4,0(s5)
ffffffffc0201446:	4789                	li	a5,2
ffffffffc0201448:	74f71563          	bne	a4,a5,ffffffffc0201b92 <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020144c:	00004597          	auipc	a1,0x4
ffffffffc0201450:	d4c58593          	addi	a1,a1,-692 # ffffffffc0205198 <commands+0xc80>
ffffffffc0201454:	10000513          	li	a0,256
ffffffffc0201458:	135020ef          	jal	ra,ffffffffc0203d8c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020145c:	10040593          	addi	a1,s0,256
ffffffffc0201460:	10000513          	li	a0,256
ffffffffc0201464:	13b020ef          	jal	ra,ffffffffc0203d9e <strcmp>
ffffffffc0201468:	70051563          	bnez	a0,ffffffffc0201b72 <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020146c:	000b3683          	ld	a3,0(s6)
ffffffffc0201470:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201474:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201476:	40da86b3          	sub	a3,s5,a3
ffffffffc020147a:	868d                	srai	a3,a3,0x3
ffffffffc020147c:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201480:	609c                	ld	a5,0(s1)
ffffffffc0201482:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201484:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201486:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc020148a:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020148c:	52f77b63          	bgeu	a4,a5,ffffffffc02019c2 <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201490:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201494:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201498:	96be                	add	a3,a3,a5
ffffffffc020149a:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb90>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020149e:	0b9020ef          	jal	ra,ffffffffc0203d56 <strlen>
ffffffffc02014a2:	6a051863          	bnez	a0,ffffffffc0201b52 <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02014a6:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02014aa:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014ac:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02014b0:	078a                	slli	a5,a5,0x2
ffffffffc02014b2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014b4:	22e7fe63          	bgeu	a5,a4,ffffffffc02016f0 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02014b8:	41a787b3          	sub	a5,a5,s10
ffffffffc02014bc:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02014c0:	96be                	add	a3,a3,a5
ffffffffc02014c2:	03968cb3          	mul	s9,a3,s9
ffffffffc02014c6:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02014ca:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02014cc:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02014ce:	4ee47a63          	bgeu	s0,a4,ffffffffc02019c2 <pmm_init+0xa14>
ffffffffc02014d2:	0009b403          	ld	s0,0(s3)
ffffffffc02014d6:	9436                	add	s0,s0,a3
ffffffffc02014d8:	100027f3          	csrr	a5,sstatus
ffffffffc02014dc:	8b89                	andi	a5,a5,2
ffffffffc02014de:	1a079163          	bnez	a5,ffffffffc0201680 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc02014e2:	000bb783          	ld	a5,0(s7)
ffffffffc02014e6:	4585                	li	a1,1
ffffffffc02014e8:	8556                	mv	a0,s5
ffffffffc02014ea:	739c                	ld	a5,32(a5)
ffffffffc02014ec:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02014ee:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02014f0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014f2:	078a                	slli	a5,a5,0x2
ffffffffc02014f4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014f6:	1ee7fd63          	bgeu	a5,a4,ffffffffc02016f0 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02014fa:	fff80737          	lui	a4,0xfff80
ffffffffc02014fe:	97ba                	add	a5,a5,a4
ffffffffc0201500:	000b3503          	ld	a0,0(s6)
ffffffffc0201504:	00379713          	slli	a4,a5,0x3
ffffffffc0201508:	97ba                	add	a5,a5,a4
ffffffffc020150a:	078e                	slli	a5,a5,0x3
ffffffffc020150c:	953e                	add	a0,a0,a5
ffffffffc020150e:	100027f3          	csrr	a5,sstatus
ffffffffc0201512:	8b89                	andi	a5,a5,2
ffffffffc0201514:	14079a63          	bnez	a5,ffffffffc0201668 <pmm_init+0x6ba>
ffffffffc0201518:	000bb783          	ld	a5,0(s7)
ffffffffc020151c:	4585                	li	a1,1
ffffffffc020151e:	739c                	ld	a5,32(a5)
ffffffffc0201520:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201522:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201526:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201528:	078a                	slli	a5,a5,0x2
ffffffffc020152a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020152c:	1ce7f263          	bgeu	a5,a4,ffffffffc02016f0 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201530:	fff80737          	lui	a4,0xfff80
ffffffffc0201534:	97ba                	add	a5,a5,a4
ffffffffc0201536:	000b3503          	ld	a0,0(s6)
ffffffffc020153a:	00379713          	slli	a4,a5,0x3
ffffffffc020153e:	97ba                	add	a5,a5,a4
ffffffffc0201540:	078e                	slli	a5,a5,0x3
ffffffffc0201542:	953e                	add	a0,a0,a5
ffffffffc0201544:	100027f3          	csrr	a5,sstatus
ffffffffc0201548:	8b89                	andi	a5,a5,2
ffffffffc020154a:	10079363          	bnez	a5,ffffffffc0201650 <pmm_init+0x6a2>
ffffffffc020154e:	000bb783          	ld	a5,0(s7)
ffffffffc0201552:	4585                	li	a1,1
ffffffffc0201554:	739c                	ld	a5,32(a5)
ffffffffc0201556:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201558:	00093783          	ld	a5,0(s2)
ffffffffc020155c:	0007b023          	sd	zero,0(a5)
ffffffffc0201560:	100027f3          	csrr	a5,sstatus
ffffffffc0201564:	8b89                	andi	a5,a5,2
ffffffffc0201566:	0c079b63          	bnez	a5,ffffffffc020163c <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020156a:	000bb783          	ld	a5,0(s7)
ffffffffc020156e:	779c                	ld	a5,40(a5)
ffffffffc0201570:	9782                	jalr	a5
ffffffffc0201572:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0201574:	3a8c1763          	bne	s8,s0,ffffffffc0201922 <pmm_init+0x974>
}
ffffffffc0201578:	7406                	ld	s0,96(sp)
ffffffffc020157a:	70a6                	ld	ra,104(sp)
ffffffffc020157c:	64e6                	ld	s1,88(sp)
ffffffffc020157e:	6946                	ld	s2,80(sp)
ffffffffc0201580:	69a6                	ld	s3,72(sp)
ffffffffc0201582:	6a06                	ld	s4,64(sp)
ffffffffc0201584:	7ae2                	ld	s5,56(sp)
ffffffffc0201586:	7b42                	ld	s6,48(sp)
ffffffffc0201588:	7ba2                	ld	s7,40(sp)
ffffffffc020158a:	7c02                	ld	s8,32(sp)
ffffffffc020158c:	6ce2                	ld	s9,24(sp)
ffffffffc020158e:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201590:	00004517          	auipc	a0,0x4
ffffffffc0201594:	c8050513          	addi	a0,a0,-896 # ffffffffc0205210 <commands+0xcf8>
}
ffffffffc0201598:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020159a:	b21fe06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020159e:	6705                	lui	a4,0x1
ffffffffc02015a0:	177d                	addi	a4,a4,-1
ffffffffc02015a2:	96ba                	add	a3,a3,a4
ffffffffc02015a4:	777d                	lui	a4,0xfffff
ffffffffc02015a6:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc02015a8:	00c75693          	srli	a3,a4,0xc
ffffffffc02015ac:	14f6f263          	bgeu	a3,a5,ffffffffc02016f0 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc02015b0:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02015b4:	95b6                	add	a1,a1,a3
ffffffffc02015b6:	00359793          	slli	a5,a1,0x3
ffffffffc02015ba:	97ae                	add	a5,a5,a1
ffffffffc02015bc:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02015c0:	40e60733          	sub	a4,a2,a4
ffffffffc02015c4:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02015c6:	00c75593          	srli	a1,a4,0xc
ffffffffc02015ca:	953e                	add	a0,a0,a5
ffffffffc02015cc:	9682                	jalr	a3
}
ffffffffc02015ce:	bcc5                	j	ffffffffc02010be <pmm_init+0x110>
        intr_disable();
ffffffffc02015d0:	efbfe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02015d4:	000bb783          	ld	a5,0(s7)
ffffffffc02015d8:	779c                	ld	a5,40(a5)
ffffffffc02015da:	9782                	jalr	a5
ffffffffc02015dc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02015de:	ee7fe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc02015e2:	b63d                	j	ffffffffc0201110 <pmm_init+0x162>
        intr_disable();
ffffffffc02015e4:	ee7fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc02015e8:	000bb783          	ld	a5,0(s7)
ffffffffc02015ec:	779c                	ld	a5,40(a5)
ffffffffc02015ee:	9782                	jalr	a5
ffffffffc02015f0:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02015f2:	ed3fe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc02015f6:	b3c1                	j	ffffffffc02013b6 <pmm_init+0x408>
        intr_disable();
ffffffffc02015f8:	ed3fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc02015fc:	000bb783          	ld	a5,0(s7)
ffffffffc0201600:	779c                	ld	a5,40(a5)
ffffffffc0201602:	9782                	jalr	a5
ffffffffc0201604:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0201606:	ebffe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc020160a:	b361                	j	ffffffffc0201392 <pmm_init+0x3e4>
ffffffffc020160c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020160e:	ebdfe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201612:	000bb783          	ld	a5,0(s7)
ffffffffc0201616:	6522                	ld	a0,8(sp)
ffffffffc0201618:	4585                	li	a1,1
ffffffffc020161a:	739c                	ld	a5,32(a5)
ffffffffc020161c:	9782                	jalr	a5
        intr_enable();
ffffffffc020161e:	ea7fe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc0201622:	bb91                	j	ffffffffc0201376 <pmm_init+0x3c8>
ffffffffc0201624:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201626:	ea5fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc020162a:	000bb783          	ld	a5,0(s7)
ffffffffc020162e:	6522                	ld	a0,8(sp)
ffffffffc0201630:	4585                	li	a1,1
ffffffffc0201632:	739c                	ld	a5,32(a5)
ffffffffc0201634:	9782                	jalr	a5
        intr_enable();
ffffffffc0201636:	e8ffe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc020163a:	b319                	j	ffffffffc0201340 <pmm_init+0x392>
        intr_disable();
ffffffffc020163c:	e8ffe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201640:	000bb783          	ld	a5,0(s7)
ffffffffc0201644:	779c                	ld	a5,40(a5)
ffffffffc0201646:	9782                	jalr	a5
ffffffffc0201648:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020164a:	e7bfe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc020164e:	b71d                	j	ffffffffc0201574 <pmm_init+0x5c6>
ffffffffc0201650:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201652:	e79fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201656:	000bb783          	ld	a5,0(s7)
ffffffffc020165a:	6522                	ld	a0,8(sp)
ffffffffc020165c:	4585                	li	a1,1
ffffffffc020165e:	739c                	ld	a5,32(a5)
ffffffffc0201660:	9782                	jalr	a5
        intr_enable();
ffffffffc0201662:	e63fe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc0201666:	bdcd                	j	ffffffffc0201558 <pmm_init+0x5aa>
ffffffffc0201668:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020166a:	e61fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc020166e:	000bb783          	ld	a5,0(s7)
ffffffffc0201672:	6522                	ld	a0,8(sp)
ffffffffc0201674:	4585                	li	a1,1
ffffffffc0201676:	739c                	ld	a5,32(a5)
ffffffffc0201678:	9782                	jalr	a5
        intr_enable();
ffffffffc020167a:	e4bfe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc020167e:	b555                	j	ffffffffc0201522 <pmm_init+0x574>
        intr_disable();
ffffffffc0201680:	e4bfe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc0201684:	000bb783          	ld	a5,0(s7)
ffffffffc0201688:	4585                	li	a1,1
ffffffffc020168a:	8556                	mv	a0,s5
ffffffffc020168c:	739c                	ld	a5,32(a5)
ffffffffc020168e:	9782                	jalr	a5
        intr_enable();
ffffffffc0201690:	e35fe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc0201694:	bda9                	j	ffffffffc02014ee <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201696:	00004697          	auipc	a3,0x4
ffffffffc020169a:	a2a68693          	addi	a3,a3,-1494 # ffffffffc02050c0 <commands+0xba8>
ffffffffc020169e:	00003617          	auipc	a2,0x3
ffffffffc02016a2:	70260613          	addi	a2,a2,1794 # ffffffffc0204da0 <commands+0x888>
ffffffffc02016a6:	1ce00593          	li	a1,462
ffffffffc02016aa:	00003517          	auipc	a0,0x3
ffffffffc02016ae:	5f650513          	addi	a0,a0,1526 # ffffffffc0204ca0 <commands+0x788>
ffffffffc02016b2:	a51fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02016b6:	00004697          	auipc	a3,0x4
ffffffffc02016ba:	9ca68693          	addi	a3,a3,-1590 # ffffffffc0205080 <commands+0xb68>
ffffffffc02016be:	00003617          	auipc	a2,0x3
ffffffffc02016c2:	6e260613          	addi	a2,a2,1762 # ffffffffc0204da0 <commands+0x888>
ffffffffc02016c6:	1cd00593          	li	a1,461
ffffffffc02016ca:	00003517          	auipc	a0,0x3
ffffffffc02016ce:	5d650513          	addi	a0,a0,1494 # ffffffffc0204ca0 <commands+0x788>
ffffffffc02016d2:	a31fe0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc02016d6:	86a2                	mv	a3,s0
ffffffffc02016d8:	00003617          	auipc	a2,0x3
ffffffffc02016dc:	5a060613          	addi	a2,a2,1440 # ffffffffc0204c78 <commands+0x760>
ffffffffc02016e0:	1cd00593          	li	a1,461
ffffffffc02016e4:	00003517          	auipc	a0,0x3
ffffffffc02016e8:	5bc50513          	addi	a0,a0,1468 # ffffffffc0204ca0 <commands+0x788>
ffffffffc02016ec:	a17fe0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc02016f0:	b90ff0ef          	jal	ra,ffffffffc0200a80 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02016f4:	00003617          	auipc	a2,0x3
ffffffffc02016f8:	64460613          	addi	a2,a2,1604 # ffffffffc0204d38 <commands+0x820>
ffffffffc02016fc:	07700593          	li	a1,119
ffffffffc0201700:	00003517          	auipc	a0,0x3
ffffffffc0201704:	5a050513          	addi	a0,a0,1440 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201708:	9fbfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020170c:	00003617          	auipc	a2,0x3
ffffffffc0201710:	62c60613          	addi	a2,a2,1580 # ffffffffc0204d38 <commands+0x820>
ffffffffc0201714:	0bd00593          	li	a1,189
ffffffffc0201718:	00003517          	auipc	a0,0x3
ffffffffc020171c:	58850513          	addi	a0,a0,1416 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201720:	9e3fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201724:	00003697          	auipc	a3,0x3
ffffffffc0201728:	69468693          	addi	a3,a3,1684 # ffffffffc0204db8 <commands+0x8a0>
ffffffffc020172c:	00003617          	auipc	a2,0x3
ffffffffc0201730:	67460613          	addi	a2,a2,1652 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201734:	19300593          	li	a1,403
ffffffffc0201738:	00003517          	auipc	a0,0x3
ffffffffc020173c:	56850513          	addi	a0,a0,1384 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201740:	9c3fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201744:	00003697          	auipc	a3,0x3
ffffffffc0201748:	63c68693          	addi	a3,a3,1596 # ffffffffc0204d80 <commands+0x868>
ffffffffc020174c:	00003617          	auipc	a2,0x3
ffffffffc0201750:	65460613          	addi	a2,a2,1620 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201754:	19200593          	li	a1,402
ffffffffc0201758:	00003517          	auipc	a0,0x3
ffffffffc020175c:	54850513          	addi	a0,a0,1352 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201760:	9a3fe0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0201764:	b38ff0ef          	jal	ra,ffffffffc0200a9c <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201768:	00003697          	auipc	a3,0x3
ffffffffc020176c:	6e068693          	addi	a3,a3,1760 # ffffffffc0204e48 <commands+0x930>
ffffffffc0201770:	00003617          	auipc	a2,0x3
ffffffffc0201774:	63060613          	addi	a2,a2,1584 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201778:	19a00593          	li	a1,410
ffffffffc020177c:	00003517          	auipc	a0,0x3
ffffffffc0201780:	52450513          	addi	a0,a0,1316 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201784:	97ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201788:	00003697          	auipc	a3,0x3
ffffffffc020178c:	69068693          	addi	a3,a3,1680 # ffffffffc0204e18 <commands+0x900>
ffffffffc0201790:	00003617          	auipc	a2,0x3
ffffffffc0201794:	61060613          	addi	a2,a2,1552 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201798:	19800593          	li	a1,408
ffffffffc020179c:	00003517          	auipc	a0,0x3
ffffffffc02017a0:	50450513          	addi	a0,a0,1284 # ffffffffc0204ca0 <commands+0x788>
ffffffffc02017a4:	95ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02017a8:	00003697          	auipc	a3,0x3
ffffffffc02017ac:	64868693          	addi	a3,a3,1608 # ffffffffc0204df0 <commands+0x8d8>
ffffffffc02017b0:	00003617          	auipc	a2,0x3
ffffffffc02017b4:	5f060613          	addi	a2,a2,1520 # ffffffffc0204da0 <commands+0x888>
ffffffffc02017b8:	19400593          	li	a1,404
ffffffffc02017bc:	00003517          	auipc	a0,0x3
ffffffffc02017c0:	4e450513          	addi	a0,a0,1252 # ffffffffc0204ca0 <commands+0x788>
ffffffffc02017c4:	93ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02017c8:	00003697          	auipc	a3,0x3
ffffffffc02017cc:	70868693          	addi	a3,a3,1800 # ffffffffc0204ed0 <commands+0x9b8>
ffffffffc02017d0:	00003617          	auipc	a2,0x3
ffffffffc02017d4:	5d060613          	addi	a2,a2,1488 # ffffffffc0204da0 <commands+0x888>
ffffffffc02017d8:	1a300593          	li	a1,419
ffffffffc02017dc:	00003517          	auipc	a0,0x3
ffffffffc02017e0:	4c450513          	addi	a0,a0,1220 # ffffffffc0204ca0 <commands+0x788>
ffffffffc02017e4:	91ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02017e8:	00003697          	auipc	a3,0x3
ffffffffc02017ec:	78868693          	addi	a3,a3,1928 # ffffffffc0204f70 <commands+0xa58>
ffffffffc02017f0:	00003617          	auipc	a2,0x3
ffffffffc02017f4:	5b060613          	addi	a2,a2,1456 # ffffffffc0204da0 <commands+0x888>
ffffffffc02017f8:	1a800593          	li	a1,424
ffffffffc02017fc:	00003517          	auipc	a0,0x3
ffffffffc0201800:	4a450513          	addi	a0,a0,1188 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201804:	8fffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201808:	00003697          	auipc	a3,0x3
ffffffffc020180c:	6a068693          	addi	a3,a3,1696 # ffffffffc0204ea8 <commands+0x990>
ffffffffc0201810:	00003617          	auipc	a2,0x3
ffffffffc0201814:	59060613          	addi	a2,a2,1424 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201818:	1a000593          	li	a1,416
ffffffffc020181c:	00003517          	auipc	a0,0x3
ffffffffc0201820:	48450513          	addi	a0,a0,1156 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201824:	8dffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201828:	86d6                	mv	a3,s5
ffffffffc020182a:	00003617          	auipc	a2,0x3
ffffffffc020182e:	44e60613          	addi	a2,a2,1102 # ffffffffc0204c78 <commands+0x760>
ffffffffc0201832:	19f00593          	li	a1,415
ffffffffc0201836:	00003517          	auipc	a0,0x3
ffffffffc020183a:	46a50513          	addi	a0,a0,1130 # ffffffffc0204ca0 <commands+0x788>
ffffffffc020183e:	8c5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201842:	00003697          	auipc	a3,0x3
ffffffffc0201846:	6c668693          	addi	a3,a3,1734 # ffffffffc0204f08 <commands+0x9f0>
ffffffffc020184a:	00003617          	auipc	a2,0x3
ffffffffc020184e:	55660613          	addi	a2,a2,1366 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201852:	1ad00593          	li	a1,429
ffffffffc0201856:	00003517          	auipc	a0,0x3
ffffffffc020185a:	44a50513          	addi	a0,a0,1098 # ffffffffc0204ca0 <commands+0x788>
ffffffffc020185e:	8a5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201862:	00003697          	auipc	a3,0x3
ffffffffc0201866:	76e68693          	addi	a3,a3,1902 # ffffffffc0204fd0 <commands+0xab8>
ffffffffc020186a:	00003617          	auipc	a2,0x3
ffffffffc020186e:	53660613          	addi	a2,a2,1334 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201872:	1ac00593          	li	a1,428
ffffffffc0201876:	00003517          	auipc	a0,0x3
ffffffffc020187a:	42a50513          	addi	a0,a0,1066 # ffffffffc0204ca0 <commands+0x788>
ffffffffc020187e:	885fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201882:	00003697          	auipc	a3,0x3
ffffffffc0201886:	73668693          	addi	a3,a3,1846 # ffffffffc0204fb8 <commands+0xaa0>
ffffffffc020188a:	00003617          	auipc	a2,0x3
ffffffffc020188e:	51660613          	addi	a2,a2,1302 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201892:	1ab00593          	li	a1,427
ffffffffc0201896:	00003517          	auipc	a0,0x3
ffffffffc020189a:	40a50513          	addi	a0,a0,1034 # ffffffffc0204ca0 <commands+0x788>
ffffffffc020189e:	865fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02018a2:	00003697          	auipc	a3,0x3
ffffffffc02018a6:	6e668693          	addi	a3,a3,1766 # ffffffffc0204f88 <commands+0xa70>
ffffffffc02018aa:	00003617          	auipc	a2,0x3
ffffffffc02018ae:	4f660613          	addi	a2,a2,1270 # ffffffffc0204da0 <commands+0x888>
ffffffffc02018b2:	1aa00593          	li	a1,426
ffffffffc02018b6:	00003517          	auipc	a0,0x3
ffffffffc02018ba:	3ea50513          	addi	a0,a0,1002 # ffffffffc0204ca0 <commands+0x788>
ffffffffc02018be:	845fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02018c2:	00004697          	auipc	a3,0x4
ffffffffc02018c6:	87e68693          	addi	a3,a3,-1922 # ffffffffc0205140 <commands+0xc28>
ffffffffc02018ca:	00003617          	auipc	a2,0x3
ffffffffc02018ce:	4d660613          	addi	a2,a2,1238 # ffffffffc0204da0 <commands+0x888>
ffffffffc02018d2:	1d800593          	li	a1,472
ffffffffc02018d6:	00003517          	auipc	a0,0x3
ffffffffc02018da:	3ca50513          	addi	a0,a0,970 # ffffffffc0204ca0 <commands+0x788>
ffffffffc02018de:	825fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02018e2:	00003697          	auipc	a3,0x3
ffffffffc02018e6:	67668693          	addi	a3,a3,1654 # ffffffffc0204f58 <commands+0xa40>
ffffffffc02018ea:	00003617          	auipc	a2,0x3
ffffffffc02018ee:	4b660613          	addi	a2,a2,1206 # ffffffffc0204da0 <commands+0x888>
ffffffffc02018f2:	1a700593          	li	a1,423
ffffffffc02018f6:	00003517          	auipc	a0,0x3
ffffffffc02018fa:	3aa50513          	addi	a0,a0,938 # ffffffffc0204ca0 <commands+0x788>
ffffffffc02018fe:	805fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201902:	00003697          	auipc	a3,0x3
ffffffffc0201906:	64668693          	addi	a3,a3,1606 # ffffffffc0204f48 <commands+0xa30>
ffffffffc020190a:	00003617          	auipc	a2,0x3
ffffffffc020190e:	49660613          	addi	a2,a2,1174 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201912:	1a600593          	li	a1,422
ffffffffc0201916:	00003517          	auipc	a0,0x3
ffffffffc020191a:	38a50513          	addi	a0,a0,906 # ffffffffc0204ca0 <commands+0x788>
ffffffffc020191e:	fe4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201922:	00003697          	auipc	a3,0x3
ffffffffc0201926:	71e68693          	addi	a3,a3,1822 # ffffffffc0205040 <commands+0xb28>
ffffffffc020192a:	00003617          	auipc	a2,0x3
ffffffffc020192e:	47660613          	addi	a2,a2,1142 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201932:	1e800593          	li	a1,488
ffffffffc0201936:	00003517          	auipc	a0,0x3
ffffffffc020193a:	36a50513          	addi	a0,a0,874 # ffffffffc0204ca0 <commands+0x788>
ffffffffc020193e:	fc4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201942:	00003697          	auipc	a3,0x3
ffffffffc0201946:	5f668693          	addi	a3,a3,1526 # ffffffffc0204f38 <commands+0xa20>
ffffffffc020194a:	00003617          	auipc	a2,0x3
ffffffffc020194e:	45660613          	addi	a2,a2,1110 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201952:	1a500593          	li	a1,421
ffffffffc0201956:	00003517          	auipc	a0,0x3
ffffffffc020195a:	34a50513          	addi	a0,a0,842 # ffffffffc0204ca0 <commands+0x788>
ffffffffc020195e:	fa4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201962:	00003697          	auipc	a3,0x3
ffffffffc0201966:	52e68693          	addi	a3,a3,1326 # ffffffffc0204e90 <commands+0x978>
ffffffffc020196a:	00003617          	auipc	a2,0x3
ffffffffc020196e:	43660613          	addi	a2,a2,1078 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201972:	1b200593          	li	a1,434
ffffffffc0201976:	00003517          	auipc	a0,0x3
ffffffffc020197a:	32a50513          	addi	a0,a0,810 # ffffffffc0204ca0 <commands+0x788>
ffffffffc020197e:	f84fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201982:	00003697          	auipc	a3,0x3
ffffffffc0201986:	66668693          	addi	a3,a3,1638 # ffffffffc0204fe8 <commands+0xad0>
ffffffffc020198a:	00003617          	auipc	a2,0x3
ffffffffc020198e:	41660613          	addi	a2,a2,1046 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201992:	1af00593          	li	a1,431
ffffffffc0201996:	00003517          	auipc	a0,0x3
ffffffffc020199a:	30a50513          	addi	a0,a0,778 # ffffffffc0204ca0 <commands+0x788>
ffffffffc020199e:	f64fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02019a2:	00003697          	auipc	a3,0x3
ffffffffc02019a6:	4d668693          	addi	a3,a3,1238 # ffffffffc0204e78 <commands+0x960>
ffffffffc02019aa:	00003617          	auipc	a2,0x3
ffffffffc02019ae:	3f660613          	addi	a2,a2,1014 # ffffffffc0204da0 <commands+0x888>
ffffffffc02019b2:	1ae00593          	li	a1,430
ffffffffc02019b6:	00003517          	auipc	a0,0x3
ffffffffc02019ba:	2ea50513          	addi	a0,a0,746 # ffffffffc0204ca0 <commands+0x788>
ffffffffc02019be:	f44fe0ef          	jal	ra,ffffffffc0200102 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02019c2:	00003617          	auipc	a2,0x3
ffffffffc02019c6:	2b660613          	addi	a2,a2,694 # ffffffffc0204c78 <commands+0x760>
ffffffffc02019ca:	06a00593          	li	a1,106
ffffffffc02019ce:	00003517          	auipc	a0,0x3
ffffffffc02019d2:	27250513          	addi	a0,a0,626 # ffffffffc0204c40 <commands+0x728>
ffffffffc02019d6:	f2cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02019da:	00003697          	auipc	a3,0x3
ffffffffc02019de:	63e68693          	addi	a3,a3,1598 # ffffffffc0205018 <commands+0xb00>
ffffffffc02019e2:	00003617          	auipc	a2,0x3
ffffffffc02019e6:	3be60613          	addi	a2,a2,958 # ffffffffc0204da0 <commands+0x888>
ffffffffc02019ea:	1b900593          	li	a1,441
ffffffffc02019ee:	00003517          	auipc	a0,0x3
ffffffffc02019f2:	2b250513          	addi	a0,a0,690 # ffffffffc0204ca0 <commands+0x788>
ffffffffc02019f6:	f0cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02019fa:	00003697          	auipc	a3,0x3
ffffffffc02019fe:	5d668693          	addi	a3,a3,1494 # ffffffffc0204fd0 <commands+0xab8>
ffffffffc0201a02:	00003617          	auipc	a2,0x3
ffffffffc0201a06:	39e60613          	addi	a2,a2,926 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201a0a:	1b700593          	li	a1,439
ffffffffc0201a0e:	00003517          	auipc	a0,0x3
ffffffffc0201a12:	29250513          	addi	a0,a0,658 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201a16:	eecfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201a1a:	00003697          	auipc	a3,0x3
ffffffffc0201a1e:	5e668693          	addi	a3,a3,1510 # ffffffffc0205000 <commands+0xae8>
ffffffffc0201a22:	00003617          	auipc	a2,0x3
ffffffffc0201a26:	37e60613          	addi	a2,a2,894 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201a2a:	1b600593          	li	a1,438
ffffffffc0201a2e:	00003517          	auipc	a0,0x3
ffffffffc0201a32:	27250513          	addi	a0,a0,626 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201a36:	eccfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201a3a:	00003697          	auipc	a3,0x3
ffffffffc0201a3e:	59668693          	addi	a3,a3,1430 # ffffffffc0204fd0 <commands+0xab8>
ffffffffc0201a42:	00003617          	auipc	a2,0x3
ffffffffc0201a46:	35e60613          	addi	a2,a2,862 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201a4a:	1b300593          	li	a1,435
ffffffffc0201a4e:	00003517          	auipc	a0,0x3
ffffffffc0201a52:	25250513          	addi	a0,a0,594 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201a56:	eacfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201a5a:	00003697          	auipc	a3,0x3
ffffffffc0201a5e:	6ce68693          	addi	a3,a3,1742 # ffffffffc0205128 <commands+0xc10>
ffffffffc0201a62:	00003617          	auipc	a2,0x3
ffffffffc0201a66:	33e60613          	addi	a2,a2,830 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201a6a:	1d700593          	li	a1,471
ffffffffc0201a6e:	00003517          	auipc	a0,0x3
ffffffffc0201a72:	23250513          	addi	a0,a0,562 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201a76:	e8cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201a7a:	00003697          	auipc	a3,0x3
ffffffffc0201a7e:	67668693          	addi	a3,a3,1654 # ffffffffc02050f0 <commands+0xbd8>
ffffffffc0201a82:	00003617          	auipc	a2,0x3
ffffffffc0201a86:	31e60613          	addi	a2,a2,798 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201a8a:	1d600593          	li	a1,470
ffffffffc0201a8e:	00003517          	auipc	a0,0x3
ffffffffc0201a92:	21250513          	addi	a0,a0,530 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201a96:	e6cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0201a9a:	00003697          	auipc	a3,0x3
ffffffffc0201a9e:	63e68693          	addi	a3,a3,1598 # ffffffffc02050d8 <commands+0xbc0>
ffffffffc0201aa2:	00003617          	auipc	a2,0x3
ffffffffc0201aa6:	2fe60613          	addi	a2,a2,766 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201aaa:	1d200593          	li	a1,466
ffffffffc0201aae:	00003517          	auipc	a0,0x3
ffffffffc0201ab2:	1f250513          	addi	a0,a0,498 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201ab6:	e4cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201aba:	00003697          	auipc	a3,0x3
ffffffffc0201abe:	58668693          	addi	a3,a3,1414 # ffffffffc0205040 <commands+0xb28>
ffffffffc0201ac2:	00003617          	auipc	a2,0x3
ffffffffc0201ac6:	2de60613          	addi	a2,a2,734 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201aca:	1c000593          	li	a1,448
ffffffffc0201ace:	00003517          	auipc	a0,0x3
ffffffffc0201ad2:	1d250513          	addi	a0,a0,466 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201ad6:	e2cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201ada:	00003697          	auipc	a3,0x3
ffffffffc0201ade:	39e68693          	addi	a3,a3,926 # ffffffffc0204e78 <commands+0x960>
ffffffffc0201ae2:	00003617          	auipc	a2,0x3
ffffffffc0201ae6:	2be60613          	addi	a2,a2,702 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201aea:	19b00593          	li	a1,411
ffffffffc0201aee:	00003517          	auipc	a0,0x3
ffffffffc0201af2:	1b250513          	addi	a0,a0,434 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201af6:	e0cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201afa:	00003617          	auipc	a2,0x3
ffffffffc0201afe:	17e60613          	addi	a2,a2,382 # ffffffffc0204c78 <commands+0x760>
ffffffffc0201b02:	19e00593          	li	a1,414
ffffffffc0201b06:	00003517          	auipc	a0,0x3
ffffffffc0201b0a:	19a50513          	addi	a0,a0,410 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201b0e:	df4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201b12:	00003697          	auipc	a3,0x3
ffffffffc0201b16:	37e68693          	addi	a3,a3,894 # ffffffffc0204e90 <commands+0x978>
ffffffffc0201b1a:	00003617          	auipc	a2,0x3
ffffffffc0201b1e:	28660613          	addi	a2,a2,646 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201b22:	19c00593          	li	a1,412
ffffffffc0201b26:	00003517          	auipc	a0,0x3
ffffffffc0201b2a:	17a50513          	addi	a0,a0,378 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201b2e:	dd4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201b32:	00003697          	auipc	a3,0x3
ffffffffc0201b36:	3d668693          	addi	a3,a3,982 # ffffffffc0204f08 <commands+0x9f0>
ffffffffc0201b3a:	00003617          	auipc	a2,0x3
ffffffffc0201b3e:	26660613          	addi	a2,a2,614 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201b42:	1a400593          	li	a1,420
ffffffffc0201b46:	00003517          	auipc	a0,0x3
ffffffffc0201b4a:	15a50513          	addi	a0,a0,346 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201b4e:	db4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201b52:	00003697          	auipc	a3,0x3
ffffffffc0201b56:	69668693          	addi	a3,a3,1686 # ffffffffc02051e8 <commands+0xcd0>
ffffffffc0201b5a:	00003617          	auipc	a2,0x3
ffffffffc0201b5e:	24660613          	addi	a2,a2,582 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201b62:	1e000593          	li	a1,480
ffffffffc0201b66:	00003517          	auipc	a0,0x3
ffffffffc0201b6a:	13a50513          	addi	a0,a0,314 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201b6e:	d94fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201b72:	00003697          	auipc	a3,0x3
ffffffffc0201b76:	63e68693          	addi	a3,a3,1598 # ffffffffc02051b0 <commands+0xc98>
ffffffffc0201b7a:	00003617          	auipc	a2,0x3
ffffffffc0201b7e:	22660613          	addi	a2,a2,550 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201b82:	1dd00593          	li	a1,477
ffffffffc0201b86:	00003517          	auipc	a0,0x3
ffffffffc0201b8a:	11a50513          	addi	a0,a0,282 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201b8e:	d74fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201b92:	00003697          	auipc	a3,0x3
ffffffffc0201b96:	5ee68693          	addi	a3,a3,1518 # ffffffffc0205180 <commands+0xc68>
ffffffffc0201b9a:	00003617          	auipc	a2,0x3
ffffffffc0201b9e:	20660613          	addi	a2,a2,518 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201ba2:	1d900593          	li	a1,473
ffffffffc0201ba6:	00003517          	auipc	a0,0x3
ffffffffc0201baa:	0fa50513          	addi	a0,a0,250 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201bae:	d54fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201bb2 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201bb2:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0201bb6:	8082                	ret

ffffffffc0201bb8 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201bb8:	7179                	addi	sp,sp,-48
ffffffffc0201bba:	e84a                	sd	s2,16(sp)
ffffffffc0201bbc:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0201bbe:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201bc0:	f022                	sd	s0,32(sp)
ffffffffc0201bc2:	ec26                	sd	s1,24(sp)
ffffffffc0201bc4:	e44e                	sd	s3,8(sp)
ffffffffc0201bc6:	f406                	sd	ra,40(sp)
ffffffffc0201bc8:	84ae                	mv	s1,a1
ffffffffc0201bca:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0201bcc:	eedfe0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0201bd0:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0201bd2:	cd09                	beqz	a0,ffffffffc0201bec <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0201bd4:	85aa                	mv	a1,a0
ffffffffc0201bd6:	86ce                	mv	a3,s3
ffffffffc0201bd8:	8626                	mv	a2,s1
ffffffffc0201bda:	854a                	mv	a0,s2
ffffffffc0201bdc:	ad2ff0ef          	jal	ra,ffffffffc0200eae <page_insert>
ffffffffc0201be0:	ed21                	bnez	a0,ffffffffc0201c38 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0201be2:	00010797          	auipc	a5,0x10
ffffffffc0201be6:	97e7a783          	lw	a5,-1666(a5) # ffffffffc0211560 <swap_init_ok>
ffffffffc0201bea:	eb89                	bnez	a5,ffffffffc0201bfc <pgdir_alloc_page+0x44>
}
ffffffffc0201bec:	70a2                	ld	ra,40(sp)
ffffffffc0201bee:	8522                	mv	a0,s0
ffffffffc0201bf0:	7402                	ld	s0,32(sp)
ffffffffc0201bf2:	64e2                	ld	s1,24(sp)
ffffffffc0201bf4:	6942                	ld	s2,16(sp)
ffffffffc0201bf6:	69a2                	ld	s3,8(sp)
ffffffffc0201bf8:	6145                	addi	sp,sp,48
ffffffffc0201bfa:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0201bfc:	4681                	li	a3,0
ffffffffc0201bfe:	8622                	mv	a2,s0
ffffffffc0201c00:	85a6                	mv	a1,s1
ffffffffc0201c02:	00010517          	auipc	a0,0x10
ffffffffc0201c06:	93e53503          	ld	a0,-1730(a0) # ffffffffc0211540 <check_mm_struct>
ffffffffc0201c0a:	0de010ef          	jal	ra,ffffffffc0202ce8 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0201c0e:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0201c10:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0201c12:	4785                	li	a5,1
ffffffffc0201c14:	fcf70ce3          	beq	a4,a5,ffffffffc0201bec <pgdir_alloc_page+0x34>
ffffffffc0201c18:	00003697          	auipc	a3,0x3
ffffffffc0201c1c:	61868693          	addi	a3,a3,1560 # ffffffffc0205230 <commands+0xd18>
ffffffffc0201c20:	00003617          	auipc	a2,0x3
ffffffffc0201c24:	18060613          	addi	a2,a2,384 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201c28:	17a00593          	li	a1,378
ffffffffc0201c2c:	00003517          	auipc	a0,0x3
ffffffffc0201c30:	07450513          	addi	a0,a0,116 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201c34:	ccefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c38:	100027f3          	csrr	a5,sstatus
ffffffffc0201c3c:	8b89                	andi	a5,a5,2
ffffffffc0201c3e:	eb99                	bnez	a5,ffffffffc0201c54 <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201c40:	00010797          	auipc	a5,0x10
ffffffffc0201c44:	8f07b783          	ld	a5,-1808(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201c48:	739c                	ld	a5,32(a5)
ffffffffc0201c4a:	8522                	mv	a0,s0
ffffffffc0201c4c:	4585                	li	a1,1
ffffffffc0201c4e:	9782                	jalr	a5
            return NULL;
ffffffffc0201c50:	4401                	li	s0,0
ffffffffc0201c52:	bf69                	j	ffffffffc0201bec <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0201c54:	877fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201c58:	00010797          	auipc	a5,0x10
ffffffffc0201c5c:	8d87b783          	ld	a5,-1832(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201c60:	739c                	ld	a5,32(a5)
ffffffffc0201c62:	8522                	mv	a0,s0
ffffffffc0201c64:	4585                	li	a1,1
ffffffffc0201c66:	9782                	jalr	a5
            return NULL;
ffffffffc0201c68:	4401                	li	s0,0
        intr_enable();
ffffffffc0201c6a:	85bfe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc0201c6e:	bfbd                	j	ffffffffc0201bec <pgdir_alloc_page+0x34>

ffffffffc0201c70 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0201c70:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201c72:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0201c74:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201c76:	fff50713          	addi	a4,a0,-1
ffffffffc0201c7a:	17f9                	addi	a5,a5,-2
ffffffffc0201c7c:	04e7ea63          	bltu	a5,a4,ffffffffc0201cd0 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0201c80:	6785                	lui	a5,0x1
ffffffffc0201c82:	17fd                	addi	a5,a5,-1
ffffffffc0201c84:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0201c86:	8131                	srli	a0,a0,0xc
ffffffffc0201c88:	e31fe0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
    assert(base != NULL);
ffffffffc0201c8c:	cd3d                	beqz	a0,ffffffffc0201d0a <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c8e:	00010797          	auipc	a5,0x10
ffffffffc0201c92:	89a7b783          	ld	a5,-1894(a5) # ffffffffc0211528 <pages>
ffffffffc0201c96:	8d1d                	sub	a0,a0,a5
ffffffffc0201c98:	00004697          	auipc	a3,0x4
ffffffffc0201c9c:	3a06b683          	ld	a3,928(a3) # ffffffffc0206038 <error_string+0x38>
ffffffffc0201ca0:	850d                	srai	a0,a0,0x3
ffffffffc0201ca2:	02d50533          	mul	a0,a0,a3
ffffffffc0201ca6:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201caa:	00010717          	auipc	a4,0x10
ffffffffc0201cae:	87673703          	ld	a4,-1930(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201cb2:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201cb4:	00c51793          	slli	a5,a0,0xc
ffffffffc0201cb8:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201cba:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201cbc:	02e7fa63          	bgeu	a5,a4,ffffffffc0201cf0 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0201cc0:	60a2                	ld	ra,8(sp)
ffffffffc0201cc2:	00010797          	auipc	a5,0x10
ffffffffc0201cc6:	8767b783          	ld	a5,-1930(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0201cca:	953e                	add	a0,a0,a5
ffffffffc0201ccc:	0141                	addi	sp,sp,16
ffffffffc0201cce:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201cd0:	00003697          	auipc	a3,0x3
ffffffffc0201cd4:	57868693          	addi	a3,a3,1400 # ffffffffc0205248 <commands+0xd30>
ffffffffc0201cd8:	00003617          	auipc	a2,0x3
ffffffffc0201cdc:	0c860613          	addi	a2,a2,200 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201ce0:	1f000593          	li	a1,496
ffffffffc0201ce4:	00003517          	auipc	a0,0x3
ffffffffc0201ce8:	fbc50513          	addi	a0,a0,-68 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201cec:	c16fe0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0201cf0:	86aa                	mv	a3,a0
ffffffffc0201cf2:	00003617          	auipc	a2,0x3
ffffffffc0201cf6:	f8660613          	addi	a2,a2,-122 # ffffffffc0204c78 <commands+0x760>
ffffffffc0201cfa:	06a00593          	li	a1,106
ffffffffc0201cfe:	00003517          	auipc	a0,0x3
ffffffffc0201d02:	f4250513          	addi	a0,a0,-190 # ffffffffc0204c40 <commands+0x728>
ffffffffc0201d06:	bfcfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(base != NULL);
ffffffffc0201d0a:	00003697          	auipc	a3,0x3
ffffffffc0201d0e:	55e68693          	addi	a3,a3,1374 # ffffffffc0205268 <commands+0xd50>
ffffffffc0201d12:	00003617          	auipc	a2,0x3
ffffffffc0201d16:	08e60613          	addi	a2,a2,142 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201d1a:	1f300593          	li	a1,499
ffffffffc0201d1e:	00003517          	auipc	a0,0x3
ffffffffc0201d22:	f8250513          	addi	a0,a0,-126 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201d26:	bdcfe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201d2a <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0201d2a:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201d2c:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0201d2e:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201d30:	fff58713          	addi	a4,a1,-1
ffffffffc0201d34:	17f9                	addi	a5,a5,-2
ffffffffc0201d36:	0ae7ee63          	bltu	a5,a4,ffffffffc0201df2 <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0201d3a:	cd41                	beqz	a0,ffffffffc0201dd2 <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0201d3c:	6785                	lui	a5,0x1
ffffffffc0201d3e:	17fd                	addi	a5,a5,-1
ffffffffc0201d40:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201d42:	c02007b7          	lui	a5,0xc0200
ffffffffc0201d46:	81b1                	srli	a1,a1,0xc
ffffffffc0201d48:	06f56863          	bltu	a0,a5,ffffffffc0201db8 <kfree+0x8e>
ffffffffc0201d4c:	0000f697          	auipc	a3,0xf
ffffffffc0201d50:	7ec6b683          	ld	a3,2028(a3) # ffffffffc0211538 <va_pa_offset>
ffffffffc0201d54:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d56:	8131                	srli	a0,a0,0xc
ffffffffc0201d58:	0000f797          	auipc	a5,0xf
ffffffffc0201d5c:	7c87b783          	ld	a5,1992(a5) # ffffffffc0211520 <npage>
ffffffffc0201d60:	04f57a63          	bgeu	a0,a5,ffffffffc0201db4 <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d64:	fff806b7          	lui	a3,0xfff80
ffffffffc0201d68:	9536                	add	a0,a0,a3
ffffffffc0201d6a:	00351793          	slli	a5,a0,0x3
ffffffffc0201d6e:	953e                	add	a0,a0,a5
ffffffffc0201d70:	050e                	slli	a0,a0,0x3
ffffffffc0201d72:	0000f797          	auipc	a5,0xf
ffffffffc0201d76:	7b67b783          	ld	a5,1974(a5) # ffffffffc0211528 <pages>
ffffffffc0201d7a:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d7c:	100027f3          	csrr	a5,sstatus
ffffffffc0201d80:	8b89                	andi	a5,a5,2
ffffffffc0201d82:	eb89                	bnez	a5,ffffffffc0201d94 <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201d84:	0000f797          	auipc	a5,0xf
ffffffffc0201d88:	7ac7b783          	ld	a5,1964(a5) # ffffffffc0211530 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0201d8c:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0201d8e:	739c                	ld	a5,32(a5)
}
ffffffffc0201d90:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc0201d92:	8782                	jr	a5
        intr_disable();
ffffffffc0201d94:	e42a                	sd	a0,8(sp)
ffffffffc0201d96:	e02e                	sd	a1,0(sp)
ffffffffc0201d98:	f32fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc0201d9c:	0000f797          	auipc	a5,0xf
ffffffffc0201da0:	7947b783          	ld	a5,1940(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201da4:	6582                	ld	a1,0(sp)
ffffffffc0201da6:	6522                	ld	a0,8(sp)
ffffffffc0201da8:	739c                	ld	a5,32(a5)
ffffffffc0201daa:	9782                	jalr	a5
}
ffffffffc0201dac:	60e2                	ld	ra,24(sp)
ffffffffc0201dae:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201db0:	f14fe06f          	j	ffffffffc02004c4 <intr_enable>
ffffffffc0201db4:	ccdfe0ef          	jal	ra,ffffffffc0200a80 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201db8:	86aa                	mv	a3,a0
ffffffffc0201dba:	00003617          	auipc	a2,0x3
ffffffffc0201dbe:	f7e60613          	addi	a2,a2,-130 # ffffffffc0204d38 <commands+0x820>
ffffffffc0201dc2:	06c00593          	li	a1,108
ffffffffc0201dc6:	00003517          	auipc	a0,0x3
ffffffffc0201dca:	e7a50513          	addi	a0,a0,-390 # ffffffffc0204c40 <commands+0x728>
ffffffffc0201dce:	b34fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(ptr != NULL);
ffffffffc0201dd2:	00003697          	auipc	a3,0x3
ffffffffc0201dd6:	4a668693          	addi	a3,a3,1190 # ffffffffc0205278 <commands+0xd60>
ffffffffc0201dda:	00003617          	auipc	a2,0x3
ffffffffc0201dde:	fc660613          	addi	a2,a2,-58 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201de2:	1fa00593          	li	a1,506
ffffffffc0201de6:	00003517          	auipc	a0,0x3
ffffffffc0201dea:	eba50513          	addi	a0,a0,-326 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201dee:	b14fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201df2:	00003697          	auipc	a3,0x3
ffffffffc0201df6:	45668693          	addi	a3,a3,1110 # ffffffffc0205248 <commands+0xd30>
ffffffffc0201dfa:	00003617          	auipc	a2,0x3
ffffffffc0201dfe:	fa660613          	addi	a2,a2,-90 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201e02:	1f900593          	li	a1,505
ffffffffc0201e06:	00003517          	auipc	a0,0x3
ffffffffc0201e0a:	e9a50513          	addi	a0,a0,-358 # ffffffffc0204ca0 <commands+0x788>
ffffffffc0201e0e:	af4fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201e12 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201e12:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0201e14:	00003697          	auipc	a3,0x3
ffffffffc0201e18:	47468693          	addi	a3,a3,1140 # ffffffffc0205288 <commands+0xd70>
ffffffffc0201e1c:	00003617          	auipc	a2,0x3
ffffffffc0201e20:	f8460613          	addi	a2,a2,-124 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201e24:	07d00593          	li	a1,125
ffffffffc0201e28:	00003517          	auipc	a0,0x3
ffffffffc0201e2c:	48050513          	addi	a0,a0,1152 # ffffffffc02052a8 <commands+0xd90>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201e30:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0201e32:	ad0fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201e36 <mm_create>:
mm_create(void) {
ffffffffc0201e36:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201e38:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0201e3c:	e022                	sd	s0,0(sp)
ffffffffc0201e3e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201e40:	e31ff0ef          	jal	ra,ffffffffc0201c70 <kmalloc>
ffffffffc0201e44:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201e46:	c105                	beqz	a0,ffffffffc0201e66 <mm_create+0x30>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201e48:	e408                	sd	a0,8(s0)
ffffffffc0201e4a:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0201e4c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201e50:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201e54:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201e58:	0000f797          	auipc	a5,0xf
ffffffffc0201e5c:	7087a783          	lw	a5,1800(a5) # ffffffffc0211560 <swap_init_ok>
ffffffffc0201e60:	eb81                	bnez	a5,ffffffffc0201e70 <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0201e62:	02053423          	sd	zero,40(a0)
}
ffffffffc0201e66:	60a2                	ld	ra,8(sp)
ffffffffc0201e68:	8522                	mv	a0,s0
ffffffffc0201e6a:	6402                	ld	s0,0(sp)
ffffffffc0201e6c:	0141                	addi	sp,sp,16
ffffffffc0201e6e:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201e70:	66d000ef          	jal	ra,ffffffffc0202cdc <swap_init_mm>
}
ffffffffc0201e74:	60a2                	ld	ra,8(sp)
ffffffffc0201e76:	8522                	mv	a0,s0
ffffffffc0201e78:	6402                	ld	s0,0(sp)
ffffffffc0201e7a:	0141                	addi	sp,sp,16
ffffffffc0201e7c:	8082                	ret

ffffffffc0201e7e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201e7e:	1101                	addi	sp,sp,-32
ffffffffc0201e80:	e04a                	sd	s2,0(sp)
ffffffffc0201e82:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201e84:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201e88:	e822                	sd	s0,16(sp)
ffffffffc0201e8a:	e426                	sd	s1,8(sp)
ffffffffc0201e8c:	ec06                	sd	ra,24(sp)
ffffffffc0201e8e:	84ae                	mv	s1,a1
ffffffffc0201e90:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201e92:	ddfff0ef          	jal	ra,ffffffffc0201c70 <kmalloc>
    if (vma != NULL) {
ffffffffc0201e96:	c509                	beqz	a0,ffffffffc0201ea0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0201e98:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201e9c:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201e9e:	ed00                	sd	s0,24(a0)
}
ffffffffc0201ea0:	60e2                	ld	ra,24(sp)
ffffffffc0201ea2:	6442                	ld	s0,16(sp)
ffffffffc0201ea4:	64a2                	ld	s1,8(sp)
ffffffffc0201ea6:	6902                	ld	s2,0(sp)
ffffffffc0201ea8:	6105                	addi	sp,sp,32
ffffffffc0201eaa:	8082                	ret

ffffffffc0201eac <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0201eac:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0201eae:	c505                	beqz	a0,ffffffffc0201ed6 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0201eb0:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201eb2:	c501                	beqz	a0,ffffffffc0201eba <find_vma+0xe>
ffffffffc0201eb4:	651c                	ld	a5,8(a0)
ffffffffc0201eb6:	02f5f263          	bgeu	a1,a5,ffffffffc0201eda <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201eba:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0201ebc:	00f68d63          	beq	a3,a5,ffffffffc0201ed6 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0201ec0:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201ec4:	00e5e663          	bltu	a1,a4,ffffffffc0201ed0 <find_vma+0x24>
ffffffffc0201ec8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201ecc:	00e5ec63          	bltu	a1,a4,ffffffffc0201ee4 <find_vma+0x38>
ffffffffc0201ed0:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0201ed2:	fef697e3          	bne	a3,a5,ffffffffc0201ec0 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0201ed6:	4501                	li	a0,0
}
ffffffffc0201ed8:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201eda:	691c                	ld	a5,16(a0)
ffffffffc0201edc:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0201eba <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0201ee0:	ea88                	sd	a0,16(a3)
ffffffffc0201ee2:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0201ee4:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0201ee8:	ea88                	sd	a0,16(a3)
ffffffffc0201eea:	8082                	ret

ffffffffc0201eec <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201eec:	6590                	ld	a2,8(a1)
ffffffffc0201eee:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0201ef2:	1141                	addi	sp,sp,-16
ffffffffc0201ef4:	e406                	sd	ra,8(sp)
ffffffffc0201ef6:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201ef8:	01066763          	bltu	a2,a6,ffffffffc0201f06 <insert_vma_struct+0x1a>
ffffffffc0201efc:	a085                	j	ffffffffc0201f5c <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201efe:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201f02:	04e66863          	bltu	a2,a4,ffffffffc0201f52 <insert_vma_struct+0x66>
ffffffffc0201f06:	86be                	mv	a3,a5
ffffffffc0201f08:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0201f0a:	fef51ae3          	bne	a0,a5,ffffffffc0201efe <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0201f0e:	02a68463          	beq	a3,a0,ffffffffc0201f36 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0201f12:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201f16:	fe86b883          	ld	a7,-24(a3)
ffffffffc0201f1a:	08e8f163          	bgeu	a7,a4,ffffffffc0201f9c <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201f1e:	04e66f63          	bltu	a2,a4,ffffffffc0201f7c <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0201f22:	00f50a63          	beq	a0,a5,ffffffffc0201f36 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201f26:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201f2a:	05076963          	bltu	a4,a6,ffffffffc0201f7c <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0201f2e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0201f32:	02c77363          	bgeu	a4,a2,ffffffffc0201f58 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0201f36:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0201f38:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201f3a:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201f3e:	e390                	sd	a2,0(a5)
ffffffffc0201f40:	e690                	sd	a2,8(a3)
}
ffffffffc0201f42:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0201f44:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201f46:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0201f48:	0017079b          	addiw	a5,a4,1
ffffffffc0201f4c:	d11c                	sw	a5,32(a0)
}
ffffffffc0201f4e:	0141                	addi	sp,sp,16
ffffffffc0201f50:	8082                	ret
    if (le_prev != list) {
ffffffffc0201f52:	fca690e3          	bne	a3,a0,ffffffffc0201f12 <insert_vma_struct+0x26>
ffffffffc0201f56:	bfd1                	j	ffffffffc0201f2a <insert_vma_struct+0x3e>
ffffffffc0201f58:	ebbff0ef          	jal	ra,ffffffffc0201e12 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201f5c:	00003697          	auipc	a3,0x3
ffffffffc0201f60:	35c68693          	addi	a3,a3,860 # ffffffffc02052b8 <commands+0xda0>
ffffffffc0201f64:	00003617          	auipc	a2,0x3
ffffffffc0201f68:	e3c60613          	addi	a2,a2,-452 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201f6c:	08400593          	li	a1,132
ffffffffc0201f70:	00003517          	auipc	a0,0x3
ffffffffc0201f74:	33850513          	addi	a0,a0,824 # ffffffffc02052a8 <commands+0xd90>
ffffffffc0201f78:	98afe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201f7c:	00003697          	auipc	a3,0x3
ffffffffc0201f80:	37c68693          	addi	a3,a3,892 # ffffffffc02052f8 <commands+0xde0>
ffffffffc0201f84:	00003617          	auipc	a2,0x3
ffffffffc0201f88:	e1c60613          	addi	a2,a2,-484 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201f8c:	07c00593          	li	a1,124
ffffffffc0201f90:	00003517          	auipc	a0,0x3
ffffffffc0201f94:	31850513          	addi	a0,a0,792 # ffffffffc02052a8 <commands+0xd90>
ffffffffc0201f98:	96afe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201f9c:	00003697          	auipc	a3,0x3
ffffffffc0201fa0:	33c68693          	addi	a3,a3,828 # ffffffffc02052d8 <commands+0xdc0>
ffffffffc0201fa4:	00003617          	auipc	a2,0x3
ffffffffc0201fa8:	dfc60613          	addi	a2,a2,-516 # ffffffffc0204da0 <commands+0x888>
ffffffffc0201fac:	07b00593          	li	a1,123
ffffffffc0201fb0:	00003517          	auipc	a0,0x3
ffffffffc0201fb4:	2f850513          	addi	a0,a0,760 # ffffffffc02052a8 <commands+0xd90>
ffffffffc0201fb8:	94afe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201fbc <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0201fbc:	1141                	addi	sp,sp,-16
ffffffffc0201fbe:	e022                	sd	s0,0(sp)
ffffffffc0201fc0:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0201fc2:	6508                	ld	a0,8(a0)
ffffffffc0201fc4:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0201fc6:	00a40e63          	beq	s0,a0,ffffffffc0201fe2 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201fca:	6118                	ld	a4,0(a0)
ffffffffc0201fcc:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0201fce:	03000593          	li	a1,48
ffffffffc0201fd2:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201fd4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201fd6:	e398                	sd	a4,0(a5)
ffffffffc0201fd8:	d53ff0ef          	jal	ra,ffffffffc0201d2a <kfree>
    return listelm->next;
ffffffffc0201fdc:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201fde:	fea416e3          	bne	s0,a0,ffffffffc0201fca <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201fe2:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201fe4:	6402                	ld	s0,0(sp)
ffffffffc0201fe6:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201fe8:	03000593          	li	a1,48
}
ffffffffc0201fec:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201fee:	bb35                	j	ffffffffc0201d2a <kfree>

ffffffffc0201ff0 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0201ff0:	715d                	addi	sp,sp,-80
ffffffffc0201ff2:	e486                	sd	ra,72(sp)
ffffffffc0201ff4:	f44e                	sd	s3,40(sp)
ffffffffc0201ff6:	f052                	sd	s4,32(sp)
ffffffffc0201ff8:	e0a2                	sd	s0,64(sp)
ffffffffc0201ffa:	fc26                	sd	s1,56(sp)
ffffffffc0201ffc:	f84a                	sd	s2,48(sp)
ffffffffc0201ffe:	ec56                	sd	s5,24(sp)
ffffffffc0202000:	e85a                	sd	s6,16(sp)
ffffffffc0202002:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202004:	b87fe0ef          	jal	ra,ffffffffc0200b8a <nr_free_pages>
ffffffffc0202008:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020200a:	b81fe0ef          	jal	ra,ffffffffc0200b8a <nr_free_pages>
ffffffffc020200e:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202010:	03000513          	li	a0,48
ffffffffc0202014:	c5dff0ef          	jal	ra,ffffffffc0201c70 <kmalloc>
    if (mm != NULL) {
ffffffffc0202018:	56050863          	beqz	a0,ffffffffc0202588 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc020201c:	e508                	sd	a0,8(a0)
ffffffffc020201e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0202020:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0202024:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0202028:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020202c:	0000f797          	auipc	a5,0xf
ffffffffc0202030:	5347a783          	lw	a5,1332(a5) # ffffffffc0211560 <swap_init_ok>
ffffffffc0202034:	84aa                	mv	s1,a0
ffffffffc0202036:	e7b9                	bnez	a5,ffffffffc0202084 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc0202038:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc020203c:	03200413          	li	s0,50
ffffffffc0202040:	a811                	j	ffffffffc0202054 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc0202042:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202044:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202046:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc020204a:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020204c:	8526                	mv	a0,s1
ffffffffc020204e:	e9fff0ef          	jal	ra,ffffffffc0201eec <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0202052:	cc05                	beqz	s0,ffffffffc020208a <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202054:	03000513          	li	a0,48
ffffffffc0202058:	c19ff0ef          	jal	ra,ffffffffc0201c70 <kmalloc>
ffffffffc020205c:	85aa                	mv	a1,a0
ffffffffc020205e:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0202062:	f165                	bnez	a0,ffffffffc0202042 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc0202064:	00003697          	auipc	a3,0x3
ffffffffc0202068:	4b468693          	addi	a3,a3,1204 # ffffffffc0205518 <commands+0x1000>
ffffffffc020206c:	00003617          	auipc	a2,0x3
ffffffffc0202070:	d3460613          	addi	a2,a2,-716 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202074:	0ce00593          	li	a1,206
ffffffffc0202078:	00003517          	auipc	a0,0x3
ffffffffc020207c:	23050513          	addi	a0,a0,560 # ffffffffc02052a8 <commands+0xd90>
ffffffffc0202080:	882fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202084:	459000ef          	jal	ra,ffffffffc0202cdc <swap_init_mm>
ffffffffc0202088:	bf55                	j	ffffffffc020203c <vmm_init+0x4c>
ffffffffc020208a:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020208e:	1f900913          	li	s2,505
ffffffffc0202092:	a819                	j	ffffffffc02020a8 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc0202094:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202096:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202098:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020209c:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020209e:	8526                	mv	a0,s1
ffffffffc02020a0:	e4dff0ef          	jal	ra,ffffffffc0201eec <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02020a4:	03240a63          	beq	s0,s2,ffffffffc02020d8 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02020a8:	03000513          	li	a0,48
ffffffffc02020ac:	bc5ff0ef          	jal	ra,ffffffffc0201c70 <kmalloc>
ffffffffc02020b0:	85aa                	mv	a1,a0
ffffffffc02020b2:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02020b6:	fd79                	bnez	a0,ffffffffc0202094 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc02020b8:	00003697          	auipc	a3,0x3
ffffffffc02020bc:	46068693          	addi	a3,a3,1120 # ffffffffc0205518 <commands+0x1000>
ffffffffc02020c0:	00003617          	auipc	a2,0x3
ffffffffc02020c4:	ce060613          	addi	a2,a2,-800 # ffffffffc0204da0 <commands+0x888>
ffffffffc02020c8:	0d400593          	li	a1,212
ffffffffc02020cc:	00003517          	auipc	a0,0x3
ffffffffc02020d0:	1dc50513          	addi	a0,a0,476 # ffffffffc02052a8 <commands+0xd90>
ffffffffc02020d4:	82efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    return listelm->next;
ffffffffc02020d8:	649c                	ld	a5,8(s1)
ffffffffc02020da:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02020dc:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02020e0:	2ef48463          	beq	s1,a5,ffffffffc02023c8 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02020e4:	fe87b603          	ld	a2,-24(a5)
ffffffffc02020e8:	ffe70693          	addi	a3,a4,-2
ffffffffc02020ec:	26d61e63          	bne	a2,a3,ffffffffc0202368 <vmm_init+0x378>
ffffffffc02020f0:	ff07b683          	ld	a3,-16(a5)
ffffffffc02020f4:	26e69a63          	bne	a3,a4,ffffffffc0202368 <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc02020f8:	0715                	addi	a4,a4,5
ffffffffc02020fa:	679c                	ld	a5,8(a5)
ffffffffc02020fc:	feb712e3          	bne	a4,a1,ffffffffc02020e0 <vmm_init+0xf0>
ffffffffc0202100:	4b1d                	li	s6,7
ffffffffc0202102:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202104:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202108:	85a2                	mv	a1,s0
ffffffffc020210a:	8526                	mv	a0,s1
ffffffffc020210c:	da1ff0ef          	jal	ra,ffffffffc0201eac <find_vma>
ffffffffc0202110:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0202112:	2c050b63          	beqz	a0,ffffffffc02023e8 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0202116:	00140593          	addi	a1,s0,1
ffffffffc020211a:	8526                	mv	a0,s1
ffffffffc020211c:	d91ff0ef          	jal	ra,ffffffffc0201eac <find_vma>
ffffffffc0202120:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0202122:	2e050363          	beqz	a0,ffffffffc0202408 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0202126:	85da                	mv	a1,s6
ffffffffc0202128:	8526                	mv	a0,s1
ffffffffc020212a:	d83ff0ef          	jal	ra,ffffffffc0201eac <find_vma>
        assert(vma3 == NULL);
ffffffffc020212e:	2e051d63          	bnez	a0,ffffffffc0202428 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0202132:	00340593          	addi	a1,s0,3
ffffffffc0202136:	8526                	mv	a0,s1
ffffffffc0202138:	d75ff0ef          	jal	ra,ffffffffc0201eac <find_vma>
        assert(vma4 == NULL);
ffffffffc020213c:	30051663          	bnez	a0,ffffffffc0202448 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0202140:	00440593          	addi	a1,s0,4
ffffffffc0202144:	8526                	mv	a0,s1
ffffffffc0202146:	d67ff0ef          	jal	ra,ffffffffc0201eac <find_vma>
        assert(vma5 == NULL);
ffffffffc020214a:	30051f63          	bnez	a0,ffffffffc0202468 <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020214e:	00893783          	ld	a5,8(s2)
ffffffffc0202152:	24879b63          	bne	a5,s0,ffffffffc02023a8 <vmm_init+0x3b8>
ffffffffc0202156:	01093783          	ld	a5,16(s2)
ffffffffc020215a:	25679763          	bne	a5,s6,ffffffffc02023a8 <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020215e:	008ab783          	ld	a5,8(s5)
ffffffffc0202162:	22879363          	bne	a5,s0,ffffffffc0202388 <vmm_init+0x398>
ffffffffc0202166:	010ab783          	ld	a5,16(s5)
ffffffffc020216a:	21679f63          	bne	a5,s6,ffffffffc0202388 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020216e:	0415                	addi	s0,s0,5
ffffffffc0202170:	0b15                	addi	s6,s6,5
ffffffffc0202172:	f9741be3          	bne	s0,s7,ffffffffc0202108 <vmm_init+0x118>
ffffffffc0202176:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0202178:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020217a:	85a2                	mv	a1,s0
ffffffffc020217c:	8526                	mv	a0,s1
ffffffffc020217e:	d2fff0ef          	jal	ra,ffffffffc0201eac <find_vma>
ffffffffc0202182:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0202186:	c90d                	beqz	a0,ffffffffc02021b8 <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0202188:	6914                	ld	a3,16(a0)
ffffffffc020218a:	6510                	ld	a2,8(a0)
ffffffffc020218c:	00003517          	auipc	a0,0x3
ffffffffc0202190:	28c50513          	addi	a0,a0,652 # ffffffffc0205418 <commands+0xf00>
ffffffffc0202194:	f27fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0202198:	00003697          	auipc	a3,0x3
ffffffffc020219c:	2a868693          	addi	a3,a3,680 # ffffffffc0205440 <commands+0xf28>
ffffffffc02021a0:	00003617          	auipc	a2,0x3
ffffffffc02021a4:	c0060613          	addi	a2,a2,-1024 # ffffffffc0204da0 <commands+0x888>
ffffffffc02021a8:	0f600593          	li	a1,246
ffffffffc02021ac:	00003517          	auipc	a0,0x3
ffffffffc02021b0:	0fc50513          	addi	a0,a0,252 # ffffffffc02052a8 <commands+0xd90>
ffffffffc02021b4:	f4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc02021b8:	147d                	addi	s0,s0,-1
ffffffffc02021ba:	fd2410e3          	bne	s0,s2,ffffffffc020217a <vmm_init+0x18a>
ffffffffc02021be:	a811                	j	ffffffffc02021d2 <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc02021c0:	6118                	ld	a4,0(a0)
ffffffffc02021c2:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc02021c4:	03000593          	li	a1,48
ffffffffc02021c8:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02021ca:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02021cc:	e398                	sd	a4,0(a5)
ffffffffc02021ce:	b5dff0ef          	jal	ra,ffffffffc0201d2a <kfree>
    return listelm->next;
ffffffffc02021d2:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc02021d4:	fea496e3          	bne	s1,a0,ffffffffc02021c0 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02021d8:	03000593          	li	a1,48
ffffffffc02021dc:	8526                	mv	a0,s1
ffffffffc02021de:	b4dff0ef          	jal	ra,ffffffffc0201d2a <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02021e2:	9a9fe0ef          	jal	ra,ffffffffc0200b8a <nr_free_pages>
ffffffffc02021e6:	3caa1163          	bne	s4,a0,ffffffffc02025a8 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02021ea:	00003517          	auipc	a0,0x3
ffffffffc02021ee:	29650513          	addi	a0,a0,662 # ffffffffc0205480 <commands+0xf68>
ffffffffc02021f2:	ec9fd0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02021f6:	995fe0ef          	jal	ra,ffffffffc0200b8a <nr_free_pages>
ffffffffc02021fa:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02021fc:	03000513          	li	a0,48
ffffffffc0202200:	a71ff0ef          	jal	ra,ffffffffc0201c70 <kmalloc>
ffffffffc0202204:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0202206:	2a050163          	beqz	a0,ffffffffc02024a8 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020220a:	0000f797          	auipc	a5,0xf
ffffffffc020220e:	3567a783          	lw	a5,854(a5) # ffffffffc0211560 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0202212:	e508                	sd	a0,8(a0)
ffffffffc0202214:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0202216:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020221a:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020221e:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202222:	14079063          	bnez	a5,ffffffffc0202362 <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc0202226:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020222a:	0000f917          	auipc	s2,0xf
ffffffffc020222e:	2ee93903          	ld	s2,750(s2) # ffffffffc0211518 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0202232:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0202236:	0000f717          	auipc	a4,0xf
ffffffffc020223a:	30873523          	sd	s0,778(a4) # ffffffffc0211540 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020223e:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0202242:	24079363          	bnez	a5,ffffffffc0202488 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202246:	03000513          	li	a0,48
ffffffffc020224a:	a27ff0ef          	jal	ra,ffffffffc0201c70 <kmalloc>
ffffffffc020224e:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0202250:	28050063          	beqz	a0,ffffffffc02024d0 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc0202254:	002007b7          	lui	a5,0x200
ffffffffc0202258:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc020225c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020225e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0202260:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0202264:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0202266:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc020226a:	c83ff0ef          	jal	ra,ffffffffc0201eec <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020226e:	10000593          	li	a1,256
ffffffffc0202272:	8522                	mv	a0,s0
ffffffffc0202274:	c39ff0ef          	jal	ra,ffffffffc0201eac <find_vma>
ffffffffc0202278:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc020227c:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0202280:	26aa1863          	bne	s4,a0,ffffffffc02024f0 <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc0202284:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0202288:	0785                	addi	a5,a5,1
ffffffffc020228a:	fee79de3          	bne	a5,a4,ffffffffc0202284 <vmm_init+0x294>
        sum += i;
ffffffffc020228e:	6705                	lui	a4,0x1
ffffffffc0202290:	10000793          	li	a5,256
ffffffffc0202294:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0202298:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020229c:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02022a0:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02022a2:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02022a4:	fec79ce3          	bne	a5,a2,ffffffffc020229c <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc02022a8:	26071463          	bnez	a4,ffffffffc0202510 <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02022ac:	4581                	li	a1,0
ffffffffc02022ae:	854a                	mv	a0,s2
ffffffffc02022b0:	b65fe0ef          	jal	ra,ffffffffc0200e14 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02022b4:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02022b8:	0000f717          	auipc	a4,0xf
ffffffffc02022bc:	26873703          	ld	a4,616(a4) # ffffffffc0211520 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc02022c0:	078a                	slli	a5,a5,0x2
ffffffffc02022c2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02022c4:	26e7f663          	bgeu	a5,a4,ffffffffc0202530 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc02022c8:	00004717          	auipc	a4,0x4
ffffffffc02022cc:	d7873703          	ld	a4,-648(a4) # ffffffffc0206040 <nbase>
ffffffffc02022d0:	8f99                	sub	a5,a5,a4
ffffffffc02022d2:	00379713          	slli	a4,a5,0x3
ffffffffc02022d6:	97ba                	add	a5,a5,a4
ffffffffc02022d8:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc02022da:	0000f517          	auipc	a0,0xf
ffffffffc02022de:	24e53503          	ld	a0,590(a0) # ffffffffc0211528 <pages>
ffffffffc02022e2:	953e                	add	a0,a0,a5
ffffffffc02022e4:	4585                	li	a1,1
ffffffffc02022e6:	865fe0ef          	jal	ra,ffffffffc0200b4a <free_pages>
    return listelm->next;
ffffffffc02022ea:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc02022ec:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc02022f0:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02022f4:	00a40e63          	beq	s0,a0,ffffffffc0202310 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc02022f8:	6118                	ld	a4,0(a0)
ffffffffc02022fa:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc02022fc:	03000593          	li	a1,48
ffffffffc0202300:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0202302:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202304:	e398                	sd	a4,0(a5)
ffffffffc0202306:	a25ff0ef          	jal	ra,ffffffffc0201d2a <kfree>
    return listelm->next;
ffffffffc020230a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020230c:	fea416e3          	bne	s0,a0,ffffffffc02022f8 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0202310:	03000593          	li	a1,48
ffffffffc0202314:	8522                	mv	a0,s0
ffffffffc0202316:	a15ff0ef          	jal	ra,ffffffffc0201d2a <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc020231a:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc020231c:	0000f797          	auipc	a5,0xf
ffffffffc0202320:	2207b223          	sd	zero,548(a5) # ffffffffc0211540 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202324:	867fe0ef          	jal	ra,ffffffffc0200b8a <nr_free_pages>
ffffffffc0202328:	22a49063          	bne	s1,a0,ffffffffc0202548 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020232c:	00003517          	auipc	a0,0x3
ffffffffc0202330:	1b450513          	addi	a0,a0,436 # ffffffffc02054e0 <commands+0xfc8>
ffffffffc0202334:	d87fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202338:	853fe0ef          	jal	ra,ffffffffc0200b8a <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc020233c:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020233e:	22a99563          	bne	s3,a0,ffffffffc0202568 <vmm_init+0x578>
}
ffffffffc0202342:	6406                	ld	s0,64(sp)
ffffffffc0202344:	60a6                	ld	ra,72(sp)
ffffffffc0202346:	74e2                	ld	s1,56(sp)
ffffffffc0202348:	7942                	ld	s2,48(sp)
ffffffffc020234a:	79a2                	ld	s3,40(sp)
ffffffffc020234c:	7a02                	ld	s4,32(sp)
ffffffffc020234e:	6ae2                	ld	s5,24(sp)
ffffffffc0202350:	6b42                	ld	s6,16(sp)
ffffffffc0202352:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202354:	00003517          	auipc	a0,0x3
ffffffffc0202358:	1ac50513          	addi	a0,a0,428 # ffffffffc0205500 <commands+0xfe8>
}
ffffffffc020235c:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc020235e:	d5dfd06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202362:	17b000ef          	jal	ra,ffffffffc0202cdc <swap_init_mm>
ffffffffc0202366:	b5d1                	j	ffffffffc020222a <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202368:	00003697          	auipc	a3,0x3
ffffffffc020236c:	fc868693          	addi	a3,a3,-56 # ffffffffc0205330 <commands+0xe18>
ffffffffc0202370:	00003617          	auipc	a2,0x3
ffffffffc0202374:	a3060613          	addi	a2,a2,-1488 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202378:	0dd00593          	li	a1,221
ffffffffc020237c:	00003517          	auipc	a0,0x3
ffffffffc0202380:	f2c50513          	addi	a0,a0,-212 # ffffffffc02052a8 <commands+0xd90>
ffffffffc0202384:	d7ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202388:	00003697          	auipc	a3,0x3
ffffffffc020238c:	06068693          	addi	a3,a3,96 # ffffffffc02053e8 <commands+0xed0>
ffffffffc0202390:	00003617          	auipc	a2,0x3
ffffffffc0202394:	a1060613          	addi	a2,a2,-1520 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202398:	0ee00593          	li	a1,238
ffffffffc020239c:	00003517          	auipc	a0,0x3
ffffffffc02023a0:	f0c50513          	addi	a0,a0,-244 # ffffffffc02052a8 <commands+0xd90>
ffffffffc02023a4:	d5ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02023a8:	00003697          	auipc	a3,0x3
ffffffffc02023ac:	01068693          	addi	a3,a3,16 # ffffffffc02053b8 <commands+0xea0>
ffffffffc02023b0:	00003617          	auipc	a2,0x3
ffffffffc02023b4:	9f060613          	addi	a2,a2,-1552 # ffffffffc0204da0 <commands+0x888>
ffffffffc02023b8:	0ed00593          	li	a1,237
ffffffffc02023bc:	00003517          	auipc	a0,0x3
ffffffffc02023c0:	eec50513          	addi	a0,a0,-276 # ffffffffc02052a8 <commands+0xd90>
ffffffffc02023c4:	d3ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02023c8:	00003697          	auipc	a3,0x3
ffffffffc02023cc:	f5068693          	addi	a3,a3,-176 # ffffffffc0205318 <commands+0xe00>
ffffffffc02023d0:	00003617          	auipc	a2,0x3
ffffffffc02023d4:	9d060613          	addi	a2,a2,-1584 # ffffffffc0204da0 <commands+0x888>
ffffffffc02023d8:	0db00593          	li	a1,219
ffffffffc02023dc:	00003517          	auipc	a0,0x3
ffffffffc02023e0:	ecc50513          	addi	a0,a0,-308 # ffffffffc02052a8 <commands+0xd90>
ffffffffc02023e4:	d1ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1 != NULL);
ffffffffc02023e8:	00003697          	auipc	a3,0x3
ffffffffc02023ec:	f8068693          	addi	a3,a3,-128 # ffffffffc0205368 <commands+0xe50>
ffffffffc02023f0:	00003617          	auipc	a2,0x3
ffffffffc02023f4:	9b060613          	addi	a2,a2,-1616 # ffffffffc0204da0 <commands+0x888>
ffffffffc02023f8:	0e300593          	li	a1,227
ffffffffc02023fc:	00003517          	auipc	a0,0x3
ffffffffc0202400:	eac50513          	addi	a0,a0,-340 # ffffffffc02052a8 <commands+0xd90>
ffffffffc0202404:	cfffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2 != NULL);
ffffffffc0202408:	00003697          	auipc	a3,0x3
ffffffffc020240c:	f7068693          	addi	a3,a3,-144 # ffffffffc0205378 <commands+0xe60>
ffffffffc0202410:	00003617          	auipc	a2,0x3
ffffffffc0202414:	99060613          	addi	a2,a2,-1648 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202418:	0e500593          	li	a1,229
ffffffffc020241c:	00003517          	auipc	a0,0x3
ffffffffc0202420:	e8c50513          	addi	a0,a0,-372 # ffffffffc02052a8 <commands+0xd90>
ffffffffc0202424:	cdffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma3 == NULL);
ffffffffc0202428:	00003697          	auipc	a3,0x3
ffffffffc020242c:	f6068693          	addi	a3,a3,-160 # ffffffffc0205388 <commands+0xe70>
ffffffffc0202430:	00003617          	auipc	a2,0x3
ffffffffc0202434:	97060613          	addi	a2,a2,-1680 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202438:	0e700593          	li	a1,231
ffffffffc020243c:	00003517          	auipc	a0,0x3
ffffffffc0202440:	e6c50513          	addi	a0,a0,-404 # ffffffffc02052a8 <commands+0xd90>
ffffffffc0202444:	cbffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma4 == NULL);
ffffffffc0202448:	00003697          	auipc	a3,0x3
ffffffffc020244c:	f5068693          	addi	a3,a3,-176 # ffffffffc0205398 <commands+0xe80>
ffffffffc0202450:	00003617          	auipc	a2,0x3
ffffffffc0202454:	95060613          	addi	a2,a2,-1712 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202458:	0e900593          	li	a1,233
ffffffffc020245c:	00003517          	auipc	a0,0x3
ffffffffc0202460:	e4c50513          	addi	a0,a0,-436 # ffffffffc02052a8 <commands+0xd90>
ffffffffc0202464:	c9ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma5 == NULL);
ffffffffc0202468:	00003697          	auipc	a3,0x3
ffffffffc020246c:	f4068693          	addi	a3,a3,-192 # ffffffffc02053a8 <commands+0xe90>
ffffffffc0202470:	00003617          	auipc	a2,0x3
ffffffffc0202474:	93060613          	addi	a2,a2,-1744 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202478:	0eb00593          	li	a1,235
ffffffffc020247c:	00003517          	auipc	a0,0x3
ffffffffc0202480:	e2c50513          	addi	a0,a0,-468 # ffffffffc02052a8 <commands+0xd90>
ffffffffc0202484:	c7ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202488:	00003697          	auipc	a3,0x3
ffffffffc020248c:	01868693          	addi	a3,a3,24 # ffffffffc02054a0 <commands+0xf88>
ffffffffc0202490:	00003617          	auipc	a2,0x3
ffffffffc0202494:	91060613          	addi	a2,a2,-1776 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202498:	10d00593          	li	a1,269
ffffffffc020249c:	00003517          	auipc	a0,0x3
ffffffffc02024a0:	e0c50513          	addi	a0,a0,-500 # ffffffffc02052a8 <commands+0xd90>
ffffffffc02024a4:	c5ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02024a8:	00003697          	auipc	a3,0x3
ffffffffc02024ac:	08068693          	addi	a3,a3,128 # ffffffffc0205528 <commands+0x1010>
ffffffffc02024b0:	00003617          	auipc	a2,0x3
ffffffffc02024b4:	8f060613          	addi	a2,a2,-1808 # ffffffffc0204da0 <commands+0x888>
ffffffffc02024b8:	10a00593          	li	a1,266
ffffffffc02024bc:	00003517          	auipc	a0,0x3
ffffffffc02024c0:	dec50513          	addi	a0,a0,-532 # ffffffffc02052a8 <commands+0xd90>
    check_mm_struct = mm_create();
ffffffffc02024c4:	0000f797          	auipc	a5,0xf
ffffffffc02024c8:	0607be23          	sd	zero,124(a5) # ffffffffc0211540 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc02024cc:	c37fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(vma != NULL);
ffffffffc02024d0:	00003697          	auipc	a3,0x3
ffffffffc02024d4:	04868693          	addi	a3,a3,72 # ffffffffc0205518 <commands+0x1000>
ffffffffc02024d8:	00003617          	auipc	a2,0x3
ffffffffc02024dc:	8c860613          	addi	a2,a2,-1848 # ffffffffc0204da0 <commands+0x888>
ffffffffc02024e0:	11100593          	li	a1,273
ffffffffc02024e4:	00003517          	auipc	a0,0x3
ffffffffc02024e8:	dc450513          	addi	a0,a0,-572 # ffffffffc02052a8 <commands+0xd90>
ffffffffc02024ec:	c17fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02024f0:	00003697          	auipc	a3,0x3
ffffffffc02024f4:	fc068693          	addi	a3,a3,-64 # ffffffffc02054b0 <commands+0xf98>
ffffffffc02024f8:	00003617          	auipc	a2,0x3
ffffffffc02024fc:	8a860613          	addi	a2,a2,-1880 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202500:	11600593          	li	a1,278
ffffffffc0202504:	00003517          	auipc	a0,0x3
ffffffffc0202508:	da450513          	addi	a0,a0,-604 # ffffffffc02052a8 <commands+0xd90>
ffffffffc020250c:	bf7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(sum == 0);
ffffffffc0202510:	00003697          	auipc	a3,0x3
ffffffffc0202514:	fc068693          	addi	a3,a3,-64 # ffffffffc02054d0 <commands+0xfb8>
ffffffffc0202518:	00003617          	auipc	a2,0x3
ffffffffc020251c:	88860613          	addi	a2,a2,-1912 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202520:	12000593          	li	a1,288
ffffffffc0202524:	00003517          	auipc	a0,0x3
ffffffffc0202528:	d8450513          	addi	a0,a0,-636 # ffffffffc02052a8 <commands+0xd90>
ffffffffc020252c:	bd7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202530:	00002617          	auipc	a2,0x2
ffffffffc0202534:	6f060613          	addi	a2,a2,1776 # ffffffffc0204c20 <commands+0x708>
ffffffffc0202538:	06500593          	li	a1,101
ffffffffc020253c:	00002517          	auipc	a0,0x2
ffffffffc0202540:	70450513          	addi	a0,a0,1796 # ffffffffc0204c40 <commands+0x728>
ffffffffc0202544:	bbffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202548:	00003697          	auipc	a3,0x3
ffffffffc020254c:	f1068693          	addi	a3,a3,-240 # ffffffffc0205458 <commands+0xf40>
ffffffffc0202550:	00003617          	auipc	a2,0x3
ffffffffc0202554:	85060613          	addi	a2,a2,-1968 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202558:	12e00593          	li	a1,302
ffffffffc020255c:	00003517          	auipc	a0,0x3
ffffffffc0202560:	d4c50513          	addi	a0,a0,-692 # ffffffffc02052a8 <commands+0xd90>
ffffffffc0202564:	b9ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202568:	00003697          	auipc	a3,0x3
ffffffffc020256c:	ef068693          	addi	a3,a3,-272 # ffffffffc0205458 <commands+0xf40>
ffffffffc0202570:	00003617          	auipc	a2,0x3
ffffffffc0202574:	83060613          	addi	a2,a2,-2000 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202578:	0bd00593          	li	a1,189
ffffffffc020257c:	00003517          	auipc	a0,0x3
ffffffffc0202580:	d2c50513          	addi	a0,a0,-724 # ffffffffc02052a8 <commands+0xd90>
ffffffffc0202584:	b7ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(mm != NULL);
ffffffffc0202588:	00003697          	auipc	a3,0x3
ffffffffc020258c:	fb868693          	addi	a3,a3,-72 # ffffffffc0205540 <commands+0x1028>
ffffffffc0202590:	00003617          	auipc	a2,0x3
ffffffffc0202594:	81060613          	addi	a2,a2,-2032 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202598:	0c700593          	li	a1,199
ffffffffc020259c:	00003517          	auipc	a0,0x3
ffffffffc02025a0:	d0c50513          	addi	a0,a0,-756 # ffffffffc02052a8 <commands+0xd90>
ffffffffc02025a4:	b5ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02025a8:	00003697          	auipc	a3,0x3
ffffffffc02025ac:	eb068693          	addi	a3,a3,-336 # ffffffffc0205458 <commands+0xf40>
ffffffffc02025b0:	00002617          	auipc	a2,0x2
ffffffffc02025b4:	7f060613          	addi	a2,a2,2032 # ffffffffc0204da0 <commands+0x888>
ffffffffc02025b8:	0fb00593          	li	a1,251
ffffffffc02025bc:	00003517          	auipc	a0,0x3
ffffffffc02025c0:	cec50513          	addi	a0,a0,-788 # ffffffffc02052a8 <commands+0xd90>
ffffffffc02025c4:	b3ffd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02025c8 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02025c8:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02025ca:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02025cc:	e822                	sd	s0,16(sp)
ffffffffc02025ce:	e426                	sd	s1,8(sp)
ffffffffc02025d0:	ec06                	sd	ra,24(sp)
ffffffffc02025d2:	e04a                	sd	s2,0(sp)
ffffffffc02025d4:	8432                	mv	s0,a2
ffffffffc02025d6:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02025d8:	8d5ff0ef          	jal	ra,ffffffffc0201eac <find_vma>

    pgfault_num++;
ffffffffc02025dc:	0000f797          	auipc	a5,0xf
ffffffffc02025e0:	f6c7a783          	lw	a5,-148(a5) # ffffffffc0211548 <pgfault_num>
ffffffffc02025e4:	2785                	addiw	a5,a5,1
ffffffffc02025e6:	0000f717          	auipc	a4,0xf
ffffffffc02025ea:	f6f72123          	sw	a5,-158(a4) # ffffffffc0211548 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02025ee:	c929                	beqz	a0,ffffffffc0202640 <do_pgfault+0x78>
ffffffffc02025f0:	651c                	ld	a5,8(a0)
ffffffffc02025f2:	04f46763          	bltu	s0,a5,ffffffffc0202640 <do_pgfault+0x78>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02025f6:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02025f8:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02025fa:	8b89                	andi	a5,a5,2
ffffffffc02025fc:	e395                	bnez	a5,ffffffffc0202620 <do_pgfault+0x58>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02025fe:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0202600:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202602:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0202604:	85a2                	mv	a1,s0
ffffffffc0202606:	4605                	li	a2,1
ffffffffc0202608:	dbcfe0ef          	jal	ra,ffffffffc0200bc4 <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc020260c:	610c                	ld	a1,0(a0)
ffffffffc020260e:	c999                	beqz	a1,ffffffffc0202624 <do_pgfault+0x5c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0202610:	0000f797          	auipc	a5,0xf
ffffffffc0202614:	f507a783          	lw	a5,-176(a5) # ffffffffc0211560 <swap_init_ok>
ffffffffc0202618:	cf8d                	beqz	a5,ffffffffc0202652 <do_pgfault+0x8a>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc020261a:	04003023          	sd	zero,64(zero) # 40 <kern_entry-0xffffffffc01fffc0>
ffffffffc020261e:	9002                	ebreak
        perm |= (PTE_R | PTE_W);
ffffffffc0202620:	4959                	li	s2,22
ffffffffc0202622:	bff1                	j	ffffffffc02025fe <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202624:	6c88                	ld	a0,24(s1)
ffffffffc0202626:	864a                	mv	a2,s2
ffffffffc0202628:	85a2                	mv	a1,s0
ffffffffc020262a:	d8eff0ef          	jal	ra,ffffffffc0201bb8 <pgdir_alloc_page>
ffffffffc020262e:	87aa                	mv	a5,a0
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0202630:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202632:	cb85                	beqz	a5,ffffffffc0202662 <do_pgfault+0x9a>
failed:
    return ret;
}
ffffffffc0202634:	60e2                	ld	ra,24(sp)
ffffffffc0202636:	6442                	ld	s0,16(sp)
ffffffffc0202638:	64a2                	ld	s1,8(sp)
ffffffffc020263a:	6902                	ld	s2,0(sp)
ffffffffc020263c:	6105                	addi	sp,sp,32
ffffffffc020263e:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0202640:	85a2                	mv	a1,s0
ffffffffc0202642:	00003517          	auipc	a0,0x3
ffffffffc0202646:	f0e50513          	addi	a0,a0,-242 # ffffffffc0205550 <commands+0x1038>
ffffffffc020264a:	a71fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc020264e:	5575                	li	a0,-3
        goto failed;
ffffffffc0202650:	b7d5                	j	ffffffffc0202634 <do_pgfault+0x6c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0202652:	00003517          	auipc	a0,0x3
ffffffffc0202656:	f5650513          	addi	a0,a0,-170 # ffffffffc02055a8 <commands+0x1090>
ffffffffc020265a:	a61fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc020265e:	5571                	li	a0,-4
            goto failed;
ffffffffc0202660:	bfd1                	j	ffffffffc0202634 <do_pgfault+0x6c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0202662:	00003517          	auipc	a0,0x3
ffffffffc0202666:	f1e50513          	addi	a0,a0,-226 # ffffffffc0205580 <commands+0x1068>
ffffffffc020266a:	a51fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc020266e:	5571                	li	a0,-4
            goto failed;
ffffffffc0202670:	b7d1                	j	ffffffffc0202634 <do_pgfault+0x6c>

ffffffffc0202672 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202672:	7135                	addi	sp,sp,-160
ffffffffc0202674:	ed06                	sd	ra,152(sp)
ffffffffc0202676:	e922                	sd	s0,144(sp)
ffffffffc0202678:	e526                	sd	s1,136(sp)
ffffffffc020267a:	e14a                	sd	s2,128(sp)
ffffffffc020267c:	fcce                	sd	s3,120(sp)
ffffffffc020267e:	f8d2                	sd	s4,112(sp)
ffffffffc0202680:	f4d6                	sd	s5,104(sp)
ffffffffc0202682:	f0da                	sd	s6,96(sp)
ffffffffc0202684:	ecde                	sd	s7,88(sp)
ffffffffc0202686:	e8e2                	sd	s8,80(sp)
ffffffffc0202688:	e4e6                	sd	s9,72(sp)
ffffffffc020268a:	e0ea                	sd	s10,64(sp)
ffffffffc020268c:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc020268e:	5f6010ef          	jal	ra,ffffffffc0203c84 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202692:	0000f697          	auipc	a3,0xf
ffffffffc0202696:	ebe6b683          	ld	a3,-322(a3) # ffffffffc0211550 <max_swap_offset>
ffffffffc020269a:	010007b7          	lui	a5,0x1000
ffffffffc020269e:	ff968713          	addi	a4,a3,-7
ffffffffc02026a2:	17e1                	addi	a5,a5,-8
ffffffffc02026a4:	3ee7e063          	bltu	a5,a4,ffffffffc0202a84 <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02026a8:	00008797          	auipc	a5,0x8
ffffffffc02026ac:	95878793          	addi	a5,a5,-1704 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc02026b0:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02026b2:	0000fb17          	auipc	s6,0xf
ffffffffc02026b6:	ea6b0b13          	addi	s6,s6,-346 # ffffffffc0211558 <sm>
ffffffffc02026ba:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc02026be:	9702                	jalr	a4
ffffffffc02026c0:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc02026c2:	c10d                	beqz	a0,ffffffffc02026e4 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02026c4:	60ea                	ld	ra,152(sp)
ffffffffc02026c6:	644a                	ld	s0,144(sp)
ffffffffc02026c8:	64aa                	ld	s1,136(sp)
ffffffffc02026ca:	690a                	ld	s2,128(sp)
ffffffffc02026cc:	7a46                	ld	s4,112(sp)
ffffffffc02026ce:	7aa6                	ld	s5,104(sp)
ffffffffc02026d0:	7b06                	ld	s6,96(sp)
ffffffffc02026d2:	6be6                	ld	s7,88(sp)
ffffffffc02026d4:	6c46                	ld	s8,80(sp)
ffffffffc02026d6:	6ca6                	ld	s9,72(sp)
ffffffffc02026d8:	6d06                	ld	s10,64(sp)
ffffffffc02026da:	7de2                	ld	s11,56(sp)
ffffffffc02026dc:	854e                	mv	a0,s3
ffffffffc02026de:	79e6                	ld	s3,120(sp)
ffffffffc02026e0:	610d                	addi	sp,sp,160
ffffffffc02026e2:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02026e4:	000b3783          	ld	a5,0(s6)
ffffffffc02026e8:	00003517          	auipc	a0,0x3
ffffffffc02026ec:	f1850513          	addi	a0,a0,-232 # ffffffffc0205600 <commands+0x10e8>
ffffffffc02026f0:	0000f497          	auipc	s1,0xf
ffffffffc02026f4:	9e048493          	addi	s1,s1,-1568 # ffffffffc02110d0 <free_area>
ffffffffc02026f8:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02026fa:	4785                	li	a5,1
ffffffffc02026fc:	0000f717          	auipc	a4,0xf
ffffffffc0202700:	e6f72223          	sw	a5,-412(a4) # ffffffffc0211560 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202704:	9b7fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0202708:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc020270a:	4401                	li	s0,0
ffffffffc020270c:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020270e:	2c978163          	beq	a5,s1,ffffffffc02029d0 <swap_init+0x35e>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202712:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202716:	8b09                	andi	a4,a4,2
ffffffffc0202718:	2a070e63          	beqz	a4,ffffffffc02029d4 <swap_init+0x362>
        count ++, total += p->property;
ffffffffc020271c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202720:	679c                	ld	a5,8(a5)
ffffffffc0202722:	2d05                	addiw	s10,s10,1
ffffffffc0202724:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202726:	fe9796e3          	bne	a5,s1,ffffffffc0202712 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc020272a:	8922                	mv	s2,s0
ffffffffc020272c:	c5efe0ef          	jal	ra,ffffffffc0200b8a <nr_free_pages>
ffffffffc0202730:	47251663          	bne	a0,s2,ffffffffc0202b9c <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202734:	8622                	mv	a2,s0
ffffffffc0202736:	85ea                	mv	a1,s10
ffffffffc0202738:	00003517          	auipc	a0,0x3
ffffffffc020273c:	f1050513          	addi	a0,a0,-240 # ffffffffc0205648 <commands+0x1130>
ffffffffc0202740:	97bfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202744:	ef2ff0ef          	jal	ra,ffffffffc0201e36 <mm_create>
ffffffffc0202748:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc020274a:	52050963          	beqz	a0,ffffffffc0202c7c <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020274e:	0000f797          	auipc	a5,0xf
ffffffffc0202752:	df278793          	addi	a5,a5,-526 # ffffffffc0211540 <check_mm_struct>
ffffffffc0202756:	6398                	ld	a4,0(a5)
ffffffffc0202758:	54071263          	bnez	a4,ffffffffc0202c9c <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020275c:	0000fb97          	auipc	s7,0xf
ffffffffc0202760:	dbcbbb83          	ld	s7,-580(s7) # ffffffffc0211518 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0202764:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc0202768:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020276a:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc020276e:	3c071763          	bnez	a4,ffffffffc0202b3c <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202772:	6599                	lui	a1,0x6
ffffffffc0202774:	460d                	li	a2,3
ffffffffc0202776:	6505                	lui	a0,0x1
ffffffffc0202778:	f06ff0ef          	jal	ra,ffffffffc0201e7e <vma_create>
ffffffffc020277c:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc020277e:	3c050f63          	beqz	a0,ffffffffc0202b5c <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0202782:	8556                	mv	a0,s5
ffffffffc0202784:	f68ff0ef          	jal	ra,ffffffffc0201eec <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202788:	00003517          	auipc	a0,0x3
ffffffffc020278c:	f0050513          	addi	a0,a0,-256 # ffffffffc0205688 <commands+0x1170>
ffffffffc0202790:	92bfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202794:	018ab503          	ld	a0,24(s5)
ffffffffc0202798:	4605                	li	a2,1
ffffffffc020279a:	6585                	lui	a1,0x1
ffffffffc020279c:	c28fe0ef          	jal	ra,ffffffffc0200bc4 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02027a0:	3c050e63          	beqz	a0,ffffffffc0202b7c <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02027a4:	00003517          	auipc	a0,0x3
ffffffffc02027a8:	f3450513          	addi	a0,a0,-204 # ffffffffc02056d8 <commands+0x11c0>
ffffffffc02027ac:	0000f917          	auipc	s2,0xf
ffffffffc02027b0:	8b490913          	addi	s2,s2,-1868 # ffffffffc0211060 <check_rp>
ffffffffc02027b4:	907fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02027b8:	0000fa17          	auipc	s4,0xf
ffffffffc02027bc:	8c8a0a13          	addi	s4,s4,-1848 # ffffffffc0211080 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02027c0:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc02027c2:	4505                	li	a0,1
ffffffffc02027c4:	af4fe0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc02027c8:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02027cc:	28050c63          	beqz	a0,ffffffffc0202a64 <swap_init+0x3f2>
ffffffffc02027d0:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02027d2:	8b89                	andi	a5,a5,2
ffffffffc02027d4:	26079863          	bnez	a5,ffffffffc0202a44 <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02027d8:	0c21                	addi	s8,s8,8
ffffffffc02027da:	ff4c14e3          	bne	s8,s4,ffffffffc02027c2 <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02027de:	609c                	ld	a5,0(s1)
ffffffffc02027e0:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc02027e4:	e084                	sd	s1,0(s1)
ffffffffc02027e6:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc02027e8:	489c                	lw	a5,16(s1)
ffffffffc02027ea:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc02027ec:	0000fc17          	auipc	s8,0xf
ffffffffc02027f0:	874c0c13          	addi	s8,s8,-1932 # ffffffffc0211060 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc02027f4:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02027f6:	0000f797          	auipc	a5,0xf
ffffffffc02027fa:	8e07a523          	sw	zero,-1814(a5) # ffffffffc02110e0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02027fe:	000c3503          	ld	a0,0(s8)
ffffffffc0202802:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202804:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc0202806:	b44fe0ef          	jal	ra,ffffffffc0200b4a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020280a:	ff4c1ae3          	bne	s8,s4,ffffffffc02027fe <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020280e:	0104ac03          	lw	s8,16(s1)
ffffffffc0202812:	4791                	li	a5,4
ffffffffc0202814:	4afc1463          	bne	s8,a5,ffffffffc0202cbc <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202818:	00003517          	auipc	a0,0x3
ffffffffc020281c:	f4850513          	addi	a0,a0,-184 # ffffffffc0205760 <commands+0x1248>
ffffffffc0202820:	89bfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202824:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202826:	0000f797          	auipc	a5,0xf
ffffffffc020282a:	d207a123          	sw	zero,-734(a5) # ffffffffc0211548 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020282e:	4529                	li	a0,10
ffffffffc0202830:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202834:	0000f597          	auipc	a1,0xf
ffffffffc0202838:	d145a583          	lw	a1,-748(a1) # ffffffffc0211548 <pgfault_num>
ffffffffc020283c:	4805                	li	a6,1
ffffffffc020283e:	0000f797          	auipc	a5,0xf
ffffffffc0202842:	d0a78793          	addi	a5,a5,-758 # ffffffffc0211548 <pgfault_num>
ffffffffc0202846:	3f059b63          	bne	a1,a6,ffffffffc0202c3c <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020284a:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc020284e:	4390                	lw	a2,0(a5)
ffffffffc0202850:	2601                	sext.w	a2,a2
ffffffffc0202852:	40b61563          	bne	a2,a1,ffffffffc0202c5c <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202856:	6589                	lui	a1,0x2
ffffffffc0202858:	452d                	li	a0,11
ffffffffc020285a:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc020285e:	4390                	lw	a2,0(a5)
ffffffffc0202860:	4809                	li	a6,2
ffffffffc0202862:	2601                	sext.w	a2,a2
ffffffffc0202864:	35061c63          	bne	a2,a6,ffffffffc0202bbc <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202868:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc020286c:	438c                	lw	a1,0(a5)
ffffffffc020286e:	2581                	sext.w	a1,a1
ffffffffc0202870:	36c59663          	bne	a1,a2,ffffffffc0202bdc <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202874:	658d                	lui	a1,0x3
ffffffffc0202876:	4531                	li	a0,12
ffffffffc0202878:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc020287c:	4390                	lw	a2,0(a5)
ffffffffc020287e:	480d                	li	a6,3
ffffffffc0202880:	2601                	sext.w	a2,a2
ffffffffc0202882:	37061d63          	bne	a2,a6,ffffffffc0202bfc <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202886:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc020288a:	438c                	lw	a1,0(a5)
ffffffffc020288c:	2581                	sext.w	a1,a1
ffffffffc020288e:	38c59763          	bne	a1,a2,ffffffffc0202c1c <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202892:	6591                	lui	a1,0x4
ffffffffc0202894:	4535                	li	a0,13
ffffffffc0202896:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc020289a:	4390                	lw	a2,0(a5)
ffffffffc020289c:	2601                	sext.w	a2,a2
ffffffffc020289e:	21861f63          	bne	a2,s8,ffffffffc0202abc <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02028a2:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc02028a6:	439c                	lw	a5,0(a5)
ffffffffc02028a8:	2781                	sext.w	a5,a5
ffffffffc02028aa:	22c79963          	bne	a5,a2,ffffffffc0202adc <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02028ae:	489c                	lw	a5,16(s1)
ffffffffc02028b0:	24079663          	bnez	a5,ffffffffc0202afc <swap_init+0x48a>
ffffffffc02028b4:	0000e797          	auipc	a5,0xe
ffffffffc02028b8:	7cc78793          	addi	a5,a5,1996 # ffffffffc0211080 <swap_in_seq_no>
ffffffffc02028bc:	0000e617          	auipc	a2,0xe
ffffffffc02028c0:	7ec60613          	addi	a2,a2,2028 # ffffffffc02110a8 <swap_out_seq_no>
ffffffffc02028c4:	0000e517          	auipc	a0,0xe
ffffffffc02028c8:	7e450513          	addi	a0,a0,2020 # ffffffffc02110a8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02028cc:	55fd                	li	a1,-1
ffffffffc02028ce:	c38c                	sw	a1,0(a5)
ffffffffc02028d0:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02028d2:	0791                	addi	a5,a5,4
ffffffffc02028d4:	0611                	addi	a2,a2,4
ffffffffc02028d6:	fef51ce3          	bne	a0,a5,ffffffffc02028ce <swap_init+0x25c>
ffffffffc02028da:	0000e817          	auipc	a6,0xe
ffffffffc02028de:	76680813          	addi	a6,a6,1894 # ffffffffc0211040 <check_ptep>
ffffffffc02028e2:	0000e897          	auipc	a7,0xe
ffffffffc02028e6:	77e88893          	addi	a7,a7,1918 # ffffffffc0211060 <check_rp>
ffffffffc02028ea:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc02028ec:	0000fc97          	auipc	s9,0xf
ffffffffc02028f0:	c3cc8c93          	addi	s9,s9,-964 # ffffffffc0211528 <pages>
ffffffffc02028f4:	00003c17          	auipc	s8,0x3
ffffffffc02028f8:	74cc0c13          	addi	s8,s8,1868 # ffffffffc0206040 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02028fc:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202900:	4601                	li	a2,0
ffffffffc0202902:	855e                	mv	a0,s7
ffffffffc0202904:	ec46                	sd	a7,24(sp)
ffffffffc0202906:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc0202908:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020290a:	abafe0ef          	jal	ra,ffffffffc0200bc4 <get_pte>
ffffffffc020290e:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202910:	65c2                	ld	a1,16(sp)
ffffffffc0202912:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202914:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0202918:	0000f317          	auipc	t1,0xf
ffffffffc020291c:	c0830313          	addi	t1,t1,-1016 # ffffffffc0211520 <npage>
ffffffffc0202920:	16050e63          	beqz	a0,ffffffffc0202a9c <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202924:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202926:	0017f613          	andi	a2,a5,1
ffffffffc020292a:	0e060563          	beqz	a2,ffffffffc0202a14 <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc020292e:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202932:	078a                	slli	a5,a5,0x2
ffffffffc0202934:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202936:	0ec7fb63          	bgeu	a5,a2,ffffffffc0202a2c <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc020293a:	000c3603          	ld	a2,0(s8)
ffffffffc020293e:	000cb503          	ld	a0,0(s9)
ffffffffc0202942:	0008bf03          	ld	t5,0(a7)
ffffffffc0202946:	8f91                	sub	a5,a5,a2
ffffffffc0202948:	00379613          	slli	a2,a5,0x3
ffffffffc020294c:	97b2                	add	a5,a5,a2
ffffffffc020294e:	078e                	slli	a5,a5,0x3
ffffffffc0202950:	97aa                	add	a5,a5,a0
ffffffffc0202952:	0aff1163          	bne	t5,a5,ffffffffc02029f4 <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202956:	6785                	lui	a5,0x1
ffffffffc0202958:	95be                	add	a1,a1,a5
ffffffffc020295a:	6795                	lui	a5,0x5
ffffffffc020295c:	0821                	addi	a6,a6,8
ffffffffc020295e:	08a1                	addi	a7,a7,8
ffffffffc0202960:	f8f59ee3          	bne	a1,a5,ffffffffc02028fc <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202964:	00003517          	auipc	a0,0x3
ffffffffc0202968:	eb450513          	addi	a0,a0,-332 # ffffffffc0205818 <commands+0x1300>
ffffffffc020296c:	f4efd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0202970:	000b3783          	ld	a5,0(s6)
ffffffffc0202974:	7f9c                	ld	a5,56(a5)
ffffffffc0202976:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202978:	1a051263          	bnez	a0,ffffffffc0202b1c <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc020297c:	00093503          	ld	a0,0(s2)
ffffffffc0202980:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202982:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0202984:	9c6fe0ef          	jal	ra,ffffffffc0200b4a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202988:	ff491ae3          	bne	s2,s4,ffffffffc020297c <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc020298c:	8556                	mv	a0,s5
ffffffffc020298e:	e2eff0ef          	jal	ra,ffffffffc0201fbc <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202992:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202994:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202998:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc020299a:	7782                	ld	a5,32(sp)
ffffffffc020299c:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020299e:	009d8a63          	beq	s11,s1,ffffffffc02029b2 <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc02029a2:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc02029a6:	008dbd83          	ld	s11,8(s11)
ffffffffc02029aa:	3d7d                	addiw	s10,s10,-1
ffffffffc02029ac:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc02029ae:	fe9d9ae3          	bne	s11,s1,ffffffffc02029a2 <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc02029b2:	8622                	mv	a2,s0
ffffffffc02029b4:	85ea                	mv	a1,s10
ffffffffc02029b6:	00003517          	auipc	a0,0x3
ffffffffc02029ba:	e9250513          	addi	a0,a0,-366 # ffffffffc0205848 <commands+0x1330>
ffffffffc02029be:	efcfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc02029c2:	00003517          	auipc	a0,0x3
ffffffffc02029c6:	ea650513          	addi	a0,a0,-346 # ffffffffc0205868 <commands+0x1350>
ffffffffc02029ca:	ef0fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc02029ce:	b9dd                	j	ffffffffc02026c4 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc02029d0:	4901                	li	s2,0
ffffffffc02029d2:	bba9                	j	ffffffffc020272c <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc02029d4:	00003697          	auipc	a3,0x3
ffffffffc02029d8:	c4468693          	addi	a3,a3,-956 # ffffffffc0205618 <commands+0x1100>
ffffffffc02029dc:	00002617          	auipc	a2,0x2
ffffffffc02029e0:	3c460613          	addi	a2,a2,964 # ffffffffc0204da0 <commands+0x888>
ffffffffc02029e4:	0bb00593          	li	a1,187
ffffffffc02029e8:	00003517          	auipc	a0,0x3
ffffffffc02029ec:	c0850513          	addi	a0,a0,-1016 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc02029f0:	f12fd0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02029f4:	00003697          	auipc	a3,0x3
ffffffffc02029f8:	dfc68693          	addi	a3,a3,-516 # ffffffffc02057f0 <commands+0x12d8>
ffffffffc02029fc:	00002617          	auipc	a2,0x2
ffffffffc0202a00:	3a460613          	addi	a2,a2,932 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202a04:	0fb00593          	li	a1,251
ffffffffc0202a08:	00003517          	auipc	a0,0x3
ffffffffc0202a0c:	be850513          	addi	a0,a0,-1048 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202a10:	ef2fd0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202a14:	00002617          	auipc	a2,0x2
ffffffffc0202a18:	23c60613          	addi	a2,a2,572 # ffffffffc0204c50 <commands+0x738>
ffffffffc0202a1c:	07000593          	li	a1,112
ffffffffc0202a20:	00002517          	auipc	a0,0x2
ffffffffc0202a24:	22050513          	addi	a0,a0,544 # ffffffffc0204c40 <commands+0x728>
ffffffffc0202a28:	edafd0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202a2c:	00002617          	auipc	a2,0x2
ffffffffc0202a30:	1f460613          	addi	a2,a2,500 # ffffffffc0204c20 <commands+0x708>
ffffffffc0202a34:	06500593          	li	a1,101
ffffffffc0202a38:	00002517          	auipc	a0,0x2
ffffffffc0202a3c:	20850513          	addi	a0,a0,520 # ffffffffc0204c40 <commands+0x728>
ffffffffc0202a40:	ec2fd0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202a44:	00003697          	auipc	a3,0x3
ffffffffc0202a48:	cd468693          	addi	a3,a3,-812 # ffffffffc0205718 <commands+0x1200>
ffffffffc0202a4c:	00002617          	auipc	a2,0x2
ffffffffc0202a50:	35460613          	addi	a2,a2,852 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202a54:	0dc00593          	li	a1,220
ffffffffc0202a58:	00003517          	auipc	a0,0x3
ffffffffc0202a5c:	b9850513          	addi	a0,a0,-1128 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202a60:	ea2fd0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202a64:	00003697          	auipc	a3,0x3
ffffffffc0202a68:	c9c68693          	addi	a3,a3,-868 # ffffffffc0205700 <commands+0x11e8>
ffffffffc0202a6c:	00002617          	auipc	a2,0x2
ffffffffc0202a70:	33460613          	addi	a2,a2,820 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202a74:	0db00593          	li	a1,219
ffffffffc0202a78:	00003517          	auipc	a0,0x3
ffffffffc0202a7c:	b7850513          	addi	a0,a0,-1160 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202a80:	e82fd0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202a84:	00003617          	auipc	a2,0x3
ffffffffc0202a88:	b4c60613          	addi	a2,a2,-1204 # ffffffffc02055d0 <commands+0x10b8>
ffffffffc0202a8c:	02800593          	li	a1,40
ffffffffc0202a90:	00003517          	auipc	a0,0x3
ffffffffc0202a94:	b6050513          	addi	a0,a0,-1184 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202a98:	e6afd0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202a9c:	00003697          	auipc	a3,0x3
ffffffffc0202aa0:	d3c68693          	addi	a3,a3,-708 # ffffffffc02057d8 <commands+0x12c0>
ffffffffc0202aa4:	00002617          	auipc	a2,0x2
ffffffffc0202aa8:	2fc60613          	addi	a2,a2,764 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202aac:	0fa00593          	li	a1,250
ffffffffc0202ab0:	00003517          	auipc	a0,0x3
ffffffffc0202ab4:	b4050513          	addi	a0,a0,-1216 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202ab8:	e4afd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0202abc:	00003697          	auipc	a3,0x3
ffffffffc0202ac0:	cfc68693          	addi	a3,a3,-772 # ffffffffc02057b8 <commands+0x12a0>
ffffffffc0202ac4:	00002617          	auipc	a2,0x2
ffffffffc0202ac8:	2dc60613          	addi	a2,a2,732 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202acc:	09e00593          	li	a1,158
ffffffffc0202ad0:	00003517          	auipc	a0,0x3
ffffffffc0202ad4:	b2050513          	addi	a0,a0,-1248 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202ad8:	e2afd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0202adc:	00003697          	auipc	a3,0x3
ffffffffc0202ae0:	cdc68693          	addi	a3,a3,-804 # ffffffffc02057b8 <commands+0x12a0>
ffffffffc0202ae4:	00002617          	auipc	a2,0x2
ffffffffc0202ae8:	2bc60613          	addi	a2,a2,700 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202aec:	0a000593          	li	a1,160
ffffffffc0202af0:	00003517          	auipc	a0,0x3
ffffffffc0202af4:	b0050513          	addi	a0,a0,-1280 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202af8:	e0afd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert( nr_free == 0);         
ffffffffc0202afc:	00003697          	auipc	a3,0x3
ffffffffc0202b00:	ccc68693          	addi	a3,a3,-820 # ffffffffc02057c8 <commands+0x12b0>
ffffffffc0202b04:	00002617          	auipc	a2,0x2
ffffffffc0202b08:	29c60613          	addi	a2,a2,668 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202b0c:	0f200593          	li	a1,242
ffffffffc0202b10:	00003517          	auipc	a0,0x3
ffffffffc0202b14:	ae050513          	addi	a0,a0,-1312 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202b18:	deafd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(ret==0);
ffffffffc0202b1c:	00003697          	auipc	a3,0x3
ffffffffc0202b20:	d2468693          	addi	a3,a3,-732 # ffffffffc0205840 <commands+0x1328>
ffffffffc0202b24:	00002617          	auipc	a2,0x2
ffffffffc0202b28:	27c60613          	addi	a2,a2,636 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202b2c:	10100593          	li	a1,257
ffffffffc0202b30:	00003517          	auipc	a0,0x3
ffffffffc0202b34:	ac050513          	addi	a0,a0,-1344 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202b38:	dcafd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202b3c:	00003697          	auipc	a3,0x3
ffffffffc0202b40:	96468693          	addi	a3,a3,-1692 # ffffffffc02054a0 <commands+0xf88>
ffffffffc0202b44:	00002617          	auipc	a2,0x2
ffffffffc0202b48:	25c60613          	addi	a2,a2,604 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202b4c:	0cb00593          	li	a1,203
ffffffffc0202b50:	00003517          	auipc	a0,0x3
ffffffffc0202b54:	aa050513          	addi	a0,a0,-1376 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202b58:	daafd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(vma != NULL);
ffffffffc0202b5c:	00003697          	auipc	a3,0x3
ffffffffc0202b60:	9bc68693          	addi	a3,a3,-1604 # ffffffffc0205518 <commands+0x1000>
ffffffffc0202b64:	00002617          	auipc	a2,0x2
ffffffffc0202b68:	23c60613          	addi	a2,a2,572 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202b6c:	0ce00593          	li	a1,206
ffffffffc0202b70:	00003517          	auipc	a0,0x3
ffffffffc0202b74:	a8050513          	addi	a0,a0,-1408 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202b78:	d8afd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202b7c:	00003697          	auipc	a3,0x3
ffffffffc0202b80:	b4468693          	addi	a3,a3,-1212 # ffffffffc02056c0 <commands+0x11a8>
ffffffffc0202b84:	00002617          	auipc	a2,0x2
ffffffffc0202b88:	21c60613          	addi	a2,a2,540 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202b8c:	0d600593          	li	a1,214
ffffffffc0202b90:	00003517          	auipc	a0,0x3
ffffffffc0202b94:	a6050513          	addi	a0,a0,-1440 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202b98:	d6afd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202b9c:	00003697          	auipc	a3,0x3
ffffffffc0202ba0:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0205628 <commands+0x1110>
ffffffffc0202ba4:	00002617          	auipc	a2,0x2
ffffffffc0202ba8:	1fc60613          	addi	a2,a2,508 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202bac:	0be00593          	li	a1,190
ffffffffc0202bb0:	00003517          	auipc	a0,0x3
ffffffffc0202bb4:	a4050513          	addi	a0,a0,-1472 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202bb8:	d4afd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0202bbc:	00003697          	auipc	a3,0x3
ffffffffc0202bc0:	bdc68693          	addi	a3,a3,-1060 # ffffffffc0205798 <commands+0x1280>
ffffffffc0202bc4:	00002617          	auipc	a2,0x2
ffffffffc0202bc8:	1dc60613          	addi	a2,a2,476 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202bcc:	09600593          	li	a1,150
ffffffffc0202bd0:	00003517          	auipc	a0,0x3
ffffffffc0202bd4:	a2050513          	addi	a0,a0,-1504 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202bd8:	d2afd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0202bdc:	00003697          	auipc	a3,0x3
ffffffffc0202be0:	bbc68693          	addi	a3,a3,-1092 # ffffffffc0205798 <commands+0x1280>
ffffffffc0202be4:	00002617          	auipc	a2,0x2
ffffffffc0202be8:	1bc60613          	addi	a2,a2,444 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202bec:	09800593          	li	a1,152
ffffffffc0202bf0:	00003517          	auipc	a0,0x3
ffffffffc0202bf4:	a0050513          	addi	a0,a0,-1536 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202bf8:	d0afd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0202bfc:	00003697          	auipc	a3,0x3
ffffffffc0202c00:	bac68693          	addi	a3,a3,-1108 # ffffffffc02057a8 <commands+0x1290>
ffffffffc0202c04:	00002617          	auipc	a2,0x2
ffffffffc0202c08:	19c60613          	addi	a2,a2,412 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202c0c:	09a00593          	li	a1,154
ffffffffc0202c10:	00003517          	auipc	a0,0x3
ffffffffc0202c14:	9e050513          	addi	a0,a0,-1568 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202c18:	ceafd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0202c1c:	00003697          	auipc	a3,0x3
ffffffffc0202c20:	b8c68693          	addi	a3,a3,-1140 # ffffffffc02057a8 <commands+0x1290>
ffffffffc0202c24:	00002617          	auipc	a2,0x2
ffffffffc0202c28:	17c60613          	addi	a2,a2,380 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202c2c:	09c00593          	li	a1,156
ffffffffc0202c30:	00003517          	auipc	a0,0x3
ffffffffc0202c34:	9c050513          	addi	a0,a0,-1600 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202c38:	ccafd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0202c3c:	00003697          	auipc	a3,0x3
ffffffffc0202c40:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0205788 <commands+0x1270>
ffffffffc0202c44:	00002617          	auipc	a2,0x2
ffffffffc0202c48:	15c60613          	addi	a2,a2,348 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202c4c:	09200593          	li	a1,146
ffffffffc0202c50:	00003517          	auipc	a0,0x3
ffffffffc0202c54:	9a050513          	addi	a0,a0,-1632 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202c58:	caafd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0202c5c:	00003697          	auipc	a3,0x3
ffffffffc0202c60:	b2c68693          	addi	a3,a3,-1236 # ffffffffc0205788 <commands+0x1270>
ffffffffc0202c64:	00002617          	auipc	a2,0x2
ffffffffc0202c68:	13c60613          	addi	a2,a2,316 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202c6c:	09400593          	li	a1,148
ffffffffc0202c70:	00003517          	auipc	a0,0x3
ffffffffc0202c74:	98050513          	addi	a0,a0,-1664 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202c78:	c8afd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(mm != NULL);
ffffffffc0202c7c:	00003697          	auipc	a3,0x3
ffffffffc0202c80:	8c468693          	addi	a3,a3,-1852 # ffffffffc0205540 <commands+0x1028>
ffffffffc0202c84:	00002617          	auipc	a2,0x2
ffffffffc0202c88:	11c60613          	addi	a2,a2,284 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202c8c:	0c300593          	li	a1,195
ffffffffc0202c90:	00003517          	auipc	a0,0x3
ffffffffc0202c94:	96050513          	addi	a0,a0,-1696 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202c98:	c6afd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202c9c:	00003697          	auipc	a3,0x3
ffffffffc0202ca0:	9d468693          	addi	a3,a3,-1580 # ffffffffc0205670 <commands+0x1158>
ffffffffc0202ca4:	00002617          	auipc	a2,0x2
ffffffffc0202ca8:	0fc60613          	addi	a2,a2,252 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202cac:	0c600593          	li	a1,198
ffffffffc0202cb0:	00003517          	auipc	a0,0x3
ffffffffc0202cb4:	94050513          	addi	a0,a0,-1728 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202cb8:	c4afd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202cbc:	00003697          	auipc	a3,0x3
ffffffffc0202cc0:	a7c68693          	addi	a3,a3,-1412 # ffffffffc0205738 <commands+0x1220>
ffffffffc0202cc4:	00002617          	auipc	a2,0x2
ffffffffc0202cc8:	0dc60613          	addi	a2,a2,220 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202ccc:	0e900593          	li	a1,233
ffffffffc0202cd0:	00003517          	auipc	a0,0x3
ffffffffc0202cd4:	92050513          	addi	a0,a0,-1760 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202cd8:	c2afd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202cdc <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202cdc:	0000f797          	auipc	a5,0xf
ffffffffc0202ce0:	87c7b783          	ld	a5,-1924(a5) # ffffffffc0211558 <sm>
ffffffffc0202ce4:	6b9c                	ld	a5,16(a5)
ffffffffc0202ce6:	8782                	jr	a5

ffffffffc0202ce8 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202ce8:	0000f797          	auipc	a5,0xf
ffffffffc0202cec:	8707b783          	ld	a5,-1936(a5) # ffffffffc0211558 <sm>
ffffffffc0202cf0:	739c                	ld	a5,32(a5)
ffffffffc0202cf2:	8782                	jr	a5

ffffffffc0202cf4 <swap_out>:
{
ffffffffc0202cf4:	711d                	addi	sp,sp,-96
ffffffffc0202cf6:	ec86                	sd	ra,88(sp)
ffffffffc0202cf8:	e8a2                	sd	s0,80(sp)
ffffffffc0202cfa:	e4a6                	sd	s1,72(sp)
ffffffffc0202cfc:	e0ca                	sd	s2,64(sp)
ffffffffc0202cfe:	fc4e                	sd	s3,56(sp)
ffffffffc0202d00:	f852                	sd	s4,48(sp)
ffffffffc0202d02:	f456                	sd	s5,40(sp)
ffffffffc0202d04:	f05a                	sd	s6,32(sp)
ffffffffc0202d06:	ec5e                	sd	s7,24(sp)
ffffffffc0202d08:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202d0a:	cde9                	beqz	a1,ffffffffc0202de4 <swap_out+0xf0>
ffffffffc0202d0c:	8a2e                	mv	s4,a1
ffffffffc0202d0e:	892a                	mv	s2,a0
ffffffffc0202d10:	8ab2                	mv	s5,a2
ffffffffc0202d12:	4401                	li	s0,0
ffffffffc0202d14:	0000f997          	auipc	s3,0xf
ffffffffc0202d18:	84498993          	addi	s3,s3,-1980 # ffffffffc0211558 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202d1c:	00003b17          	auipc	s6,0x3
ffffffffc0202d20:	bccb0b13          	addi	s6,s6,-1076 # ffffffffc02058e8 <commands+0x13d0>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202d24:	00003b97          	auipc	s7,0x3
ffffffffc0202d28:	bacb8b93          	addi	s7,s7,-1108 # ffffffffc02058d0 <commands+0x13b8>
ffffffffc0202d2c:	a825                	j	ffffffffc0202d64 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202d2e:	67a2                	ld	a5,8(sp)
ffffffffc0202d30:	8626                	mv	a2,s1
ffffffffc0202d32:	85a2                	mv	a1,s0
ffffffffc0202d34:	63b4                	ld	a3,64(a5)
ffffffffc0202d36:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202d38:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202d3a:	82b1                	srli	a3,a3,0xc
ffffffffc0202d3c:	0685                	addi	a3,a3,1
ffffffffc0202d3e:	b7cfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202d42:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202d44:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202d46:	613c                	ld	a5,64(a0)
ffffffffc0202d48:	83b1                	srli	a5,a5,0xc
ffffffffc0202d4a:	0785                	addi	a5,a5,1
ffffffffc0202d4c:	07a2                	slli	a5,a5,0x8
ffffffffc0202d4e:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202d52:	df9fd0ef          	jal	ra,ffffffffc0200b4a <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202d56:	01893503          	ld	a0,24(s2)
ffffffffc0202d5a:	85a6                	mv	a1,s1
ffffffffc0202d5c:	e57fe0ef          	jal	ra,ffffffffc0201bb2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202d60:	048a0d63          	beq	s4,s0,ffffffffc0202dba <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202d64:	0009b783          	ld	a5,0(s3)
ffffffffc0202d68:	8656                	mv	a2,s5
ffffffffc0202d6a:	002c                	addi	a1,sp,8
ffffffffc0202d6c:	7b9c                	ld	a5,48(a5)
ffffffffc0202d6e:	854a                	mv	a0,s2
ffffffffc0202d70:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202d72:	e12d                	bnez	a0,ffffffffc0202dd4 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202d74:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202d76:	01893503          	ld	a0,24(s2)
ffffffffc0202d7a:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202d7c:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202d7e:	85a6                	mv	a1,s1
ffffffffc0202d80:	e45fd0ef          	jal	ra,ffffffffc0200bc4 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202d84:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202d86:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202d88:	8b85                	andi	a5,a5,1
ffffffffc0202d8a:	cfb9                	beqz	a5,ffffffffc0202de8 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202d8c:	65a2                	ld	a1,8(sp)
ffffffffc0202d8e:	61bc                	ld	a5,64(a1)
ffffffffc0202d90:	83b1                	srli	a5,a5,0xc
ffffffffc0202d92:	0785                	addi	a5,a5,1
ffffffffc0202d94:	00879513          	slli	a0,a5,0x8
ffffffffc0202d98:	725000ef          	jal	ra,ffffffffc0203cbc <swapfs_write>
ffffffffc0202d9c:	d949                	beqz	a0,ffffffffc0202d2e <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202d9e:	855e                	mv	a0,s7
ffffffffc0202da0:	b1afd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202da4:	0009b783          	ld	a5,0(s3)
ffffffffc0202da8:	6622                	ld	a2,8(sp)
ffffffffc0202daa:	4681                	li	a3,0
ffffffffc0202dac:	739c                	ld	a5,32(a5)
ffffffffc0202dae:	85a6                	mv	a1,s1
ffffffffc0202db0:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202db2:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202db4:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202db6:	fa8a17e3          	bne	s4,s0,ffffffffc0202d64 <swap_out+0x70>
}
ffffffffc0202dba:	60e6                	ld	ra,88(sp)
ffffffffc0202dbc:	8522                	mv	a0,s0
ffffffffc0202dbe:	6446                	ld	s0,80(sp)
ffffffffc0202dc0:	64a6                	ld	s1,72(sp)
ffffffffc0202dc2:	6906                	ld	s2,64(sp)
ffffffffc0202dc4:	79e2                	ld	s3,56(sp)
ffffffffc0202dc6:	7a42                	ld	s4,48(sp)
ffffffffc0202dc8:	7aa2                	ld	s5,40(sp)
ffffffffc0202dca:	7b02                	ld	s6,32(sp)
ffffffffc0202dcc:	6be2                	ld	s7,24(sp)
ffffffffc0202dce:	6c42                	ld	s8,16(sp)
ffffffffc0202dd0:	6125                	addi	sp,sp,96
ffffffffc0202dd2:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202dd4:	85a2                	mv	a1,s0
ffffffffc0202dd6:	00003517          	auipc	a0,0x3
ffffffffc0202dda:	ab250513          	addi	a0,a0,-1358 # ffffffffc0205888 <commands+0x1370>
ffffffffc0202dde:	adcfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc0202de2:	bfe1                	j	ffffffffc0202dba <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202de4:	4401                	li	s0,0
ffffffffc0202de6:	bfd1                	j	ffffffffc0202dba <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202de8:	00003697          	auipc	a3,0x3
ffffffffc0202dec:	ad068693          	addi	a3,a3,-1328 # ffffffffc02058b8 <commands+0x13a0>
ffffffffc0202df0:	00002617          	auipc	a2,0x2
ffffffffc0202df4:	fb060613          	addi	a2,a2,-80 # ffffffffc0204da0 <commands+0x888>
ffffffffc0202df8:	06700593          	li	a1,103
ffffffffc0202dfc:	00002517          	auipc	a0,0x2
ffffffffc0202e00:	7f450513          	addi	a0,a0,2036 # ffffffffc02055f0 <commands+0x10d8>
ffffffffc0202e04:	afefd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202e08 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202e08:	0000e797          	auipc	a5,0xe
ffffffffc0202e0c:	2c878793          	addi	a5,a5,712 # ffffffffc02110d0 <free_area>
ffffffffc0202e10:	e79c                	sd	a5,8(a5)
ffffffffc0202e12:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202e14:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202e18:	8082                	ret

ffffffffc0202e1a <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202e1a:	0000e517          	auipc	a0,0xe
ffffffffc0202e1e:	2c656503          	lwu	a0,710(a0) # ffffffffc02110e0 <free_area+0x10>
ffffffffc0202e22:	8082                	ret

ffffffffc0202e24 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202e24:	715d                	addi	sp,sp,-80
ffffffffc0202e26:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0202e28:	0000e417          	auipc	s0,0xe
ffffffffc0202e2c:	2a840413          	addi	s0,s0,680 # ffffffffc02110d0 <free_area>
ffffffffc0202e30:	641c                	ld	a5,8(s0)
ffffffffc0202e32:	e486                	sd	ra,72(sp)
ffffffffc0202e34:	fc26                	sd	s1,56(sp)
ffffffffc0202e36:	f84a                	sd	s2,48(sp)
ffffffffc0202e38:	f44e                	sd	s3,40(sp)
ffffffffc0202e3a:	f052                	sd	s4,32(sp)
ffffffffc0202e3c:	ec56                	sd	s5,24(sp)
ffffffffc0202e3e:	e85a                	sd	s6,16(sp)
ffffffffc0202e40:	e45e                	sd	s7,8(sp)
ffffffffc0202e42:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202e44:	2c878763          	beq	a5,s0,ffffffffc0203112 <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0202e48:	4481                	li	s1,0
ffffffffc0202e4a:	4901                	li	s2,0
ffffffffc0202e4c:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202e50:	8b09                	andi	a4,a4,2
ffffffffc0202e52:	2c070463          	beqz	a4,ffffffffc020311a <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0202e56:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202e5a:	679c                	ld	a5,8(a5)
ffffffffc0202e5c:	2905                	addiw	s2,s2,1
ffffffffc0202e5e:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202e60:	fe8796e3          	bne	a5,s0,ffffffffc0202e4c <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0202e64:	89a6                	mv	s3,s1
ffffffffc0202e66:	d25fd0ef          	jal	ra,ffffffffc0200b8a <nr_free_pages>
ffffffffc0202e6a:	71351863          	bne	a0,s3,ffffffffc020357a <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202e6e:	4505                	li	a0,1
ffffffffc0202e70:	c49fd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0202e74:	8a2a                	mv	s4,a0
ffffffffc0202e76:	44050263          	beqz	a0,ffffffffc02032ba <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202e7a:	4505                	li	a0,1
ffffffffc0202e7c:	c3dfd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0202e80:	89aa                	mv	s3,a0
ffffffffc0202e82:	70050c63          	beqz	a0,ffffffffc020359a <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202e86:	4505                	li	a0,1
ffffffffc0202e88:	c31fd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0202e8c:	8aaa                	mv	s5,a0
ffffffffc0202e8e:	4a050663          	beqz	a0,ffffffffc020333a <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202e92:	2b3a0463          	beq	s4,s3,ffffffffc020313a <default_check+0x316>
ffffffffc0202e96:	2aaa0263          	beq	s4,a0,ffffffffc020313a <default_check+0x316>
ffffffffc0202e9a:	2aa98063          	beq	s3,a0,ffffffffc020313a <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202e9e:	000a2783          	lw	a5,0(s4)
ffffffffc0202ea2:	2a079c63          	bnez	a5,ffffffffc020315a <default_check+0x336>
ffffffffc0202ea6:	0009a783          	lw	a5,0(s3)
ffffffffc0202eaa:	2a079863          	bnez	a5,ffffffffc020315a <default_check+0x336>
ffffffffc0202eae:	411c                	lw	a5,0(a0)
ffffffffc0202eb0:	2a079563          	bnez	a5,ffffffffc020315a <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202eb4:	0000e797          	auipc	a5,0xe
ffffffffc0202eb8:	6747b783          	ld	a5,1652(a5) # ffffffffc0211528 <pages>
ffffffffc0202ebc:	40fa0733          	sub	a4,s4,a5
ffffffffc0202ec0:	870d                	srai	a4,a4,0x3
ffffffffc0202ec2:	00003597          	auipc	a1,0x3
ffffffffc0202ec6:	1765b583          	ld	a1,374(a1) # ffffffffc0206038 <error_string+0x38>
ffffffffc0202eca:	02b70733          	mul	a4,a4,a1
ffffffffc0202ece:	00003617          	auipc	a2,0x3
ffffffffc0202ed2:	17263603          	ld	a2,370(a2) # ffffffffc0206040 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202ed6:	0000e697          	auipc	a3,0xe
ffffffffc0202eda:	64a6b683          	ld	a3,1610(a3) # ffffffffc0211520 <npage>
ffffffffc0202ede:	06b2                	slli	a3,a3,0xc
ffffffffc0202ee0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ee2:	0732                	slli	a4,a4,0xc
ffffffffc0202ee4:	28d77b63          	bgeu	a4,a3,ffffffffc020317a <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202ee8:	40f98733          	sub	a4,s3,a5
ffffffffc0202eec:	870d                	srai	a4,a4,0x3
ffffffffc0202eee:	02b70733          	mul	a4,a4,a1
ffffffffc0202ef2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ef4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202ef6:	4cd77263          	bgeu	a4,a3,ffffffffc02033ba <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202efa:	40f507b3          	sub	a5,a0,a5
ffffffffc0202efe:	878d                	srai	a5,a5,0x3
ffffffffc0202f00:	02b787b3          	mul	a5,a5,a1
ffffffffc0202f04:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202f06:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202f08:	30d7f963          	bgeu	a5,a3,ffffffffc020321a <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0202f0c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202f0e:	00043c03          	ld	s8,0(s0)
ffffffffc0202f12:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0202f16:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0202f1a:	e400                	sd	s0,8(s0)
ffffffffc0202f1c:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0202f1e:	0000e797          	auipc	a5,0xe
ffffffffc0202f22:	1c07a123          	sw	zero,450(a5) # ffffffffc02110e0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202f26:	b93fd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0202f2a:	2c051863          	bnez	a0,ffffffffc02031fa <default_check+0x3d6>
    free_page(p0);
ffffffffc0202f2e:	4585                	li	a1,1
ffffffffc0202f30:	8552                	mv	a0,s4
ffffffffc0202f32:	c19fd0ef          	jal	ra,ffffffffc0200b4a <free_pages>
    free_page(p1);
ffffffffc0202f36:	4585                	li	a1,1
ffffffffc0202f38:	854e                	mv	a0,s3
ffffffffc0202f3a:	c11fd0ef          	jal	ra,ffffffffc0200b4a <free_pages>
    free_page(p2);
ffffffffc0202f3e:	4585                	li	a1,1
ffffffffc0202f40:	8556                	mv	a0,s5
ffffffffc0202f42:	c09fd0ef          	jal	ra,ffffffffc0200b4a <free_pages>
    assert(nr_free == 3);
ffffffffc0202f46:	4818                	lw	a4,16(s0)
ffffffffc0202f48:	478d                	li	a5,3
ffffffffc0202f4a:	28f71863          	bne	a4,a5,ffffffffc02031da <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202f4e:	4505                	li	a0,1
ffffffffc0202f50:	b69fd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0202f54:	89aa                	mv	s3,a0
ffffffffc0202f56:	26050263          	beqz	a0,ffffffffc02031ba <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202f5a:	4505                	li	a0,1
ffffffffc0202f5c:	b5dfd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0202f60:	8aaa                	mv	s5,a0
ffffffffc0202f62:	3a050c63          	beqz	a0,ffffffffc020331a <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202f66:	4505                	li	a0,1
ffffffffc0202f68:	b51fd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0202f6c:	8a2a                	mv	s4,a0
ffffffffc0202f6e:	38050663          	beqz	a0,ffffffffc02032fa <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0202f72:	4505                	li	a0,1
ffffffffc0202f74:	b45fd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0202f78:	36051163          	bnez	a0,ffffffffc02032da <default_check+0x4b6>
    free_page(p0);
ffffffffc0202f7c:	4585                	li	a1,1
ffffffffc0202f7e:	854e                	mv	a0,s3
ffffffffc0202f80:	bcbfd0ef          	jal	ra,ffffffffc0200b4a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202f84:	641c                	ld	a5,8(s0)
ffffffffc0202f86:	20878a63          	beq	a5,s0,ffffffffc020319a <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0202f8a:	4505                	li	a0,1
ffffffffc0202f8c:	b2dfd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0202f90:	30a99563          	bne	s3,a0,ffffffffc020329a <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0202f94:	4505                	li	a0,1
ffffffffc0202f96:	b23fd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0202f9a:	2e051063          	bnez	a0,ffffffffc020327a <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0202f9e:	481c                	lw	a5,16(s0)
ffffffffc0202fa0:	2a079d63          	bnez	a5,ffffffffc020325a <default_check+0x436>
    free_page(p);
ffffffffc0202fa4:	854e                	mv	a0,s3
ffffffffc0202fa6:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202fa8:	01843023          	sd	s8,0(s0)
ffffffffc0202fac:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0202fb0:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202fb4:	b97fd0ef          	jal	ra,ffffffffc0200b4a <free_pages>
    free_page(p1);
ffffffffc0202fb8:	4585                	li	a1,1
ffffffffc0202fba:	8556                	mv	a0,s5
ffffffffc0202fbc:	b8ffd0ef          	jal	ra,ffffffffc0200b4a <free_pages>
    free_page(p2);
ffffffffc0202fc0:	4585                	li	a1,1
ffffffffc0202fc2:	8552                	mv	a0,s4
ffffffffc0202fc4:	b87fd0ef          	jal	ra,ffffffffc0200b4a <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202fc8:	4515                	li	a0,5
ffffffffc0202fca:	aeffd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0202fce:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202fd0:	26050563          	beqz	a0,ffffffffc020323a <default_check+0x416>
ffffffffc0202fd4:	651c                	ld	a5,8(a0)
ffffffffc0202fd6:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0202fd8:	8b85                	andi	a5,a5,1
ffffffffc0202fda:	54079063          	bnez	a5,ffffffffc020351a <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202fde:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202fe0:	00043b03          	ld	s6,0(s0)
ffffffffc0202fe4:	00843a83          	ld	s5,8(s0)
ffffffffc0202fe8:	e000                	sd	s0,0(s0)
ffffffffc0202fea:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0202fec:	acdfd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0202ff0:	50051563          	bnez	a0,ffffffffc02034fa <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202ff4:	09098a13          	addi	s4,s3,144
ffffffffc0202ff8:	8552                	mv	a0,s4
ffffffffc0202ffa:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202ffc:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0203000:	0000e797          	auipc	a5,0xe
ffffffffc0203004:	0e07a023          	sw	zero,224(a5) # ffffffffc02110e0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0203008:	b43fd0ef          	jal	ra,ffffffffc0200b4a <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020300c:	4511                	li	a0,4
ffffffffc020300e:	aabfd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0203012:	4c051463          	bnez	a0,ffffffffc02034da <default_check+0x6b6>
ffffffffc0203016:	0989b783          	ld	a5,152(s3)
ffffffffc020301a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020301c:	8b85                	andi	a5,a5,1
ffffffffc020301e:	48078e63          	beqz	a5,ffffffffc02034ba <default_check+0x696>
ffffffffc0203022:	0a89a703          	lw	a4,168(s3)
ffffffffc0203026:	478d                	li	a5,3
ffffffffc0203028:	48f71963          	bne	a4,a5,ffffffffc02034ba <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020302c:	450d                	li	a0,3
ffffffffc020302e:	a8bfd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc0203032:	8c2a                	mv	s8,a0
ffffffffc0203034:	46050363          	beqz	a0,ffffffffc020349a <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0203038:	4505                	li	a0,1
ffffffffc020303a:	a7ffd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc020303e:	42051e63          	bnez	a0,ffffffffc020347a <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0203042:	418a1c63          	bne	s4,s8,ffffffffc020345a <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0203046:	4585                	li	a1,1
ffffffffc0203048:	854e                	mv	a0,s3
ffffffffc020304a:	b01fd0ef          	jal	ra,ffffffffc0200b4a <free_pages>
    free_pages(p1, 3);
ffffffffc020304e:	458d                	li	a1,3
ffffffffc0203050:	8552                	mv	a0,s4
ffffffffc0203052:	af9fd0ef          	jal	ra,ffffffffc0200b4a <free_pages>
ffffffffc0203056:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc020305a:	04898c13          	addi	s8,s3,72
ffffffffc020305e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203060:	8b85                	andi	a5,a5,1
ffffffffc0203062:	3c078c63          	beqz	a5,ffffffffc020343a <default_check+0x616>
ffffffffc0203066:	0189a703          	lw	a4,24(s3)
ffffffffc020306a:	4785                	li	a5,1
ffffffffc020306c:	3cf71763          	bne	a4,a5,ffffffffc020343a <default_check+0x616>
ffffffffc0203070:	008a3783          	ld	a5,8(s4)
ffffffffc0203074:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203076:	8b85                	andi	a5,a5,1
ffffffffc0203078:	3a078163          	beqz	a5,ffffffffc020341a <default_check+0x5f6>
ffffffffc020307c:	018a2703          	lw	a4,24(s4)
ffffffffc0203080:	478d                	li	a5,3
ffffffffc0203082:	38f71c63          	bne	a4,a5,ffffffffc020341a <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203086:	4505                	li	a0,1
ffffffffc0203088:	a31fd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc020308c:	36a99763          	bne	s3,a0,ffffffffc02033fa <default_check+0x5d6>
    free_page(p0);
ffffffffc0203090:	4585                	li	a1,1
ffffffffc0203092:	ab9fd0ef          	jal	ra,ffffffffc0200b4a <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203096:	4509                	li	a0,2
ffffffffc0203098:	a21fd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc020309c:	32aa1f63          	bne	s4,a0,ffffffffc02033da <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc02030a0:	4589                	li	a1,2
ffffffffc02030a2:	aa9fd0ef          	jal	ra,ffffffffc0200b4a <free_pages>
    free_page(p2);
ffffffffc02030a6:	4585                	li	a1,1
ffffffffc02030a8:	8562                	mv	a0,s8
ffffffffc02030aa:	aa1fd0ef          	jal	ra,ffffffffc0200b4a <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02030ae:	4515                	li	a0,5
ffffffffc02030b0:	a09fd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc02030b4:	89aa                	mv	s3,a0
ffffffffc02030b6:	48050263          	beqz	a0,ffffffffc020353a <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc02030ba:	4505                	li	a0,1
ffffffffc02030bc:	9fdfd0ef          	jal	ra,ffffffffc0200ab8 <alloc_pages>
ffffffffc02030c0:	2c051d63          	bnez	a0,ffffffffc020339a <default_check+0x576>

    assert(nr_free == 0);
ffffffffc02030c4:	481c                	lw	a5,16(s0)
ffffffffc02030c6:	2a079a63          	bnez	a5,ffffffffc020337a <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02030ca:	4595                	li	a1,5
ffffffffc02030cc:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02030ce:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02030d2:	01643023          	sd	s6,0(s0)
ffffffffc02030d6:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02030da:	a71fd0ef          	jal	ra,ffffffffc0200b4a <free_pages>
    return listelm->next;
ffffffffc02030de:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02030e0:	00878963          	beq	a5,s0,ffffffffc02030f2 <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02030e4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02030e8:	679c                	ld	a5,8(a5)
ffffffffc02030ea:	397d                	addiw	s2,s2,-1
ffffffffc02030ec:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02030ee:	fe879be3          	bne	a5,s0,ffffffffc02030e4 <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc02030f2:	26091463          	bnez	s2,ffffffffc020335a <default_check+0x536>
    assert(total == 0);
ffffffffc02030f6:	46049263          	bnez	s1,ffffffffc020355a <default_check+0x736>
}
ffffffffc02030fa:	60a6                	ld	ra,72(sp)
ffffffffc02030fc:	6406                	ld	s0,64(sp)
ffffffffc02030fe:	74e2                	ld	s1,56(sp)
ffffffffc0203100:	7942                	ld	s2,48(sp)
ffffffffc0203102:	79a2                	ld	s3,40(sp)
ffffffffc0203104:	7a02                	ld	s4,32(sp)
ffffffffc0203106:	6ae2                	ld	s5,24(sp)
ffffffffc0203108:	6b42                	ld	s6,16(sp)
ffffffffc020310a:	6ba2                	ld	s7,8(sp)
ffffffffc020310c:	6c02                	ld	s8,0(sp)
ffffffffc020310e:	6161                	addi	sp,sp,80
ffffffffc0203110:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203112:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0203114:	4481                	li	s1,0
ffffffffc0203116:	4901                	li	s2,0
ffffffffc0203118:	b3b9                	j	ffffffffc0202e66 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc020311a:	00002697          	auipc	a3,0x2
ffffffffc020311e:	4fe68693          	addi	a3,a3,1278 # ffffffffc0205618 <commands+0x1100>
ffffffffc0203122:	00002617          	auipc	a2,0x2
ffffffffc0203126:	c7e60613          	addi	a2,a2,-898 # ffffffffc0204da0 <commands+0x888>
ffffffffc020312a:	0f000593          	li	a1,240
ffffffffc020312e:	00002517          	auipc	a0,0x2
ffffffffc0203132:	7fa50513          	addi	a0,a0,2042 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203136:	fcdfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020313a:	00003697          	auipc	a3,0x3
ffffffffc020313e:	86668693          	addi	a3,a3,-1946 # ffffffffc02059a0 <commands+0x1488>
ffffffffc0203142:	00002617          	auipc	a2,0x2
ffffffffc0203146:	c5e60613          	addi	a2,a2,-930 # ffffffffc0204da0 <commands+0x888>
ffffffffc020314a:	0bd00593          	li	a1,189
ffffffffc020314e:	00002517          	auipc	a0,0x2
ffffffffc0203152:	7da50513          	addi	a0,a0,2010 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203156:	fadfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020315a:	00003697          	auipc	a3,0x3
ffffffffc020315e:	86e68693          	addi	a3,a3,-1938 # ffffffffc02059c8 <commands+0x14b0>
ffffffffc0203162:	00002617          	auipc	a2,0x2
ffffffffc0203166:	c3e60613          	addi	a2,a2,-962 # ffffffffc0204da0 <commands+0x888>
ffffffffc020316a:	0be00593          	li	a1,190
ffffffffc020316e:	00002517          	auipc	a0,0x2
ffffffffc0203172:	7ba50513          	addi	a0,a0,1978 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203176:	f8dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020317a:	00003697          	auipc	a3,0x3
ffffffffc020317e:	88e68693          	addi	a3,a3,-1906 # ffffffffc0205a08 <commands+0x14f0>
ffffffffc0203182:	00002617          	auipc	a2,0x2
ffffffffc0203186:	c1e60613          	addi	a2,a2,-994 # ffffffffc0204da0 <commands+0x888>
ffffffffc020318a:	0c000593          	li	a1,192
ffffffffc020318e:	00002517          	auipc	a0,0x2
ffffffffc0203192:	79a50513          	addi	a0,a0,1946 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203196:	f6dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020319a:	00003697          	auipc	a3,0x3
ffffffffc020319e:	8f668693          	addi	a3,a3,-1802 # ffffffffc0205a90 <commands+0x1578>
ffffffffc02031a2:	00002617          	auipc	a2,0x2
ffffffffc02031a6:	bfe60613          	addi	a2,a2,-1026 # ffffffffc0204da0 <commands+0x888>
ffffffffc02031aa:	0d900593          	li	a1,217
ffffffffc02031ae:	00002517          	auipc	a0,0x2
ffffffffc02031b2:	77a50513          	addi	a0,a0,1914 # ffffffffc0205928 <commands+0x1410>
ffffffffc02031b6:	f4dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02031ba:	00002697          	auipc	a3,0x2
ffffffffc02031be:	78668693          	addi	a3,a3,1926 # ffffffffc0205940 <commands+0x1428>
ffffffffc02031c2:	00002617          	auipc	a2,0x2
ffffffffc02031c6:	bde60613          	addi	a2,a2,-1058 # ffffffffc0204da0 <commands+0x888>
ffffffffc02031ca:	0d200593          	li	a1,210
ffffffffc02031ce:	00002517          	auipc	a0,0x2
ffffffffc02031d2:	75a50513          	addi	a0,a0,1882 # ffffffffc0205928 <commands+0x1410>
ffffffffc02031d6:	f2dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 3);
ffffffffc02031da:	00003697          	auipc	a3,0x3
ffffffffc02031de:	8a668693          	addi	a3,a3,-1882 # ffffffffc0205a80 <commands+0x1568>
ffffffffc02031e2:	00002617          	auipc	a2,0x2
ffffffffc02031e6:	bbe60613          	addi	a2,a2,-1090 # ffffffffc0204da0 <commands+0x888>
ffffffffc02031ea:	0d000593          	li	a1,208
ffffffffc02031ee:	00002517          	auipc	a0,0x2
ffffffffc02031f2:	73a50513          	addi	a0,a0,1850 # ffffffffc0205928 <commands+0x1410>
ffffffffc02031f6:	f0dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02031fa:	00003697          	auipc	a3,0x3
ffffffffc02031fe:	86e68693          	addi	a3,a3,-1938 # ffffffffc0205a68 <commands+0x1550>
ffffffffc0203202:	00002617          	auipc	a2,0x2
ffffffffc0203206:	b9e60613          	addi	a2,a2,-1122 # ffffffffc0204da0 <commands+0x888>
ffffffffc020320a:	0cb00593          	li	a1,203
ffffffffc020320e:	00002517          	auipc	a0,0x2
ffffffffc0203212:	71a50513          	addi	a0,a0,1818 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203216:	eedfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020321a:	00003697          	auipc	a3,0x3
ffffffffc020321e:	82e68693          	addi	a3,a3,-2002 # ffffffffc0205a48 <commands+0x1530>
ffffffffc0203222:	00002617          	auipc	a2,0x2
ffffffffc0203226:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0204da0 <commands+0x888>
ffffffffc020322a:	0c200593          	li	a1,194
ffffffffc020322e:	00002517          	auipc	a0,0x2
ffffffffc0203232:	6fa50513          	addi	a0,a0,1786 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203236:	ecdfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != NULL);
ffffffffc020323a:	00003697          	auipc	a3,0x3
ffffffffc020323e:	88e68693          	addi	a3,a3,-1906 # ffffffffc0205ac8 <commands+0x15b0>
ffffffffc0203242:	00002617          	auipc	a2,0x2
ffffffffc0203246:	b5e60613          	addi	a2,a2,-1186 # ffffffffc0204da0 <commands+0x888>
ffffffffc020324a:	0f800593          	li	a1,248
ffffffffc020324e:	00002517          	auipc	a0,0x2
ffffffffc0203252:	6da50513          	addi	a0,a0,1754 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203256:	eadfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc020325a:	00002697          	auipc	a3,0x2
ffffffffc020325e:	56e68693          	addi	a3,a3,1390 # ffffffffc02057c8 <commands+0x12b0>
ffffffffc0203262:	00002617          	auipc	a2,0x2
ffffffffc0203266:	b3e60613          	addi	a2,a2,-1218 # ffffffffc0204da0 <commands+0x888>
ffffffffc020326a:	0df00593          	li	a1,223
ffffffffc020326e:	00002517          	auipc	a0,0x2
ffffffffc0203272:	6ba50513          	addi	a0,a0,1722 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203276:	e8dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020327a:	00002697          	auipc	a3,0x2
ffffffffc020327e:	7ee68693          	addi	a3,a3,2030 # ffffffffc0205a68 <commands+0x1550>
ffffffffc0203282:	00002617          	auipc	a2,0x2
ffffffffc0203286:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0204da0 <commands+0x888>
ffffffffc020328a:	0dd00593          	li	a1,221
ffffffffc020328e:	00002517          	auipc	a0,0x2
ffffffffc0203292:	69a50513          	addi	a0,a0,1690 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203296:	e6dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020329a:	00003697          	auipc	a3,0x3
ffffffffc020329e:	80e68693          	addi	a3,a3,-2034 # ffffffffc0205aa8 <commands+0x1590>
ffffffffc02032a2:	00002617          	auipc	a2,0x2
ffffffffc02032a6:	afe60613          	addi	a2,a2,-1282 # ffffffffc0204da0 <commands+0x888>
ffffffffc02032aa:	0dc00593          	li	a1,220
ffffffffc02032ae:	00002517          	auipc	a0,0x2
ffffffffc02032b2:	67a50513          	addi	a0,a0,1658 # ffffffffc0205928 <commands+0x1410>
ffffffffc02032b6:	e4dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02032ba:	00002697          	auipc	a3,0x2
ffffffffc02032be:	68668693          	addi	a3,a3,1670 # ffffffffc0205940 <commands+0x1428>
ffffffffc02032c2:	00002617          	auipc	a2,0x2
ffffffffc02032c6:	ade60613          	addi	a2,a2,-1314 # ffffffffc0204da0 <commands+0x888>
ffffffffc02032ca:	0b900593          	li	a1,185
ffffffffc02032ce:	00002517          	auipc	a0,0x2
ffffffffc02032d2:	65a50513          	addi	a0,a0,1626 # ffffffffc0205928 <commands+0x1410>
ffffffffc02032d6:	e2dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02032da:	00002697          	auipc	a3,0x2
ffffffffc02032de:	78e68693          	addi	a3,a3,1934 # ffffffffc0205a68 <commands+0x1550>
ffffffffc02032e2:	00002617          	auipc	a2,0x2
ffffffffc02032e6:	abe60613          	addi	a2,a2,-1346 # ffffffffc0204da0 <commands+0x888>
ffffffffc02032ea:	0d600593          	li	a1,214
ffffffffc02032ee:	00002517          	auipc	a0,0x2
ffffffffc02032f2:	63a50513          	addi	a0,a0,1594 # ffffffffc0205928 <commands+0x1410>
ffffffffc02032f6:	e0dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02032fa:	00002697          	auipc	a3,0x2
ffffffffc02032fe:	68668693          	addi	a3,a3,1670 # ffffffffc0205980 <commands+0x1468>
ffffffffc0203302:	00002617          	auipc	a2,0x2
ffffffffc0203306:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0204da0 <commands+0x888>
ffffffffc020330a:	0d400593          	li	a1,212
ffffffffc020330e:	00002517          	auipc	a0,0x2
ffffffffc0203312:	61a50513          	addi	a0,a0,1562 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203316:	dedfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020331a:	00002697          	auipc	a3,0x2
ffffffffc020331e:	64668693          	addi	a3,a3,1606 # ffffffffc0205960 <commands+0x1448>
ffffffffc0203322:	00002617          	auipc	a2,0x2
ffffffffc0203326:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0204da0 <commands+0x888>
ffffffffc020332a:	0d300593          	li	a1,211
ffffffffc020332e:	00002517          	auipc	a0,0x2
ffffffffc0203332:	5fa50513          	addi	a0,a0,1530 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203336:	dcdfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020333a:	00002697          	auipc	a3,0x2
ffffffffc020333e:	64668693          	addi	a3,a3,1606 # ffffffffc0205980 <commands+0x1468>
ffffffffc0203342:	00002617          	auipc	a2,0x2
ffffffffc0203346:	a5e60613          	addi	a2,a2,-1442 # ffffffffc0204da0 <commands+0x888>
ffffffffc020334a:	0bb00593          	li	a1,187
ffffffffc020334e:	00002517          	auipc	a0,0x2
ffffffffc0203352:	5da50513          	addi	a0,a0,1498 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203356:	dadfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(count == 0);
ffffffffc020335a:	00003697          	auipc	a3,0x3
ffffffffc020335e:	8be68693          	addi	a3,a3,-1858 # ffffffffc0205c18 <commands+0x1700>
ffffffffc0203362:	00002617          	auipc	a2,0x2
ffffffffc0203366:	a3e60613          	addi	a2,a2,-1474 # ffffffffc0204da0 <commands+0x888>
ffffffffc020336a:	12500593          	li	a1,293
ffffffffc020336e:	00002517          	auipc	a0,0x2
ffffffffc0203372:	5ba50513          	addi	a0,a0,1466 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203376:	d8dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc020337a:	00002697          	auipc	a3,0x2
ffffffffc020337e:	44e68693          	addi	a3,a3,1102 # ffffffffc02057c8 <commands+0x12b0>
ffffffffc0203382:	00002617          	auipc	a2,0x2
ffffffffc0203386:	a1e60613          	addi	a2,a2,-1506 # ffffffffc0204da0 <commands+0x888>
ffffffffc020338a:	11a00593          	li	a1,282
ffffffffc020338e:	00002517          	auipc	a0,0x2
ffffffffc0203392:	59a50513          	addi	a0,a0,1434 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203396:	d6dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020339a:	00002697          	auipc	a3,0x2
ffffffffc020339e:	6ce68693          	addi	a3,a3,1742 # ffffffffc0205a68 <commands+0x1550>
ffffffffc02033a2:	00002617          	auipc	a2,0x2
ffffffffc02033a6:	9fe60613          	addi	a2,a2,-1538 # ffffffffc0204da0 <commands+0x888>
ffffffffc02033aa:	11800593          	li	a1,280
ffffffffc02033ae:	00002517          	auipc	a0,0x2
ffffffffc02033b2:	57a50513          	addi	a0,a0,1402 # ffffffffc0205928 <commands+0x1410>
ffffffffc02033b6:	d4dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02033ba:	00002697          	auipc	a3,0x2
ffffffffc02033be:	66e68693          	addi	a3,a3,1646 # ffffffffc0205a28 <commands+0x1510>
ffffffffc02033c2:	00002617          	auipc	a2,0x2
ffffffffc02033c6:	9de60613          	addi	a2,a2,-1570 # ffffffffc0204da0 <commands+0x888>
ffffffffc02033ca:	0c100593          	li	a1,193
ffffffffc02033ce:	00002517          	auipc	a0,0x2
ffffffffc02033d2:	55a50513          	addi	a0,a0,1370 # ffffffffc0205928 <commands+0x1410>
ffffffffc02033d6:	d2dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02033da:	00002697          	auipc	a3,0x2
ffffffffc02033de:	7fe68693          	addi	a3,a3,2046 # ffffffffc0205bd8 <commands+0x16c0>
ffffffffc02033e2:	00002617          	auipc	a2,0x2
ffffffffc02033e6:	9be60613          	addi	a2,a2,-1602 # ffffffffc0204da0 <commands+0x888>
ffffffffc02033ea:	11200593          	li	a1,274
ffffffffc02033ee:	00002517          	auipc	a0,0x2
ffffffffc02033f2:	53a50513          	addi	a0,a0,1338 # ffffffffc0205928 <commands+0x1410>
ffffffffc02033f6:	d0dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02033fa:	00002697          	auipc	a3,0x2
ffffffffc02033fe:	7be68693          	addi	a3,a3,1982 # ffffffffc0205bb8 <commands+0x16a0>
ffffffffc0203402:	00002617          	auipc	a2,0x2
ffffffffc0203406:	99e60613          	addi	a2,a2,-1634 # ffffffffc0204da0 <commands+0x888>
ffffffffc020340a:	11000593          	li	a1,272
ffffffffc020340e:	00002517          	auipc	a0,0x2
ffffffffc0203412:	51a50513          	addi	a0,a0,1306 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203416:	cedfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020341a:	00002697          	auipc	a3,0x2
ffffffffc020341e:	77668693          	addi	a3,a3,1910 # ffffffffc0205b90 <commands+0x1678>
ffffffffc0203422:	00002617          	auipc	a2,0x2
ffffffffc0203426:	97e60613          	addi	a2,a2,-1666 # ffffffffc0204da0 <commands+0x888>
ffffffffc020342a:	10e00593          	li	a1,270
ffffffffc020342e:	00002517          	auipc	a0,0x2
ffffffffc0203432:	4fa50513          	addi	a0,a0,1274 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203436:	ccdfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020343a:	00002697          	auipc	a3,0x2
ffffffffc020343e:	72e68693          	addi	a3,a3,1838 # ffffffffc0205b68 <commands+0x1650>
ffffffffc0203442:	00002617          	auipc	a2,0x2
ffffffffc0203446:	95e60613          	addi	a2,a2,-1698 # ffffffffc0204da0 <commands+0x888>
ffffffffc020344a:	10d00593          	li	a1,269
ffffffffc020344e:	00002517          	auipc	a0,0x2
ffffffffc0203452:	4da50513          	addi	a0,a0,1242 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203456:	cadfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020345a:	00002697          	auipc	a3,0x2
ffffffffc020345e:	6fe68693          	addi	a3,a3,1790 # ffffffffc0205b58 <commands+0x1640>
ffffffffc0203462:	00002617          	auipc	a2,0x2
ffffffffc0203466:	93e60613          	addi	a2,a2,-1730 # ffffffffc0204da0 <commands+0x888>
ffffffffc020346a:	10800593          	li	a1,264
ffffffffc020346e:	00002517          	auipc	a0,0x2
ffffffffc0203472:	4ba50513          	addi	a0,a0,1210 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203476:	c8dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020347a:	00002697          	auipc	a3,0x2
ffffffffc020347e:	5ee68693          	addi	a3,a3,1518 # ffffffffc0205a68 <commands+0x1550>
ffffffffc0203482:	00002617          	auipc	a2,0x2
ffffffffc0203486:	91e60613          	addi	a2,a2,-1762 # ffffffffc0204da0 <commands+0x888>
ffffffffc020348a:	10700593          	li	a1,263
ffffffffc020348e:	00002517          	auipc	a0,0x2
ffffffffc0203492:	49a50513          	addi	a0,a0,1178 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203496:	c6dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020349a:	00002697          	auipc	a3,0x2
ffffffffc020349e:	69e68693          	addi	a3,a3,1694 # ffffffffc0205b38 <commands+0x1620>
ffffffffc02034a2:	00002617          	auipc	a2,0x2
ffffffffc02034a6:	8fe60613          	addi	a2,a2,-1794 # ffffffffc0204da0 <commands+0x888>
ffffffffc02034aa:	10600593          	li	a1,262
ffffffffc02034ae:	00002517          	auipc	a0,0x2
ffffffffc02034b2:	47a50513          	addi	a0,a0,1146 # ffffffffc0205928 <commands+0x1410>
ffffffffc02034b6:	c4dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02034ba:	00002697          	auipc	a3,0x2
ffffffffc02034be:	64e68693          	addi	a3,a3,1614 # ffffffffc0205b08 <commands+0x15f0>
ffffffffc02034c2:	00002617          	auipc	a2,0x2
ffffffffc02034c6:	8de60613          	addi	a2,a2,-1826 # ffffffffc0204da0 <commands+0x888>
ffffffffc02034ca:	10500593          	li	a1,261
ffffffffc02034ce:	00002517          	auipc	a0,0x2
ffffffffc02034d2:	45a50513          	addi	a0,a0,1114 # ffffffffc0205928 <commands+0x1410>
ffffffffc02034d6:	c2dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02034da:	00002697          	auipc	a3,0x2
ffffffffc02034de:	61668693          	addi	a3,a3,1558 # ffffffffc0205af0 <commands+0x15d8>
ffffffffc02034e2:	00002617          	auipc	a2,0x2
ffffffffc02034e6:	8be60613          	addi	a2,a2,-1858 # ffffffffc0204da0 <commands+0x888>
ffffffffc02034ea:	10400593          	li	a1,260
ffffffffc02034ee:	00002517          	auipc	a0,0x2
ffffffffc02034f2:	43a50513          	addi	a0,a0,1082 # ffffffffc0205928 <commands+0x1410>
ffffffffc02034f6:	c0dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02034fa:	00002697          	auipc	a3,0x2
ffffffffc02034fe:	56e68693          	addi	a3,a3,1390 # ffffffffc0205a68 <commands+0x1550>
ffffffffc0203502:	00002617          	auipc	a2,0x2
ffffffffc0203506:	89e60613          	addi	a2,a2,-1890 # ffffffffc0204da0 <commands+0x888>
ffffffffc020350a:	0fe00593          	li	a1,254
ffffffffc020350e:	00002517          	auipc	a0,0x2
ffffffffc0203512:	41a50513          	addi	a0,a0,1050 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203516:	bedfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!PageProperty(p0));
ffffffffc020351a:	00002697          	auipc	a3,0x2
ffffffffc020351e:	5be68693          	addi	a3,a3,1470 # ffffffffc0205ad8 <commands+0x15c0>
ffffffffc0203522:	00002617          	auipc	a2,0x2
ffffffffc0203526:	87e60613          	addi	a2,a2,-1922 # ffffffffc0204da0 <commands+0x888>
ffffffffc020352a:	0f900593          	li	a1,249
ffffffffc020352e:	00002517          	auipc	a0,0x2
ffffffffc0203532:	3fa50513          	addi	a0,a0,1018 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203536:	bcdfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020353a:	00002697          	auipc	a3,0x2
ffffffffc020353e:	6be68693          	addi	a3,a3,1726 # ffffffffc0205bf8 <commands+0x16e0>
ffffffffc0203542:	00002617          	auipc	a2,0x2
ffffffffc0203546:	85e60613          	addi	a2,a2,-1954 # ffffffffc0204da0 <commands+0x888>
ffffffffc020354a:	11700593          	li	a1,279
ffffffffc020354e:	00002517          	auipc	a0,0x2
ffffffffc0203552:	3da50513          	addi	a0,a0,986 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203556:	badfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == 0);
ffffffffc020355a:	00002697          	auipc	a3,0x2
ffffffffc020355e:	6ce68693          	addi	a3,a3,1742 # ffffffffc0205c28 <commands+0x1710>
ffffffffc0203562:	00002617          	auipc	a2,0x2
ffffffffc0203566:	83e60613          	addi	a2,a2,-1986 # ffffffffc0204da0 <commands+0x888>
ffffffffc020356a:	12600593          	li	a1,294
ffffffffc020356e:	00002517          	auipc	a0,0x2
ffffffffc0203572:	3ba50513          	addi	a0,a0,954 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203576:	b8dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == nr_free_pages());
ffffffffc020357a:	00002697          	auipc	a3,0x2
ffffffffc020357e:	0ae68693          	addi	a3,a3,174 # ffffffffc0205628 <commands+0x1110>
ffffffffc0203582:	00002617          	auipc	a2,0x2
ffffffffc0203586:	81e60613          	addi	a2,a2,-2018 # ffffffffc0204da0 <commands+0x888>
ffffffffc020358a:	0f300593          	li	a1,243
ffffffffc020358e:	00002517          	auipc	a0,0x2
ffffffffc0203592:	39a50513          	addi	a0,a0,922 # ffffffffc0205928 <commands+0x1410>
ffffffffc0203596:	b6dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020359a:	00002697          	auipc	a3,0x2
ffffffffc020359e:	3c668693          	addi	a3,a3,966 # ffffffffc0205960 <commands+0x1448>
ffffffffc02035a2:	00001617          	auipc	a2,0x1
ffffffffc02035a6:	7fe60613          	addi	a2,a2,2046 # ffffffffc0204da0 <commands+0x888>
ffffffffc02035aa:	0ba00593          	li	a1,186
ffffffffc02035ae:	00002517          	auipc	a0,0x2
ffffffffc02035b2:	37a50513          	addi	a0,a0,890 # ffffffffc0205928 <commands+0x1410>
ffffffffc02035b6:	b4dfc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02035ba <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02035ba:	1141                	addi	sp,sp,-16
ffffffffc02035bc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02035be:	14058a63          	beqz	a1,ffffffffc0203712 <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc02035c2:	00359693          	slli	a3,a1,0x3
ffffffffc02035c6:	96ae                	add	a3,a3,a1
ffffffffc02035c8:	068e                	slli	a3,a3,0x3
ffffffffc02035ca:	96aa                	add	a3,a3,a0
ffffffffc02035cc:	87aa                	mv	a5,a0
ffffffffc02035ce:	02d50263          	beq	a0,a3,ffffffffc02035f2 <default_free_pages+0x38>
ffffffffc02035d2:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02035d4:	8b05                	andi	a4,a4,1
ffffffffc02035d6:	10071e63          	bnez	a4,ffffffffc02036f2 <default_free_pages+0x138>
ffffffffc02035da:	6798                	ld	a4,8(a5)
ffffffffc02035dc:	8b09                	andi	a4,a4,2
ffffffffc02035de:	10071a63          	bnez	a4,ffffffffc02036f2 <default_free_pages+0x138>
        p->flags = 0;
ffffffffc02035e2:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02035e6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02035ea:	04878793          	addi	a5,a5,72
ffffffffc02035ee:	fed792e3          	bne	a5,a3,ffffffffc02035d2 <default_free_pages+0x18>
    base->property = n;
ffffffffc02035f2:	2581                	sext.w	a1,a1
ffffffffc02035f4:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc02035f6:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02035fa:	4789                	li	a5,2
ffffffffc02035fc:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203600:	0000e697          	auipc	a3,0xe
ffffffffc0203604:	ad068693          	addi	a3,a3,-1328 # ffffffffc02110d0 <free_area>
ffffffffc0203608:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020360a:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020360c:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0203610:	9db9                	addw	a1,a1,a4
ffffffffc0203612:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0203614:	0ad78863          	beq	a5,a3,ffffffffc02036c4 <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0203618:	fe078713          	addi	a4,a5,-32
ffffffffc020361c:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203620:	4581                	li	a1,0
            if (base < page) {
ffffffffc0203622:	00e56a63          	bltu	a0,a4,ffffffffc0203636 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc0203626:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203628:	06d70263          	beq	a4,a3,ffffffffc020368c <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc020362c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020362e:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0203632:	fee57ae3          	bgeu	a0,a4,ffffffffc0203626 <default_free_pages+0x6c>
ffffffffc0203636:	c199                	beqz	a1,ffffffffc020363c <default_free_pages+0x82>
ffffffffc0203638:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020363c:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020363e:	e390                	sd	a2,0(a5)
ffffffffc0203640:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203642:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203644:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc0203646:	02d70063          	beq	a4,a3,ffffffffc0203666 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc020364a:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc020364e:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc0203652:	02081613          	slli	a2,a6,0x20
ffffffffc0203656:	9201                	srli	a2,a2,0x20
ffffffffc0203658:	00361793          	slli	a5,a2,0x3
ffffffffc020365c:	97b2                	add	a5,a5,a2
ffffffffc020365e:	078e                	slli	a5,a5,0x3
ffffffffc0203660:	97ae                	add	a5,a5,a1
ffffffffc0203662:	02f50f63          	beq	a0,a5,ffffffffc02036a0 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc0203666:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0203668:	00d70f63          	beq	a4,a3,ffffffffc0203686 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc020366c:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc020366e:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc0203672:	02059613          	slli	a2,a1,0x20
ffffffffc0203676:	9201                	srli	a2,a2,0x20
ffffffffc0203678:	00361793          	slli	a5,a2,0x3
ffffffffc020367c:	97b2                	add	a5,a5,a2
ffffffffc020367e:	078e                	slli	a5,a5,0x3
ffffffffc0203680:	97aa                	add	a5,a5,a0
ffffffffc0203682:	04f68863          	beq	a3,a5,ffffffffc02036d2 <default_free_pages+0x118>
}
ffffffffc0203686:	60a2                	ld	ra,8(sp)
ffffffffc0203688:	0141                	addi	sp,sp,16
ffffffffc020368a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020368c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020368e:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0203690:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203692:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203694:	02d70563          	beq	a4,a3,ffffffffc02036be <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0203698:	8832                	mv	a6,a2
ffffffffc020369a:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020369c:	87ba                	mv	a5,a4
ffffffffc020369e:	bf41                	j	ffffffffc020362e <default_free_pages+0x74>
            p->property += base->property;
ffffffffc02036a0:	4d1c                	lw	a5,24(a0)
ffffffffc02036a2:	0107883b          	addw	a6,a5,a6
ffffffffc02036a6:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02036aa:	57f5                	li	a5,-3
ffffffffc02036ac:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02036b0:	7110                	ld	a2,32(a0)
ffffffffc02036b2:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc02036b4:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc02036b6:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02036b8:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02036ba:	e390                	sd	a2,0(a5)
ffffffffc02036bc:	b775                	j	ffffffffc0203668 <default_free_pages+0xae>
ffffffffc02036be:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02036c0:	873e                	mv	a4,a5
ffffffffc02036c2:	b761                	j	ffffffffc020364a <default_free_pages+0x90>
}
ffffffffc02036c4:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02036c6:	e390                	sd	a2,0(a5)
ffffffffc02036c8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02036ca:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02036cc:	f11c                	sd	a5,32(a0)
ffffffffc02036ce:	0141                	addi	sp,sp,16
ffffffffc02036d0:	8082                	ret
            base->property += p->property;
ffffffffc02036d2:	ff872783          	lw	a5,-8(a4)
ffffffffc02036d6:	fe870693          	addi	a3,a4,-24
ffffffffc02036da:	9dbd                	addw	a1,a1,a5
ffffffffc02036dc:	cd0c                	sw	a1,24(a0)
ffffffffc02036de:	57f5                	li	a5,-3
ffffffffc02036e0:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02036e4:	6314                	ld	a3,0(a4)
ffffffffc02036e6:	671c                	ld	a5,8(a4)
}
ffffffffc02036e8:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02036ea:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02036ec:	e394                	sd	a3,0(a5)
ffffffffc02036ee:	0141                	addi	sp,sp,16
ffffffffc02036f0:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02036f2:	00002697          	auipc	a3,0x2
ffffffffc02036f6:	54e68693          	addi	a3,a3,1358 # ffffffffc0205c40 <commands+0x1728>
ffffffffc02036fa:	00001617          	auipc	a2,0x1
ffffffffc02036fe:	6a660613          	addi	a2,a2,1702 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203702:	08300593          	li	a1,131
ffffffffc0203706:	00002517          	auipc	a0,0x2
ffffffffc020370a:	22250513          	addi	a0,a0,546 # ffffffffc0205928 <commands+0x1410>
ffffffffc020370e:	9f5fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc0203712:	00002697          	auipc	a3,0x2
ffffffffc0203716:	52668693          	addi	a3,a3,1318 # ffffffffc0205c38 <commands+0x1720>
ffffffffc020371a:	00001617          	auipc	a2,0x1
ffffffffc020371e:	68660613          	addi	a2,a2,1670 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203722:	08000593          	li	a1,128
ffffffffc0203726:	00002517          	auipc	a0,0x2
ffffffffc020372a:	20250513          	addi	a0,a0,514 # ffffffffc0205928 <commands+0x1410>
ffffffffc020372e:	9d5fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203732 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0203732:	c959                	beqz	a0,ffffffffc02037c8 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0203734:	0000e597          	auipc	a1,0xe
ffffffffc0203738:	99c58593          	addi	a1,a1,-1636 # ffffffffc02110d0 <free_area>
ffffffffc020373c:	0105a803          	lw	a6,16(a1)
ffffffffc0203740:	862a                	mv	a2,a0
ffffffffc0203742:	02081793          	slli	a5,a6,0x20
ffffffffc0203746:	9381                	srli	a5,a5,0x20
ffffffffc0203748:	00a7ee63          	bltu	a5,a0,ffffffffc0203764 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020374c:	87ae                	mv	a5,a1
ffffffffc020374e:	a801                	j	ffffffffc020375e <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0203750:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203754:	02071693          	slli	a3,a4,0x20
ffffffffc0203758:	9281                	srli	a3,a3,0x20
ffffffffc020375a:	00c6f763          	bgeu	a3,a2,ffffffffc0203768 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020375e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203760:	feb798e3          	bne	a5,a1,ffffffffc0203750 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0203764:	4501                	li	a0,0
}
ffffffffc0203766:	8082                	ret
    return listelm->prev;
ffffffffc0203768:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020376c:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0203770:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc0203774:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0203778:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020377c:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0203780:	02d67b63          	bgeu	a2,a3,ffffffffc02037b6 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc0203784:	00361693          	slli	a3,a2,0x3
ffffffffc0203788:	96b2                	add	a3,a3,a2
ffffffffc020378a:	068e                	slli	a3,a3,0x3
ffffffffc020378c:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc020378e:	41c7073b          	subw	a4,a4,t3
ffffffffc0203792:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203794:	00868613          	addi	a2,a3,8
ffffffffc0203798:	4709                	li	a4,2
ffffffffc020379a:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc020379e:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02037a2:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc02037a6:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02037aa:	e310                	sd	a2,0(a4)
ffffffffc02037ac:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02037b0:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc02037b2:	0316b023          	sd	a7,32(a3)
ffffffffc02037b6:	41c8083b          	subw	a6,a6,t3
ffffffffc02037ba:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02037be:	5775                	li	a4,-3
ffffffffc02037c0:	17a1                	addi	a5,a5,-24
ffffffffc02037c2:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02037c6:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02037c8:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02037ca:	00002697          	auipc	a3,0x2
ffffffffc02037ce:	46e68693          	addi	a3,a3,1134 # ffffffffc0205c38 <commands+0x1720>
ffffffffc02037d2:	00001617          	auipc	a2,0x1
ffffffffc02037d6:	5ce60613          	addi	a2,a2,1486 # ffffffffc0204da0 <commands+0x888>
ffffffffc02037da:	06200593          	li	a1,98
ffffffffc02037de:	00002517          	auipc	a0,0x2
ffffffffc02037e2:	14a50513          	addi	a0,a0,330 # ffffffffc0205928 <commands+0x1410>
default_alloc_pages(size_t n) {
ffffffffc02037e6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02037e8:	91bfc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02037ec <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02037ec:	1141                	addi	sp,sp,-16
ffffffffc02037ee:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02037f0:	c9e1                	beqz	a1,ffffffffc02038c0 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02037f2:	00359693          	slli	a3,a1,0x3
ffffffffc02037f6:	96ae                	add	a3,a3,a1
ffffffffc02037f8:	068e                	slli	a3,a3,0x3
ffffffffc02037fa:	96aa                	add	a3,a3,a0
ffffffffc02037fc:	87aa                	mv	a5,a0
ffffffffc02037fe:	00d50f63          	beq	a0,a3,ffffffffc020381c <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203802:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0203804:	8b05                	andi	a4,a4,1
ffffffffc0203806:	cf49                	beqz	a4,ffffffffc02038a0 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0203808:	0007ac23          	sw	zero,24(a5)
ffffffffc020380c:	0007b423          	sd	zero,8(a5)
ffffffffc0203810:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203814:	04878793          	addi	a5,a5,72
ffffffffc0203818:	fed795e3          	bne	a5,a3,ffffffffc0203802 <default_init_memmap+0x16>
    base->property = n;
ffffffffc020381c:	2581                	sext.w	a1,a1
ffffffffc020381e:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203820:	4789                	li	a5,2
ffffffffc0203822:	00850713          	addi	a4,a0,8
ffffffffc0203826:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020382a:	0000e697          	auipc	a3,0xe
ffffffffc020382e:	8a668693          	addi	a3,a3,-1882 # ffffffffc02110d0 <free_area>
ffffffffc0203832:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203834:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0203836:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc020383a:	9db9                	addw	a1,a1,a4
ffffffffc020383c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020383e:	04d78a63          	beq	a5,a3,ffffffffc0203892 <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0203842:	fe078713          	addi	a4,a5,-32
ffffffffc0203846:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020384a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020384c:	00e56a63          	bltu	a0,a4,ffffffffc0203860 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0203850:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203852:	02d70263          	beq	a4,a3,ffffffffc0203876 <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0203856:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203858:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020385c:	fee57ae3          	bgeu	a0,a4,ffffffffc0203850 <default_init_memmap+0x64>
ffffffffc0203860:	c199                	beqz	a1,ffffffffc0203866 <default_init_memmap+0x7a>
ffffffffc0203862:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203866:	6398                	ld	a4,0(a5)
}
ffffffffc0203868:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020386a:	e390                	sd	a2,0(a5)
ffffffffc020386c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020386e:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203870:	f118                	sd	a4,32(a0)
ffffffffc0203872:	0141                	addi	sp,sp,16
ffffffffc0203874:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203876:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203878:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc020387a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020387c:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020387e:	00d70663          	beq	a4,a3,ffffffffc020388a <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0203882:	8832                	mv	a6,a2
ffffffffc0203884:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0203886:	87ba                	mv	a5,a4
ffffffffc0203888:	bfc1                	j	ffffffffc0203858 <default_init_memmap+0x6c>
}
ffffffffc020388a:	60a2                	ld	ra,8(sp)
ffffffffc020388c:	e290                	sd	a2,0(a3)
ffffffffc020388e:	0141                	addi	sp,sp,16
ffffffffc0203890:	8082                	ret
ffffffffc0203892:	60a2                	ld	ra,8(sp)
ffffffffc0203894:	e390                	sd	a2,0(a5)
ffffffffc0203896:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203898:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020389a:	f11c                	sd	a5,32(a0)
ffffffffc020389c:	0141                	addi	sp,sp,16
ffffffffc020389e:	8082                	ret
        assert(PageReserved(p));
ffffffffc02038a0:	00002697          	auipc	a3,0x2
ffffffffc02038a4:	3c868693          	addi	a3,a3,968 # ffffffffc0205c68 <commands+0x1750>
ffffffffc02038a8:	00001617          	auipc	a2,0x1
ffffffffc02038ac:	4f860613          	addi	a2,a2,1272 # ffffffffc0204da0 <commands+0x888>
ffffffffc02038b0:	04900593          	li	a1,73
ffffffffc02038b4:	00002517          	auipc	a0,0x2
ffffffffc02038b8:	07450513          	addi	a0,a0,116 # ffffffffc0205928 <commands+0x1410>
ffffffffc02038bc:	847fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc02038c0:	00002697          	auipc	a3,0x2
ffffffffc02038c4:	37868693          	addi	a3,a3,888 # ffffffffc0205c38 <commands+0x1720>
ffffffffc02038c8:	00001617          	auipc	a2,0x1
ffffffffc02038cc:	4d860613          	addi	a2,a2,1240 # ffffffffc0204da0 <commands+0x888>
ffffffffc02038d0:	04600593          	li	a1,70
ffffffffc02038d4:	00002517          	auipc	a0,0x2
ffffffffc02038d8:	05450513          	addi	a0,a0,84 # ffffffffc0205928 <commands+0x1410>
ffffffffc02038dc:	827fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02038e0 <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02038e0:	0000e797          	auipc	a5,0xe
ffffffffc02038e4:	80878793          	addi	a5,a5,-2040 # ffffffffc02110e8 <pra_list_head>
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    list_init(&pra_list_head);
    curr_ptr = &pra_list_head;
    mm->sm_priv = &pra_list_head;
ffffffffc02038e8:	f51c                	sd	a5,40(a0)
ffffffffc02038ea:	e79c                	sd	a5,8(a5)
ffffffffc02038ec:	e39c                	sd	a5,0(a5)
    curr_ptr = &pra_list_head;
ffffffffc02038ee:	0000e717          	auipc	a4,0xe
ffffffffc02038f2:	c6f73d23          	sd	a5,-902(a4) # ffffffffc0211568 <curr_ptr>
     return 0;
}
ffffffffc02038f6:	4501                	li	a0,0
ffffffffc02038f8:	8082                	ret

ffffffffc02038fa <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc02038fa:	4501                	li	a0,0
ffffffffc02038fc:	8082                	ret

ffffffffc02038fe <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02038fe:	4501                	li	a0,0
ffffffffc0203900:	8082                	ret

ffffffffc0203902 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203902:	4501                	li	a0,0
ffffffffc0203904:	8082                	ret

ffffffffc0203906 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc0203906:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203908:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc020390a:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020390c:	678d                	lui	a5,0x3
ffffffffc020390e:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203912:	0000e697          	auipc	a3,0xe
ffffffffc0203916:	c366a683          	lw	a3,-970(a3) # ffffffffc0211548 <pgfault_num>
ffffffffc020391a:	4711                	li	a4,4
ffffffffc020391c:	0ae69363          	bne	a3,a4,ffffffffc02039c2 <_clock_check_swap+0xbc>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203920:	6705                	lui	a4,0x1
ffffffffc0203922:	4629                	li	a2,10
ffffffffc0203924:	0000e797          	auipc	a5,0xe
ffffffffc0203928:	c2478793          	addi	a5,a5,-988 # ffffffffc0211548 <pgfault_num>
ffffffffc020392c:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203930:	4398                	lw	a4,0(a5)
ffffffffc0203932:	2701                	sext.w	a4,a4
ffffffffc0203934:	20d71763          	bne	a4,a3,ffffffffc0203b42 <_clock_check_swap+0x23c>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203938:	6691                	lui	a3,0x4
ffffffffc020393a:	4635                	li	a2,13
ffffffffc020393c:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203940:	4394                	lw	a3,0(a5)
ffffffffc0203942:	2681                	sext.w	a3,a3
ffffffffc0203944:	1ce69f63          	bne	a3,a4,ffffffffc0203b22 <_clock_check_swap+0x21c>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203948:	6709                	lui	a4,0x2
ffffffffc020394a:	462d                	li	a2,11
ffffffffc020394c:	00c70023          	sb	a2,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203950:	4398                	lw	a4,0(a5)
ffffffffc0203952:	2701                	sext.w	a4,a4
ffffffffc0203954:	1ad71763          	bne	a4,a3,ffffffffc0203b02 <_clock_check_swap+0x1fc>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203958:	6715                	lui	a4,0x5
ffffffffc020395a:	46b9                	li	a3,14
ffffffffc020395c:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203960:	4398                	lw	a4,0(a5)
ffffffffc0203962:	4695                	li	a3,5
ffffffffc0203964:	2701                	sext.w	a4,a4
ffffffffc0203966:	16d71e63          	bne	a4,a3,ffffffffc0203ae2 <_clock_check_swap+0x1dc>
    assert(pgfault_num==5);
ffffffffc020396a:	4394                	lw	a3,0(a5)
ffffffffc020396c:	2681                	sext.w	a3,a3
ffffffffc020396e:	14e69a63          	bne	a3,a4,ffffffffc0203ac2 <_clock_check_swap+0x1bc>
    assert(pgfault_num==5);
ffffffffc0203972:	4398                	lw	a4,0(a5)
ffffffffc0203974:	2701                	sext.w	a4,a4
ffffffffc0203976:	12d71663          	bne	a4,a3,ffffffffc0203aa2 <_clock_check_swap+0x19c>
    assert(pgfault_num==5);
ffffffffc020397a:	4394                	lw	a3,0(a5)
ffffffffc020397c:	2681                	sext.w	a3,a3
ffffffffc020397e:	10e69263          	bne	a3,a4,ffffffffc0203a82 <_clock_check_swap+0x17c>
    assert(pgfault_num==5);
ffffffffc0203982:	4398                	lw	a4,0(a5)
ffffffffc0203984:	2701                	sext.w	a4,a4
ffffffffc0203986:	0cd71e63          	bne	a4,a3,ffffffffc0203a62 <_clock_check_swap+0x15c>
    assert(pgfault_num==5);
ffffffffc020398a:	4394                	lw	a3,0(a5)
ffffffffc020398c:	2681                	sext.w	a3,a3
ffffffffc020398e:	0ae69a63          	bne	a3,a4,ffffffffc0203a42 <_clock_check_swap+0x13c>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203992:	6715                	lui	a4,0x5
ffffffffc0203994:	46b9                	li	a3,14
ffffffffc0203996:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc020399a:	4398                	lw	a4,0(a5)
ffffffffc020399c:	4695                	li	a3,5
ffffffffc020399e:	2701                	sext.w	a4,a4
ffffffffc02039a0:	08d71163          	bne	a4,a3,ffffffffc0203a22 <_clock_check_swap+0x11c>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02039a4:	6705                	lui	a4,0x1
ffffffffc02039a6:	00074683          	lbu	a3,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02039aa:	4729                	li	a4,10
ffffffffc02039ac:	04e69b63          	bne	a3,a4,ffffffffc0203a02 <_clock_check_swap+0xfc>
    assert(pgfault_num==6);
ffffffffc02039b0:	439c                	lw	a5,0(a5)
ffffffffc02039b2:	4719                	li	a4,6
ffffffffc02039b4:	2781                	sext.w	a5,a5
ffffffffc02039b6:	02e79663          	bne	a5,a4,ffffffffc02039e2 <_clock_check_swap+0xdc>
}
ffffffffc02039ba:	60a2                	ld	ra,8(sp)
ffffffffc02039bc:	4501                	li	a0,0
ffffffffc02039be:	0141                	addi	sp,sp,16
ffffffffc02039c0:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02039c2:	00002697          	auipc	a3,0x2
ffffffffc02039c6:	df668693          	addi	a3,a3,-522 # ffffffffc02057b8 <commands+0x12a0>
ffffffffc02039ca:	00001617          	auipc	a2,0x1
ffffffffc02039ce:	3d660613          	addi	a2,a2,982 # ffffffffc0204da0 <commands+0x888>
ffffffffc02039d2:	09600593          	li	a1,150
ffffffffc02039d6:	00002517          	auipc	a0,0x2
ffffffffc02039da:	2f250513          	addi	a0,a0,754 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc02039de:	f24fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==6);
ffffffffc02039e2:	00002697          	auipc	a3,0x2
ffffffffc02039e6:	33668693          	addi	a3,a3,822 # ffffffffc0205d18 <default_pmm_manager+0x88>
ffffffffc02039ea:	00001617          	auipc	a2,0x1
ffffffffc02039ee:	3b660613          	addi	a2,a2,950 # ffffffffc0204da0 <commands+0x888>
ffffffffc02039f2:	0ad00593          	li	a1,173
ffffffffc02039f6:	00002517          	auipc	a0,0x2
ffffffffc02039fa:	2d250513          	addi	a0,a0,722 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc02039fe:	f04fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203a02:	00002697          	auipc	a3,0x2
ffffffffc0203a06:	2ee68693          	addi	a3,a3,750 # ffffffffc0205cf0 <default_pmm_manager+0x60>
ffffffffc0203a0a:	00001617          	auipc	a2,0x1
ffffffffc0203a0e:	39660613          	addi	a2,a2,918 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203a12:	0ab00593          	li	a1,171
ffffffffc0203a16:	00002517          	auipc	a0,0x2
ffffffffc0203a1a:	2b250513          	addi	a0,a0,690 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc0203a1e:	ee4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a22:	00002697          	auipc	a3,0x2
ffffffffc0203a26:	2be68693          	addi	a3,a3,702 # ffffffffc0205ce0 <default_pmm_manager+0x50>
ffffffffc0203a2a:	00001617          	auipc	a2,0x1
ffffffffc0203a2e:	37660613          	addi	a2,a2,886 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203a32:	0aa00593          	li	a1,170
ffffffffc0203a36:	00002517          	auipc	a0,0x2
ffffffffc0203a3a:	29250513          	addi	a0,a0,658 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc0203a3e:	ec4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a42:	00002697          	auipc	a3,0x2
ffffffffc0203a46:	29e68693          	addi	a3,a3,670 # ffffffffc0205ce0 <default_pmm_manager+0x50>
ffffffffc0203a4a:	00001617          	auipc	a2,0x1
ffffffffc0203a4e:	35660613          	addi	a2,a2,854 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203a52:	0a800593          	li	a1,168
ffffffffc0203a56:	00002517          	auipc	a0,0x2
ffffffffc0203a5a:	27250513          	addi	a0,a0,626 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc0203a5e:	ea4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a62:	00002697          	auipc	a3,0x2
ffffffffc0203a66:	27e68693          	addi	a3,a3,638 # ffffffffc0205ce0 <default_pmm_manager+0x50>
ffffffffc0203a6a:	00001617          	auipc	a2,0x1
ffffffffc0203a6e:	33660613          	addi	a2,a2,822 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203a72:	0a600593          	li	a1,166
ffffffffc0203a76:	00002517          	auipc	a0,0x2
ffffffffc0203a7a:	25250513          	addi	a0,a0,594 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc0203a7e:	e84fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a82:	00002697          	auipc	a3,0x2
ffffffffc0203a86:	25e68693          	addi	a3,a3,606 # ffffffffc0205ce0 <default_pmm_manager+0x50>
ffffffffc0203a8a:	00001617          	auipc	a2,0x1
ffffffffc0203a8e:	31660613          	addi	a2,a2,790 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203a92:	0a400593          	li	a1,164
ffffffffc0203a96:	00002517          	auipc	a0,0x2
ffffffffc0203a9a:	23250513          	addi	a0,a0,562 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc0203a9e:	e64fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0203aa2:	00002697          	auipc	a3,0x2
ffffffffc0203aa6:	23e68693          	addi	a3,a3,574 # ffffffffc0205ce0 <default_pmm_manager+0x50>
ffffffffc0203aaa:	00001617          	auipc	a2,0x1
ffffffffc0203aae:	2f660613          	addi	a2,a2,758 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203ab2:	0a200593          	li	a1,162
ffffffffc0203ab6:	00002517          	auipc	a0,0x2
ffffffffc0203aba:	21250513          	addi	a0,a0,530 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc0203abe:	e44fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0203ac2:	00002697          	auipc	a3,0x2
ffffffffc0203ac6:	21e68693          	addi	a3,a3,542 # ffffffffc0205ce0 <default_pmm_manager+0x50>
ffffffffc0203aca:	00001617          	auipc	a2,0x1
ffffffffc0203ace:	2d660613          	addi	a2,a2,726 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203ad2:	0a000593          	li	a1,160
ffffffffc0203ad6:	00002517          	auipc	a0,0x2
ffffffffc0203ada:	1f250513          	addi	a0,a0,498 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc0203ade:	e24fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0203ae2:	00002697          	auipc	a3,0x2
ffffffffc0203ae6:	1fe68693          	addi	a3,a3,510 # ffffffffc0205ce0 <default_pmm_manager+0x50>
ffffffffc0203aea:	00001617          	auipc	a2,0x1
ffffffffc0203aee:	2b660613          	addi	a2,a2,694 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203af2:	09e00593          	li	a1,158
ffffffffc0203af6:	00002517          	auipc	a0,0x2
ffffffffc0203afa:	1d250513          	addi	a0,a0,466 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc0203afe:	e04fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0203b02:	00002697          	auipc	a3,0x2
ffffffffc0203b06:	cb668693          	addi	a3,a3,-842 # ffffffffc02057b8 <commands+0x12a0>
ffffffffc0203b0a:	00001617          	auipc	a2,0x1
ffffffffc0203b0e:	29660613          	addi	a2,a2,662 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203b12:	09c00593          	li	a1,156
ffffffffc0203b16:	00002517          	auipc	a0,0x2
ffffffffc0203b1a:	1b250513          	addi	a0,a0,434 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc0203b1e:	de4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0203b22:	00002697          	auipc	a3,0x2
ffffffffc0203b26:	c9668693          	addi	a3,a3,-874 # ffffffffc02057b8 <commands+0x12a0>
ffffffffc0203b2a:	00001617          	auipc	a2,0x1
ffffffffc0203b2e:	27660613          	addi	a2,a2,630 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203b32:	09a00593          	li	a1,154
ffffffffc0203b36:	00002517          	auipc	a0,0x2
ffffffffc0203b3a:	19250513          	addi	a0,a0,402 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc0203b3e:	dc4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0203b42:	00002697          	auipc	a3,0x2
ffffffffc0203b46:	c7668693          	addi	a3,a3,-906 # ffffffffc02057b8 <commands+0x12a0>
ffffffffc0203b4a:	00001617          	auipc	a2,0x1
ffffffffc0203b4e:	25660613          	addi	a2,a2,598 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203b52:	09800593          	li	a1,152
ffffffffc0203b56:	00002517          	auipc	a0,0x2
ffffffffc0203b5a:	17250513          	addi	a0,a0,370 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc0203b5e:	da4fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203b62 <_clock_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203b62:	751c                	ld	a5,40(a0)
{
ffffffffc0203b64:	1101                	addi	sp,sp,-32
ffffffffc0203b66:	ec06                	sd	ra,24(sp)
ffffffffc0203b68:	e822                	sd	s0,16(sp)
ffffffffc0203b6a:	e426                	sd	s1,8(sp)
ffffffffc0203b6c:	e04a                	sd	s2,0(sp)
         assert(head != NULL);
ffffffffc0203b6e:	c7cd                	beqz	a5,ffffffffc0203c18 <_clock_swap_out_victim+0xb6>
     assert(in_tick==0);
ffffffffc0203b70:	e641                	bnez	a2,ffffffffc0203bf8 <_clock_swap_out_victim+0x96>
         if (head == list_prev(head))
ffffffffc0203b72:	6398                	ld	a4,0(a5)
ffffffffc0203b74:	84ae                	mv	s1,a1
ffffffffc0203b76:	06f70863          	beq	a4,a5,ffffffffc0203be6 <_clock_swap_out_victim+0x84>
ffffffffc0203b7a:	0000e917          	auipc	s2,0xe
ffffffffc0203b7e:	9ee90913          	addi	s2,s2,-1554 # ffffffffc0211568 <curr_ptr>
ffffffffc0203b82:	00093403          	ld	s0,0(s2)
    return listelm->next;
ffffffffc0203b86:	0000d697          	auipc	a3,0xd
ffffffffc0203b8a:	56268693          	addi	a3,a3,1378 # ffffffffc02110e8 <pra_list_head>
ffffffffc0203b8e:	6690                	ld	a2,8(a3)
ffffffffc0203b90:	4701                	li	a4,0
        if (curr_ptr == &pra_list_head)
ffffffffc0203b92:	00d40b63          	beq	s0,a3,ffffffffc0203ba8 <_clock_swap_out_victim+0x46>
        if (page->visited == 0)
ffffffffc0203b96:	fe043783          	ld	a5,-32(s0)
ffffffffc0203b9a:	cf81                	beqz	a5,ffffffffc0203bb2 <_clock_swap_out_victim+0x50>
            page->visited = 0;
ffffffffc0203b9c:	fe043023          	sd	zero,-32(s0)
ffffffffc0203ba0:	6400                	ld	s0,8(s0)
ffffffffc0203ba2:	4705                	li	a4,1
        if (curr_ptr == &pra_list_head)
ffffffffc0203ba4:	fed419e3          	bne	s0,a3,ffffffffc0203b96 <_clock_swap_out_victim+0x34>
            curr_ptr = list_next(curr_ptr);
ffffffffc0203ba8:	8432                	mv	s0,a2
        if (page->visited == 0)
ffffffffc0203baa:	fe043783          	ld	a5,-32(s0)
ffffffffc0203bae:	4705                	li	a4,1
ffffffffc0203bb0:	f7f5                	bnez	a5,ffffffffc0203b9c <_clock_swap_out_victim+0x3a>
ffffffffc0203bb2:	c319                	beqz	a4,ffffffffc0203bb8 <_clock_swap_out_victim+0x56>
ffffffffc0203bb4:	00893023          	sd	s0,0(s2)
            cprintf("curr_ptr %p\n", curr_ptr);
ffffffffc0203bb8:	85a2                	mv	a1,s0
ffffffffc0203bba:	00002517          	auipc	a0,0x2
ffffffffc0203bbe:	18e50513          	addi	a0,a0,398 # ffffffffc0205d48 <default_pmm_manager+0xb8>
ffffffffc0203bc2:	cf8fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
            list_del(curr_ptr);
ffffffffc0203bc6:	00093783          	ld	a5,0(s2)
        struct Page *page = le2page(curr_ptr, pra_page_link);
ffffffffc0203bca:	fd040413          	addi	s0,s0,-48
}
ffffffffc0203bce:	60e2                	ld	ra,24(sp)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203bd0:	6398                	ld	a4,0(a5)
ffffffffc0203bd2:	679c                	ld	a5,8(a5)
ffffffffc0203bd4:	6902                	ld	s2,0(sp)
ffffffffc0203bd6:	4501                	li	a0,0
    prev->next = next;
ffffffffc0203bd8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203bda:	e398                	sd	a4,0(a5)
            *ptr_page = page;
ffffffffc0203bdc:	e080                	sd	s0,0(s1)
}
ffffffffc0203bde:	6442                	ld	s0,16(sp)
ffffffffc0203be0:	64a2                	ld	s1,8(sp)
ffffffffc0203be2:	6105                	addi	sp,sp,32
ffffffffc0203be4:	8082                	ret
ffffffffc0203be6:	60e2                	ld	ra,24(sp)
ffffffffc0203be8:	6442                	ld	s0,16(sp)
            *ptr_page = NULL;
ffffffffc0203bea:	0005b023          	sd	zero,0(a1)
}
ffffffffc0203bee:	64a2                	ld	s1,8(sp)
ffffffffc0203bf0:	6902                	ld	s2,0(sp)
ffffffffc0203bf2:	4501                	li	a0,0
ffffffffc0203bf4:	6105                	addi	sp,sp,32
ffffffffc0203bf6:	8082                	ret
     assert(in_tick==0);
ffffffffc0203bf8:	00002697          	auipc	a3,0x2
ffffffffc0203bfc:	14068693          	addi	a3,a3,320 # ffffffffc0205d38 <default_pmm_manager+0xa8>
ffffffffc0203c00:	00001617          	auipc	a2,0x1
ffffffffc0203c04:	1a060613          	addi	a2,a2,416 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203c08:	04900593          	li	a1,73
ffffffffc0203c0c:	00002517          	auipc	a0,0x2
ffffffffc0203c10:	0bc50513          	addi	a0,a0,188 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc0203c14:	ceefc0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(head != NULL);
ffffffffc0203c18:	00002697          	auipc	a3,0x2
ffffffffc0203c1c:	11068693          	addi	a3,a3,272 # ffffffffc0205d28 <default_pmm_manager+0x98>
ffffffffc0203c20:	00001617          	auipc	a2,0x1
ffffffffc0203c24:	18060613          	addi	a2,a2,384 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203c28:	04800593          	li	a1,72
ffffffffc0203c2c:	00002517          	auipc	a0,0x2
ffffffffc0203c30:	09c50513          	addi	a0,a0,156 # ffffffffc0205cc8 <default_pmm_manager+0x38>
ffffffffc0203c34:	ccefc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203c38 <_clock_map_swappable>:
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203c38:	0000e797          	auipc	a5,0xe
ffffffffc0203c3c:	9307b783          	ld	a5,-1744(a5) # ffffffffc0211568 <curr_ptr>
ffffffffc0203c40:	c385                	beqz	a5,ffffffffc0203c60 <_clock_map_swappable+0x28>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203c42:	0000d797          	auipc	a5,0xd
ffffffffc0203c46:	4a678793          	addi	a5,a5,1190 # ffffffffc02110e8 <pra_list_head>
ffffffffc0203c4a:	6394                	ld	a3,0(a5)
ffffffffc0203c4c:	03060713          	addi	a4,a2,48
    prev->next = next->prev = elm;
ffffffffc0203c50:	e398                	sd	a4,0(a5)
ffffffffc0203c52:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203c54:	fe1c                	sd	a5,56(a2)
    page->visited = 1;
ffffffffc0203c56:	4785                	li	a5,1
    elm->prev = prev;
ffffffffc0203c58:	fa14                	sd	a3,48(a2)
ffffffffc0203c5a:	ea1c                	sd	a5,16(a2)
}
ffffffffc0203c5c:	4501                	li	a0,0
ffffffffc0203c5e:	8082                	ret
{
ffffffffc0203c60:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203c62:	00002697          	auipc	a3,0x2
ffffffffc0203c66:	0f668693          	addi	a3,a3,246 # ffffffffc0205d58 <default_pmm_manager+0xc8>
ffffffffc0203c6a:	00001617          	auipc	a2,0x1
ffffffffc0203c6e:	13660613          	addi	a2,a2,310 # ffffffffc0204da0 <commands+0x888>
ffffffffc0203c72:	03600593          	li	a1,54
ffffffffc0203c76:	00002517          	auipc	a0,0x2
ffffffffc0203c7a:	05250513          	addi	a0,a0,82 # ffffffffc0205cc8 <default_pmm_manager+0x38>
{
ffffffffc0203c7e:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203c80:	c82fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203c84 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203c84:	1141                	addi	sp,sp,-16
    // 确保每一页可以被完整地映射为若干个扇区（PAGE_NSECT 个扇区），避免读写时出现对齐问题
    static_assert((PGSIZE % SECTSIZE) == 0);
    // 检查交换设备（SWAP_DEV_NO）是否有效
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c86:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203c88:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c8a:	f48fc0ef          	jal	ra,ffffffffc02003d2 <ide_device_valid>
ffffffffc0203c8e:	cd01                	beqz	a0,ffffffffc0203ca6 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    // 确定交换区可以支持的最大页数量
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c90:	4505                	li	a0,1
ffffffffc0203c92:	f46fc0ef          	jal	ra,ffffffffc02003d8 <ide_device_size>
}
ffffffffc0203c96:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c98:	810d                	srli	a0,a0,0x3
ffffffffc0203c9a:	0000e797          	auipc	a5,0xe
ffffffffc0203c9e:	8aa7bb23          	sd	a0,-1866(a5) # ffffffffc0211550 <max_swap_offset>
}
ffffffffc0203ca2:	0141                	addi	sp,sp,16
ffffffffc0203ca4:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203ca6:	00002617          	auipc	a2,0x2
ffffffffc0203caa:	0f260613          	addi	a2,a2,242 # ffffffffc0205d98 <default_pmm_manager+0x108>
ffffffffc0203cae:	45bd                	li	a1,15
ffffffffc0203cb0:	00002517          	auipc	a0,0x2
ffffffffc0203cb4:	10850513          	addi	a0,a0,264 # ffffffffc0205db8 <default_pmm_manager+0x128>
ffffffffc0203cb8:	c4afc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203cbc <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203cbc:	1141                	addi	sp,sp,-16
ffffffffc0203cbe:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cc0:	00855793          	srli	a5,a0,0x8
ffffffffc0203cc4:	c3a5                	beqz	a5,ffffffffc0203d24 <swapfs_write+0x68>
ffffffffc0203cc6:	0000e717          	auipc	a4,0xe
ffffffffc0203cca:	88a73703          	ld	a4,-1910(a4) # ffffffffc0211550 <max_swap_offset>
ffffffffc0203cce:	04e7fb63          	bgeu	a5,a4,ffffffffc0203d24 <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cd2:	0000e617          	auipc	a2,0xe
ffffffffc0203cd6:	85663603          	ld	a2,-1962(a2) # ffffffffc0211528 <pages>
ffffffffc0203cda:	8d91                	sub	a1,a1,a2
ffffffffc0203cdc:	4035d613          	srai	a2,a1,0x3
ffffffffc0203ce0:	00002597          	auipc	a1,0x2
ffffffffc0203ce4:	3585b583          	ld	a1,856(a1) # ffffffffc0206038 <error_string+0x38>
ffffffffc0203ce8:	02b60633          	mul	a2,a2,a1
ffffffffc0203cec:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203cf0:	00002797          	auipc	a5,0x2
ffffffffc0203cf4:	3507b783          	ld	a5,848(a5) # ffffffffc0206040 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cf8:	0000e717          	auipc	a4,0xe
ffffffffc0203cfc:	82873703          	ld	a4,-2008(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d00:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d02:	00c61793          	slli	a5,a2,0xc
ffffffffc0203d06:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d08:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d0a:	02e7f963          	bgeu	a5,a4,ffffffffc0203d3c <swapfs_write+0x80>
}
ffffffffc0203d0e:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d10:	0000e797          	auipc	a5,0xe
ffffffffc0203d14:	8287b783          	ld	a5,-2008(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0203d18:	46a1                	li	a3,8
ffffffffc0203d1a:	963e                	add	a2,a2,a5
ffffffffc0203d1c:	4505                	li	a0,1
}
ffffffffc0203d1e:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d20:	ebefc06f          	j	ffffffffc02003de <ide_write_secs>
ffffffffc0203d24:	86aa                	mv	a3,a0
ffffffffc0203d26:	00002617          	auipc	a2,0x2
ffffffffc0203d2a:	0aa60613          	addi	a2,a2,170 # ffffffffc0205dd0 <default_pmm_manager+0x140>
ffffffffc0203d2e:	45f1                	li	a1,28
ffffffffc0203d30:	00002517          	auipc	a0,0x2
ffffffffc0203d34:	08850513          	addi	a0,a0,136 # ffffffffc0205db8 <default_pmm_manager+0x128>
ffffffffc0203d38:	bcafc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203d3c:	86b2                	mv	a3,a2
ffffffffc0203d3e:	06a00593          	li	a1,106
ffffffffc0203d42:	00001617          	auipc	a2,0x1
ffffffffc0203d46:	f3660613          	addi	a2,a2,-202 # ffffffffc0204c78 <commands+0x760>
ffffffffc0203d4a:	00001517          	auipc	a0,0x1
ffffffffc0203d4e:	ef650513          	addi	a0,a0,-266 # ffffffffc0204c40 <commands+0x728>
ffffffffc0203d52:	bb0fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203d56 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203d56:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0203d5a:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0203d5c:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0203d5e:	cb81                	beqz	a5,ffffffffc0203d6e <strlen+0x18>
        cnt ++;
ffffffffc0203d60:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0203d62:	00a707b3          	add	a5,a4,a0
ffffffffc0203d66:	0007c783          	lbu	a5,0(a5)
ffffffffc0203d6a:	fbfd                	bnez	a5,ffffffffc0203d60 <strlen+0xa>
ffffffffc0203d6c:	8082                	ret
    }
    return cnt;
}
ffffffffc0203d6e:	8082                	ret

ffffffffc0203d70 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203d70:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203d72:	e589                	bnez	a1,ffffffffc0203d7c <strnlen+0xc>
ffffffffc0203d74:	a811                	j	ffffffffc0203d88 <strnlen+0x18>
        cnt ++;
ffffffffc0203d76:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203d78:	00f58863          	beq	a1,a5,ffffffffc0203d88 <strnlen+0x18>
ffffffffc0203d7c:	00f50733          	add	a4,a0,a5
ffffffffc0203d80:	00074703          	lbu	a4,0(a4)
ffffffffc0203d84:	fb6d                	bnez	a4,ffffffffc0203d76 <strnlen+0x6>
ffffffffc0203d86:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203d88:	852e                	mv	a0,a1
ffffffffc0203d8a:	8082                	ret

ffffffffc0203d8c <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203d8c:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203d8e:	0005c703          	lbu	a4,0(a1)
ffffffffc0203d92:	0785                	addi	a5,a5,1
ffffffffc0203d94:	0585                	addi	a1,a1,1
ffffffffc0203d96:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203d9a:	fb75                	bnez	a4,ffffffffc0203d8e <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203d9c:	8082                	ret

ffffffffc0203d9e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203d9e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203da2:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203da6:	cb89                	beqz	a5,ffffffffc0203db8 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0203da8:	0505                	addi	a0,a0,1
ffffffffc0203daa:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203dac:	fee789e3          	beq	a5,a4,ffffffffc0203d9e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203db0:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203db4:	9d19                	subw	a0,a0,a4
ffffffffc0203db6:	8082                	ret
ffffffffc0203db8:	4501                	li	a0,0
ffffffffc0203dba:	bfed                	j	ffffffffc0203db4 <strcmp+0x16>

ffffffffc0203dbc <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203dbc:	00054783          	lbu	a5,0(a0)
ffffffffc0203dc0:	c799                	beqz	a5,ffffffffc0203dce <strchr+0x12>
        if (*s == c) {
ffffffffc0203dc2:	00f58763          	beq	a1,a5,ffffffffc0203dd0 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0203dc6:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0203dca:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203dcc:	fbfd                	bnez	a5,ffffffffc0203dc2 <strchr+0x6>
    }
    return NULL;
ffffffffc0203dce:	4501                	li	a0,0
}
ffffffffc0203dd0:	8082                	ret

ffffffffc0203dd2 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203dd2:	ca01                	beqz	a2,ffffffffc0203de2 <memset+0x10>
ffffffffc0203dd4:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203dd6:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203dd8:	0785                	addi	a5,a5,1
ffffffffc0203dda:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203dde:	fec79de3          	bne	a5,a2,ffffffffc0203dd8 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203de2:	8082                	ret

ffffffffc0203de4 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203de4:	ca19                	beqz	a2,ffffffffc0203dfa <memcpy+0x16>
ffffffffc0203de6:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203de8:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203dea:	0005c703          	lbu	a4,0(a1)
ffffffffc0203dee:	0585                	addi	a1,a1,1
ffffffffc0203df0:	0785                	addi	a5,a5,1
ffffffffc0203df2:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203df6:	fec59ae3          	bne	a1,a2,ffffffffc0203dea <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203dfa:	8082                	ret

ffffffffc0203dfc <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203dfc:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e00:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203e02:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e06:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203e08:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e0c:	f022                	sd	s0,32(sp)
ffffffffc0203e0e:	ec26                	sd	s1,24(sp)
ffffffffc0203e10:	e84a                	sd	s2,16(sp)
ffffffffc0203e12:	f406                	sd	ra,40(sp)
ffffffffc0203e14:	e44e                	sd	s3,8(sp)
ffffffffc0203e16:	84aa                	mv	s1,a0
ffffffffc0203e18:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203e1a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203e1e:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203e20:	03067e63          	bgeu	a2,a6,ffffffffc0203e5c <printnum+0x60>
ffffffffc0203e24:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203e26:	00805763          	blez	s0,ffffffffc0203e34 <printnum+0x38>
ffffffffc0203e2a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203e2c:	85ca                	mv	a1,s2
ffffffffc0203e2e:	854e                	mv	a0,s3
ffffffffc0203e30:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203e32:	fc65                	bnez	s0,ffffffffc0203e2a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e34:	1a02                	slli	s4,s4,0x20
ffffffffc0203e36:	00002797          	auipc	a5,0x2
ffffffffc0203e3a:	fba78793          	addi	a5,a5,-70 # ffffffffc0205df0 <default_pmm_manager+0x160>
ffffffffc0203e3e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203e42:	9a3e                	add	s4,s4,a5
}
ffffffffc0203e44:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e46:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203e4a:	70a2                	ld	ra,40(sp)
ffffffffc0203e4c:	69a2                	ld	s3,8(sp)
ffffffffc0203e4e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e50:	85ca                	mv	a1,s2
ffffffffc0203e52:	87a6                	mv	a5,s1
}
ffffffffc0203e54:	6942                	ld	s2,16(sp)
ffffffffc0203e56:	64e2                	ld	s1,24(sp)
ffffffffc0203e58:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e5a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203e5c:	03065633          	divu	a2,a2,a6
ffffffffc0203e60:	8722                	mv	a4,s0
ffffffffc0203e62:	f9bff0ef          	jal	ra,ffffffffc0203dfc <printnum>
ffffffffc0203e66:	b7f9                	j	ffffffffc0203e34 <printnum+0x38>

ffffffffc0203e68 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203e68:	7119                	addi	sp,sp,-128
ffffffffc0203e6a:	f4a6                	sd	s1,104(sp)
ffffffffc0203e6c:	f0ca                	sd	s2,96(sp)
ffffffffc0203e6e:	ecce                	sd	s3,88(sp)
ffffffffc0203e70:	e8d2                	sd	s4,80(sp)
ffffffffc0203e72:	e4d6                	sd	s5,72(sp)
ffffffffc0203e74:	e0da                	sd	s6,64(sp)
ffffffffc0203e76:	fc5e                	sd	s7,56(sp)
ffffffffc0203e78:	f06a                	sd	s10,32(sp)
ffffffffc0203e7a:	fc86                	sd	ra,120(sp)
ffffffffc0203e7c:	f8a2                	sd	s0,112(sp)
ffffffffc0203e7e:	f862                	sd	s8,48(sp)
ffffffffc0203e80:	f466                	sd	s9,40(sp)
ffffffffc0203e82:	ec6e                	sd	s11,24(sp)
ffffffffc0203e84:	892a                	mv	s2,a0
ffffffffc0203e86:	84ae                	mv	s1,a1
ffffffffc0203e88:	8d32                	mv	s10,a2
ffffffffc0203e8a:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e8c:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203e90:	5b7d                	li	s6,-1
ffffffffc0203e92:	00002a97          	auipc	s5,0x2
ffffffffc0203e96:	f92a8a93          	addi	s5,s5,-110 # ffffffffc0205e24 <default_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203e9a:	00002b97          	auipc	s7,0x2
ffffffffc0203e9e:	166b8b93          	addi	s7,s7,358 # ffffffffc0206000 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ea2:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0203ea6:	001d0413          	addi	s0,s10,1
ffffffffc0203eaa:	01350a63          	beq	a0,s3,ffffffffc0203ebe <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0203eae:	c121                	beqz	a0,ffffffffc0203eee <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0203eb0:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203eb2:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203eb4:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203eb6:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203eba:	ff351ae3          	bne	a0,s3,ffffffffc0203eae <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ebe:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203ec2:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203ec6:	4c81                	li	s9,0
ffffffffc0203ec8:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0203eca:	5c7d                	li	s8,-1
ffffffffc0203ecc:	5dfd                	li	s11,-1
ffffffffc0203ece:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0203ed2:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ed4:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203ed8:	0ff5f593          	zext.b	a1,a1
ffffffffc0203edc:	00140d13          	addi	s10,s0,1
ffffffffc0203ee0:	04b56263          	bltu	a0,a1,ffffffffc0203f24 <vprintfmt+0xbc>
ffffffffc0203ee4:	058a                	slli	a1,a1,0x2
ffffffffc0203ee6:	95d6                	add	a1,a1,s5
ffffffffc0203ee8:	4194                	lw	a3,0(a1)
ffffffffc0203eea:	96d6                	add	a3,a3,s5
ffffffffc0203eec:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203eee:	70e6                	ld	ra,120(sp)
ffffffffc0203ef0:	7446                	ld	s0,112(sp)
ffffffffc0203ef2:	74a6                	ld	s1,104(sp)
ffffffffc0203ef4:	7906                	ld	s2,96(sp)
ffffffffc0203ef6:	69e6                	ld	s3,88(sp)
ffffffffc0203ef8:	6a46                	ld	s4,80(sp)
ffffffffc0203efa:	6aa6                	ld	s5,72(sp)
ffffffffc0203efc:	6b06                	ld	s6,64(sp)
ffffffffc0203efe:	7be2                	ld	s7,56(sp)
ffffffffc0203f00:	7c42                	ld	s8,48(sp)
ffffffffc0203f02:	7ca2                	ld	s9,40(sp)
ffffffffc0203f04:	7d02                	ld	s10,32(sp)
ffffffffc0203f06:	6de2                	ld	s11,24(sp)
ffffffffc0203f08:	6109                	addi	sp,sp,128
ffffffffc0203f0a:	8082                	ret
            padc = '0';
ffffffffc0203f0c:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0203f0e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f12:	846a                	mv	s0,s10
ffffffffc0203f14:	00140d13          	addi	s10,s0,1
ffffffffc0203f18:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203f1c:	0ff5f593          	zext.b	a1,a1
ffffffffc0203f20:	fcb572e3          	bgeu	a0,a1,ffffffffc0203ee4 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0203f24:	85a6                	mv	a1,s1
ffffffffc0203f26:	02500513          	li	a0,37
ffffffffc0203f2a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203f2c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203f30:	8d22                	mv	s10,s0
ffffffffc0203f32:	f73788e3          	beq	a5,s3,ffffffffc0203ea2 <vprintfmt+0x3a>
ffffffffc0203f36:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0203f3a:	1d7d                	addi	s10,s10,-1
ffffffffc0203f3c:	ff379de3          	bne	a5,s3,ffffffffc0203f36 <vprintfmt+0xce>
ffffffffc0203f40:	b78d                	j	ffffffffc0203ea2 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0203f42:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0203f46:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f4a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203f4c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203f50:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203f54:	02d86463          	bltu	a6,a3,ffffffffc0203f7c <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0203f58:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203f5c:	002c169b          	slliw	a3,s8,0x2
ffffffffc0203f60:	0186873b          	addw	a4,a3,s8
ffffffffc0203f64:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203f68:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0203f6a:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0203f6e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203f70:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0203f74:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203f78:	fed870e3          	bgeu	a6,a3,ffffffffc0203f58 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0203f7c:	f40ddce3          	bgez	s11,ffffffffc0203ed4 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0203f80:	8de2                	mv	s11,s8
ffffffffc0203f82:	5c7d                	li	s8,-1
ffffffffc0203f84:	bf81                	j	ffffffffc0203ed4 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0203f86:	fffdc693          	not	a3,s11
ffffffffc0203f8a:	96fd                	srai	a3,a3,0x3f
ffffffffc0203f8c:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f90:	00144603          	lbu	a2,1(s0)
ffffffffc0203f94:	2d81                	sext.w	s11,s11
ffffffffc0203f96:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203f98:	bf35                	j	ffffffffc0203ed4 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0203f9a:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f9e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0203fa2:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203fa4:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0203fa6:	bfd9                	j	ffffffffc0203f7c <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0203fa8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203faa:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203fae:	01174463          	blt	a4,a7,ffffffffc0203fb6 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0203fb2:	1a088e63          	beqz	a7,ffffffffc020416e <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0203fb6:	000a3603          	ld	a2,0(s4)
ffffffffc0203fba:	46c1                	li	a3,16
ffffffffc0203fbc:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203fbe:	2781                	sext.w	a5,a5
ffffffffc0203fc0:	876e                	mv	a4,s11
ffffffffc0203fc2:	85a6                	mv	a1,s1
ffffffffc0203fc4:	854a                	mv	a0,s2
ffffffffc0203fc6:	e37ff0ef          	jal	ra,ffffffffc0203dfc <printnum>
            break;
ffffffffc0203fca:	bde1                	j	ffffffffc0203ea2 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0203fcc:	000a2503          	lw	a0,0(s4)
ffffffffc0203fd0:	85a6                	mv	a1,s1
ffffffffc0203fd2:	0a21                	addi	s4,s4,8
ffffffffc0203fd4:	9902                	jalr	s2
            break;
ffffffffc0203fd6:	b5f1                	j	ffffffffc0203ea2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203fd8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203fda:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203fde:	01174463          	blt	a4,a7,ffffffffc0203fe6 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0203fe2:	18088163          	beqz	a7,ffffffffc0204164 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0203fe6:	000a3603          	ld	a2,0(s4)
ffffffffc0203fea:	46a9                	li	a3,10
ffffffffc0203fec:	8a2e                	mv	s4,a1
ffffffffc0203fee:	bfc1                	j	ffffffffc0203fbe <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ff0:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203ff4:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ff6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203ff8:	bdf1                	j	ffffffffc0203ed4 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0203ffa:	85a6                	mv	a1,s1
ffffffffc0203ffc:	02500513          	li	a0,37
ffffffffc0204000:	9902                	jalr	s2
            break;
ffffffffc0204002:	b545                	j	ffffffffc0203ea2 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204004:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204008:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020400a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020400c:	b5e1                	j	ffffffffc0203ed4 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020400e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204010:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204014:	01174463          	blt	a4,a7,ffffffffc020401c <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0204018:	14088163          	beqz	a7,ffffffffc020415a <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020401c:	000a3603          	ld	a2,0(s4)
ffffffffc0204020:	46a1                	li	a3,8
ffffffffc0204022:	8a2e                	mv	s4,a1
ffffffffc0204024:	bf69                	j	ffffffffc0203fbe <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204026:	03000513          	li	a0,48
ffffffffc020402a:	85a6                	mv	a1,s1
ffffffffc020402c:	e03e                	sd	a5,0(sp)
ffffffffc020402e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204030:	85a6                	mv	a1,s1
ffffffffc0204032:	07800513          	li	a0,120
ffffffffc0204036:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204038:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020403a:	6782                	ld	a5,0(sp)
ffffffffc020403c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020403e:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204042:	bfb5                	j	ffffffffc0203fbe <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204044:	000a3403          	ld	s0,0(s4)
ffffffffc0204048:	008a0713          	addi	a4,s4,8
ffffffffc020404c:	e03a                	sd	a4,0(sp)
ffffffffc020404e:	14040263          	beqz	s0,ffffffffc0204192 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204052:	0fb05763          	blez	s11,ffffffffc0204140 <vprintfmt+0x2d8>
ffffffffc0204056:	02d00693          	li	a3,45
ffffffffc020405a:	0cd79163          	bne	a5,a3,ffffffffc020411c <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020405e:	00044783          	lbu	a5,0(s0)
ffffffffc0204062:	0007851b          	sext.w	a0,a5
ffffffffc0204066:	cf85                	beqz	a5,ffffffffc020409e <vprintfmt+0x236>
ffffffffc0204068:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020406c:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204070:	000c4563          	bltz	s8,ffffffffc020407a <vprintfmt+0x212>
ffffffffc0204074:	3c7d                	addiw	s8,s8,-1
ffffffffc0204076:	036c0263          	beq	s8,s6,ffffffffc020409a <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020407a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020407c:	0e0c8e63          	beqz	s9,ffffffffc0204178 <vprintfmt+0x310>
ffffffffc0204080:	3781                	addiw	a5,a5,-32
ffffffffc0204082:	0ef47b63          	bgeu	s0,a5,ffffffffc0204178 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204086:	03f00513          	li	a0,63
ffffffffc020408a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020408c:	000a4783          	lbu	a5,0(s4)
ffffffffc0204090:	3dfd                	addiw	s11,s11,-1
ffffffffc0204092:	0a05                	addi	s4,s4,1
ffffffffc0204094:	0007851b          	sext.w	a0,a5
ffffffffc0204098:	ffe1                	bnez	a5,ffffffffc0204070 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020409a:	01b05963          	blez	s11,ffffffffc02040ac <vprintfmt+0x244>
ffffffffc020409e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02040a0:	85a6                	mv	a1,s1
ffffffffc02040a2:	02000513          	li	a0,32
ffffffffc02040a6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02040a8:	fe0d9be3          	bnez	s11,ffffffffc020409e <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02040ac:	6a02                	ld	s4,0(sp)
ffffffffc02040ae:	bbd5                	j	ffffffffc0203ea2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02040b0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02040b2:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02040b6:	01174463          	blt	a4,a7,ffffffffc02040be <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02040ba:	08088d63          	beqz	a7,ffffffffc0204154 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02040be:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02040c2:	0a044d63          	bltz	s0,ffffffffc020417c <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02040c6:	8622                	mv	a2,s0
ffffffffc02040c8:	8a66                	mv	s4,s9
ffffffffc02040ca:	46a9                	li	a3,10
ffffffffc02040cc:	bdcd                	j	ffffffffc0203fbe <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02040ce:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02040d2:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02040d4:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02040d6:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02040da:	8fb5                	xor	a5,a5,a3
ffffffffc02040dc:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02040e0:	02d74163          	blt	a4,a3,ffffffffc0204102 <vprintfmt+0x29a>
ffffffffc02040e4:	00369793          	slli	a5,a3,0x3
ffffffffc02040e8:	97de                	add	a5,a5,s7
ffffffffc02040ea:	639c                	ld	a5,0(a5)
ffffffffc02040ec:	cb99                	beqz	a5,ffffffffc0204102 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02040ee:	86be                	mv	a3,a5
ffffffffc02040f0:	00002617          	auipc	a2,0x2
ffffffffc02040f4:	d3060613          	addi	a2,a2,-720 # ffffffffc0205e20 <default_pmm_manager+0x190>
ffffffffc02040f8:	85a6                	mv	a1,s1
ffffffffc02040fa:	854a                	mv	a0,s2
ffffffffc02040fc:	0ce000ef          	jal	ra,ffffffffc02041ca <printfmt>
ffffffffc0204100:	b34d                	j	ffffffffc0203ea2 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204102:	00002617          	auipc	a2,0x2
ffffffffc0204106:	d0e60613          	addi	a2,a2,-754 # ffffffffc0205e10 <default_pmm_manager+0x180>
ffffffffc020410a:	85a6                	mv	a1,s1
ffffffffc020410c:	854a                	mv	a0,s2
ffffffffc020410e:	0bc000ef          	jal	ra,ffffffffc02041ca <printfmt>
ffffffffc0204112:	bb41                	j	ffffffffc0203ea2 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204114:	00002417          	auipc	s0,0x2
ffffffffc0204118:	cf440413          	addi	s0,s0,-780 # ffffffffc0205e08 <default_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020411c:	85e2                	mv	a1,s8
ffffffffc020411e:	8522                	mv	a0,s0
ffffffffc0204120:	e43e                	sd	a5,8(sp)
ffffffffc0204122:	c4fff0ef          	jal	ra,ffffffffc0203d70 <strnlen>
ffffffffc0204126:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020412a:	01b05b63          	blez	s11,ffffffffc0204140 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020412e:	67a2                	ld	a5,8(sp)
ffffffffc0204130:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204134:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204136:	85a6                	mv	a1,s1
ffffffffc0204138:	8552                	mv	a0,s4
ffffffffc020413a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020413c:	fe0d9ce3          	bnez	s11,ffffffffc0204134 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204140:	00044783          	lbu	a5,0(s0)
ffffffffc0204144:	00140a13          	addi	s4,s0,1
ffffffffc0204148:	0007851b          	sext.w	a0,a5
ffffffffc020414c:	d3a5                	beqz	a5,ffffffffc02040ac <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020414e:	05e00413          	li	s0,94
ffffffffc0204152:	bf39                	j	ffffffffc0204070 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204154:	000a2403          	lw	s0,0(s4)
ffffffffc0204158:	b7ad                	j	ffffffffc02040c2 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020415a:	000a6603          	lwu	a2,0(s4)
ffffffffc020415e:	46a1                	li	a3,8
ffffffffc0204160:	8a2e                	mv	s4,a1
ffffffffc0204162:	bdb1                	j	ffffffffc0203fbe <vprintfmt+0x156>
ffffffffc0204164:	000a6603          	lwu	a2,0(s4)
ffffffffc0204168:	46a9                	li	a3,10
ffffffffc020416a:	8a2e                	mv	s4,a1
ffffffffc020416c:	bd89                	j	ffffffffc0203fbe <vprintfmt+0x156>
ffffffffc020416e:	000a6603          	lwu	a2,0(s4)
ffffffffc0204172:	46c1                	li	a3,16
ffffffffc0204174:	8a2e                	mv	s4,a1
ffffffffc0204176:	b5a1                	j	ffffffffc0203fbe <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204178:	9902                	jalr	s2
ffffffffc020417a:	bf09                	j	ffffffffc020408c <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020417c:	85a6                	mv	a1,s1
ffffffffc020417e:	02d00513          	li	a0,45
ffffffffc0204182:	e03e                	sd	a5,0(sp)
ffffffffc0204184:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204186:	6782                	ld	a5,0(sp)
ffffffffc0204188:	8a66                	mv	s4,s9
ffffffffc020418a:	40800633          	neg	a2,s0
ffffffffc020418e:	46a9                	li	a3,10
ffffffffc0204190:	b53d                	j	ffffffffc0203fbe <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204192:	03b05163          	blez	s11,ffffffffc02041b4 <vprintfmt+0x34c>
ffffffffc0204196:	02d00693          	li	a3,45
ffffffffc020419a:	f6d79de3          	bne	a5,a3,ffffffffc0204114 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020419e:	00002417          	auipc	s0,0x2
ffffffffc02041a2:	c6a40413          	addi	s0,s0,-918 # ffffffffc0205e08 <default_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041a6:	02800793          	li	a5,40
ffffffffc02041aa:	02800513          	li	a0,40
ffffffffc02041ae:	00140a13          	addi	s4,s0,1
ffffffffc02041b2:	bd6d                	j	ffffffffc020406c <vprintfmt+0x204>
ffffffffc02041b4:	00002a17          	auipc	s4,0x2
ffffffffc02041b8:	c55a0a13          	addi	s4,s4,-939 # ffffffffc0205e09 <default_pmm_manager+0x179>
ffffffffc02041bc:	02800513          	li	a0,40
ffffffffc02041c0:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02041c4:	05e00413          	li	s0,94
ffffffffc02041c8:	b565                	j	ffffffffc0204070 <vprintfmt+0x208>

ffffffffc02041ca <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041ca:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02041cc:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041d0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041d2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041d4:	ec06                	sd	ra,24(sp)
ffffffffc02041d6:	f83a                	sd	a4,48(sp)
ffffffffc02041d8:	fc3e                	sd	a5,56(sp)
ffffffffc02041da:	e0c2                	sd	a6,64(sp)
ffffffffc02041dc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02041de:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041e0:	c89ff0ef          	jal	ra,ffffffffc0203e68 <vprintfmt>
}
ffffffffc02041e4:	60e2                	ld	ra,24(sp)
ffffffffc02041e6:	6161                	addi	sp,sp,80
ffffffffc02041e8:	8082                	ret

ffffffffc02041ea <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02041ea:	715d                	addi	sp,sp,-80
ffffffffc02041ec:	e486                	sd	ra,72(sp)
ffffffffc02041ee:	e0a6                	sd	s1,64(sp)
ffffffffc02041f0:	fc4a                	sd	s2,56(sp)
ffffffffc02041f2:	f84e                	sd	s3,48(sp)
ffffffffc02041f4:	f452                	sd	s4,40(sp)
ffffffffc02041f6:	f056                	sd	s5,32(sp)
ffffffffc02041f8:	ec5a                	sd	s6,24(sp)
ffffffffc02041fa:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02041fc:	c901                	beqz	a0,ffffffffc020420c <readline+0x22>
ffffffffc02041fe:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0204200:	00002517          	auipc	a0,0x2
ffffffffc0204204:	c2050513          	addi	a0,a0,-992 # ffffffffc0205e20 <default_pmm_manager+0x190>
ffffffffc0204208:	eb3fb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc020420c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020420e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0204210:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204212:	4aa9                	li	s5,10
ffffffffc0204214:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204216:	0000db97          	auipc	s7,0xd
ffffffffc020421a:	ee2b8b93          	addi	s7,s7,-286 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020421e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204222:	ed1fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204226:	00054a63          	bltz	a0,ffffffffc020423a <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020422a:	00a95a63          	bge	s2,a0,ffffffffc020423e <readline+0x54>
ffffffffc020422e:	029a5263          	bge	s4,s1,ffffffffc0204252 <readline+0x68>
        c = getchar();
ffffffffc0204232:	ec1fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204236:	fe055ae3          	bgez	a0,ffffffffc020422a <readline+0x40>
            return NULL;
ffffffffc020423a:	4501                	li	a0,0
ffffffffc020423c:	a091                	j	ffffffffc0204280 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020423e:	03351463          	bne	a0,s3,ffffffffc0204266 <readline+0x7c>
ffffffffc0204242:	e8a9                	bnez	s1,ffffffffc0204294 <readline+0xaa>
        c = getchar();
ffffffffc0204244:	eaffb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204248:	fe0549e3          	bltz	a0,ffffffffc020423a <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020424c:	fea959e3          	bge	s2,a0,ffffffffc020423e <readline+0x54>
ffffffffc0204250:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204252:	e42a                	sd	a0,8(sp)
ffffffffc0204254:	e9dfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc0204258:	6522                	ld	a0,8(sp)
ffffffffc020425a:	009b87b3          	add	a5,s7,s1
ffffffffc020425e:	2485                	addiw	s1,s1,1
ffffffffc0204260:	00a78023          	sb	a0,0(a5)
ffffffffc0204264:	bf7d                	j	ffffffffc0204222 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0204266:	01550463          	beq	a0,s5,ffffffffc020426e <readline+0x84>
ffffffffc020426a:	fb651ce3          	bne	a0,s6,ffffffffc0204222 <readline+0x38>
            cputchar(c);
ffffffffc020426e:	e83fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc0204272:	0000d517          	auipc	a0,0xd
ffffffffc0204276:	e8650513          	addi	a0,a0,-378 # ffffffffc02110f8 <buf>
ffffffffc020427a:	94aa                	add	s1,s1,a0
ffffffffc020427c:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204280:	60a6                	ld	ra,72(sp)
ffffffffc0204282:	6486                	ld	s1,64(sp)
ffffffffc0204284:	7962                	ld	s2,56(sp)
ffffffffc0204286:	79c2                	ld	s3,48(sp)
ffffffffc0204288:	7a22                	ld	s4,40(sp)
ffffffffc020428a:	7a82                	ld	s5,32(sp)
ffffffffc020428c:	6b62                	ld	s6,24(sp)
ffffffffc020428e:	6bc2                	ld	s7,16(sp)
ffffffffc0204290:	6161                	addi	sp,sp,80
ffffffffc0204292:	8082                	ret
            cputchar(c);
ffffffffc0204294:	4521                	li	a0,8
ffffffffc0204296:	e5bfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc020429a:	34fd                	addiw	s1,s1,-1
ffffffffc020429c:	b759                	j	ffffffffc0204222 <readline+0x38>
