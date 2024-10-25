
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12(右移12位)，变为三级页表的物理页号
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
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	43660613          	addi	a2,a2,1078 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	44e010ef          	jal	ra,ffffffffc0201498 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3f8000ef          	jal	ra,ffffffffc0200446 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	94e50513          	addi	a0,a0,-1714 # ffffffffc02019a0 <etext+0x4>
ffffffffc020005a:	08c000ef          	jal	ra,ffffffffc02000e6 <cputs>

    print_kerninfo();
ffffffffc020005e:	134000ef          	jal	ra,ffffffffc0200192 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	3fe000ef          	jal	ra,ffffffffc0200460 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	04f000ef          	jal	ra,ffffffffc02008b4 <pmm_init>

    //idt_init();  // init interrupt descriptor table

    clock_init();   // init clock interrupt
ffffffffc020006a:	39a000ef          	jal	ra,ffffffffc0200404 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc020006e:	3e6000ef          	jal	ra,ffffffffc0200454 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200072:	a001                	j	ffffffffc0200072 <kern_init+0x40>

ffffffffc0200074 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200074:	1141                	addi	sp,sp,-16
ffffffffc0200076:	e022                	sd	s0,0(sp)
ffffffffc0200078:	e406                	sd	ra,8(sp)
ffffffffc020007a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020007c:	3cc000ef          	jal	ra,ffffffffc0200448 <cons_putc>
    (*cnt) ++;
ffffffffc0200080:	401c                	lw	a5,0(s0)
}
ffffffffc0200082:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200084:	2785                	addiw	a5,a5,1
ffffffffc0200086:	c01c                	sw	a5,0(s0)
}
ffffffffc0200088:	6402                	ld	s0,0(sp)
ffffffffc020008a:	0141                	addi	sp,sp,16
ffffffffc020008c:	8082                	ret

ffffffffc020008e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020008e:	1101                	addi	sp,sp,-32
ffffffffc0200090:	862a                	mv	a2,a0
ffffffffc0200092:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200094:	00000517          	auipc	a0,0x0
ffffffffc0200098:	fe050513          	addi	a0,a0,-32 # ffffffffc0200074 <cputch>
ffffffffc020009c:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a2:	474010ef          	jal	ra,ffffffffc0201516 <vprintfmt>
    return cnt;
}
ffffffffc02000a6:	60e2                	ld	ra,24(sp)
ffffffffc02000a8:	4532                	lw	a0,12(sp)
ffffffffc02000aa:	6105                	addi	sp,sp,32
ffffffffc02000ac:	8082                	ret

ffffffffc02000ae <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ae:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b0:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b4:	8e2a                	mv	t3,a0
ffffffffc02000b6:	f42e                	sd	a1,40(sp)
ffffffffc02000b8:	f832                	sd	a2,48(sp)
ffffffffc02000ba:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000bc:	00000517          	auipc	a0,0x0
ffffffffc02000c0:	fb850513          	addi	a0,a0,-72 # ffffffffc0200074 <cputch>
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	869a                	mv	a3,t1
ffffffffc02000c8:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ca:	ec06                	sd	ra,24(sp)
ffffffffc02000cc:	e0ba                	sd	a4,64(sp)
ffffffffc02000ce:	e4be                	sd	a5,72(sp)
ffffffffc02000d0:	e8c2                	sd	a6,80(sp)
ffffffffc02000d2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000d6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000d8:	43e010ef          	jal	ra,ffffffffc0201516 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000dc:	60e2                	ld	ra,24(sp)
ffffffffc02000de:	4512                	lw	a0,4(sp)
ffffffffc02000e0:	6125                	addi	sp,sp,96
ffffffffc02000e2:	8082                	ret

ffffffffc02000e4 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e4:	a695                	j	ffffffffc0200448 <cons_putc>

ffffffffc02000e6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000e6:	1101                	addi	sp,sp,-32
ffffffffc02000e8:	e822                	sd	s0,16(sp)
ffffffffc02000ea:	ec06                	sd	ra,24(sp)
ffffffffc02000ec:	e426                	sd	s1,8(sp)
ffffffffc02000ee:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f0:	00054503          	lbu	a0,0(a0)
ffffffffc02000f4:	c51d                	beqz	a0,ffffffffc0200122 <cputs+0x3c>
ffffffffc02000f6:	0405                	addi	s0,s0,1
ffffffffc02000f8:	4485                	li	s1,1
ffffffffc02000fa:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02000fc:	34c000ef          	jal	ra,ffffffffc0200448 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200100:	00044503          	lbu	a0,0(s0)
ffffffffc0200104:	008487bb          	addw	a5,s1,s0
ffffffffc0200108:	0405                	addi	s0,s0,1
ffffffffc020010a:	f96d                	bnez	a0,ffffffffc02000fc <cputs+0x16>
    (*cnt) ++;
ffffffffc020010c:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200110:	4529                	li	a0,10
ffffffffc0200112:	336000ef          	jal	ra,ffffffffc0200448 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200116:	60e2                	ld	ra,24(sp)
ffffffffc0200118:	8522                	mv	a0,s0
ffffffffc020011a:	6442                	ld	s0,16(sp)
ffffffffc020011c:	64a2                	ld	s1,8(sp)
ffffffffc020011e:	6105                	addi	sp,sp,32
ffffffffc0200120:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200122:	4405                	li	s0,1
ffffffffc0200124:	b7f5                	j	ffffffffc0200110 <cputs+0x2a>

ffffffffc0200126 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200126:	1141                	addi	sp,sp,-16
ffffffffc0200128:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012a:	326000ef          	jal	ra,ffffffffc0200450 <cons_getc>
ffffffffc020012e:	dd75                	beqz	a0,ffffffffc020012a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200130:	60a2                	ld	ra,8(sp)
ffffffffc0200132:	0141                	addi	sp,sp,16
ffffffffc0200134:	8082                	ret

ffffffffc0200136 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200136:	00006317          	auipc	t1,0x6
ffffffffc020013a:	2f230313          	addi	t1,t1,754 # ffffffffc0206428 <is_panic>
ffffffffc020013e:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200142:	715d                	addi	sp,sp,-80
ffffffffc0200144:	ec06                	sd	ra,24(sp)
ffffffffc0200146:	e822                	sd	s0,16(sp)
ffffffffc0200148:	f436                	sd	a3,40(sp)
ffffffffc020014a:	f83a                	sd	a4,48(sp)
ffffffffc020014c:	fc3e                	sd	a5,56(sp)
ffffffffc020014e:	e0c2                	sd	a6,64(sp)
ffffffffc0200150:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200152:	020e1a63          	bnez	t3,ffffffffc0200186 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200156:	4785                	li	a5,1
ffffffffc0200158:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020015c:	8432                	mv	s0,a2
ffffffffc020015e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200160:	862e                	mv	a2,a1
ffffffffc0200162:	85aa                	mv	a1,a0
ffffffffc0200164:	00002517          	auipc	a0,0x2
ffffffffc0200168:	85c50513          	addi	a0,a0,-1956 # ffffffffc02019c0 <etext+0x24>
    va_start(ap, fmt);
ffffffffc020016c:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016e:	f41ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200172:	65a2                	ld	a1,8(sp)
ffffffffc0200174:	8522                	mv	a0,s0
ffffffffc0200176:	f19ff0ef          	jal	ra,ffffffffc020008e <vcprintf>
    cprintf("\n");
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	92e50513          	addi	a0,a0,-1746 # ffffffffc0201aa8 <etext+0x10c>
ffffffffc0200182:	f2dff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200186:	2d4000ef          	jal	ra,ffffffffc020045a <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020018a:	4501                	li	a0,0
ffffffffc020018c:	130000ef          	jal	ra,ffffffffc02002bc <kmonitor>
    while (1) {
ffffffffc0200190:	bfed                	j	ffffffffc020018a <__panic+0x54>

ffffffffc0200192 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200192:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200194:	00002517          	auipc	a0,0x2
ffffffffc0200198:	84c50513          	addi	a0,a0,-1972 # ffffffffc02019e0 <etext+0x44>
void print_kerninfo(void) {
ffffffffc020019c:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020019e:	f11ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001a2:	00000597          	auipc	a1,0x0
ffffffffc02001a6:	e9058593          	addi	a1,a1,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	00002517          	auipc	a0,0x2
ffffffffc02001ae:	85650513          	addi	a0,a0,-1962 # ffffffffc0201a00 <etext+0x64>
ffffffffc02001b2:	efdff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001b6:	00001597          	auipc	a1,0x1
ffffffffc02001ba:	7e658593          	addi	a1,a1,2022 # ffffffffc020199c <etext>
ffffffffc02001be:	00002517          	auipc	a0,0x2
ffffffffc02001c2:	86250513          	addi	a0,a0,-1950 # ffffffffc0201a20 <etext+0x84>
ffffffffc02001c6:	ee9ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001ca:	00006597          	auipc	a1,0x6
ffffffffc02001ce:	e4658593          	addi	a1,a1,-442 # ffffffffc0206010 <free_area>
ffffffffc02001d2:	00002517          	auipc	a0,0x2
ffffffffc02001d6:	86e50513          	addi	a0,a0,-1938 # ffffffffc0201a40 <etext+0xa4>
ffffffffc02001da:	ed5ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001de:	00006597          	auipc	a1,0x6
ffffffffc02001e2:	29258593          	addi	a1,a1,658 # ffffffffc0206470 <end>
ffffffffc02001e6:	00002517          	auipc	a0,0x2
ffffffffc02001ea:	87a50513          	addi	a0,a0,-1926 # ffffffffc0201a60 <etext+0xc4>
ffffffffc02001ee:	ec1ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001f2:	00006597          	auipc	a1,0x6
ffffffffc02001f6:	67d58593          	addi	a1,a1,1661 # ffffffffc020686f <end+0x3ff>
ffffffffc02001fa:	00000797          	auipc	a5,0x0
ffffffffc02001fe:	e3878793          	addi	a5,a5,-456 # ffffffffc0200032 <kern_init>
ffffffffc0200202:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200206:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020020a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020020c:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200210:	95be                	add	a1,a1,a5
ffffffffc0200212:	85a9                	srai	a1,a1,0xa
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	86c50513          	addi	a0,a0,-1940 # ffffffffc0201a80 <etext+0xe4>
}
ffffffffc020021c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020021e:	bd41                	j	ffffffffc02000ae <cprintf>

ffffffffc0200220 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200220:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200222:	00002617          	auipc	a2,0x2
ffffffffc0200226:	88e60613          	addi	a2,a2,-1906 # ffffffffc0201ab0 <etext+0x114>
ffffffffc020022a:	04e00593          	li	a1,78
ffffffffc020022e:	00002517          	auipc	a0,0x2
ffffffffc0200232:	89a50513          	addi	a0,a0,-1894 # ffffffffc0201ac8 <etext+0x12c>
void print_stackframe(void) {
ffffffffc0200236:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200238:	effff0ef          	jal	ra,ffffffffc0200136 <__panic>

ffffffffc020023c <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020023c:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020023e:	00002617          	auipc	a2,0x2
ffffffffc0200242:	8a260613          	addi	a2,a2,-1886 # ffffffffc0201ae0 <etext+0x144>
ffffffffc0200246:	00002597          	auipc	a1,0x2
ffffffffc020024a:	8ba58593          	addi	a1,a1,-1862 # ffffffffc0201b00 <etext+0x164>
ffffffffc020024e:	00002517          	auipc	a0,0x2
ffffffffc0200252:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0201b08 <etext+0x16c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200256:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200258:	e57ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
ffffffffc020025c:	00002617          	auipc	a2,0x2
ffffffffc0200260:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0201b18 <etext+0x17c>
ffffffffc0200264:	00002597          	auipc	a1,0x2
ffffffffc0200268:	8dc58593          	addi	a1,a1,-1828 # ffffffffc0201b40 <etext+0x1a4>
ffffffffc020026c:	00002517          	auipc	a0,0x2
ffffffffc0200270:	89c50513          	addi	a0,a0,-1892 # ffffffffc0201b08 <etext+0x16c>
ffffffffc0200274:	e3bff0ef          	jal	ra,ffffffffc02000ae <cprintf>
ffffffffc0200278:	00002617          	auipc	a2,0x2
ffffffffc020027c:	8d860613          	addi	a2,a2,-1832 # ffffffffc0201b50 <etext+0x1b4>
ffffffffc0200280:	00002597          	auipc	a1,0x2
ffffffffc0200284:	8f058593          	addi	a1,a1,-1808 # ffffffffc0201b70 <etext+0x1d4>
ffffffffc0200288:	00002517          	auipc	a0,0x2
ffffffffc020028c:	88050513          	addi	a0,a0,-1920 # ffffffffc0201b08 <etext+0x16c>
ffffffffc0200290:	e1fff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    }
    return 0;
}
ffffffffc0200294:	60a2                	ld	ra,8(sp)
ffffffffc0200296:	4501                	li	a0,0
ffffffffc0200298:	0141                	addi	sp,sp,16
ffffffffc020029a:	8082                	ret

ffffffffc020029c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020029c:	1141                	addi	sp,sp,-16
ffffffffc020029e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002a0:	ef3ff0ef          	jal	ra,ffffffffc0200192 <print_kerninfo>
    return 0;
}
ffffffffc02002a4:	60a2                	ld	ra,8(sp)
ffffffffc02002a6:	4501                	li	a0,0
ffffffffc02002a8:	0141                	addi	sp,sp,16
ffffffffc02002aa:	8082                	ret

ffffffffc02002ac <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ac:	1141                	addi	sp,sp,-16
ffffffffc02002ae:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002b0:	f71ff0ef          	jal	ra,ffffffffc0200220 <print_stackframe>
    return 0;
}
ffffffffc02002b4:	60a2                	ld	ra,8(sp)
ffffffffc02002b6:	4501                	li	a0,0
ffffffffc02002b8:	0141                	addi	sp,sp,16
ffffffffc02002ba:	8082                	ret

