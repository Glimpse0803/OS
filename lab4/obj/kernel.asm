
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
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	02e50513          	addi	a0,a0,46 # ffffffffc020a060 <buf>
ffffffffc020003a:	00015617          	auipc	a2,0x15
ffffffffc020003e:	59260613          	addi	a2,a2,1426 # ffffffffc02155cc <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	245040ef          	jal	ra,ffffffffc0204a8e <memset>

    cons_init();                // init the console
ffffffffc020004e:	4fc000ef          	jal	ra,ffffffffc020054a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	e8e58593          	addi	a1,a1,-370 # ffffffffc0204ee0 <etext>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	ea650513          	addi	a0,a0,-346 # ffffffffc0204f00 <etext+0x20>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	1be000ef          	jal	ra,ffffffffc0200224 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	004010ef          	jal	ra,ffffffffc020106e <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	54e000ef          	jal	ra,ffffffffc02005bc <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5c8000ef          	jal	ra,ffffffffc020063a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	216020ef          	jal	ra,ffffffffc020228c <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	668040ef          	jal	ra,ffffffffc02046e2 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	424000ef          	jal	ra,ffffffffc02004a2 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	4b3020ef          	jal	ra,ffffffffc0202d34 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	472000ef          	jal	ra,ffffffffc02004f8 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	534000ef          	jal	ra,ffffffffc02005be <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc020008e:	0a3040ef          	jal	ra,ffffffffc0204930 <cpu_idle>

ffffffffc0200092 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200092:	1141                	addi	sp,sp,-16
ffffffffc0200094:	e022                	sd	s0,0(sp)
ffffffffc0200096:	e406                	sd	ra,8(sp)
ffffffffc0200098:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009a:	4b2000ef          	jal	ra,ffffffffc020054c <cons_putc>
    (*cnt) ++;
ffffffffc020009e:	401c                	lw	a5,0(s0)
}
ffffffffc02000a0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a2:	2785                	addiw	a5,a5,1
ffffffffc02000a4:	c01c                	sw	a5,0(s0)
}
ffffffffc02000a6:	6402                	ld	s0,0(sp)
ffffffffc02000a8:	0141                	addi	sp,sp,16
ffffffffc02000aa:	8082                	ret

ffffffffc02000ac <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ac:	1101                	addi	sp,sp,-32
ffffffffc02000ae:	862a                	mv	a2,a0
ffffffffc02000b0:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	00000517          	auipc	a0,0x0
ffffffffc02000b6:	fe050513          	addi	a0,a0,-32 # ffffffffc0200092 <cputch>
ffffffffc02000ba:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000bc:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000be:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	289040ef          	jal	ra,ffffffffc0204b48 <vprintfmt>
    return cnt;
}
ffffffffc02000c4:	60e2                	ld	ra,24(sp)
ffffffffc02000c6:	4532                	lw	a0,12(sp)
ffffffffc02000c8:	6105                	addi	sp,sp,32
ffffffffc02000ca:	8082                	ret

ffffffffc02000cc <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000cc:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000ce:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d2:	8e2a                	mv	t3,a0
ffffffffc02000d4:	f42e                	sd	a1,40(sp)
ffffffffc02000d6:	f832                	sd	a2,48(sp)
ffffffffc02000d8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000da:	00000517          	auipc	a0,0x0
ffffffffc02000de:	fb850513          	addi	a0,a0,-72 # ffffffffc0200092 <cputch>
ffffffffc02000e2:	004c                	addi	a1,sp,4
ffffffffc02000e4:	869a                	mv	a3,t1
ffffffffc02000e6:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000e8:	ec06                	sd	ra,24(sp)
ffffffffc02000ea:	e0ba                	sd	a4,64(sp)
ffffffffc02000ec:	e4be                	sd	a5,72(sp)
ffffffffc02000ee:	e8c2                	sd	a6,80(sp)
ffffffffc02000f0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f6:	253040ef          	jal	ra,ffffffffc0204b48 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fa:	60e2                	ld	ra,24(sp)
ffffffffc02000fc:	4512                	lw	a0,4(sp)
ffffffffc02000fe:	6125                	addi	sp,sp,96
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200102:	a1a9                	j	ffffffffc020054c <cons_putc>

ffffffffc0200104 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200104:	1141                	addi	sp,sp,-16
ffffffffc0200106:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200108:	478000ef          	jal	ra,ffffffffc0200580 <cons_getc>
ffffffffc020010c:	dd75                	beqz	a0,ffffffffc0200108 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020010e:	60a2                	ld	ra,8(sp)
ffffffffc0200110:	0141                	addi	sp,sp,16
ffffffffc0200112:	8082                	ret

ffffffffc0200114 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200114:	715d                	addi	sp,sp,-80
ffffffffc0200116:	e486                	sd	ra,72(sp)
ffffffffc0200118:	e0a6                	sd	s1,64(sp)
ffffffffc020011a:	fc4a                	sd	s2,56(sp)
ffffffffc020011c:	f84e                	sd	s3,48(sp)
ffffffffc020011e:	f452                	sd	s4,40(sp)
ffffffffc0200120:	f056                	sd	s5,32(sp)
ffffffffc0200122:	ec5a                	sd	s6,24(sp)
ffffffffc0200124:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0200126:	c901                	beqz	a0,ffffffffc0200136 <readline+0x22>
ffffffffc0200128:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020012a:	00005517          	auipc	a0,0x5
ffffffffc020012e:	dde50513          	addi	a0,a0,-546 # ffffffffc0204f08 <etext+0x28>
ffffffffc0200132:	f9bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
readline(const char *prompt) {
ffffffffc0200136:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200138:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020013a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020013c:	4aa9                	li	s5,10
ffffffffc020013e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200140:	0000ab97          	auipc	s7,0xa
ffffffffc0200144:	f20b8b93          	addi	s7,s7,-224 # ffffffffc020a060 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200148:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020014c:	fb9ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200150:	00054a63          	bltz	a0,ffffffffc0200164 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200154:	00a95a63          	bge	s2,a0,ffffffffc0200168 <readline+0x54>
ffffffffc0200158:	029a5263          	bge	s4,s1,ffffffffc020017c <readline+0x68>
        c = getchar();
ffffffffc020015c:	fa9ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200160:	fe055ae3          	bgez	a0,ffffffffc0200154 <readline+0x40>
            return NULL;
ffffffffc0200164:	4501                	li	a0,0
ffffffffc0200166:	a091                	j	ffffffffc02001aa <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0200168:	03351463          	bne	a0,s3,ffffffffc0200190 <readline+0x7c>
ffffffffc020016c:	e8a9                	bnez	s1,ffffffffc02001be <readline+0xaa>
        c = getchar();
ffffffffc020016e:	f97ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200172:	fe0549e3          	bltz	a0,ffffffffc0200164 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200176:	fea959e3          	bge	s2,a0,ffffffffc0200168 <readline+0x54>
ffffffffc020017a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020017c:	e42a                	sd	a0,8(sp)
ffffffffc020017e:	f85ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i ++] = c;
ffffffffc0200182:	6522                	ld	a0,8(sp)
ffffffffc0200184:	009b87b3          	add	a5,s7,s1
ffffffffc0200188:	2485                	addiw	s1,s1,1
ffffffffc020018a:	00a78023          	sb	a0,0(a5)
ffffffffc020018e:	bf7d                	j	ffffffffc020014c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0200190:	01550463          	beq	a0,s5,ffffffffc0200198 <readline+0x84>
ffffffffc0200194:	fb651ce3          	bne	a0,s6,ffffffffc020014c <readline+0x38>
            cputchar(c);
ffffffffc0200198:	f6bff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i] = '\0';
ffffffffc020019c:	0000a517          	auipc	a0,0xa
ffffffffc02001a0:	ec450513          	addi	a0,a0,-316 # ffffffffc020a060 <buf>
ffffffffc02001a4:	94aa                	add	s1,s1,a0
ffffffffc02001a6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001aa:	60a6                	ld	ra,72(sp)
ffffffffc02001ac:	6486                	ld	s1,64(sp)
ffffffffc02001ae:	7962                	ld	s2,56(sp)
ffffffffc02001b0:	79c2                	ld	s3,48(sp)
ffffffffc02001b2:	7a22                	ld	s4,40(sp)
ffffffffc02001b4:	7a82                	ld	s5,32(sp)
ffffffffc02001b6:	6b62                	ld	s6,24(sp)
ffffffffc02001b8:	6bc2                	ld	s7,16(sp)
ffffffffc02001ba:	6161                	addi	sp,sp,80
ffffffffc02001bc:	8082                	ret
            cputchar(c);
ffffffffc02001be:	4521                	li	a0,8
ffffffffc02001c0:	f43ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            i --;
ffffffffc02001c4:	34fd                	addiw	s1,s1,-1
ffffffffc02001c6:	b759                	j	ffffffffc020014c <readline+0x38>

ffffffffc02001c8 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c8:	00015317          	auipc	t1,0x15
ffffffffc02001cc:	37030313          	addi	t1,t1,880 # ffffffffc0215538 <is_panic>
ffffffffc02001d0:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001d4:	715d                	addi	sp,sp,-80
ffffffffc02001d6:	ec06                	sd	ra,24(sp)
ffffffffc02001d8:	e822                	sd	s0,16(sp)
ffffffffc02001da:	f436                	sd	a3,40(sp)
ffffffffc02001dc:	f83a                	sd	a4,48(sp)
ffffffffc02001de:	fc3e                	sd	a5,56(sp)
ffffffffc02001e0:	e0c2                	sd	a6,64(sp)
ffffffffc02001e2:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001e4:	020e1a63          	bnez	t3,ffffffffc0200218 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02001e8:	4785                	li	a5,1
ffffffffc02001ea:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02001ee:	8432                	mv	s0,a2
ffffffffc02001f0:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001f2:	862e                	mv	a2,a1
ffffffffc02001f4:	85aa                	mv	a1,a0
ffffffffc02001f6:	00005517          	auipc	a0,0x5
ffffffffc02001fa:	d1a50513          	addi	a0,a0,-742 # ffffffffc0204f10 <etext+0x30>
    va_start(ap, fmt);
ffffffffc02001fe:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200200:	ecdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200204:	65a2                	ld	a1,8(sp)
ffffffffc0200206:	8522                	mv	a0,s0
ffffffffc0200208:	ea5ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc020020c:	00006517          	auipc	a0,0x6
ffffffffc0200210:	aa450513          	addi	a0,a0,-1372 # ffffffffc0205cb0 <commands+0xb48>
ffffffffc0200214:	eb9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200218:	3ac000ef          	jal	ra,ffffffffc02005c4 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020021c:	4501                	li	a0,0
ffffffffc020021e:	130000ef          	jal	ra,ffffffffc020034e <kmonitor>
    while (1) {
ffffffffc0200222:	bfed                	j	ffffffffc020021c <__panic+0x54>

ffffffffc0200224 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200224:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200226:	00005517          	auipc	a0,0x5
ffffffffc020022a:	d0a50513          	addi	a0,a0,-758 # ffffffffc0204f30 <etext+0x50>
void print_kerninfo(void) {
ffffffffc020022e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200230:	e9dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200234:	00000597          	auipc	a1,0x0
ffffffffc0200238:	dfe58593          	addi	a1,a1,-514 # ffffffffc0200032 <kern_init>
ffffffffc020023c:	00005517          	auipc	a0,0x5
ffffffffc0200240:	d1450513          	addi	a0,a0,-748 # ffffffffc0204f50 <etext+0x70>
ffffffffc0200244:	e89ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200248:	00005597          	auipc	a1,0x5
ffffffffc020024c:	c9858593          	addi	a1,a1,-872 # ffffffffc0204ee0 <etext>
ffffffffc0200250:	00005517          	auipc	a0,0x5
ffffffffc0200254:	d2050513          	addi	a0,a0,-736 # ffffffffc0204f70 <etext+0x90>
ffffffffc0200258:	e75ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020025c:	0000a597          	auipc	a1,0xa
ffffffffc0200260:	e0458593          	addi	a1,a1,-508 # ffffffffc020a060 <buf>
ffffffffc0200264:	00005517          	auipc	a0,0x5
ffffffffc0200268:	d2c50513          	addi	a0,a0,-724 # ffffffffc0204f90 <etext+0xb0>
ffffffffc020026c:	e61ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200270:	00015597          	auipc	a1,0x15
ffffffffc0200274:	35c58593          	addi	a1,a1,860 # ffffffffc02155cc <end>
ffffffffc0200278:	00005517          	auipc	a0,0x5
ffffffffc020027c:	d3850513          	addi	a0,a0,-712 # ffffffffc0204fb0 <etext+0xd0>
ffffffffc0200280:	e4dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200284:	00015597          	auipc	a1,0x15
ffffffffc0200288:	74758593          	addi	a1,a1,1863 # ffffffffc02159cb <end+0x3ff>
ffffffffc020028c:	00000797          	auipc	a5,0x0
ffffffffc0200290:	da678793          	addi	a5,a5,-602 # ffffffffc0200032 <kern_init>
ffffffffc0200294:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200298:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020029c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020029e:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002a2:	95be                	add	a1,a1,a5
ffffffffc02002a4:	85a9                	srai	a1,a1,0xa
ffffffffc02002a6:	00005517          	auipc	a0,0x5
ffffffffc02002aa:	d2a50513          	addi	a0,a0,-726 # ffffffffc0204fd0 <etext+0xf0>
}
ffffffffc02002ae:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002b0:	bd31                	j	ffffffffc02000cc <cprintf>

ffffffffc02002b2 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002b2:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002b4:	00005617          	auipc	a2,0x5
ffffffffc02002b8:	d4c60613          	addi	a2,a2,-692 # ffffffffc0205000 <etext+0x120>
ffffffffc02002bc:	04d00593          	li	a1,77
ffffffffc02002c0:	00005517          	auipc	a0,0x5
ffffffffc02002c4:	d5850513          	addi	a0,a0,-680 # ffffffffc0205018 <etext+0x138>
void print_stackframe(void) {
ffffffffc02002c8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ca:	effff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02002ce <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ce:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002d0:	00005617          	auipc	a2,0x5
ffffffffc02002d4:	d6060613          	addi	a2,a2,-672 # ffffffffc0205030 <etext+0x150>
ffffffffc02002d8:	00005597          	auipc	a1,0x5
ffffffffc02002dc:	d7858593          	addi	a1,a1,-648 # ffffffffc0205050 <etext+0x170>
ffffffffc02002e0:	00005517          	auipc	a0,0x5
ffffffffc02002e4:	d7850513          	addi	a0,a0,-648 # ffffffffc0205058 <etext+0x178>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ea:	de3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02002ee:	00005617          	auipc	a2,0x5
ffffffffc02002f2:	d7a60613          	addi	a2,a2,-646 # ffffffffc0205068 <etext+0x188>
ffffffffc02002f6:	00005597          	auipc	a1,0x5
ffffffffc02002fa:	d9a58593          	addi	a1,a1,-614 # ffffffffc0205090 <etext+0x1b0>
ffffffffc02002fe:	00005517          	auipc	a0,0x5
ffffffffc0200302:	d5a50513          	addi	a0,a0,-678 # ffffffffc0205058 <etext+0x178>
ffffffffc0200306:	dc7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020030a:	00005617          	auipc	a2,0x5
ffffffffc020030e:	d9660613          	addi	a2,a2,-618 # ffffffffc02050a0 <etext+0x1c0>
ffffffffc0200312:	00005597          	auipc	a1,0x5
ffffffffc0200316:	dae58593          	addi	a1,a1,-594 # ffffffffc02050c0 <etext+0x1e0>
ffffffffc020031a:	00005517          	auipc	a0,0x5
ffffffffc020031e:	d3e50513          	addi	a0,a0,-706 # ffffffffc0205058 <etext+0x178>
ffffffffc0200322:	dabff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    }
    return 0;
}
ffffffffc0200326:	60a2                	ld	ra,8(sp)
ffffffffc0200328:	4501                	li	a0,0
ffffffffc020032a:	0141                	addi	sp,sp,16
ffffffffc020032c:	8082                	ret

ffffffffc020032e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020032e:	1141                	addi	sp,sp,-16
ffffffffc0200330:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200332:	ef3ff0ef          	jal	ra,ffffffffc0200224 <print_kerninfo>
    return 0;
}
ffffffffc0200336:	60a2                	ld	ra,8(sp)
ffffffffc0200338:	4501                	li	a0,0
ffffffffc020033a:	0141                	addi	sp,sp,16
ffffffffc020033c:	8082                	ret

ffffffffc020033e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020033e:	1141                	addi	sp,sp,-16
ffffffffc0200340:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200342:	f71ff0ef          	jal	ra,ffffffffc02002b2 <print_stackframe>
    return 0;
}
ffffffffc0200346:	60a2                	ld	ra,8(sp)
ffffffffc0200348:	4501                	li	a0,0
ffffffffc020034a:	0141                	addi	sp,sp,16
ffffffffc020034c:	8082                	ret

ffffffffc020034e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020034e:	7115                	addi	sp,sp,-224
ffffffffc0200350:	ed5e                	sd	s7,152(sp)
ffffffffc0200352:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200354:	00005517          	auipc	a0,0x5
ffffffffc0200358:	d7c50513          	addi	a0,a0,-644 # ffffffffc02050d0 <etext+0x1f0>
kmonitor(struct trapframe *tf) {
ffffffffc020035c:	ed86                	sd	ra,216(sp)
ffffffffc020035e:	e9a2                	sd	s0,208(sp)
ffffffffc0200360:	e5a6                	sd	s1,200(sp)
ffffffffc0200362:	e1ca                	sd	s2,192(sp)
ffffffffc0200364:	fd4e                	sd	s3,184(sp)
ffffffffc0200366:	f952                	sd	s4,176(sp)
ffffffffc0200368:	f556                	sd	s5,168(sp)
ffffffffc020036a:	f15a                	sd	s6,160(sp)
ffffffffc020036c:	e962                	sd	s8,144(sp)
ffffffffc020036e:	e566                	sd	s9,136(sp)
ffffffffc0200370:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200372:	d5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200376:	00005517          	auipc	a0,0x5
ffffffffc020037a:	d8250513          	addi	a0,a0,-638 # ffffffffc02050f8 <etext+0x218>
ffffffffc020037e:	d4fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200382:	000b8563          	beqz	s7,ffffffffc020038c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200386:	855e                	mv	a0,s7
ffffffffc0200388:	49a000ef          	jal	ra,ffffffffc0200822 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020038c:	4501                	li	a0,0
ffffffffc020038e:	4581                	li	a1,0
ffffffffc0200390:	4601                	li	a2,0
ffffffffc0200392:	48a1                	li	a7,8
ffffffffc0200394:	00000073          	ecall
ffffffffc0200398:	00005c17          	auipc	s8,0x5
ffffffffc020039c:	dd0c0c13          	addi	s8,s8,-560 # ffffffffc0205168 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003a0:	00005917          	auipc	s2,0x5
ffffffffc02003a4:	d8090913          	addi	s2,s2,-640 # ffffffffc0205120 <etext+0x240>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a8:	00005497          	auipc	s1,0x5
ffffffffc02003ac:	d8048493          	addi	s1,s1,-640 # ffffffffc0205128 <etext+0x248>
        if (argc == MAXARGS - 1) {
ffffffffc02003b0:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003b2:	00005b17          	auipc	s6,0x5
ffffffffc02003b6:	d7eb0b13          	addi	s6,s6,-642 # ffffffffc0205130 <etext+0x250>
        argv[argc ++] = buf;
ffffffffc02003ba:	00005a17          	auipc	s4,0x5
ffffffffc02003be:	c96a0a13          	addi	s4,s4,-874 # ffffffffc0205050 <etext+0x170>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c2:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003c4:	854a                	mv	a0,s2
ffffffffc02003c6:	d4fff0ef          	jal	ra,ffffffffc0200114 <readline>
ffffffffc02003ca:	842a                	mv	s0,a0
ffffffffc02003cc:	dd65                	beqz	a0,ffffffffc02003c4 <kmonitor+0x76>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ce:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003d2:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d4:	e1bd                	bnez	a1,ffffffffc020043a <kmonitor+0xec>
    if (argc == 0) {
ffffffffc02003d6:	fe0c87e3          	beqz	s9,ffffffffc02003c4 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003da:	6582                	ld	a1,0(sp)
ffffffffc02003dc:	00005d17          	auipc	s10,0x5
ffffffffc02003e0:	d8cd0d13          	addi	s10,s10,-628 # ffffffffc0205168 <commands>
        argv[argc ++] = buf;
ffffffffc02003e4:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e6:	4401                	li	s0,0
ffffffffc02003e8:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ea:	670040ef          	jal	ra,ffffffffc0204a5a <strcmp>
ffffffffc02003ee:	c919                	beqz	a0,ffffffffc0200404 <kmonitor+0xb6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003f0:	2405                	addiw	s0,s0,1
ffffffffc02003f2:	0b540063          	beq	s0,s5,ffffffffc0200492 <kmonitor+0x144>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f6:	000d3503          	ld	a0,0(s10)
ffffffffc02003fa:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003fc:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003fe:	65c040ef          	jal	ra,ffffffffc0204a5a <strcmp>
ffffffffc0200402:	f57d                	bnez	a0,ffffffffc02003f0 <kmonitor+0xa2>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200404:	00141793          	slli	a5,s0,0x1
ffffffffc0200408:	97a2                	add	a5,a5,s0
ffffffffc020040a:	078e                	slli	a5,a5,0x3
ffffffffc020040c:	97e2                	add	a5,a5,s8
ffffffffc020040e:	6b9c                	ld	a5,16(a5)
ffffffffc0200410:	865e                	mv	a2,s7
ffffffffc0200412:	002c                	addi	a1,sp,8
ffffffffc0200414:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200418:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020041a:	fa0555e3          	bgez	a0,ffffffffc02003c4 <kmonitor+0x76>
}
ffffffffc020041e:	60ee                	ld	ra,216(sp)
ffffffffc0200420:	644e                	ld	s0,208(sp)
ffffffffc0200422:	64ae                	ld	s1,200(sp)
ffffffffc0200424:	690e                	ld	s2,192(sp)
ffffffffc0200426:	79ea                	ld	s3,184(sp)
ffffffffc0200428:	7a4a                	ld	s4,176(sp)
ffffffffc020042a:	7aaa                	ld	s5,168(sp)
ffffffffc020042c:	7b0a                	ld	s6,160(sp)
ffffffffc020042e:	6bea                	ld	s7,152(sp)
ffffffffc0200430:	6c4a                	ld	s8,144(sp)
ffffffffc0200432:	6caa                	ld	s9,136(sp)
ffffffffc0200434:	6d0a                	ld	s10,128(sp)
ffffffffc0200436:	612d                	addi	sp,sp,224
ffffffffc0200438:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043a:	8526                	mv	a0,s1
ffffffffc020043c:	63c040ef          	jal	ra,ffffffffc0204a78 <strchr>
ffffffffc0200440:	c901                	beqz	a0,ffffffffc0200450 <kmonitor+0x102>
ffffffffc0200442:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200446:	00040023          	sb	zero,0(s0)
ffffffffc020044a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020044c:	d5c9                	beqz	a1,ffffffffc02003d6 <kmonitor+0x88>
ffffffffc020044e:	b7f5                	j	ffffffffc020043a <kmonitor+0xec>
        if (*buf == '\0') {
ffffffffc0200450:	00044783          	lbu	a5,0(s0)
ffffffffc0200454:	d3c9                	beqz	a5,ffffffffc02003d6 <kmonitor+0x88>
        if (argc == MAXARGS - 1) {
ffffffffc0200456:	033c8963          	beq	s9,s3,ffffffffc0200488 <kmonitor+0x13a>
        argv[argc ++] = buf;
ffffffffc020045a:	003c9793          	slli	a5,s9,0x3
ffffffffc020045e:	0118                	addi	a4,sp,128
ffffffffc0200460:	97ba                	add	a5,a5,a4
ffffffffc0200462:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200466:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020046a:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020046c:	e591                	bnez	a1,ffffffffc0200478 <kmonitor+0x12a>
ffffffffc020046e:	b7b5                	j	ffffffffc02003da <kmonitor+0x8c>
ffffffffc0200470:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200474:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200476:	d1a5                	beqz	a1,ffffffffc02003d6 <kmonitor+0x88>
ffffffffc0200478:	8526                	mv	a0,s1
ffffffffc020047a:	5fe040ef          	jal	ra,ffffffffc0204a78 <strchr>
ffffffffc020047e:	d96d                	beqz	a0,ffffffffc0200470 <kmonitor+0x122>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200480:	00044583          	lbu	a1,0(s0)
ffffffffc0200484:	d9a9                	beqz	a1,ffffffffc02003d6 <kmonitor+0x88>
ffffffffc0200486:	bf55                	j	ffffffffc020043a <kmonitor+0xec>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200488:	45c1                	li	a1,16
ffffffffc020048a:	855a                	mv	a0,s6
ffffffffc020048c:	c41ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0200490:	b7e9                	j	ffffffffc020045a <kmonitor+0x10c>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200492:	6582                	ld	a1,0(sp)
ffffffffc0200494:	00005517          	auipc	a0,0x5
ffffffffc0200498:	cbc50513          	addi	a0,a0,-836 # ffffffffc0205150 <etext+0x270>
ffffffffc020049c:	c31ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
ffffffffc02004a0:	b715                	j	ffffffffc02003c4 <kmonitor+0x76>

ffffffffc02004a2 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02004a2:	8082                	ret

ffffffffc02004a4 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02004a4:	00253513          	sltiu	a0,a0,2
ffffffffc02004a8:	8082                	ret

ffffffffc02004aa <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004aa:	03800513          	li	a0,56
ffffffffc02004ae:	8082                	ret

ffffffffc02004b0 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b0:	0000a797          	auipc	a5,0xa
ffffffffc02004b4:	fb078793          	addi	a5,a5,-80 # ffffffffc020a460 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02004b8:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004bc:	1141                	addi	sp,sp,-16
ffffffffc02004be:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004c0:	95be                	add	a1,a1,a5
ffffffffc02004c2:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004c6:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004c8:	5d8040ef          	jal	ra,ffffffffc0204aa0 <memcpy>
    return 0;
}
ffffffffc02004cc:	60a2                	ld	ra,8(sp)
ffffffffc02004ce:	4501                	li	a0,0
ffffffffc02004d0:	0141                	addi	sp,sp,16
ffffffffc02004d2:	8082                	ret

ffffffffc02004d4 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004d4:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d8:	0000a517          	auipc	a0,0xa
ffffffffc02004dc:	f8850513          	addi	a0,a0,-120 # ffffffffc020a460 <ide>
                   size_t nsecs) {
ffffffffc02004e0:	1141                	addi	sp,sp,-16
ffffffffc02004e2:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e4:	953e                	add	a0,a0,a5
ffffffffc02004e6:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004ea:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ec:	5b4040ef          	jal	ra,ffffffffc0204aa0 <memcpy>
    return 0;
}
ffffffffc02004f0:	60a2                	ld	ra,8(sp)
ffffffffc02004f2:	4501                	li	a0,0
ffffffffc02004f4:	0141                	addi	sp,sp,16
ffffffffc02004f6:	8082                	ret

ffffffffc02004f8 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004f8:	67e1                	lui	a5,0x18
ffffffffc02004fa:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004fe:	00015717          	auipc	a4,0x15
ffffffffc0200502:	04f73523          	sd	a5,74(a4) # ffffffffc0215548 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200506:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020050a:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020050c:	953e                	add	a0,a0,a5
ffffffffc020050e:	4601                	li	a2,0
ffffffffc0200510:	4881                	li	a7,0
ffffffffc0200512:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200516:	02000793          	li	a5,32
ffffffffc020051a:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020051e:	00005517          	auipc	a0,0x5
ffffffffc0200522:	c9250513          	addi	a0,a0,-878 # ffffffffc02051b0 <commands+0x48>
    ticks = 0;
ffffffffc0200526:	00015797          	auipc	a5,0x15
ffffffffc020052a:	0007bd23          	sd	zero,26(a5) # ffffffffc0215540 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020052e:	be79                	j	ffffffffc02000cc <cprintf>

ffffffffc0200530 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200530:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200534:	00015797          	auipc	a5,0x15
ffffffffc0200538:	0147b783          	ld	a5,20(a5) # ffffffffc0215548 <timebase>
ffffffffc020053c:	953e                	add	a0,a0,a5
ffffffffc020053e:	4581                	li	a1,0
ffffffffc0200540:	4601                	li	a2,0
ffffffffc0200542:	4881                	li	a7,0
ffffffffc0200544:	00000073          	ecall
ffffffffc0200548:	8082                	ret

ffffffffc020054a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020054a:	8082                	ret

ffffffffc020054c <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020054c:	100027f3          	csrr	a5,sstatus
ffffffffc0200550:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200552:	0ff57513          	zext.b	a0,a0
ffffffffc0200556:	e799                	bnez	a5,ffffffffc0200564 <cons_putc+0x18>
ffffffffc0200558:	4581                	li	a1,0
ffffffffc020055a:	4601                	li	a2,0
ffffffffc020055c:	4885                	li	a7,1
ffffffffc020055e:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200562:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200564:	1101                	addi	sp,sp,-32
ffffffffc0200566:	ec06                	sd	ra,24(sp)
ffffffffc0200568:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020056a:	05a000ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc020056e:	6522                	ld	a0,8(sp)
ffffffffc0200570:	4581                	li	a1,0
ffffffffc0200572:	4601                	li	a2,0
ffffffffc0200574:	4885                	li	a7,1
ffffffffc0200576:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020057a:	60e2                	ld	ra,24(sp)
ffffffffc020057c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020057e:	a081                	j	ffffffffc02005be <intr_enable>

ffffffffc0200580 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200580:	100027f3          	csrr	a5,sstatus
ffffffffc0200584:	8b89                	andi	a5,a5,2
ffffffffc0200586:	eb89                	bnez	a5,ffffffffc0200598 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200588:	4501                	li	a0,0
ffffffffc020058a:	4581                	li	a1,0
ffffffffc020058c:	4601                	li	a2,0
ffffffffc020058e:	4889                	li	a7,2
ffffffffc0200590:	00000073          	ecall
ffffffffc0200594:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200596:	8082                	ret
int cons_getc(void) {
ffffffffc0200598:	1101                	addi	sp,sp,-32
ffffffffc020059a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020059c:	028000ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc02005a0:	4501                	li	a0,0
ffffffffc02005a2:	4581                	li	a1,0
ffffffffc02005a4:	4601                	li	a2,0
ffffffffc02005a6:	4889                	li	a7,2
ffffffffc02005a8:	00000073          	ecall
ffffffffc02005ac:	2501                	sext.w	a0,a0
ffffffffc02005ae:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005b0:	00e000ef          	jal	ra,ffffffffc02005be <intr_enable>
}
ffffffffc02005b4:	60e2                	ld	ra,24(sp)
ffffffffc02005b6:	6522                	ld	a0,8(sp)
ffffffffc02005b8:	6105                	addi	sp,sp,32
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005bc:	8082                	ret

ffffffffc02005be <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005be:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005c2:	8082                	ret

ffffffffc02005c4 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005c4:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005c8:	8082                	ret

ffffffffc02005ca <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005ca:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005ce:	1141                	addi	sp,sp,-16
ffffffffc02005d0:	e022                	sd	s0,0(sp)
ffffffffc02005d2:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005d4:	1007f793          	andi	a5,a5,256
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005d8:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005dc:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005de:	05500613          	li	a2,85
ffffffffc02005e2:	c399                	beqz	a5,ffffffffc02005e8 <pgfault_handler+0x1e>
ffffffffc02005e4:	04b00613          	li	a2,75
ffffffffc02005e8:	11843703          	ld	a4,280(s0)
ffffffffc02005ec:	47bd                	li	a5,15
ffffffffc02005ee:	05700693          	li	a3,87
ffffffffc02005f2:	00f70463          	beq	a4,a5,ffffffffc02005fa <pgfault_handler+0x30>
ffffffffc02005f6:	05200693          	li	a3,82
ffffffffc02005fa:	00005517          	auipc	a0,0x5
ffffffffc02005fe:	bd650513          	addi	a0,a0,-1066 # ffffffffc02051d0 <commands+0x68>
ffffffffc0200602:	acbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200606:	00015517          	auipc	a0,0x15
ffffffffc020060a:	f7a53503          	ld	a0,-134(a0) # ffffffffc0215580 <check_mm_struct>
ffffffffc020060e:	c911                	beqz	a0,ffffffffc0200622 <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200610:	11043603          	ld	a2,272(s0)
ffffffffc0200614:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200618:	6402                	ld	s0,0(sp)
ffffffffc020061a:	60a2                	ld	ra,8(sp)
ffffffffc020061c:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020061e:	2420206f          	j	ffffffffc0202860 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200622:	00005617          	auipc	a2,0x5
ffffffffc0200626:	bce60613          	addi	a2,a2,-1074 # ffffffffc02051f0 <commands+0x88>
ffffffffc020062a:	06200593          	li	a1,98
ffffffffc020062e:	00005517          	auipc	a0,0x5
ffffffffc0200632:	bda50513          	addi	a0,a0,-1062 # ffffffffc0205208 <commands+0xa0>
ffffffffc0200636:	b93ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020063a <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020063a:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020063e:	00000797          	auipc	a5,0x0
ffffffffc0200642:	47a78793          	addi	a5,a5,1146 # ffffffffc0200ab8 <__alltraps>
ffffffffc0200646:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020064a:	000407b7          	lui	a5,0x40
ffffffffc020064e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200654:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200656:	1141                	addi	sp,sp,-16
ffffffffc0200658:	e022                	sd	s0,0(sp)
ffffffffc020065a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020065c:	00005517          	auipc	a0,0x5
ffffffffc0200660:	bc450513          	addi	a0,a0,-1084 # ffffffffc0205220 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200664:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200666:	a67ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020066a:	640c                	ld	a1,8(s0)
ffffffffc020066c:	00005517          	auipc	a0,0x5
ffffffffc0200670:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0205238 <commands+0xd0>
ffffffffc0200674:	a59ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200678:	680c                	ld	a1,16(s0)
ffffffffc020067a:	00005517          	auipc	a0,0x5
ffffffffc020067e:	bd650513          	addi	a0,a0,-1066 # ffffffffc0205250 <commands+0xe8>
ffffffffc0200682:	a4bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200686:	6c0c                	ld	a1,24(s0)
ffffffffc0200688:	00005517          	auipc	a0,0x5
ffffffffc020068c:	be050513          	addi	a0,a0,-1056 # ffffffffc0205268 <commands+0x100>
ffffffffc0200690:	a3dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200694:	700c                	ld	a1,32(s0)
ffffffffc0200696:	00005517          	auipc	a0,0x5
ffffffffc020069a:	bea50513          	addi	a0,a0,-1046 # ffffffffc0205280 <commands+0x118>
ffffffffc020069e:	a2fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006a2:	740c                	ld	a1,40(s0)
ffffffffc02006a4:	00005517          	auipc	a0,0x5
ffffffffc02006a8:	bf450513          	addi	a0,a0,-1036 # ffffffffc0205298 <commands+0x130>
ffffffffc02006ac:	a21ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006b0:	780c                	ld	a1,48(s0)
ffffffffc02006b2:	00005517          	auipc	a0,0x5
ffffffffc02006b6:	bfe50513          	addi	a0,a0,-1026 # ffffffffc02052b0 <commands+0x148>
ffffffffc02006ba:	a13ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006be:	7c0c                	ld	a1,56(s0)
ffffffffc02006c0:	00005517          	auipc	a0,0x5
ffffffffc02006c4:	c0850513          	addi	a0,a0,-1016 # ffffffffc02052c8 <commands+0x160>
ffffffffc02006c8:	a05ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006cc:	602c                	ld	a1,64(s0)
ffffffffc02006ce:	00005517          	auipc	a0,0x5
ffffffffc02006d2:	c1250513          	addi	a0,a0,-1006 # ffffffffc02052e0 <commands+0x178>
ffffffffc02006d6:	9f7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006da:	642c                	ld	a1,72(s0)
ffffffffc02006dc:	00005517          	auipc	a0,0x5
ffffffffc02006e0:	c1c50513          	addi	a0,a0,-996 # ffffffffc02052f8 <commands+0x190>
ffffffffc02006e4:	9e9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006e8:	682c                	ld	a1,80(s0)
ffffffffc02006ea:	00005517          	auipc	a0,0x5
ffffffffc02006ee:	c2650513          	addi	a0,a0,-986 # ffffffffc0205310 <commands+0x1a8>
ffffffffc02006f2:	9dbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006f6:	6c2c                	ld	a1,88(s0)
ffffffffc02006f8:	00005517          	auipc	a0,0x5
ffffffffc02006fc:	c3050513          	addi	a0,a0,-976 # ffffffffc0205328 <commands+0x1c0>
ffffffffc0200700:	9cdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200704:	702c                	ld	a1,96(s0)
ffffffffc0200706:	00005517          	auipc	a0,0x5
ffffffffc020070a:	c3a50513          	addi	a0,a0,-966 # ffffffffc0205340 <commands+0x1d8>
ffffffffc020070e:	9bfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200712:	742c                	ld	a1,104(s0)
ffffffffc0200714:	00005517          	auipc	a0,0x5
ffffffffc0200718:	c4450513          	addi	a0,a0,-956 # ffffffffc0205358 <commands+0x1f0>
ffffffffc020071c:	9b1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200720:	782c                	ld	a1,112(s0)
ffffffffc0200722:	00005517          	auipc	a0,0x5
ffffffffc0200726:	c4e50513          	addi	a0,a0,-946 # ffffffffc0205370 <commands+0x208>
ffffffffc020072a:	9a3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020072e:	7c2c                	ld	a1,120(s0)
ffffffffc0200730:	00005517          	auipc	a0,0x5
ffffffffc0200734:	c5850513          	addi	a0,a0,-936 # ffffffffc0205388 <commands+0x220>
ffffffffc0200738:	995ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020073c:	604c                	ld	a1,128(s0)
ffffffffc020073e:	00005517          	auipc	a0,0x5
ffffffffc0200742:	c6250513          	addi	a0,a0,-926 # ffffffffc02053a0 <commands+0x238>
ffffffffc0200746:	987ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020074a:	644c                	ld	a1,136(s0)
ffffffffc020074c:	00005517          	auipc	a0,0x5
ffffffffc0200750:	c6c50513          	addi	a0,a0,-916 # ffffffffc02053b8 <commands+0x250>
ffffffffc0200754:	979ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200758:	684c                	ld	a1,144(s0)
ffffffffc020075a:	00005517          	auipc	a0,0x5
ffffffffc020075e:	c7650513          	addi	a0,a0,-906 # ffffffffc02053d0 <commands+0x268>
ffffffffc0200762:	96bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200766:	6c4c                	ld	a1,152(s0)
ffffffffc0200768:	00005517          	auipc	a0,0x5
ffffffffc020076c:	c8050513          	addi	a0,a0,-896 # ffffffffc02053e8 <commands+0x280>
ffffffffc0200770:	95dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200774:	704c                	ld	a1,160(s0)
ffffffffc0200776:	00005517          	auipc	a0,0x5
ffffffffc020077a:	c8a50513          	addi	a0,a0,-886 # ffffffffc0205400 <commands+0x298>
ffffffffc020077e:	94fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200782:	744c                	ld	a1,168(s0)
ffffffffc0200784:	00005517          	auipc	a0,0x5
ffffffffc0200788:	c9450513          	addi	a0,a0,-876 # ffffffffc0205418 <commands+0x2b0>
ffffffffc020078c:	941ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200790:	784c                	ld	a1,176(s0)
ffffffffc0200792:	00005517          	auipc	a0,0x5
ffffffffc0200796:	c9e50513          	addi	a0,a0,-866 # ffffffffc0205430 <commands+0x2c8>
ffffffffc020079a:	933ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020079e:	7c4c                	ld	a1,184(s0)
ffffffffc02007a0:	00005517          	auipc	a0,0x5
ffffffffc02007a4:	ca850513          	addi	a0,a0,-856 # ffffffffc0205448 <commands+0x2e0>
ffffffffc02007a8:	925ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007ac:	606c                	ld	a1,192(s0)
ffffffffc02007ae:	00005517          	auipc	a0,0x5
ffffffffc02007b2:	cb250513          	addi	a0,a0,-846 # ffffffffc0205460 <commands+0x2f8>
ffffffffc02007b6:	917ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ba:	646c                	ld	a1,200(s0)
ffffffffc02007bc:	00005517          	auipc	a0,0x5
ffffffffc02007c0:	cbc50513          	addi	a0,a0,-836 # ffffffffc0205478 <commands+0x310>
ffffffffc02007c4:	909ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007c8:	686c                	ld	a1,208(s0)
ffffffffc02007ca:	00005517          	auipc	a0,0x5
ffffffffc02007ce:	cc650513          	addi	a0,a0,-826 # ffffffffc0205490 <commands+0x328>
ffffffffc02007d2:	8fbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007d6:	6c6c                	ld	a1,216(s0)
ffffffffc02007d8:	00005517          	auipc	a0,0x5
ffffffffc02007dc:	cd050513          	addi	a0,a0,-816 # ffffffffc02054a8 <commands+0x340>
ffffffffc02007e0:	8edff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007e4:	706c                	ld	a1,224(s0)
ffffffffc02007e6:	00005517          	auipc	a0,0x5
ffffffffc02007ea:	cda50513          	addi	a0,a0,-806 # ffffffffc02054c0 <commands+0x358>
ffffffffc02007ee:	8dfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007f2:	746c                	ld	a1,232(s0)
ffffffffc02007f4:	00005517          	auipc	a0,0x5
ffffffffc02007f8:	ce450513          	addi	a0,a0,-796 # ffffffffc02054d8 <commands+0x370>
ffffffffc02007fc:	8d1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200800:	786c                	ld	a1,240(s0)
ffffffffc0200802:	00005517          	auipc	a0,0x5
ffffffffc0200806:	cee50513          	addi	a0,a0,-786 # ffffffffc02054f0 <commands+0x388>
ffffffffc020080a:	8c3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200810:	6402                	ld	s0,0(sp)
ffffffffc0200812:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200814:	00005517          	auipc	a0,0x5
ffffffffc0200818:	cf450513          	addi	a0,a0,-780 # ffffffffc0205508 <commands+0x3a0>
}
ffffffffc020081c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081e:	8afff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200822 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200822:	1141                	addi	sp,sp,-16
ffffffffc0200824:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200826:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200828:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020082a:	00005517          	auipc	a0,0x5
ffffffffc020082e:	cf650513          	addi	a0,a0,-778 # ffffffffc0205520 <commands+0x3b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200832:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200834:	899ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200838:	8522                	mv	a0,s0
ffffffffc020083a:	e1bff0ef          	jal	ra,ffffffffc0200654 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020083e:	10043583          	ld	a1,256(s0)
ffffffffc0200842:	00005517          	auipc	a0,0x5
ffffffffc0200846:	cf650513          	addi	a0,a0,-778 # ffffffffc0205538 <commands+0x3d0>
ffffffffc020084a:	883ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020084e:	10843583          	ld	a1,264(s0)
ffffffffc0200852:	00005517          	auipc	a0,0x5
ffffffffc0200856:	cfe50513          	addi	a0,a0,-770 # ffffffffc0205550 <commands+0x3e8>
ffffffffc020085a:	873ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020085e:	11043583          	ld	a1,272(s0)
ffffffffc0200862:	00005517          	auipc	a0,0x5
ffffffffc0200866:	d0650513          	addi	a0,a0,-762 # ffffffffc0205568 <commands+0x400>
ffffffffc020086a:	863ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200872:	6402                	ld	s0,0(sp)
ffffffffc0200874:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200876:	00005517          	auipc	a0,0x5
ffffffffc020087a:	d0a50513          	addi	a0,a0,-758 # ffffffffc0205580 <commands+0x418>
}
ffffffffc020087e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200880:	84dff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200884 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200884:	11853783          	ld	a5,280(a0)
ffffffffc0200888:	472d                	li	a4,11
ffffffffc020088a:	0786                	slli	a5,a5,0x1
ffffffffc020088c:	8385                	srli	a5,a5,0x1
ffffffffc020088e:	06f76c63          	bltu	a4,a5,ffffffffc0200906 <interrupt_handler+0x82>
ffffffffc0200892:	00005717          	auipc	a4,0x5
ffffffffc0200896:	db670713          	addi	a4,a4,-586 # ffffffffc0205648 <commands+0x4e0>
ffffffffc020089a:	078a                	slli	a5,a5,0x2
ffffffffc020089c:	97ba                	add	a5,a5,a4
ffffffffc020089e:	439c                	lw	a5,0(a5)
ffffffffc02008a0:	97ba                	add	a5,a5,a4
ffffffffc02008a2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008a4:	00005517          	auipc	a0,0x5
ffffffffc02008a8:	d5450513          	addi	a0,a0,-684 # ffffffffc02055f8 <commands+0x490>
ffffffffc02008ac:	821ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008b0:	00005517          	auipc	a0,0x5
ffffffffc02008b4:	d2850513          	addi	a0,a0,-728 # ffffffffc02055d8 <commands+0x470>
ffffffffc02008b8:	815ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008bc:	00005517          	auipc	a0,0x5
ffffffffc02008c0:	cdc50513          	addi	a0,a0,-804 # ffffffffc0205598 <commands+0x430>
ffffffffc02008c4:	809ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008c8:	00005517          	auipc	a0,0x5
ffffffffc02008cc:	cf050513          	addi	a0,a0,-784 # ffffffffc02055b8 <commands+0x450>
ffffffffc02008d0:	ffcff06f          	j	ffffffffc02000cc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008d4:	1141                	addi	sp,sp,-16
ffffffffc02008d6:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02008d8:	c59ff0ef          	jal	ra,ffffffffc0200530 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008dc:	00015697          	auipc	a3,0x15
ffffffffc02008e0:	c6468693          	addi	a3,a3,-924 # ffffffffc0215540 <ticks>
ffffffffc02008e4:	629c                	ld	a5,0(a3)
ffffffffc02008e6:	06400713          	li	a4,100
ffffffffc02008ea:	0785                	addi	a5,a5,1
ffffffffc02008ec:	02e7f733          	remu	a4,a5,a4
ffffffffc02008f0:	e29c                	sd	a5,0(a3)
ffffffffc02008f2:	cb19                	beqz	a4,ffffffffc0200908 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008f4:	60a2                	ld	ra,8(sp)
ffffffffc02008f6:	0141                	addi	sp,sp,16
ffffffffc02008f8:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc02008fa:	00005517          	auipc	a0,0x5
ffffffffc02008fe:	d2e50513          	addi	a0,a0,-722 # ffffffffc0205628 <commands+0x4c0>
ffffffffc0200902:	fcaff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc0200906:	bf31                	j	ffffffffc0200822 <print_trapframe>
}
ffffffffc0200908:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020090a:	06400593          	li	a1,100
ffffffffc020090e:	00005517          	auipc	a0,0x5
ffffffffc0200912:	d0a50513          	addi	a0,a0,-758 # ffffffffc0205618 <commands+0x4b0>
}
ffffffffc0200916:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200918:	fb4ff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc020091c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020091c:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200920:	1101                	addi	sp,sp,-32
ffffffffc0200922:	e822                	sd	s0,16(sp)
ffffffffc0200924:	ec06                	sd	ra,24(sp)
ffffffffc0200926:	e426                	sd	s1,8(sp)
ffffffffc0200928:	473d                	li	a4,15
ffffffffc020092a:	842a                	mv	s0,a0
ffffffffc020092c:	14f76a63          	bltu	a4,a5,ffffffffc0200a80 <exception_handler+0x164>
ffffffffc0200930:	00005717          	auipc	a4,0x5
ffffffffc0200934:	f0070713          	addi	a4,a4,-256 # ffffffffc0205830 <commands+0x6c8>
ffffffffc0200938:	078a                	slli	a5,a5,0x2
ffffffffc020093a:	97ba                	add	a5,a5,a4
ffffffffc020093c:	439c                	lw	a5,0(a5)
ffffffffc020093e:	97ba                	add	a5,a5,a4
ffffffffc0200940:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200942:	00005517          	auipc	a0,0x5
ffffffffc0200946:	ed650513          	addi	a0,a0,-298 # ffffffffc0205818 <commands+0x6b0>
ffffffffc020094a:	f82ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020094e:	8522                	mv	a0,s0
ffffffffc0200950:	c7bff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200954:	84aa                	mv	s1,a0
ffffffffc0200956:	12051b63          	bnez	a0,ffffffffc0200a8c <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020095a:	60e2                	ld	ra,24(sp)
ffffffffc020095c:	6442                	ld	s0,16(sp)
ffffffffc020095e:	64a2                	ld	s1,8(sp)
ffffffffc0200960:	6105                	addi	sp,sp,32
ffffffffc0200962:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200964:	00005517          	auipc	a0,0x5
ffffffffc0200968:	d1450513          	addi	a0,a0,-748 # ffffffffc0205678 <commands+0x510>
}
ffffffffc020096c:	6442                	ld	s0,16(sp)
ffffffffc020096e:	60e2                	ld	ra,24(sp)
ffffffffc0200970:	64a2                	ld	s1,8(sp)
ffffffffc0200972:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200974:	f58ff06f          	j	ffffffffc02000cc <cprintf>
ffffffffc0200978:	00005517          	auipc	a0,0x5
ffffffffc020097c:	d2050513          	addi	a0,a0,-736 # ffffffffc0205698 <commands+0x530>
ffffffffc0200980:	b7f5                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200982:	00005517          	auipc	a0,0x5
ffffffffc0200986:	d3650513          	addi	a0,a0,-714 # ffffffffc02056b8 <commands+0x550>
ffffffffc020098a:	b7cd                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc020098c:	00005517          	auipc	a0,0x5
ffffffffc0200990:	d4450513          	addi	a0,a0,-700 # ffffffffc02056d0 <commands+0x568>
ffffffffc0200994:	bfe1                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200996:	00005517          	auipc	a0,0x5
ffffffffc020099a:	d4a50513          	addi	a0,a0,-694 # ffffffffc02056e0 <commands+0x578>
ffffffffc020099e:	b7f9                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02009a0:	00005517          	auipc	a0,0x5
ffffffffc02009a4:	d6050513          	addi	a0,a0,-672 # ffffffffc0205700 <commands+0x598>
ffffffffc02009a8:	f24ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009ac:	8522                	mv	a0,s0
ffffffffc02009ae:	c1dff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc02009b2:	84aa                	mv	s1,a0
ffffffffc02009b4:	d15d                	beqz	a0,ffffffffc020095a <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009b6:	8522                	mv	a0,s0
ffffffffc02009b8:	e6bff0ef          	jal	ra,ffffffffc0200822 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009bc:	86a6                	mv	a3,s1
ffffffffc02009be:	00005617          	auipc	a2,0x5
ffffffffc02009c2:	d5a60613          	addi	a2,a2,-678 # ffffffffc0205718 <commands+0x5b0>
ffffffffc02009c6:	0b300593          	li	a1,179
ffffffffc02009ca:	00005517          	auipc	a0,0x5
ffffffffc02009ce:	83e50513          	addi	a0,a0,-1986 # ffffffffc0205208 <commands+0xa0>
ffffffffc02009d2:	ff6ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009d6:	00005517          	auipc	a0,0x5
ffffffffc02009da:	d6250513          	addi	a0,a0,-670 # ffffffffc0205738 <commands+0x5d0>
ffffffffc02009de:	b779                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009e0:	00005517          	auipc	a0,0x5
ffffffffc02009e4:	d7050513          	addi	a0,a0,-656 # ffffffffc0205750 <commands+0x5e8>
ffffffffc02009e8:	ee4ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009ec:	8522                	mv	a0,s0
ffffffffc02009ee:	bddff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc02009f2:	84aa                	mv	s1,a0
ffffffffc02009f4:	d13d                	beqz	a0,ffffffffc020095a <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009f6:	8522                	mv	a0,s0
ffffffffc02009f8:	e2bff0ef          	jal	ra,ffffffffc0200822 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009fc:	86a6                	mv	a3,s1
ffffffffc02009fe:	00005617          	auipc	a2,0x5
ffffffffc0200a02:	d1a60613          	addi	a2,a2,-742 # ffffffffc0205718 <commands+0x5b0>
ffffffffc0200a06:	0bd00593          	li	a1,189
ffffffffc0200a0a:	00004517          	auipc	a0,0x4
ffffffffc0200a0e:	7fe50513          	addi	a0,a0,2046 # ffffffffc0205208 <commands+0xa0>
ffffffffc0200a12:	fb6ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a16:	00005517          	auipc	a0,0x5
ffffffffc0200a1a:	d5250513          	addi	a0,a0,-686 # ffffffffc0205768 <commands+0x600>
ffffffffc0200a1e:	b7b9                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a20:	00005517          	auipc	a0,0x5
ffffffffc0200a24:	d6850513          	addi	a0,a0,-664 # ffffffffc0205788 <commands+0x620>
ffffffffc0200a28:	b791                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a2a:	00005517          	auipc	a0,0x5
ffffffffc0200a2e:	d7e50513          	addi	a0,a0,-642 # ffffffffc02057a8 <commands+0x640>
ffffffffc0200a32:	bf2d                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	d9450513          	addi	a0,a0,-620 # ffffffffc02057c8 <commands+0x660>
ffffffffc0200a3c:	bf05                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a3e:	00005517          	auipc	a0,0x5
ffffffffc0200a42:	daa50513          	addi	a0,a0,-598 # ffffffffc02057e8 <commands+0x680>
ffffffffc0200a46:	b71d                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a48:	00005517          	auipc	a0,0x5
ffffffffc0200a4c:	db850513          	addi	a0,a0,-584 # ffffffffc0205800 <commands+0x698>
ffffffffc0200a50:	e7cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a54:	8522                	mv	a0,s0
ffffffffc0200a56:	b75ff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200a5a:	84aa                	mv	s1,a0
ffffffffc0200a5c:	ee050fe3          	beqz	a0,ffffffffc020095a <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a60:	8522                	mv	a0,s0
ffffffffc0200a62:	dc1ff0ef          	jal	ra,ffffffffc0200822 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a66:	86a6                	mv	a3,s1
ffffffffc0200a68:	00005617          	auipc	a2,0x5
ffffffffc0200a6c:	cb060613          	addi	a2,a2,-848 # ffffffffc0205718 <commands+0x5b0>
ffffffffc0200a70:	0d300593          	li	a1,211
ffffffffc0200a74:	00004517          	auipc	a0,0x4
ffffffffc0200a78:	79450513          	addi	a0,a0,1940 # ffffffffc0205208 <commands+0xa0>
ffffffffc0200a7c:	f4cff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            print_trapframe(tf);
ffffffffc0200a80:	8522                	mv	a0,s0
}
ffffffffc0200a82:	6442                	ld	s0,16(sp)
ffffffffc0200a84:	60e2                	ld	ra,24(sp)
ffffffffc0200a86:	64a2                	ld	s1,8(sp)
ffffffffc0200a88:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a8a:	bb61                	j	ffffffffc0200822 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a8c:	8522                	mv	a0,s0
ffffffffc0200a8e:	d95ff0ef          	jal	ra,ffffffffc0200822 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a92:	86a6                	mv	a3,s1
ffffffffc0200a94:	00005617          	auipc	a2,0x5
ffffffffc0200a98:	c8460613          	addi	a2,a2,-892 # ffffffffc0205718 <commands+0x5b0>
ffffffffc0200a9c:	0da00593          	li	a1,218
ffffffffc0200aa0:	00004517          	auipc	a0,0x4
ffffffffc0200aa4:	76850513          	addi	a0,a0,1896 # ffffffffc0205208 <commands+0xa0>
ffffffffc0200aa8:	f20ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200aac <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200aac:	11853783          	ld	a5,280(a0)
ffffffffc0200ab0:	0007c363          	bltz	a5,ffffffffc0200ab6 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200ab4:	b5a5                	j	ffffffffc020091c <exception_handler>
        interrupt_handler(tf);
ffffffffc0200ab6:	b3f9                	j	ffffffffc0200884 <interrupt_handler>

ffffffffc0200ab8 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ab8:	14011073          	csrw	sscratch,sp
ffffffffc0200abc:	712d                	addi	sp,sp,-288
ffffffffc0200abe:	e406                	sd	ra,8(sp)
ffffffffc0200ac0:	ec0e                	sd	gp,24(sp)
ffffffffc0200ac2:	f012                	sd	tp,32(sp)
ffffffffc0200ac4:	f416                	sd	t0,40(sp)
ffffffffc0200ac6:	f81a                	sd	t1,48(sp)
ffffffffc0200ac8:	fc1e                	sd	t2,56(sp)
ffffffffc0200aca:	e0a2                	sd	s0,64(sp)
ffffffffc0200acc:	e4a6                	sd	s1,72(sp)
ffffffffc0200ace:	e8aa                	sd	a0,80(sp)
ffffffffc0200ad0:	ecae                	sd	a1,88(sp)
ffffffffc0200ad2:	f0b2                	sd	a2,96(sp)
ffffffffc0200ad4:	f4b6                	sd	a3,104(sp)
ffffffffc0200ad6:	f8ba                	sd	a4,112(sp)
ffffffffc0200ad8:	fcbe                	sd	a5,120(sp)
ffffffffc0200ada:	e142                	sd	a6,128(sp)
ffffffffc0200adc:	e546                	sd	a7,136(sp)
ffffffffc0200ade:	e94a                	sd	s2,144(sp)
ffffffffc0200ae0:	ed4e                	sd	s3,152(sp)
ffffffffc0200ae2:	f152                	sd	s4,160(sp)
ffffffffc0200ae4:	f556                	sd	s5,168(sp)
ffffffffc0200ae6:	f95a                	sd	s6,176(sp)
ffffffffc0200ae8:	fd5e                	sd	s7,184(sp)
ffffffffc0200aea:	e1e2                	sd	s8,192(sp)
ffffffffc0200aec:	e5e6                	sd	s9,200(sp)
ffffffffc0200aee:	e9ea                	sd	s10,208(sp)
ffffffffc0200af0:	edee                	sd	s11,216(sp)
ffffffffc0200af2:	f1f2                	sd	t3,224(sp)
ffffffffc0200af4:	f5f6                	sd	t4,232(sp)
ffffffffc0200af6:	f9fa                	sd	t5,240(sp)
ffffffffc0200af8:	fdfe                	sd	t6,248(sp)
ffffffffc0200afa:	14002473          	csrr	s0,sscratch
ffffffffc0200afe:	100024f3          	csrr	s1,sstatus
ffffffffc0200b02:	14102973          	csrr	s2,sepc
ffffffffc0200b06:	143029f3          	csrr	s3,stval
ffffffffc0200b0a:	14202a73          	csrr	s4,scause
ffffffffc0200b0e:	e822                	sd	s0,16(sp)
ffffffffc0200b10:	e226                	sd	s1,256(sp)
ffffffffc0200b12:	e64a                	sd	s2,264(sp)
ffffffffc0200b14:	ea4e                	sd	s3,272(sp)
ffffffffc0200b16:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b18:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b1a:	f93ff0ef          	jal	ra,ffffffffc0200aac <trap>

ffffffffc0200b1e <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b1e:	6492                	ld	s1,256(sp)
ffffffffc0200b20:	6932                	ld	s2,264(sp)
ffffffffc0200b22:	10049073          	csrw	sstatus,s1
ffffffffc0200b26:	14191073          	csrw	sepc,s2
ffffffffc0200b2a:	60a2                	ld	ra,8(sp)
ffffffffc0200b2c:	61e2                	ld	gp,24(sp)
ffffffffc0200b2e:	7202                	ld	tp,32(sp)
ffffffffc0200b30:	72a2                	ld	t0,40(sp)
ffffffffc0200b32:	7342                	ld	t1,48(sp)
ffffffffc0200b34:	73e2                	ld	t2,56(sp)
ffffffffc0200b36:	6406                	ld	s0,64(sp)
ffffffffc0200b38:	64a6                	ld	s1,72(sp)
ffffffffc0200b3a:	6546                	ld	a0,80(sp)
ffffffffc0200b3c:	65e6                	ld	a1,88(sp)
ffffffffc0200b3e:	7606                	ld	a2,96(sp)
ffffffffc0200b40:	76a6                	ld	a3,104(sp)
ffffffffc0200b42:	7746                	ld	a4,112(sp)
ffffffffc0200b44:	77e6                	ld	a5,120(sp)
ffffffffc0200b46:	680a                	ld	a6,128(sp)
ffffffffc0200b48:	68aa                	ld	a7,136(sp)
ffffffffc0200b4a:	694a                	ld	s2,144(sp)
ffffffffc0200b4c:	69ea                	ld	s3,152(sp)
ffffffffc0200b4e:	7a0a                	ld	s4,160(sp)
ffffffffc0200b50:	7aaa                	ld	s5,168(sp)
ffffffffc0200b52:	7b4a                	ld	s6,176(sp)
ffffffffc0200b54:	7bea                	ld	s7,184(sp)
ffffffffc0200b56:	6c0e                	ld	s8,192(sp)
ffffffffc0200b58:	6cae                	ld	s9,200(sp)
ffffffffc0200b5a:	6d4e                	ld	s10,208(sp)
ffffffffc0200b5c:	6dee                	ld	s11,216(sp)
ffffffffc0200b5e:	7e0e                	ld	t3,224(sp)
ffffffffc0200b60:	7eae                	ld	t4,232(sp)
ffffffffc0200b62:	7f4e                	ld	t5,240(sp)
ffffffffc0200b64:	7fee                	ld	t6,248(sp)
ffffffffc0200b66:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b68:	10200073          	sret

ffffffffc0200b6c <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b6c:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b6e:	bf45                	j	ffffffffc0200b1e <__trapret>
	...

ffffffffc0200b72 <pa2page.part.0>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200b72:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200b74:	00005617          	auipc	a2,0x5
ffffffffc0200b78:	cfc60613          	addi	a2,a2,-772 # ffffffffc0205870 <commands+0x708>
ffffffffc0200b7c:	06200593          	li	a1,98
ffffffffc0200b80:	00005517          	auipc	a0,0x5
ffffffffc0200b84:	d1050513          	addi	a0,a0,-752 # ffffffffc0205890 <commands+0x728>
pa2page(uintptr_t pa) {
ffffffffc0200b88:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200b8a:	e3eff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200b8e <pte2page.part.0>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
ffffffffc0200b8e:	1141                	addi	sp,sp,-16
    if (!(pte & PTE_V)) {
        panic("pte2page called with invalid pte");
ffffffffc0200b90:	00005617          	auipc	a2,0x5
ffffffffc0200b94:	d1060613          	addi	a2,a2,-752 # ffffffffc02058a0 <commands+0x738>
ffffffffc0200b98:	07400593          	li	a1,116
ffffffffc0200b9c:	00005517          	auipc	a0,0x5
ffffffffc0200ba0:	cf450513          	addi	a0,a0,-780 # ffffffffc0205890 <commands+0x728>
pte2page(pte_t pte) {
ffffffffc0200ba4:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0200ba6:	e22ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200baa <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200baa:	7139                	addi	sp,sp,-64
ffffffffc0200bac:	f426                	sd	s1,40(sp)
ffffffffc0200bae:	f04a                	sd	s2,32(sp)
ffffffffc0200bb0:	ec4e                	sd	s3,24(sp)
ffffffffc0200bb2:	e852                	sd	s4,16(sp)
ffffffffc0200bb4:	e456                	sd	s5,8(sp)
ffffffffc0200bb6:	e05a                	sd	s6,0(sp)
ffffffffc0200bb8:	fc06                	sd	ra,56(sp)
ffffffffc0200bba:	f822                	sd	s0,48(sp)
ffffffffc0200bbc:	84aa                	mv	s1,a0
ffffffffc0200bbe:	00015917          	auipc	s2,0x15
ffffffffc0200bc2:	9b290913          	addi	s2,s2,-1614 # ffffffffc0215570 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200bc6:	4a05                	li	s4,1
ffffffffc0200bc8:	00015a97          	auipc	s5,0x15
ffffffffc0200bcc:	9e0a8a93          	addi	s5,s5,-1568 # ffffffffc02155a8 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bd0:	0005099b          	sext.w	s3,a0
ffffffffc0200bd4:	00015b17          	auipc	s6,0x15
ffffffffc0200bd8:	9acb0b13          	addi	s6,s6,-1620 # ffffffffc0215580 <check_mm_struct>
ffffffffc0200bdc:	a01d                	j	ffffffffc0200c02 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200bde:	00093783          	ld	a5,0(s2)
ffffffffc0200be2:	6f9c                	ld	a5,24(a5)
ffffffffc0200be4:	9782                	jalr	a5
ffffffffc0200be6:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0200be8:	4601                	li	a2,0
ffffffffc0200bea:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200bec:	ec0d                	bnez	s0,ffffffffc0200c26 <alloc_pages+0x7c>
ffffffffc0200bee:	029a6c63          	bltu	s4,s1,ffffffffc0200c26 <alloc_pages+0x7c>
ffffffffc0200bf2:	000aa783          	lw	a5,0(s5)
ffffffffc0200bf6:	2781                	sext.w	a5,a5
ffffffffc0200bf8:	c79d                	beqz	a5,ffffffffc0200c26 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bfa:	000b3503          	ld	a0,0(s6)
ffffffffc0200bfe:	089020ef          	jal	ra,ffffffffc0203486 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c02:	100027f3          	csrr	a5,sstatus
ffffffffc0200c06:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200c08:	8526                	mv	a0,s1
ffffffffc0200c0a:	dbf1                	beqz	a5,ffffffffc0200bde <alloc_pages+0x34>
        intr_disable();
ffffffffc0200c0c:	9b9ff0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0200c10:	00093783          	ld	a5,0(s2)
ffffffffc0200c14:	8526                	mv	a0,s1
ffffffffc0200c16:	6f9c                	ld	a5,24(a5)
ffffffffc0200c18:	9782                	jalr	a5
ffffffffc0200c1a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200c1c:	9a3ff0ef          	jal	ra,ffffffffc02005be <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200c20:	4601                	li	a2,0
ffffffffc0200c22:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200c24:	d469                	beqz	s0,ffffffffc0200bee <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200c26:	70e2                	ld	ra,56(sp)
ffffffffc0200c28:	8522                	mv	a0,s0
ffffffffc0200c2a:	7442                	ld	s0,48(sp)
ffffffffc0200c2c:	74a2                	ld	s1,40(sp)
ffffffffc0200c2e:	7902                	ld	s2,32(sp)
ffffffffc0200c30:	69e2                	ld	s3,24(sp)
ffffffffc0200c32:	6a42                	ld	s4,16(sp)
ffffffffc0200c34:	6aa2                	ld	s5,8(sp)
ffffffffc0200c36:	6b02                	ld	s6,0(sp)
ffffffffc0200c38:	6121                	addi	sp,sp,64
ffffffffc0200c3a:	8082                	ret

ffffffffc0200c3c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c3c:	100027f3          	csrr	a5,sstatus
ffffffffc0200c40:	8b89                	andi	a5,a5,2
ffffffffc0200c42:	e799                	bnez	a5,ffffffffc0200c50 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200c44:	00015797          	auipc	a5,0x15
ffffffffc0200c48:	92c7b783          	ld	a5,-1748(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0200c4c:	739c                	ld	a5,32(a5)
ffffffffc0200c4e:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200c50:	1101                	addi	sp,sp,-32
ffffffffc0200c52:	ec06                	sd	ra,24(sp)
ffffffffc0200c54:	e822                	sd	s0,16(sp)
ffffffffc0200c56:	e426                	sd	s1,8(sp)
ffffffffc0200c58:	842a                	mv	s0,a0
ffffffffc0200c5a:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200c5c:	969ff0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200c60:	00015797          	auipc	a5,0x15
ffffffffc0200c64:	9107b783          	ld	a5,-1776(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0200c68:	739c                	ld	a5,32(a5)
ffffffffc0200c6a:	85a6                	mv	a1,s1
ffffffffc0200c6c:	8522                	mv	a0,s0
ffffffffc0200c6e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200c70:	6442                	ld	s0,16(sp)
ffffffffc0200c72:	60e2                	ld	ra,24(sp)
ffffffffc0200c74:	64a2                	ld	s1,8(sp)
ffffffffc0200c76:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200c78:	947ff06f          	j	ffffffffc02005be <intr_enable>

ffffffffc0200c7c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c7c:	100027f3          	csrr	a5,sstatus
ffffffffc0200c80:	8b89                	andi	a5,a5,2
ffffffffc0200c82:	e799                	bnez	a5,ffffffffc0200c90 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200c84:	00015797          	auipc	a5,0x15
ffffffffc0200c88:	8ec7b783          	ld	a5,-1812(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0200c8c:	779c                	ld	a5,40(a5)
ffffffffc0200c8e:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200c90:	1141                	addi	sp,sp,-16
ffffffffc0200c92:	e406                	sd	ra,8(sp)
ffffffffc0200c94:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200c96:	92fff0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200c9a:	00015797          	auipc	a5,0x15
ffffffffc0200c9e:	8d67b783          	ld	a5,-1834(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0200ca2:	779c                	ld	a5,40(a5)
ffffffffc0200ca4:	9782                	jalr	a5
ffffffffc0200ca6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200ca8:	917ff0ef          	jal	ra,ffffffffc02005be <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200cac:	60a2                	ld	ra,8(sp)
ffffffffc0200cae:	8522                	mv	a0,s0
ffffffffc0200cb0:	6402                	ld	s0,0(sp)
ffffffffc0200cb2:	0141                	addi	sp,sp,16
ffffffffc0200cb4:	8082                	ret

ffffffffc0200cb6 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200cb6:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0200cba:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200cbe:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200cc0:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200cc2:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200cc4:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200cc8:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200cca:	f04a                	sd	s2,32(sp)
ffffffffc0200ccc:	ec4e                	sd	s3,24(sp)
ffffffffc0200cce:	e852                	sd	s4,16(sp)
ffffffffc0200cd0:	fc06                	sd	ra,56(sp)
ffffffffc0200cd2:	f822                	sd	s0,48(sp)
ffffffffc0200cd4:	e456                	sd	s5,8(sp)
ffffffffc0200cd6:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200cd8:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200cdc:	892e                	mv	s2,a1
ffffffffc0200cde:	89b2                	mv	s3,a2
ffffffffc0200ce0:	00015a17          	auipc	s4,0x15
ffffffffc0200ce4:	880a0a13          	addi	s4,s4,-1920 # ffffffffc0215560 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200ce8:	e7b5                	bnez	a5,ffffffffc0200d54 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200cea:	12060b63          	beqz	a2,ffffffffc0200e20 <get_pte+0x16a>
ffffffffc0200cee:	4505                	li	a0,1
ffffffffc0200cf0:	ebbff0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0200cf4:	842a                	mv	s0,a0
ffffffffc0200cf6:	12050563          	beqz	a0,ffffffffc0200e20 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200cfa:	00015b17          	auipc	s6,0x15
ffffffffc0200cfe:	86eb0b13          	addi	s6,s6,-1938 # ffffffffc0215568 <pages>
ffffffffc0200d02:	000b3503          	ld	a0,0(s6)
ffffffffc0200d06:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200d0a:	00015a17          	auipc	s4,0x15
ffffffffc0200d0e:	856a0a13          	addi	s4,s4,-1962 # ffffffffc0215560 <npage>
ffffffffc0200d12:	40a40533          	sub	a0,s0,a0
ffffffffc0200d16:	8519                	srai	a0,a0,0x6
ffffffffc0200d18:	9556                	add	a0,a0,s5
ffffffffc0200d1a:	000a3703          	ld	a4,0(s4)
ffffffffc0200d1e:	00c51793          	slli	a5,a0,0xc
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200d22:	4685                	li	a3,1
ffffffffc0200d24:	c014                	sw	a3,0(s0)
ffffffffc0200d26:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d28:	0532                	slli	a0,a0,0xc
ffffffffc0200d2a:	14e7f263          	bgeu	a5,a4,ffffffffc0200e6e <get_pte+0x1b8>
ffffffffc0200d2e:	00015797          	auipc	a5,0x15
ffffffffc0200d32:	84a7b783          	ld	a5,-1974(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc0200d36:	6605                	lui	a2,0x1
ffffffffc0200d38:	4581                	li	a1,0
ffffffffc0200d3a:	953e                	add	a0,a0,a5
ffffffffc0200d3c:	553030ef          	jal	ra,ffffffffc0204a8e <memset>
    return page - pages + nbase;
ffffffffc0200d40:	000b3683          	ld	a3,0(s6)
ffffffffc0200d44:	40d406b3          	sub	a3,s0,a3
ffffffffc0200d48:	8699                	srai	a3,a3,0x6
ffffffffc0200d4a:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200d4c:	06aa                	slli	a3,a3,0xa
ffffffffc0200d4e:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200d52:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200d54:	77fd                	lui	a5,0xfffff
ffffffffc0200d56:	068a                	slli	a3,a3,0x2
ffffffffc0200d58:	000a3703          	ld	a4,0(s4)
ffffffffc0200d5c:	8efd                	and	a3,a3,a5
ffffffffc0200d5e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200d62:	0ce7f163          	bgeu	a5,a4,ffffffffc0200e24 <get_pte+0x16e>
ffffffffc0200d66:	00015a97          	auipc	s5,0x15
ffffffffc0200d6a:	812a8a93          	addi	s5,s5,-2030 # ffffffffc0215578 <va_pa_offset>
ffffffffc0200d6e:	000ab403          	ld	s0,0(s5)
ffffffffc0200d72:	01595793          	srli	a5,s2,0x15
ffffffffc0200d76:	1ff7f793          	andi	a5,a5,511
ffffffffc0200d7a:	96a2                	add	a3,a3,s0
ffffffffc0200d7c:	00379413          	slli	s0,a5,0x3
ffffffffc0200d80:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0200d82:	6014                	ld	a3,0(s0)
ffffffffc0200d84:	0016f793          	andi	a5,a3,1
ffffffffc0200d88:	e3ad                	bnez	a5,ffffffffc0200dea <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200d8a:	08098b63          	beqz	s3,ffffffffc0200e20 <get_pte+0x16a>
ffffffffc0200d8e:	4505                	li	a0,1
ffffffffc0200d90:	e1bff0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0200d94:	84aa                	mv	s1,a0
ffffffffc0200d96:	c549                	beqz	a0,ffffffffc0200e20 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200d98:	00014b17          	auipc	s6,0x14
ffffffffc0200d9c:	7d0b0b13          	addi	s6,s6,2000 # ffffffffc0215568 <pages>
ffffffffc0200da0:	000b3503          	ld	a0,0(s6)
ffffffffc0200da4:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200da8:	000a3703          	ld	a4,0(s4)
ffffffffc0200dac:	40a48533          	sub	a0,s1,a0
ffffffffc0200db0:	8519                	srai	a0,a0,0x6
ffffffffc0200db2:	954e                	add	a0,a0,s3
ffffffffc0200db4:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0200db8:	4685                	li	a3,1
ffffffffc0200dba:	c094                	sw	a3,0(s1)
ffffffffc0200dbc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200dbe:	0532                	slli	a0,a0,0xc
ffffffffc0200dc0:	08e7fa63          	bgeu	a5,a4,ffffffffc0200e54 <get_pte+0x19e>
ffffffffc0200dc4:	000ab783          	ld	a5,0(s5)
ffffffffc0200dc8:	6605                	lui	a2,0x1
ffffffffc0200dca:	4581                	li	a1,0
ffffffffc0200dcc:	953e                	add	a0,a0,a5
ffffffffc0200dce:	4c1030ef          	jal	ra,ffffffffc0204a8e <memset>
    return page - pages + nbase;
ffffffffc0200dd2:	000b3683          	ld	a3,0(s6)
ffffffffc0200dd6:	40d486b3          	sub	a3,s1,a3
ffffffffc0200dda:	8699                	srai	a3,a3,0x6
ffffffffc0200ddc:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200dde:	06aa                	slli	a3,a3,0xa
ffffffffc0200de0:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200de4:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200de6:	000a3703          	ld	a4,0(s4)
ffffffffc0200dea:	068a                	slli	a3,a3,0x2
ffffffffc0200dec:	757d                	lui	a0,0xfffff
ffffffffc0200dee:	8ee9                	and	a3,a3,a0
ffffffffc0200df0:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200df4:	04e7f463          	bgeu	a5,a4,ffffffffc0200e3c <get_pte+0x186>
ffffffffc0200df8:	000ab503          	ld	a0,0(s5)
ffffffffc0200dfc:	00c95913          	srli	s2,s2,0xc
ffffffffc0200e00:	1ff97913          	andi	s2,s2,511
ffffffffc0200e04:	96aa                	add	a3,a3,a0
ffffffffc0200e06:	00391513          	slli	a0,s2,0x3
ffffffffc0200e0a:	9536                	add	a0,a0,a3
}
ffffffffc0200e0c:	70e2                	ld	ra,56(sp)
ffffffffc0200e0e:	7442                	ld	s0,48(sp)
ffffffffc0200e10:	74a2                	ld	s1,40(sp)
ffffffffc0200e12:	7902                	ld	s2,32(sp)
ffffffffc0200e14:	69e2                	ld	s3,24(sp)
ffffffffc0200e16:	6a42                	ld	s4,16(sp)
ffffffffc0200e18:	6aa2                	ld	s5,8(sp)
ffffffffc0200e1a:	6b02                	ld	s6,0(sp)
ffffffffc0200e1c:	6121                	addi	sp,sp,64
ffffffffc0200e1e:	8082                	ret
            return NULL;
ffffffffc0200e20:	4501                	li	a0,0
ffffffffc0200e22:	b7ed                	j	ffffffffc0200e0c <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200e24:	00005617          	auipc	a2,0x5
ffffffffc0200e28:	aa460613          	addi	a2,a2,-1372 # ffffffffc02058c8 <commands+0x760>
ffffffffc0200e2c:	0e400593          	li	a1,228
ffffffffc0200e30:	00005517          	auipc	a0,0x5
ffffffffc0200e34:	ac050513          	addi	a0,a0,-1344 # ffffffffc02058f0 <commands+0x788>
ffffffffc0200e38:	b90ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200e3c:	00005617          	auipc	a2,0x5
ffffffffc0200e40:	a8c60613          	addi	a2,a2,-1396 # ffffffffc02058c8 <commands+0x760>
ffffffffc0200e44:	0ef00593          	li	a1,239
ffffffffc0200e48:	00005517          	auipc	a0,0x5
ffffffffc0200e4c:	aa850513          	addi	a0,a0,-1368 # ffffffffc02058f0 <commands+0x788>
ffffffffc0200e50:	b78ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200e54:	86aa                	mv	a3,a0
ffffffffc0200e56:	00005617          	auipc	a2,0x5
ffffffffc0200e5a:	a7260613          	addi	a2,a2,-1422 # ffffffffc02058c8 <commands+0x760>
ffffffffc0200e5e:	0ec00593          	li	a1,236
ffffffffc0200e62:	00005517          	auipc	a0,0x5
ffffffffc0200e66:	a8e50513          	addi	a0,a0,-1394 # ffffffffc02058f0 <commands+0x788>
ffffffffc0200e6a:	b5eff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200e6e:	86aa                	mv	a3,a0
ffffffffc0200e70:	00005617          	auipc	a2,0x5
ffffffffc0200e74:	a5860613          	addi	a2,a2,-1448 # ffffffffc02058c8 <commands+0x760>
ffffffffc0200e78:	0e100593          	li	a1,225
ffffffffc0200e7c:	00005517          	auipc	a0,0x5
ffffffffc0200e80:	a7450513          	addi	a0,a0,-1420 # ffffffffc02058f0 <commands+0x788>
ffffffffc0200e84:	b44ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200e88 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200e88:	1141                	addi	sp,sp,-16
ffffffffc0200e8a:	e022                	sd	s0,0(sp)
ffffffffc0200e8c:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e8e:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200e90:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e92:	e25ff0ef          	jal	ra,ffffffffc0200cb6 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0200e96:	c011                	beqz	s0,ffffffffc0200e9a <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0200e98:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e9a:	c511                	beqz	a0,ffffffffc0200ea6 <get_page+0x1e>
ffffffffc0200e9c:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0200e9e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200ea0:	0017f713          	andi	a4,a5,1
ffffffffc0200ea4:	e709                	bnez	a4,ffffffffc0200eae <get_page+0x26>
}
ffffffffc0200ea6:	60a2                	ld	ra,8(sp)
ffffffffc0200ea8:	6402                	ld	s0,0(sp)
ffffffffc0200eaa:	0141                	addi	sp,sp,16
ffffffffc0200eac:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0200eae:	078a                	slli	a5,a5,0x2
ffffffffc0200eb0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200eb2:	00014717          	auipc	a4,0x14
ffffffffc0200eb6:	6ae73703          	ld	a4,1710(a4) # ffffffffc0215560 <npage>
ffffffffc0200eba:	00e7ff63          	bgeu	a5,a4,ffffffffc0200ed8 <get_page+0x50>
ffffffffc0200ebe:	60a2                	ld	ra,8(sp)
ffffffffc0200ec0:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0200ec2:	fff80537          	lui	a0,0xfff80
ffffffffc0200ec6:	97aa                	add	a5,a5,a0
ffffffffc0200ec8:	079a                	slli	a5,a5,0x6
ffffffffc0200eca:	00014517          	auipc	a0,0x14
ffffffffc0200ece:	69e53503          	ld	a0,1694(a0) # ffffffffc0215568 <pages>
ffffffffc0200ed2:	953e                	add	a0,a0,a5
ffffffffc0200ed4:	0141                	addi	sp,sp,16
ffffffffc0200ed6:	8082                	ret
ffffffffc0200ed8:	c9bff0ef          	jal	ra,ffffffffc0200b72 <pa2page.part.0>

ffffffffc0200edc <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200edc:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200ede:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200ee0:	ec26                	sd	s1,24(sp)
ffffffffc0200ee2:	f406                	sd	ra,40(sp)
ffffffffc0200ee4:	f022                	sd	s0,32(sp)
ffffffffc0200ee6:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200ee8:	dcfff0ef          	jal	ra,ffffffffc0200cb6 <get_pte>
    if (ptep != NULL) {
ffffffffc0200eec:	c511                	beqz	a0,ffffffffc0200ef8 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0200eee:	611c                	ld	a5,0(a0)
ffffffffc0200ef0:	842a                	mv	s0,a0
ffffffffc0200ef2:	0017f713          	andi	a4,a5,1
ffffffffc0200ef6:	e711                	bnez	a4,ffffffffc0200f02 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0200ef8:	70a2                	ld	ra,40(sp)
ffffffffc0200efa:	7402                	ld	s0,32(sp)
ffffffffc0200efc:	64e2                	ld	s1,24(sp)
ffffffffc0200efe:	6145                	addi	sp,sp,48
ffffffffc0200f00:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0200f02:	078a                	slli	a5,a5,0x2
ffffffffc0200f04:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f06:	00014717          	auipc	a4,0x14
ffffffffc0200f0a:	65a73703          	ld	a4,1626(a4) # ffffffffc0215560 <npage>
ffffffffc0200f0e:	06e7f363          	bgeu	a5,a4,ffffffffc0200f74 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f12:	fff80537          	lui	a0,0xfff80
ffffffffc0200f16:	97aa                	add	a5,a5,a0
ffffffffc0200f18:	079a                	slli	a5,a5,0x6
ffffffffc0200f1a:	00014517          	auipc	a0,0x14
ffffffffc0200f1e:	64e53503          	ld	a0,1614(a0) # ffffffffc0215568 <pages>
ffffffffc0200f22:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0200f24:	411c                	lw	a5,0(a0)
ffffffffc0200f26:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200f2a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200f2c:	cb11                	beqz	a4,ffffffffc0200f40 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200f2e:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200f32:	12048073          	sfence.vma	s1
}
ffffffffc0200f36:	70a2                	ld	ra,40(sp)
ffffffffc0200f38:	7402                	ld	s0,32(sp)
ffffffffc0200f3a:	64e2                	ld	s1,24(sp)
ffffffffc0200f3c:	6145                	addi	sp,sp,48
ffffffffc0200f3e:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f40:	100027f3          	csrr	a5,sstatus
ffffffffc0200f44:	8b89                	andi	a5,a5,2
ffffffffc0200f46:	eb89                	bnez	a5,ffffffffc0200f58 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0200f48:	00014797          	auipc	a5,0x14
ffffffffc0200f4c:	6287b783          	ld	a5,1576(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0200f50:	739c                	ld	a5,32(a5)
ffffffffc0200f52:	4585                	li	a1,1
ffffffffc0200f54:	9782                	jalr	a5
    if (flag) {
ffffffffc0200f56:	bfe1                	j	ffffffffc0200f2e <page_remove+0x52>
        intr_disable();
ffffffffc0200f58:	e42a                	sd	a0,8(sp)
ffffffffc0200f5a:	e6aff0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0200f5e:	00014797          	auipc	a5,0x14
ffffffffc0200f62:	6127b783          	ld	a5,1554(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0200f66:	739c                	ld	a5,32(a5)
ffffffffc0200f68:	6522                	ld	a0,8(sp)
ffffffffc0200f6a:	4585                	li	a1,1
ffffffffc0200f6c:	9782                	jalr	a5
        intr_enable();
ffffffffc0200f6e:	e50ff0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0200f72:	bf75                	j	ffffffffc0200f2e <page_remove+0x52>
ffffffffc0200f74:	bffff0ef          	jal	ra,ffffffffc0200b72 <pa2page.part.0>

ffffffffc0200f78 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f78:	7139                	addi	sp,sp,-64
ffffffffc0200f7a:	e852                	sd	s4,16(sp)
ffffffffc0200f7c:	8a32                	mv	s4,a2
ffffffffc0200f7e:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f80:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f82:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f84:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f86:	f426                	sd	s1,40(sp)
ffffffffc0200f88:	fc06                	sd	ra,56(sp)
ffffffffc0200f8a:	f04a                	sd	s2,32(sp)
ffffffffc0200f8c:	ec4e                	sd	s3,24(sp)
ffffffffc0200f8e:	e456                	sd	s5,8(sp)
ffffffffc0200f90:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f92:	d25ff0ef          	jal	ra,ffffffffc0200cb6 <get_pte>
    if (ptep == NULL) {
ffffffffc0200f96:	c961                	beqz	a0,ffffffffc0201066 <page_insert+0xee>
    page->ref += 1;
ffffffffc0200f98:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0200f9a:	611c                	ld	a5,0(a0)
ffffffffc0200f9c:	89aa                	mv	s3,a0
ffffffffc0200f9e:	0016871b          	addiw	a4,a3,1
ffffffffc0200fa2:	c018                	sw	a4,0(s0)
ffffffffc0200fa4:	0017f713          	andi	a4,a5,1
ffffffffc0200fa8:	ef05                	bnez	a4,ffffffffc0200fe0 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0200faa:	00014717          	auipc	a4,0x14
ffffffffc0200fae:	5be73703          	ld	a4,1470(a4) # ffffffffc0215568 <pages>
ffffffffc0200fb2:	8c19                	sub	s0,s0,a4
ffffffffc0200fb4:	000807b7          	lui	a5,0x80
ffffffffc0200fb8:	8419                	srai	s0,s0,0x6
ffffffffc0200fba:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200fbc:	042a                	slli	s0,s0,0xa
ffffffffc0200fbe:	8cc1                	or	s1,s1,s0
ffffffffc0200fc0:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0200fc4:	0099b023          	sd	s1,0(s3) # 80000 <kern_entry-0xffffffffc0180000>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200fc8:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0200fcc:	4501                	li	a0,0
}
ffffffffc0200fce:	70e2                	ld	ra,56(sp)
ffffffffc0200fd0:	7442                	ld	s0,48(sp)
ffffffffc0200fd2:	74a2                	ld	s1,40(sp)
ffffffffc0200fd4:	7902                	ld	s2,32(sp)
ffffffffc0200fd6:	69e2                	ld	s3,24(sp)
ffffffffc0200fd8:	6a42                	ld	s4,16(sp)
ffffffffc0200fda:	6aa2                	ld	s5,8(sp)
ffffffffc0200fdc:	6121                	addi	sp,sp,64
ffffffffc0200fde:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0200fe0:	078a                	slli	a5,a5,0x2
ffffffffc0200fe2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200fe4:	00014717          	auipc	a4,0x14
ffffffffc0200fe8:	57c73703          	ld	a4,1404(a4) # ffffffffc0215560 <npage>
ffffffffc0200fec:	06e7ff63          	bgeu	a5,a4,ffffffffc020106a <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0200ff0:	00014a97          	auipc	s5,0x14
ffffffffc0200ff4:	578a8a93          	addi	s5,s5,1400 # ffffffffc0215568 <pages>
ffffffffc0200ff8:	000ab703          	ld	a4,0(s5)
ffffffffc0200ffc:	fff80937          	lui	s2,0xfff80
ffffffffc0201000:	993e                	add	s2,s2,a5
ffffffffc0201002:	091a                	slli	s2,s2,0x6
ffffffffc0201004:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0201006:	01240c63          	beq	s0,s2,ffffffffc020101e <page_insert+0xa6>
    page->ref -= 1;
ffffffffc020100a:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd6aa34>
ffffffffc020100e:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201012:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0201016:	c691                	beqz	a3,ffffffffc0201022 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201018:	120a0073          	sfence.vma	s4
}
ffffffffc020101c:	bf59                	j	ffffffffc0200fb2 <page_insert+0x3a>
ffffffffc020101e:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201020:	bf49                	j	ffffffffc0200fb2 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201022:	100027f3          	csrr	a5,sstatus
ffffffffc0201026:	8b89                	andi	a5,a5,2
ffffffffc0201028:	ef91                	bnez	a5,ffffffffc0201044 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc020102a:	00014797          	auipc	a5,0x14
ffffffffc020102e:	5467b783          	ld	a5,1350(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201032:	739c                	ld	a5,32(a5)
ffffffffc0201034:	4585                	li	a1,1
ffffffffc0201036:	854a                	mv	a0,s2
ffffffffc0201038:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020103a:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020103e:	120a0073          	sfence.vma	s4
ffffffffc0201042:	bf85                	j	ffffffffc0200fb2 <page_insert+0x3a>
        intr_disable();
ffffffffc0201044:	d80ff0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201048:	00014797          	auipc	a5,0x14
ffffffffc020104c:	5287b783          	ld	a5,1320(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201050:	739c                	ld	a5,32(a5)
ffffffffc0201052:	4585                	li	a1,1
ffffffffc0201054:	854a                	mv	a0,s2
ffffffffc0201056:	9782                	jalr	a5
        intr_enable();
ffffffffc0201058:	d66ff0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc020105c:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201060:	120a0073          	sfence.vma	s4
ffffffffc0201064:	b7b9                	j	ffffffffc0200fb2 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201066:	5571                	li	a0,-4
ffffffffc0201068:	b79d                	j	ffffffffc0200fce <page_insert+0x56>
ffffffffc020106a:	b09ff0ef          	jal	ra,ffffffffc0200b72 <pa2page.part.0>

ffffffffc020106e <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020106e:	00006797          	auipc	a5,0x6
ffffffffc0201072:	aca78793          	addi	a5,a5,-1334 # ffffffffc0206b38 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201076:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201078:	711d                	addi	sp,sp,-96
ffffffffc020107a:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020107c:	00005517          	auipc	a0,0x5
ffffffffc0201080:	88450513          	addi	a0,a0,-1916 # ffffffffc0205900 <commands+0x798>
    pmm_manager = &default_pmm_manager;
ffffffffc0201084:	00014b97          	auipc	s7,0x14
ffffffffc0201088:	4ecb8b93          	addi	s7,s7,1260 # ffffffffc0215570 <pmm_manager>
void pmm_init(void) {
ffffffffc020108c:	ec86                	sd	ra,88(sp)
ffffffffc020108e:	e4a6                	sd	s1,72(sp)
ffffffffc0201090:	fc4e                	sd	s3,56(sp)
ffffffffc0201092:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201094:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201098:	e8a2                	sd	s0,80(sp)
ffffffffc020109a:	e0ca                	sd	s2,64(sp)
ffffffffc020109c:	f852                	sd	s4,48(sp)
ffffffffc020109e:	f456                	sd	s5,40(sp)
ffffffffc02010a0:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02010a2:	82aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc02010a6:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02010aa:	00014997          	auipc	s3,0x14
ffffffffc02010ae:	4ce98993          	addi	s3,s3,1230 # ffffffffc0215578 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc02010b2:	00014497          	auipc	s1,0x14
ffffffffc02010b6:	4ae48493          	addi	s1,s1,1198 # ffffffffc0215560 <npage>
    pmm_manager->init();
ffffffffc02010ba:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010bc:	00014b17          	auipc	s6,0x14
ffffffffc02010c0:	4acb0b13          	addi	s6,s6,1196 # ffffffffc0215568 <pages>
    pmm_manager->init();
ffffffffc02010c4:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02010c6:	57f5                	li	a5,-3
ffffffffc02010c8:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02010ca:	00005517          	auipc	a0,0x5
ffffffffc02010ce:	84e50513          	addi	a0,a0,-1970 # ffffffffc0205918 <commands+0x7b0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02010d2:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc02010d6:	ff7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02010da:	46c5                	li	a3,17
ffffffffc02010dc:	06ee                	slli	a3,a3,0x1b
ffffffffc02010de:	40100613          	li	a2,1025
ffffffffc02010e2:	07e005b7          	lui	a1,0x7e00
ffffffffc02010e6:	16fd                	addi	a3,a3,-1
ffffffffc02010e8:	0656                	slli	a2,a2,0x15
ffffffffc02010ea:	00005517          	auipc	a0,0x5
ffffffffc02010ee:	84650513          	addi	a0,a0,-1978 # ffffffffc0205930 <commands+0x7c8>
ffffffffc02010f2:	fdbfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010f6:	777d                	lui	a4,0xfffff
ffffffffc02010f8:	00015797          	auipc	a5,0x15
ffffffffc02010fc:	4d378793          	addi	a5,a5,1235 # ffffffffc02165cb <end+0xfff>
ffffffffc0201100:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201102:	00088737          	lui	a4,0x88
ffffffffc0201106:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201108:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020110c:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020110e:	4585                	li	a1,1
ffffffffc0201110:	fff80837          	lui	a6,0xfff80
ffffffffc0201114:	a019                	j	ffffffffc020111a <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0201116:	000b3783          	ld	a5,0(s6)
ffffffffc020111a:	00671693          	slli	a3,a4,0x6
ffffffffc020111e:	97b6                	add	a5,a5,a3
ffffffffc0201120:	07a1                	addi	a5,a5,8
ffffffffc0201122:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201126:	6090                	ld	a2,0(s1)
ffffffffc0201128:	0705                	addi	a4,a4,1
ffffffffc020112a:	010607b3          	add	a5,a2,a6
ffffffffc020112e:	fef764e3          	bltu	a4,a5,ffffffffc0201116 <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201132:	000b3503          	ld	a0,0(s6)
ffffffffc0201136:	079a                	slli	a5,a5,0x6
ffffffffc0201138:	c0200737          	lui	a4,0xc0200
ffffffffc020113c:	00f506b3          	add	a3,a0,a5
ffffffffc0201140:	60e6e563          	bltu	a3,a4,ffffffffc020174a <pmm_init+0x6dc>
ffffffffc0201144:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0201148:	4745                	li	a4,17
ffffffffc020114a:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020114c:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020114e:	4ae6e563          	bltu	a3,a4,ffffffffc02015f8 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201152:	00005517          	auipc	a0,0x5
ffffffffc0201156:	82e50513          	addi	a0,a0,-2002 # ffffffffc0205980 <commands+0x818>
ffffffffc020115a:	f73fe0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020115e:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201162:	00014917          	auipc	s2,0x14
ffffffffc0201166:	3f690913          	addi	s2,s2,1014 # ffffffffc0215558 <boot_pgdir>
    pmm_manager->check();
ffffffffc020116a:	7b9c                	ld	a5,48(a5)
ffffffffc020116c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020116e:	00005517          	auipc	a0,0x5
ffffffffc0201172:	82a50513          	addi	a0,a0,-2006 # ffffffffc0205998 <commands+0x830>
ffffffffc0201176:	f57fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020117a:	00008697          	auipc	a3,0x8
ffffffffc020117e:	e8668693          	addi	a3,a3,-378 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201182:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201186:	c02007b7          	lui	a5,0xc0200
ffffffffc020118a:	5cf6ec63          	bltu	a3,a5,ffffffffc0201762 <pmm_init+0x6f4>
ffffffffc020118e:	0009b783          	ld	a5,0(s3)
ffffffffc0201192:	8e9d                	sub	a3,a3,a5
ffffffffc0201194:	00014797          	auipc	a5,0x14
ffffffffc0201198:	3ad7be23          	sd	a3,956(a5) # ffffffffc0215550 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020119c:	100027f3          	csrr	a5,sstatus
ffffffffc02011a0:	8b89                	andi	a5,a5,2
ffffffffc02011a2:	48079263          	bnez	a5,ffffffffc0201626 <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc02011a6:	000bb783          	ld	a5,0(s7)
ffffffffc02011aa:	779c                	ld	a5,40(a5)
ffffffffc02011ac:	9782                	jalr	a5
ffffffffc02011ae:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02011b0:	6098                	ld	a4,0(s1)
ffffffffc02011b2:	c80007b7          	lui	a5,0xc8000
ffffffffc02011b6:	83b1                	srli	a5,a5,0xc
ffffffffc02011b8:	5ee7e163          	bltu	a5,a4,ffffffffc020179a <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02011bc:	00093503          	ld	a0,0(s2)
ffffffffc02011c0:	5a050d63          	beqz	a0,ffffffffc020177a <pmm_init+0x70c>
ffffffffc02011c4:	03451793          	slli	a5,a0,0x34
ffffffffc02011c8:	5a079963          	bnez	a5,ffffffffc020177a <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02011cc:	4601                	li	a2,0
ffffffffc02011ce:	4581                	li	a1,0
ffffffffc02011d0:	cb9ff0ef          	jal	ra,ffffffffc0200e88 <get_page>
ffffffffc02011d4:	62051563          	bnez	a0,ffffffffc02017fe <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02011d8:	4505                	li	a0,1
ffffffffc02011da:	9d1ff0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc02011de:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02011e0:	00093503          	ld	a0,0(s2)
ffffffffc02011e4:	4681                	li	a3,0
ffffffffc02011e6:	4601                	li	a2,0
ffffffffc02011e8:	85d2                	mv	a1,s4
ffffffffc02011ea:	d8fff0ef          	jal	ra,ffffffffc0200f78 <page_insert>
ffffffffc02011ee:	5e051863          	bnez	a0,ffffffffc02017de <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02011f2:	00093503          	ld	a0,0(s2)
ffffffffc02011f6:	4601                	li	a2,0
ffffffffc02011f8:	4581                	li	a1,0
ffffffffc02011fa:	abdff0ef          	jal	ra,ffffffffc0200cb6 <get_pte>
ffffffffc02011fe:	5c050063          	beqz	a0,ffffffffc02017be <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0201202:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201204:	0017f713          	andi	a4,a5,1
ffffffffc0201208:	5a070963          	beqz	a4,ffffffffc02017ba <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc020120c:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020120e:	078a                	slli	a5,a5,0x2
ffffffffc0201210:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201212:	52e7fa63          	bgeu	a5,a4,ffffffffc0201746 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201216:	000b3683          	ld	a3,0(s6)
ffffffffc020121a:	fff80637          	lui	a2,0xfff80
ffffffffc020121e:	97b2                	add	a5,a5,a2
ffffffffc0201220:	079a                	slli	a5,a5,0x6
ffffffffc0201222:	97b6                	add	a5,a5,a3
ffffffffc0201224:	10fa16e3          	bne	s4,a5,ffffffffc0201b30 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc0201228:	000a2683          	lw	a3,0(s4)
ffffffffc020122c:	4785                	li	a5,1
ffffffffc020122e:	12f69de3          	bne	a3,a5,ffffffffc0201b68 <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201232:	00093503          	ld	a0,0(s2)
ffffffffc0201236:	77fd                	lui	a5,0xfffff
ffffffffc0201238:	6114                	ld	a3,0(a0)
ffffffffc020123a:	068a                	slli	a3,a3,0x2
ffffffffc020123c:	8efd                	and	a3,a3,a5
ffffffffc020123e:	00c6d613          	srli	a2,a3,0xc
ffffffffc0201242:	10e677e3          	bgeu	a2,a4,ffffffffc0201b50 <pmm_init+0xae2>
ffffffffc0201246:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020124a:	96e2                	add	a3,a3,s8
ffffffffc020124c:	0006ba83          	ld	s5,0(a3)
ffffffffc0201250:	0a8a                	slli	s5,s5,0x2
ffffffffc0201252:	00fafab3          	and	s5,s5,a5
ffffffffc0201256:	00cad793          	srli	a5,s5,0xc
ffffffffc020125a:	62e7f263          	bgeu	a5,a4,ffffffffc020187e <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020125e:	4601                	li	a2,0
ffffffffc0201260:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201262:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201264:	a53ff0ef          	jal	ra,ffffffffc0200cb6 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201268:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020126a:	5f551a63          	bne	a0,s5,ffffffffc020185e <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc020126e:	4505                	li	a0,1
ffffffffc0201270:	93bff0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0201274:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201276:	00093503          	ld	a0,0(s2)
ffffffffc020127a:	46d1                	li	a3,20
ffffffffc020127c:	6605                	lui	a2,0x1
ffffffffc020127e:	85d6                	mv	a1,s5
ffffffffc0201280:	cf9ff0ef          	jal	ra,ffffffffc0200f78 <page_insert>
ffffffffc0201284:	58051d63          	bnez	a0,ffffffffc020181e <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201288:	00093503          	ld	a0,0(s2)
ffffffffc020128c:	4601                	li	a2,0
ffffffffc020128e:	6585                	lui	a1,0x1
ffffffffc0201290:	a27ff0ef          	jal	ra,ffffffffc0200cb6 <get_pte>
ffffffffc0201294:	0e050ae3          	beqz	a0,ffffffffc0201b88 <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc0201298:	611c                	ld	a5,0(a0)
ffffffffc020129a:	0107f713          	andi	a4,a5,16
ffffffffc020129e:	6e070d63          	beqz	a4,ffffffffc0201998 <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc02012a2:	8b91                	andi	a5,a5,4
ffffffffc02012a4:	6a078a63          	beqz	a5,ffffffffc0201958 <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02012a8:	00093503          	ld	a0,0(s2)
ffffffffc02012ac:	611c                	ld	a5,0(a0)
ffffffffc02012ae:	8bc1                	andi	a5,a5,16
ffffffffc02012b0:	68078463          	beqz	a5,ffffffffc0201938 <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc02012b4:	000aa703          	lw	a4,0(s5)
ffffffffc02012b8:	4785                	li	a5,1
ffffffffc02012ba:	58f71263          	bne	a4,a5,ffffffffc020183e <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02012be:	4681                	li	a3,0
ffffffffc02012c0:	6605                	lui	a2,0x1
ffffffffc02012c2:	85d2                	mv	a1,s4
ffffffffc02012c4:	cb5ff0ef          	jal	ra,ffffffffc0200f78 <page_insert>
ffffffffc02012c8:	62051863          	bnez	a0,ffffffffc02018f8 <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc02012cc:	000a2703          	lw	a4,0(s4)
ffffffffc02012d0:	4789                	li	a5,2
ffffffffc02012d2:	60f71363          	bne	a4,a5,ffffffffc02018d8 <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc02012d6:	000aa783          	lw	a5,0(s5)
ffffffffc02012da:	5c079f63          	bnez	a5,ffffffffc02018b8 <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02012de:	00093503          	ld	a0,0(s2)
ffffffffc02012e2:	4601                	li	a2,0
ffffffffc02012e4:	6585                	lui	a1,0x1
ffffffffc02012e6:	9d1ff0ef          	jal	ra,ffffffffc0200cb6 <get_pte>
ffffffffc02012ea:	5a050763          	beqz	a0,ffffffffc0201898 <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc02012ee:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02012f0:	00177793          	andi	a5,a4,1
ffffffffc02012f4:	4c078363          	beqz	a5,ffffffffc02017ba <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02012f8:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02012fa:	00271793          	slli	a5,a4,0x2
ffffffffc02012fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201300:	44d7f363          	bgeu	a5,a3,ffffffffc0201746 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201304:	000b3683          	ld	a3,0(s6)
ffffffffc0201308:	fff80637          	lui	a2,0xfff80
ffffffffc020130c:	97b2                	add	a5,a5,a2
ffffffffc020130e:	079a                	slli	a5,a5,0x6
ffffffffc0201310:	97b6                	add	a5,a5,a3
ffffffffc0201312:	6efa1363          	bne	s4,a5,ffffffffc02019f8 <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201316:	8b41                	andi	a4,a4,16
ffffffffc0201318:	6c071063          	bnez	a4,ffffffffc02019d8 <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc020131c:	00093503          	ld	a0,0(s2)
ffffffffc0201320:	4581                	li	a1,0
ffffffffc0201322:	bbbff0ef          	jal	ra,ffffffffc0200edc <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201326:	000a2703          	lw	a4,0(s4)
ffffffffc020132a:	4785                	li	a5,1
ffffffffc020132c:	68f71663          	bne	a4,a5,ffffffffc02019b8 <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0201330:	000aa783          	lw	a5,0(s5)
ffffffffc0201334:	74079e63          	bnez	a5,ffffffffc0201a90 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201338:	00093503          	ld	a0,0(s2)
ffffffffc020133c:	6585                	lui	a1,0x1
ffffffffc020133e:	b9fff0ef          	jal	ra,ffffffffc0200edc <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201342:	000a2783          	lw	a5,0(s4)
ffffffffc0201346:	72079563          	bnez	a5,ffffffffc0201a70 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc020134a:	000aa783          	lw	a5,0(s5)
ffffffffc020134e:	70079163          	bnez	a5,ffffffffc0201a50 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201352:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201356:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201358:	000a3683          	ld	a3,0(s4)
ffffffffc020135c:	068a                	slli	a3,a3,0x2
ffffffffc020135e:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201360:	3ee6f363          	bgeu	a3,a4,ffffffffc0201746 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201364:	fff807b7          	lui	a5,0xfff80
ffffffffc0201368:	000b3503          	ld	a0,0(s6)
ffffffffc020136c:	96be                	add	a3,a3,a5
ffffffffc020136e:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0201370:	00d507b3          	add	a5,a0,a3
ffffffffc0201374:	4390                	lw	a2,0(a5)
ffffffffc0201376:	4785                	li	a5,1
ffffffffc0201378:	6af61c63          	bne	a2,a5,ffffffffc0201a30 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc020137c:	8699                	srai	a3,a3,0x6
ffffffffc020137e:	000805b7          	lui	a1,0x80
ffffffffc0201382:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0201384:	00c69613          	slli	a2,a3,0xc
ffffffffc0201388:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020138a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020138c:	68e67663          	bgeu	a2,a4,ffffffffc0201a18 <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201390:	0009b603          	ld	a2,0(s3)
ffffffffc0201394:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc0201396:	629c                	ld	a5,0(a3)
ffffffffc0201398:	078a                	slli	a5,a5,0x2
ffffffffc020139a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020139c:	3ae7f563          	bgeu	a5,a4,ffffffffc0201746 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02013a0:	8f8d                	sub	a5,a5,a1
ffffffffc02013a2:	079a                	slli	a5,a5,0x6
ffffffffc02013a4:	953e                	add	a0,a0,a5
ffffffffc02013a6:	100027f3          	csrr	a5,sstatus
ffffffffc02013aa:	8b89                	andi	a5,a5,2
ffffffffc02013ac:	2c079763          	bnez	a5,ffffffffc020167a <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc02013b0:	000bb783          	ld	a5,0(s7)
ffffffffc02013b4:	4585                	li	a1,1
ffffffffc02013b6:	739c                	ld	a5,32(a5)
ffffffffc02013b8:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02013ba:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02013be:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02013c0:	078a                	slli	a5,a5,0x2
ffffffffc02013c2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02013c4:	38e7f163          	bgeu	a5,a4,ffffffffc0201746 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02013c8:	000b3503          	ld	a0,0(s6)
ffffffffc02013cc:	fff80737          	lui	a4,0xfff80
ffffffffc02013d0:	97ba                	add	a5,a5,a4
ffffffffc02013d2:	079a                	slli	a5,a5,0x6
ffffffffc02013d4:	953e                	add	a0,a0,a5
ffffffffc02013d6:	100027f3          	csrr	a5,sstatus
ffffffffc02013da:	8b89                	andi	a5,a5,2
ffffffffc02013dc:	28079363          	bnez	a5,ffffffffc0201662 <pmm_init+0x5f4>
ffffffffc02013e0:	000bb783          	ld	a5,0(s7)
ffffffffc02013e4:	4585                	li	a1,1
ffffffffc02013e6:	739c                	ld	a5,32(a5)
ffffffffc02013e8:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02013ea:	00093783          	ld	a5,0(s2)
ffffffffc02013ee:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fd6aa34>
  asm volatile("sfence.vma");
ffffffffc02013f2:	12000073          	sfence.vma
ffffffffc02013f6:	100027f3          	csrr	a5,sstatus
ffffffffc02013fa:	8b89                	andi	a5,a5,2
ffffffffc02013fc:	24079963          	bnez	a5,ffffffffc020164e <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201400:	000bb783          	ld	a5,0(s7)
ffffffffc0201404:	779c                	ld	a5,40(a5)
ffffffffc0201406:	9782                	jalr	a5
ffffffffc0201408:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020140a:	71441363          	bne	s0,s4,ffffffffc0201b10 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020140e:	00005517          	auipc	a0,0x5
ffffffffc0201412:	88a50513          	addi	a0,a0,-1910 # ffffffffc0205c98 <commands+0xb30>
ffffffffc0201416:	cb7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020141a:	100027f3          	csrr	a5,sstatus
ffffffffc020141e:	8b89                	andi	a5,a5,2
ffffffffc0201420:	20079d63          	bnez	a5,ffffffffc020163a <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201424:	000bb783          	ld	a5,0(s7)
ffffffffc0201428:	779c                	ld	a5,40(a5)
ffffffffc020142a:	9782                	jalr	a5
ffffffffc020142c:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020142e:	6098                	ld	a4,0(s1)
ffffffffc0201430:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201434:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201436:	00c71793          	slli	a5,a4,0xc
ffffffffc020143a:	6a05                	lui	s4,0x1
ffffffffc020143c:	02f47c63          	bgeu	s0,a5,ffffffffc0201474 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201440:	00c45793          	srli	a5,s0,0xc
ffffffffc0201444:	00093503          	ld	a0,0(s2)
ffffffffc0201448:	2ee7f263          	bgeu	a5,a4,ffffffffc020172c <pmm_init+0x6be>
ffffffffc020144c:	0009b583          	ld	a1,0(s3)
ffffffffc0201450:	4601                	li	a2,0
ffffffffc0201452:	95a2                	add	a1,a1,s0
ffffffffc0201454:	863ff0ef          	jal	ra,ffffffffc0200cb6 <get_pte>
ffffffffc0201458:	2a050a63          	beqz	a0,ffffffffc020170c <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020145c:	611c                	ld	a5,0(a0)
ffffffffc020145e:	078a                	slli	a5,a5,0x2
ffffffffc0201460:	0157f7b3          	and	a5,a5,s5
ffffffffc0201464:	28879463          	bne	a5,s0,ffffffffc02016ec <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201468:	6098                	ld	a4,0(s1)
ffffffffc020146a:	9452                	add	s0,s0,s4
ffffffffc020146c:	00c71793          	slli	a5,a4,0xc
ffffffffc0201470:	fcf468e3          	bltu	s0,a5,ffffffffc0201440 <pmm_init+0x3d2>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc0201474:	00093783          	ld	a5,0(s2)
ffffffffc0201478:	639c                	ld	a5,0(a5)
ffffffffc020147a:	66079b63          	bnez	a5,ffffffffc0201af0 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc020147e:	4505                	li	a0,1
ffffffffc0201480:	f2aff0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0201484:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201486:	00093503          	ld	a0,0(s2)
ffffffffc020148a:	4699                	li	a3,6
ffffffffc020148c:	10000613          	li	a2,256
ffffffffc0201490:	85d6                	mv	a1,s5
ffffffffc0201492:	ae7ff0ef          	jal	ra,ffffffffc0200f78 <page_insert>
ffffffffc0201496:	62051d63          	bnez	a0,ffffffffc0201ad0 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc020149a:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fde9a34>
ffffffffc020149e:	4785                	li	a5,1
ffffffffc02014a0:	60f71863          	bne	a4,a5,ffffffffc0201ab0 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02014a4:	00093503          	ld	a0,0(s2)
ffffffffc02014a8:	6405                	lui	s0,0x1
ffffffffc02014aa:	4699                	li	a3,6
ffffffffc02014ac:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02014b0:	85d6                	mv	a1,s5
ffffffffc02014b2:	ac7ff0ef          	jal	ra,ffffffffc0200f78 <page_insert>
ffffffffc02014b6:	46051163          	bnez	a0,ffffffffc0201918 <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc02014ba:	000aa703          	lw	a4,0(s5)
ffffffffc02014be:	4789                	li	a5,2
ffffffffc02014c0:	72f71463          	bne	a4,a5,ffffffffc0201be8 <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02014c4:	00005597          	auipc	a1,0x5
ffffffffc02014c8:	90c58593          	addi	a1,a1,-1780 # ffffffffc0205dd0 <commands+0xc68>
ffffffffc02014cc:	10000513          	li	a0,256
ffffffffc02014d0:	578030ef          	jal	ra,ffffffffc0204a48 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02014d4:	10040593          	addi	a1,s0,256
ffffffffc02014d8:	10000513          	li	a0,256
ffffffffc02014dc:	57e030ef          	jal	ra,ffffffffc0204a5a <strcmp>
ffffffffc02014e0:	6e051463          	bnez	a0,ffffffffc0201bc8 <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc02014e4:	000b3683          	ld	a3,0(s6)
ffffffffc02014e8:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02014ec:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02014ee:	40da86b3          	sub	a3,s5,a3
ffffffffc02014f2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02014f4:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02014f6:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02014f8:	8031                	srli	s0,s0,0xc
ffffffffc02014fa:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02014fe:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201500:	50f77c63          	bgeu	a4,a5,ffffffffc0201a18 <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201504:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201508:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020150c:	96be                	add	a3,a3,a5
ffffffffc020150e:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201512:	500030ef          	jal	ra,ffffffffc0204a12 <strlen>
ffffffffc0201516:	68051963          	bnez	a0,ffffffffc0201ba8 <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020151a:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020151e:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201520:	000a3683          	ld	a3,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201524:	068a                	slli	a3,a3,0x2
ffffffffc0201526:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201528:	20f6ff63          	bgeu	a3,a5,ffffffffc0201746 <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc020152c:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020152e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201530:	4ef47463          	bgeu	s0,a5,ffffffffc0201a18 <pmm_init+0x9aa>
ffffffffc0201534:	0009b403          	ld	s0,0(s3)
ffffffffc0201538:	9436                	add	s0,s0,a3
ffffffffc020153a:	100027f3          	csrr	a5,sstatus
ffffffffc020153e:	8b89                	andi	a5,a5,2
ffffffffc0201540:	18079b63          	bnez	a5,ffffffffc02016d6 <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0201544:	000bb783          	ld	a5,0(s7)
ffffffffc0201548:	4585                	li	a1,1
ffffffffc020154a:	8556                	mv	a0,s5
ffffffffc020154c:	739c                	ld	a5,32(a5)
ffffffffc020154e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201550:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201552:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201554:	078a                	slli	a5,a5,0x2
ffffffffc0201556:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201558:	1ee7f763          	bgeu	a5,a4,ffffffffc0201746 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020155c:	000b3503          	ld	a0,0(s6)
ffffffffc0201560:	fff80737          	lui	a4,0xfff80
ffffffffc0201564:	97ba                	add	a5,a5,a4
ffffffffc0201566:	079a                	slli	a5,a5,0x6
ffffffffc0201568:	953e                	add	a0,a0,a5
ffffffffc020156a:	100027f3          	csrr	a5,sstatus
ffffffffc020156e:	8b89                	andi	a5,a5,2
ffffffffc0201570:	14079763          	bnez	a5,ffffffffc02016be <pmm_init+0x650>
ffffffffc0201574:	000bb783          	ld	a5,0(s7)
ffffffffc0201578:	4585                	li	a1,1
ffffffffc020157a:	739c                	ld	a5,32(a5)
ffffffffc020157c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020157e:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201582:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201584:	078a                	slli	a5,a5,0x2
ffffffffc0201586:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201588:	1ae7ff63          	bgeu	a5,a4,ffffffffc0201746 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020158c:	000b3503          	ld	a0,0(s6)
ffffffffc0201590:	fff80737          	lui	a4,0xfff80
ffffffffc0201594:	97ba                	add	a5,a5,a4
ffffffffc0201596:	079a                	slli	a5,a5,0x6
ffffffffc0201598:	953e                	add	a0,a0,a5
ffffffffc020159a:	100027f3          	csrr	a5,sstatus
ffffffffc020159e:	8b89                	andi	a5,a5,2
ffffffffc02015a0:	10079363          	bnez	a5,ffffffffc02016a6 <pmm_init+0x638>
ffffffffc02015a4:	000bb783          	ld	a5,0(s7)
ffffffffc02015a8:	4585                	li	a1,1
ffffffffc02015aa:	739c                	ld	a5,32(a5)
ffffffffc02015ac:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02015ae:	00093783          	ld	a5,0(s2)
ffffffffc02015b2:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02015b6:	12000073          	sfence.vma
ffffffffc02015ba:	100027f3          	csrr	a5,sstatus
ffffffffc02015be:	8b89                	andi	a5,a5,2
ffffffffc02015c0:	0c079963          	bnez	a5,ffffffffc0201692 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc02015c4:	000bb783          	ld	a5,0(s7)
ffffffffc02015c8:	779c                	ld	a5,40(a5)
ffffffffc02015ca:	9782                	jalr	a5
ffffffffc02015cc:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02015ce:	3a8c1563          	bne	s8,s0,ffffffffc0201978 <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02015d2:	00005517          	auipc	a0,0x5
ffffffffc02015d6:	87650513          	addi	a0,a0,-1930 # ffffffffc0205e48 <commands+0xce0>
ffffffffc02015da:	af3fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02015de:	6446                	ld	s0,80(sp)
ffffffffc02015e0:	60e6                	ld	ra,88(sp)
ffffffffc02015e2:	64a6                	ld	s1,72(sp)
ffffffffc02015e4:	6906                	ld	s2,64(sp)
ffffffffc02015e6:	79e2                	ld	s3,56(sp)
ffffffffc02015e8:	7a42                	ld	s4,48(sp)
ffffffffc02015ea:	7aa2                	ld	s5,40(sp)
ffffffffc02015ec:	7b02                	ld	s6,32(sp)
ffffffffc02015ee:	6be2                	ld	s7,24(sp)
ffffffffc02015f0:	6c42                	ld	s8,16(sp)
ffffffffc02015f2:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc02015f4:	55a0106f          	j	ffffffffc0202b4e <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02015f8:	6785                	lui	a5,0x1
ffffffffc02015fa:	17fd                	addi	a5,a5,-1
ffffffffc02015fc:	96be                	add	a3,a3,a5
ffffffffc02015fe:	77fd                	lui	a5,0xfffff
ffffffffc0201600:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0201602:	00c7d693          	srli	a3,a5,0xc
ffffffffc0201606:	14c6f063          	bgeu	a3,a2,ffffffffc0201746 <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc020160a:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc020160e:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201610:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0201614:	6a10                	ld	a2,16(a2)
ffffffffc0201616:	069a                	slli	a3,a3,0x6
ffffffffc0201618:	00c7d593          	srli	a1,a5,0xc
ffffffffc020161c:	9536                	add	a0,a0,a3
ffffffffc020161e:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201620:	0009b583          	ld	a1,0(s3)
}
ffffffffc0201624:	b63d                	j	ffffffffc0201152 <pmm_init+0xe4>
        intr_disable();
ffffffffc0201626:	f9ffe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020162a:	000bb783          	ld	a5,0(s7)
ffffffffc020162e:	779c                	ld	a5,40(a5)
ffffffffc0201630:	9782                	jalr	a5
ffffffffc0201632:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201634:	f8bfe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0201638:	bea5                	j	ffffffffc02011b0 <pmm_init+0x142>
        intr_disable();
ffffffffc020163a:	f8bfe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc020163e:	000bb783          	ld	a5,0(s7)
ffffffffc0201642:	779c                	ld	a5,40(a5)
ffffffffc0201644:	9782                	jalr	a5
ffffffffc0201646:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0201648:	f77fe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc020164c:	b3cd                	j	ffffffffc020142e <pmm_init+0x3c0>
        intr_disable();
ffffffffc020164e:	f77fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0201652:	000bb783          	ld	a5,0(s7)
ffffffffc0201656:	779c                	ld	a5,40(a5)
ffffffffc0201658:	9782                	jalr	a5
ffffffffc020165a:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020165c:	f63fe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0201660:	b36d                	j	ffffffffc020140a <pmm_init+0x39c>
ffffffffc0201662:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201664:	f61fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201668:	000bb783          	ld	a5,0(s7)
ffffffffc020166c:	6522                	ld	a0,8(sp)
ffffffffc020166e:	4585                	li	a1,1
ffffffffc0201670:	739c                	ld	a5,32(a5)
ffffffffc0201672:	9782                	jalr	a5
        intr_enable();
ffffffffc0201674:	f4bfe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0201678:	bb8d                	j	ffffffffc02013ea <pmm_init+0x37c>
ffffffffc020167a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020167c:	f49fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0201680:	000bb783          	ld	a5,0(s7)
ffffffffc0201684:	6522                	ld	a0,8(sp)
ffffffffc0201686:	4585                	li	a1,1
ffffffffc0201688:	739c                	ld	a5,32(a5)
ffffffffc020168a:	9782                	jalr	a5
        intr_enable();
ffffffffc020168c:	f33fe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0201690:	b32d                	j	ffffffffc02013ba <pmm_init+0x34c>
        intr_disable();
ffffffffc0201692:	f33fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201696:	000bb783          	ld	a5,0(s7)
ffffffffc020169a:	779c                	ld	a5,40(a5)
ffffffffc020169c:	9782                	jalr	a5
ffffffffc020169e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02016a0:	f1ffe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc02016a4:	b72d                	j	ffffffffc02015ce <pmm_init+0x560>
ffffffffc02016a6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02016a8:	f1dfe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02016ac:	000bb783          	ld	a5,0(s7)
ffffffffc02016b0:	6522                	ld	a0,8(sp)
ffffffffc02016b2:	4585                	li	a1,1
ffffffffc02016b4:	739c                	ld	a5,32(a5)
ffffffffc02016b6:	9782                	jalr	a5
        intr_enable();
ffffffffc02016b8:	f07fe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc02016bc:	bdcd                	j	ffffffffc02015ae <pmm_init+0x540>
ffffffffc02016be:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02016c0:	f05fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc02016c4:	000bb783          	ld	a5,0(s7)
ffffffffc02016c8:	6522                	ld	a0,8(sp)
ffffffffc02016ca:	4585                	li	a1,1
ffffffffc02016cc:	739c                	ld	a5,32(a5)
ffffffffc02016ce:	9782                	jalr	a5
        intr_enable();
ffffffffc02016d0:	eeffe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc02016d4:	b56d                	j	ffffffffc020157e <pmm_init+0x510>
        intr_disable();
ffffffffc02016d6:	eeffe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc02016da:	000bb783          	ld	a5,0(s7)
ffffffffc02016de:	4585                	li	a1,1
ffffffffc02016e0:	8556                	mv	a0,s5
ffffffffc02016e2:	739c                	ld	a5,32(a5)
ffffffffc02016e4:	9782                	jalr	a5
        intr_enable();
ffffffffc02016e6:	ed9fe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc02016ea:	b59d                	j	ffffffffc0201550 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02016ec:	00004697          	auipc	a3,0x4
ffffffffc02016f0:	60c68693          	addi	a3,a3,1548 # ffffffffc0205cf8 <commands+0xb90>
ffffffffc02016f4:	00004617          	auipc	a2,0x4
ffffffffc02016f8:	2e460613          	addi	a2,a2,740 # ffffffffc02059d8 <commands+0x870>
ffffffffc02016fc:	19e00593          	li	a1,414
ffffffffc0201700:	00004517          	auipc	a0,0x4
ffffffffc0201704:	1f050513          	addi	a0,a0,496 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201708:	ac1fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020170c:	00004697          	auipc	a3,0x4
ffffffffc0201710:	5ac68693          	addi	a3,a3,1452 # ffffffffc0205cb8 <commands+0xb50>
ffffffffc0201714:	00004617          	auipc	a2,0x4
ffffffffc0201718:	2c460613          	addi	a2,a2,708 # ffffffffc02059d8 <commands+0x870>
ffffffffc020171c:	19d00593          	li	a1,413
ffffffffc0201720:	00004517          	auipc	a0,0x4
ffffffffc0201724:	1d050513          	addi	a0,a0,464 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201728:	aa1fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc020172c:	86a2                	mv	a3,s0
ffffffffc020172e:	00004617          	auipc	a2,0x4
ffffffffc0201732:	19a60613          	addi	a2,a2,410 # ffffffffc02058c8 <commands+0x760>
ffffffffc0201736:	19d00593          	li	a1,413
ffffffffc020173a:	00004517          	auipc	a0,0x4
ffffffffc020173e:	1b650513          	addi	a0,a0,438 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201742:	a87fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0201746:	c2cff0ef          	jal	ra,ffffffffc0200b72 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020174a:	00004617          	auipc	a2,0x4
ffffffffc020174e:	20e60613          	addi	a2,a2,526 # ffffffffc0205958 <commands+0x7f0>
ffffffffc0201752:	07f00593          	li	a1,127
ffffffffc0201756:	00004517          	auipc	a0,0x4
ffffffffc020175a:	19a50513          	addi	a0,a0,410 # ffffffffc02058f0 <commands+0x788>
ffffffffc020175e:	a6bfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201762:	00004617          	auipc	a2,0x4
ffffffffc0201766:	1f660613          	addi	a2,a2,502 # ffffffffc0205958 <commands+0x7f0>
ffffffffc020176a:	0c300593          	li	a1,195
ffffffffc020176e:	00004517          	auipc	a0,0x4
ffffffffc0201772:	18250513          	addi	a0,a0,386 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201776:	a53fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020177a:	00004697          	auipc	a3,0x4
ffffffffc020177e:	27668693          	addi	a3,a3,630 # ffffffffc02059f0 <commands+0x888>
ffffffffc0201782:	00004617          	auipc	a2,0x4
ffffffffc0201786:	25660613          	addi	a2,a2,598 # ffffffffc02059d8 <commands+0x870>
ffffffffc020178a:	16100593          	li	a1,353
ffffffffc020178e:	00004517          	auipc	a0,0x4
ffffffffc0201792:	16250513          	addi	a0,a0,354 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201796:	a33fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020179a:	00004697          	auipc	a3,0x4
ffffffffc020179e:	21e68693          	addi	a3,a3,542 # ffffffffc02059b8 <commands+0x850>
ffffffffc02017a2:	00004617          	auipc	a2,0x4
ffffffffc02017a6:	23660613          	addi	a2,a2,566 # ffffffffc02059d8 <commands+0x870>
ffffffffc02017aa:	16000593          	li	a1,352
ffffffffc02017ae:	00004517          	auipc	a0,0x4
ffffffffc02017b2:	14250513          	addi	a0,a0,322 # ffffffffc02058f0 <commands+0x788>
ffffffffc02017b6:	a13fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc02017ba:	bd4ff0ef          	jal	ra,ffffffffc0200b8e <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02017be:	00004697          	auipc	a3,0x4
ffffffffc02017c2:	2c268693          	addi	a3,a3,706 # ffffffffc0205a80 <commands+0x918>
ffffffffc02017c6:	00004617          	auipc	a2,0x4
ffffffffc02017ca:	21260613          	addi	a2,a2,530 # ffffffffc02059d8 <commands+0x870>
ffffffffc02017ce:	16900593          	li	a1,361
ffffffffc02017d2:	00004517          	auipc	a0,0x4
ffffffffc02017d6:	11e50513          	addi	a0,a0,286 # ffffffffc02058f0 <commands+0x788>
ffffffffc02017da:	9effe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02017de:	00004697          	auipc	a3,0x4
ffffffffc02017e2:	27268693          	addi	a3,a3,626 # ffffffffc0205a50 <commands+0x8e8>
ffffffffc02017e6:	00004617          	auipc	a2,0x4
ffffffffc02017ea:	1f260613          	addi	a2,a2,498 # ffffffffc02059d8 <commands+0x870>
ffffffffc02017ee:	16600593          	li	a1,358
ffffffffc02017f2:	00004517          	auipc	a0,0x4
ffffffffc02017f6:	0fe50513          	addi	a0,a0,254 # ffffffffc02058f0 <commands+0x788>
ffffffffc02017fa:	9cffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02017fe:	00004697          	auipc	a3,0x4
ffffffffc0201802:	22a68693          	addi	a3,a3,554 # ffffffffc0205a28 <commands+0x8c0>
ffffffffc0201806:	00004617          	auipc	a2,0x4
ffffffffc020180a:	1d260613          	addi	a2,a2,466 # ffffffffc02059d8 <commands+0x870>
ffffffffc020180e:	16200593          	li	a1,354
ffffffffc0201812:	00004517          	auipc	a0,0x4
ffffffffc0201816:	0de50513          	addi	a0,a0,222 # ffffffffc02058f0 <commands+0x788>
ffffffffc020181a:	9affe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020181e:	00004697          	auipc	a3,0x4
ffffffffc0201822:	2ea68693          	addi	a3,a3,746 # ffffffffc0205b08 <commands+0x9a0>
ffffffffc0201826:	00004617          	auipc	a2,0x4
ffffffffc020182a:	1b260613          	addi	a2,a2,434 # ffffffffc02059d8 <commands+0x870>
ffffffffc020182e:	17200593          	li	a1,370
ffffffffc0201832:	00004517          	auipc	a0,0x4
ffffffffc0201836:	0be50513          	addi	a0,a0,190 # ffffffffc02058f0 <commands+0x788>
ffffffffc020183a:	98ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020183e:	00004697          	auipc	a3,0x4
ffffffffc0201842:	36a68693          	addi	a3,a3,874 # ffffffffc0205ba8 <commands+0xa40>
ffffffffc0201846:	00004617          	auipc	a2,0x4
ffffffffc020184a:	19260613          	addi	a2,a2,402 # ffffffffc02059d8 <commands+0x870>
ffffffffc020184e:	17700593          	li	a1,375
ffffffffc0201852:	00004517          	auipc	a0,0x4
ffffffffc0201856:	09e50513          	addi	a0,a0,158 # ffffffffc02058f0 <commands+0x788>
ffffffffc020185a:	96ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020185e:	00004697          	auipc	a3,0x4
ffffffffc0201862:	28268693          	addi	a3,a3,642 # ffffffffc0205ae0 <commands+0x978>
ffffffffc0201866:	00004617          	auipc	a2,0x4
ffffffffc020186a:	17260613          	addi	a2,a2,370 # ffffffffc02059d8 <commands+0x870>
ffffffffc020186e:	16f00593          	li	a1,367
ffffffffc0201872:	00004517          	auipc	a0,0x4
ffffffffc0201876:	07e50513          	addi	a0,a0,126 # ffffffffc02058f0 <commands+0x788>
ffffffffc020187a:	94ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020187e:	86d6                	mv	a3,s5
ffffffffc0201880:	00004617          	auipc	a2,0x4
ffffffffc0201884:	04860613          	addi	a2,a2,72 # ffffffffc02058c8 <commands+0x760>
ffffffffc0201888:	16e00593          	li	a1,366
ffffffffc020188c:	00004517          	auipc	a0,0x4
ffffffffc0201890:	06450513          	addi	a0,a0,100 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201894:	935fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201898:	00004697          	auipc	a3,0x4
ffffffffc020189c:	2a868693          	addi	a3,a3,680 # ffffffffc0205b40 <commands+0x9d8>
ffffffffc02018a0:	00004617          	auipc	a2,0x4
ffffffffc02018a4:	13860613          	addi	a2,a2,312 # ffffffffc02059d8 <commands+0x870>
ffffffffc02018a8:	17c00593          	li	a1,380
ffffffffc02018ac:	00004517          	auipc	a0,0x4
ffffffffc02018b0:	04450513          	addi	a0,a0,68 # ffffffffc02058f0 <commands+0x788>
ffffffffc02018b4:	915fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02018b8:	00004697          	auipc	a3,0x4
ffffffffc02018bc:	35068693          	addi	a3,a3,848 # ffffffffc0205c08 <commands+0xaa0>
ffffffffc02018c0:	00004617          	auipc	a2,0x4
ffffffffc02018c4:	11860613          	addi	a2,a2,280 # ffffffffc02059d8 <commands+0x870>
ffffffffc02018c8:	17b00593          	li	a1,379
ffffffffc02018cc:	00004517          	auipc	a0,0x4
ffffffffc02018d0:	02450513          	addi	a0,a0,36 # ffffffffc02058f0 <commands+0x788>
ffffffffc02018d4:	8f5fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02018d8:	00004697          	auipc	a3,0x4
ffffffffc02018dc:	31868693          	addi	a3,a3,792 # ffffffffc0205bf0 <commands+0xa88>
ffffffffc02018e0:	00004617          	auipc	a2,0x4
ffffffffc02018e4:	0f860613          	addi	a2,a2,248 # ffffffffc02059d8 <commands+0x870>
ffffffffc02018e8:	17a00593          	li	a1,378
ffffffffc02018ec:	00004517          	auipc	a0,0x4
ffffffffc02018f0:	00450513          	addi	a0,a0,4 # ffffffffc02058f0 <commands+0x788>
ffffffffc02018f4:	8d5fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02018f8:	00004697          	auipc	a3,0x4
ffffffffc02018fc:	2c868693          	addi	a3,a3,712 # ffffffffc0205bc0 <commands+0xa58>
ffffffffc0201900:	00004617          	auipc	a2,0x4
ffffffffc0201904:	0d860613          	addi	a2,a2,216 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201908:	17900593          	li	a1,377
ffffffffc020190c:	00004517          	auipc	a0,0x4
ffffffffc0201910:	fe450513          	addi	a0,a0,-28 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201914:	8b5fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201918:	00004697          	auipc	a3,0x4
ffffffffc020191c:	46068693          	addi	a3,a3,1120 # ffffffffc0205d78 <commands+0xc10>
ffffffffc0201920:	00004617          	auipc	a2,0x4
ffffffffc0201924:	0b860613          	addi	a2,a2,184 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201928:	1a700593          	li	a1,423
ffffffffc020192c:	00004517          	auipc	a0,0x4
ffffffffc0201930:	fc450513          	addi	a0,a0,-60 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201934:	895fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201938:	00004697          	auipc	a3,0x4
ffffffffc020193c:	25868693          	addi	a3,a3,600 # ffffffffc0205b90 <commands+0xa28>
ffffffffc0201940:	00004617          	auipc	a2,0x4
ffffffffc0201944:	09860613          	addi	a2,a2,152 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201948:	17600593          	li	a1,374
ffffffffc020194c:	00004517          	auipc	a0,0x4
ffffffffc0201950:	fa450513          	addi	a0,a0,-92 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201954:	875fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201958:	00004697          	auipc	a3,0x4
ffffffffc020195c:	22868693          	addi	a3,a3,552 # ffffffffc0205b80 <commands+0xa18>
ffffffffc0201960:	00004617          	auipc	a2,0x4
ffffffffc0201964:	07860613          	addi	a2,a2,120 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201968:	17500593          	li	a1,373
ffffffffc020196c:	00004517          	auipc	a0,0x4
ffffffffc0201970:	f8450513          	addi	a0,a0,-124 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201974:	855fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201978:	00004697          	auipc	a3,0x4
ffffffffc020197c:	30068693          	addi	a3,a3,768 # ffffffffc0205c78 <commands+0xb10>
ffffffffc0201980:	00004617          	auipc	a2,0x4
ffffffffc0201984:	05860613          	addi	a2,a2,88 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201988:	1b800593          	li	a1,440
ffffffffc020198c:	00004517          	auipc	a0,0x4
ffffffffc0201990:	f6450513          	addi	a0,a0,-156 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201994:	835fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201998:	00004697          	auipc	a3,0x4
ffffffffc020199c:	1d868693          	addi	a3,a3,472 # ffffffffc0205b70 <commands+0xa08>
ffffffffc02019a0:	00004617          	auipc	a2,0x4
ffffffffc02019a4:	03860613          	addi	a2,a2,56 # ffffffffc02059d8 <commands+0x870>
ffffffffc02019a8:	17400593          	li	a1,372
ffffffffc02019ac:	00004517          	auipc	a0,0x4
ffffffffc02019b0:	f4450513          	addi	a0,a0,-188 # ffffffffc02058f0 <commands+0x788>
ffffffffc02019b4:	815fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02019b8:	00004697          	auipc	a3,0x4
ffffffffc02019bc:	11068693          	addi	a3,a3,272 # ffffffffc0205ac8 <commands+0x960>
ffffffffc02019c0:	00004617          	auipc	a2,0x4
ffffffffc02019c4:	01860613          	addi	a2,a2,24 # ffffffffc02059d8 <commands+0x870>
ffffffffc02019c8:	18100593          	li	a1,385
ffffffffc02019cc:	00004517          	auipc	a0,0x4
ffffffffc02019d0:	f2450513          	addi	a0,a0,-220 # ffffffffc02058f0 <commands+0x788>
ffffffffc02019d4:	ff4fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02019d8:	00004697          	auipc	a3,0x4
ffffffffc02019dc:	24868693          	addi	a3,a3,584 # ffffffffc0205c20 <commands+0xab8>
ffffffffc02019e0:	00004617          	auipc	a2,0x4
ffffffffc02019e4:	ff860613          	addi	a2,a2,-8 # ffffffffc02059d8 <commands+0x870>
ffffffffc02019e8:	17e00593          	li	a1,382
ffffffffc02019ec:	00004517          	auipc	a0,0x4
ffffffffc02019f0:	f0450513          	addi	a0,a0,-252 # ffffffffc02058f0 <commands+0x788>
ffffffffc02019f4:	fd4fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02019f8:	00004697          	auipc	a3,0x4
ffffffffc02019fc:	0b868693          	addi	a3,a3,184 # ffffffffc0205ab0 <commands+0x948>
ffffffffc0201a00:	00004617          	auipc	a2,0x4
ffffffffc0201a04:	fd860613          	addi	a2,a2,-40 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201a08:	17d00593          	li	a1,381
ffffffffc0201a0c:	00004517          	auipc	a0,0x4
ffffffffc0201a10:	ee450513          	addi	a0,a0,-284 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201a14:	fb4fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201a18:	00004617          	auipc	a2,0x4
ffffffffc0201a1c:	eb060613          	addi	a2,a2,-336 # ffffffffc02058c8 <commands+0x760>
ffffffffc0201a20:	06900593          	li	a1,105
ffffffffc0201a24:	00004517          	auipc	a0,0x4
ffffffffc0201a28:	e6c50513          	addi	a0,a0,-404 # ffffffffc0205890 <commands+0x728>
ffffffffc0201a2c:	f9cfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201a30:	00004697          	auipc	a3,0x4
ffffffffc0201a34:	22068693          	addi	a3,a3,544 # ffffffffc0205c50 <commands+0xae8>
ffffffffc0201a38:	00004617          	auipc	a2,0x4
ffffffffc0201a3c:	fa060613          	addi	a2,a2,-96 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201a40:	18800593          	li	a1,392
ffffffffc0201a44:	00004517          	auipc	a0,0x4
ffffffffc0201a48:	eac50513          	addi	a0,a0,-340 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201a4c:	f7cfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201a50:	00004697          	auipc	a3,0x4
ffffffffc0201a54:	1b868693          	addi	a3,a3,440 # ffffffffc0205c08 <commands+0xaa0>
ffffffffc0201a58:	00004617          	auipc	a2,0x4
ffffffffc0201a5c:	f8060613          	addi	a2,a2,-128 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201a60:	18600593          	li	a1,390
ffffffffc0201a64:	00004517          	auipc	a0,0x4
ffffffffc0201a68:	e8c50513          	addi	a0,a0,-372 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201a6c:	f5cfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201a70:	00004697          	auipc	a3,0x4
ffffffffc0201a74:	1c868693          	addi	a3,a3,456 # ffffffffc0205c38 <commands+0xad0>
ffffffffc0201a78:	00004617          	auipc	a2,0x4
ffffffffc0201a7c:	f6060613          	addi	a2,a2,-160 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201a80:	18500593          	li	a1,389
ffffffffc0201a84:	00004517          	auipc	a0,0x4
ffffffffc0201a88:	e6c50513          	addi	a0,a0,-404 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201a8c:	f3cfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201a90:	00004697          	auipc	a3,0x4
ffffffffc0201a94:	17868693          	addi	a3,a3,376 # ffffffffc0205c08 <commands+0xaa0>
ffffffffc0201a98:	00004617          	auipc	a2,0x4
ffffffffc0201a9c:	f4060613          	addi	a2,a2,-192 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201aa0:	18200593          	li	a1,386
ffffffffc0201aa4:	00004517          	auipc	a0,0x4
ffffffffc0201aa8:	e4c50513          	addi	a0,a0,-436 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201aac:	f1cfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201ab0:	00004697          	auipc	a3,0x4
ffffffffc0201ab4:	2b068693          	addi	a3,a3,688 # ffffffffc0205d60 <commands+0xbf8>
ffffffffc0201ab8:	00004617          	auipc	a2,0x4
ffffffffc0201abc:	f2060613          	addi	a2,a2,-224 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201ac0:	1a600593          	li	a1,422
ffffffffc0201ac4:	00004517          	auipc	a0,0x4
ffffffffc0201ac8:	e2c50513          	addi	a0,a0,-468 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201acc:	efcfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201ad0:	00004697          	auipc	a3,0x4
ffffffffc0201ad4:	25868693          	addi	a3,a3,600 # ffffffffc0205d28 <commands+0xbc0>
ffffffffc0201ad8:	00004617          	auipc	a2,0x4
ffffffffc0201adc:	f0060613          	addi	a2,a2,-256 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201ae0:	1a500593          	li	a1,421
ffffffffc0201ae4:	00004517          	auipc	a0,0x4
ffffffffc0201ae8:	e0c50513          	addi	a0,a0,-500 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201aec:	edcfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0201af0:	00004697          	auipc	a3,0x4
ffffffffc0201af4:	22068693          	addi	a3,a3,544 # ffffffffc0205d10 <commands+0xba8>
ffffffffc0201af8:	00004617          	auipc	a2,0x4
ffffffffc0201afc:	ee060613          	addi	a2,a2,-288 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201b00:	1a100593          	li	a1,417
ffffffffc0201b04:	00004517          	auipc	a0,0x4
ffffffffc0201b08:	dec50513          	addi	a0,a0,-532 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201b0c:	ebcfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201b10:	00004697          	auipc	a3,0x4
ffffffffc0201b14:	16868693          	addi	a3,a3,360 # ffffffffc0205c78 <commands+0xb10>
ffffffffc0201b18:	00004617          	auipc	a2,0x4
ffffffffc0201b1c:	ec060613          	addi	a2,a2,-320 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201b20:	19000593          	li	a1,400
ffffffffc0201b24:	00004517          	auipc	a0,0x4
ffffffffc0201b28:	dcc50513          	addi	a0,a0,-564 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201b2c:	e9cfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201b30:	00004697          	auipc	a3,0x4
ffffffffc0201b34:	f8068693          	addi	a3,a3,-128 # ffffffffc0205ab0 <commands+0x948>
ffffffffc0201b38:	00004617          	auipc	a2,0x4
ffffffffc0201b3c:	ea060613          	addi	a2,a2,-352 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201b40:	16a00593          	li	a1,362
ffffffffc0201b44:	00004517          	auipc	a0,0x4
ffffffffc0201b48:	dac50513          	addi	a0,a0,-596 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201b4c:	e7cfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201b50:	00004617          	auipc	a2,0x4
ffffffffc0201b54:	d7860613          	addi	a2,a2,-648 # ffffffffc02058c8 <commands+0x760>
ffffffffc0201b58:	16d00593          	li	a1,365
ffffffffc0201b5c:	00004517          	auipc	a0,0x4
ffffffffc0201b60:	d9450513          	addi	a0,a0,-620 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201b64:	e64fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201b68:	00004697          	auipc	a3,0x4
ffffffffc0201b6c:	f6068693          	addi	a3,a3,-160 # ffffffffc0205ac8 <commands+0x960>
ffffffffc0201b70:	00004617          	auipc	a2,0x4
ffffffffc0201b74:	e6860613          	addi	a2,a2,-408 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201b78:	16b00593          	li	a1,363
ffffffffc0201b7c:	00004517          	auipc	a0,0x4
ffffffffc0201b80:	d7450513          	addi	a0,a0,-652 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201b84:	e44fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201b88:	00004697          	auipc	a3,0x4
ffffffffc0201b8c:	fb868693          	addi	a3,a3,-72 # ffffffffc0205b40 <commands+0x9d8>
ffffffffc0201b90:	00004617          	auipc	a2,0x4
ffffffffc0201b94:	e4860613          	addi	a2,a2,-440 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201b98:	17300593          	li	a1,371
ffffffffc0201b9c:	00004517          	auipc	a0,0x4
ffffffffc0201ba0:	d5450513          	addi	a0,a0,-684 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201ba4:	e24fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201ba8:	00004697          	auipc	a3,0x4
ffffffffc0201bac:	27868693          	addi	a3,a3,632 # ffffffffc0205e20 <commands+0xcb8>
ffffffffc0201bb0:	00004617          	auipc	a2,0x4
ffffffffc0201bb4:	e2860613          	addi	a2,a2,-472 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201bb8:	1af00593          	li	a1,431
ffffffffc0201bbc:	00004517          	auipc	a0,0x4
ffffffffc0201bc0:	d3450513          	addi	a0,a0,-716 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201bc4:	e04fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201bc8:	00004697          	auipc	a3,0x4
ffffffffc0201bcc:	22068693          	addi	a3,a3,544 # ffffffffc0205de8 <commands+0xc80>
ffffffffc0201bd0:	00004617          	auipc	a2,0x4
ffffffffc0201bd4:	e0860613          	addi	a2,a2,-504 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201bd8:	1ac00593          	li	a1,428
ffffffffc0201bdc:	00004517          	auipc	a0,0x4
ffffffffc0201be0:	d1450513          	addi	a0,a0,-748 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201be4:	de4fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201be8:	00004697          	auipc	a3,0x4
ffffffffc0201bec:	1d068693          	addi	a3,a3,464 # ffffffffc0205db8 <commands+0xc50>
ffffffffc0201bf0:	00004617          	auipc	a2,0x4
ffffffffc0201bf4:	de860613          	addi	a2,a2,-536 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201bf8:	1a800593          	li	a1,424
ffffffffc0201bfc:	00004517          	auipc	a0,0x4
ffffffffc0201c00:	cf450513          	addi	a0,a0,-780 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201c04:	dc4fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201c08 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201c08:	12058073          	sfence.vma	a1
}
ffffffffc0201c0c:	8082                	ret

ffffffffc0201c0e <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201c0e:	7179                	addi	sp,sp,-48
ffffffffc0201c10:	e84a                	sd	s2,16(sp)
ffffffffc0201c12:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0201c14:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201c16:	f022                	sd	s0,32(sp)
ffffffffc0201c18:	ec26                	sd	s1,24(sp)
ffffffffc0201c1a:	e44e                	sd	s3,8(sp)
ffffffffc0201c1c:	f406                	sd	ra,40(sp)
ffffffffc0201c1e:	84ae                	mv	s1,a1
ffffffffc0201c20:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0201c22:	f89fe0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0201c26:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0201c28:	cd09                	beqz	a0,ffffffffc0201c42 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0201c2a:	85aa                	mv	a1,a0
ffffffffc0201c2c:	86ce                	mv	a3,s3
ffffffffc0201c2e:	8626                	mv	a2,s1
ffffffffc0201c30:	854a                	mv	a0,s2
ffffffffc0201c32:	b46ff0ef          	jal	ra,ffffffffc0200f78 <page_insert>
ffffffffc0201c36:	ed21                	bnez	a0,ffffffffc0201c8e <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0201c38:	00014797          	auipc	a5,0x14
ffffffffc0201c3c:	9707a783          	lw	a5,-1680(a5) # ffffffffc02155a8 <swap_init_ok>
ffffffffc0201c40:	eb89                	bnez	a5,ffffffffc0201c52 <pgdir_alloc_page+0x44>
}
ffffffffc0201c42:	70a2                	ld	ra,40(sp)
ffffffffc0201c44:	8522                	mv	a0,s0
ffffffffc0201c46:	7402                	ld	s0,32(sp)
ffffffffc0201c48:	64e2                	ld	s1,24(sp)
ffffffffc0201c4a:	6942                	ld	s2,16(sp)
ffffffffc0201c4c:	69a2                	ld	s3,8(sp)
ffffffffc0201c4e:	6145                	addi	sp,sp,48
ffffffffc0201c50:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0201c52:	4681                	li	a3,0
ffffffffc0201c54:	8622                	mv	a2,s0
ffffffffc0201c56:	85a6                	mv	a1,s1
ffffffffc0201c58:	00014517          	auipc	a0,0x14
ffffffffc0201c5c:	92853503          	ld	a0,-1752(a0) # ffffffffc0215580 <check_mm_struct>
ffffffffc0201c60:	01b010ef          	jal	ra,ffffffffc020347a <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0201c64:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0201c66:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0201c68:	4785                	li	a5,1
ffffffffc0201c6a:	fcf70ce3          	beq	a4,a5,ffffffffc0201c42 <pgdir_alloc_page+0x34>
ffffffffc0201c6e:	00004697          	auipc	a3,0x4
ffffffffc0201c72:	1fa68693          	addi	a3,a3,506 # ffffffffc0205e68 <commands+0xd00>
ffffffffc0201c76:	00004617          	auipc	a2,0x4
ffffffffc0201c7a:	d6260613          	addi	a2,a2,-670 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201c7e:	14800593          	li	a1,328
ffffffffc0201c82:	00004517          	auipc	a0,0x4
ffffffffc0201c86:	c6e50513          	addi	a0,a0,-914 # ffffffffc02058f0 <commands+0x788>
ffffffffc0201c8a:	d3efe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c8e:	100027f3          	csrr	a5,sstatus
ffffffffc0201c92:	8b89                	andi	a5,a5,2
ffffffffc0201c94:	eb99                	bnez	a5,ffffffffc0201caa <pgdir_alloc_page+0x9c>
        pmm_manager->free_pages(base, n);
ffffffffc0201c96:	00014797          	auipc	a5,0x14
ffffffffc0201c9a:	8da7b783          	ld	a5,-1830(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201c9e:	739c                	ld	a5,32(a5)
ffffffffc0201ca0:	8522                	mv	a0,s0
ffffffffc0201ca2:	4585                	li	a1,1
ffffffffc0201ca4:	9782                	jalr	a5
            return NULL;
ffffffffc0201ca6:	4401                	li	s0,0
ffffffffc0201ca8:	bf69                	j	ffffffffc0201c42 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0201caa:	91bfe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201cae:	00014797          	auipc	a5,0x14
ffffffffc0201cb2:	8c27b783          	ld	a5,-1854(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201cb6:	739c                	ld	a5,32(a5)
ffffffffc0201cb8:	8522                	mv	a0,s0
ffffffffc0201cba:	4585                	li	a1,1
ffffffffc0201cbc:	9782                	jalr	a5
            return NULL;
ffffffffc0201cbe:	4401                	li	s0,0
        intr_enable();
ffffffffc0201cc0:	8fffe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0201cc4:	bfbd                	j	ffffffffc0201c42 <pgdir_alloc_page+0x34>

ffffffffc0201cc6 <_fifo_init_mm>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201cc6:	0000f797          	auipc	a5,0xf
ffffffffc0201cca:	79a78793          	addi	a5,a5,1946 # ffffffffc0211460 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0201cce:	f51c                	sd	a5,40(a0)
ffffffffc0201cd0:	e79c                	sd	a5,8(a5)
ffffffffc0201cd2:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0201cd4:	4501                	li	a0,0
ffffffffc0201cd6:	8082                	ret

ffffffffc0201cd8 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0201cd8:	4501                	li	a0,0
ffffffffc0201cda:	8082                	ret

ffffffffc0201cdc <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0201cdc:	4501                	li	a0,0
ffffffffc0201cde:	8082                	ret

ffffffffc0201ce0 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0201ce0:	4501                	li	a0,0
ffffffffc0201ce2:	8082                	ret

ffffffffc0201ce4 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0201ce4:	711d                	addi	sp,sp,-96
ffffffffc0201ce6:	fc4e                	sd	s3,56(sp)
ffffffffc0201ce8:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201cea:	00004517          	auipc	a0,0x4
ffffffffc0201cee:	19650513          	addi	a0,a0,406 # ffffffffc0205e80 <commands+0xd18>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201cf2:	698d                	lui	s3,0x3
ffffffffc0201cf4:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0201cf6:	e0ca                	sd	s2,64(sp)
ffffffffc0201cf8:	ec86                	sd	ra,88(sp)
ffffffffc0201cfa:	e8a2                	sd	s0,80(sp)
ffffffffc0201cfc:	e4a6                	sd	s1,72(sp)
ffffffffc0201cfe:	f456                	sd	s5,40(sp)
ffffffffc0201d00:	f05a                	sd	s6,32(sp)
ffffffffc0201d02:	ec5e                	sd	s7,24(sp)
ffffffffc0201d04:	e862                	sd	s8,16(sp)
ffffffffc0201d06:	e466                	sd	s9,8(sp)
ffffffffc0201d08:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201d0a:	bc2fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201d0e:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0201d12:	00014917          	auipc	s2,0x14
ffffffffc0201d16:	87692903          	lw	s2,-1930(s2) # ffffffffc0215588 <pgfault_num>
ffffffffc0201d1a:	4791                	li	a5,4
ffffffffc0201d1c:	14f91e63          	bne	s2,a5,ffffffffc0201e78 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201d20:	00004517          	auipc	a0,0x4
ffffffffc0201d24:	1b050513          	addi	a0,a0,432 # ffffffffc0205ed0 <commands+0xd68>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201d28:	6a85                	lui	s5,0x1
ffffffffc0201d2a:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201d2c:	ba0fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201d30:	00014417          	auipc	s0,0x14
ffffffffc0201d34:	85840413          	addi	s0,s0,-1960 # ffffffffc0215588 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201d38:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0201d3c:	4004                	lw	s1,0(s0)
ffffffffc0201d3e:	2481                	sext.w	s1,s1
ffffffffc0201d40:	2b249c63          	bne	s1,s2,ffffffffc0201ff8 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201d44:	00004517          	auipc	a0,0x4
ffffffffc0201d48:	1b450513          	addi	a0,a0,436 # ffffffffc0205ef8 <commands+0xd90>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201d4c:	6b91                	lui	s7,0x4
ffffffffc0201d4e:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201d50:	b7cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201d54:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0201d58:	00042903          	lw	s2,0(s0)
ffffffffc0201d5c:	2901                	sext.w	s2,s2
ffffffffc0201d5e:	26991d63          	bne	s2,s1,ffffffffc0201fd8 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201d62:	00004517          	auipc	a0,0x4
ffffffffc0201d66:	1be50513          	addi	a0,a0,446 # ffffffffc0205f20 <commands+0xdb8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201d6a:	6c89                	lui	s9,0x2
ffffffffc0201d6c:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201d6e:	b5efe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201d72:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0201d76:	401c                	lw	a5,0(s0)
ffffffffc0201d78:	2781                	sext.w	a5,a5
ffffffffc0201d7a:	23279f63          	bne	a5,s2,ffffffffc0201fb8 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201d7e:	00004517          	auipc	a0,0x4
ffffffffc0201d82:	1ca50513          	addi	a0,a0,458 # ffffffffc0205f48 <commands+0xde0>
ffffffffc0201d86:	b46fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201d8a:	6795                	lui	a5,0x5
ffffffffc0201d8c:	4739                	li	a4,14
ffffffffc0201d8e:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0201d92:	4004                	lw	s1,0(s0)
ffffffffc0201d94:	4795                	li	a5,5
ffffffffc0201d96:	2481                	sext.w	s1,s1
ffffffffc0201d98:	20f49063          	bne	s1,a5,ffffffffc0201f98 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201d9c:	00004517          	auipc	a0,0x4
ffffffffc0201da0:	18450513          	addi	a0,a0,388 # ffffffffc0205f20 <commands+0xdb8>
ffffffffc0201da4:	b28fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201da8:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0201dac:	401c                	lw	a5,0(s0)
ffffffffc0201dae:	2781                	sext.w	a5,a5
ffffffffc0201db0:	1c979463          	bne	a5,s1,ffffffffc0201f78 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201db4:	00004517          	auipc	a0,0x4
ffffffffc0201db8:	11c50513          	addi	a0,a0,284 # ffffffffc0205ed0 <commands+0xd68>
ffffffffc0201dbc:	b10fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201dc0:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0201dc4:	401c                	lw	a5,0(s0)
ffffffffc0201dc6:	4719                	li	a4,6
ffffffffc0201dc8:	2781                	sext.w	a5,a5
ffffffffc0201dca:	18e79763          	bne	a5,a4,ffffffffc0201f58 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201dce:	00004517          	auipc	a0,0x4
ffffffffc0201dd2:	15250513          	addi	a0,a0,338 # ffffffffc0205f20 <commands+0xdb8>
ffffffffc0201dd6:	af6fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201dda:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0201dde:	401c                	lw	a5,0(s0)
ffffffffc0201de0:	471d                	li	a4,7
ffffffffc0201de2:	2781                	sext.w	a5,a5
ffffffffc0201de4:	14e79a63          	bne	a5,a4,ffffffffc0201f38 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201de8:	00004517          	auipc	a0,0x4
ffffffffc0201dec:	09850513          	addi	a0,a0,152 # ffffffffc0205e80 <commands+0xd18>
ffffffffc0201df0:	adcfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201df4:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0201df8:	401c                	lw	a5,0(s0)
ffffffffc0201dfa:	4721                	li	a4,8
ffffffffc0201dfc:	2781                	sext.w	a5,a5
ffffffffc0201dfe:	10e79d63          	bne	a5,a4,ffffffffc0201f18 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201e02:	00004517          	auipc	a0,0x4
ffffffffc0201e06:	0f650513          	addi	a0,a0,246 # ffffffffc0205ef8 <commands+0xd90>
ffffffffc0201e0a:	ac2fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201e0e:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0201e12:	401c                	lw	a5,0(s0)
ffffffffc0201e14:	4725                	li	a4,9
ffffffffc0201e16:	2781                	sext.w	a5,a5
ffffffffc0201e18:	0ee79063          	bne	a5,a4,ffffffffc0201ef8 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201e1c:	00004517          	auipc	a0,0x4
ffffffffc0201e20:	12c50513          	addi	a0,a0,300 # ffffffffc0205f48 <commands+0xde0>
ffffffffc0201e24:	aa8fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201e28:	6795                	lui	a5,0x5
ffffffffc0201e2a:	4739                	li	a4,14
ffffffffc0201e2c:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0201e30:	4004                	lw	s1,0(s0)
ffffffffc0201e32:	47a9                	li	a5,10
ffffffffc0201e34:	2481                	sext.w	s1,s1
ffffffffc0201e36:	0af49163          	bne	s1,a5,ffffffffc0201ed8 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201e3a:	00004517          	auipc	a0,0x4
ffffffffc0201e3e:	09650513          	addi	a0,a0,150 # ffffffffc0205ed0 <commands+0xd68>
ffffffffc0201e42:	a8afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201e46:	6785                	lui	a5,0x1
ffffffffc0201e48:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201e4c:	06979663          	bne	a5,s1,ffffffffc0201eb8 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0201e50:	401c                	lw	a5,0(s0)
ffffffffc0201e52:	472d                	li	a4,11
ffffffffc0201e54:	2781                	sext.w	a5,a5
ffffffffc0201e56:	04e79163          	bne	a5,a4,ffffffffc0201e98 <_fifo_check_swap+0x1b4>
}
ffffffffc0201e5a:	60e6                	ld	ra,88(sp)
ffffffffc0201e5c:	6446                	ld	s0,80(sp)
ffffffffc0201e5e:	64a6                	ld	s1,72(sp)
ffffffffc0201e60:	6906                	ld	s2,64(sp)
ffffffffc0201e62:	79e2                	ld	s3,56(sp)
ffffffffc0201e64:	7a42                	ld	s4,48(sp)
ffffffffc0201e66:	7aa2                	ld	s5,40(sp)
ffffffffc0201e68:	7b02                	ld	s6,32(sp)
ffffffffc0201e6a:	6be2                	ld	s7,24(sp)
ffffffffc0201e6c:	6c42                	ld	s8,16(sp)
ffffffffc0201e6e:	6ca2                	ld	s9,8(sp)
ffffffffc0201e70:	6d02                	ld	s10,0(sp)
ffffffffc0201e72:	4501                	li	a0,0
ffffffffc0201e74:	6125                	addi	sp,sp,96
ffffffffc0201e76:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0201e78:	00004697          	auipc	a3,0x4
ffffffffc0201e7c:	03068693          	addi	a3,a3,48 # ffffffffc0205ea8 <commands+0xd40>
ffffffffc0201e80:	00004617          	auipc	a2,0x4
ffffffffc0201e84:	b5860613          	addi	a2,a2,-1192 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201e88:	05100593          	li	a1,81
ffffffffc0201e8c:	00004517          	auipc	a0,0x4
ffffffffc0201e90:	02c50513          	addi	a0,a0,44 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0201e94:	b34fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==11);
ffffffffc0201e98:	00004697          	auipc	a3,0x4
ffffffffc0201e9c:	16068693          	addi	a3,a3,352 # ffffffffc0205ff8 <commands+0xe90>
ffffffffc0201ea0:	00004617          	auipc	a2,0x4
ffffffffc0201ea4:	b3860613          	addi	a2,a2,-1224 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201ea8:	07300593          	li	a1,115
ffffffffc0201eac:	00004517          	auipc	a0,0x4
ffffffffc0201eb0:	00c50513          	addi	a0,a0,12 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0201eb4:	b14fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201eb8:	00004697          	auipc	a3,0x4
ffffffffc0201ebc:	11868693          	addi	a3,a3,280 # ffffffffc0205fd0 <commands+0xe68>
ffffffffc0201ec0:	00004617          	auipc	a2,0x4
ffffffffc0201ec4:	b1860613          	addi	a2,a2,-1256 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201ec8:	07100593          	li	a1,113
ffffffffc0201ecc:	00004517          	auipc	a0,0x4
ffffffffc0201ed0:	fec50513          	addi	a0,a0,-20 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0201ed4:	af4fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==10);
ffffffffc0201ed8:	00004697          	auipc	a3,0x4
ffffffffc0201edc:	0e868693          	addi	a3,a3,232 # ffffffffc0205fc0 <commands+0xe58>
ffffffffc0201ee0:	00004617          	auipc	a2,0x4
ffffffffc0201ee4:	af860613          	addi	a2,a2,-1288 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201ee8:	06f00593          	li	a1,111
ffffffffc0201eec:	00004517          	auipc	a0,0x4
ffffffffc0201ef0:	fcc50513          	addi	a0,a0,-52 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0201ef4:	ad4fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==9);
ffffffffc0201ef8:	00004697          	auipc	a3,0x4
ffffffffc0201efc:	0b868693          	addi	a3,a3,184 # ffffffffc0205fb0 <commands+0xe48>
ffffffffc0201f00:	00004617          	auipc	a2,0x4
ffffffffc0201f04:	ad860613          	addi	a2,a2,-1320 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201f08:	06c00593          	li	a1,108
ffffffffc0201f0c:	00004517          	auipc	a0,0x4
ffffffffc0201f10:	fac50513          	addi	a0,a0,-84 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0201f14:	ab4fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==8);
ffffffffc0201f18:	00004697          	auipc	a3,0x4
ffffffffc0201f1c:	08868693          	addi	a3,a3,136 # ffffffffc0205fa0 <commands+0xe38>
ffffffffc0201f20:	00004617          	auipc	a2,0x4
ffffffffc0201f24:	ab860613          	addi	a2,a2,-1352 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201f28:	06900593          	li	a1,105
ffffffffc0201f2c:	00004517          	auipc	a0,0x4
ffffffffc0201f30:	f8c50513          	addi	a0,a0,-116 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0201f34:	a94fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==7);
ffffffffc0201f38:	00004697          	auipc	a3,0x4
ffffffffc0201f3c:	05868693          	addi	a3,a3,88 # ffffffffc0205f90 <commands+0xe28>
ffffffffc0201f40:	00004617          	auipc	a2,0x4
ffffffffc0201f44:	a9860613          	addi	a2,a2,-1384 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201f48:	06600593          	li	a1,102
ffffffffc0201f4c:	00004517          	auipc	a0,0x4
ffffffffc0201f50:	f6c50513          	addi	a0,a0,-148 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0201f54:	a74fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==6);
ffffffffc0201f58:	00004697          	auipc	a3,0x4
ffffffffc0201f5c:	02868693          	addi	a3,a3,40 # ffffffffc0205f80 <commands+0xe18>
ffffffffc0201f60:	00004617          	auipc	a2,0x4
ffffffffc0201f64:	a7860613          	addi	a2,a2,-1416 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201f68:	06300593          	li	a1,99
ffffffffc0201f6c:	00004517          	auipc	a0,0x4
ffffffffc0201f70:	f4c50513          	addi	a0,a0,-180 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0201f74:	a54fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==5);
ffffffffc0201f78:	00004697          	auipc	a3,0x4
ffffffffc0201f7c:	ff868693          	addi	a3,a3,-8 # ffffffffc0205f70 <commands+0xe08>
ffffffffc0201f80:	00004617          	auipc	a2,0x4
ffffffffc0201f84:	a5860613          	addi	a2,a2,-1448 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201f88:	06000593          	li	a1,96
ffffffffc0201f8c:	00004517          	auipc	a0,0x4
ffffffffc0201f90:	f2c50513          	addi	a0,a0,-212 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0201f94:	a34fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==5);
ffffffffc0201f98:	00004697          	auipc	a3,0x4
ffffffffc0201f9c:	fd868693          	addi	a3,a3,-40 # ffffffffc0205f70 <commands+0xe08>
ffffffffc0201fa0:	00004617          	auipc	a2,0x4
ffffffffc0201fa4:	a3860613          	addi	a2,a2,-1480 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201fa8:	05d00593          	li	a1,93
ffffffffc0201fac:	00004517          	auipc	a0,0x4
ffffffffc0201fb0:	f0c50513          	addi	a0,a0,-244 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0201fb4:	a14fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc0201fb8:	00004697          	auipc	a3,0x4
ffffffffc0201fbc:	ef068693          	addi	a3,a3,-272 # ffffffffc0205ea8 <commands+0xd40>
ffffffffc0201fc0:	00004617          	auipc	a2,0x4
ffffffffc0201fc4:	a1860613          	addi	a2,a2,-1512 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201fc8:	05a00593          	li	a1,90
ffffffffc0201fcc:	00004517          	auipc	a0,0x4
ffffffffc0201fd0:	eec50513          	addi	a0,a0,-276 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0201fd4:	9f4fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc0201fd8:	00004697          	auipc	a3,0x4
ffffffffc0201fdc:	ed068693          	addi	a3,a3,-304 # ffffffffc0205ea8 <commands+0xd40>
ffffffffc0201fe0:	00004617          	auipc	a2,0x4
ffffffffc0201fe4:	9f860613          	addi	a2,a2,-1544 # ffffffffc02059d8 <commands+0x870>
ffffffffc0201fe8:	05700593          	li	a1,87
ffffffffc0201fec:	00004517          	auipc	a0,0x4
ffffffffc0201ff0:	ecc50513          	addi	a0,a0,-308 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0201ff4:	9d4fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc0201ff8:	00004697          	auipc	a3,0x4
ffffffffc0201ffc:	eb068693          	addi	a3,a3,-336 # ffffffffc0205ea8 <commands+0xd40>
ffffffffc0202000:	00004617          	auipc	a2,0x4
ffffffffc0202004:	9d860613          	addi	a2,a2,-1576 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202008:	05400593          	li	a1,84
ffffffffc020200c:	00004517          	auipc	a0,0x4
ffffffffc0202010:	eac50513          	addi	a0,a0,-340 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0202014:	9b4fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202018 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202018:	751c                	ld	a5,40(a0)
{
ffffffffc020201a:	1141                	addi	sp,sp,-16
ffffffffc020201c:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc020201e:	cf91                	beqz	a5,ffffffffc020203a <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0202020:	ee0d                	bnez	a2,ffffffffc020205a <_fifo_swap_out_victim+0x42>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0202022:	679c                	ld	a5,8(a5)
}
ffffffffc0202024:	60a2                	ld	ra,8(sp)
ffffffffc0202026:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0202028:	6394                	ld	a3,0(a5)
ffffffffc020202a:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc020202c:	fd878793          	addi	a5,a5,-40
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0202030:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0202032:	e314                	sd	a3,0(a4)
ffffffffc0202034:	e19c                	sd	a5,0(a1)
}
ffffffffc0202036:	0141                	addi	sp,sp,16
ffffffffc0202038:	8082                	ret
         assert(head != NULL);
ffffffffc020203a:	00004697          	auipc	a3,0x4
ffffffffc020203e:	fce68693          	addi	a3,a3,-50 # ffffffffc0206008 <commands+0xea0>
ffffffffc0202042:	00004617          	auipc	a2,0x4
ffffffffc0202046:	99660613          	addi	a2,a2,-1642 # ffffffffc02059d8 <commands+0x870>
ffffffffc020204a:	04100593          	li	a1,65
ffffffffc020204e:	00004517          	auipc	a0,0x4
ffffffffc0202052:	e6a50513          	addi	a0,a0,-406 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0202056:	972fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(in_tick==0);
ffffffffc020205a:	00004697          	auipc	a3,0x4
ffffffffc020205e:	fbe68693          	addi	a3,a3,-66 # ffffffffc0206018 <commands+0xeb0>
ffffffffc0202062:	00004617          	auipc	a2,0x4
ffffffffc0202066:	97660613          	addi	a2,a2,-1674 # ffffffffc02059d8 <commands+0x870>
ffffffffc020206a:	04200593          	li	a1,66
ffffffffc020206e:	00004517          	auipc	a0,0x4
ffffffffc0202072:	e4a50513          	addi	a0,a0,-438 # ffffffffc0205eb8 <commands+0xd50>
ffffffffc0202076:	952fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020207a <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020207a:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020207c:	cb91                	beqz	a5,ffffffffc0202090 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020207e:	6394                	ld	a3,0(a5)
ffffffffc0202080:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0202084:	e398                	sd	a4,0(a5)
ffffffffc0202086:	e698                	sd	a4,8(a3)
}
ffffffffc0202088:	4501                	li	a0,0
    elm->next = next;
ffffffffc020208a:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020208c:	f614                	sd	a3,40(a2)
ffffffffc020208e:	8082                	ret
{
ffffffffc0202090:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0202092:	00004697          	auipc	a3,0x4
ffffffffc0202096:	f9668693          	addi	a3,a3,-106 # ffffffffc0206028 <commands+0xec0>
ffffffffc020209a:	00004617          	auipc	a2,0x4
ffffffffc020209e:	93e60613          	addi	a2,a2,-1730 # ffffffffc02059d8 <commands+0x870>
ffffffffc02020a2:	03200593          	li	a1,50
ffffffffc02020a6:	00004517          	auipc	a0,0x4
ffffffffc02020aa:	e1250513          	addi	a0,a0,-494 # ffffffffc0205eb8 <commands+0xd50>
{
ffffffffc02020ae:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02020b0:	918fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02020b4 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02020b4:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02020b6:	00004697          	auipc	a3,0x4
ffffffffc02020ba:	faa68693          	addi	a3,a3,-86 # ffffffffc0206060 <commands+0xef8>
ffffffffc02020be:	00004617          	auipc	a2,0x4
ffffffffc02020c2:	91a60613          	addi	a2,a2,-1766 # ffffffffc02059d8 <commands+0x870>
ffffffffc02020c6:	07e00593          	li	a1,126
ffffffffc02020ca:	00004517          	auipc	a0,0x4
ffffffffc02020ce:	fb650513          	addi	a0,a0,-74 # ffffffffc0206080 <commands+0xf18>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02020d2:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02020d4:	8f4fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02020d8 <mm_create>:
mm_create(void) {
ffffffffc02020d8:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02020da:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02020de:	e022                	sd	s0,0(sp)
ffffffffc02020e0:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02020e2:	28d000ef          	jal	ra,ffffffffc0202b6e <kmalloc>
ffffffffc02020e6:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02020e8:	c105                	beqz	a0,ffffffffc0202108 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc02020ea:	e408                	sd	a0,8(s0)
ffffffffc02020ec:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02020ee:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02020f2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02020f6:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02020fa:	00013797          	auipc	a5,0x13
ffffffffc02020fe:	4ae7a783          	lw	a5,1198(a5) # ffffffffc02155a8 <swap_init_ok>
ffffffffc0202102:	eb81                	bnez	a5,ffffffffc0202112 <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0202104:	02053423          	sd	zero,40(a0)
}
ffffffffc0202108:	60a2                	ld	ra,8(sp)
ffffffffc020210a:	8522                	mv	a0,s0
ffffffffc020210c:	6402                	ld	s0,0(sp)
ffffffffc020210e:	0141                	addi	sp,sp,16
ffffffffc0202110:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202112:	35c010ef          	jal	ra,ffffffffc020346e <swap_init_mm>
}
ffffffffc0202116:	60a2                	ld	ra,8(sp)
ffffffffc0202118:	8522                	mv	a0,s0
ffffffffc020211a:	6402                	ld	s0,0(sp)
ffffffffc020211c:	0141                	addi	sp,sp,16
ffffffffc020211e:	8082                	ret

ffffffffc0202120 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0202120:	1101                	addi	sp,sp,-32
ffffffffc0202122:	e04a                	sd	s2,0(sp)
ffffffffc0202124:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202126:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020212a:	e822                	sd	s0,16(sp)
ffffffffc020212c:	e426                	sd	s1,8(sp)
ffffffffc020212e:	ec06                	sd	ra,24(sp)
ffffffffc0202130:	84ae                	mv	s1,a1
ffffffffc0202132:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202134:	23b000ef          	jal	ra,ffffffffc0202b6e <kmalloc>
    if (vma != NULL) {
ffffffffc0202138:	c509                	beqz	a0,ffffffffc0202142 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020213a:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020213e:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202140:	cd00                	sw	s0,24(a0)
}
ffffffffc0202142:	60e2                	ld	ra,24(sp)
ffffffffc0202144:	6442                	ld	s0,16(sp)
ffffffffc0202146:	64a2                	ld	s1,8(sp)
ffffffffc0202148:	6902                	ld	s2,0(sp)
ffffffffc020214a:	6105                	addi	sp,sp,32
ffffffffc020214c:	8082                	ret

ffffffffc020214e <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc020214e:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0202150:	c505                	beqz	a0,ffffffffc0202178 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0202152:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202154:	c501                	beqz	a0,ffffffffc020215c <find_vma+0xe>
ffffffffc0202156:	651c                	ld	a5,8(a0)
ffffffffc0202158:	02f5f263          	bgeu	a1,a5,ffffffffc020217c <find_vma+0x2e>
    return listelm->next;
ffffffffc020215c:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc020215e:	00f68d63          	beq	a3,a5,ffffffffc0202178 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0202162:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202166:	00e5e663          	bltu	a1,a4,ffffffffc0202172 <find_vma+0x24>
ffffffffc020216a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020216e:	00e5ec63          	bltu	a1,a4,ffffffffc0202186 <find_vma+0x38>
ffffffffc0202172:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0202174:	fef697e3          	bne	a3,a5,ffffffffc0202162 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0202178:	4501                	li	a0,0
}
ffffffffc020217a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020217c:	691c                	ld	a5,16(a0)
ffffffffc020217e:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020215c <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0202182:	ea88                	sd	a0,16(a3)
ffffffffc0202184:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0202186:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020218a:	ea88                	sd	a0,16(a3)
ffffffffc020218c:	8082                	ret

ffffffffc020218e <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020218e:	6590                	ld	a2,8(a1)
ffffffffc0202190:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0202194:	1141                	addi	sp,sp,-16
ffffffffc0202196:	e406                	sd	ra,8(sp)
ffffffffc0202198:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020219a:	01066763          	bltu	a2,a6,ffffffffc02021a8 <insert_vma_struct+0x1a>
ffffffffc020219e:	a085                	j	ffffffffc02021fe <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02021a0:	fe87b703          	ld	a4,-24(a5)
ffffffffc02021a4:	04e66863          	bltu	a2,a4,ffffffffc02021f4 <insert_vma_struct+0x66>
ffffffffc02021a8:	86be                	mv	a3,a5
ffffffffc02021aa:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02021ac:	fef51ae3          	bne	a0,a5,ffffffffc02021a0 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02021b0:	02a68463          	beq	a3,a0,ffffffffc02021d8 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02021b4:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02021b8:	fe86b883          	ld	a7,-24(a3)
ffffffffc02021bc:	08e8f163          	bgeu	a7,a4,ffffffffc020223e <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02021c0:	04e66f63          	bltu	a2,a4,ffffffffc020221e <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02021c4:	00f50a63          	beq	a0,a5,ffffffffc02021d8 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02021c8:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02021cc:	05076963          	bltu	a4,a6,ffffffffc020221e <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02021d0:	ff07b603          	ld	a2,-16(a5)
ffffffffc02021d4:	02c77363          	bgeu	a4,a2,ffffffffc02021fa <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02021d8:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02021da:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02021dc:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02021e0:	e390                	sd	a2,0(a5)
ffffffffc02021e2:	e690                	sd	a2,8(a3)
}
ffffffffc02021e4:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02021e6:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02021e8:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc02021ea:	0017079b          	addiw	a5,a4,1
ffffffffc02021ee:	d11c                	sw	a5,32(a0)
}
ffffffffc02021f0:	0141                	addi	sp,sp,16
ffffffffc02021f2:	8082                	ret
    if (le_prev != list) {
ffffffffc02021f4:	fca690e3          	bne	a3,a0,ffffffffc02021b4 <insert_vma_struct+0x26>
ffffffffc02021f8:	bfd1                	j	ffffffffc02021cc <insert_vma_struct+0x3e>
ffffffffc02021fa:	ebbff0ef          	jal	ra,ffffffffc02020b4 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02021fe:	00004697          	auipc	a3,0x4
ffffffffc0202202:	e9268693          	addi	a3,a3,-366 # ffffffffc0206090 <commands+0xf28>
ffffffffc0202206:	00003617          	auipc	a2,0x3
ffffffffc020220a:	7d260613          	addi	a2,a2,2002 # ffffffffc02059d8 <commands+0x870>
ffffffffc020220e:	08500593          	li	a1,133
ffffffffc0202212:	00004517          	auipc	a0,0x4
ffffffffc0202216:	e6e50513          	addi	a0,a0,-402 # ffffffffc0206080 <commands+0xf18>
ffffffffc020221a:	faffd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020221e:	00004697          	auipc	a3,0x4
ffffffffc0202222:	eb268693          	addi	a3,a3,-334 # ffffffffc02060d0 <commands+0xf68>
ffffffffc0202226:	00003617          	auipc	a2,0x3
ffffffffc020222a:	7b260613          	addi	a2,a2,1970 # ffffffffc02059d8 <commands+0x870>
ffffffffc020222e:	07d00593          	li	a1,125
ffffffffc0202232:	00004517          	auipc	a0,0x4
ffffffffc0202236:	e4e50513          	addi	a0,a0,-434 # ffffffffc0206080 <commands+0xf18>
ffffffffc020223a:	f8ffd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020223e:	00004697          	auipc	a3,0x4
ffffffffc0202242:	e7268693          	addi	a3,a3,-398 # ffffffffc02060b0 <commands+0xf48>
ffffffffc0202246:	00003617          	auipc	a2,0x3
ffffffffc020224a:	79260613          	addi	a2,a2,1938 # ffffffffc02059d8 <commands+0x870>
ffffffffc020224e:	07c00593          	li	a1,124
ffffffffc0202252:	00004517          	auipc	a0,0x4
ffffffffc0202256:	e2e50513          	addi	a0,a0,-466 # ffffffffc0206080 <commands+0xf18>
ffffffffc020225a:	f6ffd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020225e <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc020225e:	1141                	addi	sp,sp,-16
ffffffffc0202260:	e022                	sd	s0,0(sp)
ffffffffc0202262:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0202264:	6508                	ld	a0,8(a0)
ffffffffc0202266:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0202268:	00a40c63          	beq	s0,a0,ffffffffc0202280 <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc020226c:	6118                	ld	a4,0(a0)
ffffffffc020226e:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0202270:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0202272:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202274:	e398                	sd	a4,0(a5)
ffffffffc0202276:	1a9000ef          	jal	ra,ffffffffc0202c1e <kfree>
    return listelm->next;
ffffffffc020227a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020227c:	fea418e3          	bne	s0,a0,ffffffffc020226c <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0202280:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0202282:	6402                	ld	s0,0(sp)
ffffffffc0202284:	60a2                	ld	ra,8(sp)
ffffffffc0202286:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0202288:	1970006f          	j	ffffffffc0202c1e <kfree>

ffffffffc020228c <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020228c:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020228e:	03000513          	li	a0,48
vmm_init(void) {
ffffffffc0202292:	fc06                	sd	ra,56(sp)
ffffffffc0202294:	f822                	sd	s0,48(sp)
ffffffffc0202296:	f426                	sd	s1,40(sp)
ffffffffc0202298:	f04a                	sd	s2,32(sp)
ffffffffc020229a:	ec4e                	sd	s3,24(sp)
ffffffffc020229c:	e852                	sd	s4,16(sp)
ffffffffc020229e:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02022a0:	0cf000ef          	jal	ra,ffffffffc0202b6e <kmalloc>
    if (mm != NULL) {
ffffffffc02022a4:	58050e63          	beqz	a0,ffffffffc0202840 <vmm_init+0x5b4>
    elm->prev = elm->next = elm;
ffffffffc02022a8:	e508                	sd	a0,8(a0)
ffffffffc02022aa:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02022ac:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02022b0:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02022b4:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02022b8:	00013797          	auipc	a5,0x13
ffffffffc02022bc:	2f07a783          	lw	a5,752(a5) # ffffffffc02155a8 <swap_init_ok>
ffffffffc02022c0:	84aa                	mv	s1,a0
ffffffffc02022c2:	e7b9                	bnez	a5,ffffffffc0202310 <vmm_init+0x84>
        else mm->sm_priv = NULL;
ffffffffc02022c4:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc02022c8:	03200413          	li	s0,50
ffffffffc02022cc:	a811                	j	ffffffffc02022e0 <vmm_init+0x54>
        vma->vm_start = vm_start;
ffffffffc02022ce:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02022d0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02022d2:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02022d6:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02022d8:	8526                	mv	a0,s1
ffffffffc02022da:	eb5ff0ef          	jal	ra,ffffffffc020218e <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02022de:	cc05                	beqz	s0,ffffffffc0202316 <vmm_init+0x8a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02022e0:	03000513          	li	a0,48
ffffffffc02022e4:	08b000ef          	jal	ra,ffffffffc0202b6e <kmalloc>
ffffffffc02022e8:	85aa                	mv	a1,a0
ffffffffc02022ea:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02022ee:	f165                	bnez	a0,ffffffffc02022ce <vmm_init+0x42>
        assert(vma != NULL);
ffffffffc02022f0:	00004697          	auipc	a3,0x4
ffffffffc02022f4:	00068693          	mv	a3,a3
ffffffffc02022f8:	00003617          	auipc	a2,0x3
ffffffffc02022fc:	6e060613          	addi	a2,a2,1760 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202300:	0c900593          	li	a1,201
ffffffffc0202304:	00004517          	auipc	a0,0x4
ffffffffc0202308:	d7c50513          	addi	a0,a0,-644 # ffffffffc0206080 <commands+0xf18>
ffffffffc020230c:	ebdfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202310:	15e010ef          	jal	ra,ffffffffc020346e <swap_init_mm>
ffffffffc0202314:	bf55                	j	ffffffffc02022c8 <vmm_init+0x3c>
ffffffffc0202316:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020231a:	1f900913          	li	s2,505
ffffffffc020231e:	a819                	j	ffffffffc0202334 <vmm_init+0xa8>
        vma->vm_start = vm_start;
ffffffffc0202320:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202322:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202324:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202328:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020232a:	8526                	mv	a0,s1
ffffffffc020232c:	e63ff0ef          	jal	ra,ffffffffc020218e <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202330:	03240a63          	beq	s0,s2,ffffffffc0202364 <vmm_init+0xd8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202334:	03000513          	li	a0,48
ffffffffc0202338:	037000ef          	jal	ra,ffffffffc0202b6e <kmalloc>
ffffffffc020233c:	85aa                	mv	a1,a0
ffffffffc020233e:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0202342:	fd79                	bnez	a0,ffffffffc0202320 <vmm_init+0x94>
        assert(vma != NULL);
ffffffffc0202344:	00004697          	auipc	a3,0x4
ffffffffc0202348:	fac68693          	addi	a3,a3,-84 # ffffffffc02062f0 <commands+0x1188>
ffffffffc020234c:	00003617          	auipc	a2,0x3
ffffffffc0202350:	68c60613          	addi	a2,a2,1676 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202354:	0cf00593          	li	a1,207
ffffffffc0202358:	00004517          	auipc	a0,0x4
ffffffffc020235c:	d2850513          	addi	a0,a0,-728 # ffffffffc0206080 <commands+0xf18>
ffffffffc0202360:	e69fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return listelm->next;
ffffffffc0202364:	649c                	ld	a5,8(s1)
ffffffffc0202366:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0202368:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020236c:	30f48e63          	beq	s1,a5,ffffffffc0202688 <vmm_init+0x3fc>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202370:	fe87b683          	ld	a3,-24(a5)
ffffffffc0202374:	ffe70613          	addi	a2,a4,-2 # fffffffffff7fffe <end+0x3fd6aa32>
ffffffffc0202378:	2ad61863          	bne	a2,a3,ffffffffc0202628 <vmm_init+0x39c>
ffffffffc020237c:	ff07b683          	ld	a3,-16(a5)
ffffffffc0202380:	2ae69463          	bne	a3,a4,ffffffffc0202628 <vmm_init+0x39c>
    for (i = 1; i <= step2; i ++) {
ffffffffc0202384:	0715                	addi	a4,a4,5
ffffffffc0202386:	679c                	ld	a5,8(a5)
ffffffffc0202388:	feb712e3          	bne	a4,a1,ffffffffc020236c <vmm_init+0xe0>
ffffffffc020238c:	4a1d                	li	s4,7
ffffffffc020238e:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202390:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202394:	85a2                	mv	a1,s0
ffffffffc0202396:	8526                	mv	a0,s1
ffffffffc0202398:	db7ff0ef          	jal	ra,ffffffffc020214e <find_vma>
ffffffffc020239c:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc020239e:	34050563          	beqz	a0,ffffffffc02026e8 <vmm_init+0x45c>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02023a2:	00140593          	addi	a1,s0,1
ffffffffc02023a6:	8526                	mv	a0,s1
ffffffffc02023a8:	da7ff0ef          	jal	ra,ffffffffc020214e <find_vma>
ffffffffc02023ac:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02023ae:	34050d63          	beqz	a0,ffffffffc0202708 <vmm_init+0x47c>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02023b2:	85d2                	mv	a1,s4
ffffffffc02023b4:	8526                	mv	a0,s1
ffffffffc02023b6:	d99ff0ef          	jal	ra,ffffffffc020214e <find_vma>
        assert(vma3 == NULL);
ffffffffc02023ba:	36051763          	bnez	a0,ffffffffc0202728 <vmm_init+0x49c>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02023be:	00340593          	addi	a1,s0,3
ffffffffc02023c2:	8526                	mv	a0,s1
ffffffffc02023c4:	d8bff0ef          	jal	ra,ffffffffc020214e <find_vma>
        assert(vma4 == NULL);
ffffffffc02023c8:	2e051063          	bnez	a0,ffffffffc02026a8 <vmm_init+0x41c>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02023cc:	00440593          	addi	a1,s0,4
ffffffffc02023d0:	8526                	mv	a0,s1
ffffffffc02023d2:	d7dff0ef          	jal	ra,ffffffffc020214e <find_vma>
        assert(vma5 == NULL);
ffffffffc02023d6:	2e051963          	bnez	a0,ffffffffc02026c8 <vmm_init+0x43c>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02023da:	00893783          	ld	a5,8(s2)
ffffffffc02023de:	26879563          	bne	a5,s0,ffffffffc0202648 <vmm_init+0x3bc>
ffffffffc02023e2:	01093783          	ld	a5,16(s2)
ffffffffc02023e6:	27479163          	bne	a5,s4,ffffffffc0202648 <vmm_init+0x3bc>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02023ea:	0089b783          	ld	a5,8(s3)
ffffffffc02023ee:	26879d63          	bne	a5,s0,ffffffffc0202668 <vmm_init+0x3dc>
ffffffffc02023f2:	0109b783          	ld	a5,16(s3)
ffffffffc02023f6:	27479963          	bne	a5,s4,ffffffffc0202668 <vmm_init+0x3dc>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02023fa:	0415                	addi	s0,s0,5
ffffffffc02023fc:	0a15                	addi	s4,s4,5
ffffffffc02023fe:	f9541be3          	bne	s0,s5,ffffffffc0202394 <vmm_init+0x108>
ffffffffc0202402:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0202404:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0202406:	85a2                	mv	a1,s0
ffffffffc0202408:	8526                	mv	a0,s1
ffffffffc020240a:	d45ff0ef          	jal	ra,ffffffffc020214e <find_vma>
ffffffffc020240e:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0202412:	c90d                	beqz	a0,ffffffffc0202444 <vmm_init+0x1b8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0202414:	6914                	ld	a3,16(a0)
ffffffffc0202416:	6510                	ld	a2,8(a0)
ffffffffc0202418:	00004517          	auipc	a0,0x4
ffffffffc020241c:	dd850513          	addi	a0,a0,-552 # ffffffffc02061f0 <commands+0x1088>
ffffffffc0202420:	cadfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0202424:	00004697          	auipc	a3,0x4
ffffffffc0202428:	df468693          	addi	a3,a3,-524 # ffffffffc0206218 <commands+0x10b0>
ffffffffc020242c:	00003617          	auipc	a2,0x3
ffffffffc0202430:	5ac60613          	addi	a2,a2,1452 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202434:	0f100593          	li	a1,241
ffffffffc0202438:	00004517          	auipc	a0,0x4
ffffffffc020243c:	c4850513          	addi	a0,a0,-952 # ffffffffc0206080 <commands+0xf18>
ffffffffc0202440:	d89fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0202444:	147d                	addi	s0,s0,-1
ffffffffc0202446:	fd2410e3          	bne	s0,s2,ffffffffc0202406 <vmm_init+0x17a>
ffffffffc020244a:	a801                	j	ffffffffc020245a <vmm_init+0x1ce>
    __list_del(listelm->prev, listelm->next);
ffffffffc020244c:	6118                	ld	a4,0(a0)
ffffffffc020244e:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0202450:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0202452:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202454:	e398                	sd	a4,0(a5)
ffffffffc0202456:	7c8000ef          	jal	ra,ffffffffc0202c1e <kfree>
    return listelm->next;
ffffffffc020245a:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc020245c:	fea498e3          	bne	s1,a0,ffffffffc020244c <vmm_init+0x1c0>
    kfree(mm); //kfree mm
ffffffffc0202460:	8526                	mv	a0,s1
ffffffffc0202462:	7bc000ef          	jal	ra,ffffffffc0202c1e <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0202466:	00004517          	auipc	a0,0x4
ffffffffc020246a:	dca50513          	addi	a0,a0,-566 # ffffffffc0206230 <commands+0x10c8>
ffffffffc020246e:	c5ffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202472:	80bfe0ef          	jal	ra,ffffffffc0200c7c <nr_free_pages>
ffffffffc0202476:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202478:	03000513          	li	a0,48
ffffffffc020247c:	6f2000ef          	jal	ra,ffffffffc0202b6e <kmalloc>
ffffffffc0202480:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0202482:	2c050363          	beqz	a0,ffffffffc0202748 <vmm_init+0x4bc>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202486:	00013797          	auipc	a5,0x13
ffffffffc020248a:	1227a783          	lw	a5,290(a5) # ffffffffc02155a8 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc020248e:	e508                	sd	a0,8(a0)
ffffffffc0202490:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0202492:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0202496:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020249a:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020249e:	18079263          	bnez	a5,ffffffffc0202622 <vmm_init+0x396>
        else mm->sm_priv = NULL;
ffffffffc02024a2:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();
    assert(check_mm_struct != NULL);

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02024a6:	00013917          	auipc	s2,0x13
ffffffffc02024aa:	0b293903          	ld	s2,178(s2) # ffffffffc0215558 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02024ae:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc02024b2:	00013717          	auipc	a4,0x13
ffffffffc02024b6:	0c873723          	sd	s0,206(a4) # ffffffffc0215580 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02024ba:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc02024be:	36079163          	bnez	a5,ffffffffc0202820 <vmm_init+0x594>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02024c2:	03000513          	li	a0,48
ffffffffc02024c6:	6a8000ef          	jal	ra,ffffffffc0202b6e <kmalloc>
ffffffffc02024ca:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc02024cc:	2a050263          	beqz	a0,ffffffffc0202770 <vmm_init+0x4e4>
        vma->vm_end = vm_end;
ffffffffc02024d0:	002007b7          	lui	a5,0x200
ffffffffc02024d4:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc02024d8:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02024da:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02024dc:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc02024e0:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02024e2:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc02024e6:	ca9ff0ef          	jal	ra,ffffffffc020218e <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02024ea:	10000593          	li	a1,256
ffffffffc02024ee:	8522                	mv	a0,s0
ffffffffc02024f0:	c5fff0ef          	jal	ra,ffffffffc020214e <find_vma>
ffffffffc02024f4:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02024f8:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02024fc:	28a99a63          	bne	s3,a0,ffffffffc0202790 <vmm_init+0x504>
        *(char *)(addr + i) = i;
ffffffffc0202500:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0202504:	0785                	addi	a5,a5,1
ffffffffc0202506:	fee79de3          	bne	a5,a4,ffffffffc0202500 <vmm_init+0x274>
        sum += i;
ffffffffc020250a:	6705                	lui	a4,0x1
ffffffffc020250c:	10000793          	li	a5,256
ffffffffc0202510:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0202514:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0202518:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc020251c:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc020251e:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0202520:	fec79ce3          	bne	a5,a2,ffffffffc0202518 <vmm_init+0x28c>
    }
    assert(sum == 0);
ffffffffc0202524:	28071663          	bnez	a4,ffffffffc02027b0 <vmm_init+0x524>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202528:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020252c:	00013a97          	auipc	s5,0x13
ffffffffc0202530:	034a8a93          	addi	s5,s5,52 # ffffffffc0215560 <npage>
ffffffffc0202534:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202538:	078a                	slli	a5,a5,0x2
ffffffffc020253a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020253c:	28c7fa63          	bgeu	a5,a2,ffffffffc02027d0 <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0202540:	00005a17          	auipc	s4,0x5
ffffffffc0202544:	a80a3a03          	ld	s4,-1408(s4) # ffffffffc0206fc0 <nbase>
ffffffffc0202548:	414787b3          	sub	a5,a5,s4
ffffffffc020254c:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc020254e:	8799                	srai	a5,a5,0x6
ffffffffc0202550:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0202552:	00c79713          	slli	a4,a5,0xc
ffffffffc0202556:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202558:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020255c:	28c77663          	bgeu	a4,a2,ffffffffc02027e8 <vmm_init+0x55c>
ffffffffc0202560:	00013997          	auipc	s3,0x13
ffffffffc0202564:	0189b983          	ld	s3,24(s3) # ffffffffc0215578 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0202568:	4581                	li	a1,0
ffffffffc020256a:	854a                	mv	a0,s2
ffffffffc020256c:	99b6                	add	s3,s3,a3
ffffffffc020256e:	96ffe0ef          	jal	ra,ffffffffc0200edc <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202572:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202576:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020257a:	078a                	slli	a5,a5,0x2
ffffffffc020257c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020257e:	24e7f963          	bgeu	a5,a4,ffffffffc02027d0 <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0202582:	00013997          	auipc	s3,0x13
ffffffffc0202586:	fe698993          	addi	s3,s3,-26 # ffffffffc0215568 <pages>
ffffffffc020258a:	0009b503          	ld	a0,0(s3)
ffffffffc020258e:	414787b3          	sub	a5,a5,s4
ffffffffc0202592:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202594:	953e                	add	a0,a0,a5
ffffffffc0202596:	4585                	li	a1,1
ffffffffc0202598:	ea4fe0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020259c:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02025a0:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02025a4:	078a                	slli	a5,a5,0x2
ffffffffc02025a6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025a8:	22e7f463          	bgeu	a5,a4,ffffffffc02027d0 <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc02025ac:	0009b503          	ld	a0,0(s3)
ffffffffc02025b0:	414787b3          	sub	a5,a5,s4
ffffffffc02025b4:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02025b6:	4585                	li	a1,1
ffffffffc02025b8:	953e                	add	a0,a0,a5
ffffffffc02025ba:	e82fe0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    pgdir[0] = 0;
ffffffffc02025be:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc02025c2:	12000073          	sfence.vma
    return listelm->next;
ffffffffc02025c6:	6408                	ld	a0,8(s0)
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc02025c8:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02025cc:	00a40c63          	beq	s0,a0,ffffffffc02025e4 <vmm_init+0x358>
    __list_del(listelm->prev, listelm->next);
ffffffffc02025d0:	6118                	ld	a4,0(a0)
ffffffffc02025d2:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02025d4:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02025d6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02025d8:	e398                	sd	a4,0(a5)
ffffffffc02025da:	644000ef          	jal	ra,ffffffffc0202c1e <kfree>
    return listelm->next;
ffffffffc02025de:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02025e0:	fea418e3          	bne	s0,a0,ffffffffc02025d0 <vmm_init+0x344>
    kfree(mm); //kfree mm
ffffffffc02025e4:	8522                	mv	a0,s0
ffffffffc02025e6:	638000ef          	jal	ra,ffffffffc0202c1e <kfree>
    mm_destroy(mm);
    check_mm_struct = NULL;
ffffffffc02025ea:	00013797          	auipc	a5,0x13
ffffffffc02025ee:	f807bb23          	sd	zero,-106(a5) # ffffffffc0215580 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02025f2:	e8afe0ef          	jal	ra,ffffffffc0200c7c <nr_free_pages>
ffffffffc02025f6:	20a49563          	bne	s1,a0,ffffffffc0202800 <vmm_init+0x574>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02025fa:	00004517          	auipc	a0,0x4
ffffffffc02025fe:	cbe50513          	addi	a0,a0,-834 # ffffffffc02062b8 <commands+0x1150>
ffffffffc0202602:	acbfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0202606:	7442                	ld	s0,48(sp)
ffffffffc0202608:	70e2                	ld	ra,56(sp)
ffffffffc020260a:	74a2                	ld	s1,40(sp)
ffffffffc020260c:	7902                	ld	s2,32(sp)
ffffffffc020260e:	69e2                	ld	s3,24(sp)
ffffffffc0202610:	6a42                	ld	s4,16(sp)
ffffffffc0202612:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202614:	00004517          	auipc	a0,0x4
ffffffffc0202618:	cc450513          	addi	a0,a0,-828 # ffffffffc02062d8 <commands+0x1170>
}
ffffffffc020261c:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc020261e:	aaffd06f          	j	ffffffffc02000cc <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202622:	64d000ef          	jal	ra,ffffffffc020346e <swap_init_mm>
ffffffffc0202626:	b541                	j	ffffffffc02024a6 <vmm_init+0x21a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202628:	00004697          	auipc	a3,0x4
ffffffffc020262c:	ae068693          	addi	a3,a3,-1312 # ffffffffc0206108 <commands+0xfa0>
ffffffffc0202630:	00003617          	auipc	a2,0x3
ffffffffc0202634:	3a860613          	addi	a2,a2,936 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202638:	0d800593          	li	a1,216
ffffffffc020263c:	00004517          	auipc	a0,0x4
ffffffffc0202640:	a4450513          	addi	a0,a0,-1468 # ffffffffc0206080 <commands+0xf18>
ffffffffc0202644:	b85fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202648:	00004697          	auipc	a3,0x4
ffffffffc020264c:	b4868693          	addi	a3,a3,-1208 # ffffffffc0206190 <commands+0x1028>
ffffffffc0202650:	00003617          	auipc	a2,0x3
ffffffffc0202654:	38860613          	addi	a2,a2,904 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202658:	0e800593          	li	a1,232
ffffffffc020265c:	00004517          	auipc	a0,0x4
ffffffffc0202660:	a2450513          	addi	a0,a0,-1500 # ffffffffc0206080 <commands+0xf18>
ffffffffc0202664:	b65fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202668:	00004697          	auipc	a3,0x4
ffffffffc020266c:	b5868693          	addi	a3,a3,-1192 # ffffffffc02061c0 <commands+0x1058>
ffffffffc0202670:	00003617          	auipc	a2,0x3
ffffffffc0202674:	36860613          	addi	a2,a2,872 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202678:	0e900593          	li	a1,233
ffffffffc020267c:	00004517          	auipc	a0,0x4
ffffffffc0202680:	a0450513          	addi	a0,a0,-1532 # ffffffffc0206080 <commands+0xf18>
ffffffffc0202684:	b45fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0202688:	00004697          	auipc	a3,0x4
ffffffffc020268c:	a6868693          	addi	a3,a3,-1432 # ffffffffc02060f0 <commands+0xf88>
ffffffffc0202690:	00003617          	auipc	a2,0x3
ffffffffc0202694:	34860613          	addi	a2,a2,840 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202698:	0d600593          	li	a1,214
ffffffffc020269c:	00004517          	auipc	a0,0x4
ffffffffc02026a0:	9e450513          	addi	a0,a0,-1564 # ffffffffc0206080 <commands+0xf18>
ffffffffc02026a4:	b25fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma4 == NULL);
ffffffffc02026a8:	00004697          	auipc	a3,0x4
ffffffffc02026ac:	ac868693          	addi	a3,a3,-1336 # ffffffffc0206170 <commands+0x1008>
ffffffffc02026b0:	00003617          	auipc	a2,0x3
ffffffffc02026b4:	32860613          	addi	a2,a2,808 # ffffffffc02059d8 <commands+0x870>
ffffffffc02026b8:	0e400593          	li	a1,228
ffffffffc02026bc:	00004517          	auipc	a0,0x4
ffffffffc02026c0:	9c450513          	addi	a0,a0,-1596 # ffffffffc0206080 <commands+0xf18>
ffffffffc02026c4:	b05fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma5 == NULL);
ffffffffc02026c8:	00004697          	auipc	a3,0x4
ffffffffc02026cc:	ab868693          	addi	a3,a3,-1352 # ffffffffc0206180 <commands+0x1018>
ffffffffc02026d0:	00003617          	auipc	a2,0x3
ffffffffc02026d4:	30860613          	addi	a2,a2,776 # ffffffffc02059d8 <commands+0x870>
ffffffffc02026d8:	0e600593          	li	a1,230
ffffffffc02026dc:	00004517          	auipc	a0,0x4
ffffffffc02026e0:	9a450513          	addi	a0,a0,-1628 # ffffffffc0206080 <commands+0xf18>
ffffffffc02026e4:	ae5fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma1 != NULL);
ffffffffc02026e8:	00004697          	auipc	a3,0x4
ffffffffc02026ec:	a5868693          	addi	a3,a3,-1448 # ffffffffc0206140 <commands+0xfd8>
ffffffffc02026f0:	00003617          	auipc	a2,0x3
ffffffffc02026f4:	2e860613          	addi	a2,a2,744 # ffffffffc02059d8 <commands+0x870>
ffffffffc02026f8:	0de00593          	li	a1,222
ffffffffc02026fc:	00004517          	auipc	a0,0x4
ffffffffc0202700:	98450513          	addi	a0,a0,-1660 # ffffffffc0206080 <commands+0xf18>
ffffffffc0202704:	ac5fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma2 != NULL);
ffffffffc0202708:	00004697          	auipc	a3,0x4
ffffffffc020270c:	a4868693          	addi	a3,a3,-1464 # ffffffffc0206150 <commands+0xfe8>
ffffffffc0202710:	00003617          	auipc	a2,0x3
ffffffffc0202714:	2c860613          	addi	a2,a2,712 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202718:	0e000593          	li	a1,224
ffffffffc020271c:	00004517          	auipc	a0,0x4
ffffffffc0202720:	96450513          	addi	a0,a0,-1692 # ffffffffc0206080 <commands+0xf18>
ffffffffc0202724:	aa5fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma3 == NULL);
ffffffffc0202728:	00004697          	auipc	a3,0x4
ffffffffc020272c:	a3868693          	addi	a3,a3,-1480 # ffffffffc0206160 <commands+0xff8>
ffffffffc0202730:	00003617          	auipc	a2,0x3
ffffffffc0202734:	2a860613          	addi	a2,a2,680 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202738:	0e200593          	li	a1,226
ffffffffc020273c:	00004517          	auipc	a0,0x4
ffffffffc0202740:	94450513          	addi	a0,a0,-1724 # ffffffffc0206080 <commands+0xf18>
ffffffffc0202744:	a85fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0202748:	00004697          	auipc	a3,0x4
ffffffffc020274c:	bb868693          	addi	a3,a3,-1096 # ffffffffc0206300 <commands+0x1198>
ffffffffc0202750:	00003617          	auipc	a2,0x3
ffffffffc0202754:	28860613          	addi	a2,a2,648 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202758:	10100593          	li	a1,257
ffffffffc020275c:	00004517          	auipc	a0,0x4
ffffffffc0202760:	92450513          	addi	a0,a0,-1756 # ffffffffc0206080 <commands+0xf18>
    check_mm_struct = mm_create();
ffffffffc0202764:	00013797          	auipc	a5,0x13
ffffffffc0202768:	e007be23          	sd	zero,-484(a5) # ffffffffc0215580 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc020276c:	a5dfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(vma != NULL);
ffffffffc0202770:	00004697          	auipc	a3,0x4
ffffffffc0202774:	b8068693          	addi	a3,a3,-1152 # ffffffffc02062f0 <commands+0x1188>
ffffffffc0202778:	00003617          	auipc	a2,0x3
ffffffffc020277c:	26060613          	addi	a2,a2,608 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202780:	10800593          	li	a1,264
ffffffffc0202784:	00004517          	auipc	a0,0x4
ffffffffc0202788:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0206080 <commands+0xf18>
ffffffffc020278c:	a3dfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0202790:	00004697          	auipc	a3,0x4
ffffffffc0202794:	ad068693          	addi	a3,a3,-1328 # ffffffffc0206260 <commands+0x10f8>
ffffffffc0202798:	00003617          	auipc	a2,0x3
ffffffffc020279c:	24060613          	addi	a2,a2,576 # ffffffffc02059d8 <commands+0x870>
ffffffffc02027a0:	10d00593          	li	a1,269
ffffffffc02027a4:	00004517          	auipc	a0,0x4
ffffffffc02027a8:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0206080 <commands+0xf18>
ffffffffc02027ac:	a1dfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(sum == 0);
ffffffffc02027b0:	00004697          	auipc	a3,0x4
ffffffffc02027b4:	ad068693          	addi	a3,a3,-1328 # ffffffffc0206280 <commands+0x1118>
ffffffffc02027b8:	00003617          	auipc	a2,0x3
ffffffffc02027bc:	22060613          	addi	a2,a2,544 # ffffffffc02059d8 <commands+0x870>
ffffffffc02027c0:	11700593          	li	a1,279
ffffffffc02027c4:	00004517          	auipc	a0,0x4
ffffffffc02027c8:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0206080 <commands+0xf18>
ffffffffc02027cc:	9fdfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02027d0:	00003617          	auipc	a2,0x3
ffffffffc02027d4:	0a060613          	addi	a2,a2,160 # ffffffffc0205870 <commands+0x708>
ffffffffc02027d8:	06200593          	li	a1,98
ffffffffc02027dc:	00003517          	auipc	a0,0x3
ffffffffc02027e0:	0b450513          	addi	a0,a0,180 # ffffffffc0205890 <commands+0x728>
ffffffffc02027e4:	9e5fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc02027e8:	00003617          	auipc	a2,0x3
ffffffffc02027ec:	0e060613          	addi	a2,a2,224 # ffffffffc02058c8 <commands+0x760>
ffffffffc02027f0:	06900593          	li	a1,105
ffffffffc02027f4:	00003517          	auipc	a0,0x3
ffffffffc02027f8:	09c50513          	addi	a0,a0,156 # ffffffffc0205890 <commands+0x728>
ffffffffc02027fc:	9cdfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202800:	00004697          	auipc	a3,0x4
ffffffffc0202804:	a9068693          	addi	a3,a3,-1392 # ffffffffc0206290 <commands+0x1128>
ffffffffc0202808:	00003617          	auipc	a2,0x3
ffffffffc020280c:	1d060613          	addi	a2,a2,464 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202810:	12400593          	li	a1,292
ffffffffc0202814:	00004517          	auipc	a0,0x4
ffffffffc0202818:	86c50513          	addi	a0,a0,-1940 # ffffffffc0206080 <commands+0xf18>
ffffffffc020281c:	9adfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202820:	00004697          	auipc	a3,0x4
ffffffffc0202824:	a3068693          	addi	a3,a3,-1488 # ffffffffc0206250 <commands+0x10e8>
ffffffffc0202828:	00003617          	auipc	a2,0x3
ffffffffc020282c:	1b060613          	addi	a2,a2,432 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202830:	10500593          	li	a1,261
ffffffffc0202834:	00004517          	auipc	a0,0x4
ffffffffc0202838:	84c50513          	addi	a0,a0,-1972 # ffffffffc0206080 <commands+0xf18>
ffffffffc020283c:	98dfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(mm != NULL);
ffffffffc0202840:	00004697          	auipc	a3,0x4
ffffffffc0202844:	ad868693          	addi	a3,a3,-1320 # ffffffffc0206318 <commands+0x11b0>
ffffffffc0202848:	00003617          	auipc	a2,0x3
ffffffffc020284c:	19060613          	addi	a2,a2,400 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202850:	0c200593          	li	a1,194
ffffffffc0202854:	00004517          	auipc	a0,0x4
ffffffffc0202858:	82c50513          	addi	a0,a0,-2004 # ffffffffc0206080 <commands+0xf18>
ffffffffc020285c:	96dfd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202860 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0202860:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202862:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0202864:	f022                	sd	s0,32(sp)
ffffffffc0202866:	ec26                	sd	s1,24(sp)
ffffffffc0202868:	f406                	sd	ra,40(sp)
ffffffffc020286a:	e84a                	sd	s2,16(sp)
ffffffffc020286c:	8432                	mv	s0,a2
ffffffffc020286e:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202870:	8dfff0ef          	jal	ra,ffffffffc020214e <find_vma>

    pgfault_num++;
ffffffffc0202874:	00013797          	auipc	a5,0x13
ffffffffc0202878:	d147a783          	lw	a5,-748(a5) # ffffffffc0215588 <pgfault_num>
ffffffffc020287c:	2785                	addiw	a5,a5,1
ffffffffc020287e:	00013717          	auipc	a4,0x13
ffffffffc0202882:	d0f72523          	sw	a5,-758(a4) # ffffffffc0215588 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202886:	c541                	beqz	a0,ffffffffc020290e <do_pgfault+0xae>
ffffffffc0202888:	651c                	ld	a5,8(a0)
ffffffffc020288a:	08f46263          	bltu	s0,a5,ffffffffc020290e <do_pgfault+0xae>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020288e:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0202890:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202892:	8b89                	andi	a5,a5,2
ffffffffc0202894:	ebb9                	bnez	a5,ffffffffc02028ea <do_pgfault+0x8a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202896:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202898:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020289a:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020289c:	4605                	li	a2,1
ffffffffc020289e:	85a2                	mv	a1,s0
ffffffffc02028a0:	c16fe0ef          	jal	ra,ffffffffc0200cb6 <get_pte>
ffffffffc02028a4:	c551                	beqz	a0,ffffffffc0202930 <do_pgfault+0xd0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02028a6:	610c                	ld	a1,0(a0)
ffffffffc02028a8:	c1b9                	beqz	a1,ffffffffc02028ee <do_pgfault+0x8e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02028aa:	00013797          	auipc	a5,0x13
ffffffffc02028ae:	cfe7a783          	lw	a5,-770(a5) # ffffffffc02155a8 <swap_init_ok>
ffffffffc02028b2:	c7bd                	beqz	a5,ffffffffc0202920 <do_pgfault+0xc0>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm,addr,&page);
ffffffffc02028b4:	85a2                	mv	a1,s0
ffffffffc02028b6:	0030                	addi	a2,sp,8
ffffffffc02028b8:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02028ba:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc02028bc:	4df000ef          	jal	ra,ffffffffc020359a <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc02028c0:	65a2                	ld	a1,8(sp)
ffffffffc02028c2:	6c88                	ld	a0,24(s1)
ffffffffc02028c4:	86ca                	mv	a3,s2
ffffffffc02028c6:	8622                	mv	a2,s0
ffffffffc02028c8:	eb0fe0ef          	jal	ra,ffffffffc0200f78 <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc02028cc:	6622                	ld	a2,8(sp)
ffffffffc02028ce:	4685                	li	a3,1
ffffffffc02028d0:	85a2                	mv	a1,s0
ffffffffc02028d2:	8526                	mv	a0,s1
ffffffffc02028d4:	3a7000ef          	jal	ra,ffffffffc020347a <swap_map_swappable>

            page->pra_vaddr = addr;
ffffffffc02028d8:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc02028da:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc02028dc:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc02028de:	70a2                	ld	ra,40(sp)
ffffffffc02028e0:	7402                	ld	s0,32(sp)
ffffffffc02028e2:	64e2                	ld	s1,24(sp)
ffffffffc02028e4:	6942                	ld	s2,16(sp)
ffffffffc02028e6:	6145                	addi	sp,sp,48
ffffffffc02028e8:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02028ea:	495d                	li	s2,23
ffffffffc02028ec:	b76d                	j	ffffffffc0202896 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02028ee:	6c88                	ld	a0,24(s1)
ffffffffc02028f0:	864a                	mv	a2,s2
ffffffffc02028f2:	85a2                	mv	a1,s0
ffffffffc02028f4:	b1aff0ef          	jal	ra,ffffffffc0201c0e <pgdir_alloc_page>
ffffffffc02028f8:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc02028fa:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02028fc:	f3ed                	bnez	a5,ffffffffc02028de <do_pgfault+0x7e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02028fe:	00004517          	auipc	a0,0x4
ffffffffc0202902:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0206378 <commands+0x1210>
ffffffffc0202906:	fc6fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc020290a:	5571                	li	a0,-4
            goto failed;
ffffffffc020290c:	bfc9                	j	ffffffffc02028de <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020290e:	85a2                	mv	a1,s0
ffffffffc0202910:	00004517          	auipc	a0,0x4
ffffffffc0202914:	a1850513          	addi	a0,a0,-1512 # ffffffffc0206328 <commands+0x11c0>
ffffffffc0202918:	fb4fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc020291c:	5575                	li	a0,-3
        goto failed;
ffffffffc020291e:	b7c1                	j	ffffffffc02028de <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0202920:	00004517          	auipc	a0,0x4
ffffffffc0202924:	a8050513          	addi	a0,a0,-1408 # ffffffffc02063a0 <commands+0x1238>
ffffffffc0202928:	fa4fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc020292c:	5571                	li	a0,-4
            goto failed;
ffffffffc020292e:	bf45                	j	ffffffffc02028de <do_pgfault+0x7e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0202930:	00004517          	auipc	a0,0x4
ffffffffc0202934:	a2850513          	addi	a0,a0,-1496 # ffffffffc0206358 <commands+0x11f0>
ffffffffc0202938:	f94fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc020293c:	5571                	li	a0,-4
        goto failed;
ffffffffc020293e:	b745                	j	ffffffffc02028de <do_pgfault+0x7e>

ffffffffc0202940 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0202940:	c94d                	beqz	a0,ffffffffc02029f2 <slob_free+0xb2>
{
ffffffffc0202942:	1141                	addi	sp,sp,-16
ffffffffc0202944:	e022                	sd	s0,0(sp)
ffffffffc0202946:	e406                	sd	ra,8(sp)
ffffffffc0202948:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc020294a:	e9c1                	bnez	a1,ffffffffc02029da <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020294c:	100027f3          	csrr	a5,sstatus
ffffffffc0202950:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0202952:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202954:	ebd9                	bnez	a5,ffffffffc02029ea <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202956:	00007617          	auipc	a2,0x7
ffffffffc020295a:	6fa60613          	addi	a2,a2,1786 # ffffffffc020a050 <slobfree>
ffffffffc020295e:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202960:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202962:	679c                	ld	a5,8(a5)
ffffffffc0202964:	02877a63          	bgeu	a4,s0,ffffffffc0202998 <slob_free+0x58>
ffffffffc0202968:	00f46463          	bltu	s0,a5,ffffffffc0202970 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020296c:	fef76ae3          	bltu	a4,a5,ffffffffc0202960 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0202970:	400c                	lw	a1,0(s0)
ffffffffc0202972:	00459693          	slli	a3,a1,0x4
ffffffffc0202976:	96a2                	add	a3,a3,s0
ffffffffc0202978:	02d78a63          	beq	a5,a3,ffffffffc02029ac <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc020297c:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc020297e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0202980:	00469793          	slli	a5,a3,0x4
ffffffffc0202984:	97ba                	add	a5,a5,a4
ffffffffc0202986:	02f40e63          	beq	s0,a5,ffffffffc02029c2 <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc020298a:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc020298c:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc020298e:	e129                	bnez	a0,ffffffffc02029d0 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0202990:	60a2                	ld	ra,8(sp)
ffffffffc0202992:	6402                	ld	s0,0(sp)
ffffffffc0202994:	0141                	addi	sp,sp,16
ffffffffc0202996:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202998:	fcf764e3          	bltu	a4,a5,ffffffffc0202960 <slob_free+0x20>
ffffffffc020299c:	fcf472e3          	bgeu	s0,a5,ffffffffc0202960 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc02029a0:	400c                	lw	a1,0(s0)
ffffffffc02029a2:	00459693          	slli	a3,a1,0x4
ffffffffc02029a6:	96a2                	add	a3,a3,s0
ffffffffc02029a8:	fcd79ae3          	bne	a5,a3,ffffffffc020297c <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc02029ac:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02029ae:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc02029b0:	9db5                	addw	a1,a1,a3
ffffffffc02029b2:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc02029b4:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02029b6:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc02029b8:	00469793          	slli	a5,a3,0x4
ffffffffc02029bc:	97ba                	add	a5,a5,a4
ffffffffc02029be:	fcf416e3          	bne	s0,a5,ffffffffc020298a <slob_free+0x4a>
		cur->units += b->units;
ffffffffc02029c2:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc02029c4:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc02029c6:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc02029c8:	9ebd                	addw	a3,a3,a5
ffffffffc02029ca:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc02029cc:	e70c                	sd	a1,8(a4)
ffffffffc02029ce:	d169                	beqz	a0,ffffffffc0202990 <slob_free+0x50>
}
ffffffffc02029d0:	6402                	ld	s0,0(sp)
ffffffffc02029d2:	60a2                	ld	ra,8(sp)
ffffffffc02029d4:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02029d6:	be9fd06f          	j	ffffffffc02005be <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc02029da:	25bd                	addiw	a1,a1,15
ffffffffc02029dc:	8191                	srli	a1,a1,0x4
ffffffffc02029de:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02029e0:	100027f3          	csrr	a5,sstatus
ffffffffc02029e4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02029e6:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02029e8:	d7bd                	beqz	a5,ffffffffc0202956 <slob_free+0x16>
        intr_disable();
ffffffffc02029ea:	bdbfd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc02029ee:	4505                	li	a0,1
ffffffffc02029f0:	b79d                	j	ffffffffc0202956 <slob_free+0x16>
ffffffffc02029f2:	8082                	ret

ffffffffc02029f4 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02029f4:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02029f6:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02029f8:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02029fc:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02029fe:	9acfe0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
  if(!page)
ffffffffc0202a02:	c91d                	beqz	a0,ffffffffc0202a38 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0202a04:	00013697          	auipc	a3,0x13
ffffffffc0202a08:	b646b683          	ld	a3,-1180(a3) # ffffffffc0215568 <pages>
ffffffffc0202a0c:	8d15                	sub	a0,a0,a3
ffffffffc0202a0e:	8519                	srai	a0,a0,0x6
ffffffffc0202a10:	00004697          	auipc	a3,0x4
ffffffffc0202a14:	5b06b683          	ld	a3,1456(a3) # ffffffffc0206fc0 <nbase>
ffffffffc0202a18:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0202a1a:	00c51793          	slli	a5,a0,0xc
ffffffffc0202a1e:	83b1                	srli	a5,a5,0xc
ffffffffc0202a20:	00013717          	auipc	a4,0x13
ffffffffc0202a24:	b4073703          	ld	a4,-1216(a4) # ffffffffc0215560 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a28:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0202a2a:	00e7fa63          	bgeu	a5,a4,ffffffffc0202a3e <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0202a2e:	00013697          	auipc	a3,0x13
ffffffffc0202a32:	b4a6b683          	ld	a3,-1206(a3) # ffffffffc0215578 <va_pa_offset>
ffffffffc0202a36:	9536                	add	a0,a0,a3
}
ffffffffc0202a38:	60a2                	ld	ra,8(sp)
ffffffffc0202a3a:	0141                	addi	sp,sp,16
ffffffffc0202a3c:	8082                	ret
ffffffffc0202a3e:	86aa                	mv	a3,a0
ffffffffc0202a40:	00003617          	auipc	a2,0x3
ffffffffc0202a44:	e8860613          	addi	a2,a2,-376 # ffffffffc02058c8 <commands+0x760>
ffffffffc0202a48:	06900593          	li	a1,105
ffffffffc0202a4c:	00003517          	auipc	a0,0x3
ffffffffc0202a50:	e4450513          	addi	a0,a0,-444 # ffffffffc0205890 <commands+0x728>
ffffffffc0202a54:	f74fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202a58 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0202a58:	1101                	addi	sp,sp,-32
ffffffffc0202a5a:	ec06                	sd	ra,24(sp)
ffffffffc0202a5c:	e822                	sd	s0,16(sp)
ffffffffc0202a5e:	e426                	sd	s1,8(sp)
ffffffffc0202a60:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202a62:	01050713          	addi	a4,a0,16
ffffffffc0202a66:	6785                	lui	a5,0x1
ffffffffc0202a68:	0cf77363          	bgeu	a4,a5,ffffffffc0202b2e <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0202a6c:	00f50493          	addi	s1,a0,15
ffffffffc0202a70:	8091                	srli	s1,s1,0x4
ffffffffc0202a72:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a74:	10002673          	csrr	a2,sstatus
ffffffffc0202a78:	8a09                	andi	a2,a2,2
ffffffffc0202a7a:	e25d                	bnez	a2,ffffffffc0202b20 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0202a7c:	00007917          	auipc	s2,0x7
ffffffffc0202a80:	5d490913          	addi	s2,s2,1492 # ffffffffc020a050 <slobfree>
ffffffffc0202a84:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202a88:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202a8a:	4398                	lw	a4,0(a5)
ffffffffc0202a8c:	08975e63          	bge	a4,s1,ffffffffc0202b28 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0202a90:	00d78b63          	beq	a5,a3,ffffffffc0202aa6 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202a94:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202a96:	4018                	lw	a4,0(s0)
ffffffffc0202a98:	02975a63          	bge	a4,s1,ffffffffc0202acc <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0202a9c:	00093683          	ld	a3,0(s2)
ffffffffc0202aa0:	87a2                	mv	a5,s0
ffffffffc0202aa2:	fed799e3          	bne	a5,a3,ffffffffc0202a94 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0202aa6:	ee31                	bnez	a2,ffffffffc0202b02 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202aa8:	4501                	li	a0,0
ffffffffc0202aaa:	f4bff0ef          	jal	ra,ffffffffc02029f4 <__slob_get_free_pages.constprop.0>
ffffffffc0202aae:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0202ab0:	cd05                	beqz	a0,ffffffffc0202ae8 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0202ab2:	6585                	lui	a1,0x1
ffffffffc0202ab4:	e8dff0ef          	jal	ra,ffffffffc0202940 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202ab8:	10002673          	csrr	a2,sstatus
ffffffffc0202abc:	8a09                	andi	a2,a2,2
ffffffffc0202abe:	ee05                	bnez	a2,ffffffffc0202af6 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0202ac0:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202ac4:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202ac6:	4018                	lw	a4,0(s0)
ffffffffc0202ac8:	fc974ae3          	blt	a4,s1,ffffffffc0202a9c <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0202acc:	04e48763          	beq	s1,a4,ffffffffc0202b1a <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0202ad0:	00449693          	slli	a3,s1,0x4
ffffffffc0202ad4:	96a2                	add	a3,a3,s0
ffffffffc0202ad6:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0202ad8:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0202ada:	9f05                	subw	a4,a4,s1
ffffffffc0202adc:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0202ade:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0202ae0:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0202ae2:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0202ae6:	e20d                	bnez	a2,ffffffffc0202b08 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0202ae8:	60e2                	ld	ra,24(sp)
ffffffffc0202aea:	8522                	mv	a0,s0
ffffffffc0202aec:	6442                	ld	s0,16(sp)
ffffffffc0202aee:	64a2                	ld	s1,8(sp)
ffffffffc0202af0:	6902                	ld	s2,0(sp)
ffffffffc0202af2:	6105                	addi	sp,sp,32
ffffffffc0202af4:	8082                	ret
        intr_disable();
ffffffffc0202af6:	acffd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
			cur = slobfree;
ffffffffc0202afa:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0202afe:	4605                	li	a2,1
ffffffffc0202b00:	b7d1                	j	ffffffffc0202ac4 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0202b02:	abdfd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0202b06:	b74d                	j	ffffffffc0202aa8 <slob_alloc.constprop.0+0x50>
ffffffffc0202b08:	ab7fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
}
ffffffffc0202b0c:	60e2                	ld	ra,24(sp)
ffffffffc0202b0e:	8522                	mv	a0,s0
ffffffffc0202b10:	6442                	ld	s0,16(sp)
ffffffffc0202b12:	64a2                	ld	s1,8(sp)
ffffffffc0202b14:	6902                	ld	s2,0(sp)
ffffffffc0202b16:	6105                	addi	sp,sp,32
ffffffffc0202b18:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0202b1a:	6418                	ld	a4,8(s0)
ffffffffc0202b1c:	e798                	sd	a4,8(a5)
ffffffffc0202b1e:	b7d1                	j	ffffffffc0202ae2 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0202b20:	aa5fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc0202b24:	4605                	li	a2,1
ffffffffc0202b26:	bf99                	j	ffffffffc0202a7c <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202b28:	843e                	mv	s0,a5
ffffffffc0202b2a:	87b6                	mv	a5,a3
ffffffffc0202b2c:	b745                	j	ffffffffc0202acc <slob_alloc.constprop.0+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202b2e:	00004697          	auipc	a3,0x4
ffffffffc0202b32:	89a68693          	addi	a3,a3,-1894 # ffffffffc02063c8 <commands+0x1260>
ffffffffc0202b36:	00003617          	auipc	a2,0x3
ffffffffc0202b3a:	ea260613          	addi	a2,a2,-350 # ffffffffc02059d8 <commands+0x870>
ffffffffc0202b3e:	06300593          	li	a1,99
ffffffffc0202b42:	00004517          	auipc	a0,0x4
ffffffffc0202b46:	8a650513          	addi	a0,a0,-1882 # ffffffffc02063e8 <commands+0x1280>
ffffffffc0202b4a:	e7efd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202b4e <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0202b4e:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0202b50:	00004517          	auipc	a0,0x4
ffffffffc0202b54:	8b050513          	addi	a0,a0,-1872 # ffffffffc0206400 <commands+0x1298>
kmalloc_init(void) {
ffffffffc0202b58:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0202b5a:	d72fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0202b5e:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202b60:	00004517          	auipc	a0,0x4
ffffffffc0202b64:	8b850513          	addi	a0,a0,-1864 # ffffffffc0206418 <commands+0x12b0>
}
ffffffffc0202b68:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202b6a:	d62fd06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0202b6e <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0202b6e:	1101                	addi	sp,sp,-32
ffffffffc0202b70:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202b72:	6905                	lui	s2,0x1
{
ffffffffc0202b74:	e822                	sd	s0,16(sp)
ffffffffc0202b76:	ec06                	sd	ra,24(sp)
ffffffffc0202b78:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202b7a:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
{
ffffffffc0202b7e:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202b80:	04a7f963          	bgeu	a5,a0,ffffffffc0202bd2 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0202b84:	4561                	li	a0,24
ffffffffc0202b86:	ed3ff0ef          	jal	ra,ffffffffc0202a58 <slob_alloc.constprop.0>
ffffffffc0202b8a:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0202b8c:	c929                	beqz	a0,ffffffffc0202bde <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0202b8e:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0202b92:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0202b94:	00f95763          	bge	s2,a5,ffffffffc0202ba2 <kmalloc+0x34>
ffffffffc0202b98:	6705                	lui	a4,0x1
ffffffffc0202b9a:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0202b9c:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0202b9e:	fef74ee3          	blt	a4,a5,ffffffffc0202b9a <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0202ba2:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0202ba4:	e51ff0ef          	jal	ra,ffffffffc02029f4 <__slob_get_free_pages.constprop.0>
ffffffffc0202ba8:	e488                	sd	a0,8(s1)
ffffffffc0202baa:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0202bac:	c525                	beqz	a0,ffffffffc0202c14 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202bae:	100027f3          	csrr	a5,sstatus
ffffffffc0202bb2:	8b89                	andi	a5,a5,2
ffffffffc0202bb4:	ef8d                	bnez	a5,ffffffffc0202bee <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0202bb6:	00013797          	auipc	a5,0x13
ffffffffc0202bba:	9da78793          	addi	a5,a5,-1574 # ffffffffc0215590 <bigblocks>
ffffffffc0202bbe:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0202bc0:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0202bc2:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0202bc4:	60e2                	ld	ra,24(sp)
ffffffffc0202bc6:	8522                	mv	a0,s0
ffffffffc0202bc8:	6442                	ld	s0,16(sp)
ffffffffc0202bca:	64a2                	ld	s1,8(sp)
ffffffffc0202bcc:	6902                	ld	s2,0(sp)
ffffffffc0202bce:	6105                	addi	sp,sp,32
ffffffffc0202bd0:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0202bd2:	0541                	addi	a0,a0,16
ffffffffc0202bd4:	e85ff0ef          	jal	ra,ffffffffc0202a58 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0202bd8:	01050413          	addi	s0,a0,16
ffffffffc0202bdc:	f565                	bnez	a0,ffffffffc0202bc4 <kmalloc+0x56>
ffffffffc0202bde:	4401                	li	s0,0
}
ffffffffc0202be0:	60e2                	ld	ra,24(sp)
ffffffffc0202be2:	8522                	mv	a0,s0
ffffffffc0202be4:	6442                	ld	s0,16(sp)
ffffffffc0202be6:	64a2                	ld	s1,8(sp)
ffffffffc0202be8:	6902                	ld	s2,0(sp)
ffffffffc0202bea:	6105                	addi	sp,sp,32
ffffffffc0202bec:	8082                	ret
        intr_disable();
ffffffffc0202bee:	9d7fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
		bb->next = bigblocks;
ffffffffc0202bf2:	00013797          	auipc	a5,0x13
ffffffffc0202bf6:	99e78793          	addi	a5,a5,-1634 # ffffffffc0215590 <bigblocks>
ffffffffc0202bfa:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0202bfc:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0202bfe:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0202c00:	9bffd0ef          	jal	ra,ffffffffc02005be <intr_enable>
		return bb->pages;
ffffffffc0202c04:	6480                	ld	s0,8(s1)
}
ffffffffc0202c06:	60e2                	ld	ra,24(sp)
ffffffffc0202c08:	64a2                	ld	s1,8(sp)
ffffffffc0202c0a:	8522                	mv	a0,s0
ffffffffc0202c0c:	6442                	ld	s0,16(sp)
ffffffffc0202c0e:	6902                	ld	s2,0(sp)
ffffffffc0202c10:	6105                	addi	sp,sp,32
ffffffffc0202c12:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0202c14:	45e1                	li	a1,24
ffffffffc0202c16:	8526                	mv	a0,s1
ffffffffc0202c18:	d29ff0ef          	jal	ra,ffffffffc0202940 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0202c1c:	b765                	j	ffffffffc0202bc4 <kmalloc+0x56>

ffffffffc0202c1e <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0202c1e:	c179                	beqz	a0,ffffffffc0202ce4 <kfree+0xc6>
{
ffffffffc0202c20:	1101                	addi	sp,sp,-32
ffffffffc0202c22:	e822                	sd	s0,16(sp)
ffffffffc0202c24:	ec06                	sd	ra,24(sp)
ffffffffc0202c26:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0202c28:	03451793          	slli	a5,a0,0x34
ffffffffc0202c2c:	842a                	mv	s0,a0
ffffffffc0202c2e:	e7c1                	bnez	a5,ffffffffc0202cb6 <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202c30:	100027f3          	csrr	a5,sstatus
ffffffffc0202c34:	8b89                	andi	a5,a5,2
ffffffffc0202c36:	ebc9                	bnez	a5,ffffffffc0202cc8 <kfree+0xaa>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202c38:	00013797          	auipc	a5,0x13
ffffffffc0202c3c:	9587b783          	ld	a5,-1704(a5) # ffffffffc0215590 <bigblocks>
    return 0;
ffffffffc0202c40:	4601                	li	a2,0
ffffffffc0202c42:	cbb5                	beqz	a5,ffffffffc0202cb6 <kfree+0x98>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0202c44:	00013697          	auipc	a3,0x13
ffffffffc0202c48:	94c68693          	addi	a3,a3,-1716 # ffffffffc0215590 <bigblocks>
ffffffffc0202c4c:	a021                	j	ffffffffc0202c54 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202c4e:	01048693          	addi	a3,s1,16
ffffffffc0202c52:	c3ad                	beqz	a5,ffffffffc0202cb4 <kfree+0x96>
			if (bb->pages == block) {
ffffffffc0202c54:	6798                	ld	a4,8(a5)
ffffffffc0202c56:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0202c58:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0202c5a:	fe871ae3          	bne	a4,s0,ffffffffc0202c4e <kfree+0x30>
				*last = bb->next;
ffffffffc0202c5e:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0202c60:	ee3d                	bnez	a2,ffffffffc0202cde <kfree+0xc0>
    return pa2page(PADDR(kva));
ffffffffc0202c62:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0202c66:	4098                	lw	a4,0(s1)
ffffffffc0202c68:	08f46b63          	bltu	s0,a5,ffffffffc0202cfe <kfree+0xe0>
ffffffffc0202c6c:	00013697          	auipc	a3,0x13
ffffffffc0202c70:	90c6b683          	ld	a3,-1780(a3) # ffffffffc0215578 <va_pa_offset>
ffffffffc0202c74:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0202c76:	8031                	srli	s0,s0,0xc
ffffffffc0202c78:	00013797          	auipc	a5,0x13
ffffffffc0202c7c:	8e87b783          	ld	a5,-1816(a5) # ffffffffc0215560 <npage>
ffffffffc0202c80:	06f47363          	bgeu	s0,a5,ffffffffc0202ce6 <kfree+0xc8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c84:	00004517          	auipc	a0,0x4
ffffffffc0202c88:	33c53503          	ld	a0,828(a0) # ffffffffc0206fc0 <nbase>
ffffffffc0202c8c:	8c09                	sub	s0,s0,a0
ffffffffc0202c8e:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0202c90:	00013517          	auipc	a0,0x13
ffffffffc0202c94:	8d853503          	ld	a0,-1832(a0) # ffffffffc0215568 <pages>
ffffffffc0202c98:	4585                	li	a1,1
ffffffffc0202c9a:	9522                	add	a0,a0,s0
ffffffffc0202c9c:	00e595bb          	sllw	a1,a1,a4
ffffffffc0202ca0:	f9dfd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0202ca4:	6442                	ld	s0,16(sp)
ffffffffc0202ca6:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202ca8:	8526                	mv	a0,s1
}
ffffffffc0202caa:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202cac:	45e1                	li	a1,24
}
ffffffffc0202cae:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202cb0:	c91ff06f          	j	ffffffffc0202940 <slob_free>
ffffffffc0202cb4:	e215                	bnez	a2,ffffffffc0202cd8 <kfree+0xba>
ffffffffc0202cb6:	ff040513          	addi	a0,s0,-16
}
ffffffffc0202cba:	6442                	ld	s0,16(sp)
ffffffffc0202cbc:	60e2                	ld	ra,24(sp)
ffffffffc0202cbe:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202cc0:	4581                	li	a1,0
}
ffffffffc0202cc2:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202cc4:	c7dff06f          	j	ffffffffc0202940 <slob_free>
        intr_disable();
ffffffffc0202cc8:	8fdfd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202ccc:	00013797          	auipc	a5,0x13
ffffffffc0202cd0:	8c47b783          	ld	a5,-1852(a5) # ffffffffc0215590 <bigblocks>
        return 1;
ffffffffc0202cd4:	4605                	li	a2,1
ffffffffc0202cd6:	f7bd                	bnez	a5,ffffffffc0202c44 <kfree+0x26>
        intr_enable();
ffffffffc0202cd8:	8e7fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0202cdc:	bfe9                	j	ffffffffc0202cb6 <kfree+0x98>
ffffffffc0202cde:	8e1fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0202ce2:	b741                	j	ffffffffc0202c62 <kfree+0x44>
ffffffffc0202ce4:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0202ce6:	00003617          	auipc	a2,0x3
ffffffffc0202cea:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0205870 <commands+0x708>
ffffffffc0202cee:	06200593          	li	a1,98
ffffffffc0202cf2:	00003517          	auipc	a0,0x3
ffffffffc0202cf6:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0205890 <commands+0x728>
ffffffffc0202cfa:	ccefd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0202cfe:	86a2                	mv	a3,s0
ffffffffc0202d00:	00003617          	auipc	a2,0x3
ffffffffc0202d04:	c5860613          	addi	a2,a2,-936 # ffffffffc0205958 <commands+0x7f0>
ffffffffc0202d08:	06e00593          	li	a1,110
ffffffffc0202d0c:	00003517          	auipc	a0,0x3
ffffffffc0202d10:	b8450513          	addi	a0,a0,-1148 # ffffffffc0205890 <commands+0x728>
ffffffffc0202d14:	cb4fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202d18 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0202d18:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202d1a:	00003617          	auipc	a2,0x3
ffffffffc0202d1e:	b5660613          	addi	a2,a2,-1194 # ffffffffc0205870 <commands+0x708>
ffffffffc0202d22:	06200593          	li	a1,98
ffffffffc0202d26:	00003517          	auipc	a0,0x3
ffffffffc0202d2a:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0205890 <commands+0x728>
pa2page(uintptr_t pa) {
ffffffffc0202d2e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202d30:	c98fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202d34 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202d34:	7135                	addi	sp,sp,-160
ffffffffc0202d36:	ed06                	sd	ra,152(sp)
ffffffffc0202d38:	e922                	sd	s0,144(sp)
ffffffffc0202d3a:	e526                	sd	s1,136(sp)
ffffffffc0202d3c:	e14a                	sd	s2,128(sp)
ffffffffc0202d3e:	fcce                	sd	s3,120(sp)
ffffffffc0202d40:	f8d2                	sd	s4,112(sp)
ffffffffc0202d42:	f4d6                	sd	s5,104(sp)
ffffffffc0202d44:	f0da                	sd	s6,96(sp)
ffffffffc0202d46:	ecde                	sd	s7,88(sp)
ffffffffc0202d48:	e8e2                	sd	s8,80(sp)
ffffffffc0202d4a:	e4e6                	sd	s9,72(sp)
ffffffffc0202d4c:	e0ea                	sd	s10,64(sp)
ffffffffc0202d4e:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202d50:	372010ef          	jal	ra,ffffffffc02040c2 <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202d54:	00013697          	auipc	a3,0x13
ffffffffc0202d58:	8446b683          	ld	a3,-1980(a3) # ffffffffc0215598 <max_swap_offset>
ffffffffc0202d5c:	010007b7          	lui	a5,0x1000
ffffffffc0202d60:	ff968713          	addi	a4,a3,-7
ffffffffc0202d64:	17e1                	addi	a5,a5,-8
ffffffffc0202d66:	42e7e063          	bltu	a5,a4,ffffffffc0203186 <swap_init+0x452>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202d6a:	00007797          	auipc	a5,0x7
ffffffffc0202d6e:	29678793          	addi	a5,a5,662 # ffffffffc020a000 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202d72:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202d74:	00013b97          	auipc	s7,0x13
ffffffffc0202d78:	82cb8b93          	addi	s7,s7,-2004 # ffffffffc02155a0 <sm>
ffffffffc0202d7c:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc0202d80:	9702                	jalr	a4
ffffffffc0202d82:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc0202d84:	c10d                	beqz	a0,ffffffffc0202da6 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202d86:	60ea                	ld	ra,152(sp)
ffffffffc0202d88:	644a                	ld	s0,144(sp)
ffffffffc0202d8a:	64aa                	ld	s1,136(sp)
ffffffffc0202d8c:	79e6                	ld	s3,120(sp)
ffffffffc0202d8e:	7a46                	ld	s4,112(sp)
ffffffffc0202d90:	7aa6                	ld	s5,104(sp)
ffffffffc0202d92:	7b06                	ld	s6,96(sp)
ffffffffc0202d94:	6be6                	ld	s7,88(sp)
ffffffffc0202d96:	6c46                	ld	s8,80(sp)
ffffffffc0202d98:	6ca6                	ld	s9,72(sp)
ffffffffc0202d9a:	6d06                	ld	s10,64(sp)
ffffffffc0202d9c:	7de2                	ld	s11,56(sp)
ffffffffc0202d9e:	854a                	mv	a0,s2
ffffffffc0202da0:	690a                	ld	s2,128(sp)
ffffffffc0202da2:	610d                	addi	sp,sp,160
ffffffffc0202da4:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202da6:	000bb783          	ld	a5,0(s7)
ffffffffc0202daa:	00003517          	auipc	a0,0x3
ffffffffc0202dae:	6be50513          	addi	a0,a0,1726 # ffffffffc0206468 <commands+0x1300>
ffffffffc0202db2:	0000e417          	auipc	s0,0xe
ffffffffc0202db6:	74e40413          	addi	s0,s0,1870 # ffffffffc0211500 <free_area>
ffffffffc0202dba:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202dbc:	4785                	li	a5,1
ffffffffc0202dbe:	00012717          	auipc	a4,0x12
ffffffffc0202dc2:	7ef72523          	sw	a5,2026(a4) # ffffffffc02155a8 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202dc6:	b06fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0202dca:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202dcc:	4d01                	li	s10,0
ffffffffc0202dce:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202dd0:	32878b63          	beq	a5,s0,ffffffffc0203106 <swap_init+0x3d2>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202dd4:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202dd8:	8b09                	andi	a4,a4,2
ffffffffc0202dda:	32070863          	beqz	a4,ffffffffc020310a <swap_init+0x3d6>
        count ++, total += p->property;
ffffffffc0202dde:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202de2:	679c                	ld	a5,8(a5)
ffffffffc0202de4:	2d85                	addiw	s11,s11,1
ffffffffc0202de6:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202dea:	fe8795e3          	bne	a5,s0,ffffffffc0202dd4 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0202dee:	84ea                	mv	s1,s10
ffffffffc0202df0:	e8dfd0ef          	jal	ra,ffffffffc0200c7c <nr_free_pages>
ffffffffc0202df4:	42951163          	bne	a0,s1,ffffffffc0203216 <swap_init+0x4e2>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202df8:	866a                	mv	a2,s10
ffffffffc0202dfa:	85ee                	mv	a1,s11
ffffffffc0202dfc:	00003517          	auipc	a0,0x3
ffffffffc0202e00:	6b450513          	addi	a0,a0,1716 # ffffffffc02064b0 <commands+0x1348>
ffffffffc0202e04:	ac8fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202e08:	ad0ff0ef          	jal	ra,ffffffffc02020d8 <mm_create>
ffffffffc0202e0c:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0202e0e:	46050463          	beqz	a0,ffffffffc0203276 <swap_init+0x542>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202e12:	00012797          	auipc	a5,0x12
ffffffffc0202e16:	76e78793          	addi	a5,a5,1902 # ffffffffc0215580 <check_mm_struct>
ffffffffc0202e1a:	6398                	ld	a4,0(a5)
ffffffffc0202e1c:	3c071d63          	bnez	a4,ffffffffc02031f6 <swap_init+0x4c2>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202e20:	00012717          	auipc	a4,0x12
ffffffffc0202e24:	73870713          	addi	a4,a4,1848 # ffffffffc0215558 <boot_pgdir>
ffffffffc0202e28:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0202e2c:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0202e2e:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202e32:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202e36:	42079063          	bnez	a5,ffffffffc0203256 <swap_init+0x522>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202e3a:	6599                	lui	a1,0x6
ffffffffc0202e3c:	460d                	li	a2,3
ffffffffc0202e3e:	6505                	lui	a0,0x1
ffffffffc0202e40:	ae0ff0ef          	jal	ra,ffffffffc0202120 <vma_create>
ffffffffc0202e44:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202e46:	52050463          	beqz	a0,ffffffffc020336e <swap_init+0x63a>

     insert_vma_struct(mm, vma);
ffffffffc0202e4a:	8556                	mv	a0,s5
ffffffffc0202e4c:	b42ff0ef          	jal	ra,ffffffffc020218e <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202e50:	00003517          	auipc	a0,0x3
ffffffffc0202e54:	6a050513          	addi	a0,a0,1696 # ffffffffc02064f0 <commands+0x1388>
ffffffffc0202e58:	a74fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202e5c:	018ab503          	ld	a0,24(s5)
ffffffffc0202e60:	4605                	li	a2,1
ffffffffc0202e62:	6585                	lui	a1,0x1
ffffffffc0202e64:	e53fd0ef          	jal	ra,ffffffffc0200cb6 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202e68:	4c050363          	beqz	a0,ffffffffc020332e <swap_init+0x5fa>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202e6c:	00003517          	auipc	a0,0x3
ffffffffc0202e70:	6d450513          	addi	a0,a0,1748 # ffffffffc0206540 <commands+0x13d8>
ffffffffc0202e74:	0000e497          	auipc	s1,0xe
ffffffffc0202e78:	61c48493          	addi	s1,s1,1564 # ffffffffc0211490 <check_rp>
ffffffffc0202e7c:	a50fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e80:	0000e997          	auipc	s3,0xe
ffffffffc0202e84:	63098993          	addi	s3,s3,1584 # ffffffffc02114b0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202e88:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0202e8a:	4505                	li	a0,1
ffffffffc0202e8c:	d1ffd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0202e90:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc0202e94:	2c050963          	beqz	a0,ffffffffc0203166 <swap_init+0x432>
ffffffffc0202e98:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202e9a:	8b89                	andi	a5,a5,2
ffffffffc0202e9c:	32079d63          	bnez	a5,ffffffffc02031d6 <swap_init+0x4a2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ea0:	0a21                	addi	s4,s4,8
ffffffffc0202ea2:	ff3a14e3          	bne	s4,s3,ffffffffc0202e8a <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202ea6:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202ea8:	0000ea17          	auipc	s4,0xe
ffffffffc0202eac:	5e8a0a13          	addi	s4,s4,1512 # ffffffffc0211490 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0202eb0:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0202eb2:	ec3e                	sd	a5,24(sp)
ffffffffc0202eb4:	641c                	ld	a5,8(s0)
ffffffffc0202eb6:	e400                	sd	s0,8(s0)
ffffffffc0202eb8:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202eba:	481c                	lw	a5,16(s0)
ffffffffc0202ebc:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202ebe:	0000e797          	auipc	a5,0xe
ffffffffc0202ec2:	6407a923          	sw	zero,1618(a5) # ffffffffc0211510 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202ec6:	000a3503          	ld	a0,0(s4)
ffffffffc0202eca:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ecc:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0202ece:	d6ffd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ed2:	ff3a1ae3          	bne	s4,s3,ffffffffc0202ec6 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202ed6:	01042a03          	lw	s4,16(s0)
ffffffffc0202eda:	4791                	li	a5,4
ffffffffc0202edc:	42fa1963          	bne	s4,a5,ffffffffc020330e <swap_init+0x5da>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202ee0:	00003517          	auipc	a0,0x3
ffffffffc0202ee4:	6e850513          	addi	a0,a0,1768 # ffffffffc02065c8 <commands+0x1460>
ffffffffc0202ee8:	9e4fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202eec:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202eee:	00012797          	auipc	a5,0x12
ffffffffc0202ef2:	6807ad23          	sw	zero,1690(a5) # ffffffffc0215588 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202ef6:	4629                	li	a2,10
ffffffffc0202ef8:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202efc:	00012697          	auipc	a3,0x12
ffffffffc0202f00:	68c6a683          	lw	a3,1676(a3) # ffffffffc0215588 <pgfault_num>
ffffffffc0202f04:	4585                	li	a1,1
ffffffffc0202f06:	00012797          	auipc	a5,0x12
ffffffffc0202f0a:	68278793          	addi	a5,a5,1666 # ffffffffc0215588 <pgfault_num>
ffffffffc0202f0e:	54b69063          	bne	a3,a1,ffffffffc020344e <swap_init+0x71a>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202f12:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0202f16:	4398                	lw	a4,0(a5)
ffffffffc0202f18:	2701                	sext.w	a4,a4
ffffffffc0202f1a:	3cd71a63          	bne	a4,a3,ffffffffc02032ee <swap_init+0x5ba>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202f1e:	6689                	lui	a3,0x2
ffffffffc0202f20:	462d                	li	a2,11
ffffffffc0202f22:	00c68023          	sb	a2,0(a3) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202f26:	4398                	lw	a4,0(a5)
ffffffffc0202f28:	4589                	li	a1,2
ffffffffc0202f2a:	2701                	sext.w	a4,a4
ffffffffc0202f2c:	4ab71163          	bne	a4,a1,ffffffffc02033ce <swap_init+0x69a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202f30:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202f34:	4394                	lw	a3,0(a5)
ffffffffc0202f36:	2681                	sext.w	a3,a3
ffffffffc0202f38:	4ae69b63          	bne	a3,a4,ffffffffc02033ee <swap_init+0x6ba>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202f3c:	668d                	lui	a3,0x3
ffffffffc0202f3e:	4631                	li	a2,12
ffffffffc0202f40:	00c68023          	sb	a2,0(a3) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202f44:	4398                	lw	a4,0(a5)
ffffffffc0202f46:	458d                	li	a1,3
ffffffffc0202f48:	2701                	sext.w	a4,a4
ffffffffc0202f4a:	4cb71263          	bne	a4,a1,ffffffffc020340e <swap_init+0x6da>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202f4e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202f52:	4394                	lw	a3,0(a5)
ffffffffc0202f54:	2681                	sext.w	a3,a3
ffffffffc0202f56:	4ce69c63          	bne	a3,a4,ffffffffc020342e <swap_init+0x6fa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202f5a:	6691                	lui	a3,0x4
ffffffffc0202f5c:	4635                	li	a2,13
ffffffffc0202f5e:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202f62:	4398                	lw	a4,0(a5)
ffffffffc0202f64:	2701                	sext.w	a4,a4
ffffffffc0202f66:	43471463          	bne	a4,s4,ffffffffc020338e <swap_init+0x65a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202f6a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202f6e:	439c                	lw	a5,0(a5)
ffffffffc0202f70:	2781                	sext.w	a5,a5
ffffffffc0202f72:	42e79e63          	bne	a5,a4,ffffffffc02033ae <swap_init+0x67a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202f76:	481c                	lw	a5,16(s0)
ffffffffc0202f78:	2a079f63          	bnez	a5,ffffffffc0203236 <swap_init+0x502>
ffffffffc0202f7c:	0000e797          	auipc	a5,0xe
ffffffffc0202f80:	53478793          	addi	a5,a5,1332 # ffffffffc02114b0 <swap_in_seq_no>
ffffffffc0202f84:	0000e717          	auipc	a4,0xe
ffffffffc0202f88:	55470713          	addi	a4,a4,1364 # ffffffffc02114d8 <swap_out_seq_no>
ffffffffc0202f8c:	0000e617          	auipc	a2,0xe
ffffffffc0202f90:	54c60613          	addi	a2,a2,1356 # ffffffffc02114d8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202f94:	56fd                	li	a3,-1
ffffffffc0202f96:	c394                	sw	a3,0(a5)
ffffffffc0202f98:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202f9a:	0791                	addi	a5,a5,4
ffffffffc0202f9c:	0711                	addi	a4,a4,4
ffffffffc0202f9e:	fec79ce3          	bne	a5,a2,ffffffffc0202f96 <swap_init+0x262>
ffffffffc0202fa2:	0000e717          	auipc	a4,0xe
ffffffffc0202fa6:	4ce70713          	addi	a4,a4,1230 # ffffffffc0211470 <check_ptep>
ffffffffc0202faa:	0000e697          	auipc	a3,0xe
ffffffffc0202fae:	4e668693          	addi	a3,a3,1254 # ffffffffc0211490 <check_rp>
ffffffffc0202fb2:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202fb4:	00012c17          	auipc	s8,0x12
ffffffffc0202fb8:	5acc0c13          	addi	s8,s8,1452 # ffffffffc0215560 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fbc:	00012c97          	auipc	s9,0x12
ffffffffc0202fc0:	5acc8c93          	addi	s9,s9,1452 # ffffffffc0215568 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202fc4:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202fc8:	4601                	li	a2,0
ffffffffc0202fca:	855a                	mv	a0,s6
ffffffffc0202fcc:	e836                	sd	a3,16(sp)
ffffffffc0202fce:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0202fd0:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202fd2:	ce5fd0ef          	jal	ra,ffffffffc0200cb6 <get_pte>
ffffffffc0202fd6:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202fd8:	65a2                	ld	a1,8(sp)
ffffffffc0202fda:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202fdc:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0202fde:	1c050063          	beqz	a0,ffffffffc020319e <swap_init+0x46a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202fe2:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202fe4:	0017f613          	andi	a2,a5,1
ffffffffc0202fe8:	1c060b63          	beqz	a2,ffffffffc02031be <swap_init+0x48a>
    if (PPN(pa) >= npage) {
ffffffffc0202fec:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ff0:	078a                	slli	a5,a5,0x2
ffffffffc0202ff2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ff4:	12c7fd63          	bgeu	a5,a2,ffffffffc020312e <swap_init+0x3fa>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ff8:	00004617          	auipc	a2,0x4
ffffffffc0202ffc:	fc860613          	addi	a2,a2,-56 # ffffffffc0206fc0 <nbase>
ffffffffc0203000:	00063a03          	ld	s4,0(a2)
ffffffffc0203004:	000cb603          	ld	a2,0(s9)
ffffffffc0203008:	6288                	ld	a0,0(a3)
ffffffffc020300a:	414787b3          	sub	a5,a5,s4
ffffffffc020300e:	079a                	slli	a5,a5,0x6
ffffffffc0203010:	97b2                	add	a5,a5,a2
ffffffffc0203012:	12f51a63          	bne	a0,a5,ffffffffc0203146 <swap_init+0x412>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203016:	6785                	lui	a5,0x1
ffffffffc0203018:	95be                	add	a1,a1,a5
ffffffffc020301a:	6795                	lui	a5,0x5
ffffffffc020301c:	0721                	addi	a4,a4,8
ffffffffc020301e:	06a1                	addi	a3,a3,8
ffffffffc0203020:	faf592e3          	bne	a1,a5,ffffffffc0202fc4 <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0203024:	00003517          	auipc	a0,0x3
ffffffffc0203028:	64c50513          	addi	a0,a0,1612 # ffffffffc0206670 <commands+0x1508>
ffffffffc020302c:	8a0fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc0203030:	000bb783          	ld	a5,0(s7)
ffffffffc0203034:	7f9c                	ld	a5,56(a5)
ffffffffc0203036:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203038:	30051b63          	bnez	a0,ffffffffc020334e <swap_init+0x61a>

     nr_free = nr_free_store;
ffffffffc020303c:	77a2                	ld	a5,40(sp)
ffffffffc020303e:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0203040:	67e2                	ld	a5,24(sp)
ffffffffc0203042:	e01c                	sd	a5,0(s0)
ffffffffc0203044:	7782                	ld	a5,32(sp)
ffffffffc0203046:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203048:	6088                	ld	a0,0(s1)
ffffffffc020304a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020304c:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc020304e:	beffd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203052:	ff349be3          	bne	s1,s3,ffffffffc0203048 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0203056:	8556                	mv	a0,s5
ffffffffc0203058:	a06ff0ef          	jal	ra,ffffffffc020225e <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020305c:	00012797          	auipc	a5,0x12
ffffffffc0203060:	4fc78793          	addi	a5,a5,1276 # ffffffffc0215558 <boot_pgdir>
ffffffffc0203064:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203066:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc020306a:	639c                	ld	a5,0(a5)
ffffffffc020306c:	078a                	slli	a5,a5,0x2
ffffffffc020306e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203070:	0ae7fd63          	bgeu	a5,a4,ffffffffc020312a <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0203074:	414786b3          	sub	a3,a5,s4
ffffffffc0203078:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc020307a:	8699                	srai	a3,a3,0x6
ffffffffc020307c:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc020307e:	00c69793          	slli	a5,a3,0xc
ffffffffc0203082:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0203084:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0203088:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020308a:	22e7f663          	bgeu	a5,a4,ffffffffc02032b6 <swap_init+0x582>
     free_page(pde2page(pd0[0]));
ffffffffc020308e:	00012797          	auipc	a5,0x12
ffffffffc0203092:	4ea7b783          	ld	a5,1258(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc0203096:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203098:	629c                	ld	a5,0(a3)
ffffffffc020309a:	078a                	slli	a5,a5,0x2
ffffffffc020309c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020309e:	08e7f663          	bgeu	a5,a4,ffffffffc020312a <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc02030a2:	414787b3          	sub	a5,a5,s4
ffffffffc02030a6:	079a                	slli	a5,a5,0x6
ffffffffc02030a8:	953e                	add	a0,a0,a5
ffffffffc02030aa:	4585                	li	a1,1
ffffffffc02030ac:	b91fd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02030b0:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc02030b4:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc02030b8:	078a                	slli	a5,a5,0x2
ffffffffc02030ba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02030bc:	06e7f763          	bgeu	a5,a4,ffffffffc020312a <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc02030c0:	000cb503          	ld	a0,0(s9)
ffffffffc02030c4:	414787b3          	sub	a5,a5,s4
ffffffffc02030c8:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc02030ca:	4585                	li	a1,1
ffffffffc02030cc:	953e                	add	a0,a0,a5
ffffffffc02030ce:	b6ffd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
     pgdir[0] = 0;
ffffffffc02030d2:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc02030d6:	12000073          	sfence.vma
    return listelm->next;
ffffffffc02030da:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02030dc:	00878a63          	beq	a5,s0,ffffffffc02030f0 <swap_init+0x3bc>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc02030e0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02030e4:	679c                	ld	a5,8(a5)
ffffffffc02030e6:	3dfd                	addiw	s11,s11,-1
ffffffffc02030e8:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02030ec:	fe879ae3          	bne	a5,s0,ffffffffc02030e0 <swap_init+0x3ac>
     }
     assert(count==0);
ffffffffc02030f0:	1c0d9f63          	bnez	s11,ffffffffc02032ce <swap_init+0x59a>
     assert(total==0);
ffffffffc02030f4:	1a0d1163          	bnez	s10,ffffffffc0203296 <swap_init+0x562>

     cprintf("check_swap() succeeded!\n");
ffffffffc02030f8:	00003517          	auipc	a0,0x3
ffffffffc02030fc:	5c850513          	addi	a0,a0,1480 # ffffffffc02066c0 <commands+0x1558>
ffffffffc0203100:	fcdfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0203104:	b149                	j	ffffffffc0202d86 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203106:	4481                	li	s1,0
ffffffffc0203108:	b1e5                	j	ffffffffc0202df0 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc020310a:	00003697          	auipc	a3,0x3
ffffffffc020310e:	37668693          	addi	a3,a3,886 # ffffffffc0206480 <commands+0x1318>
ffffffffc0203112:	00003617          	auipc	a2,0x3
ffffffffc0203116:	8c660613          	addi	a2,a2,-1850 # ffffffffc02059d8 <commands+0x870>
ffffffffc020311a:	0bd00593          	li	a1,189
ffffffffc020311e:	00003517          	auipc	a0,0x3
ffffffffc0203122:	33a50513          	addi	a0,a0,826 # ffffffffc0206458 <commands+0x12f0>
ffffffffc0203126:	8a2fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc020312a:	befff0ef          	jal	ra,ffffffffc0202d18 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc020312e:	00002617          	auipc	a2,0x2
ffffffffc0203132:	74260613          	addi	a2,a2,1858 # ffffffffc0205870 <commands+0x708>
ffffffffc0203136:	06200593          	li	a1,98
ffffffffc020313a:	00002517          	auipc	a0,0x2
ffffffffc020313e:	75650513          	addi	a0,a0,1878 # ffffffffc0205890 <commands+0x728>
ffffffffc0203142:	886fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203146:	00003697          	auipc	a3,0x3
ffffffffc020314a:	50268693          	addi	a3,a3,1282 # ffffffffc0206648 <commands+0x14e0>
ffffffffc020314e:	00003617          	auipc	a2,0x3
ffffffffc0203152:	88a60613          	addi	a2,a2,-1910 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203156:	0fd00593          	li	a1,253
ffffffffc020315a:	00003517          	auipc	a0,0x3
ffffffffc020315e:	2fe50513          	addi	a0,a0,766 # ffffffffc0206458 <commands+0x12f0>
ffffffffc0203162:	866fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203166:	00003697          	auipc	a3,0x3
ffffffffc020316a:	40268693          	addi	a3,a3,1026 # ffffffffc0206568 <commands+0x1400>
ffffffffc020316e:	00003617          	auipc	a2,0x3
ffffffffc0203172:	86a60613          	addi	a2,a2,-1942 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203176:	0dd00593          	li	a1,221
ffffffffc020317a:	00003517          	auipc	a0,0x3
ffffffffc020317e:	2de50513          	addi	a0,a0,734 # ffffffffc0206458 <commands+0x12f0>
ffffffffc0203182:	846fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203186:	00003617          	auipc	a2,0x3
ffffffffc020318a:	2b260613          	addi	a2,a2,690 # ffffffffc0206438 <commands+0x12d0>
ffffffffc020318e:	02a00593          	li	a1,42
ffffffffc0203192:	00003517          	auipc	a0,0x3
ffffffffc0203196:	2c650513          	addi	a0,a0,710 # ffffffffc0206458 <commands+0x12f0>
ffffffffc020319a:	82efd0ef          	jal	ra,ffffffffc02001c8 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020319e:	00003697          	auipc	a3,0x3
ffffffffc02031a2:	49268693          	addi	a3,a3,1170 # ffffffffc0206630 <commands+0x14c8>
ffffffffc02031a6:	00003617          	auipc	a2,0x3
ffffffffc02031aa:	83260613          	addi	a2,a2,-1998 # ffffffffc02059d8 <commands+0x870>
ffffffffc02031ae:	0fc00593          	li	a1,252
ffffffffc02031b2:	00003517          	auipc	a0,0x3
ffffffffc02031b6:	2a650513          	addi	a0,a0,678 # ffffffffc0206458 <commands+0x12f0>
ffffffffc02031ba:	80efd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02031be:	00002617          	auipc	a2,0x2
ffffffffc02031c2:	6e260613          	addi	a2,a2,1762 # ffffffffc02058a0 <commands+0x738>
ffffffffc02031c6:	07400593          	li	a1,116
ffffffffc02031ca:	00002517          	auipc	a0,0x2
ffffffffc02031ce:	6c650513          	addi	a0,a0,1734 # ffffffffc0205890 <commands+0x728>
ffffffffc02031d2:	ff7fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02031d6:	00003697          	auipc	a3,0x3
ffffffffc02031da:	3aa68693          	addi	a3,a3,938 # ffffffffc0206580 <commands+0x1418>
ffffffffc02031de:	00002617          	auipc	a2,0x2
ffffffffc02031e2:	7fa60613          	addi	a2,a2,2042 # ffffffffc02059d8 <commands+0x870>
ffffffffc02031e6:	0de00593          	li	a1,222
ffffffffc02031ea:	00003517          	auipc	a0,0x3
ffffffffc02031ee:	26e50513          	addi	a0,a0,622 # ffffffffc0206458 <commands+0x12f0>
ffffffffc02031f2:	fd7fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc02031f6:	00003697          	auipc	a3,0x3
ffffffffc02031fa:	2e268693          	addi	a3,a3,738 # ffffffffc02064d8 <commands+0x1370>
ffffffffc02031fe:	00002617          	auipc	a2,0x2
ffffffffc0203202:	7da60613          	addi	a2,a2,2010 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203206:	0c800593          	li	a1,200
ffffffffc020320a:	00003517          	auipc	a0,0x3
ffffffffc020320e:	24e50513          	addi	a0,a0,590 # ffffffffc0206458 <commands+0x12f0>
ffffffffc0203212:	fb7fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203216:	00003697          	auipc	a3,0x3
ffffffffc020321a:	27a68693          	addi	a3,a3,634 # ffffffffc0206490 <commands+0x1328>
ffffffffc020321e:	00002617          	auipc	a2,0x2
ffffffffc0203222:	7ba60613          	addi	a2,a2,1978 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203226:	0c000593          	li	a1,192
ffffffffc020322a:	00003517          	auipc	a0,0x3
ffffffffc020322e:	22e50513          	addi	a0,a0,558 # ffffffffc0206458 <commands+0x12f0>
ffffffffc0203232:	f97fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert( nr_free == 0);         
ffffffffc0203236:	00003697          	auipc	a3,0x3
ffffffffc020323a:	3ea68693          	addi	a3,a3,1002 # ffffffffc0206620 <commands+0x14b8>
ffffffffc020323e:	00002617          	auipc	a2,0x2
ffffffffc0203242:	79a60613          	addi	a2,a2,1946 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203246:	0f400593          	li	a1,244
ffffffffc020324a:	00003517          	auipc	a0,0x3
ffffffffc020324e:	20e50513          	addi	a0,a0,526 # ffffffffc0206458 <commands+0x12f0>
ffffffffc0203252:	f77fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203256:	00003697          	auipc	a3,0x3
ffffffffc020325a:	ffa68693          	addi	a3,a3,-6 # ffffffffc0206250 <commands+0x10e8>
ffffffffc020325e:	00002617          	auipc	a2,0x2
ffffffffc0203262:	77a60613          	addi	a2,a2,1914 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203266:	0cd00593          	li	a1,205
ffffffffc020326a:	00003517          	auipc	a0,0x3
ffffffffc020326e:	1ee50513          	addi	a0,a0,494 # ffffffffc0206458 <commands+0x12f0>
ffffffffc0203272:	f57fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(mm != NULL);
ffffffffc0203276:	00003697          	auipc	a3,0x3
ffffffffc020327a:	0a268693          	addi	a3,a3,162 # ffffffffc0206318 <commands+0x11b0>
ffffffffc020327e:	00002617          	auipc	a2,0x2
ffffffffc0203282:	75a60613          	addi	a2,a2,1882 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203286:	0c500593          	li	a1,197
ffffffffc020328a:	00003517          	auipc	a0,0x3
ffffffffc020328e:	1ce50513          	addi	a0,a0,462 # ffffffffc0206458 <commands+0x12f0>
ffffffffc0203292:	f37fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(total==0);
ffffffffc0203296:	00003697          	auipc	a3,0x3
ffffffffc020329a:	41a68693          	addi	a3,a3,1050 # ffffffffc02066b0 <commands+0x1548>
ffffffffc020329e:	00002617          	auipc	a2,0x2
ffffffffc02032a2:	73a60613          	addi	a2,a2,1850 # ffffffffc02059d8 <commands+0x870>
ffffffffc02032a6:	11d00593          	li	a1,285
ffffffffc02032aa:	00003517          	auipc	a0,0x3
ffffffffc02032ae:	1ae50513          	addi	a0,a0,430 # ffffffffc0206458 <commands+0x12f0>
ffffffffc02032b2:	f17fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc02032b6:	00002617          	auipc	a2,0x2
ffffffffc02032ba:	61260613          	addi	a2,a2,1554 # ffffffffc02058c8 <commands+0x760>
ffffffffc02032be:	06900593          	li	a1,105
ffffffffc02032c2:	00002517          	auipc	a0,0x2
ffffffffc02032c6:	5ce50513          	addi	a0,a0,1486 # ffffffffc0205890 <commands+0x728>
ffffffffc02032ca:	efffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(count==0);
ffffffffc02032ce:	00003697          	auipc	a3,0x3
ffffffffc02032d2:	3d268693          	addi	a3,a3,978 # ffffffffc02066a0 <commands+0x1538>
ffffffffc02032d6:	00002617          	auipc	a2,0x2
ffffffffc02032da:	70260613          	addi	a2,a2,1794 # ffffffffc02059d8 <commands+0x870>
ffffffffc02032de:	11c00593          	li	a1,284
ffffffffc02032e2:	00003517          	auipc	a0,0x3
ffffffffc02032e6:	17650513          	addi	a0,a0,374 # ffffffffc0206458 <commands+0x12f0>
ffffffffc02032ea:	edffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==1);
ffffffffc02032ee:	00003697          	auipc	a3,0x3
ffffffffc02032f2:	30268693          	addi	a3,a3,770 # ffffffffc02065f0 <commands+0x1488>
ffffffffc02032f6:	00002617          	auipc	a2,0x2
ffffffffc02032fa:	6e260613          	addi	a2,a2,1762 # ffffffffc02059d8 <commands+0x870>
ffffffffc02032fe:	09600593          	li	a1,150
ffffffffc0203302:	00003517          	auipc	a0,0x3
ffffffffc0203306:	15650513          	addi	a0,a0,342 # ffffffffc0206458 <commands+0x12f0>
ffffffffc020330a:	ebffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020330e:	00003697          	auipc	a3,0x3
ffffffffc0203312:	29268693          	addi	a3,a3,658 # ffffffffc02065a0 <commands+0x1438>
ffffffffc0203316:	00002617          	auipc	a2,0x2
ffffffffc020331a:	6c260613          	addi	a2,a2,1730 # ffffffffc02059d8 <commands+0x870>
ffffffffc020331e:	0eb00593          	li	a1,235
ffffffffc0203322:	00003517          	auipc	a0,0x3
ffffffffc0203326:	13650513          	addi	a0,a0,310 # ffffffffc0206458 <commands+0x12f0>
ffffffffc020332a:	e9ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc020332e:	00003697          	auipc	a3,0x3
ffffffffc0203332:	1fa68693          	addi	a3,a3,506 # ffffffffc0206528 <commands+0x13c0>
ffffffffc0203336:	00002617          	auipc	a2,0x2
ffffffffc020333a:	6a260613          	addi	a2,a2,1698 # ffffffffc02059d8 <commands+0x870>
ffffffffc020333e:	0d800593          	li	a1,216
ffffffffc0203342:	00003517          	auipc	a0,0x3
ffffffffc0203346:	11650513          	addi	a0,a0,278 # ffffffffc0206458 <commands+0x12f0>
ffffffffc020334a:	e7ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(ret==0);
ffffffffc020334e:	00003697          	auipc	a3,0x3
ffffffffc0203352:	34a68693          	addi	a3,a3,842 # ffffffffc0206698 <commands+0x1530>
ffffffffc0203356:	00002617          	auipc	a2,0x2
ffffffffc020335a:	68260613          	addi	a2,a2,1666 # ffffffffc02059d8 <commands+0x870>
ffffffffc020335e:	10300593          	li	a1,259
ffffffffc0203362:	00003517          	auipc	a0,0x3
ffffffffc0203366:	0f650513          	addi	a0,a0,246 # ffffffffc0206458 <commands+0x12f0>
ffffffffc020336a:	e5ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(vma != NULL);
ffffffffc020336e:	00003697          	auipc	a3,0x3
ffffffffc0203372:	f8268693          	addi	a3,a3,-126 # ffffffffc02062f0 <commands+0x1188>
ffffffffc0203376:	00002617          	auipc	a2,0x2
ffffffffc020337a:	66260613          	addi	a2,a2,1634 # ffffffffc02059d8 <commands+0x870>
ffffffffc020337e:	0d000593          	li	a1,208
ffffffffc0203382:	00003517          	auipc	a0,0x3
ffffffffc0203386:	0d650513          	addi	a0,a0,214 # ffffffffc0206458 <commands+0x12f0>
ffffffffc020338a:	e3ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==4);
ffffffffc020338e:	00003697          	auipc	a3,0x3
ffffffffc0203392:	b1a68693          	addi	a3,a3,-1254 # ffffffffc0205ea8 <commands+0xd40>
ffffffffc0203396:	00002617          	auipc	a2,0x2
ffffffffc020339a:	64260613          	addi	a2,a2,1602 # ffffffffc02059d8 <commands+0x870>
ffffffffc020339e:	0a000593          	li	a1,160
ffffffffc02033a2:	00003517          	auipc	a0,0x3
ffffffffc02033a6:	0b650513          	addi	a0,a0,182 # ffffffffc0206458 <commands+0x12f0>
ffffffffc02033aa:	e1ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==4);
ffffffffc02033ae:	00003697          	auipc	a3,0x3
ffffffffc02033b2:	afa68693          	addi	a3,a3,-1286 # ffffffffc0205ea8 <commands+0xd40>
ffffffffc02033b6:	00002617          	auipc	a2,0x2
ffffffffc02033ba:	62260613          	addi	a2,a2,1570 # ffffffffc02059d8 <commands+0x870>
ffffffffc02033be:	0a200593          	li	a1,162
ffffffffc02033c2:	00003517          	auipc	a0,0x3
ffffffffc02033c6:	09650513          	addi	a0,a0,150 # ffffffffc0206458 <commands+0x12f0>
ffffffffc02033ca:	dfffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==2);
ffffffffc02033ce:	00003697          	auipc	a3,0x3
ffffffffc02033d2:	23268693          	addi	a3,a3,562 # ffffffffc0206600 <commands+0x1498>
ffffffffc02033d6:	00002617          	auipc	a2,0x2
ffffffffc02033da:	60260613          	addi	a2,a2,1538 # ffffffffc02059d8 <commands+0x870>
ffffffffc02033de:	09800593          	li	a1,152
ffffffffc02033e2:	00003517          	auipc	a0,0x3
ffffffffc02033e6:	07650513          	addi	a0,a0,118 # ffffffffc0206458 <commands+0x12f0>
ffffffffc02033ea:	ddffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==2);
ffffffffc02033ee:	00003697          	auipc	a3,0x3
ffffffffc02033f2:	21268693          	addi	a3,a3,530 # ffffffffc0206600 <commands+0x1498>
ffffffffc02033f6:	00002617          	auipc	a2,0x2
ffffffffc02033fa:	5e260613          	addi	a2,a2,1506 # ffffffffc02059d8 <commands+0x870>
ffffffffc02033fe:	09a00593          	li	a1,154
ffffffffc0203402:	00003517          	auipc	a0,0x3
ffffffffc0203406:	05650513          	addi	a0,a0,86 # ffffffffc0206458 <commands+0x12f0>
ffffffffc020340a:	dbffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==3);
ffffffffc020340e:	00003697          	auipc	a3,0x3
ffffffffc0203412:	20268693          	addi	a3,a3,514 # ffffffffc0206610 <commands+0x14a8>
ffffffffc0203416:	00002617          	auipc	a2,0x2
ffffffffc020341a:	5c260613          	addi	a2,a2,1474 # ffffffffc02059d8 <commands+0x870>
ffffffffc020341e:	09c00593          	li	a1,156
ffffffffc0203422:	00003517          	auipc	a0,0x3
ffffffffc0203426:	03650513          	addi	a0,a0,54 # ffffffffc0206458 <commands+0x12f0>
ffffffffc020342a:	d9ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==3);
ffffffffc020342e:	00003697          	auipc	a3,0x3
ffffffffc0203432:	1e268693          	addi	a3,a3,482 # ffffffffc0206610 <commands+0x14a8>
ffffffffc0203436:	00002617          	auipc	a2,0x2
ffffffffc020343a:	5a260613          	addi	a2,a2,1442 # ffffffffc02059d8 <commands+0x870>
ffffffffc020343e:	09e00593          	li	a1,158
ffffffffc0203442:	00003517          	auipc	a0,0x3
ffffffffc0203446:	01650513          	addi	a0,a0,22 # ffffffffc0206458 <commands+0x12f0>
ffffffffc020344a:	d7ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==1);
ffffffffc020344e:	00003697          	auipc	a3,0x3
ffffffffc0203452:	1a268693          	addi	a3,a3,418 # ffffffffc02065f0 <commands+0x1488>
ffffffffc0203456:	00002617          	auipc	a2,0x2
ffffffffc020345a:	58260613          	addi	a2,a2,1410 # ffffffffc02059d8 <commands+0x870>
ffffffffc020345e:	09400593          	li	a1,148
ffffffffc0203462:	00003517          	auipc	a0,0x3
ffffffffc0203466:	ff650513          	addi	a0,a0,-10 # ffffffffc0206458 <commands+0x12f0>
ffffffffc020346a:	d5ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020346e <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc020346e:	00012797          	auipc	a5,0x12
ffffffffc0203472:	1327b783          	ld	a5,306(a5) # ffffffffc02155a0 <sm>
ffffffffc0203476:	6b9c                	ld	a5,16(a5)
ffffffffc0203478:	8782                	jr	a5

ffffffffc020347a <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc020347a:	00012797          	auipc	a5,0x12
ffffffffc020347e:	1267b783          	ld	a5,294(a5) # ffffffffc02155a0 <sm>
ffffffffc0203482:	739c                	ld	a5,32(a5)
ffffffffc0203484:	8782                	jr	a5

ffffffffc0203486 <swap_out>:
{
ffffffffc0203486:	711d                	addi	sp,sp,-96
ffffffffc0203488:	ec86                	sd	ra,88(sp)
ffffffffc020348a:	e8a2                	sd	s0,80(sp)
ffffffffc020348c:	e4a6                	sd	s1,72(sp)
ffffffffc020348e:	e0ca                	sd	s2,64(sp)
ffffffffc0203490:	fc4e                	sd	s3,56(sp)
ffffffffc0203492:	f852                	sd	s4,48(sp)
ffffffffc0203494:	f456                	sd	s5,40(sp)
ffffffffc0203496:	f05a                	sd	s6,32(sp)
ffffffffc0203498:	ec5e                	sd	s7,24(sp)
ffffffffc020349a:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc020349c:	cde9                	beqz	a1,ffffffffc0203576 <swap_out+0xf0>
ffffffffc020349e:	8a2e                	mv	s4,a1
ffffffffc02034a0:	892a                	mv	s2,a0
ffffffffc02034a2:	8ab2                	mv	s5,a2
ffffffffc02034a4:	4401                	li	s0,0
ffffffffc02034a6:	00012997          	auipc	s3,0x12
ffffffffc02034aa:	0fa98993          	addi	s3,s3,250 # ffffffffc02155a0 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02034ae:	00003b17          	auipc	s6,0x3
ffffffffc02034b2:	292b0b13          	addi	s6,s6,658 # ffffffffc0206740 <commands+0x15d8>
                    cprintf("SWAP: failed to save\n");
ffffffffc02034b6:	00003b97          	auipc	s7,0x3
ffffffffc02034ba:	272b8b93          	addi	s7,s7,626 # ffffffffc0206728 <commands+0x15c0>
ffffffffc02034be:	a825                	j	ffffffffc02034f6 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02034c0:	67a2                	ld	a5,8(sp)
ffffffffc02034c2:	8626                	mv	a2,s1
ffffffffc02034c4:	85a2                	mv	a1,s0
ffffffffc02034c6:	7f94                	ld	a3,56(a5)
ffffffffc02034c8:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02034ca:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02034cc:	82b1                	srli	a3,a3,0xc
ffffffffc02034ce:	0685                	addi	a3,a3,1
ffffffffc02034d0:	bfdfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02034d4:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc02034d6:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02034d8:	7d1c                	ld	a5,56(a0)
ffffffffc02034da:	83b1                	srli	a5,a5,0xc
ffffffffc02034dc:	0785                	addi	a5,a5,1
ffffffffc02034de:	07a2                	slli	a5,a5,0x8
ffffffffc02034e0:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc02034e4:	f58fd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc02034e8:	01893503          	ld	a0,24(s2)
ffffffffc02034ec:	85a6                	mv	a1,s1
ffffffffc02034ee:	f1afe0ef          	jal	ra,ffffffffc0201c08 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc02034f2:	048a0d63          	beq	s4,s0,ffffffffc020354c <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc02034f6:	0009b783          	ld	a5,0(s3)
ffffffffc02034fa:	8656                	mv	a2,s5
ffffffffc02034fc:	002c                	addi	a1,sp,8
ffffffffc02034fe:	7b9c                	ld	a5,48(a5)
ffffffffc0203500:	854a                	mv	a0,s2
ffffffffc0203502:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203504:	e12d                	bnez	a0,ffffffffc0203566 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203506:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203508:	01893503          	ld	a0,24(s2)
ffffffffc020350c:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc020350e:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203510:	85a6                	mv	a1,s1
ffffffffc0203512:	fa4fd0ef          	jal	ra,ffffffffc0200cb6 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203516:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203518:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc020351a:	8b85                	andi	a5,a5,1
ffffffffc020351c:	cfb9                	beqz	a5,ffffffffc020357a <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc020351e:	65a2                	ld	a1,8(sp)
ffffffffc0203520:	7d9c                	ld	a5,56(a1)
ffffffffc0203522:	83b1                	srli	a5,a5,0xc
ffffffffc0203524:	0785                	addi	a5,a5,1
ffffffffc0203526:	00879513          	slli	a0,a5,0x8
ffffffffc020352a:	45f000ef          	jal	ra,ffffffffc0204188 <swapfs_write>
ffffffffc020352e:	d949                	beqz	a0,ffffffffc02034c0 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203530:	855e                	mv	a0,s7
ffffffffc0203532:	b9bfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203536:	0009b783          	ld	a5,0(s3)
ffffffffc020353a:	6622                	ld	a2,8(sp)
ffffffffc020353c:	4681                	li	a3,0
ffffffffc020353e:	739c                	ld	a5,32(a5)
ffffffffc0203540:	85a6                	mv	a1,s1
ffffffffc0203542:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203544:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203546:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203548:	fa8a17e3          	bne	s4,s0,ffffffffc02034f6 <swap_out+0x70>
}
ffffffffc020354c:	60e6                	ld	ra,88(sp)
ffffffffc020354e:	8522                	mv	a0,s0
ffffffffc0203550:	6446                	ld	s0,80(sp)
ffffffffc0203552:	64a6                	ld	s1,72(sp)
ffffffffc0203554:	6906                	ld	s2,64(sp)
ffffffffc0203556:	79e2                	ld	s3,56(sp)
ffffffffc0203558:	7a42                	ld	s4,48(sp)
ffffffffc020355a:	7aa2                	ld	s5,40(sp)
ffffffffc020355c:	7b02                	ld	s6,32(sp)
ffffffffc020355e:	6be2                	ld	s7,24(sp)
ffffffffc0203560:	6c42                	ld	s8,16(sp)
ffffffffc0203562:	6125                	addi	sp,sp,96
ffffffffc0203564:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203566:	85a2                	mv	a1,s0
ffffffffc0203568:	00003517          	auipc	a0,0x3
ffffffffc020356c:	17850513          	addi	a0,a0,376 # ffffffffc02066e0 <commands+0x1578>
ffffffffc0203570:	b5dfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc0203574:	bfe1                	j	ffffffffc020354c <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203576:	4401                	li	s0,0
ffffffffc0203578:	bfd1                	j	ffffffffc020354c <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc020357a:	00003697          	auipc	a3,0x3
ffffffffc020357e:	19668693          	addi	a3,a3,406 # ffffffffc0206710 <commands+0x15a8>
ffffffffc0203582:	00002617          	auipc	a2,0x2
ffffffffc0203586:	45660613          	addi	a2,a2,1110 # ffffffffc02059d8 <commands+0x870>
ffffffffc020358a:	06900593          	li	a1,105
ffffffffc020358e:	00003517          	auipc	a0,0x3
ffffffffc0203592:	eca50513          	addi	a0,a0,-310 # ffffffffc0206458 <commands+0x12f0>
ffffffffc0203596:	c33fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020359a <swap_in>:
{
ffffffffc020359a:	7179                	addi	sp,sp,-48
ffffffffc020359c:	e84a                	sd	s2,16(sp)
ffffffffc020359e:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02035a0:	4505                	li	a0,1
{
ffffffffc02035a2:	ec26                	sd	s1,24(sp)
ffffffffc02035a4:	e44e                	sd	s3,8(sp)
ffffffffc02035a6:	f406                	sd	ra,40(sp)
ffffffffc02035a8:	f022                	sd	s0,32(sp)
ffffffffc02035aa:	84ae                	mv	s1,a1
ffffffffc02035ac:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02035ae:	dfcfd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
     assert(result!=NULL);
ffffffffc02035b2:	c129                	beqz	a0,ffffffffc02035f4 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02035b4:	842a                	mv	s0,a0
ffffffffc02035b6:	01893503          	ld	a0,24(s2)
ffffffffc02035ba:	4601                	li	a2,0
ffffffffc02035bc:	85a6                	mv	a1,s1
ffffffffc02035be:	ef8fd0ef          	jal	ra,ffffffffc0200cb6 <get_pte>
ffffffffc02035c2:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc02035c4:	6108                	ld	a0,0(a0)
ffffffffc02035c6:	85a2                	mv	a1,s0
ffffffffc02035c8:	333000ef          	jal	ra,ffffffffc02040fa <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc02035cc:	00093583          	ld	a1,0(s2)
ffffffffc02035d0:	8626                	mv	a2,s1
ffffffffc02035d2:	00003517          	auipc	a0,0x3
ffffffffc02035d6:	1be50513          	addi	a0,a0,446 # ffffffffc0206790 <commands+0x1628>
ffffffffc02035da:	81a1                	srli	a1,a1,0x8
ffffffffc02035dc:	af1fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02035e0:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc02035e2:	0089b023          	sd	s0,0(s3)
}
ffffffffc02035e6:	7402                	ld	s0,32(sp)
ffffffffc02035e8:	64e2                	ld	s1,24(sp)
ffffffffc02035ea:	6942                	ld	s2,16(sp)
ffffffffc02035ec:	69a2                	ld	s3,8(sp)
ffffffffc02035ee:	4501                	li	a0,0
ffffffffc02035f0:	6145                	addi	sp,sp,48
ffffffffc02035f2:	8082                	ret
     assert(result!=NULL);
ffffffffc02035f4:	00003697          	auipc	a3,0x3
ffffffffc02035f8:	18c68693          	addi	a3,a3,396 # ffffffffc0206780 <commands+0x1618>
ffffffffc02035fc:	00002617          	auipc	a2,0x2
ffffffffc0203600:	3dc60613          	addi	a2,a2,988 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203604:	07f00593          	li	a1,127
ffffffffc0203608:	00003517          	auipc	a0,0x3
ffffffffc020360c:	e5050513          	addi	a0,a0,-432 # ffffffffc0206458 <commands+0x12f0>
ffffffffc0203610:	bb9fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203614 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0203614:	0000e797          	auipc	a5,0xe
ffffffffc0203618:	eec78793          	addi	a5,a5,-276 # ffffffffc0211500 <free_area>
ffffffffc020361c:	e79c                	sd	a5,8(a5)
ffffffffc020361e:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0203620:	0007a823          	sw	zero,16(a5)
}
ffffffffc0203624:	8082                	ret

ffffffffc0203626 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0203626:	0000e517          	auipc	a0,0xe
ffffffffc020362a:	eea56503          	lwu	a0,-278(a0) # ffffffffc0211510 <free_area+0x10>
ffffffffc020362e:	8082                	ret

ffffffffc0203630 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0203630:	715d                	addi	sp,sp,-80
ffffffffc0203632:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0203634:	0000e417          	auipc	s0,0xe
ffffffffc0203638:	ecc40413          	addi	s0,s0,-308 # ffffffffc0211500 <free_area>
ffffffffc020363c:	641c                	ld	a5,8(s0)
ffffffffc020363e:	e486                	sd	ra,72(sp)
ffffffffc0203640:	fc26                	sd	s1,56(sp)
ffffffffc0203642:	f84a                	sd	s2,48(sp)
ffffffffc0203644:	f44e                	sd	s3,40(sp)
ffffffffc0203646:	f052                	sd	s4,32(sp)
ffffffffc0203648:	ec56                	sd	s5,24(sp)
ffffffffc020364a:	e85a                	sd	s6,16(sp)
ffffffffc020364c:	e45e                	sd	s7,8(sp)
ffffffffc020364e:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203650:	2a878d63          	beq	a5,s0,ffffffffc020390a <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0203654:	4481                	li	s1,0
ffffffffc0203656:	4901                	li	s2,0
ffffffffc0203658:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020365c:	8b09                	andi	a4,a4,2
ffffffffc020365e:	2a070a63          	beqz	a4,ffffffffc0203912 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0203662:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203666:	679c                	ld	a5,8(a5)
ffffffffc0203668:	2905                	addiw	s2,s2,1
ffffffffc020366a:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020366c:	fe8796e3          	bne	a5,s0,ffffffffc0203658 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0203670:	89a6                	mv	s3,s1
ffffffffc0203672:	e0afd0ef          	jal	ra,ffffffffc0200c7c <nr_free_pages>
ffffffffc0203676:	6f351e63          	bne	a0,s3,ffffffffc0203d72 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020367a:	4505                	li	a0,1
ffffffffc020367c:	d2efd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0203680:	8aaa                	mv	s5,a0
ffffffffc0203682:	42050863          	beqz	a0,ffffffffc0203ab2 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203686:	4505                	li	a0,1
ffffffffc0203688:	d22fd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc020368c:	89aa                	mv	s3,a0
ffffffffc020368e:	70050263          	beqz	a0,ffffffffc0203d92 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203692:	4505                	li	a0,1
ffffffffc0203694:	d16fd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0203698:	8a2a                	mv	s4,a0
ffffffffc020369a:	48050c63          	beqz	a0,ffffffffc0203b32 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020369e:	293a8a63          	beq	s5,s3,ffffffffc0203932 <default_check+0x302>
ffffffffc02036a2:	28aa8863          	beq	s5,a0,ffffffffc0203932 <default_check+0x302>
ffffffffc02036a6:	28a98663          	beq	s3,a0,ffffffffc0203932 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02036aa:	000aa783          	lw	a5,0(s5)
ffffffffc02036ae:	2a079263          	bnez	a5,ffffffffc0203952 <default_check+0x322>
ffffffffc02036b2:	0009a783          	lw	a5,0(s3)
ffffffffc02036b6:	28079e63          	bnez	a5,ffffffffc0203952 <default_check+0x322>
ffffffffc02036ba:	411c                	lw	a5,0(a0)
ffffffffc02036bc:	28079b63          	bnez	a5,ffffffffc0203952 <default_check+0x322>
    return page - pages + nbase;
ffffffffc02036c0:	00012797          	auipc	a5,0x12
ffffffffc02036c4:	ea87b783          	ld	a5,-344(a5) # ffffffffc0215568 <pages>
ffffffffc02036c8:	40fa8733          	sub	a4,s5,a5
ffffffffc02036cc:	00004617          	auipc	a2,0x4
ffffffffc02036d0:	8f463603          	ld	a2,-1804(a2) # ffffffffc0206fc0 <nbase>
ffffffffc02036d4:	8719                	srai	a4,a4,0x6
ffffffffc02036d6:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02036d8:	00012697          	auipc	a3,0x12
ffffffffc02036dc:	e886b683          	ld	a3,-376(a3) # ffffffffc0215560 <npage>
ffffffffc02036e0:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02036e2:	0732                	slli	a4,a4,0xc
ffffffffc02036e4:	28d77763          	bgeu	a4,a3,ffffffffc0203972 <default_check+0x342>
    return page - pages + nbase;
ffffffffc02036e8:	40f98733          	sub	a4,s3,a5
ffffffffc02036ec:	8719                	srai	a4,a4,0x6
ffffffffc02036ee:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02036f0:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02036f2:	4cd77063          	bgeu	a4,a3,ffffffffc0203bb2 <default_check+0x582>
    return page - pages + nbase;
ffffffffc02036f6:	40f507b3          	sub	a5,a0,a5
ffffffffc02036fa:	8799                	srai	a5,a5,0x6
ffffffffc02036fc:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02036fe:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203700:	30d7f963          	bgeu	a5,a3,ffffffffc0203a12 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0203704:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0203706:	00043c03          	ld	s8,0(s0)
ffffffffc020370a:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc020370e:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0203712:	e400                	sd	s0,8(s0)
ffffffffc0203714:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0203716:	0000e797          	auipc	a5,0xe
ffffffffc020371a:	de07ad23          	sw	zero,-518(a5) # ffffffffc0211510 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc020371e:	c8cfd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0203722:	2c051863          	bnez	a0,ffffffffc02039f2 <default_check+0x3c2>
    free_page(p0);
ffffffffc0203726:	4585                	li	a1,1
ffffffffc0203728:	8556                	mv	a0,s5
ffffffffc020372a:	d12fd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    free_page(p1);
ffffffffc020372e:	4585                	li	a1,1
ffffffffc0203730:	854e                	mv	a0,s3
ffffffffc0203732:	d0afd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    free_page(p2);
ffffffffc0203736:	4585                	li	a1,1
ffffffffc0203738:	8552                	mv	a0,s4
ffffffffc020373a:	d02fd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    assert(nr_free == 3);
ffffffffc020373e:	4818                	lw	a4,16(s0)
ffffffffc0203740:	478d                	li	a5,3
ffffffffc0203742:	28f71863          	bne	a4,a5,ffffffffc02039d2 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203746:	4505                	li	a0,1
ffffffffc0203748:	c62fd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc020374c:	89aa                	mv	s3,a0
ffffffffc020374e:	26050263          	beqz	a0,ffffffffc02039b2 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203752:	4505                	li	a0,1
ffffffffc0203754:	c56fd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0203758:	8aaa                	mv	s5,a0
ffffffffc020375a:	3a050c63          	beqz	a0,ffffffffc0203b12 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020375e:	4505                	li	a0,1
ffffffffc0203760:	c4afd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0203764:	8a2a                	mv	s4,a0
ffffffffc0203766:	38050663          	beqz	a0,ffffffffc0203af2 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc020376a:	4505                	li	a0,1
ffffffffc020376c:	c3efd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0203770:	36051163          	bnez	a0,ffffffffc0203ad2 <default_check+0x4a2>
    free_page(p0);
ffffffffc0203774:	4585                	li	a1,1
ffffffffc0203776:	854e                	mv	a0,s3
ffffffffc0203778:	cc4fd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020377c:	641c                	ld	a5,8(s0)
ffffffffc020377e:	20878a63          	beq	a5,s0,ffffffffc0203992 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0203782:	4505                	li	a0,1
ffffffffc0203784:	c26fd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0203788:	30a99563          	bne	s3,a0,ffffffffc0203a92 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc020378c:	4505                	li	a0,1
ffffffffc020378e:	c1cfd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0203792:	2e051063          	bnez	a0,ffffffffc0203a72 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0203796:	481c                	lw	a5,16(s0)
ffffffffc0203798:	2a079d63          	bnez	a5,ffffffffc0203a52 <default_check+0x422>
    free_page(p);
ffffffffc020379c:	854e                	mv	a0,s3
ffffffffc020379e:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02037a0:	01843023          	sd	s8,0(s0)
ffffffffc02037a4:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02037a8:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02037ac:	c90fd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    free_page(p1);
ffffffffc02037b0:	4585                	li	a1,1
ffffffffc02037b2:	8556                	mv	a0,s5
ffffffffc02037b4:	c88fd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    free_page(p2);
ffffffffc02037b8:	4585                	li	a1,1
ffffffffc02037ba:	8552                	mv	a0,s4
ffffffffc02037bc:	c80fd0ef          	jal	ra,ffffffffc0200c3c <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02037c0:	4515                	li	a0,5
ffffffffc02037c2:	be8fd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc02037c6:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02037c8:	26050563          	beqz	a0,ffffffffc0203a32 <default_check+0x402>
ffffffffc02037cc:	651c                	ld	a5,8(a0)
ffffffffc02037ce:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02037d0:	8b85                	andi	a5,a5,1
ffffffffc02037d2:	54079063          	bnez	a5,ffffffffc0203d12 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02037d6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02037d8:	00043b03          	ld	s6,0(s0)
ffffffffc02037dc:	00843a83          	ld	s5,8(s0)
ffffffffc02037e0:	e000                	sd	s0,0(s0)
ffffffffc02037e2:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02037e4:	bc6fd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc02037e8:	50051563          	bnez	a0,ffffffffc0203cf2 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02037ec:	08098a13          	addi	s4,s3,128
ffffffffc02037f0:	8552                	mv	a0,s4
ffffffffc02037f2:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02037f4:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02037f8:	0000e797          	auipc	a5,0xe
ffffffffc02037fc:	d007ac23          	sw	zero,-744(a5) # ffffffffc0211510 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0203800:	c3cfd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0203804:	4511                	li	a0,4
ffffffffc0203806:	ba4fd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc020380a:	4c051463          	bnez	a0,ffffffffc0203cd2 <default_check+0x6a2>
ffffffffc020380e:	0889b783          	ld	a5,136(s3)
ffffffffc0203812:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203814:	8b85                	andi	a5,a5,1
ffffffffc0203816:	48078e63          	beqz	a5,ffffffffc0203cb2 <default_check+0x682>
ffffffffc020381a:	0909a703          	lw	a4,144(s3)
ffffffffc020381e:	478d                	li	a5,3
ffffffffc0203820:	48f71963          	bne	a4,a5,ffffffffc0203cb2 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203824:	450d                	li	a0,3
ffffffffc0203826:	b84fd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc020382a:	8c2a                	mv	s8,a0
ffffffffc020382c:	46050363          	beqz	a0,ffffffffc0203c92 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0203830:	4505                	li	a0,1
ffffffffc0203832:	b78fd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0203836:	42051e63          	bnez	a0,ffffffffc0203c72 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc020383a:	418a1c63          	bne	s4,s8,ffffffffc0203c52 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020383e:	4585                	li	a1,1
ffffffffc0203840:	854e                	mv	a0,s3
ffffffffc0203842:	bfafd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    free_pages(p1, 3);
ffffffffc0203846:	458d                	li	a1,3
ffffffffc0203848:	8552                	mv	a0,s4
ffffffffc020384a:	bf2fd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
ffffffffc020384e:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0203852:	04098c13          	addi	s8,s3,64
ffffffffc0203856:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203858:	8b85                	andi	a5,a5,1
ffffffffc020385a:	3c078c63          	beqz	a5,ffffffffc0203c32 <default_check+0x602>
ffffffffc020385e:	0109a703          	lw	a4,16(s3)
ffffffffc0203862:	4785                	li	a5,1
ffffffffc0203864:	3cf71763          	bne	a4,a5,ffffffffc0203c32 <default_check+0x602>
ffffffffc0203868:	008a3783          	ld	a5,8(s4)
ffffffffc020386c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020386e:	8b85                	andi	a5,a5,1
ffffffffc0203870:	3a078163          	beqz	a5,ffffffffc0203c12 <default_check+0x5e2>
ffffffffc0203874:	010a2703          	lw	a4,16(s4)
ffffffffc0203878:	478d                	li	a5,3
ffffffffc020387a:	38f71c63          	bne	a4,a5,ffffffffc0203c12 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020387e:	4505                	li	a0,1
ffffffffc0203880:	b2afd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0203884:	36a99763          	bne	s3,a0,ffffffffc0203bf2 <default_check+0x5c2>
    free_page(p0);
ffffffffc0203888:	4585                	li	a1,1
ffffffffc020388a:	bb2fd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020388e:	4509                	li	a0,2
ffffffffc0203890:	b1afd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc0203894:	32aa1f63          	bne	s4,a0,ffffffffc0203bd2 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0203898:	4589                	li	a1,2
ffffffffc020389a:	ba2fd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    free_page(p2);
ffffffffc020389e:	4585                	li	a1,1
ffffffffc02038a0:	8562                	mv	a0,s8
ffffffffc02038a2:	b9afd0ef          	jal	ra,ffffffffc0200c3c <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02038a6:	4515                	li	a0,5
ffffffffc02038a8:	b02fd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc02038ac:	89aa                	mv	s3,a0
ffffffffc02038ae:	48050263          	beqz	a0,ffffffffc0203d32 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02038b2:	4505                	li	a0,1
ffffffffc02038b4:	af6fd0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
ffffffffc02038b8:	2c051d63          	bnez	a0,ffffffffc0203b92 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02038bc:	481c                	lw	a5,16(s0)
ffffffffc02038be:	2a079a63          	bnez	a5,ffffffffc0203b72 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02038c2:	4595                	li	a1,5
ffffffffc02038c4:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02038c6:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02038ca:	01643023          	sd	s6,0(s0)
ffffffffc02038ce:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02038d2:	b6afd0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    return listelm->next;
ffffffffc02038d6:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02038d8:	00878963          	beq	a5,s0,ffffffffc02038ea <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02038dc:	ff87a703          	lw	a4,-8(a5)
ffffffffc02038e0:	679c                	ld	a5,8(a5)
ffffffffc02038e2:	397d                	addiw	s2,s2,-1
ffffffffc02038e4:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02038e6:	fe879be3          	bne	a5,s0,ffffffffc02038dc <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02038ea:	26091463          	bnez	s2,ffffffffc0203b52 <default_check+0x522>
    assert(total == 0);
ffffffffc02038ee:	46049263          	bnez	s1,ffffffffc0203d52 <default_check+0x722>
}
ffffffffc02038f2:	60a6                	ld	ra,72(sp)
ffffffffc02038f4:	6406                	ld	s0,64(sp)
ffffffffc02038f6:	74e2                	ld	s1,56(sp)
ffffffffc02038f8:	7942                	ld	s2,48(sp)
ffffffffc02038fa:	79a2                	ld	s3,40(sp)
ffffffffc02038fc:	7a02                	ld	s4,32(sp)
ffffffffc02038fe:	6ae2                	ld	s5,24(sp)
ffffffffc0203900:	6b42                	ld	s6,16(sp)
ffffffffc0203902:	6ba2                	ld	s7,8(sp)
ffffffffc0203904:	6c02                	ld	s8,0(sp)
ffffffffc0203906:	6161                	addi	sp,sp,80
ffffffffc0203908:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020390a:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020390c:	4481                	li	s1,0
ffffffffc020390e:	4901                	li	s2,0
ffffffffc0203910:	b38d                	j	ffffffffc0203672 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0203912:	00003697          	auipc	a3,0x3
ffffffffc0203916:	b6e68693          	addi	a3,a3,-1170 # ffffffffc0206480 <commands+0x1318>
ffffffffc020391a:	00002617          	auipc	a2,0x2
ffffffffc020391e:	0be60613          	addi	a2,a2,190 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203922:	0f000593          	li	a1,240
ffffffffc0203926:	00003517          	auipc	a0,0x3
ffffffffc020392a:	eaa50513          	addi	a0,a0,-342 # ffffffffc02067d0 <commands+0x1668>
ffffffffc020392e:	89bfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203932:	00003697          	auipc	a3,0x3
ffffffffc0203936:	f1668693          	addi	a3,a3,-234 # ffffffffc0206848 <commands+0x16e0>
ffffffffc020393a:	00002617          	auipc	a2,0x2
ffffffffc020393e:	09e60613          	addi	a2,a2,158 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203942:	0bd00593          	li	a1,189
ffffffffc0203946:	00003517          	auipc	a0,0x3
ffffffffc020394a:	e8a50513          	addi	a0,a0,-374 # ffffffffc02067d0 <commands+0x1668>
ffffffffc020394e:	87bfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203952:	00003697          	auipc	a3,0x3
ffffffffc0203956:	f1e68693          	addi	a3,a3,-226 # ffffffffc0206870 <commands+0x1708>
ffffffffc020395a:	00002617          	auipc	a2,0x2
ffffffffc020395e:	07e60613          	addi	a2,a2,126 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203962:	0be00593          	li	a1,190
ffffffffc0203966:	00003517          	auipc	a0,0x3
ffffffffc020396a:	e6a50513          	addi	a0,a0,-406 # ffffffffc02067d0 <commands+0x1668>
ffffffffc020396e:	85bfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203972:	00003697          	auipc	a3,0x3
ffffffffc0203976:	f3e68693          	addi	a3,a3,-194 # ffffffffc02068b0 <commands+0x1748>
ffffffffc020397a:	00002617          	auipc	a2,0x2
ffffffffc020397e:	05e60613          	addi	a2,a2,94 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203982:	0c000593          	li	a1,192
ffffffffc0203986:	00003517          	auipc	a0,0x3
ffffffffc020398a:	e4a50513          	addi	a0,a0,-438 # ffffffffc02067d0 <commands+0x1668>
ffffffffc020398e:	83bfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0203992:	00003697          	auipc	a3,0x3
ffffffffc0203996:	fa668693          	addi	a3,a3,-90 # ffffffffc0206938 <commands+0x17d0>
ffffffffc020399a:	00002617          	auipc	a2,0x2
ffffffffc020399e:	03e60613          	addi	a2,a2,62 # ffffffffc02059d8 <commands+0x870>
ffffffffc02039a2:	0d900593          	li	a1,217
ffffffffc02039a6:	00003517          	auipc	a0,0x3
ffffffffc02039aa:	e2a50513          	addi	a0,a0,-470 # ffffffffc02067d0 <commands+0x1668>
ffffffffc02039ae:	81bfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02039b2:	00003697          	auipc	a3,0x3
ffffffffc02039b6:	e3668693          	addi	a3,a3,-458 # ffffffffc02067e8 <commands+0x1680>
ffffffffc02039ba:	00002617          	auipc	a2,0x2
ffffffffc02039be:	01e60613          	addi	a2,a2,30 # ffffffffc02059d8 <commands+0x870>
ffffffffc02039c2:	0d200593          	li	a1,210
ffffffffc02039c6:	00003517          	auipc	a0,0x3
ffffffffc02039ca:	e0a50513          	addi	a0,a0,-502 # ffffffffc02067d0 <commands+0x1668>
ffffffffc02039ce:	ffafc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 3);
ffffffffc02039d2:	00003697          	auipc	a3,0x3
ffffffffc02039d6:	f5668693          	addi	a3,a3,-170 # ffffffffc0206928 <commands+0x17c0>
ffffffffc02039da:	00002617          	auipc	a2,0x2
ffffffffc02039de:	ffe60613          	addi	a2,a2,-2 # ffffffffc02059d8 <commands+0x870>
ffffffffc02039e2:	0d000593          	li	a1,208
ffffffffc02039e6:	00003517          	auipc	a0,0x3
ffffffffc02039ea:	dea50513          	addi	a0,a0,-534 # ffffffffc02067d0 <commands+0x1668>
ffffffffc02039ee:	fdafc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02039f2:	00003697          	auipc	a3,0x3
ffffffffc02039f6:	f1e68693          	addi	a3,a3,-226 # ffffffffc0206910 <commands+0x17a8>
ffffffffc02039fa:	00002617          	auipc	a2,0x2
ffffffffc02039fe:	fde60613          	addi	a2,a2,-34 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203a02:	0cb00593          	li	a1,203
ffffffffc0203a06:	00003517          	auipc	a0,0x3
ffffffffc0203a0a:	dca50513          	addi	a0,a0,-566 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203a0e:	fbafc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203a12:	00003697          	auipc	a3,0x3
ffffffffc0203a16:	ede68693          	addi	a3,a3,-290 # ffffffffc02068f0 <commands+0x1788>
ffffffffc0203a1a:	00002617          	auipc	a2,0x2
ffffffffc0203a1e:	fbe60613          	addi	a2,a2,-66 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203a22:	0c200593          	li	a1,194
ffffffffc0203a26:	00003517          	auipc	a0,0x3
ffffffffc0203a2a:	daa50513          	addi	a0,a0,-598 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203a2e:	f9afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 != NULL);
ffffffffc0203a32:	00003697          	auipc	a3,0x3
ffffffffc0203a36:	f3e68693          	addi	a3,a3,-194 # ffffffffc0206970 <commands+0x1808>
ffffffffc0203a3a:	00002617          	auipc	a2,0x2
ffffffffc0203a3e:	f9e60613          	addi	a2,a2,-98 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203a42:	0f800593          	li	a1,248
ffffffffc0203a46:	00003517          	auipc	a0,0x3
ffffffffc0203a4a:	d8a50513          	addi	a0,a0,-630 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203a4e:	f7afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 0);
ffffffffc0203a52:	00003697          	auipc	a3,0x3
ffffffffc0203a56:	bce68693          	addi	a3,a3,-1074 # ffffffffc0206620 <commands+0x14b8>
ffffffffc0203a5a:	00002617          	auipc	a2,0x2
ffffffffc0203a5e:	f7e60613          	addi	a2,a2,-130 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203a62:	0df00593          	li	a1,223
ffffffffc0203a66:	00003517          	auipc	a0,0x3
ffffffffc0203a6a:	d6a50513          	addi	a0,a0,-662 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203a6e:	f5afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203a72:	00003697          	auipc	a3,0x3
ffffffffc0203a76:	e9e68693          	addi	a3,a3,-354 # ffffffffc0206910 <commands+0x17a8>
ffffffffc0203a7a:	00002617          	auipc	a2,0x2
ffffffffc0203a7e:	f5e60613          	addi	a2,a2,-162 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203a82:	0dd00593          	li	a1,221
ffffffffc0203a86:	00003517          	auipc	a0,0x3
ffffffffc0203a8a:	d4a50513          	addi	a0,a0,-694 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203a8e:	f3afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0203a92:	00003697          	auipc	a3,0x3
ffffffffc0203a96:	ebe68693          	addi	a3,a3,-322 # ffffffffc0206950 <commands+0x17e8>
ffffffffc0203a9a:	00002617          	auipc	a2,0x2
ffffffffc0203a9e:	f3e60613          	addi	a2,a2,-194 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203aa2:	0dc00593          	li	a1,220
ffffffffc0203aa6:	00003517          	auipc	a0,0x3
ffffffffc0203aaa:	d2a50513          	addi	a0,a0,-726 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203aae:	f1afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203ab2:	00003697          	auipc	a3,0x3
ffffffffc0203ab6:	d3668693          	addi	a3,a3,-714 # ffffffffc02067e8 <commands+0x1680>
ffffffffc0203aba:	00002617          	auipc	a2,0x2
ffffffffc0203abe:	f1e60613          	addi	a2,a2,-226 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203ac2:	0b900593          	li	a1,185
ffffffffc0203ac6:	00003517          	auipc	a0,0x3
ffffffffc0203aca:	d0a50513          	addi	a0,a0,-758 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203ace:	efafc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203ad2:	00003697          	auipc	a3,0x3
ffffffffc0203ad6:	e3e68693          	addi	a3,a3,-450 # ffffffffc0206910 <commands+0x17a8>
ffffffffc0203ada:	00002617          	auipc	a2,0x2
ffffffffc0203ade:	efe60613          	addi	a2,a2,-258 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203ae2:	0d600593          	li	a1,214
ffffffffc0203ae6:	00003517          	auipc	a0,0x3
ffffffffc0203aea:	cea50513          	addi	a0,a0,-790 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203aee:	edafc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203af2:	00003697          	auipc	a3,0x3
ffffffffc0203af6:	d3668693          	addi	a3,a3,-714 # ffffffffc0206828 <commands+0x16c0>
ffffffffc0203afa:	00002617          	auipc	a2,0x2
ffffffffc0203afe:	ede60613          	addi	a2,a2,-290 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203b02:	0d400593          	li	a1,212
ffffffffc0203b06:	00003517          	auipc	a0,0x3
ffffffffc0203b0a:	cca50513          	addi	a0,a0,-822 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203b0e:	ebafc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203b12:	00003697          	auipc	a3,0x3
ffffffffc0203b16:	cf668693          	addi	a3,a3,-778 # ffffffffc0206808 <commands+0x16a0>
ffffffffc0203b1a:	00002617          	auipc	a2,0x2
ffffffffc0203b1e:	ebe60613          	addi	a2,a2,-322 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203b22:	0d300593          	li	a1,211
ffffffffc0203b26:	00003517          	auipc	a0,0x3
ffffffffc0203b2a:	caa50513          	addi	a0,a0,-854 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203b2e:	e9afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203b32:	00003697          	auipc	a3,0x3
ffffffffc0203b36:	cf668693          	addi	a3,a3,-778 # ffffffffc0206828 <commands+0x16c0>
ffffffffc0203b3a:	00002617          	auipc	a2,0x2
ffffffffc0203b3e:	e9e60613          	addi	a2,a2,-354 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203b42:	0bb00593          	li	a1,187
ffffffffc0203b46:	00003517          	auipc	a0,0x3
ffffffffc0203b4a:	c8a50513          	addi	a0,a0,-886 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203b4e:	e7afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(count == 0);
ffffffffc0203b52:	00003697          	auipc	a3,0x3
ffffffffc0203b56:	f6e68693          	addi	a3,a3,-146 # ffffffffc0206ac0 <commands+0x1958>
ffffffffc0203b5a:	00002617          	auipc	a2,0x2
ffffffffc0203b5e:	e7e60613          	addi	a2,a2,-386 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203b62:	12500593          	li	a1,293
ffffffffc0203b66:	00003517          	auipc	a0,0x3
ffffffffc0203b6a:	c6a50513          	addi	a0,a0,-918 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203b6e:	e5afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 0);
ffffffffc0203b72:	00003697          	auipc	a3,0x3
ffffffffc0203b76:	aae68693          	addi	a3,a3,-1362 # ffffffffc0206620 <commands+0x14b8>
ffffffffc0203b7a:	00002617          	auipc	a2,0x2
ffffffffc0203b7e:	e5e60613          	addi	a2,a2,-418 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203b82:	11a00593          	li	a1,282
ffffffffc0203b86:	00003517          	auipc	a0,0x3
ffffffffc0203b8a:	c4a50513          	addi	a0,a0,-950 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203b8e:	e3afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203b92:	00003697          	auipc	a3,0x3
ffffffffc0203b96:	d7e68693          	addi	a3,a3,-642 # ffffffffc0206910 <commands+0x17a8>
ffffffffc0203b9a:	00002617          	auipc	a2,0x2
ffffffffc0203b9e:	e3e60613          	addi	a2,a2,-450 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203ba2:	11800593          	li	a1,280
ffffffffc0203ba6:	00003517          	auipc	a0,0x3
ffffffffc0203baa:	c2a50513          	addi	a0,a0,-982 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203bae:	e1afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203bb2:	00003697          	auipc	a3,0x3
ffffffffc0203bb6:	d1e68693          	addi	a3,a3,-738 # ffffffffc02068d0 <commands+0x1768>
ffffffffc0203bba:	00002617          	auipc	a2,0x2
ffffffffc0203bbe:	e1e60613          	addi	a2,a2,-482 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203bc2:	0c100593          	li	a1,193
ffffffffc0203bc6:	00003517          	auipc	a0,0x3
ffffffffc0203bca:	c0a50513          	addi	a0,a0,-1014 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203bce:	dfafc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203bd2:	00003697          	auipc	a3,0x3
ffffffffc0203bd6:	eae68693          	addi	a3,a3,-338 # ffffffffc0206a80 <commands+0x1918>
ffffffffc0203bda:	00002617          	auipc	a2,0x2
ffffffffc0203bde:	dfe60613          	addi	a2,a2,-514 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203be2:	11200593          	li	a1,274
ffffffffc0203be6:	00003517          	auipc	a0,0x3
ffffffffc0203bea:	bea50513          	addi	a0,a0,-1046 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203bee:	ddafc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203bf2:	00003697          	auipc	a3,0x3
ffffffffc0203bf6:	e6e68693          	addi	a3,a3,-402 # ffffffffc0206a60 <commands+0x18f8>
ffffffffc0203bfa:	00002617          	auipc	a2,0x2
ffffffffc0203bfe:	dde60613          	addi	a2,a2,-546 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203c02:	11000593          	li	a1,272
ffffffffc0203c06:	00003517          	auipc	a0,0x3
ffffffffc0203c0a:	bca50513          	addi	a0,a0,-1078 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203c0e:	dbafc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203c12:	00003697          	auipc	a3,0x3
ffffffffc0203c16:	e2668693          	addi	a3,a3,-474 # ffffffffc0206a38 <commands+0x18d0>
ffffffffc0203c1a:	00002617          	auipc	a2,0x2
ffffffffc0203c1e:	dbe60613          	addi	a2,a2,-578 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203c22:	10e00593          	li	a1,270
ffffffffc0203c26:	00003517          	auipc	a0,0x3
ffffffffc0203c2a:	baa50513          	addi	a0,a0,-1110 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203c2e:	d9afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203c32:	00003697          	auipc	a3,0x3
ffffffffc0203c36:	dde68693          	addi	a3,a3,-546 # ffffffffc0206a10 <commands+0x18a8>
ffffffffc0203c3a:	00002617          	auipc	a2,0x2
ffffffffc0203c3e:	d9e60613          	addi	a2,a2,-610 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203c42:	10d00593          	li	a1,269
ffffffffc0203c46:	00003517          	auipc	a0,0x3
ffffffffc0203c4a:	b8a50513          	addi	a0,a0,-1142 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203c4e:	d7afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0203c52:	00003697          	auipc	a3,0x3
ffffffffc0203c56:	dae68693          	addi	a3,a3,-594 # ffffffffc0206a00 <commands+0x1898>
ffffffffc0203c5a:	00002617          	auipc	a2,0x2
ffffffffc0203c5e:	d7e60613          	addi	a2,a2,-642 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203c62:	10800593          	li	a1,264
ffffffffc0203c66:	00003517          	auipc	a0,0x3
ffffffffc0203c6a:	b6a50513          	addi	a0,a0,-1174 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203c6e:	d5afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203c72:	00003697          	auipc	a3,0x3
ffffffffc0203c76:	c9e68693          	addi	a3,a3,-866 # ffffffffc0206910 <commands+0x17a8>
ffffffffc0203c7a:	00002617          	auipc	a2,0x2
ffffffffc0203c7e:	d5e60613          	addi	a2,a2,-674 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203c82:	10700593          	li	a1,263
ffffffffc0203c86:	00003517          	auipc	a0,0x3
ffffffffc0203c8a:	b4a50513          	addi	a0,a0,-1206 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203c8e:	d3afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203c92:	00003697          	auipc	a3,0x3
ffffffffc0203c96:	d4e68693          	addi	a3,a3,-690 # ffffffffc02069e0 <commands+0x1878>
ffffffffc0203c9a:	00002617          	auipc	a2,0x2
ffffffffc0203c9e:	d3e60613          	addi	a2,a2,-706 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203ca2:	10600593          	li	a1,262
ffffffffc0203ca6:	00003517          	auipc	a0,0x3
ffffffffc0203caa:	b2a50513          	addi	a0,a0,-1238 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203cae:	d1afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203cb2:	00003697          	auipc	a3,0x3
ffffffffc0203cb6:	cfe68693          	addi	a3,a3,-770 # ffffffffc02069b0 <commands+0x1848>
ffffffffc0203cba:	00002617          	auipc	a2,0x2
ffffffffc0203cbe:	d1e60613          	addi	a2,a2,-738 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203cc2:	10500593          	li	a1,261
ffffffffc0203cc6:	00003517          	auipc	a0,0x3
ffffffffc0203cca:	b0a50513          	addi	a0,a0,-1270 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203cce:	cfafc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0203cd2:	00003697          	auipc	a3,0x3
ffffffffc0203cd6:	cc668693          	addi	a3,a3,-826 # ffffffffc0206998 <commands+0x1830>
ffffffffc0203cda:	00002617          	auipc	a2,0x2
ffffffffc0203cde:	cfe60613          	addi	a2,a2,-770 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203ce2:	10400593          	li	a1,260
ffffffffc0203ce6:	00003517          	auipc	a0,0x3
ffffffffc0203cea:	aea50513          	addi	a0,a0,-1302 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203cee:	cdafc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203cf2:	00003697          	auipc	a3,0x3
ffffffffc0203cf6:	c1e68693          	addi	a3,a3,-994 # ffffffffc0206910 <commands+0x17a8>
ffffffffc0203cfa:	00002617          	auipc	a2,0x2
ffffffffc0203cfe:	cde60613          	addi	a2,a2,-802 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203d02:	0fe00593          	li	a1,254
ffffffffc0203d06:	00003517          	auipc	a0,0x3
ffffffffc0203d0a:	aca50513          	addi	a0,a0,-1334 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203d0e:	cbafc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(!PageProperty(p0));
ffffffffc0203d12:	00003697          	auipc	a3,0x3
ffffffffc0203d16:	c6e68693          	addi	a3,a3,-914 # ffffffffc0206980 <commands+0x1818>
ffffffffc0203d1a:	00002617          	auipc	a2,0x2
ffffffffc0203d1e:	cbe60613          	addi	a2,a2,-834 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203d22:	0f900593          	li	a1,249
ffffffffc0203d26:	00003517          	auipc	a0,0x3
ffffffffc0203d2a:	aaa50513          	addi	a0,a0,-1366 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203d2e:	c9afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203d32:	00003697          	auipc	a3,0x3
ffffffffc0203d36:	d6e68693          	addi	a3,a3,-658 # ffffffffc0206aa0 <commands+0x1938>
ffffffffc0203d3a:	00002617          	auipc	a2,0x2
ffffffffc0203d3e:	c9e60613          	addi	a2,a2,-866 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203d42:	11700593          	li	a1,279
ffffffffc0203d46:	00003517          	auipc	a0,0x3
ffffffffc0203d4a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203d4e:	c7afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(total == 0);
ffffffffc0203d52:	00003697          	auipc	a3,0x3
ffffffffc0203d56:	d7e68693          	addi	a3,a3,-642 # ffffffffc0206ad0 <commands+0x1968>
ffffffffc0203d5a:	00002617          	auipc	a2,0x2
ffffffffc0203d5e:	c7e60613          	addi	a2,a2,-898 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203d62:	12600593          	li	a1,294
ffffffffc0203d66:	00003517          	auipc	a0,0x3
ffffffffc0203d6a:	a6a50513          	addi	a0,a0,-1430 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203d6e:	c5afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(total == nr_free_pages());
ffffffffc0203d72:	00002697          	auipc	a3,0x2
ffffffffc0203d76:	71e68693          	addi	a3,a3,1822 # ffffffffc0206490 <commands+0x1328>
ffffffffc0203d7a:	00002617          	auipc	a2,0x2
ffffffffc0203d7e:	c5e60613          	addi	a2,a2,-930 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203d82:	0f300593          	li	a1,243
ffffffffc0203d86:	00003517          	auipc	a0,0x3
ffffffffc0203d8a:	a4a50513          	addi	a0,a0,-1462 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203d8e:	c3afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203d92:	00003697          	auipc	a3,0x3
ffffffffc0203d96:	a7668693          	addi	a3,a3,-1418 # ffffffffc0206808 <commands+0x16a0>
ffffffffc0203d9a:	00002617          	auipc	a2,0x2
ffffffffc0203d9e:	c3e60613          	addi	a2,a2,-962 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203da2:	0ba00593          	li	a1,186
ffffffffc0203da6:	00003517          	auipc	a0,0x3
ffffffffc0203daa:	a2a50513          	addi	a0,a0,-1494 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203dae:	c1afc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203db2 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0203db2:	1141                	addi	sp,sp,-16
ffffffffc0203db4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203db6:	14058463          	beqz	a1,ffffffffc0203efe <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0203dba:	00659693          	slli	a3,a1,0x6
ffffffffc0203dbe:	96aa                	add	a3,a3,a0
ffffffffc0203dc0:	87aa                	mv	a5,a0
ffffffffc0203dc2:	02d50263          	beq	a0,a3,ffffffffc0203de6 <default_free_pages+0x34>
ffffffffc0203dc6:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203dc8:	8b05                	andi	a4,a4,1
ffffffffc0203dca:	10071a63          	bnez	a4,ffffffffc0203ede <default_free_pages+0x12c>
ffffffffc0203dce:	6798                	ld	a4,8(a5)
ffffffffc0203dd0:	8b09                	andi	a4,a4,2
ffffffffc0203dd2:	10071663          	bnez	a4,ffffffffc0203ede <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0203dd6:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0203dda:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203dde:	04078793          	addi	a5,a5,64
ffffffffc0203de2:	fed792e3          	bne	a5,a3,ffffffffc0203dc6 <default_free_pages+0x14>
    base->property = n;
ffffffffc0203de6:	2581                	sext.w	a1,a1
ffffffffc0203de8:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0203dea:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203dee:	4789                	li	a5,2
ffffffffc0203df0:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203df4:	0000d697          	auipc	a3,0xd
ffffffffc0203df8:	70c68693          	addi	a3,a3,1804 # ffffffffc0211500 <free_area>
ffffffffc0203dfc:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203dfe:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0203e00:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0203e04:	9db9                	addw	a1,a1,a4
ffffffffc0203e06:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0203e08:	0ad78463          	beq	a5,a3,ffffffffc0203eb0 <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc0203e0c:	fe878713          	addi	a4,a5,-24
ffffffffc0203e10:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203e14:	4581                	li	a1,0
            if (base < page) {
ffffffffc0203e16:	00e56a63          	bltu	a0,a4,ffffffffc0203e2a <default_free_pages+0x78>
    return listelm->next;
ffffffffc0203e1a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203e1c:	04d70c63          	beq	a4,a3,ffffffffc0203e74 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc0203e20:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203e22:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203e26:	fee57ae3          	bgeu	a0,a4,ffffffffc0203e1a <default_free_pages+0x68>
ffffffffc0203e2a:	c199                	beqz	a1,ffffffffc0203e30 <default_free_pages+0x7e>
ffffffffc0203e2c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203e30:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203e32:	e390                	sd	a2,0(a5)
ffffffffc0203e34:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203e36:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203e38:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0203e3a:	00d70d63          	beq	a4,a3,ffffffffc0203e54 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0203e3e:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0203e42:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0203e46:	02059813          	slli	a6,a1,0x20
ffffffffc0203e4a:	01a85793          	srli	a5,a6,0x1a
ffffffffc0203e4e:	97b2                	add	a5,a5,a2
ffffffffc0203e50:	02f50c63          	beq	a0,a5,ffffffffc0203e88 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0203e54:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0203e56:	00d78c63          	beq	a5,a3,ffffffffc0203e6e <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0203e5a:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0203e5c:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0203e60:	02061593          	slli	a1,a2,0x20
ffffffffc0203e64:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0203e68:	972a                	add	a4,a4,a0
ffffffffc0203e6a:	04e68a63          	beq	a3,a4,ffffffffc0203ebe <default_free_pages+0x10c>
}
ffffffffc0203e6e:	60a2                	ld	ra,8(sp)
ffffffffc0203e70:	0141                	addi	sp,sp,16
ffffffffc0203e72:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203e74:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203e76:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0203e78:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203e7a:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203e7c:	02d70763          	beq	a4,a3,ffffffffc0203eaa <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0203e80:	8832                	mv	a6,a2
ffffffffc0203e82:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0203e84:	87ba                	mv	a5,a4
ffffffffc0203e86:	bf71                	j	ffffffffc0203e22 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0203e88:	491c                	lw	a5,16(a0)
ffffffffc0203e8a:	9dbd                	addw	a1,a1,a5
ffffffffc0203e8c:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203e90:	57f5                	li	a5,-3
ffffffffc0203e92:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203e96:	01853803          	ld	a6,24(a0)
ffffffffc0203e9a:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0203e9c:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0203e9e:	00b83423          	sd	a1,8(a6) # fffffffffff80008 <end+0x3fd6aa3c>
    return listelm->next;
ffffffffc0203ea2:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0203ea4:	0105b023          	sd	a6,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203ea8:	b77d                	j	ffffffffc0203e56 <default_free_pages+0xa4>
ffffffffc0203eaa:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203eac:	873e                	mv	a4,a5
ffffffffc0203eae:	bf41                	j	ffffffffc0203e3e <default_free_pages+0x8c>
}
ffffffffc0203eb0:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203eb2:	e390                	sd	a2,0(a5)
ffffffffc0203eb4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203eb6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203eb8:	ed1c                	sd	a5,24(a0)
ffffffffc0203eba:	0141                	addi	sp,sp,16
ffffffffc0203ebc:	8082                	ret
            base->property += p->property;
ffffffffc0203ebe:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203ec2:	ff078693          	addi	a3,a5,-16
ffffffffc0203ec6:	9e39                	addw	a2,a2,a4
ffffffffc0203ec8:	c910                	sw	a2,16(a0)
ffffffffc0203eca:	5775                	li	a4,-3
ffffffffc0203ecc:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203ed0:	6398                	ld	a4,0(a5)
ffffffffc0203ed2:	679c                	ld	a5,8(a5)
}
ffffffffc0203ed4:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203ed6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203ed8:	e398                	sd	a4,0(a5)
ffffffffc0203eda:	0141                	addi	sp,sp,16
ffffffffc0203edc:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203ede:	00003697          	auipc	a3,0x3
ffffffffc0203ee2:	c0a68693          	addi	a3,a3,-1014 # ffffffffc0206ae8 <commands+0x1980>
ffffffffc0203ee6:	00002617          	auipc	a2,0x2
ffffffffc0203eea:	af260613          	addi	a2,a2,-1294 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203eee:	08300593          	li	a1,131
ffffffffc0203ef2:	00003517          	auipc	a0,0x3
ffffffffc0203ef6:	8de50513          	addi	a0,a0,-1826 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203efa:	acefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc0203efe:	00003697          	auipc	a3,0x3
ffffffffc0203f02:	be268693          	addi	a3,a3,-1054 # ffffffffc0206ae0 <commands+0x1978>
ffffffffc0203f06:	00002617          	auipc	a2,0x2
ffffffffc0203f0a:	ad260613          	addi	a2,a2,-1326 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203f0e:	08000593          	li	a1,128
ffffffffc0203f12:	00003517          	auipc	a0,0x3
ffffffffc0203f16:	8be50513          	addi	a0,a0,-1858 # ffffffffc02067d0 <commands+0x1668>
ffffffffc0203f1a:	aaefc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203f1e <default_alloc_pages>:
    assert(n > 0);
ffffffffc0203f1e:	c941                	beqz	a0,ffffffffc0203fae <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc0203f20:	0000d597          	auipc	a1,0xd
ffffffffc0203f24:	5e058593          	addi	a1,a1,1504 # ffffffffc0211500 <free_area>
ffffffffc0203f28:	0105a803          	lw	a6,16(a1)
ffffffffc0203f2c:	872a                	mv	a4,a0
ffffffffc0203f2e:	02081793          	slli	a5,a6,0x20
ffffffffc0203f32:	9381                	srli	a5,a5,0x20
ffffffffc0203f34:	00a7ee63          	bltu	a5,a0,ffffffffc0203f50 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203f38:	87ae                	mv	a5,a1
ffffffffc0203f3a:	a801                	j	ffffffffc0203f4a <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0203f3c:	ff87a683          	lw	a3,-8(a5)
ffffffffc0203f40:	02069613          	slli	a2,a3,0x20
ffffffffc0203f44:	9201                	srli	a2,a2,0x20
ffffffffc0203f46:	00e67763          	bgeu	a2,a4,ffffffffc0203f54 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203f4a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203f4c:	feb798e3          	bne	a5,a1,ffffffffc0203f3c <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0203f50:	4501                	li	a0,0
}
ffffffffc0203f52:	8082                	ret
    return listelm->prev;
ffffffffc0203f54:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203f58:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0203f5c:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0203f60:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0203f64:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0203f68:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0203f6c:	02c77863          	bgeu	a4,a2,ffffffffc0203f9c <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0203f70:	071a                	slli	a4,a4,0x6
ffffffffc0203f72:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0203f74:	41c686bb          	subw	a3,a3,t3
ffffffffc0203f78:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203f7a:	00870613          	addi	a2,a4,8
ffffffffc0203f7e:	4689                	li	a3,2
ffffffffc0203f80:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203f84:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203f88:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0203f8c:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0203f90:	e290                	sd	a2,0(a3)
ffffffffc0203f92:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0203f96:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0203f98:	01173c23          	sd	a7,24(a4)
ffffffffc0203f9c:	41c8083b          	subw	a6,a6,t3
ffffffffc0203fa0:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203fa4:	5775                	li	a4,-3
ffffffffc0203fa6:	17c1                	addi	a5,a5,-16
ffffffffc0203fa8:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0203fac:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0203fae:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0203fb0:	00003697          	auipc	a3,0x3
ffffffffc0203fb4:	b3068693          	addi	a3,a3,-1232 # ffffffffc0206ae0 <commands+0x1978>
ffffffffc0203fb8:	00002617          	auipc	a2,0x2
ffffffffc0203fbc:	a2060613          	addi	a2,a2,-1504 # ffffffffc02059d8 <commands+0x870>
ffffffffc0203fc0:	06200593          	li	a1,98
ffffffffc0203fc4:	00003517          	auipc	a0,0x3
ffffffffc0203fc8:	80c50513          	addi	a0,a0,-2036 # ffffffffc02067d0 <commands+0x1668>
default_alloc_pages(size_t n) {
ffffffffc0203fcc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203fce:	9fafc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203fd2 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0203fd2:	1141                	addi	sp,sp,-16
ffffffffc0203fd4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203fd6:	c5f1                	beqz	a1,ffffffffc02040a2 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0203fd8:	00659693          	slli	a3,a1,0x6
ffffffffc0203fdc:	96aa                	add	a3,a3,a0
ffffffffc0203fde:	87aa                	mv	a5,a0
ffffffffc0203fe0:	00d50f63          	beq	a0,a3,ffffffffc0203ffe <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203fe4:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0203fe6:	8b05                	andi	a4,a4,1
ffffffffc0203fe8:	cf49                	beqz	a4,ffffffffc0204082 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0203fea:	0007a823          	sw	zero,16(a5)
ffffffffc0203fee:	0007b423          	sd	zero,8(a5)
ffffffffc0203ff2:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203ff6:	04078793          	addi	a5,a5,64
ffffffffc0203ffa:	fed795e3          	bne	a5,a3,ffffffffc0203fe4 <default_init_memmap+0x12>
    base->property = n;
ffffffffc0203ffe:	2581                	sext.w	a1,a1
ffffffffc0204000:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204002:	4789                	li	a5,2
ffffffffc0204004:	00850713          	addi	a4,a0,8
ffffffffc0204008:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020400c:	0000d697          	auipc	a3,0xd
ffffffffc0204010:	4f468693          	addi	a3,a3,1268 # ffffffffc0211500 <free_area>
ffffffffc0204014:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204016:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0204018:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020401c:	9db9                	addw	a1,a1,a4
ffffffffc020401e:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0204020:	04d78a63          	beq	a5,a3,ffffffffc0204074 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0204024:	fe878713          	addi	a4,a5,-24
ffffffffc0204028:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020402c:	4581                	li	a1,0
            if (base < page) {
ffffffffc020402e:	00e56a63          	bltu	a0,a4,ffffffffc0204042 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0204032:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204034:	02d70263          	beq	a4,a3,ffffffffc0204058 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0204038:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020403a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020403e:	fee57ae3          	bgeu	a0,a4,ffffffffc0204032 <default_init_memmap+0x60>
ffffffffc0204042:	c199                	beqz	a1,ffffffffc0204048 <default_init_memmap+0x76>
ffffffffc0204044:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204048:	6398                	ld	a4,0(a5)
}
ffffffffc020404a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020404c:	e390                	sd	a2,0(a5)
ffffffffc020404e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0204050:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204052:	ed18                	sd	a4,24(a0)
ffffffffc0204054:	0141                	addi	sp,sp,16
ffffffffc0204056:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204058:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020405a:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020405c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020405e:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204060:	00d70663          	beq	a4,a3,ffffffffc020406c <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0204064:	8832                	mv	a6,a2
ffffffffc0204066:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0204068:	87ba                	mv	a5,a4
ffffffffc020406a:	bfc1                	j	ffffffffc020403a <default_init_memmap+0x68>
}
ffffffffc020406c:	60a2                	ld	ra,8(sp)
ffffffffc020406e:	e290                	sd	a2,0(a3)
ffffffffc0204070:	0141                	addi	sp,sp,16
ffffffffc0204072:	8082                	ret
ffffffffc0204074:	60a2                	ld	ra,8(sp)
ffffffffc0204076:	e390                	sd	a2,0(a5)
ffffffffc0204078:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020407a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020407c:	ed1c                	sd	a5,24(a0)
ffffffffc020407e:	0141                	addi	sp,sp,16
ffffffffc0204080:	8082                	ret
        assert(PageReserved(p));
ffffffffc0204082:	00003697          	auipc	a3,0x3
ffffffffc0204086:	a8e68693          	addi	a3,a3,-1394 # ffffffffc0206b10 <commands+0x19a8>
ffffffffc020408a:	00002617          	auipc	a2,0x2
ffffffffc020408e:	94e60613          	addi	a2,a2,-1714 # ffffffffc02059d8 <commands+0x870>
ffffffffc0204092:	04900593          	li	a1,73
ffffffffc0204096:	00002517          	auipc	a0,0x2
ffffffffc020409a:	73a50513          	addi	a0,a0,1850 # ffffffffc02067d0 <commands+0x1668>
ffffffffc020409e:	92afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc02040a2:	00003697          	auipc	a3,0x3
ffffffffc02040a6:	a3e68693          	addi	a3,a3,-1474 # ffffffffc0206ae0 <commands+0x1978>
ffffffffc02040aa:	00002617          	auipc	a2,0x2
ffffffffc02040ae:	92e60613          	addi	a2,a2,-1746 # ffffffffc02059d8 <commands+0x870>
ffffffffc02040b2:	04600593          	li	a1,70
ffffffffc02040b6:	00002517          	auipc	a0,0x2
ffffffffc02040ba:	71a50513          	addi	a0,a0,1818 # ffffffffc02067d0 <commands+0x1668>
ffffffffc02040be:	90afc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02040c2 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc02040c2:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02040c4:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc02040c6:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02040c8:	bdcfc0ef          	jal	ra,ffffffffc02004a4 <ide_device_valid>
ffffffffc02040cc:	cd01                	beqz	a0,ffffffffc02040e4 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02040ce:	4505                	li	a0,1
ffffffffc02040d0:	bdafc0ef          	jal	ra,ffffffffc02004aa <ide_device_size>
}
ffffffffc02040d4:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02040d6:	810d                	srli	a0,a0,0x3
ffffffffc02040d8:	00011797          	auipc	a5,0x11
ffffffffc02040dc:	4ca7b023          	sd	a0,1216(a5) # ffffffffc0215598 <max_swap_offset>
}
ffffffffc02040e0:	0141                	addi	sp,sp,16
ffffffffc02040e2:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc02040e4:	00003617          	auipc	a2,0x3
ffffffffc02040e8:	a8c60613          	addi	a2,a2,-1396 # ffffffffc0206b70 <default_pmm_manager+0x38>
ffffffffc02040ec:	45b5                	li	a1,13
ffffffffc02040ee:	00003517          	auipc	a0,0x3
ffffffffc02040f2:	aa250513          	addi	a0,a0,-1374 # ffffffffc0206b90 <default_pmm_manager+0x58>
ffffffffc02040f6:	8d2fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02040fa <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc02040fa:	1141                	addi	sp,sp,-16
ffffffffc02040fc:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040fe:	00855793          	srli	a5,a0,0x8
ffffffffc0204102:	cbb1                	beqz	a5,ffffffffc0204156 <swapfs_read+0x5c>
ffffffffc0204104:	00011717          	auipc	a4,0x11
ffffffffc0204108:	49473703          	ld	a4,1172(a4) # ffffffffc0215598 <max_swap_offset>
ffffffffc020410c:	04e7f563          	bgeu	a5,a4,ffffffffc0204156 <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204110:	00011617          	auipc	a2,0x11
ffffffffc0204114:	45863603          	ld	a2,1112(a2) # ffffffffc0215568 <pages>
ffffffffc0204118:	8d91                	sub	a1,a1,a2
ffffffffc020411a:	4065d613          	srai	a2,a1,0x6
ffffffffc020411e:	00003717          	auipc	a4,0x3
ffffffffc0204122:	ea273703          	ld	a4,-350(a4) # ffffffffc0206fc0 <nbase>
ffffffffc0204126:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204128:	00c61713          	slli	a4,a2,0xc
ffffffffc020412c:	8331                	srli	a4,a4,0xc
ffffffffc020412e:	00011697          	auipc	a3,0x11
ffffffffc0204132:	4326b683          	ld	a3,1074(a3) # ffffffffc0215560 <npage>
ffffffffc0204136:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc020413a:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc020413c:	02d77963          	bgeu	a4,a3,ffffffffc020416e <swapfs_read+0x74>
}
ffffffffc0204140:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204142:	00011797          	auipc	a5,0x11
ffffffffc0204146:	4367b783          	ld	a5,1078(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc020414a:	46a1                	li	a3,8
ffffffffc020414c:	963e                	add	a2,a2,a5
ffffffffc020414e:	4505                	li	a0,1
}
ffffffffc0204150:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204152:	b5efc06f          	j	ffffffffc02004b0 <ide_read_secs>
ffffffffc0204156:	86aa                	mv	a3,a0
ffffffffc0204158:	00003617          	auipc	a2,0x3
ffffffffc020415c:	a5060613          	addi	a2,a2,-1456 # ffffffffc0206ba8 <default_pmm_manager+0x70>
ffffffffc0204160:	45d1                	li	a1,20
ffffffffc0204162:	00003517          	auipc	a0,0x3
ffffffffc0204166:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0206b90 <default_pmm_manager+0x58>
ffffffffc020416a:	85efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc020416e:	86b2                	mv	a3,a2
ffffffffc0204170:	06900593          	li	a1,105
ffffffffc0204174:	00001617          	auipc	a2,0x1
ffffffffc0204178:	75460613          	addi	a2,a2,1876 # ffffffffc02058c8 <commands+0x760>
ffffffffc020417c:	00001517          	auipc	a0,0x1
ffffffffc0204180:	71450513          	addi	a0,a0,1812 # ffffffffc0205890 <commands+0x728>
ffffffffc0204184:	844fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204188 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204188:	1141                	addi	sp,sp,-16
ffffffffc020418a:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020418c:	00855793          	srli	a5,a0,0x8
ffffffffc0204190:	cbb1                	beqz	a5,ffffffffc02041e4 <swapfs_write+0x5c>
ffffffffc0204192:	00011717          	auipc	a4,0x11
ffffffffc0204196:	40673703          	ld	a4,1030(a4) # ffffffffc0215598 <max_swap_offset>
ffffffffc020419a:	04e7f563          	bgeu	a5,a4,ffffffffc02041e4 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc020419e:	00011617          	auipc	a2,0x11
ffffffffc02041a2:	3ca63603          	ld	a2,970(a2) # ffffffffc0215568 <pages>
ffffffffc02041a6:	8d91                	sub	a1,a1,a2
ffffffffc02041a8:	4065d613          	srai	a2,a1,0x6
ffffffffc02041ac:	00003717          	auipc	a4,0x3
ffffffffc02041b0:	e1473703          	ld	a4,-492(a4) # ffffffffc0206fc0 <nbase>
ffffffffc02041b4:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc02041b6:	00c61713          	slli	a4,a2,0xc
ffffffffc02041ba:	8331                	srli	a4,a4,0xc
ffffffffc02041bc:	00011697          	auipc	a3,0x11
ffffffffc02041c0:	3a46b683          	ld	a3,932(a3) # ffffffffc0215560 <npage>
ffffffffc02041c4:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02041c8:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02041ca:	02d77963          	bgeu	a4,a3,ffffffffc02041fc <swapfs_write+0x74>
}
ffffffffc02041ce:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041d0:	00011797          	auipc	a5,0x11
ffffffffc02041d4:	3a87b783          	ld	a5,936(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc02041d8:	46a1                	li	a3,8
ffffffffc02041da:	963e                	add	a2,a2,a5
ffffffffc02041dc:	4505                	li	a0,1
}
ffffffffc02041de:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041e0:	af4fc06f          	j	ffffffffc02004d4 <ide_write_secs>
ffffffffc02041e4:	86aa                	mv	a3,a0
ffffffffc02041e6:	00003617          	auipc	a2,0x3
ffffffffc02041ea:	9c260613          	addi	a2,a2,-1598 # ffffffffc0206ba8 <default_pmm_manager+0x70>
ffffffffc02041ee:	45e5                	li	a1,25
ffffffffc02041f0:	00003517          	auipc	a0,0x3
ffffffffc02041f4:	9a050513          	addi	a0,a0,-1632 # ffffffffc0206b90 <default_pmm_manager+0x58>
ffffffffc02041f8:	fd1fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc02041fc:	86b2                	mv	a3,a2
ffffffffc02041fe:	06900593          	li	a1,105
ffffffffc0204202:	00001617          	auipc	a2,0x1
ffffffffc0204206:	6c660613          	addi	a2,a2,1734 # ffffffffc02058c8 <commands+0x760>
ffffffffc020420a:	00001517          	auipc	a0,0x1
ffffffffc020420e:	68650513          	addi	a0,a0,1670 # ffffffffc0205890 <commands+0x728>
ffffffffc0204212:	fb7fb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204216 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204216:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204218:	9402                	jalr	s0

	jal do_exit
ffffffffc020421a:	4ac000ef          	jal	ra,ffffffffc02046c6 <do_exit>

ffffffffc020421e <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc020421e:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204222:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204226:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204228:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc020422a:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc020422e:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204232:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204236:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc020423a:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc020423e:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204242:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204246:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020424a:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc020424e:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204252:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204256:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc020425a:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc020425c:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc020425e:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204262:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204266:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc020426a:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc020426e:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204272:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204276:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020427a:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc020427e:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204282:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204286:	8082                	ret

ffffffffc0204288 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204288:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020428a:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc020428e:	e022                	sd	s0,0(sp)
ffffffffc0204290:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204292:	8ddfe0ef          	jal	ra,ffffffffc0202b6e <kmalloc>
ffffffffc0204296:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204298:	c521                	beqz	a0,ffffffffc02042e0 <alloc_proc+0x58>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
     proc->state = PROC_UNINIT;
ffffffffc020429a:	57fd                	li	a5,-1
ffffffffc020429c:	1782                	slli	a5,a5,0x20
ffffffffc020429e:	e11c                	sd	a5,0(a0)
     proc->runs = 0;  
     proc->kstack = 0;
     proc->need_resched = 0;
     proc->parent = NULL;
     proc->mm = NULL;
     memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02042a0:	07000613          	li	a2,112
ffffffffc02042a4:	4581                	li	a1,0
     proc->runs = 0;  
ffffffffc02042a6:	00052423          	sw	zero,8(a0)
     proc->kstack = 0;
ffffffffc02042aa:	00053823          	sd	zero,16(a0)
     proc->need_resched = 0;
ffffffffc02042ae:	00052c23          	sw	zero,24(a0)
     proc->parent = NULL;
ffffffffc02042b2:	02053023          	sd	zero,32(a0)
     proc->mm = NULL;
ffffffffc02042b6:	02053423          	sd	zero,40(a0)
     memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02042ba:	03050513          	addi	a0,a0,48
ffffffffc02042be:	7d0000ef          	jal	ra,ffffffffc0204a8e <memset>
     proc->tf = NULL;
     proc->cr3 = boot_cr3;
ffffffffc02042c2:	00011797          	auipc	a5,0x11
ffffffffc02042c6:	28e7b783          	ld	a5,654(a5) # ffffffffc0215550 <boot_cr3>
     proc->tf = NULL;
ffffffffc02042ca:	0a043023          	sd	zero,160(s0)
     proc->cr3 = boot_cr3;
ffffffffc02042ce:	f45c                	sd	a5,168(s0)
     proc->flags = 0;
ffffffffc02042d0:	0a042823          	sw	zero,176(s0)
     memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc02042d4:	463d                	li	a2,15
ffffffffc02042d6:	4581                	li	a1,0
ffffffffc02042d8:	0b440513          	addi	a0,s0,180
ffffffffc02042dc:	7b2000ef          	jal	ra,ffffffffc0204a8e <memset>


    }
    return proc;
}
ffffffffc02042e0:	60a2                	ld	ra,8(sp)
ffffffffc02042e2:	8522                	mv	a0,s0
ffffffffc02042e4:	6402                	ld	s0,0(sp)
ffffffffc02042e6:	0141                	addi	sp,sp,16
ffffffffc02042e8:	8082                	ret

ffffffffc02042ea <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc02042ea:	00011797          	auipc	a5,0x11
ffffffffc02042ee:	2c67b783          	ld	a5,710(a5) # ffffffffc02155b0 <current>
ffffffffc02042f2:	73c8                	ld	a0,160(a5)
ffffffffc02042f4:	879fc06f          	j	ffffffffc0200b6c <forkrets>

ffffffffc02042f8 <init_main>:
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02042f8:	7179                	addi	sp,sp,-48
ffffffffc02042fa:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc02042fc:	00011497          	auipc	s1,0x11
ffffffffc0204300:	21c48493          	addi	s1,s1,540 # ffffffffc0215518 <name.2>
init_main(void *arg) {
ffffffffc0204304:	f022                	sd	s0,32(sp)
ffffffffc0204306:	e84a                	sd	s2,16(sp)
ffffffffc0204308:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020430a:	00011917          	auipc	s2,0x11
ffffffffc020430e:	2a693903          	ld	s2,678(s2) # ffffffffc02155b0 <current>
    memset(name, 0, sizeof(name));
ffffffffc0204312:	4641                	li	a2,16
ffffffffc0204314:	4581                	li	a1,0
ffffffffc0204316:	8526                	mv	a0,s1
init_main(void *arg) {
ffffffffc0204318:	f406                	sd	ra,40(sp)
ffffffffc020431a:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020431c:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc0204320:	76e000ef          	jal	ra,ffffffffc0204a8e <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204324:	0b490593          	addi	a1,s2,180
ffffffffc0204328:	463d                	li	a2,15
ffffffffc020432a:	8526                	mv	a0,s1
ffffffffc020432c:	774000ef          	jal	ra,ffffffffc0204aa0 <memcpy>
ffffffffc0204330:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204332:	85ce                	mv	a1,s3
ffffffffc0204334:	00003517          	auipc	a0,0x3
ffffffffc0204338:	89450513          	addi	a0,a0,-1900 # ffffffffc0206bc8 <default_pmm_manager+0x90>
ffffffffc020433c:	d91fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc0204340:	85a2                	mv	a1,s0
ffffffffc0204342:	00003517          	auipc	a0,0x3
ffffffffc0204346:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0206bf0 <default_pmm_manager+0xb8>
ffffffffc020434a:	d83fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc020434e:	00003517          	auipc	a0,0x3
ffffffffc0204352:	8b250513          	addi	a0,a0,-1870 # ffffffffc0206c00 <default_pmm_manager+0xc8>
ffffffffc0204356:	d77fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc020435a:	70a2                	ld	ra,40(sp)
ffffffffc020435c:	7402                	ld	s0,32(sp)
ffffffffc020435e:	64e2                	ld	s1,24(sp)
ffffffffc0204360:	6942                	ld	s2,16(sp)
ffffffffc0204362:	69a2                	ld	s3,8(sp)
ffffffffc0204364:	4501                	li	a0,0
ffffffffc0204366:	6145                	addi	sp,sp,48
ffffffffc0204368:	8082                	ret

ffffffffc020436a <proc_run>:
void proc_run(struct proc_struct *proc) {
ffffffffc020436a:	7179                	addi	sp,sp,-48
ffffffffc020436c:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc020436e:	00011917          	auipc	s2,0x11
ffffffffc0204372:	24290913          	addi	s2,s2,578 # ffffffffc02155b0 <current>
void proc_run(struct proc_struct *proc) {
ffffffffc0204376:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204378:	00093483          	ld	s1,0(s2)
void proc_run(struct proc_struct *proc) {
ffffffffc020437c:	f406                	sd	ra,40(sp)
ffffffffc020437e:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204380:	02a48963          	beq	s1,a0,ffffffffc02043b2 <proc_run+0x48>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204384:	100027f3          	csrr	a5,sstatus
ffffffffc0204388:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020438a:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020438c:	e3a1                	bnez	a5,ffffffffc02043cc <proc_run+0x62>
            lcr3(next->cr3);
ffffffffc020438e:	755c                	ld	a5,168(a0)

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204390:	80000737          	lui	a4,0x80000
            current = proc;
ffffffffc0204394:	00a93023          	sd	a0,0(s2)
ffffffffc0204398:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc020439c:	8fd9                	or	a5,a5,a4
ffffffffc020439e:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc02043a2:	03050593          	addi	a1,a0,48
ffffffffc02043a6:	03048513          	addi	a0,s1,48
ffffffffc02043aa:	e75ff0ef          	jal	ra,ffffffffc020421e <switch_to>
    if (flag) {
ffffffffc02043ae:	00099863          	bnez	s3,ffffffffc02043be <proc_run+0x54>
}
ffffffffc02043b2:	70a2                	ld	ra,40(sp)
ffffffffc02043b4:	7482                	ld	s1,32(sp)
ffffffffc02043b6:	6962                	ld	s2,24(sp)
ffffffffc02043b8:	69c2                	ld	s3,16(sp)
ffffffffc02043ba:	6145                	addi	sp,sp,48
ffffffffc02043bc:	8082                	ret
ffffffffc02043be:	70a2                	ld	ra,40(sp)
ffffffffc02043c0:	7482                	ld	s1,32(sp)
ffffffffc02043c2:	6962                	ld	s2,24(sp)
ffffffffc02043c4:	69c2                	ld	s3,16(sp)
ffffffffc02043c6:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc02043c8:	9f6fc06f          	j	ffffffffc02005be <intr_enable>
ffffffffc02043cc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02043ce:	9f6fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc02043d2:	6522                	ld	a0,8(sp)
ffffffffc02043d4:	4985                	li	s3,1
ffffffffc02043d6:	bf65                	j	ffffffffc020438e <proc_run+0x24>

ffffffffc02043d8 <do_fork>:
{
ffffffffc02043d8:	7179                	addi	sp,sp,-48
ffffffffc02043da:	e44e                	sd	s3,8(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc02043dc:	00011997          	auipc	s3,0x11
ffffffffc02043e0:	1ec98993          	addi	s3,s3,492 # ffffffffc02155c8 <nr_process>
ffffffffc02043e4:	0009a703          	lw	a4,0(s3)
{
ffffffffc02043e8:	f406                	sd	ra,40(sp)
ffffffffc02043ea:	f022                	sd	s0,32(sp)
ffffffffc02043ec:	ec26                	sd	s1,24(sp)
ffffffffc02043ee:	e84a                	sd	s2,16(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc02043f0:	6785                	lui	a5,0x1
ffffffffc02043f2:	20f75863          	bge	a4,a5,ffffffffc0204602 <do_fork+0x22a>
ffffffffc02043f6:	84ae                	mv	s1,a1
ffffffffc02043f8:	8432                	mv	s0,a2
    proc = alloc_proc();
ffffffffc02043fa:	e8fff0ef          	jal	ra,ffffffffc0204288 <alloc_proc>
ffffffffc02043fe:	892a                	mv	s2,a0
    if (proc == NULL)
ffffffffc0204400:	20050563          	beqz	a0,ffffffffc020460a <do_fork+0x232>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204404:	4509                	li	a0,2
ffffffffc0204406:	fa4fc0ef          	jal	ra,ffffffffc0200baa <alloc_pages>
    if (page != NULL) {
ffffffffc020440a:	1a050663          	beqz	a0,ffffffffc02045b6 <do_fork+0x1de>
    return page - pages + nbase;
ffffffffc020440e:	00011697          	auipc	a3,0x11
ffffffffc0204412:	15a6b683          	ld	a3,346(a3) # ffffffffc0215568 <pages>
ffffffffc0204416:	40d506b3          	sub	a3,a0,a3
ffffffffc020441a:	8699                	srai	a3,a3,0x6
ffffffffc020441c:	00003517          	auipc	a0,0x3
ffffffffc0204420:	ba453503          	ld	a0,-1116(a0) # ffffffffc0206fc0 <nbase>
ffffffffc0204424:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0204426:	00c69793          	slli	a5,a3,0xc
ffffffffc020442a:	83b1                	srli	a5,a5,0xc
ffffffffc020442c:	00011717          	auipc	a4,0x11
ffffffffc0204430:	13473703          	ld	a4,308(a4) # ffffffffc0215560 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0204434:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204436:	1ee7fc63          	bgeu	a5,a4,ffffffffc020462e <do_fork+0x256>
    assert(current->mm == NULL);
ffffffffc020443a:	00011797          	auipc	a5,0x11
ffffffffc020443e:	1767b783          	ld	a5,374(a5) # ffffffffc02155b0 <current>
ffffffffc0204442:	779c                	ld	a5,40(a5)
ffffffffc0204444:	00011717          	auipc	a4,0x11
ffffffffc0204448:	13473703          	ld	a4,308(a4) # ffffffffc0215578 <va_pa_offset>
ffffffffc020444c:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020444e:	00d93823          	sd	a3,16(s2)
    assert(current->mm == NULL);
ffffffffc0204452:	1a079e63          	bnez	a5,ffffffffc020460e <do_fork+0x236>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204456:	6789                	lui	a5,0x2
ffffffffc0204458:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc020445c:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc020445e:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204460:	0ad93023          	sd	a3,160(s2)
    *(proc->tf) = *tf;
ffffffffc0204464:	87b6                	mv	a5,a3
ffffffffc0204466:	12040893          	addi	a7,s0,288
ffffffffc020446a:	00063803          	ld	a6,0(a2)
ffffffffc020446e:	6608                	ld	a0,8(a2)
ffffffffc0204470:	6a0c                	ld	a1,16(a2)
ffffffffc0204472:	6e18                	ld	a4,24(a2)
ffffffffc0204474:	0107b023          	sd	a6,0(a5)
ffffffffc0204478:	e788                	sd	a0,8(a5)
ffffffffc020447a:	eb8c                	sd	a1,16(a5)
ffffffffc020447c:	ef98                	sd	a4,24(a5)
ffffffffc020447e:	02060613          	addi	a2,a2,32
ffffffffc0204482:	02078793          	addi	a5,a5,32
ffffffffc0204486:	ff1612e3          	bne	a2,a7,ffffffffc020446a <do_fork+0x92>
    proc->tf->gpr.a0 = 0;
ffffffffc020448a:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020448e:	10048963          	beqz	s1,ffffffffc02045a0 <do_fork+0x1c8>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204492:	00006517          	auipc	a0,0x6
ffffffffc0204496:	bc650513          	addi	a0,a0,-1082 # ffffffffc020a058 <last_pid.1>
ffffffffc020449a:	411c                	lw	a5,0(a0)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020449c:	ea84                	sd	s1,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020449e:	00000717          	auipc	a4,0x0
ffffffffc02044a2:	e4c70713          	addi	a4,a4,-436 # ffffffffc02042ea <forkret>
    if (++ last_pid >= MAX_PID) {
ffffffffc02044a6:	0017849b          	addiw	s1,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044aa:	02e93823          	sd	a4,48(s2)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02044ae:	02d93c23          	sd	a3,56(s2)
    if (++ last_pid >= MAX_PID) {
ffffffffc02044b2:	c104                	sw	s1,0(a0)
ffffffffc02044b4:	6789                	lui	a5,0x2
ffffffffc02044b6:	08f4d063          	bge	s1,a5,ffffffffc0204536 <do_fork+0x15e>
    if (last_pid >= next_safe) {
ffffffffc02044ba:	00006897          	auipc	a7,0x6
ffffffffc02044be:	ba288893          	addi	a7,a7,-1118 # ffffffffc020a05c <next_safe.0>
ffffffffc02044c2:	0008a783          	lw	a5,0(a7)
ffffffffc02044c6:	00011417          	auipc	s0,0x11
ffffffffc02044ca:	06240413          	addi	s0,s0,98 # ffffffffc0215528 <proc_list>
ffffffffc02044ce:	06f4db63          	bge	s1,a5,ffffffffc0204544 <do_fork+0x16c>
    nr_process++;
ffffffffc02044d2:	0009a783          	lw	a5,0(s3)
    proc->pid = pid;
ffffffffc02044d6:	00992223          	sw	s1,4(s2)
    list_add(hash_list + pid_hashfn(pid), &(proc->hash_link));
ffffffffc02044da:	45a9                	li	a1,10
    nr_process++;
ffffffffc02044dc:	2785                	addiw	a5,a5,1
    list_add(hash_list + pid_hashfn(pid), &(proc->hash_link));
ffffffffc02044de:	0004851b          	sext.w	a0,s1
    nr_process++;
ffffffffc02044e2:	00f9a023          	sw	a5,0(s3)
    list_add(hash_list + pid_hashfn(pid), &(proc->hash_link));
ffffffffc02044e6:	1e5000ef          	jal	ra,ffffffffc0204eca <hash32>
ffffffffc02044ea:	02051793          	slli	a5,a0,0x20
ffffffffc02044ee:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02044f2:	0000d797          	auipc	a5,0xd
ffffffffc02044f6:	02678793          	addi	a5,a5,38 # ffffffffc0211518 <hash_list>
ffffffffc02044fa:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02044fc:	6514                	ld	a3,8(a0)
ffffffffc02044fe:	0d890793          	addi	a5,s2,216
ffffffffc0204502:	6418                	ld	a4,8(s0)
    prev->next = next->prev = elm;
ffffffffc0204504:	e29c                	sd	a5,0(a3)
ffffffffc0204506:	e51c                	sd	a5,8(a0)
    elm->prev = prev;
ffffffffc0204508:	0ca93c23          	sd	a0,216(s2)
    list_add(&proc_list, &(proc->list_link));
ffffffffc020450c:	0c890793          	addi	a5,s2,200
    elm->next = next;
ffffffffc0204510:	0ed93023          	sd	a3,224(s2)
    prev->next = next->prev = elm;
ffffffffc0204514:	e31c                	sd	a5,0(a4)
    elm->next = next;
ffffffffc0204516:	0ce93823          	sd	a4,208(s2)
    elm->prev = prev;
ffffffffc020451a:	0c893423          	sd	s0,200(s2)
    wakeup_proc(proc);
ffffffffc020451e:	854a                	mv	a0,s2
    prev->next = next->prev = elm;
ffffffffc0204520:	e41c                	sd	a5,8(s0)
ffffffffc0204522:	42a000ef          	jal	ra,ffffffffc020494c <wakeup_proc>
}
ffffffffc0204526:	70a2                	ld	ra,40(sp)
ffffffffc0204528:	7402                	ld	s0,32(sp)
ffffffffc020452a:	6942                	ld	s2,16(sp)
ffffffffc020452c:	69a2                	ld	s3,8(sp)
ffffffffc020452e:	8526                	mv	a0,s1
ffffffffc0204530:	64e2                	ld	s1,24(sp)
ffffffffc0204532:	6145                	addi	sp,sp,48
ffffffffc0204534:	8082                	ret
        last_pid = 1;
ffffffffc0204536:	4785                	li	a5,1
ffffffffc0204538:	c11c                	sw	a5,0(a0)
        goto inside;
ffffffffc020453a:	4485                	li	s1,1
ffffffffc020453c:	00006897          	auipc	a7,0x6
ffffffffc0204540:	b2088893          	addi	a7,a7,-1248 # ffffffffc020a05c <next_safe.0>
    return listelm->next;
ffffffffc0204544:	00011417          	auipc	s0,0x11
ffffffffc0204548:	fe440413          	addi	s0,s0,-28 # ffffffffc0215528 <proc_list>
ffffffffc020454c:	00843303          	ld	t1,8(s0)
        next_safe = MAX_PID;
ffffffffc0204550:	6789                	lui	a5,0x2
ffffffffc0204552:	00f8a023          	sw	a5,0(a7)
ffffffffc0204556:	86a6                	mv	a3,s1
ffffffffc0204558:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc020455a:	6e09                	lui	t3,0x2
ffffffffc020455c:	04830963          	beq	t1,s0,ffffffffc02045ae <do_fork+0x1d6>
ffffffffc0204560:	882e                	mv	a6,a1
ffffffffc0204562:	879a                	mv	a5,t1
ffffffffc0204564:	6609                	lui	a2,0x2
ffffffffc0204566:	a811                	j	ffffffffc020457a <do_fork+0x1a2>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0204568:	00e6d663          	bge	a3,a4,ffffffffc0204574 <do_fork+0x19c>
ffffffffc020456c:	00c75463          	bge	a4,a2,ffffffffc0204574 <do_fork+0x19c>
ffffffffc0204570:	863a                	mv	a2,a4
ffffffffc0204572:	4805                	li	a6,1
ffffffffc0204574:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204576:	00878d63          	beq	a5,s0,ffffffffc0204590 <do_fork+0x1b8>
            if (proc->pid == last_pid) {
ffffffffc020457a:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc020457e:	fed715e3          	bne	a4,a3,ffffffffc0204568 <do_fork+0x190>
                if (++ last_pid >= next_safe) {
ffffffffc0204582:	2685                	addiw	a3,a3,1
ffffffffc0204584:	02c6d063          	bge	a3,a2,ffffffffc02045a4 <do_fork+0x1cc>
ffffffffc0204588:	679c                	ld	a5,8(a5)
ffffffffc020458a:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc020458c:	fe8797e3          	bne	a5,s0,ffffffffc020457a <do_fork+0x1a2>
ffffffffc0204590:	c199                	beqz	a1,ffffffffc0204596 <do_fork+0x1be>
ffffffffc0204592:	c114                	sw	a3,0(a0)
ffffffffc0204594:	84b6                	mv	s1,a3
ffffffffc0204596:	f2080ee3          	beqz	a6,ffffffffc02044d2 <do_fork+0xfa>
ffffffffc020459a:	00c8a023          	sw	a2,0(a7)
ffffffffc020459e:	bf15                	j	ffffffffc02044d2 <do_fork+0xfa>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02045a0:	84b6                	mv	s1,a3
ffffffffc02045a2:	bdc5                	j	ffffffffc0204492 <do_fork+0xba>
                    if (last_pid >= MAX_PID) {
ffffffffc02045a4:	01c6c363          	blt	a3,t3,ffffffffc02045aa <do_fork+0x1d2>
                        last_pid = 1;
ffffffffc02045a8:	4685                	li	a3,1
                    goto repeat;
ffffffffc02045aa:	4585                	li	a1,1
ffffffffc02045ac:	bf45                	j	ffffffffc020455c <do_fork+0x184>
ffffffffc02045ae:	cda1                	beqz	a1,ffffffffc0204606 <do_fork+0x22e>
ffffffffc02045b0:	c114                	sw	a3,0(a0)
    return last_pid;
ffffffffc02045b2:	84b6                	mv	s1,a3
ffffffffc02045b4:	bf39                	j	ffffffffc02044d2 <do_fork+0xfa>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02045b6:	01093683          	ld	a3,16(s2)
    return pa2page(PADDR(kva));
ffffffffc02045ba:	c02007b7          	lui	a5,0xc0200
ffffffffc02045be:	0af6e063          	bltu	a3,a5,ffffffffc020465e <do_fork+0x286>
ffffffffc02045c2:	00011797          	auipc	a5,0x11
ffffffffc02045c6:	fb67b783          	ld	a5,-74(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc02045ca:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02045ce:	83b1                	srli	a5,a5,0xc
ffffffffc02045d0:	00011717          	auipc	a4,0x11
ffffffffc02045d4:	f9073703          	ld	a4,-112(a4) # ffffffffc0215560 <npage>
ffffffffc02045d8:	06e7f763          	bgeu	a5,a4,ffffffffc0204646 <do_fork+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02045dc:	00003717          	auipc	a4,0x3
ffffffffc02045e0:	9e473703          	ld	a4,-1564(a4) # ffffffffc0206fc0 <nbase>
ffffffffc02045e4:	8f99                	sub	a5,a5,a4
ffffffffc02045e6:	079a                	slli	a5,a5,0x6
ffffffffc02045e8:	00011517          	auipc	a0,0x11
ffffffffc02045ec:	f8053503          	ld	a0,-128(a0) # ffffffffc0215568 <pages>
ffffffffc02045f0:	953e                	add	a0,a0,a5
ffffffffc02045f2:	4589                	li	a1,2
ffffffffc02045f4:	e48fc0ef          	jal	ra,ffffffffc0200c3c <free_pages>
    kfree(proc);
ffffffffc02045f8:	854a                	mv	a0,s2
ffffffffc02045fa:	e24fe0ef          	jal	ra,ffffffffc0202c1e <kfree>
    ret = setup_kstack(proc);
ffffffffc02045fe:	54f1                	li	s1,-4
    goto fork_out;
ffffffffc0204600:	b71d                	j	ffffffffc0204526 <do_fork+0x14e>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204602:	54ed                	li	s1,-5
ffffffffc0204604:	b70d                	j	ffffffffc0204526 <do_fork+0x14e>
    return last_pid;
ffffffffc0204606:	4104                	lw	s1,0(a0)
ffffffffc0204608:	b5e9                	j	ffffffffc02044d2 <do_fork+0xfa>
    ret = -E_NO_MEM;
ffffffffc020460a:	54f1                	li	s1,-4
    return ret;
ffffffffc020460c:	bf29                	j	ffffffffc0204526 <do_fork+0x14e>
    assert(current->mm == NULL);
ffffffffc020460e:	00002697          	auipc	a3,0x2
ffffffffc0204612:	61268693          	addi	a3,a3,1554 # ffffffffc0206c20 <default_pmm_manager+0xe8>
ffffffffc0204616:	00001617          	auipc	a2,0x1
ffffffffc020461a:	3c260613          	addi	a2,a2,962 # ffffffffc02059d8 <commands+0x870>
ffffffffc020461e:	13900593          	li	a1,313
ffffffffc0204622:	00002517          	auipc	a0,0x2
ffffffffc0204626:	61650513          	addi	a0,a0,1558 # ffffffffc0206c38 <default_pmm_manager+0x100>
ffffffffc020462a:	b9ffb0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc020462e:	00001617          	auipc	a2,0x1
ffffffffc0204632:	29a60613          	addi	a2,a2,666 # ffffffffc02058c8 <commands+0x760>
ffffffffc0204636:	06900593          	li	a1,105
ffffffffc020463a:	00001517          	auipc	a0,0x1
ffffffffc020463e:	25650513          	addi	a0,a0,598 # ffffffffc0205890 <commands+0x728>
ffffffffc0204642:	b87fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204646:	00001617          	auipc	a2,0x1
ffffffffc020464a:	22a60613          	addi	a2,a2,554 # ffffffffc0205870 <commands+0x708>
ffffffffc020464e:	06200593          	li	a1,98
ffffffffc0204652:	00001517          	auipc	a0,0x1
ffffffffc0204656:	23e50513          	addi	a0,a0,574 # ffffffffc0205890 <commands+0x728>
ffffffffc020465a:	b6ffb0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020465e:	00001617          	auipc	a2,0x1
ffffffffc0204662:	2fa60613          	addi	a2,a2,762 # ffffffffc0205958 <commands+0x7f0>
ffffffffc0204666:	06e00593          	li	a1,110
ffffffffc020466a:	00001517          	auipc	a0,0x1
ffffffffc020466e:	22650513          	addi	a0,a0,550 # ffffffffc0205890 <commands+0x728>
ffffffffc0204672:	b57fb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204676 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204676:	7129                	addi	sp,sp,-320
ffffffffc0204678:	fa22                	sd	s0,304(sp)
ffffffffc020467a:	f626                	sd	s1,296(sp)
ffffffffc020467c:	f24a                	sd	s2,288(sp)
ffffffffc020467e:	84ae                	mv	s1,a1
ffffffffc0204680:	892a                	mv	s2,a0
ffffffffc0204682:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204684:	4581                	li	a1,0
ffffffffc0204686:	12000613          	li	a2,288
ffffffffc020468a:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020468c:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020468e:	400000ef          	jal	ra,ffffffffc0204a8e <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204692:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204694:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204696:	100027f3          	csrr	a5,sstatus
ffffffffc020469a:	edd7f793          	andi	a5,a5,-291
ffffffffc020469e:	1207e793          	ori	a5,a5,288
ffffffffc02046a2:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046a4:	860a                	mv	a2,sp
ffffffffc02046a6:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02046aa:	00000797          	auipc	a5,0x0
ffffffffc02046ae:	b6c78793          	addi	a5,a5,-1172 # ffffffffc0204216 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046b2:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02046b4:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046b6:	d23ff0ef          	jal	ra,ffffffffc02043d8 <do_fork>
}
ffffffffc02046ba:	70f2                	ld	ra,312(sp)
ffffffffc02046bc:	7452                	ld	s0,304(sp)
ffffffffc02046be:	74b2                	ld	s1,296(sp)
ffffffffc02046c0:	7912                	ld	s2,288(sp)
ffffffffc02046c2:	6131                	addi	sp,sp,320
ffffffffc02046c4:	8082                	ret

ffffffffc02046c6 <do_exit>:
do_exit(int error_code) {
ffffffffc02046c6:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc02046c8:	00002617          	auipc	a2,0x2
ffffffffc02046cc:	58860613          	addi	a2,a2,1416 # ffffffffc0206c50 <default_pmm_manager+0x118>
ffffffffc02046d0:	19e00593          	li	a1,414
ffffffffc02046d4:	00002517          	auipc	a0,0x2
ffffffffc02046d8:	56450513          	addi	a0,a0,1380 # ffffffffc0206c38 <default_pmm_manager+0x100>
do_exit(int error_code) {
ffffffffc02046dc:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc02046de:	aebfb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02046e2 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
// 完成了idleproc内核线程和initproc内核线程的创建或复制工作
void
proc_init(void) {
ffffffffc02046e2:	7179                	addi	sp,sp,-48
ffffffffc02046e4:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc02046e6:	00011797          	auipc	a5,0x11
ffffffffc02046ea:	e4278793          	addi	a5,a5,-446 # ffffffffc0215528 <proc_list>
ffffffffc02046ee:	f406                	sd	ra,40(sp)
ffffffffc02046f0:	f022                	sd	s0,32(sp)
ffffffffc02046f2:	e84a                	sd	s2,16(sp)
ffffffffc02046f4:	e44e                	sd	s3,8(sp)
ffffffffc02046f6:	0000d497          	auipc	s1,0xd
ffffffffc02046fa:	e2248493          	addi	s1,s1,-478 # ffffffffc0211518 <hash_list>
ffffffffc02046fe:	e79c                	sd	a5,8(a5)
ffffffffc0204700:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0204702:	00011717          	auipc	a4,0x11
ffffffffc0204706:	e1670713          	addi	a4,a4,-490 # ffffffffc0215518 <name.2>
ffffffffc020470a:	87a6                	mv	a5,s1
ffffffffc020470c:	e79c                	sd	a5,8(a5)
ffffffffc020470e:	e39c                	sd	a5,0(a5)
ffffffffc0204710:	07c1                	addi	a5,a5,16
ffffffffc0204712:	fef71de3          	bne	a4,a5,ffffffffc020470c <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0204716:	b73ff0ef          	jal	ra,ffffffffc0204288 <alloc_proc>
ffffffffc020471a:	00011917          	auipc	s2,0x11
ffffffffc020471e:	e9e90913          	addi	s2,s2,-354 # ffffffffc02155b8 <idleproc>
ffffffffc0204722:	00a93023          	sd	a0,0(s2)
ffffffffc0204726:	18050d63          	beqz	a0,ffffffffc02048c0 <proc_init+0x1de>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc020472a:	07000513          	li	a0,112
ffffffffc020472e:	c40fe0ef          	jal	ra,ffffffffc0202b6e <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204732:	07000613          	li	a2,112
ffffffffc0204736:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204738:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020473a:	354000ef          	jal	ra,ffffffffc0204a8e <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc020473e:	00093503          	ld	a0,0(s2)
ffffffffc0204742:	85a2                	mv	a1,s0
ffffffffc0204744:	07000613          	li	a2,112
ffffffffc0204748:	03050513          	addi	a0,a0,48
ffffffffc020474c:	36c000ef          	jal	ra,ffffffffc0204ab8 <memcmp>
ffffffffc0204750:	89aa                	mv	s3,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204752:	453d                	li	a0,15
ffffffffc0204754:	c1afe0ef          	jal	ra,ffffffffc0202b6e <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204758:	463d                	li	a2,15
ffffffffc020475a:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc020475c:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc020475e:	330000ef          	jal	ra,ffffffffc0204a8e <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc0204762:	00093503          	ld	a0,0(s2)
ffffffffc0204766:	463d                	li	a2,15
ffffffffc0204768:	85a2                	mv	a1,s0
ffffffffc020476a:	0b450513          	addi	a0,a0,180
ffffffffc020476e:	34a000ef          	jal	ra,ffffffffc0204ab8 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204772:	00093783          	ld	a5,0(s2)
ffffffffc0204776:	00011717          	auipc	a4,0x11
ffffffffc020477a:	dda73703          	ld	a4,-550(a4) # ffffffffc0215550 <boot_cr3>
ffffffffc020477e:	77d4                	ld	a3,168(a5)
ffffffffc0204780:	0ee68463          	beq	a3,a4,ffffffffc0204868 <proc_init+0x186>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204784:	4709                	li	a4,2
ffffffffc0204786:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204788:	00003717          	auipc	a4,0x3
ffffffffc020478c:	87870713          	addi	a4,a4,-1928 # ffffffffc0207000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204790:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204794:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc0204796:	4705                	li	a4,1
ffffffffc0204798:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020479a:	4641                	li	a2,16
ffffffffc020479c:	4581                	li	a1,0
ffffffffc020479e:	8522                	mv	a0,s0
ffffffffc02047a0:	2ee000ef          	jal	ra,ffffffffc0204a8e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02047a4:	463d                	li	a2,15
ffffffffc02047a6:	00002597          	auipc	a1,0x2
ffffffffc02047aa:	4f258593          	addi	a1,a1,1266 # ffffffffc0206c98 <default_pmm_manager+0x160>
ffffffffc02047ae:	8522                	mv	a0,s0
ffffffffc02047b0:	2f0000ef          	jal	ra,ffffffffc0204aa0 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc02047b4:	00011717          	auipc	a4,0x11
ffffffffc02047b8:	e1470713          	addi	a4,a4,-492 # ffffffffc02155c8 <nr_process>
ffffffffc02047bc:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc02047be:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02047c2:	4601                	li	a2,0
    nr_process ++;
ffffffffc02047c4:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02047c6:	00002597          	auipc	a1,0x2
ffffffffc02047ca:	4da58593          	addi	a1,a1,1242 # ffffffffc0206ca0 <default_pmm_manager+0x168>
ffffffffc02047ce:	00000517          	auipc	a0,0x0
ffffffffc02047d2:	b2a50513          	addi	a0,a0,-1238 # ffffffffc02042f8 <init_main>
    nr_process ++;
ffffffffc02047d6:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc02047d8:	00011797          	auipc	a5,0x11
ffffffffc02047dc:	dcd7bc23          	sd	a3,-552(a5) # ffffffffc02155b0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02047e0:	e97ff0ef          	jal	ra,ffffffffc0204676 <kernel_thread>
ffffffffc02047e4:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc02047e6:	0ea05963          	blez	a0,ffffffffc02048d8 <proc_init+0x1f6>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02047ea:	6789                	lui	a5,0x2
ffffffffc02047ec:	fff5071b          	addiw	a4,a0,-1
ffffffffc02047f0:	17f9                	addi	a5,a5,-2
ffffffffc02047f2:	2501                	sext.w	a0,a0
ffffffffc02047f4:	02e7e363          	bltu	a5,a4,ffffffffc020481a <proc_init+0x138>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02047f8:	45a9                	li	a1,10
ffffffffc02047fa:	6d0000ef          	jal	ra,ffffffffc0204eca <hash32>
ffffffffc02047fe:	02051793          	slli	a5,a0,0x20
ffffffffc0204802:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204806:	96a6                	add	a3,a3,s1
ffffffffc0204808:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc020480a:	a029                	j	ffffffffc0204814 <proc_init+0x132>
            if (proc->pid == pid) {
ffffffffc020480c:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc0204810:	0a870563          	beq	a4,s0,ffffffffc02048ba <proc_init+0x1d8>
    return listelm->next;
ffffffffc0204814:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204816:	fef69be3          	bne	a3,a5,ffffffffc020480c <proc_init+0x12a>
    return NULL;
ffffffffc020481a:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020481c:	0b478493          	addi	s1,a5,180
ffffffffc0204820:	4641                	li	a2,16
ffffffffc0204822:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204824:	00011417          	auipc	s0,0x11
ffffffffc0204828:	d9c40413          	addi	s0,s0,-612 # ffffffffc02155c0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020482c:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc020482e:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204830:	25e000ef          	jal	ra,ffffffffc0204a8e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204834:	463d                	li	a2,15
ffffffffc0204836:	00002597          	auipc	a1,0x2
ffffffffc020483a:	49a58593          	addi	a1,a1,1178 # ffffffffc0206cd0 <default_pmm_manager+0x198>
ffffffffc020483e:	8526                	mv	a0,s1
ffffffffc0204840:	260000ef          	jal	ra,ffffffffc0204aa0 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204844:	00093783          	ld	a5,0(s2)
ffffffffc0204848:	c7e1                	beqz	a5,ffffffffc0204910 <proc_init+0x22e>
ffffffffc020484a:	43dc                	lw	a5,4(a5)
ffffffffc020484c:	e3f1                	bnez	a5,ffffffffc0204910 <proc_init+0x22e>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020484e:	601c                	ld	a5,0(s0)
ffffffffc0204850:	c3c5                	beqz	a5,ffffffffc02048f0 <proc_init+0x20e>
ffffffffc0204852:	43d8                	lw	a4,4(a5)
ffffffffc0204854:	4785                	li	a5,1
ffffffffc0204856:	08f71d63          	bne	a4,a5,ffffffffc02048f0 <proc_init+0x20e>
}
ffffffffc020485a:	70a2                	ld	ra,40(sp)
ffffffffc020485c:	7402                	ld	s0,32(sp)
ffffffffc020485e:	64e2                	ld	s1,24(sp)
ffffffffc0204860:	6942                	ld	s2,16(sp)
ffffffffc0204862:	69a2                	ld	s3,8(sp)
ffffffffc0204864:	6145                	addi	sp,sp,48
ffffffffc0204866:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204868:	73d8                	ld	a4,160(a5)
ffffffffc020486a:	ff09                	bnez	a4,ffffffffc0204784 <proc_init+0xa2>
ffffffffc020486c:	f0099ce3          	bnez	s3,ffffffffc0204784 <proc_init+0xa2>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc0204870:	6394                	ld	a3,0(a5)
ffffffffc0204872:	577d                	li	a4,-1
ffffffffc0204874:	1702                	slli	a4,a4,0x20
ffffffffc0204876:	f0e697e3          	bne	a3,a4,ffffffffc0204784 <proc_init+0xa2>
ffffffffc020487a:	4798                	lw	a4,8(a5)
ffffffffc020487c:	f00714e3          	bnez	a4,ffffffffc0204784 <proc_init+0xa2>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc0204880:	6b98                	ld	a4,16(a5)
ffffffffc0204882:	f00711e3          	bnez	a4,ffffffffc0204784 <proc_init+0xa2>
ffffffffc0204886:	4f98                	lw	a4,24(a5)
ffffffffc0204888:	2701                	sext.w	a4,a4
ffffffffc020488a:	ee071de3          	bnez	a4,ffffffffc0204784 <proc_init+0xa2>
ffffffffc020488e:	7398                	ld	a4,32(a5)
ffffffffc0204890:	ee071ae3          	bnez	a4,ffffffffc0204784 <proc_init+0xa2>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204894:	7798                	ld	a4,40(a5)
ffffffffc0204896:	ee0717e3          	bnez	a4,ffffffffc0204784 <proc_init+0xa2>
ffffffffc020489a:	0b07a703          	lw	a4,176(a5)
ffffffffc020489e:	8d59                	or	a0,a0,a4
ffffffffc02048a0:	0005071b          	sext.w	a4,a0
ffffffffc02048a4:	ee0710e3          	bnez	a4,ffffffffc0204784 <proc_init+0xa2>
        cprintf("alloc_proc() correct!\n");
ffffffffc02048a8:	00002517          	auipc	a0,0x2
ffffffffc02048ac:	3d850513          	addi	a0,a0,984 # ffffffffc0206c80 <default_pmm_manager+0x148>
ffffffffc02048b0:	81dfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    idleproc->pid = 0;
ffffffffc02048b4:	00093783          	ld	a5,0(s2)
ffffffffc02048b8:	b5f1                	j	ffffffffc0204784 <proc_init+0xa2>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02048ba:	f2878793          	addi	a5,a5,-216
ffffffffc02048be:	bfb9                	j	ffffffffc020481c <proc_init+0x13a>
        panic("cannot alloc idleproc.\n");
ffffffffc02048c0:	00002617          	auipc	a2,0x2
ffffffffc02048c4:	3a860613          	addi	a2,a2,936 # ffffffffc0206c68 <default_pmm_manager+0x130>
ffffffffc02048c8:	1b700593          	li	a1,439
ffffffffc02048cc:	00002517          	auipc	a0,0x2
ffffffffc02048d0:	36c50513          	addi	a0,a0,876 # ffffffffc0206c38 <default_pmm_manager+0x100>
ffffffffc02048d4:	8f5fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("create init_main failed.\n");
ffffffffc02048d8:	00002617          	auipc	a2,0x2
ffffffffc02048dc:	3d860613          	addi	a2,a2,984 # ffffffffc0206cb0 <default_pmm_manager+0x178>
ffffffffc02048e0:	1d700593          	li	a1,471
ffffffffc02048e4:	00002517          	auipc	a0,0x2
ffffffffc02048e8:	35450513          	addi	a0,a0,852 # ffffffffc0206c38 <default_pmm_manager+0x100>
ffffffffc02048ec:	8ddfb0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02048f0:	00002697          	auipc	a3,0x2
ffffffffc02048f4:	41068693          	addi	a3,a3,1040 # ffffffffc0206d00 <default_pmm_manager+0x1c8>
ffffffffc02048f8:	00001617          	auipc	a2,0x1
ffffffffc02048fc:	0e060613          	addi	a2,a2,224 # ffffffffc02059d8 <commands+0x870>
ffffffffc0204900:	1de00593          	li	a1,478
ffffffffc0204904:	00002517          	auipc	a0,0x2
ffffffffc0204908:	33450513          	addi	a0,a0,820 # ffffffffc0206c38 <default_pmm_manager+0x100>
ffffffffc020490c:	8bdfb0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204910:	00002697          	auipc	a3,0x2
ffffffffc0204914:	3c868693          	addi	a3,a3,968 # ffffffffc0206cd8 <default_pmm_manager+0x1a0>
ffffffffc0204918:	00001617          	auipc	a2,0x1
ffffffffc020491c:	0c060613          	addi	a2,a2,192 # ffffffffc02059d8 <commands+0x870>
ffffffffc0204920:	1dd00593          	li	a1,477
ffffffffc0204924:	00002517          	auipc	a0,0x2
ffffffffc0204928:	31450513          	addi	a0,a0,788 # ffffffffc0206c38 <default_pmm_manager+0x100>
ffffffffc020492c:	89dfb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204930 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
// 调度点
void cpu_idle(void) {
ffffffffc0204930:	1141                	addi	sp,sp,-16
ffffffffc0204932:	e022                	sd	s0,0(sp)
ffffffffc0204934:	e406                	sd	ra,8(sp)
ffffffffc0204936:	00011417          	auipc	s0,0x11
ffffffffc020493a:	c7a40413          	addi	s0,s0,-902 # ffffffffc02155b0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc020493e:	6018                	ld	a4,0(s0)
ffffffffc0204940:	4f1c                	lw	a5,24(a4)
ffffffffc0204942:	2781                	sext.w	a5,a5
ffffffffc0204944:	dff5                	beqz	a5,ffffffffc0204940 <cpu_idle+0x10>
            schedule();
ffffffffc0204946:	038000ef          	jal	ra,ffffffffc020497e <schedule>
ffffffffc020494a:	bfd5                	j	ffffffffc020493e <cpu_idle+0xe>

ffffffffc020494c <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020494c:	411c                	lw	a5,0(a0)
ffffffffc020494e:	4705                	li	a4,1
ffffffffc0204950:	37f9                	addiw	a5,a5,-2
ffffffffc0204952:	00f77563          	bgeu	a4,a5,ffffffffc020495c <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc0204956:	4789                	li	a5,2
ffffffffc0204958:	c11c                	sw	a5,0(a0)
ffffffffc020495a:	8082                	ret
void wakeup_proc(struct proc_struct *proc) {
ffffffffc020495c:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020495e:	00002697          	auipc	a3,0x2
ffffffffc0204962:	3ca68693          	addi	a3,a3,970 # ffffffffc0206d28 <default_pmm_manager+0x1f0>
ffffffffc0204966:	00001617          	auipc	a2,0x1
ffffffffc020496a:	07260613          	addi	a2,a2,114 # ffffffffc02059d8 <commands+0x870>
ffffffffc020496e:	45a1                	li	a1,8
ffffffffc0204970:	00002517          	auipc	a0,0x2
ffffffffc0204974:	3f850513          	addi	a0,a0,1016 # ffffffffc0206d68 <default_pmm_manager+0x230>
void wakeup_proc(struct proc_struct *proc) {
ffffffffc0204978:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020497a:	84ffb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020497e <schedule>:
}

void schedule(void) {
ffffffffc020497e:	1141                	addi	sp,sp,-16
ffffffffc0204980:	e406                	sd	ra,8(sp)
ffffffffc0204982:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204984:	100027f3          	csrr	a5,sstatus
ffffffffc0204988:	8b89                	andi	a5,a5,2
ffffffffc020498a:	4401                	li	s0,0
ffffffffc020498c:	efbd                	bnez	a5,ffffffffc0204a0a <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc020498e:	00011897          	auipc	a7,0x11
ffffffffc0204992:	c228b883          	ld	a7,-990(a7) # ffffffffc02155b0 <current>
ffffffffc0204996:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020499a:	00011517          	auipc	a0,0x11
ffffffffc020499e:	c1e53503          	ld	a0,-994(a0) # ffffffffc02155b8 <idleproc>
ffffffffc02049a2:	04a88e63          	beq	a7,a0,ffffffffc02049fe <schedule+0x80>
ffffffffc02049a6:	0c888693          	addi	a3,a7,200
ffffffffc02049aa:	00011617          	auipc	a2,0x11
ffffffffc02049ae:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0215528 <proc_list>
        le = last;
ffffffffc02049b2:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02049b4:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02049b6:	4809                	li	a6,2
ffffffffc02049b8:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02049ba:	00c78863          	beq	a5,a2,ffffffffc02049ca <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02049be:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02049c2:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02049c6:	03070163          	beq	a4,a6,ffffffffc02049e8 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc02049ca:	fef697e3          	bne	a3,a5,ffffffffc02049b8 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02049ce:	ed89                	bnez	a1,ffffffffc02049e8 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02049d0:	451c                	lw	a5,8(a0)
ffffffffc02049d2:	2785                	addiw	a5,a5,1
ffffffffc02049d4:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc02049d6:	00a88463          	beq	a7,a0,ffffffffc02049de <schedule+0x60>
            proc_run(next);
ffffffffc02049da:	991ff0ef          	jal	ra,ffffffffc020436a <proc_run>
    if (flag) {
ffffffffc02049de:	e819                	bnez	s0,ffffffffc02049f4 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02049e0:	60a2                	ld	ra,8(sp)
ffffffffc02049e2:	6402                	ld	s0,0(sp)
ffffffffc02049e4:	0141                	addi	sp,sp,16
ffffffffc02049e6:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02049e8:	4198                	lw	a4,0(a1)
ffffffffc02049ea:	4789                	li	a5,2
ffffffffc02049ec:	fef712e3          	bne	a4,a5,ffffffffc02049d0 <schedule+0x52>
ffffffffc02049f0:	852e                	mv	a0,a1
ffffffffc02049f2:	bff9                	j	ffffffffc02049d0 <schedule+0x52>
}
ffffffffc02049f4:	6402                	ld	s0,0(sp)
ffffffffc02049f6:	60a2                	ld	ra,8(sp)
ffffffffc02049f8:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02049fa:	bc5fb06f          	j	ffffffffc02005be <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02049fe:	00011617          	auipc	a2,0x11
ffffffffc0204a02:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0215528 <proc_list>
ffffffffc0204a06:	86b2                	mv	a3,a2
ffffffffc0204a08:	b76d                	j	ffffffffc02049b2 <schedule+0x34>
        intr_disable();
ffffffffc0204a0a:	bbbfb0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc0204a0e:	4405                	li	s0,1
ffffffffc0204a10:	bfbd                	j	ffffffffc020498e <schedule+0x10>

ffffffffc0204a12 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204a12:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204a16:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0204a18:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0204a1a:	cb81                	beqz	a5,ffffffffc0204a2a <strlen+0x18>
        cnt ++;
ffffffffc0204a1c:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204a1e:	00a707b3          	add	a5,a4,a0
ffffffffc0204a22:	0007c783          	lbu	a5,0(a5)
ffffffffc0204a26:	fbfd                	bnez	a5,ffffffffc0204a1c <strlen+0xa>
ffffffffc0204a28:	8082                	ret
    }
    return cnt;
}
ffffffffc0204a2a:	8082                	ret

ffffffffc0204a2c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0204a2c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204a2e:	e589                	bnez	a1,ffffffffc0204a38 <strnlen+0xc>
ffffffffc0204a30:	a811                	j	ffffffffc0204a44 <strnlen+0x18>
        cnt ++;
ffffffffc0204a32:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204a34:	00f58863          	beq	a1,a5,ffffffffc0204a44 <strnlen+0x18>
ffffffffc0204a38:	00f50733          	add	a4,a0,a5
ffffffffc0204a3c:	00074703          	lbu	a4,0(a4)
ffffffffc0204a40:	fb6d                	bnez	a4,ffffffffc0204a32 <strnlen+0x6>
ffffffffc0204a42:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204a44:	852e                	mv	a0,a1
ffffffffc0204a46:	8082                	ret

ffffffffc0204a48 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204a48:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204a4a:	0005c703          	lbu	a4,0(a1)
ffffffffc0204a4e:	0785                	addi	a5,a5,1
ffffffffc0204a50:	0585                	addi	a1,a1,1
ffffffffc0204a52:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204a56:	fb75                	bnez	a4,ffffffffc0204a4a <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204a58:	8082                	ret

ffffffffc0204a5a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204a5a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204a5e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204a62:	cb89                	beqz	a5,ffffffffc0204a74 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204a64:	0505                	addi	a0,a0,1
ffffffffc0204a66:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204a68:	fee789e3          	beq	a5,a4,ffffffffc0204a5a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204a6c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204a70:	9d19                	subw	a0,a0,a4
ffffffffc0204a72:	8082                	ret
ffffffffc0204a74:	4501                	li	a0,0
ffffffffc0204a76:	bfed                	j	ffffffffc0204a70 <strcmp+0x16>

ffffffffc0204a78 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204a78:	00054783          	lbu	a5,0(a0)
ffffffffc0204a7c:	c799                	beqz	a5,ffffffffc0204a8a <strchr+0x12>
        if (*s == c) {
ffffffffc0204a7e:	00f58763          	beq	a1,a5,ffffffffc0204a8c <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204a82:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204a86:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204a88:	fbfd                	bnez	a5,ffffffffc0204a7e <strchr+0x6>
    }
    return NULL;
ffffffffc0204a8a:	4501                	li	a0,0
}
ffffffffc0204a8c:	8082                	ret

ffffffffc0204a8e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204a8e:	ca01                	beqz	a2,ffffffffc0204a9e <memset+0x10>
ffffffffc0204a90:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204a92:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204a94:	0785                	addi	a5,a5,1
ffffffffc0204a96:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204a9a:	fec79de3          	bne	a5,a2,ffffffffc0204a94 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204a9e:	8082                	ret

ffffffffc0204aa0 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204aa0:	ca19                	beqz	a2,ffffffffc0204ab6 <memcpy+0x16>
ffffffffc0204aa2:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204aa4:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204aa6:	0005c703          	lbu	a4,0(a1)
ffffffffc0204aaa:	0585                	addi	a1,a1,1
ffffffffc0204aac:	0785                	addi	a5,a5,1
ffffffffc0204aae:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204ab2:	fec59ae3          	bne	a1,a2,ffffffffc0204aa6 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204ab6:	8082                	ret

ffffffffc0204ab8 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204ab8:	c205                	beqz	a2,ffffffffc0204ad8 <memcmp+0x20>
ffffffffc0204aba:	962e                	add	a2,a2,a1
ffffffffc0204abc:	a019                	j	ffffffffc0204ac2 <memcmp+0xa>
ffffffffc0204abe:	00c58d63          	beq	a1,a2,ffffffffc0204ad8 <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc0204ac2:	00054783          	lbu	a5,0(a0)
ffffffffc0204ac6:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204aca:	0505                	addi	a0,a0,1
ffffffffc0204acc:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc0204ace:	fee788e3          	beq	a5,a4,ffffffffc0204abe <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204ad2:	40e7853b          	subw	a0,a5,a4
ffffffffc0204ad6:	8082                	ret
    }
    return 0;
ffffffffc0204ad8:	4501                	li	a0,0
}
ffffffffc0204ada:	8082                	ret

ffffffffc0204adc <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204adc:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204ae0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204ae2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204ae6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204ae8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204aec:	f022                	sd	s0,32(sp)
ffffffffc0204aee:	ec26                	sd	s1,24(sp)
ffffffffc0204af0:	e84a                	sd	s2,16(sp)
ffffffffc0204af2:	f406                	sd	ra,40(sp)
ffffffffc0204af4:	e44e                	sd	s3,8(sp)
ffffffffc0204af6:	84aa                	mv	s1,a0
ffffffffc0204af8:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204afa:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204afe:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0204b00:	03067e63          	bgeu	a2,a6,ffffffffc0204b3c <printnum+0x60>
ffffffffc0204b04:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0204b06:	00805763          	blez	s0,ffffffffc0204b14 <printnum+0x38>
ffffffffc0204b0a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204b0c:	85ca                	mv	a1,s2
ffffffffc0204b0e:	854e                	mv	a0,s3
ffffffffc0204b10:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204b12:	fc65                	bnez	s0,ffffffffc0204b0a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b14:	1a02                	slli	s4,s4,0x20
ffffffffc0204b16:	00002797          	auipc	a5,0x2
ffffffffc0204b1a:	26a78793          	addi	a5,a5,618 # ffffffffc0206d80 <default_pmm_manager+0x248>
ffffffffc0204b1e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204b22:	9a3e                	add	s4,s4,a5
}
ffffffffc0204b24:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b26:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204b2a:	70a2                	ld	ra,40(sp)
ffffffffc0204b2c:	69a2                	ld	s3,8(sp)
ffffffffc0204b2e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b30:	85ca                	mv	a1,s2
ffffffffc0204b32:	87a6                	mv	a5,s1
}
ffffffffc0204b34:	6942                	ld	s2,16(sp)
ffffffffc0204b36:	64e2                	ld	s1,24(sp)
ffffffffc0204b38:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b3a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204b3c:	03065633          	divu	a2,a2,a6
ffffffffc0204b40:	8722                	mv	a4,s0
ffffffffc0204b42:	f9bff0ef          	jal	ra,ffffffffc0204adc <printnum>
ffffffffc0204b46:	b7f9                	j	ffffffffc0204b14 <printnum+0x38>

ffffffffc0204b48 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204b48:	7119                	addi	sp,sp,-128
ffffffffc0204b4a:	f4a6                	sd	s1,104(sp)
ffffffffc0204b4c:	f0ca                	sd	s2,96(sp)
ffffffffc0204b4e:	ecce                	sd	s3,88(sp)
ffffffffc0204b50:	e8d2                	sd	s4,80(sp)
ffffffffc0204b52:	e4d6                	sd	s5,72(sp)
ffffffffc0204b54:	e0da                	sd	s6,64(sp)
ffffffffc0204b56:	fc5e                	sd	s7,56(sp)
ffffffffc0204b58:	f06a                	sd	s10,32(sp)
ffffffffc0204b5a:	fc86                	sd	ra,120(sp)
ffffffffc0204b5c:	f8a2                	sd	s0,112(sp)
ffffffffc0204b5e:	f862                	sd	s8,48(sp)
ffffffffc0204b60:	f466                	sd	s9,40(sp)
ffffffffc0204b62:	ec6e                	sd	s11,24(sp)
ffffffffc0204b64:	892a                	mv	s2,a0
ffffffffc0204b66:	84ae                	mv	s1,a1
ffffffffc0204b68:	8d32                	mv	s10,a2
ffffffffc0204b6a:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b6c:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204b70:	5b7d                	li	s6,-1
ffffffffc0204b72:	00002a97          	auipc	s5,0x2
ffffffffc0204b76:	23aa8a93          	addi	s5,s5,570 # ffffffffc0206dac <default_pmm_manager+0x274>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204b7a:	00002b97          	auipc	s7,0x2
ffffffffc0204b7e:	40eb8b93          	addi	s7,s7,1038 # ffffffffc0206f88 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b82:	000d4503          	lbu	a0,0(s10)
ffffffffc0204b86:	001d0413          	addi	s0,s10,1
ffffffffc0204b8a:	01350a63          	beq	a0,s3,ffffffffc0204b9e <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204b8e:	c121                	beqz	a0,ffffffffc0204bce <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204b90:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b92:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204b94:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b96:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204b9a:	ff351ae3          	bne	a0,s3,ffffffffc0204b8e <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b9e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204ba2:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204ba6:	4c81                	li	s9,0
ffffffffc0204ba8:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204baa:	5c7d                	li	s8,-1
ffffffffc0204bac:	5dfd                	li	s11,-1
ffffffffc0204bae:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204bb2:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bb4:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204bb8:	0ff5f593          	zext.b	a1,a1
ffffffffc0204bbc:	00140d13          	addi	s10,s0,1
ffffffffc0204bc0:	04b56263          	bltu	a0,a1,ffffffffc0204c04 <vprintfmt+0xbc>
ffffffffc0204bc4:	058a                	slli	a1,a1,0x2
ffffffffc0204bc6:	95d6                	add	a1,a1,s5
ffffffffc0204bc8:	4194                	lw	a3,0(a1)
ffffffffc0204bca:	96d6                	add	a3,a3,s5
ffffffffc0204bcc:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204bce:	70e6                	ld	ra,120(sp)
ffffffffc0204bd0:	7446                	ld	s0,112(sp)
ffffffffc0204bd2:	74a6                	ld	s1,104(sp)
ffffffffc0204bd4:	7906                	ld	s2,96(sp)
ffffffffc0204bd6:	69e6                	ld	s3,88(sp)
ffffffffc0204bd8:	6a46                	ld	s4,80(sp)
ffffffffc0204bda:	6aa6                	ld	s5,72(sp)
ffffffffc0204bdc:	6b06                	ld	s6,64(sp)
ffffffffc0204bde:	7be2                	ld	s7,56(sp)
ffffffffc0204be0:	7c42                	ld	s8,48(sp)
ffffffffc0204be2:	7ca2                	ld	s9,40(sp)
ffffffffc0204be4:	7d02                	ld	s10,32(sp)
ffffffffc0204be6:	6de2                	ld	s11,24(sp)
ffffffffc0204be8:	6109                	addi	sp,sp,128
ffffffffc0204bea:	8082                	ret
            padc = '0';
ffffffffc0204bec:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204bee:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bf2:	846a                	mv	s0,s10
ffffffffc0204bf4:	00140d13          	addi	s10,s0,1
ffffffffc0204bf8:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204bfc:	0ff5f593          	zext.b	a1,a1
ffffffffc0204c00:	fcb572e3          	bgeu	a0,a1,ffffffffc0204bc4 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204c04:	85a6                	mv	a1,s1
ffffffffc0204c06:	02500513          	li	a0,37
ffffffffc0204c0a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204c0c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204c10:	8d22                	mv	s10,s0
ffffffffc0204c12:	f73788e3          	beq	a5,s3,ffffffffc0204b82 <vprintfmt+0x3a>
ffffffffc0204c16:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204c1a:	1d7d                	addi	s10,s10,-1
ffffffffc0204c1c:	ff379de3          	bne	a5,s3,ffffffffc0204c16 <vprintfmt+0xce>
ffffffffc0204c20:	b78d                	j	ffffffffc0204b82 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204c22:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204c26:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c2a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204c2c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204c30:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204c34:	02d86463          	bltu	a6,a3,ffffffffc0204c5c <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0204c38:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204c3c:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204c40:	0186873b          	addw	a4,a3,s8
ffffffffc0204c44:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204c48:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204c4a:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204c4e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204c50:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204c54:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204c58:	fed870e3          	bgeu	a6,a3,ffffffffc0204c38 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204c5c:	f40ddce3          	bgez	s11,ffffffffc0204bb4 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204c60:	8de2                	mv	s11,s8
ffffffffc0204c62:	5c7d                	li	s8,-1
ffffffffc0204c64:	bf81                	j	ffffffffc0204bb4 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204c66:	fffdc693          	not	a3,s11
ffffffffc0204c6a:	96fd                	srai	a3,a3,0x3f
ffffffffc0204c6c:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c70:	00144603          	lbu	a2,1(s0)
ffffffffc0204c74:	2d81                	sext.w	s11,s11
ffffffffc0204c76:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c78:	bf35                	j	ffffffffc0204bb4 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204c7a:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c7e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204c82:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c84:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204c86:	bfd9                	j	ffffffffc0204c5c <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204c88:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204c8a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204c8e:	01174463          	blt	a4,a7,ffffffffc0204c96 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204c92:	1a088e63          	beqz	a7,ffffffffc0204e4e <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204c96:	000a3603          	ld	a2,0(s4)
ffffffffc0204c9a:	46c1                	li	a3,16
ffffffffc0204c9c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204c9e:	2781                	sext.w	a5,a5
ffffffffc0204ca0:	876e                	mv	a4,s11
ffffffffc0204ca2:	85a6                	mv	a1,s1
ffffffffc0204ca4:	854a                	mv	a0,s2
ffffffffc0204ca6:	e37ff0ef          	jal	ra,ffffffffc0204adc <printnum>
            break;
ffffffffc0204caa:	bde1                	j	ffffffffc0204b82 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204cac:	000a2503          	lw	a0,0(s4)
ffffffffc0204cb0:	85a6                	mv	a1,s1
ffffffffc0204cb2:	0a21                	addi	s4,s4,8
ffffffffc0204cb4:	9902                	jalr	s2
            break;
ffffffffc0204cb6:	b5f1                	j	ffffffffc0204b82 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204cb8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204cba:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204cbe:	01174463          	blt	a4,a7,ffffffffc0204cc6 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204cc2:	18088163          	beqz	a7,ffffffffc0204e44 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204cc6:	000a3603          	ld	a2,0(s4)
ffffffffc0204cca:	46a9                	li	a3,10
ffffffffc0204ccc:	8a2e                	mv	s4,a1
ffffffffc0204cce:	bfc1                	j	ffffffffc0204c9e <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cd0:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204cd4:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cd6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204cd8:	bdf1                	j	ffffffffc0204bb4 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204cda:	85a6                	mv	a1,s1
ffffffffc0204cdc:	02500513          	li	a0,37
ffffffffc0204ce0:	9902                	jalr	s2
            break;
ffffffffc0204ce2:	b545                	j	ffffffffc0204b82 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204ce4:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204ce8:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cea:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204cec:	b5e1                	j	ffffffffc0204bb4 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204cee:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204cf0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204cf4:	01174463          	blt	a4,a7,ffffffffc0204cfc <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0204cf8:	14088163          	beqz	a7,ffffffffc0204e3a <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204cfc:	000a3603          	ld	a2,0(s4)
ffffffffc0204d00:	46a1                	li	a3,8
ffffffffc0204d02:	8a2e                	mv	s4,a1
ffffffffc0204d04:	bf69                	j	ffffffffc0204c9e <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204d06:	03000513          	li	a0,48
ffffffffc0204d0a:	85a6                	mv	a1,s1
ffffffffc0204d0c:	e03e                	sd	a5,0(sp)
ffffffffc0204d0e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204d10:	85a6                	mv	a1,s1
ffffffffc0204d12:	07800513          	li	a0,120
ffffffffc0204d16:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204d18:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204d1a:	6782                	ld	a5,0(sp)
ffffffffc0204d1c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204d1e:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204d22:	bfb5                	j	ffffffffc0204c9e <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204d24:	000a3403          	ld	s0,0(s4)
ffffffffc0204d28:	008a0713          	addi	a4,s4,8
ffffffffc0204d2c:	e03a                	sd	a4,0(sp)
ffffffffc0204d2e:	14040263          	beqz	s0,ffffffffc0204e72 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204d32:	0fb05763          	blez	s11,ffffffffc0204e20 <vprintfmt+0x2d8>
ffffffffc0204d36:	02d00693          	li	a3,45
ffffffffc0204d3a:	0cd79163          	bne	a5,a3,ffffffffc0204dfc <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d3e:	00044783          	lbu	a5,0(s0)
ffffffffc0204d42:	0007851b          	sext.w	a0,a5
ffffffffc0204d46:	cf85                	beqz	a5,ffffffffc0204d7e <vprintfmt+0x236>
ffffffffc0204d48:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204d4c:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d50:	000c4563          	bltz	s8,ffffffffc0204d5a <vprintfmt+0x212>
ffffffffc0204d54:	3c7d                	addiw	s8,s8,-1
ffffffffc0204d56:	036c0263          	beq	s8,s6,ffffffffc0204d7a <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204d5a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204d5c:	0e0c8e63          	beqz	s9,ffffffffc0204e58 <vprintfmt+0x310>
ffffffffc0204d60:	3781                	addiw	a5,a5,-32
ffffffffc0204d62:	0ef47b63          	bgeu	s0,a5,ffffffffc0204e58 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204d66:	03f00513          	li	a0,63
ffffffffc0204d6a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d6c:	000a4783          	lbu	a5,0(s4)
ffffffffc0204d70:	3dfd                	addiw	s11,s11,-1
ffffffffc0204d72:	0a05                	addi	s4,s4,1
ffffffffc0204d74:	0007851b          	sext.w	a0,a5
ffffffffc0204d78:	ffe1                	bnez	a5,ffffffffc0204d50 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204d7a:	01b05963          	blez	s11,ffffffffc0204d8c <vprintfmt+0x244>
ffffffffc0204d7e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204d80:	85a6                	mv	a1,s1
ffffffffc0204d82:	02000513          	li	a0,32
ffffffffc0204d86:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204d88:	fe0d9be3          	bnez	s11,ffffffffc0204d7e <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204d8c:	6a02                	ld	s4,0(sp)
ffffffffc0204d8e:	bbd5                	j	ffffffffc0204b82 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204d90:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204d92:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204d96:	01174463          	blt	a4,a7,ffffffffc0204d9e <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204d9a:	08088d63          	beqz	a7,ffffffffc0204e34 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204d9e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204da2:	0a044d63          	bltz	s0,ffffffffc0204e5c <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204da6:	8622                	mv	a2,s0
ffffffffc0204da8:	8a66                	mv	s4,s9
ffffffffc0204daa:	46a9                	li	a3,10
ffffffffc0204dac:	bdcd                	j	ffffffffc0204c9e <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204dae:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204db2:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204db4:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204db6:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204dba:	8fb5                	xor	a5,a5,a3
ffffffffc0204dbc:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204dc0:	02d74163          	blt	a4,a3,ffffffffc0204de2 <vprintfmt+0x29a>
ffffffffc0204dc4:	00369793          	slli	a5,a3,0x3
ffffffffc0204dc8:	97de                	add	a5,a5,s7
ffffffffc0204dca:	639c                	ld	a5,0(a5)
ffffffffc0204dcc:	cb99                	beqz	a5,ffffffffc0204de2 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204dce:	86be                	mv	a3,a5
ffffffffc0204dd0:	00000617          	auipc	a2,0x0
ffffffffc0204dd4:	13860613          	addi	a2,a2,312 # ffffffffc0204f08 <etext+0x28>
ffffffffc0204dd8:	85a6                	mv	a1,s1
ffffffffc0204dda:	854a                	mv	a0,s2
ffffffffc0204ddc:	0ce000ef          	jal	ra,ffffffffc0204eaa <printfmt>
ffffffffc0204de0:	b34d                	j	ffffffffc0204b82 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204de2:	00002617          	auipc	a2,0x2
ffffffffc0204de6:	fbe60613          	addi	a2,a2,-66 # ffffffffc0206da0 <default_pmm_manager+0x268>
ffffffffc0204dea:	85a6                	mv	a1,s1
ffffffffc0204dec:	854a                	mv	a0,s2
ffffffffc0204dee:	0bc000ef          	jal	ra,ffffffffc0204eaa <printfmt>
ffffffffc0204df2:	bb41                	j	ffffffffc0204b82 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204df4:	00002417          	auipc	s0,0x2
ffffffffc0204df8:	fa440413          	addi	s0,s0,-92 # ffffffffc0206d98 <default_pmm_manager+0x260>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204dfc:	85e2                	mv	a1,s8
ffffffffc0204dfe:	8522                	mv	a0,s0
ffffffffc0204e00:	e43e                	sd	a5,8(sp)
ffffffffc0204e02:	c2bff0ef          	jal	ra,ffffffffc0204a2c <strnlen>
ffffffffc0204e06:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204e0a:	01b05b63          	blez	s11,ffffffffc0204e20 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204e0e:	67a2                	ld	a5,8(sp)
ffffffffc0204e10:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204e14:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204e16:	85a6                	mv	a1,s1
ffffffffc0204e18:	8552                	mv	a0,s4
ffffffffc0204e1a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204e1c:	fe0d9ce3          	bnez	s11,ffffffffc0204e14 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e20:	00044783          	lbu	a5,0(s0)
ffffffffc0204e24:	00140a13          	addi	s4,s0,1
ffffffffc0204e28:	0007851b          	sext.w	a0,a5
ffffffffc0204e2c:	d3a5                	beqz	a5,ffffffffc0204d8c <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204e2e:	05e00413          	li	s0,94
ffffffffc0204e32:	bf39                	j	ffffffffc0204d50 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204e34:	000a2403          	lw	s0,0(s4)
ffffffffc0204e38:	b7ad                	j	ffffffffc0204da2 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204e3a:	000a6603          	lwu	a2,0(s4)
ffffffffc0204e3e:	46a1                	li	a3,8
ffffffffc0204e40:	8a2e                	mv	s4,a1
ffffffffc0204e42:	bdb1                	j	ffffffffc0204c9e <vprintfmt+0x156>
ffffffffc0204e44:	000a6603          	lwu	a2,0(s4)
ffffffffc0204e48:	46a9                	li	a3,10
ffffffffc0204e4a:	8a2e                	mv	s4,a1
ffffffffc0204e4c:	bd89                	j	ffffffffc0204c9e <vprintfmt+0x156>
ffffffffc0204e4e:	000a6603          	lwu	a2,0(s4)
ffffffffc0204e52:	46c1                	li	a3,16
ffffffffc0204e54:	8a2e                	mv	s4,a1
ffffffffc0204e56:	b5a1                	j	ffffffffc0204c9e <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204e58:	9902                	jalr	s2
ffffffffc0204e5a:	bf09                	j	ffffffffc0204d6c <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204e5c:	85a6                	mv	a1,s1
ffffffffc0204e5e:	02d00513          	li	a0,45
ffffffffc0204e62:	e03e                	sd	a5,0(sp)
ffffffffc0204e64:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204e66:	6782                	ld	a5,0(sp)
ffffffffc0204e68:	8a66                	mv	s4,s9
ffffffffc0204e6a:	40800633          	neg	a2,s0
ffffffffc0204e6e:	46a9                	li	a3,10
ffffffffc0204e70:	b53d                	j	ffffffffc0204c9e <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204e72:	03b05163          	blez	s11,ffffffffc0204e94 <vprintfmt+0x34c>
ffffffffc0204e76:	02d00693          	li	a3,45
ffffffffc0204e7a:	f6d79de3          	bne	a5,a3,ffffffffc0204df4 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204e7e:	00002417          	auipc	s0,0x2
ffffffffc0204e82:	f1a40413          	addi	s0,s0,-230 # ffffffffc0206d98 <default_pmm_manager+0x260>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e86:	02800793          	li	a5,40
ffffffffc0204e8a:	02800513          	li	a0,40
ffffffffc0204e8e:	00140a13          	addi	s4,s0,1
ffffffffc0204e92:	bd6d                	j	ffffffffc0204d4c <vprintfmt+0x204>
ffffffffc0204e94:	00002a17          	auipc	s4,0x2
ffffffffc0204e98:	f05a0a13          	addi	s4,s4,-251 # ffffffffc0206d99 <default_pmm_manager+0x261>
ffffffffc0204e9c:	02800513          	li	a0,40
ffffffffc0204ea0:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204ea4:	05e00413          	li	s0,94
ffffffffc0204ea8:	b565                	j	ffffffffc0204d50 <vprintfmt+0x208>

ffffffffc0204eaa <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204eaa:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204eac:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204eb0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204eb2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204eb4:	ec06                	sd	ra,24(sp)
ffffffffc0204eb6:	f83a                	sd	a4,48(sp)
ffffffffc0204eb8:	fc3e                	sd	a5,56(sp)
ffffffffc0204eba:	e0c2                	sd	a6,64(sp)
ffffffffc0204ebc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204ebe:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204ec0:	c89ff0ef          	jal	ra,ffffffffc0204b48 <vprintfmt>
}
ffffffffc0204ec4:	60e2                	ld	ra,24(sp)
ffffffffc0204ec6:	6161                	addi	sp,sp,80
ffffffffc0204ec8:	8082                	ret

ffffffffc0204eca <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204eca:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204ece:	2785                	addiw	a5,a5,1
ffffffffc0204ed0:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0204ed4:	02000793          	li	a5,32
ffffffffc0204ed8:	9f8d                	subw	a5,a5,a1
}
ffffffffc0204eda:	00f5553b          	srlw	a0,a0,a5
ffffffffc0204ede:	8082                	ret
