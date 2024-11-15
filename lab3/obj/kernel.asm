
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
ffffffffc020003e:	52a60613          	addi	a2,a2,1322 # ffffffffc0211564 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	7a5030ef          	jal	ra,ffffffffc0203fee <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	47258593          	addi	a1,a1,1138 # ffffffffc02044c0 <etext+0x6>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	48a50513          	addi	a0,a0,1162 # ffffffffc02044e0 <etext+0x26>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0fc000ef          	jal	ra,ffffffffc020015e <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	779000ef          	jal	ra,ffffffffc0200fde <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	7b3010ef          	jal	ra,ffffffffc0202020 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	35e000ef          	jal	ra,ffffffffc02003d0 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	650020ef          	jal	ra,ffffffffc02026c6 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	3ac000ef          	jal	ra,ffffffffc0200426 <clock_init>
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
ffffffffc0200088:	3f0000ef          	jal	ra,ffffffffc0200478 <cons_putc>
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
ffffffffc02000ae:	7d7030ef          	jal	ra,ffffffffc0204084 <vprintfmt>
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
ffffffffc02000e4:	7a1030ef          	jal	ra,ffffffffc0204084 <vprintfmt>
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
ffffffffc02000f0:	a661                	j	ffffffffc0200478 <cons_putc>

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
ffffffffc02000f6:	3b6000ef          	jal	ra,ffffffffc02004ac <cons_getc>
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
ffffffffc0200134:	3b850513          	addi	a0,a0,952 # ffffffffc02044e8 <etext+0x2e>
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
ffffffffc020014a:	15250513          	addi	a0,a0,338 # ffffffffc0205298 <commands+0xb60>
ffffffffc020014e:	f6dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200152:	39c000ef          	jal	ra,ffffffffc02004ee <intr_disable>
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
ffffffffc0200164:	3a850513          	addi	a0,a0,936 # ffffffffc0204508 <etext+0x4e>
void print_kerninfo(void) {
ffffffffc0200168:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	f51ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020016e:	00000597          	auipc	a1,0x0
ffffffffc0200172:	ec458593          	addi	a1,a1,-316 # ffffffffc0200032 <kern_init>
ffffffffc0200176:	00004517          	auipc	a0,0x4
ffffffffc020017a:	3b250513          	addi	a0,a0,946 # ffffffffc0204528 <etext+0x6e>
ffffffffc020017e:	f3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200182:	00004597          	auipc	a1,0x4
ffffffffc0200186:	33858593          	addi	a1,a1,824 # ffffffffc02044ba <etext>
ffffffffc020018a:	00004517          	auipc	a0,0x4
ffffffffc020018e:	3be50513          	addi	a0,a0,958 # ffffffffc0204548 <etext+0x8e>
ffffffffc0200192:	f29ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200196:	0000a597          	auipc	a1,0xa
ffffffffc020019a:	eaa58593          	addi	a1,a1,-342 # ffffffffc020a040 <ide>
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	3ca50513          	addi	a0,a0,970 # ffffffffc0204568 <etext+0xae>
ffffffffc02001a6:	f15ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001aa:	00011597          	auipc	a1,0x11
ffffffffc02001ae:	3ba58593          	addi	a1,a1,954 # ffffffffc0211564 <end>
ffffffffc02001b2:	00004517          	auipc	a0,0x4
ffffffffc02001b6:	3d650513          	addi	a0,a0,982 # ffffffffc0204588 <etext+0xce>
ffffffffc02001ba:	f01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001be:	00011597          	auipc	a1,0x11
ffffffffc02001c2:	7a558593          	addi	a1,a1,1957 # ffffffffc0211963 <end+0x3ff>
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
ffffffffc02001e4:	3c850513          	addi	a0,a0,968 # ffffffffc02045a8 <etext+0xee>
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
ffffffffc02001f2:	3ea60613          	addi	a2,a2,1002 # ffffffffc02045d8 <etext+0x11e>
ffffffffc02001f6:	04e00593          	li	a1,78
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	3f650513          	addi	a0,a0,1014 # ffffffffc02045f0 <etext+0x136>
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
ffffffffc020020e:	3fe60613          	addi	a2,a2,1022 # ffffffffc0204608 <etext+0x14e>
ffffffffc0200212:	00004597          	auipc	a1,0x4
ffffffffc0200216:	41658593          	addi	a1,a1,1046 # ffffffffc0204628 <etext+0x16e>
ffffffffc020021a:	00004517          	auipc	a0,0x4
ffffffffc020021e:	41650513          	addi	a0,a0,1046 # ffffffffc0204630 <etext+0x176>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200224:	e97ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200228:	00004617          	auipc	a2,0x4
ffffffffc020022c:	41860613          	addi	a2,a2,1048 # ffffffffc0204640 <etext+0x186>
ffffffffc0200230:	00004597          	auipc	a1,0x4
ffffffffc0200234:	43858593          	addi	a1,a1,1080 # ffffffffc0204668 <etext+0x1ae>
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	3f850513          	addi	a0,a0,1016 # ffffffffc0204630 <etext+0x176>
ffffffffc0200240:	e7bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200244:	00004617          	auipc	a2,0x4
ffffffffc0200248:	43460613          	addi	a2,a2,1076 # ffffffffc0204678 <etext+0x1be>
ffffffffc020024c:	00004597          	auipc	a1,0x4
ffffffffc0200250:	44c58593          	addi	a1,a1,1100 # ffffffffc0204698 <etext+0x1de>
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	3dc50513          	addi	a0,a0,988 # ffffffffc0204630 <etext+0x176>
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
ffffffffc0200292:	41a50513          	addi	a0,a0,1050 # ffffffffc02046a8 <etext+0x1ee>
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
ffffffffc02002b4:	42050513          	addi	a0,a0,1056 # ffffffffc02046d0 <etext+0x216>
ffffffffc02002b8:	e03ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002bc:	000b8563          	beqz	s7,ffffffffc02002c6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002c0:	855e                	mv	a0,s7
ffffffffc02002c2:	48c000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc02002c6:	00004c17          	auipc	s8,0x4
ffffffffc02002ca:	472c0c13          	addi	s8,s8,1138 # ffffffffc0204738 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002ce:	00005917          	auipc	s2,0x5
ffffffffc02002d2:	7d290913          	addi	s2,s2,2002 # ffffffffc0205aa0 <commands+0x1368>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d6:	00004497          	auipc	s1,0x4
ffffffffc02002da:	42248493          	addi	s1,s1,1058 # ffffffffc02046f8 <etext+0x23e>
        if (argc == MAXARGS - 1) {
ffffffffc02002de:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002e0:	00004b17          	auipc	s6,0x4
ffffffffc02002e4:	420b0b13          	addi	s6,s6,1056 # ffffffffc0204700 <etext+0x246>
        argv[argc ++] = buf;
ffffffffc02002e8:	00004a17          	auipc	s4,0x4
ffffffffc02002ec:	340a0a13          	addi	s4,s4,832 # ffffffffc0204628 <etext+0x16e>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002f2:	854a                	mv	a0,s2
ffffffffc02002f4:	112040ef          	jal	ra,ffffffffc0204406 <readline>
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
ffffffffc020030e:	42ed0d13          	addi	s10,s10,1070 # ffffffffc0204738 <commands>
        argv[argc ++] = buf;
ffffffffc0200312:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200314:	4401                	li	s0,0
ffffffffc0200316:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	4a3030ef          	jal	ra,ffffffffc0203fba <strcmp>
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
ffffffffc020032c:	48f030ef          	jal	ra,ffffffffc0203fba <strcmp>
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
ffffffffc020036a:	46f030ef          	jal	ra,ffffffffc0203fd8 <strchr>
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
ffffffffc02003a8:	431030ef          	jal	ra,ffffffffc0203fd8 <strchr>
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
ffffffffc02003c6:	35e50513          	addi	a0,a0,862 # ffffffffc0204720 <etext+0x266>
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

ffffffffc02003de <ide_read_secs>:
// nsecs：要读取的扇区数量。
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    // 计算读取偏移
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003de:	0000a797          	auipc	a5,0xa
ffffffffc02003e2:	c6278793          	addi	a5,a5,-926 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02003e6:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02003ea:	1141                	addi	sp,sp,-16
ffffffffc02003ec:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003ee:	95be                	add	a1,a1,a5
ffffffffc02003f0:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02003f4:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003f6:	40b030ef          	jal	ra,ffffffffc0204000 <memcpy>
    return 0;
}
ffffffffc02003fa:	60a2                	ld	ra,8(sp)
ffffffffc02003fc:	4501                	li	a0,0
ffffffffc02003fe:	0141                	addi	sp,sp,16
ffffffffc0200400:	8082                	ret

ffffffffc0200402 <ide_write_secs>:

// 将数据写入到模拟磁盘的指定扇区中
int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE; // 偏移
ffffffffc0200402:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200406:	0000a517          	auipc	a0,0xa
ffffffffc020040a:	c3a50513          	addi	a0,a0,-966 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc020040e:	1141                	addi	sp,sp,-16
ffffffffc0200410:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200412:	953e                	add	a0,a0,a5
ffffffffc0200414:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc0200418:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020041a:	3e7030ef          	jal	ra,ffffffffc0204000 <memcpy>
    return 0;
}
ffffffffc020041e:	60a2                	ld	ra,8(sp)
ffffffffc0200420:	4501                	li	a0,0
ffffffffc0200422:	0141                	addi	sp,sp,16
ffffffffc0200424:	8082                	ret

ffffffffc0200426 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200426:	67e1                	lui	a5,0x18
ffffffffc0200428:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020042c:	00011717          	auipc	a4,0x11
ffffffffc0200430:	0cf73e23          	sd	a5,220(a4) # ffffffffc0211508 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200434:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200438:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043a:	953e                	add	a0,a0,a5
ffffffffc020043c:	4601                	li	a2,0
ffffffffc020043e:	4881                	li	a7,0
ffffffffc0200440:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200444:	02000793          	li	a5,32
ffffffffc0200448:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020044c:	00004517          	auipc	a0,0x4
ffffffffc0200450:	33450513          	addi	a0,a0,820 # ffffffffc0204780 <commands+0x48>
    ticks = 0;
ffffffffc0200454:	00011797          	auipc	a5,0x11
ffffffffc0200458:	0a07b623          	sd	zero,172(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020045c:	b9b9                	j	ffffffffc02000ba <cprintf>

ffffffffc020045e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020045e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200462:	00011797          	auipc	a5,0x11
ffffffffc0200466:	0a67b783          	ld	a5,166(a5) # ffffffffc0211508 <timebase>
ffffffffc020046a:	953e                	add	a0,a0,a5
ffffffffc020046c:	4581                	li	a1,0
ffffffffc020046e:	4601                	li	a2,0
ffffffffc0200470:	4881                	li	a7,0
ffffffffc0200472:	00000073          	ecall
ffffffffc0200476:	8082                	ret

ffffffffc0200478 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200478:	100027f3          	csrr	a5,sstatus
ffffffffc020047c:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020047e:	0ff57513          	zext.b	a0,a0
ffffffffc0200482:	e799                	bnez	a5,ffffffffc0200490 <cons_putc+0x18>
ffffffffc0200484:	4581                	li	a1,0
ffffffffc0200486:	4601                	li	a2,0
ffffffffc0200488:	4885                	li	a7,1
ffffffffc020048a:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020048e:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200490:	1101                	addi	sp,sp,-32
ffffffffc0200492:	ec06                	sd	ra,24(sp)
ffffffffc0200494:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200496:	058000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020049a:	6522                	ld	a0,8(sp)
ffffffffc020049c:	4581                	li	a1,0
ffffffffc020049e:	4601                	li	a2,0
ffffffffc02004a0:	4885                	li	a7,1
ffffffffc02004a2:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004a6:	60e2                	ld	ra,24(sp)
ffffffffc02004a8:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004aa:	a83d                	j	ffffffffc02004e8 <intr_enable>

ffffffffc02004ac <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004ac:	100027f3          	csrr	a5,sstatus
ffffffffc02004b0:	8b89                	andi	a5,a5,2
ffffffffc02004b2:	eb89                	bnez	a5,ffffffffc02004c4 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004b4:	4501                	li	a0,0
ffffffffc02004b6:	4581                	li	a1,0
ffffffffc02004b8:	4601                	li	a2,0
ffffffffc02004ba:	4889                	li	a7,2
ffffffffc02004bc:	00000073          	ecall
ffffffffc02004c0:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02004c2:	8082                	ret
int cons_getc(void) {
ffffffffc02004c4:	1101                	addi	sp,sp,-32
ffffffffc02004c6:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004c8:	026000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02004cc:	4501                	li	a0,0
ffffffffc02004ce:	4581                	li	a1,0
ffffffffc02004d0:	4601                	li	a2,0
ffffffffc02004d2:	4889                	li	a7,2
ffffffffc02004d4:	00000073          	ecall
ffffffffc02004d8:	2501                	sext.w	a0,a0
ffffffffc02004da:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004dc:	00c000ef          	jal	ra,ffffffffc02004e8 <intr_enable>
}
ffffffffc02004e0:	60e2                	ld	ra,24(sp)
ffffffffc02004e2:	6522                	ld	a0,8(sp)
ffffffffc02004e4:	6105                	addi	sp,sp,32
ffffffffc02004e6:	8082                	ret

ffffffffc02004e8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ee:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f8:	1141                	addi	sp,sp,-16
ffffffffc02004fa:	e022                	sd	s0,0(sp)
ffffffffc02004fc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004fe:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200502:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	05500613          	li	a2,85
ffffffffc020050c:	c399                	beqz	a5,ffffffffc0200512 <pgfault_handler+0x1e>
ffffffffc020050e:	04b00613          	li	a2,75
ffffffffc0200512:	11843703          	ld	a4,280(s0)
ffffffffc0200516:	47bd                	li	a5,15
ffffffffc0200518:	05700693          	li	a3,87
ffffffffc020051c:	00f70463          	beq	a4,a5,ffffffffc0200524 <pgfault_handler+0x30>
ffffffffc0200520:	05200693          	li	a3,82
ffffffffc0200524:	00004517          	auipc	a0,0x4
ffffffffc0200528:	27c50513          	addi	a0,a0,636 # ffffffffc02047a0 <commands+0x68>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	01053503          	ld	a0,16(a0) # ffffffffc0211540 <check_mm_struct>
ffffffffc0200538:	c911                	beqz	a0,ffffffffc020054c <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053a:	11043603          	ld	a2,272(s0)
ffffffffc020053e:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200542:	6402                	ld	s0,0(sp)
ffffffffc0200544:	60a2                	ld	ra,8(sp)
ffffffffc0200546:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	0b00206f          	j	ffffffffc02025f8 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	27460613          	addi	a2,a2,628 # ffffffffc02047c0 <commands+0x88>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	28050513          	addi	a0,a0,640 # ffffffffc02047d8 <commands+0xa0>
ffffffffc0200560:	ba3ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	48878793          	addi	a5,a5,1160 # ffffffffc02009f0 <__alltraps>
ffffffffc0200570:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200574:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200578:	000407b7          	lui	a5,0x40
ffffffffc020057c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200584:	1141                	addi	sp,sp,-16
ffffffffc0200586:	e022                	sd	s0,0(sp)
ffffffffc0200588:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	26650513          	addi	a0,a0,614 # ffffffffc02047f0 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	26e50513          	addi	a0,a0,622 # ffffffffc0204808 <commands+0xd0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	27850513          	addi	a0,a0,632 # ffffffffc0204820 <commands+0xe8>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	28250513          	addi	a0,a0,642 # ffffffffc0204838 <commands+0x100>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	28c50513          	addi	a0,a0,652 # ffffffffc0204850 <commands+0x118>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	29650513          	addi	a0,a0,662 # ffffffffc0204868 <commands+0x130>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	2a050513          	addi	a0,a0,672 # ffffffffc0204880 <commands+0x148>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	2aa50513          	addi	a0,a0,682 # ffffffffc0204898 <commands+0x160>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	2b450513          	addi	a0,a0,692 # ffffffffc02048b0 <commands+0x178>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	2be50513          	addi	a0,a0,702 # ffffffffc02048c8 <commands+0x190>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	2c850513          	addi	a0,a0,712 # ffffffffc02048e0 <commands+0x1a8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	2d250513          	addi	a0,a0,722 # ffffffffc02048f8 <commands+0x1c0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	2dc50513          	addi	a0,a0,732 # ffffffffc0204910 <commands+0x1d8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	2e650513          	addi	a0,a0,742 # ffffffffc0204928 <commands+0x1f0>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	2f050513          	addi	a0,a0,752 # ffffffffc0204940 <commands+0x208>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	2fa50513          	addi	a0,a0,762 # ffffffffc0204958 <commands+0x220>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	30450513          	addi	a0,a0,772 # ffffffffc0204970 <commands+0x238>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	30e50513          	addi	a0,a0,782 # ffffffffc0204988 <commands+0x250>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	31850513          	addi	a0,a0,792 # ffffffffc02049a0 <commands+0x268>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	32250513          	addi	a0,a0,802 # ffffffffc02049b8 <commands+0x280>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	32c50513          	addi	a0,a0,812 # ffffffffc02049d0 <commands+0x298>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	33650513          	addi	a0,a0,822 # ffffffffc02049e8 <commands+0x2b0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	34050513          	addi	a0,a0,832 # ffffffffc0204a00 <commands+0x2c8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	34a50513          	addi	a0,a0,842 # ffffffffc0204a18 <commands+0x2e0>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	35450513          	addi	a0,a0,852 # ffffffffc0204a30 <commands+0x2f8>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	35e50513          	addi	a0,a0,862 # ffffffffc0204a48 <commands+0x310>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	36850513          	addi	a0,a0,872 # ffffffffc0204a60 <commands+0x328>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	37250513          	addi	a0,a0,882 # ffffffffc0204a78 <commands+0x340>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	37c50513          	addi	a0,a0,892 # ffffffffc0204a90 <commands+0x358>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	38650513          	addi	a0,a0,902 # ffffffffc0204aa8 <commands+0x370>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	39050513          	addi	a0,a0,912 # ffffffffc0204ac0 <commands+0x388>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	39650513          	addi	a0,a0,918 # ffffffffc0204ad8 <commands+0x3a0>
}
ffffffffc020074a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074c:	b2bd                	j	ffffffffc02000ba <cprintf>

ffffffffc020074e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200752:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	00004517          	auipc	a0,0x4
ffffffffc020075a:	39a50513          	addi	a0,a0,922 # ffffffffc0204af0 <commands+0x3b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200760:	95bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200764:	8522                	mv	a0,s0
ffffffffc0200766:	e1dff0ef          	jal	ra,ffffffffc0200582 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076a:	10043583          	ld	a1,256(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	39a50513          	addi	a0,a0,922 # ffffffffc0204b08 <commands+0x3d0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	3a250513          	addi	a0,a0,930 # ffffffffc0204b20 <commands+0x3e8>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	3aa50513          	addi	a0,a0,938 # ffffffffc0204b38 <commands+0x400>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	3ae50513          	addi	a0,a0,942 # ffffffffc0204b50 <commands+0x418>
}
ffffffffc02007aa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007ac:	90fff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02007b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b0:	11853783          	ld	a5,280(a0)
ffffffffc02007b4:	472d                	li	a4,11
ffffffffc02007b6:	0786                	slli	a5,a5,0x1
ffffffffc02007b8:	8385                	srli	a5,a5,0x1
ffffffffc02007ba:	06f76c63          	bltu	a4,a5,ffffffffc0200832 <interrupt_handler+0x82>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	45a70713          	addi	a4,a4,1114 # ffffffffc0204c18 <commands+0x4e0>
ffffffffc02007c6:	078a                	slli	a5,a5,0x2
ffffffffc02007c8:	97ba                	add	a5,a5,a4
ffffffffc02007ca:	439c                	lw	a5,0(a5)
ffffffffc02007cc:	97ba                	add	a5,a5,a4
ffffffffc02007ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	3f850513          	addi	a0,a0,1016 # ffffffffc0204bc8 <commands+0x490>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	3cc50513          	addi	a0,a0,972 # ffffffffc0204ba8 <commands+0x470>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	38050513          	addi	a0,a0,896 # ffffffffc0204b68 <commands+0x430>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	39450513          	addi	a0,a0,916 # ffffffffc0204b88 <commands+0x450>
ffffffffc02007fc:	8bfff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200800:	1141                	addi	sp,sp,-16
ffffffffc0200802:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200804:	c5bff0ef          	jal	ra,ffffffffc020045e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200808:	00011697          	auipc	a3,0x11
ffffffffc020080c:	cf868693          	addi	a3,a3,-776 # ffffffffc0211500 <ticks>
ffffffffc0200810:	629c                	ld	a5,0(a3)
ffffffffc0200812:	06400713          	li	a4,100
ffffffffc0200816:	0785                	addi	a5,a5,1
ffffffffc0200818:	02e7f733          	remu	a4,a5,a4
ffffffffc020081c:	e29c                	sd	a5,0(a3)
ffffffffc020081e:	cb19                	beqz	a4,ffffffffc0200834 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200820:	60a2                	ld	ra,8(sp)
ffffffffc0200822:	0141                	addi	sp,sp,16
ffffffffc0200824:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200826:	00004517          	auipc	a0,0x4
ffffffffc020082a:	3d250513          	addi	a0,a0,978 # ffffffffc0204bf8 <commands+0x4c0>
ffffffffc020082e:	88dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200832:	bf31                	j	ffffffffc020074e <print_trapframe>
}
ffffffffc0200834:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200836:	06400593          	li	a1,100
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	3ae50513          	addi	a0,a0,942 # ffffffffc0204be8 <commands+0x4b0>
}
ffffffffc0200842:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200844:	877ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0200848 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200848:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020084c:	1101                	addi	sp,sp,-32
ffffffffc020084e:	e822                	sd	s0,16(sp)
ffffffffc0200850:	ec06                	sd	ra,24(sp)
ffffffffc0200852:	e426                	sd	s1,8(sp)
ffffffffc0200854:	473d                	li	a4,15
ffffffffc0200856:	842a                	mv	s0,a0
ffffffffc0200858:	14f76a63          	bltu	a4,a5,ffffffffc02009ac <exception_handler+0x164>
ffffffffc020085c:	00004717          	auipc	a4,0x4
ffffffffc0200860:	5a470713          	addi	a4,a4,1444 # ffffffffc0204e00 <commands+0x6c8>
ffffffffc0200864:	078a                	slli	a5,a5,0x2
ffffffffc0200866:	97ba                	add	a5,a5,a4
ffffffffc0200868:	439c                	lw	a5,0(a5)
ffffffffc020086a:	97ba                	add	a5,a5,a4
ffffffffc020086c:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020086e:	00004517          	auipc	a0,0x4
ffffffffc0200872:	57a50513          	addi	a0,a0,1402 # ffffffffc0204de8 <commands+0x6b0>
ffffffffc0200876:	845ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020087a:	8522                	mv	a0,s0
ffffffffc020087c:	c79ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200880:	84aa                	mv	s1,a0
ffffffffc0200882:	12051b63          	bnez	a0,ffffffffc02009b8 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200886:	60e2                	ld	ra,24(sp)
ffffffffc0200888:	6442                	ld	s0,16(sp)
ffffffffc020088a:	64a2                	ld	s1,8(sp)
ffffffffc020088c:	6105                	addi	sp,sp,32
ffffffffc020088e:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200890:	00004517          	auipc	a0,0x4
ffffffffc0200894:	3b850513          	addi	a0,a0,952 # ffffffffc0204c48 <commands+0x510>
}
ffffffffc0200898:	6442                	ld	s0,16(sp)
ffffffffc020089a:	60e2                	ld	ra,24(sp)
ffffffffc020089c:	64a2                	ld	s1,8(sp)
ffffffffc020089e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008a0:	81bff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	3c450513          	addi	a0,a0,964 # ffffffffc0204c68 <commands+0x530>
ffffffffc02008ac:	b7f5                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	3da50513          	addi	a0,a0,986 # ffffffffc0204c88 <commands+0x550>
ffffffffc02008b6:	b7cd                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	3e850513          	addi	a0,a0,1000 # ffffffffc0204ca0 <commands+0x568>
ffffffffc02008c0:	bfe1                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008c2:	00004517          	auipc	a0,0x4
ffffffffc02008c6:	3ee50513          	addi	a0,a0,1006 # ffffffffc0204cb0 <commands+0x578>
ffffffffc02008ca:	b7f9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	40450513          	addi	a0,a0,1028 # ffffffffc0204cd0 <commands+0x598>
ffffffffc02008d4:	fe6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008d8:	8522                	mv	a0,s0
ffffffffc02008da:	c1bff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008de:	84aa                	mv	s1,a0
ffffffffc02008e0:	d15d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008e2:	8522                	mv	a0,s0
ffffffffc02008e4:	e6bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008e8:	86a6                	mv	a3,s1
ffffffffc02008ea:	00004617          	auipc	a2,0x4
ffffffffc02008ee:	3fe60613          	addi	a2,a2,1022 # ffffffffc0204ce8 <commands+0x5b0>
ffffffffc02008f2:	0ca00593          	li	a1,202
ffffffffc02008f6:	00004517          	auipc	a0,0x4
ffffffffc02008fa:	ee250513          	addi	a0,a0,-286 # ffffffffc02047d8 <commands+0xa0>
ffffffffc02008fe:	805ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	40650513          	addi	a0,a0,1030 # ffffffffc0204d08 <commands+0x5d0>
ffffffffc020090a:	b779                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	41450513          	addi	a0,a0,1044 # ffffffffc0204d20 <commands+0x5e8>
ffffffffc0200914:	fa6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200918:	8522                	mv	a0,s0
ffffffffc020091a:	bdbff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020091e:	84aa                	mv	s1,a0
ffffffffc0200920:	d13d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200922:	8522                	mv	a0,s0
ffffffffc0200924:	e2bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200928:	86a6                	mv	a3,s1
ffffffffc020092a:	00004617          	auipc	a2,0x4
ffffffffc020092e:	3be60613          	addi	a2,a2,958 # ffffffffc0204ce8 <commands+0x5b0>
ffffffffc0200932:	0d400593          	li	a1,212
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	ea250513          	addi	a0,a0,-350 # ffffffffc02047d8 <commands+0xa0>
ffffffffc020093e:	fc4ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	3f650513          	addi	a0,a0,1014 # ffffffffc0204d38 <commands+0x600>
ffffffffc020094a:	b7b9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	40c50513          	addi	a0,a0,1036 # ffffffffc0204d58 <commands+0x620>
ffffffffc0200954:	b791                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	42250513          	addi	a0,a0,1058 # ffffffffc0204d78 <commands+0x640>
ffffffffc020095e:	bf2d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200960:	00004517          	auipc	a0,0x4
ffffffffc0200964:	43850513          	addi	a0,a0,1080 # ffffffffc0204d98 <commands+0x660>
ffffffffc0200968:	bf05                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	44e50513          	addi	a0,a0,1102 # ffffffffc0204db8 <commands+0x680>
ffffffffc0200972:	b71d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	45c50513          	addi	a0,a0,1116 # ffffffffc0204dd0 <commands+0x698>
ffffffffc020097c:	f3eff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200980:	8522                	mv	a0,s0
ffffffffc0200982:	b73ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200986:	84aa                	mv	s1,a0
ffffffffc0200988:	ee050fe3          	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020098c:	8522                	mv	a0,s0
ffffffffc020098e:	dc1ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200992:	86a6                	mv	a3,s1
ffffffffc0200994:	00004617          	auipc	a2,0x4
ffffffffc0200998:	35460613          	addi	a2,a2,852 # ffffffffc0204ce8 <commands+0x5b0>
ffffffffc020099c:	0ea00593          	li	a1,234
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	e3850513          	addi	a0,a0,-456 # ffffffffc02047d8 <commands+0xa0>
ffffffffc02009a8:	f5aff0ef          	jal	ra,ffffffffc0200102 <__panic>
            print_trapframe(tf);
ffffffffc02009ac:	8522                	mv	a0,s0
}
ffffffffc02009ae:	6442                	ld	s0,16(sp)
ffffffffc02009b0:	60e2                	ld	ra,24(sp)
ffffffffc02009b2:	64a2                	ld	s1,8(sp)
ffffffffc02009b4:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009b6:	bb61                	j	ffffffffc020074e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009b8:	8522                	mv	a0,s0
ffffffffc02009ba:	d95ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009be:	86a6                	mv	a3,s1
ffffffffc02009c0:	00004617          	auipc	a2,0x4
ffffffffc02009c4:	32860613          	addi	a2,a2,808 # ffffffffc0204ce8 <commands+0x5b0>
ffffffffc02009c8:	0f100593          	li	a1,241
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	e0c50513          	addi	a0,a0,-500 # ffffffffc02047d8 <commands+0xa0>
ffffffffc02009d4:	f2eff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02009d8 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009d8:	11853783          	ld	a5,280(a0)
ffffffffc02009dc:	0007c363          	bltz	a5,ffffffffc02009e2 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009e0:	b5a5                	j	ffffffffc0200848 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009e2:	b3f9                	j	ffffffffc02007b0 <interrupt_handler>
	...

ffffffffc02009f0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009f0:	14011073          	csrw	sscratch,sp
ffffffffc02009f4:	712d                	addi	sp,sp,-288
ffffffffc02009f6:	e406                	sd	ra,8(sp)
ffffffffc02009f8:	ec0e                	sd	gp,24(sp)
ffffffffc02009fa:	f012                	sd	tp,32(sp)
ffffffffc02009fc:	f416                	sd	t0,40(sp)
ffffffffc02009fe:	f81a                	sd	t1,48(sp)
ffffffffc0200a00:	fc1e                	sd	t2,56(sp)
ffffffffc0200a02:	e0a2                	sd	s0,64(sp)
ffffffffc0200a04:	e4a6                	sd	s1,72(sp)
ffffffffc0200a06:	e8aa                	sd	a0,80(sp)
ffffffffc0200a08:	ecae                	sd	a1,88(sp)
ffffffffc0200a0a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a0c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a0e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a10:	fcbe                	sd	a5,120(sp)
ffffffffc0200a12:	e142                	sd	a6,128(sp)
ffffffffc0200a14:	e546                	sd	a7,136(sp)
ffffffffc0200a16:	e94a                	sd	s2,144(sp)
ffffffffc0200a18:	ed4e                	sd	s3,152(sp)
ffffffffc0200a1a:	f152                	sd	s4,160(sp)
ffffffffc0200a1c:	f556                	sd	s5,168(sp)
ffffffffc0200a1e:	f95a                	sd	s6,176(sp)
ffffffffc0200a20:	fd5e                	sd	s7,184(sp)
ffffffffc0200a22:	e1e2                	sd	s8,192(sp)
ffffffffc0200a24:	e5e6                	sd	s9,200(sp)
ffffffffc0200a26:	e9ea                	sd	s10,208(sp)
ffffffffc0200a28:	edee                	sd	s11,216(sp)
ffffffffc0200a2a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a2c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a2e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a30:	fdfe                	sd	t6,248(sp)
ffffffffc0200a32:	14002473          	csrr	s0,sscratch
ffffffffc0200a36:	100024f3          	csrr	s1,sstatus
ffffffffc0200a3a:	14102973          	csrr	s2,sepc
ffffffffc0200a3e:	143029f3          	csrr	s3,stval
ffffffffc0200a42:	14202a73          	csrr	s4,scause
ffffffffc0200a46:	e822                	sd	s0,16(sp)
ffffffffc0200a48:	e226                	sd	s1,256(sp)
ffffffffc0200a4a:	e64a                	sd	s2,264(sp)
ffffffffc0200a4c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a4e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a50:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a52:	f87ff0ef          	jal	ra,ffffffffc02009d8 <trap>

ffffffffc0200a56 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a56:	6492                	ld	s1,256(sp)
ffffffffc0200a58:	6932                	ld	s2,264(sp)
ffffffffc0200a5a:	10049073          	csrw	sstatus,s1
ffffffffc0200a5e:	14191073          	csrw	sepc,s2
ffffffffc0200a62:	60a2                	ld	ra,8(sp)
ffffffffc0200a64:	61e2                	ld	gp,24(sp)
ffffffffc0200a66:	7202                	ld	tp,32(sp)
ffffffffc0200a68:	72a2                	ld	t0,40(sp)
ffffffffc0200a6a:	7342                	ld	t1,48(sp)
ffffffffc0200a6c:	73e2                	ld	t2,56(sp)
ffffffffc0200a6e:	6406                	ld	s0,64(sp)
ffffffffc0200a70:	64a6                	ld	s1,72(sp)
ffffffffc0200a72:	6546                	ld	a0,80(sp)
ffffffffc0200a74:	65e6                	ld	a1,88(sp)
ffffffffc0200a76:	7606                	ld	a2,96(sp)
ffffffffc0200a78:	76a6                	ld	a3,104(sp)
ffffffffc0200a7a:	7746                	ld	a4,112(sp)
ffffffffc0200a7c:	77e6                	ld	a5,120(sp)
ffffffffc0200a7e:	680a                	ld	a6,128(sp)
ffffffffc0200a80:	68aa                	ld	a7,136(sp)
ffffffffc0200a82:	694a                	ld	s2,144(sp)
ffffffffc0200a84:	69ea                	ld	s3,152(sp)
ffffffffc0200a86:	7a0a                	ld	s4,160(sp)
ffffffffc0200a88:	7aaa                	ld	s5,168(sp)
ffffffffc0200a8a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a8c:	7bea                	ld	s7,184(sp)
ffffffffc0200a8e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a90:	6cae                	ld	s9,200(sp)
ffffffffc0200a92:	6d4e                	ld	s10,208(sp)
ffffffffc0200a94:	6dee                	ld	s11,216(sp)
ffffffffc0200a96:	7e0e                	ld	t3,224(sp)
ffffffffc0200a98:	7eae                	ld	t4,232(sp)
ffffffffc0200a9a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a9c:	7fee                	ld	t6,248(sp)
ffffffffc0200a9e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200aa0:	10200073          	sret
	...

ffffffffc0200ab0 <pa2page.part.0>:

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0200ab0:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200ab2:	00004617          	auipc	a2,0x4
ffffffffc0200ab6:	38e60613          	addi	a2,a2,910 # ffffffffc0204e40 <commands+0x708>
ffffffffc0200aba:	06500593          	li	a1,101
ffffffffc0200abe:	00004517          	auipc	a0,0x4
ffffffffc0200ac2:	3a250513          	addi	a0,a0,930 # ffffffffc0204e60 <commands+0x728>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0200ac6:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200ac8:	e3aff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200acc <pte2page.part.0>:

static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }

static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }

static inline struct Page *pte2page(pte_t pte) {
ffffffffc0200acc:	1141                	addi	sp,sp,-16
    if (!(pte & PTE_V)) {
        panic("pte2page called with invalid pte");
ffffffffc0200ace:	00004617          	auipc	a2,0x4
ffffffffc0200ad2:	3a260613          	addi	a2,a2,930 # ffffffffc0204e70 <commands+0x738>
ffffffffc0200ad6:	07000593          	li	a1,112
ffffffffc0200ada:	00004517          	auipc	a0,0x4
ffffffffc0200ade:	38650513          	addi	a0,a0,902 # ffffffffc0204e60 <commands+0x728>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0200ae2:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0200ae4:	e1eff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200ae8 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200ae8:	7139                	addi	sp,sp,-64
ffffffffc0200aea:	f426                	sd	s1,40(sp)
ffffffffc0200aec:	f04a                	sd	s2,32(sp)
ffffffffc0200aee:	ec4e                	sd	s3,24(sp)
ffffffffc0200af0:	e852                	sd	s4,16(sp)
ffffffffc0200af2:	e456                	sd	s5,8(sp)
ffffffffc0200af4:	e05a                	sd	s6,0(sp)
ffffffffc0200af6:	fc06                	sd	ra,56(sp)
ffffffffc0200af8:	f822                	sd	s0,48(sp)
ffffffffc0200afa:	84aa                	mv	s1,a0
ffffffffc0200afc:	00011917          	auipc	s2,0x11
ffffffffc0200b00:	a3490913          	addi	s2,s2,-1484 # ffffffffc0211530 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b04:	4a05                	li	s4,1
ffffffffc0200b06:	00011a97          	auipc	s5,0x11
ffffffffc0200b0a:	a5aa8a93          	addi	s5,s5,-1446 # ffffffffc0211560 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b0e:	0005099b          	sext.w	s3,a0
ffffffffc0200b12:	00011b17          	auipc	s6,0x11
ffffffffc0200b16:	a2eb0b13          	addi	s6,s6,-1490 # ffffffffc0211540 <check_mm_struct>
ffffffffc0200b1a:	a01d                	j	ffffffffc0200b40 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0200b1c:	00093783          	ld	a5,0(s2)
ffffffffc0200b20:	6f9c                	ld	a5,24(a5)
ffffffffc0200b22:	9782                	jalr	a5
ffffffffc0200b24:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b26:	4601                	li	a2,0
ffffffffc0200b28:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b2a:	ec0d                	bnez	s0,ffffffffc0200b64 <alloc_pages+0x7c>
ffffffffc0200b2c:	029a6c63          	bltu	s4,s1,ffffffffc0200b64 <alloc_pages+0x7c>
ffffffffc0200b30:	000aa783          	lw	a5,0(s5)
ffffffffc0200b34:	2781                	sext.w	a5,a5
ffffffffc0200b36:	c79d                	beqz	a5,ffffffffc0200b64 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b38:	000b3503          	ld	a0,0(s6)
ffffffffc0200b3c:	20c020ef          	jal	ra,ffffffffc0202d48 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b40:	100027f3          	csrr	a5,sstatus
ffffffffc0200b44:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0200b46:	8526                	mv	a0,s1
ffffffffc0200b48:	dbf1                	beqz	a5,ffffffffc0200b1c <alloc_pages+0x34>
        intr_disable();
ffffffffc0200b4a:	9a5ff0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200b4e:	00093783          	ld	a5,0(s2)
ffffffffc0200b52:	8526                	mv	a0,s1
ffffffffc0200b54:	6f9c                	ld	a5,24(a5)
ffffffffc0200b56:	9782                	jalr	a5
ffffffffc0200b58:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200b5a:	98fff0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b5e:	4601                	li	a2,0
ffffffffc0200b60:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b62:	d469                	beqz	s0,ffffffffc0200b2c <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200b64:	70e2                	ld	ra,56(sp)
ffffffffc0200b66:	8522                	mv	a0,s0
ffffffffc0200b68:	7442                	ld	s0,48(sp)
ffffffffc0200b6a:	74a2                	ld	s1,40(sp)
ffffffffc0200b6c:	7902                	ld	s2,32(sp)
ffffffffc0200b6e:	69e2                	ld	s3,24(sp)
ffffffffc0200b70:	6a42                	ld	s4,16(sp)
ffffffffc0200b72:	6aa2                	ld	s5,8(sp)
ffffffffc0200b74:	6b02                	ld	s6,0(sp)
ffffffffc0200b76:	6121                	addi	sp,sp,64
ffffffffc0200b78:	8082                	ret

ffffffffc0200b7a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b7a:	100027f3          	csrr	a5,sstatus
ffffffffc0200b7e:	8b89                	andi	a5,a5,2
ffffffffc0200b80:	e799                	bnez	a5,ffffffffc0200b8e <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0200b82:	00011797          	auipc	a5,0x11
ffffffffc0200b86:	9ae7b783          	ld	a5,-1618(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200b8a:	739c                	ld	a5,32(a5)
ffffffffc0200b8c:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200b8e:	1101                	addi	sp,sp,-32
ffffffffc0200b90:	ec06                	sd	ra,24(sp)
ffffffffc0200b92:	e822                	sd	s0,16(sp)
ffffffffc0200b94:	e426                	sd	s1,8(sp)
ffffffffc0200b96:	842a                	mv	s0,a0
ffffffffc0200b98:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200b9a:	955ff0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0200b9e:	00011797          	auipc	a5,0x11
ffffffffc0200ba2:	9927b783          	ld	a5,-1646(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200ba6:	739c                	ld	a5,32(a5)
ffffffffc0200ba8:	85a6                	mv	a1,s1
ffffffffc0200baa:	8522                	mv	a0,s0
ffffffffc0200bac:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0200bae:	6442                	ld	s0,16(sp)
ffffffffc0200bb0:	60e2                	ld	ra,24(sp)
ffffffffc0200bb2:	64a2                	ld	s1,8(sp)
ffffffffc0200bb4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200bb6:	933ff06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc0200bba <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200bba:	100027f3          	csrr	a5,sstatus
ffffffffc0200bbe:	8b89                	andi	a5,a5,2
ffffffffc0200bc0:	e799                	bnez	a5,ffffffffc0200bce <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0200bc2:	00011797          	auipc	a5,0x11
ffffffffc0200bc6:	96e7b783          	ld	a5,-1682(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200bca:	779c                	ld	a5,40(a5)
ffffffffc0200bcc:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200bce:	1141                	addi	sp,sp,-16
ffffffffc0200bd0:	e406                	sd	ra,8(sp)
ffffffffc0200bd2:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200bd4:	91bff0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0200bd8:	00011797          	auipc	a5,0x11
ffffffffc0200bdc:	9587b783          	ld	a5,-1704(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200be0:	779c                	ld	a5,40(a5)
ffffffffc0200be2:	9782                	jalr	a5
ffffffffc0200be4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200be6:	903ff0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200bea:	60a2                	ld	ra,8(sp)
ffffffffc0200bec:	8522                	mv	a0,s0
ffffffffc0200bee:	6402                	ld	s0,0(sp)
ffffffffc0200bf0:	0141                	addi	sp,sp,16
ffffffffc0200bf2:	8082                	ret

ffffffffc0200bf4 <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200bf4:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0200bf8:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200bfc:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200bfe:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200c00:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200c02:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200c06:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200c08:	f84a                	sd	s2,48(sp)
ffffffffc0200c0a:	f44e                	sd	s3,40(sp)
ffffffffc0200c0c:	f052                	sd	s4,32(sp)
ffffffffc0200c0e:	e486                	sd	ra,72(sp)
ffffffffc0200c10:	e0a2                	sd	s0,64(sp)
ffffffffc0200c12:	ec56                	sd	s5,24(sp)
ffffffffc0200c14:	e85a                	sd	s6,16(sp)
ffffffffc0200c16:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200c18:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200c1c:	892e                	mv	s2,a1
ffffffffc0200c1e:	8a32                	mv	s4,a2
ffffffffc0200c20:	00011997          	auipc	s3,0x11
ffffffffc0200c24:	90098993          	addi	s3,s3,-1792 # ffffffffc0211520 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200c28:	efb5                	bnez	a5,ffffffffc0200ca4 <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200c2a:	14060c63          	beqz	a2,ffffffffc0200d82 <get_pte+0x18e>
ffffffffc0200c2e:	4505                	li	a0,1
ffffffffc0200c30:	eb9ff0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc0200c34:	842a                	mv	s0,a0
ffffffffc0200c36:	14050663          	beqz	a0,ffffffffc0200d82 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c3a:	00011b97          	auipc	s7,0x11
ffffffffc0200c3e:	8eeb8b93          	addi	s7,s7,-1810 # ffffffffc0211528 <pages>
ffffffffc0200c42:	000bb503          	ld	a0,0(s7)
ffffffffc0200c46:	00005b17          	auipc	s6,0x5
ffffffffc0200c4a:	742b3b03          	ld	s6,1858(s6) # ffffffffc0206388 <error_string+0x38>
ffffffffc0200c4e:	00080ab7          	lui	s5,0x80
ffffffffc0200c52:	40a40533          	sub	a0,s0,a0
ffffffffc0200c56:	850d                	srai	a0,a0,0x3
ffffffffc0200c58:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200c5c:	00011997          	auipc	s3,0x11
ffffffffc0200c60:	8c498993          	addi	s3,s3,-1852 # ffffffffc0211520 <npage>
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200c64:	4785                	li	a5,1
ffffffffc0200c66:	0009b703          	ld	a4,0(s3)
ffffffffc0200c6a:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c6c:	9556                	add	a0,a0,s5
ffffffffc0200c6e:	00c51793          	slli	a5,a0,0xc
ffffffffc0200c72:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c74:	0532                	slli	a0,a0,0xc
ffffffffc0200c76:	14e7fd63          	bgeu	a5,a4,ffffffffc0200dd0 <get_pte+0x1dc>
ffffffffc0200c7a:	00011797          	auipc	a5,0x11
ffffffffc0200c7e:	8be7b783          	ld	a5,-1858(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0200c82:	6605                	lui	a2,0x1
ffffffffc0200c84:	4581                	li	a1,0
ffffffffc0200c86:	953e                	add	a0,a0,a5
ffffffffc0200c88:	366030ef          	jal	ra,ffffffffc0203fee <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c8c:	000bb683          	ld	a3,0(s7)
ffffffffc0200c90:	40d406b3          	sub	a3,s0,a3
ffffffffc0200c94:	868d                	srai	a3,a3,0x3
ffffffffc0200c96:	036686b3          	mul	a3,a3,s6
ffffffffc0200c9a:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200c9c:	06aa                	slli	a3,a3,0xa
ffffffffc0200c9e:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200ca2:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200ca4:	77fd                	lui	a5,0xfffff
ffffffffc0200ca6:	068a                	slli	a3,a3,0x2
ffffffffc0200ca8:	0009b703          	ld	a4,0(s3)
ffffffffc0200cac:	8efd                	and	a3,a3,a5
ffffffffc0200cae:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200cb2:	0ce7fa63          	bgeu	a5,a4,ffffffffc0200d86 <get_pte+0x192>
ffffffffc0200cb6:	00011a97          	auipc	s5,0x11
ffffffffc0200cba:	882a8a93          	addi	s5,s5,-1918 # ffffffffc0211538 <va_pa_offset>
ffffffffc0200cbe:	000ab403          	ld	s0,0(s5)
ffffffffc0200cc2:	01595793          	srli	a5,s2,0x15
ffffffffc0200cc6:	1ff7f793          	andi	a5,a5,511
ffffffffc0200cca:	96a2                	add	a3,a3,s0
ffffffffc0200ccc:	00379413          	slli	s0,a5,0x3
ffffffffc0200cd0:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0200cd2:	6014                	ld	a3,0(s0)
ffffffffc0200cd4:	0016f793          	andi	a5,a3,1
ffffffffc0200cd8:	ebad                	bnez	a5,ffffffffc0200d4a <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200cda:	0a0a0463          	beqz	s4,ffffffffc0200d82 <get_pte+0x18e>
ffffffffc0200cde:	4505                	li	a0,1
ffffffffc0200ce0:	e09ff0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc0200ce4:	84aa                	mv	s1,a0
ffffffffc0200ce6:	cd51                	beqz	a0,ffffffffc0200d82 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ce8:	00011b97          	auipc	s7,0x11
ffffffffc0200cec:	840b8b93          	addi	s7,s7,-1984 # ffffffffc0211528 <pages>
ffffffffc0200cf0:	000bb503          	ld	a0,0(s7)
ffffffffc0200cf4:	00005b17          	auipc	s6,0x5
ffffffffc0200cf8:	694b3b03          	ld	s6,1684(s6) # ffffffffc0206388 <error_string+0x38>
ffffffffc0200cfc:	00080a37          	lui	s4,0x80
ffffffffc0200d00:	40a48533          	sub	a0,s1,a0
ffffffffc0200d04:	850d                	srai	a0,a0,0x3
ffffffffc0200d06:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200d0a:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200d0c:	0009b703          	ld	a4,0(s3)
ffffffffc0200d10:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d12:	9552                	add	a0,a0,s4
ffffffffc0200d14:	00c51793          	slli	a5,a0,0xc
ffffffffc0200d18:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d1a:	0532                	slli	a0,a0,0xc
ffffffffc0200d1c:	08e7fd63          	bgeu	a5,a4,ffffffffc0200db6 <get_pte+0x1c2>
ffffffffc0200d20:	000ab783          	ld	a5,0(s5)
ffffffffc0200d24:	6605                	lui	a2,0x1
ffffffffc0200d26:	4581                	li	a1,0
ffffffffc0200d28:	953e                	add	a0,a0,a5
ffffffffc0200d2a:	2c4030ef          	jal	ra,ffffffffc0203fee <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d2e:	000bb683          	ld	a3,0(s7)
ffffffffc0200d32:	40d486b3          	sub	a3,s1,a3
ffffffffc0200d36:	868d                	srai	a3,a3,0x3
ffffffffc0200d38:	036686b3          	mul	a3,a3,s6
ffffffffc0200d3c:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200d3e:	06aa                	slli	a3,a3,0xa
ffffffffc0200d40:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200d44:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200d46:	0009b703          	ld	a4,0(s3)
ffffffffc0200d4a:	068a                	slli	a3,a3,0x2
ffffffffc0200d4c:	757d                	lui	a0,0xfffff
ffffffffc0200d4e:	8ee9                	and	a3,a3,a0
ffffffffc0200d50:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200d54:	04e7f563          	bgeu	a5,a4,ffffffffc0200d9e <get_pte+0x1aa>
ffffffffc0200d58:	000ab503          	ld	a0,0(s5)
ffffffffc0200d5c:	00c95913          	srli	s2,s2,0xc
ffffffffc0200d60:	1ff97913          	andi	s2,s2,511
ffffffffc0200d64:	96aa                	add	a3,a3,a0
ffffffffc0200d66:	00391513          	slli	a0,s2,0x3
ffffffffc0200d6a:	9536                	add	a0,a0,a3
}
ffffffffc0200d6c:	60a6                	ld	ra,72(sp)
ffffffffc0200d6e:	6406                	ld	s0,64(sp)
ffffffffc0200d70:	74e2                	ld	s1,56(sp)
ffffffffc0200d72:	7942                	ld	s2,48(sp)
ffffffffc0200d74:	79a2                	ld	s3,40(sp)
ffffffffc0200d76:	7a02                	ld	s4,32(sp)
ffffffffc0200d78:	6ae2                	ld	s5,24(sp)
ffffffffc0200d7a:	6b42                	ld	s6,16(sp)
ffffffffc0200d7c:	6ba2                	ld	s7,8(sp)
ffffffffc0200d7e:	6161                	addi	sp,sp,80
ffffffffc0200d80:	8082                	ret
            return NULL;
ffffffffc0200d82:	4501                	li	a0,0
ffffffffc0200d84:	b7e5                	j	ffffffffc0200d6c <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200d86:	00004617          	auipc	a2,0x4
ffffffffc0200d8a:	11260613          	addi	a2,a2,274 # ffffffffc0204e98 <commands+0x760>
ffffffffc0200d8e:	10400593          	li	a1,260
ffffffffc0200d92:	00004517          	auipc	a0,0x4
ffffffffc0200d96:	12e50513          	addi	a0,a0,302 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0200d9a:	b68ff0ef          	jal	ra,ffffffffc0200102 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200d9e:	00004617          	auipc	a2,0x4
ffffffffc0200da2:	0fa60613          	addi	a2,a2,250 # ffffffffc0204e98 <commands+0x760>
ffffffffc0200da6:	11100593          	li	a1,273
ffffffffc0200daa:	00004517          	auipc	a0,0x4
ffffffffc0200dae:	11650513          	addi	a0,a0,278 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0200db2:	b50ff0ef          	jal	ra,ffffffffc0200102 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200db6:	86aa                	mv	a3,a0
ffffffffc0200db8:	00004617          	auipc	a2,0x4
ffffffffc0200dbc:	0e060613          	addi	a2,a2,224 # ffffffffc0204e98 <commands+0x760>
ffffffffc0200dc0:	10d00593          	li	a1,269
ffffffffc0200dc4:	00004517          	auipc	a0,0x4
ffffffffc0200dc8:	0fc50513          	addi	a0,a0,252 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0200dcc:	b36ff0ef          	jal	ra,ffffffffc0200102 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200dd0:	86aa                	mv	a3,a0
ffffffffc0200dd2:	00004617          	auipc	a2,0x4
ffffffffc0200dd6:	0c660613          	addi	a2,a2,198 # ffffffffc0204e98 <commands+0x760>
ffffffffc0200dda:	10100593          	li	a1,257
ffffffffc0200dde:	00004517          	auipc	a0,0x4
ffffffffc0200de2:	0e250513          	addi	a0,a0,226 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0200de6:	b1cff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200dea <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200dea:	1141                	addi	sp,sp,-16
ffffffffc0200dec:	e022                	sd	s0,0(sp)
ffffffffc0200dee:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200df0:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200df2:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200df4:	e01ff0ef          	jal	ra,ffffffffc0200bf4 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0200df8:	c011                	beqz	s0,ffffffffc0200dfc <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0200dfa:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200dfc:	c511                	beqz	a0,ffffffffc0200e08 <get_page+0x1e>
ffffffffc0200dfe:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0200e00:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e02:	0017f713          	andi	a4,a5,1
ffffffffc0200e06:	e709                	bnez	a4,ffffffffc0200e10 <get_page+0x26>
}
ffffffffc0200e08:	60a2                	ld	ra,8(sp)
ffffffffc0200e0a:	6402                	ld	s0,0(sp)
ffffffffc0200e0c:	0141                	addi	sp,sp,16
ffffffffc0200e0e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0200e10:	078a                	slli	a5,a5,0x2
ffffffffc0200e12:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200e14:	00010717          	auipc	a4,0x10
ffffffffc0200e18:	70c73703          	ld	a4,1804(a4) # ffffffffc0211520 <npage>
ffffffffc0200e1c:	02e7f263          	bgeu	a5,a4,ffffffffc0200e40 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0200e20:	fff80537          	lui	a0,0xfff80
ffffffffc0200e24:	97aa                	add	a5,a5,a0
ffffffffc0200e26:	60a2                	ld	ra,8(sp)
ffffffffc0200e28:	6402                	ld	s0,0(sp)
ffffffffc0200e2a:	00379513          	slli	a0,a5,0x3
ffffffffc0200e2e:	97aa                	add	a5,a5,a0
ffffffffc0200e30:	078e                	slli	a5,a5,0x3
ffffffffc0200e32:	00010517          	auipc	a0,0x10
ffffffffc0200e36:	6f653503          	ld	a0,1782(a0) # ffffffffc0211528 <pages>
ffffffffc0200e3a:	953e                	add	a0,a0,a5
ffffffffc0200e3c:	0141                	addi	sp,sp,16
ffffffffc0200e3e:	8082                	ret
ffffffffc0200e40:	c71ff0ef          	jal	ra,ffffffffc0200ab0 <pa2page.part.0>

ffffffffc0200e44 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200e44:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e46:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200e48:	ec06                	sd	ra,24(sp)
ffffffffc0200e4a:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e4c:	da9ff0ef          	jal	ra,ffffffffc0200bf4 <get_pte>
    if (ptep != NULL) {
ffffffffc0200e50:	c511                	beqz	a0,ffffffffc0200e5c <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0200e52:	611c                	ld	a5,0(a0)
ffffffffc0200e54:	842a                	mv	s0,a0
ffffffffc0200e56:	0017f713          	andi	a4,a5,1
ffffffffc0200e5a:	e709                	bnez	a4,ffffffffc0200e64 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0200e5c:	60e2                	ld	ra,24(sp)
ffffffffc0200e5e:	6442                	ld	s0,16(sp)
ffffffffc0200e60:	6105                	addi	sp,sp,32
ffffffffc0200e62:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0200e64:	078a                	slli	a5,a5,0x2
ffffffffc0200e66:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200e68:	00010717          	auipc	a4,0x10
ffffffffc0200e6c:	6b873703          	ld	a4,1720(a4) # ffffffffc0211520 <npage>
ffffffffc0200e70:	06e7f563          	bgeu	a5,a4,ffffffffc0200eda <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0200e74:	fff80737          	lui	a4,0xfff80
ffffffffc0200e78:	97ba                	add	a5,a5,a4
ffffffffc0200e7a:	00379513          	slli	a0,a5,0x3
ffffffffc0200e7e:	97aa                	add	a5,a5,a0
ffffffffc0200e80:	078e                	slli	a5,a5,0x3
ffffffffc0200e82:	00010517          	auipc	a0,0x10
ffffffffc0200e86:	6a653503          	ld	a0,1702(a0) # ffffffffc0211528 <pages>
ffffffffc0200e8a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0200e8c:	411c                	lw	a5,0(a0)
ffffffffc0200e8e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200e92:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200e94:	cb09                	beqz	a4,ffffffffc0200ea6 <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200e96:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200e9a:	12000073          	sfence.vma
}
ffffffffc0200e9e:	60e2                	ld	ra,24(sp)
ffffffffc0200ea0:	6442                	ld	s0,16(sp)
ffffffffc0200ea2:	6105                	addi	sp,sp,32
ffffffffc0200ea4:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ea6:	100027f3          	csrr	a5,sstatus
ffffffffc0200eaa:	8b89                	andi	a5,a5,2
ffffffffc0200eac:	eb89                	bnez	a5,ffffffffc0200ebe <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0200eae:	00010797          	auipc	a5,0x10
ffffffffc0200eb2:	6827b783          	ld	a5,1666(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200eb6:	739c                	ld	a5,32(a5)
ffffffffc0200eb8:	4585                	li	a1,1
ffffffffc0200eba:	9782                	jalr	a5
    if (flag) {
ffffffffc0200ebc:	bfe9                	j	ffffffffc0200e96 <page_remove+0x52>
        intr_disable();
ffffffffc0200ebe:	e42a                	sd	a0,8(sp)
ffffffffc0200ec0:	e2eff0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200ec4:	00010797          	auipc	a5,0x10
ffffffffc0200ec8:	66c7b783          	ld	a5,1644(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200ecc:	739c                	ld	a5,32(a5)
ffffffffc0200ece:	6522                	ld	a0,8(sp)
ffffffffc0200ed0:	4585                	li	a1,1
ffffffffc0200ed2:	9782                	jalr	a5
        intr_enable();
ffffffffc0200ed4:	e14ff0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0200ed8:	bf7d                	j	ffffffffc0200e96 <page_remove+0x52>
ffffffffc0200eda:	bd7ff0ef          	jal	ra,ffffffffc0200ab0 <pa2page.part.0>

ffffffffc0200ede <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200ede:	7179                	addi	sp,sp,-48
ffffffffc0200ee0:	87b2                	mv	a5,a2
ffffffffc0200ee2:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200ee4:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200ee6:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200ee8:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200eea:	ec26                	sd	s1,24(sp)
ffffffffc0200eec:	f406                	sd	ra,40(sp)
ffffffffc0200eee:	e84a                	sd	s2,16(sp)
ffffffffc0200ef0:	e44e                	sd	s3,8(sp)
ffffffffc0200ef2:	e052                	sd	s4,0(sp)
ffffffffc0200ef4:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200ef6:	cffff0ef          	jal	ra,ffffffffc0200bf4 <get_pte>
    if (ptep == NULL) {
ffffffffc0200efa:	cd71                	beqz	a0,ffffffffc0200fd6 <page_insert+0xf8>
    page->ref += 1;
ffffffffc0200efc:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0200efe:	611c                	ld	a5,0(a0)
ffffffffc0200f00:	89aa                	mv	s3,a0
ffffffffc0200f02:	0016871b          	addiw	a4,a3,1
ffffffffc0200f06:	c018                	sw	a4,0(s0)
ffffffffc0200f08:	0017f713          	andi	a4,a5,1
ffffffffc0200f0c:	e331                	bnez	a4,ffffffffc0200f50 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200f0e:	00010797          	auipc	a5,0x10
ffffffffc0200f12:	61a7b783          	ld	a5,1562(a5) # ffffffffc0211528 <pages>
ffffffffc0200f16:	40f407b3          	sub	a5,s0,a5
ffffffffc0200f1a:	878d                	srai	a5,a5,0x3
ffffffffc0200f1c:	00005417          	auipc	s0,0x5
ffffffffc0200f20:	46c43403          	ld	s0,1132(s0) # ffffffffc0206388 <error_string+0x38>
ffffffffc0200f24:	028787b3          	mul	a5,a5,s0
ffffffffc0200f28:	00080437          	lui	s0,0x80
ffffffffc0200f2c:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200f2e:	07aa                	slli	a5,a5,0xa
ffffffffc0200f30:	8cdd                	or	s1,s1,a5
ffffffffc0200f32:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0200f36:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200f3a:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0200f3e:	4501                	li	a0,0
}
ffffffffc0200f40:	70a2                	ld	ra,40(sp)
ffffffffc0200f42:	7402                	ld	s0,32(sp)
ffffffffc0200f44:	64e2                	ld	s1,24(sp)
ffffffffc0200f46:	6942                	ld	s2,16(sp)
ffffffffc0200f48:	69a2                	ld	s3,8(sp)
ffffffffc0200f4a:	6a02                	ld	s4,0(sp)
ffffffffc0200f4c:	6145                	addi	sp,sp,48
ffffffffc0200f4e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0200f50:	00279713          	slli	a4,a5,0x2
ffffffffc0200f54:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f56:	00010797          	auipc	a5,0x10
ffffffffc0200f5a:	5ca7b783          	ld	a5,1482(a5) # ffffffffc0211520 <npage>
ffffffffc0200f5e:	06f77e63          	bgeu	a4,a5,ffffffffc0200fda <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f62:	fff807b7          	lui	a5,0xfff80
ffffffffc0200f66:	973e                	add	a4,a4,a5
ffffffffc0200f68:	00010a17          	auipc	s4,0x10
ffffffffc0200f6c:	5c0a0a13          	addi	s4,s4,1472 # ffffffffc0211528 <pages>
ffffffffc0200f70:	000a3783          	ld	a5,0(s4)
ffffffffc0200f74:	00371913          	slli	s2,a4,0x3
ffffffffc0200f78:	993a                	add	s2,s2,a4
ffffffffc0200f7a:	090e                	slli	s2,s2,0x3
ffffffffc0200f7c:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0200f7e:	03240063          	beq	s0,s2,ffffffffc0200f9e <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0200f82:	00092783          	lw	a5,0(s2)
ffffffffc0200f86:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200f8a:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0200f8e:	cb11                	beqz	a4,ffffffffc0200fa2 <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200f90:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200f94:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200f98:	000a3783          	ld	a5,0(s4)
}
ffffffffc0200f9c:	bfad                	j	ffffffffc0200f16 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0200f9e:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0200fa0:	bf9d                	j	ffffffffc0200f16 <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200fa2:	100027f3          	csrr	a5,sstatus
ffffffffc0200fa6:	8b89                	andi	a5,a5,2
ffffffffc0200fa8:	eb91                	bnez	a5,ffffffffc0200fbc <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0200faa:	00010797          	auipc	a5,0x10
ffffffffc0200fae:	5867b783          	ld	a5,1414(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200fb2:	739c                	ld	a5,32(a5)
ffffffffc0200fb4:	4585                	li	a1,1
ffffffffc0200fb6:	854a                	mv	a0,s2
ffffffffc0200fb8:	9782                	jalr	a5
    if (flag) {
ffffffffc0200fba:	bfd9                	j	ffffffffc0200f90 <page_insert+0xb2>
        intr_disable();
ffffffffc0200fbc:	d32ff0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200fc0:	00010797          	auipc	a5,0x10
ffffffffc0200fc4:	5707b783          	ld	a5,1392(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0200fc8:	739c                	ld	a5,32(a5)
ffffffffc0200fca:	4585                	li	a1,1
ffffffffc0200fcc:	854a                	mv	a0,s2
ffffffffc0200fce:	9782                	jalr	a5
        intr_enable();
ffffffffc0200fd0:	d18ff0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0200fd4:	bf75                	j	ffffffffc0200f90 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0200fd6:	5571                	li	a0,-4
ffffffffc0200fd8:	b7a5                	j	ffffffffc0200f40 <page_insert+0x62>
ffffffffc0200fda:	ad7ff0ef          	jal	ra,ffffffffc0200ab0 <pa2page.part.0>

ffffffffc0200fde <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0200fde:	00005797          	auipc	a5,0x5
ffffffffc0200fe2:	f2278793          	addi	a5,a5,-222 # ffffffffc0205f00 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fe6:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0200fe8:	7159                	addi	sp,sp,-112
ffffffffc0200fea:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fec:	00004517          	auipc	a0,0x4
ffffffffc0200ff0:	ee450513          	addi	a0,a0,-284 # ffffffffc0204ed0 <commands+0x798>
    pmm_manager = &default_pmm_manager;
ffffffffc0200ff4:	00010b97          	auipc	s7,0x10
ffffffffc0200ff8:	53cb8b93          	addi	s7,s7,1340 # ffffffffc0211530 <pmm_manager>
void pmm_init(void) {
ffffffffc0200ffc:	f486                	sd	ra,104(sp)
ffffffffc0200ffe:	f0a2                	sd	s0,96(sp)
ffffffffc0201000:	eca6                	sd	s1,88(sp)
ffffffffc0201002:	e8ca                	sd	s2,80(sp)
ffffffffc0201004:	e4ce                	sd	s3,72(sp)
ffffffffc0201006:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201008:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc020100c:	e0d2                	sd	s4,64(sp)
ffffffffc020100e:	fc56                	sd	s5,56(sp)
ffffffffc0201010:	f062                	sd	s8,32(sp)
ffffffffc0201012:	ec66                	sd	s9,24(sp)
ffffffffc0201014:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201016:	8a4ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc020101a:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc020101e:	4445                	li	s0,17
ffffffffc0201020:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0201024:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201026:	00010997          	auipc	s3,0x10
ffffffffc020102a:	51298993          	addi	s3,s3,1298 # ffffffffc0211538 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc020102e:	00010497          	auipc	s1,0x10
ffffffffc0201032:	4f248493          	addi	s1,s1,1266 # ffffffffc0211520 <npage>
    pmm_manager->init();
ffffffffc0201036:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201038:	57f5                	li	a5,-3
ffffffffc020103a:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc020103c:	07e006b7          	lui	a3,0x7e00
ffffffffc0201040:	01b41613          	slli	a2,s0,0x1b
ffffffffc0201044:	01591593          	slli	a1,s2,0x15
ffffffffc0201048:	00004517          	auipc	a0,0x4
ffffffffc020104c:	ea050513          	addi	a0,a0,-352 # ffffffffc0204ee8 <commands+0x7b0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201050:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201054:	866ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201058:	00004517          	auipc	a0,0x4
ffffffffc020105c:	ec050513          	addi	a0,a0,-320 # ffffffffc0204f18 <commands+0x7e0>
ffffffffc0201060:	85aff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201064:	01b41693          	slli	a3,s0,0x1b
ffffffffc0201068:	16fd                	addi	a3,a3,-1
ffffffffc020106a:	07e005b7          	lui	a1,0x7e00
ffffffffc020106e:	01591613          	slli	a2,s2,0x15
ffffffffc0201072:	00004517          	auipc	a0,0x4
ffffffffc0201076:	ebe50513          	addi	a0,a0,-322 # ffffffffc0204f30 <commands+0x7f8>
ffffffffc020107a:	840ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020107e:	777d                	lui	a4,0xfffff
ffffffffc0201080:	00011797          	auipc	a5,0x11
ffffffffc0201084:	4e378793          	addi	a5,a5,1251 # ffffffffc0212563 <end+0xfff>
ffffffffc0201088:	8ff9                	and	a5,a5,a4
ffffffffc020108a:	00010b17          	auipc	s6,0x10
ffffffffc020108e:	49eb0b13          	addi	s6,s6,1182 # ffffffffc0211528 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201092:	00088737          	lui	a4,0x88
ffffffffc0201096:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201098:	00fb3023          	sd	a5,0(s6)
ffffffffc020109c:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020109e:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02010a0:	4505                	li	a0,1
ffffffffc02010a2:	fff805b7          	lui	a1,0xfff80
ffffffffc02010a6:	a019                	j	ffffffffc02010ac <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc02010a8:	000b3783          	ld	a5,0(s6)
ffffffffc02010ac:	97b6                	add	a5,a5,a3
ffffffffc02010ae:	07a1                	addi	a5,a5,8
ffffffffc02010b0:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02010b4:	609c                	ld	a5,0(s1)
ffffffffc02010b6:	0705                	addi	a4,a4,1
ffffffffc02010b8:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc02010bc:	00b78633          	add	a2,a5,a1
ffffffffc02010c0:	fec764e3          	bltu	a4,a2,ffffffffc02010a8 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010c4:	000b3503          	ld	a0,0(s6)
ffffffffc02010c8:	00379693          	slli	a3,a5,0x3
ffffffffc02010cc:	96be                	add	a3,a3,a5
ffffffffc02010ce:	fdc00737          	lui	a4,0xfdc00
ffffffffc02010d2:	972a                	add	a4,a4,a0
ffffffffc02010d4:	068e                	slli	a3,a3,0x3
ffffffffc02010d6:	96ba                	add	a3,a3,a4
ffffffffc02010d8:	c0200737          	lui	a4,0xc0200
ffffffffc02010dc:	64e6e463          	bltu	a3,a4,ffffffffc0201724 <pmm_init+0x746>
ffffffffc02010e0:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc02010e4:	4645                	li	a2,17
ffffffffc02010e6:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010e8:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02010ea:	4ec6e263          	bltu	a3,a2,ffffffffc02015ce <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02010ee:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02010f2:	00010917          	auipc	s2,0x10
ffffffffc02010f6:	42690913          	addi	s2,s2,1062 # ffffffffc0211518 <boot_pgdir>
    pmm_manager->check();
ffffffffc02010fa:	7b9c                	ld	a5,48(a5)
ffffffffc02010fc:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02010fe:	00004517          	auipc	a0,0x4
ffffffffc0201102:	e8250513          	addi	a0,a0,-382 # ffffffffc0204f80 <commands+0x848>
ffffffffc0201106:	fb5fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020110a:	00008697          	auipc	a3,0x8
ffffffffc020110e:	ef668693          	addi	a3,a3,-266 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201112:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201116:	c02007b7          	lui	a5,0xc0200
ffffffffc020111a:	62f6e163          	bltu	a3,a5,ffffffffc020173c <pmm_init+0x75e>
ffffffffc020111e:	0009b783          	ld	a5,0(s3)
ffffffffc0201122:	8e9d                	sub	a3,a3,a5
ffffffffc0201124:	00010797          	auipc	a5,0x10
ffffffffc0201128:	3ed7b623          	sd	a3,1004(a5) # ffffffffc0211510 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020112c:	100027f3          	csrr	a5,sstatus
ffffffffc0201130:	8b89                	andi	a5,a5,2
ffffffffc0201132:	4c079763          	bnez	a5,ffffffffc0201600 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201136:	000bb783          	ld	a5,0(s7)
ffffffffc020113a:	779c                	ld	a5,40(a5)
ffffffffc020113c:	9782                	jalr	a5
ffffffffc020113e:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201140:	6098                	ld	a4,0(s1)
ffffffffc0201142:	c80007b7          	lui	a5,0xc8000
ffffffffc0201146:	83b1                	srli	a5,a5,0xc
ffffffffc0201148:	62e7e663          	bltu	a5,a4,ffffffffc0201774 <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020114c:	00093503          	ld	a0,0(s2)
ffffffffc0201150:	60050263          	beqz	a0,ffffffffc0201754 <pmm_init+0x776>
ffffffffc0201154:	03451793          	slli	a5,a0,0x34
ffffffffc0201158:	5e079e63          	bnez	a5,ffffffffc0201754 <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020115c:	4601                	li	a2,0
ffffffffc020115e:	4581                	li	a1,0
ffffffffc0201160:	c8bff0ef          	jal	ra,ffffffffc0200dea <get_page>
ffffffffc0201164:	66051a63          	bnez	a0,ffffffffc02017d8 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201168:	4505                	li	a0,1
ffffffffc020116a:	97fff0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc020116e:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201170:	00093503          	ld	a0,0(s2)
ffffffffc0201174:	4681                	li	a3,0
ffffffffc0201176:	4601                	li	a2,0
ffffffffc0201178:	85d2                	mv	a1,s4
ffffffffc020117a:	d65ff0ef          	jal	ra,ffffffffc0200ede <page_insert>
ffffffffc020117e:	62051d63          	bnez	a0,ffffffffc02017b8 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201182:	00093503          	ld	a0,0(s2)
ffffffffc0201186:	4601                	li	a2,0
ffffffffc0201188:	4581                	li	a1,0
ffffffffc020118a:	a6bff0ef          	jal	ra,ffffffffc0200bf4 <get_pte>
ffffffffc020118e:	60050563          	beqz	a0,ffffffffc0201798 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0201192:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201194:	0017f713          	andi	a4,a5,1
ffffffffc0201198:	5e070e63          	beqz	a4,ffffffffc0201794 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc020119c:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020119e:	078a                	slli	a5,a5,0x2
ffffffffc02011a0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02011a2:	56c7ff63          	bgeu	a5,a2,ffffffffc0201720 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02011a6:	fff80737          	lui	a4,0xfff80
ffffffffc02011aa:	97ba                	add	a5,a5,a4
ffffffffc02011ac:	000b3683          	ld	a3,0(s6)
ffffffffc02011b0:	00379713          	slli	a4,a5,0x3
ffffffffc02011b4:	97ba                	add	a5,a5,a4
ffffffffc02011b6:	078e                	slli	a5,a5,0x3
ffffffffc02011b8:	97b6                	add	a5,a5,a3
ffffffffc02011ba:	14fa18e3          	bne	s4,a5,ffffffffc0201b0a <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc02011be:	000a2703          	lw	a4,0(s4)
ffffffffc02011c2:	4785                	li	a5,1
ffffffffc02011c4:	16f71fe3          	bne	a4,a5,ffffffffc0201b42 <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02011c8:	00093503          	ld	a0,0(s2)
ffffffffc02011cc:	77fd                	lui	a5,0xfffff
ffffffffc02011ce:	6114                	ld	a3,0(a0)
ffffffffc02011d0:	068a                	slli	a3,a3,0x2
ffffffffc02011d2:	8efd                	and	a3,a3,a5
ffffffffc02011d4:	00c6d713          	srli	a4,a3,0xc
ffffffffc02011d8:	14c779e3          	bgeu	a4,a2,ffffffffc0201b2a <pmm_init+0xb4c>
ffffffffc02011dc:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011e0:	96e2                	add	a3,a3,s8
ffffffffc02011e2:	0006ba83          	ld	s5,0(a3)
ffffffffc02011e6:	0a8a                	slli	s5,s5,0x2
ffffffffc02011e8:	00fafab3          	and	s5,s5,a5
ffffffffc02011ec:	00cad793          	srli	a5,s5,0xc
ffffffffc02011f0:	66c7f463          	bgeu	a5,a2,ffffffffc0201858 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02011f4:	4601                	li	a2,0
ffffffffc02011f6:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011f8:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02011fa:	9fbff0ef          	jal	ra,ffffffffc0200bf4 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011fe:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201200:	63551c63          	bne	a0,s5,ffffffffc0201838 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc0201204:	4505                	li	a0,1
ffffffffc0201206:	8e3ff0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc020120a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020120c:	00093503          	ld	a0,0(s2)
ffffffffc0201210:	46d1                	li	a3,20
ffffffffc0201212:	6605                	lui	a2,0x1
ffffffffc0201214:	85d6                	mv	a1,s5
ffffffffc0201216:	cc9ff0ef          	jal	ra,ffffffffc0200ede <page_insert>
ffffffffc020121a:	5c051f63          	bnez	a0,ffffffffc02017f8 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020121e:	00093503          	ld	a0,0(s2)
ffffffffc0201222:	4601                	li	a2,0
ffffffffc0201224:	6585                	lui	a1,0x1
ffffffffc0201226:	9cfff0ef          	jal	ra,ffffffffc0200bf4 <get_pte>
ffffffffc020122a:	12050ce3          	beqz	a0,ffffffffc0201b62 <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc020122e:	611c                	ld	a5,0(a0)
ffffffffc0201230:	0107f713          	andi	a4,a5,16
ffffffffc0201234:	72070f63          	beqz	a4,ffffffffc0201972 <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0201238:	8b91                	andi	a5,a5,4
ffffffffc020123a:	6e078c63          	beqz	a5,ffffffffc0201932 <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020123e:	00093503          	ld	a0,0(s2)
ffffffffc0201242:	611c                	ld	a5,0(a0)
ffffffffc0201244:	8bc1                	andi	a5,a5,16
ffffffffc0201246:	6c078663          	beqz	a5,ffffffffc0201912 <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc020124a:	000aa703          	lw	a4,0(s5)
ffffffffc020124e:	4785                	li	a5,1
ffffffffc0201250:	5cf71463          	bne	a4,a5,ffffffffc0201818 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201254:	4681                	li	a3,0
ffffffffc0201256:	6605                	lui	a2,0x1
ffffffffc0201258:	85d2                	mv	a1,s4
ffffffffc020125a:	c85ff0ef          	jal	ra,ffffffffc0200ede <page_insert>
ffffffffc020125e:	66051a63          	bnez	a0,ffffffffc02018d2 <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc0201262:	000a2703          	lw	a4,0(s4)
ffffffffc0201266:	4789                	li	a5,2
ffffffffc0201268:	64f71563          	bne	a4,a5,ffffffffc02018b2 <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc020126c:	000aa783          	lw	a5,0(s5)
ffffffffc0201270:	62079163          	bnez	a5,ffffffffc0201892 <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201274:	00093503          	ld	a0,0(s2)
ffffffffc0201278:	4601                	li	a2,0
ffffffffc020127a:	6585                	lui	a1,0x1
ffffffffc020127c:	979ff0ef          	jal	ra,ffffffffc0200bf4 <get_pte>
ffffffffc0201280:	5e050963          	beqz	a0,ffffffffc0201872 <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc0201284:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201286:	00177793          	andi	a5,a4,1
ffffffffc020128a:	50078563          	beqz	a5,ffffffffc0201794 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc020128e:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201290:	00271793          	slli	a5,a4,0x2
ffffffffc0201294:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201296:	48d7f563          	bgeu	a5,a3,ffffffffc0201720 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020129a:	fff806b7          	lui	a3,0xfff80
ffffffffc020129e:	97b6                	add	a5,a5,a3
ffffffffc02012a0:	000b3603          	ld	a2,0(s6)
ffffffffc02012a4:	00379693          	slli	a3,a5,0x3
ffffffffc02012a8:	97b6                	add	a5,a5,a3
ffffffffc02012aa:	078e                	slli	a5,a5,0x3
ffffffffc02012ac:	97b2                	add	a5,a5,a2
ffffffffc02012ae:	72fa1263          	bne	s4,a5,ffffffffc02019d2 <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc02012b2:	8b41                	andi	a4,a4,16
ffffffffc02012b4:	6e071f63          	bnez	a4,ffffffffc02019b2 <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc02012b8:	00093503          	ld	a0,0(s2)
ffffffffc02012bc:	4581                	li	a1,0
ffffffffc02012be:	b87ff0ef          	jal	ra,ffffffffc0200e44 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02012c2:	000a2703          	lw	a4,0(s4)
ffffffffc02012c6:	4785                	li	a5,1
ffffffffc02012c8:	6cf71563          	bne	a4,a5,ffffffffc0201992 <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc02012cc:	000aa783          	lw	a5,0(s5)
ffffffffc02012d0:	78079d63          	bnez	a5,ffffffffc0201a6a <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02012d4:	00093503          	ld	a0,0(s2)
ffffffffc02012d8:	6585                	lui	a1,0x1
ffffffffc02012da:	b6bff0ef          	jal	ra,ffffffffc0200e44 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02012de:	000a2783          	lw	a5,0(s4)
ffffffffc02012e2:	76079463          	bnez	a5,ffffffffc0201a4a <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc02012e6:	000aa783          	lw	a5,0(s5)
ffffffffc02012ea:	74079063          	bnez	a5,ffffffffc0201a2a <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02012ee:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02012f2:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02012f4:	000a3783          	ld	a5,0(s4)
ffffffffc02012f8:	078a                	slli	a5,a5,0x2
ffffffffc02012fa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012fc:	42c7f263          	bgeu	a5,a2,ffffffffc0201720 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201300:	fff80737          	lui	a4,0xfff80
ffffffffc0201304:	973e                	add	a4,a4,a5
ffffffffc0201306:	00371793          	slli	a5,a4,0x3
ffffffffc020130a:	000b3503          	ld	a0,0(s6)
ffffffffc020130e:	97ba                	add	a5,a5,a4
ffffffffc0201310:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201312:	00f50733          	add	a4,a0,a5
ffffffffc0201316:	4314                	lw	a3,0(a4)
ffffffffc0201318:	4705                	li	a4,1
ffffffffc020131a:	6ee69863          	bne	a3,a4,ffffffffc0201a0a <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020131e:	4037d693          	srai	a3,a5,0x3
ffffffffc0201322:	00005c97          	auipc	s9,0x5
ffffffffc0201326:	066cbc83          	ld	s9,102(s9) # ffffffffc0206388 <error_string+0x38>
ffffffffc020132a:	039686b3          	mul	a3,a3,s9
ffffffffc020132e:	000805b7          	lui	a1,0x80
ffffffffc0201332:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201334:	00c69713          	slli	a4,a3,0xc
ffffffffc0201338:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020133a:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020133c:	6ac77b63          	bgeu	a4,a2,ffffffffc02019f2 <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201340:	0009b703          	ld	a4,0(s3)
ffffffffc0201344:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201346:	629c                	ld	a5,0(a3)
ffffffffc0201348:	078a                	slli	a5,a5,0x2
ffffffffc020134a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020134c:	3cc7fa63          	bgeu	a5,a2,ffffffffc0201720 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201350:	8f8d                	sub	a5,a5,a1
ffffffffc0201352:	00379713          	slli	a4,a5,0x3
ffffffffc0201356:	97ba                	add	a5,a5,a4
ffffffffc0201358:	078e                	slli	a5,a5,0x3
ffffffffc020135a:	953e                	add	a0,a0,a5
ffffffffc020135c:	100027f3          	csrr	a5,sstatus
ffffffffc0201360:	8b89                	andi	a5,a5,2
ffffffffc0201362:	2e079963          	bnez	a5,ffffffffc0201654 <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201366:	000bb783          	ld	a5,0(s7)
ffffffffc020136a:	4585                	li	a1,1
ffffffffc020136c:	739c                	ld	a5,32(a5)
ffffffffc020136e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201370:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201374:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201376:	078a                	slli	a5,a5,0x2
ffffffffc0201378:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020137a:	3ae7f363          	bgeu	a5,a4,ffffffffc0201720 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020137e:	fff80737          	lui	a4,0xfff80
ffffffffc0201382:	97ba                	add	a5,a5,a4
ffffffffc0201384:	000b3503          	ld	a0,0(s6)
ffffffffc0201388:	00379713          	slli	a4,a5,0x3
ffffffffc020138c:	97ba                	add	a5,a5,a4
ffffffffc020138e:	078e                	slli	a5,a5,0x3
ffffffffc0201390:	953e                	add	a0,a0,a5
ffffffffc0201392:	100027f3          	csrr	a5,sstatus
ffffffffc0201396:	8b89                	andi	a5,a5,2
ffffffffc0201398:	2a079263          	bnez	a5,ffffffffc020163c <pmm_init+0x65e>
ffffffffc020139c:	000bb783          	ld	a5,0(s7)
ffffffffc02013a0:	4585                	li	a1,1
ffffffffc02013a2:	739c                	ld	a5,32(a5)
ffffffffc02013a4:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02013a6:	00093783          	ld	a5,0(s2)
ffffffffc02013aa:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda9c>
ffffffffc02013ae:	100027f3          	csrr	a5,sstatus
ffffffffc02013b2:	8b89                	andi	a5,a5,2
ffffffffc02013b4:	26079a63          	bnez	a5,ffffffffc0201628 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02013b8:	000bb783          	ld	a5,0(s7)
ffffffffc02013bc:	779c                	ld	a5,40(a5)
ffffffffc02013be:	9782                	jalr	a5
ffffffffc02013c0:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02013c2:	73441463          	bne	s0,s4,ffffffffc0201aea <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02013c6:	00004517          	auipc	a0,0x4
ffffffffc02013ca:	eba50513          	addi	a0,a0,-326 # ffffffffc0205280 <commands+0xb48>
ffffffffc02013ce:	cedfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02013d2:	100027f3          	csrr	a5,sstatus
ffffffffc02013d6:	8b89                	andi	a5,a5,2
ffffffffc02013d8:	22079e63          	bnez	a5,ffffffffc0201614 <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02013dc:	000bb783          	ld	a5,0(s7)
ffffffffc02013e0:	779c                	ld	a5,40(a5)
ffffffffc02013e2:	9782                	jalr	a5
ffffffffc02013e4:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013e6:	6098                	ld	a4,0(s1)
ffffffffc02013e8:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02013ec:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013ee:	00c71793          	slli	a5,a4,0xc
ffffffffc02013f2:	6a05                	lui	s4,0x1
ffffffffc02013f4:	02f47c63          	bgeu	s0,a5,ffffffffc020142c <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02013f8:	00c45793          	srli	a5,s0,0xc
ffffffffc02013fc:	00093503          	ld	a0,0(s2)
ffffffffc0201400:	30e7f363          	bgeu	a5,a4,ffffffffc0201706 <pmm_init+0x728>
ffffffffc0201404:	0009b583          	ld	a1,0(s3)
ffffffffc0201408:	4601                	li	a2,0
ffffffffc020140a:	95a2                	add	a1,a1,s0
ffffffffc020140c:	fe8ff0ef          	jal	ra,ffffffffc0200bf4 <get_pte>
ffffffffc0201410:	2c050b63          	beqz	a0,ffffffffc02016e6 <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201414:	611c                	ld	a5,0(a0)
ffffffffc0201416:	078a                	slli	a5,a5,0x2
ffffffffc0201418:	0157f7b3          	and	a5,a5,s5
ffffffffc020141c:	2a879563          	bne	a5,s0,ffffffffc02016c6 <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201420:	6098                	ld	a4,0(s1)
ffffffffc0201422:	9452                	add	s0,s0,s4
ffffffffc0201424:	00c71793          	slli	a5,a4,0xc
ffffffffc0201428:	fcf468e3          	bltu	s0,a5,ffffffffc02013f8 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc020142c:	00093783          	ld	a5,0(s2)
ffffffffc0201430:	639c                	ld	a5,0(a5)
ffffffffc0201432:	68079c63          	bnez	a5,ffffffffc0201aca <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0201436:	4505                	li	a0,1
ffffffffc0201438:	eb0ff0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc020143c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020143e:	00093503          	ld	a0,0(s2)
ffffffffc0201442:	4699                	li	a3,6
ffffffffc0201444:	10000613          	li	a2,256
ffffffffc0201448:	85d6                	mv	a1,s5
ffffffffc020144a:	a95ff0ef          	jal	ra,ffffffffc0200ede <page_insert>
ffffffffc020144e:	64051e63          	bnez	a0,ffffffffc0201aaa <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0201452:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda9c>
ffffffffc0201456:	4785                	li	a5,1
ffffffffc0201458:	62f71963          	bne	a4,a5,ffffffffc0201a8a <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020145c:	00093503          	ld	a0,0(s2)
ffffffffc0201460:	6405                	lui	s0,0x1
ffffffffc0201462:	4699                	li	a3,6
ffffffffc0201464:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201468:	85d6                	mv	a1,s5
ffffffffc020146a:	a75ff0ef          	jal	ra,ffffffffc0200ede <page_insert>
ffffffffc020146e:	48051263          	bnez	a0,ffffffffc02018f2 <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0201472:	000aa703          	lw	a4,0(s5)
ffffffffc0201476:	4789                	li	a5,2
ffffffffc0201478:	74f71563          	bne	a4,a5,ffffffffc0201bc2 <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020147c:	00004597          	auipc	a1,0x4
ffffffffc0201480:	f3c58593          	addi	a1,a1,-196 # ffffffffc02053b8 <commands+0xc80>
ffffffffc0201484:	10000513          	li	a0,256
ffffffffc0201488:	321020ef          	jal	ra,ffffffffc0203fa8 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020148c:	10040593          	addi	a1,s0,256
ffffffffc0201490:	10000513          	li	a0,256
ffffffffc0201494:	327020ef          	jal	ra,ffffffffc0203fba <strcmp>
ffffffffc0201498:	70051563          	bnez	a0,ffffffffc0201ba2 <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020149c:	000b3683          	ld	a3,0(s6)
ffffffffc02014a0:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02014a4:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02014a6:	40da86b3          	sub	a3,s5,a3
ffffffffc02014aa:	868d                	srai	a3,a3,0x3
ffffffffc02014ac:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02014b0:	609c                	ld	a5,0(s1)
ffffffffc02014b2:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02014b4:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02014b6:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02014ba:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02014bc:	52f77b63          	bgeu	a4,a5,ffffffffc02019f2 <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02014c0:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02014c4:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02014c8:	96be                	add	a3,a3,a5
ffffffffc02014ca:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb9c>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02014ce:	2a5020ef          	jal	ra,ffffffffc0203f72 <strlen>
ffffffffc02014d2:	6a051863          	bnez	a0,ffffffffc0201b82 <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02014d6:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02014da:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014dc:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02014e0:	078a                	slli	a5,a5,0x2
ffffffffc02014e2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014e4:	22e7fe63          	bgeu	a5,a4,ffffffffc0201720 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02014e8:	41a787b3          	sub	a5,a5,s10
ffffffffc02014ec:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02014f0:	96be                	add	a3,a3,a5
ffffffffc02014f2:	03968cb3          	mul	s9,a3,s9
ffffffffc02014f6:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02014fa:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02014fc:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02014fe:	4ee47a63          	bgeu	s0,a4,ffffffffc02019f2 <pmm_init+0xa14>
ffffffffc0201502:	0009b403          	ld	s0,0(s3)
ffffffffc0201506:	9436                	add	s0,s0,a3
ffffffffc0201508:	100027f3          	csrr	a5,sstatus
ffffffffc020150c:	8b89                	andi	a5,a5,2
ffffffffc020150e:	1a079163          	bnez	a5,ffffffffc02016b0 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201512:	000bb783          	ld	a5,0(s7)
ffffffffc0201516:	4585                	li	a1,1
ffffffffc0201518:	8556                	mv	a0,s5
ffffffffc020151a:	739c                	ld	a5,32(a5)
ffffffffc020151c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020151e:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201520:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201522:	078a                	slli	a5,a5,0x2
ffffffffc0201524:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201526:	1ee7fd63          	bgeu	a5,a4,ffffffffc0201720 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020152a:	fff80737          	lui	a4,0xfff80
ffffffffc020152e:	97ba                	add	a5,a5,a4
ffffffffc0201530:	000b3503          	ld	a0,0(s6)
ffffffffc0201534:	00379713          	slli	a4,a5,0x3
ffffffffc0201538:	97ba                	add	a5,a5,a4
ffffffffc020153a:	078e                	slli	a5,a5,0x3
ffffffffc020153c:	953e                	add	a0,a0,a5
ffffffffc020153e:	100027f3          	csrr	a5,sstatus
ffffffffc0201542:	8b89                	andi	a5,a5,2
ffffffffc0201544:	14079a63          	bnez	a5,ffffffffc0201698 <pmm_init+0x6ba>
ffffffffc0201548:	000bb783          	ld	a5,0(s7)
ffffffffc020154c:	4585                	li	a1,1
ffffffffc020154e:	739c                	ld	a5,32(a5)
ffffffffc0201550:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201552:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201556:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201558:	078a                	slli	a5,a5,0x2
ffffffffc020155a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020155c:	1ce7f263          	bgeu	a5,a4,ffffffffc0201720 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201560:	fff80737          	lui	a4,0xfff80
ffffffffc0201564:	97ba                	add	a5,a5,a4
ffffffffc0201566:	000b3503          	ld	a0,0(s6)
ffffffffc020156a:	00379713          	slli	a4,a5,0x3
ffffffffc020156e:	97ba                	add	a5,a5,a4
ffffffffc0201570:	078e                	slli	a5,a5,0x3
ffffffffc0201572:	953e                	add	a0,a0,a5
ffffffffc0201574:	100027f3          	csrr	a5,sstatus
ffffffffc0201578:	8b89                	andi	a5,a5,2
ffffffffc020157a:	10079363          	bnez	a5,ffffffffc0201680 <pmm_init+0x6a2>
ffffffffc020157e:	000bb783          	ld	a5,0(s7)
ffffffffc0201582:	4585                	li	a1,1
ffffffffc0201584:	739c                	ld	a5,32(a5)
ffffffffc0201586:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201588:	00093783          	ld	a5,0(s2)
ffffffffc020158c:	0007b023          	sd	zero,0(a5)
ffffffffc0201590:	100027f3          	csrr	a5,sstatus
ffffffffc0201594:	8b89                	andi	a5,a5,2
ffffffffc0201596:	0c079b63          	bnez	a5,ffffffffc020166c <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020159a:	000bb783          	ld	a5,0(s7)
ffffffffc020159e:	779c                	ld	a5,40(a5)
ffffffffc02015a0:	9782                	jalr	a5
ffffffffc02015a2:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02015a4:	3a8c1763          	bne	s8,s0,ffffffffc0201952 <pmm_init+0x974>
}
ffffffffc02015a8:	7406                	ld	s0,96(sp)
ffffffffc02015aa:	70a6                	ld	ra,104(sp)
ffffffffc02015ac:	64e6                	ld	s1,88(sp)
ffffffffc02015ae:	6946                	ld	s2,80(sp)
ffffffffc02015b0:	69a6                	ld	s3,72(sp)
ffffffffc02015b2:	6a06                	ld	s4,64(sp)
ffffffffc02015b4:	7ae2                	ld	s5,56(sp)
ffffffffc02015b6:	7b42                	ld	s6,48(sp)
ffffffffc02015b8:	7ba2                	ld	s7,40(sp)
ffffffffc02015ba:	7c02                	ld	s8,32(sp)
ffffffffc02015bc:	6ce2                	ld	s9,24(sp)
ffffffffc02015be:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02015c0:	00004517          	auipc	a0,0x4
ffffffffc02015c4:	e7050513          	addi	a0,a0,-400 # ffffffffc0205430 <commands+0xcf8>
}
ffffffffc02015c8:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02015ca:	af1fe06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02015ce:	6705                	lui	a4,0x1
ffffffffc02015d0:	177d                	addi	a4,a4,-1
ffffffffc02015d2:	96ba                	add	a3,a3,a4
ffffffffc02015d4:	777d                	lui	a4,0xfffff
ffffffffc02015d6:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc02015d8:	00c75693          	srli	a3,a4,0xc
ffffffffc02015dc:	14f6f263          	bgeu	a3,a5,ffffffffc0201720 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc02015e0:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02015e4:	95b6                	add	a1,a1,a3
ffffffffc02015e6:	00359793          	slli	a5,a1,0x3
ffffffffc02015ea:	97ae                	add	a5,a5,a1
ffffffffc02015ec:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02015f0:	40e60733          	sub	a4,a2,a4
ffffffffc02015f4:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02015f6:	00c75593          	srli	a1,a4,0xc
ffffffffc02015fa:	953e                	add	a0,a0,a5
ffffffffc02015fc:	9682                	jalr	a3
}
ffffffffc02015fe:	bcc5                	j	ffffffffc02010ee <pmm_init+0x110>
        intr_disable();
ffffffffc0201600:	eeffe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201604:	000bb783          	ld	a5,0(s7)
ffffffffc0201608:	779c                	ld	a5,40(a5)
ffffffffc020160a:	9782                	jalr	a5
ffffffffc020160c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020160e:	edbfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201612:	b63d                	j	ffffffffc0201140 <pmm_init+0x162>
        intr_disable();
ffffffffc0201614:	edbfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201618:	000bb783          	ld	a5,0(s7)
ffffffffc020161c:	779c                	ld	a5,40(a5)
ffffffffc020161e:	9782                	jalr	a5
ffffffffc0201620:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0201622:	ec7fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201626:	b3c1                	j	ffffffffc02013e6 <pmm_init+0x408>
        intr_disable();
ffffffffc0201628:	ec7fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020162c:	000bb783          	ld	a5,0(s7)
ffffffffc0201630:	779c                	ld	a5,40(a5)
ffffffffc0201632:	9782                	jalr	a5
ffffffffc0201634:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0201636:	eb3fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020163a:	b361                	j	ffffffffc02013c2 <pmm_init+0x3e4>
ffffffffc020163c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020163e:	eb1fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201642:	000bb783          	ld	a5,0(s7)
ffffffffc0201646:	6522                	ld	a0,8(sp)
ffffffffc0201648:	4585                	li	a1,1
ffffffffc020164a:	739c                	ld	a5,32(a5)
ffffffffc020164c:	9782                	jalr	a5
        intr_enable();
ffffffffc020164e:	e9bfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201652:	bb91                	j	ffffffffc02013a6 <pmm_init+0x3c8>
ffffffffc0201654:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201656:	e99fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020165a:	000bb783          	ld	a5,0(s7)
ffffffffc020165e:	6522                	ld	a0,8(sp)
ffffffffc0201660:	4585                	li	a1,1
ffffffffc0201662:	739c                	ld	a5,32(a5)
ffffffffc0201664:	9782                	jalr	a5
        intr_enable();
ffffffffc0201666:	e83fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020166a:	b319                	j	ffffffffc0201370 <pmm_init+0x392>
        intr_disable();
ffffffffc020166c:	e83fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201670:	000bb783          	ld	a5,0(s7)
ffffffffc0201674:	779c                	ld	a5,40(a5)
ffffffffc0201676:	9782                	jalr	a5
ffffffffc0201678:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020167a:	e6ffe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020167e:	b71d                	j	ffffffffc02015a4 <pmm_init+0x5c6>
ffffffffc0201680:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201682:	e6dfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201686:	000bb783          	ld	a5,0(s7)
ffffffffc020168a:	6522                	ld	a0,8(sp)
ffffffffc020168c:	4585                	li	a1,1
ffffffffc020168e:	739c                	ld	a5,32(a5)
ffffffffc0201690:	9782                	jalr	a5
        intr_enable();
ffffffffc0201692:	e57fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201696:	bdcd                	j	ffffffffc0201588 <pmm_init+0x5aa>
ffffffffc0201698:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020169a:	e55fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020169e:	000bb783          	ld	a5,0(s7)
ffffffffc02016a2:	6522                	ld	a0,8(sp)
ffffffffc02016a4:	4585                	li	a1,1
ffffffffc02016a6:	739c                	ld	a5,32(a5)
ffffffffc02016a8:	9782                	jalr	a5
        intr_enable();
ffffffffc02016aa:	e3ffe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02016ae:	b555                	j	ffffffffc0201552 <pmm_init+0x574>
        intr_disable();
ffffffffc02016b0:	e3ffe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02016b4:	000bb783          	ld	a5,0(s7)
ffffffffc02016b8:	4585                	li	a1,1
ffffffffc02016ba:	8556                	mv	a0,s5
ffffffffc02016bc:	739c                	ld	a5,32(a5)
ffffffffc02016be:	9782                	jalr	a5
        intr_enable();
ffffffffc02016c0:	e29fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02016c4:	bda9                	j	ffffffffc020151e <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02016c6:	00004697          	auipc	a3,0x4
ffffffffc02016ca:	c1a68693          	addi	a3,a3,-998 # ffffffffc02052e0 <commands+0xba8>
ffffffffc02016ce:	00004617          	auipc	a2,0x4
ffffffffc02016d2:	8f260613          	addi	a2,a2,-1806 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02016d6:	1d000593          	li	a1,464
ffffffffc02016da:	00003517          	auipc	a0,0x3
ffffffffc02016de:	7e650513          	addi	a0,a0,2022 # ffffffffc0204ec0 <commands+0x788>
ffffffffc02016e2:	a21fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02016e6:	00004697          	auipc	a3,0x4
ffffffffc02016ea:	bba68693          	addi	a3,a3,-1094 # ffffffffc02052a0 <commands+0xb68>
ffffffffc02016ee:	00004617          	auipc	a2,0x4
ffffffffc02016f2:	8d260613          	addi	a2,a2,-1838 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02016f6:	1cf00593          	li	a1,463
ffffffffc02016fa:	00003517          	auipc	a0,0x3
ffffffffc02016fe:	7c650513          	addi	a0,a0,1990 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201702:	a01fe0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0201706:	86a2                	mv	a3,s0
ffffffffc0201708:	00003617          	auipc	a2,0x3
ffffffffc020170c:	79060613          	addi	a2,a2,1936 # ffffffffc0204e98 <commands+0x760>
ffffffffc0201710:	1cf00593          	li	a1,463
ffffffffc0201714:	00003517          	auipc	a0,0x3
ffffffffc0201718:	7ac50513          	addi	a0,a0,1964 # ffffffffc0204ec0 <commands+0x788>
ffffffffc020171c:	9e7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0201720:	b90ff0ef          	jal	ra,ffffffffc0200ab0 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201724:	00004617          	auipc	a2,0x4
ffffffffc0201728:	83460613          	addi	a2,a2,-1996 # ffffffffc0204f58 <commands+0x820>
ffffffffc020172c:	07900593          	li	a1,121
ffffffffc0201730:	00003517          	auipc	a0,0x3
ffffffffc0201734:	79050513          	addi	a0,a0,1936 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201738:	9cbfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020173c:	00004617          	auipc	a2,0x4
ffffffffc0201740:	81c60613          	addi	a2,a2,-2020 # ffffffffc0204f58 <commands+0x820>
ffffffffc0201744:	0bf00593          	li	a1,191
ffffffffc0201748:	00003517          	auipc	a0,0x3
ffffffffc020174c:	77850513          	addi	a0,a0,1912 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201750:	9b3fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201754:	00004697          	auipc	a3,0x4
ffffffffc0201758:	88468693          	addi	a3,a3,-1916 # ffffffffc0204fd8 <commands+0x8a0>
ffffffffc020175c:	00004617          	auipc	a2,0x4
ffffffffc0201760:	86460613          	addi	a2,a2,-1948 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201764:	19500593          	li	a1,405
ffffffffc0201768:	00003517          	auipc	a0,0x3
ffffffffc020176c:	75850513          	addi	a0,a0,1880 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201770:	993fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201774:	00004697          	auipc	a3,0x4
ffffffffc0201778:	82c68693          	addi	a3,a3,-2004 # ffffffffc0204fa0 <commands+0x868>
ffffffffc020177c:	00004617          	auipc	a2,0x4
ffffffffc0201780:	84460613          	addi	a2,a2,-1980 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201784:	19400593          	li	a1,404
ffffffffc0201788:	00003517          	auipc	a0,0x3
ffffffffc020178c:	73850513          	addi	a0,a0,1848 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201790:	973fe0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0201794:	b38ff0ef          	jal	ra,ffffffffc0200acc <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201798:	00004697          	auipc	a3,0x4
ffffffffc020179c:	8d068693          	addi	a3,a3,-1840 # ffffffffc0205068 <commands+0x930>
ffffffffc02017a0:	00004617          	auipc	a2,0x4
ffffffffc02017a4:	82060613          	addi	a2,a2,-2016 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02017a8:	19c00593          	li	a1,412
ffffffffc02017ac:	00003517          	auipc	a0,0x3
ffffffffc02017b0:	71450513          	addi	a0,a0,1812 # ffffffffc0204ec0 <commands+0x788>
ffffffffc02017b4:	94ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02017b8:	00004697          	auipc	a3,0x4
ffffffffc02017bc:	88068693          	addi	a3,a3,-1920 # ffffffffc0205038 <commands+0x900>
ffffffffc02017c0:	00004617          	auipc	a2,0x4
ffffffffc02017c4:	80060613          	addi	a2,a2,-2048 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02017c8:	19a00593          	li	a1,410
ffffffffc02017cc:	00003517          	auipc	a0,0x3
ffffffffc02017d0:	6f450513          	addi	a0,a0,1780 # ffffffffc0204ec0 <commands+0x788>
ffffffffc02017d4:	92ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02017d8:	00004697          	auipc	a3,0x4
ffffffffc02017dc:	83868693          	addi	a3,a3,-1992 # ffffffffc0205010 <commands+0x8d8>
ffffffffc02017e0:	00003617          	auipc	a2,0x3
ffffffffc02017e4:	7e060613          	addi	a2,a2,2016 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02017e8:	19600593          	li	a1,406
ffffffffc02017ec:	00003517          	auipc	a0,0x3
ffffffffc02017f0:	6d450513          	addi	a0,a0,1748 # ffffffffc0204ec0 <commands+0x788>
ffffffffc02017f4:	90ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02017f8:	00004697          	auipc	a3,0x4
ffffffffc02017fc:	8f868693          	addi	a3,a3,-1800 # ffffffffc02050f0 <commands+0x9b8>
ffffffffc0201800:	00003617          	auipc	a2,0x3
ffffffffc0201804:	7c060613          	addi	a2,a2,1984 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201808:	1a500593          	li	a1,421
ffffffffc020180c:	00003517          	auipc	a0,0x3
ffffffffc0201810:	6b450513          	addi	a0,a0,1716 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201814:	8effe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201818:	00004697          	auipc	a3,0x4
ffffffffc020181c:	97868693          	addi	a3,a3,-1672 # ffffffffc0205190 <commands+0xa58>
ffffffffc0201820:	00003617          	auipc	a2,0x3
ffffffffc0201824:	7a060613          	addi	a2,a2,1952 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201828:	1aa00593          	li	a1,426
ffffffffc020182c:	00003517          	auipc	a0,0x3
ffffffffc0201830:	69450513          	addi	a0,a0,1684 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201834:	8cffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201838:	00004697          	auipc	a3,0x4
ffffffffc020183c:	89068693          	addi	a3,a3,-1904 # ffffffffc02050c8 <commands+0x990>
ffffffffc0201840:	00003617          	auipc	a2,0x3
ffffffffc0201844:	78060613          	addi	a2,a2,1920 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201848:	1a200593          	li	a1,418
ffffffffc020184c:	00003517          	auipc	a0,0x3
ffffffffc0201850:	67450513          	addi	a0,a0,1652 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201854:	8affe0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201858:	86d6                	mv	a3,s5
ffffffffc020185a:	00003617          	auipc	a2,0x3
ffffffffc020185e:	63e60613          	addi	a2,a2,1598 # ffffffffc0204e98 <commands+0x760>
ffffffffc0201862:	1a100593          	li	a1,417
ffffffffc0201866:	00003517          	auipc	a0,0x3
ffffffffc020186a:	65a50513          	addi	a0,a0,1626 # ffffffffc0204ec0 <commands+0x788>
ffffffffc020186e:	895fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201872:	00004697          	auipc	a3,0x4
ffffffffc0201876:	8b668693          	addi	a3,a3,-1866 # ffffffffc0205128 <commands+0x9f0>
ffffffffc020187a:	00003617          	auipc	a2,0x3
ffffffffc020187e:	74660613          	addi	a2,a2,1862 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201882:	1af00593          	li	a1,431
ffffffffc0201886:	00003517          	auipc	a0,0x3
ffffffffc020188a:	63a50513          	addi	a0,a0,1594 # ffffffffc0204ec0 <commands+0x788>
ffffffffc020188e:	875fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201892:	00004697          	auipc	a3,0x4
ffffffffc0201896:	95e68693          	addi	a3,a3,-1698 # ffffffffc02051f0 <commands+0xab8>
ffffffffc020189a:	00003617          	auipc	a2,0x3
ffffffffc020189e:	72660613          	addi	a2,a2,1830 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02018a2:	1ae00593          	li	a1,430
ffffffffc02018a6:	00003517          	auipc	a0,0x3
ffffffffc02018aa:	61a50513          	addi	a0,a0,1562 # ffffffffc0204ec0 <commands+0x788>
ffffffffc02018ae:	855fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02018b2:	00004697          	auipc	a3,0x4
ffffffffc02018b6:	92668693          	addi	a3,a3,-1754 # ffffffffc02051d8 <commands+0xaa0>
ffffffffc02018ba:	00003617          	auipc	a2,0x3
ffffffffc02018be:	70660613          	addi	a2,a2,1798 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02018c2:	1ad00593          	li	a1,429
ffffffffc02018c6:	00003517          	auipc	a0,0x3
ffffffffc02018ca:	5fa50513          	addi	a0,a0,1530 # ffffffffc0204ec0 <commands+0x788>
ffffffffc02018ce:	835fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02018d2:	00004697          	auipc	a3,0x4
ffffffffc02018d6:	8d668693          	addi	a3,a3,-1834 # ffffffffc02051a8 <commands+0xa70>
ffffffffc02018da:	00003617          	auipc	a2,0x3
ffffffffc02018de:	6e660613          	addi	a2,a2,1766 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02018e2:	1ac00593          	li	a1,428
ffffffffc02018e6:	00003517          	auipc	a0,0x3
ffffffffc02018ea:	5da50513          	addi	a0,a0,1498 # ffffffffc0204ec0 <commands+0x788>
ffffffffc02018ee:	815fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02018f2:	00004697          	auipc	a3,0x4
ffffffffc02018f6:	a6e68693          	addi	a3,a3,-1426 # ffffffffc0205360 <commands+0xc28>
ffffffffc02018fa:	00003617          	auipc	a2,0x3
ffffffffc02018fe:	6c660613          	addi	a2,a2,1734 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201902:	1da00593          	li	a1,474
ffffffffc0201906:	00003517          	auipc	a0,0x3
ffffffffc020190a:	5ba50513          	addi	a0,a0,1466 # ffffffffc0204ec0 <commands+0x788>
ffffffffc020190e:	ff4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201912:	00004697          	auipc	a3,0x4
ffffffffc0201916:	86668693          	addi	a3,a3,-1946 # ffffffffc0205178 <commands+0xa40>
ffffffffc020191a:	00003617          	auipc	a2,0x3
ffffffffc020191e:	6a660613          	addi	a2,a2,1702 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201922:	1a900593          	li	a1,425
ffffffffc0201926:	00003517          	auipc	a0,0x3
ffffffffc020192a:	59a50513          	addi	a0,a0,1434 # ffffffffc0204ec0 <commands+0x788>
ffffffffc020192e:	fd4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201932:	00004697          	auipc	a3,0x4
ffffffffc0201936:	83668693          	addi	a3,a3,-1994 # ffffffffc0205168 <commands+0xa30>
ffffffffc020193a:	00003617          	auipc	a2,0x3
ffffffffc020193e:	68660613          	addi	a2,a2,1670 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201942:	1a800593          	li	a1,424
ffffffffc0201946:	00003517          	auipc	a0,0x3
ffffffffc020194a:	57a50513          	addi	a0,a0,1402 # ffffffffc0204ec0 <commands+0x788>
ffffffffc020194e:	fb4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201952:	00004697          	auipc	a3,0x4
ffffffffc0201956:	90e68693          	addi	a3,a3,-1778 # ffffffffc0205260 <commands+0xb28>
ffffffffc020195a:	00003617          	auipc	a2,0x3
ffffffffc020195e:	66660613          	addi	a2,a2,1638 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201962:	1ea00593          	li	a1,490
ffffffffc0201966:	00003517          	auipc	a0,0x3
ffffffffc020196a:	55a50513          	addi	a0,a0,1370 # ffffffffc0204ec0 <commands+0x788>
ffffffffc020196e:	f94fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201972:	00003697          	auipc	a3,0x3
ffffffffc0201976:	7e668693          	addi	a3,a3,2022 # ffffffffc0205158 <commands+0xa20>
ffffffffc020197a:	00003617          	auipc	a2,0x3
ffffffffc020197e:	64660613          	addi	a2,a2,1606 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201982:	1a700593          	li	a1,423
ffffffffc0201986:	00003517          	auipc	a0,0x3
ffffffffc020198a:	53a50513          	addi	a0,a0,1338 # ffffffffc0204ec0 <commands+0x788>
ffffffffc020198e:	f74fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201992:	00003697          	auipc	a3,0x3
ffffffffc0201996:	71e68693          	addi	a3,a3,1822 # ffffffffc02050b0 <commands+0x978>
ffffffffc020199a:	00003617          	auipc	a2,0x3
ffffffffc020199e:	62660613          	addi	a2,a2,1574 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02019a2:	1b400593          	li	a1,436
ffffffffc02019a6:	00003517          	auipc	a0,0x3
ffffffffc02019aa:	51a50513          	addi	a0,a0,1306 # ffffffffc0204ec0 <commands+0x788>
ffffffffc02019ae:	f54fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02019b2:	00004697          	auipc	a3,0x4
ffffffffc02019b6:	85668693          	addi	a3,a3,-1962 # ffffffffc0205208 <commands+0xad0>
ffffffffc02019ba:	00003617          	auipc	a2,0x3
ffffffffc02019be:	60660613          	addi	a2,a2,1542 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02019c2:	1b100593          	li	a1,433
ffffffffc02019c6:	00003517          	auipc	a0,0x3
ffffffffc02019ca:	4fa50513          	addi	a0,a0,1274 # ffffffffc0204ec0 <commands+0x788>
ffffffffc02019ce:	f34fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02019d2:	00003697          	auipc	a3,0x3
ffffffffc02019d6:	6c668693          	addi	a3,a3,1734 # ffffffffc0205098 <commands+0x960>
ffffffffc02019da:	00003617          	auipc	a2,0x3
ffffffffc02019de:	5e660613          	addi	a2,a2,1510 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02019e2:	1b000593          	li	a1,432
ffffffffc02019e6:	00003517          	auipc	a0,0x3
ffffffffc02019ea:	4da50513          	addi	a0,a0,1242 # ffffffffc0204ec0 <commands+0x788>
ffffffffc02019ee:	f14fe0ef          	jal	ra,ffffffffc0200102 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02019f2:	00003617          	auipc	a2,0x3
ffffffffc02019f6:	4a660613          	addi	a2,a2,1190 # ffffffffc0204e98 <commands+0x760>
ffffffffc02019fa:	06a00593          	li	a1,106
ffffffffc02019fe:	00003517          	auipc	a0,0x3
ffffffffc0201a02:	46250513          	addi	a0,a0,1122 # ffffffffc0204e60 <commands+0x728>
ffffffffc0201a06:	efcfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201a0a:	00004697          	auipc	a3,0x4
ffffffffc0201a0e:	82e68693          	addi	a3,a3,-2002 # ffffffffc0205238 <commands+0xb00>
ffffffffc0201a12:	00003617          	auipc	a2,0x3
ffffffffc0201a16:	5ae60613          	addi	a2,a2,1454 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201a1a:	1bb00593          	li	a1,443
ffffffffc0201a1e:	00003517          	auipc	a0,0x3
ffffffffc0201a22:	4a250513          	addi	a0,a0,1186 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201a26:	edcfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201a2a:	00003697          	auipc	a3,0x3
ffffffffc0201a2e:	7c668693          	addi	a3,a3,1990 # ffffffffc02051f0 <commands+0xab8>
ffffffffc0201a32:	00003617          	auipc	a2,0x3
ffffffffc0201a36:	58e60613          	addi	a2,a2,1422 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201a3a:	1b900593          	li	a1,441
ffffffffc0201a3e:	00003517          	auipc	a0,0x3
ffffffffc0201a42:	48250513          	addi	a0,a0,1154 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201a46:	ebcfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201a4a:	00003697          	auipc	a3,0x3
ffffffffc0201a4e:	7d668693          	addi	a3,a3,2006 # ffffffffc0205220 <commands+0xae8>
ffffffffc0201a52:	00003617          	auipc	a2,0x3
ffffffffc0201a56:	56e60613          	addi	a2,a2,1390 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201a5a:	1b800593          	li	a1,440
ffffffffc0201a5e:	00003517          	auipc	a0,0x3
ffffffffc0201a62:	46250513          	addi	a0,a0,1122 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201a66:	e9cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201a6a:	00003697          	auipc	a3,0x3
ffffffffc0201a6e:	78668693          	addi	a3,a3,1926 # ffffffffc02051f0 <commands+0xab8>
ffffffffc0201a72:	00003617          	auipc	a2,0x3
ffffffffc0201a76:	54e60613          	addi	a2,a2,1358 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201a7a:	1b500593          	li	a1,437
ffffffffc0201a7e:	00003517          	auipc	a0,0x3
ffffffffc0201a82:	44250513          	addi	a0,a0,1090 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201a86:	e7cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201a8a:	00004697          	auipc	a3,0x4
ffffffffc0201a8e:	8be68693          	addi	a3,a3,-1858 # ffffffffc0205348 <commands+0xc10>
ffffffffc0201a92:	00003617          	auipc	a2,0x3
ffffffffc0201a96:	52e60613          	addi	a2,a2,1326 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201a9a:	1d900593          	li	a1,473
ffffffffc0201a9e:	00003517          	auipc	a0,0x3
ffffffffc0201aa2:	42250513          	addi	a0,a0,1058 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201aa6:	e5cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201aaa:	00004697          	auipc	a3,0x4
ffffffffc0201aae:	86668693          	addi	a3,a3,-1946 # ffffffffc0205310 <commands+0xbd8>
ffffffffc0201ab2:	00003617          	auipc	a2,0x3
ffffffffc0201ab6:	50e60613          	addi	a2,a2,1294 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201aba:	1d800593          	li	a1,472
ffffffffc0201abe:	00003517          	auipc	a0,0x3
ffffffffc0201ac2:	40250513          	addi	a0,a0,1026 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201ac6:	e3cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0201aca:	00004697          	auipc	a3,0x4
ffffffffc0201ace:	82e68693          	addi	a3,a3,-2002 # ffffffffc02052f8 <commands+0xbc0>
ffffffffc0201ad2:	00003617          	auipc	a2,0x3
ffffffffc0201ad6:	4ee60613          	addi	a2,a2,1262 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201ada:	1d400593          	li	a1,468
ffffffffc0201ade:	00003517          	auipc	a0,0x3
ffffffffc0201ae2:	3e250513          	addi	a0,a0,994 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201ae6:	e1cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201aea:	00003697          	auipc	a3,0x3
ffffffffc0201aee:	77668693          	addi	a3,a3,1910 # ffffffffc0205260 <commands+0xb28>
ffffffffc0201af2:	00003617          	auipc	a2,0x3
ffffffffc0201af6:	4ce60613          	addi	a2,a2,1230 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201afa:	1c200593          	li	a1,450
ffffffffc0201afe:	00003517          	auipc	a0,0x3
ffffffffc0201b02:	3c250513          	addi	a0,a0,962 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201b06:	dfcfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201b0a:	00003697          	auipc	a3,0x3
ffffffffc0201b0e:	58e68693          	addi	a3,a3,1422 # ffffffffc0205098 <commands+0x960>
ffffffffc0201b12:	00003617          	auipc	a2,0x3
ffffffffc0201b16:	4ae60613          	addi	a2,a2,1198 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201b1a:	19d00593          	li	a1,413
ffffffffc0201b1e:	00003517          	auipc	a0,0x3
ffffffffc0201b22:	3a250513          	addi	a0,a0,930 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201b26:	ddcfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201b2a:	00003617          	auipc	a2,0x3
ffffffffc0201b2e:	36e60613          	addi	a2,a2,878 # ffffffffc0204e98 <commands+0x760>
ffffffffc0201b32:	1a000593          	li	a1,416
ffffffffc0201b36:	00003517          	auipc	a0,0x3
ffffffffc0201b3a:	38a50513          	addi	a0,a0,906 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201b3e:	dc4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201b42:	00003697          	auipc	a3,0x3
ffffffffc0201b46:	56e68693          	addi	a3,a3,1390 # ffffffffc02050b0 <commands+0x978>
ffffffffc0201b4a:	00003617          	auipc	a2,0x3
ffffffffc0201b4e:	47660613          	addi	a2,a2,1142 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201b52:	19e00593          	li	a1,414
ffffffffc0201b56:	00003517          	auipc	a0,0x3
ffffffffc0201b5a:	36a50513          	addi	a0,a0,874 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201b5e:	da4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201b62:	00003697          	auipc	a3,0x3
ffffffffc0201b66:	5c668693          	addi	a3,a3,1478 # ffffffffc0205128 <commands+0x9f0>
ffffffffc0201b6a:	00003617          	auipc	a2,0x3
ffffffffc0201b6e:	45660613          	addi	a2,a2,1110 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201b72:	1a600593          	li	a1,422
ffffffffc0201b76:	00003517          	auipc	a0,0x3
ffffffffc0201b7a:	34a50513          	addi	a0,a0,842 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201b7e:	d84fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201b82:	00004697          	auipc	a3,0x4
ffffffffc0201b86:	88668693          	addi	a3,a3,-1914 # ffffffffc0205408 <commands+0xcd0>
ffffffffc0201b8a:	00003617          	auipc	a2,0x3
ffffffffc0201b8e:	43660613          	addi	a2,a2,1078 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201b92:	1e200593          	li	a1,482
ffffffffc0201b96:	00003517          	auipc	a0,0x3
ffffffffc0201b9a:	32a50513          	addi	a0,a0,810 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201b9e:	d64fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201ba2:	00004697          	auipc	a3,0x4
ffffffffc0201ba6:	82e68693          	addi	a3,a3,-2002 # ffffffffc02053d0 <commands+0xc98>
ffffffffc0201baa:	00003617          	auipc	a2,0x3
ffffffffc0201bae:	41660613          	addi	a2,a2,1046 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201bb2:	1df00593          	li	a1,479
ffffffffc0201bb6:	00003517          	auipc	a0,0x3
ffffffffc0201bba:	30a50513          	addi	a0,a0,778 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201bbe:	d44fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201bc2:	00003697          	auipc	a3,0x3
ffffffffc0201bc6:	7de68693          	addi	a3,a3,2014 # ffffffffc02053a0 <commands+0xc68>
ffffffffc0201bca:	00003617          	auipc	a2,0x3
ffffffffc0201bce:	3f660613          	addi	a2,a2,1014 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201bd2:	1db00593          	li	a1,475
ffffffffc0201bd6:	00003517          	auipc	a0,0x3
ffffffffc0201bda:	2ea50513          	addi	a0,a0,746 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201bde:	d24fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201be2 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201be2:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0201be6:	8082                	ret

ffffffffc0201be8 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201be8:	7179                	addi	sp,sp,-48
ffffffffc0201bea:	e84a                	sd	s2,16(sp)
ffffffffc0201bec:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0201bee:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201bf0:	f022                	sd	s0,32(sp)
ffffffffc0201bf2:	ec26                	sd	s1,24(sp)
ffffffffc0201bf4:	e44e                	sd	s3,8(sp)
ffffffffc0201bf6:	f406                	sd	ra,40(sp)
ffffffffc0201bf8:	84ae                	mv	s1,a1
ffffffffc0201bfa:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0201bfc:	eedfe0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc0201c00:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0201c02:	cd09                	beqz	a0,ffffffffc0201c1c <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0201c04:	85aa                	mv	a1,a0
ffffffffc0201c06:	86ce                	mv	a3,s3
ffffffffc0201c08:	8626                	mv	a2,s1
ffffffffc0201c0a:	854a                	mv	a0,s2
ffffffffc0201c0c:	ad2ff0ef          	jal	ra,ffffffffc0200ede <page_insert>
ffffffffc0201c10:	ed21                	bnez	a0,ffffffffc0201c68 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0201c12:	00010797          	auipc	a5,0x10
ffffffffc0201c16:	94e7a783          	lw	a5,-1714(a5) # ffffffffc0211560 <swap_init_ok>
ffffffffc0201c1a:	eb89                	bnez	a5,ffffffffc0201c2c <pgdir_alloc_page+0x44>
}
ffffffffc0201c1c:	70a2                	ld	ra,40(sp)
ffffffffc0201c1e:	8522                	mv	a0,s0
ffffffffc0201c20:	7402                	ld	s0,32(sp)
ffffffffc0201c22:	64e2                	ld	s1,24(sp)
ffffffffc0201c24:	6942                	ld	s2,16(sp)
ffffffffc0201c26:	69a2                	ld	s3,8(sp)
ffffffffc0201c28:	6145                	addi	sp,sp,48
ffffffffc0201c2a:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0201c2c:	4681                	li	a3,0
ffffffffc0201c2e:	8622                	mv	a2,s0
ffffffffc0201c30:	85a6                	mv	a1,s1
ffffffffc0201c32:	00010517          	auipc	a0,0x10
ffffffffc0201c36:	90e53503          	ld	a0,-1778(a0) # ffffffffc0211540 <check_mm_struct>
ffffffffc0201c3a:	102010ef          	jal	ra,ffffffffc0202d3c <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0201c3e:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0201c40:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0201c42:	4785                	li	a5,1
ffffffffc0201c44:	fcf70ce3          	beq	a4,a5,ffffffffc0201c1c <pgdir_alloc_page+0x34>
ffffffffc0201c48:	00004697          	auipc	a3,0x4
ffffffffc0201c4c:	80868693          	addi	a3,a3,-2040 # ffffffffc0205450 <commands+0xd18>
ffffffffc0201c50:	00003617          	auipc	a2,0x3
ffffffffc0201c54:	37060613          	addi	a2,a2,880 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201c58:	17c00593          	li	a1,380
ffffffffc0201c5c:	00003517          	auipc	a0,0x3
ffffffffc0201c60:	26450513          	addi	a0,a0,612 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201c64:	c9efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c68:	100027f3          	csrr	a5,sstatus
ffffffffc0201c6c:	8b89                	andi	a5,a5,2
ffffffffc0201c6e:	eb99                	bnez	a5,ffffffffc0201c84 <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201c70:	00010797          	auipc	a5,0x10
ffffffffc0201c74:	8c07b783          	ld	a5,-1856(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201c78:	739c                	ld	a5,32(a5)
ffffffffc0201c7a:	8522                	mv	a0,s0
ffffffffc0201c7c:	4585                	li	a1,1
ffffffffc0201c7e:	9782                	jalr	a5
            return NULL;
ffffffffc0201c80:	4401                	li	s0,0
ffffffffc0201c82:	bf69                	j	ffffffffc0201c1c <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0201c84:	86bfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201c88:	00010797          	auipc	a5,0x10
ffffffffc0201c8c:	8a87b783          	ld	a5,-1880(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201c90:	739c                	ld	a5,32(a5)
ffffffffc0201c92:	8522                	mv	a0,s0
ffffffffc0201c94:	4585                	li	a1,1
ffffffffc0201c96:	9782                	jalr	a5
            return NULL;
ffffffffc0201c98:	4401                	li	s0,0
        intr_enable();
ffffffffc0201c9a:	84ffe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201c9e:	bfbd                	j	ffffffffc0201c1c <pgdir_alloc_page+0x34>

ffffffffc0201ca0 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0201ca0:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201ca2:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0201ca4:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201ca6:	fff50713          	addi	a4,a0,-1
ffffffffc0201caa:	17f9                	addi	a5,a5,-2
ffffffffc0201cac:	04e7ea63          	bltu	a5,a4,ffffffffc0201d00 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0201cb0:	6785                	lui	a5,0x1
ffffffffc0201cb2:	17fd                	addi	a5,a5,-1
ffffffffc0201cb4:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0201cb6:	8131                	srli	a0,a0,0xc
ffffffffc0201cb8:	e31fe0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
    assert(base != NULL);
ffffffffc0201cbc:	cd3d                	beqz	a0,ffffffffc0201d3a <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201cbe:	00010797          	auipc	a5,0x10
ffffffffc0201cc2:	86a7b783          	ld	a5,-1942(a5) # ffffffffc0211528 <pages>
ffffffffc0201cc6:	8d1d                	sub	a0,a0,a5
ffffffffc0201cc8:	00004697          	auipc	a3,0x4
ffffffffc0201ccc:	6c06b683          	ld	a3,1728(a3) # ffffffffc0206388 <error_string+0x38>
ffffffffc0201cd0:	850d                	srai	a0,a0,0x3
ffffffffc0201cd2:	02d50533          	mul	a0,a0,a3
ffffffffc0201cd6:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201cda:	00010717          	auipc	a4,0x10
ffffffffc0201cde:	84673703          	ld	a4,-1978(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ce2:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ce4:	00c51793          	slli	a5,a0,0xc
ffffffffc0201ce8:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201cea:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201cec:	02e7fa63          	bgeu	a5,a4,ffffffffc0201d20 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0201cf0:	60a2                	ld	ra,8(sp)
ffffffffc0201cf2:	00010797          	auipc	a5,0x10
ffffffffc0201cf6:	8467b783          	ld	a5,-1978(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0201cfa:	953e                	add	a0,a0,a5
ffffffffc0201cfc:	0141                	addi	sp,sp,16
ffffffffc0201cfe:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201d00:	00003697          	auipc	a3,0x3
ffffffffc0201d04:	76868693          	addi	a3,a3,1896 # ffffffffc0205468 <commands+0xd30>
ffffffffc0201d08:	00003617          	auipc	a2,0x3
ffffffffc0201d0c:	2b860613          	addi	a2,a2,696 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201d10:	1f200593          	li	a1,498
ffffffffc0201d14:	00003517          	auipc	a0,0x3
ffffffffc0201d18:	1ac50513          	addi	a0,a0,428 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201d1c:	be6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0201d20:	86aa                	mv	a3,a0
ffffffffc0201d22:	00003617          	auipc	a2,0x3
ffffffffc0201d26:	17660613          	addi	a2,a2,374 # ffffffffc0204e98 <commands+0x760>
ffffffffc0201d2a:	06a00593          	li	a1,106
ffffffffc0201d2e:	00003517          	auipc	a0,0x3
ffffffffc0201d32:	13250513          	addi	a0,a0,306 # ffffffffc0204e60 <commands+0x728>
ffffffffc0201d36:	bccfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(base != NULL);
ffffffffc0201d3a:	00003697          	auipc	a3,0x3
ffffffffc0201d3e:	74e68693          	addi	a3,a3,1870 # ffffffffc0205488 <commands+0xd50>
ffffffffc0201d42:	00003617          	auipc	a2,0x3
ffffffffc0201d46:	27e60613          	addi	a2,a2,638 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201d4a:	1f500593          	li	a1,501
ffffffffc0201d4e:	00003517          	auipc	a0,0x3
ffffffffc0201d52:	17250513          	addi	a0,a0,370 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201d56:	bacfe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201d5a <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0201d5a:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201d5c:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0201d5e:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201d60:	fff58713          	addi	a4,a1,-1
ffffffffc0201d64:	17f9                	addi	a5,a5,-2
ffffffffc0201d66:	0ae7ee63          	bltu	a5,a4,ffffffffc0201e22 <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0201d6a:	cd41                	beqz	a0,ffffffffc0201e02 <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0201d6c:	6785                	lui	a5,0x1
ffffffffc0201d6e:	17fd                	addi	a5,a5,-1
ffffffffc0201d70:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201d72:	c02007b7          	lui	a5,0xc0200
ffffffffc0201d76:	81b1                	srli	a1,a1,0xc
ffffffffc0201d78:	06f56863          	bltu	a0,a5,ffffffffc0201de8 <kfree+0x8e>
ffffffffc0201d7c:	0000f697          	auipc	a3,0xf
ffffffffc0201d80:	7bc6b683          	ld	a3,1980(a3) # ffffffffc0211538 <va_pa_offset>
ffffffffc0201d84:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d86:	8131                	srli	a0,a0,0xc
ffffffffc0201d88:	0000f797          	auipc	a5,0xf
ffffffffc0201d8c:	7987b783          	ld	a5,1944(a5) # ffffffffc0211520 <npage>
ffffffffc0201d90:	04f57a63          	bgeu	a0,a5,ffffffffc0201de4 <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d94:	fff806b7          	lui	a3,0xfff80
ffffffffc0201d98:	9536                	add	a0,a0,a3
ffffffffc0201d9a:	00351793          	slli	a5,a0,0x3
ffffffffc0201d9e:	953e                	add	a0,a0,a5
ffffffffc0201da0:	050e                	slli	a0,a0,0x3
ffffffffc0201da2:	0000f797          	auipc	a5,0xf
ffffffffc0201da6:	7867b783          	ld	a5,1926(a5) # ffffffffc0211528 <pages>
ffffffffc0201daa:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201dac:	100027f3          	csrr	a5,sstatus
ffffffffc0201db0:	8b89                	andi	a5,a5,2
ffffffffc0201db2:	eb89                	bnez	a5,ffffffffc0201dc4 <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201db4:	0000f797          	auipc	a5,0xf
ffffffffc0201db8:	77c7b783          	ld	a5,1916(a5) # ffffffffc0211530 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0201dbc:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0201dbe:	739c                	ld	a5,32(a5)
}
ffffffffc0201dc0:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc0201dc2:	8782                	jr	a5
        intr_disable();
ffffffffc0201dc4:	e42a                	sd	a0,8(sp)
ffffffffc0201dc6:	e02e                	sd	a1,0(sp)
ffffffffc0201dc8:	f26fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201dcc:	0000f797          	auipc	a5,0xf
ffffffffc0201dd0:	7647b783          	ld	a5,1892(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201dd4:	6582                	ld	a1,0(sp)
ffffffffc0201dd6:	6522                	ld	a0,8(sp)
ffffffffc0201dd8:	739c                	ld	a5,32(a5)
ffffffffc0201dda:	9782                	jalr	a5
}
ffffffffc0201ddc:	60e2                	ld	ra,24(sp)
ffffffffc0201dde:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201de0:	f08fe06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc0201de4:	ccdfe0ef          	jal	ra,ffffffffc0200ab0 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201de8:	86aa                	mv	a3,a0
ffffffffc0201dea:	00003617          	auipc	a2,0x3
ffffffffc0201dee:	16e60613          	addi	a2,a2,366 # ffffffffc0204f58 <commands+0x820>
ffffffffc0201df2:	06c00593          	li	a1,108
ffffffffc0201df6:	00003517          	auipc	a0,0x3
ffffffffc0201dfa:	06a50513          	addi	a0,a0,106 # ffffffffc0204e60 <commands+0x728>
ffffffffc0201dfe:	b04fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(ptr != NULL);
ffffffffc0201e02:	00003697          	auipc	a3,0x3
ffffffffc0201e06:	69668693          	addi	a3,a3,1686 # ffffffffc0205498 <commands+0xd60>
ffffffffc0201e0a:	00003617          	auipc	a2,0x3
ffffffffc0201e0e:	1b660613          	addi	a2,a2,438 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201e12:	1fc00593          	li	a1,508
ffffffffc0201e16:	00003517          	auipc	a0,0x3
ffffffffc0201e1a:	0aa50513          	addi	a0,a0,170 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201e1e:	ae4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201e22:	00003697          	auipc	a3,0x3
ffffffffc0201e26:	64668693          	addi	a3,a3,1606 # ffffffffc0205468 <commands+0xd30>
ffffffffc0201e2a:	00003617          	auipc	a2,0x3
ffffffffc0201e2e:	19660613          	addi	a2,a2,406 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201e32:	1fb00593          	li	a1,507
ffffffffc0201e36:	00003517          	auipc	a0,0x3
ffffffffc0201e3a:	08a50513          	addi	a0,a0,138 # ffffffffc0204ec0 <commands+0x788>
ffffffffc0201e3e:	ac4fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201e42 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201e42:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);//next 是我们想插入的区间， 这里顺便检验了start < end
ffffffffc0201e44:	00003697          	auipc	a3,0x3
ffffffffc0201e48:	66468693          	addi	a3,a3,1636 # ffffffffc02054a8 <commands+0xd70>
ffffffffc0201e4c:	00003617          	auipc	a2,0x3
ffffffffc0201e50:	17460613          	addi	a2,a2,372 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201e54:	07f00593          	li	a1,127
ffffffffc0201e58:	00003517          	auipc	a0,0x3
ffffffffc0201e5c:	67050513          	addi	a0,a0,1648 # ffffffffc02054c8 <commands+0xd90>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201e60:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);//next 是我们想插入的区间， 这里顺便检验了start < end
ffffffffc0201e62:	aa0fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201e66 <mm_create>:
mm_create(void) {
ffffffffc0201e66:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201e68:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0201e6c:	e022                	sd	s0,0(sp)
ffffffffc0201e6e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201e70:	e31ff0ef          	jal	ra,ffffffffc0201ca0 <kmalloc>
ffffffffc0201e74:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201e76:	c105                	beqz	a0,ffffffffc0201e96 <mm_create+0x30>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201e78:	e408                	sd	a0,8(s0)
ffffffffc0201e7a:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0201e7c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201e80:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201e84:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);//页面置换的初始化
ffffffffc0201e88:	0000f797          	auipc	a5,0xf
ffffffffc0201e8c:	6d87a783          	lw	a5,1752(a5) # ffffffffc0211560 <swap_init_ok>
ffffffffc0201e90:	eb81                	bnez	a5,ffffffffc0201ea0 <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0201e92:	02053423          	sd	zero,40(a0)
}
ffffffffc0201e96:	60a2                	ld	ra,8(sp)
ffffffffc0201e98:	8522                	mv	a0,s0
ffffffffc0201e9a:	6402                	ld	s0,0(sp)
ffffffffc0201e9c:	0141                	addi	sp,sp,16
ffffffffc0201e9e:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);//页面置换的初始化
ffffffffc0201ea0:	691000ef          	jal	ra,ffffffffc0202d30 <swap_init_mm>
}
ffffffffc0201ea4:	60a2                	ld	ra,8(sp)
ffffffffc0201ea6:	8522                	mv	a0,s0
ffffffffc0201ea8:	6402                	ld	s0,0(sp)
ffffffffc0201eaa:	0141                	addi	sp,sp,16
ffffffffc0201eac:	8082                	ret

ffffffffc0201eae <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201eae:	1101                	addi	sp,sp,-32
ffffffffc0201eb0:	e04a                	sd	s2,0(sp)
ffffffffc0201eb2:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201eb4:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201eb8:	e822                	sd	s0,16(sp)
ffffffffc0201eba:	e426                	sd	s1,8(sp)
ffffffffc0201ebc:	ec06                	sd	ra,24(sp)
ffffffffc0201ebe:	84ae                	mv	s1,a1
ffffffffc0201ec0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201ec2:	ddfff0ef          	jal	ra,ffffffffc0201ca0 <kmalloc>
    if (vma != NULL) {
ffffffffc0201ec6:	c509                	beqz	a0,ffffffffc0201ed0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0201ec8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201ecc:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201ece:	ed00                	sd	s0,24(a0)
}
ffffffffc0201ed0:	60e2                	ld	ra,24(sp)
ffffffffc0201ed2:	6442                	ld	s0,16(sp)
ffffffffc0201ed4:	64a2                	ld	s1,8(sp)
ffffffffc0201ed6:	6902                	ld	s2,0(sp)
ffffffffc0201ed8:	6105                	addi	sp,sp,32
ffffffffc0201eda:	8082                	ret

ffffffffc0201edc <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0201edc:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0201ede:	c505                	beqz	a0,ffffffffc0201f06 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0201ee0:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201ee2:	c501                	beqz	a0,ffffffffc0201eea <find_vma+0xe>
ffffffffc0201ee4:	651c                	ld	a5,8(a0)
ffffffffc0201ee6:	02f5f263          	bgeu	a1,a5,ffffffffc0201f0a <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201eea:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0201eec:	00f68d63          	beq	a3,a5,ffffffffc0201f06 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0201ef0:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201ef4:	00e5e663          	bltu	a1,a4,ffffffffc0201f00 <find_vma+0x24>
ffffffffc0201ef8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201efc:	00e5ec63          	bltu	a1,a4,ffffffffc0201f14 <find_vma+0x38>
ffffffffc0201f00:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0201f02:	fef697e3          	bne	a3,a5,ffffffffc0201ef0 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0201f06:	4501                	li	a0,0
}
ffffffffc0201f08:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201f0a:	691c                	ld	a5,16(a0)
ffffffffc0201f0c:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0201eea <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0201f10:	ea88                	sd	a0,16(a3)
ffffffffc0201f12:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0201f14:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0201f18:	ea88                	sd	a0,16(a3)
ffffffffc0201f1a:	8082                	ret

ffffffffc0201f1c <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201f1c:	6590                	ld	a2,8(a1)
ffffffffc0201f1e:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0201f22:	1141                	addi	sp,sp,-16
ffffffffc0201f24:	e406                	sd	ra,8(sp)
ffffffffc0201f26:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201f28:	01066763          	bltu	a2,a6,ffffffffc0201f36 <insert_vma_struct+0x1a>
ffffffffc0201f2c:	a085                	j	ffffffffc0201f8c <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

    list_entry_t *le = list;
    while ((le = list_next(le)) != list) {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201f2e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201f32:	04e66863          	bltu	a2,a4,ffffffffc0201f82 <insert_vma_struct+0x66>
ffffffffc0201f36:	86be                	mv	a3,a5
ffffffffc0201f38:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list) {
ffffffffc0201f3a:	fef51ae3          	bne	a0,a5,ffffffffc0201f2e <insert_vma_struct+0x12>
    }
    //保证插入后所有vma_struct按照区间左端点有序排列
    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0201f3e:	02a68463          	beq	a3,a0,ffffffffc0201f66 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0201f42:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201f46:	fe86b883          	ld	a7,-24(a3)
ffffffffc0201f4a:	08e8f163          	bgeu	a7,a4,ffffffffc0201fcc <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201f4e:	04e66f63          	bltu	a2,a4,ffffffffc0201fac <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0201f52:	00f50a63          	beq	a0,a5,ffffffffc0201f66 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201f56:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201f5a:	05076963          	bltu	a4,a6,ffffffffc0201fac <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);//next 是我们想插入的区间， 这里顺便检验了start < end
ffffffffc0201f5e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0201f62:	02c77363          	bgeu	a4,a2,ffffffffc0201f88 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0201f66:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0201f68:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201f6a:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201f6e:	e390                	sd	a2,0(a5)
ffffffffc0201f70:	e690                	sd	a2,8(a3)
}
ffffffffc0201f72:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0201f74:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201f76:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0201f78:	0017079b          	addiw	a5,a4,1
ffffffffc0201f7c:	d11c                	sw	a5,32(a0)
}
ffffffffc0201f7e:	0141                	addi	sp,sp,16
ffffffffc0201f80:	8082                	ret
    if (le_prev != list) {
ffffffffc0201f82:	fca690e3          	bne	a3,a0,ffffffffc0201f42 <insert_vma_struct+0x26>
ffffffffc0201f86:	bfd1                	j	ffffffffc0201f5a <insert_vma_struct+0x3e>
ffffffffc0201f88:	ebbff0ef          	jal	ra,ffffffffc0201e42 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201f8c:	00003697          	auipc	a3,0x3
ffffffffc0201f90:	54c68693          	addi	a3,a3,1356 # ffffffffc02054d8 <commands+0xda0>
ffffffffc0201f94:	00003617          	auipc	a2,0x3
ffffffffc0201f98:	02c60613          	addi	a2,a2,44 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201f9c:	08600593          	li	a1,134
ffffffffc0201fa0:	00003517          	auipc	a0,0x3
ffffffffc0201fa4:	52850513          	addi	a0,a0,1320 # ffffffffc02054c8 <commands+0xd90>
ffffffffc0201fa8:	95afe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201fac:	00003697          	auipc	a3,0x3
ffffffffc0201fb0:	56c68693          	addi	a3,a3,1388 # ffffffffc0205518 <commands+0xde0>
ffffffffc0201fb4:	00003617          	auipc	a2,0x3
ffffffffc0201fb8:	00c60613          	addi	a2,a2,12 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201fbc:	07e00593          	li	a1,126
ffffffffc0201fc0:	00003517          	auipc	a0,0x3
ffffffffc0201fc4:	50850513          	addi	a0,a0,1288 # ffffffffc02054c8 <commands+0xd90>
ffffffffc0201fc8:	93afe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201fcc:	00003697          	auipc	a3,0x3
ffffffffc0201fd0:	52c68693          	addi	a3,a3,1324 # ffffffffc02054f8 <commands+0xdc0>
ffffffffc0201fd4:	00003617          	auipc	a2,0x3
ffffffffc0201fd8:	fec60613          	addi	a2,a2,-20 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0201fdc:	07d00593          	li	a1,125
ffffffffc0201fe0:	00003517          	auipc	a0,0x3
ffffffffc0201fe4:	4e850513          	addi	a0,a0,1256 # ffffffffc02054c8 <commands+0xd90>
ffffffffc0201fe8:	91afe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201fec <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0201fec:	1141                	addi	sp,sp,-16
ffffffffc0201fee:	e022                	sd	s0,0(sp)
ffffffffc0201ff0:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0201ff2:	6508                	ld	a0,8(a0)
ffffffffc0201ff4:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0201ff6:	00a40e63          	beq	s0,a0,ffffffffc0202012 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201ffa:	6118                	ld	a4,0(a0)
ffffffffc0201ffc:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0201ffe:	03000593          	li	a1,48
ffffffffc0202002:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0202004:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202006:	e398                	sd	a4,0(a5)
ffffffffc0202008:	d53ff0ef          	jal	ra,ffffffffc0201d5a <kfree>
    return listelm->next;
ffffffffc020200c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020200e:	fea416e3          	bne	s0,a0,ffffffffc0201ffa <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0202012:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0202014:	6402                	ld	s0,0(sp)
ffffffffc0202016:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0202018:	03000593          	li	a1,48
}
ffffffffc020201c:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020201e:	bb35                	j	ffffffffc0201d5a <kfree>

ffffffffc0202020 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0202020:	715d                	addi	sp,sp,-80
ffffffffc0202022:	e486                	sd	ra,72(sp)
ffffffffc0202024:	f44e                	sd	s3,40(sp)
ffffffffc0202026:	f052                	sd	s4,32(sp)
ffffffffc0202028:	e0a2                	sd	s0,64(sp)
ffffffffc020202a:	fc26                	sd	s1,56(sp)
ffffffffc020202c:	f84a                	sd	s2,48(sp)
ffffffffc020202e:	ec56                	sd	s5,24(sp)
ffffffffc0202030:	e85a                	sd	s6,16(sp)
ffffffffc0202032:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202034:	b87fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0202038:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020203a:	b81fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc020203e:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202040:	03000513          	li	a0,48
ffffffffc0202044:	c5dff0ef          	jal	ra,ffffffffc0201ca0 <kmalloc>
    if (mm != NULL) {
ffffffffc0202048:	56050863          	beqz	a0,ffffffffc02025b8 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc020204c:	e508                	sd	a0,8(a0)
ffffffffc020204e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0202050:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0202054:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0202058:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);//页面置换的初始化
ffffffffc020205c:	0000f797          	auipc	a5,0xf
ffffffffc0202060:	5047a783          	lw	a5,1284(a5) # ffffffffc0211560 <swap_init_ok>
ffffffffc0202064:	84aa                	mv	s1,a0
ffffffffc0202066:	e7b9                	bnez	a5,ffffffffc02020b4 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc0202068:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc020206c:	03200413          	li	s0,50
ffffffffc0202070:	a811                	j	ffffffffc0202084 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc0202072:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202074:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202076:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc020207a:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020207c:	8526                	mv	a0,s1
ffffffffc020207e:	e9fff0ef          	jal	ra,ffffffffc0201f1c <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0202082:	cc05                	beqz	s0,ffffffffc02020ba <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202084:	03000513          	li	a0,48
ffffffffc0202088:	c19ff0ef          	jal	ra,ffffffffc0201ca0 <kmalloc>
ffffffffc020208c:	85aa                	mv	a1,a0
ffffffffc020208e:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0202092:	f165                	bnez	a0,ffffffffc0202072 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc0202094:	00003697          	auipc	a3,0x3
ffffffffc0202098:	6a468693          	addi	a3,a3,1700 # ffffffffc0205738 <commands+0x1000>
ffffffffc020209c:	00003617          	auipc	a2,0x3
ffffffffc02020a0:	f2460613          	addi	a2,a2,-220 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02020a4:	0d000593          	li	a1,208
ffffffffc02020a8:	00003517          	auipc	a0,0x3
ffffffffc02020ac:	42050513          	addi	a0,a0,1056 # ffffffffc02054c8 <commands+0xd90>
ffffffffc02020b0:	852fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        if (swap_init_ok) swap_init_mm(mm);//页面置换的初始化
ffffffffc02020b4:	47d000ef          	jal	ra,ffffffffc0202d30 <swap_init_mm>
ffffffffc02020b8:	bf55                	j	ffffffffc020206c <vmm_init+0x4c>
ffffffffc02020ba:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02020be:	1f900913          	li	s2,505
ffffffffc02020c2:	a819                	j	ffffffffc02020d8 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc02020c4:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02020c6:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02020c8:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02020cc:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02020ce:	8526                	mv	a0,s1
ffffffffc02020d0:	e4dff0ef          	jal	ra,ffffffffc0201f1c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02020d4:	03240a63          	beq	s0,s2,ffffffffc0202108 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02020d8:	03000513          	li	a0,48
ffffffffc02020dc:	bc5ff0ef          	jal	ra,ffffffffc0201ca0 <kmalloc>
ffffffffc02020e0:	85aa                	mv	a1,a0
ffffffffc02020e2:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02020e6:	fd79                	bnez	a0,ffffffffc02020c4 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc02020e8:	00003697          	auipc	a3,0x3
ffffffffc02020ec:	65068693          	addi	a3,a3,1616 # ffffffffc0205738 <commands+0x1000>
ffffffffc02020f0:	00003617          	auipc	a2,0x3
ffffffffc02020f4:	ed060613          	addi	a2,a2,-304 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02020f8:	0d600593          	li	a1,214
ffffffffc02020fc:	00003517          	auipc	a0,0x3
ffffffffc0202100:	3cc50513          	addi	a0,a0,972 # ffffffffc02054c8 <commands+0xd90>
ffffffffc0202104:	ffffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    return listelm->next;
ffffffffc0202108:	649c                	ld	a5,8(s1)
ffffffffc020210a:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc020210c:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0202110:	2ef48463          	beq	s1,a5,ffffffffc02023f8 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202114:	fe87b603          	ld	a2,-24(a5)
ffffffffc0202118:	ffe70693          	addi	a3,a4,-2
ffffffffc020211c:	26d61e63          	bne	a2,a3,ffffffffc0202398 <vmm_init+0x378>
ffffffffc0202120:	ff07b683          	ld	a3,-16(a5)
ffffffffc0202124:	26e69a63          	bne	a3,a4,ffffffffc0202398 <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc0202128:	0715                	addi	a4,a4,5
ffffffffc020212a:	679c                	ld	a5,8(a5)
ffffffffc020212c:	feb712e3          	bne	a4,a1,ffffffffc0202110 <vmm_init+0xf0>
ffffffffc0202130:	4b1d                	li	s6,7
ffffffffc0202132:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202134:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202138:	85a2                	mv	a1,s0
ffffffffc020213a:	8526                	mv	a0,s1
ffffffffc020213c:	da1ff0ef          	jal	ra,ffffffffc0201edc <find_vma>
ffffffffc0202140:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0202142:	2c050b63          	beqz	a0,ffffffffc0202418 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0202146:	00140593          	addi	a1,s0,1
ffffffffc020214a:	8526                	mv	a0,s1
ffffffffc020214c:	d91ff0ef          	jal	ra,ffffffffc0201edc <find_vma>
ffffffffc0202150:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0202152:	2e050363          	beqz	a0,ffffffffc0202438 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0202156:	85da                	mv	a1,s6
ffffffffc0202158:	8526                	mv	a0,s1
ffffffffc020215a:	d83ff0ef          	jal	ra,ffffffffc0201edc <find_vma>
        assert(vma3 == NULL);
ffffffffc020215e:	2e051d63          	bnez	a0,ffffffffc0202458 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0202162:	00340593          	addi	a1,s0,3
ffffffffc0202166:	8526                	mv	a0,s1
ffffffffc0202168:	d75ff0ef          	jal	ra,ffffffffc0201edc <find_vma>
        assert(vma4 == NULL);
ffffffffc020216c:	30051663          	bnez	a0,ffffffffc0202478 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0202170:	00440593          	addi	a1,s0,4
ffffffffc0202174:	8526                	mv	a0,s1
ffffffffc0202176:	d67ff0ef          	jal	ra,ffffffffc0201edc <find_vma>
        assert(vma5 == NULL);
ffffffffc020217a:	30051f63          	bnez	a0,ffffffffc0202498 <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020217e:	00893783          	ld	a5,8(s2)
ffffffffc0202182:	24879b63          	bne	a5,s0,ffffffffc02023d8 <vmm_init+0x3b8>
ffffffffc0202186:	01093783          	ld	a5,16(s2)
ffffffffc020218a:	25679763          	bne	a5,s6,ffffffffc02023d8 <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020218e:	008ab783          	ld	a5,8(s5)
ffffffffc0202192:	22879363          	bne	a5,s0,ffffffffc02023b8 <vmm_init+0x398>
ffffffffc0202196:	010ab783          	ld	a5,16(s5)
ffffffffc020219a:	21679f63          	bne	a5,s6,ffffffffc02023b8 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020219e:	0415                	addi	s0,s0,5
ffffffffc02021a0:	0b15                	addi	s6,s6,5
ffffffffc02021a2:	f9741be3          	bne	s0,s7,ffffffffc0202138 <vmm_init+0x118>
ffffffffc02021a6:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02021a8:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02021aa:	85a2                	mv	a1,s0
ffffffffc02021ac:	8526                	mv	a0,s1
ffffffffc02021ae:	d2fff0ef          	jal	ra,ffffffffc0201edc <find_vma>
ffffffffc02021b2:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc02021b6:	c90d                	beqz	a0,ffffffffc02021e8 <vmm_init+0x1c8>
            cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02021b8:	6914                	ld	a3,16(a0)
ffffffffc02021ba:	6510                	ld	a2,8(a0)
ffffffffc02021bc:	00003517          	auipc	a0,0x3
ffffffffc02021c0:	47c50513          	addi	a0,a0,1148 # ffffffffc0205638 <commands+0xf00>
ffffffffc02021c4:	ef7fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02021c8:	00003697          	auipc	a3,0x3
ffffffffc02021cc:	49868693          	addi	a3,a3,1176 # ffffffffc0205660 <commands+0xf28>
ffffffffc02021d0:	00003617          	auipc	a2,0x3
ffffffffc02021d4:	df060613          	addi	a2,a2,-528 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02021d8:	0f800593          	li	a1,248
ffffffffc02021dc:	00003517          	auipc	a0,0x3
ffffffffc02021e0:	2ec50513          	addi	a0,a0,748 # ffffffffc02054c8 <commands+0xd90>
ffffffffc02021e4:	f1ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc02021e8:	147d                	addi	s0,s0,-1
ffffffffc02021ea:	fd2410e3          	bne	s0,s2,ffffffffc02021aa <vmm_init+0x18a>
ffffffffc02021ee:	a811                	j	ffffffffc0202202 <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc02021f0:	6118                	ld	a4,0(a0)
ffffffffc02021f2:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc02021f4:	03000593          	li	a1,48
ffffffffc02021f8:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02021fa:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02021fc:	e398                	sd	a4,0(a5)
ffffffffc02021fe:	b5dff0ef          	jal	ra,ffffffffc0201d5a <kfree>
    return listelm->next;
ffffffffc0202202:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0202204:	fea496e3          	bne	s1,a0,ffffffffc02021f0 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0202208:	03000593          	li	a1,48
ffffffffc020220c:	8526                	mv	a0,s1
ffffffffc020220e:	b4dff0ef          	jal	ra,ffffffffc0201d5a <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202212:	9a9fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0202216:	3caa1163          	bne	s4,a0,ffffffffc02025d8 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020221a:	00003517          	auipc	a0,0x3
ffffffffc020221e:	48650513          	addi	a0,a0,1158 # ffffffffc02056a0 <commands+0xf68>
ffffffffc0202222:	e99fd0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202226:	995fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc020222a:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020222c:	03000513          	li	a0,48
ffffffffc0202230:	a71ff0ef          	jal	ra,ffffffffc0201ca0 <kmalloc>
ffffffffc0202234:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0202236:	2a050163          	beqz	a0,ffffffffc02024d8 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);//页面置换的初始化
ffffffffc020223a:	0000f797          	auipc	a5,0xf
ffffffffc020223e:	3267a783          	lw	a5,806(a5) # ffffffffc0211560 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0202242:	e508                	sd	a0,8(a0)
ffffffffc0202244:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0202246:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020224a:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020224e:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);//页面置换的初始化
ffffffffc0202252:	14079063          	bnez	a5,ffffffffc0202392 <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc0202256:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020225a:	0000f917          	auipc	s2,0xf
ffffffffc020225e:	2be93903          	ld	s2,702(s2) # ffffffffc0211518 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0202262:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0202266:	0000f717          	auipc	a4,0xf
ffffffffc020226a:	2c873d23          	sd	s0,730(a4) # ffffffffc0211540 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020226e:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0202272:	24079363          	bnez	a5,ffffffffc02024b8 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202276:	03000513          	li	a0,48
ffffffffc020227a:	a27ff0ef          	jal	ra,ffffffffc0201ca0 <kmalloc>
ffffffffc020227e:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0202280:	28050063          	beqz	a0,ffffffffc0202500 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc0202284:	002007b7          	lui	a5,0x200
ffffffffc0202288:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc020228c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020228e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0202290:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0202294:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0202296:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc020229a:	c83ff0ef          	jal	ra,ffffffffc0201f1c <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020229e:	10000593          	li	a1,256
ffffffffc02022a2:	8522                	mv	a0,s0
ffffffffc02022a4:	c39ff0ef          	jal	ra,ffffffffc0201edc <find_vma>
ffffffffc02022a8:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02022ac:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02022b0:	26aa1863          	bne	s4,a0,ffffffffc0202520 <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc02022b4:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc02022b8:	0785                	addi	a5,a5,1
ffffffffc02022ba:	fee79de3          	bne	a5,a4,ffffffffc02022b4 <vmm_init+0x294>
        sum += i;
ffffffffc02022be:	6705                	lui	a4,0x1
ffffffffc02022c0:	10000793          	li	a5,256
ffffffffc02022c4:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02022c8:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02022cc:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02022d0:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02022d2:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02022d4:	fec79ce3          	bne	a5,a2,ffffffffc02022cc <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc02022d8:	26071463          	bnez	a4,ffffffffc0202540 <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02022dc:	4581                	li	a1,0
ffffffffc02022de:	854a                	mv	a0,s2
ffffffffc02022e0:	b65fe0ef          	jal	ra,ffffffffc0200e44 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02022e4:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02022e8:	0000f717          	auipc	a4,0xf
ffffffffc02022ec:	23873703          	ld	a4,568(a4) # ffffffffc0211520 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc02022f0:	078a                	slli	a5,a5,0x2
ffffffffc02022f2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02022f4:	26e7f663          	bgeu	a5,a4,ffffffffc0202560 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc02022f8:	00004717          	auipc	a4,0x4
ffffffffc02022fc:	09873703          	ld	a4,152(a4) # ffffffffc0206390 <nbase>
ffffffffc0202300:	8f99                	sub	a5,a5,a4
ffffffffc0202302:	00379713          	slli	a4,a5,0x3
ffffffffc0202306:	97ba                	add	a5,a5,a4
ffffffffc0202308:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc020230a:	0000f517          	auipc	a0,0xf
ffffffffc020230e:	21e53503          	ld	a0,542(a0) # ffffffffc0211528 <pages>
ffffffffc0202312:	953e                	add	a0,a0,a5
ffffffffc0202314:	4585                	li	a1,1
ffffffffc0202316:	865fe0ef          	jal	ra,ffffffffc0200b7a <free_pages>
    return listelm->next;
ffffffffc020231a:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc020231c:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0202320:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0202324:	00a40e63          	beq	s0,a0,ffffffffc0202340 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202328:	6118                	ld	a4,0(a0)
ffffffffc020232a:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc020232c:	03000593          	li	a1,48
ffffffffc0202330:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0202332:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202334:	e398                	sd	a4,0(a5)
ffffffffc0202336:	a25ff0ef          	jal	ra,ffffffffc0201d5a <kfree>
    return listelm->next;
ffffffffc020233a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020233c:	fea416e3          	bne	s0,a0,ffffffffc0202328 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0202340:	03000593          	li	a1,48
ffffffffc0202344:	8522                	mv	a0,s0
ffffffffc0202346:	a15ff0ef          	jal	ra,ffffffffc0201d5a <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc020234a:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc020234c:	0000f797          	auipc	a5,0xf
ffffffffc0202350:	1e07ba23          	sd	zero,500(a5) # ffffffffc0211540 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202354:	867fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0202358:	22a49063          	bne	s1,a0,ffffffffc0202578 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020235c:	00003517          	auipc	a0,0x3
ffffffffc0202360:	3a450513          	addi	a0,a0,932 # ffffffffc0205700 <commands+0xfc8>
ffffffffc0202364:	d57fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202368:	853fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc020236c:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020236e:	22a99563          	bne	s3,a0,ffffffffc0202598 <vmm_init+0x578>
}
ffffffffc0202372:	6406                	ld	s0,64(sp)
ffffffffc0202374:	60a6                	ld	ra,72(sp)
ffffffffc0202376:	74e2                	ld	s1,56(sp)
ffffffffc0202378:	7942                	ld	s2,48(sp)
ffffffffc020237a:	79a2                	ld	s3,40(sp)
ffffffffc020237c:	7a02                	ld	s4,32(sp)
ffffffffc020237e:	6ae2                	ld	s5,24(sp)
ffffffffc0202380:	6b42                	ld	s6,16(sp)
ffffffffc0202382:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202384:	00003517          	auipc	a0,0x3
ffffffffc0202388:	39c50513          	addi	a0,a0,924 # ffffffffc0205720 <commands+0xfe8>
}
ffffffffc020238c:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc020238e:	d2dfd06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);//页面置换的初始化
ffffffffc0202392:	19f000ef          	jal	ra,ffffffffc0202d30 <swap_init_mm>
ffffffffc0202396:	b5d1                	j	ffffffffc020225a <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202398:	00003697          	auipc	a3,0x3
ffffffffc020239c:	1b868693          	addi	a3,a3,440 # ffffffffc0205550 <commands+0xe18>
ffffffffc02023a0:	00003617          	auipc	a2,0x3
ffffffffc02023a4:	c2060613          	addi	a2,a2,-992 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02023a8:	0df00593          	li	a1,223
ffffffffc02023ac:	00003517          	auipc	a0,0x3
ffffffffc02023b0:	11c50513          	addi	a0,a0,284 # ffffffffc02054c8 <commands+0xd90>
ffffffffc02023b4:	d4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02023b8:	00003697          	auipc	a3,0x3
ffffffffc02023bc:	25068693          	addi	a3,a3,592 # ffffffffc0205608 <commands+0xed0>
ffffffffc02023c0:	00003617          	auipc	a2,0x3
ffffffffc02023c4:	c0060613          	addi	a2,a2,-1024 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02023c8:	0f000593          	li	a1,240
ffffffffc02023cc:	00003517          	auipc	a0,0x3
ffffffffc02023d0:	0fc50513          	addi	a0,a0,252 # ffffffffc02054c8 <commands+0xd90>
ffffffffc02023d4:	d2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02023d8:	00003697          	auipc	a3,0x3
ffffffffc02023dc:	20068693          	addi	a3,a3,512 # ffffffffc02055d8 <commands+0xea0>
ffffffffc02023e0:	00003617          	auipc	a2,0x3
ffffffffc02023e4:	be060613          	addi	a2,a2,-1056 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02023e8:	0ef00593          	li	a1,239
ffffffffc02023ec:	00003517          	auipc	a0,0x3
ffffffffc02023f0:	0dc50513          	addi	a0,a0,220 # ffffffffc02054c8 <commands+0xd90>
ffffffffc02023f4:	d0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02023f8:	00003697          	auipc	a3,0x3
ffffffffc02023fc:	14068693          	addi	a3,a3,320 # ffffffffc0205538 <commands+0xe00>
ffffffffc0202400:	00003617          	auipc	a2,0x3
ffffffffc0202404:	bc060613          	addi	a2,a2,-1088 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202408:	0dd00593          	li	a1,221
ffffffffc020240c:	00003517          	auipc	a0,0x3
ffffffffc0202410:	0bc50513          	addi	a0,a0,188 # ffffffffc02054c8 <commands+0xd90>
ffffffffc0202414:	ceffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1 != NULL);
ffffffffc0202418:	00003697          	auipc	a3,0x3
ffffffffc020241c:	17068693          	addi	a3,a3,368 # ffffffffc0205588 <commands+0xe50>
ffffffffc0202420:	00003617          	auipc	a2,0x3
ffffffffc0202424:	ba060613          	addi	a2,a2,-1120 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202428:	0e500593          	li	a1,229
ffffffffc020242c:	00003517          	auipc	a0,0x3
ffffffffc0202430:	09c50513          	addi	a0,a0,156 # ffffffffc02054c8 <commands+0xd90>
ffffffffc0202434:	ccffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2 != NULL);
ffffffffc0202438:	00003697          	auipc	a3,0x3
ffffffffc020243c:	16068693          	addi	a3,a3,352 # ffffffffc0205598 <commands+0xe60>
ffffffffc0202440:	00003617          	auipc	a2,0x3
ffffffffc0202444:	b8060613          	addi	a2,a2,-1152 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202448:	0e700593          	li	a1,231
ffffffffc020244c:	00003517          	auipc	a0,0x3
ffffffffc0202450:	07c50513          	addi	a0,a0,124 # ffffffffc02054c8 <commands+0xd90>
ffffffffc0202454:	caffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma3 == NULL);
ffffffffc0202458:	00003697          	auipc	a3,0x3
ffffffffc020245c:	15068693          	addi	a3,a3,336 # ffffffffc02055a8 <commands+0xe70>
ffffffffc0202460:	00003617          	auipc	a2,0x3
ffffffffc0202464:	b6060613          	addi	a2,a2,-1184 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202468:	0e900593          	li	a1,233
ffffffffc020246c:	00003517          	auipc	a0,0x3
ffffffffc0202470:	05c50513          	addi	a0,a0,92 # ffffffffc02054c8 <commands+0xd90>
ffffffffc0202474:	c8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma4 == NULL);
ffffffffc0202478:	00003697          	auipc	a3,0x3
ffffffffc020247c:	14068693          	addi	a3,a3,320 # ffffffffc02055b8 <commands+0xe80>
ffffffffc0202480:	00003617          	auipc	a2,0x3
ffffffffc0202484:	b4060613          	addi	a2,a2,-1216 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202488:	0eb00593          	li	a1,235
ffffffffc020248c:	00003517          	auipc	a0,0x3
ffffffffc0202490:	03c50513          	addi	a0,a0,60 # ffffffffc02054c8 <commands+0xd90>
ffffffffc0202494:	c6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma5 == NULL);
ffffffffc0202498:	00003697          	auipc	a3,0x3
ffffffffc020249c:	13068693          	addi	a3,a3,304 # ffffffffc02055c8 <commands+0xe90>
ffffffffc02024a0:	00003617          	auipc	a2,0x3
ffffffffc02024a4:	b2060613          	addi	a2,a2,-1248 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02024a8:	0ed00593          	li	a1,237
ffffffffc02024ac:	00003517          	auipc	a0,0x3
ffffffffc02024b0:	01c50513          	addi	a0,a0,28 # ffffffffc02054c8 <commands+0xd90>
ffffffffc02024b4:	c4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02024b8:	00003697          	auipc	a3,0x3
ffffffffc02024bc:	20868693          	addi	a3,a3,520 # ffffffffc02056c0 <commands+0xf88>
ffffffffc02024c0:	00003617          	auipc	a2,0x3
ffffffffc02024c4:	b0060613          	addi	a2,a2,-1280 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02024c8:	10f00593          	li	a1,271
ffffffffc02024cc:	00003517          	auipc	a0,0x3
ffffffffc02024d0:	ffc50513          	addi	a0,a0,-4 # ffffffffc02054c8 <commands+0xd90>
ffffffffc02024d4:	c2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02024d8:	00003697          	auipc	a3,0x3
ffffffffc02024dc:	27068693          	addi	a3,a3,624 # ffffffffc0205748 <commands+0x1010>
ffffffffc02024e0:	00003617          	auipc	a2,0x3
ffffffffc02024e4:	ae060613          	addi	a2,a2,-1312 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02024e8:	10c00593          	li	a1,268
ffffffffc02024ec:	00003517          	auipc	a0,0x3
ffffffffc02024f0:	fdc50513          	addi	a0,a0,-36 # ffffffffc02054c8 <commands+0xd90>
    check_mm_struct = mm_create();
ffffffffc02024f4:	0000f797          	auipc	a5,0xf
ffffffffc02024f8:	0407b623          	sd	zero,76(a5) # ffffffffc0211540 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc02024fc:	c07fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(vma != NULL);
ffffffffc0202500:	00003697          	auipc	a3,0x3
ffffffffc0202504:	23868693          	addi	a3,a3,568 # ffffffffc0205738 <commands+0x1000>
ffffffffc0202508:	00003617          	auipc	a2,0x3
ffffffffc020250c:	ab860613          	addi	a2,a2,-1352 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202510:	11300593          	li	a1,275
ffffffffc0202514:	00003517          	auipc	a0,0x3
ffffffffc0202518:	fb450513          	addi	a0,a0,-76 # ffffffffc02054c8 <commands+0xd90>
ffffffffc020251c:	be7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0202520:	00003697          	auipc	a3,0x3
ffffffffc0202524:	1b068693          	addi	a3,a3,432 # ffffffffc02056d0 <commands+0xf98>
ffffffffc0202528:	00003617          	auipc	a2,0x3
ffffffffc020252c:	a9860613          	addi	a2,a2,-1384 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202530:	11800593          	li	a1,280
ffffffffc0202534:	00003517          	auipc	a0,0x3
ffffffffc0202538:	f9450513          	addi	a0,a0,-108 # ffffffffc02054c8 <commands+0xd90>
ffffffffc020253c:	bc7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(sum == 0);
ffffffffc0202540:	00003697          	auipc	a3,0x3
ffffffffc0202544:	1b068693          	addi	a3,a3,432 # ffffffffc02056f0 <commands+0xfb8>
ffffffffc0202548:	00003617          	auipc	a2,0x3
ffffffffc020254c:	a7860613          	addi	a2,a2,-1416 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202550:	12200593          	li	a1,290
ffffffffc0202554:	00003517          	auipc	a0,0x3
ffffffffc0202558:	f7450513          	addi	a0,a0,-140 # ffffffffc02054c8 <commands+0xd90>
ffffffffc020255c:	ba7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202560:	00003617          	auipc	a2,0x3
ffffffffc0202564:	8e060613          	addi	a2,a2,-1824 # ffffffffc0204e40 <commands+0x708>
ffffffffc0202568:	06500593          	li	a1,101
ffffffffc020256c:	00003517          	auipc	a0,0x3
ffffffffc0202570:	8f450513          	addi	a0,a0,-1804 # ffffffffc0204e60 <commands+0x728>
ffffffffc0202574:	b8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202578:	00003697          	auipc	a3,0x3
ffffffffc020257c:	10068693          	addi	a3,a3,256 # ffffffffc0205678 <commands+0xf40>
ffffffffc0202580:	00003617          	auipc	a2,0x3
ffffffffc0202584:	a4060613          	addi	a2,a2,-1472 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202588:	13000593          	li	a1,304
ffffffffc020258c:	00003517          	auipc	a0,0x3
ffffffffc0202590:	f3c50513          	addi	a0,a0,-196 # ffffffffc02054c8 <commands+0xd90>
ffffffffc0202594:	b6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202598:	00003697          	auipc	a3,0x3
ffffffffc020259c:	0e068693          	addi	a3,a3,224 # ffffffffc0205678 <commands+0xf40>
ffffffffc02025a0:	00003617          	auipc	a2,0x3
ffffffffc02025a4:	a2060613          	addi	a2,a2,-1504 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02025a8:	0bf00593          	li	a1,191
ffffffffc02025ac:	00003517          	auipc	a0,0x3
ffffffffc02025b0:	f1c50513          	addi	a0,a0,-228 # ffffffffc02054c8 <commands+0xd90>
ffffffffc02025b4:	b4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(mm != NULL);
ffffffffc02025b8:	00003697          	auipc	a3,0x3
ffffffffc02025bc:	1a868693          	addi	a3,a3,424 # ffffffffc0205760 <commands+0x1028>
ffffffffc02025c0:	00003617          	auipc	a2,0x3
ffffffffc02025c4:	a0060613          	addi	a2,a2,-1536 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02025c8:	0c900593          	li	a1,201
ffffffffc02025cc:	00003517          	auipc	a0,0x3
ffffffffc02025d0:	efc50513          	addi	a0,a0,-260 # ffffffffc02054c8 <commands+0xd90>
ffffffffc02025d4:	b2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02025d8:	00003697          	auipc	a3,0x3
ffffffffc02025dc:	0a068693          	addi	a3,a3,160 # ffffffffc0205678 <commands+0xf40>
ffffffffc02025e0:	00003617          	auipc	a2,0x3
ffffffffc02025e4:	9e060613          	addi	a2,a2,-1568 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02025e8:	0fd00593          	li	a1,253
ffffffffc02025ec:	00003517          	auipc	a0,0x3
ffffffffc02025f0:	edc50513          	addi	a0,a0,-292 # ffffffffc02054c8 <commands+0xd90>
ffffffffc02025f4:	b0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02025f8 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02025f8:	7179                	addi	sp,sp,-48
    // }

    //addr: 访问出错的虚拟地址
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02025fa:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02025fc:	f022                	sd	s0,32(sp)
ffffffffc02025fe:	ec26                	sd	s1,24(sp)
ffffffffc0202600:	f406                	sd	ra,40(sp)
ffffffffc0202602:	e84a                	sd	s2,16(sp)
ffffffffc0202604:	8432                	mv	s0,a2
ffffffffc0202606:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202608:	8d5ff0ef          	jal	ra,ffffffffc0201edc <find_vma>
    //在mm_struct里判断这个虚拟地址是否可用
    pgfault_num++;
ffffffffc020260c:	0000f797          	auipc	a5,0xf
ffffffffc0202610:	f3c7a783          	lw	a5,-196(a5) # ffffffffc0211548 <pgfault_num>
ffffffffc0202614:	2785                	addiw	a5,a5,1
ffffffffc0202616:	0000f717          	auipc	a4,0xf
ffffffffc020261a:	f2f72923          	sw	a5,-206(a4) # ffffffffc0211548 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc020261e:	c159                	beqz	a0,ffffffffc02026a4 <do_pgfault+0xac>
ffffffffc0202620:	651c                	ld	a5,8(a0)
ffffffffc0202622:	08f46163          	bltu	s0,a5,ffffffffc02026a4 <do_pgfault+0xac>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202626:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0202628:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020262a:	8b89                	andi	a5,a5,2
ffffffffc020262c:	ebb1                	bnez	a5,ffffffffc0202680 <do_pgfault+0x88>
        perm |= (PTE_R | PTE_W);
    }
    // perm &= ~PTE_R;

    addr = ROUNDDOWN(addr, PGSIZE);//按照页面大小把地址对齐
ffffffffc020262e:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0202630:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);//按照页面大小把地址对齐
ffffffffc0202632:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0202634:	85a2                	mv	a1,s0
ffffffffc0202636:	4605                	li	a2,1
ffffffffc0202638:	dbcfe0ef          	jal	ra,ffffffffc0200bf4 <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc020263c:	610c                	ld	a1,0(a0)
ffffffffc020263e:	c1b9                	beqz	a1,ffffffffc0202684 <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0202640:	0000f797          	auipc	a5,0xf
ffffffffc0202644:	f207a783          	lw	a5,-224(a5) # ffffffffc0211560 <swap_init_ok>
ffffffffc0202648:	c7bd                	beqz	a5,ffffffffc02026b6 <do_pgfault+0xbe>
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.

            swap_in(mm,addr,&page);
ffffffffc020264a:	85a2                	mv	a1,s0
ffffffffc020264c:	0030                	addi	a2,sp,8
ffffffffc020264e:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0202650:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc0202652:	00b000ef          	jal	ra,ffffffffc0202e5c <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0202656:	65a2                	ld	a1,8(sp)
ffffffffc0202658:	6c88                	ld	a0,24(s1)
ffffffffc020265a:	86ca                	mv	a3,s2
ffffffffc020265c:	8622                	mv	a2,s0
ffffffffc020265e:	881fe0ef          	jal	ra,ffffffffc0200ede <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc0202662:	6622                	ld	a2,8(sp)
ffffffffc0202664:	4685                	li	a3,1
ffffffffc0202666:	85a2                	mv	a1,s0
ffffffffc0202668:	8526                	mv	a0,s1
ffffffffc020266a:	6d2000ef          	jal	ra,ffffffffc0202d3c <swap_map_swappable>

            page->pra_vaddr = addr;
ffffffffc020266e:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0202670:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc0202672:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
ffffffffc0202674:	70a2                	ld	ra,40(sp)
ffffffffc0202676:	7402                	ld	s0,32(sp)
ffffffffc0202678:	64e2                	ld	s1,24(sp)
ffffffffc020267a:	6942                	ld	s2,16(sp)
ffffffffc020267c:	6145                	addi	sp,sp,48
ffffffffc020267e:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0202680:	4959                	li	s2,22
ffffffffc0202682:	b775                	j	ffffffffc020262e <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202684:	6c88                	ld	a0,24(s1)
ffffffffc0202686:	864a                	mv	a2,s2
ffffffffc0202688:	85a2                	mv	a1,s0
ffffffffc020268a:	d5eff0ef          	jal	ra,ffffffffc0201be8 <pgdir_alloc_page>
ffffffffc020268e:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0202690:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202692:	f3ed                	bnez	a5,ffffffffc0202674 <do_pgfault+0x7c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0202694:	00003517          	auipc	a0,0x3
ffffffffc0202698:	10c50513          	addi	a0,a0,268 # ffffffffc02057a0 <commands+0x1068>
ffffffffc020269c:	a1ffd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc02026a0:	5571                	li	a0,-4
            goto failed;
ffffffffc02026a2:	bfc9                	j	ffffffffc0202674 <do_pgfault+0x7c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02026a4:	85a2                	mv	a1,s0
ffffffffc02026a6:	00003517          	auipc	a0,0x3
ffffffffc02026aa:	0ca50513          	addi	a0,a0,202 # ffffffffc0205770 <commands+0x1038>
ffffffffc02026ae:	a0dfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc02026b2:	5575                	li	a0,-3
        goto failed;
ffffffffc02026b4:	b7c1                	j	ffffffffc0202674 <do_pgfault+0x7c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02026b6:	00003517          	auipc	a0,0x3
ffffffffc02026ba:	11250513          	addi	a0,a0,274 # ffffffffc02057c8 <commands+0x1090>
ffffffffc02026be:	9fdfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc02026c2:	5571                	li	a0,-4
            goto failed;
ffffffffc02026c4:	bf45                	j	ffffffffc0202674 <do_pgfault+0x7c>

ffffffffc02026c6 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02026c6:	7135                	addi	sp,sp,-160
ffffffffc02026c8:	ed06                	sd	ra,152(sp)
ffffffffc02026ca:	e922                	sd	s0,144(sp)
ffffffffc02026cc:	e526                	sd	s1,136(sp)
ffffffffc02026ce:	e14a                	sd	s2,128(sp)
ffffffffc02026d0:	fcce                	sd	s3,120(sp)
ffffffffc02026d2:	f8d2                	sd	s4,112(sp)
ffffffffc02026d4:	f4d6                	sd	s5,104(sp)
ffffffffc02026d6:	f0da                	sd	s6,96(sp)
ffffffffc02026d8:	ecde                	sd	s7,88(sp)
ffffffffc02026da:	e8e2                	sd	s8,80(sp)
ffffffffc02026dc:	e4e6                	sd	s9,72(sp)
ffffffffc02026de:	e0ea                	sd	s10,64(sp)
ffffffffc02026e0:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02026e2:	724010ef          	jal	ra,ffffffffc0203e06 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02026e6:	0000f697          	auipc	a3,0xf
ffffffffc02026ea:	e6a6b683          	ld	a3,-406(a3) # ffffffffc0211550 <max_swap_offset>
ffffffffc02026ee:	010007b7          	lui	a5,0x1000
ffffffffc02026f2:	ff968713          	addi	a4,a3,-7
ffffffffc02026f6:	17e1                	addi	a5,a5,-8
ffffffffc02026f8:	3ee7e063          	bltu	a5,a4,ffffffffc0202ad8 <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     //sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
     sm = &swap_manager_lru;
ffffffffc02026fc:	00008797          	auipc	a5,0x8
ffffffffc0202700:	90478793          	addi	a5,a5,-1788 # ffffffffc020a000 <swap_manager_lru>
     int r = sm->init();
ffffffffc0202704:	6798                	ld	a4,8(a5)
     sm = &swap_manager_lru;
ffffffffc0202706:	0000fb17          	auipc	s6,0xf
ffffffffc020270a:	e52b0b13          	addi	s6,s6,-430 # ffffffffc0211558 <sm>
ffffffffc020270e:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0202712:	9702                	jalr	a4
ffffffffc0202714:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc0202716:	c10d                	beqz	a0,ffffffffc0202738 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202718:	60ea                	ld	ra,152(sp)
ffffffffc020271a:	644a                	ld	s0,144(sp)
ffffffffc020271c:	64aa                	ld	s1,136(sp)
ffffffffc020271e:	690a                	ld	s2,128(sp)
ffffffffc0202720:	7a46                	ld	s4,112(sp)
ffffffffc0202722:	7aa6                	ld	s5,104(sp)
ffffffffc0202724:	7b06                	ld	s6,96(sp)
ffffffffc0202726:	6be6                	ld	s7,88(sp)
ffffffffc0202728:	6c46                	ld	s8,80(sp)
ffffffffc020272a:	6ca6                	ld	s9,72(sp)
ffffffffc020272c:	6d06                	ld	s10,64(sp)
ffffffffc020272e:	7de2                	ld	s11,56(sp)
ffffffffc0202730:	854e                	mv	a0,s3
ffffffffc0202732:	79e6                	ld	s3,120(sp)
ffffffffc0202734:	610d                	addi	sp,sp,160
ffffffffc0202736:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202738:	000b3783          	ld	a5,0(s6)
ffffffffc020273c:	00003517          	auipc	a0,0x3
ffffffffc0202740:	0e450513          	addi	a0,a0,228 # ffffffffc0205820 <commands+0x10e8>
ffffffffc0202744:	0000f497          	auipc	s1,0xf
ffffffffc0202748:	99c48493          	addi	s1,s1,-1636 # ffffffffc02110e0 <free_area>
ffffffffc020274c:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020274e:	4785                	li	a5,1
ffffffffc0202750:	0000f717          	auipc	a4,0xf
ffffffffc0202754:	e0f72823          	sw	a5,-496(a4) # ffffffffc0211560 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202758:	963fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020275c:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc020275e:	4401                	li	s0,0
ffffffffc0202760:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202762:	2c978163          	beq	a5,s1,ffffffffc0202a24 <swap_init+0x35e>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202766:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020276a:	8b09                	andi	a4,a4,2
ffffffffc020276c:	2a070e63          	beqz	a4,ffffffffc0202a28 <swap_init+0x362>
        count ++, total += p->property;
ffffffffc0202770:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202774:	679c                	ld	a5,8(a5)
ffffffffc0202776:	2d05                	addiw	s10,s10,1
ffffffffc0202778:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020277a:	fe9796e3          	bne	a5,s1,ffffffffc0202766 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc020277e:	8922                	mv	s2,s0
ffffffffc0202780:	c3afe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0202784:	47251663          	bne	a0,s2,ffffffffc0202bf0 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202788:	8622                	mv	a2,s0
ffffffffc020278a:	85ea                	mv	a1,s10
ffffffffc020278c:	00003517          	auipc	a0,0x3
ffffffffc0202790:	0dc50513          	addi	a0,a0,220 # ffffffffc0205868 <commands+0x1130>
ffffffffc0202794:	927fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202798:	eceff0ef          	jal	ra,ffffffffc0201e66 <mm_create>
ffffffffc020279c:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc020279e:	52050963          	beqz	a0,ffffffffc0202cd0 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02027a2:	0000f797          	auipc	a5,0xf
ffffffffc02027a6:	d9e78793          	addi	a5,a5,-610 # ffffffffc0211540 <check_mm_struct>
ffffffffc02027aa:	6398                	ld	a4,0(a5)
ffffffffc02027ac:	54071263          	bnez	a4,ffffffffc0202cf0 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02027b0:	0000fb97          	auipc	s7,0xf
ffffffffc02027b4:	d68bbb83          	ld	s7,-664(s7) # ffffffffc0211518 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc02027b8:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc02027bc:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02027be:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02027c2:	3c071763          	bnez	a4,ffffffffc0202b90 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02027c6:	6599                	lui	a1,0x6
ffffffffc02027c8:	460d                	li	a2,3
ffffffffc02027ca:	6505                	lui	a0,0x1
ffffffffc02027cc:	ee2ff0ef          	jal	ra,ffffffffc0201eae <vma_create>
ffffffffc02027d0:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02027d2:	3c050f63          	beqz	a0,ffffffffc0202bb0 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc02027d6:	8556                	mv	a0,s5
ffffffffc02027d8:	f44ff0ef          	jal	ra,ffffffffc0201f1c <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02027dc:	00003517          	auipc	a0,0x3
ffffffffc02027e0:	0cc50513          	addi	a0,a0,204 # ffffffffc02058a8 <commands+0x1170>
ffffffffc02027e4:	8d7fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02027e8:	018ab503          	ld	a0,24(s5)
ffffffffc02027ec:	4605                	li	a2,1
ffffffffc02027ee:	6585                	lui	a1,0x1
ffffffffc02027f0:	c04fe0ef          	jal	ra,ffffffffc0200bf4 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02027f4:	3c050e63          	beqz	a0,ffffffffc0202bd0 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02027f8:	00003517          	auipc	a0,0x3
ffffffffc02027fc:	10050513          	addi	a0,a0,256 # ffffffffc02058f8 <commands+0x11c0>
ffffffffc0202800:	0000f917          	auipc	s2,0xf
ffffffffc0202804:	87090913          	addi	s2,s2,-1936 # ffffffffc0211070 <check_rp>
ffffffffc0202808:	8b3fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020280c:	0000fa17          	auipc	s4,0xf
ffffffffc0202810:	884a0a13          	addi	s4,s4,-1916 # ffffffffc0211090 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202814:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0202816:	4505                	li	a0,1
ffffffffc0202818:	ad0fe0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc020281c:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202820:	28050c63          	beqz	a0,ffffffffc0202ab8 <swap_init+0x3f2>
ffffffffc0202824:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202826:	8b89                	andi	a5,a5,2
ffffffffc0202828:	26079863          	bnez	a5,ffffffffc0202a98 <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020282c:	0c21                	addi	s8,s8,8
ffffffffc020282e:	ff4c14e3          	bne	s8,s4,ffffffffc0202816 <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202832:	609c                	ld	a5,0(s1)
ffffffffc0202834:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202838:	e084                	sd	s1,0(s1)
ffffffffc020283a:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc020283c:	489c                	lw	a5,16(s1)
ffffffffc020283e:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202840:	0000fc17          	auipc	s8,0xf
ffffffffc0202844:	830c0c13          	addi	s8,s8,-2000 # ffffffffc0211070 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202848:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc020284a:	0000f797          	auipc	a5,0xf
ffffffffc020284e:	8a07a323          	sw	zero,-1882(a5) # ffffffffc02110f0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202852:	000c3503          	ld	a0,0(s8)
ffffffffc0202856:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202858:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc020285a:	b20fe0ef          	jal	ra,ffffffffc0200b7a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020285e:	ff4c1ae3          	bne	s8,s4,ffffffffc0202852 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202862:	0104ac03          	lw	s8,16(s1)
ffffffffc0202866:	4791                	li	a5,4
ffffffffc0202868:	4afc1463          	bne	s8,a5,ffffffffc0202d10 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020286c:	00003517          	auipc	a0,0x3
ffffffffc0202870:	11450513          	addi	a0,a0,276 # ffffffffc0205980 <commands+0x1248>
ffffffffc0202874:	847fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202878:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020287a:	0000f797          	auipc	a5,0xf
ffffffffc020287e:	cc07a723          	sw	zero,-818(a5) # ffffffffc0211548 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202882:	4529                	li	a0,10
ffffffffc0202884:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202888:	0000f597          	auipc	a1,0xf
ffffffffc020288c:	cc05a583          	lw	a1,-832(a1) # ffffffffc0211548 <pgfault_num>
ffffffffc0202890:	4805                	li	a6,1
ffffffffc0202892:	0000f797          	auipc	a5,0xf
ffffffffc0202896:	cb678793          	addi	a5,a5,-842 # ffffffffc0211548 <pgfault_num>
ffffffffc020289a:	3f059b63          	bne	a1,a6,ffffffffc0202c90 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020289e:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc02028a2:	4390                	lw	a2,0(a5)
ffffffffc02028a4:	2601                	sext.w	a2,a2
ffffffffc02028a6:	40b61563          	bne	a2,a1,ffffffffc0202cb0 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02028aa:	6589                	lui	a1,0x2
ffffffffc02028ac:	452d                	li	a0,11
ffffffffc02028ae:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc02028b2:	4390                	lw	a2,0(a5)
ffffffffc02028b4:	4809                	li	a6,2
ffffffffc02028b6:	2601                	sext.w	a2,a2
ffffffffc02028b8:	35061c63          	bne	a2,a6,ffffffffc0202c10 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02028bc:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc02028c0:	438c                	lw	a1,0(a5)
ffffffffc02028c2:	2581                	sext.w	a1,a1
ffffffffc02028c4:	36c59663          	bne	a1,a2,ffffffffc0202c30 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02028c8:	658d                	lui	a1,0x3
ffffffffc02028ca:	4531                	li	a0,12
ffffffffc02028cc:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc02028d0:	4390                	lw	a2,0(a5)
ffffffffc02028d2:	480d                	li	a6,3
ffffffffc02028d4:	2601                	sext.w	a2,a2
ffffffffc02028d6:	37061d63          	bne	a2,a6,ffffffffc0202c50 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02028da:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc02028de:	438c                	lw	a1,0(a5)
ffffffffc02028e0:	2581                	sext.w	a1,a1
ffffffffc02028e2:	38c59763          	bne	a1,a2,ffffffffc0202c70 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02028e6:	6591                	lui	a1,0x4
ffffffffc02028e8:	4535                	li	a0,13
ffffffffc02028ea:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc02028ee:	4390                	lw	a2,0(a5)
ffffffffc02028f0:	2601                	sext.w	a2,a2
ffffffffc02028f2:	21861f63          	bne	a2,s8,ffffffffc0202b10 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02028f6:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc02028fa:	439c                	lw	a5,0(a5)
ffffffffc02028fc:	2781                	sext.w	a5,a5
ffffffffc02028fe:	22c79963          	bne	a5,a2,ffffffffc0202b30 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202902:	489c                	lw	a5,16(s1)
ffffffffc0202904:	24079663          	bnez	a5,ffffffffc0202b50 <swap_init+0x48a>
ffffffffc0202908:	0000e797          	auipc	a5,0xe
ffffffffc020290c:	78878793          	addi	a5,a5,1928 # ffffffffc0211090 <swap_in_seq_no>
ffffffffc0202910:	0000e617          	auipc	a2,0xe
ffffffffc0202914:	7a860613          	addi	a2,a2,1960 # ffffffffc02110b8 <swap_out_seq_no>
ffffffffc0202918:	0000e517          	auipc	a0,0xe
ffffffffc020291c:	7a050513          	addi	a0,a0,1952 # ffffffffc02110b8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202920:	55fd                	li	a1,-1
ffffffffc0202922:	c38c                	sw	a1,0(a5)
ffffffffc0202924:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202926:	0791                	addi	a5,a5,4
ffffffffc0202928:	0611                	addi	a2,a2,4
ffffffffc020292a:	fef51ce3          	bne	a0,a5,ffffffffc0202922 <swap_init+0x25c>
ffffffffc020292e:	0000e817          	auipc	a6,0xe
ffffffffc0202932:	72280813          	addi	a6,a6,1826 # ffffffffc0211050 <check_ptep>
ffffffffc0202936:	0000e897          	auipc	a7,0xe
ffffffffc020293a:	73a88893          	addi	a7,a7,1850 # ffffffffc0211070 <check_rp>
ffffffffc020293e:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0202940:	0000fc97          	auipc	s9,0xf
ffffffffc0202944:	be8c8c93          	addi	s9,s9,-1048 # ffffffffc0211528 <pages>
ffffffffc0202948:	00004c17          	auipc	s8,0x4
ffffffffc020294c:	a48c0c13          	addi	s8,s8,-1464 # ffffffffc0206390 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202950:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202954:	4601                	li	a2,0
ffffffffc0202956:	855e                	mv	a0,s7
ffffffffc0202958:	ec46                	sd	a7,24(sp)
ffffffffc020295a:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc020295c:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020295e:	a96fe0ef          	jal	ra,ffffffffc0200bf4 <get_pte>
ffffffffc0202962:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202964:	65c2                	ld	a1,16(sp)
ffffffffc0202966:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202968:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc020296c:	0000f317          	auipc	t1,0xf
ffffffffc0202970:	bb430313          	addi	t1,t1,-1100 # ffffffffc0211520 <npage>
ffffffffc0202974:	16050e63          	beqz	a0,ffffffffc0202af0 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202978:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020297a:	0017f613          	andi	a2,a5,1
ffffffffc020297e:	0e060563          	beqz	a2,ffffffffc0202a68 <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0202982:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202986:	078a                	slli	a5,a5,0x2
ffffffffc0202988:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020298a:	0ec7fb63          	bgeu	a5,a2,ffffffffc0202a80 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc020298e:	000c3603          	ld	a2,0(s8)
ffffffffc0202992:	000cb503          	ld	a0,0(s9)
ffffffffc0202996:	0008bf03          	ld	t5,0(a7)
ffffffffc020299a:	8f91                	sub	a5,a5,a2
ffffffffc020299c:	00379613          	slli	a2,a5,0x3
ffffffffc02029a0:	97b2                	add	a5,a5,a2
ffffffffc02029a2:	078e                	slli	a5,a5,0x3
ffffffffc02029a4:	97aa                	add	a5,a5,a0
ffffffffc02029a6:	0aff1163          	bne	t5,a5,ffffffffc0202a48 <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029aa:	6785                	lui	a5,0x1
ffffffffc02029ac:	95be                	add	a1,a1,a5
ffffffffc02029ae:	6795                	lui	a5,0x5
ffffffffc02029b0:	0821                	addi	a6,a6,8
ffffffffc02029b2:	08a1                	addi	a7,a7,8
ffffffffc02029b4:	f8f59ee3          	bne	a1,a5,ffffffffc0202950 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02029b8:	00003517          	auipc	a0,0x3
ffffffffc02029bc:	08050513          	addi	a0,a0,128 # ffffffffc0205a38 <commands+0x1300>
ffffffffc02029c0:	efafd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc02029c4:	000b3783          	ld	a5,0(s6)
ffffffffc02029c8:	7f9c                	ld	a5,56(a5)
ffffffffc02029ca:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02029cc:	1a051263          	bnez	a0,ffffffffc0202b70 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02029d0:	00093503          	ld	a0,0(s2)
ffffffffc02029d4:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029d6:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc02029d8:	9a2fe0ef          	jal	ra,ffffffffc0200b7a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029dc:	ff491ae3          	bne	s2,s4,ffffffffc02029d0 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc02029e0:	8556                	mv	a0,s5
ffffffffc02029e2:	e0aff0ef          	jal	ra,ffffffffc0201fec <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc02029e6:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc02029e8:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc02029ec:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc02029ee:	7782                	ld	a5,32(sp)
ffffffffc02029f0:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02029f2:	009d8a63          	beq	s11,s1,ffffffffc0202a06 <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc02029f6:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc02029fa:	008dbd83          	ld	s11,8(s11)
ffffffffc02029fe:	3d7d                	addiw	s10,s10,-1
ffffffffc0202a00:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202a02:	fe9d9ae3          	bne	s11,s1,ffffffffc02029f6 <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202a06:	8622                	mv	a2,s0
ffffffffc0202a08:	85ea                	mv	a1,s10
ffffffffc0202a0a:	00003517          	auipc	a0,0x3
ffffffffc0202a0e:	05e50513          	addi	a0,a0,94 # ffffffffc0205a68 <commands+0x1330>
ffffffffc0202a12:	ea8fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202a16:	00003517          	auipc	a0,0x3
ffffffffc0202a1a:	07250513          	addi	a0,a0,114 # ffffffffc0205a88 <commands+0x1350>
ffffffffc0202a1e:	e9cfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0202a22:	b9dd                	j	ffffffffc0202718 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202a24:	4901                	li	s2,0
ffffffffc0202a26:	bba9                	j	ffffffffc0202780 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0202a28:	00003697          	auipc	a3,0x3
ffffffffc0202a2c:	e1068693          	addi	a3,a3,-496 # ffffffffc0205838 <commands+0x1100>
ffffffffc0202a30:	00002617          	auipc	a2,0x2
ffffffffc0202a34:	59060613          	addi	a2,a2,1424 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202a38:	0bd00593          	li	a1,189
ffffffffc0202a3c:	00003517          	auipc	a0,0x3
ffffffffc0202a40:	dd450513          	addi	a0,a0,-556 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202a44:	ebefd0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202a48:	00003697          	auipc	a3,0x3
ffffffffc0202a4c:	fc868693          	addi	a3,a3,-56 # ffffffffc0205a10 <commands+0x12d8>
ffffffffc0202a50:	00002617          	auipc	a2,0x2
ffffffffc0202a54:	57060613          	addi	a2,a2,1392 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202a58:	0fd00593          	li	a1,253
ffffffffc0202a5c:	00003517          	auipc	a0,0x3
ffffffffc0202a60:	db450513          	addi	a0,a0,-588 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202a64:	e9efd0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202a68:	00002617          	auipc	a2,0x2
ffffffffc0202a6c:	40860613          	addi	a2,a2,1032 # ffffffffc0204e70 <commands+0x738>
ffffffffc0202a70:	07000593          	li	a1,112
ffffffffc0202a74:	00002517          	auipc	a0,0x2
ffffffffc0202a78:	3ec50513          	addi	a0,a0,1004 # ffffffffc0204e60 <commands+0x728>
ffffffffc0202a7c:	e86fd0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202a80:	00002617          	auipc	a2,0x2
ffffffffc0202a84:	3c060613          	addi	a2,a2,960 # ffffffffc0204e40 <commands+0x708>
ffffffffc0202a88:	06500593          	li	a1,101
ffffffffc0202a8c:	00002517          	auipc	a0,0x2
ffffffffc0202a90:	3d450513          	addi	a0,a0,980 # ffffffffc0204e60 <commands+0x728>
ffffffffc0202a94:	e6efd0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202a98:	00003697          	auipc	a3,0x3
ffffffffc0202a9c:	ea068693          	addi	a3,a3,-352 # ffffffffc0205938 <commands+0x1200>
ffffffffc0202aa0:	00002617          	auipc	a2,0x2
ffffffffc0202aa4:	52060613          	addi	a2,a2,1312 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202aa8:	0de00593          	li	a1,222
ffffffffc0202aac:	00003517          	auipc	a0,0x3
ffffffffc0202ab0:	d6450513          	addi	a0,a0,-668 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202ab4:	e4efd0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202ab8:	00003697          	auipc	a3,0x3
ffffffffc0202abc:	e6868693          	addi	a3,a3,-408 # ffffffffc0205920 <commands+0x11e8>
ffffffffc0202ac0:	00002617          	auipc	a2,0x2
ffffffffc0202ac4:	50060613          	addi	a2,a2,1280 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202ac8:	0dd00593          	li	a1,221
ffffffffc0202acc:	00003517          	auipc	a0,0x3
ffffffffc0202ad0:	d4450513          	addi	a0,a0,-700 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202ad4:	e2efd0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202ad8:	00003617          	auipc	a2,0x3
ffffffffc0202adc:	d1860613          	addi	a2,a2,-744 # ffffffffc02057f0 <commands+0x10b8>
ffffffffc0202ae0:	02900593          	li	a1,41
ffffffffc0202ae4:	00003517          	auipc	a0,0x3
ffffffffc0202ae8:	d2c50513          	addi	a0,a0,-724 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202aec:	e16fd0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202af0:	00003697          	auipc	a3,0x3
ffffffffc0202af4:	f0868693          	addi	a3,a3,-248 # ffffffffc02059f8 <commands+0x12c0>
ffffffffc0202af8:	00002617          	auipc	a2,0x2
ffffffffc0202afc:	4c860613          	addi	a2,a2,1224 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202b00:	0fc00593          	li	a1,252
ffffffffc0202b04:	00003517          	auipc	a0,0x3
ffffffffc0202b08:	d0c50513          	addi	a0,a0,-756 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202b0c:	df6fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0202b10:	00003697          	auipc	a3,0x3
ffffffffc0202b14:	ec868693          	addi	a3,a3,-312 # ffffffffc02059d8 <commands+0x12a0>
ffffffffc0202b18:	00002617          	auipc	a2,0x2
ffffffffc0202b1c:	4a860613          	addi	a2,a2,1192 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202b20:	0a000593          	li	a1,160
ffffffffc0202b24:	00003517          	auipc	a0,0x3
ffffffffc0202b28:	cec50513          	addi	a0,a0,-788 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202b2c:	dd6fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0202b30:	00003697          	auipc	a3,0x3
ffffffffc0202b34:	ea868693          	addi	a3,a3,-344 # ffffffffc02059d8 <commands+0x12a0>
ffffffffc0202b38:	00002617          	auipc	a2,0x2
ffffffffc0202b3c:	48860613          	addi	a2,a2,1160 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202b40:	0a200593          	li	a1,162
ffffffffc0202b44:	00003517          	auipc	a0,0x3
ffffffffc0202b48:	ccc50513          	addi	a0,a0,-820 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202b4c:	db6fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert( nr_free == 0);         
ffffffffc0202b50:	00003697          	auipc	a3,0x3
ffffffffc0202b54:	e9868693          	addi	a3,a3,-360 # ffffffffc02059e8 <commands+0x12b0>
ffffffffc0202b58:	00002617          	auipc	a2,0x2
ffffffffc0202b5c:	46860613          	addi	a2,a2,1128 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202b60:	0f400593          	li	a1,244
ffffffffc0202b64:	00003517          	auipc	a0,0x3
ffffffffc0202b68:	cac50513          	addi	a0,a0,-852 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202b6c:	d96fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(ret==0);
ffffffffc0202b70:	00003697          	auipc	a3,0x3
ffffffffc0202b74:	ef068693          	addi	a3,a3,-272 # ffffffffc0205a60 <commands+0x1328>
ffffffffc0202b78:	00002617          	auipc	a2,0x2
ffffffffc0202b7c:	44860613          	addi	a2,a2,1096 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202b80:	10300593          	li	a1,259
ffffffffc0202b84:	00003517          	auipc	a0,0x3
ffffffffc0202b88:	c8c50513          	addi	a0,a0,-884 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202b8c:	d76fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202b90:	00003697          	auipc	a3,0x3
ffffffffc0202b94:	b3068693          	addi	a3,a3,-1232 # ffffffffc02056c0 <commands+0xf88>
ffffffffc0202b98:	00002617          	auipc	a2,0x2
ffffffffc0202b9c:	42860613          	addi	a2,a2,1064 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202ba0:	0cd00593          	li	a1,205
ffffffffc0202ba4:	00003517          	auipc	a0,0x3
ffffffffc0202ba8:	c6c50513          	addi	a0,a0,-916 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202bac:	d56fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(vma != NULL);
ffffffffc0202bb0:	00003697          	auipc	a3,0x3
ffffffffc0202bb4:	b8868693          	addi	a3,a3,-1144 # ffffffffc0205738 <commands+0x1000>
ffffffffc0202bb8:	00002617          	auipc	a2,0x2
ffffffffc0202bbc:	40860613          	addi	a2,a2,1032 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202bc0:	0d000593          	li	a1,208
ffffffffc0202bc4:	00003517          	auipc	a0,0x3
ffffffffc0202bc8:	c4c50513          	addi	a0,a0,-948 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202bcc:	d36fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202bd0:	00003697          	auipc	a3,0x3
ffffffffc0202bd4:	d1068693          	addi	a3,a3,-752 # ffffffffc02058e0 <commands+0x11a8>
ffffffffc0202bd8:	00002617          	auipc	a2,0x2
ffffffffc0202bdc:	3e860613          	addi	a2,a2,1000 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202be0:	0d800593          	li	a1,216
ffffffffc0202be4:	00003517          	auipc	a0,0x3
ffffffffc0202be8:	c2c50513          	addi	a0,a0,-980 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202bec:	d16fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202bf0:	00003697          	auipc	a3,0x3
ffffffffc0202bf4:	c5868693          	addi	a3,a3,-936 # ffffffffc0205848 <commands+0x1110>
ffffffffc0202bf8:	00002617          	auipc	a2,0x2
ffffffffc0202bfc:	3c860613          	addi	a2,a2,968 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202c00:	0c000593          	li	a1,192
ffffffffc0202c04:	00003517          	auipc	a0,0x3
ffffffffc0202c08:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202c0c:	cf6fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0202c10:	00003697          	auipc	a3,0x3
ffffffffc0202c14:	da868693          	addi	a3,a3,-600 # ffffffffc02059b8 <commands+0x1280>
ffffffffc0202c18:	00002617          	auipc	a2,0x2
ffffffffc0202c1c:	3a860613          	addi	a2,a2,936 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202c20:	09800593          	li	a1,152
ffffffffc0202c24:	00003517          	auipc	a0,0x3
ffffffffc0202c28:	bec50513          	addi	a0,a0,-1044 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202c2c:	cd6fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0202c30:	00003697          	auipc	a3,0x3
ffffffffc0202c34:	d8868693          	addi	a3,a3,-632 # ffffffffc02059b8 <commands+0x1280>
ffffffffc0202c38:	00002617          	auipc	a2,0x2
ffffffffc0202c3c:	38860613          	addi	a2,a2,904 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202c40:	09a00593          	li	a1,154
ffffffffc0202c44:	00003517          	auipc	a0,0x3
ffffffffc0202c48:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202c4c:	cb6fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0202c50:	00003697          	auipc	a3,0x3
ffffffffc0202c54:	d7868693          	addi	a3,a3,-648 # ffffffffc02059c8 <commands+0x1290>
ffffffffc0202c58:	00002617          	auipc	a2,0x2
ffffffffc0202c5c:	36860613          	addi	a2,a2,872 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202c60:	09c00593          	li	a1,156
ffffffffc0202c64:	00003517          	auipc	a0,0x3
ffffffffc0202c68:	bac50513          	addi	a0,a0,-1108 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202c6c:	c96fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0202c70:	00003697          	auipc	a3,0x3
ffffffffc0202c74:	d5868693          	addi	a3,a3,-680 # ffffffffc02059c8 <commands+0x1290>
ffffffffc0202c78:	00002617          	auipc	a2,0x2
ffffffffc0202c7c:	34860613          	addi	a2,a2,840 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202c80:	09e00593          	li	a1,158
ffffffffc0202c84:	00003517          	auipc	a0,0x3
ffffffffc0202c88:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202c8c:	c76fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0202c90:	00003697          	auipc	a3,0x3
ffffffffc0202c94:	d1868693          	addi	a3,a3,-744 # ffffffffc02059a8 <commands+0x1270>
ffffffffc0202c98:	00002617          	auipc	a2,0x2
ffffffffc0202c9c:	32860613          	addi	a2,a2,808 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202ca0:	09400593          	li	a1,148
ffffffffc0202ca4:	00003517          	auipc	a0,0x3
ffffffffc0202ca8:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202cac:	c56fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0202cb0:	00003697          	auipc	a3,0x3
ffffffffc0202cb4:	cf868693          	addi	a3,a3,-776 # ffffffffc02059a8 <commands+0x1270>
ffffffffc0202cb8:	00002617          	auipc	a2,0x2
ffffffffc0202cbc:	30860613          	addi	a2,a2,776 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202cc0:	09600593          	li	a1,150
ffffffffc0202cc4:	00003517          	auipc	a0,0x3
ffffffffc0202cc8:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202ccc:	c36fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(mm != NULL);
ffffffffc0202cd0:	00003697          	auipc	a3,0x3
ffffffffc0202cd4:	a9068693          	addi	a3,a3,-1392 # ffffffffc0205760 <commands+0x1028>
ffffffffc0202cd8:	00002617          	auipc	a2,0x2
ffffffffc0202cdc:	2e860613          	addi	a2,a2,744 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202ce0:	0c500593          	li	a1,197
ffffffffc0202ce4:	00003517          	auipc	a0,0x3
ffffffffc0202ce8:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202cec:	c16fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202cf0:	00003697          	auipc	a3,0x3
ffffffffc0202cf4:	ba068693          	addi	a3,a3,-1120 # ffffffffc0205890 <commands+0x1158>
ffffffffc0202cf8:	00002617          	auipc	a2,0x2
ffffffffc0202cfc:	2c860613          	addi	a2,a2,712 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202d00:	0c800593          	li	a1,200
ffffffffc0202d04:	00003517          	auipc	a0,0x3
ffffffffc0202d08:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202d0c:	bf6fd0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d10:	00003697          	auipc	a3,0x3
ffffffffc0202d14:	c4868693          	addi	a3,a3,-952 # ffffffffc0205958 <commands+0x1220>
ffffffffc0202d18:	00002617          	auipc	a2,0x2
ffffffffc0202d1c:	2a860613          	addi	a2,a2,680 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202d20:	0eb00593          	li	a1,235
ffffffffc0202d24:	00003517          	auipc	a0,0x3
ffffffffc0202d28:	aec50513          	addi	a0,a0,-1300 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202d2c:	bd6fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202d30 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202d30:	0000f797          	auipc	a5,0xf
ffffffffc0202d34:	8287b783          	ld	a5,-2008(a5) # ffffffffc0211558 <sm>
ffffffffc0202d38:	6b9c                	ld	a5,16(a5)
ffffffffc0202d3a:	8782                	jr	a5

ffffffffc0202d3c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202d3c:	0000f797          	auipc	a5,0xf
ffffffffc0202d40:	81c7b783          	ld	a5,-2020(a5) # ffffffffc0211558 <sm>
ffffffffc0202d44:	739c                	ld	a5,32(a5)
ffffffffc0202d46:	8782                	jr	a5

ffffffffc0202d48 <swap_out>:
{
ffffffffc0202d48:	711d                	addi	sp,sp,-96
ffffffffc0202d4a:	ec86                	sd	ra,88(sp)
ffffffffc0202d4c:	e8a2                	sd	s0,80(sp)
ffffffffc0202d4e:	e4a6                	sd	s1,72(sp)
ffffffffc0202d50:	e0ca                	sd	s2,64(sp)
ffffffffc0202d52:	fc4e                	sd	s3,56(sp)
ffffffffc0202d54:	f852                	sd	s4,48(sp)
ffffffffc0202d56:	f456                	sd	s5,40(sp)
ffffffffc0202d58:	f05a                	sd	s6,32(sp)
ffffffffc0202d5a:	ec5e                	sd	s7,24(sp)
ffffffffc0202d5c:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202d5e:	cde9                	beqz	a1,ffffffffc0202e38 <swap_out+0xf0>
ffffffffc0202d60:	8a2e                	mv	s4,a1
ffffffffc0202d62:	892a                	mv	s2,a0
ffffffffc0202d64:	8ab2                	mv	s5,a2
ffffffffc0202d66:	4401                	li	s0,0
ffffffffc0202d68:	0000e997          	auipc	s3,0xe
ffffffffc0202d6c:	7f098993          	addi	s3,s3,2032 # ffffffffc0211558 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202d70:	00003b17          	auipc	s6,0x3
ffffffffc0202d74:	d98b0b13          	addi	s6,s6,-616 # ffffffffc0205b08 <commands+0x13d0>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202d78:	00003b97          	auipc	s7,0x3
ffffffffc0202d7c:	d78b8b93          	addi	s7,s7,-648 # ffffffffc0205af0 <commands+0x13b8>
ffffffffc0202d80:	a825                	j	ffffffffc0202db8 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202d82:	67a2                	ld	a5,8(sp)
ffffffffc0202d84:	8626                	mv	a2,s1
ffffffffc0202d86:	85a2                	mv	a1,s0
ffffffffc0202d88:	63b4                	ld	a3,64(a5)
ffffffffc0202d8a:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202d8c:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202d8e:	82b1                	srli	a3,a3,0xc
ffffffffc0202d90:	0685                	addi	a3,a3,1
ffffffffc0202d92:	b28fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202d96:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202d98:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202d9a:	613c                	ld	a5,64(a0)
ffffffffc0202d9c:	83b1                	srli	a5,a5,0xc
ffffffffc0202d9e:	0785                	addi	a5,a5,1
ffffffffc0202da0:	07a2                	slli	a5,a5,0x8
ffffffffc0202da2:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202da6:	dd5fd0ef          	jal	ra,ffffffffc0200b7a <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202daa:	01893503          	ld	a0,24(s2)
ffffffffc0202dae:	85a6                	mv	a1,s1
ffffffffc0202db0:	e33fe0ef          	jal	ra,ffffffffc0201be2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202db4:	048a0d63          	beq	s4,s0,ffffffffc0202e0e <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202db8:	0009b783          	ld	a5,0(s3)
ffffffffc0202dbc:	8656                	mv	a2,s5
ffffffffc0202dbe:	002c                	addi	a1,sp,8
ffffffffc0202dc0:	7b9c                	ld	a5,48(a5)
ffffffffc0202dc2:	854a                	mv	a0,s2
ffffffffc0202dc4:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202dc6:	e12d                	bnez	a0,ffffffffc0202e28 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202dc8:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202dca:	01893503          	ld	a0,24(s2)
ffffffffc0202dce:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202dd0:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202dd2:	85a6                	mv	a1,s1
ffffffffc0202dd4:	e21fd0ef          	jal	ra,ffffffffc0200bf4 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202dd8:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202dda:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202ddc:	8b85                	andi	a5,a5,1
ffffffffc0202dde:	cfb9                	beqz	a5,ffffffffc0202e3c <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202de0:	65a2                	ld	a1,8(sp)
ffffffffc0202de2:	61bc                	ld	a5,64(a1)
ffffffffc0202de4:	83b1                	srli	a5,a5,0xc
ffffffffc0202de6:	0785                	addi	a5,a5,1
ffffffffc0202de8:	00879513          	slli	a0,a5,0x8
ffffffffc0202dec:	0ec010ef          	jal	ra,ffffffffc0203ed8 <swapfs_write>
ffffffffc0202df0:	d949                	beqz	a0,ffffffffc0202d82 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202df2:	855e                	mv	a0,s7
ffffffffc0202df4:	ac6fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202df8:	0009b783          	ld	a5,0(s3)
ffffffffc0202dfc:	6622                	ld	a2,8(sp)
ffffffffc0202dfe:	4681                	li	a3,0
ffffffffc0202e00:	739c                	ld	a5,32(a5)
ffffffffc0202e02:	85a6                	mv	a1,s1
ffffffffc0202e04:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202e06:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202e08:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202e0a:	fa8a17e3          	bne	s4,s0,ffffffffc0202db8 <swap_out+0x70>
}
ffffffffc0202e0e:	60e6                	ld	ra,88(sp)
ffffffffc0202e10:	8522                	mv	a0,s0
ffffffffc0202e12:	6446                	ld	s0,80(sp)
ffffffffc0202e14:	64a6                	ld	s1,72(sp)
ffffffffc0202e16:	6906                	ld	s2,64(sp)
ffffffffc0202e18:	79e2                	ld	s3,56(sp)
ffffffffc0202e1a:	7a42                	ld	s4,48(sp)
ffffffffc0202e1c:	7aa2                	ld	s5,40(sp)
ffffffffc0202e1e:	7b02                	ld	s6,32(sp)
ffffffffc0202e20:	6be2                	ld	s7,24(sp)
ffffffffc0202e22:	6c42                	ld	s8,16(sp)
ffffffffc0202e24:	6125                	addi	sp,sp,96
ffffffffc0202e26:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202e28:	85a2                	mv	a1,s0
ffffffffc0202e2a:	00003517          	auipc	a0,0x3
ffffffffc0202e2e:	c7e50513          	addi	a0,a0,-898 # ffffffffc0205aa8 <commands+0x1370>
ffffffffc0202e32:	a88fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc0202e36:	bfe1                	j	ffffffffc0202e0e <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202e38:	4401                	li	s0,0
ffffffffc0202e3a:	bfd1                	j	ffffffffc0202e0e <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202e3c:	00003697          	auipc	a3,0x3
ffffffffc0202e40:	c9c68693          	addi	a3,a3,-868 # ffffffffc0205ad8 <commands+0x13a0>
ffffffffc0202e44:	00002617          	auipc	a2,0x2
ffffffffc0202e48:	17c60613          	addi	a2,a2,380 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202e4c:	06900593          	li	a1,105
ffffffffc0202e50:	00003517          	auipc	a0,0x3
ffffffffc0202e54:	9c050513          	addi	a0,a0,-1600 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202e58:	aaafd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202e5c <swap_in>:
{
ffffffffc0202e5c:	7179                	addi	sp,sp,-48
ffffffffc0202e5e:	e84a                	sd	s2,16(sp)
ffffffffc0202e60:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202e62:	4505                	li	a0,1
{
ffffffffc0202e64:	ec26                	sd	s1,24(sp)
ffffffffc0202e66:	e44e                	sd	s3,8(sp)
ffffffffc0202e68:	f406                	sd	ra,40(sp)
ffffffffc0202e6a:	f022                	sd	s0,32(sp)
ffffffffc0202e6c:	84ae                	mv	s1,a1
ffffffffc0202e6e:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202e70:	c79fd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
     assert(result!=NULL);
ffffffffc0202e74:	c129                	beqz	a0,ffffffffc0202eb6 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202e76:	842a                	mv	s0,a0
ffffffffc0202e78:	01893503          	ld	a0,24(s2)
ffffffffc0202e7c:	4601                	li	a2,0
ffffffffc0202e7e:	85a6                	mv	a1,s1
ffffffffc0202e80:	d75fd0ef          	jal	ra,ffffffffc0200bf4 <get_pte>
ffffffffc0202e84:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202e86:	6108                	ld	a0,0(a0)
ffffffffc0202e88:	85a2                	mv	a1,s0
ffffffffc0202e8a:	7b5000ef          	jal	ra,ffffffffc0203e3e <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202e8e:	00093583          	ld	a1,0(s2)
ffffffffc0202e92:	8626                	mv	a2,s1
ffffffffc0202e94:	00003517          	auipc	a0,0x3
ffffffffc0202e98:	cc450513          	addi	a0,a0,-828 # ffffffffc0205b58 <commands+0x1420>
ffffffffc0202e9c:	81a1                	srli	a1,a1,0x8
ffffffffc0202e9e:	a1cfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0202ea2:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202ea4:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202ea8:	7402                	ld	s0,32(sp)
ffffffffc0202eaa:	64e2                	ld	s1,24(sp)
ffffffffc0202eac:	6942                	ld	s2,16(sp)
ffffffffc0202eae:	69a2                	ld	s3,8(sp)
ffffffffc0202eb0:	4501                	li	a0,0
ffffffffc0202eb2:	6145                	addi	sp,sp,48
ffffffffc0202eb4:	8082                	ret
     assert(result!=NULL);
ffffffffc0202eb6:	00003697          	auipc	a3,0x3
ffffffffc0202eba:	c9268693          	addi	a3,a3,-878 # ffffffffc0205b48 <commands+0x1410>
ffffffffc0202ebe:	00002617          	auipc	a2,0x2
ffffffffc0202ec2:	10260613          	addi	a2,a2,258 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0202ec6:	07f00593          	li	a1,127
ffffffffc0202eca:	00003517          	auipc	a0,0x3
ffffffffc0202ece:	94650513          	addi	a0,a0,-1722 # ffffffffc0205810 <commands+0x10d8>
ffffffffc0202ed2:	a30fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202ed6 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202ed6:	0000e797          	auipc	a5,0xe
ffffffffc0202eda:	20a78793          	addi	a5,a5,522 # ffffffffc02110e0 <free_area>
ffffffffc0202ede:	e79c                	sd	a5,8(a5)
ffffffffc0202ee0:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202ee2:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202ee6:	8082                	ret

ffffffffc0202ee8 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202ee8:	0000e517          	auipc	a0,0xe
ffffffffc0202eec:	20856503          	lwu	a0,520(a0) # ffffffffc02110f0 <free_area+0x10>
ffffffffc0202ef0:	8082                	ret

ffffffffc0202ef2 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202ef2:	715d                	addi	sp,sp,-80
ffffffffc0202ef4:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0202ef6:	0000e417          	auipc	s0,0xe
ffffffffc0202efa:	1ea40413          	addi	s0,s0,490 # ffffffffc02110e0 <free_area>
ffffffffc0202efe:	641c                	ld	a5,8(s0)
ffffffffc0202f00:	e486                	sd	ra,72(sp)
ffffffffc0202f02:	fc26                	sd	s1,56(sp)
ffffffffc0202f04:	f84a                	sd	s2,48(sp)
ffffffffc0202f06:	f44e                	sd	s3,40(sp)
ffffffffc0202f08:	f052                	sd	s4,32(sp)
ffffffffc0202f0a:	ec56                	sd	s5,24(sp)
ffffffffc0202f0c:	e85a                	sd	s6,16(sp)
ffffffffc0202f0e:	e45e                	sd	s7,8(sp)
ffffffffc0202f10:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202f12:	2c878763          	beq	a5,s0,ffffffffc02031e0 <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0202f16:	4481                	li	s1,0
ffffffffc0202f18:	4901                	li	s2,0
ffffffffc0202f1a:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202f1e:	8b09                	andi	a4,a4,2
ffffffffc0202f20:	2c070463          	beqz	a4,ffffffffc02031e8 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0202f24:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202f28:	679c                	ld	a5,8(a5)
ffffffffc0202f2a:	2905                	addiw	s2,s2,1
ffffffffc0202f2c:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202f2e:	fe8796e3          	bne	a5,s0,ffffffffc0202f1a <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0202f32:	89a6                	mv	s3,s1
ffffffffc0202f34:	c87fd0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0202f38:	71351863          	bne	a0,s3,ffffffffc0203648 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202f3c:	4505                	li	a0,1
ffffffffc0202f3e:	babfd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc0202f42:	8a2a                	mv	s4,a0
ffffffffc0202f44:	44050263          	beqz	a0,ffffffffc0203388 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202f48:	4505                	li	a0,1
ffffffffc0202f4a:	b9ffd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc0202f4e:	89aa                	mv	s3,a0
ffffffffc0202f50:	70050c63          	beqz	a0,ffffffffc0203668 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202f54:	4505                	li	a0,1
ffffffffc0202f56:	b93fd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc0202f5a:	8aaa                	mv	s5,a0
ffffffffc0202f5c:	4a050663          	beqz	a0,ffffffffc0203408 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202f60:	2b3a0463          	beq	s4,s3,ffffffffc0203208 <default_check+0x316>
ffffffffc0202f64:	2aaa0263          	beq	s4,a0,ffffffffc0203208 <default_check+0x316>
ffffffffc0202f68:	2aa98063          	beq	s3,a0,ffffffffc0203208 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202f6c:	000a2783          	lw	a5,0(s4)
ffffffffc0202f70:	2a079c63          	bnez	a5,ffffffffc0203228 <default_check+0x336>
ffffffffc0202f74:	0009a783          	lw	a5,0(s3)
ffffffffc0202f78:	2a079863          	bnez	a5,ffffffffc0203228 <default_check+0x336>
ffffffffc0202f7c:	411c                	lw	a5,0(a0)
ffffffffc0202f7e:	2a079563          	bnez	a5,ffffffffc0203228 <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202f82:	0000e797          	auipc	a5,0xe
ffffffffc0202f86:	5a67b783          	ld	a5,1446(a5) # ffffffffc0211528 <pages>
ffffffffc0202f8a:	40fa0733          	sub	a4,s4,a5
ffffffffc0202f8e:	870d                	srai	a4,a4,0x3
ffffffffc0202f90:	00003597          	auipc	a1,0x3
ffffffffc0202f94:	3f85b583          	ld	a1,1016(a1) # ffffffffc0206388 <error_string+0x38>
ffffffffc0202f98:	02b70733          	mul	a4,a4,a1
ffffffffc0202f9c:	00003617          	auipc	a2,0x3
ffffffffc0202fa0:	3f463603          	ld	a2,1012(a2) # ffffffffc0206390 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202fa4:	0000e697          	auipc	a3,0xe
ffffffffc0202fa8:	57c6b683          	ld	a3,1404(a3) # ffffffffc0211520 <npage>
ffffffffc0202fac:	06b2                	slli	a3,a3,0xc
ffffffffc0202fae:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202fb0:	0732                	slli	a4,a4,0xc
ffffffffc0202fb2:	28d77b63          	bgeu	a4,a3,ffffffffc0203248 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202fb6:	40f98733          	sub	a4,s3,a5
ffffffffc0202fba:	870d                	srai	a4,a4,0x3
ffffffffc0202fbc:	02b70733          	mul	a4,a4,a1
ffffffffc0202fc0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202fc2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202fc4:	4cd77263          	bgeu	a4,a3,ffffffffc0203488 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202fc8:	40f507b3          	sub	a5,a0,a5
ffffffffc0202fcc:	878d                	srai	a5,a5,0x3
ffffffffc0202fce:	02b787b3          	mul	a5,a5,a1
ffffffffc0202fd2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202fd4:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202fd6:	30d7f963          	bgeu	a5,a3,ffffffffc02032e8 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0202fda:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202fdc:	00043c03          	ld	s8,0(s0)
ffffffffc0202fe0:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0202fe4:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0202fe8:	e400                	sd	s0,8(s0)
ffffffffc0202fea:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0202fec:	0000e797          	auipc	a5,0xe
ffffffffc0202ff0:	1007a223          	sw	zero,260(a5) # ffffffffc02110f0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202ff4:	af5fd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc0202ff8:	2c051863          	bnez	a0,ffffffffc02032c8 <default_check+0x3d6>
    free_page(p0);
ffffffffc0202ffc:	4585                	li	a1,1
ffffffffc0202ffe:	8552                	mv	a0,s4
ffffffffc0203000:	b7bfd0ef          	jal	ra,ffffffffc0200b7a <free_pages>
    free_page(p1);
ffffffffc0203004:	4585                	li	a1,1
ffffffffc0203006:	854e                	mv	a0,s3
ffffffffc0203008:	b73fd0ef          	jal	ra,ffffffffc0200b7a <free_pages>
    free_page(p2);
ffffffffc020300c:	4585                	li	a1,1
ffffffffc020300e:	8556                	mv	a0,s5
ffffffffc0203010:	b6bfd0ef          	jal	ra,ffffffffc0200b7a <free_pages>
    assert(nr_free == 3);
ffffffffc0203014:	4818                	lw	a4,16(s0)
ffffffffc0203016:	478d                	li	a5,3
ffffffffc0203018:	28f71863          	bne	a4,a5,ffffffffc02032a8 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020301c:	4505                	li	a0,1
ffffffffc020301e:	acbfd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc0203022:	89aa                	mv	s3,a0
ffffffffc0203024:	26050263          	beqz	a0,ffffffffc0203288 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203028:	4505                	li	a0,1
ffffffffc020302a:	abffd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc020302e:	8aaa                	mv	s5,a0
ffffffffc0203030:	3a050c63          	beqz	a0,ffffffffc02033e8 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203034:	4505                	li	a0,1
ffffffffc0203036:	ab3fd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc020303a:	8a2a                	mv	s4,a0
ffffffffc020303c:	38050663          	beqz	a0,ffffffffc02033c8 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0203040:	4505                	li	a0,1
ffffffffc0203042:	aa7fd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc0203046:	36051163          	bnez	a0,ffffffffc02033a8 <default_check+0x4b6>
    free_page(p0);
ffffffffc020304a:	4585                	li	a1,1
ffffffffc020304c:	854e                	mv	a0,s3
ffffffffc020304e:	b2dfd0ef          	jal	ra,ffffffffc0200b7a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0203052:	641c                	ld	a5,8(s0)
ffffffffc0203054:	20878a63          	beq	a5,s0,ffffffffc0203268 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0203058:	4505                	li	a0,1
ffffffffc020305a:	a8ffd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc020305e:	30a99563          	bne	s3,a0,ffffffffc0203368 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0203062:	4505                	li	a0,1
ffffffffc0203064:	a85fd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc0203068:	2e051063          	bnez	a0,ffffffffc0203348 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc020306c:	481c                	lw	a5,16(s0)
ffffffffc020306e:	2a079d63          	bnez	a5,ffffffffc0203328 <default_check+0x436>
    free_page(p);
ffffffffc0203072:	854e                	mv	a0,s3
ffffffffc0203074:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0203076:	01843023          	sd	s8,0(s0)
ffffffffc020307a:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc020307e:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0203082:	af9fd0ef          	jal	ra,ffffffffc0200b7a <free_pages>
    free_page(p1);
ffffffffc0203086:	4585                	li	a1,1
ffffffffc0203088:	8556                	mv	a0,s5
ffffffffc020308a:	af1fd0ef          	jal	ra,ffffffffc0200b7a <free_pages>
    free_page(p2);
ffffffffc020308e:	4585                	li	a1,1
ffffffffc0203090:	8552                	mv	a0,s4
ffffffffc0203092:	ae9fd0ef          	jal	ra,ffffffffc0200b7a <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0203096:	4515                	li	a0,5
ffffffffc0203098:	a51fd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc020309c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020309e:	26050563          	beqz	a0,ffffffffc0203308 <default_check+0x416>
ffffffffc02030a2:	651c                	ld	a5,8(a0)
ffffffffc02030a4:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02030a6:	8b85                	andi	a5,a5,1
ffffffffc02030a8:	54079063          	bnez	a5,ffffffffc02035e8 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02030ac:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02030ae:	00043b03          	ld	s6,0(s0)
ffffffffc02030b2:	00843a83          	ld	s5,8(s0)
ffffffffc02030b6:	e000                	sd	s0,0(s0)
ffffffffc02030b8:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02030ba:	a2ffd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc02030be:	50051563          	bnez	a0,ffffffffc02035c8 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02030c2:	09098a13          	addi	s4,s3,144
ffffffffc02030c6:	8552                	mv	a0,s4
ffffffffc02030c8:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02030ca:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02030ce:	0000e797          	auipc	a5,0xe
ffffffffc02030d2:	0207a123          	sw	zero,34(a5) # ffffffffc02110f0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02030d6:	aa5fd0ef          	jal	ra,ffffffffc0200b7a <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02030da:	4511                	li	a0,4
ffffffffc02030dc:	a0dfd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc02030e0:	4c051463          	bnez	a0,ffffffffc02035a8 <default_check+0x6b6>
ffffffffc02030e4:	0989b783          	ld	a5,152(s3)
ffffffffc02030e8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02030ea:	8b85                	andi	a5,a5,1
ffffffffc02030ec:	48078e63          	beqz	a5,ffffffffc0203588 <default_check+0x696>
ffffffffc02030f0:	0a89a703          	lw	a4,168(s3)
ffffffffc02030f4:	478d                	li	a5,3
ffffffffc02030f6:	48f71963          	bne	a4,a5,ffffffffc0203588 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02030fa:	450d                	li	a0,3
ffffffffc02030fc:	9edfd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc0203100:	8c2a                	mv	s8,a0
ffffffffc0203102:	46050363          	beqz	a0,ffffffffc0203568 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0203106:	4505                	li	a0,1
ffffffffc0203108:	9e1fd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc020310c:	42051e63          	bnez	a0,ffffffffc0203548 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0203110:	418a1c63          	bne	s4,s8,ffffffffc0203528 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0203114:	4585                	li	a1,1
ffffffffc0203116:	854e                	mv	a0,s3
ffffffffc0203118:	a63fd0ef          	jal	ra,ffffffffc0200b7a <free_pages>
    free_pages(p1, 3);
ffffffffc020311c:	458d                	li	a1,3
ffffffffc020311e:	8552                	mv	a0,s4
ffffffffc0203120:	a5bfd0ef          	jal	ra,ffffffffc0200b7a <free_pages>
ffffffffc0203124:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0203128:	04898c13          	addi	s8,s3,72
ffffffffc020312c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020312e:	8b85                	andi	a5,a5,1
ffffffffc0203130:	3c078c63          	beqz	a5,ffffffffc0203508 <default_check+0x616>
ffffffffc0203134:	0189a703          	lw	a4,24(s3)
ffffffffc0203138:	4785                	li	a5,1
ffffffffc020313a:	3cf71763          	bne	a4,a5,ffffffffc0203508 <default_check+0x616>
ffffffffc020313e:	008a3783          	ld	a5,8(s4)
ffffffffc0203142:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203144:	8b85                	andi	a5,a5,1
ffffffffc0203146:	3a078163          	beqz	a5,ffffffffc02034e8 <default_check+0x5f6>
ffffffffc020314a:	018a2703          	lw	a4,24(s4)
ffffffffc020314e:	478d                	li	a5,3
ffffffffc0203150:	38f71c63          	bne	a4,a5,ffffffffc02034e8 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203154:	4505                	li	a0,1
ffffffffc0203156:	993fd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc020315a:	36a99763          	bne	s3,a0,ffffffffc02034c8 <default_check+0x5d6>
    free_page(p0);
ffffffffc020315e:	4585                	li	a1,1
ffffffffc0203160:	a1bfd0ef          	jal	ra,ffffffffc0200b7a <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203164:	4509                	li	a0,2
ffffffffc0203166:	983fd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc020316a:	32aa1f63          	bne	s4,a0,ffffffffc02034a8 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc020316e:	4589                	li	a1,2
ffffffffc0203170:	a0bfd0ef          	jal	ra,ffffffffc0200b7a <free_pages>
    free_page(p2);
ffffffffc0203174:	4585                	li	a1,1
ffffffffc0203176:	8562                	mv	a0,s8
ffffffffc0203178:	a03fd0ef          	jal	ra,ffffffffc0200b7a <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020317c:	4515                	li	a0,5
ffffffffc020317e:	96bfd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc0203182:	89aa                	mv	s3,a0
ffffffffc0203184:	48050263          	beqz	a0,ffffffffc0203608 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0203188:	4505                	li	a0,1
ffffffffc020318a:	95ffd0ef          	jal	ra,ffffffffc0200ae8 <alloc_pages>
ffffffffc020318e:	2c051d63          	bnez	a0,ffffffffc0203468 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0203192:	481c                	lw	a5,16(s0)
ffffffffc0203194:	2a079a63          	bnez	a5,ffffffffc0203448 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0203198:	4595                	li	a1,5
ffffffffc020319a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020319c:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02031a0:	01643023          	sd	s6,0(s0)
ffffffffc02031a4:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02031a8:	9d3fd0ef          	jal	ra,ffffffffc0200b7a <free_pages>
    return listelm->next;
ffffffffc02031ac:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02031ae:	00878963          	beq	a5,s0,ffffffffc02031c0 <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02031b2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02031b6:	679c                	ld	a5,8(a5)
ffffffffc02031b8:	397d                	addiw	s2,s2,-1
ffffffffc02031ba:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02031bc:	fe879be3          	bne	a5,s0,ffffffffc02031b2 <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc02031c0:	26091463          	bnez	s2,ffffffffc0203428 <default_check+0x536>
    assert(total == 0);
ffffffffc02031c4:	46049263          	bnez	s1,ffffffffc0203628 <default_check+0x736>
}
ffffffffc02031c8:	60a6                	ld	ra,72(sp)
ffffffffc02031ca:	6406                	ld	s0,64(sp)
ffffffffc02031cc:	74e2                	ld	s1,56(sp)
ffffffffc02031ce:	7942                	ld	s2,48(sp)
ffffffffc02031d0:	79a2                	ld	s3,40(sp)
ffffffffc02031d2:	7a02                	ld	s4,32(sp)
ffffffffc02031d4:	6ae2                	ld	s5,24(sp)
ffffffffc02031d6:	6b42                	ld	s6,16(sp)
ffffffffc02031d8:	6ba2                	ld	s7,8(sp)
ffffffffc02031da:	6c02                	ld	s8,0(sp)
ffffffffc02031dc:	6161                	addi	sp,sp,80
ffffffffc02031de:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02031e0:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02031e2:	4481                	li	s1,0
ffffffffc02031e4:	4901                	li	s2,0
ffffffffc02031e6:	b3b9                	j	ffffffffc0202f34 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02031e8:	00002697          	auipc	a3,0x2
ffffffffc02031ec:	65068693          	addi	a3,a3,1616 # ffffffffc0205838 <commands+0x1100>
ffffffffc02031f0:	00002617          	auipc	a2,0x2
ffffffffc02031f4:	dd060613          	addi	a2,a2,-560 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02031f8:	0f000593          	li	a1,240
ffffffffc02031fc:	00003517          	auipc	a0,0x3
ffffffffc0203200:	99c50513          	addi	a0,a0,-1636 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203204:	efffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203208:	00003697          	auipc	a3,0x3
ffffffffc020320c:	a0868693          	addi	a3,a3,-1528 # ffffffffc0205c10 <commands+0x14d8>
ffffffffc0203210:	00002617          	auipc	a2,0x2
ffffffffc0203214:	db060613          	addi	a2,a2,-592 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203218:	0bd00593          	li	a1,189
ffffffffc020321c:	00003517          	auipc	a0,0x3
ffffffffc0203220:	97c50513          	addi	a0,a0,-1668 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203224:	edffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203228:	00003697          	auipc	a3,0x3
ffffffffc020322c:	a1068693          	addi	a3,a3,-1520 # ffffffffc0205c38 <commands+0x1500>
ffffffffc0203230:	00002617          	auipc	a2,0x2
ffffffffc0203234:	d9060613          	addi	a2,a2,-624 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203238:	0be00593          	li	a1,190
ffffffffc020323c:	00003517          	auipc	a0,0x3
ffffffffc0203240:	95c50513          	addi	a0,a0,-1700 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203244:	ebffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203248:	00003697          	auipc	a3,0x3
ffffffffc020324c:	a3068693          	addi	a3,a3,-1488 # ffffffffc0205c78 <commands+0x1540>
ffffffffc0203250:	00002617          	auipc	a2,0x2
ffffffffc0203254:	d7060613          	addi	a2,a2,-656 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203258:	0c000593          	li	a1,192
ffffffffc020325c:	00003517          	auipc	a0,0x3
ffffffffc0203260:	93c50513          	addi	a0,a0,-1732 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203264:	e9ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0203268:	00003697          	auipc	a3,0x3
ffffffffc020326c:	a9868693          	addi	a3,a3,-1384 # ffffffffc0205d00 <commands+0x15c8>
ffffffffc0203270:	00002617          	auipc	a2,0x2
ffffffffc0203274:	d5060613          	addi	a2,a2,-688 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203278:	0d900593          	li	a1,217
ffffffffc020327c:	00003517          	auipc	a0,0x3
ffffffffc0203280:	91c50513          	addi	a0,a0,-1764 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203284:	e7ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203288:	00003697          	auipc	a3,0x3
ffffffffc020328c:	92868693          	addi	a3,a3,-1752 # ffffffffc0205bb0 <commands+0x1478>
ffffffffc0203290:	00002617          	auipc	a2,0x2
ffffffffc0203294:	d3060613          	addi	a2,a2,-720 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203298:	0d200593          	li	a1,210
ffffffffc020329c:	00003517          	auipc	a0,0x3
ffffffffc02032a0:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02032a4:	e5ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 3);
ffffffffc02032a8:	00003697          	auipc	a3,0x3
ffffffffc02032ac:	a4868693          	addi	a3,a3,-1464 # ffffffffc0205cf0 <commands+0x15b8>
ffffffffc02032b0:	00002617          	auipc	a2,0x2
ffffffffc02032b4:	d1060613          	addi	a2,a2,-752 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02032b8:	0d000593          	li	a1,208
ffffffffc02032bc:	00003517          	auipc	a0,0x3
ffffffffc02032c0:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02032c4:	e3ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02032c8:	00003697          	auipc	a3,0x3
ffffffffc02032cc:	a1068693          	addi	a3,a3,-1520 # ffffffffc0205cd8 <commands+0x15a0>
ffffffffc02032d0:	00002617          	auipc	a2,0x2
ffffffffc02032d4:	cf060613          	addi	a2,a2,-784 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02032d8:	0cb00593          	li	a1,203
ffffffffc02032dc:	00003517          	auipc	a0,0x3
ffffffffc02032e0:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02032e4:	e1ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02032e8:	00003697          	auipc	a3,0x3
ffffffffc02032ec:	9d068693          	addi	a3,a3,-1584 # ffffffffc0205cb8 <commands+0x1580>
ffffffffc02032f0:	00002617          	auipc	a2,0x2
ffffffffc02032f4:	cd060613          	addi	a2,a2,-816 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02032f8:	0c200593          	li	a1,194
ffffffffc02032fc:	00003517          	auipc	a0,0x3
ffffffffc0203300:	89c50513          	addi	a0,a0,-1892 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203304:	dfffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != NULL);
ffffffffc0203308:	00003697          	auipc	a3,0x3
ffffffffc020330c:	a3068693          	addi	a3,a3,-1488 # ffffffffc0205d38 <commands+0x1600>
ffffffffc0203310:	00002617          	auipc	a2,0x2
ffffffffc0203314:	cb060613          	addi	a2,a2,-848 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203318:	0f800593          	li	a1,248
ffffffffc020331c:	00003517          	auipc	a0,0x3
ffffffffc0203320:	87c50513          	addi	a0,a0,-1924 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203324:	ddffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc0203328:	00002697          	auipc	a3,0x2
ffffffffc020332c:	6c068693          	addi	a3,a3,1728 # ffffffffc02059e8 <commands+0x12b0>
ffffffffc0203330:	00002617          	auipc	a2,0x2
ffffffffc0203334:	c9060613          	addi	a2,a2,-880 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203338:	0df00593          	li	a1,223
ffffffffc020333c:	00003517          	auipc	a0,0x3
ffffffffc0203340:	85c50513          	addi	a0,a0,-1956 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203344:	dbffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203348:	00003697          	auipc	a3,0x3
ffffffffc020334c:	99068693          	addi	a3,a3,-1648 # ffffffffc0205cd8 <commands+0x15a0>
ffffffffc0203350:	00002617          	auipc	a2,0x2
ffffffffc0203354:	c7060613          	addi	a2,a2,-912 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203358:	0dd00593          	li	a1,221
ffffffffc020335c:	00003517          	auipc	a0,0x3
ffffffffc0203360:	83c50513          	addi	a0,a0,-1988 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203364:	d9ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0203368:	00003697          	auipc	a3,0x3
ffffffffc020336c:	9b068693          	addi	a3,a3,-1616 # ffffffffc0205d18 <commands+0x15e0>
ffffffffc0203370:	00002617          	auipc	a2,0x2
ffffffffc0203374:	c5060613          	addi	a2,a2,-944 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203378:	0dc00593          	li	a1,220
ffffffffc020337c:	00003517          	auipc	a0,0x3
ffffffffc0203380:	81c50513          	addi	a0,a0,-2020 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203384:	d7ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203388:	00003697          	auipc	a3,0x3
ffffffffc020338c:	82868693          	addi	a3,a3,-2008 # ffffffffc0205bb0 <commands+0x1478>
ffffffffc0203390:	00002617          	auipc	a2,0x2
ffffffffc0203394:	c3060613          	addi	a2,a2,-976 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203398:	0b900593          	li	a1,185
ffffffffc020339c:	00002517          	auipc	a0,0x2
ffffffffc02033a0:	7fc50513          	addi	a0,a0,2044 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02033a4:	d5ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02033a8:	00003697          	auipc	a3,0x3
ffffffffc02033ac:	93068693          	addi	a3,a3,-1744 # ffffffffc0205cd8 <commands+0x15a0>
ffffffffc02033b0:	00002617          	auipc	a2,0x2
ffffffffc02033b4:	c1060613          	addi	a2,a2,-1008 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02033b8:	0d600593          	li	a1,214
ffffffffc02033bc:	00002517          	auipc	a0,0x2
ffffffffc02033c0:	7dc50513          	addi	a0,a0,2012 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02033c4:	d3ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02033c8:	00003697          	auipc	a3,0x3
ffffffffc02033cc:	82868693          	addi	a3,a3,-2008 # ffffffffc0205bf0 <commands+0x14b8>
ffffffffc02033d0:	00002617          	auipc	a2,0x2
ffffffffc02033d4:	bf060613          	addi	a2,a2,-1040 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02033d8:	0d400593          	li	a1,212
ffffffffc02033dc:	00002517          	auipc	a0,0x2
ffffffffc02033e0:	7bc50513          	addi	a0,a0,1980 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02033e4:	d1ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02033e8:	00002697          	auipc	a3,0x2
ffffffffc02033ec:	7e868693          	addi	a3,a3,2024 # ffffffffc0205bd0 <commands+0x1498>
ffffffffc02033f0:	00002617          	auipc	a2,0x2
ffffffffc02033f4:	bd060613          	addi	a2,a2,-1072 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02033f8:	0d300593          	li	a1,211
ffffffffc02033fc:	00002517          	auipc	a0,0x2
ffffffffc0203400:	79c50513          	addi	a0,a0,1948 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203404:	cfffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203408:	00002697          	auipc	a3,0x2
ffffffffc020340c:	7e868693          	addi	a3,a3,2024 # ffffffffc0205bf0 <commands+0x14b8>
ffffffffc0203410:	00002617          	auipc	a2,0x2
ffffffffc0203414:	bb060613          	addi	a2,a2,-1104 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203418:	0bb00593          	li	a1,187
ffffffffc020341c:	00002517          	auipc	a0,0x2
ffffffffc0203420:	77c50513          	addi	a0,a0,1916 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203424:	cdffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(count == 0);
ffffffffc0203428:	00003697          	auipc	a3,0x3
ffffffffc020342c:	a6068693          	addi	a3,a3,-1440 # ffffffffc0205e88 <commands+0x1750>
ffffffffc0203430:	00002617          	auipc	a2,0x2
ffffffffc0203434:	b9060613          	addi	a2,a2,-1136 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203438:	12500593          	li	a1,293
ffffffffc020343c:	00002517          	auipc	a0,0x2
ffffffffc0203440:	75c50513          	addi	a0,a0,1884 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203444:	cbffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc0203448:	00002697          	auipc	a3,0x2
ffffffffc020344c:	5a068693          	addi	a3,a3,1440 # ffffffffc02059e8 <commands+0x12b0>
ffffffffc0203450:	00002617          	auipc	a2,0x2
ffffffffc0203454:	b7060613          	addi	a2,a2,-1168 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203458:	11a00593          	li	a1,282
ffffffffc020345c:	00002517          	auipc	a0,0x2
ffffffffc0203460:	73c50513          	addi	a0,a0,1852 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203464:	c9ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203468:	00003697          	auipc	a3,0x3
ffffffffc020346c:	87068693          	addi	a3,a3,-1936 # ffffffffc0205cd8 <commands+0x15a0>
ffffffffc0203470:	00002617          	auipc	a2,0x2
ffffffffc0203474:	b5060613          	addi	a2,a2,-1200 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203478:	11800593          	li	a1,280
ffffffffc020347c:	00002517          	auipc	a0,0x2
ffffffffc0203480:	71c50513          	addi	a0,a0,1820 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203484:	c7ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203488:	00003697          	auipc	a3,0x3
ffffffffc020348c:	81068693          	addi	a3,a3,-2032 # ffffffffc0205c98 <commands+0x1560>
ffffffffc0203490:	00002617          	auipc	a2,0x2
ffffffffc0203494:	b3060613          	addi	a2,a2,-1232 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203498:	0c100593          	li	a1,193
ffffffffc020349c:	00002517          	auipc	a0,0x2
ffffffffc02034a0:	6fc50513          	addi	a0,a0,1788 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02034a4:	c5ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02034a8:	00003697          	auipc	a3,0x3
ffffffffc02034ac:	9a068693          	addi	a3,a3,-1632 # ffffffffc0205e48 <commands+0x1710>
ffffffffc02034b0:	00002617          	auipc	a2,0x2
ffffffffc02034b4:	b1060613          	addi	a2,a2,-1264 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02034b8:	11200593          	li	a1,274
ffffffffc02034bc:	00002517          	auipc	a0,0x2
ffffffffc02034c0:	6dc50513          	addi	a0,a0,1756 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02034c4:	c3ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02034c8:	00003697          	auipc	a3,0x3
ffffffffc02034cc:	96068693          	addi	a3,a3,-1696 # ffffffffc0205e28 <commands+0x16f0>
ffffffffc02034d0:	00002617          	auipc	a2,0x2
ffffffffc02034d4:	af060613          	addi	a2,a2,-1296 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02034d8:	11000593          	li	a1,272
ffffffffc02034dc:	00002517          	auipc	a0,0x2
ffffffffc02034e0:	6bc50513          	addi	a0,a0,1724 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02034e4:	c1ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02034e8:	00003697          	auipc	a3,0x3
ffffffffc02034ec:	91868693          	addi	a3,a3,-1768 # ffffffffc0205e00 <commands+0x16c8>
ffffffffc02034f0:	00002617          	auipc	a2,0x2
ffffffffc02034f4:	ad060613          	addi	a2,a2,-1328 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02034f8:	10e00593          	li	a1,270
ffffffffc02034fc:	00002517          	auipc	a0,0x2
ffffffffc0203500:	69c50513          	addi	a0,a0,1692 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203504:	bfffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203508:	00003697          	auipc	a3,0x3
ffffffffc020350c:	8d068693          	addi	a3,a3,-1840 # ffffffffc0205dd8 <commands+0x16a0>
ffffffffc0203510:	00002617          	auipc	a2,0x2
ffffffffc0203514:	ab060613          	addi	a2,a2,-1360 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203518:	10d00593          	li	a1,269
ffffffffc020351c:	00002517          	auipc	a0,0x2
ffffffffc0203520:	67c50513          	addi	a0,a0,1660 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203524:	bdffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0203528:	00003697          	auipc	a3,0x3
ffffffffc020352c:	8a068693          	addi	a3,a3,-1888 # ffffffffc0205dc8 <commands+0x1690>
ffffffffc0203530:	00002617          	auipc	a2,0x2
ffffffffc0203534:	a9060613          	addi	a2,a2,-1392 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203538:	10800593          	li	a1,264
ffffffffc020353c:	00002517          	auipc	a0,0x2
ffffffffc0203540:	65c50513          	addi	a0,a0,1628 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203544:	bbffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203548:	00002697          	auipc	a3,0x2
ffffffffc020354c:	79068693          	addi	a3,a3,1936 # ffffffffc0205cd8 <commands+0x15a0>
ffffffffc0203550:	00002617          	auipc	a2,0x2
ffffffffc0203554:	a7060613          	addi	a2,a2,-1424 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203558:	10700593          	li	a1,263
ffffffffc020355c:	00002517          	auipc	a0,0x2
ffffffffc0203560:	63c50513          	addi	a0,a0,1596 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203564:	b9ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203568:	00003697          	auipc	a3,0x3
ffffffffc020356c:	84068693          	addi	a3,a3,-1984 # ffffffffc0205da8 <commands+0x1670>
ffffffffc0203570:	00002617          	auipc	a2,0x2
ffffffffc0203574:	a5060613          	addi	a2,a2,-1456 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203578:	10600593          	li	a1,262
ffffffffc020357c:	00002517          	auipc	a0,0x2
ffffffffc0203580:	61c50513          	addi	a0,a0,1564 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203584:	b7ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203588:	00002697          	auipc	a3,0x2
ffffffffc020358c:	7f068693          	addi	a3,a3,2032 # ffffffffc0205d78 <commands+0x1640>
ffffffffc0203590:	00002617          	auipc	a2,0x2
ffffffffc0203594:	a3060613          	addi	a2,a2,-1488 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203598:	10500593          	li	a1,261
ffffffffc020359c:	00002517          	auipc	a0,0x2
ffffffffc02035a0:	5fc50513          	addi	a0,a0,1532 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02035a4:	b5ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02035a8:	00002697          	auipc	a3,0x2
ffffffffc02035ac:	7b868693          	addi	a3,a3,1976 # ffffffffc0205d60 <commands+0x1628>
ffffffffc02035b0:	00002617          	auipc	a2,0x2
ffffffffc02035b4:	a1060613          	addi	a2,a2,-1520 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02035b8:	10400593          	li	a1,260
ffffffffc02035bc:	00002517          	auipc	a0,0x2
ffffffffc02035c0:	5dc50513          	addi	a0,a0,1500 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02035c4:	b3ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02035c8:	00002697          	auipc	a3,0x2
ffffffffc02035cc:	71068693          	addi	a3,a3,1808 # ffffffffc0205cd8 <commands+0x15a0>
ffffffffc02035d0:	00002617          	auipc	a2,0x2
ffffffffc02035d4:	9f060613          	addi	a2,a2,-1552 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02035d8:	0fe00593          	li	a1,254
ffffffffc02035dc:	00002517          	auipc	a0,0x2
ffffffffc02035e0:	5bc50513          	addi	a0,a0,1468 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02035e4:	b1ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!PageProperty(p0));
ffffffffc02035e8:	00002697          	auipc	a3,0x2
ffffffffc02035ec:	76068693          	addi	a3,a3,1888 # ffffffffc0205d48 <commands+0x1610>
ffffffffc02035f0:	00002617          	auipc	a2,0x2
ffffffffc02035f4:	9d060613          	addi	a2,a2,-1584 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02035f8:	0f900593          	li	a1,249
ffffffffc02035fc:	00002517          	auipc	a0,0x2
ffffffffc0203600:	59c50513          	addi	a0,a0,1436 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203604:	afffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203608:	00003697          	auipc	a3,0x3
ffffffffc020360c:	86068693          	addi	a3,a3,-1952 # ffffffffc0205e68 <commands+0x1730>
ffffffffc0203610:	00002617          	auipc	a2,0x2
ffffffffc0203614:	9b060613          	addi	a2,a2,-1616 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203618:	11700593          	li	a1,279
ffffffffc020361c:	00002517          	auipc	a0,0x2
ffffffffc0203620:	57c50513          	addi	a0,a0,1404 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203624:	adffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == 0);
ffffffffc0203628:	00003697          	auipc	a3,0x3
ffffffffc020362c:	87068693          	addi	a3,a3,-1936 # ffffffffc0205e98 <commands+0x1760>
ffffffffc0203630:	00002617          	auipc	a2,0x2
ffffffffc0203634:	99060613          	addi	a2,a2,-1648 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203638:	12600593          	li	a1,294
ffffffffc020363c:	00002517          	auipc	a0,0x2
ffffffffc0203640:	55c50513          	addi	a0,a0,1372 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203644:	abffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == nr_free_pages());
ffffffffc0203648:	00002697          	auipc	a3,0x2
ffffffffc020364c:	20068693          	addi	a3,a3,512 # ffffffffc0205848 <commands+0x1110>
ffffffffc0203650:	00002617          	auipc	a2,0x2
ffffffffc0203654:	97060613          	addi	a2,a2,-1680 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203658:	0f300593          	li	a1,243
ffffffffc020365c:	00002517          	auipc	a0,0x2
ffffffffc0203660:	53c50513          	addi	a0,a0,1340 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203664:	a9ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203668:	00002697          	auipc	a3,0x2
ffffffffc020366c:	56868693          	addi	a3,a3,1384 # ffffffffc0205bd0 <commands+0x1498>
ffffffffc0203670:	00002617          	auipc	a2,0x2
ffffffffc0203674:	95060613          	addi	a2,a2,-1712 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203678:	0ba00593          	li	a1,186
ffffffffc020367c:	00002517          	auipc	a0,0x2
ffffffffc0203680:	51c50513          	addi	a0,a0,1308 # ffffffffc0205b98 <commands+0x1460>
ffffffffc0203684:	a7ffc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203688 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0203688:	1141                	addi	sp,sp,-16
ffffffffc020368a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020368c:	14058a63          	beqz	a1,ffffffffc02037e0 <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0203690:	00359693          	slli	a3,a1,0x3
ffffffffc0203694:	96ae                	add	a3,a3,a1
ffffffffc0203696:	068e                	slli	a3,a3,0x3
ffffffffc0203698:	96aa                	add	a3,a3,a0
ffffffffc020369a:	87aa                	mv	a5,a0
ffffffffc020369c:	02d50263          	beq	a0,a3,ffffffffc02036c0 <default_free_pages+0x38>
ffffffffc02036a0:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02036a2:	8b05                	andi	a4,a4,1
ffffffffc02036a4:	10071e63          	bnez	a4,ffffffffc02037c0 <default_free_pages+0x138>
ffffffffc02036a8:	6798                	ld	a4,8(a5)
ffffffffc02036aa:	8b09                	andi	a4,a4,2
ffffffffc02036ac:	10071a63          	bnez	a4,ffffffffc02037c0 <default_free_pages+0x138>
        p->flags = 0;
ffffffffc02036b0:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02036b4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02036b8:	04878793          	addi	a5,a5,72
ffffffffc02036bc:	fed792e3          	bne	a5,a3,ffffffffc02036a0 <default_free_pages+0x18>
    base->property = n;
ffffffffc02036c0:	2581                	sext.w	a1,a1
ffffffffc02036c2:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc02036c4:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02036c8:	4789                	li	a5,2
ffffffffc02036ca:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02036ce:	0000e697          	auipc	a3,0xe
ffffffffc02036d2:	a1268693          	addi	a3,a3,-1518 # ffffffffc02110e0 <free_area>
ffffffffc02036d6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02036d8:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02036da:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02036de:	9db9                	addw	a1,a1,a4
ffffffffc02036e0:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02036e2:	0ad78863          	beq	a5,a3,ffffffffc0203792 <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02036e6:	fe078713          	addi	a4,a5,-32
ffffffffc02036ea:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02036ee:	4581                	li	a1,0
            if (base < page) {
ffffffffc02036f0:	00e56a63          	bltu	a0,a4,ffffffffc0203704 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc02036f4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02036f6:	06d70263          	beq	a4,a3,ffffffffc020375a <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02036fa:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02036fc:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0203700:	fee57ae3          	bgeu	a0,a4,ffffffffc02036f4 <default_free_pages+0x6c>
ffffffffc0203704:	c199                	beqz	a1,ffffffffc020370a <default_free_pages+0x82>
ffffffffc0203706:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020370a:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020370c:	e390                	sd	a2,0(a5)
ffffffffc020370e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203710:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203712:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc0203714:	02d70063          	beq	a4,a3,ffffffffc0203734 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0203718:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc020371c:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc0203720:	02081613          	slli	a2,a6,0x20
ffffffffc0203724:	9201                	srli	a2,a2,0x20
ffffffffc0203726:	00361793          	slli	a5,a2,0x3
ffffffffc020372a:	97b2                	add	a5,a5,a2
ffffffffc020372c:	078e                	slli	a5,a5,0x3
ffffffffc020372e:	97ae                	add	a5,a5,a1
ffffffffc0203730:	02f50f63          	beq	a0,a5,ffffffffc020376e <default_free_pages+0xe6>
    return listelm->next;
ffffffffc0203734:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0203736:	00d70f63          	beq	a4,a3,ffffffffc0203754 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc020373a:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc020373c:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc0203740:	02059613          	slli	a2,a1,0x20
ffffffffc0203744:	9201                	srli	a2,a2,0x20
ffffffffc0203746:	00361793          	slli	a5,a2,0x3
ffffffffc020374a:	97b2                	add	a5,a5,a2
ffffffffc020374c:	078e                	slli	a5,a5,0x3
ffffffffc020374e:	97aa                	add	a5,a5,a0
ffffffffc0203750:	04f68863          	beq	a3,a5,ffffffffc02037a0 <default_free_pages+0x118>
}
ffffffffc0203754:	60a2                	ld	ra,8(sp)
ffffffffc0203756:	0141                	addi	sp,sp,16
ffffffffc0203758:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020375a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020375c:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc020375e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203760:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203762:	02d70563          	beq	a4,a3,ffffffffc020378c <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0203766:	8832                	mv	a6,a2
ffffffffc0203768:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020376a:	87ba                	mv	a5,a4
ffffffffc020376c:	bf41                	j	ffffffffc02036fc <default_free_pages+0x74>
            p->property += base->property;
ffffffffc020376e:	4d1c                	lw	a5,24(a0)
ffffffffc0203770:	0107883b          	addw	a6,a5,a6
ffffffffc0203774:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203778:	57f5                	li	a5,-3
ffffffffc020377a:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020377e:	7110                	ld	a2,32(a0)
ffffffffc0203780:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc0203782:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc0203784:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0203786:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0203788:	e390                	sd	a2,0(a5)
ffffffffc020378a:	b775                	j	ffffffffc0203736 <default_free_pages+0xae>
ffffffffc020378c:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020378e:	873e                	mv	a4,a5
ffffffffc0203790:	b761                	j	ffffffffc0203718 <default_free_pages+0x90>
}
ffffffffc0203792:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203794:	e390                	sd	a2,0(a5)
ffffffffc0203796:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203798:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020379a:	f11c                	sd	a5,32(a0)
ffffffffc020379c:	0141                	addi	sp,sp,16
ffffffffc020379e:	8082                	ret
            base->property += p->property;
ffffffffc02037a0:	ff872783          	lw	a5,-8(a4)
ffffffffc02037a4:	fe870693          	addi	a3,a4,-24
ffffffffc02037a8:	9dbd                	addw	a1,a1,a5
ffffffffc02037aa:	cd0c                	sw	a1,24(a0)
ffffffffc02037ac:	57f5                	li	a5,-3
ffffffffc02037ae:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02037b2:	6314                	ld	a3,0(a4)
ffffffffc02037b4:	671c                	ld	a5,8(a4)
}
ffffffffc02037b6:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02037b8:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02037ba:	e394                	sd	a3,0(a5)
ffffffffc02037bc:	0141                	addi	sp,sp,16
ffffffffc02037be:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02037c0:	00002697          	auipc	a3,0x2
ffffffffc02037c4:	6f068693          	addi	a3,a3,1776 # ffffffffc0205eb0 <commands+0x1778>
ffffffffc02037c8:	00001617          	auipc	a2,0x1
ffffffffc02037cc:	7f860613          	addi	a2,a2,2040 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02037d0:	08300593          	li	a1,131
ffffffffc02037d4:	00002517          	auipc	a0,0x2
ffffffffc02037d8:	3c450513          	addi	a0,a0,964 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02037dc:	927fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc02037e0:	00002697          	auipc	a3,0x2
ffffffffc02037e4:	6c868693          	addi	a3,a3,1736 # ffffffffc0205ea8 <commands+0x1770>
ffffffffc02037e8:	00001617          	auipc	a2,0x1
ffffffffc02037ec:	7d860613          	addi	a2,a2,2008 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02037f0:	08000593          	li	a1,128
ffffffffc02037f4:	00002517          	auipc	a0,0x2
ffffffffc02037f8:	3a450513          	addi	a0,a0,932 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02037fc:	907fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203800 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0203800:	c959                	beqz	a0,ffffffffc0203896 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0203802:	0000e597          	auipc	a1,0xe
ffffffffc0203806:	8de58593          	addi	a1,a1,-1826 # ffffffffc02110e0 <free_area>
ffffffffc020380a:	0105a803          	lw	a6,16(a1)
ffffffffc020380e:	862a                	mv	a2,a0
ffffffffc0203810:	02081793          	slli	a5,a6,0x20
ffffffffc0203814:	9381                	srli	a5,a5,0x20
ffffffffc0203816:	00a7ee63          	bltu	a5,a0,ffffffffc0203832 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020381a:	87ae                	mv	a5,a1
ffffffffc020381c:	a801                	j	ffffffffc020382c <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020381e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203822:	02071693          	slli	a3,a4,0x20
ffffffffc0203826:	9281                	srli	a3,a3,0x20
ffffffffc0203828:	00c6f763          	bgeu	a3,a2,ffffffffc0203836 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020382c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020382e:	feb798e3          	bne	a5,a1,ffffffffc020381e <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0203832:	4501                	li	a0,0
}
ffffffffc0203834:	8082                	ret
    return listelm->prev;
ffffffffc0203836:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020383a:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020383e:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc0203842:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0203846:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020384a:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020384e:	02d67b63          	bgeu	a2,a3,ffffffffc0203884 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc0203852:	00361693          	slli	a3,a2,0x3
ffffffffc0203856:	96b2                	add	a3,a3,a2
ffffffffc0203858:	068e                	slli	a3,a3,0x3
ffffffffc020385a:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc020385c:	41c7073b          	subw	a4,a4,t3
ffffffffc0203860:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203862:	00868613          	addi	a2,a3,8
ffffffffc0203866:	4709                	li	a4,2
ffffffffc0203868:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc020386c:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203870:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc0203874:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0203878:	e310                	sd	a2,0(a4)
ffffffffc020387a:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc020387e:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc0203880:	0316b023          	sd	a7,32(a3)
ffffffffc0203884:	41c8083b          	subw	a6,a6,t3
ffffffffc0203888:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020388c:	5775                	li	a4,-3
ffffffffc020388e:	17a1                	addi	a5,a5,-24
ffffffffc0203890:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0203894:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0203896:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0203898:	00002697          	auipc	a3,0x2
ffffffffc020389c:	61068693          	addi	a3,a3,1552 # ffffffffc0205ea8 <commands+0x1770>
ffffffffc02038a0:	00001617          	auipc	a2,0x1
ffffffffc02038a4:	72060613          	addi	a2,a2,1824 # ffffffffc0204fc0 <commands+0x888>
ffffffffc02038a8:	06200593          	li	a1,98
ffffffffc02038ac:	00002517          	auipc	a0,0x2
ffffffffc02038b0:	2ec50513          	addi	a0,a0,748 # ffffffffc0205b98 <commands+0x1460>
default_alloc_pages(size_t n) {
ffffffffc02038b4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02038b6:	84dfc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02038ba <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02038ba:	1141                	addi	sp,sp,-16
ffffffffc02038bc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02038be:	c9e1                	beqz	a1,ffffffffc020398e <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02038c0:	00359693          	slli	a3,a1,0x3
ffffffffc02038c4:	96ae                	add	a3,a3,a1
ffffffffc02038c6:	068e                	slli	a3,a3,0x3
ffffffffc02038c8:	96aa                	add	a3,a3,a0
ffffffffc02038ca:	87aa                	mv	a5,a0
ffffffffc02038cc:	00d50f63          	beq	a0,a3,ffffffffc02038ea <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02038d0:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02038d2:	8b05                	andi	a4,a4,1
ffffffffc02038d4:	cf49                	beqz	a4,ffffffffc020396e <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02038d6:	0007ac23          	sw	zero,24(a5)
ffffffffc02038da:	0007b423          	sd	zero,8(a5)
ffffffffc02038de:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02038e2:	04878793          	addi	a5,a5,72
ffffffffc02038e6:	fed795e3          	bne	a5,a3,ffffffffc02038d0 <default_init_memmap+0x16>
    base->property = n;
ffffffffc02038ea:	2581                	sext.w	a1,a1
ffffffffc02038ec:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02038ee:	4789                	li	a5,2
ffffffffc02038f0:	00850713          	addi	a4,a0,8
ffffffffc02038f4:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02038f8:	0000d697          	auipc	a3,0xd
ffffffffc02038fc:	7e868693          	addi	a3,a3,2024 # ffffffffc02110e0 <free_area>
ffffffffc0203900:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203902:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0203904:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0203908:	9db9                	addw	a1,a1,a4
ffffffffc020390a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020390c:	04d78a63          	beq	a5,a3,ffffffffc0203960 <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0203910:	fe078713          	addi	a4,a5,-32
ffffffffc0203914:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203918:	4581                	li	a1,0
            if (base < page) {
ffffffffc020391a:	00e56a63          	bltu	a0,a4,ffffffffc020392e <default_init_memmap+0x74>
    return listelm->next;
ffffffffc020391e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203920:	02d70263          	beq	a4,a3,ffffffffc0203944 <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0203924:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203926:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020392a:	fee57ae3          	bgeu	a0,a4,ffffffffc020391e <default_init_memmap+0x64>
ffffffffc020392e:	c199                	beqz	a1,ffffffffc0203934 <default_init_memmap+0x7a>
ffffffffc0203930:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203934:	6398                	ld	a4,0(a5)
}
ffffffffc0203936:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203938:	e390                	sd	a2,0(a5)
ffffffffc020393a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020393c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020393e:	f118                	sd	a4,32(a0)
ffffffffc0203940:	0141                	addi	sp,sp,16
ffffffffc0203942:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203944:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203946:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0203948:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020394a:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020394c:	00d70663          	beq	a4,a3,ffffffffc0203958 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0203950:	8832                	mv	a6,a2
ffffffffc0203952:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0203954:	87ba                	mv	a5,a4
ffffffffc0203956:	bfc1                	j	ffffffffc0203926 <default_init_memmap+0x6c>
}
ffffffffc0203958:	60a2                	ld	ra,8(sp)
ffffffffc020395a:	e290                	sd	a2,0(a3)
ffffffffc020395c:	0141                	addi	sp,sp,16
ffffffffc020395e:	8082                	ret
ffffffffc0203960:	60a2                	ld	ra,8(sp)
ffffffffc0203962:	e390                	sd	a2,0(a5)
ffffffffc0203964:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203966:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203968:	f11c                	sd	a5,32(a0)
ffffffffc020396a:	0141                	addi	sp,sp,16
ffffffffc020396c:	8082                	ret
        assert(PageReserved(p));
ffffffffc020396e:	00002697          	auipc	a3,0x2
ffffffffc0203972:	56a68693          	addi	a3,a3,1386 # ffffffffc0205ed8 <commands+0x17a0>
ffffffffc0203976:	00001617          	auipc	a2,0x1
ffffffffc020397a:	64a60613          	addi	a2,a2,1610 # ffffffffc0204fc0 <commands+0x888>
ffffffffc020397e:	04900593          	li	a1,73
ffffffffc0203982:	00002517          	auipc	a0,0x2
ffffffffc0203986:	21650513          	addi	a0,a0,534 # ffffffffc0205b98 <commands+0x1460>
ffffffffc020398a:	f78fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc020398e:	00002697          	auipc	a3,0x2
ffffffffc0203992:	51a68693          	addi	a3,a3,1306 # ffffffffc0205ea8 <commands+0x1770>
ffffffffc0203996:	00001617          	auipc	a2,0x1
ffffffffc020399a:	62a60613          	addi	a2,a2,1578 # ffffffffc0204fc0 <commands+0x888>
ffffffffc020399e:	04600593          	li	a1,70
ffffffffc02039a2:	00002517          	auipc	a0,0x2
ffffffffc02039a6:	1f650513          	addi	a0,a0,502 # ffffffffc0205b98 <commands+0x1460>
ffffffffc02039aa:	f58fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02039ae <_lru_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02039ae:	0000d797          	auipc	a5,0xd
ffffffffc02039b2:	69278793          	addi	a5,a5,1682 # ffffffffc0211040 <pra_list_head>
static int
_lru_init_mm(struct mm_struct *mm)
{     

    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
ffffffffc02039b6:	f51c                	sd	a5,40(a0)
ffffffffc02039b8:	e79c                	sd	a5,8(a5)
ffffffffc02039ba:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02039bc:	4501                	li	a0,0
ffffffffc02039be:	8082                	ret

ffffffffc02039c0 <_lru_init>:

static int
_lru_init(void)
{
    return 0;
}
ffffffffc02039c0:	4501                	li	a0,0
ffffffffc02039c2:	8082                	ret

ffffffffc02039c4 <_lru_set_unswappable>:

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02039c4:	4501                	li	a0,0
ffffffffc02039c6:	8082                	ret

ffffffffc02039c8 <_lru_tick_event>:

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02039c8:	4501                	li	a0,0
ffffffffc02039ca:	8082                	ret

ffffffffc02039cc <_lru_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02039cc:	7518                	ld	a4,40(a0)
{
ffffffffc02039ce:	1141                	addi	sp,sp,-16
ffffffffc02039d0:	e406                	sd	ra,8(sp)
        assert(head != NULL);
ffffffffc02039d2:	c731                	beqz	a4,ffffffffc0203a1e <_lru_swap_out_victim+0x52>
    assert(in_tick==0);
ffffffffc02039d4:	e60d                	bnez	a2,ffffffffc02039fe <_lru_swap_out_victim+0x32>
    return listelm->prev;
ffffffffc02039d6:	631c                	ld	a5,0(a4)
    if (entry != head) {
ffffffffc02039d8:	00f70d63          	beq	a4,a5,ffffffffc02039f2 <_lru_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02039dc:	6394                	ld	a3,0(a5)
ffffffffc02039de:	6798                	ld	a4,8(a5)
}
ffffffffc02039e0:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc02039e2:	fd078793          	addi	a5,a5,-48
    prev->next = next;
ffffffffc02039e6:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02039e8:	e314                	sd	a3,0(a4)
ffffffffc02039ea:	e19c                	sd	a5,0(a1)
}
ffffffffc02039ec:	4501                	li	a0,0
ffffffffc02039ee:	0141                	addi	sp,sp,16
ffffffffc02039f0:	8082                	ret
ffffffffc02039f2:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc02039f4:	0005b023          	sd	zero,0(a1)
}
ffffffffc02039f8:	4501                	li	a0,0
ffffffffc02039fa:	0141                	addi	sp,sp,16
ffffffffc02039fc:	8082                	ret
    assert(in_tick==0);
ffffffffc02039fe:	00002697          	auipc	a3,0x2
ffffffffc0203a02:	56268693          	addi	a3,a3,1378 # ffffffffc0205f60 <default_pmm_manager+0x60>
ffffffffc0203a06:	00001617          	auipc	a2,0x1
ffffffffc0203a0a:	5ba60613          	addi	a2,a2,1466 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203a0e:	02400593          	li	a1,36
ffffffffc0203a12:	00002517          	auipc	a0,0x2
ffffffffc0203a16:	53650513          	addi	a0,a0,1334 # ffffffffc0205f48 <default_pmm_manager+0x48>
ffffffffc0203a1a:	ee8fc0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(head != NULL);
ffffffffc0203a1e:	00002697          	auipc	a3,0x2
ffffffffc0203a22:	51a68693          	addi	a3,a3,1306 # ffffffffc0205f38 <default_pmm_manager+0x38>
ffffffffc0203a26:	00001617          	auipc	a2,0x1
ffffffffc0203a2a:	59a60613          	addi	a2,a2,1434 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203a2e:	02300593          	li	a1,35
ffffffffc0203a32:	00002517          	auipc	a0,0x2
ffffffffc0203a36:	51650513          	addi	a0,a0,1302 # ffffffffc0205f48 <default_pmm_manager+0x48>
ffffffffc0203a3a:	ec8fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203a3e <_lru_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203a3e:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203a40:	cb91                	beqz	a5,ffffffffc0203a54 <_lru_map_swappable+0x16>
    __list_add(elm, listelm, listelm->next);
ffffffffc0203a42:	6794                	ld	a3,8(a5)
ffffffffc0203a44:	03060713          	addi	a4,a2,48
}
ffffffffc0203a48:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0203a4a:	e298                	sd	a4,0(a3)
ffffffffc0203a4c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203a4e:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc0203a50:	fa1c                	sd	a5,48(a2)
ffffffffc0203a52:	8082                	ret
{
ffffffffc0203a54:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203a56:	00002697          	auipc	a3,0x2
ffffffffc0203a5a:	51a68693          	addi	a3,a3,1306 # ffffffffc0205f70 <default_pmm_manager+0x70>
ffffffffc0203a5e:	00001617          	auipc	a2,0x1
ffffffffc0203a62:	56260613          	addi	a2,a2,1378 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203a66:	45ed                	li	a1,27
ffffffffc0203a68:	00002517          	auipc	a0,0x2
ffffffffc0203a6c:	4e050513          	addi	a0,a0,1248 # ffffffffc0205f48 <default_pmm_manager+0x48>
{
ffffffffc0203a70:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203a72:	e90fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203a76 <_lru_check_swap>:
_lru_check_swap(void) {
ffffffffc0203a76:	1101                	addi	sp,sp,-32
ffffffffc0203a78:	e822                	sd	s0,16(sp)
    cprintf("--------begin----------\n");
ffffffffc0203a7a:	00002517          	auipc	a0,0x2
ffffffffc0203a7e:	51650513          	addi	a0,a0,1302 # ffffffffc0205f90 <default_pmm_manager+0x90>
    return listelm->next;
ffffffffc0203a82:	0000d417          	auipc	s0,0xd
ffffffffc0203a86:	5be40413          	addi	s0,s0,1470 # ffffffffc0211040 <pra_list_head>
_lru_check_swap(void) {
ffffffffc0203a8a:	e426                	sd	s1,8(sp)
ffffffffc0203a8c:	ec06                	sd	ra,24(sp)
ffffffffc0203a8e:	e04a                	sd	s2,0(sp)
    cprintf("--------begin----------\n");
ffffffffc0203a90:	e2afc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203a94:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203a96:	00848d63          	beq	s1,s0,ffffffffc0203ab0 <_lru_check_swap+0x3a>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203a9a:	00002917          	auipc	s2,0x2
ffffffffc0203a9e:	51690913          	addi	s2,s2,1302 # ffffffffc0205fb0 <default_pmm_manager+0xb0>
ffffffffc0203aa2:	688c                	ld	a1,16(s1)
ffffffffc0203aa4:	854a                	mv	a0,s2
ffffffffc0203aa6:	e14fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203aaa:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203aac:	fe849be3          	bne	s1,s0,ffffffffc0203aa2 <_lru_check_swap+0x2c>
    cprintf("---------end-----------\n");
ffffffffc0203ab0:	00002517          	auipc	a0,0x2
ffffffffc0203ab4:	51050513          	addi	a0,a0,1296 # ffffffffc0205fc0 <default_pmm_manager+0xc0>
ffffffffc0203ab8:	e02fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc0203abc:	00002517          	auipc	a0,0x2
ffffffffc0203ac0:	52450513          	addi	a0,a0,1316 # ffffffffc0205fe0 <default_pmm_manager+0xe0>
ffffffffc0203ac4:	df6fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203ac8:	678d                	lui	a5,0x3
ffffffffc0203aca:	4731                	li	a4,12
ffffffffc0203acc:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    cprintf("--------begin----------\n");
ffffffffc0203ad0:	00002517          	auipc	a0,0x2
ffffffffc0203ad4:	4c050513          	addi	a0,a0,1216 # ffffffffc0205f90 <default_pmm_manager+0x90>
ffffffffc0203ad8:	de2fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203adc:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203ade:	00848d63          	beq	s1,s0,ffffffffc0203af8 <_lru_check_swap+0x82>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203ae2:	00002917          	auipc	s2,0x2
ffffffffc0203ae6:	4ce90913          	addi	s2,s2,1230 # ffffffffc0205fb0 <default_pmm_manager+0xb0>
ffffffffc0203aea:	688c                	ld	a1,16(s1)
ffffffffc0203aec:	854a                	mv	a0,s2
ffffffffc0203aee:	dccfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203af2:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203af4:	fe849be3          	bne	s1,s0,ffffffffc0203aea <_lru_check_swap+0x74>
    cprintf("---------end-----------\n");
ffffffffc0203af8:	00002517          	auipc	a0,0x2
ffffffffc0203afc:	4c850513          	addi	a0,a0,1224 # ffffffffc0205fc0 <default_pmm_manager+0xc0>
ffffffffc0203b00:	dbafc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0203b04:	00002517          	auipc	a0,0x2
ffffffffc0203b08:	50450513          	addi	a0,a0,1284 # ffffffffc0206008 <default_pmm_manager+0x108>
ffffffffc0203b0c:	daefc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203b10:	6785                	lui	a5,0x1
ffffffffc0203b12:	4729                	li	a4,10
ffffffffc0203b14:	00e78023          	sb	a4,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
    cprintf("--------begin----------\n");
ffffffffc0203b18:	00002517          	auipc	a0,0x2
ffffffffc0203b1c:	47850513          	addi	a0,a0,1144 # ffffffffc0205f90 <default_pmm_manager+0x90>
ffffffffc0203b20:	d9afc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203b24:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203b26:	00848d63          	beq	s1,s0,ffffffffc0203b40 <_lru_check_swap+0xca>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203b2a:	00002917          	auipc	s2,0x2
ffffffffc0203b2e:	48690913          	addi	s2,s2,1158 # ffffffffc0205fb0 <default_pmm_manager+0xb0>
ffffffffc0203b32:	688c                	ld	a1,16(s1)
ffffffffc0203b34:	854a                	mv	a0,s2
ffffffffc0203b36:	d84fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203b3a:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203b3c:	fe849be3          	bne	s1,s0,ffffffffc0203b32 <_lru_check_swap+0xbc>
    cprintf("---------end-----------\n");
ffffffffc0203b40:	00002517          	auipc	a0,0x2
ffffffffc0203b44:	48050513          	addi	a0,a0,1152 # ffffffffc0205fc0 <default_pmm_manager+0xc0>
ffffffffc0203b48:	d72fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203b4c:	00002517          	auipc	a0,0x2
ffffffffc0203b50:	4e450513          	addi	a0,a0,1252 # ffffffffc0206030 <default_pmm_manager+0x130>
ffffffffc0203b54:	d66fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203b58:	6789                	lui	a5,0x2
ffffffffc0203b5a:	472d                	li	a4,11
ffffffffc0203b5c:	00e78023          	sb	a4,0(a5) # 2000 <kern_entry-0xffffffffc01fe000>
    cprintf("--------begin----------\n");
ffffffffc0203b60:	00002517          	auipc	a0,0x2
ffffffffc0203b64:	43050513          	addi	a0,a0,1072 # ffffffffc0205f90 <default_pmm_manager+0x90>
ffffffffc0203b68:	d52fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203b6c:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203b6e:	00848d63          	beq	s1,s0,ffffffffc0203b88 <_lru_check_swap+0x112>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203b72:	00002917          	auipc	s2,0x2
ffffffffc0203b76:	43e90913          	addi	s2,s2,1086 # ffffffffc0205fb0 <default_pmm_manager+0xb0>
ffffffffc0203b7a:	688c                	ld	a1,16(s1)
ffffffffc0203b7c:	854a                	mv	a0,s2
ffffffffc0203b7e:	d3cfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203b82:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203b84:	fe849be3          	bne	s1,s0,ffffffffc0203b7a <_lru_check_swap+0x104>
    cprintf("---------end-----------\n");
ffffffffc0203b88:	00002517          	auipc	a0,0x2
ffffffffc0203b8c:	43850513          	addi	a0,a0,1080 # ffffffffc0205fc0 <default_pmm_manager+0xc0>
ffffffffc0203b90:	d2afc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc0203b94:	00002517          	auipc	a0,0x2
ffffffffc0203b98:	4c450513          	addi	a0,a0,1220 # ffffffffc0206058 <default_pmm_manager+0x158>
ffffffffc0203b9c:	d1efc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203ba0:	6795                	lui	a5,0x5
ffffffffc0203ba2:	4739                	li	a4,14
ffffffffc0203ba4:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    cprintf("--------begin----------\n");
ffffffffc0203ba8:	00002517          	auipc	a0,0x2
ffffffffc0203bac:	3e850513          	addi	a0,a0,1000 # ffffffffc0205f90 <default_pmm_manager+0x90>
ffffffffc0203bb0:	d0afc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203bb4:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203bb6:	00848d63          	beq	s1,s0,ffffffffc0203bd0 <_lru_check_swap+0x15a>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203bba:	00002917          	auipc	s2,0x2
ffffffffc0203bbe:	3f690913          	addi	s2,s2,1014 # ffffffffc0205fb0 <default_pmm_manager+0xb0>
ffffffffc0203bc2:	688c                	ld	a1,16(s1)
ffffffffc0203bc4:	854a                	mv	a0,s2
ffffffffc0203bc6:	cf4fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203bca:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203bcc:	fe849be3          	bne	s1,s0,ffffffffc0203bc2 <_lru_check_swap+0x14c>
    cprintf("---------end-----------\n");
ffffffffc0203bd0:	00002517          	auipc	a0,0x2
ffffffffc0203bd4:	3f050513          	addi	a0,a0,1008 # ffffffffc0205fc0 <default_pmm_manager+0xc0>
ffffffffc0203bd8:	ce2fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203bdc:	00002517          	auipc	a0,0x2
ffffffffc0203be0:	45450513          	addi	a0,a0,1108 # ffffffffc0206030 <default_pmm_manager+0x130>
ffffffffc0203be4:	cd6fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203be8:	6789                	lui	a5,0x2
ffffffffc0203bea:	472d                	li	a4,11
ffffffffc0203bec:	00e78023          	sb	a4,0(a5) # 2000 <kern_entry-0xffffffffc01fe000>
    cprintf("--------begin----------\n");
ffffffffc0203bf0:	00002517          	auipc	a0,0x2
ffffffffc0203bf4:	3a050513          	addi	a0,a0,928 # ffffffffc0205f90 <default_pmm_manager+0x90>
ffffffffc0203bf8:	cc2fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203bfc:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203bfe:	00848d63          	beq	s1,s0,ffffffffc0203c18 <_lru_check_swap+0x1a2>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203c02:	00002917          	auipc	s2,0x2
ffffffffc0203c06:	3ae90913          	addi	s2,s2,942 # ffffffffc0205fb0 <default_pmm_manager+0xb0>
ffffffffc0203c0a:	688c                	ld	a1,16(s1)
ffffffffc0203c0c:	854a                	mv	a0,s2
ffffffffc0203c0e:	cacfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203c12:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203c14:	fe849be3          	bne	s1,s0,ffffffffc0203c0a <_lru_check_swap+0x194>
    cprintf("---------end-----------\n");
ffffffffc0203c18:	00002517          	auipc	a0,0x2
ffffffffc0203c1c:	3a850513          	addi	a0,a0,936 # ffffffffc0205fc0 <default_pmm_manager+0xc0>
ffffffffc0203c20:	c9afc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0203c24:	00002517          	auipc	a0,0x2
ffffffffc0203c28:	3e450513          	addi	a0,a0,996 # ffffffffc0206008 <default_pmm_manager+0x108>
ffffffffc0203c2c:	c8efc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c30:	6785                	lui	a5,0x1
ffffffffc0203c32:	4729                	li	a4,10
ffffffffc0203c34:	00e78023          	sb	a4,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
    cprintf("--------begin----------\n");
ffffffffc0203c38:	00002517          	auipc	a0,0x2
ffffffffc0203c3c:	35850513          	addi	a0,a0,856 # ffffffffc0205f90 <default_pmm_manager+0x90>
ffffffffc0203c40:	c7afc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203c44:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203c46:	00848d63          	beq	s1,s0,ffffffffc0203c60 <_lru_check_swap+0x1ea>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203c4a:	00002917          	auipc	s2,0x2
ffffffffc0203c4e:	36690913          	addi	s2,s2,870 # ffffffffc0205fb0 <default_pmm_manager+0xb0>
ffffffffc0203c52:	688c                	ld	a1,16(s1)
ffffffffc0203c54:	854a                	mv	a0,s2
ffffffffc0203c56:	c64fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203c5a:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203c5c:	fe849be3          	bne	s1,s0,ffffffffc0203c52 <_lru_check_swap+0x1dc>
    cprintf("---------end-----------\n");
ffffffffc0203c60:	00002517          	auipc	a0,0x2
ffffffffc0203c64:	36050513          	addi	a0,a0,864 # ffffffffc0205fc0 <default_pmm_manager+0xc0>
ffffffffc0203c68:	c52fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203c6c:	00002517          	auipc	a0,0x2
ffffffffc0203c70:	3c450513          	addi	a0,a0,964 # ffffffffc0206030 <default_pmm_manager+0x130>
ffffffffc0203c74:	c46fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203c78:	6789                	lui	a5,0x2
ffffffffc0203c7a:	472d                	li	a4,11
ffffffffc0203c7c:	00e78023          	sb	a4,0(a5) # 2000 <kern_entry-0xffffffffc01fe000>
    cprintf("--------begin----------\n");
ffffffffc0203c80:	00002517          	auipc	a0,0x2
ffffffffc0203c84:	31050513          	addi	a0,a0,784 # ffffffffc0205f90 <default_pmm_manager+0x90>
ffffffffc0203c88:	c32fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203c8c:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203c8e:	00848d63          	beq	s1,s0,ffffffffc0203ca8 <_lru_check_swap+0x232>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203c92:	00002917          	auipc	s2,0x2
ffffffffc0203c96:	31e90913          	addi	s2,s2,798 # ffffffffc0205fb0 <default_pmm_manager+0xb0>
ffffffffc0203c9a:	688c                	ld	a1,16(s1)
ffffffffc0203c9c:	854a                	mv	a0,s2
ffffffffc0203c9e:	c1cfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203ca2:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203ca4:	fe849be3          	bne	s1,s0,ffffffffc0203c9a <_lru_check_swap+0x224>
    cprintf("---------end-----------\n");
ffffffffc0203ca8:	00002517          	auipc	a0,0x2
ffffffffc0203cac:	31850513          	addi	a0,a0,792 # ffffffffc0205fc0 <default_pmm_manager+0xc0>
ffffffffc0203cb0:	c0afc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc0203cb4:	00002517          	auipc	a0,0x2
ffffffffc0203cb8:	32c50513          	addi	a0,a0,812 # ffffffffc0205fe0 <default_pmm_manager+0xe0>
ffffffffc0203cbc:	bfefc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203cc0:	678d                	lui	a5,0x3
ffffffffc0203cc2:	4731                	li	a4,12
ffffffffc0203cc4:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    cprintf("--------begin----------\n");
ffffffffc0203cc8:	00002517          	auipc	a0,0x2
ffffffffc0203ccc:	2c850513          	addi	a0,a0,712 # ffffffffc0205f90 <default_pmm_manager+0x90>
ffffffffc0203cd0:	beafc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203cd4:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203cd6:	00848d63          	beq	s1,s0,ffffffffc0203cf0 <_lru_check_swap+0x27a>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203cda:	00002917          	auipc	s2,0x2
ffffffffc0203cde:	2d690913          	addi	s2,s2,726 # ffffffffc0205fb0 <default_pmm_manager+0xb0>
ffffffffc0203ce2:	688c                	ld	a1,16(s1)
ffffffffc0203ce4:	854a                	mv	a0,s2
ffffffffc0203ce6:	bd4fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203cea:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203cec:	fe849be3          	bne	s1,s0,ffffffffc0203ce2 <_lru_check_swap+0x26c>
    cprintf("---------end-----------\n");
ffffffffc0203cf0:	00002517          	auipc	a0,0x2
ffffffffc0203cf4:	2d050513          	addi	a0,a0,720 # ffffffffc0205fc0 <default_pmm_manager+0xc0>
ffffffffc0203cf8:	bc2fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc0203cfc:	00002517          	auipc	a0,0x2
ffffffffc0203d00:	38450513          	addi	a0,a0,900 # ffffffffc0206080 <default_pmm_manager+0x180>
ffffffffc0203d04:	bb6fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d08:	6791                	lui	a5,0x4
ffffffffc0203d0a:	4735                	li	a4,13
ffffffffc0203d0c:	00e78023          	sb	a4,0(a5) # 4000 <kern_entry-0xffffffffc01fc000>
    cprintf("--------begin----------\n");
ffffffffc0203d10:	00002517          	auipc	a0,0x2
ffffffffc0203d14:	28050513          	addi	a0,a0,640 # ffffffffc0205f90 <default_pmm_manager+0x90>
ffffffffc0203d18:	ba2fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203d1c:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203d1e:	00848d63          	beq	s1,s0,ffffffffc0203d38 <_lru_check_swap+0x2c2>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203d22:	00002917          	auipc	s2,0x2
ffffffffc0203d26:	28e90913          	addi	s2,s2,654 # ffffffffc0205fb0 <default_pmm_manager+0xb0>
ffffffffc0203d2a:	688c                	ld	a1,16(s1)
ffffffffc0203d2c:	854a                	mv	a0,s2
ffffffffc0203d2e:	b8cfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203d32:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203d34:	fe849be3          	bne	s1,s0,ffffffffc0203d2a <_lru_check_swap+0x2b4>
    cprintf("---------end-----------\n");
ffffffffc0203d38:	00002517          	auipc	a0,0x2
ffffffffc0203d3c:	28850513          	addi	a0,a0,648 # ffffffffc0205fc0 <default_pmm_manager+0xc0>
ffffffffc0203d40:	b7afc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc0203d44:	00002517          	auipc	a0,0x2
ffffffffc0203d48:	31450513          	addi	a0,a0,788 # ffffffffc0206058 <default_pmm_manager+0x158>
ffffffffc0203d4c:	b6efc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d50:	6795                	lui	a5,0x5
ffffffffc0203d52:	4739                	li	a4,14
ffffffffc0203d54:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    cprintf("--------begin----------\n");
ffffffffc0203d58:	00002517          	auipc	a0,0x2
ffffffffc0203d5c:	23850513          	addi	a0,a0,568 # ffffffffc0205f90 <default_pmm_manager+0x90>
ffffffffc0203d60:	b5afc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203d64:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203d66:	00848d63          	beq	s1,s0,ffffffffc0203d80 <_lru_check_swap+0x30a>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203d6a:	00002917          	auipc	s2,0x2
ffffffffc0203d6e:	24690913          	addi	s2,s2,582 # ffffffffc0205fb0 <default_pmm_manager+0xb0>
ffffffffc0203d72:	688c                	ld	a1,16(s1)
ffffffffc0203d74:	854a                	mv	a0,s2
ffffffffc0203d76:	b44fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203d7a:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203d7c:	fe849be3          	bne	s1,s0,ffffffffc0203d72 <_lru_check_swap+0x2fc>
    cprintf("---------end-----------\n");
ffffffffc0203d80:	00002517          	auipc	a0,0x2
ffffffffc0203d84:	24050513          	addi	a0,a0,576 # ffffffffc0205fc0 <default_pmm_manager+0xc0>
ffffffffc0203d88:	b32fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0203d8c:	00002517          	auipc	a0,0x2
ffffffffc0203d90:	27c50513          	addi	a0,a0,636 # ffffffffc0206008 <default_pmm_manager+0x108>
ffffffffc0203d94:	b26fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203d98:	6785                	lui	a5,0x1
ffffffffc0203d9a:	0007c703          	lbu	a4,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203d9e:	47a9                	li	a5,10
ffffffffc0203da0:	04f71363          	bne	a4,a5,ffffffffc0203de6 <_lru_check_swap+0x370>
    cprintf("--------begin----------\n");
ffffffffc0203da4:	00002517          	auipc	a0,0x2
ffffffffc0203da8:	1ec50513          	addi	a0,a0,492 # ffffffffc0205f90 <default_pmm_manager+0x90>
ffffffffc0203dac:	b0efc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203db0:	6404                	ld	s1,8(s0)
    while ((le = list_next(le)) != head)
ffffffffc0203db2:	00848d63          	beq	s1,s0,ffffffffc0203dcc <_lru_check_swap+0x356>
        cprintf("vaddr: 0x%x\n", page->pra_vaddr);
ffffffffc0203db6:	00002917          	auipc	s2,0x2
ffffffffc0203dba:	1fa90913          	addi	s2,s2,506 # ffffffffc0205fb0 <default_pmm_manager+0xb0>
ffffffffc0203dbe:	688c                	ld	a1,16(s1)
ffffffffc0203dc0:	854a                	mv	a0,s2
ffffffffc0203dc2:	af8fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203dc6:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != head)
ffffffffc0203dc8:	fe849be3          	bne	s1,s0,ffffffffc0203dbe <_lru_check_swap+0x348>
    cprintf("---------end-----------\n");
ffffffffc0203dcc:	00002517          	auipc	a0,0x2
ffffffffc0203dd0:	1f450513          	addi	a0,a0,500 # ffffffffc0205fc0 <default_pmm_manager+0xc0>
ffffffffc0203dd4:	ae6fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0203dd8:	60e2                	ld	ra,24(sp)
ffffffffc0203dda:	6442                	ld	s0,16(sp)
ffffffffc0203ddc:	64a2                	ld	s1,8(sp)
ffffffffc0203dde:	6902                	ld	s2,0(sp)
ffffffffc0203de0:	4501                	li	a0,0
ffffffffc0203de2:	6105                	addi	sp,sp,32
ffffffffc0203de4:	8082                	ret
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203de6:	00002697          	auipc	a3,0x2
ffffffffc0203dea:	2c268693          	addi	a3,a3,706 # ffffffffc02060a8 <default_pmm_manager+0x1a8>
ffffffffc0203dee:	00001617          	auipc	a2,0x1
ffffffffc0203df2:	1d260613          	addi	a2,a2,466 # ffffffffc0204fc0 <commands+0x888>
ffffffffc0203df6:	05b00593          	li	a1,91
ffffffffc0203dfa:	00002517          	auipc	a0,0x2
ffffffffc0203dfe:	14e50513          	addi	a0,a0,334 # ffffffffc0205f48 <default_pmm_manager+0x48>
ffffffffc0203e02:	b00fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203e06 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203e06:	1141                	addi	sp,sp,-16
    // 确保每一页可以被完整地映射为若干个扇区（PAGE_NSECT 个扇区），避免读写时出现对齐问题
    static_assert((PGSIZE % SECTSIZE) == 0);
    // 检查交换设备（SWAP_DEV_NO）是否有效
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e08:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203e0a:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e0c:	dc6fc0ef          	jal	ra,ffffffffc02003d2 <ide_device_valid>
ffffffffc0203e10:	cd01                	beqz	a0,ffffffffc0203e28 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    // 确定交换区可以支持的最大页数量
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e12:	4505                	li	a0,1
ffffffffc0203e14:	dc4fc0ef          	jal	ra,ffffffffc02003d8 <ide_device_size>
}
ffffffffc0203e18:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e1a:	810d                	srli	a0,a0,0x3
ffffffffc0203e1c:	0000d797          	auipc	a5,0xd
ffffffffc0203e20:	72a7ba23          	sd	a0,1844(a5) # ffffffffc0211550 <max_swap_offset>
}
ffffffffc0203e24:	0141                	addi	sp,sp,16
ffffffffc0203e26:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203e28:	00002617          	auipc	a2,0x2
ffffffffc0203e2c:	2c060613          	addi	a2,a2,704 # ffffffffc02060e8 <default_pmm_manager+0x1e8>
ffffffffc0203e30:	45bd                	li	a1,15
ffffffffc0203e32:	00002517          	auipc	a0,0x2
ffffffffc0203e36:	2d650513          	addi	a0,a0,726 # ffffffffc0206108 <default_pmm_manager+0x208>
ffffffffc0203e3a:	ac8fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203e3e <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203e3e:	1141                	addi	sp,sp,-16
ffffffffc0203e40:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e42:	00855793          	srli	a5,a0,0x8
ffffffffc0203e46:	c3a5                	beqz	a5,ffffffffc0203ea6 <swapfs_read+0x68>
ffffffffc0203e48:	0000d717          	auipc	a4,0xd
ffffffffc0203e4c:	70873703          	ld	a4,1800(a4) # ffffffffc0211550 <max_swap_offset>
ffffffffc0203e50:	04e7fb63          	bgeu	a5,a4,ffffffffc0203ea6 <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e54:	0000d617          	auipc	a2,0xd
ffffffffc0203e58:	6d463603          	ld	a2,1748(a2) # ffffffffc0211528 <pages>
ffffffffc0203e5c:	8d91                	sub	a1,a1,a2
ffffffffc0203e5e:	4035d613          	srai	a2,a1,0x3
ffffffffc0203e62:	00002597          	auipc	a1,0x2
ffffffffc0203e66:	5265b583          	ld	a1,1318(a1) # ffffffffc0206388 <error_string+0x38>
ffffffffc0203e6a:	02b60633          	mul	a2,a2,a1
ffffffffc0203e6e:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203e72:	00002797          	auipc	a5,0x2
ffffffffc0203e76:	51e7b783          	ld	a5,1310(a5) # ffffffffc0206390 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e7a:	0000d717          	auipc	a4,0xd
ffffffffc0203e7e:	6a673703          	ld	a4,1702(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e82:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e84:	00c61793          	slli	a5,a2,0xc
ffffffffc0203e88:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203e8a:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e8c:	02e7f963          	bgeu	a5,a4,ffffffffc0203ebe <swapfs_read+0x80>
}
ffffffffc0203e90:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e92:	0000d797          	auipc	a5,0xd
ffffffffc0203e96:	6a67b783          	ld	a5,1702(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0203e9a:	46a1                	li	a3,8
ffffffffc0203e9c:	963e                	add	a2,a2,a5
ffffffffc0203e9e:	4505                	li	a0,1
}
ffffffffc0203ea0:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ea2:	d3cfc06f          	j	ffffffffc02003de <ide_read_secs>
ffffffffc0203ea6:	86aa                	mv	a3,a0
ffffffffc0203ea8:	00002617          	auipc	a2,0x2
ffffffffc0203eac:	27860613          	addi	a2,a2,632 # ffffffffc0206120 <default_pmm_manager+0x220>
ffffffffc0203eb0:	45dd                	li	a1,23
ffffffffc0203eb2:	00002517          	auipc	a0,0x2
ffffffffc0203eb6:	25650513          	addi	a0,a0,598 # ffffffffc0206108 <default_pmm_manager+0x208>
ffffffffc0203eba:	a48fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203ebe:	86b2                	mv	a3,a2
ffffffffc0203ec0:	06a00593          	li	a1,106
ffffffffc0203ec4:	00001617          	auipc	a2,0x1
ffffffffc0203ec8:	fd460613          	addi	a2,a2,-44 # ffffffffc0204e98 <commands+0x760>
ffffffffc0203ecc:	00001517          	auipc	a0,0x1
ffffffffc0203ed0:	f9450513          	addi	a0,a0,-108 # ffffffffc0204e60 <commands+0x728>
ffffffffc0203ed4:	a2efc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203ed8 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203ed8:	1141                	addi	sp,sp,-16
ffffffffc0203eda:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203edc:	00855793          	srli	a5,a0,0x8
ffffffffc0203ee0:	c3a5                	beqz	a5,ffffffffc0203f40 <swapfs_write+0x68>
ffffffffc0203ee2:	0000d717          	auipc	a4,0xd
ffffffffc0203ee6:	66e73703          	ld	a4,1646(a4) # ffffffffc0211550 <max_swap_offset>
ffffffffc0203eea:	04e7fb63          	bgeu	a5,a4,ffffffffc0203f40 <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203eee:	0000d617          	auipc	a2,0xd
ffffffffc0203ef2:	63a63603          	ld	a2,1594(a2) # ffffffffc0211528 <pages>
ffffffffc0203ef6:	8d91                	sub	a1,a1,a2
ffffffffc0203ef8:	4035d613          	srai	a2,a1,0x3
ffffffffc0203efc:	00002597          	auipc	a1,0x2
ffffffffc0203f00:	48c5b583          	ld	a1,1164(a1) # ffffffffc0206388 <error_string+0x38>
ffffffffc0203f04:	02b60633          	mul	a2,a2,a1
ffffffffc0203f08:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203f0c:	00002797          	auipc	a5,0x2
ffffffffc0203f10:	4847b783          	ld	a5,1156(a5) # ffffffffc0206390 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f14:	0000d717          	auipc	a4,0xd
ffffffffc0203f18:	60c73703          	ld	a4,1548(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f1c:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f1e:	00c61793          	slli	a5,a2,0xc
ffffffffc0203f22:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f24:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f26:	02e7f963          	bgeu	a5,a4,ffffffffc0203f58 <swapfs_write+0x80>
}
ffffffffc0203f2a:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f2c:	0000d797          	auipc	a5,0xd
ffffffffc0203f30:	60c7b783          	ld	a5,1548(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0203f34:	46a1                	li	a3,8
ffffffffc0203f36:	963e                	add	a2,a2,a5
ffffffffc0203f38:	4505                	li	a0,1
}
ffffffffc0203f3a:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f3c:	cc6fc06f          	j	ffffffffc0200402 <ide_write_secs>
ffffffffc0203f40:	86aa                	mv	a3,a0
ffffffffc0203f42:	00002617          	auipc	a2,0x2
ffffffffc0203f46:	1de60613          	addi	a2,a2,478 # ffffffffc0206120 <default_pmm_manager+0x220>
ffffffffc0203f4a:	45f1                	li	a1,28
ffffffffc0203f4c:	00002517          	auipc	a0,0x2
ffffffffc0203f50:	1bc50513          	addi	a0,a0,444 # ffffffffc0206108 <default_pmm_manager+0x208>
ffffffffc0203f54:	9aefc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203f58:	86b2                	mv	a3,a2
ffffffffc0203f5a:	06a00593          	li	a1,106
ffffffffc0203f5e:	00001617          	auipc	a2,0x1
ffffffffc0203f62:	f3a60613          	addi	a2,a2,-198 # ffffffffc0204e98 <commands+0x760>
ffffffffc0203f66:	00001517          	auipc	a0,0x1
ffffffffc0203f6a:	efa50513          	addi	a0,a0,-262 # ffffffffc0204e60 <commands+0x728>
ffffffffc0203f6e:	994fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203f72 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203f72:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0203f76:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0203f78:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0203f7a:	cb81                	beqz	a5,ffffffffc0203f8a <strlen+0x18>
        cnt ++;
ffffffffc0203f7c:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0203f7e:	00a707b3          	add	a5,a4,a0
ffffffffc0203f82:	0007c783          	lbu	a5,0(a5)
ffffffffc0203f86:	fbfd                	bnez	a5,ffffffffc0203f7c <strlen+0xa>
ffffffffc0203f88:	8082                	ret
    }
    return cnt;
}
ffffffffc0203f8a:	8082                	ret

ffffffffc0203f8c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203f8c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203f8e:	e589                	bnez	a1,ffffffffc0203f98 <strnlen+0xc>
ffffffffc0203f90:	a811                	j	ffffffffc0203fa4 <strnlen+0x18>
        cnt ++;
ffffffffc0203f92:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203f94:	00f58863          	beq	a1,a5,ffffffffc0203fa4 <strnlen+0x18>
ffffffffc0203f98:	00f50733          	add	a4,a0,a5
ffffffffc0203f9c:	00074703          	lbu	a4,0(a4)
ffffffffc0203fa0:	fb6d                	bnez	a4,ffffffffc0203f92 <strnlen+0x6>
ffffffffc0203fa2:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203fa4:	852e                	mv	a0,a1
ffffffffc0203fa6:	8082                	ret

ffffffffc0203fa8 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203fa8:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203faa:	0005c703          	lbu	a4,0(a1)
ffffffffc0203fae:	0785                	addi	a5,a5,1
ffffffffc0203fb0:	0585                	addi	a1,a1,1
ffffffffc0203fb2:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203fb6:	fb75                	bnez	a4,ffffffffc0203faa <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203fb8:	8082                	ret

ffffffffc0203fba <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203fba:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203fbe:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203fc2:	cb89                	beqz	a5,ffffffffc0203fd4 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0203fc4:	0505                	addi	a0,a0,1
ffffffffc0203fc6:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203fc8:	fee789e3          	beq	a5,a4,ffffffffc0203fba <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203fcc:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203fd0:	9d19                	subw	a0,a0,a4
ffffffffc0203fd2:	8082                	ret
ffffffffc0203fd4:	4501                	li	a0,0
ffffffffc0203fd6:	bfed                	j	ffffffffc0203fd0 <strcmp+0x16>

ffffffffc0203fd8 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203fd8:	00054783          	lbu	a5,0(a0)
ffffffffc0203fdc:	c799                	beqz	a5,ffffffffc0203fea <strchr+0x12>
        if (*s == c) {
ffffffffc0203fde:	00f58763          	beq	a1,a5,ffffffffc0203fec <strchr+0x14>
    while (*s != '\0') {
ffffffffc0203fe2:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0203fe6:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203fe8:	fbfd                	bnez	a5,ffffffffc0203fde <strchr+0x6>
    }
    return NULL;
ffffffffc0203fea:	4501                	li	a0,0
}
ffffffffc0203fec:	8082                	ret

ffffffffc0203fee <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203fee:	ca01                	beqz	a2,ffffffffc0203ffe <memset+0x10>
ffffffffc0203ff0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203ff2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203ff4:	0785                	addi	a5,a5,1
ffffffffc0203ff6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203ffa:	fec79de3          	bne	a5,a2,ffffffffc0203ff4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203ffe:	8082                	ret

ffffffffc0204000 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204000:	ca19                	beqz	a2,ffffffffc0204016 <memcpy+0x16>
ffffffffc0204002:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204004:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204006:	0005c703          	lbu	a4,0(a1)
ffffffffc020400a:	0585                	addi	a1,a1,1
ffffffffc020400c:	0785                	addi	a5,a5,1
ffffffffc020400e:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204012:	fec59ae3          	bne	a1,a2,ffffffffc0204006 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204016:	8082                	ret

ffffffffc0204018 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204018:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020401c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020401e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204022:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204024:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204028:	f022                	sd	s0,32(sp)
ffffffffc020402a:	ec26                	sd	s1,24(sp)
ffffffffc020402c:	e84a                	sd	s2,16(sp)
ffffffffc020402e:	f406                	sd	ra,40(sp)
ffffffffc0204030:	e44e                	sd	s3,8(sp)
ffffffffc0204032:	84aa                	mv	s1,a0
ffffffffc0204034:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204036:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020403a:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020403c:	03067e63          	bgeu	a2,a6,ffffffffc0204078 <printnum+0x60>
ffffffffc0204040:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0204042:	00805763          	blez	s0,ffffffffc0204050 <printnum+0x38>
ffffffffc0204046:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204048:	85ca                	mv	a1,s2
ffffffffc020404a:	854e                	mv	a0,s3
ffffffffc020404c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020404e:	fc65                	bnez	s0,ffffffffc0204046 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204050:	1a02                	slli	s4,s4,0x20
ffffffffc0204052:	00002797          	auipc	a5,0x2
ffffffffc0204056:	0ee78793          	addi	a5,a5,238 # ffffffffc0206140 <default_pmm_manager+0x240>
ffffffffc020405a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020405e:	9a3e                	add	s4,s4,a5
}
ffffffffc0204060:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204062:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204066:	70a2                	ld	ra,40(sp)
ffffffffc0204068:	69a2                	ld	s3,8(sp)
ffffffffc020406a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020406c:	85ca                	mv	a1,s2
ffffffffc020406e:	87a6                	mv	a5,s1
}
ffffffffc0204070:	6942                	ld	s2,16(sp)
ffffffffc0204072:	64e2                	ld	s1,24(sp)
ffffffffc0204074:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204076:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204078:	03065633          	divu	a2,a2,a6
ffffffffc020407c:	8722                	mv	a4,s0
ffffffffc020407e:	f9bff0ef          	jal	ra,ffffffffc0204018 <printnum>
ffffffffc0204082:	b7f9                	j	ffffffffc0204050 <printnum+0x38>

ffffffffc0204084 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204084:	7119                	addi	sp,sp,-128
ffffffffc0204086:	f4a6                	sd	s1,104(sp)
ffffffffc0204088:	f0ca                	sd	s2,96(sp)
ffffffffc020408a:	ecce                	sd	s3,88(sp)
ffffffffc020408c:	e8d2                	sd	s4,80(sp)
ffffffffc020408e:	e4d6                	sd	s5,72(sp)
ffffffffc0204090:	e0da                	sd	s6,64(sp)
ffffffffc0204092:	fc5e                	sd	s7,56(sp)
ffffffffc0204094:	f06a                	sd	s10,32(sp)
ffffffffc0204096:	fc86                	sd	ra,120(sp)
ffffffffc0204098:	f8a2                	sd	s0,112(sp)
ffffffffc020409a:	f862                	sd	s8,48(sp)
ffffffffc020409c:	f466                	sd	s9,40(sp)
ffffffffc020409e:	ec6e                	sd	s11,24(sp)
ffffffffc02040a0:	892a                	mv	s2,a0
ffffffffc02040a2:	84ae                	mv	s1,a1
ffffffffc02040a4:	8d32                	mv	s10,a2
ffffffffc02040a6:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02040a8:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02040ac:	5b7d                	li	s6,-1
ffffffffc02040ae:	00002a97          	auipc	s5,0x2
ffffffffc02040b2:	0c6a8a93          	addi	s5,s5,198 # ffffffffc0206174 <default_pmm_manager+0x274>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02040b6:	00002b97          	auipc	s7,0x2
ffffffffc02040ba:	29ab8b93          	addi	s7,s7,666 # ffffffffc0206350 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02040be:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc02040c2:	001d0413          	addi	s0,s10,1
ffffffffc02040c6:	01350a63          	beq	a0,s3,ffffffffc02040da <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02040ca:	c121                	beqz	a0,ffffffffc020410a <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02040cc:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02040ce:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02040d0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02040d2:	fff44503          	lbu	a0,-1(s0)
ffffffffc02040d6:	ff351ae3          	bne	a0,s3,ffffffffc02040ca <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040da:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02040de:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02040e2:	4c81                	li	s9,0
ffffffffc02040e4:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02040e6:	5c7d                	li	s8,-1
ffffffffc02040e8:	5dfd                	li	s11,-1
ffffffffc02040ea:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02040ee:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040f0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02040f4:	0ff5f593          	zext.b	a1,a1
ffffffffc02040f8:	00140d13          	addi	s10,s0,1
ffffffffc02040fc:	04b56263          	bltu	a0,a1,ffffffffc0204140 <vprintfmt+0xbc>
ffffffffc0204100:	058a                	slli	a1,a1,0x2
ffffffffc0204102:	95d6                	add	a1,a1,s5
ffffffffc0204104:	4194                	lw	a3,0(a1)
ffffffffc0204106:	96d6                	add	a3,a3,s5
ffffffffc0204108:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020410a:	70e6                	ld	ra,120(sp)
ffffffffc020410c:	7446                	ld	s0,112(sp)
ffffffffc020410e:	74a6                	ld	s1,104(sp)
ffffffffc0204110:	7906                	ld	s2,96(sp)
ffffffffc0204112:	69e6                	ld	s3,88(sp)
ffffffffc0204114:	6a46                	ld	s4,80(sp)
ffffffffc0204116:	6aa6                	ld	s5,72(sp)
ffffffffc0204118:	6b06                	ld	s6,64(sp)
ffffffffc020411a:	7be2                	ld	s7,56(sp)
ffffffffc020411c:	7c42                	ld	s8,48(sp)
ffffffffc020411e:	7ca2                	ld	s9,40(sp)
ffffffffc0204120:	7d02                	ld	s10,32(sp)
ffffffffc0204122:	6de2                	ld	s11,24(sp)
ffffffffc0204124:	6109                	addi	sp,sp,128
ffffffffc0204126:	8082                	ret
            padc = '0';
ffffffffc0204128:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020412a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020412e:	846a                	mv	s0,s10
ffffffffc0204130:	00140d13          	addi	s10,s0,1
ffffffffc0204134:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204138:	0ff5f593          	zext.b	a1,a1
ffffffffc020413c:	fcb572e3          	bgeu	a0,a1,ffffffffc0204100 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204140:	85a6                	mv	a1,s1
ffffffffc0204142:	02500513          	li	a0,37
ffffffffc0204146:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204148:	fff44783          	lbu	a5,-1(s0)
ffffffffc020414c:	8d22                	mv	s10,s0
ffffffffc020414e:	f73788e3          	beq	a5,s3,ffffffffc02040be <vprintfmt+0x3a>
ffffffffc0204152:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204156:	1d7d                	addi	s10,s10,-1
ffffffffc0204158:	ff379de3          	bne	a5,s3,ffffffffc0204152 <vprintfmt+0xce>
ffffffffc020415c:	b78d                	j	ffffffffc02040be <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020415e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204162:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204166:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204168:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020416c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204170:	02d86463          	bltu	a6,a3,ffffffffc0204198 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0204174:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204178:	002c169b          	slliw	a3,s8,0x2
ffffffffc020417c:	0186873b          	addw	a4,a3,s8
ffffffffc0204180:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204184:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204186:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020418a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020418c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204190:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204194:	fed870e3          	bgeu	a6,a3,ffffffffc0204174 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204198:	f40ddce3          	bgez	s11,ffffffffc02040f0 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020419c:	8de2                	mv	s11,s8
ffffffffc020419e:	5c7d                	li	s8,-1
ffffffffc02041a0:	bf81                	j	ffffffffc02040f0 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02041a2:	fffdc693          	not	a3,s11
ffffffffc02041a6:	96fd                	srai	a3,a3,0x3f
ffffffffc02041a8:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041ac:	00144603          	lbu	a2,1(s0)
ffffffffc02041b0:	2d81                	sext.w	s11,s11
ffffffffc02041b2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02041b4:	bf35                	j	ffffffffc02040f0 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02041b6:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041ba:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02041be:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041c0:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02041c2:	bfd9                	j	ffffffffc0204198 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02041c4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02041c6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02041ca:	01174463          	blt	a4,a7,ffffffffc02041d2 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02041ce:	1a088e63          	beqz	a7,ffffffffc020438a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02041d2:	000a3603          	ld	a2,0(s4)
ffffffffc02041d6:	46c1                	li	a3,16
ffffffffc02041d8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02041da:	2781                	sext.w	a5,a5
ffffffffc02041dc:	876e                	mv	a4,s11
ffffffffc02041de:	85a6                	mv	a1,s1
ffffffffc02041e0:	854a                	mv	a0,s2
ffffffffc02041e2:	e37ff0ef          	jal	ra,ffffffffc0204018 <printnum>
            break;
ffffffffc02041e6:	bde1                	j	ffffffffc02040be <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02041e8:	000a2503          	lw	a0,0(s4)
ffffffffc02041ec:	85a6                	mv	a1,s1
ffffffffc02041ee:	0a21                	addi	s4,s4,8
ffffffffc02041f0:	9902                	jalr	s2
            break;
ffffffffc02041f2:	b5f1                	j	ffffffffc02040be <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02041f4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02041f6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02041fa:	01174463          	blt	a4,a7,ffffffffc0204202 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02041fe:	18088163          	beqz	a7,ffffffffc0204380 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204202:	000a3603          	ld	a2,0(s4)
ffffffffc0204206:	46a9                	li	a3,10
ffffffffc0204208:	8a2e                	mv	s4,a1
ffffffffc020420a:	bfc1                	j	ffffffffc02041da <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020420c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204210:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204212:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204214:	bdf1                	j	ffffffffc02040f0 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204216:	85a6                	mv	a1,s1
ffffffffc0204218:	02500513          	li	a0,37
ffffffffc020421c:	9902                	jalr	s2
            break;
ffffffffc020421e:	b545                	j	ffffffffc02040be <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204220:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204224:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204226:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204228:	b5e1                	j	ffffffffc02040f0 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020422a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020422c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204230:	01174463          	blt	a4,a7,ffffffffc0204238 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0204234:	14088163          	beqz	a7,ffffffffc0204376 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204238:	000a3603          	ld	a2,0(s4)
ffffffffc020423c:	46a1                	li	a3,8
ffffffffc020423e:	8a2e                	mv	s4,a1
ffffffffc0204240:	bf69                	j	ffffffffc02041da <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204242:	03000513          	li	a0,48
ffffffffc0204246:	85a6                	mv	a1,s1
ffffffffc0204248:	e03e                	sd	a5,0(sp)
ffffffffc020424a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020424c:	85a6                	mv	a1,s1
ffffffffc020424e:	07800513          	li	a0,120
ffffffffc0204252:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204254:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204256:	6782                	ld	a5,0(sp)
ffffffffc0204258:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020425a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020425e:	bfb5                	j	ffffffffc02041da <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204260:	000a3403          	ld	s0,0(s4)
ffffffffc0204264:	008a0713          	addi	a4,s4,8
ffffffffc0204268:	e03a                	sd	a4,0(sp)
ffffffffc020426a:	14040263          	beqz	s0,ffffffffc02043ae <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020426e:	0fb05763          	blez	s11,ffffffffc020435c <vprintfmt+0x2d8>
ffffffffc0204272:	02d00693          	li	a3,45
ffffffffc0204276:	0cd79163          	bne	a5,a3,ffffffffc0204338 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020427a:	00044783          	lbu	a5,0(s0)
ffffffffc020427e:	0007851b          	sext.w	a0,a5
ffffffffc0204282:	cf85                	beqz	a5,ffffffffc02042ba <vprintfmt+0x236>
ffffffffc0204284:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204288:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020428c:	000c4563          	bltz	s8,ffffffffc0204296 <vprintfmt+0x212>
ffffffffc0204290:	3c7d                	addiw	s8,s8,-1
ffffffffc0204292:	036c0263          	beq	s8,s6,ffffffffc02042b6 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204296:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204298:	0e0c8e63          	beqz	s9,ffffffffc0204394 <vprintfmt+0x310>
ffffffffc020429c:	3781                	addiw	a5,a5,-32
ffffffffc020429e:	0ef47b63          	bgeu	s0,a5,ffffffffc0204394 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02042a2:	03f00513          	li	a0,63
ffffffffc02042a6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042a8:	000a4783          	lbu	a5,0(s4)
ffffffffc02042ac:	3dfd                	addiw	s11,s11,-1
ffffffffc02042ae:	0a05                	addi	s4,s4,1
ffffffffc02042b0:	0007851b          	sext.w	a0,a5
ffffffffc02042b4:	ffe1                	bnez	a5,ffffffffc020428c <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02042b6:	01b05963          	blez	s11,ffffffffc02042c8 <vprintfmt+0x244>
ffffffffc02042ba:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02042bc:	85a6                	mv	a1,s1
ffffffffc02042be:	02000513          	li	a0,32
ffffffffc02042c2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02042c4:	fe0d9be3          	bnez	s11,ffffffffc02042ba <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02042c8:	6a02                	ld	s4,0(sp)
ffffffffc02042ca:	bbd5                	j	ffffffffc02040be <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02042cc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02042ce:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02042d2:	01174463          	blt	a4,a7,ffffffffc02042da <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02042d6:	08088d63          	beqz	a7,ffffffffc0204370 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02042da:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02042de:	0a044d63          	bltz	s0,ffffffffc0204398 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02042e2:	8622                	mv	a2,s0
ffffffffc02042e4:	8a66                	mv	s4,s9
ffffffffc02042e6:	46a9                	li	a3,10
ffffffffc02042e8:	bdcd                	j	ffffffffc02041da <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02042ea:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02042ee:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02042f0:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02042f2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02042f6:	8fb5                	xor	a5,a5,a3
ffffffffc02042f8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02042fc:	02d74163          	blt	a4,a3,ffffffffc020431e <vprintfmt+0x29a>
ffffffffc0204300:	00369793          	slli	a5,a3,0x3
ffffffffc0204304:	97de                	add	a5,a5,s7
ffffffffc0204306:	639c                	ld	a5,0(a5)
ffffffffc0204308:	cb99                	beqz	a5,ffffffffc020431e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020430a:	86be                	mv	a3,a5
ffffffffc020430c:	00002617          	auipc	a2,0x2
ffffffffc0204310:	e6460613          	addi	a2,a2,-412 # ffffffffc0206170 <default_pmm_manager+0x270>
ffffffffc0204314:	85a6                	mv	a1,s1
ffffffffc0204316:	854a                	mv	a0,s2
ffffffffc0204318:	0ce000ef          	jal	ra,ffffffffc02043e6 <printfmt>
ffffffffc020431c:	b34d                	j	ffffffffc02040be <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020431e:	00002617          	auipc	a2,0x2
ffffffffc0204322:	e4260613          	addi	a2,a2,-446 # ffffffffc0206160 <default_pmm_manager+0x260>
ffffffffc0204326:	85a6                	mv	a1,s1
ffffffffc0204328:	854a                	mv	a0,s2
ffffffffc020432a:	0bc000ef          	jal	ra,ffffffffc02043e6 <printfmt>
ffffffffc020432e:	bb41                	j	ffffffffc02040be <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204330:	00002417          	auipc	s0,0x2
ffffffffc0204334:	e2840413          	addi	s0,s0,-472 # ffffffffc0206158 <default_pmm_manager+0x258>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204338:	85e2                	mv	a1,s8
ffffffffc020433a:	8522                	mv	a0,s0
ffffffffc020433c:	e43e                	sd	a5,8(sp)
ffffffffc020433e:	c4fff0ef          	jal	ra,ffffffffc0203f8c <strnlen>
ffffffffc0204342:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204346:	01b05b63          	blez	s11,ffffffffc020435c <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020434a:	67a2                	ld	a5,8(sp)
ffffffffc020434c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204350:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204352:	85a6                	mv	a1,s1
ffffffffc0204354:	8552                	mv	a0,s4
ffffffffc0204356:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204358:	fe0d9ce3          	bnez	s11,ffffffffc0204350 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020435c:	00044783          	lbu	a5,0(s0)
ffffffffc0204360:	00140a13          	addi	s4,s0,1
ffffffffc0204364:	0007851b          	sext.w	a0,a5
ffffffffc0204368:	d3a5                	beqz	a5,ffffffffc02042c8 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020436a:	05e00413          	li	s0,94
ffffffffc020436e:	bf39                	j	ffffffffc020428c <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204370:	000a2403          	lw	s0,0(s4)
ffffffffc0204374:	b7ad                	j	ffffffffc02042de <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204376:	000a6603          	lwu	a2,0(s4)
ffffffffc020437a:	46a1                	li	a3,8
ffffffffc020437c:	8a2e                	mv	s4,a1
ffffffffc020437e:	bdb1                	j	ffffffffc02041da <vprintfmt+0x156>
ffffffffc0204380:	000a6603          	lwu	a2,0(s4)
ffffffffc0204384:	46a9                	li	a3,10
ffffffffc0204386:	8a2e                	mv	s4,a1
ffffffffc0204388:	bd89                	j	ffffffffc02041da <vprintfmt+0x156>
ffffffffc020438a:	000a6603          	lwu	a2,0(s4)
ffffffffc020438e:	46c1                	li	a3,16
ffffffffc0204390:	8a2e                	mv	s4,a1
ffffffffc0204392:	b5a1                	j	ffffffffc02041da <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204394:	9902                	jalr	s2
ffffffffc0204396:	bf09                	j	ffffffffc02042a8 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204398:	85a6                	mv	a1,s1
ffffffffc020439a:	02d00513          	li	a0,45
ffffffffc020439e:	e03e                	sd	a5,0(sp)
ffffffffc02043a0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02043a2:	6782                	ld	a5,0(sp)
ffffffffc02043a4:	8a66                	mv	s4,s9
ffffffffc02043a6:	40800633          	neg	a2,s0
ffffffffc02043aa:	46a9                	li	a3,10
ffffffffc02043ac:	b53d                	j	ffffffffc02041da <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02043ae:	03b05163          	blez	s11,ffffffffc02043d0 <vprintfmt+0x34c>
ffffffffc02043b2:	02d00693          	li	a3,45
ffffffffc02043b6:	f6d79de3          	bne	a5,a3,ffffffffc0204330 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02043ba:	00002417          	auipc	s0,0x2
ffffffffc02043be:	d9e40413          	addi	s0,s0,-610 # ffffffffc0206158 <default_pmm_manager+0x258>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02043c2:	02800793          	li	a5,40
ffffffffc02043c6:	02800513          	li	a0,40
ffffffffc02043ca:	00140a13          	addi	s4,s0,1
ffffffffc02043ce:	bd6d                	j	ffffffffc0204288 <vprintfmt+0x204>
ffffffffc02043d0:	00002a17          	auipc	s4,0x2
ffffffffc02043d4:	d89a0a13          	addi	s4,s4,-631 # ffffffffc0206159 <default_pmm_manager+0x259>
ffffffffc02043d8:	02800513          	li	a0,40
ffffffffc02043dc:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02043e0:	05e00413          	li	s0,94
ffffffffc02043e4:	b565                	j	ffffffffc020428c <vprintfmt+0x208>

ffffffffc02043e6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043e6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02043e8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043ec:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02043ee:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043f0:	ec06                	sd	ra,24(sp)
ffffffffc02043f2:	f83a                	sd	a4,48(sp)
ffffffffc02043f4:	fc3e                	sd	a5,56(sp)
ffffffffc02043f6:	e0c2                	sd	a6,64(sp)
ffffffffc02043f8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02043fa:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02043fc:	c89ff0ef          	jal	ra,ffffffffc0204084 <vprintfmt>
}
ffffffffc0204400:	60e2                	ld	ra,24(sp)
ffffffffc0204402:	6161                	addi	sp,sp,80
ffffffffc0204404:	8082                	ret

ffffffffc0204406 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204406:	715d                	addi	sp,sp,-80
ffffffffc0204408:	e486                	sd	ra,72(sp)
ffffffffc020440a:	e0a6                	sd	s1,64(sp)
ffffffffc020440c:	fc4a                	sd	s2,56(sp)
ffffffffc020440e:	f84e                	sd	s3,48(sp)
ffffffffc0204410:	f452                	sd	s4,40(sp)
ffffffffc0204412:	f056                	sd	s5,32(sp)
ffffffffc0204414:	ec5a                	sd	s6,24(sp)
ffffffffc0204416:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0204418:	c901                	beqz	a0,ffffffffc0204428 <readline+0x22>
ffffffffc020441a:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020441c:	00002517          	auipc	a0,0x2
ffffffffc0204420:	d5450513          	addi	a0,a0,-684 # ffffffffc0206170 <default_pmm_manager+0x270>
ffffffffc0204424:	c97fb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc0204428:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020442a:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020442c:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020442e:	4aa9                	li	s5,10
ffffffffc0204430:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204432:	0000db97          	auipc	s7,0xd
ffffffffc0204436:	cc6b8b93          	addi	s7,s7,-826 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020443a:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020443e:	cb5fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204442:	00054a63          	bltz	a0,ffffffffc0204456 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204446:	00a95a63          	bge	s2,a0,ffffffffc020445a <readline+0x54>
ffffffffc020444a:	029a5263          	bge	s4,s1,ffffffffc020446e <readline+0x68>
        c = getchar();
ffffffffc020444e:	ca5fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204452:	fe055ae3          	bgez	a0,ffffffffc0204446 <readline+0x40>
            return NULL;
ffffffffc0204456:	4501                	li	a0,0
ffffffffc0204458:	a091                	j	ffffffffc020449c <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020445a:	03351463          	bne	a0,s3,ffffffffc0204482 <readline+0x7c>
ffffffffc020445e:	e8a9                	bnez	s1,ffffffffc02044b0 <readline+0xaa>
        c = getchar();
ffffffffc0204460:	c93fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204464:	fe0549e3          	bltz	a0,ffffffffc0204456 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204468:	fea959e3          	bge	s2,a0,ffffffffc020445a <readline+0x54>
ffffffffc020446c:	4481                	li	s1,0
            cputchar(c);
ffffffffc020446e:	e42a                	sd	a0,8(sp)
ffffffffc0204470:	c81fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc0204474:	6522                	ld	a0,8(sp)
ffffffffc0204476:	009b87b3          	add	a5,s7,s1
ffffffffc020447a:	2485                	addiw	s1,s1,1
ffffffffc020447c:	00a78023          	sb	a0,0(a5)
ffffffffc0204480:	bf7d                	j	ffffffffc020443e <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0204482:	01550463          	beq	a0,s5,ffffffffc020448a <readline+0x84>
ffffffffc0204486:	fb651ce3          	bne	a0,s6,ffffffffc020443e <readline+0x38>
            cputchar(c);
ffffffffc020448a:	c67fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc020448e:	0000d517          	auipc	a0,0xd
ffffffffc0204492:	c6a50513          	addi	a0,a0,-918 # ffffffffc02110f8 <buf>
ffffffffc0204496:	94aa                	add	s1,s1,a0
ffffffffc0204498:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020449c:	60a6                	ld	ra,72(sp)
ffffffffc020449e:	6486                	ld	s1,64(sp)
ffffffffc02044a0:	7962                	ld	s2,56(sp)
ffffffffc02044a2:	79c2                	ld	s3,48(sp)
ffffffffc02044a4:	7a22                	ld	s4,40(sp)
ffffffffc02044a6:	7a82                	ld	s5,32(sp)
ffffffffc02044a8:	6b62                	ld	s6,24(sp)
ffffffffc02044aa:	6bc2                	ld	s7,16(sp)
ffffffffc02044ac:	6161                	addi	sp,sp,80
ffffffffc02044ae:	8082                	ret
            cputchar(c);
ffffffffc02044b0:	4521                	li	a0,8
ffffffffc02044b2:	c3ffb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc02044b6:	34fd                	addiw	s1,s1,-1
ffffffffc02044b8:	b759                	j	ffffffffc020443e <readline+0x38>