ffffffffc02002bc <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002bc:	7115                	addi	sp,sp,-224
ffffffffc02002be:	ed5e                	sd	s7,152(sp)
ffffffffc02002c0:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002c2:	00002517          	auipc	a0,0x2
ffffffffc02002c6:	8be50513          	addi	a0,a0,-1858 # ffffffffc0201b80 <etext+0x1e4>
kmonitor(struct trapframe *tf) {
ffffffffc02002ca:	ed86                	sd	ra,216(sp)
ffffffffc02002cc:	e9a2                	sd	s0,208(sp)
ffffffffc02002ce:	e5a6                	sd	s1,200(sp)
ffffffffc02002d0:	e1ca                	sd	s2,192(sp)
ffffffffc02002d2:	fd4e                	sd	s3,184(sp)
ffffffffc02002d4:	f952                	sd	s4,176(sp)
ffffffffc02002d6:	f556                	sd	s5,168(sp)
ffffffffc02002d8:	f15a                	sd	s6,160(sp)
ffffffffc02002da:	e962                	sd	s8,144(sp)
ffffffffc02002dc:	e566                	sd	s9,136(sp)
ffffffffc02002de:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002e0:	dcfff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002e4:	00002517          	auipc	a0,0x2
ffffffffc02002e8:	8c450513          	addi	a0,a0,-1852 # ffffffffc0201ba8 <etext+0x20c>
ffffffffc02002ec:	dc3ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    if (tf != NULL) {
ffffffffc02002f0:	000b8563          	beqz	s7,ffffffffc02002fa <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002f4:	855e                	mv	a0,s7
ffffffffc02002f6:	348000ef          	jal	ra,ffffffffc020063e <print_trapframe>
ffffffffc02002fa:	00002c17          	auipc	s8,0x2
ffffffffc02002fe:	91ec0c13          	addi	s8,s8,-1762 # ffffffffc0201c18 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200302:	00002917          	auipc	s2,0x2
ffffffffc0200306:	8ce90913          	addi	s2,s2,-1842 # ffffffffc0201bd0 <etext+0x234>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030a:	00002497          	auipc	s1,0x2
ffffffffc020030e:	8ce48493          	addi	s1,s1,-1842 # ffffffffc0201bd8 <etext+0x23c>
        if (argc == MAXARGS - 1) {
ffffffffc0200312:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200314:	00002b17          	auipc	s6,0x2
ffffffffc0200318:	8ccb0b13          	addi	s6,s6,-1844 # ffffffffc0201be0 <etext+0x244>
        argv[argc ++] = buf;
ffffffffc020031c:	00001a17          	auipc	s4,0x1
ffffffffc0200320:	7e4a0a13          	addi	s4,s4,2020 # ffffffffc0201b00 <etext+0x164>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200324:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200326:	854a                	mv	a0,s2
ffffffffc0200328:	570010ef          	jal	ra,ffffffffc0201898 <readline>
ffffffffc020032c:	842a                	mv	s0,a0
ffffffffc020032e:	dd65                	beqz	a0,ffffffffc0200326 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200330:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200334:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200336:	e1bd                	bnez	a1,ffffffffc020039c <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200338:	fe0c87e3          	beqz	s9,ffffffffc0200326 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020033c:	6582                	ld	a1,0(sp)
ffffffffc020033e:	00002d17          	auipc	s10,0x2
ffffffffc0200342:	8dad0d13          	addi	s10,s10,-1830 # ffffffffc0201c18 <commands>
        argv[argc ++] = buf;
ffffffffc0200346:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200348:	4401                	li	s0,0
ffffffffc020034a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020034c:	118010ef          	jal	ra,ffffffffc0201464 <strcmp>
ffffffffc0200350:	c919                	beqz	a0,ffffffffc0200366 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200352:	2405                	addiw	s0,s0,1
ffffffffc0200354:	0b540063          	beq	s0,s5,ffffffffc02003f4 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200358:	000d3503          	ld	a0,0(s10)
ffffffffc020035c:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020035e:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200360:	104010ef          	jal	ra,ffffffffc0201464 <strcmp>
ffffffffc0200364:	f57d                	bnez	a0,ffffffffc0200352 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200366:	00141793          	slli	a5,s0,0x1
ffffffffc020036a:	97a2                	add	a5,a5,s0
ffffffffc020036c:	078e                	slli	a5,a5,0x3
ffffffffc020036e:	97e2                	add	a5,a5,s8
ffffffffc0200370:	6b9c                	ld	a5,16(a5)
ffffffffc0200372:	865e                	mv	a2,s7
ffffffffc0200374:	002c                	addi	a1,sp,8
ffffffffc0200376:	fffc851b          	addiw	a0,s9,-1
ffffffffc020037a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020037c:	fa0555e3          	bgez	a0,ffffffffc0200326 <kmonitor+0x6a>
}
ffffffffc0200380:	60ee                	ld	ra,216(sp)
ffffffffc0200382:	644e                	ld	s0,208(sp)
ffffffffc0200384:	64ae                	ld	s1,200(sp)
ffffffffc0200386:	690e                	ld	s2,192(sp)
ffffffffc0200388:	79ea                	ld	s3,184(sp)
ffffffffc020038a:	7a4a                	ld	s4,176(sp)
ffffffffc020038c:	7aaa                	ld	s5,168(sp)
ffffffffc020038e:	7b0a                	ld	s6,160(sp)
ffffffffc0200390:	6bea                	ld	s7,152(sp)
ffffffffc0200392:	6c4a                	ld	s8,144(sp)
ffffffffc0200394:	6caa                	ld	s9,136(sp)
ffffffffc0200396:	6d0a                	ld	s10,128(sp)
ffffffffc0200398:	612d                	addi	sp,sp,224
ffffffffc020039a:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020039c:	8526                	mv	a0,s1
ffffffffc020039e:	0e4010ef          	jal	ra,ffffffffc0201482 <strchr>
ffffffffc02003a2:	c901                	beqz	a0,ffffffffc02003b2 <kmonitor+0xf6>
ffffffffc02003a4:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003a8:	00040023          	sb	zero,0(s0)
ffffffffc02003ac:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ae:	d5c9                	beqz	a1,ffffffffc0200338 <kmonitor+0x7c>
ffffffffc02003b0:	b7f5                	j	ffffffffc020039c <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02003b2:	00044783          	lbu	a5,0(s0)
ffffffffc02003b6:	d3c9                	beqz	a5,ffffffffc0200338 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02003b8:	033c8963          	beq	s9,s3,ffffffffc02003ea <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02003bc:	003c9793          	slli	a5,s9,0x3
ffffffffc02003c0:	0118                	addi	a4,sp,128
ffffffffc02003c2:	97ba                	add	a5,a5,a4
ffffffffc02003c4:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003c8:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003cc:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003ce:	e591                	bnez	a1,ffffffffc02003da <kmonitor+0x11e>
ffffffffc02003d0:	b7b5                	j	ffffffffc020033c <kmonitor+0x80>
ffffffffc02003d2:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003d6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d8:	d1a5                	beqz	a1,ffffffffc0200338 <kmonitor+0x7c>
ffffffffc02003da:	8526                	mv	a0,s1
ffffffffc02003dc:	0a6010ef          	jal	ra,ffffffffc0201482 <strchr>
ffffffffc02003e0:	d96d                	beqz	a0,ffffffffc02003d2 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e2:	00044583          	lbu	a1,0(s0)
ffffffffc02003e6:	d9a9                	beqz	a1,ffffffffc0200338 <kmonitor+0x7c>
ffffffffc02003e8:	bf55                	j	ffffffffc020039c <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ea:	45c1                	li	a1,16
ffffffffc02003ec:	855a                	mv	a0,s6
ffffffffc02003ee:	cc1ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
ffffffffc02003f2:	b7e9                	j	ffffffffc02003bc <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003f4:	6582                	ld	a1,0(sp)
ffffffffc02003f6:	00002517          	auipc	a0,0x2
ffffffffc02003fa:	80a50513          	addi	a0,a0,-2038 # ffffffffc0201c00 <etext+0x264>
ffffffffc02003fe:	cb1ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    return 0;
ffffffffc0200402:	b715                	j	ffffffffc0200326 <kmonitor+0x6a>

ffffffffc0200404 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200404:	1141                	addi	sp,sp,-16
ffffffffc0200406:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200408:	02000793          	li	a5,32
ffffffffc020040c:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200410:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200414:	67e1                	lui	a5,0x18
ffffffffc0200416:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041a:	953e                	add	a0,a0,a5
ffffffffc020041c:	54a010ef          	jal	ra,ffffffffc0201966 <sbi_set_timer>
}
ffffffffc0200420:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200422:	00006797          	auipc	a5,0x6
ffffffffc0200426:	0007b723          	sd	zero,14(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042a:	00002517          	auipc	a0,0x2
ffffffffc020042e:	83650513          	addi	a0,a0,-1994 # ffffffffc0201c60 <commands+0x48>
}
ffffffffc0200432:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200434:	b9ad                	j	ffffffffc02000ae <cprintf>

ffffffffc0200436 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200436:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043a:	67e1                	lui	a5,0x18
ffffffffc020043c:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200440:	953e                	add	a0,a0,a5
ffffffffc0200442:	5240106f          	j	ffffffffc0201966 <sbi_set_timer>

ffffffffc0200446 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200446:	8082                	ret

ffffffffc0200448 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200448:	0ff57513          	zext.b	a0,a0
ffffffffc020044c:	5000106f          	j	ffffffffc020194c <sbi_console_putchar>

ffffffffc0200450 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200450:	5300106f          	j	ffffffffc0201980 <sbi_console_getchar>

ffffffffc0200454 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200454:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200458:	8082                	ret

ffffffffc020045a <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045a:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020045e:	8082                	ret

ffffffffc0200460 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200460:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200464:	00000797          	auipc	a5,0x0
ffffffffc0200468:	2e478793          	addi	a5,a5,740 # ffffffffc0200748 <__alltraps>
ffffffffc020046c:	10579073          	csrw	stvec,a5
}
ffffffffc0200470:	8082                	ret

ffffffffc0200472 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200472:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200474:	1141                	addi	sp,sp,-16
ffffffffc0200476:	e022                	sd	s0,0(sp)
ffffffffc0200478:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047a:	00002517          	auipc	a0,0x2
ffffffffc020047e:	80650513          	addi	a0,a0,-2042 # ffffffffc0201c80 <commands+0x68>
void print_regs(struct pushregs *gpr) {
ffffffffc0200482:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	c2bff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200488:	640c                	ld	a1,8(s0)
ffffffffc020048a:	00002517          	auipc	a0,0x2
ffffffffc020048e:	80e50513          	addi	a0,a0,-2034 # ffffffffc0201c98 <commands+0x80>
ffffffffc0200492:	c1dff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200496:	680c                	ld	a1,16(s0)
ffffffffc0200498:	00002517          	auipc	a0,0x2
ffffffffc020049c:	81850513          	addi	a0,a0,-2024 # ffffffffc0201cb0 <commands+0x98>
ffffffffc02004a0:	c0fff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a4:	6c0c                	ld	a1,24(s0)
ffffffffc02004a6:	00002517          	auipc	a0,0x2
ffffffffc02004aa:	82250513          	addi	a0,a0,-2014 # ffffffffc0201cc8 <commands+0xb0>
ffffffffc02004ae:	c01ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b2:	700c                	ld	a1,32(s0)
ffffffffc02004b4:	00002517          	auipc	a0,0x2
ffffffffc02004b8:	82c50513          	addi	a0,a0,-2004 # ffffffffc0201ce0 <commands+0xc8>
ffffffffc02004bc:	bf3ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c0:	740c                	ld	a1,40(s0)
ffffffffc02004c2:	00002517          	auipc	a0,0x2
ffffffffc02004c6:	83650513          	addi	a0,a0,-1994 # ffffffffc0201cf8 <commands+0xe0>
ffffffffc02004ca:	be5ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004ce:	780c                	ld	a1,48(s0)
ffffffffc02004d0:	00002517          	auipc	a0,0x2
ffffffffc02004d4:	84050513          	addi	a0,a0,-1984 # ffffffffc0201d10 <commands+0xf8>
ffffffffc02004d8:	bd7ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004dc:	7c0c                	ld	a1,56(s0)
ffffffffc02004de:	00002517          	auipc	a0,0x2
ffffffffc02004e2:	84a50513          	addi	a0,a0,-1974 # ffffffffc0201d28 <commands+0x110>
ffffffffc02004e6:	bc9ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ea:	602c                	ld	a1,64(s0)
ffffffffc02004ec:	00002517          	auipc	a0,0x2
ffffffffc02004f0:	85450513          	addi	a0,a0,-1964 # ffffffffc0201d40 <commands+0x128>
ffffffffc02004f4:	bbbff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004f8:	642c                	ld	a1,72(s0)
ffffffffc02004fa:	00002517          	auipc	a0,0x2
ffffffffc02004fe:	85e50513          	addi	a0,a0,-1954 # ffffffffc0201d58 <commands+0x140>
ffffffffc0200502:	badff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200506:	682c                	ld	a1,80(s0)
ffffffffc0200508:	00002517          	auipc	a0,0x2
ffffffffc020050c:	86850513          	addi	a0,a0,-1944 # ffffffffc0201d70 <commands+0x158>
ffffffffc0200510:	b9fff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200514:	6c2c                	ld	a1,88(s0)
ffffffffc0200516:	00002517          	auipc	a0,0x2
ffffffffc020051a:	87250513          	addi	a0,a0,-1934 # ffffffffc0201d88 <commands+0x170>
ffffffffc020051e:	b91ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200522:	702c                	ld	a1,96(s0)
ffffffffc0200524:	00002517          	auipc	a0,0x2
ffffffffc0200528:	87c50513          	addi	a0,a0,-1924 # ffffffffc0201da0 <commands+0x188>
ffffffffc020052c:	b83ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200530:	742c                	ld	a1,104(s0)
ffffffffc0200532:	00002517          	auipc	a0,0x2
ffffffffc0200536:	88650513          	addi	a0,a0,-1914 # ffffffffc0201db8 <commands+0x1a0>
ffffffffc020053a:	b75ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020053e:	782c                	ld	a1,112(s0)
ffffffffc0200540:	00002517          	auipc	a0,0x2
ffffffffc0200544:	89050513          	addi	a0,a0,-1904 # ffffffffc0201dd0 <commands+0x1b8>
ffffffffc0200548:	b67ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020054c:	7c2c                	ld	a1,120(s0)
ffffffffc020054e:	00002517          	auipc	a0,0x2
ffffffffc0200552:	89a50513          	addi	a0,a0,-1894 # ffffffffc0201de8 <commands+0x1d0>
ffffffffc0200556:	b59ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055a:	604c                	ld	a1,128(s0)
ffffffffc020055c:	00002517          	auipc	a0,0x2
ffffffffc0200560:	8a450513          	addi	a0,a0,-1884 # ffffffffc0201e00 <commands+0x1e8>
ffffffffc0200564:	b4bff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200568:	644c                	ld	a1,136(s0)
ffffffffc020056a:	00002517          	auipc	a0,0x2
ffffffffc020056e:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0201e18 <commands+0x200>
ffffffffc0200572:	b3dff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200576:	684c                	ld	a1,144(s0)
ffffffffc0200578:	00002517          	auipc	a0,0x2
ffffffffc020057c:	8b850513          	addi	a0,a0,-1864 # ffffffffc0201e30 <commands+0x218>
ffffffffc0200580:	b2fff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200584:	6c4c                	ld	a1,152(s0)
ffffffffc0200586:	00002517          	auipc	a0,0x2
ffffffffc020058a:	8c250513          	addi	a0,a0,-1854 # ffffffffc0201e48 <commands+0x230>
ffffffffc020058e:	b21ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200592:	704c                	ld	a1,160(s0)
ffffffffc0200594:	00002517          	auipc	a0,0x2
ffffffffc0200598:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0201e60 <commands+0x248>
ffffffffc020059c:	b13ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a0:	744c                	ld	a1,168(s0)
ffffffffc02005a2:	00002517          	auipc	a0,0x2
ffffffffc02005a6:	8d650513          	addi	a0,a0,-1834 # ffffffffc0201e78 <commands+0x260>
ffffffffc02005aa:	b05ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005ae:	784c                	ld	a1,176(s0)
ffffffffc02005b0:	00002517          	auipc	a0,0x2
ffffffffc02005b4:	8e050513          	addi	a0,a0,-1824 # ffffffffc0201e90 <commands+0x278>
ffffffffc02005b8:	af7ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005bc:	7c4c                	ld	a1,184(s0)
ffffffffc02005be:	00002517          	auipc	a0,0x2
ffffffffc02005c2:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0201ea8 <commands+0x290>
ffffffffc02005c6:	ae9ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ca:	606c                	ld	a1,192(s0)
ffffffffc02005cc:	00002517          	auipc	a0,0x2
ffffffffc02005d0:	8f450513          	addi	a0,a0,-1804 # ffffffffc0201ec0 <commands+0x2a8>
ffffffffc02005d4:	adbff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005d8:	646c                	ld	a1,200(s0)
ffffffffc02005da:	00002517          	auipc	a0,0x2
ffffffffc02005de:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0201ed8 <commands+0x2c0>
ffffffffc02005e2:	acdff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005e6:	686c                	ld	a1,208(s0)
ffffffffc02005e8:	00002517          	auipc	a0,0x2
ffffffffc02005ec:	90850513          	addi	a0,a0,-1784 # ffffffffc0201ef0 <commands+0x2d8>
ffffffffc02005f0:	abfff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f4:	6c6c                	ld	a1,216(s0)
ffffffffc02005f6:	00002517          	auipc	a0,0x2
ffffffffc02005fa:	91250513          	addi	a0,a0,-1774 # ffffffffc0201f08 <commands+0x2f0>
ffffffffc02005fe:	ab1ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200602:	706c                	ld	a1,224(s0)
ffffffffc0200604:	00002517          	auipc	a0,0x2
ffffffffc0200608:	91c50513          	addi	a0,a0,-1764 # ffffffffc0201f20 <commands+0x308>
ffffffffc020060c:	aa3ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200610:	746c                	ld	a1,232(s0)
ffffffffc0200612:	00002517          	auipc	a0,0x2
ffffffffc0200616:	92650513          	addi	a0,a0,-1754 # ffffffffc0201f38 <commands+0x320>
ffffffffc020061a:	a95ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020061e:	786c                	ld	a1,240(s0)
ffffffffc0200620:	00002517          	auipc	a0,0x2
ffffffffc0200624:	93050513          	addi	a0,a0,-1744 # ffffffffc0201f50 <commands+0x338>
ffffffffc0200628:	a87ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020062c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020062e:	6402                	ld	s0,0(sp)
ffffffffc0200630:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200632:	00002517          	auipc	a0,0x2
ffffffffc0200636:	93650513          	addi	a0,a0,-1738 # ffffffffc0201f68 <commands+0x350>
}
ffffffffc020063a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	bc8d                	j	ffffffffc02000ae <cprintf>

ffffffffc020063e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020063e:	1141                	addi	sp,sp,-16
ffffffffc0200640:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200642:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200644:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	00002517          	auipc	a0,0x2
ffffffffc020064a:	93a50513          	addi	a0,a0,-1734 # ffffffffc0201f80 <commands+0x368>
void print_trapframe(struct trapframe *tf) {
ffffffffc020064e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200650:	a5fff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200654:	8522                	mv	a0,s0
ffffffffc0200656:	e1dff0ef          	jal	ra,ffffffffc0200472 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065a:	10043583          	ld	a1,256(s0)
ffffffffc020065e:	00002517          	auipc	a0,0x2
ffffffffc0200662:	93a50513          	addi	a0,a0,-1734 # ffffffffc0201f98 <commands+0x380>
ffffffffc0200666:	a49ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066a:	10843583          	ld	a1,264(s0)
ffffffffc020066e:	00002517          	auipc	a0,0x2
ffffffffc0200672:	94250513          	addi	a0,a0,-1726 # ffffffffc0201fb0 <commands+0x398>
ffffffffc0200676:	a39ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067a:	11043583          	ld	a1,272(s0)
ffffffffc020067e:	00002517          	auipc	a0,0x2
ffffffffc0200682:	94a50513          	addi	a0,a0,-1718 # ffffffffc0201fc8 <commands+0x3b0>
ffffffffc0200686:	a29ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068a:	11843583          	ld	a1,280(s0)
}
ffffffffc020068e:	6402                	ld	s0,0(sp)
ffffffffc0200690:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200692:	00002517          	auipc	a0,0x2
ffffffffc0200696:	94e50513          	addi	a0,a0,-1714 # ffffffffc0201fe0 <commands+0x3c8>
}
ffffffffc020069a:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069c:	bc09                	j	ffffffffc02000ae <cprintf>

ffffffffc020069e <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020069e:	11853783          	ld	a5,280(a0)
ffffffffc02006a2:	472d                	li	a4,11
ffffffffc02006a4:	0786                	slli	a5,a5,0x1
ffffffffc02006a6:	8385                	srli	a5,a5,0x1
ffffffffc02006a8:	06f76c63          	bltu	a4,a5,ffffffffc0200720 <interrupt_handler+0x82>
ffffffffc02006ac:	00002717          	auipc	a4,0x2
ffffffffc02006b0:	a1470713          	addi	a4,a4,-1516 # ffffffffc02020c0 <commands+0x4a8>
ffffffffc02006b4:	078a                	slli	a5,a5,0x2
ffffffffc02006b6:	97ba                	add	a5,a5,a4
ffffffffc02006b8:	439c                	lw	a5,0(a5)
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006be:	00002517          	auipc	a0,0x2
ffffffffc02006c2:	99a50513          	addi	a0,a0,-1638 # ffffffffc0202058 <commands+0x440>
ffffffffc02006c6:	b2e5                	j	ffffffffc02000ae <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006c8:	00002517          	auipc	a0,0x2
ffffffffc02006cc:	97050513          	addi	a0,a0,-1680 # ffffffffc0202038 <commands+0x420>
ffffffffc02006d0:	baf9                	j	ffffffffc02000ae <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d2:	00002517          	auipc	a0,0x2
ffffffffc02006d6:	92650513          	addi	a0,a0,-1754 # ffffffffc0201ff8 <commands+0x3e0>
ffffffffc02006da:	bad1                	j	ffffffffc02000ae <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006dc:	00002517          	auipc	a0,0x2
ffffffffc02006e0:	99c50513          	addi	a0,a0,-1636 # ffffffffc0202078 <commands+0x460>
ffffffffc02006e4:	b2e9                	j	ffffffffc02000ae <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006e6:	1141                	addi	sp,sp,-16
ffffffffc02006e8:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ea:	d4dff0ef          	jal	ra,ffffffffc0200436 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006ee:	00006697          	auipc	a3,0x6
ffffffffc02006f2:	d4268693          	addi	a3,a3,-702 # ffffffffc0206430 <ticks>
ffffffffc02006f6:	629c                	ld	a5,0(a3)
ffffffffc02006f8:	06400713          	li	a4,100
ffffffffc02006fc:	0785                	addi	a5,a5,1
ffffffffc02006fe:	02e7f733          	remu	a4,a5,a4
ffffffffc0200702:	e29c                	sd	a5,0(a3)
ffffffffc0200704:	cf19                	beqz	a4,ffffffffc0200722 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200706:	60a2                	ld	ra,8(sp)
ffffffffc0200708:	0141                	addi	sp,sp,16
ffffffffc020070a:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020070c:	00002517          	auipc	a0,0x2
ffffffffc0200710:	99450513          	addi	a0,a0,-1644 # ffffffffc02020a0 <commands+0x488>
ffffffffc0200714:	ba69                	j	ffffffffc02000ae <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200716:	00002517          	auipc	a0,0x2
ffffffffc020071a:	90250513          	addi	a0,a0,-1790 # ffffffffc0202018 <commands+0x400>
ffffffffc020071e:	ba41                	j	ffffffffc02000ae <cprintf>
            print_trapframe(tf);
ffffffffc0200720:	bf39                	j	ffffffffc020063e <print_trapframe>
}
ffffffffc0200722:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200724:	06400593          	li	a1,100
ffffffffc0200728:	00002517          	auipc	a0,0x2
ffffffffc020072c:	96850513          	addi	a0,a0,-1688 # ffffffffc0202090 <commands+0x478>
}
ffffffffc0200730:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200732:	bab5                	j	ffffffffc02000ae <cprintf>

ffffffffc0200734 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200734:	11853783          	ld	a5,280(a0)
ffffffffc0200738:	0007c763          	bltz	a5,ffffffffc0200746 <trap+0x12>
    switch (tf->cause) {
ffffffffc020073c:	472d                	li	a4,11
ffffffffc020073e:	00f76363          	bltu	a4,a5,ffffffffc0200744 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200742:	8082                	ret
            print_trapframe(tf);
ffffffffc0200744:	bded                	j	ffffffffc020063e <print_trapframe>
        interrupt_handler(tf);
ffffffffc0200746:	bfa1                	j	ffffffffc020069e <interrupt_handler>

ffffffffc0200748 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200748:	14011073          	csrw	sscratch,sp
ffffffffc020074c:	712d                	addi	sp,sp,-288
ffffffffc020074e:	e002                	sd	zero,0(sp)
ffffffffc0200750:	e406                	sd	ra,8(sp)
ffffffffc0200752:	ec0e                	sd	gp,24(sp)
ffffffffc0200754:	f012                	sd	tp,32(sp)
ffffffffc0200756:	f416                	sd	t0,40(sp)
ffffffffc0200758:	f81a                	sd	t1,48(sp)
ffffffffc020075a:	fc1e                	sd	t2,56(sp)
ffffffffc020075c:	e0a2                	sd	s0,64(sp)
ffffffffc020075e:	e4a6                	sd	s1,72(sp)
ffffffffc0200760:	e8aa                	sd	a0,80(sp)
ffffffffc0200762:	ecae                	sd	a1,88(sp)
ffffffffc0200764:	f0b2                	sd	a2,96(sp)
ffffffffc0200766:	f4b6                	sd	a3,104(sp)
ffffffffc0200768:	f8ba                	sd	a4,112(sp)
ffffffffc020076a:	fcbe                	sd	a5,120(sp)
ffffffffc020076c:	e142                	sd	a6,128(sp)
ffffffffc020076e:	e546                	sd	a7,136(sp)
ffffffffc0200770:	e94a                	sd	s2,144(sp)
ffffffffc0200772:	ed4e                	sd	s3,152(sp)
ffffffffc0200774:	f152                	sd	s4,160(sp)
ffffffffc0200776:	f556                	sd	s5,168(sp)
ffffffffc0200778:	f95a                	sd	s6,176(sp)
ffffffffc020077a:	fd5e                	sd	s7,184(sp)
ffffffffc020077c:	e1e2                	sd	s8,192(sp)
ffffffffc020077e:	e5e6                	sd	s9,200(sp)
ffffffffc0200780:	e9ea                	sd	s10,208(sp)
ffffffffc0200782:	edee                	sd	s11,216(sp)
ffffffffc0200784:	f1f2                	sd	t3,224(sp)
ffffffffc0200786:	f5f6                	sd	t4,232(sp)
ffffffffc0200788:	f9fa                	sd	t5,240(sp)
ffffffffc020078a:	fdfe                	sd	t6,248(sp)
ffffffffc020078c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200790:	100024f3          	csrr	s1,sstatus
ffffffffc0200794:	14102973          	csrr	s2,sepc
ffffffffc0200798:	143029f3          	csrr	s3,stval
ffffffffc020079c:	14202a73          	csrr	s4,scause
ffffffffc02007a0:	e822                	sd	s0,16(sp)
ffffffffc02007a2:	e226                	sd	s1,256(sp)
ffffffffc02007a4:	e64a                	sd	s2,264(sp)
ffffffffc02007a6:	ea4e                	sd	s3,272(sp)
ffffffffc02007a8:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007aa:	850a                	mv	a0,sp
    jal trap
ffffffffc02007ac:	f89ff0ef          	jal	ra,ffffffffc0200734 <trap>

ffffffffc02007b0 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b0:	6492                	ld	s1,256(sp)
ffffffffc02007b2:	6932                	ld	s2,264(sp)
ffffffffc02007b4:	10049073          	csrw	sstatus,s1
ffffffffc02007b8:	14191073          	csrw	sepc,s2
ffffffffc02007bc:	60a2                	ld	ra,8(sp)
ffffffffc02007be:	61e2                	ld	gp,24(sp)
ffffffffc02007c0:	7202                	ld	tp,32(sp)
ffffffffc02007c2:	72a2                	ld	t0,40(sp)
ffffffffc02007c4:	7342                	ld	t1,48(sp)
ffffffffc02007c6:	73e2                	ld	t2,56(sp)
ffffffffc02007c8:	6406                	ld	s0,64(sp)
ffffffffc02007ca:	64a6                	ld	s1,72(sp)
ffffffffc02007cc:	6546                	ld	a0,80(sp)
ffffffffc02007ce:	65e6                	ld	a1,88(sp)
ffffffffc02007d0:	7606                	ld	a2,96(sp)
ffffffffc02007d2:	76a6                	ld	a3,104(sp)
ffffffffc02007d4:	7746                	ld	a4,112(sp)
ffffffffc02007d6:	77e6                	ld	a5,120(sp)
ffffffffc02007d8:	680a                	ld	a6,128(sp)
ffffffffc02007da:	68aa                	ld	a7,136(sp)
ffffffffc02007dc:	694a                	ld	s2,144(sp)
ffffffffc02007de:	69ea                	ld	s3,152(sp)
ffffffffc02007e0:	7a0a                	ld	s4,160(sp)
ffffffffc02007e2:	7aaa                	ld	s5,168(sp)
ffffffffc02007e4:	7b4a                	ld	s6,176(sp)
ffffffffc02007e6:	7bea                	ld	s7,184(sp)
ffffffffc02007e8:	6c0e                	ld	s8,192(sp)
ffffffffc02007ea:	6cae                	ld	s9,200(sp)
ffffffffc02007ec:	6d4e                	ld	s10,208(sp)
ffffffffc02007ee:	6dee                	ld	s11,216(sp)
ffffffffc02007f0:	7e0e                	ld	t3,224(sp)
ffffffffc02007f2:	7eae                	ld	t4,232(sp)
ffffffffc02007f4:	7f4e                	ld	t5,240(sp)
ffffffffc02007f6:	7fee                	ld	t6,248(sp)
ffffffffc02007f8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fa:	10200073          	sret

ffffffffc02007fe <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02007fe:	100027f3          	csrr	a5,sstatus
ffffffffc0200802:	8b89                	andi	a5,a5,2
ffffffffc0200804:	e799                	bnez	a5,ffffffffc0200812 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200806:	00006797          	auipc	a5,0x6
ffffffffc020080a:	c427b783          	ld	a5,-958(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020080e:	6f9c                	ld	a5,24(a5)
ffffffffc0200810:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200812:	1141                	addi	sp,sp,-16
ffffffffc0200814:	e406                	sd	ra,8(sp)
ffffffffc0200816:	e022                	sd	s0,0(sp)
ffffffffc0200818:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020081a:	c41ff0ef          	jal	ra,ffffffffc020045a <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020081e:	00006797          	auipc	a5,0x6
ffffffffc0200822:	c2a7b783          	ld	a5,-982(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0200826:	6f9c                	ld	a5,24(a5)
ffffffffc0200828:	8522                	mv	a0,s0
ffffffffc020082a:	9782                	jalr	a5
ffffffffc020082c:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020082e:	c27ff0ef          	jal	ra,ffffffffc0200454 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200832:	60a2                	ld	ra,8(sp)
ffffffffc0200834:	8522                	mv	a0,s0
ffffffffc0200836:	6402                	ld	s0,0(sp)
ffffffffc0200838:	0141                	addi	sp,sp,16
ffffffffc020083a:	8082                	ret

ffffffffc020083c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020083c:	100027f3          	csrr	a5,sstatus
ffffffffc0200840:	8b89                	andi	a5,a5,2
ffffffffc0200842:	e799                	bnez	a5,ffffffffc0200850 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200844:	00006797          	auipc	a5,0x6
ffffffffc0200848:	c047b783          	ld	a5,-1020(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020084c:	739c                	ld	a5,32(a5)
ffffffffc020084e:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200850:	1101                	addi	sp,sp,-32
ffffffffc0200852:	ec06                	sd	ra,24(sp)
ffffffffc0200854:	e822                	sd	s0,16(sp)
ffffffffc0200856:	e426                	sd	s1,8(sp)
ffffffffc0200858:	842a                	mv	s0,a0
ffffffffc020085a:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020085c:	bffff0ef          	jal	ra,ffffffffc020045a <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200860:	00006797          	auipc	a5,0x6
ffffffffc0200864:	be87b783          	ld	a5,-1048(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0200868:	739c                	ld	a5,32(a5)
ffffffffc020086a:	85a6                	mv	a1,s1
ffffffffc020086c:	8522                	mv	a0,s0
ffffffffc020086e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200870:	6442                	ld	s0,16(sp)
ffffffffc0200872:	60e2                	ld	ra,24(sp)
ffffffffc0200874:	64a2                	ld	s1,8(sp)
ffffffffc0200876:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200878:	bef1                	j	ffffffffc0200454 <intr_enable>

ffffffffc020087a <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020087a:	100027f3          	csrr	a5,sstatus
ffffffffc020087e:	8b89                	andi	a5,a5,2
ffffffffc0200880:	e799                	bnez	a5,ffffffffc020088e <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200882:	00006797          	auipc	a5,0x6
ffffffffc0200886:	bc67b783          	ld	a5,-1082(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020088a:	779c                	ld	a5,40(a5)
ffffffffc020088c:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020088e:	1141                	addi	sp,sp,-16
ffffffffc0200890:	e406                	sd	ra,8(sp)
ffffffffc0200892:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200894:	bc7ff0ef          	jal	ra,ffffffffc020045a <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200898:	00006797          	auipc	a5,0x6
ffffffffc020089c:	bb07b783          	ld	a5,-1104(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02008a0:	779c                	ld	a5,40(a5)
ffffffffc02008a2:	9782                	jalr	a5
ffffffffc02008a4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02008a6:	bafff0ef          	jal	ra,ffffffffc0200454 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02008aa:	60a2                	ld	ra,8(sp)
ffffffffc02008ac:	8522                	mv	a0,s0
ffffffffc02008ae:	6402                	ld	s0,0(sp)
ffffffffc02008b0:	0141                	addi	sp,sp,16
ffffffffc02008b2:	8082                	ret

ffffffffc02008b4 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02008b4:	00002797          	auipc	a5,0x2
ffffffffc02008b8:	cac78793          	addi	a5,a5,-852 # ffffffffc0202560 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008bc:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02008be:	1101                	addi	sp,sp,-32
ffffffffc02008c0:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008c2:	00002517          	auipc	a0,0x2
ffffffffc02008c6:	82e50513          	addi	a0,a0,-2002 # ffffffffc02020f0 <commands+0x4d8>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02008ca:	00006497          	auipc	s1,0x6
ffffffffc02008ce:	b7e48493          	addi	s1,s1,-1154 # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc02008d2:	ec06                	sd	ra,24(sp)
ffffffffc02008d4:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02008d6:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008d8:	fd6ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    pmm_manager->init();
ffffffffc02008dc:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;//硬编码 0xFFFFFFFF40000000(虚拟地址与物理地址间的偏移量)
ffffffffc02008de:	00006417          	auipc	s0,0x6
ffffffffc02008e2:	b8240413          	addi	s0,s0,-1150 # ffffffffc0206460 <va_pa_offset>
    pmm_manager->init();
ffffffffc02008e6:	679c                	ld	a5,8(a5)
ffffffffc02008e8:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;//硬编码 0xFFFFFFFF40000000(虚拟地址与物理地址间的偏移量)
ffffffffc02008ea:	57f5                	li	a5,-3
ffffffffc02008ec:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02008ee:	00002517          	auipc	a0,0x2
ffffffffc02008f2:	81a50513          	addi	a0,a0,-2022 # ffffffffc0202108 <commands+0x4f0>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;//硬编码 0xFFFFFFFF40000000(虚拟地址与物理地址间的偏移量)
ffffffffc02008f6:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02008f8:	fb6ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02008fc:	46c5                	li	a3,17
ffffffffc02008fe:	06ee                	slli	a3,a3,0x1b
ffffffffc0200900:	40100613          	li	a2,1025
ffffffffc0200904:	16fd                	addi	a3,a3,-1
ffffffffc0200906:	07e005b7          	lui	a1,0x7e00
ffffffffc020090a:	0656                	slli	a2,a2,0x15
ffffffffc020090c:	00002517          	auipc	a0,0x2
ffffffffc0200910:	81450513          	addi	a0,a0,-2028 # ffffffffc0202120 <commands+0x508>
ffffffffc0200914:	f9aff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200918:	777d                	lui	a4,0xfffff
ffffffffc020091a:	00007797          	auipc	a5,0x7
ffffffffc020091e:	b5578793          	addi	a5,a5,-1195 # ffffffffc020746f <end+0xfff>
ffffffffc0200922:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200924:	00006517          	auipc	a0,0x6
ffffffffc0200928:	b1450513          	addi	a0,a0,-1260 # ffffffffc0206438 <npage>
ffffffffc020092c:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200930:	00006597          	auipc	a1,0x6
ffffffffc0200934:	b1058593          	addi	a1,a1,-1264 # ffffffffc0206440 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200938:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020093a:	e19c                	sd	a5,0(a1)
ffffffffc020093c:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020093e:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200940:	4885                	li	a7,1
ffffffffc0200942:	fff80837          	lui	a6,0xfff80
ffffffffc0200946:	a011                	j	ffffffffc020094a <pmm_init+0x96>
        SetPageReserved(pages + i); // 在kern/mm/memlayout.h定义的
ffffffffc0200948:	619c                	ld	a5,0(a1)
ffffffffc020094a:	97b6                	add	a5,a5,a3
ffffffffc020094c:	07a1                	addi	a5,a5,8
ffffffffc020094e:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200952:	611c                	ld	a5,0(a0)
ffffffffc0200954:	0705                	addi	a4,a4,1
ffffffffc0200956:	02868693          	addi	a3,a3,40
ffffffffc020095a:	01078633          	add	a2,a5,a6
ffffffffc020095e:	fec765e3          	bltu	a4,a2,ffffffffc0200948 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200962:	6190                	ld	a2,0(a1)
ffffffffc0200964:	00279713          	slli	a4,a5,0x2
ffffffffc0200968:	973e                	add	a4,a4,a5
ffffffffc020096a:	fec006b7          	lui	a3,0xfec00
ffffffffc020096e:	070e                	slli	a4,a4,0x3
ffffffffc0200970:	96b2                	add	a3,a3,a2
ffffffffc0200972:	96ba                	add	a3,a3,a4
ffffffffc0200974:	c0200737          	lui	a4,0xc0200
ffffffffc0200978:	08e6ef63          	bltu	a3,a4,ffffffffc0200a16 <pmm_init+0x162>
ffffffffc020097c:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc020097e:	45c5                	li	a1,17
ffffffffc0200980:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200982:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200984:	04b6e863          	bltu	a3,a1,ffffffffc02009d4 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200988:	609c                	ld	a5,0(s1)
ffffffffc020098a:	7b9c                	ld	a5,48(a5)
ffffffffc020098c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020098e:	00002517          	auipc	a0,0x2
ffffffffc0200992:	82a50513          	addi	a0,a0,-2006 # ffffffffc02021b8 <commands+0x5a0>
ffffffffc0200996:	f18ff0ef          	jal	ra,ffffffffc02000ae <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020099a:	00004597          	auipc	a1,0x4
ffffffffc020099e:	66658593          	addi	a1,a1,1638 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02009a2:	00006797          	auipc	a5,0x6
ffffffffc02009a6:	aab7bb23          	sd	a1,-1354(a5) # ffffffffc0206458 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02009aa:	c02007b7          	lui	a5,0xc0200
ffffffffc02009ae:	08f5e063          	bltu	a1,a5,ffffffffc0200a2e <pmm_init+0x17a>
ffffffffc02009b2:	6010                	ld	a2,0(s0)
}
ffffffffc02009b4:	6442                	ld	s0,16(sp)
ffffffffc02009b6:	60e2                	ld	ra,24(sp)
ffffffffc02009b8:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02009ba:	40c58633          	sub	a2,a1,a2
ffffffffc02009be:	00006797          	auipc	a5,0x6
ffffffffc02009c2:	a8c7b923          	sd	a2,-1390(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009c6:	00002517          	auipc	a0,0x2
ffffffffc02009ca:	81250513          	addi	a0,a0,-2030 # ffffffffc02021d8 <commands+0x5c0>
}
ffffffffc02009ce:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009d0:	edeff06f          	j	ffffffffc02000ae <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02009d4:	6705                	lui	a4,0x1
ffffffffc02009d6:	177d                	addi	a4,a4,-1
ffffffffc02009d8:	96ba                	add	a3,a3,a4
ffffffffc02009da:	777d                	lui	a4,0xfffff
ffffffffc02009dc:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02009de:	00c6d513          	srli	a0,a3,0xc
ffffffffc02009e2:	00f57e63          	bgeu	a0,a5,ffffffffc02009fe <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02009e6:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02009e8:	982a                	add	a6,a6,a0
ffffffffc02009ea:	00281513          	slli	a0,a6,0x2
ffffffffc02009ee:	9542                	add	a0,a0,a6
ffffffffc02009f0:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02009f2:	8d95                	sub	a1,a1,a3
ffffffffc02009f4:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02009f6:	81b1                	srli	a1,a1,0xc
ffffffffc02009f8:	9532                	add	a0,a0,a2
ffffffffc02009fa:	9782                	jalr	a5
}
ffffffffc02009fc:	b771                	j	ffffffffc0200988 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02009fe:	00001617          	auipc	a2,0x1
ffffffffc0200a02:	78a60613          	addi	a2,a2,1930 # ffffffffc0202188 <commands+0x570>
ffffffffc0200a06:	06f00593          	li	a1,111
ffffffffc0200a0a:	00001517          	auipc	a0,0x1
ffffffffc0200a0e:	79e50513          	addi	a0,a0,1950 # ffffffffc02021a8 <commands+0x590>
ffffffffc0200a12:	f24ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a16:	00001617          	auipc	a2,0x1
ffffffffc0200a1a:	73a60613          	addi	a2,a2,1850 # ffffffffc0202150 <commands+0x538>
ffffffffc0200a1e:	07400593          	li	a1,116
ffffffffc0200a22:	00001517          	auipc	a0,0x1
ffffffffc0200a26:	75650513          	addi	a0,a0,1878 # ffffffffc0202178 <commands+0x560>
ffffffffc0200a2a:	f0cff0ef          	jal	ra,ffffffffc0200136 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a2e:	86ae                	mv	a3,a1
ffffffffc0200a30:	00001617          	auipc	a2,0x1
ffffffffc0200a34:	72060613          	addi	a2,a2,1824 # ffffffffc0202150 <commands+0x538>
ffffffffc0200a38:	09000593          	li	a1,144
ffffffffc0200a3c:	00001517          	auipc	a0,0x1
ffffffffc0200a40:	73c50513          	addi	a0,a0,1852 # ffffffffc0202178 <commands+0x560>
ffffffffc0200a44:	ef2ff0ef          	jal	ra,ffffffffc0200136 <__panic>

ffffffffc0200a48 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200a48:	00005797          	auipc	a5,0x5
ffffffffc0200a4c:	5c878793          	addi	a5,a5,1480 # ffffffffc0206010 <free_area>
ffffffffc0200a50:	e79c                	sd	a5,8(a5)
ffffffffc0200a52:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200a54:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200a58:	8082                	ret

ffffffffc0200a5a <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200a5a:	00005517          	auipc	a0,0x5
ffffffffc0200a5e:	5c656503          	lwu	a0,1478(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc0200a62:	8082                	ret

ffffffffc0200a64 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200a64:	715d                	addi	sp,sp,-80
ffffffffc0200a66:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200a68:	00005417          	auipc	s0,0x5
ffffffffc0200a6c:	5a840413          	addi	s0,s0,1448 # ffffffffc0206010 <free_area>
ffffffffc0200a70:	641c                	ld	a5,8(s0)
ffffffffc0200a72:	e486                	sd	ra,72(sp)
ffffffffc0200a74:	fc26                	sd	s1,56(sp)
ffffffffc0200a76:	f84a                	sd	s2,48(sp)
ffffffffc0200a78:	f44e                	sd	s3,40(sp)
ffffffffc0200a7a:	f052                	sd	s4,32(sp)
ffffffffc0200a7c:	ec56                	sd	s5,24(sp)
ffffffffc0200a7e:	e85a                	sd	s6,16(sp)
ffffffffc0200a80:	e45e                	sd	s7,8(sp)
ffffffffc0200a82:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a84:	26878b63          	beq	a5,s0,ffffffffc0200cfa <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc0200a88:	4481                	li	s1,0
ffffffffc0200a8a:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a8c:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200a90:	8b09                	andi	a4,a4,2
ffffffffc0200a92:	26070863          	beqz	a4,ffffffffc0200d02 <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc0200a96:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200a9a:	679c                	ld	a5,8(a5)
ffffffffc0200a9c:	2905                	addiw	s2,s2,1
ffffffffc0200a9e:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200aa0:	fe8796e3          	bne	a5,s0,ffffffffc0200a8c <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200aa4:	89a6                	mv	s3,s1
ffffffffc0200aa6:	dd5ff0ef          	jal	ra,ffffffffc020087a <nr_free_pages>
ffffffffc0200aaa:	33351c63          	bne	a0,s3,ffffffffc0200de2 <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200aae:	4505                	li	a0,1
ffffffffc0200ab0:	d4fff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200ab4:	8a2a                	mv	s4,a0
ffffffffc0200ab6:	36050663          	beqz	a0,ffffffffc0200e22 <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200aba:	4505                	li	a0,1
ffffffffc0200abc:	d43ff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200ac0:	89aa                	mv	s3,a0
ffffffffc0200ac2:	34050063          	beqz	a0,ffffffffc0200e02 <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ac6:	4505                	li	a0,1
ffffffffc0200ac8:	d37ff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200acc:	8aaa                	mv	s5,a0
ffffffffc0200ace:	2c050a63          	beqz	a0,ffffffffc0200da2 <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ad2:	253a0863          	beq	s4,s3,ffffffffc0200d22 <best_fit_check+0x2be>
ffffffffc0200ad6:	24aa0663          	beq	s4,a0,ffffffffc0200d22 <best_fit_check+0x2be>
ffffffffc0200ada:	24a98463          	beq	s3,a0,ffffffffc0200d22 <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ade:	000a2783          	lw	a5,0(s4)
ffffffffc0200ae2:	26079063          	bnez	a5,ffffffffc0200d42 <best_fit_check+0x2de>
ffffffffc0200ae6:	0009a783          	lw	a5,0(s3)
ffffffffc0200aea:	24079c63          	bnez	a5,ffffffffc0200d42 <best_fit_check+0x2de>
ffffffffc0200aee:	411c                	lw	a5,0(a0)
ffffffffc0200af0:	24079963          	bnez	a5,ffffffffc0200d42 <best_fit_check+0x2de>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200af4:	00006797          	auipc	a5,0x6
ffffffffc0200af8:	94c7b783          	ld	a5,-1716(a5) # ffffffffc0206440 <pages>
ffffffffc0200afc:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b00:	870d                	srai	a4,a4,0x3
ffffffffc0200b02:	00002597          	auipc	a1,0x2
ffffffffc0200b06:	ce65b583          	ld	a1,-794(a1) # ffffffffc02027e8 <nbase+0x8>
ffffffffc0200b0a:	02b70733          	mul	a4,a4,a1
ffffffffc0200b0e:	00002617          	auipc	a2,0x2
ffffffffc0200b12:	cd263603          	ld	a2,-814(a2) # ffffffffc02027e0 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b16:	00006697          	auipc	a3,0x6
ffffffffc0200b1a:	9226b683          	ld	a3,-1758(a3) # ffffffffc0206438 <npage>
ffffffffc0200b1e:	06b2                	slli	a3,a3,0xc
ffffffffc0200b20:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b22:	0732                	slli	a4,a4,0xc
ffffffffc0200b24:	22d77f63          	bgeu	a4,a3,ffffffffc0200d62 <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b28:	40f98733          	sub	a4,s3,a5
ffffffffc0200b2c:	870d                	srai	a4,a4,0x3
ffffffffc0200b2e:	02b70733          	mul	a4,a4,a1
ffffffffc0200b32:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b34:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200b36:	3ed77663          	bgeu	a4,a3,ffffffffc0200f22 <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b3a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200b3e:	878d                	srai	a5,a5,0x3
ffffffffc0200b40:	02b787b3          	mul	a5,a5,a1
ffffffffc0200b44:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b46:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200b48:	3ad7fd63          	bgeu	a5,a3,ffffffffc0200f02 <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc0200b4c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200b4e:	00043c03          	ld	s8,0(s0)
ffffffffc0200b52:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200b56:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200b5a:	e400                	sd	s0,8(s0)
ffffffffc0200b5c:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200b5e:	00005797          	auipc	a5,0x5
ffffffffc0200b62:	4c07a123          	sw	zero,1218(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200b66:	c99ff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200b6a:	36051c63          	bnez	a0,ffffffffc0200ee2 <best_fit_check+0x47e>
    free_page(p0);
ffffffffc0200b6e:	4585                	li	a1,1
ffffffffc0200b70:	8552                	mv	a0,s4
ffffffffc0200b72:	ccbff0ef          	jal	ra,ffffffffc020083c <free_pages>
    free_page(p1);
ffffffffc0200b76:	4585                	li	a1,1
ffffffffc0200b78:	854e                	mv	a0,s3
ffffffffc0200b7a:	cc3ff0ef          	jal	ra,ffffffffc020083c <free_pages>
    free_page(p2);
ffffffffc0200b7e:	4585                	li	a1,1
ffffffffc0200b80:	8556                	mv	a0,s5
ffffffffc0200b82:	cbbff0ef          	jal	ra,ffffffffc020083c <free_pages>
    assert(nr_free == 3);
ffffffffc0200b86:	4818                	lw	a4,16(s0)
ffffffffc0200b88:	478d                	li	a5,3
ffffffffc0200b8a:	32f71c63          	bne	a4,a5,ffffffffc0200ec2 <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b8e:	4505                	li	a0,1
ffffffffc0200b90:	c6fff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200b94:	89aa                	mv	s3,a0
ffffffffc0200b96:	30050663          	beqz	a0,ffffffffc0200ea2 <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b9a:	4505                	li	a0,1
ffffffffc0200b9c:	c63ff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200ba0:	8aaa                	mv	s5,a0
ffffffffc0200ba2:	2e050063          	beqz	a0,ffffffffc0200e82 <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ba6:	4505                	li	a0,1
ffffffffc0200ba8:	c57ff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200bac:	8a2a                	mv	s4,a0
ffffffffc0200bae:	2a050a63          	beqz	a0,ffffffffc0200e62 <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc0200bb2:	4505                	li	a0,1
ffffffffc0200bb4:	c4bff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200bb8:	28051563          	bnez	a0,ffffffffc0200e42 <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200bbc:	4585                	li	a1,1
ffffffffc0200bbe:	854e                	mv	a0,s3
ffffffffc0200bc0:	c7dff0ef          	jal	ra,ffffffffc020083c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200bc4:	641c                	ld	a5,8(s0)
ffffffffc0200bc6:	1a878e63          	beq	a5,s0,ffffffffc0200d82 <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200bca:	4505                	li	a0,1
ffffffffc0200bcc:	c33ff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200bd0:	52a99963          	bne	s3,a0,ffffffffc0201102 <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc0200bd4:	4505                	li	a0,1
ffffffffc0200bd6:	c29ff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200bda:	50051463          	bnez	a0,ffffffffc02010e2 <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200bde:	481c                	lw	a5,16(s0)
ffffffffc0200be0:	4e079163          	bnez	a5,ffffffffc02010c2 <best_fit_check+0x65e>
    free_page(p);
ffffffffc0200be4:	854e                	mv	a0,s3
ffffffffc0200be6:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200be8:	01843023          	sd	s8,0(s0)
ffffffffc0200bec:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200bf0:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200bf4:	c49ff0ef          	jal	ra,ffffffffc020083c <free_pages>
    free_page(p1);
ffffffffc0200bf8:	4585                	li	a1,1
ffffffffc0200bfa:	8556                	mv	a0,s5
ffffffffc0200bfc:	c41ff0ef          	jal	ra,ffffffffc020083c <free_pages>
    free_page(p2);
ffffffffc0200c00:	4585                	li	a1,1
ffffffffc0200c02:	8552                	mv	a0,s4
ffffffffc0200c04:	c39ff0ef          	jal	ra,ffffffffc020083c <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200c08:	4515                	li	a0,5
ffffffffc0200c0a:	bf5ff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200c0e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200c10:	48050963          	beqz	a0,ffffffffc02010a2 <best_fit_check+0x63e>
ffffffffc0200c14:	651c                	ld	a5,8(a0)
ffffffffc0200c16:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200c18:	8b85                	andi	a5,a5,1
ffffffffc0200c1a:	46079463          	bnez	a5,ffffffffc0201082 <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200c1e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c20:	00043a83          	ld	s5,0(s0)
ffffffffc0200c24:	00843a03          	ld	s4,8(s0)
ffffffffc0200c28:	e000                	sd	s0,0(s0)
ffffffffc0200c2a:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200c2c:	bd3ff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200c30:	42051963          	bnez	a0,ffffffffc0201062 <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200c34:	4589                	li	a1,2
ffffffffc0200c36:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200c3a:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200c3e:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200c42:	00005797          	auipc	a5,0x5
ffffffffc0200c46:	3c07af23          	sw	zero,990(a5) # ffffffffc0206020 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200c4a:	bf3ff0ef          	jal	ra,ffffffffc020083c <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200c4e:	8562                	mv	a0,s8
ffffffffc0200c50:	4585                	li	a1,1
ffffffffc0200c52:	bebff0ef          	jal	ra,ffffffffc020083c <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200c56:	4511                	li	a0,4
ffffffffc0200c58:	ba7ff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200c5c:	3e051363          	bnez	a0,ffffffffc0201042 <best_fit_check+0x5de>
ffffffffc0200c60:	0309b783          	ld	a5,48(s3)
ffffffffc0200c64:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200c66:	8b85                	andi	a5,a5,1
ffffffffc0200c68:	3a078d63          	beqz	a5,ffffffffc0201022 <best_fit_check+0x5be>
ffffffffc0200c6c:	0389a703          	lw	a4,56(s3)
ffffffffc0200c70:	4789                	li	a5,2
ffffffffc0200c72:	3af71863          	bne	a4,a5,ffffffffc0201022 <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200c76:	4505                	li	a0,1
ffffffffc0200c78:	b87ff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200c7c:	8baa                	mv	s7,a0
ffffffffc0200c7e:	38050263          	beqz	a0,ffffffffc0201002 <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200c82:	4509                	li	a0,2
ffffffffc0200c84:	b7bff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200c88:	34050d63          	beqz	a0,ffffffffc0200fe2 <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0200c8c:	337c1b63          	bne	s8,s7,ffffffffc0200fc2 <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200c90:	854e                	mv	a0,s3
ffffffffc0200c92:	4595                	li	a1,5
ffffffffc0200c94:	ba9ff0ef          	jal	ra,ffffffffc020083c <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200c98:	4515                	li	a0,5
ffffffffc0200c9a:	b65ff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200c9e:	89aa                	mv	s3,a0
ffffffffc0200ca0:	30050163          	beqz	a0,ffffffffc0200fa2 <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0200ca4:	4505                	li	a0,1
ffffffffc0200ca6:	b59ff0ef          	jal	ra,ffffffffc02007fe <alloc_pages>
ffffffffc0200caa:	2c051c63          	bnez	a0,ffffffffc0200f82 <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200cae:	481c                	lw	a5,16(s0)
ffffffffc0200cb0:	2a079963          	bnez	a5,ffffffffc0200f62 <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200cb4:	4595                	li	a1,5
ffffffffc0200cb6:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200cb8:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200cbc:	01543023          	sd	s5,0(s0)
ffffffffc0200cc0:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200cc4:	b79ff0ef          	jal	ra,ffffffffc020083c <free_pages>
    return listelm->next;
ffffffffc0200cc8:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200cca:	00878963          	beq	a5,s0,ffffffffc0200cdc <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200cce:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200cd2:	679c                	ld	a5,8(a5)
ffffffffc0200cd4:	397d                	addiw	s2,s2,-1
ffffffffc0200cd6:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200cd8:	fe879be3          	bne	a5,s0,ffffffffc0200cce <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0200cdc:	26091363          	bnez	s2,ffffffffc0200f42 <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0200ce0:	e0ed                	bnez	s1,ffffffffc0200dc2 <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200ce2:	60a6                	ld	ra,72(sp)
ffffffffc0200ce4:	6406                	ld	s0,64(sp)
ffffffffc0200ce6:	74e2                	ld	s1,56(sp)
ffffffffc0200ce8:	7942                	ld	s2,48(sp)
ffffffffc0200cea:	79a2                	ld	s3,40(sp)
ffffffffc0200cec:	7a02                	ld	s4,32(sp)
ffffffffc0200cee:	6ae2                	ld	s5,24(sp)
ffffffffc0200cf0:	6b42                	ld	s6,16(sp)
ffffffffc0200cf2:	6ba2                	ld	s7,8(sp)
ffffffffc0200cf4:	6c02                	ld	s8,0(sp)
ffffffffc0200cf6:	6161                	addi	sp,sp,80
ffffffffc0200cf8:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200cfa:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200cfc:	4481                	li	s1,0
ffffffffc0200cfe:	4901                	li	s2,0
ffffffffc0200d00:	b35d                	j	ffffffffc0200aa6 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200d02:	00001697          	auipc	a3,0x1
ffffffffc0200d06:	51668693          	addi	a3,a3,1302 # ffffffffc0202218 <commands+0x600>
ffffffffc0200d0a:	00001617          	auipc	a2,0x1
ffffffffc0200d0e:	51e60613          	addi	a2,a2,1310 # ffffffffc0202228 <commands+0x610>
ffffffffc0200d12:	10a00593          	li	a1,266
ffffffffc0200d16:	00001517          	auipc	a0,0x1
ffffffffc0200d1a:	52a50513          	addi	a0,a0,1322 # ffffffffc0202240 <commands+0x628>
ffffffffc0200d1e:	c18ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200d22:	00001697          	auipc	a3,0x1
ffffffffc0200d26:	5b668693          	addi	a3,a3,1462 # ffffffffc02022d8 <commands+0x6c0>
ffffffffc0200d2a:	00001617          	auipc	a2,0x1
ffffffffc0200d2e:	4fe60613          	addi	a2,a2,1278 # ffffffffc0202228 <commands+0x610>
ffffffffc0200d32:	0d600593          	li	a1,214
ffffffffc0200d36:	00001517          	auipc	a0,0x1
ffffffffc0200d3a:	50a50513          	addi	a0,a0,1290 # ffffffffc0202240 <commands+0x628>
ffffffffc0200d3e:	bf8ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200d42:	00001697          	auipc	a3,0x1
ffffffffc0200d46:	5be68693          	addi	a3,a3,1470 # ffffffffc0202300 <commands+0x6e8>
ffffffffc0200d4a:	00001617          	auipc	a2,0x1
ffffffffc0200d4e:	4de60613          	addi	a2,a2,1246 # ffffffffc0202228 <commands+0x610>
ffffffffc0200d52:	0d700593          	li	a1,215
ffffffffc0200d56:	00001517          	auipc	a0,0x1
ffffffffc0200d5a:	4ea50513          	addi	a0,a0,1258 # ffffffffc0202240 <commands+0x628>
ffffffffc0200d5e:	bd8ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200d62:	00001697          	auipc	a3,0x1
ffffffffc0200d66:	5de68693          	addi	a3,a3,1502 # ffffffffc0202340 <commands+0x728>
ffffffffc0200d6a:	00001617          	auipc	a2,0x1
ffffffffc0200d6e:	4be60613          	addi	a2,a2,1214 # ffffffffc0202228 <commands+0x610>
ffffffffc0200d72:	0d900593          	li	a1,217
ffffffffc0200d76:	00001517          	auipc	a0,0x1
ffffffffc0200d7a:	4ca50513          	addi	a0,a0,1226 # ffffffffc0202240 <commands+0x628>
ffffffffc0200d7e:	bb8ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200d82:	00001697          	auipc	a3,0x1
ffffffffc0200d86:	64668693          	addi	a3,a3,1606 # ffffffffc02023c8 <commands+0x7b0>
ffffffffc0200d8a:	00001617          	auipc	a2,0x1
ffffffffc0200d8e:	49e60613          	addi	a2,a2,1182 # ffffffffc0202228 <commands+0x610>
ffffffffc0200d92:	0f200593          	li	a1,242
ffffffffc0200d96:	00001517          	auipc	a0,0x1
ffffffffc0200d9a:	4aa50513          	addi	a0,a0,1194 # ffffffffc0202240 <commands+0x628>
ffffffffc0200d9e:	b98ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200da2:	00001697          	auipc	a3,0x1
ffffffffc0200da6:	51668693          	addi	a3,a3,1302 # ffffffffc02022b8 <commands+0x6a0>
ffffffffc0200daa:	00001617          	auipc	a2,0x1
ffffffffc0200dae:	47e60613          	addi	a2,a2,1150 # ffffffffc0202228 <commands+0x610>
ffffffffc0200db2:	0d400593          	li	a1,212
ffffffffc0200db6:	00001517          	auipc	a0,0x1
ffffffffc0200dba:	48a50513          	addi	a0,a0,1162 # ffffffffc0202240 <commands+0x628>
ffffffffc0200dbe:	b78ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(total == 0);
ffffffffc0200dc2:	00001697          	auipc	a3,0x1
ffffffffc0200dc6:	73668693          	addi	a3,a3,1846 # ffffffffc02024f8 <commands+0x8e0>
ffffffffc0200dca:	00001617          	auipc	a2,0x1
ffffffffc0200dce:	45e60613          	addi	a2,a2,1118 # ffffffffc0202228 <commands+0x610>
ffffffffc0200dd2:	14c00593          	li	a1,332
ffffffffc0200dd6:	00001517          	auipc	a0,0x1
ffffffffc0200dda:	46a50513          	addi	a0,a0,1130 # ffffffffc0202240 <commands+0x628>
ffffffffc0200dde:	b58ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(total == nr_free_pages());
ffffffffc0200de2:	00001697          	auipc	a3,0x1
ffffffffc0200de6:	47668693          	addi	a3,a3,1142 # ffffffffc0202258 <commands+0x640>
ffffffffc0200dea:	00001617          	auipc	a2,0x1
ffffffffc0200dee:	43e60613          	addi	a2,a2,1086 # ffffffffc0202228 <commands+0x610>
ffffffffc0200df2:	10d00593          	li	a1,269
ffffffffc0200df6:	00001517          	auipc	a0,0x1
ffffffffc0200dfa:	44a50513          	addi	a0,a0,1098 # ffffffffc0202240 <commands+0x628>
ffffffffc0200dfe:	b38ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e02:	00001697          	auipc	a3,0x1
ffffffffc0200e06:	49668693          	addi	a3,a3,1174 # ffffffffc0202298 <commands+0x680>
ffffffffc0200e0a:	00001617          	auipc	a2,0x1
ffffffffc0200e0e:	41e60613          	addi	a2,a2,1054 # ffffffffc0202228 <commands+0x610>
ffffffffc0200e12:	0d300593          	li	a1,211
ffffffffc0200e16:	00001517          	auipc	a0,0x1
ffffffffc0200e1a:	42a50513          	addi	a0,a0,1066 # ffffffffc0202240 <commands+0x628>
ffffffffc0200e1e:	b18ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e22:	00001697          	auipc	a3,0x1
ffffffffc0200e26:	45668693          	addi	a3,a3,1110 # ffffffffc0202278 <commands+0x660>
ffffffffc0200e2a:	00001617          	auipc	a2,0x1
ffffffffc0200e2e:	3fe60613          	addi	a2,a2,1022 # ffffffffc0202228 <commands+0x610>
ffffffffc0200e32:	0d200593          	li	a1,210
ffffffffc0200e36:	00001517          	auipc	a0,0x1
ffffffffc0200e3a:	40a50513          	addi	a0,a0,1034 # ffffffffc0202240 <commands+0x628>
ffffffffc0200e3e:	af8ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e42:	00001697          	auipc	a3,0x1
ffffffffc0200e46:	55e68693          	addi	a3,a3,1374 # ffffffffc02023a0 <commands+0x788>
ffffffffc0200e4a:	00001617          	auipc	a2,0x1
ffffffffc0200e4e:	3de60613          	addi	a2,a2,990 # ffffffffc0202228 <commands+0x610>
ffffffffc0200e52:	0ef00593          	li	a1,239
ffffffffc0200e56:	00001517          	auipc	a0,0x1
ffffffffc0200e5a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0202240 <commands+0x628>
ffffffffc0200e5e:	ad8ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e62:	00001697          	auipc	a3,0x1
ffffffffc0200e66:	45668693          	addi	a3,a3,1110 # ffffffffc02022b8 <commands+0x6a0>
ffffffffc0200e6a:	00001617          	auipc	a2,0x1
ffffffffc0200e6e:	3be60613          	addi	a2,a2,958 # ffffffffc0202228 <commands+0x610>
ffffffffc0200e72:	0ed00593          	li	a1,237
ffffffffc0200e76:	00001517          	auipc	a0,0x1
ffffffffc0200e7a:	3ca50513          	addi	a0,a0,970 # ffffffffc0202240 <commands+0x628>
ffffffffc0200e7e:	ab8ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e82:	00001697          	auipc	a3,0x1
ffffffffc0200e86:	41668693          	addi	a3,a3,1046 # ffffffffc0202298 <commands+0x680>
ffffffffc0200e8a:	00001617          	auipc	a2,0x1
ffffffffc0200e8e:	39e60613          	addi	a2,a2,926 # ffffffffc0202228 <commands+0x610>
ffffffffc0200e92:	0ec00593          	li	a1,236
ffffffffc0200e96:	00001517          	auipc	a0,0x1
ffffffffc0200e9a:	3aa50513          	addi	a0,a0,938 # ffffffffc0202240 <commands+0x628>
ffffffffc0200e9e:	a98ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ea2:	00001697          	auipc	a3,0x1
ffffffffc0200ea6:	3d668693          	addi	a3,a3,982 # ffffffffc0202278 <commands+0x660>
ffffffffc0200eaa:	00001617          	auipc	a2,0x1
ffffffffc0200eae:	37e60613          	addi	a2,a2,894 # ffffffffc0202228 <commands+0x610>
ffffffffc0200eb2:	0eb00593          	li	a1,235
ffffffffc0200eb6:	00001517          	auipc	a0,0x1
ffffffffc0200eba:	38a50513          	addi	a0,a0,906 # ffffffffc0202240 <commands+0x628>
ffffffffc0200ebe:	a78ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(nr_free == 3);
ffffffffc0200ec2:	00001697          	auipc	a3,0x1
ffffffffc0200ec6:	4f668693          	addi	a3,a3,1270 # ffffffffc02023b8 <commands+0x7a0>
ffffffffc0200eca:	00001617          	auipc	a2,0x1
ffffffffc0200ece:	35e60613          	addi	a2,a2,862 # ffffffffc0202228 <commands+0x610>
ffffffffc0200ed2:	0e900593          	li	a1,233
ffffffffc0200ed6:	00001517          	auipc	a0,0x1
ffffffffc0200eda:	36a50513          	addi	a0,a0,874 # ffffffffc0202240 <commands+0x628>
ffffffffc0200ede:	a58ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ee2:	00001697          	auipc	a3,0x1
ffffffffc0200ee6:	4be68693          	addi	a3,a3,1214 # ffffffffc02023a0 <commands+0x788>
ffffffffc0200eea:	00001617          	auipc	a2,0x1
ffffffffc0200eee:	33e60613          	addi	a2,a2,830 # ffffffffc0202228 <commands+0x610>
ffffffffc0200ef2:	0e400593          	li	a1,228
ffffffffc0200ef6:	00001517          	auipc	a0,0x1
ffffffffc0200efa:	34a50513          	addi	a0,a0,842 # ffffffffc0202240 <commands+0x628>
ffffffffc0200efe:	a38ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f02:	00001697          	auipc	a3,0x1
ffffffffc0200f06:	47e68693          	addi	a3,a3,1150 # ffffffffc0202380 <commands+0x768>
ffffffffc0200f0a:	00001617          	auipc	a2,0x1
ffffffffc0200f0e:	31e60613          	addi	a2,a2,798 # ffffffffc0202228 <commands+0x610>
ffffffffc0200f12:	0db00593          	li	a1,219
ffffffffc0200f16:	00001517          	auipc	a0,0x1
ffffffffc0200f1a:	32a50513          	addi	a0,a0,810 # ffffffffc0202240 <commands+0x628>
ffffffffc0200f1e:	a18ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f22:	00001697          	auipc	a3,0x1
ffffffffc0200f26:	43e68693          	addi	a3,a3,1086 # ffffffffc0202360 <commands+0x748>
ffffffffc0200f2a:	00001617          	auipc	a2,0x1
ffffffffc0200f2e:	2fe60613          	addi	a2,a2,766 # ffffffffc0202228 <commands+0x610>
ffffffffc0200f32:	0da00593          	li	a1,218
ffffffffc0200f36:	00001517          	auipc	a0,0x1
ffffffffc0200f3a:	30a50513          	addi	a0,a0,778 # ffffffffc0202240 <commands+0x628>
ffffffffc0200f3e:	9f8ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(count == 0);
ffffffffc0200f42:	00001697          	auipc	a3,0x1
ffffffffc0200f46:	5a668693          	addi	a3,a3,1446 # ffffffffc02024e8 <commands+0x8d0>
ffffffffc0200f4a:	00001617          	auipc	a2,0x1
ffffffffc0200f4e:	2de60613          	addi	a2,a2,734 # ffffffffc0202228 <commands+0x610>
ffffffffc0200f52:	14b00593          	li	a1,331
ffffffffc0200f56:	00001517          	auipc	a0,0x1
ffffffffc0200f5a:	2ea50513          	addi	a0,a0,746 # ffffffffc0202240 <commands+0x628>
ffffffffc0200f5e:	9d8ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(nr_free == 0);
ffffffffc0200f62:	00001697          	auipc	a3,0x1
ffffffffc0200f66:	49e68693          	addi	a3,a3,1182 # ffffffffc0202400 <commands+0x7e8>
ffffffffc0200f6a:	00001617          	auipc	a2,0x1
ffffffffc0200f6e:	2be60613          	addi	a2,a2,702 # ffffffffc0202228 <commands+0x610>
ffffffffc0200f72:	14000593          	li	a1,320
ffffffffc0200f76:	00001517          	auipc	a0,0x1
ffffffffc0200f7a:	2ca50513          	addi	a0,a0,714 # ffffffffc0202240 <commands+0x628>
ffffffffc0200f7e:	9b8ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f82:	00001697          	auipc	a3,0x1
ffffffffc0200f86:	41e68693          	addi	a3,a3,1054 # ffffffffc02023a0 <commands+0x788>
ffffffffc0200f8a:	00001617          	auipc	a2,0x1
ffffffffc0200f8e:	29e60613          	addi	a2,a2,670 # ffffffffc0202228 <commands+0x610>
ffffffffc0200f92:	13a00593          	li	a1,314
ffffffffc0200f96:	00001517          	auipc	a0,0x1
ffffffffc0200f9a:	2aa50513          	addi	a0,a0,682 # ffffffffc0202240 <commands+0x628>
ffffffffc0200f9e:	998ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200fa2:	00001697          	auipc	a3,0x1
ffffffffc0200fa6:	52668693          	addi	a3,a3,1318 # ffffffffc02024c8 <commands+0x8b0>
ffffffffc0200faa:	00001617          	auipc	a2,0x1
ffffffffc0200fae:	27e60613          	addi	a2,a2,638 # ffffffffc0202228 <commands+0x610>
ffffffffc0200fb2:	13900593          	li	a1,313
ffffffffc0200fb6:	00001517          	auipc	a0,0x1
ffffffffc0200fba:	28a50513          	addi	a0,a0,650 # ffffffffc0202240 <commands+0x628>
ffffffffc0200fbe:	978ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200fc2:	00001697          	auipc	a3,0x1
ffffffffc0200fc6:	4f668693          	addi	a3,a3,1270 # ffffffffc02024b8 <commands+0x8a0>
ffffffffc0200fca:	00001617          	auipc	a2,0x1
ffffffffc0200fce:	25e60613          	addi	a2,a2,606 # ffffffffc0202228 <commands+0x610>
ffffffffc0200fd2:	13100593          	li	a1,305
ffffffffc0200fd6:	00001517          	auipc	a0,0x1
ffffffffc0200fda:	26a50513          	addi	a0,a0,618 # ffffffffc0202240 <commands+0x628>
ffffffffc0200fde:	958ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200fe2:	00001697          	auipc	a3,0x1
ffffffffc0200fe6:	4be68693          	addi	a3,a3,1214 # ffffffffc02024a0 <commands+0x888>
ffffffffc0200fea:	00001617          	auipc	a2,0x1
ffffffffc0200fee:	23e60613          	addi	a2,a2,574 # ffffffffc0202228 <commands+0x610>
ffffffffc0200ff2:	13000593          	li	a1,304
ffffffffc0200ff6:	00001517          	auipc	a0,0x1
ffffffffc0200ffa:	24a50513          	addi	a0,a0,586 # ffffffffc0202240 <commands+0x628>
ffffffffc0200ffe:	938ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0201002:	00001697          	auipc	a3,0x1
ffffffffc0201006:	47e68693          	addi	a3,a3,1150 # ffffffffc0202480 <commands+0x868>
ffffffffc020100a:	00001617          	auipc	a2,0x1
ffffffffc020100e:	21e60613          	addi	a2,a2,542 # ffffffffc0202228 <commands+0x610>
ffffffffc0201012:	12f00593          	li	a1,303
ffffffffc0201016:	00001517          	auipc	a0,0x1
ffffffffc020101a:	22a50513          	addi	a0,a0,554 # ffffffffc0202240 <commands+0x628>
ffffffffc020101e:	918ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0201022:	00001697          	auipc	a3,0x1
ffffffffc0201026:	42e68693          	addi	a3,a3,1070 # ffffffffc0202450 <commands+0x838>
ffffffffc020102a:	00001617          	auipc	a2,0x1
ffffffffc020102e:	1fe60613          	addi	a2,a2,510 # ffffffffc0202228 <commands+0x610>
ffffffffc0201032:	12d00593          	li	a1,301
ffffffffc0201036:	00001517          	auipc	a0,0x1
ffffffffc020103a:	20a50513          	addi	a0,a0,522 # ffffffffc0202240 <commands+0x628>
ffffffffc020103e:	8f8ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201042:	00001697          	auipc	a3,0x1
ffffffffc0201046:	3f668693          	addi	a3,a3,1014 # ffffffffc0202438 <commands+0x820>
ffffffffc020104a:	00001617          	auipc	a2,0x1
ffffffffc020104e:	1de60613          	addi	a2,a2,478 # ffffffffc0202228 <commands+0x610>
ffffffffc0201052:	12c00593          	li	a1,300
ffffffffc0201056:	00001517          	auipc	a0,0x1
ffffffffc020105a:	1ea50513          	addi	a0,a0,490 # ffffffffc0202240 <commands+0x628>
ffffffffc020105e:	8d8ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201062:	00001697          	auipc	a3,0x1
ffffffffc0201066:	33e68693          	addi	a3,a3,830 # ffffffffc02023a0 <commands+0x788>
ffffffffc020106a:	00001617          	auipc	a2,0x1
ffffffffc020106e:	1be60613          	addi	a2,a2,446 # ffffffffc0202228 <commands+0x610>
ffffffffc0201072:	12000593          	li	a1,288
ffffffffc0201076:	00001517          	auipc	a0,0x1
ffffffffc020107a:	1ca50513          	addi	a0,a0,458 # ffffffffc0202240 <commands+0x628>
ffffffffc020107e:	8b8ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201082:	00001697          	auipc	a3,0x1
ffffffffc0201086:	39e68693          	addi	a3,a3,926 # ffffffffc0202420 <commands+0x808>
ffffffffc020108a:	00001617          	auipc	a2,0x1
ffffffffc020108e:	19e60613          	addi	a2,a2,414 # ffffffffc0202228 <commands+0x610>
ffffffffc0201092:	11700593          	li	a1,279
ffffffffc0201096:	00001517          	auipc	a0,0x1
ffffffffc020109a:	1aa50513          	addi	a0,a0,426 # ffffffffc0202240 <commands+0x628>
ffffffffc020109e:	898ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(p0 != NULL);
ffffffffc02010a2:	00001697          	auipc	a3,0x1
ffffffffc02010a6:	36e68693          	addi	a3,a3,878 # ffffffffc0202410 <commands+0x7f8>
ffffffffc02010aa:	00001617          	auipc	a2,0x1
ffffffffc02010ae:	17e60613          	addi	a2,a2,382 # ffffffffc0202228 <commands+0x610>
ffffffffc02010b2:	11600593          	li	a1,278
ffffffffc02010b6:	00001517          	auipc	a0,0x1
ffffffffc02010ba:	18a50513          	addi	a0,a0,394 # ffffffffc0202240 <commands+0x628>
ffffffffc02010be:	878ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(nr_free == 0);
ffffffffc02010c2:	00001697          	auipc	a3,0x1
ffffffffc02010c6:	33e68693          	addi	a3,a3,830 # ffffffffc0202400 <commands+0x7e8>
ffffffffc02010ca:	00001617          	auipc	a2,0x1
ffffffffc02010ce:	15e60613          	addi	a2,a2,350 # ffffffffc0202228 <commands+0x610>
ffffffffc02010d2:	0f800593          	li	a1,248
ffffffffc02010d6:	00001517          	auipc	a0,0x1
ffffffffc02010da:	16a50513          	addi	a0,a0,362 # ffffffffc0202240 <commands+0x628>
ffffffffc02010de:	858ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010e2:	00001697          	auipc	a3,0x1
ffffffffc02010e6:	2be68693          	addi	a3,a3,702 # ffffffffc02023a0 <commands+0x788>
ffffffffc02010ea:	00001617          	auipc	a2,0x1
ffffffffc02010ee:	13e60613          	addi	a2,a2,318 # ffffffffc0202228 <commands+0x610>
ffffffffc02010f2:	0f600593          	li	a1,246
ffffffffc02010f6:	00001517          	auipc	a0,0x1
ffffffffc02010fa:	14a50513          	addi	a0,a0,330 # ffffffffc0202240 <commands+0x628>
ffffffffc02010fe:	838ff0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201102:	00001697          	auipc	a3,0x1
ffffffffc0201106:	2de68693          	addi	a3,a3,734 # ffffffffc02023e0 <commands+0x7c8>
ffffffffc020110a:	00001617          	auipc	a2,0x1
ffffffffc020110e:	11e60613          	addi	a2,a2,286 # ffffffffc0202228 <commands+0x610>
ffffffffc0201112:	0f500593          	li	a1,245
ffffffffc0201116:	00001517          	auipc	a0,0x1
ffffffffc020111a:	12a50513          	addi	a0,a0,298 # ffffffffc0202240 <commands+0x628>
ffffffffc020111e:	818ff0ef          	jal	ra,ffffffffc0200136 <__panic>

ffffffffc0201122 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0201122:	1141                	addi	sp,sp,-16
ffffffffc0201124:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201126:	14058a63          	beqz	a1,ffffffffc020127a <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020112a:	00259693          	slli	a3,a1,0x2
ffffffffc020112e:	96ae                	add	a3,a3,a1
ffffffffc0201130:	068e                	slli	a3,a3,0x3
ffffffffc0201132:	96aa                	add	a3,a3,a0
ffffffffc0201134:	87aa                	mv	a5,a0
ffffffffc0201136:	02d50263          	beq	a0,a3,ffffffffc020115a <best_fit_free_pages+0x38>
ffffffffc020113a:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020113c:	8b05                	andi	a4,a4,1
ffffffffc020113e:	10071e63          	bnez	a4,ffffffffc020125a <best_fit_free_pages+0x138>
ffffffffc0201142:	6798                	ld	a4,8(a5)
ffffffffc0201144:	8b09                	andi	a4,a4,2
ffffffffc0201146:	10071a63          	bnez	a4,ffffffffc020125a <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc020114a:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020114e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201152:	02878793          	addi	a5,a5,40
ffffffffc0201156:	fed792e3          	bne	a5,a3,ffffffffc020113a <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc020115a:	2581                	sext.w	a1,a1
ffffffffc020115c:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020115e:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201162:	4789                	li	a5,2
ffffffffc0201164:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201168:	00005697          	auipc	a3,0x5
ffffffffc020116c:	ea868693          	addi	a3,a3,-344 # ffffffffc0206010 <free_area>
ffffffffc0201170:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201172:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201174:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201178:	9db9                	addw	a1,a1,a4
ffffffffc020117a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020117c:	0ad78863          	beq	a5,a3,ffffffffc020122c <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201180:	fe878713          	addi	a4,a5,-24
ffffffffc0201184:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201188:	4581                	li	a1,0
            if (base < page) {
ffffffffc020118a:	00e56a63          	bltu	a0,a4,ffffffffc020119e <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc020118e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201190:	06d70263          	beq	a4,a3,ffffffffc02011f4 <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201194:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201196:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020119a:	fee57ae3          	bgeu	a0,a4,ffffffffc020118e <best_fit_free_pages+0x6c>
ffffffffc020119e:	c199                	beqz	a1,ffffffffc02011a4 <best_fit_free_pages+0x82>
ffffffffc02011a0:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02011a4:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02011a6:	e390                	sd	a2,0(a5)
ffffffffc02011a8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02011aa:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011ac:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc02011ae:	02d70063          	beq	a4,a3,ffffffffc02011ce <best_fit_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02011b2:	ff872803          	lw	a6,-8(a4) # ffffffffffffeff8 <end+0x3fdf8b88>
        p = le2page(le, page_link);
ffffffffc02011b6:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc02011ba:	02081613          	slli	a2,a6,0x20
ffffffffc02011be:	9201                	srli	a2,a2,0x20
ffffffffc02011c0:	00261793          	slli	a5,a2,0x2
ffffffffc02011c4:	97b2                	add	a5,a5,a2
ffffffffc02011c6:	078e                	slli	a5,a5,0x3
ffffffffc02011c8:	97ae                	add	a5,a5,a1
ffffffffc02011ca:	02f50f63          	beq	a0,a5,ffffffffc0201208 <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc02011ce:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc02011d0:	00d70f63          	beq	a4,a3,ffffffffc02011ee <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02011d4:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc02011d6:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc02011da:	02059613          	slli	a2,a1,0x20
ffffffffc02011de:	9201                	srli	a2,a2,0x20
ffffffffc02011e0:	00261793          	slli	a5,a2,0x2
ffffffffc02011e4:	97b2                	add	a5,a5,a2
ffffffffc02011e6:	078e                	slli	a5,a5,0x3
ffffffffc02011e8:	97aa                	add	a5,a5,a0
ffffffffc02011ea:	04f68863          	beq	a3,a5,ffffffffc020123a <best_fit_free_pages+0x118>
}
ffffffffc02011ee:	60a2                	ld	ra,8(sp)
ffffffffc02011f0:	0141                	addi	sp,sp,16
ffffffffc02011f2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02011f4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011f6:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02011f8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02011fa:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02011fc:	02d70563          	beq	a4,a3,ffffffffc0201226 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201200:	8832                	mv	a6,a2
ffffffffc0201202:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201204:	87ba                	mv	a5,a4
ffffffffc0201206:	bf41                	j	ffffffffc0201196 <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc0201208:	491c                	lw	a5,16(a0)
ffffffffc020120a:	0107883b          	addw	a6,a5,a6
ffffffffc020120e:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201212:	57f5                	li	a5,-3
ffffffffc0201214:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201218:	6d10                	ld	a2,24(a0)
ffffffffc020121a:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc020121c:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020121e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201220:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201222:	e390                	sd	a2,0(a5)
ffffffffc0201224:	b775                	j	ffffffffc02011d0 <best_fit_free_pages+0xae>
ffffffffc0201226:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201228:	873e                	mv	a4,a5
ffffffffc020122a:	b761                	j	ffffffffc02011b2 <best_fit_free_pages+0x90>
}
ffffffffc020122c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020122e:	e390                	sd	a2,0(a5)
ffffffffc0201230:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201232:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201234:	ed1c                	sd	a5,24(a0)
ffffffffc0201236:	0141                	addi	sp,sp,16
ffffffffc0201238:	8082                	ret
            base->property += p->property;
ffffffffc020123a:	ff872783          	lw	a5,-8(a4)
ffffffffc020123e:	ff070693          	addi	a3,a4,-16
ffffffffc0201242:	9dbd                	addw	a1,a1,a5
ffffffffc0201244:	c90c                	sw	a1,16(a0)
ffffffffc0201246:	57f5                	li	a5,-3
ffffffffc0201248:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020124c:	6314                	ld	a3,0(a4)
ffffffffc020124e:	671c                	ld	a5,8(a4)
}
ffffffffc0201250:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201252:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201254:	e394                	sd	a3,0(a5)
ffffffffc0201256:	0141                	addi	sp,sp,16
ffffffffc0201258:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020125a:	00001697          	auipc	a3,0x1
ffffffffc020125e:	2b668693          	addi	a3,a3,694 # ffffffffc0202510 <commands+0x8f8>
ffffffffc0201262:	00001617          	auipc	a2,0x1
ffffffffc0201266:	fc660613          	addi	a2,a2,-58 # ffffffffc0202228 <commands+0x610>
ffffffffc020126a:	09200593          	li	a1,146
ffffffffc020126e:	00001517          	auipc	a0,0x1
ffffffffc0201272:	fd250513          	addi	a0,a0,-46 # ffffffffc0202240 <commands+0x628>
ffffffffc0201276:	ec1fe0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(n > 0);
ffffffffc020127a:	00001697          	auipc	a3,0x1
ffffffffc020127e:	28e68693          	addi	a3,a3,654 # ffffffffc0202508 <commands+0x8f0>
ffffffffc0201282:	00001617          	auipc	a2,0x1
ffffffffc0201286:	fa660613          	addi	a2,a2,-90 # ffffffffc0202228 <commands+0x610>
ffffffffc020128a:	08f00593          	li	a1,143
ffffffffc020128e:	00001517          	auipc	a0,0x1
ffffffffc0201292:	fb250513          	addi	a0,a0,-78 # ffffffffc0202240 <commands+0x628>
ffffffffc0201296:	ea1fe0ef          	jal	ra,ffffffffc0200136 <__panic>

ffffffffc020129a <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc020129a:	c959                	beqz	a0,ffffffffc0201330 <best_fit_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020129c:	00005617          	auipc	a2,0x5
ffffffffc02012a0:	d7460613          	addi	a2,a2,-652 # ffffffffc0206010 <free_area>
ffffffffc02012a4:	4a0c                	lw	a1,16(a2)
ffffffffc02012a6:	872a                	mv	a4,a0
ffffffffc02012a8:	02059793          	slli	a5,a1,0x20
ffffffffc02012ac:	9381                	srli	a5,a5,0x20
ffffffffc02012ae:	06a7ef63          	bltu	a5,a0,ffffffffc020132c <best_fit_alloc_pages+0x92>
    return listelm->next;
ffffffffc02012b2:	661c                	ld	a5,8(a2)
    struct Page *page = NULL;
ffffffffc02012b4:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc02012b6:	06c78a63          	beq	a5,a2,ffffffffc020132a <best_fit_alloc_pages+0x90>
        if (p->property >= n) {
ffffffffc02012ba:	ff87e683          	lwu	a3,-8(a5)
ffffffffc02012be:	00e6e463          	bltu	a3,a4,ffffffffc02012c6 <best_fit_alloc_pages+0x2c>
        struct Page *p = le2page(le, page_link);
ffffffffc02012c2:	fe878513          	addi	a0,a5,-24
ffffffffc02012c6:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02012c8:	fec799e3          	bne	a5,a2,ffffffffc02012ba <best_fit_alloc_pages+0x20>
    if (page != NULL) {
ffffffffc02012cc:	cd39                	beqz	a0,ffffffffc020132a <best_fit_alloc_pages+0x90>
    __list_del(listelm->prev, listelm->next);
ffffffffc02012ce:	711c                	ld	a5,32(a0)
    return listelm->prev;
ffffffffc02012d0:	6d14                	ld	a3,24(a0)
        if (page->property > n) {
ffffffffc02012d2:	01052803          	lw	a6,16(a0)
            p->property = page->property - n;
ffffffffc02012d6:	0007089b          	sext.w	a7,a4
    prev->next = next;
ffffffffc02012da:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02012dc:	e394                	sd	a3,0(a5)
        if (page->property > n) {
ffffffffc02012de:	02081793          	slli	a5,a6,0x20
ffffffffc02012e2:	9381                	srli	a5,a5,0x20
ffffffffc02012e4:	02f77a63          	bgeu	a4,a5,ffffffffc0201318 <best_fit_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc02012e8:	00271793          	slli	a5,a4,0x2
ffffffffc02012ec:	97ba                	add	a5,a5,a4
ffffffffc02012ee:	078e                	slli	a5,a5,0x3
ffffffffc02012f0:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc02012f2:	4118083b          	subw	a6,a6,a7
ffffffffc02012f6:	0107a823          	sw	a6,16(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012fa:	4709                	li	a4,2
ffffffffc02012fc:	00878593          	addi	a1,a5,8
ffffffffc0201300:	40e5b02f          	amoor.d	zero,a4,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201304:	6698                	ld	a4,8(a3)
            list_add(prev, &(p->page_link));
ffffffffc0201306:	01878813          	addi	a6,a5,24
        nr_free -= n;
ffffffffc020130a:	4a0c                	lw	a1,16(a2)
    prev->next = next->prev = elm;
ffffffffc020130c:	01073023          	sd	a6,0(a4)
ffffffffc0201310:	0106b423          	sd	a6,8(a3)
    elm->next = next;
ffffffffc0201314:	f398                	sd	a4,32(a5)
    elm->prev = prev;
ffffffffc0201316:	ef94                	sd	a3,24(a5)
ffffffffc0201318:	411585bb          	subw	a1,a1,a7
ffffffffc020131c:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020131e:	57f5                	li	a5,-3
ffffffffc0201320:	00850713          	addi	a4,a0,8
ffffffffc0201324:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0201328:	8082                	ret
}
ffffffffc020132a:	8082                	ret
        return NULL;
ffffffffc020132c:	4501                	li	a0,0
ffffffffc020132e:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0201330:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201332:	00001697          	auipc	a3,0x1
ffffffffc0201336:	1d668693          	addi	a3,a3,470 # ffffffffc0202508 <commands+0x8f0>
ffffffffc020133a:	00001617          	auipc	a2,0x1
ffffffffc020133e:	eee60613          	addi	a2,a2,-274 # ffffffffc0202228 <commands+0x610>
ffffffffc0201342:	06a00593          	li	a1,106
ffffffffc0201346:	00001517          	auipc	a0,0x1
ffffffffc020134a:	efa50513          	addi	a0,a0,-262 # ffffffffc0202240 <commands+0x628>
best_fit_alloc_pages(size_t n) {
ffffffffc020134e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201350:	de7fe0ef          	jal	ra,ffffffffc0200136 <__panic>

ffffffffc0201354 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc0201354:	1141                	addi	sp,sp,-16
ffffffffc0201356:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201358:	c9e1                	beqz	a1,ffffffffc0201428 <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc020135a:	00259693          	slli	a3,a1,0x2
ffffffffc020135e:	96ae                	add	a3,a3,a1
ffffffffc0201360:	068e                	slli	a3,a3,0x3
ffffffffc0201362:	96aa                	add	a3,a3,a0
ffffffffc0201364:	87aa                	mv	a5,a0
ffffffffc0201366:	00d50f63          	beq	a0,a3,ffffffffc0201384 <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020136a:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020136c:	8b05                	andi	a4,a4,1
ffffffffc020136e:	cf49                	beqz	a4,ffffffffc0201408 <best_fit_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201370:	0007a823          	sw	zero,16(a5)
ffffffffc0201374:	0007b423          	sd	zero,8(a5)
ffffffffc0201378:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020137c:	02878793          	addi	a5,a5,40
ffffffffc0201380:	fed795e3          	bne	a5,a3,ffffffffc020136a <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc0201384:	2581                	sext.w	a1,a1
ffffffffc0201386:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201388:	4789                	li	a5,2
ffffffffc020138a:	00850713          	addi	a4,a0,8
ffffffffc020138e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201392:	00005697          	auipc	a3,0x5
ffffffffc0201396:	c7e68693          	addi	a3,a3,-898 # ffffffffc0206010 <free_area>
ffffffffc020139a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020139c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020139e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02013a2:	9db9                	addw	a1,a1,a4
ffffffffc02013a4:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02013a6:	04d78a63          	beq	a5,a3,ffffffffc02013fa <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc02013aa:	fe878713          	addi	a4,a5,-24
ffffffffc02013ae:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02013b2:	4581                	li	a1,0
            if(base < page) {
ffffffffc02013b4:	00e56a63          	bltu	a0,a4,ffffffffc02013c8 <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc02013b8:	6798                	ld	a4,8(a5)
            } else if(list_next(le) == &free_list) {
ffffffffc02013ba:	02d70263          	beq	a4,a3,ffffffffc02013de <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02013be:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02013c0:	fe878713          	addi	a4,a5,-24
            if(base < page) {
ffffffffc02013c4:	fee57ae3          	bgeu	a0,a4,ffffffffc02013b8 <best_fit_init_memmap+0x64>
ffffffffc02013c8:	c199                	beqz	a1,ffffffffc02013ce <best_fit_init_memmap+0x7a>
ffffffffc02013ca:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013ce:	6398                	ld	a4,0(a5)
}
ffffffffc02013d0:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02013d2:	e390                	sd	a2,0(a5)
ffffffffc02013d4:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02013d6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02013d8:	ed18                	sd	a4,24(a0)
ffffffffc02013da:	0141                	addi	sp,sp,16
ffffffffc02013dc:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02013de:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013e0:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02013e2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02013e4:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013e6:	00d70663          	beq	a4,a3,ffffffffc02013f2 <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02013ea:	8832                	mv	a6,a2
ffffffffc02013ec:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02013ee:	87ba                	mv	a5,a4
ffffffffc02013f0:	bfc1                	j	ffffffffc02013c0 <best_fit_init_memmap+0x6c>
}
ffffffffc02013f2:	60a2                	ld	ra,8(sp)
ffffffffc02013f4:	e290                	sd	a2,0(a3)
ffffffffc02013f6:	0141                	addi	sp,sp,16
ffffffffc02013f8:	8082                	ret
ffffffffc02013fa:	60a2                	ld	ra,8(sp)
ffffffffc02013fc:	e390                	sd	a2,0(a5)
ffffffffc02013fe:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201400:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201402:	ed1c                	sd	a5,24(a0)
ffffffffc0201404:	0141                	addi	sp,sp,16
ffffffffc0201406:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201408:	00001697          	auipc	a3,0x1
ffffffffc020140c:	13068693          	addi	a3,a3,304 # ffffffffc0202538 <commands+0x920>
ffffffffc0201410:	00001617          	auipc	a2,0x1
ffffffffc0201414:	e1860613          	addi	a2,a2,-488 # ffffffffc0202228 <commands+0x610>
ffffffffc0201418:	04a00593          	li	a1,74
ffffffffc020141c:	00001517          	auipc	a0,0x1
ffffffffc0201420:	e2450513          	addi	a0,a0,-476 # ffffffffc0202240 <commands+0x628>
ffffffffc0201424:	d13fe0ef          	jal	ra,ffffffffc0200136 <__panic>
    assert(n > 0);
ffffffffc0201428:	00001697          	auipc	a3,0x1
ffffffffc020142c:	0e068693          	addi	a3,a3,224 # ffffffffc0202508 <commands+0x8f0>
ffffffffc0201430:	00001617          	auipc	a2,0x1
ffffffffc0201434:	df860613          	addi	a2,a2,-520 # ffffffffc0202228 <commands+0x610>
ffffffffc0201438:	04700593          	li	a1,71
ffffffffc020143c:	00001517          	auipc	a0,0x1
ffffffffc0201440:	e0450513          	addi	a0,a0,-508 # ffffffffc0202240 <commands+0x628>
ffffffffc0201444:	cf3fe0ef          	jal	ra,ffffffffc0200136 <__panic>

ffffffffc0201448 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201448:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020144a:	e589                	bnez	a1,ffffffffc0201454 <strnlen+0xc>
ffffffffc020144c:	a811                	j	ffffffffc0201460 <strnlen+0x18>
        cnt ++;
ffffffffc020144e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201450:	00f58863          	beq	a1,a5,ffffffffc0201460 <strnlen+0x18>
ffffffffc0201454:	00f50733          	add	a4,a0,a5
ffffffffc0201458:	00074703          	lbu	a4,0(a4)
ffffffffc020145c:	fb6d                	bnez	a4,ffffffffc020144e <strnlen+0x6>
ffffffffc020145e:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201460:	852e                	mv	a0,a1
ffffffffc0201462:	8082                	ret

ffffffffc0201464 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201464:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201468:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020146c:	cb89                	beqz	a5,ffffffffc020147e <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020146e:	0505                	addi	a0,a0,1
ffffffffc0201470:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201472:	fee789e3          	beq	a5,a4,ffffffffc0201464 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201476:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020147a:	9d19                	subw	a0,a0,a4
ffffffffc020147c:	8082                	ret
ffffffffc020147e:	4501                	li	a0,0
ffffffffc0201480:	bfed                	j	ffffffffc020147a <strcmp+0x16>

ffffffffc0201482 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201482:	00054783          	lbu	a5,0(a0)
ffffffffc0201486:	c799                	beqz	a5,ffffffffc0201494 <strchr+0x12>
        if (*s == c) {
ffffffffc0201488:	00f58763          	beq	a1,a5,ffffffffc0201496 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020148c:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201490:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201492:	fbfd                	bnez	a5,ffffffffc0201488 <strchr+0x6>
    }
    return NULL;
ffffffffc0201494:	4501                	li	a0,0
}
ffffffffc0201496:	8082                	ret

ffffffffc0201498 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201498:	ca01                	beqz	a2,ffffffffc02014a8 <memset+0x10>
ffffffffc020149a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020149c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020149e:	0785                	addi	a5,a5,1
ffffffffc02014a0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02014a4:	fec79de3          	bne	a5,a2,ffffffffc020149e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02014a8:	8082                	ret

ffffffffc02014aa <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02014aa:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014ae:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02014b0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014b4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02014b6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014ba:	f022                	sd	s0,32(sp)
ffffffffc02014bc:	ec26                	sd	s1,24(sp)
ffffffffc02014be:	e84a                	sd	s2,16(sp)
ffffffffc02014c0:	f406                	sd	ra,40(sp)
ffffffffc02014c2:	e44e                	sd	s3,8(sp)
ffffffffc02014c4:	84aa                	mv	s1,a0
ffffffffc02014c6:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02014c8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02014cc:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02014ce:	03067e63          	bgeu	a2,a6,ffffffffc020150a <printnum+0x60>
ffffffffc02014d2:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02014d4:	00805763          	blez	s0,ffffffffc02014e2 <printnum+0x38>
ffffffffc02014d8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02014da:	85ca                	mv	a1,s2
ffffffffc02014dc:	854e                	mv	a0,s3
ffffffffc02014de:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02014e0:	fc65                	bnez	s0,ffffffffc02014d8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014e2:	1a02                	slli	s4,s4,0x20
ffffffffc02014e4:	00001797          	auipc	a5,0x1
ffffffffc02014e8:	0b478793          	addi	a5,a5,180 # ffffffffc0202598 <best_fit_pmm_manager+0x38>
ffffffffc02014ec:	020a5a13          	srli	s4,s4,0x20
ffffffffc02014f0:	9a3e                	add	s4,s4,a5
}
ffffffffc02014f2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014f4:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02014f8:	70a2                	ld	ra,40(sp)
ffffffffc02014fa:	69a2                	ld	s3,8(sp)
ffffffffc02014fc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014fe:	85ca                	mv	a1,s2
ffffffffc0201500:	87a6                	mv	a5,s1
}
ffffffffc0201502:	6942                	ld	s2,16(sp)
ffffffffc0201504:	64e2                	ld	s1,24(sp)
ffffffffc0201506:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201508:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020150a:	03065633          	divu	a2,a2,a6
ffffffffc020150e:	8722                	mv	a4,s0
ffffffffc0201510:	f9bff0ef          	jal	ra,ffffffffc02014aa <printnum>
ffffffffc0201514:	b7f9                	j	ffffffffc02014e2 <printnum+0x38>

ffffffffc0201516 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201516:	7119                	addi	sp,sp,-128
ffffffffc0201518:	f4a6                	sd	s1,104(sp)
ffffffffc020151a:	f0ca                	sd	s2,96(sp)
ffffffffc020151c:	ecce                	sd	s3,88(sp)
ffffffffc020151e:	e8d2                	sd	s4,80(sp)
ffffffffc0201520:	e4d6                	sd	s5,72(sp)
ffffffffc0201522:	e0da                	sd	s6,64(sp)
ffffffffc0201524:	fc5e                	sd	s7,56(sp)
ffffffffc0201526:	f06a                	sd	s10,32(sp)
ffffffffc0201528:	fc86                	sd	ra,120(sp)
ffffffffc020152a:	f8a2                	sd	s0,112(sp)
ffffffffc020152c:	f862                	sd	s8,48(sp)
ffffffffc020152e:	f466                	sd	s9,40(sp)
ffffffffc0201530:	ec6e                	sd	s11,24(sp)
ffffffffc0201532:	892a                	mv	s2,a0
ffffffffc0201534:	84ae                	mv	s1,a1
ffffffffc0201536:	8d32                	mv	s10,a2
ffffffffc0201538:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020153a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020153e:	5b7d                	li	s6,-1
ffffffffc0201540:	00001a97          	auipc	s5,0x1
ffffffffc0201544:	08ca8a93          	addi	s5,s5,140 # ffffffffc02025cc <best_fit_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201548:	00001b97          	auipc	s7,0x1
ffffffffc020154c:	260b8b93          	addi	s7,s7,608 # ffffffffc02027a8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201550:	000d4503          	lbu	a0,0(s10)
ffffffffc0201554:	001d0413          	addi	s0,s10,1
ffffffffc0201558:	01350a63          	beq	a0,s3,ffffffffc020156c <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020155c:	c121                	beqz	a0,ffffffffc020159c <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020155e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201560:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201562:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201564:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201568:	ff351ae3          	bne	a0,s3,ffffffffc020155c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020156c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201570:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201574:	4c81                	li	s9,0
ffffffffc0201576:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201578:	5c7d                	li	s8,-1
ffffffffc020157a:	5dfd                	li	s11,-1
ffffffffc020157c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201580:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201582:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201586:	0ff5f593          	zext.b	a1,a1
ffffffffc020158a:	00140d13          	addi	s10,s0,1
ffffffffc020158e:	04b56263          	bltu	a0,a1,ffffffffc02015d2 <vprintfmt+0xbc>
ffffffffc0201592:	058a                	slli	a1,a1,0x2
ffffffffc0201594:	95d6                	add	a1,a1,s5
ffffffffc0201596:	4194                	lw	a3,0(a1)
ffffffffc0201598:	96d6                	add	a3,a3,s5
ffffffffc020159a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020159c:	70e6                	ld	ra,120(sp)
ffffffffc020159e:	7446                	ld	s0,112(sp)
ffffffffc02015a0:	74a6                	ld	s1,104(sp)
ffffffffc02015a2:	7906                	ld	s2,96(sp)
ffffffffc02015a4:	69e6                	ld	s3,88(sp)
ffffffffc02015a6:	6a46                	ld	s4,80(sp)
ffffffffc02015a8:	6aa6                	ld	s5,72(sp)
ffffffffc02015aa:	6b06                	ld	s6,64(sp)
ffffffffc02015ac:	7be2                	ld	s7,56(sp)
ffffffffc02015ae:	7c42                	ld	s8,48(sp)
ffffffffc02015b0:	7ca2                	ld	s9,40(sp)
ffffffffc02015b2:	7d02                	ld	s10,32(sp)
ffffffffc02015b4:	6de2                	ld	s11,24(sp)
ffffffffc02015b6:	6109                	addi	sp,sp,128
ffffffffc02015b8:	8082                	ret
            padc = '0';
ffffffffc02015ba:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02015bc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015c0:	846a                	mv	s0,s10
ffffffffc02015c2:	00140d13          	addi	s10,s0,1
ffffffffc02015c6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02015ca:	0ff5f593          	zext.b	a1,a1
ffffffffc02015ce:	fcb572e3          	bgeu	a0,a1,ffffffffc0201592 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02015d2:	85a6                	mv	a1,s1
ffffffffc02015d4:	02500513          	li	a0,37
ffffffffc02015d8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02015da:	fff44783          	lbu	a5,-1(s0)
ffffffffc02015de:	8d22                	mv	s10,s0
ffffffffc02015e0:	f73788e3          	beq	a5,s3,ffffffffc0201550 <vprintfmt+0x3a>
ffffffffc02015e4:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02015e8:	1d7d                	addi	s10,s10,-1
ffffffffc02015ea:	ff379de3          	bne	a5,s3,ffffffffc02015e4 <vprintfmt+0xce>
ffffffffc02015ee:	b78d                	j	ffffffffc0201550 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02015f0:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02015f4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015f8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02015fa:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02015fe:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201602:	02d86463          	bltu	a6,a3,ffffffffc020162a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201606:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020160a:	002c169b          	slliw	a3,s8,0x2
ffffffffc020160e:	0186873b          	addw	a4,a3,s8
ffffffffc0201612:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201616:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201618:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020161c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020161e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201622:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201626:	fed870e3          	bgeu	a6,a3,ffffffffc0201606 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020162a:	f40ddce3          	bgez	s11,ffffffffc0201582 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020162e:	8de2                	mv	s11,s8
ffffffffc0201630:	5c7d                	li	s8,-1
ffffffffc0201632:	bf81                	j	ffffffffc0201582 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201634:	fffdc693          	not	a3,s11
ffffffffc0201638:	96fd                	srai	a3,a3,0x3f
ffffffffc020163a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020163e:	00144603          	lbu	a2,1(s0)
ffffffffc0201642:	2d81                	sext.w	s11,s11
ffffffffc0201644:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201646:	bf35                	j	ffffffffc0201582 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201648:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020164c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201650:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201652:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201654:	bfd9                	j	ffffffffc020162a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201656:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201658:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020165c:	01174463          	blt	a4,a7,ffffffffc0201664 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201660:	1a088e63          	beqz	a7,ffffffffc020181c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201664:	000a3603          	ld	a2,0(s4)
ffffffffc0201668:	46c1                	li	a3,16
ffffffffc020166a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020166c:	2781                	sext.w	a5,a5
ffffffffc020166e:	876e                	mv	a4,s11
ffffffffc0201670:	85a6                	mv	a1,s1
ffffffffc0201672:	854a                	mv	a0,s2
ffffffffc0201674:	e37ff0ef          	jal	ra,ffffffffc02014aa <printnum>
            break;
ffffffffc0201678:	bde1                	j	ffffffffc0201550 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020167a:	000a2503          	lw	a0,0(s4)
ffffffffc020167e:	85a6                	mv	a1,s1
ffffffffc0201680:	0a21                	addi	s4,s4,8
ffffffffc0201682:	9902                	jalr	s2
            break;
ffffffffc0201684:	b5f1                	j	ffffffffc0201550 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201686:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201688:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020168c:	01174463          	blt	a4,a7,ffffffffc0201694 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201690:	18088163          	beqz	a7,ffffffffc0201812 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201694:	000a3603          	ld	a2,0(s4)
ffffffffc0201698:	46a9                	li	a3,10
ffffffffc020169a:	8a2e                	mv	s4,a1
ffffffffc020169c:	bfc1                	j	ffffffffc020166c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020169e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02016a2:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016a4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016a6:	bdf1                	j	ffffffffc0201582 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02016a8:	85a6                	mv	a1,s1
ffffffffc02016aa:	02500513          	li	a0,37
ffffffffc02016ae:	9902                	jalr	s2
            break;
ffffffffc02016b0:	b545                	j	ffffffffc0201550 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016b2:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02016b6:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016b8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016ba:	b5e1                	j	ffffffffc0201582 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02016bc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02016be:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02016c2:	01174463          	blt	a4,a7,ffffffffc02016ca <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02016c6:	14088163          	beqz	a7,ffffffffc0201808 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02016ca:	000a3603          	ld	a2,0(s4)
ffffffffc02016ce:	46a1                	li	a3,8
ffffffffc02016d0:	8a2e                	mv	s4,a1
ffffffffc02016d2:	bf69                	j	ffffffffc020166c <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02016d4:	03000513          	li	a0,48
ffffffffc02016d8:	85a6                	mv	a1,s1
ffffffffc02016da:	e03e                	sd	a5,0(sp)
ffffffffc02016dc:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02016de:	85a6                	mv	a1,s1
ffffffffc02016e0:	07800513          	li	a0,120
ffffffffc02016e4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02016e6:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02016e8:	6782                	ld	a5,0(sp)
ffffffffc02016ea:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02016ec:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02016f0:	bfb5                	j	ffffffffc020166c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02016f2:	000a3403          	ld	s0,0(s4)
ffffffffc02016f6:	008a0713          	addi	a4,s4,8
ffffffffc02016fa:	e03a                	sd	a4,0(sp)
ffffffffc02016fc:	14040263          	beqz	s0,ffffffffc0201840 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201700:	0fb05763          	blez	s11,ffffffffc02017ee <vprintfmt+0x2d8>
ffffffffc0201704:	02d00693          	li	a3,45
ffffffffc0201708:	0cd79163          	bne	a5,a3,ffffffffc02017ca <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020170c:	00044783          	lbu	a5,0(s0)
ffffffffc0201710:	0007851b          	sext.w	a0,a5
ffffffffc0201714:	cf85                	beqz	a5,ffffffffc020174c <vprintfmt+0x236>
ffffffffc0201716:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020171a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020171e:	000c4563          	bltz	s8,ffffffffc0201728 <vprintfmt+0x212>
ffffffffc0201722:	3c7d                	addiw	s8,s8,-1
ffffffffc0201724:	036c0263          	beq	s8,s6,ffffffffc0201748 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201728:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020172a:	0e0c8e63          	beqz	s9,ffffffffc0201826 <vprintfmt+0x310>
ffffffffc020172e:	3781                	addiw	a5,a5,-32
ffffffffc0201730:	0ef47b63          	bgeu	s0,a5,ffffffffc0201826 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201734:	03f00513          	li	a0,63
ffffffffc0201738:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020173a:	000a4783          	lbu	a5,0(s4)
ffffffffc020173e:	3dfd                	addiw	s11,s11,-1
ffffffffc0201740:	0a05                	addi	s4,s4,1
ffffffffc0201742:	0007851b          	sext.w	a0,a5
ffffffffc0201746:	ffe1                	bnez	a5,ffffffffc020171e <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201748:	01b05963          	blez	s11,ffffffffc020175a <vprintfmt+0x244>
ffffffffc020174c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020174e:	85a6                	mv	a1,s1
ffffffffc0201750:	02000513          	li	a0,32
ffffffffc0201754:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201756:	fe0d9be3          	bnez	s11,ffffffffc020174c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020175a:	6a02                	ld	s4,0(sp)
ffffffffc020175c:	bbd5                	j	ffffffffc0201550 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020175e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201760:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201764:	01174463          	blt	a4,a7,ffffffffc020176c <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201768:	08088d63          	beqz	a7,ffffffffc0201802 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020176c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201770:	0a044d63          	bltz	s0,ffffffffc020182a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201774:	8622                	mv	a2,s0
ffffffffc0201776:	8a66                	mv	s4,s9
ffffffffc0201778:	46a9                	li	a3,10
ffffffffc020177a:	bdcd                	j	ffffffffc020166c <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020177c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201780:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201782:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201784:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201788:	8fb5                	xor	a5,a5,a3
ffffffffc020178a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020178e:	02d74163          	blt	a4,a3,ffffffffc02017b0 <vprintfmt+0x29a>
ffffffffc0201792:	00369793          	slli	a5,a3,0x3
ffffffffc0201796:	97de                	add	a5,a5,s7
ffffffffc0201798:	639c                	ld	a5,0(a5)
ffffffffc020179a:	cb99                	beqz	a5,ffffffffc02017b0 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020179c:	86be                	mv	a3,a5
ffffffffc020179e:	00001617          	auipc	a2,0x1
ffffffffc02017a2:	e2a60613          	addi	a2,a2,-470 # ffffffffc02025c8 <best_fit_pmm_manager+0x68>
ffffffffc02017a6:	85a6                	mv	a1,s1
ffffffffc02017a8:	854a                	mv	a0,s2
ffffffffc02017aa:	0ce000ef          	jal	ra,ffffffffc0201878 <printfmt>
ffffffffc02017ae:	b34d                	j	ffffffffc0201550 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02017b0:	00001617          	auipc	a2,0x1
ffffffffc02017b4:	e0860613          	addi	a2,a2,-504 # ffffffffc02025b8 <best_fit_pmm_manager+0x58>
ffffffffc02017b8:	85a6                	mv	a1,s1
ffffffffc02017ba:	854a                	mv	a0,s2
ffffffffc02017bc:	0bc000ef          	jal	ra,ffffffffc0201878 <printfmt>
ffffffffc02017c0:	bb41                	j	ffffffffc0201550 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02017c2:	00001417          	auipc	s0,0x1
ffffffffc02017c6:	dee40413          	addi	s0,s0,-530 # ffffffffc02025b0 <best_fit_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017ca:	85e2                	mv	a1,s8
ffffffffc02017cc:	8522                	mv	a0,s0
ffffffffc02017ce:	e43e                	sd	a5,8(sp)
ffffffffc02017d0:	c79ff0ef          	jal	ra,ffffffffc0201448 <strnlen>
ffffffffc02017d4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02017d8:	01b05b63          	blez	s11,ffffffffc02017ee <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02017dc:	67a2                	ld	a5,8(sp)
ffffffffc02017de:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017e2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02017e4:	85a6                	mv	a1,s1
ffffffffc02017e6:	8552                	mv	a0,s4
ffffffffc02017e8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017ea:	fe0d9ce3          	bnez	s11,ffffffffc02017e2 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017ee:	00044783          	lbu	a5,0(s0)
ffffffffc02017f2:	00140a13          	addi	s4,s0,1
ffffffffc02017f6:	0007851b          	sext.w	a0,a5
ffffffffc02017fa:	d3a5                	beqz	a5,ffffffffc020175a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017fc:	05e00413          	li	s0,94
ffffffffc0201800:	bf39                	j	ffffffffc020171e <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201802:	000a2403          	lw	s0,0(s4)
ffffffffc0201806:	b7ad                	j	ffffffffc0201770 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201808:	000a6603          	lwu	a2,0(s4)
ffffffffc020180c:	46a1                	li	a3,8
ffffffffc020180e:	8a2e                	mv	s4,a1
ffffffffc0201810:	bdb1                	j	ffffffffc020166c <vprintfmt+0x156>
ffffffffc0201812:	000a6603          	lwu	a2,0(s4)
ffffffffc0201816:	46a9                	li	a3,10
ffffffffc0201818:	8a2e                	mv	s4,a1
ffffffffc020181a:	bd89                	j	ffffffffc020166c <vprintfmt+0x156>
ffffffffc020181c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201820:	46c1                	li	a3,16
ffffffffc0201822:	8a2e                	mv	s4,a1
ffffffffc0201824:	b5a1                	j	ffffffffc020166c <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201826:	9902                	jalr	s2
ffffffffc0201828:	bf09                	j	ffffffffc020173a <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020182a:	85a6                	mv	a1,s1
ffffffffc020182c:	02d00513          	li	a0,45
ffffffffc0201830:	e03e                	sd	a5,0(sp)
ffffffffc0201832:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201834:	6782                	ld	a5,0(sp)
ffffffffc0201836:	8a66                	mv	s4,s9
ffffffffc0201838:	40800633          	neg	a2,s0
ffffffffc020183c:	46a9                	li	a3,10
ffffffffc020183e:	b53d                	j	ffffffffc020166c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201840:	03b05163          	blez	s11,ffffffffc0201862 <vprintfmt+0x34c>
ffffffffc0201844:	02d00693          	li	a3,45
ffffffffc0201848:	f6d79de3          	bne	a5,a3,ffffffffc02017c2 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020184c:	00001417          	auipc	s0,0x1
ffffffffc0201850:	d6440413          	addi	s0,s0,-668 # ffffffffc02025b0 <best_fit_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201854:	02800793          	li	a5,40
ffffffffc0201858:	02800513          	li	a0,40
ffffffffc020185c:	00140a13          	addi	s4,s0,1
ffffffffc0201860:	bd6d                	j	ffffffffc020171a <vprintfmt+0x204>
ffffffffc0201862:	00001a17          	auipc	s4,0x1
ffffffffc0201866:	d4fa0a13          	addi	s4,s4,-689 # ffffffffc02025b1 <best_fit_pmm_manager+0x51>
ffffffffc020186a:	02800513          	li	a0,40
ffffffffc020186e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201872:	05e00413          	li	s0,94
ffffffffc0201876:	b565                	j	ffffffffc020171e <vprintfmt+0x208>

ffffffffc0201878 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201878:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020187a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020187e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201880:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201882:	ec06                	sd	ra,24(sp)
ffffffffc0201884:	f83a                	sd	a4,48(sp)
ffffffffc0201886:	fc3e                	sd	a5,56(sp)
ffffffffc0201888:	e0c2                	sd	a6,64(sp)
ffffffffc020188a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020188c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020188e:	c89ff0ef          	jal	ra,ffffffffc0201516 <vprintfmt>
}
ffffffffc0201892:	60e2                	ld	ra,24(sp)
ffffffffc0201894:	6161                	addi	sp,sp,80
ffffffffc0201896:	8082                	ret

ffffffffc0201898 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201898:	715d                	addi	sp,sp,-80
ffffffffc020189a:	e486                	sd	ra,72(sp)
ffffffffc020189c:	e0a6                	sd	s1,64(sp)
ffffffffc020189e:	fc4a                	sd	s2,56(sp)
ffffffffc02018a0:	f84e                	sd	s3,48(sp)
ffffffffc02018a2:	f452                	sd	s4,40(sp)
ffffffffc02018a4:	f056                	sd	s5,32(sp)
ffffffffc02018a6:	ec5a                	sd	s6,24(sp)
ffffffffc02018a8:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02018aa:	c901                	beqz	a0,ffffffffc02018ba <readline+0x22>
ffffffffc02018ac:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02018ae:	00001517          	auipc	a0,0x1
ffffffffc02018b2:	d1a50513          	addi	a0,a0,-742 # ffffffffc02025c8 <best_fit_pmm_manager+0x68>
ffffffffc02018b6:	ff8fe0ef          	jal	ra,ffffffffc02000ae <cprintf>
readline(const char *prompt) {
ffffffffc02018ba:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018bc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02018be:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02018c0:	4aa9                	li	s5,10
ffffffffc02018c2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02018c4:	00004b97          	auipc	s7,0x4
ffffffffc02018c8:	764b8b93          	addi	s7,s7,1892 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02018d0:	857fe0ef          	jal	ra,ffffffffc0200126 <getchar>
        if (c < 0) {
ffffffffc02018d4:	00054a63          	bltz	a0,ffffffffc02018e8 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018d8:	00a95a63          	bge	s2,a0,ffffffffc02018ec <readline+0x54>
ffffffffc02018dc:	029a5263          	bge	s4,s1,ffffffffc0201900 <readline+0x68>
        c = getchar();
ffffffffc02018e0:	847fe0ef          	jal	ra,ffffffffc0200126 <getchar>
        if (c < 0) {
ffffffffc02018e4:	fe055ae3          	bgez	a0,ffffffffc02018d8 <readline+0x40>
            return NULL;
ffffffffc02018e8:	4501                	li	a0,0
ffffffffc02018ea:	a091                	j	ffffffffc020192e <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02018ec:	03351463          	bne	a0,s3,ffffffffc0201914 <readline+0x7c>
ffffffffc02018f0:	e8a9                	bnez	s1,ffffffffc0201942 <readline+0xaa>
        c = getchar();
ffffffffc02018f2:	835fe0ef          	jal	ra,ffffffffc0200126 <getchar>
        if (c < 0) {
ffffffffc02018f6:	fe0549e3          	bltz	a0,ffffffffc02018e8 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018fa:	fea959e3          	bge	s2,a0,ffffffffc02018ec <readline+0x54>
ffffffffc02018fe:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201900:	e42a                	sd	a0,8(sp)
ffffffffc0201902:	fe2fe0ef          	jal	ra,ffffffffc02000e4 <cputchar>
            buf[i ++] = c;
ffffffffc0201906:	6522                	ld	a0,8(sp)
ffffffffc0201908:	009b87b3          	add	a5,s7,s1
ffffffffc020190c:	2485                	addiw	s1,s1,1
ffffffffc020190e:	00a78023          	sb	a0,0(a5)
ffffffffc0201912:	bf7d                	j	ffffffffc02018d0 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201914:	01550463          	beq	a0,s5,ffffffffc020191c <readline+0x84>
ffffffffc0201918:	fb651ce3          	bne	a0,s6,ffffffffc02018d0 <readline+0x38>
            cputchar(c);
ffffffffc020191c:	fc8fe0ef          	jal	ra,ffffffffc02000e4 <cputchar>
            buf[i] = '\0';
ffffffffc0201920:	00004517          	auipc	a0,0x4
ffffffffc0201924:	70850513          	addi	a0,a0,1800 # ffffffffc0206028 <buf>
ffffffffc0201928:	94aa                	add	s1,s1,a0
ffffffffc020192a:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020192e:	60a6                	ld	ra,72(sp)
ffffffffc0201930:	6486                	ld	s1,64(sp)
ffffffffc0201932:	7962                	ld	s2,56(sp)
ffffffffc0201934:	79c2                	ld	s3,48(sp)
ffffffffc0201936:	7a22                	ld	s4,40(sp)
ffffffffc0201938:	7a82                	ld	s5,32(sp)
ffffffffc020193a:	6b62                	ld	s6,24(sp)
ffffffffc020193c:	6bc2                	ld	s7,16(sp)
ffffffffc020193e:	6161                	addi	sp,sp,80
ffffffffc0201940:	8082                	ret
            cputchar(c);
ffffffffc0201942:	4521                	li	a0,8
ffffffffc0201944:	fa0fe0ef          	jal	ra,ffffffffc02000e4 <cputchar>
            i --;
ffffffffc0201948:	34fd                	addiw	s1,s1,-1
ffffffffc020194a:	b759                	j	ffffffffc02018d0 <readline+0x38>

ffffffffc020194c <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc020194c:	4781                	li	a5,0
ffffffffc020194e:	00004717          	auipc	a4,0x4
ffffffffc0201952:	6ba73703          	ld	a4,1722(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201956:	88ba                	mv	a7,a4
ffffffffc0201958:	852a                	mv	a0,a0
ffffffffc020195a:	85be                	mv	a1,a5
ffffffffc020195c:	863e                	mv	a2,a5
ffffffffc020195e:	00000073          	ecall
ffffffffc0201962:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201964:	8082                	ret

ffffffffc0201966 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201966:	4781                	li	a5,0
ffffffffc0201968:	00005717          	auipc	a4,0x5
ffffffffc020196c:	b0073703          	ld	a4,-1280(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc0201970:	88ba                	mv	a7,a4
ffffffffc0201972:	852a                	mv	a0,a0
ffffffffc0201974:	85be                	mv	a1,a5
ffffffffc0201976:	863e                	mv	a2,a5
ffffffffc0201978:	00000073          	ecall
ffffffffc020197c:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc020197e:	8082                	ret

ffffffffc0201980 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201980:	4501                	li	a0,0
ffffffffc0201982:	00004797          	auipc	a5,0x4
ffffffffc0201986:	67e7b783          	ld	a5,1662(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc020198a:	88be                	mv	a7,a5
ffffffffc020198c:	852a                	mv	a0,a0
ffffffffc020198e:	85aa                	mv	a1,a0
ffffffffc0201990:	862a                	mv	a2,a0
ffffffffc0201992:	00000073          	ecall
ffffffffc0201996:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201998:	2501                	sext.w	a0,a0
ffffffffc020199a:	8082                	ret
