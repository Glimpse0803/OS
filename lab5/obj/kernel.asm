
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

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
ffffffffc0200032:	000a7517          	auipc	a0,0xa7
ffffffffc0200036:	3d650513          	addi	a0,a0,982 # ffffffffc02a7408 <buf>
ffffffffc020003a:	000b3617          	auipc	a2,0xb3
ffffffffc020003e:	92a60613          	addi	a2,a2,-1750 # ffffffffc02b2964 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	795050ef          	jal	ra,ffffffffc0205fde <memset>
    cons_init();                // init the console
ffffffffc020004e:	55c000ef          	jal	ra,ffffffffc02005aa <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	3be58593          	addi	a1,a1,958 # ffffffffc0206410 <etext+0x4>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	3d650513          	addi	a0,a0,982 # ffffffffc0206430 <etext+0x24>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	24e000ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	668010ef          	jal	ra,ffffffffc02016d2 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5ae000ef          	jal	ra,ffffffffc020061c <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5b8000ef          	jal	ra,ffffffffc020062a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	491020ef          	jal	ra,ffffffffc0202d06 <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	34b050ef          	jal	ra,ffffffffc0205bc4 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4a8000ef          	jal	ra,ffffffffc0200526 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	70c030ef          	jal	ra,ffffffffc020378e <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4d2000ef          	jal	ra,ffffffffc0200558 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	594000ef          	jal	ra,ffffffffc020061e <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	4cf050ef          	jal	ra,ffffffffc0205d5c <cpu_idle>

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
ffffffffc020009a:	512000ef          	jal	ra,ffffffffc02005ac <cons_putc>
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
ffffffffc02000c0:	7b5050ef          	jal	ra,ffffffffc0206074 <vprintfmt>
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
ffffffffc02000ce:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
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
ffffffffc02000f6:	77f050ef          	jal	ra,ffffffffc0206074 <vprintfmt>
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
ffffffffc0200102:	a16d                	j	ffffffffc02005ac <cons_putc>

ffffffffc0200104 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200104:	1101                	addi	sp,sp,-32
ffffffffc0200106:	e822                	sd	s0,16(sp)
ffffffffc0200108:	ec06                	sd	ra,24(sp)
ffffffffc020010a:	e426                	sd	s1,8(sp)
ffffffffc020010c:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020010e:	00054503          	lbu	a0,0(a0)
ffffffffc0200112:	c51d                	beqz	a0,ffffffffc0200140 <cputs+0x3c>
ffffffffc0200114:	0405                	addi	s0,s0,1
ffffffffc0200116:	4485                	li	s1,1
ffffffffc0200118:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011a:	492000ef          	jal	ra,ffffffffc02005ac <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020011e:	00044503          	lbu	a0,0(s0)
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	f96d                	bnez	a0,ffffffffc020011a <cputs+0x16>
    (*cnt) ++;
ffffffffc020012a:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020012e:	4529                	li	a0,10
ffffffffc0200130:	47c000ef          	jal	ra,ffffffffc02005ac <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200134:	60e2                	ld	ra,24(sp)
ffffffffc0200136:	8522                	mv	a0,s0
ffffffffc0200138:	6442                	ld	s0,16(sp)
ffffffffc020013a:	64a2                	ld	s1,8(sp)
ffffffffc020013c:	6105                	addi	sp,sp,32
ffffffffc020013e:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200140:	4405                	li	s0,1
ffffffffc0200142:	b7f5                	j	ffffffffc020012e <cputs+0x2a>

ffffffffc0200144 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200144:	1141                	addi	sp,sp,-16
ffffffffc0200146:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200148:	498000ef          	jal	ra,ffffffffc02005e0 <cons_getc>
ffffffffc020014c:	dd75                	beqz	a0,ffffffffc0200148 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020014e:	60a2                	ld	ra,8(sp)
ffffffffc0200150:	0141                	addi	sp,sp,16
ffffffffc0200152:	8082                	ret

ffffffffc0200154 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200154:	715d                	addi	sp,sp,-80
ffffffffc0200156:	e486                	sd	ra,72(sp)
ffffffffc0200158:	e0a6                	sd	s1,64(sp)
ffffffffc020015a:	fc4a                	sd	s2,56(sp)
ffffffffc020015c:	f84e                	sd	s3,48(sp)
ffffffffc020015e:	f452                	sd	s4,40(sp)
ffffffffc0200160:	f056                	sd	s5,32(sp)
ffffffffc0200162:	ec5a                	sd	s6,24(sp)
ffffffffc0200164:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0200166:	c901                	beqz	a0,ffffffffc0200176 <readline+0x22>
ffffffffc0200168:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020016a:	00006517          	auipc	a0,0x6
ffffffffc020016e:	2ce50513          	addi	a0,a0,718 # ffffffffc0206438 <etext+0x2c>
ffffffffc0200172:	f5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
readline(const char *prompt) {
ffffffffc0200176:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200178:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020017a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020017c:	4aa9                	li	s5,10
ffffffffc020017e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200180:	000a7b97          	auipc	s7,0xa7
ffffffffc0200184:	288b8b93          	addi	s7,s7,648 # ffffffffc02a7408 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200188:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020018c:	fb9ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc0200190:	00054a63          	bltz	a0,ffffffffc02001a4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200194:	00a95a63          	bge	s2,a0,ffffffffc02001a8 <readline+0x54>
ffffffffc0200198:	029a5263          	bge	s4,s1,ffffffffc02001bc <readline+0x68>
        c = getchar();
ffffffffc020019c:	fa9ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc02001a0:	fe055ae3          	bgez	a0,ffffffffc0200194 <readline+0x40>
            return NULL;
ffffffffc02001a4:	4501                	li	a0,0
ffffffffc02001a6:	a091                	j	ffffffffc02001ea <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02001a8:	03351463          	bne	a0,s3,ffffffffc02001d0 <readline+0x7c>
ffffffffc02001ac:	e8a9                	bnez	s1,ffffffffc02001fe <readline+0xaa>
        c = getchar();
ffffffffc02001ae:	f97ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc02001b2:	fe0549e3          	bltz	a0,ffffffffc02001a4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001b6:	fea959e3          	bge	s2,a0,ffffffffc02001a8 <readline+0x54>
ffffffffc02001ba:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001bc:	e42a                	sd	a0,8(sp)
ffffffffc02001be:	f45ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i ++] = c;
ffffffffc02001c2:	6522                	ld	a0,8(sp)
ffffffffc02001c4:	009b87b3          	add	a5,s7,s1
ffffffffc02001c8:	2485                	addiw	s1,s1,1
ffffffffc02001ca:	00a78023          	sb	a0,0(a5)
ffffffffc02001ce:	bf7d                	j	ffffffffc020018c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02001d0:	01550463          	beq	a0,s5,ffffffffc02001d8 <readline+0x84>
ffffffffc02001d4:	fb651ce3          	bne	a0,s6,ffffffffc020018c <readline+0x38>
            cputchar(c);
ffffffffc02001d8:	f2bff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i] = '\0';
ffffffffc02001dc:	000a7517          	auipc	a0,0xa7
ffffffffc02001e0:	22c50513          	addi	a0,a0,556 # ffffffffc02a7408 <buf>
ffffffffc02001e4:	94aa                	add	s1,s1,a0
ffffffffc02001e6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001ea:	60a6                	ld	ra,72(sp)
ffffffffc02001ec:	6486                	ld	s1,64(sp)
ffffffffc02001ee:	7962                	ld	s2,56(sp)
ffffffffc02001f0:	79c2                	ld	s3,48(sp)
ffffffffc02001f2:	7a22                	ld	s4,40(sp)
ffffffffc02001f4:	7a82                	ld	s5,32(sp)
ffffffffc02001f6:	6b62                	ld	s6,24(sp)
ffffffffc02001f8:	6bc2                	ld	s7,16(sp)
ffffffffc02001fa:	6161                	addi	sp,sp,80
ffffffffc02001fc:	8082                	ret
            cputchar(c);
ffffffffc02001fe:	4521                	li	a0,8
ffffffffc0200200:	f03ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            i --;
ffffffffc0200204:	34fd                	addiw	s1,s1,-1
ffffffffc0200206:	b759                	j	ffffffffc020018c <readline+0x38>

ffffffffc0200208 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200208:	000b2317          	auipc	t1,0xb2
ffffffffc020020c:	6c830313          	addi	t1,t1,1736 # ffffffffc02b28d0 <is_panic>
ffffffffc0200210:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200214:	715d                	addi	sp,sp,-80
ffffffffc0200216:	ec06                	sd	ra,24(sp)
ffffffffc0200218:	e822                	sd	s0,16(sp)
ffffffffc020021a:	f436                	sd	a3,40(sp)
ffffffffc020021c:	f83a                	sd	a4,48(sp)
ffffffffc020021e:	fc3e                	sd	a5,56(sp)
ffffffffc0200220:	e0c2                	sd	a6,64(sp)
ffffffffc0200222:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200224:	020e1a63          	bnez	t3,ffffffffc0200258 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200228:	4785                	li	a5,1
ffffffffc020022a:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020022e:	8432                	mv	s0,a2
ffffffffc0200230:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200232:	862e                	mv	a2,a1
ffffffffc0200234:	85aa                	mv	a1,a0
ffffffffc0200236:	00006517          	auipc	a0,0x6
ffffffffc020023a:	20a50513          	addi	a0,a0,522 # ffffffffc0206440 <etext+0x34>
    va_start(ap, fmt);
ffffffffc020023e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200240:	e8dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200244:	65a2                	ld	a1,8(sp)
ffffffffc0200246:	8522                	mv	a0,s0
ffffffffc0200248:	e65ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc020024c:	00007517          	auipc	a0,0x7
ffffffffc0200250:	fdc50513          	addi	a0,a0,-36 # ffffffffc0207228 <commands+0xb70>
ffffffffc0200254:	e79ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200258:	4501                	li	a0,0
ffffffffc020025a:	4581                	li	a1,0
ffffffffc020025c:	4601                	li	a2,0
ffffffffc020025e:	48a1                	li	a7,8
ffffffffc0200260:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200264:	3c0000ef          	jal	ra,ffffffffc0200624 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200268:	4501                	li	a0,0
ffffffffc020026a:	174000ef          	jal	ra,ffffffffc02003de <kmonitor>
    while (1) {
ffffffffc020026e:	bfed                	j	ffffffffc0200268 <__panic+0x60>

ffffffffc0200270 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200270:	715d                	addi	sp,sp,-80
ffffffffc0200272:	832e                	mv	t1,a1
ffffffffc0200274:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200276:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200278:	8432                	mv	s0,a2
ffffffffc020027a:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020027c:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc020027e:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200280:	00006517          	auipc	a0,0x6
ffffffffc0200284:	1e050513          	addi	a0,a0,480 # ffffffffc0206460 <etext+0x54>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200288:	ec06                	sd	ra,24(sp)
ffffffffc020028a:	f436                	sd	a3,40(sp)
ffffffffc020028c:	f83a                	sd	a4,48(sp)
ffffffffc020028e:	e0c2                	sd	a6,64(sp)
ffffffffc0200290:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200292:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200294:	e39ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200298:	65a2                	ld	a1,8(sp)
ffffffffc020029a:	8522                	mv	a0,s0
ffffffffc020029c:	e11ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc02002a0:	00007517          	auipc	a0,0x7
ffffffffc02002a4:	f8850513          	addi	a0,a0,-120 # ffffffffc0207228 <commands+0xb70>
ffffffffc02002a8:	e25ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    va_end(ap);
}
ffffffffc02002ac:	60e2                	ld	ra,24(sp)
ffffffffc02002ae:	6442                	ld	s0,16(sp)
ffffffffc02002b0:	6161                	addi	sp,sp,80
ffffffffc02002b2:	8082                	ret

ffffffffc02002b4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002b4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002b6:	00006517          	auipc	a0,0x6
ffffffffc02002ba:	1ca50513          	addi	a0,a0,458 # ffffffffc0206480 <etext+0x74>
void print_kerninfo(void) {
ffffffffc02002be:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002c0:	e0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002c4:	00000597          	auipc	a1,0x0
ffffffffc02002c8:	d6e58593          	addi	a1,a1,-658 # ffffffffc0200032 <kern_init>
ffffffffc02002cc:	00006517          	auipc	a0,0x6
ffffffffc02002d0:	1d450513          	addi	a0,a0,468 # ffffffffc02064a0 <etext+0x94>
ffffffffc02002d4:	df9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002d8:	00006597          	auipc	a1,0x6
ffffffffc02002dc:	13458593          	addi	a1,a1,308 # ffffffffc020640c <etext>
ffffffffc02002e0:	00006517          	auipc	a0,0x6
ffffffffc02002e4:	1e050513          	addi	a0,a0,480 # ffffffffc02064c0 <etext+0xb4>
ffffffffc02002e8:	de5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002ec:	000a7597          	auipc	a1,0xa7
ffffffffc02002f0:	11c58593          	addi	a1,a1,284 # ffffffffc02a7408 <buf>
ffffffffc02002f4:	00006517          	auipc	a0,0x6
ffffffffc02002f8:	1ec50513          	addi	a0,a0,492 # ffffffffc02064e0 <etext+0xd4>
ffffffffc02002fc:	dd1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200300:	000b2597          	auipc	a1,0xb2
ffffffffc0200304:	66458593          	addi	a1,a1,1636 # ffffffffc02b2964 <end>
ffffffffc0200308:	00006517          	auipc	a0,0x6
ffffffffc020030c:	1f850513          	addi	a0,a0,504 # ffffffffc0206500 <etext+0xf4>
ffffffffc0200310:	dbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200314:	000b3597          	auipc	a1,0xb3
ffffffffc0200318:	a4f58593          	addi	a1,a1,-1457 # ffffffffc02b2d63 <end+0x3ff>
ffffffffc020031c:	00000797          	auipc	a5,0x0
ffffffffc0200320:	d1678793          	addi	a5,a5,-746 # ffffffffc0200032 <kern_init>
ffffffffc0200324:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200328:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020032c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020032e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200332:	95be                	add	a1,a1,a5
ffffffffc0200334:	85a9                	srai	a1,a1,0xa
ffffffffc0200336:	00006517          	auipc	a0,0x6
ffffffffc020033a:	1ea50513          	addi	a0,a0,490 # ffffffffc0206520 <etext+0x114>
}
ffffffffc020033e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200340:	b371                	j	ffffffffc02000cc <cprintf>

ffffffffc0200342 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200342:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200344:	00006617          	auipc	a2,0x6
ffffffffc0200348:	20c60613          	addi	a2,a2,524 # ffffffffc0206550 <etext+0x144>
ffffffffc020034c:	04d00593          	li	a1,77
ffffffffc0200350:	00006517          	auipc	a0,0x6
ffffffffc0200354:	21850513          	addi	a0,a0,536 # ffffffffc0206568 <etext+0x15c>
void print_stackframe(void) {
ffffffffc0200358:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020035a:	eafff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020035e <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020035e:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200360:	00006617          	auipc	a2,0x6
ffffffffc0200364:	22060613          	addi	a2,a2,544 # ffffffffc0206580 <etext+0x174>
ffffffffc0200368:	00006597          	auipc	a1,0x6
ffffffffc020036c:	23858593          	addi	a1,a1,568 # ffffffffc02065a0 <etext+0x194>
ffffffffc0200370:	00006517          	auipc	a0,0x6
ffffffffc0200374:	23850513          	addi	a0,a0,568 # ffffffffc02065a8 <etext+0x19c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200378:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020037a:	d53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020037e:	00006617          	auipc	a2,0x6
ffffffffc0200382:	23a60613          	addi	a2,a2,570 # ffffffffc02065b8 <etext+0x1ac>
ffffffffc0200386:	00006597          	auipc	a1,0x6
ffffffffc020038a:	25a58593          	addi	a1,a1,602 # ffffffffc02065e0 <etext+0x1d4>
ffffffffc020038e:	00006517          	auipc	a0,0x6
ffffffffc0200392:	21a50513          	addi	a0,a0,538 # ffffffffc02065a8 <etext+0x19c>
ffffffffc0200396:	d37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020039a:	00006617          	auipc	a2,0x6
ffffffffc020039e:	25660613          	addi	a2,a2,598 # ffffffffc02065f0 <etext+0x1e4>
ffffffffc02003a2:	00006597          	auipc	a1,0x6
ffffffffc02003a6:	26e58593          	addi	a1,a1,622 # ffffffffc0206610 <etext+0x204>
ffffffffc02003aa:	00006517          	auipc	a0,0x6
ffffffffc02003ae:	1fe50513          	addi	a0,a0,510 # ffffffffc02065a8 <etext+0x19c>
ffffffffc02003b2:	d1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    }
    return 0;
}
ffffffffc02003b6:	60a2                	ld	ra,8(sp)
ffffffffc02003b8:	4501                	li	a0,0
ffffffffc02003ba:	0141                	addi	sp,sp,16
ffffffffc02003bc:	8082                	ret

ffffffffc02003be <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003be:	1141                	addi	sp,sp,-16
ffffffffc02003c0:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003c2:	ef3ff0ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>
    return 0;
}
ffffffffc02003c6:	60a2                	ld	ra,8(sp)
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	0141                	addi	sp,sp,16
ffffffffc02003cc:	8082                	ret

ffffffffc02003ce <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003ce:	1141                	addi	sp,sp,-16
ffffffffc02003d0:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003d2:	f71ff0ef          	jal	ra,ffffffffc0200342 <print_stackframe>
    return 0;
}
ffffffffc02003d6:	60a2                	ld	ra,8(sp)
ffffffffc02003d8:	4501                	li	a0,0
ffffffffc02003da:	0141                	addi	sp,sp,16
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003de:	7115                	addi	sp,sp,-224
ffffffffc02003e0:	ed5e                	sd	s7,152(sp)
ffffffffc02003e2:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003e4:	00006517          	auipc	a0,0x6
ffffffffc02003e8:	23c50513          	addi	a0,a0,572 # ffffffffc0206620 <etext+0x214>
kmonitor(struct trapframe *tf) {
ffffffffc02003ec:	ed86                	sd	ra,216(sp)
ffffffffc02003ee:	e9a2                	sd	s0,208(sp)
ffffffffc02003f0:	e5a6                	sd	s1,200(sp)
ffffffffc02003f2:	e1ca                	sd	s2,192(sp)
ffffffffc02003f4:	fd4e                	sd	s3,184(sp)
ffffffffc02003f6:	f952                	sd	s4,176(sp)
ffffffffc02003f8:	f556                	sd	s5,168(sp)
ffffffffc02003fa:	f15a                	sd	s6,160(sp)
ffffffffc02003fc:	e962                	sd	s8,144(sp)
ffffffffc02003fe:	e566                	sd	s9,136(sp)
ffffffffc0200400:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200402:	ccbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200406:	00006517          	auipc	a0,0x6
ffffffffc020040a:	24250513          	addi	a0,a0,578 # ffffffffc0206648 <etext+0x23c>
ffffffffc020040e:	cbfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200412:	000b8563          	beqz	s7,ffffffffc020041c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200416:	855e                	mv	a0,s7
ffffffffc0200418:	3fa000ef          	jal	ra,ffffffffc0200812 <print_trapframe>
ffffffffc020041c:	00006c17          	auipc	s8,0x6
ffffffffc0200420:	29cc0c13          	addi	s8,s8,668 # ffffffffc02066b8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200424:	00006917          	auipc	s2,0x6
ffffffffc0200428:	24c90913          	addi	s2,s2,588 # ffffffffc0206670 <etext+0x264>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042c:	00006497          	auipc	s1,0x6
ffffffffc0200430:	24c48493          	addi	s1,s1,588 # ffffffffc0206678 <etext+0x26c>
        if (argc == MAXARGS - 1) {
ffffffffc0200434:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	00006b17          	auipc	s6,0x6
ffffffffc020043a:	24ab0b13          	addi	s6,s6,586 # ffffffffc0206680 <etext+0x274>
        argv[argc ++] = buf;
ffffffffc020043e:	00006a17          	auipc	s4,0x6
ffffffffc0200442:	162a0a13          	addi	s4,s4,354 # ffffffffc02065a0 <etext+0x194>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200446:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200448:	854a                	mv	a0,s2
ffffffffc020044a:	d0bff0ef          	jal	ra,ffffffffc0200154 <readline>
ffffffffc020044e:	842a                	mv	s0,a0
ffffffffc0200450:	dd65                	beqz	a0,ffffffffc0200448 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200452:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200456:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	e1bd                	bnez	a1,ffffffffc02004be <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc020045a:	fe0c87e3          	beqz	s9,ffffffffc0200448 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020045e:	6582                	ld	a1,0(sp)
ffffffffc0200460:	00006d17          	auipc	s10,0x6
ffffffffc0200464:	258d0d13          	addi	s10,s10,600 # ffffffffc02066b8 <commands>
        argv[argc ++] = buf;
ffffffffc0200468:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020046a:	4401                	li	s0,0
ffffffffc020046c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020046e:	33d050ef          	jal	ra,ffffffffc0205faa <strcmp>
ffffffffc0200472:	c919                	beqz	a0,ffffffffc0200488 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200474:	2405                	addiw	s0,s0,1
ffffffffc0200476:	0b540063          	beq	s0,s5,ffffffffc0200516 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020047a:	000d3503          	ld	a0,0(s10)
ffffffffc020047e:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200480:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200482:	329050ef          	jal	ra,ffffffffc0205faa <strcmp>
ffffffffc0200486:	f57d                	bnez	a0,ffffffffc0200474 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200488:	00141793          	slli	a5,s0,0x1
ffffffffc020048c:	97a2                	add	a5,a5,s0
ffffffffc020048e:	078e                	slli	a5,a5,0x3
ffffffffc0200490:	97e2                	add	a5,a5,s8
ffffffffc0200492:	6b9c                	ld	a5,16(a5)
ffffffffc0200494:	865e                	mv	a2,s7
ffffffffc0200496:	002c                	addi	a1,sp,8
ffffffffc0200498:	fffc851b          	addiw	a0,s9,-1
ffffffffc020049c:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020049e:	fa0555e3          	bgez	a0,ffffffffc0200448 <kmonitor+0x6a>
}
ffffffffc02004a2:	60ee                	ld	ra,216(sp)
ffffffffc02004a4:	644e                	ld	s0,208(sp)
ffffffffc02004a6:	64ae                	ld	s1,200(sp)
ffffffffc02004a8:	690e                	ld	s2,192(sp)
ffffffffc02004aa:	79ea                	ld	s3,184(sp)
ffffffffc02004ac:	7a4a                	ld	s4,176(sp)
ffffffffc02004ae:	7aaa                	ld	s5,168(sp)
ffffffffc02004b0:	7b0a                	ld	s6,160(sp)
ffffffffc02004b2:	6bea                	ld	s7,152(sp)
ffffffffc02004b4:	6c4a                	ld	s8,144(sp)
ffffffffc02004b6:	6caa                	ld	s9,136(sp)
ffffffffc02004b8:	6d0a                	ld	s10,128(sp)
ffffffffc02004ba:	612d                	addi	sp,sp,224
ffffffffc02004bc:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004be:	8526                	mv	a0,s1
ffffffffc02004c0:	309050ef          	jal	ra,ffffffffc0205fc8 <strchr>
ffffffffc02004c4:	c901                	beqz	a0,ffffffffc02004d4 <kmonitor+0xf6>
ffffffffc02004c6:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02004ca:	00040023          	sb	zero,0(s0)
ffffffffc02004ce:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004d0:	d5c9                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc02004d2:	b7f5                	j	ffffffffc02004be <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02004d4:	00044783          	lbu	a5,0(s0)
ffffffffc02004d8:	d3c9                	beqz	a5,ffffffffc020045a <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02004da:	033c8963          	beq	s9,s3,ffffffffc020050c <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02004de:	003c9793          	slli	a5,s9,0x3
ffffffffc02004e2:	0118                	addi	a4,sp,128
ffffffffc02004e4:	97ba                	add	a5,a5,a4
ffffffffc02004e6:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004ea:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004ee:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f0:	e591                	bnez	a1,ffffffffc02004fc <kmonitor+0x11e>
ffffffffc02004f2:	b7b5                	j	ffffffffc020045e <kmonitor+0x80>
ffffffffc02004f4:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02004f8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fa:	d1a5                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc02004fc:	8526                	mv	a0,s1
ffffffffc02004fe:	2cb050ef          	jal	ra,ffffffffc0205fc8 <strchr>
ffffffffc0200502:	d96d                	beqz	a0,ffffffffc02004f4 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
ffffffffc0200508:	d9a9                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc020050a:	bf55                	j	ffffffffc02004be <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020050c:	45c1                	li	a1,16
ffffffffc020050e:	855a                	mv	a0,s6
ffffffffc0200510:	bbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0200514:	b7e9                	j	ffffffffc02004de <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200516:	6582                	ld	a1,0(sp)
ffffffffc0200518:	00006517          	auipc	a0,0x6
ffffffffc020051c:	18850513          	addi	a0,a0,392 # ffffffffc02066a0 <etext+0x294>
ffffffffc0200520:	badff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
ffffffffc0200524:	b715                	j	ffffffffc0200448 <kmonitor+0x6a>

ffffffffc0200526 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200526:	8082                	ret

ffffffffc0200528 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200528:	00253513          	sltiu	a0,a0,2
ffffffffc020052c:	8082                	ret

ffffffffc020052e <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020052e:	03800513          	li	a0,56
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <ide_write_secs>:
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200534:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200538:	000a7517          	auipc	a0,0xa7
ffffffffc020053c:	2d050513          	addi	a0,a0,720 # ffffffffc02a7808 <ide>
                   size_t nsecs) {
ffffffffc0200540:	1141                	addi	sp,sp,-16
ffffffffc0200542:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200544:	953e                	add	a0,a0,a5
ffffffffc0200546:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020054a:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020054c:	2a5050ef          	jal	ra,ffffffffc0205ff0 <memcpy>
    return 0;
}
ffffffffc0200550:	60a2                	ld	ra,8(sp)
ffffffffc0200552:	4501                	li	a0,0
ffffffffc0200554:	0141                	addi	sp,sp,16
ffffffffc0200556:	8082                	ret

ffffffffc0200558 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200558:	67e1                	lui	a5,0x18
ffffffffc020055a:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd570>
ffffffffc020055e:	000b2717          	auipc	a4,0xb2
ffffffffc0200562:	38f73123          	sd	a5,898(a4) # ffffffffc02b28e0 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200566:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020056a:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020056c:	953e                	add	a0,a0,a5
ffffffffc020056e:	4601                	li	a2,0
ffffffffc0200570:	4881                	li	a7,0
ffffffffc0200572:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200576:	02000793          	li	a5,32
ffffffffc020057a:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020057e:	00006517          	auipc	a0,0x6
ffffffffc0200582:	18250513          	addi	a0,a0,386 # ffffffffc0206700 <commands+0x48>
    ticks = 0;
ffffffffc0200586:	000b2797          	auipc	a5,0xb2
ffffffffc020058a:	3407b923          	sd	zero,850(a5) # ffffffffc02b28d8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020058e:	be3d                	j	ffffffffc02000cc <cprintf>

ffffffffc0200590 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200590:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200594:	000b2797          	auipc	a5,0xb2
ffffffffc0200598:	34c7b783          	ld	a5,844(a5) # ffffffffc02b28e0 <timebase>
ffffffffc020059c:	953e                	add	a0,a0,a5
ffffffffc020059e:	4581                	li	a1,0
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4881                	li	a7,0
ffffffffc02005a4:	00000073          	ecall
ffffffffc02005a8:	8082                	ret

ffffffffc02005aa <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005aa:	8082                	ret

ffffffffc02005ac <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005ac:	100027f3          	csrr	a5,sstatus
ffffffffc02005b0:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005b2:	0ff57513          	zext.b	a0,a0
ffffffffc02005b6:	e799                	bnez	a5,ffffffffc02005c4 <cons_putc+0x18>
ffffffffc02005b8:	4581                	li	a1,0
ffffffffc02005ba:	4601                	li	a2,0
ffffffffc02005bc:	4885                	li	a7,1
ffffffffc02005be:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005c2:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005c4:	1101                	addi	sp,sp,-32
ffffffffc02005c6:	ec06                	sd	ra,24(sp)
ffffffffc02005c8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005ca:	05a000ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc02005ce:	6522                	ld	a0,8(sp)
ffffffffc02005d0:	4581                	li	a1,0
ffffffffc02005d2:	4601                	li	a2,0
ffffffffc02005d4:	4885                	li	a7,1
ffffffffc02005d6:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005da:	60e2                	ld	ra,24(sp)
ffffffffc02005dc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005de:	a081                	j	ffffffffc020061e <intr_enable>

ffffffffc02005e0 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005e0:	100027f3          	csrr	a5,sstatus
ffffffffc02005e4:	8b89                	andi	a5,a5,2
ffffffffc02005e6:	eb89                	bnez	a5,ffffffffc02005f8 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005e8:	4501                	li	a0,0
ffffffffc02005ea:	4581                	li	a1,0
ffffffffc02005ec:	4601                	li	a2,0
ffffffffc02005ee:	4889                	li	a7,2
ffffffffc02005f0:	00000073          	ecall
ffffffffc02005f4:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005f6:	8082                	ret
int cons_getc(void) {
ffffffffc02005f8:	1101                	addi	sp,sp,-32
ffffffffc02005fa:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005fc:	028000ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0200600:	4501                	li	a0,0
ffffffffc0200602:	4581                	li	a1,0
ffffffffc0200604:	4601                	li	a2,0
ffffffffc0200606:	4889                	li	a7,2
ffffffffc0200608:	00000073          	ecall
ffffffffc020060c:	2501                	sext.w	a0,a0
ffffffffc020060e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200610:	00e000ef          	jal	ra,ffffffffc020061e <intr_enable>
}
ffffffffc0200614:	60e2                	ld	ra,24(sp)
ffffffffc0200616:	6522                	ld	a0,8(sp)
ffffffffc0200618:	6105                	addi	sp,sp,32
ffffffffc020061a:	8082                	ret

ffffffffc020061c <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020061c:	8082                	ret

ffffffffc020061e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020061e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200622:	8082                	ret

ffffffffc0200624 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200624:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200628:	8082                	ret

ffffffffc020062a <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020062a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020062e:	00000797          	auipc	a5,0x0
ffffffffc0200632:	65a78793          	addi	a5,a5,1626 # ffffffffc0200c88 <__alltraps>
ffffffffc0200636:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020063a:	000407b7          	lui	a5,0x40
ffffffffc020063e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200642:	8082                	ret

ffffffffc0200644 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200644:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200646:	1141                	addi	sp,sp,-16
ffffffffc0200648:	e022                	sd	s0,0(sp)
ffffffffc020064a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020064c:	00006517          	auipc	a0,0x6
ffffffffc0200650:	0d450513          	addi	a0,a0,212 # ffffffffc0206720 <commands+0x68>
void print_regs(struct pushregs* gpr) {
ffffffffc0200654:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200656:	a77ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020065a:	640c                	ld	a1,8(s0)
ffffffffc020065c:	00006517          	auipc	a0,0x6
ffffffffc0200660:	0dc50513          	addi	a0,a0,220 # ffffffffc0206738 <commands+0x80>
ffffffffc0200664:	a69ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200668:	680c                	ld	a1,16(s0)
ffffffffc020066a:	00006517          	auipc	a0,0x6
ffffffffc020066e:	0e650513          	addi	a0,a0,230 # ffffffffc0206750 <commands+0x98>
ffffffffc0200672:	a5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200676:	6c0c                	ld	a1,24(s0)
ffffffffc0200678:	00006517          	auipc	a0,0x6
ffffffffc020067c:	0f050513          	addi	a0,a0,240 # ffffffffc0206768 <commands+0xb0>
ffffffffc0200680:	a4dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200684:	700c                	ld	a1,32(s0)
ffffffffc0200686:	00006517          	auipc	a0,0x6
ffffffffc020068a:	0fa50513          	addi	a0,a0,250 # ffffffffc0206780 <commands+0xc8>
ffffffffc020068e:	a3fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200692:	740c                	ld	a1,40(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	10450513          	addi	a0,a0,260 # ffffffffc0206798 <commands+0xe0>
ffffffffc020069c:	a31ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006a0:	780c                	ld	a1,48(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	10e50513          	addi	a0,a0,270 # ffffffffc02067b0 <commands+0xf8>
ffffffffc02006aa:	a23ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006ae:	7c0c                	ld	a1,56(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	11850513          	addi	a0,a0,280 # ffffffffc02067c8 <commands+0x110>
ffffffffc02006b8:	a15ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006bc:	602c                	ld	a1,64(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	12250513          	addi	a0,a0,290 # ffffffffc02067e0 <commands+0x128>
ffffffffc02006c6:	a07ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ca:	642c                	ld	a1,72(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	12c50513          	addi	a0,a0,300 # ffffffffc02067f8 <commands+0x140>
ffffffffc02006d4:	9f9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006d8:	682c                	ld	a1,80(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	13650513          	addi	a0,a0,310 # ffffffffc0206810 <commands+0x158>
ffffffffc02006e2:	9ebff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006e6:	6c2c                	ld	a1,88(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	14050513          	addi	a0,a0,320 # ffffffffc0206828 <commands+0x170>
ffffffffc02006f0:	9ddff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02006f4:	702c                	ld	a1,96(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	14a50513          	addi	a0,a0,330 # ffffffffc0206840 <commands+0x188>
ffffffffc02006fe:	9cfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200702:	742c                	ld	a1,104(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	15450513          	addi	a0,a0,340 # ffffffffc0206858 <commands+0x1a0>
ffffffffc020070c:	9c1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200710:	782c                	ld	a1,112(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	15e50513          	addi	a0,a0,350 # ffffffffc0206870 <commands+0x1b8>
ffffffffc020071a:	9b3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020071e:	7c2c                	ld	a1,120(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	16850513          	addi	a0,a0,360 # ffffffffc0206888 <commands+0x1d0>
ffffffffc0200728:	9a5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020072c:	604c                	ld	a1,128(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	17250513          	addi	a0,a0,370 # ffffffffc02068a0 <commands+0x1e8>
ffffffffc0200736:	997ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020073a:	644c                	ld	a1,136(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	17c50513          	addi	a0,a0,380 # ffffffffc02068b8 <commands+0x200>
ffffffffc0200744:	989ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200748:	684c                	ld	a1,144(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	18650513          	addi	a0,a0,390 # ffffffffc02068d0 <commands+0x218>
ffffffffc0200752:	97bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200756:	6c4c                	ld	a1,152(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	19050513          	addi	a0,a0,400 # ffffffffc02068e8 <commands+0x230>
ffffffffc0200760:	96dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200764:	704c                	ld	a1,160(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	19a50513          	addi	a0,a0,410 # ffffffffc0206900 <commands+0x248>
ffffffffc020076e:	95fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200772:	744c                	ld	a1,168(s0)
ffffffffc0200774:	00006517          	auipc	a0,0x6
ffffffffc0200778:	1a450513          	addi	a0,a0,420 # ffffffffc0206918 <commands+0x260>
ffffffffc020077c:	951ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200780:	784c                	ld	a1,176(s0)
ffffffffc0200782:	00006517          	auipc	a0,0x6
ffffffffc0200786:	1ae50513          	addi	a0,a0,430 # ffffffffc0206930 <commands+0x278>
ffffffffc020078a:	943ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020078e:	7c4c                	ld	a1,184(s0)
ffffffffc0200790:	00006517          	auipc	a0,0x6
ffffffffc0200794:	1b850513          	addi	a0,a0,440 # ffffffffc0206948 <commands+0x290>
ffffffffc0200798:	935ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc020079c:	606c                	ld	a1,192(s0)
ffffffffc020079e:	00006517          	auipc	a0,0x6
ffffffffc02007a2:	1c250513          	addi	a0,a0,450 # ffffffffc0206960 <commands+0x2a8>
ffffffffc02007a6:	927ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007aa:	646c                	ld	a1,200(s0)
ffffffffc02007ac:	00006517          	auipc	a0,0x6
ffffffffc02007b0:	1cc50513          	addi	a0,a0,460 # ffffffffc0206978 <commands+0x2c0>
ffffffffc02007b4:	919ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007b8:	686c                	ld	a1,208(s0)
ffffffffc02007ba:	00006517          	auipc	a0,0x6
ffffffffc02007be:	1d650513          	addi	a0,a0,470 # ffffffffc0206990 <commands+0x2d8>
ffffffffc02007c2:	90bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007c6:	6c6c                	ld	a1,216(s0)
ffffffffc02007c8:	00006517          	auipc	a0,0x6
ffffffffc02007cc:	1e050513          	addi	a0,a0,480 # ffffffffc02069a8 <commands+0x2f0>
ffffffffc02007d0:	8fdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007d4:	706c                	ld	a1,224(s0)
ffffffffc02007d6:	00006517          	auipc	a0,0x6
ffffffffc02007da:	1ea50513          	addi	a0,a0,490 # ffffffffc02069c0 <commands+0x308>
ffffffffc02007de:	8efff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007e2:	746c                	ld	a1,232(s0)
ffffffffc02007e4:	00006517          	auipc	a0,0x6
ffffffffc02007e8:	1f450513          	addi	a0,a0,500 # ffffffffc02069d8 <commands+0x320>
ffffffffc02007ec:	8e1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02007f0:	786c                	ld	a1,240(s0)
ffffffffc02007f2:	00006517          	auipc	a0,0x6
ffffffffc02007f6:	1fe50513          	addi	a0,a0,510 # ffffffffc02069f0 <commands+0x338>
ffffffffc02007fa:	8d3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc02007fe:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200800:	6402                	ld	s0,0(sp)
ffffffffc0200802:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200804:	00006517          	auipc	a0,0x6
ffffffffc0200808:	20450513          	addi	a0,a0,516 # ffffffffc0206a08 <commands+0x350>
}
ffffffffc020080c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080e:	8bfff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200812 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200812:	1141                	addi	sp,sp,-16
ffffffffc0200814:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200816:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200818:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020081a:	00006517          	auipc	a0,0x6
ffffffffc020081e:	20650513          	addi	a0,a0,518 # ffffffffc0206a20 <commands+0x368>
print_trapframe(struct trapframe *tf) {
ffffffffc0200822:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200824:	8a9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200828:	8522                	mv	a0,s0
ffffffffc020082a:	e1bff0ef          	jal	ra,ffffffffc0200644 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020082e:	10043583          	ld	a1,256(s0)
ffffffffc0200832:	00006517          	auipc	a0,0x6
ffffffffc0200836:	20650513          	addi	a0,a0,518 # ffffffffc0206a38 <commands+0x380>
ffffffffc020083a:	893ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020083e:	10843583          	ld	a1,264(s0)
ffffffffc0200842:	00006517          	auipc	a0,0x6
ffffffffc0200846:	20e50513          	addi	a0,a0,526 # ffffffffc0206a50 <commands+0x398>
ffffffffc020084a:	883ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020084e:	11043583          	ld	a1,272(s0)
ffffffffc0200852:	00006517          	auipc	a0,0x6
ffffffffc0200856:	21650513          	addi	a0,a0,534 # ffffffffc0206a68 <commands+0x3b0>
ffffffffc020085a:	873ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020085e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200862:	6402                	ld	s0,0(sp)
ffffffffc0200864:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	21250513          	addi	a0,a0,530 # ffffffffc0206a78 <commands+0x3c0>
}
ffffffffc020086e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200870:	85dff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200874 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200874:	1101                	addi	sp,sp,-32
ffffffffc0200876:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200878:	000b2497          	auipc	s1,0xb2
ffffffffc020087c:	0a048493          	addi	s1,s1,160 # ffffffffc02b2918 <check_mm_struct>
ffffffffc0200880:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc0200882:	e822                	sd	s0,16(sp)
ffffffffc0200884:	ec06                	sd	ra,24(sp)
ffffffffc0200886:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200888:	cbad                	beqz	a5,ffffffffc02008fa <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020088a:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020088e:	11053583          	ld	a1,272(a0)
ffffffffc0200892:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200896:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020089a:	c7b1                	beqz	a5,ffffffffc02008e6 <pgfault_handler+0x72>
ffffffffc020089c:	11843703          	ld	a4,280(s0)
ffffffffc02008a0:	47bd                	li	a5,15
ffffffffc02008a2:	05700693          	li	a3,87
ffffffffc02008a6:	00f70463          	beq	a4,a5,ffffffffc02008ae <pgfault_handler+0x3a>
ffffffffc02008aa:	05200693          	li	a3,82
ffffffffc02008ae:	00006517          	auipc	a0,0x6
ffffffffc02008b2:	1e250513          	addi	a0,a0,482 # ffffffffc0206a90 <commands+0x3d8>
ffffffffc02008b6:	817ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008ba:	6088                	ld	a0,0(s1)
ffffffffc02008bc:	cd1d                	beqz	a0,ffffffffc02008fa <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008be:	000b2717          	auipc	a4,0xb2
ffffffffc02008c2:	08a73703          	ld	a4,138(a4) # ffffffffc02b2948 <current>
ffffffffc02008c6:	000b2797          	auipc	a5,0xb2
ffffffffc02008ca:	08a7b783          	ld	a5,138(a5) # ffffffffc02b2950 <idleproc>
ffffffffc02008ce:	04f71663          	bne	a4,a5,ffffffffc020091a <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008d2:	11043603          	ld	a2,272(s0)
ffffffffc02008d6:	11843583          	ld	a1,280(s0)
}
ffffffffc02008da:	6442                	ld	s0,16(sp)
ffffffffc02008dc:	60e2                	ld	ra,24(sp)
ffffffffc02008de:	64a2                	ld	s1,8(sp)
ffffffffc02008e0:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008e2:	1650206f          	j	ffffffffc0203246 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008e6:	11843703          	ld	a4,280(s0)
ffffffffc02008ea:	47bd                	li	a5,15
ffffffffc02008ec:	05500613          	li	a2,85
ffffffffc02008f0:	05700693          	li	a3,87
ffffffffc02008f4:	faf71be3          	bne	a4,a5,ffffffffc02008aa <pgfault_handler+0x36>
ffffffffc02008f8:	bf5d                	j	ffffffffc02008ae <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc02008fa:	000b2797          	auipc	a5,0xb2
ffffffffc02008fe:	04e7b783          	ld	a5,78(a5) # ffffffffc02b2948 <current>
ffffffffc0200902:	cf85                	beqz	a5,ffffffffc020093a <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200904:	11043603          	ld	a2,272(s0)
ffffffffc0200908:	11843583          	ld	a1,280(s0)
}
ffffffffc020090c:	6442                	ld	s0,16(sp)
ffffffffc020090e:	60e2                	ld	ra,24(sp)
ffffffffc0200910:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200912:	7788                	ld	a0,40(a5)
}
ffffffffc0200914:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200916:	1310206f          	j	ffffffffc0203246 <do_pgfault>
        assert(current == idleproc);
ffffffffc020091a:	00006697          	auipc	a3,0x6
ffffffffc020091e:	19668693          	addi	a3,a3,406 # ffffffffc0206ab0 <commands+0x3f8>
ffffffffc0200922:	00006617          	auipc	a2,0x6
ffffffffc0200926:	1a660613          	addi	a2,a2,422 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020092a:	06b00593          	li	a1,107
ffffffffc020092e:	00006517          	auipc	a0,0x6
ffffffffc0200932:	1b250513          	addi	a0,a0,434 # ffffffffc0206ae0 <commands+0x428>
ffffffffc0200936:	8d3ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc020093a:	8522                	mv	a0,s0
ffffffffc020093c:	ed7ff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200940:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200944:	11043583          	ld	a1,272(s0)
ffffffffc0200948:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020094c:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200950:	e399                	bnez	a5,ffffffffc0200956 <pgfault_handler+0xe2>
ffffffffc0200952:	05500613          	li	a2,85
ffffffffc0200956:	11843703          	ld	a4,280(s0)
ffffffffc020095a:	47bd                	li	a5,15
ffffffffc020095c:	02f70663          	beq	a4,a5,ffffffffc0200988 <pgfault_handler+0x114>
ffffffffc0200960:	05200693          	li	a3,82
ffffffffc0200964:	00006517          	auipc	a0,0x6
ffffffffc0200968:	12c50513          	addi	a0,a0,300 # ffffffffc0206a90 <commands+0x3d8>
ffffffffc020096c:	f60ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200970:	00006617          	auipc	a2,0x6
ffffffffc0200974:	18860613          	addi	a2,a2,392 # ffffffffc0206af8 <commands+0x440>
ffffffffc0200978:	07200593          	li	a1,114
ffffffffc020097c:	00006517          	auipc	a0,0x6
ffffffffc0200980:	16450513          	addi	a0,a0,356 # ffffffffc0206ae0 <commands+0x428>
ffffffffc0200984:	885ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200988:	05700693          	li	a3,87
ffffffffc020098c:	bfe1                	j	ffffffffc0200964 <pgfault_handler+0xf0>

ffffffffc020098e <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020098e:	11853783          	ld	a5,280(a0)
ffffffffc0200992:	472d                	li	a4,11
ffffffffc0200994:	0786                	slli	a5,a5,0x1
ffffffffc0200996:	8385                	srli	a5,a5,0x1
ffffffffc0200998:	08f76363          	bltu	a4,a5,ffffffffc0200a1e <interrupt_handler+0x90>
ffffffffc020099c:	00006717          	auipc	a4,0x6
ffffffffc02009a0:	21470713          	addi	a4,a4,532 # ffffffffc0206bb0 <commands+0x4f8>
ffffffffc02009a4:	078a                	slli	a5,a5,0x2
ffffffffc02009a6:	97ba                	add	a5,a5,a4
ffffffffc02009a8:	439c                	lw	a5,0(a5)
ffffffffc02009aa:	97ba                	add	a5,a5,a4
ffffffffc02009ac:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ae:	00006517          	auipc	a0,0x6
ffffffffc02009b2:	1c250513          	addi	a0,a0,450 # ffffffffc0206b70 <commands+0x4b8>
ffffffffc02009b6:	f16ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009ba:	00006517          	auipc	a0,0x6
ffffffffc02009be:	19650513          	addi	a0,a0,406 # ffffffffc0206b50 <commands+0x498>
ffffffffc02009c2:	f0aff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009c6:	00006517          	auipc	a0,0x6
ffffffffc02009ca:	14a50513          	addi	a0,a0,330 # ffffffffc0206b10 <commands+0x458>
ffffffffc02009ce:	efeff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009d2:	00006517          	auipc	a0,0x6
ffffffffc02009d6:	15e50513          	addi	a0,a0,350 # ffffffffc0206b30 <commands+0x478>
ffffffffc02009da:	ef2ff06f          	j	ffffffffc02000cc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02009de:	1141                	addi	sp,sp,-16
ffffffffc02009e0:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02009e2:	bafff0ef          	jal	ra,ffffffffc0200590 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc02009e6:	000b2697          	auipc	a3,0xb2
ffffffffc02009ea:	ef268693          	addi	a3,a3,-270 # ffffffffc02b28d8 <ticks>
ffffffffc02009ee:	629c                	ld	a5,0(a3)
ffffffffc02009f0:	06400713          	li	a4,100
ffffffffc02009f4:	0785                	addi	a5,a5,1
ffffffffc02009f6:	02e7f733          	remu	a4,a5,a4
ffffffffc02009fa:	e29c                	sd	a5,0(a3)
ffffffffc02009fc:	eb01                	bnez	a4,ffffffffc0200a0c <interrupt_handler+0x7e>
ffffffffc02009fe:	000b2797          	auipc	a5,0xb2
ffffffffc0200a02:	f4a7b783          	ld	a5,-182(a5) # ffffffffc02b2948 <current>
ffffffffc0200a06:	c399                	beqz	a5,ffffffffc0200a0c <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a08:	4705                	li	a4,1
ffffffffc0200a0a:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a0c:	60a2                	ld	ra,8(sp)
ffffffffc0200a0e:	0141                	addi	sp,sp,16
ffffffffc0200a10:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	17e50513          	addi	a0,a0,382 # ffffffffc0206b90 <commands+0x4d8>
ffffffffc0200a1a:	eb2ff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc0200a1e:	bbd5                	j	ffffffffc0200812 <print_trapframe>

ffffffffc0200a20 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a20:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a24:	1101                	addi	sp,sp,-32
ffffffffc0200a26:	e822                	sd	s0,16(sp)
ffffffffc0200a28:	ec06                	sd	ra,24(sp)
ffffffffc0200a2a:	e426                	sd	s1,8(sp)
ffffffffc0200a2c:	473d                	li	a4,15
ffffffffc0200a2e:	842a                	mv	s0,a0
ffffffffc0200a30:	18f76563          	bltu	a4,a5,ffffffffc0200bba <exception_handler+0x19a>
ffffffffc0200a34:	00006717          	auipc	a4,0x6
ffffffffc0200a38:	34470713          	addi	a4,a4,836 # ffffffffc0206d78 <commands+0x6c0>
ffffffffc0200a3c:	078a                	slli	a5,a5,0x2
ffffffffc0200a3e:	97ba                	add	a5,a5,a4
ffffffffc0200a40:	439c                	lw	a5,0(a5)
ffffffffc0200a42:	97ba                	add	a5,a5,a4
ffffffffc0200a44:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a46:	00006517          	auipc	a0,0x6
ffffffffc0200a4a:	28a50513          	addi	a0,a0,650 # ffffffffc0206cd0 <commands+0x618>
ffffffffc0200a4e:	e7eff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            tf->epc += 4;
ffffffffc0200a52:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a56:	60e2                	ld	ra,24(sp)
ffffffffc0200a58:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a5a:	0791                	addi	a5,a5,4
ffffffffc0200a5c:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a60:	6442                	ld	s0,16(sp)
ffffffffc0200a62:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a64:	47e0506f          	j	ffffffffc0205ee2 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a68:	00006517          	auipc	a0,0x6
ffffffffc0200a6c:	28850513          	addi	a0,a0,648 # ffffffffc0206cf0 <commands+0x638>
}
ffffffffc0200a70:	6442                	ld	s0,16(sp)
ffffffffc0200a72:	60e2                	ld	ra,24(sp)
ffffffffc0200a74:	64a2                	ld	s1,8(sp)
ffffffffc0200a76:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a78:	e54ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a7c:	00006517          	auipc	a0,0x6
ffffffffc0200a80:	29450513          	addi	a0,a0,660 # ffffffffc0206d10 <commands+0x658>
ffffffffc0200a84:	b7f5                	j	ffffffffc0200a70 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a86:	00006517          	auipc	a0,0x6
ffffffffc0200a8a:	2aa50513          	addi	a0,a0,682 # ffffffffc0206d30 <commands+0x678>
ffffffffc0200a8e:	b7cd                	j	ffffffffc0200a70 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a90:	00006517          	auipc	a0,0x6
ffffffffc0200a94:	2b850513          	addi	a0,a0,696 # ffffffffc0206d48 <commands+0x690>
ffffffffc0200a98:	e34ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a9c:	8522                	mv	a0,s0
ffffffffc0200a9e:	dd7ff0ef          	jal	ra,ffffffffc0200874 <pgfault_handler>
ffffffffc0200aa2:	84aa                	mv	s1,a0
ffffffffc0200aa4:	12051d63          	bnez	a0,ffffffffc0200bde <exception_handler+0x1be>
}
ffffffffc0200aa8:	60e2                	ld	ra,24(sp)
ffffffffc0200aaa:	6442                	ld	s0,16(sp)
ffffffffc0200aac:	64a2                	ld	s1,8(sp)
ffffffffc0200aae:	6105                	addi	sp,sp,32
ffffffffc0200ab0:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	2ae50513          	addi	a0,a0,686 # ffffffffc0206d60 <commands+0x6a8>
ffffffffc0200aba:	e12ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200abe:	8522                	mv	a0,s0
ffffffffc0200ac0:	db5ff0ef          	jal	ra,ffffffffc0200874 <pgfault_handler>
ffffffffc0200ac4:	84aa                	mv	s1,a0
ffffffffc0200ac6:	d16d                	beqz	a0,ffffffffc0200aa8 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ac8:	8522                	mv	a0,s0
ffffffffc0200aca:	d49ff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ace:	86a6                	mv	a3,s1
ffffffffc0200ad0:	00006617          	auipc	a2,0x6
ffffffffc0200ad4:	1b060613          	addi	a2,a2,432 # ffffffffc0206c80 <commands+0x5c8>
ffffffffc0200ad8:	0f800593          	li	a1,248
ffffffffc0200adc:	00006517          	auipc	a0,0x6
ffffffffc0200ae0:	00450513          	addi	a0,a0,4 # ffffffffc0206ae0 <commands+0x428>
ffffffffc0200ae4:	f24ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200ae8:	00006517          	auipc	a0,0x6
ffffffffc0200aec:	0f850513          	addi	a0,a0,248 # ffffffffc0206be0 <commands+0x528>
ffffffffc0200af0:	b741                	j	ffffffffc0200a70 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200af2:	00006517          	auipc	a0,0x6
ffffffffc0200af6:	10e50513          	addi	a0,a0,270 # ffffffffc0206c00 <commands+0x548>
ffffffffc0200afa:	bf9d                	j	ffffffffc0200a70 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200afc:	00006517          	auipc	a0,0x6
ffffffffc0200b00:	12450513          	addi	a0,a0,292 # ffffffffc0206c20 <commands+0x568>
ffffffffc0200b04:	b7b5                	j	ffffffffc0200a70 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b06:	00006517          	auipc	a0,0x6
ffffffffc0200b0a:	13250513          	addi	a0,a0,306 # ffffffffc0206c38 <commands+0x580>
ffffffffc0200b0e:	dbeff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b12:	6458                	ld	a4,136(s0)
ffffffffc0200b14:	47a9                	li	a5,10
ffffffffc0200b16:	f8f719e3          	bne	a4,a5,ffffffffc0200aa8 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b1a:	10843783          	ld	a5,264(s0)
ffffffffc0200b1e:	0791                	addi	a5,a5,4
ffffffffc0200b20:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b24:	3be050ef          	jal	ra,ffffffffc0205ee2 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b28:	000b2797          	auipc	a5,0xb2
ffffffffc0200b2c:	e207b783          	ld	a5,-480(a5) # ffffffffc02b2948 <current>
ffffffffc0200b30:	6b9c                	ld	a5,16(a5)
ffffffffc0200b32:	8522                	mv	a0,s0
}
ffffffffc0200b34:	6442                	ld	s0,16(sp)
ffffffffc0200b36:	60e2                	ld	ra,24(sp)
ffffffffc0200b38:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b3a:	6589                	lui	a1,0x2
ffffffffc0200b3c:	95be                	add	a1,a1,a5
}
ffffffffc0200b3e:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b40:	ac19                	j	ffffffffc0200d56 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b42:	00006517          	auipc	a0,0x6
ffffffffc0200b46:	10650513          	addi	a0,a0,262 # ffffffffc0206c48 <commands+0x590>
ffffffffc0200b4a:	b71d                	j	ffffffffc0200a70 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b4c:	00006517          	auipc	a0,0x6
ffffffffc0200b50:	11c50513          	addi	a0,a0,284 # ffffffffc0206c68 <commands+0x5b0>
ffffffffc0200b54:	d78ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b58:	8522                	mv	a0,s0
ffffffffc0200b5a:	d1bff0ef          	jal	ra,ffffffffc0200874 <pgfault_handler>
ffffffffc0200b5e:	84aa                	mv	s1,a0
ffffffffc0200b60:	d521                	beqz	a0,ffffffffc0200aa8 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b62:	8522                	mv	a0,s0
ffffffffc0200b64:	cafff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b68:	86a6                	mv	a3,s1
ffffffffc0200b6a:	00006617          	auipc	a2,0x6
ffffffffc0200b6e:	11660613          	addi	a2,a2,278 # ffffffffc0206c80 <commands+0x5c8>
ffffffffc0200b72:	0cd00593          	li	a1,205
ffffffffc0200b76:	00006517          	auipc	a0,0x6
ffffffffc0200b7a:	f6a50513          	addi	a0,a0,-150 # ffffffffc0206ae0 <commands+0x428>
ffffffffc0200b7e:	e8aff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200b82:	00006517          	auipc	a0,0x6
ffffffffc0200b86:	13650513          	addi	a0,a0,310 # ffffffffc0206cb8 <commands+0x600>
ffffffffc0200b8a:	d42ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b8e:	8522                	mv	a0,s0
ffffffffc0200b90:	ce5ff0ef          	jal	ra,ffffffffc0200874 <pgfault_handler>
ffffffffc0200b94:	84aa                	mv	s1,a0
ffffffffc0200b96:	f00509e3          	beqz	a0,ffffffffc0200aa8 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b9a:	8522                	mv	a0,s0
ffffffffc0200b9c:	c77ff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ba0:	86a6                	mv	a3,s1
ffffffffc0200ba2:	00006617          	auipc	a2,0x6
ffffffffc0200ba6:	0de60613          	addi	a2,a2,222 # ffffffffc0206c80 <commands+0x5c8>
ffffffffc0200baa:	0d700593          	li	a1,215
ffffffffc0200bae:	00006517          	auipc	a0,0x6
ffffffffc0200bb2:	f3250513          	addi	a0,a0,-206 # ffffffffc0206ae0 <commands+0x428>
ffffffffc0200bb6:	e52ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc0200bba:	8522                	mv	a0,s0
}
ffffffffc0200bbc:	6442                	ld	s0,16(sp)
ffffffffc0200bbe:	60e2                	ld	ra,24(sp)
ffffffffc0200bc0:	64a2                	ld	s1,8(sp)
ffffffffc0200bc2:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200bc4:	b1b9                	j	ffffffffc0200812 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bc6:	00006617          	auipc	a2,0x6
ffffffffc0200bca:	0da60613          	addi	a2,a2,218 # ffffffffc0206ca0 <commands+0x5e8>
ffffffffc0200bce:	0d100593          	li	a1,209
ffffffffc0200bd2:	00006517          	auipc	a0,0x6
ffffffffc0200bd6:	f0e50513          	addi	a0,a0,-242 # ffffffffc0206ae0 <commands+0x428>
ffffffffc0200bda:	e2eff0ef          	jal	ra,ffffffffc0200208 <__panic>
                print_trapframe(tf);
ffffffffc0200bde:	8522                	mv	a0,s0
ffffffffc0200be0:	c33ff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200be4:	86a6                	mv	a3,s1
ffffffffc0200be6:	00006617          	auipc	a2,0x6
ffffffffc0200bea:	09a60613          	addi	a2,a2,154 # ffffffffc0206c80 <commands+0x5c8>
ffffffffc0200bee:	0f100593          	li	a1,241
ffffffffc0200bf2:	00006517          	auipc	a0,0x6
ffffffffc0200bf6:	eee50513          	addi	a0,a0,-274 # ffffffffc0206ae0 <commands+0x428>
ffffffffc0200bfa:	e0eff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200bfe <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200bfe:	1101                	addi	sp,sp,-32
ffffffffc0200c00:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c02:	000b2417          	auipc	s0,0xb2
ffffffffc0200c06:	d4640413          	addi	s0,s0,-698 # ffffffffc02b2948 <current>
ffffffffc0200c0a:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c0c:	ec06                	sd	ra,24(sp)
ffffffffc0200c0e:	e426                	sd	s1,8(sp)
ffffffffc0200c10:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c12:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c16:	cf1d                	beqz	a4,ffffffffc0200c54 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c18:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c1c:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c20:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c22:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c26:	0206c463          	bltz	a3,ffffffffc0200c4e <trap+0x50>
        exception_handler(tf);
ffffffffc0200c2a:	df7ff0ef          	jal	ra,ffffffffc0200a20 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c2e:	601c                	ld	a5,0(s0)
ffffffffc0200c30:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c34:	e499                	bnez	s1,ffffffffc0200c42 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c36:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c3a:	8b05                	andi	a4,a4,1
ffffffffc0200c3c:	e329                	bnez	a4,ffffffffc0200c7e <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c3e:	6f9c                	ld	a5,24(a5)
ffffffffc0200c40:	eb85                	bnez	a5,ffffffffc0200c70 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c42:	60e2                	ld	ra,24(sp)
ffffffffc0200c44:	6442                	ld	s0,16(sp)
ffffffffc0200c46:	64a2                	ld	s1,8(sp)
ffffffffc0200c48:	6902                	ld	s2,0(sp)
ffffffffc0200c4a:	6105                	addi	sp,sp,32
ffffffffc0200c4c:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c4e:	d41ff0ef          	jal	ra,ffffffffc020098e <interrupt_handler>
ffffffffc0200c52:	bff1                	j	ffffffffc0200c2e <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c54:	0006c863          	bltz	a3,ffffffffc0200c64 <trap+0x66>
}
ffffffffc0200c58:	6442                	ld	s0,16(sp)
ffffffffc0200c5a:	60e2                	ld	ra,24(sp)
ffffffffc0200c5c:	64a2                	ld	s1,8(sp)
ffffffffc0200c5e:	6902                	ld	s2,0(sp)
ffffffffc0200c60:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c62:	bb7d                	j	ffffffffc0200a20 <exception_handler>
}
ffffffffc0200c64:	6442                	ld	s0,16(sp)
ffffffffc0200c66:	60e2                	ld	ra,24(sp)
ffffffffc0200c68:	64a2                	ld	s1,8(sp)
ffffffffc0200c6a:	6902                	ld	s2,0(sp)
ffffffffc0200c6c:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c6e:	b305                	j	ffffffffc020098e <interrupt_handler>
}
ffffffffc0200c70:	6442                	ld	s0,16(sp)
ffffffffc0200c72:	60e2                	ld	ra,24(sp)
ffffffffc0200c74:	64a2                	ld	s1,8(sp)
ffffffffc0200c76:	6902                	ld	s2,0(sp)
ffffffffc0200c78:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c7a:	17c0506f          	j	ffffffffc0205df6 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200c7e:	555d                	li	a0,-9
ffffffffc0200c80:	52a040ef          	jal	ra,ffffffffc02051aa <do_exit>
            if (current->need_resched) {
ffffffffc0200c84:	601c                	ld	a5,0(s0)
ffffffffc0200c86:	bf65                	j	ffffffffc0200c3e <trap+0x40>

ffffffffc0200c88 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200c88:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200c8c:	00011463          	bnez	sp,ffffffffc0200c94 <__alltraps+0xc>
ffffffffc0200c90:	14002173          	csrr	sp,sscratch
ffffffffc0200c94:	712d                	addi	sp,sp,-288
ffffffffc0200c96:	e002                	sd	zero,0(sp)
ffffffffc0200c98:	e406                	sd	ra,8(sp)
ffffffffc0200c9a:	ec0e                	sd	gp,24(sp)
ffffffffc0200c9c:	f012                	sd	tp,32(sp)
ffffffffc0200c9e:	f416                	sd	t0,40(sp)
ffffffffc0200ca0:	f81a                	sd	t1,48(sp)
ffffffffc0200ca2:	fc1e                	sd	t2,56(sp)
ffffffffc0200ca4:	e0a2                	sd	s0,64(sp)
ffffffffc0200ca6:	e4a6                	sd	s1,72(sp)
ffffffffc0200ca8:	e8aa                	sd	a0,80(sp)
ffffffffc0200caa:	ecae                	sd	a1,88(sp)
ffffffffc0200cac:	f0b2                	sd	a2,96(sp)
ffffffffc0200cae:	f4b6                	sd	a3,104(sp)
ffffffffc0200cb0:	f8ba                	sd	a4,112(sp)
ffffffffc0200cb2:	fcbe                	sd	a5,120(sp)
ffffffffc0200cb4:	e142                	sd	a6,128(sp)
ffffffffc0200cb6:	e546                	sd	a7,136(sp)
ffffffffc0200cb8:	e94a                	sd	s2,144(sp)
ffffffffc0200cba:	ed4e                	sd	s3,152(sp)
ffffffffc0200cbc:	f152                	sd	s4,160(sp)
ffffffffc0200cbe:	f556                	sd	s5,168(sp)
ffffffffc0200cc0:	f95a                	sd	s6,176(sp)
ffffffffc0200cc2:	fd5e                	sd	s7,184(sp)
ffffffffc0200cc4:	e1e2                	sd	s8,192(sp)
ffffffffc0200cc6:	e5e6                	sd	s9,200(sp)
ffffffffc0200cc8:	e9ea                	sd	s10,208(sp)
ffffffffc0200cca:	edee                	sd	s11,216(sp)
ffffffffc0200ccc:	f1f2                	sd	t3,224(sp)
ffffffffc0200cce:	f5f6                	sd	t4,232(sp)
ffffffffc0200cd0:	f9fa                	sd	t5,240(sp)
ffffffffc0200cd2:	fdfe                	sd	t6,248(sp)
ffffffffc0200cd4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cd8:	100024f3          	csrr	s1,sstatus
ffffffffc0200cdc:	14102973          	csrr	s2,sepc
ffffffffc0200ce0:	143029f3          	csrr	s3,stval
ffffffffc0200ce4:	14202a73          	csrr	s4,scause
ffffffffc0200ce8:	e822                	sd	s0,16(sp)
ffffffffc0200cea:	e226                	sd	s1,256(sp)
ffffffffc0200cec:	e64a                	sd	s2,264(sp)
ffffffffc0200cee:	ea4e                	sd	s3,272(sp)
ffffffffc0200cf0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200cf2:	850a                	mv	a0,sp
    jal trap
ffffffffc0200cf4:	f0bff0ef          	jal	ra,ffffffffc0200bfe <trap>

ffffffffc0200cf8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200cf8:	6492                	ld	s1,256(sp)
ffffffffc0200cfa:	6932                	ld	s2,264(sp)
ffffffffc0200cfc:	1004f413          	andi	s0,s1,256
ffffffffc0200d00:	e401                	bnez	s0,ffffffffc0200d08 <__trapret+0x10>
ffffffffc0200d02:	1200                	addi	s0,sp,288
ffffffffc0200d04:	14041073          	csrw	sscratch,s0
ffffffffc0200d08:	10049073          	csrw	sstatus,s1
ffffffffc0200d0c:	14191073          	csrw	sepc,s2
ffffffffc0200d10:	60a2                	ld	ra,8(sp)
ffffffffc0200d12:	61e2                	ld	gp,24(sp)
ffffffffc0200d14:	7202                	ld	tp,32(sp)
ffffffffc0200d16:	72a2                	ld	t0,40(sp)
ffffffffc0200d18:	7342                	ld	t1,48(sp)
ffffffffc0200d1a:	73e2                	ld	t2,56(sp)
ffffffffc0200d1c:	6406                	ld	s0,64(sp)
ffffffffc0200d1e:	64a6                	ld	s1,72(sp)
ffffffffc0200d20:	6546                	ld	a0,80(sp)
ffffffffc0200d22:	65e6                	ld	a1,88(sp)
ffffffffc0200d24:	7606                	ld	a2,96(sp)
ffffffffc0200d26:	76a6                	ld	a3,104(sp)
ffffffffc0200d28:	7746                	ld	a4,112(sp)
ffffffffc0200d2a:	77e6                	ld	a5,120(sp)
ffffffffc0200d2c:	680a                	ld	a6,128(sp)
ffffffffc0200d2e:	68aa                	ld	a7,136(sp)
ffffffffc0200d30:	694a                	ld	s2,144(sp)
ffffffffc0200d32:	69ea                	ld	s3,152(sp)
ffffffffc0200d34:	7a0a                	ld	s4,160(sp)
ffffffffc0200d36:	7aaa                	ld	s5,168(sp)
ffffffffc0200d38:	7b4a                	ld	s6,176(sp)
ffffffffc0200d3a:	7bea                	ld	s7,184(sp)
ffffffffc0200d3c:	6c0e                	ld	s8,192(sp)
ffffffffc0200d3e:	6cae                	ld	s9,200(sp)
ffffffffc0200d40:	6d4e                	ld	s10,208(sp)
ffffffffc0200d42:	6dee                	ld	s11,216(sp)
ffffffffc0200d44:	7e0e                	ld	t3,224(sp)
ffffffffc0200d46:	7eae                	ld	t4,232(sp)
ffffffffc0200d48:	7f4e                	ld	t5,240(sp)
ffffffffc0200d4a:	7fee                	ld	t6,248(sp)
ffffffffc0200d4c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d4e:	10200073          	sret

ffffffffc0200d52 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d52:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d54:	b755                	j	ffffffffc0200cf8 <__trapret>

ffffffffc0200d56 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d56:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7ce0>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d5a:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d5e:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d62:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d66:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d6a:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d6e:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d72:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d76:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d7a:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200d7c:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200d7e:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200d80:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200d82:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200d84:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200d86:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200d88:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200d8a:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200d8c:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200d8e:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200d90:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200d92:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200d94:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200d96:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200d98:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200d9a:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200d9c:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200d9e:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200da0:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200da2:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200da4:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200da6:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200da8:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200daa:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dac:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dae:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200db0:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200db2:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200db4:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200db6:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200db8:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dba:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200dbc:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dbe:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200dc0:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200dc2:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200dc4:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dc6:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dc8:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dca:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200dcc:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200dce:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200dd0:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200dd2:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200dd4:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dd6:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200dd8:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200dda:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200ddc:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200dde:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200de0:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200de2:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200de4:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200de6:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200de8:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200dea:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200dec:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200dee:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200df0:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200df2:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200df4:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200df6:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200df8:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200dfa:	812e                	mv	sp,a1
ffffffffc0200dfc:	bdf5                	j	ffffffffc0200cf8 <__trapret>

ffffffffc0200dfe <pa2page.part.0>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200dfe:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200e00:	00006617          	auipc	a2,0x6
ffffffffc0200e04:	fb860613          	addi	a2,a2,-72 # ffffffffc0206db8 <commands+0x700>
ffffffffc0200e08:	06200593          	li	a1,98
ffffffffc0200e0c:	00006517          	auipc	a0,0x6
ffffffffc0200e10:	fcc50513          	addi	a0,a0,-52 # ffffffffc0206dd8 <commands+0x720>
pa2page(uintptr_t pa) {
ffffffffc0200e14:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200e16:	bf2ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200e1a <pte2page.part.0>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
ffffffffc0200e1a:	1141                	addi	sp,sp,-16
    if (!(pte & PTE_V)) {
        panic("pte2page called with invalid pte");
ffffffffc0200e1c:	00006617          	auipc	a2,0x6
ffffffffc0200e20:	fcc60613          	addi	a2,a2,-52 # ffffffffc0206de8 <commands+0x730>
ffffffffc0200e24:	07400593          	li	a1,116
ffffffffc0200e28:	00006517          	auipc	a0,0x6
ffffffffc0200e2c:	fb050513          	addi	a0,a0,-80 # ffffffffc0206dd8 <commands+0x720>
pte2page(pte_t pte) {
ffffffffc0200e30:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0200e32:	bd6ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200e36 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200e36:	7139                	addi	sp,sp,-64
ffffffffc0200e38:	f426                	sd	s1,40(sp)
ffffffffc0200e3a:	f04a                	sd	s2,32(sp)
ffffffffc0200e3c:	ec4e                	sd	s3,24(sp)
ffffffffc0200e3e:	e852                	sd	s4,16(sp)
ffffffffc0200e40:	e456                	sd	s5,8(sp)
ffffffffc0200e42:	e05a                	sd	s6,0(sp)
ffffffffc0200e44:	fc06                	sd	ra,56(sp)
ffffffffc0200e46:	f822                	sd	s0,48(sp)
ffffffffc0200e48:	84aa                	mv	s1,a0
ffffffffc0200e4a:	000b2917          	auipc	s2,0xb2
ffffffffc0200e4e:	abe90913          	addi	s2,s2,-1346 # ffffffffc02b2908 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e52:	4a05                	li	s4,1
ffffffffc0200e54:	000b2a97          	auipc	s5,0xb2
ffffffffc0200e58:	aeca8a93          	addi	s5,s5,-1300 # ffffffffc02b2940 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e5c:	0005099b          	sext.w	s3,a0
ffffffffc0200e60:	000b2b17          	auipc	s6,0xb2
ffffffffc0200e64:	ab8b0b13          	addi	s6,s6,-1352 # ffffffffc02b2918 <check_mm_struct>
ffffffffc0200e68:	a01d                	j	ffffffffc0200e8e <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200e6a:	00093783          	ld	a5,0(s2)
ffffffffc0200e6e:	6f9c                	ld	a5,24(a5)
ffffffffc0200e70:	9782                	jalr	a5
ffffffffc0200e72:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e74:	4601                	li	a2,0
ffffffffc0200e76:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e78:	ec0d                	bnez	s0,ffffffffc0200eb2 <alloc_pages+0x7c>
ffffffffc0200e7a:	029a6c63          	bltu	s4,s1,ffffffffc0200eb2 <alloc_pages+0x7c>
ffffffffc0200e7e:	000aa783          	lw	a5,0(s5)
ffffffffc0200e82:	2781                	sext.w	a5,a5
ffffffffc0200e84:	c79d                	beqz	a5,ffffffffc0200eb2 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e86:	000b3503          	ld	a0,0(s6)
ffffffffc0200e8a:	062030ef          	jal	ra,ffffffffc0203eec <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e8e:	100027f3          	csrr	a5,sstatus
ffffffffc0200e92:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200e94:	8526                	mv	a0,s1
ffffffffc0200e96:	dbf1                	beqz	a5,ffffffffc0200e6a <alloc_pages+0x34>
        intr_disable();
ffffffffc0200e98:	f8cff0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0200e9c:	00093783          	ld	a5,0(s2)
ffffffffc0200ea0:	8526                	mv	a0,s1
ffffffffc0200ea2:	6f9c                	ld	a5,24(a5)
ffffffffc0200ea4:	9782                	jalr	a5
ffffffffc0200ea6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200ea8:	f76ff0ef          	jal	ra,ffffffffc020061e <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200eac:	4601                	li	a2,0
ffffffffc0200eae:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200eb0:	d469                	beqz	s0,ffffffffc0200e7a <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200eb2:	70e2                	ld	ra,56(sp)
ffffffffc0200eb4:	8522                	mv	a0,s0
ffffffffc0200eb6:	7442                	ld	s0,48(sp)
ffffffffc0200eb8:	74a2                	ld	s1,40(sp)
ffffffffc0200eba:	7902                	ld	s2,32(sp)
ffffffffc0200ebc:	69e2                	ld	s3,24(sp)
ffffffffc0200ebe:	6a42                	ld	s4,16(sp)
ffffffffc0200ec0:	6aa2                	ld	s5,8(sp)
ffffffffc0200ec2:	6b02                	ld	s6,0(sp)
ffffffffc0200ec4:	6121                	addi	sp,sp,64
ffffffffc0200ec6:	8082                	ret

ffffffffc0200ec8 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ec8:	100027f3          	csrr	a5,sstatus
ffffffffc0200ecc:	8b89                	andi	a5,a5,2
ffffffffc0200ece:	e799                	bnez	a5,ffffffffc0200edc <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200ed0:	000b2797          	auipc	a5,0xb2
ffffffffc0200ed4:	a387b783          	ld	a5,-1480(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc0200ed8:	739c                	ld	a5,32(a5)
ffffffffc0200eda:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200edc:	1101                	addi	sp,sp,-32
ffffffffc0200ede:	ec06                	sd	ra,24(sp)
ffffffffc0200ee0:	e822                	sd	s0,16(sp)
ffffffffc0200ee2:	e426                	sd	s1,8(sp)
ffffffffc0200ee4:	842a                	mv	s0,a0
ffffffffc0200ee6:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200ee8:	f3cff0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200eec:	000b2797          	auipc	a5,0xb2
ffffffffc0200ef0:	a1c7b783          	ld	a5,-1508(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc0200ef4:	739c                	ld	a5,32(a5)
ffffffffc0200ef6:	85a6                	mv	a1,s1
ffffffffc0200ef8:	8522                	mv	a0,s0
ffffffffc0200efa:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200efc:	6442                	ld	s0,16(sp)
ffffffffc0200efe:	60e2                	ld	ra,24(sp)
ffffffffc0200f00:	64a2                	ld	s1,8(sp)
ffffffffc0200f02:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f04:	f1aff06f          	j	ffffffffc020061e <intr_enable>

ffffffffc0200f08 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f08:	100027f3          	csrr	a5,sstatus
ffffffffc0200f0c:	8b89                	andi	a5,a5,2
ffffffffc0200f0e:	e799                	bnez	a5,ffffffffc0200f1c <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f10:	000b2797          	auipc	a5,0xb2
ffffffffc0200f14:	9f87b783          	ld	a5,-1544(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc0200f18:	779c                	ld	a5,40(a5)
ffffffffc0200f1a:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200f1c:	1141                	addi	sp,sp,-16
ffffffffc0200f1e:	e406                	sd	ra,8(sp)
ffffffffc0200f20:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200f22:	f02ff0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f26:	000b2797          	auipc	a5,0xb2
ffffffffc0200f2a:	9e27b783          	ld	a5,-1566(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc0200f2e:	779c                	ld	a5,40(a5)
ffffffffc0200f30:	9782                	jalr	a5
ffffffffc0200f32:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200f34:	eeaff0ef          	jal	ra,ffffffffc020061e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200f38:	60a2                	ld	ra,8(sp)
ffffffffc0200f3a:	8522                	mv	a0,s0
ffffffffc0200f3c:	6402                	ld	s0,0(sp)
ffffffffc0200f3e:	0141                	addi	sp,sp,16
ffffffffc0200f40:	8082                	ret

ffffffffc0200f42 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f42:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0200f46:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f4a:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f4c:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f4e:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f50:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f54:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f56:	f04a                	sd	s2,32(sp)
ffffffffc0200f58:	ec4e                	sd	s3,24(sp)
ffffffffc0200f5a:	e852                	sd	s4,16(sp)
ffffffffc0200f5c:	fc06                	sd	ra,56(sp)
ffffffffc0200f5e:	f822                	sd	s0,48(sp)
ffffffffc0200f60:	e456                	sd	s5,8(sp)
ffffffffc0200f62:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f64:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f68:	892e                	mv	s2,a1
ffffffffc0200f6a:	89b2                	mv	s3,a2
ffffffffc0200f6c:	000b2a17          	auipc	s4,0xb2
ffffffffc0200f70:	98ca0a13          	addi	s4,s4,-1652 # ffffffffc02b28f8 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f74:	e7b5                	bnez	a5,ffffffffc0200fe0 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200f76:	12060b63          	beqz	a2,ffffffffc02010ac <get_pte+0x16a>
ffffffffc0200f7a:	4505                	li	a0,1
ffffffffc0200f7c:	ebbff0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0200f80:	842a                	mv	s0,a0
ffffffffc0200f82:	12050563          	beqz	a0,ffffffffc02010ac <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200f86:	000b2b17          	auipc	s6,0xb2
ffffffffc0200f8a:	97ab0b13          	addi	s6,s6,-1670 # ffffffffc02b2900 <pages>
ffffffffc0200f8e:	000b3503          	ld	a0,0(s6)
ffffffffc0200f92:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200f96:	000b2a17          	auipc	s4,0xb2
ffffffffc0200f9a:	962a0a13          	addi	s4,s4,-1694 # ffffffffc02b28f8 <npage>
ffffffffc0200f9e:	40a40533          	sub	a0,s0,a0
ffffffffc0200fa2:	8519                	srai	a0,a0,0x6
ffffffffc0200fa4:	9556                	add	a0,a0,s5
ffffffffc0200fa6:	000a3703          	ld	a4,0(s4)
ffffffffc0200faa:	00c51793          	slli	a5,a0,0xc
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200fae:	4685                	li	a3,1
ffffffffc0200fb0:	c014                	sw	a3,0(s0)
ffffffffc0200fb2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fb4:	0532                	slli	a0,a0,0xc
ffffffffc0200fb6:	14e7f263          	bgeu	a5,a4,ffffffffc02010fa <get_pte+0x1b8>
ffffffffc0200fba:	000b2797          	auipc	a5,0xb2
ffffffffc0200fbe:	9567b783          	ld	a5,-1706(a5) # ffffffffc02b2910 <va_pa_offset>
ffffffffc0200fc2:	6605                	lui	a2,0x1
ffffffffc0200fc4:	4581                	li	a1,0
ffffffffc0200fc6:	953e                	add	a0,a0,a5
ffffffffc0200fc8:	016050ef          	jal	ra,ffffffffc0205fde <memset>
    return page - pages + nbase;
ffffffffc0200fcc:	000b3683          	ld	a3,0(s6)
ffffffffc0200fd0:	40d406b3          	sub	a3,s0,a3
ffffffffc0200fd4:	8699                	srai	a3,a3,0x6
ffffffffc0200fd6:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200fd8:	06aa                	slli	a3,a3,0xa
ffffffffc0200fda:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200fde:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200fe0:	77fd                	lui	a5,0xfffff
ffffffffc0200fe2:	068a                	slli	a3,a3,0x2
ffffffffc0200fe4:	000a3703          	ld	a4,0(s4)
ffffffffc0200fe8:	8efd                	and	a3,a3,a5
ffffffffc0200fea:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200fee:	0ce7f163          	bgeu	a5,a4,ffffffffc02010b0 <get_pte+0x16e>
ffffffffc0200ff2:	000b2a97          	auipc	s5,0xb2
ffffffffc0200ff6:	91ea8a93          	addi	s5,s5,-1762 # ffffffffc02b2910 <va_pa_offset>
ffffffffc0200ffa:	000ab403          	ld	s0,0(s5)
ffffffffc0200ffe:	01595793          	srli	a5,s2,0x15
ffffffffc0201002:	1ff7f793          	andi	a5,a5,511
ffffffffc0201006:	96a2                	add	a3,a3,s0
ffffffffc0201008:	00379413          	slli	s0,a5,0x3
ffffffffc020100c:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020100e:	6014                	ld	a3,0(s0)
ffffffffc0201010:	0016f793          	andi	a5,a3,1
ffffffffc0201014:	e3ad                	bnez	a5,ffffffffc0201076 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201016:	08098b63          	beqz	s3,ffffffffc02010ac <get_pte+0x16a>
ffffffffc020101a:	4505                	li	a0,1
ffffffffc020101c:	e1bff0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0201020:	84aa                	mv	s1,a0
ffffffffc0201022:	c549                	beqz	a0,ffffffffc02010ac <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201024:	000b2b17          	auipc	s6,0xb2
ffffffffc0201028:	8dcb0b13          	addi	s6,s6,-1828 # ffffffffc02b2900 <pages>
ffffffffc020102c:	000b3503          	ld	a0,0(s6)
ffffffffc0201030:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201034:	000a3703          	ld	a4,0(s4)
ffffffffc0201038:	40a48533          	sub	a0,s1,a0
ffffffffc020103c:	8519                	srai	a0,a0,0x6
ffffffffc020103e:	954e                	add	a0,a0,s3
ffffffffc0201040:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201044:	4685                	li	a3,1
ffffffffc0201046:	c094                	sw	a3,0(s1)
ffffffffc0201048:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020104a:	0532                	slli	a0,a0,0xc
ffffffffc020104c:	08e7fa63          	bgeu	a5,a4,ffffffffc02010e0 <get_pte+0x19e>
ffffffffc0201050:	000ab783          	ld	a5,0(s5)
ffffffffc0201054:	6605                	lui	a2,0x1
ffffffffc0201056:	4581                	li	a1,0
ffffffffc0201058:	953e                	add	a0,a0,a5
ffffffffc020105a:	785040ef          	jal	ra,ffffffffc0205fde <memset>
    return page - pages + nbase;
ffffffffc020105e:	000b3683          	ld	a3,0(s6)
ffffffffc0201062:	40d486b3          	sub	a3,s1,a3
ffffffffc0201066:	8699                	srai	a3,a3,0x6
ffffffffc0201068:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020106a:	06aa                	slli	a3,a3,0xa
ffffffffc020106c:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201070:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201072:	000a3703          	ld	a4,0(s4)
ffffffffc0201076:	068a                	slli	a3,a3,0x2
ffffffffc0201078:	757d                	lui	a0,0xfffff
ffffffffc020107a:	8ee9                	and	a3,a3,a0
ffffffffc020107c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201080:	04e7f463          	bgeu	a5,a4,ffffffffc02010c8 <get_pte+0x186>
ffffffffc0201084:	000ab503          	ld	a0,0(s5)
ffffffffc0201088:	00c95913          	srli	s2,s2,0xc
ffffffffc020108c:	1ff97913          	andi	s2,s2,511
ffffffffc0201090:	96aa                	add	a3,a3,a0
ffffffffc0201092:	00391513          	slli	a0,s2,0x3
ffffffffc0201096:	9536                	add	a0,a0,a3
}
ffffffffc0201098:	70e2                	ld	ra,56(sp)
ffffffffc020109a:	7442                	ld	s0,48(sp)
ffffffffc020109c:	74a2                	ld	s1,40(sp)
ffffffffc020109e:	7902                	ld	s2,32(sp)
ffffffffc02010a0:	69e2                	ld	s3,24(sp)
ffffffffc02010a2:	6a42                	ld	s4,16(sp)
ffffffffc02010a4:	6aa2                	ld	s5,8(sp)
ffffffffc02010a6:	6b02                	ld	s6,0(sp)
ffffffffc02010a8:	6121                	addi	sp,sp,64
ffffffffc02010aa:	8082                	ret
            return NULL;
ffffffffc02010ac:	4501                	li	a0,0
ffffffffc02010ae:	b7ed                	j	ffffffffc0201098 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02010b0:	00006617          	auipc	a2,0x6
ffffffffc02010b4:	d6060613          	addi	a2,a2,-672 # ffffffffc0206e10 <commands+0x758>
ffffffffc02010b8:	0e300593          	li	a1,227
ffffffffc02010bc:	00006517          	auipc	a0,0x6
ffffffffc02010c0:	d7c50513          	addi	a0,a0,-644 # ffffffffc0206e38 <commands+0x780>
ffffffffc02010c4:	944ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02010c8:	00006617          	auipc	a2,0x6
ffffffffc02010cc:	d4860613          	addi	a2,a2,-696 # ffffffffc0206e10 <commands+0x758>
ffffffffc02010d0:	0ee00593          	li	a1,238
ffffffffc02010d4:	00006517          	auipc	a0,0x6
ffffffffc02010d8:	d6450513          	addi	a0,a0,-668 # ffffffffc0206e38 <commands+0x780>
ffffffffc02010dc:	92cff0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02010e0:	86aa                	mv	a3,a0
ffffffffc02010e2:	00006617          	auipc	a2,0x6
ffffffffc02010e6:	d2e60613          	addi	a2,a2,-722 # ffffffffc0206e10 <commands+0x758>
ffffffffc02010ea:	0eb00593          	li	a1,235
ffffffffc02010ee:	00006517          	auipc	a0,0x6
ffffffffc02010f2:	d4a50513          	addi	a0,a0,-694 # ffffffffc0206e38 <commands+0x780>
ffffffffc02010f6:	912ff0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02010fa:	86aa                	mv	a3,a0
ffffffffc02010fc:	00006617          	auipc	a2,0x6
ffffffffc0201100:	d1460613          	addi	a2,a2,-748 # ffffffffc0206e10 <commands+0x758>
ffffffffc0201104:	0df00593          	li	a1,223
ffffffffc0201108:	00006517          	auipc	a0,0x6
ffffffffc020110c:	d3050513          	addi	a0,a0,-720 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201110:	8f8ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201114 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201114:	1141                	addi	sp,sp,-16
ffffffffc0201116:	e022                	sd	s0,0(sp)
ffffffffc0201118:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020111a:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020111c:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020111e:	e25ff0ef          	jal	ra,ffffffffc0200f42 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201122:	c011                	beqz	s0,ffffffffc0201126 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201124:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201126:	c511                	beqz	a0,ffffffffc0201132 <get_page+0x1e>
ffffffffc0201128:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020112a:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020112c:	0017f713          	andi	a4,a5,1
ffffffffc0201130:	e709                	bnez	a4,ffffffffc020113a <get_page+0x26>
}
ffffffffc0201132:	60a2                	ld	ra,8(sp)
ffffffffc0201134:	6402                	ld	s0,0(sp)
ffffffffc0201136:	0141                	addi	sp,sp,16
ffffffffc0201138:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020113a:	078a                	slli	a5,a5,0x2
ffffffffc020113c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020113e:	000b1717          	auipc	a4,0xb1
ffffffffc0201142:	7ba73703          	ld	a4,1978(a4) # ffffffffc02b28f8 <npage>
ffffffffc0201146:	00e7ff63          	bgeu	a5,a4,ffffffffc0201164 <get_page+0x50>
ffffffffc020114a:	60a2                	ld	ra,8(sp)
ffffffffc020114c:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc020114e:	fff80537          	lui	a0,0xfff80
ffffffffc0201152:	97aa                	add	a5,a5,a0
ffffffffc0201154:	079a                	slli	a5,a5,0x6
ffffffffc0201156:	000b1517          	auipc	a0,0xb1
ffffffffc020115a:	7aa53503          	ld	a0,1962(a0) # ffffffffc02b2900 <pages>
ffffffffc020115e:	953e                	add	a0,a0,a5
ffffffffc0201160:	0141                	addi	sp,sp,16
ffffffffc0201162:	8082                	ret
ffffffffc0201164:	c9bff0ef          	jal	ra,ffffffffc0200dfe <pa2page.part.0>

ffffffffc0201168 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201168:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020116a:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020116e:	f486                	sd	ra,104(sp)
ffffffffc0201170:	f0a2                	sd	s0,96(sp)
ffffffffc0201172:	eca6                	sd	s1,88(sp)
ffffffffc0201174:	e8ca                	sd	s2,80(sp)
ffffffffc0201176:	e4ce                	sd	s3,72(sp)
ffffffffc0201178:	e0d2                	sd	s4,64(sp)
ffffffffc020117a:	fc56                	sd	s5,56(sp)
ffffffffc020117c:	f85a                	sd	s6,48(sp)
ffffffffc020117e:	f45e                	sd	s7,40(sp)
ffffffffc0201180:	f062                	sd	s8,32(sp)
ffffffffc0201182:	ec66                	sd	s9,24(sp)
ffffffffc0201184:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201186:	17d2                	slli	a5,a5,0x34
ffffffffc0201188:	e3ed                	bnez	a5,ffffffffc020126a <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc020118a:	002007b7          	lui	a5,0x200
ffffffffc020118e:	842e                	mv	s0,a1
ffffffffc0201190:	0ef5ed63          	bltu	a1,a5,ffffffffc020128a <unmap_range+0x122>
ffffffffc0201194:	8932                	mv	s2,a2
ffffffffc0201196:	0ec5fa63          	bgeu	a1,a2,ffffffffc020128a <unmap_range+0x122>
ffffffffc020119a:	4785                	li	a5,1
ffffffffc020119c:	07fe                	slli	a5,a5,0x1f
ffffffffc020119e:	0ec7e663          	bltu	a5,a2,ffffffffc020128a <unmap_range+0x122>
ffffffffc02011a2:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02011a4:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02011a6:	000b1c97          	auipc	s9,0xb1
ffffffffc02011aa:	752c8c93          	addi	s9,s9,1874 # ffffffffc02b28f8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02011ae:	000b1c17          	auipc	s8,0xb1
ffffffffc02011b2:	752c0c13          	addi	s8,s8,1874 # ffffffffc02b2900 <pages>
ffffffffc02011b6:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc02011ba:	000b1d17          	auipc	s10,0xb1
ffffffffc02011be:	74ed0d13          	addi	s10,s10,1870 # ffffffffc02b2908 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02011c2:	00200b37          	lui	s6,0x200
ffffffffc02011c6:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02011ca:	4601                	li	a2,0
ffffffffc02011cc:	85a2                	mv	a1,s0
ffffffffc02011ce:	854e                	mv	a0,s3
ffffffffc02011d0:	d73ff0ef          	jal	ra,ffffffffc0200f42 <get_pte>
ffffffffc02011d4:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02011d6:	cd29                	beqz	a0,ffffffffc0201230 <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc02011d8:	611c                	ld	a5,0(a0)
ffffffffc02011da:	e395                	bnez	a5,ffffffffc02011fe <unmap_range+0x96>
        start += PGSIZE;
ffffffffc02011dc:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02011de:	ff2466e3          	bltu	s0,s2,ffffffffc02011ca <unmap_range+0x62>
}
ffffffffc02011e2:	70a6                	ld	ra,104(sp)
ffffffffc02011e4:	7406                	ld	s0,96(sp)
ffffffffc02011e6:	64e6                	ld	s1,88(sp)
ffffffffc02011e8:	6946                	ld	s2,80(sp)
ffffffffc02011ea:	69a6                	ld	s3,72(sp)
ffffffffc02011ec:	6a06                	ld	s4,64(sp)
ffffffffc02011ee:	7ae2                	ld	s5,56(sp)
ffffffffc02011f0:	7b42                	ld	s6,48(sp)
ffffffffc02011f2:	7ba2                	ld	s7,40(sp)
ffffffffc02011f4:	7c02                	ld	s8,32(sp)
ffffffffc02011f6:	6ce2                	ld	s9,24(sp)
ffffffffc02011f8:	6d42                	ld	s10,16(sp)
ffffffffc02011fa:	6165                	addi	sp,sp,112
ffffffffc02011fc:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02011fe:	0017f713          	andi	a4,a5,1
ffffffffc0201202:	df69                	beqz	a4,ffffffffc02011dc <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc0201204:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201208:	078a                	slli	a5,a5,0x2
ffffffffc020120a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020120c:	08e7ff63          	bgeu	a5,a4,ffffffffc02012aa <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0201210:	000c3503          	ld	a0,0(s8)
ffffffffc0201214:	97de                	add	a5,a5,s7
ffffffffc0201216:	079a                	slli	a5,a5,0x6
ffffffffc0201218:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020121a:	411c                	lw	a5,0(a0)
ffffffffc020121c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201220:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201222:	cf11                	beqz	a4,ffffffffc020123e <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201224:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201228:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020122c:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020122e:	bf45                	j	ffffffffc02011de <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201230:	945a                	add	s0,s0,s6
ffffffffc0201232:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0201236:	d455                	beqz	s0,ffffffffc02011e2 <unmap_range+0x7a>
ffffffffc0201238:	f92469e3          	bltu	s0,s2,ffffffffc02011ca <unmap_range+0x62>
ffffffffc020123c:	b75d                	j	ffffffffc02011e2 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020123e:	100027f3          	csrr	a5,sstatus
ffffffffc0201242:	8b89                	andi	a5,a5,2
ffffffffc0201244:	e799                	bnez	a5,ffffffffc0201252 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc0201246:	000d3783          	ld	a5,0(s10)
ffffffffc020124a:	4585                	li	a1,1
ffffffffc020124c:	739c                	ld	a5,32(a5)
ffffffffc020124e:	9782                	jalr	a5
    if (flag) {
ffffffffc0201250:	bfd1                	j	ffffffffc0201224 <unmap_range+0xbc>
ffffffffc0201252:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201254:	bd0ff0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0201258:	000d3783          	ld	a5,0(s10)
ffffffffc020125c:	6522                	ld	a0,8(sp)
ffffffffc020125e:	4585                	li	a1,1
ffffffffc0201260:	739c                	ld	a5,32(a5)
ffffffffc0201262:	9782                	jalr	a5
        intr_enable();
ffffffffc0201264:	bbaff0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0201268:	bf75                	j	ffffffffc0201224 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020126a:	00006697          	auipc	a3,0x6
ffffffffc020126e:	bde68693          	addi	a3,a3,-1058 # ffffffffc0206e48 <commands+0x790>
ffffffffc0201272:	00006617          	auipc	a2,0x6
ffffffffc0201276:	85660613          	addi	a2,a2,-1962 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020127a:	10f00593          	li	a1,271
ffffffffc020127e:	00006517          	auipc	a0,0x6
ffffffffc0201282:	bba50513          	addi	a0,a0,-1094 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201286:	f83fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020128a:	00006697          	auipc	a3,0x6
ffffffffc020128e:	bee68693          	addi	a3,a3,-1042 # ffffffffc0206e78 <commands+0x7c0>
ffffffffc0201292:	00006617          	auipc	a2,0x6
ffffffffc0201296:	83660613          	addi	a2,a2,-1994 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020129a:	11000593          	li	a1,272
ffffffffc020129e:	00006517          	auipc	a0,0x6
ffffffffc02012a2:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0206e38 <commands+0x780>
ffffffffc02012a6:	f63fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02012aa:	b55ff0ef          	jal	ra,ffffffffc0200dfe <pa2page.part.0>

ffffffffc02012ae <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02012ae:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012b0:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02012b4:	fc86                	sd	ra,120(sp)
ffffffffc02012b6:	f8a2                	sd	s0,112(sp)
ffffffffc02012b8:	f4a6                	sd	s1,104(sp)
ffffffffc02012ba:	f0ca                	sd	s2,96(sp)
ffffffffc02012bc:	ecce                	sd	s3,88(sp)
ffffffffc02012be:	e8d2                	sd	s4,80(sp)
ffffffffc02012c0:	e4d6                	sd	s5,72(sp)
ffffffffc02012c2:	e0da                	sd	s6,64(sp)
ffffffffc02012c4:	fc5e                	sd	s7,56(sp)
ffffffffc02012c6:	f862                	sd	s8,48(sp)
ffffffffc02012c8:	f466                	sd	s9,40(sp)
ffffffffc02012ca:	f06a                	sd	s10,32(sp)
ffffffffc02012cc:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012ce:	17d2                	slli	a5,a5,0x34
ffffffffc02012d0:	20079a63          	bnez	a5,ffffffffc02014e4 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc02012d4:	002007b7          	lui	a5,0x200
ffffffffc02012d8:	24f5e463          	bltu	a1,a5,ffffffffc0201520 <exit_range+0x272>
ffffffffc02012dc:	8ab2                	mv	s5,a2
ffffffffc02012de:	24c5f163          	bgeu	a1,a2,ffffffffc0201520 <exit_range+0x272>
ffffffffc02012e2:	4785                	li	a5,1
ffffffffc02012e4:	07fe                	slli	a5,a5,0x1f
ffffffffc02012e6:	22c7ed63          	bltu	a5,a2,ffffffffc0201520 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02012ea:	c00009b7          	lui	s3,0xc0000
ffffffffc02012ee:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02012f2:	ffe00937          	lui	s2,0xffe00
ffffffffc02012f6:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc02012fa:	5cfd                	li	s9,-1
ffffffffc02012fc:	8c2a                	mv	s8,a0
ffffffffc02012fe:	0125f933          	and	s2,a1,s2
ffffffffc0201302:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc0201304:	000b1d17          	auipc	s10,0xb1
ffffffffc0201308:	5f4d0d13          	addi	s10,s10,1524 # ffffffffc02b28f8 <npage>
    return KADDR(page2pa(page));
ffffffffc020130c:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0201310:	000b1717          	auipc	a4,0xb1
ffffffffc0201314:	5f070713          	addi	a4,a4,1520 # ffffffffc02b2900 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc0201318:	000b1d97          	auipc	s11,0xb1
ffffffffc020131c:	5f0d8d93          	addi	s11,s11,1520 # ffffffffc02b2908 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0201320:	c0000437          	lui	s0,0xc0000
ffffffffc0201324:	944e                	add	s0,s0,s3
ffffffffc0201326:	8079                	srli	s0,s0,0x1e
ffffffffc0201328:	1ff47413          	andi	s0,s0,511
ffffffffc020132c:	040e                	slli	s0,s0,0x3
ffffffffc020132e:	9462                	add	s0,s0,s8
ffffffffc0201330:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed0>
        if (pde1&PTE_V){
ffffffffc0201334:	001a7793          	andi	a5,s4,1
ffffffffc0201338:	eb99                	bnez	a5,ffffffffc020134e <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc020133a:	12098463          	beqz	s3,ffffffffc0201462 <exit_range+0x1b4>
ffffffffc020133e:	400007b7          	lui	a5,0x40000
ffffffffc0201342:	97ce                	add	a5,a5,s3
ffffffffc0201344:	894e                	mv	s2,s3
ffffffffc0201346:	1159fe63          	bgeu	s3,s5,ffffffffc0201462 <exit_range+0x1b4>
ffffffffc020134a:	89be                	mv	s3,a5
ffffffffc020134c:	bfd1                	j	ffffffffc0201320 <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc020134e:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201352:	0a0a                	slli	s4,s4,0x2
ffffffffc0201354:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201358:	1cfa7263          	bgeu	s4,a5,ffffffffc020151c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020135c:	fff80637          	lui	a2,0xfff80
ffffffffc0201360:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0201362:	000806b7          	lui	a3,0x80
ffffffffc0201366:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0201368:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc020136c:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020136e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201370:	18f5fa63          	bgeu	a1,a5,ffffffffc0201504 <exit_range+0x256>
ffffffffc0201374:	000b1817          	auipc	a6,0xb1
ffffffffc0201378:	59c80813          	addi	a6,a6,1436 # ffffffffc02b2910 <va_pa_offset>
ffffffffc020137c:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0201380:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0201382:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0201386:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0201388:	00080337          	lui	t1,0x80
ffffffffc020138c:	6885                	lui	a7,0x1
ffffffffc020138e:	a819                	j	ffffffffc02013a4 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0201390:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0201392:	002007b7          	lui	a5,0x200
ffffffffc0201396:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0201398:	08090c63          	beqz	s2,ffffffffc0201430 <exit_range+0x182>
ffffffffc020139c:	09397a63          	bgeu	s2,s3,ffffffffc0201430 <exit_range+0x182>
ffffffffc02013a0:	0f597063          	bgeu	s2,s5,ffffffffc0201480 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02013a4:	01595493          	srli	s1,s2,0x15
ffffffffc02013a8:	1ff4f493          	andi	s1,s1,511
ffffffffc02013ac:	048e                	slli	s1,s1,0x3
ffffffffc02013ae:	94da                	add	s1,s1,s6
ffffffffc02013b0:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc02013b2:	0017f693          	andi	a3,a5,1
ffffffffc02013b6:	dee9                	beqz	a3,ffffffffc0201390 <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc02013b8:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02013bc:	078a                	slli	a5,a5,0x2
ffffffffc02013be:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02013c0:	14b7fe63          	bgeu	a5,a1,ffffffffc020151c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02013c4:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc02013c6:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc02013ca:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02013ce:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02013d2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02013d4:	12bef863          	bgeu	t4,a1,ffffffffc0201504 <exit_range+0x256>
ffffffffc02013d8:	00083783          	ld	a5,0(a6)
ffffffffc02013dc:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02013de:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc02013e2:	629c                	ld	a5,0(a3)
ffffffffc02013e4:	8b85                	andi	a5,a5,1
ffffffffc02013e6:	f7d5                	bnez	a5,ffffffffc0201392 <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02013e8:	06a1                	addi	a3,a3,8
ffffffffc02013ea:	fed59ce3          	bne	a1,a3,ffffffffc02013e2 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc02013ee:	631c                	ld	a5,0(a4)
ffffffffc02013f0:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02013f2:	100027f3          	csrr	a5,sstatus
ffffffffc02013f6:	8b89                	andi	a5,a5,2
ffffffffc02013f8:	e7d9                	bnez	a5,ffffffffc0201486 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc02013fa:	000db783          	ld	a5,0(s11)
ffffffffc02013fe:	4585                	li	a1,1
ffffffffc0201400:	e032                	sd	a2,0(sp)
ffffffffc0201402:	739c                	ld	a5,32(a5)
ffffffffc0201404:	9782                	jalr	a5
    if (flag) {
ffffffffc0201406:	6602                	ld	a2,0(sp)
ffffffffc0201408:	000b1817          	auipc	a6,0xb1
ffffffffc020140c:	50880813          	addi	a6,a6,1288 # ffffffffc02b2910 <va_pa_offset>
ffffffffc0201410:	fff80e37          	lui	t3,0xfff80
ffffffffc0201414:	00080337          	lui	t1,0x80
ffffffffc0201418:	6885                	lui	a7,0x1
ffffffffc020141a:	000b1717          	auipc	a4,0xb1
ffffffffc020141e:	4e670713          	addi	a4,a4,1254 # ffffffffc02b2900 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0201422:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0201426:	002007b7          	lui	a5,0x200
ffffffffc020142a:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020142c:	f60918e3          	bnez	s2,ffffffffc020139c <exit_range+0xee>
            if (free_pd0) {
ffffffffc0201430:	f00b85e3          	beqz	s7,ffffffffc020133a <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc0201434:	000d3783          	ld	a5,0(s10)
ffffffffc0201438:	0efa7263          	bgeu	s4,a5,ffffffffc020151c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020143c:	6308                	ld	a0,0(a4)
ffffffffc020143e:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201440:	100027f3          	csrr	a5,sstatus
ffffffffc0201444:	8b89                	andi	a5,a5,2
ffffffffc0201446:	efad                	bnez	a5,ffffffffc02014c0 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc0201448:	000db783          	ld	a5,0(s11)
ffffffffc020144c:	4585                	li	a1,1
ffffffffc020144e:	739c                	ld	a5,32(a5)
ffffffffc0201450:	9782                	jalr	a5
ffffffffc0201452:	000b1717          	auipc	a4,0xb1
ffffffffc0201456:	4ae70713          	addi	a4,a4,1198 # ffffffffc02b2900 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020145a:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc020145e:	ee0990e3          	bnez	s3,ffffffffc020133e <exit_range+0x90>
}
ffffffffc0201462:	70e6                	ld	ra,120(sp)
ffffffffc0201464:	7446                	ld	s0,112(sp)
ffffffffc0201466:	74a6                	ld	s1,104(sp)
ffffffffc0201468:	7906                	ld	s2,96(sp)
ffffffffc020146a:	69e6                	ld	s3,88(sp)
ffffffffc020146c:	6a46                	ld	s4,80(sp)
ffffffffc020146e:	6aa6                	ld	s5,72(sp)
ffffffffc0201470:	6b06                	ld	s6,64(sp)
ffffffffc0201472:	7be2                	ld	s7,56(sp)
ffffffffc0201474:	7c42                	ld	s8,48(sp)
ffffffffc0201476:	7ca2                	ld	s9,40(sp)
ffffffffc0201478:	7d02                	ld	s10,32(sp)
ffffffffc020147a:	6de2                	ld	s11,24(sp)
ffffffffc020147c:	6109                	addi	sp,sp,128
ffffffffc020147e:	8082                	ret
            if (free_pd0) {
ffffffffc0201480:	ea0b8fe3          	beqz	s7,ffffffffc020133e <exit_range+0x90>
ffffffffc0201484:	bf45                	j	ffffffffc0201434 <exit_range+0x186>
ffffffffc0201486:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0201488:	e42a                	sd	a0,8(sp)
ffffffffc020148a:	99aff0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020148e:	000db783          	ld	a5,0(s11)
ffffffffc0201492:	6522                	ld	a0,8(sp)
ffffffffc0201494:	4585                	li	a1,1
ffffffffc0201496:	739c                	ld	a5,32(a5)
ffffffffc0201498:	9782                	jalr	a5
        intr_enable();
ffffffffc020149a:	984ff0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc020149e:	6602                	ld	a2,0(sp)
ffffffffc02014a0:	000b1717          	auipc	a4,0xb1
ffffffffc02014a4:	46070713          	addi	a4,a4,1120 # ffffffffc02b2900 <pages>
ffffffffc02014a8:	6885                	lui	a7,0x1
ffffffffc02014aa:	00080337          	lui	t1,0x80
ffffffffc02014ae:	fff80e37          	lui	t3,0xfff80
ffffffffc02014b2:	000b1817          	auipc	a6,0xb1
ffffffffc02014b6:	45e80813          	addi	a6,a6,1118 # ffffffffc02b2910 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02014ba:	0004b023          	sd	zero,0(s1)
ffffffffc02014be:	b7a5                	j	ffffffffc0201426 <exit_range+0x178>
ffffffffc02014c0:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc02014c2:	962ff0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02014c6:	000db783          	ld	a5,0(s11)
ffffffffc02014ca:	6502                	ld	a0,0(sp)
ffffffffc02014cc:	4585                	li	a1,1
ffffffffc02014ce:	739c                	ld	a5,32(a5)
ffffffffc02014d0:	9782                	jalr	a5
        intr_enable();
ffffffffc02014d2:	94cff0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc02014d6:	000b1717          	auipc	a4,0xb1
ffffffffc02014da:	42a70713          	addi	a4,a4,1066 # ffffffffc02b2900 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02014de:	00043023          	sd	zero,0(s0)
ffffffffc02014e2:	bfb5                	j	ffffffffc020145e <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02014e4:	00006697          	auipc	a3,0x6
ffffffffc02014e8:	96468693          	addi	a3,a3,-1692 # ffffffffc0206e48 <commands+0x790>
ffffffffc02014ec:	00005617          	auipc	a2,0x5
ffffffffc02014f0:	5dc60613          	addi	a2,a2,1500 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02014f4:	12000593          	li	a1,288
ffffffffc02014f8:	00006517          	auipc	a0,0x6
ffffffffc02014fc:	94050513          	addi	a0,a0,-1728 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201500:	d09fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201504:	00006617          	auipc	a2,0x6
ffffffffc0201508:	90c60613          	addi	a2,a2,-1780 # ffffffffc0206e10 <commands+0x758>
ffffffffc020150c:	06900593          	li	a1,105
ffffffffc0201510:	00006517          	auipc	a0,0x6
ffffffffc0201514:	8c850513          	addi	a0,a0,-1848 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0201518:	cf1fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020151c:	8e3ff0ef          	jal	ra,ffffffffc0200dfe <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0201520:	00006697          	auipc	a3,0x6
ffffffffc0201524:	95868693          	addi	a3,a3,-1704 # ffffffffc0206e78 <commands+0x7c0>
ffffffffc0201528:	00005617          	auipc	a2,0x5
ffffffffc020152c:	5a060613          	addi	a2,a2,1440 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201530:	12100593          	li	a1,289
ffffffffc0201534:	00006517          	auipc	a0,0x6
ffffffffc0201538:	90450513          	addi	a0,a0,-1788 # ffffffffc0206e38 <commands+0x780>
ffffffffc020153c:	ccdfe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201540 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201540:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201542:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201544:	ec26                	sd	s1,24(sp)
ffffffffc0201546:	f406                	sd	ra,40(sp)
ffffffffc0201548:	f022                	sd	s0,32(sp)
ffffffffc020154a:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020154c:	9f7ff0ef          	jal	ra,ffffffffc0200f42 <get_pte>
    if (ptep != NULL) {
ffffffffc0201550:	c511                	beqz	a0,ffffffffc020155c <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201552:	611c                	ld	a5,0(a0)
ffffffffc0201554:	842a                	mv	s0,a0
ffffffffc0201556:	0017f713          	andi	a4,a5,1
ffffffffc020155a:	e711                	bnez	a4,ffffffffc0201566 <page_remove+0x26>
}
ffffffffc020155c:	70a2                	ld	ra,40(sp)
ffffffffc020155e:	7402                	ld	s0,32(sp)
ffffffffc0201560:	64e2                	ld	s1,24(sp)
ffffffffc0201562:	6145                	addi	sp,sp,48
ffffffffc0201564:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201566:	078a                	slli	a5,a5,0x2
ffffffffc0201568:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020156a:	000b1717          	auipc	a4,0xb1
ffffffffc020156e:	38e73703          	ld	a4,910(a4) # ffffffffc02b28f8 <npage>
ffffffffc0201572:	06e7f363          	bgeu	a5,a4,ffffffffc02015d8 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0201576:	fff80537          	lui	a0,0xfff80
ffffffffc020157a:	97aa                	add	a5,a5,a0
ffffffffc020157c:	079a                	slli	a5,a5,0x6
ffffffffc020157e:	000b1517          	auipc	a0,0xb1
ffffffffc0201582:	38253503          	ld	a0,898(a0) # ffffffffc02b2900 <pages>
ffffffffc0201586:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201588:	411c                	lw	a5,0(a0)
ffffffffc020158a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020158e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201590:	cb11                	beqz	a4,ffffffffc02015a4 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201592:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201596:	12048073          	sfence.vma	s1
}
ffffffffc020159a:	70a2                	ld	ra,40(sp)
ffffffffc020159c:	7402                	ld	s0,32(sp)
ffffffffc020159e:	64e2                	ld	s1,24(sp)
ffffffffc02015a0:	6145                	addi	sp,sp,48
ffffffffc02015a2:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02015a4:	100027f3          	csrr	a5,sstatus
ffffffffc02015a8:	8b89                	andi	a5,a5,2
ffffffffc02015aa:	eb89                	bnez	a5,ffffffffc02015bc <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc02015ac:	000b1797          	auipc	a5,0xb1
ffffffffc02015b0:	35c7b783          	ld	a5,860(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc02015b4:	739c                	ld	a5,32(a5)
ffffffffc02015b6:	4585                	li	a1,1
ffffffffc02015b8:	9782                	jalr	a5
    if (flag) {
ffffffffc02015ba:	bfe1                	j	ffffffffc0201592 <page_remove+0x52>
        intr_disable();
ffffffffc02015bc:	e42a                	sd	a0,8(sp)
ffffffffc02015be:	866ff0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc02015c2:	000b1797          	auipc	a5,0xb1
ffffffffc02015c6:	3467b783          	ld	a5,838(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc02015ca:	739c                	ld	a5,32(a5)
ffffffffc02015cc:	6522                	ld	a0,8(sp)
ffffffffc02015ce:	4585                	li	a1,1
ffffffffc02015d0:	9782                	jalr	a5
        intr_enable();
ffffffffc02015d2:	84cff0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc02015d6:	bf75                	j	ffffffffc0201592 <page_remove+0x52>
ffffffffc02015d8:	827ff0ef          	jal	ra,ffffffffc0200dfe <pa2page.part.0>

ffffffffc02015dc <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02015dc:	7139                	addi	sp,sp,-64
ffffffffc02015de:	e852                	sd	s4,16(sp)
ffffffffc02015e0:	8a32                	mv	s4,a2
ffffffffc02015e2:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02015e4:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02015e6:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02015e8:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02015ea:	f426                	sd	s1,40(sp)
ffffffffc02015ec:	fc06                	sd	ra,56(sp)
ffffffffc02015ee:	f04a                	sd	s2,32(sp)
ffffffffc02015f0:	ec4e                	sd	s3,24(sp)
ffffffffc02015f2:	e456                	sd	s5,8(sp)
ffffffffc02015f4:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02015f6:	94dff0ef          	jal	ra,ffffffffc0200f42 <get_pte>
    if (ptep == NULL) {
ffffffffc02015fa:	c961                	beqz	a0,ffffffffc02016ca <page_insert+0xee>
    page->ref += 1;
ffffffffc02015fc:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc02015fe:	611c                	ld	a5,0(a0)
ffffffffc0201600:	89aa                	mv	s3,a0
ffffffffc0201602:	0016871b          	addiw	a4,a3,1
ffffffffc0201606:	c018                	sw	a4,0(s0)
ffffffffc0201608:	0017f713          	andi	a4,a5,1
ffffffffc020160c:	ef05                	bnez	a4,ffffffffc0201644 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc020160e:	000b1717          	auipc	a4,0xb1
ffffffffc0201612:	2f273703          	ld	a4,754(a4) # ffffffffc02b2900 <pages>
ffffffffc0201616:	8c19                	sub	s0,s0,a4
ffffffffc0201618:	000807b7          	lui	a5,0x80
ffffffffc020161c:	8419                	srai	s0,s0,0x6
ffffffffc020161e:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201620:	042a                	slli	s0,s0,0xa
ffffffffc0201622:	8cc1                	or	s1,s1,s0
ffffffffc0201624:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201628:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020162c:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0201630:	4501                	li	a0,0
}
ffffffffc0201632:	70e2                	ld	ra,56(sp)
ffffffffc0201634:	7442                	ld	s0,48(sp)
ffffffffc0201636:	74a2                	ld	s1,40(sp)
ffffffffc0201638:	7902                	ld	s2,32(sp)
ffffffffc020163a:	69e2                	ld	s3,24(sp)
ffffffffc020163c:	6a42                	ld	s4,16(sp)
ffffffffc020163e:	6aa2                	ld	s5,8(sp)
ffffffffc0201640:	6121                	addi	sp,sp,64
ffffffffc0201642:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201644:	078a                	slli	a5,a5,0x2
ffffffffc0201646:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201648:	000b1717          	auipc	a4,0xb1
ffffffffc020164c:	2b073703          	ld	a4,688(a4) # ffffffffc02b28f8 <npage>
ffffffffc0201650:	06e7ff63          	bgeu	a5,a4,ffffffffc02016ce <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0201654:	000b1a97          	auipc	s5,0xb1
ffffffffc0201658:	2aca8a93          	addi	s5,s5,684 # ffffffffc02b2900 <pages>
ffffffffc020165c:	000ab703          	ld	a4,0(s5)
ffffffffc0201660:	fff80937          	lui	s2,0xfff80
ffffffffc0201664:	993e                	add	s2,s2,a5
ffffffffc0201666:	091a                	slli	s2,s2,0x6
ffffffffc0201668:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc020166a:	01240c63          	beq	s0,s2,ffffffffc0201682 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc020166e:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd69c>
ffffffffc0201672:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201676:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc020167a:	c691                	beqz	a3,ffffffffc0201686 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020167c:	120a0073          	sfence.vma	s4
}
ffffffffc0201680:	bf59                	j	ffffffffc0201616 <page_insert+0x3a>
ffffffffc0201682:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201684:	bf49                	j	ffffffffc0201616 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201686:	100027f3          	csrr	a5,sstatus
ffffffffc020168a:	8b89                	andi	a5,a5,2
ffffffffc020168c:	ef91                	bnez	a5,ffffffffc02016a8 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc020168e:	000b1797          	auipc	a5,0xb1
ffffffffc0201692:	27a7b783          	ld	a5,634(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc0201696:	739c                	ld	a5,32(a5)
ffffffffc0201698:	4585                	li	a1,1
ffffffffc020169a:	854a                	mv	a0,s2
ffffffffc020169c:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020169e:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02016a2:	120a0073          	sfence.vma	s4
ffffffffc02016a6:	bf85                	j	ffffffffc0201616 <page_insert+0x3a>
        intr_disable();
ffffffffc02016a8:	f7dfe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02016ac:	000b1797          	auipc	a5,0xb1
ffffffffc02016b0:	25c7b783          	ld	a5,604(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc02016b4:	739c                	ld	a5,32(a5)
ffffffffc02016b6:	4585                	li	a1,1
ffffffffc02016b8:	854a                	mv	a0,s2
ffffffffc02016ba:	9782                	jalr	a5
        intr_enable();
ffffffffc02016bc:	f63fe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc02016c0:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02016c4:	120a0073          	sfence.vma	s4
ffffffffc02016c8:	b7b9                	j	ffffffffc0201616 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02016ca:	5571                	li	a0,-4
ffffffffc02016cc:	b79d                	j	ffffffffc0201632 <page_insert+0x56>
ffffffffc02016ce:	f30ff0ef          	jal	ra,ffffffffc0200dfe <pa2page.part.0>

ffffffffc02016d2 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02016d2:	00007797          	auipc	a5,0x7
ffffffffc02016d6:	a1678793          	addi	a5,a5,-1514 # ffffffffc02080e8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02016da:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc02016dc:	711d                	addi	sp,sp,-96
ffffffffc02016de:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02016e0:	00005517          	auipc	a0,0x5
ffffffffc02016e4:	7b050513          	addi	a0,a0,1968 # ffffffffc0206e90 <commands+0x7d8>
    pmm_manager = &default_pmm_manager;
ffffffffc02016e8:	000b1b97          	auipc	s7,0xb1
ffffffffc02016ec:	220b8b93          	addi	s7,s7,544 # ffffffffc02b2908 <pmm_manager>
void pmm_init(void) {
ffffffffc02016f0:	ec86                	sd	ra,88(sp)
ffffffffc02016f2:	e4a6                	sd	s1,72(sp)
ffffffffc02016f4:	fc4e                	sd	s3,56(sp)
ffffffffc02016f6:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02016f8:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc02016fc:	e8a2                	sd	s0,80(sp)
ffffffffc02016fe:	e0ca                	sd	s2,64(sp)
ffffffffc0201700:	f852                	sd	s4,48(sp)
ffffffffc0201702:	f456                	sd	s5,40(sp)
ffffffffc0201704:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201706:	9c7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc020170a:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020170e:	000b1997          	auipc	s3,0xb1
ffffffffc0201712:	20298993          	addi	s3,s3,514 # ffffffffc02b2910 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201716:	000b1497          	auipc	s1,0xb1
ffffffffc020171a:	1e248493          	addi	s1,s1,482 # ffffffffc02b28f8 <npage>
    pmm_manager->init();
ffffffffc020171e:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201720:	000b1b17          	auipc	s6,0xb1
ffffffffc0201724:	1e0b0b13          	addi	s6,s6,480 # ffffffffc02b2900 <pages>
    pmm_manager->init();
ffffffffc0201728:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020172a:	57f5                	li	a5,-3
ffffffffc020172c:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020172e:	00005517          	auipc	a0,0x5
ffffffffc0201732:	77a50513          	addi	a0,a0,1914 # ffffffffc0206ea8 <commands+0x7f0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201736:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc020173a:	993fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020173e:	46c5                	li	a3,17
ffffffffc0201740:	06ee                	slli	a3,a3,0x1b
ffffffffc0201742:	40100613          	li	a2,1025
ffffffffc0201746:	07e005b7          	lui	a1,0x7e00
ffffffffc020174a:	16fd                	addi	a3,a3,-1
ffffffffc020174c:	0656                	slli	a2,a2,0x15
ffffffffc020174e:	00005517          	auipc	a0,0x5
ffffffffc0201752:	77250513          	addi	a0,a0,1906 # ffffffffc0206ec0 <commands+0x808>
ffffffffc0201756:	977fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020175a:	777d                	lui	a4,0xfffff
ffffffffc020175c:	000b2797          	auipc	a5,0xb2
ffffffffc0201760:	20778793          	addi	a5,a5,519 # ffffffffc02b3963 <end+0xfff>
ffffffffc0201764:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201766:	00088737          	lui	a4,0x88
ffffffffc020176a:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020176c:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201770:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201772:	4585                	li	a1,1
ffffffffc0201774:	fff80837          	lui	a6,0xfff80
ffffffffc0201778:	a019                	j	ffffffffc020177e <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc020177a:	000b3783          	ld	a5,0(s6)
ffffffffc020177e:	00671693          	slli	a3,a4,0x6
ffffffffc0201782:	97b6                	add	a5,a5,a3
ffffffffc0201784:	07a1                	addi	a5,a5,8
ffffffffc0201786:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020178a:	6090                	ld	a2,0(s1)
ffffffffc020178c:	0705                	addi	a4,a4,1
ffffffffc020178e:	010607b3          	add	a5,a2,a6
ffffffffc0201792:	fef764e3          	bltu	a4,a5,ffffffffc020177a <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201796:	000b3503          	ld	a0,0(s6)
ffffffffc020179a:	079a                	slli	a5,a5,0x6
ffffffffc020179c:	c0200737          	lui	a4,0xc0200
ffffffffc02017a0:	00f506b3          	add	a3,a0,a5
ffffffffc02017a4:	60e6e563          	bltu	a3,a4,ffffffffc0201dae <pmm_init+0x6dc>
ffffffffc02017a8:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02017ac:	4745                	li	a4,17
ffffffffc02017ae:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02017b0:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02017b2:	4ae6e563          	bltu	a3,a4,ffffffffc0201c5c <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02017b6:	00005517          	auipc	a0,0x5
ffffffffc02017ba:	75a50513          	addi	a0,a0,1882 # ffffffffc0206f10 <commands+0x858>
ffffffffc02017be:	90ffe0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02017c2:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02017c6:	000b1917          	auipc	s2,0xb1
ffffffffc02017ca:	12a90913          	addi	s2,s2,298 # ffffffffc02b28f0 <boot_pgdir>
    pmm_manager->check();
ffffffffc02017ce:	7b9c                	ld	a5,48(a5)
ffffffffc02017d0:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02017d2:	00005517          	auipc	a0,0x5
ffffffffc02017d6:	75650513          	addi	a0,a0,1878 # ffffffffc0206f28 <commands+0x870>
ffffffffc02017da:	8f3fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02017de:	0000a697          	auipc	a3,0xa
ffffffffc02017e2:	82268693          	addi	a3,a3,-2014 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc02017e6:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02017ea:	c02007b7          	lui	a5,0xc0200
ffffffffc02017ee:	5cf6ec63          	bltu	a3,a5,ffffffffc0201dc6 <pmm_init+0x6f4>
ffffffffc02017f2:	0009b783          	ld	a5,0(s3)
ffffffffc02017f6:	8e9d                	sub	a3,a3,a5
ffffffffc02017f8:	000b1797          	auipc	a5,0xb1
ffffffffc02017fc:	0ed7b823          	sd	a3,240(a5) # ffffffffc02b28e8 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201800:	100027f3          	csrr	a5,sstatus
ffffffffc0201804:	8b89                	andi	a5,a5,2
ffffffffc0201806:	48079263          	bnez	a5,ffffffffc0201c8a <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc020180a:	000bb783          	ld	a5,0(s7)
ffffffffc020180e:	779c                	ld	a5,40(a5)
ffffffffc0201810:	9782                	jalr	a5
ffffffffc0201812:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201814:	6098                	ld	a4,0(s1)
ffffffffc0201816:	c80007b7          	lui	a5,0xc8000
ffffffffc020181a:	83b1                	srli	a5,a5,0xc
ffffffffc020181c:	5ee7e163          	bltu	a5,a4,ffffffffc0201dfe <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201820:	00093503          	ld	a0,0(s2)
ffffffffc0201824:	5a050d63          	beqz	a0,ffffffffc0201dde <pmm_init+0x70c>
ffffffffc0201828:	03451793          	slli	a5,a0,0x34
ffffffffc020182c:	5a079963          	bnez	a5,ffffffffc0201dde <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201830:	4601                	li	a2,0
ffffffffc0201832:	4581                	li	a1,0
ffffffffc0201834:	8e1ff0ef          	jal	ra,ffffffffc0201114 <get_page>
ffffffffc0201838:	62051563          	bnez	a0,ffffffffc0201e62 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc020183c:	4505                	li	a0,1
ffffffffc020183e:	df8ff0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0201842:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201844:	00093503          	ld	a0,0(s2)
ffffffffc0201848:	4681                	li	a3,0
ffffffffc020184a:	4601                	li	a2,0
ffffffffc020184c:	85d2                	mv	a1,s4
ffffffffc020184e:	d8fff0ef          	jal	ra,ffffffffc02015dc <page_insert>
ffffffffc0201852:	5e051863          	bnez	a0,ffffffffc0201e42 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201856:	00093503          	ld	a0,0(s2)
ffffffffc020185a:	4601                	li	a2,0
ffffffffc020185c:	4581                	li	a1,0
ffffffffc020185e:	ee4ff0ef          	jal	ra,ffffffffc0200f42 <get_pte>
ffffffffc0201862:	5c050063          	beqz	a0,ffffffffc0201e22 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0201866:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201868:	0017f713          	andi	a4,a5,1
ffffffffc020186c:	5a070963          	beqz	a4,ffffffffc0201e1e <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0201870:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201872:	078a                	slli	a5,a5,0x2
ffffffffc0201874:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201876:	52e7fa63          	bgeu	a5,a4,ffffffffc0201daa <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020187a:	000b3683          	ld	a3,0(s6)
ffffffffc020187e:	fff80637          	lui	a2,0xfff80
ffffffffc0201882:	97b2                	add	a5,a5,a2
ffffffffc0201884:	079a                	slli	a5,a5,0x6
ffffffffc0201886:	97b6                	add	a5,a5,a3
ffffffffc0201888:	10fa16e3          	bne	s4,a5,ffffffffc0202194 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc020188c:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0201890:	4785                	li	a5,1
ffffffffc0201892:	12f69de3          	bne	a3,a5,ffffffffc02021cc <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201896:	00093503          	ld	a0,0(s2)
ffffffffc020189a:	77fd                	lui	a5,0xfffff
ffffffffc020189c:	6114                	ld	a3,0(a0)
ffffffffc020189e:	068a                	slli	a3,a3,0x2
ffffffffc02018a0:	8efd                	and	a3,a3,a5
ffffffffc02018a2:	00c6d613          	srli	a2,a3,0xc
ffffffffc02018a6:	10e677e3          	bgeu	a2,a4,ffffffffc02021b4 <pmm_init+0xae2>
ffffffffc02018aa:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02018ae:	96e2                	add	a3,a3,s8
ffffffffc02018b0:	0006ba83          	ld	s5,0(a3)
ffffffffc02018b4:	0a8a                	slli	s5,s5,0x2
ffffffffc02018b6:	00fafab3          	and	s5,s5,a5
ffffffffc02018ba:	00cad793          	srli	a5,s5,0xc
ffffffffc02018be:	62e7f263          	bgeu	a5,a4,ffffffffc0201ee2 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02018c2:	4601                	li	a2,0
ffffffffc02018c4:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02018c6:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02018c8:	e7aff0ef          	jal	ra,ffffffffc0200f42 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02018cc:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02018ce:	5f551a63          	bne	a0,s5,ffffffffc0201ec2 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc02018d2:	4505                	li	a0,1
ffffffffc02018d4:	d62ff0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc02018d8:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02018da:	00093503          	ld	a0,0(s2)
ffffffffc02018de:	46d1                	li	a3,20
ffffffffc02018e0:	6605                	lui	a2,0x1
ffffffffc02018e2:	85d6                	mv	a1,s5
ffffffffc02018e4:	cf9ff0ef          	jal	ra,ffffffffc02015dc <page_insert>
ffffffffc02018e8:	58051d63          	bnez	a0,ffffffffc0201e82 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02018ec:	00093503          	ld	a0,0(s2)
ffffffffc02018f0:	4601                	li	a2,0
ffffffffc02018f2:	6585                	lui	a1,0x1
ffffffffc02018f4:	e4eff0ef          	jal	ra,ffffffffc0200f42 <get_pte>
ffffffffc02018f8:	0e050ae3          	beqz	a0,ffffffffc02021ec <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc02018fc:	611c                	ld	a5,0(a0)
ffffffffc02018fe:	0107f713          	andi	a4,a5,16
ffffffffc0201902:	6e070d63          	beqz	a4,ffffffffc0201ffc <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc0201906:	8b91                	andi	a5,a5,4
ffffffffc0201908:	6a078a63          	beqz	a5,ffffffffc0201fbc <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020190c:	00093503          	ld	a0,0(s2)
ffffffffc0201910:	611c                	ld	a5,0(a0)
ffffffffc0201912:	8bc1                	andi	a5,a5,16
ffffffffc0201914:	68078463          	beqz	a5,ffffffffc0201f9c <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc0201918:	000aa703          	lw	a4,0(s5)
ffffffffc020191c:	4785                	li	a5,1
ffffffffc020191e:	58f71263          	bne	a4,a5,ffffffffc0201ea2 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201922:	4681                	li	a3,0
ffffffffc0201924:	6605                	lui	a2,0x1
ffffffffc0201926:	85d2                	mv	a1,s4
ffffffffc0201928:	cb5ff0ef          	jal	ra,ffffffffc02015dc <page_insert>
ffffffffc020192c:	62051863          	bnez	a0,ffffffffc0201f5c <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc0201930:	000a2703          	lw	a4,0(s4)
ffffffffc0201934:	4789                	li	a5,2
ffffffffc0201936:	60f71363          	bne	a4,a5,ffffffffc0201f3c <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc020193a:	000aa783          	lw	a5,0(s5)
ffffffffc020193e:	5c079f63          	bnez	a5,ffffffffc0201f1c <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201942:	00093503          	ld	a0,0(s2)
ffffffffc0201946:	4601                	li	a2,0
ffffffffc0201948:	6585                	lui	a1,0x1
ffffffffc020194a:	df8ff0ef          	jal	ra,ffffffffc0200f42 <get_pte>
ffffffffc020194e:	5a050763          	beqz	a0,ffffffffc0201efc <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc0201952:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201954:	00177793          	andi	a5,a4,1
ffffffffc0201958:	4c078363          	beqz	a5,ffffffffc0201e1e <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc020195c:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020195e:	00271793          	slli	a5,a4,0x2
ffffffffc0201962:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201964:	44d7f363          	bgeu	a5,a3,ffffffffc0201daa <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201968:	000b3683          	ld	a3,0(s6)
ffffffffc020196c:	fff80637          	lui	a2,0xfff80
ffffffffc0201970:	97b2                	add	a5,a5,a2
ffffffffc0201972:	079a                	slli	a5,a5,0x6
ffffffffc0201974:	97b6                	add	a5,a5,a3
ffffffffc0201976:	6efa1363          	bne	s4,a5,ffffffffc020205c <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc020197a:	8b41                	andi	a4,a4,16
ffffffffc020197c:	6c071063          	bnez	a4,ffffffffc020203c <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201980:	00093503          	ld	a0,0(s2)
ffffffffc0201984:	4581                	li	a1,0
ffffffffc0201986:	bbbff0ef          	jal	ra,ffffffffc0201540 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020198a:	000a2703          	lw	a4,0(s4)
ffffffffc020198e:	4785                	li	a5,1
ffffffffc0201990:	68f71663          	bne	a4,a5,ffffffffc020201c <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0201994:	000aa783          	lw	a5,0(s5)
ffffffffc0201998:	74079e63          	bnez	a5,ffffffffc02020f4 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020199c:	00093503          	ld	a0,0(s2)
ffffffffc02019a0:	6585                	lui	a1,0x1
ffffffffc02019a2:	b9fff0ef          	jal	ra,ffffffffc0201540 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02019a6:	000a2783          	lw	a5,0(s4)
ffffffffc02019aa:	72079563          	bnez	a5,ffffffffc02020d4 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc02019ae:	000aa783          	lw	a5,0(s5)
ffffffffc02019b2:	70079163          	bnez	a5,ffffffffc02020b4 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02019b6:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02019ba:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02019bc:	000a3683          	ld	a3,0(s4)
ffffffffc02019c0:	068a                	slli	a3,a3,0x2
ffffffffc02019c2:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019c4:	3ee6f363          	bgeu	a3,a4,ffffffffc0201daa <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02019c8:	fff807b7          	lui	a5,0xfff80
ffffffffc02019cc:	000b3503          	ld	a0,0(s6)
ffffffffc02019d0:	96be                	add	a3,a3,a5
ffffffffc02019d2:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc02019d4:	00d507b3          	add	a5,a0,a3
ffffffffc02019d8:	4390                	lw	a2,0(a5)
ffffffffc02019da:	4785                	li	a5,1
ffffffffc02019dc:	6af61c63          	bne	a2,a5,ffffffffc0202094 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc02019e0:	8699                	srai	a3,a3,0x6
ffffffffc02019e2:	000805b7          	lui	a1,0x80
ffffffffc02019e6:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02019e8:	00c69613          	slli	a2,a3,0xc
ffffffffc02019ec:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02019ee:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02019f0:	68e67663          	bgeu	a2,a4,ffffffffc020207c <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02019f4:	0009b603          	ld	a2,0(s3)
ffffffffc02019f8:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc02019fa:	629c                	ld	a5,0(a3)
ffffffffc02019fc:	078a                	slli	a5,a5,0x2
ffffffffc02019fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a00:	3ae7f563          	bgeu	a5,a4,ffffffffc0201daa <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a04:	8f8d                	sub	a5,a5,a1
ffffffffc0201a06:	079a                	slli	a5,a5,0x6
ffffffffc0201a08:	953e                	add	a0,a0,a5
ffffffffc0201a0a:	100027f3          	csrr	a5,sstatus
ffffffffc0201a0e:	8b89                	andi	a5,a5,2
ffffffffc0201a10:	2c079763          	bnez	a5,ffffffffc0201cde <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc0201a14:	000bb783          	ld	a5,0(s7)
ffffffffc0201a18:	4585                	li	a1,1
ffffffffc0201a1a:	739c                	ld	a5,32(a5)
ffffffffc0201a1c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201a1e:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201a22:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201a24:	078a                	slli	a5,a5,0x2
ffffffffc0201a26:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a28:	38e7f163          	bgeu	a5,a4,ffffffffc0201daa <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a2c:	000b3503          	ld	a0,0(s6)
ffffffffc0201a30:	fff80737          	lui	a4,0xfff80
ffffffffc0201a34:	97ba                	add	a5,a5,a4
ffffffffc0201a36:	079a                	slli	a5,a5,0x6
ffffffffc0201a38:	953e                	add	a0,a0,a5
ffffffffc0201a3a:	100027f3          	csrr	a5,sstatus
ffffffffc0201a3e:	8b89                	andi	a5,a5,2
ffffffffc0201a40:	28079363          	bnez	a5,ffffffffc0201cc6 <pmm_init+0x5f4>
ffffffffc0201a44:	000bb783          	ld	a5,0(s7)
ffffffffc0201a48:	4585                	li	a1,1
ffffffffc0201a4a:	739c                	ld	a5,32(a5)
ffffffffc0201a4c:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201a4e:	00093783          	ld	a5,0(s2)
ffffffffc0201a52:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd69c>
  asm volatile("sfence.vma");
ffffffffc0201a56:	12000073          	sfence.vma
ffffffffc0201a5a:	100027f3          	csrr	a5,sstatus
ffffffffc0201a5e:	8b89                	andi	a5,a5,2
ffffffffc0201a60:	24079963          	bnez	a5,ffffffffc0201cb2 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201a64:	000bb783          	ld	a5,0(s7)
ffffffffc0201a68:	779c                	ld	a5,40(a5)
ffffffffc0201a6a:	9782                	jalr	a5
ffffffffc0201a6c:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201a6e:	71441363          	bne	s0,s4,ffffffffc0202174 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201a72:	00005517          	auipc	a0,0x5
ffffffffc0201a76:	79e50513          	addi	a0,a0,1950 # ffffffffc0207210 <commands+0xb58>
ffffffffc0201a7a:	e52fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201a7e:	100027f3          	csrr	a5,sstatus
ffffffffc0201a82:	8b89                	andi	a5,a5,2
ffffffffc0201a84:	20079d63          	bnez	a5,ffffffffc0201c9e <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201a88:	000bb783          	ld	a5,0(s7)
ffffffffc0201a8c:	779c                	ld	a5,40(a5)
ffffffffc0201a8e:	9782                	jalr	a5
ffffffffc0201a90:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201a92:	6098                	ld	a4,0(s1)
ffffffffc0201a94:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201a98:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201a9a:	00c71793          	slli	a5,a4,0xc
ffffffffc0201a9e:	6a05                	lui	s4,0x1
ffffffffc0201aa0:	02f47c63          	bgeu	s0,a5,ffffffffc0201ad8 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201aa4:	00c45793          	srli	a5,s0,0xc
ffffffffc0201aa8:	00093503          	ld	a0,0(s2)
ffffffffc0201aac:	2ee7f263          	bgeu	a5,a4,ffffffffc0201d90 <pmm_init+0x6be>
ffffffffc0201ab0:	0009b583          	ld	a1,0(s3)
ffffffffc0201ab4:	4601                	li	a2,0
ffffffffc0201ab6:	95a2                	add	a1,a1,s0
ffffffffc0201ab8:	c8aff0ef          	jal	ra,ffffffffc0200f42 <get_pte>
ffffffffc0201abc:	2a050a63          	beqz	a0,ffffffffc0201d70 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ac0:	611c                	ld	a5,0(a0)
ffffffffc0201ac2:	078a                	slli	a5,a5,0x2
ffffffffc0201ac4:	0157f7b3          	and	a5,a5,s5
ffffffffc0201ac8:	28879463          	bne	a5,s0,ffffffffc0201d50 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201acc:	6098                	ld	a4,0(s1)
ffffffffc0201ace:	9452                	add	s0,s0,s4
ffffffffc0201ad0:	00c71793          	slli	a5,a4,0xc
ffffffffc0201ad4:	fcf468e3          	bltu	s0,a5,ffffffffc0201aa4 <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201ad8:	00093783          	ld	a5,0(s2)
ffffffffc0201adc:	639c                	ld	a5,0(a5)
ffffffffc0201ade:	66079b63          	bnez	a5,ffffffffc0202154 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0201ae2:	4505                	li	a0,1
ffffffffc0201ae4:	b52ff0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0201ae8:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201aea:	00093503          	ld	a0,0(s2)
ffffffffc0201aee:	4699                	li	a3,6
ffffffffc0201af0:	10000613          	li	a2,256
ffffffffc0201af4:	85d6                	mv	a1,s5
ffffffffc0201af6:	ae7ff0ef          	jal	ra,ffffffffc02015dc <page_insert>
ffffffffc0201afa:	62051d63          	bnez	a0,ffffffffc0202134 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc0201afe:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c69c>
ffffffffc0201b02:	4785                	li	a5,1
ffffffffc0201b04:	60f71863          	bne	a4,a5,ffffffffc0202114 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201b08:	00093503          	ld	a0,0(s2)
ffffffffc0201b0c:	6405                	lui	s0,0x1
ffffffffc0201b0e:	4699                	li	a3,6
ffffffffc0201b10:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ac0>
ffffffffc0201b14:	85d6                	mv	a1,s5
ffffffffc0201b16:	ac7ff0ef          	jal	ra,ffffffffc02015dc <page_insert>
ffffffffc0201b1a:	46051163          	bnez	a0,ffffffffc0201f7c <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc0201b1e:	000aa703          	lw	a4,0(s5)
ffffffffc0201b22:	4789                	li	a5,2
ffffffffc0201b24:	72f71463          	bne	a4,a5,ffffffffc020224c <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201b28:	00006597          	auipc	a1,0x6
ffffffffc0201b2c:	82058593          	addi	a1,a1,-2016 # ffffffffc0207348 <commands+0xc90>
ffffffffc0201b30:	10000513          	li	a0,256
ffffffffc0201b34:	464040ef          	jal	ra,ffffffffc0205f98 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201b38:	10040593          	addi	a1,s0,256
ffffffffc0201b3c:	10000513          	li	a0,256
ffffffffc0201b40:	46a040ef          	jal	ra,ffffffffc0205faa <strcmp>
ffffffffc0201b44:	6e051463          	bnez	a0,ffffffffc020222c <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc0201b48:	000b3683          	ld	a3,0(s6)
ffffffffc0201b4c:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201b50:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0201b52:	40da86b3          	sub	a3,s5,a3
ffffffffc0201b56:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201b58:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201b5a:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201b5c:	8031                	srli	s0,s0,0xc
ffffffffc0201b5e:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b62:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201b64:	50f77c63          	bgeu	a4,a5,ffffffffc020207c <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201b68:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201b6c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201b70:	96be                	add	a3,a3,a5
ffffffffc0201b72:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201b76:	3ec040ef          	jal	ra,ffffffffc0205f62 <strlen>
ffffffffc0201b7a:	68051963          	bnez	a0,ffffffffc020220c <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201b7e:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201b82:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b84:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0201b88:	068a                	slli	a3,a3,0x2
ffffffffc0201b8a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b8c:	20f6ff63          	bgeu	a3,a5,ffffffffc0201daa <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0201b90:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b92:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201b94:	4ef47463          	bgeu	s0,a5,ffffffffc020207c <pmm_init+0x9aa>
ffffffffc0201b98:	0009b403          	ld	s0,0(s3)
ffffffffc0201b9c:	9436                	add	s0,s0,a3
ffffffffc0201b9e:	100027f3          	csrr	a5,sstatus
ffffffffc0201ba2:	8b89                	andi	a5,a5,2
ffffffffc0201ba4:	18079b63          	bnez	a5,ffffffffc0201d3a <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0201ba8:	000bb783          	ld	a5,0(s7)
ffffffffc0201bac:	4585                	li	a1,1
ffffffffc0201bae:	8556                	mv	a0,s5
ffffffffc0201bb0:	739c                	ld	a5,32(a5)
ffffffffc0201bb2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201bb4:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201bb6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201bb8:	078a                	slli	a5,a5,0x2
ffffffffc0201bba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201bbc:	1ee7f763          	bgeu	a5,a4,ffffffffc0201daa <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201bc0:	000b3503          	ld	a0,0(s6)
ffffffffc0201bc4:	fff80737          	lui	a4,0xfff80
ffffffffc0201bc8:	97ba                	add	a5,a5,a4
ffffffffc0201bca:	079a                	slli	a5,a5,0x6
ffffffffc0201bcc:	953e                	add	a0,a0,a5
ffffffffc0201bce:	100027f3          	csrr	a5,sstatus
ffffffffc0201bd2:	8b89                	andi	a5,a5,2
ffffffffc0201bd4:	14079763          	bnez	a5,ffffffffc0201d22 <pmm_init+0x650>
ffffffffc0201bd8:	000bb783          	ld	a5,0(s7)
ffffffffc0201bdc:	4585                	li	a1,1
ffffffffc0201bde:	739c                	ld	a5,32(a5)
ffffffffc0201be0:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201be2:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201be6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201be8:	078a                	slli	a5,a5,0x2
ffffffffc0201bea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201bec:	1ae7ff63          	bgeu	a5,a4,ffffffffc0201daa <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201bf0:	000b3503          	ld	a0,0(s6)
ffffffffc0201bf4:	fff80737          	lui	a4,0xfff80
ffffffffc0201bf8:	97ba                	add	a5,a5,a4
ffffffffc0201bfa:	079a                	slli	a5,a5,0x6
ffffffffc0201bfc:	953e                	add	a0,a0,a5
ffffffffc0201bfe:	100027f3          	csrr	a5,sstatus
ffffffffc0201c02:	8b89                	andi	a5,a5,2
ffffffffc0201c04:	10079363          	bnez	a5,ffffffffc0201d0a <pmm_init+0x638>
ffffffffc0201c08:	000bb783          	ld	a5,0(s7)
ffffffffc0201c0c:	4585                	li	a1,1
ffffffffc0201c0e:	739c                	ld	a5,32(a5)
ffffffffc0201c10:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201c12:	00093783          	ld	a5,0(s2)
ffffffffc0201c16:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0201c1a:	12000073          	sfence.vma
ffffffffc0201c1e:	100027f3          	csrr	a5,sstatus
ffffffffc0201c22:	8b89                	andi	a5,a5,2
ffffffffc0201c24:	0c079963          	bnez	a5,ffffffffc0201cf6 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c28:	000bb783          	ld	a5,0(s7)
ffffffffc0201c2c:	779c                	ld	a5,40(a5)
ffffffffc0201c2e:	9782                	jalr	a5
ffffffffc0201c30:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201c32:	3a8c1563          	bne	s8,s0,ffffffffc0201fdc <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201c36:	00005517          	auipc	a0,0x5
ffffffffc0201c3a:	78a50513          	addi	a0,a0,1930 # ffffffffc02073c0 <commands+0xd08>
ffffffffc0201c3e:	c8efe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0201c42:	6446                	ld	s0,80(sp)
ffffffffc0201c44:	60e6                	ld	ra,88(sp)
ffffffffc0201c46:	64a6                	ld	s1,72(sp)
ffffffffc0201c48:	6906                	ld	s2,64(sp)
ffffffffc0201c4a:	79e2                	ld	s3,56(sp)
ffffffffc0201c4c:	7a42                	ld	s4,48(sp)
ffffffffc0201c4e:	7aa2                	ld	s5,40(sp)
ffffffffc0201c50:	7b02                	ld	s6,32(sp)
ffffffffc0201c52:	6be2                	ld	s7,24(sp)
ffffffffc0201c54:	6c42                	ld	s8,16(sp)
ffffffffc0201c56:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0201c58:	14d0106f          	j	ffffffffc02035a4 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201c5c:	6785                	lui	a5,0x1
ffffffffc0201c5e:	17fd                	addi	a5,a5,-1
ffffffffc0201c60:	96be                	add	a3,a3,a5
ffffffffc0201c62:	77fd                	lui	a5,0xfffff
ffffffffc0201c64:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0201c66:	00c7d693          	srli	a3,a5,0xc
ffffffffc0201c6a:	14c6f063          	bgeu	a3,a2,ffffffffc0201daa <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0201c6e:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0201c72:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201c74:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0201c78:	6a10                	ld	a2,16(a2)
ffffffffc0201c7a:	069a                	slli	a3,a3,0x6
ffffffffc0201c7c:	00c7d593          	srli	a1,a5,0xc
ffffffffc0201c80:	9536                	add	a0,a0,a3
ffffffffc0201c82:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201c84:	0009b583          	ld	a1,0(s3)
}
ffffffffc0201c88:	b63d                	j	ffffffffc02017b6 <pmm_init+0xe4>
        intr_disable();
ffffffffc0201c8a:	99bfe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c8e:	000bb783          	ld	a5,0(s7)
ffffffffc0201c92:	779c                	ld	a5,40(a5)
ffffffffc0201c94:	9782                	jalr	a5
ffffffffc0201c96:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201c98:	987fe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0201c9c:	bea5                	j	ffffffffc0201814 <pmm_init+0x142>
        intr_disable();
ffffffffc0201c9e:	987fe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0201ca2:	000bb783          	ld	a5,0(s7)
ffffffffc0201ca6:	779c                	ld	a5,40(a5)
ffffffffc0201ca8:	9782                	jalr	a5
ffffffffc0201caa:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0201cac:	973fe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0201cb0:	b3cd                	j	ffffffffc0201a92 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0201cb2:	973fe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0201cb6:	000bb783          	ld	a5,0(s7)
ffffffffc0201cba:	779c                	ld	a5,40(a5)
ffffffffc0201cbc:	9782                	jalr	a5
ffffffffc0201cbe:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0201cc0:	95ffe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0201cc4:	b36d                	j	ffffffffc0201a6e <pmm_init+0x39c>
ffffffffc0201cc6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201cc8:	95dfe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201ccc:	000bb783          	ld	a5,0(s7)
ffffffffc0201cd0:	6522                	ld	a0,8(sp)
ffffffffc0201cd2:	4585                	li	a1,1
ffffffffc0201cd4:	739c                	ld	a5,32(a5)
ffffffffc0201cd6:	9782                	jalr	a5
        intr_enable();
ffffffffc0201cd8:	947fe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0201cdc:	bb8d                	j	ffffffffc0201a4e <pmm_init+0x37c>
ffffffffc0201cde:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201ce0:	945fe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0201ce4:	000bb783          	ld	a5,0(s7)
ffffffffc0201ce8:	6522                	ld	a0,8(sp)
ffffffffc0201cea:	4585                	li	a1,1
ffffffffc0201cec:	739c                	ld	a5,32(a5)
ffffffffc0201cee:	9782                	jalr	a5
        intr_enable();
ffffffffc0201cf0:	92ffe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0201cf4:	b32d                	j	ffffffffc0201a1e <pmm_init+0x34c>
        intr_disable();
ffffffffc0201cf6:	92ffe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201cfa:	000bb783          	ld	a5,0(s7)
ffffffffc0201cfe:	779c                	ld	a5,40(a5)
ffffffffc0201d00:	9782                	jalr	a5
ffffffffc0201d02:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d04:	91bfe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0201d08:	b72d                	j	ffffffffc0201c32 <pmm_init+0x560>
ffffffffc0201d0a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201d0c:	919fe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201d10:	000bb783          	ld	a5,0(s7)
ffffffffc0201d14:	6522                	ld	a0,8(sp)
ffffffffc0201d16:	4585                	li	a1,1
ffffffffc0201d18:	739c                	ld	a5,32(a5)
ffffffffc0201d1a:	9782                	jalr	a5
        intr_enable();
ffffffffc0201d1c:	903fe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0201d20:	bdcd                	j	ffffffffc0201c12 <pmm_init+0x540>
ffffffffc0201d22:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201d24:	901fe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0201d28:	000bb783          	ld	a5,0(s7)
ffffffffc0201d2c:	6522                	ld	a0,8(sp)
ffffffffc0201d2e:	4585                	li	a1,1
ffffffffc0201d30:	739c                	ld	a5,32(a5)
ffffffffc0201d32:	9782                	jalr	a5
        intr_enable();
ffffffffc0201d34:	8ebfe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0201d38:	b56d                	j	ffffffffc0201be2 <pmm_init+0x510>
        intr_disable();
ffffffffc0201d3a:	8ebfe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0201d3e:	000bb783          	ld	a5,0(s7)
ffffffffc0201d42:	4585                	li	a1,1
ffffffffc0201d44:	8556                	mv	a0,s5
ffffffffc0201d46:	739c                	ld	a5,32(a5)
ffffffffc0201d48:	9782                	jalr	a5
        intr_enable();
ffffffffc0201d4a:	8d5fe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0201d4e:	b59d                	j	ffffffffc0201bb4 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201d50:	00005697          	auipc	a3,0x5
ffffffffc0201d54:	52068693          	addi	a3,a3,1312 # ffffffffc0207270 <commands+0xbb8>
ffffffffc0201d58:	00005617          	auipc	a2,0x5
ffffffffc0201d5c:	d7060613          	addi	a2,a2,-656 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201d60:	22700593          	li	a1,551
ffffffffc0201d64:	00005517          	auipc	a0,0x5
ffffffffc0201d68:	0d450513          	addi	a0,a0,212 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201d6c:	c9cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201d70:	00005697          	auipc	a3,0x5
ffffffffc0201d74:	4c068693          	addi	a3,a3,1216 # ffffffffc0207230 <commands+0xb78>
ffffffffc0201d78:	00005617          	auipc	a2,0x5
ffffffffc0201d7c:	d5060613          	addi	a2,a2,-688 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201d80:	22600593          	li	a1,550
ffffffffc0201d84:	00005517          	auipc	a0,0x5
ffffffffc0201d88:	0b450513          	addi	a0,a0,180 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201d8c:	c7cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201d90:	86a2                	mv	a3,s0
ffffffffc0201d92:	00005617          	auipc	a2,0x5
ffffffffc0201d96:	07e60613          	addi	a2,a2,126 # ffffffffc0206e10 <commands+0x758>
ffffffffc0201d9a:	22600593          	li	a1,550
ffffffffc0201d9e:	00005517          	auipc	a0,0x5
ffffffffc0201da2:	09a50513          	addi	a0,a0,154 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201da6:	c62fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201daa:	854ff0ef          	jal	ra,ffffffffc0200dfe <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201dae:	00005617          	auipc	a2,0x5
ffffffffc0201db2:	13a60613          	addi	a2,a2,314 # ffffffffc0206ee8 <commands+0x830>
ffffffffc0201db6:	07f00593          	li	a1,127
ffffffffc0201dba:	00005517          	auipc	a0,0x5
ffffffffc0201dbe:	07e50513          	addi	a0,a0,126 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201dc2:	c46fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201dc6:	00005617          	auipc	a2,0x5
ffffffffc0201dca:	12260613          	addi	a2,a2,290 # ffffffffc0206ee8 <commands+0x830>
ffffffffc0201dce:	0c100593          	li	a1,193
ffffffffc0201dd2:	00005517          	auipc	a0,0x5
ffffffffc0201dd6:	06650513          	addi	a0,a0,102 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201dda:	c2efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201dde:	00005697          	auipc	a3,0x5
ffffffffc0201de2:	18a68693          	addi	a3,a3,394 # ffffffffc0206f68 <commands+0x8b0>
ffffffffc0201de6:	00005617          	auipc	a2,0x5
ffffffffc0201dea:	ce260613          	addi	a2,a2,-798 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201dee:	1ea00593          	li	a1,490
ffffffffc0201df2:	00005517          	auipc	a0,0x5
ffffffffc0201df6:	04650513          	addi	a0,a0,70 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201dfa:	c0efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201dfe:	00005697          	auipc	a3,0x5
ffffffffc0201e02:	14a68693          	addi	a3,a3,330 # ffffffffc0206f48 <commands+0x890>
ffffffffc0201e06:	00005617          	auipc	a2,0x5
ffffffffc0201e0a:	cc260613          	addi	a2,a2,-830 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201e0e:	1e900593          	li	a1,489
ffffffffc0201e12:	00005517          	auipc	a0,0x5
ffffffffc0201e16:	02650513          	addi	a0,a0,38 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201e1a:	beefe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201e1e:	ffdfe0ef          	jal	ra,ffffffffc0200e1a <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201e22:	00005697          	auipc	a3,0x5
ffffffffc0201e26:	1d668693          	addi	a3,a3,470 # ffffffffc0206ff8 <commands+0x940>
ffffffffc0201e2a:	00005617          	auipc	a2,0x5
ffffffffc0201e2e:	c9e60613          	addi	a2,a2,-866 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201e32:	1f200593          	li	a1,498
ffffffffc0201e36:	00005517          	auipc	a0,0x5
ffffffffc0201e3a:	00250513          	addi	a0,a0,2 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201e3e:	bcafe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201e42:	00005697          	auipc	a3,0x5
ffffffffc0201e46:	18668693          	addi	a3,a3,390 # ffffffffc0206fc8 <commands+0x910>
ffffffffc0201e4a:	00005617          	auipc	a2,0x5
ffffffffc0201e4e:	c7e60613          	addi	a2,a2,-898 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201e52:	1ef00593          	li	a1,495
ffffffffc0201e56:	00005517          	auipc	a0,0x5
ffffffffc0201e5a:	fe250513          	addi	a0,a0,-30 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201e5e:	baafe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201e62:	00005697          	auipc	a3,0x5
ffffffffc0201e66:	13e68693          	addi	a3,a3,318 # ffffffffc0206fa0 <commands+0x8e8>
ffffffffc0201e6a:	00005617          	auipc	a2,0x5
ffffffffc0201e6e:	c5e60613          	addi	a2,a2,-930 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201e72:	1eb00593          	li	a1,491
ffffffffc0201e76:	00005517          	auipc	a0,0x5
ffffffffc0201e7a:	fc250513          	addi	a0,a0,-62 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201e7e:	b8afe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201e82:	00005697          	auipc	a3,0x5
ffffffffc0201e86:	1fe68693          	addi	a3,a3,510 # ffffffffc0207080 <commands+0x9c8>
ffffffffc0201e8a:	00005617          	auipc	a2,0x5
ffffffffc0201e8e:	c3e60613          	addi	a2,a2,-962 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201e92:	1fb00593          	li	a1,507
ffffffffc0201e96:	00005517          	auipc	a0,0x5
ffffffffc0201e9a:	fa250513          	addi	a0,a0,-94 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201e9e:	b6afe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201ea2:	00005697          	auipc	a3,0x5
ffffffffc0201ea6:	27e68693          	addi	a3,a3,638 # ffffffffc0207120 <commands+0xa68>
ffffffffc0201eaa:	00005617          	auipc	a2,0x5
ffffffffc0201eae:	c1e60613          	addi	a2,a2,-994 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201eb2:	20000593          	li	a1,512
ffffffffc0201eb6:	00005517          	auipc	a0,0x5
ffffffffc0201eba:	f8250513          	addi	a0,a0,-126 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201ebe:	b4afe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201ec2:	00005697          	auipc	a3,0x5
ffffffffc0201ec6:	19668693          	addi	a3,a3,406 # ffffffffc0207058 <commands+0x9a0>
ffffffffc0201eca:	00005617          	auipc	a2,0x5
ffffffffc0201ece:	bfe60613          	addi	a2,a2,-1026 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201ed2:	1f800593          	li	a1,504
ffffffffc0201ed6:	00005517          	auipc	a0,0x5
ffffffffc0201eda:	f6250513          	addi	a0,a0,-158 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201ede:	b2afe0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201ee2:	86d6                	mv	a3,s5
ffffffffc0201ee4:	00005617          	auipc	a2,0x5
ffffffffc0201ee8:	f2c60613          	addi	a2,a2,-212 # ffffffffc0206e10 <commands+0x758>
ffffffffc0201eec:	1f700593          	li	a1,503
ffffffffc0201ef0:	00005517          	auipc	a0,0x5
ffffffffc0201ef4:	f4850513          	addi	a0,a0,-184 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201ef8:	b10fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201efc:	00005697          	auipc	a3,0x5
ffffffffc0201f00:	1bc68693          	addi	a3,a3,444 # ffffffffc02070b8 <commands+0xa00>
ffffffffc0201f04:	00005617          	auipc	a2,0x5
ffffffffc0201f08:	bc460613          	addi	a2,a2,-1084 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201f0c:	20500593          	li	a1,517
ffffffffc0201f10:	00005517          	auipc	a0,0x5
ffffffffc0201f14:	f2850513          	addi	a0,a0,-216 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201f18:	af0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201f1c:	00005697          	auipc	a3,0x5
ffffffffc0201f20:	26468693          	addi	a3,a3,612 # ffffffffc0207180 <commands+0xac8>
ffffffffc0201f24:	00005617          	auipc	a2,0x5
ffffffffc0201f28:	ba460613          	addi	a2,a2,-1116 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201f2c:	20400593          	li	a1,516
ffffffffc0201f30:	00005517          	auipc	a0,0x5
ffffffffc0201f34:	f0850513          	addi	a0,a0,-248 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201f38:	ad0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201f3c:	00005697          	auipc	a3,0x5
ffffffffc0201f40:	22c68693          	addi	a3,a3,556 # ffffffffc0207168 <commands+0xab0>
ffffffffc0201f44:	00005617          	auipc	a2,0x5
ffffffffc0201f48:	b8460613          	addi	a2,a2,-1148 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201f4c:	20300593          	li	a1,515
ffffffffc0201f50:	00005517          	auipc	a0,0x5
ffffffffc0201f54:	ee850513          	addi	a0,a0,-280 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201f58:	ab0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201f5c:	00005697          	auipc	a3,0x5
ffffffffc0201f60:	1dc68693          	addi	a3,a3,476 # ffffffffc0207138 <commands+0xa80>
ffffffffc0201f64:	00005617          	auipc	a2,0x5
ffffffffc0201f68:	b6460613          	addi	a2,a2,-1180 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201f6c:	20200593          	li	a1,514
ffffffffc0201f70:	00005517          	auipc	a0,0x5
ffffffffc0201f74:	ec850513          	addi	a0,a0,-312 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201f78:	a90fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f7c:	00005697          	auipc	a3,0x5
ffffffffc0201f80:	37468693          	addi	a3,a3,884 # ffffffffc02072f0 <commands+0xc38>
ffffffffc0201f84:	00005617          	auipc	a2,0x5
ffffffffc0201f88:	b4460613          	addi	a2,a2,-1212 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201f8c:	23100593          	li	a1,561
ffffffffc0201f90:	00005517          	auipc	a0,0x5
ffffffffc0201f94:	ea850513          	addi	a0,a0,-344 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201f98:	a70fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201f9c:	00005697          	auipc	a3,0x5
ffffffffc0201fa0:	16c68693          	addi	a3,a3,364 # ffffffffc0207108 <commands+0xa50>
ffffffffc0201fa4:	00005617          	auipc	a2,0x5
ffffffffc0201fa8:	b2460613          	addi	a2,a2,-1244 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201fac:	1ff00593          	li	a1,511
ffffffffc0201fb0:	00005517          	auipc	a0,0x5
ffffffffc0201fb4:	e8850513          	addi	a0,a0,-376 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201fb8:	a50fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201fbc:	00005697          	auipc	a3,0x5
ffffffffc0201fc0:	13c68693          	addi	a3,a3,316 # ffffffffc02070f8 <commands+0xa40>
ffffffffc0201fc4:	00005617          	auipc	a2,0x5
ffffffffc0201fc8:	b0460613          	addi	a2,a2,-1276 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201fcc:	1fe00593          	li	a1,510
ffffffffc0201fd0:	00005517          	auipc	a0,0x5
ffffffffc0201fd4:	e6850513          	addi	a0,a0,-408 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201fd8:	a30fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201fdc:	00005697          	auipc	a3,0x5
ffffffffc0201fe0:	21468693          	addi	a3,a3,532 # ffffffffc02071f0 <commands+0xb38>
ffffffffc0201fe4:	00005617          	auipc	a2,0x5
ffffffffc0201fe8:	ae460613          	addi	a2,a2,-1308 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0201fec:	24200593          	li	a1,578
ffffffffc0201ff0:	00005517          	auipc	a0,0x5
ffffffffc0201ff4:	e4850513          	addi	a0,a0,-440 # ffffffffc0206e38 <commands+0x780>
ffffffffc0201ff8:	a10fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201ffc:	00005697          	auipc	a3,0x5
ffffffffc0202000:	0ec68693          	addi	a3,a3,236 # ffffffffc02070e8 <commands+0xa30>
ffffffffc0202004:	00005617          	auipc	a2,0x5
ffffffffc0202008:	ac460613          	addi	a2,a2,-1340 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020200c:	1fd00593          	li	a1,509
ffffffffc0202010:	00005517          	auipc	a0,0x5
ffffffffc0202014:	e2850513          	addi	a0,a0,-472 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202018:	9f0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020201c:	00005697          	auipc	a3,0x5
ffffffffc0202020:	02468693          	addi	a3,a3,36 # ffffffffc0207040 <commands+0x988>
ffffffffc0202024:	00005617          	auipc	a2,0x5
ffffffffc0202028:	aa460613          	addi	a2,a2,-1372 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020202c:	20a00593          	li	a1,522
ffffffffc0202030:	00005517          	auipc	a0,0x5
ffffffffc0202034:	e0850513          	addi	a0,a0,-504 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202038:	9d0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020203c:	00005697          	auipc	a3,0x5
ffffffffc0202040:	15c68693          	addi	a3,a3,348 # ffffffffc0207198 <commands+0xae0>
ffffffffc0202044:	00005617          	auipc	a2,0x5
ffffffffc0202048:	a8460613          	addi	a2,a2,-1404 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020204c:	20700593          	li	a1,519
ffffffffc0202050:	00005517          	auipc	a0,0x5
ffffffffc0202054:	de850513          	addi	a0,a0,-536 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202058:	9b0fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020205c:	00005697          	auipc	a3,0x5
ffffffffc0202060:	fcc68693          	addi	a3,a3,-52 # ffffffffc0207028 <commands+0x970>
ffffffffc0202064:	00005617          	auipc	a2,0x5
ffffffffc0202068:	a6460613          	addi	a2,a2,-1436 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020206c:	20600593          	li	a1,518
ffffffffc0202070:	00005517          	auipc	a0,0x5
ffffffffc0202074:	dc850513          	addi	a0,a0,-568 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202078:	990fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc020207c:	00005617          	auipc	a2,0x5
ffffffffc0202080:	d9460613          	addi	a2,a2,-620 # ffffffffc0206e10 <commands+0x758>
ffffffffc0202084:	06900593          	li	a1,105
ffffffffc0202088:	00005517          	auipc	a0,0x5
ffffffffc020208c:	d5050513          	addi	a0,a0,-688 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0202090:	978fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202094:	00005697          	auipc	a3,0x5
ffffffffc0202098:	13468693          	addi	a3,a3,308 # ffffffffc02071c8 <commands+0xb10>
ffffffffc020209c:	00005617          	auipc	a2,0x5
ffffffffc02020a0:	a2c60613          	addi	a2,a2,-1492 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02020a4:	21100593          	li	a1,529
ffffffffc02020a8:	00005517          	auipc	a0,0x5
ffffffffc02020ac:	d9050513          	addi	a0,a0,-624 # ffffffffc0206e38 <commands+0x780>
ffffffffc02020b0:	958fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02020b4:	00005697          	auipc	a3,0x5
ffffffffc02020b8:	0cc68693          	addi	a3,a3,204 # ffffffffc0207180 <commands+0xac8>
ffffffffc02020bc:	00005617          	auipc	a2,0x5
ffffffffc02020c0:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02020c4:	20f00593          	li	a1,527
ffffffffc02020c8:	00005517          	auipc	a0,0x5
ffffffffc02020cc:	d7050513          	addi	a0,a0,-656 # ffffffffc0206e38 <commands+0x780>
ffffffffc02020d0:	938fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02020d4:	00005697          	auipc	a3,0x5
ffffffffc02020d8:	0dc68693          	addi	a3,a3,220 # ffffffffc02071b0 <commands+0xaf8>
ffffffffc02020dc:	00005617          	auipc	a2,0x5
ffffffffc02020e0:	9ec60613          	addi	a2,a2,-1556 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02020e4:	20e00593          	li	a1,526
ffffffffc02020e8:	00005517          	auipc	a0,0x5
ffffffffc02020ec:	d5050513          	addi	a0,a0,-688 # ffffffffc0206e38 <commands+0x780>
ffffffffc02020f0:	918fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02020f4:	00005697          	auipc	a3,0x5
ffffffffc02020f8:	08c68693          	addi	a3,a3,140 # ffffffffc0207180 <commands+0xac8>
ffffffffc02020fc:	00005617          	auipc	a2,0x5
ffffffffc0202100:	9cc60613          	addi	a2,a2,-1588 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202104:	20b00593          	li	a1,523
ffffffffc0202108:	00005517          	auipc	a0,0x5
ffffffffc020210c:	d3050513          	addi	a0,a0,-720 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202110:	8f8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202114:	00005697          	auipc	a3,0x5
ffffffffc0202118:	1c468693          	addi	a3,a3,452 # ffffffffc02072d8 <commands+0xc20>
ffffffffc020211c:	00005617          	auipc	a2,0x5
ffffffffc0202120:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202124:	23000593          	li	a1,560
ffffffffc0202128:	00005517          	auipc	a0,0x5
ffffffffc020212c:	d1050513          	addi	a0,a0,-752 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202130:	8d8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202134:	00005697          	auipc	a3,0x5
ffffffffc0202138:	16c68693          	addi	a3,a3,364 # ffffffffc02072a0 <commands+0xbe8>
ffffffffc020213c:	00005617          	auipc	a2,0x5
ffffffffc0202140:	98c60613          	addi	a2,a2,-1652 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202144:	22f00593          	li	a1,559
ffffffffc0202148:	00005517          	auipc	a0,0x5
ffffffffc020214c:	cf050513          	addi	a0,a0,-784 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202150:	8b8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202154:	00005697          	auipc	a3,0x5
ffffffffc0202158:	13468693          	addi	a3,a3,308 # ffffffffc0207288 <commands+0xbd0>
ffffffffc020215c:	00005617          	auipc	a2,0x5
ffffffffc0202160:	96c60613          	addi	a2,a2,-1684 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202164:	22b00593          	li	a1,555
ffffffffc0202168:	00005517          	auipc	a0,0x5
ffffffffc020216c:	cd050513          	addi	a0,a0,-816 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202170:	898fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202174:	00005697          	auipc	a3,0x5
ffffffffc0202178:	07c68693          	addi	a3,a3,124 # ffffffffc02071f0 <commands+0xb38>
ffffffffc020217c:	00005617          	auipc	a2,0x5
ffffffffc0202180:	94c60613          	addi	a2,a2,-1716 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202184:	21900593          	li	a1,537
ffffffffc0202188:	00005517          	auipc	a0,0x5
ffffffffc020218c:	cb050513          	addi	a0,a0,-848 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202190:	878fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202194:	00005697          	auipc	a3,0x5
ffffffffc0202198:	e9468693          	addi	a3,a3,-364 # ffffffffc0207028 <commands+0x970>
ffffffffc020219c:	00005617          	auipc	a2,0x5
ffffffffc02021a0:	92c60613          	addi	a2,a2,-1748 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02021a4:	1f300593          	li	a1,499
ffffffffc02021a8:	00005517          	auipc	a0,0x5
ffffffffc02021ac:	c9050513          	addi	a0,a0,-880 # ffffffffc0206e38 <commands+0x780>
ffffffffc02021b0:	858fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02021b4:	00005617          	auipc	a2,0x5
ffffffffc02021b8:	c5c60613          	addi	a2,a2,-932 # ffffffffc0206e10 <commands+0x758>
ffffffffc02021bc:	1f600593          	li	a1,502
ffffffffc02021c0:	00005517          	auipc	a0,0x5
ffffffffc02021c4:	c7850513          	addi	a0,a0,-904 # ffffffffc0206e38 <commands+0x780>
ffffffffc02021c8:	840fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02021cc:	00005697          	auipc	a3,0x5
ffffffffc02021d0:	e7468693          	addi	a3,a3,-396 # ffffffffc0207040 <commands+0x988>
ffffffffc02021d4:	00005617          	auipc	a2,0x5
ffffffffc02021d8:	8f460613          	addi	a2,a2,-1804 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02021dc:	1f400593          	li	a1,500
ffffffffc02021e0:	00005517          	auipc	a0,0x5
ffffffffc02021e4:	c5850513          	addi	a0,a0,-936 # ffffffffc0206e38 <commands+0x780>
ffffffffc02021e8:	820fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02021ec:	00005697          	auipc	a3,0x5
ffffffffc02021f0:	ecc68693          	addi	a3,a3,-308 # ffffffffc02070b8 <commands+0xa00>
ffffffffc02021f4:	00005617          	auipc	a2,0x5
ffffffffc02021f8:	8d460613          	addi	a2,a2,-1836 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02021fc:	1fc00593          	li	a1,508
ffffffffc0202200:	00005517          	auipc	a0,0x5
ffffffffc0202204:	c3850513          	addi	a0,a0,-968 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202208:	800fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020220c:	00005697          	auipc	a3,0x5
ffffffffc0202210:	18c68693          	addi	a3,a3,396 # ffffffffc0207398 <commands+0xce0>
ffffffffc0202214:	00005617          	auipc	a2,0x5
ffffffffc0202218:	8b460613          	addi	a2,a2,-1868 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020221c:	23900593          	li	a1,569
ffffffffc0202220:	00005517          	auipc	a0,0x5
ffffffffc0202224:	c1850513          	addi	a0,a0,-1000 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202228:	fe1fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020222c:	00005697          	auipc	a3,0x5
ffffffffc0202230:	13468693          	addi	a3,a3,308 # ffffffffc0207360 <commands+0xca8>
ffffffffc0202234:	00005617          	auipc	a2,0x5
ffffffffc0202238:	89460613          	addi	a2,a2,-1900 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020223c:	23600593          	li	a1,566
ffffffffc0202240:	00005517          	auipc	a0,0x5
ffffffffc0202244:	bf850513          	addi	a0,a0,-1032 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202248:	fc1fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020224c:	00005697          	auipc	a3,0x5
ffffffffc0202250:	0e468693          	addi	a3,a3,228 # ffffffffc0207330 <commands+0xc78>
ffffffffc0202254:	00005617          	auipc	a2,0x5
ffffffffc0202258:	87460613          	addi	a2,a2,-1932 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020225c:	23200593          	li	a1,562
ffffffffc0202260:	00005517          	auipc	a0,0x5
ffffffffc0202264:	bd850513          	addi	a0,a0,-1064 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202268:	fa1fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020226c <copy_range>:
               bool share) {
ffffffffc020226c:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020226e:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc0202272:	f486                	sd	ra,104(sp)
ffffffffc0202274:	f0a2                	sd	s0,96(sp)
ffffffffc0202276:	eca6                	sd	s1,88(sp)
ffffffffc0202278:	e8ca                	sd	s2,80(sp)
ffffffffc020227a:	e4ce                	sd	s3,72(sp)
ffffffffc020227c:	e0d2                	sd	s4,64(sp)
ffffffffc020227e:	fc56                	sd	s5,56(sp)
ffffffffc0202280:	f85a                	sd	s6,48(sp)
ffffffffc0202282:	f45e                	sd	s7,40(sp)
ffffffffc0202284:	f062                	sd	s8,32(sp)
ffffffffc0202286:	ec66                	sd	s9,24(sp)
ffffffffc0202288:	e86a                	sd	s10,16(sp)
ffffffffc020228a:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020228c:	17d2                	slli	a5,a5,0x34
ffffffffc020228e:	1e079763          	bnez	a5,ffffffffc020247c <copy_range+0x210>
    assert(USER_ACCESS(start, end));
ffffffffc0202292:	002007b7          	lui	a5,0x200
ffffffffc0202296:	8432                	mv	s0,a2
ffffffffc0202298:	16f66a63          	bltu	a2,a5,ffffffffc020240c <copy_range+0x1a0>
ffffffffc020229c:	8936                	mv	s2,a3
ffffffffc020229e:	16d67763          	bgeu	a2,a3,ffffffffc020240c <copy_range+0x1a0>
ffffffffc02022a2:	4785                	li	a5,1
ffffffffc02022a4:	07fe                	slli	a5,a5,0x1f
ffffffffc02022a6:	16d7e363          	bltu	a5,a3,ffffffffc020240c <copy_range+0x1a0>
ffffffffc02022aa:	5b7d                	li	s6,-1
ffffffffc02022ac:	8aaa                	mv	s5,a0
ffffffffc02022ae:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc02022b0:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02022b2:	000b0c97          	auipc	s9,0xb0
ffffffffc02022b6:	646c8c93          	addi	s9,s9,1606 # ffffffffc02b28f8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02022ba:	000b0c17          	auipc	s8,0xb0
ffffffffc02022be:	646c0c13          	addi	s8,s8,1606 # ffffffffc02b2900 <pages>
    return page - pages + nbase;
ffffffffc02022c2:	00080bb7          	lui	s7,0x80
    return KADDR(page2pa(page));
ffffffffc02022c6:	00cb5b13          	srli	s6,s6,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02022ca:	4601                	li	a2,0
ffffffffc02022cc:	85a2                	mv	a1,s0
ffffffffc02022ce:	854e                	mv	a0,s3
ffffffffc02022d0:	c73fe0ef          	jal	ra,ffffffffc0200f42 <get_pte>
ffffffffc02022d4:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02022d6:	c175                	beqz	a0,ffffffffc02023ba <copy_range+0x14e>
        if (*ptep & PTE_V) {
ffffffffc02022d8:	611c                	ld	a5,0(a0)
ffffffffc02022da:	8b85                	andi	a5,a5,1
ffffffffc02022dc:	e785                	bnez	a5,ffffffffc0202304 <copy_range+0x98>
        start += PGSIZE;
ffffffffc02022de:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02022e0:	ff2465e3          	bltu	s0,s2,ffffffffc02022ca <copy_range+0x5e>
    return 0;
ffffffffc02022e4:	4501                	li	a0,0
}
ffffffffc02022e6:	70a6                	ld	ra,104(sp)
ffffffffc02022e8:	7406                	ld	s0,96(sp)
ffffffffc02022ea:	64e6                	ld	s1,88(sp)
ffffffffc02022ec:	6946                	ld	s2,80(sp)
ffffffffc02022ee:	69a6                	ld	s3,72(sp)
ffffffffc02022f0:	6a06                	ld	s4,64(sp)
ffffffffc02022f2:	7ae2                	ld	s5,56(sp)
ffffffffc02022f4:	7b42                	ld	s6,48(sp)
ffffffffc02022f6:	7ba2                	ld	s7,40(sp)
ffffffffc02022f8:	7c02                	ld	s8,32(sp)
ffffffffc02022fa:	6ce2                	ld	s9,24(sp)
ffffffffc02022fc:	6d42                	ld	s10,16(sp)
ffffffffc02022fe:	6da2                	ld	s11,8(sp)
ffffffffc0202300:	6165                	addi	sp,sp,112
ffffffffc0202302:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0202304:	4605                	li	a2,1
ffffffffc0202306:	85a2                	mv	a1,s0
ffffffffc0202308:	8556                	mv	a0,s5
ffffffffc020230a:	c39fe0ef          	jal	ra,ffffffffc0200f42 <get_pte>
ffffffffc020230e:	c161                	beqz	a0,ffffffffc02023ce <copy_range+0x162>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0202310:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V)) {
ffffffffc0202312:	0017f713          	andi	a4,a5,1
ffffffffc0202316:	01f7f493          	andi	s1,a5,31
ffffffffc020231a:	14070563          	beqz	a4,ffffffffc0202464 <copy_range+0x1f8>
    if (PPN(pa) >= npage) {
ffffffffc020231e:	000cb683          	ld	a3,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202322:	078a                	slli	a5,a5,0x2
ffffffffc0202324:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202328:	12d77263          	bgeu	a4,a3,ffffffffc020244c <copy_range+0x1e0>
    return &pages[PPN(pa) - nbase];
ffffffffc020232c:	000c3783          	ld	a5,0(s8)
ffffffffc0202330:	fff806b7          	lui	a3,0xfff80
ffffffffc0202334:	9736                	add	a4,a4,a3
ffffffffc0202336:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc0202338:	4505                	li	a0,1
ffffffffc020233a:	00e78db3          	add	s11,a5,a4
ffffffffc020233e:	af9fe0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0202342:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc0202344:	0a0d8463          	beqz	s11,ffffffffc02023ec <copy_range+0x180>
            assert(npage != NULL);
ffffffffc0202348:	c175                	beqz	a0,ffffffffc020242c <copy_range+0x1c0>
    return page - pages + nbase;
ffffffffc020234a:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc020234e:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0202352:	40ed86b3          	sub	a3,s11,a4
ffffffffc0202356:	8699                	srai	a3,a3,0x6
ffffffffc0202358:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc020235a:	0166f7b3          	and	a5,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc020235e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202360:	06c7fa63          	bgeu	a5,a2,ffffffffc02023d4 <copy_range+0x168>
    return page - pages + nbase;
ffffffffc0202364:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc0202368:	000b0717          	auipc	a4,0xb0
ffffffffc020236c:	5a870713          	addi	a4,a4,1448 # ffffffffc02b2910 <va_pa_offset>
ffffffffc0202370:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc0202372:	8799                	srai	a5,a5,0x6
ffffffffc0202374:	97de                	add	a5,a5,s7
    return KADDR(page2pa(page));
ffffffffc0202376:	0167f733          	and	a4,a5,s6
ffffffffc020237a:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020237e:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202380:	04c77963          	bgeu	a4,a2,ffffffffc02023d2 <copy_range+0x166>
            memcpy(kva_dst, kva_src, PGSIZE); 
ffffffffc0202384:	6605                	lui	a2,0x1
ffffffffc0202386:	953e                	add	a0,a0,a5
ffffffffc0202388:	469030ef          	jal	ra,ffffffffc0205ff0 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc020238c:	86a6                	mv	a3,s1
ffffffffc020238e:	8622                	mv	a2,s0
ffffffffc0202390:	85ea                	mv	a1,s10
ffffffffc0202392:	8556                	mv	a0,s5
ffffffffc0202394:	a48ff0ef          	jal	ra,ffffffffc02015dc <page_insert>
            assert(ret == 0);
ffffffffc0202398:	d139                	beqz	a0,ffffffffc02022de <copy_range+0x72>
ffffffffc020239a:	00005697          	auipc	a3,0x5
ffffffffc020239e:	06668693          	addi	a3,a3,102 # ffffffffc0207400 <commands+0xd48>
ffffffffc02023a2:	00004617          	auipc	a2,0x4
ffffffffc02023a6:	72660613          	addi	a2,a2,1830 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02023aa:	18b00593          	li	a1,395
ffffffffc02023ae:	00005517          	auipc	a0,0x5
ffffffffc02023b2:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0206e38 <commands+0x780>
ffffffffc02023b6:	e53fd0ef          	jal	ra,ffffffffc0200208 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02023ba:	00200637          	lui	a2,0x200
ffffffffc02023be:	9432                	add	s0,s0,a2
ffffffffc02023c0:	ffe00637          	lui	a2,0xffe00
ffffffffc02023c4:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc02023c6:	dc19                	beqz	s0,ffffffffc02022e4 <copy_range+0x78>
ffffffffc02023c8:	f12461e3          	bltu	s0,s2,ffffffffc02022ca <copy_range+0x5e>
ffffffffc02023cc:	bf21                	j	ffffffffc02022e4 <copy_range+0x78>
                return -E_NO_MEM;
ffffffffc02023ce:	5571                	li	a0,-4
ffffffffc02023d0:	bf19                	j	ffffffffc02022e6 <copy_range+0x7a>
ffffffffc02023d2:	86be                	mv	a3,a5
ffffffffc02023d4:	00005617          	auipc	a2,0x5
ffffffffc02023d8:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0206e10 <commands+0x758>
ffffffffc02023dc:	06900593          	li	a1,105
ffffffffc02023e0:	00005517          	auipc	a0,0x5
ffffffffc02023e4:	9f850513          	addi	a0,a0,-1544 # ffffffffc0206dd8 <commands+0x720>
ffffffffc02023e8:	e21fd0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(page != NULL);
ffffffffc02023ec:	00005697          	auipc	a3,0x5
ffffffffc02023f0:	ff468693          	addi	a3,a3,-12 # ffffffffc02073e0 <commands+0xd28>
ffffffffc02023f4:	00004617          	auipc	a2,0x4
ffffffffc02023f8:	6d460613          	addi	a2,a2,1748 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02023fc:	17200593          	li	a1,370
ffffffffc0202400:	00005517          	auipc	a0,0x5
ffffffffc0202404:	a3850513          	addi	a0,a0,-1480 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202408:	e01fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020240c:	00005697          	auipc	a3,0x5
ffffffffc0202410:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0206e78 <commands+0x7c0>
ffffffffc0202414:	00004617          	auipc	a2,0x4
ffffffffc0202418:	6b460613          	addi	a2,a2,1716 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020241c:	15e00593          	li	a1,350
ffffffffc0202420:	00005517          	auipc	a0,0x5
ffffffffc0202424:	a1850513          	addi	a0,a0,-1512 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202428:	de1fd0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(npage != NULL);
ffffffffc020242c:	00005697          	auipc	a3,0x5
ffffffffc0202430:	fc468693          	addi	a3,a3,-60 # ffffffffc02073f0 <commands+0xd38>
ffffffffc0202434:	00004617          	auipc	a2,0x4
ffffffffc0202438:	69460613          	addi	a2,a2,1684 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020243c:	17300593          	li	a1,371
ffffffffc0202440:	00005517          	auipc	a0,0x5
ffffffffc0202444:	9f850513          	addi	a0,a0,-1544 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202448:	dc1fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020244c:	00005617          	auipc	a2,0x5
ffffffffc0202450:	96c60613          	addi	a2,a2,-1684 # ffffffffc0206db8 <commands+0x700>
ffffffffc0202454:	06200593          	li	a1,98
ffffffffc0202458:	00005517          	auipc	a0,0x5
ffffffffc020245c:	98050513          	addi	a0,a0,-1664 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0202460:	da9fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202464:	00005617          	auipc	a2,0x5
ffffffffc0202468:	98460613          	addi	a2,a2,-1660 # ffffffffc0206de8 <commands+0x730>
ffffffffc020246c:	07400593          	li	a1,116
ffffffffc0202470:	00005517          	auipc	a0,0x5
ffffffffc0202474:	96850513          	addi	a0,a0,-1688 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0202478:	d91fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020247c:	00005697          	auipc	a3,0x5
ffffffffc0202480:	9cc68693          	addi	a3,a3,-1588 # ffffffffc0206e48 <commands+0x790>
ffffffffc0202484:	00004617          	auipc	a2,0x4
ffffffffc0202488:	64460613          	addi	a2,a2,1604 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020248c:	15d00593          	li	a1,349
ffffffffc0202490:	00005517          	auipc	a0,0x5
ffffffffc0202494:	9a850513          	addi	a0,a0,-1624 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202498:	d71fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020249c <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020249c:	12058073          	sfence.vma	a1
}
ffffffffc02024a0:	8082                	ret

ffffffffc02024a2 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02024a2:	7179                	addi	sp,sp,-48
ffffffffc02024a4:	e84a                	sd	s2,16(sp)
ffffffffc02024a6:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02024a8:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02024aa:	f022                	sd	s0,32(sp)
ffffffffc02024ac:	ec26                	sd	s1,24(sp)
ffffffffc02024ae:	e44e                	sd	s3,8(sp)
ffffffffc02024b0:	f406                	sd	ra,40(sp)
ffffffffc02024b2:	84ae                	mv	s1,a1
ffffffffc02024b4:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02024b6:	981fe0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc02024ba:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02024bc:	cd05                	beqz	a0,ffffffffc02024f4 <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02024be:	85aa                	mv	a1,a0
ffffffffc02024c0:	86ce                	mv	a3,s3
ffffffffc02024c2:	8626                	mv	a2,s1
ffffffffc02024c4:	854a                	mv	a0,s2
ffffffffc02024c6:	916ff0ef          	jal	ra,ffffffffc02015dc <page_insert>
ffffffffc02024ca:	ed0d                	bnez	a0,ffffffffc0202504 <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc02024cc:	000b0797          	auipc	a5,0xb0
ffffffffc02024d0:	4747a783          	lw	a5,1140(a5) # ffffffffc02b2940 <swap_init_ok>
ffffffffc02024d4:	c385                	beqz	a5,ffffffffc02024f4 <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc02024d6:	000b0517          	auipc	a0,0xb0
ffffffffc02024da:	44253503          	ld	a0,1090(a0) # ffffffffc02b2918 <check_mm_struct>
ffffffffc02024de:	c919                	beqz	a0,ffffffffc02024f4 <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02024e0:	4681                	li	a3,0
ffffffffc02024e2:	8622                	mv	a2,s0
ffffffffc02024e4:	85a6                	mv	a1,s1
ffffffffc02024e6:	1fb010ef          	jal	ra,ffffffffc0203ee0 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc02024ea:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc02024ec:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc02024ee:	4785                	li	a5,1
ffffffffc02024f0:	04f71663          	bne	a4,a5,ffffffffc020253c <pgdir_alloc_page+0x9a>
}
ffffffffc02024f4:	70a2                	ld	ra,40(sp)
ffffffffc02024f6:	8522                	mv	a0,s0
ffffffffc02024f8:	7402                	ld	s0,32(sp)
ffffffffc02024fa:	64e2                	ld	s1,24(sp)
ffffffffc02024fc:	6942                	ld	s2,16(sp)
ffffffffc02024fe:	69a2                	ld	s3,8(sp)
ffffffffc0202500:	6145                	addi	sp,sp,48
ffffffffc0202502:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202504:	100027f3          	csrr	a5,sstatus
ffffffffc0202508:	8b89                	andi	a5,a5,2
ffffffffc020250a:	eb99                	bnez	a5,ffffffffc0202520 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc020250c:	000b0797          	auipc	a5,0xb0
ffffffffc0202510:	3fc7b783          	ld	a5,1020(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc0202514:	739c                	ld	a5,32(a5)
ffffffffc0202516:	8522                	mv	a0,s0
ffffffffc0202518:	4585                	li	a1,1
ffffffffc020251a:	9782                	jalr	a5
            return NULL;
ffffffffc020251c:	4401                	li	s0,0
ffffffffc020251e:	bfd9                	j	ffffffffc02024f4 <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0202520:	904fe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202524:	000b0797          	auipc	a5,0xb0
ffffffffc0202528:	3e47b783          	ld	a5,996(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc020252c:	739c                	ld	a5,32(a5)
ffffffffc020252e:	8522                	mv	a0,s0
ffffffffc0202530:	4585                	li	a1,1
ffffffffc0202532:	9782                	jalr	a5
            return NULL;
ffffffffc0202534:	4401                	li	s0,0
        intr_enable();
ffffffffc0202536:	8e8fe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc020253a:	bf6d                	j	ffffffffc02024f4 <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc020253c:	00005697          	auipc	a3,0x5
ffffffffc0202540:	ed468693          	addi	a3,a3,-300 # ffffffffc0207410 <commands+0xd58>
ffffffffc0202544:	00004617          	auipc	a2,0x4
ffffffffc0202548:	58460613          	addi	a2,a2,1412 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020254c:	1ca00593          	li	a1,458
ffffffffc0202550:	00005517          	auipc	a0,0x5
ffffffffc0202554:	8e850513          	addi	a0,a0,-1816 # ffffffffc0206e38 <commands+0x780>
ffffffffc0202558:	cb1fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020255c <_fifo_init_mm>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020255c:	000ac797          	auipc	a5,0xac
ffffffffc0202560:	2ac78793          	addi	a5,a5,684 # ffffffffc02ae808 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0202564:	f51c                	sd	a5,40(a0)
ffffffffc0202566:	e79c                	sd	a5,8(a5)
ffffffffc0202568:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc020256a:	4501                	li	a0,0
ffffffffc020256c:	8082                	ret

ffffffffc020256e <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc020256e:	4501                	li	a0,0
ffffffffc0202570:	8082                	ret

ffffffffc0202572 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0202572:	4501                	li	a0,0
ffffffffc0202574:	8082                	ret

ffffffffc0202576 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0202576:	4501                	li	a0,0
ffffffffc0202578:	8082                	ret

ffffffffc020257a <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc020257a:	711d                	addi	sp,sp,-96
ffffffffc020257c:	fc4e                	sd	s3,56(sp)
ffffffffc020257e:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0202580:	00005517          	auipc	a0,0x5
ffffffffc0202584:	ea850513          	addi	a0,a0,-344 # ffffffffc0207428 <commands+0xd70>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202588:	698d                	lui	s3,0x3
ffffffffc020258a:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc020258c:	e0ca                	sd	s2,64(sp)
ffffffffc020258e:	ec86                	sd	ra,88(sp)
ffffffffc0202590:	e8a2                	sd	s0,80(sp)
ffffffffc0202592:	e4a6                	sd	s1,72(sp)
ffffffffc0202594:	f456                	sd	s5,40(sp)
ffffffffc0202596:	f05a                	sd	s6,32(sp)
ffffffffc0202598:	ec5e                	sd	s7,24(sp)
ffffffffc020259a:	e862                	sd	s8,16(sp)
ffffffffc020259c:	e466                	sd	s9,8(sp)
ffffffffc020259e:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02025a0:	b2dfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02025a4:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bc0>
    assert(pgfault_num==4);
ffffffffc02025a8:	000b0917          	auipc	s2,0xb0
ffffffffc02025ac:	37892903          	lw	s2,888(s2) # ffffffffc02b2920 <pgfault_num>
ffffffffc02025b0:	4791                	li	a5,4
ffffffffc02025b2:	14f91e63          	bne	s2,a5,ffffffffc020270e <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02025b6:	00005517          	auipc	a0,0x5
ffffffffc02025ba:	ec250513          	addi	a0,a0,-318 # ffffffffc0207478 <commands+0xdc0>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02025be:	6a85                	lui	s5,0x1
ffffffffc02025c0:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02025c2:	b0bfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02025c6:	000b0417          	auipc	s0,0xb0
ffffffffc02025ca:	35a40413          	addi	s0,s0,858 # ffffffffc02b2920 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02025ce:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
    assert(pgfault_num==4);
ffffffffc02025d2:	4004                	lw	s1,0(s0)
ffffffffc02025d4:	2481                	sext.w	s1,s1
ffffffffc02025d6:	2b249c63          	bne	s1,s2,ffffffffc020288e <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02025da:	00005517          	auipc	a0,0x5
ffffffffc02025de:	ec650513          	addi	a0,a0,-314 # ffffffffc02074a0 <commands+0xde8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02025e2:	6b91                	lui	s7,0x4
ffffffffc02025e4:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02025e6:	ae7fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02025ea:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bc0>
    assert(pgfault_num==4);
ffffffffc02025ee:	00042903          	lw	s2,0(s0)
ffffffffc02025f2:	2901                	sext.w	s2,s2
ffffffffc02025f4:	26991d63          	bne	s2,s1,ffffffffc020286e <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02025f8:	00005517          	auipc	a0,0x5
ffffffffc02025fc:	ed050513          	addi	a0,a0,-304 # ffffffffc02074c8 <commands+0xe10>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202600:	6c89                	lui	s9,0x2
ffffffffc0202602:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202604:	ac9fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202608:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bc0>
    assert(pgfault_num==4);
ffffffffc020260c:	401c                	lw	a5,0(s0)
ffffffffc020260e:	2781                	sext.w	a5,a5
ffffffffc0202610:	23279f63          	bne	a5,s2,ffffffffc020284e <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0202614:	00005517          	auipc	a0,0x5
ffffffffc0202618:	edc50513          	addi	a0,a0,-292 # ffffffffc02074f0 <commands+0xe38>
ffffffffc020261c:	ab1fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202620:	6795                	lui	a5,0x5
ffffffffc0202622:	4739                	li	a4,14
ffffffffc0202624:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bc0>
    assert(pgfault_num==5);
ffffffffc0202628:	4004                	lw	s1,0(s0)
ffffffffc020262a:	4795                	li	a5,5
ffffffffc020262c:	2481                	sext.w	s1,s1
ffffffffc020262e:	20f49063          	bne	s1,a5,ffffffffc020282e <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202632:	00005517          	auipc	a0,0x5
ffffffffc0202636:	e9650513          	addi	a0,a0,-362 # ffffffffc02074c8 <commands+0xe10>
ffffffffc020263a:	a93fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020263e:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0202642:	401c                	lw	a5,0(s0)
ffffffffc0202644:	2781                	sext.w	a5,a5
ffffffffc0202646:	1c979463          	bne	a5,s1,ffffffffc020280e <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020264a:	00005517          	auipc	a0,0x5
ffffffffc020264e:	e2e50513          	addi	a0,a0,-466 # ffffffffc0207478 <commands+0xdc0>
ffffffffc0202652:	a7bfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202656:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc020265a:	401c                	lw	a5,0(s0)
ffffffffc020265c:	4719                	li	a4,6
ffffffffc020265e:	2781                	sext.w	a5,a5
ffffffffc0202660:	18e79763          	bne	a5,a4,ffffffffc02027ee <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202664:	00005517          	auipc	a0,0x5
ffffffffc0202668:	e6450513          	addi	a0,a0,-412 # ffffffffc02074c8 <commands+0xe10>
ffffffffc020266c:	a61fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202670:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0202674:	401c                	lw	a5,0(s0)
ffffffffc0202676:	471d                	li	a4,7
ffffffffc0202678:	2781                	sext.w	a5,a5
ffffffffc020267a:	14e79a63          	bne	a5,a4,ffffffffc02027ce <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020267e:	00005517          	auipc	a0,0x5
ffffffffc0202682:	daa50513          	addi	a0,a0,-598 # ffffffffc0207428 <commands+0xd70>
ffffffffc0202686:	a47fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020268a:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc020268e:	401c                	lw	a5,0(s0)
ffffffffc0202690:	4721                	li	a4,8
ffffffffc0202692:	2781                	sext.w	a5,a5
ffffffffc0202694:	10e79d63          	bne	a5,a4,ffffffffc02027ae <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0202698:	00005517          	auipc	a0,0x5
ffffffffc020269c:	e0850513          	addi	a0,a0,-504 # ffffffffc02074a0 <commands+0xde8>
ffffffffc02026a0:	a2dfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02026a4:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02026a8:	401c                	lw	a5,0(s0)
ffffffffc02026aa:	4725                	li	a4,9
ffffffffc02026ac:	2781                	sext.w	a5,a5
ffffffffc02026ae:	0ee79063          	bne	a5,a4,ffffffffc020278e <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02026b2:	00005517          	auipc	a0,0x5
ffffffffc02026b6:	e3e50513          	addi	a0,a0,-450 # ffffffffc02074f0 <commands+0xe38>
ffffffffc02026ba:	a13fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02026be:	6795                	lui	a5,0x5
ffffffffc02026c0:	4739                	li	a4,14
ffffffffc02026c2:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bc0>
    assert(pgfault_num==10);
ffffffffc02026c6:	4004                	lw	s1,0(s0)
ffffffffc02026c8:	47a9                	li	a5,10
ffffffffc02026ca:	2481                	sext.w	s1,s1
ffffffffc02026cc:	0af49163          	bne	s1,a5,ffffffffc020276e <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02026d0:	00005517          	auipc	a0,0x5
ffffffffc02026d4:	da850513          	addi	a0,a0,-600 # ffffffffc0207478 <commands+0xdc0>
ffffffffc02026d8:	9f5fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02026dc:	6785                	lui	a5,0x1
ffffffffc02026de:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc02026e2:	06979663          	bne	a5,s1,ffffffffc020274e <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc02026e6:	401c                	lw	a5,0(s0)
ffffffffc02026e8:	472d                	li	a4,11
ffffffffc02026ea:	2781                	sext.w	a5,a5
ffffffffc02026ec:	04e79163          	bne	a5,a4,ffffffffc020272e <_fifo_check_swap+0x1b4>
}
ffffffffc02026f0:	60e6                	ld	ra,88(sp)
ffffffffc02026f2:	6446                	ld	s0,80(sp)
ffffffffc02026f4:	64a6                	ld	s1,72(sp)
ffffffffc02026f6:	6906                	ld	s2,64(sp)
ffffffffc02026f8:	79e2                	ld	s3,56(sp)
ffffffffc02026fa:	7a42                	ld	s4,48(sp)
ffffffffc02026fc:	7aa2                	ld	s5,40(sp)
ffffffffc02026fe:	7b02                	ld	s6,32(sp)
ffffffffc0202700:	6be2                	ld	s7,24(sp)
ffffffffc0202702:	6c42                	ld	s8,16(sp)
ffffffffc0202704:	6ca2                	ld	s9,8(sp)
ffffffffc0202706:	6d02                	ld	s10,0(sp)
ffffffffc0202708:	4501                	li	a0,0
ffffffffc020270a:	6125                	addi	sp,sp,96
ffffffffc020270c:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020270e:	00005697          	auipc	a3,0x5
ffffffffc0202712:	d4268693          	addi	a3,a3,-702 # ffffffffc0207450 <commands+0xd98>
ffffffffc0202716:	00004617          	auipc	a2,0x4
ffffffffc020271a:	3b260613          	addi	a2,a2,946 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020271e:	05100593          	li	a1,81
ffffffffc0202722:	00005517          	auipc	a0,0x5
ffffffffc0202726:	d3e50513          	addi	a0,a0,-706 # ffffffffc0207460 <commands+0xda8>
ffffffffc020272a:	adffd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==11);
ffffffffc020272e:	00005697          	auipc	a3,0x5
ffffffffc0202732:	e7268693          	addi	a3,a3,-398 # ffffffffc02075a0 <commands+0xee8>
ffffffffc0202736:	00004617          	auipc	a2,0x4
ffffffffc020273a:	39260613          	addi	a2,a2,914 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020273e:	07300593          	li	a1,115
ffffffffc0202742:	00005517          	auipc	a0,0x5
ffffffffc0202746:	d1e50513          	addi	a0,a0,-738 # ffffffffc0207460 <commands+0xda8>
ffffffffc020274a:	abffd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020274e:	00005697          	auipc	a3,0x5
ffffffffc0202752:	e2a68693          	addi	a3,a3,-470 # ffffffffc0207578 <commands+0xec0>
ffffffffc0202756:	00004617          	auipc	a2,0x4
ffffffffc020275a:	37260613          	addi	a2,a2,882 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020275e:	07100593          	li	a1,113
ffffffffc0202762:	00005517          	auipc	a0,0x5
ffffffffc0202766:	cfe50513          	addi	a0,a0,-770 # ffffffffc0207460 <commands+0xda8>
ffffffffc020276a:	a9ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==10);
ffffffffc020276e:	00005697          	auipc	a3,0x5
ffffffffc0202772:	dfa68693          	addi	a3,a3,-518 # ffffffffc0207568 <commands+0xeb0>
ffffffffc0202776:	00004617          	auipc	a2,0x4
ffffffffc020277a:	35260613          	addi	a2,a2,850 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020277e:	06f00593          	li	a1,111
ffffffffc0202782:	00005517          	auipc	a0,0x5
ffffffffc0202786:	cde50513          	addi	a0,a0,-802 # ffffffffc0207460 <commands+0xda8>
ffffffffc020278a:	a7ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==9);
ffffffffc020278e:	00005697          	auipc	a3,0x5
ffffffffc0202792:	dca68693          	addi	a3,a3,-566 # ffffffffc0207558 <commands+0xea0>
ffffffffc0202796:	00004617          	auipc	a2,0x4
ffffffffc020279a:	33260613          	addi	a2,a2,818 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020279e:	06c00593          	li	a1,108
ffffffffc02027a2:	00005517          	auipc	a0,0x5
ffffffffc02027a6:	cbe50513          	addi	a0,a0,-834 # ffffffffc0207460 <commands+0xda8>
ffffffffc02027aa:	a5ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==8);
ffffffffc02027ae:	00005697          	auipc	a3,0x5
ffffffffc02027b2:	d9a68693          	addi	a3,a3,-614 # ffffffffc0207548 <commands+0xe90>
ffffffffc02027b6:	00004617          	auipc	a2,0x4
ffffffffc02027ba:	31260613          	addi	a2,a2,786 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02027be:	06900593          	li	a1,105
ffffffffc02027c2:	00005517          	auipc	a0,0x5
ffffffffc02027c6:	c9e50513          	addi	a0,a0,-866 # ffffffffc0207460 <commands+0xda8>
ffffffffc02027ca:	a3ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==7);
ffffffffc02027ce:	00005697          	auipc	a3,0x5
ffffffffc02027d2:	d6a68693          	addi	a3,a3,-662 # ffffffffc0207538 <commands+0xe80>
ffffffffc02027d6:	00004617          	auipc	a2,0x4
ffffffffc02027da:	2f260613          	addi	a2,a2,754 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02027de:	06600593          	li	a1,102
ffffffffc02027e2:	00005517          	auipc	a0,0x5
ffffffffc02027e6:	c7e50513          	addi	a0,a0,-898 # ffffffffc0207460 <commands+0xda8>
ffffffffc02027ea:	a1ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==6);
ffffffffc02027ee:	00005697          	auipc	a3,0x5
ffffffffc02027f2:	d3a68693          	addi	a3,a3,-710 # ffffffffc0207528 <commands+0xe70>
ffffffffc02027f6:	00004617          	auipc	a2,0x4
ffffffffc02027fa:	2d260613          	addi	a2,a2,722 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02027fe:	06300593          	li	a1,99
ffffffffc0202802:	00005517          	auipc	a0,0x5
ffffffffc0202806:	c5e50513          	addi	a0,a0,-930 # ffffffffc0207460 <commands+0xda8>
ffffffffc020280a:	9fffd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc020280e:	00005697          	auipc	a3,0x5
ffffffffc0202812:	d0a68693          	addi	a3,a3,-758 # ffffffffc0207518 <commands+0xe60>
ffffffffc0202816:	00004617          	auipc	a2,0x4
ffffffffc020281a:	2b260613          	addi	a2,a2,690 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020281e:	06000593          	li	a1,96
ffffffffc0202822:	00005517          	auipc	a0,0x5
ffffffffc0202826:	c3e50513          	addi	a0,a0,-962 # ffffffffc0207460 <commands+0xda8>
ffffffffc020282a:	9dffd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc020282e:	00005697          	auipc	a3,0x5
ffffffffc0202832:	cea68693          	addi	a3,a3,-790 # ffffffffc0207518 <commands+0xe60>
ffffffffc0202836:	00004617          	auipc	a2,0x4
ffffffffc020283a:	29260613          	addi	a2,a2,658 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020283e:	05d00593          	li	a1,93
ffffffffc0202842:	00005517          	auipc	a0,0x5
ffffffffc0202846:	c1e50513          	addi	a0,a0,-994 # ffffffffc0207460 <commands+0xda8>
ffffffffc020284a:	9bffd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc020284e:	00005697          	auipc	a3,0x5
ffffffffc0202852:	c0268693          	addi	a3,a3,-1022 # ffffffffc0207450 <commands+0xd98>
ffffffffc0202856:	00004617          	auipc	a2,0x4
ffffffffc020285a:	27260613          	addi	a2,a2,626 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020285e:	05a00593          	li	a1,90
ffffffffc0202862:	00005517          	auipc	a0,0x5
ffffffffc0202866:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0207460 <commands+0xda8>
ffffffffc020286a:	99ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc020286e:	00005697          	auipc	a3,0x5
ffffffffc0202872:	be268693          	addi	a3,a3,-1054 # ffffffffc0207450 <commands+0xd98>
ffffffffc0202876:	00004617          	auipc	a2,0x4
ffffffffc020287a:	25260613          	addi	a2,a2,594 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020287e:	05700593          	li	a1,87
ffffffffc0202882:	00005517          	auipc	a0,0x5
ffffffffc0202886:	bde50513          	addi	a0,a0,-1058 # ffffffffc0207460 <commands+0xda8>
ffffffffc020288a:	97ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc020288e:	00005697          	auipc	a3,0x5
ffffffffc0202892:	bc268693          	addi	a3,a3,-1086 # ffffffffc0207450 <commands+0xd98>
ffffffffc0202896:	00004617          	auipc	a2,0x4
ffffffffc020289a:	23260613          	addi	a2,a2,562 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020289e:	05400593          	li	a1,84
ffffffffc02028a2:	00005517          	auipc	a0,0x5
ffffffffc02028a6:	bbe50513          	addi	a0,a0,-1090 # ffffffffc0207460 <commands+0xda8>
ffffffffc02028aa:	95ffd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02028ae <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02028ae:	751c                	ld	a5,40(a0)
{
ffffffffc02028b0:	1141                	addi	sp,sp,-16
ffffffffc02028b2:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02028b4:	cf91                	beqz	a5,ffffffffc02028d0 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc02028b6:	ee0d                	bnez	a2,ffffffffc02028f0 <_fifo_swap_out_victim+0x42>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02028b8:	679c                	ld	a5,8(a5)
}
ffffffffc02028ba:	60a2                	ld	ra,8(sp)
ffffffffc02028bc:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc02028be:	6394                	ld	a3,0(a5)
ffffffffc02028c0:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc02028c2:	fd878793          	addi	a5,a5,-40
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02028c6:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02028c8:	e314                	sd	a3,0(a4)
ffffffffc02028ca:	e19c                	sd	a5,0(a1)
}
ffffffffc02028cc:	0141                	addi	sp,sp,16
ffffffffc02028ce:	8082                	ret
         assert(head != NULL);
ffffffffc02028d0:	00005697          	auipc	a3,0x5
ffffffffc02028d4:	ce068693          	addi	a3,a3,-800 # ffffffffc02075b0 <commands+0xef8>
ffffffffc02028d8:	00004617          	auipc	a2,0x4
ffffffffc02028dc:	1f060613          	addi	a2,a2,496 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02028e0:	04100593          	li	a1,65
ffffffffc02028e4:	00005517          	auipc	a0,0x5
ffffffffc02028e8:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0207460 <commands+0xda8>
ffffffffc02028ec:	91dfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(in_tick==0);
ffffffffc02028f0:	00005697          	auipc	a3,0x5
ffffffffc02028f4:	cd068693          	addi	a3,a3,-816 # ffffffffc02075c0 <commands+0xf08>
ffffffffc02028f8:	00004617          	auipc	a2,0x4
ffffffffc02028fc:	1d060613          	addi	a2,a2,464 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202900:	04200593          	li	a1,66
ffffffffc0202904:	00005517          	auipc	a0,0x5
ffffffffc0202908:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0207460 <commands+0xda8>
ffffffffc020290c:	8fdfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202910 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202910:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0202912:	cb91                	beqz	a5,ffffffffc0202926 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202914:	6394                	ld	a3,0(a5)
ffffffffc0202916:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc020291a:	e398                	sd	a4,0(a5)
ffffffffc020291c:	e698                	sd	a4,8(a3)
}
ffffffffc020291e:	4501                	li	a0,0
    elm->next = next;
ffffffffc0202920:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0202922:	f614                	sd	a3,40(a2)
ffffffffc0202924:	8082                	ret
{
ffffffffc0202926:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0202928:	00005697          	auipc	a3,0x5
ffffffffc020292c:	ca868693          	addi	a3,a3,-856 # ffffffffc02075d0 <commands+0xf18>
ffffffffc0202930:	00004617          	auipc	a2,0x4
ffffffffc0202934:	19860613          	addi	a2,a2,408 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202938:	03200593          	li	a1,50
ffffffffc020293c:	00005517          	auipc	a0,0x5
ffffffffc0202940:	b2450513          	addi	a0,a0,-1244 # ffffffffc0207460 <commands+0xda8>
{
ffffffffc0202944:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0202946:	8c3fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020294a <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020294a:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020294c:	00005697          	auipc	a3,0x5
ffffffffc0202950:	cbc68693          	addi	a3,a3,-836 # ffffffffc0207608 <commands+0xf50>
ffffffffc0202954:	00004617          	auipc	a2,0x4
ffffffffc0202958:	17460613          	addi	a2,a2,372 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020295c:	06d00593          	li	a1,109
ffffffffc0202960:	00005517          	auipc	a0,0x5
ffffffffc0202964:	cc850513          	addi	a0,a0,-824 # ffffffffc0207628 <commands+0xf70>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0202968:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020296a:	89ffd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020296e <mm_create>:
mm_create(void) {
ffffffffc020296e:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202970:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0202974:	e022                	sd	s0,0(sp)
ffffffffc0202976:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202978:	451000ef          	jal	ra,ffffffffc02035c8 <kmalloc>
ffffffffc020297c:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020297e:	c505                	beqz	a0,ffffffffc02029a6 <mm_create+0x38>
    elm->prev = elm->next = elm;
ffffffffc0202980:	e408                	sd	a0,8(s0)
ffffffffc0202982:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0202984:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0202988:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020298c:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202990:	000b0797          	auipc	a5,0xb0
ffffffffc0202994:	fb07a783          	lw	a5,-80(a5) # ffffffffc02b2940 <swap_init_ok>
ffffffffc0202998:	ef81                	bnez	a5,ffffffffc02029b0 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc020299a:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc020299e:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02029a2:	02043c23          	sd	zero,56(s0)
}
ffffffffc02029a6:	60a2                	ld	ra,8(sp)
ffffffffc02029a8:	8522                	mv	a0,s0
ffffffffc02029aa:	6402                	ld	s0,0(sp)
ffffffffc02029ac:	0141                	addi	sp,sp,16
ffffffffc02029ae:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02029b0:	524010ef          	jal	ra,ffffffffc0203ed4 <swap_init_mm>
ffffffffc02029b4:	b7ed                	j	ffffffffc020299e <mm_create+0x30>

ffffffffc02029b6 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02029b6:	1101                	addi	sp,sp,-32
ffffffffc02029b8:	e04a                	sd	s2,0(sp)
ffffffffc02029ba:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02029bc:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02029c0:	e822                	sd	s0,16(sp)
ffffffffc02029c2:	e426                	sd	s1,8(sp)
ffffffffc02029c4:	ec06                	sd	ra,24(sp)
ffffffffc02029c6:	84ae                	mv	s1,a1
ffffffffc02029c8:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02029ca:	3ff000ef          	jal	ra,ffffffffc02035c8 <kmalloc>
    if (vma != NULL) {
ffffffffc02029ce:	c509                	beqz	a0,ffffffffc02029d8 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02029d0:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02029d4:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02029d6:	cd00                	sw	s0,24(a0)
}
ffffffffc02029d8:	60e2                	ld	ra,24(sp)
ffffffffc02029da:	6442                	ld	s0,16(sp)
ffffffffc02029dc:	64a2                	ld	s1,8(sp)
ffffffffc02029de:	6902                	ld	s2,0(sp)
ffffffffc02029e0:	6105                	addi	sp,sp,32
ffffffffc02029e2:	8082                	ret

ffffffffc02029e4 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc02029e4:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc02029e6:	c505                	beqz	a0,ffffffffc0202a0e <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc02029e8:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02029ea:	c501                	beqz	a0,ffffffffc02029f2 <find_vma+0xe>
ffffffffc02029ec:	651c                	ld	a5,8(a0)
ffffffffc02029ee:	02f5f263          	bgeu	a1,a5,ffffffffc0202a12 <find_vma+0x2e>
    return listelm->next;
ffffffffc02029f2:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc02029f4:	00f68d63          	beq	a3,a5,ffffffffc0202a0e <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02029f8:	fe87b703          	ld	a4,-24(a5)
ffffffffc02029fc:	00e5e663          	bltu	a1,a4,ffffffffc0202a08 <find_vma+0x24>
ffffffffc0202a00:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202a04:	00e5ec63          	bltu	a1,a4,ffffffffc0202a1c <find_vma+0x38>
ffffffffc0202a08:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0202a0a:	fef697e3          	bne	a3,a5,ffffffffc02029f8 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0202a0e:	4501                	li	a0,0
}
ffffffffc0202a10:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202a12:	691c                	ld	a5,16(a0)
ffffffffc0202a14:	fcf5ffe3          	bgeu	a1,a5,ffffffffc02029f2 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0202a18:	ea88                	sd	a0,16(a3)
ffffffffc0202a1a:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0202a1c:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0202a20:	ea88                	sd	a0,16(a3)
ffffffffc0202a22:	8082                	ret

ffffffffc0202a24 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202a24:	6590                	ld	a2,8(a1)
ffffffffc0202a26:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0202a2a:	1141                	addi	sp,sp,-16
ffffffffc0202a2c:	e406                	sd	ra,8(sp)
ffffffffc0202a2e:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202a30:	01066763          	bltu	a2,a6,ffffffffc0202a3e <insert_vma_struct+0x1a>
ffffffffc0202a34:	a085                	j	ffffffffc0202a94 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0202a36:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202a3a:	04e66863          	bltu	a2,a4,ffffffffc0202a8a <insert_vma_struct+0x66>
ffffffffc0202a3e:	86be                	mv	a3,a5
ffffffffc0202a40:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0202a42:	fef51ae3          	bne	a0,a5,ffffffffc0202a36 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0202a46:	02a68463          	beq	a3,a0,ffffffffc0202a6e <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0202a4a:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202a4e:	fe86b883          	ld	a7,-24(a3)
ffffffffc0202a52:	08e8f163          	bgeu	a7,a4,ffffffffc0202ad4 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202a56:	04e66f63          	bltu	a2,a4,ffffffffc0202ab4 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0202a5a:	00f50a63          	beq	a0,a5,ffffffffc0202a6e <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0202a5e:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202a62:	05076963          	bltu	a4,a6,ffffffffc0202ab4 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0202a66:	ff07b603          	ld	a2,-16(a5)
ffffffffc0202a6a:	02c77363          	bgeu	a4,a2,ffffffffc0202a90 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0202a6e:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0202a70:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0202a72:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0202a76:	e390                	sd	a2,0(a5)
ffffffffc0202a78:	e690                	sd	a2,8(a3)
}
ffffffffc0202a7a:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0202a7c:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0202a7e:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0202a80:	0017079b          	addiw	a5,a4,1
ffffffffc0202a84:	d11c                	sw	a5,32(a0)
}
ffffffffc0202a86:	0141                	addi	sp,sp,16
ffffffffc0202a88:	8082                	ret
    if (le_prev != list) {
ffffffffc0202a8a:	fca690e3          	bne	a3,a0,ffffffffc0202a4a <insert_vma_struct+0x26>
ffffffffc0202a8e:	bfd1                	j	ffffffffc0202a62 <insert_vma_struct+0x3e>
ffffffffc0202a90:	ebbff0ef          	jal	ra,ffffffffc020294a <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202a94:	00005697          	auipc	a3,0x5
ffffffffc0202a98:	ba468693          	addi	a3,a3,-1116 # ffffffffc0207638 <commands+0xf80>
ffffffffc0202a9c:	00004617          	auipc	a2,0x4
ffffffffc0202aa0:	02c60613          	addi	a2,a2,44 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202aa4:	07400593          	li	a1,116
ffffffffc0202aa8:	00005517          	auipc	a0,0x5
ffffffffc0202aac:	b8050513          	addi	a0,a0,-1152 # ffffffffc0207628 <commands+0xf70>
ffffffffc0202ab0:	f58fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202ab4:	00005697          	auipc	a3,0x5
ffffffffc0202ab8:	bc468693          	addi	a3,a3,-1084 # ffffffffc0207678 <commands+0xfc0>
ffffffffc0202abc:	00004617          	auipc	a2,0x4
ffffffffc0202ac0:	00c60613          	addi	a2,a2,12 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202ac4:	06c00593          	li	a1,108
ffffffffc0202ac8:	00005517          	auipc	a0,0x5
ffffffffc0202acc:	b6050513          	addi	a0,a0,-1184 # ffffffffc0207628 <commands+0xf70>
ffffffffc0202ad0:	f38fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202ad4:	00005697          	auipc	a3,0x5
ffffffffc0202ad8:	b8468693          	addi	a3,a3,-1148 # ffffffffc0207658 <commands+0xfa0>
ffffffffc0202adc:	00004617          	auipc	a2,0x4
ffffffffc0202ae0:	fec60613          	addi	a2,a2,-20 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202ae4:	06b00593          	li	a1,107
ffffffffc0202ae8:	00005517          	auipc	a0,0x5
ffffffffc0202aec:	b4050513          	addi	a0,a0,-1216 # ffffffffc0207628 <commands+0xf70>
ffffffffc0202af0:	f18fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202af4 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0202af4:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0202af6:	1141                	addi	sp,sp,-16
ffffffffc0202af8:	e406                	sd	ra,8(sp)
ffffffffc0202afa:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0202afc:	e78d                	bnez	a5,ffffffffc0202b26 <mm_destroy+0x32>
ffffffffc0202afe:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0202b00:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0202b02:	00a40c63          	beq	s0,a0,ffffffffc0202b1a <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202b06:	6118                	ld	a4,0(a0)
ffffffffc0202b08:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0202b0a:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0202b0c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202b0e:	e398                	sd	a4,0(a5)
ffffffffc0202b10:	369000ef          	jal	ra,ffffffffc0203678 <kfree>
    return listelm->next;
ffffffffc0202b14:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0202b16:	fea418e3          	bne	s0,a0,ffffffffc0202b06 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0202b1a:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0202b1c:	6402                	ld	s0,0(sp)
ffffffffc0202b1e:	60a2                	ld	ra,8(sp)
ffffffffc0202b20:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0202b22:	3570006f          	j	ffffffffc0203678 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0202b26:	00005697          	auipc	a3,0x5
ffffffffc0202b2a:	b7268693          	addi	a3,a3,-1166 # ffffffffc0207698 <commands+0xfe0>
ffffffffc0202b2e:	00004617          	auipc	a2,0x4
ffffffffc0202b32:	f9a60613          	addi	a2,a2,-102 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202b36:	09400593          	li	a1,148
ffffffffc0202b3a:	00005517          	auipc	a0,0x5
ffffffffc0202b3e:	aee50513          	addi	a0,a0,-1298 # ffffffffc0207628 <commands+0xf70>
ffffffffc0202b42:	ec6fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202b46 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc0202b46:	7139                	addi	sp,sp,-64
ffffffffc0202b48:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202b4a:	6405                	lui	s0,0x1
ffffffffc0202b4c:	147d                	addi	s0,s0,-1
ffffffffc0202b4e:	77fd                	lui	a5,0xfffff
ffffffffc0202b50:	9622                	add	a2,a2,s0
ffffffffc0202b52:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc0202b54:	f426                	sd	s1,40(sp)
ffffffffc0202b56:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202b58:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc0202b5c:	f04a                	sd	s2,32(sp)
ffffffffc0202b5e:	ec4e                	sd	s3,24(sp)
ffffffffc0202b60:	e852                	sd	s4,16(sp)
ffffffffc0202b62:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc0202b64:	002005b7          	lui	a1,0x200
ffffffffc0202b68:	00f67433          	and	s0,a2,a5
ffffffffc0202b6c:	06b4e363          	bltu	s1,a1,ffffffffc0202bd2 <mm_map+0x8c>
ffffffffc0202b70:	0684f163          	bgeu	s1,s0,ffffffffc0202bd2 <mm_map+0x8c>
ffffffffc0202b74:	4785                	li	a5,1
ffffffffc0202b76:	07fe                	slli	a5,a5,0x1f
ffffffffc0202b78:	0487ed63          	bltu	a5,s0,ffffffffc0202bd2 <mm_map+0x8c>
ffffffffc0202b7c:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0202b7e:	cd21                	beqz	a0,ffffffffc0202bd6 <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0202b80:	85a6                	mv	a1,s1
ffffffffc0202b82:	8ab6                	mv	s5,a3
ffffffffc0202b84:	8a3a                	mv	s4,a4
ffffffffc0202b86:	e5fff0ef          	jal	ra,ffffffffc02029e4 <find_vma>
ffffffffc0202b8a:	c501                	beqz	a0,ffffffffc0202b92 <mm_map+0x4c>
ffffffffc0202b8c:	651c                	ld	a5,8(a0)
ffffffffc0202b8e:	0487e263          	bltu	a5,s0,ffffffffc0202bd2 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202b92:	03000513          	li	a0,48
ffffffffc0202b96:	233000ef          	jal	ra,ffffffffc02035c8 <kmalloc>
ffffffffc0202b9a:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0202b9c:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0202b9e:	02090163          	beqz	s2,ffffffffc0202bc0 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0202ba2:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0202ba4:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0202ba8:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0202bac:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0202bb0:	85ca                	mv	a1,s2
ffffffffc0202bb2:	e73ff0ef          	jal	ra,ffffffffc0202a24 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0202bb6:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0202bb8:	000a0463          	beqz	s4,ffffffffc0202bc0 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0202bbc:	012a3023          	sd	s2,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>

out:
    return ret;
}
ffffffffc0202bc0:	70e2                	ld	ra,56(sp)
ffffffffc0202bc2:	7442                	ld	s0,48(sp)
ffffffffc0202bc4:	74a2                	ld	s1,40(sp)
ffffffffc0202bc6:	7902                	ld	s2,32(sp)
ffffffffc0202bc8:	69e2                	ld	s3,24(sp)
ffffffffc0202bca:	6a42                	ld	s4,16(sp)
ffffffffc0202bcc:	6aa2                	ld	s5,8(sp)
ffffffffc0202bce:	6121                	addi	sp,sp,64
ffffffffc0202bd0:	8082                	ret
        return -E_INVAL;
ffffffffc0202bd2:	5575                	li	a0,-3
ffffffffc0202bd4:	b7f5                	j	ffffffffc0202bc0 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0202bd6:	00005697          	auipc	a3,0x5
ffffffffc0202bda:	ada68693          	addi	a3,a3,-1318 # ffffffffc02076b0 <commands+0xff8>
ffffffffc0202bde:	00004617          	auipc	a2,0x4
ffffffffc0202be2:	eea60613          	addi	a2,a2,-278 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202be6:	0a700593          	li	a1,167
ffffffffc0202bea:	00005517          	auipc	a0,0x5
ffffffffc0202bee:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0207628 <commands+0xf70>
ffffffffc0202bf2:	e16fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202bf6 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0202bf6:	7139                	addi	sp,sp,-64
ffffffffc0202bf8:	fc06                	sd	ra,56(sp)
ffffffffc0202bfa:	f822                	sd	s0,48(sp)
ffffffffc0202bfc:	f426                	sd	s1,40(sp)
ffffffffc0202bfe:	f04a                	sd	s2,32(sp)
ffffffffc0202c00:	ec4e                	sd	s3,24(sp)
ffffffffc0202c02:	e852                	sd	s4,16(sp)
ffffffffc0202c04:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0202c06:	c52d                	beqz	a0,ffffffffc0202c70 <dup_mmap+0x7a>
ffffffffc0202c08:	892a                	mv	s2,a0
ffffffffc0202c0a:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0202c0c:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0202c0e:	e595                	bnez	a1,ffffffffc0202c3a <dup_mmap+0x44>
ffffffffc0202c10:	a085                	j	ffffffffc0202c70 <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0202c12:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0202c14:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ed8>
        vma->vm_end = vm_end;
ffffffffc0202c18:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0202c1c:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0202c20:	e05ff0ef          	jal	ra,ffffffffc0202a24 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0202c24:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bd0>
ffffffffc0202c28:	fe843603          	ld	a2,-24(s0)
ffffffffc0202c2c:	6c8c                	ld	a1,24(s1)
ffffffffc0202c2e:	01893503          	ld	a0,24(s2)
ffffffffc0202c32:	4701                	li	a4,0
ffffffffc0202c34:	e38ff0ef          	jal	ra,ffffffffc020226c <copy_range>
ffffffffc0202c38:	e105                	bnez	a0,ffffffffc0202c58 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0202c3a:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0202c3c:	02848863          	beq	s1,s0,ffffffffc0202c6c <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202c40:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0202c44:	fe843a83          	ld	s5,-24(s0)
ffffffffc0202c48:	ff043a03          	ld	s4,-16(s0)
ffffffffc0202c4c:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202c50:	179000ef          	jal	ra,ffffffffc02035c8 <kmalloc>
ffffffffc0202c54:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc0202c56:	fd55                	bnez	a0,ffffffffc0202c12 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0202c58:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0202c5a:	70e2                	ld	ra,56(sp)
ffffffffc0202c5c:	7442                	ld	s0,48(sp)
ffffffffc0202c5e:	74a2                	ld	s1,40(sp)
ffffffffc0202c60:	7902                	ld	s2,32(sp)
ffffffffc0202c62:	69e2                	ld	s3,24(sp)
ffffffffc0202c64:	6a42                	ld	s4,16(sp)
ffffffffc0202c66:	6aa2                	ld	s5,8(sp)
ffffffffc0202c68:	6121                	addi	sp,sp,64
ffffffffc0202c6a:	8082                	ret
    return 0;
ffffffffc0202c6c:	4501                	li	a0,0
ffffffffc0202c6e:	b7f5                	j	ffffffffc0202c5a <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0202c70:	00005697          	auipc	a3,0x5
ffffffffc0202c74:	a5068693          	addi	a3,a3,-1456 # ffffffffc02076c0 <commands+0x1008>
ffffffffc0202c78:	00004617          	auipc	a2,0x4
ffffffffc0202c7c:	e5060613          	addi	a2,a2,-432 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202c80:	0c000593          	li	a1,192
ffffffffc0202c84:	00005517          	auipc	a0,0x5
ffffffffc0202c88:	9a450513          	addi	a0,a0,-1628 # ffffffffc0207628 <commands+0xf70>
ffffffffc0202c8c:	d7cfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202c90 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0202c90:	1101                	addi	sp,sp,-32
ffffffffc0202c92:	ec06                	sd	ra,24(sp)
ffffffffc0202c94:	e822                	sd	s0,16(sp)
ffffffffc0202c96:	e426                	sd	s1,8(sp)
ffffffffc0202c98:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202c9a:	c531                	beqz	a0,ffffffffc0202ce6 <exit_mmap+0x56>
ffffffffc0202c9c:	591c                	lw	a5,48(a0)
ffffffffc0202c9e:	84aa                	mv	s1,a0
ffffffffc0202ca0:	e3b9                	bnez	a5,ffffffffc0202ce6 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0202ca2:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0202ca4:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0202ca8:	02850663          	beq	a0,s0,ffffffffc0202cd4 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202cac:	ff043603          	ld	a2,-16(s0)
ffffffffc0202cb0:	fe843583          	ld	a1,-24(s0)
ffffffffc0202cb4:	854a                	mv	a0,s2
ffffffffc0202cb6:	cb2fe0ef          	jal	ra,ffffffffc0201168 <unmap_range>
ffffffffc0202cba:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202cbc:	fe8498e3          	bne	s1,s0,ffffffffc0202cac <exit_mmap+0x1c>
ffffffffc0202cc0:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0202cc2:	00848c63          	beq	s1,s0,ffffffffc0202cda <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202cc6:	ff043603          	ld	a2,-16(s0)
ffffffffc0202cca:	fe843583          	ld	a1,-24(s0)
ffffffffc0202cce:	854a                	mv	a0,s2
ffffffffc0202cd0:	ddefe0ef          	jal	ra,ffffffffc02012ae <exit_range>
ffffffffc0202cd4:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202cd6:	fe8498e3          	bne	s1,s0,ffffffffc0202cc6 <exit_mmap+0x36>
    }
}
ffffffffc0202cda:	60e2                	ld	ra,24(sp)
ffffffffc0202cdc:	6442                	ld	s0,16(sp)
ffffffffc0202cde:	64a2                	ld	s1,8(sp)
ffffffffc0202ce0:	6902                	ld	s2,0(sp)
ffffffffc0202ce2:	6105                	addi	sp,sp,32
ffffffffc0202ce4:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202ce6:	00005697          	auipc	a3,0x5
ffffffffc0202cea:	9fa68693          	addi	a3,a3,-1542 # ffffffffc02076e0 <commands+0x1028>
ffffffffc0202cee:	00004617          	auipc	a2,0x4
ffffffffc0202cf2:	dda60613          	addi	a2,a2,-550 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202cf6:	0d600593          	li	a1,214
ffffffffc0202cfa:	00005517          	auipc	a0,0x5
ffffffffc0202cfe:	92e50513          	addi	a0,a0,-1746 # ffffffffc0207628 <commands+0xf70>
ffffffffc0202d02:	d06fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202d06 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0202d06:	7139                	addi	sp,sp,-64
ffffffffc0202d08:	f822                	sd	s0,48(sp)
ffffffffc0202d0a:	f426                	sd	s1,40(sp)
ffffffffc0202d0c:	fc06                	sd	ra,56(sp)
ffffffffc0202d0e:	f04a                	sd	s2,32(sp)
ffffffffc0202d10:	ec4e                	sd	s3,24(sp)
ffffffffc0202d12:	e852                	sd	s4,16(sp)
ffffffffc0202d14:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0202d16:	c59ff0ef          	jal	ra,ffffffffc020296e <mm_create>
    assert(mm != NULL);
ffffffffc0202d1a:	84aa                	mv	s1,a0
ffffffffc0202d1c:	03200413          	li	s0,50
ffffffffc0202d20:	e919                	bnez	a0,ffffffffc0202d36 <vmm_init+0x30>
ffffffffc0202d22:	a991                	j	ffffffffc0203176 <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc0202d24:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202d26:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202d28:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0202d2c:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202d2e:	8526                	mv	a0,s1
ffffffffc0202d30:	cf5ff0ef          	jal	ra,ffffffffc0202a24 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0202d34:	c80d                	beqz	s0,ffffffffc0202d66 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202d36:	03000513          	li	a0,48
ffffffffc0202d3a:	08f000ef          	jal	ra,ffffffffc02035c8 <kmalloc>
ffffffffc0202d3e:	85aa                	mv	a1,a0
ffffffffc0202d40:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0202d44:	f165                	bnez	a0,ffffffffc0202d24 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0202d46:	00005697          	auipc	a3,0x5
ffffffffc0202d4a:	bd268693          	addi	a3,a3,-1070 # ffffffffc0207918 <commands+0x1260>
ffffffffc0202d4e:	00004617          	auipc	a2,0x4
ffffffffc0202d52:	d7a60613          	addi	a2,a2,-646 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202d56:	11300593          	li	a1,275
ffffffffc0202d5a:	00005517          	auipc	a0,0x5
ffffffffc0202d5e:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0207628 <commands+0xf70>
ffffffffc0202d62:	ca6fd0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0202d66:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202d6a:	1f900913          	li	s2,505
ffffffffc0202d6e:	a819                	j	ffffffffc0202d84 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0202d70:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202d72:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202d74:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202d78:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202d7a:	8526                	mv	a0,s1
ffffffffc0202d7c:	ca9ff0ef          	jal	ra,ffffffffc0202a24 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202d80:	03240a63          	beq	s0,s2,ffffffffc0202db4 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202d84:	03000513          	li	a0,48
ffffffffc0202d88:	041000ef          	jal	ra,ffffffffc02035c8 <kmalloc>
ffffffffc0202d8c:	85aa                	mv	a1,a0
ffffffffc0202d8e:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0202d92:	fd79                	bnez	a0,ffffffffc0202d70 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0202d94:	00005697          	auipc	a3,0x5
ffffffffc0202d98:	b8468693          	addi	a3,a3,-1148 # ffffffffc0207918 <commands+0x1260>
ffffffffc0202d9c:	00004617          	auipc	a2,0x4
ffffffffc0202da0:	d2c60613          	addi	a2,a2,-724 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202da4:	11900593          	li	a1,281
ffffffffc0202da8:	00005517          	auipc	a0,0x5
ffffffffc0202dac:	88050513          	addi	a0,a0,-1920 # ffffffffc0207628 <commands+0xf70>
ffffffffc0202db0:	c58fd0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0202db4:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc0202db6:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc0202db8:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0202dbc:	2cf48d63          	beq	s1,a5,ffffffffc0203096 <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202dc0:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c684>
ffffffffc0202dc4:	ffe70613          	addi	a2,a4,-2
ffffffffc0202dc8:	24d61763          	bne	a2,a3,ffffffffc0203016 <vmm_init+0x310>
ffffffffc0202dcc:	ff07b683          	ld	a3,-16(a5)
ffffffffc0202dd0:	24e69363          	bne	a3,a4,ffffffffc0203016 <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc0202dd4:	0715                	addi	a4,a4,5
ffffffffc0202dd6:	679c                	ld	a5,8(a5)
ffffffffc0202dd8:	feb712e3          	bne	a4,a1,ffffffffc0202dbc <vmm_init+0xb6>
ffffffffc0202ddc:	4a1d                	li	s4,7
ffffffffc0202dde:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202de0:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202de4:	85a2                	mv	a1,s0
ffffffffc0202de6:	8526                	mv	a0,s1
ffffffffc0202de8:	bfdff0ef          	jal	ra,ffffffffc02029e4 <find_vma>
ffffffffc0202dec:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0202dee:	30050463          	beqz	a0,ffffffffc02030f6 <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0202df2:	00140593          	addi	a1,s0,1
ffffffffc0202df6:	8526                	mv	a0,s1
ffffffffc0202df8:	bedff0ef          	jal	ra,ffffffffc02029e4 <find_vma>
ffffffffc0202dfc:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0202dfe:	2c050c63          	beqz	a0,ffffffffc02030d6 <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0202e02:	85d2                	mv	a1,s4
ffffffffc0202e04:	8526                	mv	a0,s1
ffffffffc0202e06:	bdfff0ef          	jal	ra,ffffffffc02029e4 <find_vma>
        assert(vma3 == NULL);
ffffffffc0202e0a:	2a051663          	bnez	a0,ffffffffc02030b6 <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0202e0e:	00340593          	addi	a1,s0,3
ffffffffc0202e12:	8526                	mv	a0,s1
ffffffffc0202e14:	bd1ff0ef          	jal	ra,ffffffffc02029e4 <find_vma>
        assert(vma4 == NULL);
ffffffffc0202e18:	30051f63          	bnez	a0,ffffffffc0203136 <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0202e1c:	00440593          	addi	a1,s0,4
ffffffffc0202e20:	8526                	mv	a0,s1
ffffffffc0202e22:	bc3ff0ef          	jal	ra,ffffffffc02029e4 <find_vma>
        assert(vma5 == NULL);
ffffffffc0202e26:	2e051863          	bnez	a0,ffffffffc0203116 <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202e2a:	00893783          	ld	a5,8(s2)
ffffffffc0202e2e:	20879463          	bne	a5,s0,ffffffffc0203036 <vmm_init+0x330>
ffffffffc0202e32:	01093783          	ld	a5,16(s2)
ffffffffc0202e36:	20fa1063          	bne	s4,a5,ffffffffc0203036 <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202e3a:	0089b783          	ld	a5,8(s3)
ffffffffc0202e3e:	20879c63          	bne	a5,s0,ffffffffc0203056 <vmm_init+0x350>
ffffffffc0202e42:	0109b783          	ld	a5,16(s3)
ffffffffc0202e46:	20fa1863          	bne	s4,a5,ffffffffc0203056 <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202e4a:	0415                	addi	s0,s0,5
ffffffffc0202e4c:	0a15                	addi	s4,s4,5
ffffffffc0202e4e:	f9541be3          	bne	s0,s5,ffffffffc0202de4 <vmm_init+0xde>
ffffffffc0202e52:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0202e54:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0202e56:	85a2                	mv	a1,s0
ffffffffc0202e58:	8526                	mv	a0,s1
ffffffffc0202e5a:	b8bff0ef          	jal	ra,ffffffffc02029e4 <find_vma>
ffffffffc0202e5e:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0202e62:	c90d                	beqz	a0,ffffffffc0202e94 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0202e64:	6914                	ld	a3,16(a0)
ffffffffc0202e66:	6510                	ld	a2,8(a0)
ffffffffc0202e68:	00005517          	auipc	a0,0x5
ffffffffc0202e6c:	99850513          	addi	a0,a0,-1640 # ffffffffc0207800 <commands+0x1148>
ffffffffc0202e70:	a5cfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0202e74:	00005697          	auipc	a3,0x5
ffffffffc0202e78:	9b468693          	addi	a3,a3,-1612 # ffffffffc0207828 <commands+0x1170>
ffffffffc0202e7c:	00004617          	auipc	a2,0x4
ffffffffc0202e80:	c4c60613          	addi	a2,a2,-948 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0202e84:	13b00593          	li	a1,315
ffffffffc0202e88:	00004517          	auipc	a0,0x4
ffffffffc0202e8c:	7a050513          	addi	a0,a0,1952 # ffffffffc0207628 <commands+0xf70>
ffffffffc0202e90:	b78fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0202e94:	147d                	addi	s0,s0,-1
ffffffffc0202e96:	fd2410e3          	bne	s0,s2,ffffffffc0202e56 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0202e9a:	8526                	mv	a0,s1
ffffffffc0202e9c:	c59ff0ef          	jal	ra,ffffffffc0202af4 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0202ea0:	00005517          	auipc	a0,0x5
ffffffffc0202ea4:	9a050513          	addi	a0,a0,-1632 # ffffffffc0207840 <commands+0x1188>
ffffffffc0202ea8:	a24fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202eac:	85cfe0ef          	jal	ra,ffffffffc0200f08 <nr_free_pages>
ffffffffc0202eb0:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc0202eb2:	abdff0ef          	jal	ra,ffffffffc020296e <mm_create>
ffffffffc0202eb6:	000b0797          	auipc	a5,0xb0
ffffffffc0202eba:	a6a7b123          	sd	a0,-1438(a5) # ffffffffc02b2918 <check_mm_struct>
ffffffffc0202ebe:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc0202ec0:	28050b63          	beqz	a0,ffffffffc0203156 <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202ec4:	000b0497          	auipc	s1,0xb0
ffffffffc0202ec8:	a2c4b483          	ld	s1,-1492(s1) # ffffffffc02b28f0 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0202ecc:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202ece:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0202ed0:	2e079f63          	bnez	a5,ffffffffc02031ce <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202ed4:	03000513          	li	a0,48
ffffffffc0202ed8:	6f0000ef          	jal	ra,ffffffffc02035c8 <kmalloc>
ffffffffc0202edc:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0202ede:	18050c63          	beqz	a0,ffffffffc0203076 <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc0202ee2:	002007b7          	lui	a5,0x200
ffffffffc0202ee6:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0202eea:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0202eec:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0202eee:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0202ef2:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0202ef4:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0202ef8:	b2dff0ef          	jal	ra,ffffffffc0202a24 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0202efc:	10000593          	li	a1,256
ffffffffc0202f00:	8522                	mv	a0,s0
ffffffffc0202f02:	ae3ff0ef          	jal	ra,ffffffffc02029e4 <find_vma>
ffffffffc0202f06:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc0202f0a:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0202f0e:	2ea99063          	bne	s3,a0,ffffffffc02031ee <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc0202f12:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ed0>
    for (i = 0; i < 100; i ++) {
ffffffffc0202f16:	0785                	addi	a5,a5,1
ffffffffc0202f18:	fee79de3          	bne	a5,a4,ffffffffc0202f12 <vmm_init+0x20c>
        sum += i;
ffffffffc0202f1c:	6705                	lui	a4,0x1
ffffffffc0202f1e:	10000793          	li	a5,256
ffffffffc0202f22:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x886a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0202f26:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0202f2a:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0202f2e:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0202f30:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0202f32:	fec79ce3          	bne	a5,a2,ffffffffc0202f2a <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc0202f36:	2e071863          	bnez	a4,ffffffffc0203226 <vmm_init+0x520>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f3a:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0202f3c:	000b0a97          	auipc	s5,0xb0
ffffffffc0202f40:	9bca8a93          	addi	s5,s5,-1604 # ffffffffc02b28f8 <npage>
ffffffffc0202f44:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f48:	078a                	slli	a5,a5,0x2
ffffffffc0202f4a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f4c:	2cc7f163          	bgeu	a5,a2,ffffffffc020320e <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f50:	00006a17          	auipc	s4,0x6
ffffffffc0202f54:	b20a3a03          	ld	s4,-1248(s4) # ffffffffc0208a70 <nbase>
ffffffffc0202f58:	414787b3          	sub	a5,a5,s4
ffffffffc0202f5c:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0202f5e:	8799                	srai	a5,a5,0x6
ffffffffc0202f60:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0202f62:	00c79713          	slli	a4,a5,0xc
ffffffffc0202f66:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202f68:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202f6c:	24c77563          	bgeu	a4,a2,ffffffffc02031b6 <vmm_init+0x4b0>
ffffffffc0202f70:	000b0997          	auipc	s3,0xb0
ffffffffc0202f74:	9a09b983          	ld	s3,-1632(s3) # ffffffffc02b2910 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0202f78:	4581                	li	a1,0
ffffffffc0202f7a:	8526                	mv	a0,s1
ffffffffc0202f7c:	99b6                	add	s3,s3,a3
ffffffffc0202f7e:	dc2fe0ef          	jal	ra,ffffffffc0201540 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f82:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202f86:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f8a:	078a                	slli	a5,a5,0x2
ffffffffc0202f8c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f8e:	28e7f063          	bgeu	a5,a4,ffffffffc020320e <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f92:	000b0997          	auipc	s3,0xb0
ffffffffc0202f96:	96e98993          	addi	s3,s3,-1682 # ffffffffc02b2900 <pages>
ffffffffc0202f9a:	0009b503          	ld	a0,0(s3)
ffffffffc0202f9e:	414787b3          	sub	a5,a5,s4
ffffffffc0202fa2:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202fa4:	953e                	add	a0,a0,a5
ffffffffc0202fa6:	4585                	li	a1,1
ffffffffc0202fa8:	f21fd0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fac:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0202fae:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fb2:	078a                	slli	a5,a5,0x2
ffffffffc0202fb4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202fb6:	24e7fc63          	bgeu	a5,a4,ffffffffc020320e <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fba:	0009b503          	ld	a0,0(s3)
ffffffffc0202fbe:	414787b3          	sub	a5,a5,s4
ffffffffc0202fc2:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202fc4:	4585                	li	a1,1
ffffffffc0202fc6:	953e                	add	a0,a0,a5
ffffffffc0202fc8:	f01fd0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    pgdir[0] = 0;
ffffffffc0202fcc:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc0202fd0:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0202fd4:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0202fd6:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0202fda:	b1bff0ef          	jal	ra,ffffffffc0202af4 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0202fde:	000b0797          	auipc	a5,0xb0
ffffffffc0202fe2:	9207bd23          	sd	zero,-1734(a5) # ffffffffc02b2918 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202fe6:	f23fd0ef          	jal	ra,ffffffffc0200f08 <nr_free_pages>
ffffffffc0202fea:	1aa91663          	bne	s2,a0,ffffffffc0203196 <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0202fee:	00005517          	auipc	a0,0x5
ffffffffc0202ff2:	8f250513          	addi	a0,a0,-1806 # ffffffffc02078e0 <commands+0x1228>
ffffffffc0202ff6:	8d6fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0202ffa:	7442                	ld	s0,48(sp)
ffffffffc0202ffc:	70e2                	ld	ra,56(sp)
ffffffffc0202ffe:	74a2                	ld	s1,40(sp)
ffffffffc0203000:	7902                	ld	s2,32(sp)
ffffffffc0203002:	69e2                	ld	s3,24(sp)
ffffffffc0203004:	6a42                	ld	s4,16(sp)
ffffffffc0203006:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203008:	00005517          	auipc	a0,0x5
ffffffffc020300c:	8f850513          	addi	a0,a0,-1800 # ffffffffc0207900 <commands+0x1248>
}
ffffffffc0203010:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203012:	8bafd06f          	j	ffffffffc02000cc <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203016:	00004697          	auipc	a3,0x4
ffffffffc020301a:	70268693          	addi	a3,a3,1794 # ffffffffc0207718 <commands+0x1060>
ffffffffc020301e:	00004617          	auipc	a2,0x4
ffffffffc0203022:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203026:	12200593          	li	a1,290
ffffffffc020302a:	00004517          	auipc	a0,0x4
ffffffffc020302e:	5fe50513          	addi	a0,a0,1534 # ffffffffc0207628 <commands+0xf70>
ffffffffc0203032:	9d6fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203036:	00004697          	auipc	a3,0x4
ffffffffc020303a:	76a68693          	addi	a3,a3,1898 # ffffffffc02077a0 <commands+0x10e8>
ffffffffc020303e:	00004617          	auipc	a2,0x4
ffffffffc0203042:	a8a60613          	addi	a2,a2,-1398 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203046:	13200593          	li	a1,306
ffffffffc020304a:	00004517          	auipc	a0,0x4
ffffffffc020304e:	5de50513          	addi	a0,a0,1502 # ffffffffc0207628 <commands+0xf70>
ffffffffc0203052:	9b6fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203056:	00004697          	auipc	a3,0x4
ffffffffc020305a:	77a68693          	addi	a3,a3,1914 # ffffffffc02077d0 <commands+0x1118>
ffffffffc020305e:	00004617          	auipc	a2,0x4
ffffffffc0203062:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203066:	13300593          	li	a1,307
ffffffffc020306a:	00004517          	auipc	a0,0x4
ffffffffc020306e:	5be50513          	addi	a0,a0,1470 # ffffffffc0207628 <commands+0xf70>
ffffffffc0203072:	996fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(vma != NULL);
ffffffffc0203076:	00005697          	auipc	a3,0x5
ffffffffc020307a:	8a268693          	addi	a3,a3,-1886 # ffffffffc0207918 <commands+0x1260>
ffffffffc020307e:	00004617          	auipc	a2,0x4
ffffffffc0203082:	a4a60613          	addi	a2,a2,-1462 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203086:	15200593          	li	a1,338
ffffffffc020308a:	00004517          	auipc	a0,0x4
ffffffffc020308e:	59e50513          	addi	a0,a0,1438 # ffffffffc0207628 <commands+0xf70>
ffffffffc0203092:	976fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203096:	00004697          	auipc	a3,0x4
ffffffffc020309a:	66a68693          	addi	a3,a3,1642 # ffffffffc0207700 <commands+0x1048>
ffffffffc020309e:	00004617          	auipc	a2,0x4
ffffffffc02030a2:	a2a60613          	addi	a2,a2,-1494 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02030a6:	12000593          	li	a1,288
ffffffffc02030aa:	00004517          	auipc	a0,0x4
ffffffffc02030ae:	57e50513          	addi	a0,a0,1406 # ffffffffc0207628 <commands+0xf70>
ffffffffc02030b2:	956fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma3 == NULL);
ffffffffc02030b6:	00004697          	auipc	a3,0x4
ffffffffc02030ba:	6ba68693          	addi	a3,a3,1722 # ffffffffc0207770 <commands+0x10b8>
ffffffffc02030be:	00004617          	auipc	a2,0x4
ffffffffc02030c2:	a0a60613          	addi	a2,a2,-1526 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02030c6:	12c00593          	li	a1,300
ffffffffc02030ca:	00004517          	auipc	a0,0x4
ffffffffc02030ce:	55e50513          	addi	a0,a0,1374 # ffffffffc0207628 <commands+0xf70>
ffffffffc02030d2:	936fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2 != NULL);
ffffffffc02030d6:	00004697          	auipc	a3,0x4
ffffffffc02030da:	68a68693          	addi	a3,a3,1674 # ffffffffc0207760 <commands+0x10a8>
ffffffffc02030de:	00004617          	auipc	a2,0x4
ffffffffc02030e2:	9ea60613          	addi	a2,a2,-1558 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02030e6:	12a00593          	li	a1,298
ffffffffc02030ea:	00004517          	auipc	a0,0x4
ffffffffc02030ee:	53e50513          	addi	a0,a0,1342 # ffffffffc0207628 <commands+0xf70>
ffffffffc02030f2:	916fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1 != NULL);
ffffffffc02030f6:	00004697          	auipc	a3,0x4
ffffffffc02030fa:	65a68693          	addi	a3,a3,1626 # ffffffffc0207750 <commands+0x1098>
ffffffffc02030fe:	00004617          	auipc	a2,0x4
ffffffffc0203102:	9ca60613          	addi	a2,a2,-1590 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203106:	12800593          	li	a1,296
ffffffffc020310a:	00004517          	auipc	a0,0x4
ffffffffc020310e:	51e50513          	addi	a0,a0,1310 # ffffffffc0207628 <commands+0xf70>
ffffffffc0203112:	8f6fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma5 == NULL);
ffffffffc0203116:	00004697          	auipc	a3,0x4
ffffffffc020311a:	67a68693          	addi	a3,a3,1658 # ffffffffc0207790 <commands+0x10d8>
ffffffffc020311e:	00004617          	auipc	a2,0x4
ffffffffc0203122:	9aa60613          	addi	a2,a2,-1622 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203126:	13000593          	li	a1,304
ffffffffc020312a:	00004517          	auipc	a0,0x4
ffffffffc020312e:	4fe50513          	addi	a0,a0,1278 # ffffffffc0207628 <commands+0xf70>
ffffffffc0203132:	8d6fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma4 == NULL);
ffffffffc0203136:	00004697          	auipc	a3,0x4
ffffffffc020313a:	64a68693          	addi	a3,a3,1610 # ffffffffc0207780 <commands+0x10c8>
ffffffffc020313e:	00004617          	auipc	a2,0x4
ffffffffc0203142:	98a60613          	addi	a2,a2,-1654 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203146:	12e00593          	li	a1,302
ffffffffc020314a:	00004517          	auipc	a0,0x4
ffffffffc020314e:	4de50513          	addi	a0,a0,1246 # ffffffffc0207628 <commands+0xf70>
ffffffffc0203152:	8b6fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203156:	00004697          	auipc	a3,0x4
ffffffffc020315a:	70a68693          	addi	a3,a3,1802 # ffffffffc0207860 <commands+0x11a8>
ffffffffc020315e:	00004617          	auipc	a2,0x4
ffffffffc0203162:	96a60613          	addi	a2,a2,-1686 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203166:	14b00593          	li	a1,331
ffffffffc020316a:	00004517          	auipc	a0,0x4
ffffffffc020316e:	4be50513          	addi	a0,a0,1214 # ffffffffc0207628 <commands+0xf70>
ffffffffc0203172:	896fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(mm != NULL);
ffffffffc0203176:	00004697          	auipc	a3,0x4
ffffffffc020317a:	53a68693          	addi	a3,a3,1338 # ffffffffc02076b0 <commands+0xff8>
ffffffffc020317e:	00004617          	auipc	a2,0x4
ffffffffc0203182:	94a60613          	addi	a2,a2,-1718 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203186:	10c00593          	li	a1,268
ffffffffc020318a:	00004517          	auipc	a0,0x4
ffffffffc020318e:	49e50513          	addi	a0,a0,1182 # ffffffffc0207628 <commands+0xf70>
ffffffffc0203192:	876fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203196:	00004697          	auipc	a3,0x4
ffffffffc020319a:	72268693          	addi	a3,a3,1826 # ffffffffc02078b8 <commands+0x1200>
ffffffffc020319e:	00004617          	auipc	a2,0x4
ffffffffc02031a2:	92a60613          	addi	a2,a2,-1750 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02031a6:	17000593          	li	a1,368
ffffffffc02031aa:	00004517          	auipc	a0,0x4
ffffffffc02031ae:	47e50513          	addi	a0,a0,1150 # ffffffffc0207628 <commands+0xf70>
ffffffffc02031b2:	856fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc02031b6:	00004617          	auipc	a2,0x4
ffffffffc02031ba:	c5a60613          	addi	a2,a2,-934 # ffffffffc0206e10 <commands+0x758>
ffffffffc02031be:	06900593          	li	a1,105
ffffffffc02031c2:	00004517          	auipc	a0,0x4
ffffffffc02031c6:	c1650513          	addi	a0,a0,-1002 # ffffffffc0206dd8 <commands+0x720>
ffffffffc02031ca:	83efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02031ce:	00004697          	auipc	a3,0x4
ffffffffc02031d2:	6aa68693          	addi	a3,a3,1706 # ffffffffc0207878 <commands+0x11c0>
ffffffffc02031d6:	00004617          	auipc	a2,0x4
ffffffffc02031da:	8f260613          	addi	a2,a2,-1806 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02031de:	14f00593          	li	a1,335
ffffffffc02031e2:	00004517          	auipc	a0,0x4
ffffffffc02031e6:	44650513          	addi	a0,a0,1094 # ffffffffc0207628 <commands+0xf70>
ffffffffc02031ea:	81efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02031ee:	00004697          	auipc	a3,0x4
ffffffffc02031f2:	69a68693          	addi	a3,a3,1690 # ffffffffc0207888 <commands+0x11d0>
ffffffffc02031f6:	00004617          	auipc	a2,0x4
ffffffffc02031fa:	8d260613          	addi	a2,a2,-1838 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02031fe:	15700593          	li	a1,343
ffffffffc0203202:	00004517          	auipc	a0,0x4
ffffffffc0203206:	42650513          	addi	a0,a0,1062 # ffffffffc0207628 <commands+0xf70>
ffffffffc020320a:	ffffc0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020320e:	00004617          	auipc	a2,0x4
ffffffffc0203212:	baa60613          	addi	a2,a2,-1110 # ffffffffc0206db8 <commands+0x700>
ffffffffc0203216:	06200593          	li	a1,98
ffffffffc020321a:	00004517          	auipc	a0,0x4
ffffffffc020321e:	bbe50513          	addi	a0,a0,-1090 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0203222:	fe7fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(sum == 0);
ffffffffc0203226:	00004697          	auipc	a3,0x4
ffffffffc020322a:	68268693          	addi	a3,a3,1666 # ffffffffc02078a8 <commands+0x11f0>
ffffffffc020322e:	00004617          	auipc	a2,0x4
ffffffffc0203232:	89a60613          	addi	a2,a2,-1894 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203236:	16300593          	li	a1,355
ffffffffc020323a:	00004517          	auipc	a0,0x4
ffffffffc020323e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0207628 <commands+0xf70>
ffffffffc0203242:	fc7fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203246 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203246:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203248:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020324a:	e822                	sd	s0,16(sp)
ffffffffc020324c:	e426                	sd	s1,8(sp)
ffffffffc020324e:	ec06                	sd	ra,24(sp)
ffffffffc0203250:	e04a                	sd	s2,0(sp)
ffffffffc0203252:	8432                	mv	s0,a2
ffffffffc0203254:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203256:	f8eff0ef          	jal	ra,ffffffffc02029e4 <find_vma>

    pgfault_num++;
ffffffffc020325a:	000af797          	auipc	a5,0xaf
ffffffffc020325e:	6c67a783          	lw	a5,1734(a5) # ffffffffc02b2920 <pgfault_num>
ffffffffc0203262:	2785                	addiw	a5,a5,1
ffffffffc0203264:	000af717          	auipc	a4,0xaf
ffffffffc0203268:	6af72e23          	sw	a5,1724(a4) # ffffffffc02b2920 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc020326c:	c931                	beqz	a0,ffffffffc02032c0 <do_pgfault+0x7a>
ffffffffc020326e:	651c                	ld	a5,8(a0)
ffffffffc0203270:	04f46863          	bltu	s0,a5,ffffffffc02032c0 <do_pgfault+0x7a>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203274:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203276:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203278:	8b89                	andi	a5,a5,2
ffffffffc020327a:	e39d                	bnez	a5,ffffffffc02032a0 <do_pgfault+0x5a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020327c:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020327e:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203280:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203282:	4605                	li	a2,1
ffffffffc0203284:	85a2                	mv	a1,s0
ffffffffc0203286:	cbdfd0ef          	jal	ra,ffffffffc0200f42 <get_pte>
ffffffffc020328a:	cd21                	beqz	a0,ffffffffc02032e2 <do_pgfault+0x9c>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc020328c:	610c                	ld	a1,0(a0)
ffffffffc020328e:	c999                	beqz	a1,ffffffffc02032a4 <do_pgfault+0x5e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203290:	000af797          	auipc	a5,0xaf
ffffffffc0203294:	6b07a783          	lw	a5,1712(a5) # ffffffffc02b2940 <swap_init_ok>
ffffffffc0203298:	cf8d                	beqz	a5,ffffffffc02032d2 <do_pgfault+0x8c>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc020329a:	02003c23          	sd	zero,56(zero) # 38 <_binary_obj___user_faultread_out_size-0x9b88>
ffffffffc020329e:	9002                	ebreak
        perm |= READ_WRITE;
ffffffffc02032a0:	495d                	li	s2,23
ffffffffc02032a2:	bfe9                	j	ffffffffc020327c <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02032a4:	6c88                	ld	a0,24(s1)
ffffffffc02032a6:	864a                	mv	a2,s2
ffffffffc02032a8:	85a2                	mv	a1,s0
ffffffffc02032aa:	9f8ff0ef          	jal	ra,ffffffffc02024a2 <pgdir_alloc_page>
ffffffffc02032ae:	87aa                	mv	a5,a0
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc02032b0:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02032b2:	c3a1                	beqz	a5,ffffffffc02032f2 <do_pgfault+0xac>
failed:
    return ret;
}
ffffffffc02032b4:	60e2                	ld	ra,24(sp)
ffffffffc02032b6:	6442                	ld	s0,16(sp)
ffffffffc02032b8:	64a2                	ld	s1,8(sp)
ffffffffc02032ba:	6902                	ld	s2,0(sp)
ffffffffc02032bc:	6105                	addi	sp,sp,32
ffffffffc02032be:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02032c0:	85a2                	mv	a1,s0
ffffffffc02032c2:	00004517          	auipc	a0,0x4
ffffffffc02032c6:	66650513          	addi	a0,a0,1638 # ffffffffc0207928 <commands+0x1270>
ffffffffc02032ca:	e03fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc02032ce:	5575                	li	a0,-3
        goto failed;
ffffffffc02032d0:	b7d5                	j	ffffffffc02032b4 <do_pgfault+0x6e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02032d2:	00004517          	auipc	a0,0x4
ffffffffc02032d6:	6ce50513          	addi	a0,a0,1742 # ffffffffc02079a0 <commands+0x12e8>
ffffffffc02032da:	df3fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02032de:	5571                	li	a0,-4
            goto failed;
ffffffffc02032e0:	bfd1                	j	ffffffffc02032b4 <do_pgfault+0x6e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc02032e2:	00004517          	auipc	a0,0x4
ffffffffc02032e6:	67650513          	addi	a0,a0,1654 # ffffffffc0207958 <commands+0x12a0>
ffffffffc02032ea:	de3fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02032ee:	5571                	li	a0,-4
        goto failed;
ffffffffc02032f0:	b7d1                	j	ffffffffc02032b4 <do_pgfault+0x6e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02032f2:	00004517          	auipc	a0,0x4
ffffffffc02032f6:	68650513          	addi	a0,a0,1670 # ffffffffc0207978 <commands+0x12c0>
ffffffffc02032fa:	dd3fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02032fe:	5571                	li	a0,-4
            goto failed;
ffffffffc0203300:	bf55                	j	ffffffffc02032b4 <do_pgfault+0x6e>

ffffffffc0203302 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0203302:	7179                	addi	sp,sp,-48
ffffffffc0203304:	f022                	sd	s0,32(sp)
ffffffffc0203306:	f406                	sd	ra,40(sp)
ffffffffc0203308:	ec26                	sd	s1,24(sp)
ffffffffc020330a:	e84a                	sd	s2,16(sp)
ffffffffc020330c:	e44e                	sd	s3,8(sp)
ffffffffc020330e:	e052                	sd	s4,0(sp)
ffffffffc0203310:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0203312:	c135                	beqz	a0,ffffffffc0203376 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0203314:	002007b7          	lui	a5,0x200
ffffffffc0203318:	04f5e663          	bltu	a1,a5,ffffffffc0203364 <user_mem_check+0x62>
ffffffffc020331c:	00c584b3          	add	s1,a1,a2
ffffffffc0203320:	0495f263          	bgeu	a1,s1,ffffffffc0203364 <user_mem_check+0x62>
ffffffffc0203324:	4785                	li	a5,1
ffffffffc0203326:	07fe                	slli	a5,a5,0x1f
ffffffffc0203328:	0297ee63          	bltu	a5,s1,ffffffffc0203364 <user_mem_check+0x62>
ffffffffc020332c:	892a                	mv	s2,a0
ffffffffc020332e:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0203330:	6a05                	lui	s4,0x1
ffffffffc0203332:	a821                	j	ffffffffc020334a <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0203334:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0203338:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc020333a:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc020333c:	c685                	beqz	a3,ffffffffc0203364 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc020333e:	c399                	beqz	a5,ffffffffc0203344 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0203340:	02e46263          	bltu	s0,a4,ffffffffc0203364 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203344:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0203346:	04947663          	bgeu	s0,s1,ffffffffc0203392 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc020334a:	85a2                	mv	a1,s0
ffffffffc020334c:	854a                	mv	a0,s2
ffffffffc020334e:	e96ff0ef          	jal	ra,ffffffffc02029e4 <find_vma>
ffffffffc0203352:	c909                	beqz	a0,ffffffffc0203364 <user_mem_check+0x62>
ffffffffc0203354:	6518                	ld	a4,8(a0)
ffffffffc0203356:	00e46763          	bltu	s0,a4,ffffffffc0203364 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc020335a:	4d1c                	lw	a5,24(a0)
ffffffffc020335c:	fc099ce3          	bnez	s3,ffffffffc0203334 <user_mem_check+0x32>
ffffffffc0203360:	8b85                	andi	a5,a5,1
ffffffffc0203362:	f3ed                	bnez	a5,ffffffffc0203344 <user_mem_check+0x42>
            return 0;
ffffffffc0203364:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0203366:	70a2                	ld	ra,40(sp)
ffffffffc0203368:	7402                	ld	s0,32(sp)
ffffffffc020336a:	64e2                	ld	s1,24(sp)
ffffffffc020336c:	6942                	ld	s2,16(sp)
ffffffffc020336e:	69a2                	ld	s3,8(sp)
ffffffffc0203370:	6a02                	ld	s4,0(sp)
ffffffffc0203372:	6145                	addi	sp,sp,48
ffffffffc0203374:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203376:	c02007b7          	lui	a5,0xc0200
ffffffffc020337a:	4501                	li	a0,0
ffffffffc020337c:	fef5e5e3          	bltu	a1,a5,ffffffffc0203366 <user_mem_check+0x64>
ffffffffc0203380:	962e                	add	a2,a2,a1
ffffffffc0203382:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203366 <user_mem_check+0x64>
ffffffffc0203386:	c8000537          	lui	a0,0xc8000
ffffffffc020338a:	0505                	addi	a0,a0,1
ffffffffc020338c:	00a63533          	sltu	a0,a2,a0
ffffffffc0203390:	bfd9                	j	ffffffffc0203366 <user_mem_check+0x64>
        return 1;
ffffffffc0203392:	4505                	li	a0,1
ffffffffc0203394:	bfc9                	j	ffffffffc0203366 <user_mem_check+0x64>

ffffffffc0203396 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0203396:	c94d                	beqz	a0,ffffffffc0203448 <slob_free+0xb2>
{
ffffffffc0203398:	1141                	addi	sp,sp,-16
ffffffffc020339a:	e022                	sd	s0,0(sp)
ffffffffc020339c:	e406                	sd	ra,8(sp)
ffffffffc020339e:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02033a0:	e9c1                	bnez	a1,ffffffffc0203430 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033a2:	100027f3          	csrr	a5,sstatus
ffffffffc02033a6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02033a8:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033aa:	ebd9                	bnez	a5,ffffffffc0203440 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02033ac:	000a4617          	auipc	a2,0xa4
ffffffffc02033b0:	04c60613          	addi	a2,a2,76 # ffffffffc02a73f8 <slobfree>
ffffffffc02033b4:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02033b6:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02033b8:	679c                	ld	a5,8(a5)
ffffffffc02033ba:	02877a63          	bgeu	a4,s0,ffffffffc02033ee <slob_free+0x58>
ffffffffc02033be:	00f46463          	bltu	s0,a5,ffffffffc02033c6 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02033c2:	fef76ae3          	bltu	a4,a5,ffffffffc02033b6 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc02033c6:	400c                	lw	a1,0(s0)
ffffffffc02033c8:	00459693          	slli	a3,a1,0x4
ffffffffc02033cc:	96a2                	add	a3,a3,s0
ffffffffc02033ce:	02d78a63          	beq	a5,a3,ffffffffc0203402 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02033d2:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc02033d4:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc02033d6:	00469793          	slli	a5,a3,0x4
ffffffffc02033da:	97ba                	add	a5,a5,a4
ffffffffc02033dc:	02f40e63          	beq	s0,a5,ffffffffc0203418 <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02033e0:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc02033e2:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc02033e4:	e129                	bnez	a0,ffffffffc0203426 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02033e6:	60a2                	ld	ra,8(sp)
ffffffffc02033e8:	6402                	ld	s0,0(sp)
ffffffffc02033ea:	0141                	addi	sp,sp,16
ffffffffc02033ec:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02033ee:	fcf764e3          	bltu	a4,a5,ffffffffc02033b6 <slob_free+0x20>
ffffffffc02033f2:	fcf472e3          	bgeu	s0,a5,ffffffffc02033b6 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc02033f6:	400c                	lw	a1,0(s0)
ffffffffc02033f8:	00459693          	slli	a3,a1,0x4
ffffffffc02033fc:	96a2                	add	a3,a3,s0
ffffffffc02033fe:	fcd79ae3          	bne	a5,a3,ffffffffc02033d2 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0203402:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0203404:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0203406:	9db5                	addw	a1,a1,a3
ffffffffc0203408:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc020340a:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020340c:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc020340e:	00469793          	slli	a5,a3,0x4
ffffffffc0203412:	97ba                	add	a5,a5,a4
ffffffffc0203414:	fcf416e3          	bne	s0,a5,ffffffffc02033e0 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0203418:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc020341a:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc020341c:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc020341e:	9ebd                	addw	a3,a3,a5
ffffffffc0203420:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0203422:	e70c                	sd	a1,8(a4)
ffffffffc0203424:	d169                	beqz	a0,ffffffffc02033e6 <slob_free+0x50>
}
ffffffffc0203426:	6402                	ld	s0,0(sp)
ffffffffc0203428:	60a2                	ld	ra,8(sp)
ffffffffc020342a:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020342c:	9f2fd06f          	j	ffffffffc020061e <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0203430:	25bd                	addiw	a1,a1,15
ffffffffc0203432:	8191                	srli	a1,a1,0x4
ffffffffc0203434:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203436:	100027f3          	csrr	a5,sstatus
ffffffffc020343a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020343c:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020343e:	d7bd                	beqz	a5,ffffffffc02033ac <slob_free+0x16>
        intr_disable();
ffffffffc0203440:	9e4fd0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc0203444:	4505                	li	a0,1
ffffffffc0203446:	b79d                	j	ffffffffc02033ac <slob_free+0x16>
ffffffffc0203448:	8082                	ret

ffffffffc020344a <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc020344a:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020344c:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc020344e:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0203452:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0203454:	9e3fd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
  if(!page)
ffffffffc0203458:	c91d                	beqz	a0,ffffffffc020348e <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc020345a:	000af697          	auipc	a3,0xaf
ffffffffc020345e:	4a66b683          	ld	a3,1190(a3) # ffffffffc02b2900 <pages>
ffffffffc0203462:	8d15                	sub	a0,a0,a3
ffffffffc0203464:	8519                	srai	a0,a0,0x6
ffffffffc0203466:	00005697          	auipc	a3,0x5
ffffffffc020346a:	60a6b683          	ld	a3,1546(a3) # ffffffffc0208a70 <nbase>
ffffffffc020346e:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0203470:	00c51793          	slli	a5,a0,0xc
ffffffffc0203474:	83b1                	srli	a5,a5,0xc
ffffffffc0203476:	000af717          	auipc	a4,0xaf
ffffffffc020347a:	48273703          	ld	a4,1154(a4) # ffffffffc02b28f8 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc020347e:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0203480:	00e7fa63          	bgeu	a5,a4,ffffffffc0203494 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0203484:	000af697          	auipc	a3,0xaf
ffffffffc0203488:	48c6b683          	ld	a3,1164(a3) # ffffffffc02b2910 <va_pa_offset>
ffffffffc020348c:	9536                	add	a0,a0,a3
}
ffffffffc020348e:	60a2                	ld	ra,8(sp)
ffffffffc0203490:	0141                	addi	sp,sp,16
ffffffffc0203492:	8082                	ret
ffffffffc0203494:	86aa                	mv	a3,a0
ffffffffc0203496:	00004617          	auipc	a2,0x4
ffffffffc020349a:	97a60613          	addi	a2,a2,-1670 # ffffffffc0206e10 <commands+0x758>
ffffffffc020349e:	06900593          	li	a1,105
ffffffffc02034a2:	00004517          	auipc	a0,0x4
ffffffffc02034a6:	93650513          	addi	a0,a0,-1738 # ffffffffc0206dd8 <commands+0x720>
ffffffffc02034aa:	d5ffc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02034ae <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02034ae:	1101                	addi	sp,sp,-32
ffffffffc02034b0:	ec06                	sd	ra,24(sp)
ffffffffc02034b2:	e822                	sd	s0,16(sp)
ffffffffc02034b4:	e426                	sd	s1,8(sp)
ffffffffc02034b6:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02034b8:	01050713          	addi	a4,a0,16
ffffffffc02034bc:	6785                	lui	a5,0x1
ffffffffc02034be:	0cf77363          	bgeu	a4,a5,ffffffffc0203584 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02034c2:	00f50493          	addi	s1,a0,15
ffffffffc02034c6:	8091                	srli	s1,s1,0x4
ffffffffc02034c8:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034ca:	10002673          	csrr	a2,sstatus
ffffffffc02034ce:	8a09                	andi	a2,a2,2
ffffffffc02034d0:	e25d                	bnez	a2,ffffffffc0203576 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc02034d2:	000a4917          	auipc	s2,0xa4
ffffffffc02034d6:	f2690913          	addi	s2,s2,-218 # ffffffffc02a73f8 <slobfree>
ffffffffc02034da:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02034de:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02034e0:	4398                	lw	a4,0(a5)
ffffffffc02034e2:	08975e63          	bge	a4,s1,ffffffffc020357e <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc02034e6:	00f68b63          	beq	a3,a5,ffffffffc02034fc <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02034ea:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02034ec:	4018                	lw	a4,0(s0)
ffffffffc02034ee:	02975a63          	bge	a4,s1,ffffffffc0203522 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc02034f2:	00093683          	ld	a3,0(s2)
ffffffffc02034f6:	87a2                	mv	a5,s0
ffffffffc02034f8:	fef699e3          	bne	a3,a5,ffffffffc02034ea <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc02034fc:	ee31                	bnez	a2,ffffffffc0203558 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02034fe:	4501                	li	a0,0
ffffffffc0203500:	f4bff0ef          	jal	ra,ffffffffc020344a <__slob_get_free_pages.constprop.0>
ffffffffc0203504:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0203506:	cd05                	beqz	a0,ffffffffc020353e <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0203508:	6585                	lui	a1,0x1
ffffffffc020350a:	e8dff0ef          	jal	ra,ffffffffc0203396 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020350e:	10002673          	csrr	a2,sstatus
ffffffffc0203512:	8a09                	andi	a2,a2,2
ffffffffc0203514:	ee05                	bnez	a2,ffffffffc020354c <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0203516:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020351a:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020351c:	4018                	lw	a4,0(s0)
ffffffffc020351e:	fc974ae3          	blt	a4,s1,ffffffffc02034f2 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0203522:	04e48763          	beq	s1,a4,ffffffffc0203570 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0203526:	00449693          	slli	a3,s1,0x4
ffffffffc020352a:	96a2                	add	a3,a3,s0
ffffffffc020352c:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc020352e:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0203530:	9f05                	subw	a4,a4,s1
ffffffffc0203532:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0203534:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0203536:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0203538:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc020353c:	e20d                	bnez	a2,ffffffffc020355e <slob_alloc.constprop.0+0xb0>
}
ffffffffc020353e:	60e2                	ld	ra,24(sp)
ffffffffc0203540:	8522                	mv	a0,s0
ffffffffc0203542:	6442                	ld	s0,16(sp)
ffffffffc0203544:	64a2                	ld	s1,8(sp)
ffffffffc0203546:	6902                	ld	s2,0(sp)
ffffffffc0203548:	6105                	addi	sp,sp,32
ffffffffc020354a:	8082                	ret
        intr_disable();
ffffffffc020354c:	8d8fd0ef          	jal	ra,ffffffffc0200624 <intr_disable>
			cur = slobfree;
ffffffffc0203550:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0203554:	4605                	li	a2,1
ffffffffc0203556:	b7d1                	j	ffffffffc020351a <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0203558:	8c6fd0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc020355c:	b74d                	j	ffffffffc02034fe <slob_alloc.constprop.0+0x50>
ffffffffc020355e:	8c0fd0ef          	jal	ra,ffffffffc020061e <intr_enable>
}
ffffffffc0203562:	60e2                	ld	ra,24(sp)
ffffffffc0203564:	8522                	mv	a0,s0
ffffffffc0203566:	6442                	ld	s0,16(sp)
ffffffffc0203568:	64a2                	ld	s1,8(sp)
ffffffffc020356a:	6902                	ld	s2,0(sp)
ffffffffc020356c:	6105                	addi	sp,sp,32
ffffffffc020356e:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0203570:	6418                	ld	a4,8(s0)
ffffffffc0203572:	e798                	sd	a4,8(a5)
ffffffffc0203574:	b7d1                	j	ffffffffc0203538 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0203576:	8aefd0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc020357a:	4605                	li	a2,1
ffffffffc020357c:	bf99                	j	ffffffffc02034d2 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020357e:	843e                	mv	s0,a5
ffffffffc0203580:	87b6                	mv	a5,a3
ffffffffc0203582:	b745                	j	ffffffffc0203522 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0203584:	00004697          	auipc	a3,0x4
ffffffffc0203588:	44468693          	addi	a3,a3,1092 # ffffffffc02079c8 <commands+0x1310>
ffffffffc020358c:	00003617          	auipc	a2,0x3
ffffffffc0203590:	53c60613          	addi	a2,a2,1340 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203594:	06400593          	li	a1,100
ffffffffc0203598:	00004517          	auipc	a0,0x4
ffffffffc020359c:	45050513          	addi	a0,a0,1104 # ffffffffc02079e8 <commands+0x1330>
ffffffffc02035a0:	c69fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02035a4 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02035a4:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02035a6:	00004517          	auipc	a0,0x4
ffffffffc02035aa:	45a50513          	addi	a0,a0,1114 # ffffffffc0207a00 <commands+0x1348>
kmalloc_init(void) {
ffffffffc02035ae:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02035b0:	b1dfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02035b4:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02035b6:	00004517          	auipc	a0,0x4
ffffffffc02035ba:	46250513          	addi	a0,a0,1122 # ffffffffc0207a18 <commands+0x1360>
}
ffffffffc02035be:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02035c0:	b0dfc06f          	j	ffffffffc02000cc <cprintf>

ffffffffc02035c4 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc02035c4:	4501                	li	a0,0
ffffffffc02035c6:	8082                	ret

ffffffffc02035c8 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02035c8:	1101                	addi	sp,sp,-32
ffffffffc02035ca:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02035cc:	6905                	lui	s2,0x1
{
ffffffffc02035ce:	e822                	sd	s0,16(sp)
ffffffffc02035d0:	ec06                	sd	ra,24(sp)
ffffffffc02035d2:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02035d4:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bd1>
{
ffffffffc02035d8:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02035da:	04a7f963          	bgeu	a5,a0,ffffffffc020362c <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02035de:	4561                	li	a0,24
ffffffffc02035e0:	ecfff0ef          	jal	ra,ffffffffc02034ae <slob_alloc.constprop.0>
ffffffffc02035e4:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02035e6:	c929                	beqz	a0,ffffffffc0203638 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc02035e8:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02035ec:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02035ee:	00f95763          	bge	s2,a5,ffffffffc02035fc <kmalloc+0x34>
ffffffffc02035f2:	6705                	lui	a4,0x1
ffffffffc02035f4:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02035f6:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02035f8:	fef74ee3          	blt	a4,a5,ffffffffc02035f4 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02035fc:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02035fe:	e4dff0ef          	jal	ra,ffffffffc020344a <__slob_get_free_pages.constprop.0>
ffffffffc0203602:	e488                	sd	a0,8(s1)
ffffffffc0203604:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0203606:	c525                	beqz	a0,ffffffffc020366e <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203608:	100027f3          	csrr	a5,sstatus
ffffffffc020360c:	8b89                	andi	a5,a5,2
ffffffffc020360e:	ef8d                	bnez	a5,ffffffffc0203648 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0203610:	000af797          	auipc	a5,0xaf
ffffffffc0203614:	31878793          	addi	a5,a5,792 # ffffffffc02b2928 <bigblocks>
ffffffffc0203618:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020361a:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020361c:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc020361e:	60e2                	ld	ra,24(sp)
ffffffffc0203620:	8522                	mv	a0,s0
ffffffffc0203622:	6442                	ld	s0,16(sp)
ffffffffc0203624:	64a2                	ld	s1,8(sp)
ffffffffc0203626:	6902                	ld	s2,0(sp)
ffffffffc0203628:	6105                	addi	sp,sp,32
ffffffffc020362a:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc020362c:	0541                	addi	a0,a0,16
ffffffffc020362e:	e81ff0ef          	jal	ra,ffffffffc02034ae <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0203632:	01050413          	addi	s0,a0,16
ffffffffc0203636:	f565                	bnez	a0,ffffffffc020361e <kmalloc+0x56>
ffffffffc0203638:	4401                	li	s0,0
}
ffffffffc020363a:	60e2                	ld	ra,24(sp)
ffffffffc020363c:	8522                	mv	a0,s0
ffffffffc020363e:	6442                	ld	s0,16(sp)
ffffffffc0203640:	64a2                	ld	s1,8(sp)
ffffffffc0203642:	6902                	ld	s2,0(sp)
ffffffffc0203644:	6105                	addi	sp,sp,32
ffffffffc0203646:	8082                	ret
        intr_disable();
ffffffffc0203648:	fddfc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
		bb->next = bigblocks;
ffffffffc020364c:	000af797          	auipc	a5,0xaf
ffffffffc0203650:	2dc78793          	addi	a5,a5,732 # ffffffffc02b2928 <bigblocks>
ffffffffc0203654:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0203656:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0203658:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc020365a:	fc5fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
		return bb->pages;
ffffffffc020365e:	6480                	ld	s0,8(s1)
}
ffffffffc0203660:	60e2                	ld	ra,24(sp)
ffffffffc0203662:	64a2                	ld	s1,8(sp)
ffffffffc0203664:	8522                	mv	a0,s0
ffffffffc0203666:	6442                	ld	s0,16(sp)
ffffffffc0203668:	6902                	ld	s2,0(sp)
ffffffffc020366a:	6105                	addi	sp,sp,32
ffffffffc020366c:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc020366e:	45e1                	li	a1,24
ffffffffc0203670:	8526                	mv	a0,s1
ffffffffc0203672:	d25ff0ef          	jal	ra,ffffffffc0203396 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0203676:	b765                	j	ffffffffc020361e <kmalloc+0x56>

ffffffffc0203678 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0203678:	c179                	beqz	a0,ffffffffc020373e <kfree+0xc6>
{
ffffffffc020367a:	1101                	addi	sp,sp,-32
ffffffffc020367c:	e822                	sd	s0,16(sp)
ffffffffc020367e:	ec06                	sd	ra,24(sp)
ffffffffc0203680:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0203682:	03451793          	slli	a5,a0,0x34
ffffffffc0203686:	842a                	mv	s0,a0
ffffffffc0203688:	e7c1                	bnez	a5,ffffffffc0203710 <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020368a:	100027f3          	csrr	a5,sstatus
ffffffffc020368e:	8b89                	andi	a5,a5,2
ffffffffc0203690:	ebc9                	bnez	a5,ffffffffc0203722 <kfree+0xaa>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203692:	000af797          	auipc	a5,0xaf
ffffffffc0203696:	2967b783          	ld	a5,662(a5) # ffffffffc02b2928 <bigblocks>
    return 0;
ffffffffc020369a:	4601                	li	a2,0
ffffffffc020369c:	cbb5                	beqz	a5,ffffffffc0203710 <kfree+0x98>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc020369e:	000af697          	auipc	a3,0xaf
ffffffffc02036a2:	28a68693          	addi	a3,a3,650 # ffffffffc02b2928 <bigblocks>
ffffffffc02036a6:	a021                	j	ffffffffc02036ae <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02036a8:	01048693          	addi	a3,s1,16
ffffffffc02036ac:	c3ad                	beqz	a5,ffffffffc020370e <kfree+0x96>
			if (bb->pages == block) {
ffffffffc02036ae:	6798                	ld	a4,8(a5)
ffffffffc02036b0:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc02036b2:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc02036b4:	fe871ae3          	bne	a4,s0,ffffffffc02036a8 <kfree+0x30>
				*last = bb->next;
ffffffffc02036b8:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc02036ba:	ee3d                	bnez	a2,ffffffffc0203738 <kfree+0xc0>
    return pa2page(PADDR(kva));
ffffffffc02036bc:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02036c0:	4098                	lw	a4,0(s1)
ffffffffc02036c2:	08f46b63          	bltu	s0,a5,ffffffffc0203758 <kfree+0xe0>
ffffffffc02036c6:	000af697          	auipc	a3,0xaf
ffffffffc02036ca:	24a6b683          	ld	a3,586(a3) # ffffffffc02b2910 <va_pa_offset>
ffffffffc02036ce:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc02036d0:	8031                	srli	s0,s0,0xc
ffffffffc02036d2:	000af797          	auipc	a5,0xaf
ffffffffc02036d6:	2267b783          	ld	a5,550(a5) # ffffffffc02b28f8 <npage>
ffffffffc02036da:	06f47363          	bgeu	s0,a5,ffffffffc0203740 <kfree+0xc8>
    return &pages[PPN(pa) - nbase];
ffffffffc02036de:	00005517          	auipc	a0,0x5
ffffffffc02036e2:	39253503          	ld	a0,914(a0) # ffffffffc0208a70 <nbase>
ffffffffc02036e6:	8c09                	sub	s0,s0,a0
ffffffffc02036e8:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc02036ea:	000af517          	auipc	a0,0xaf
ffffffffc02036ee:	21653503          	ld	a0,534(a0) # ffffffffc02b2900 <pages>
ffffffffc02036f2:	4585                	li	a1,1
ffffffffc02036f4:	9522                	add	a0,a0,s0
ffffffffc02036f6:	00e595bb          	sllw	a1,a1,a4
ffffffffc02036fa:	fcefd0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02036fe:	6442                	ld	s0,16(sp)
ffffffffc0203700:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203702:	8526                	mv	a0,s1
}
ffffffffc0203704:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203706:	45e1                	li	a1,24
}
ffffffffc0203708:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020370a:	c8dff06f          	j	ffffffffc0203396 <slob_free>
ffffffffc020370e:	e215                	bnez	a2,ffffffffc0203732 <kfree+0xba>
ffffffffc0203710:	ff040513          	addi	a0,s0,-16
}
ffffffffc0203714:	6442                	ld	s0,16(sp)
ffffffffc0203716:	60e2                	ld	ra,24(sp)
ffffffffc0203718:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020371a:	4581                	li	a1,0
}
ffffffffc020371c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020371e:	c79ff06f          	j	ffffffffc0203396 <slob_free>
        intr_disable();
ffffffffc0203722:	f03fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203726:	000af797          	auipc	a5,0xaf
ffffffffc020372a:	2027b783          	ld	a5,514(a5) # ffffffffc02b2928 <bigblocks>
        return 1;
ffffffffc020372e:	4605                	li	a2,1
ffffffffc0203730:	f7bd                	bnez	a5,ffffffffc020369e <kfree+0x26>
        intr_enable();
ffffffffc0203732:	eedfc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0203736:	bfe9                	j	ffffffffc0203710 <kfree+0x98>
ffffffffc0203738:	ee7fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc020373c:	b741                	j	ffffffffc02036bc <kfree+0x44>
ffffffffc020373e:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0203740:	00003617          	auipc	a2,0x3
ffffffffc0203744:	67860613          	addi	a2,a2,1656 # ffffffffc0206db8 <commands+0x700>
ffffffffc0203748:	06200593          	li	a1,98
ffffffffc020374c:	00003517          	auipc	a0,0x3
ffffffffc0203750:	68c50513          	addi	a0,a0,1676 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0203754:	ab5fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0203758:	86a2                	mv	a3,s0
ffffffffc020375a:	00003617          	auipc	a2,0x3
ffffffffc020375e:	78e60613          	addi	a2,a2,1934 # ffffffffc0206ee8 <commands+0x830>
ffffffffc0203762:	06e00593          	li	a1,110
ffffffffc0203766:	00003517          	auipc	a0,0x3
ffffffffc020376a:	67250513          	addi	a0,a0,1650 # ffffffffc0206dd8 <commands+0x720>
ffffffffc020376e:	a9bfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203772 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0203772:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0203774:	00003617          	auipc	a2,0x3
ffffffffc0203778:	64460613          	addi	a2,a2,1604 # ffffffffc0206db8 <commands+0x700>
ffffffffc020377c:	06200593          	li	a1,98
ffffffffc0203780:	00003517          	auipc	a0,0x3
ffffffffc0203784:	65850513          	addi	a0,a0,1624 # ffffffffc0206dd8 <commands+0x720>
pa2page(uintptr_t pa) {
ffffffffc0203788:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020378a:	a7ffc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020378e <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020378e:	7135                	addi	sp,sp,-160
ffffffffc0203790:	ed06                	sd	ra,152(sp)
ffffffffc0203792:	e922                	sd	s0,144(sp)
ffffffffc0203794:	e526                	sd	s1,136(sp)
ffffffffc0203796:	e14a                	sd	s2,128(sp)
ffffffffc0203798:	fcce                	sd	s3,120(sp)
ffffffffc020379a:	f8d2                	sd	s4,112(sp)
ffffffffc020379c:	f4d6                	sd	s5,104(sp)
ffffffffc020379e:	f0da                	sd	s6,96(sp)
ffffffffc02037a0:	ecde                	sd	s7,88(sp)
ffffffffc02037a2:	e8e2                	sd	s8,80(sp)
ffffffffc02037a4:	e4e6                	sd	s9,72(sp)
ffffffffc02037a6:	e0ea                	sd	s10,64(sp)
ffffffffc02037a8:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02037aa:	304010ef          	jal	ra,ffffffffc0204aae <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02037ae:	000af697          	auipc	a3,0xaf
ffffffffc02037b2:	1826b683          	ld	a3,386(a3) # ffffffffc02b2930 <max_swap_offset>
ffffffffc02037b6:	010007b7          	lui	a5,0x1000
ffffffffc02037ba:	ff968713          	addi	a4,a3,-7
ffffffffc02037be:	17e1                	addi	a5,a5,-8
ffffffffc02037c0:	42e7e663          	bltu	a5,a4,ffffffffc0203bec <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02037c4:	000a4797          	auipc	a5,0xa4
ffffffffc02037c8:	be478793          	addi	a5,a5,-1052 # ffffffffc02a73a8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02037cc:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02037ce:	000afb97          	auipc	s7,0xaf
ffffffffc02037d2:	16ab8b93          	addi	s7,s7,362 # ffffffffc02b2938 <sm>
ffffffffc02037d6:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc02037da:	9702                	jalr	a4
ffffffffc02037dc:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc02037de:	c10d                	beqz	a0,ffffffffc0203800 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02037e0:	60ea                	ld	ra,152(sp)
ffffffffc02037e2:	644a                	ld	s0,144(sp)
ffffffffc02037e4:	64aa                	ld	s1,136(sp)
ffffffffc02037e6:	79e6                	ld	s3,120(sp)
ffffffffc02037e8:	7a46                	ld	s4,112(sp)
ffffffffc02037ea:	7aa6                	ld	s5,104(sp)
ffffffffc02037ec:	7b06                	ld	s6,96(sp)
ffffffffc02037ee:	6be6                	ld	s7,88(sp)
ffffffffc02037f0:	6c46                	ld	s8,80(sp)
ffffffffc02037f2:	6ca6                	ld	s9,72(sp)
ffffffffc02037f4:	6d06                	ld	s10,64(sp)
ffffffffc02037f6:	7de2                	ld	s11,56(sp)
ffffffffc02037f8:	854a                	mv	a0,s2
ffffffffc02037fa:	690a                	ld	s2,128(sp)
ffffffffc02037fc:	610d                	addi	sp,sp,160
ffffffffc02037fe:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203800:	000bb783          	ld	a5,0(s7)
ffffffffc0203804:	00004517          	auipc	a0,0x4
ffffffffc0203808:	26450513          	addi	a0,a0,612 # ffffffffc0207a68 <commands+0x13b0>
ffffffffc020380c:	000ab417          	auipc	s0,0xab
ffffffffc0203810:	09c40413          	addi	s0,s0,156 # ffffffffc02ae8a8 <free_area>
ffffffffc0203814:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203816:	4785                	li	a5,1
ffffffffc0203818:	000af717          	auipc	a4,0xaf
ffffffffc020381c:	12f72423          	sw	a5,296(a4) # ffffffffc02b2940 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203820:	8adfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0203824:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0203826:	4d01                	li	s10,0
ffffffffc0203828:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020382a:	34878163          	beq	a5,s0,ffffffffc0203b6c <swap_init+0x3de>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020382e:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203832:	8b09                	andi	a4,a4,2
ffffffffc0203834:	32070e63          	beqz	a4,ffffffffc0203b70 <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc0203838:	ff87a703          	lw	a4,-8(a5)
ffffffffc020383c:	679c                	ld	a5,8(a5)
ffffffffc020383e:	2d85                	addiw	s11,s11,1
ffffffffc0203840:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203844:	fe8795e3          	bne	a5,s0,ffffffffc020382e <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0203848:	84ea                	mv	s1,s10
ffffffffc020384a:	ebefd0ef          	jal	ra,ffffffffc0200f08 <nr_free_pages>
ffffffffc020384e:	42951763          	bne	a0,s1,ffffffffc0203c7c <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203852:	866a                	mv	a2,s10
ffffffffc0203854:	85ee                	mv	a1,s11
ffffffffc0203856:	00004517          	auipc	a0,0x4
ffffffffc020385a:	25a50513          	addi	a0,a0,602 # ffffffffc0207ab0 <commands+0x13f8>
ffffffffc020385e:	86ffc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0203862:	90cff0ef          	jal	ra,ffffffffc020296e <mm_create>
ffffffffc0203866:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0203868:	46050a63          	beqz	a0,ffffffffc0203cdc <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020386c:	000af797          	auipc	a5,0xaf
ffffffffc0203870:	0ac78793          	addi	a5,a5,172 # ffffffffc02b2918 <check_mm_struct>
ffffffffc0203874:	6398                	ld	a4,0(a5)
ffffffffc0203876:	3e071363          	bnez	a4,ffffffffc0203c5c <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020387a:	000af717          	auipc	a4,0xaf
ffffffffc020387e:	07670713          	addi	a4,a4,118 # ffffffffc02b28f0 <boot_pgdir>
ffffffffc0203882:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0203886:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0203888:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020388c:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203890:	42079663          	bnez	a5,ffffffffc0203cbc <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203894:	6599                	lui	a1,0x6
ffffffffc0203896:	460d                	li	a2,3
ffffffffc0203898:	6505                	lui	a0,0x1
ffffffffc020389a:	91cff0ef          	jal	ra,ffffffffc02029b6 <vma_create>
ffffffffc020389e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02038a0:	52050a63          	beqz	a0,ffffffffc0203dd4 <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc02038a4:	8556                	mv	a0,s5
ffffffffc02038a6:	97eff0ef          	jal	ra,ffffffffc0202a24 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02038aa:	00004517          	auipc	a0,0x4
ffffffffc02038ae:	24650513          	addi	a0,a0,582 # ffffffffc0207af0 <commands+0x1438>
ffffffffc02038b2:	81bfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02038b6:	018ab503          	ld	a0,24(s5)
ffffffffc02038ba:	4605                	li	a2,1
ffffffffc02038bc:	6585                	lui	a1,0x1
ffffffffc02038be:	e84fd0ef          	jal	ra,ffffffffc0200f42 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02038c2:	4c050963          	beqz	a0,ffffffffc0203d94 <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02038c6:	00004517          	auipc	a0,0x4
ffffffffc02038ca:	27a50513          	addi	a0,a0,634 # ffffffffc0207b40 <commands+0x1488>
ffffffffc02038ce:	000ab497          	auipc	s1,0xab
ffffffffc02038d2:	f6a48493          	addi	s1,s1,-150 # ffffffffc02ae838 <check_rp>
ffffffffc02038d6:	ff6fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02038da:	000ab997          	auipc	s3,0xab
ffffffffc02038de:	f7e98993          	addi	s3,s3,-130 # ffffffffc02ae858 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02038e2:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc02038e4:	4505                	li	a0,1
ffffffffc02038e6:	d50fd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc02038ea:	00aa3023          	sd	a0,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
          assert(check_rp[i] != NULL );
ffffffffc02038ee:	2c050f63          	beqz	a0,ffffffffc0203bcc <swap_init+0x43e>
ffffffffc02038f2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02038f4:	8b89                	andi	a5,a5,2
ffffffffc02038f6:	34079363          	bnez	a5,ffffffffc0203c3c <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02038fa:	0a21                	addi	s4,s4,8
ffffffffc02038fc:	ff3a14e3          	bne	s4,s3,ffffffffc02038e4 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203900:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203902:	000aba17          	auipc	s4,0xab
ffffffffc0203906:	f36a0a13          	addi	s4,s4,-202 # ffffffffc02ae838 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc020390a:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc020390c:	ec3e                	sd	a5,24(sp)
ffffffffc020390e:	641c                	ld	a5,8(s0)
ffffffffc0203910:	e400                	sd	s0,8(s0)
ffffffffc0203912:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203914:	481c                	lw	a5,16(s0)
ffffffffc0203916:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0203918:	000ab797          	auipc	a5,0xab
ffffffffc020391c:	fa07a023          	sw	zero,-96(a5) # ffffffffc02ae8b8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203920:	000a3503          	ld	a0,0(s4)
ffffffffc0203924:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203926:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0203928:	da0fd0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020392c:	ff3a1ae3          	bne	s4,s3,ffffffffc0203920 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203930:	01042a03          	lw	s4,16(s0)
ffffffffc0203934:	4791                	li	a5,4
ffffffffc0203936:	42fa1f63          	bne	s4,a5,ffffffffc0203d74 <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020393a:	00004517          	auipc	a0,0x4
ffffffffc020393e:	28e50513          	addi	a0,a0,654 # ffffffffc0207bc8 <commands+0x1510>
ffffffffc0203942:	f8afc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203946:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203948:	000af797          	auipc	a5,0xaf
ffffffffc020394c:	fc07ac23          	sw	zero,-40(a5) # ffffffffc02b2920 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203950:	4629                	li	a2,10
ffffffffc0203952:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
     assert(pgfault_num==1);
ffffffffc0203956:	000af697          	auipc	a3,0xaf
ffffffffc020395a:	fca6a683          	lw	a3,-54(a3) # ffffffffc02b2920 <pgfault_num>
ffffffffc020395e:	4585                	li	a1,1
ffffffffc0203960:	000af797          	auipc	a5,0xaf
ffffffffc0203964:	fc078793          	addi	a5,a5,-64 # ffffffffc02b2920 <pgfault_num>
ffffffffc0203968:	54b69663          	bne	a3,a1,ffffffffc0203eb4 <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020396c:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0203970:	4398                	lw	a4,0(a5)
ffffffffc0203972:	2701                	sext.w	a4,a4
ffffffffc0203974:	3ed71063          	bne	a4,a3,ffffffffc0203d54 <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203978:	6689                	lui	a3,0x2
ffffffffc020397a:	462d                	li	a2,11
ffffffffc020397c:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bc0>
     assert(pgfault_num==2);
ffffffffc0203980:	4398                	lw	a4,0(a5)
ffffffffc0203982:	4589                	li	a1,2
ffffffffc0203984:	2701                	sext.w	a4,a4
ffffffffc0203986:	4ab71763          	bne	a4,a1,ffffffffc0203e34 <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc020398a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020398e:	4394                	lw	a3,0(a5)
ffffffffc0203990:	2681                	sext.w	a3,a3
ffffffffc0203992:	4ce69163          	bne	a3,a4,ffffffffc0203e54 <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203996:	668d                	lui	a3,0x3
ffffffffc0203998:	4631                	li	a2,12
ffffffffc020399a:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bc0>
     assert(pgfault_num==3);
ffffffffc020399e:	4398                	lw	a4,0(a5)
ffffffffc02039a0:	458d                	li	a1,3
ffffffffc02039a2:	2701                	sext.w	a4,a4
ffffffffc02039a4:	4cb71863          	bne	a4,a1,ffffffffc0203e74 <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02039a8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02039ac:	4394                	lw	a3,0(a5)
ffffffffc02039ae:	2681                	sext.w	a3,a3
ffffffffc02039b0:	4ee69263          	bne	a3,a4,ffffffffc0203e94 <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02039b4:	6691                	lui	a3,0x4
ffffffffc02039b6:	4635                	li	a2,13
ffffffffc02039b8:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bc0>
     assert(pgfault_num==4);
ffffffffc02039bc:	4398                	lw	a4,0(a5)
ffffffffc02039be:	2701                	sext.w	a4,a4
ffffffffc02039c0:	43471a63          	bne	a4,s4,ffffffffc0203df4 <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02039c4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02039c8:	439c                	lw	a5,0(a5)
ffffffffc02039ca:	2781                	sext.w	a5,a5
ffffffffc02039cc:	44e79463          	bne	a5,a4,ffffffffc0203e14 <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02039d0:	481c                	lw	a5,16(s0)
ffffffffc02039d2:	2c079563          	bnez	a5,ffffffffc0203c9c <swap_init+0x50e>
ffffffffc02039d6:	000ab797          	auipc	a5,0xab
ffffffffc02039da:	e8278793          	addi	a5,a5,-382 # ffffffffc02ae858 <swap_in_seq_no>
ffffffffc02039de:	000ab717          	auipc	a4,0xab
ffffffffc02039e2:	ea270713          	addi	a4,a4,-350 # ffffffffc02ae880 <swap_out_seq_no>
ffffffffc02039e6:	000ab617          	auipc	a2,0xab
ffffffffc02039ea:	e9a60613          	addi	a2,a2,-358 # ffffffffc02ae880 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02039ee:	56fd                	li	a3,-1
ffffffffc02039f0:	c394                	sw	a3,0(a5)
ffffffffc02039f2:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02039f4:	0791                	addi	a5,a5,4
ffffffffc02039f6:	0711                	addi	a4,a4,4
ffffffffc02039f8:	fec79ce3          	bne	a5,a2,ffffffffc02039f0 <swap_init+0x262>
ffffffffc02039fc:	000ab717          	auipc	a4,0xab
ffffffffc0203a00:	e1c70713          	addi	a4,a4,-484 # ffffffffc02ae818 <check_ptep>
ffffffffc0203a04:	000ab697          	auipc	a3,0xab
ffffffffc0203a08:	e3468693          	addi	a3,a3,-460 # ffffffffc02ae838 <check_rp>
ffffffffc0203a0c:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203a0e:	000afc17          	auipc	s8,0xaf
ffffffffc0203a12:	eeac0c13          	addi	s8,s8,-278 # ffffffffc02b28f8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a16:	000afc97          	auipc	s9,0xaf
ffffffffc0203a1a:	eeac8c93          	addi	s9,s9,-278 # ffffffffc02b2900 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203a1e:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203a22:	4601                	li	a2,0
ffffffffc0203a24:	855a                	mv	a0,s6
ffffffffc0203a26:	e836                	sd	a3,16(sp)
ffffffffc0203a28:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0203a2a:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203a2c:	d16fd0ef          	jal	ra,ffffffffc0200f42 <get_pte>
ffffffffc0203a30:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203a32:	65a2                	ld	a1,8(sp)
ffffffffc0203a34:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203a36:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0203a38:	1c050663          	beqz	a0,ffffffffc0203c04 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203a3c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203a3e:	0017f613          	andi	a2,a5,1
ffffffffc0203a42:	1e060163          	beqz	a2,ffffffffc0203c24 <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0203a46:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203a4a:	078a                	slli	a5,a5,0x2
ffffffffc0203a4c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a4e:	14c7f363          	bgeu	a5,a2,ffffffffc0203b94 <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a52:	00005617          	auipc	a2,0x5
ffffffffc0203a56:	01e60613          	addi	a2,a2,30 # ffffffffc0208a70 <nbase>
ffffffffc0203a5a:	00063a03          	ld	s4,0(a2)
ffffffffc0203a5e:	000cb603          	ld	a2,0(s9)
ffffffffc0203a62:	6288                	ld	a0,0(a3)
ffffffffc0203a64:	414787b3          	sub	a5,a5,s4
ffffffffc0203a68:	079a                	slli	a5,a5,0x6
ffffffffc0203a6a:	97b2                	add	a5,a5,a2
ffffffffc0203a6c:	14f51063          	bne	a0,a5,ffffffffc0203bac <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203a70:	6785                	lui	a5,0x1
ffffffffc0203a72:	95be                	add	a1,a1,a5
ffffffffc0203a74:	6795                	lui	a5,0x5
ffffffffc0203a76:	0721                	addi	a4,a4,8
ffffffffc0203a78:	06a1                	addi	a3,a3,8
ffffffffc0203a7a:	faf592e3          	bne	a1,a5,ffffffffc0203a1e <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0203a7e:	00004517          	auipc	a0,0x4
ffffffffc0203a82:	1f250513          	addi	a0,a0,498 # ffffffffc0207c70 <commands+0x15b8>
ffffffffc0203a86:	e46fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc0203a8a:	000bb783          	ld	a5,0(s7)
ffffffffc0203a8e:	7f9c                	ld	a5,56(a5)
ffffffffc0203a90:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203a92:	32051163          	bnez	a0,ffffffffc0203db4 <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc0203a96:	77a2                	ld	a5,40(sp)
ffffffffc0203a98:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0203a9a:	67e2                	ld	a5,24(sp)
ffffffffc0203a9c:	e01c                	sd	a5,0(s0)
ffffffffc0203a9e:	7782                	ld	a5,32(sp)
ffffffffc0203aa0:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203aa2:	6088                	ld	a0,0(s1)
ffffffffc0203aa4:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203aa6:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0203aa8:	c20fd0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203aac:	ff349be3          	bne	s1,s3,ffffffffc0203aa2 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203ab0:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc0203ab4:	8556                	mv	a0,s5
ffffffffc0203ab6:	83eff0ef          	jal	ra,ffffffffc0202af4 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203aba:	000af797          	auipc	a5,0xaf
ffffffffc0203abe:	e3678793          	addi	a5,a5,-458 # ffffffffc02b28f0 <boot_pgdir>
ffffffffc0203ac2:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203ac4:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc0203ac8:	000af697          	auipc	a3,0xaf
ffffffffc0203acc:	e406b823          	sd	zero,-432(a3) # ffffffffc02b2918 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203ad0:	639c                	ld	a5,0(a5)
ffffffffc0203ad2:	078a                	slli	a5,a5,0x2
ffffffffc0203ad4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203ad6:	0ae7fd63          	bgeu	a5,a4,ffffffffc0203b90 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ada:	414786b3          	sub	a3,a5,s4
ffffffffc0203ade:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203ae0:	8699                	srai	a3,a3,0x6
ffffffffc0203ae2:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203ae4:	00c69793          	slli	a5,a3,0xc
ffffffffc0203ae8:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0203aea:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0203aee:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203af0:	22e7f663          	bgeu	a5,a4,ffffffffc0203d1c <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc0203af4:	000af797          	auipc	a5,0xaf
ffffffffc0203af8:	e1c7b783          	ld	a5,-484(a5) # ffffffffc02b2910 <va_pa_offset>
ffffffffc0203afc:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203afe:	629c                	ld	a5,0(a3)
ffffffffc0203b00:	078a                	slli	a5,a5,0x2
ffffffffc0203b02:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b04:	08e7f663          	bgeu	a5,a4,ffffffffc0203b90 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b08:	414787b3          	sub	a5,a5,s4
ffffffffc0203b0c:	079a                	slli	a5,a5,0x6
ffffffffc0203b0e:	953e                	add	a0,a0,a5
ffffffffc0203b10:	4585                	li	a1,1
ffffffffc0203b12:	bb6fd0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b16:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203b1a:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b1e:	078a                	slli	a5,a5,0x2
ffffffffc0203b20:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b22:	06e7f763          	bgeu	a5,a4,ffffffffc0203b90 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b26:	000cb503          	ld	a0,0(s9)
ffffffffc0203b2a:	414787b3          	sub	a5,a5,s4
ffffffffc0203b2e:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203b30:	4585                	li	a1,1
ffffffffc0203b32:	953e                	add	a0,a0,a5
ffffffffc0203b34:	b94fd0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
     pgdir[0] = 0;
ffffffffc0203b38:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203b3c:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203b40:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203b42:	00878a63          	beq	a5,s0,ffffffffc0203b56 <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203b46:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203b4a:	679c                	ld	a5,8(a5)
ffffffffc0203b4c:	3dfd                	addiw	s11,s11,-1
ffffffffc0203b4e:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203b52:	fe879ae3          	bne	a5,s0,ffffffffc0203b46 <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc0203b56:	1c0d9f63          	bnez	s11,ffffffffc0203d34 <swap_init+0x5a6>
     assert(total==0);
ffffffffc0203b5a:	1a0d1163          	bnez	s10,ffffffffc0203cfc <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203b5e:	00004517          	auipc	a0,0x4
ffffffffc0203b62:	16250513          	addi	a0,a0,354 # ffffffffc0207cc0 <commands+0x1608>
ffffffffc0203b66:	d66fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0203b6a:	b99d                	j	ffffffffc02037e0 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203b6c:	4481                	li	s1,0
ffffffffc0203b6e:	b9f1                	j	ffffffffc020384a <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0203b70:	00004697          	auipc	a3,0x4
ffffffffc0203b74:	f1068693          	addi	a3,a3,-240 # ffffffffc0207a80 <commands+0x13c8>
ffffffffc0203b78:	00003617          	auipc	a2,0x3
ffffffffc0203b7c:	f5060613          	addi	a2,a2,-176 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203b80:	0bc00593          	li	a1,188
ffffffffc0203b84:	00004517          	auipc	a0,0x4
ffffffffc0203b88:	ed450513          	addi	a0,a0,-300 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203b8c:	e7cfc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0203b90:	be3ff0ef          	jal	ra,ffffffffc0203772 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0203b94:	00003617          	auipc	a2,0x3
ffffffffc0203b98:	22460613          	addi	a2,a2,548 # ffffffffc0206db8 <commands+0x700>
ffffffffc0203b9c:	06200593          	li	a1,98
ffffffffc0203ba0:	00003517          	auipc	a0,0x3
ffffffffc0203ba4:	23850513          	addi	a0,a0,568 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0203ba8:	e60fc0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203bac:	00004697          	auipc	a3,0x4
ffffffffc0203bb0:	09c68693          	addi	a3,a3,156 # ffffffffc0207c48 <commands+0x1590>
ffffffffc0203bb4:	00003617          	auipc	a2,0x3
ffffffffc0203bb8:	f1460613          	addi	a2,a2,-236 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203bbc:	0fc00593          	li	a1,252
ffffffffc0203bc0:	00004517          	auipc	a0,0x4
ffffffffc0203bc4:	e9850513          	addi	a0,a0,-360 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203bc8:	e40fc0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203bcc:	00004697          	auipc	a3,0x4
ffffffffc0203bd0:	f9c68693          	addi	a3,a3,-100 # ffffffffc0207b68 <commands+0x14b0>
ffffffffc0203bd4:	00003617          	auipc	a2,0x3
ffffffffc0203bd8:	ef460613          	addi	a2,a2,-268 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203bdc:	0dc00593          	li	a1,220
ffffffffc0203be0:	00004517          	auipc	a0,0x4
ffffffffc0203be4:	e7850513          	addi	a0,a0,-392 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203be8:	e20fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203bec:	00004617          	auipc	a2,0x4
ffffffffc0203bf0:	e4c60613          	addi	a2,a2,-436 # ffffffffc0207a38 <commands+0x1380>
ffffffffc0203bf4:	02800593          	li	a1,40
ffffffffc0203bf8:	00004517          	auipc	a0,0x4
ffffffffc0203bfc:	e6050513          	addi	a0,a0,-416 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203c00:	e08fc0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203c04:	00004697          	auipc	a3,0x4
ffffffffc0203c08:	02c68693          	addi	a3,a3,44 # ffffffffc0207c30 <commands+0x1578>
ffffffffc0203c0c:	00003617          	auipc	a2,0x3
ffffffffc0203c10:	ebc60613          	addi	a2,a2,-324 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203c14:	0fb00593          	li	a1,251
ffffffffc0203c18:	00004517          	auipc	a0,0x4
ffffffffc0203c1c:	e4050513          	addi	a0,a0,-448 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203c20:	de8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203c24:	00003617          	auipc	a2,0x3
ffffffffc0203c28:	1c460613          	addi	a2,a2,452 # ffffffffc0206de8 <commands+0x730>
ffffffffc0203c2c:	07400593          	li	a1,116
ffffffffc0203c30:	00003517          	auipc	a0,0x3
ffffffffc0203c34:	1a850513          	addi	a0,a0,424 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0203c38:	dd0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203c3c:	00004697          	auipc	a3,0x4
ffffffffc0203c40:	f4468693          	addi	a3,a3,-188 # ffffffffc0207b80 <commands+0x14c8>
ffffffffc0203c44:	00003617          	auipc	a2,0x3
ffffffffc0203c48:	e8460613          	addi	a2,a2,-380 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203c4c:	0dd00593          	li	a1,221
ffffffffc0203c50:	00004517          	auipc	a0,0x4
ffffffffc0203c54:	e0850513          	addi	a0,a0,-504 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203c58:	db0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203c5c:	00004697          	auipc	a3,0x4
ffffffffc0203c60:	e7c68693          	addi	a3,a3,-388 # ffffffffc0207ad8 <commands+0x1420>
ffffffffc0203c64:	00003617          	auipc	a2,0x3
ffffffffc0203c68:	e6460613          	addi	a2,a2,-412 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203c6c:	0c700593          	li	a1,199
ffffffffc0203c70:	00004517          	auipc	a0,0x4
ffffffffc0203c74:	de850513          	addi	a0,a0,-536 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203c78:	d90fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203c7c:	00004697          	auipc	a3,0x4
ffffffffc0203c80:	e1468693          	addi	a3,a3,-492 # ffffffffc0207a90 <commands+0x13d8>
ffffffffc0203c84:	00003617          	auipc	a2,0x3
ffffffffc0203c88:	e4460613          	addi	a2,a2,-444 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203c8c:	0bf00593          	li	a1,191
ffffffffc0203c90:	00004517          	auipc	a0,0x4
ffffffffc0203c94:	dc850513          	addi	a0,a0,-568 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203c98:	d70fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert( nr_free == 0);         
ffffffffc0203c9c:	00004697          	auipc	a3,0x4
ffffffffc0203ca0:	f8468693          	addi	a3,a3,-124 # ffffffffc0207c20 <commands+0x1568>
ffffffffc0203ca4:	00003617          	auipc	a2,0x3
ffffffffc0203ca8:	e2460613          	addi	a2,a2,-476 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203cac:	0f300593          	li	a1,243
ffffffffc0203cb0:	00004517          	auipc	a0,0x4
ffffffffc0203cb4:	da850513          	addi	a0,a0,-600 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203cb8:	d50fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203cbc:	00004697          	auipc	a3,0x4
ffffffffc0203cc0:	bbc68693          	addi	a3,a3,-1092 # ffffffffc0207878 <commands+0x11c0>
ffffffffc0203cc4:	00003617          	auipc	a2,0x3
ffffffffc0203cc8:	e0460613          	addi	a2,a2,-508 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203ccc:	0cc00593          	li	a1,204
ffffffffc0203cd0:	00004517          	auipc	a0,0x4
ffffffffc0203cd4:	d8850513          	addi	a0,a0,-632 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203cd8:	d30fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(mm != NULL);
ffffffffc0203cdc:	00004697          	auipc	a3,0x4
ffffffffc0203ce0:	9d468693          	addi	a3,a3,-1580 # ffffffffc02076b0 <commands+0xff8>
ffffffffc0203ce4:	00003617          	auipc	a2,0x3
ffffffffc0203ce8:	de460613          	addi	a2,a2,-540 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203cec:	0c400593          	li	a1,196
ffffffffc0203cf0:	00004517          	auipc	a0,0x4
ffffffffc0203cf4:	d6850513          	addi	a0,a0,-664 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203cf8:	d10fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total==0);
ffffffffc0203cfc:	00004697          	auipc	a3,0x4
ffffffffc0203d00:	fb468693          	addi	a3,a3,-76 # ffffffffc0207cb0 <commands+0x15f8>
ffffffffc0203d04:	00003617          	auipc	a2,0x3
ffffffffc0203d08:	dc460613          	addi	a2,a2,-572 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203d0c:	11e00593          	li	a1,286
ffffffffc0203d10:	00004517          	auipc	a0,0x4
ffffffffc0203d14:	d4850513          	addi	a0,a0,-696 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203d18:	cf0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203d1c:	00003617          	auipc	a2,0x3
ffffffffc0203d20:	0f460613          	addi	a2,a2,244 # ffffffffc0206e10 <commands+0x758>
ffffffffc0203d24:	06900593          	li	a1,105
ffffffffc0203d28:	00003517          	auipc	a0,0x3
ffffffffc0203d2c:	0b050513          	addi	a0,a0,176 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0203d30:	cd8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(count==0);
ffffffffc0203d34:	00004697          	auipc	a3,0x4
ffffffffc0203d38:	f6c68693          	addi	a3,a3,-148 # ffffffffc0207ca0 <commands+0x15e8>
ffffffffc0203d3c:	00003617          	auipc	a2,0x3
ffffffffc0203d40:	d8c60613          	addi	a2,a2,-628 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203d44:	11d00593          	li	a1,285
ffffffffc0203d48:	00004517          	auipc	a0,0x4
ffffffffc0203d4c:	d1050513          	addi	a0,a0,-752 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203d50:	cb8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0203d54:	00004697          	auipc	a3,0x4
ffffffffc0203d58:	e9c68693          	addi	a3,a3,-356 # ffffffffc0207bf0 <commands+0x1538>
ffffffffc0203d5c:	00003617          	auipc	a2,0x3
ffffffffc0203d60:	d6c60613          	addi	a2,a2,-660 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203d64:	09500593          	li	a1,149
ffffffffc0203d68:	00004517          	auipc	a0,0x4
ffffffffc0203d6c:	cf050513          	addi	a0,a0,-784 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203d70:	c98fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203d74:	00004697          	auipc	a3,0x4
ffffffffc0203d78:	e2c68693          	addi	a3,a3,-468 # ffffffffc0207ba0 <commands+0x14e8>
ffffffffc0203d7c:	00003617          	auipc	a2,0x3
ffffffffc0203d80:	d4c60613          	addi	a2,a2,-692 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203d84:	0ea00593          	li	a1,234
ffffffffc0203d88:	00004517          	auipc	a0,0x4
ffffffffc0203d8c:	cd050513          	addi	a0,a0,-816 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203d90:	c78fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203d94:	00004697          	auipc	a3,0x4
ffffffffc0203d98:	d9468693          	addi	a3,a3,-620 # ffffffffc0207b28 <commands+0x1470>
ffffffffc0203d9c:	00003617          	auipc	a2,0x3
ffffffffc0203da0:	d2c60613          	addi	a2,a2,-724 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203da4:	0d700593          	li	a1,215
ffffffffc0203da8:	00004517          	auipc	a0,0x4
ffffffffc0203dac:	cb050513          	addi	a0,a0,-848 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203db0:	c58fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(ret==0);
ffffffffc0203db4:	00004697          	auipc	a3,0x4
ffffffffc0203db8:	ee468693          	addi	a3,a3,-284 # ffffffffc0207c98 <commands+0x15e0>
ffffffffc0203dbc:	00003617          	auipc	a2,0x3
ffffffffc0203dc0:	d0c60613          	addi	a2,a2,-756 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203dc4:	10200593          	li	a1,258
ffffffffc0203dc8:	00004517          	auipc	a0,0x4
ffffffffc0203dcc:	c9050513          	addi	a0,a0,-880 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203dd0:	c38fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(vma != NULL);
ffffffffc0203dd4:	00004697          	auipc	a3,0x4
ffffffffc0203dd8:	b4468693          	addi	a3,a3,-1212 # ffffffffc0207918 <commands+0x1260>
ffffffffc0203ddc:	00003617          	auipc	a2,0x3
ffffffffc0203de0:	cec60613          	addi	a2,a2,-788 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203de4:	0cf00593          	li	a1,207
ffffffffc0203de8:	00004517          	auipc	a0,0x4
ffffffffc0203dec:	c7050513          	addi	a0,a0,-912 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203df0:	c18fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0203df4:	00003697          	auipc	a3,0x3
ffffffffc0203df8:	65c68693          	addi	a3,a3,1628 # ffffffffc0207450 <commands+0xd98>
ffffffffc0203dfc:	00003617          	auipc	a2,0x3
ffffffffc0203e00:	ccc60613          	addi	a2,a2,-820 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203e04:	09f00593          	li	a1,159
ffffffffc0203e08:	00004517          	auipc	a0,0x4
ffffffffc0203e0c:	c5050513          	addi	a0,a0,-944 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203e10:	bf8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0203e14:	00003697          	auipc	a3,0x3
ffffffffc0203e18:	63c68693          	addi	a3,a3,1596 # ffffffffc0207450 <commands+0xd98>
ffffffffc0203e1c:	00003617          	auipc	a2,0x3
ffffffffc0203e20:	cac60613          	addi	a2,a2,-852 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203e24:	0a100593          	li	a1,161
ffffffffc0203e28:	00004517          	auipc	a0,0x4
ffffffffc0203e2c:	c3050513          	addi	a0,a0,-976 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203e30:	bd8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0203e34:	00004697          	auipc	a3,0x4
ffffffffc0203e38:	dcc68693          	addi	a3,a3,-564 # ffffffffc0207c00 <commands+0x1548>
ffffffffc0203e3c:	00003617          	auipc	a2,0x3
ffffffffc0203e40:	c8c60613          	addi	a2,a2,-884 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203e44:	09700593          	li	a1,151
ffffffffc0203e48:	00004517          	auipc	a0,0x4
ffffffffc0203e4c:	c1050513          	addi	a0,a0,-1008 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203e50:	bb8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0203e54:	00004697          	auipc	a3,0x4
ffffffffc0203e58:	dac68693          	addi	a3,a3,-596 # ffffffffc0207c00 <commands+0x1548>
ffffffffc0203e5c:	00003617          	auipc	a2,0x3
ffffffffc0203e60:	c6c60613          	addi	a2,a2,-916 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203e64:	09900593          	li	a1,153
ffffffffc0203e68:	00004517          	auipc	a0,0x4
ffffffffc0203e6c:	bf050513          	addi	a0,a0,-1040 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203e70:	b98fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0203e74:	00004697          	auipc	a3,0x4
ffffffffc0203e78:	d9c68693          	addi	a3,a3,-612 # ffffffffc0207c10 <commands+0x1558>
ffffffffc0203e7c:	00003617          	auipc	a2,0x3
ffffffffc0203e80:	c4c60613          	addi	a2,a2,-948 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203e84:	09b00593          	li	a1,155
ffffffffc0203e88:	00004517          	auipc	a0,0x4
ffffffffc0203e8c:	bd050513          	addi	a0,a0,-1072 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203e90:	b78fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0203e94:	00004697          	auipc	a3,0x4
ffffffffc0203e98:	d7c68693          	addi	a3,a3,-644 # ffffffffc0207c10 <commands+0x1558>
ffffffffc0203e9c:	00003617          	auipc	a2,0x3
ffffffffc0203ea0:	c2c60613          	addi	a2,a2,-980 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203ea4:	09d00593          	li	a1,157
ffffffffc0203ea8:	00004517          	auipc	a0,0x4
ffffffffc0203eac:	bb050513          	addi	a0,a0,-1104 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203eb0:	b58fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0203eb4:	00004697          	auipc	a3,0x4
ffffffffc0203eb8:	d3c68693          	addi	a3,a3,-708 # ffffffffc0207bf0 <commands+0x1538>
ffffffffc0203ebc:	00003617          	auipc	a2,0x3
ffffffffc0203ec0:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203ec4:	09300593          	li	a1,147
ffffffffc0203ec8:	00004517          	auipc	a0,0x4
ffffffffc0203ecc:	b9050513          	addi	a0,a0,-1136 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203ed0:	b38fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203ed4 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203ed4:	000af797          	auipc	a5,0xaf
ffffffffc0203ed8:	a647b783          	ld	a5,-1436(a5) # ffffffffc02b2938 <sm>
ffffffffc0203edc:	6b9c                	ld	a5,16(a5)
ffffffffc0203ede:	8782                	jr	a5

ffffffffc0203ee0 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203ee0:	000af797          	auipc	a5,0xaf
ffffffffc0203ee4:	a587b783          	ld	a5,-1448(a5) # ffffffffc02b2938 <sm>
ffffffffc0203ee8:	739c                	ld	a5,32(a5)
ffffffffc0203eea:	8782                	jr	a5

ffffffffc0203eec <swap_out>:
{
ffffffffc0203eec:	711d                	addi	sp,sp,-96
ffffffffc0203eee:	ec86                	sd	ra,88(sp)
ffffffffc0203ef0:	e8a2                	sd	s0,80(sp)
ffffffffc0203ef2:	e4a6                	sd	s1,72(sp)
ffffffffc0203ef4:	e0ca                	sd	s2,64(sp)
ffffffffc0203ef6:	fc4e                	sd	s3,56(sp)
ffffffffc0203ef8:	f852                	sd	s4,48(sp)
ffffffffc0203efa:	f456                	sd	s5,40(sp)
ffffffffc0203efc:	f05a                	sd	s6,32(sp)
ffffffffc0203efe:	ec5e                	sd	s7,24(sp)
ffffffffc0203f00:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203f02:	cde9                	beqz	a1,ffffffffc0203fdc <swap_out+0xf0>
ffffffffc0203f04:	8a2e                	mv	s4,a1
ffffffffc0203f06:	892a                	mv	s2,a0
ffffffffc0203f08:	8ab2                	mv	s5,a2
ffffffffc0203f0a:	4401                	li	s0,0
ffffffffc0203f0c:	000af997          	auipc	s3,0xaf
ffffffffc0203f10:	a2c98993          	addi	s3,s3,-1492 # ffffffffc02b2938 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203f14:	00004b17          	auipc	s6,0x4
ffffffffc0203f18:	e2cb0b13          	addi	s6,s6,-468 # ffffffffc0207d40 <commands+0x1688>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203f1c:	00004b97          	auipc	s7,0x4
ffffffffc0203f20:	e0cb8b93          	addi	s7,s7,-500 # ffffffffc0207d28 <commands+0x1670>
ffffffffc0203f24:	a825                	j	ffffffffc0203f5c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203f26:	67a2                	ld	a5,8(sp)
ffffffffc0203f28:	8626                	mv	a2,s1
ffffffffc0203f2a:	85a2                	mv	a1,s0
ffffffffc0203f2c:	7f94                	ld	a3,56(a5)
ffffffffc0203f2e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203f30:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203f32:	82b1                	srli	a3,a3,0xc
ffffffffc0203f34:	0685                	addi	a3,a3,1
ffffffffc0203f36:	996fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203f3a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203f3c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203f3e:	7d1c                	ld	a5,56(a0)
ffffffffc0203f40:	83b1                	srli	a5,a5,0xc
ffffffffc0203f42:	0785                	addi	a5,a5,1
ffffffffc0203f44:	07a2                	slli	a5,a5,0x8
ffffffffc0203f46:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203f4a:	f7ffc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203f4e:	01893503          	ld	a0,24(s2)
ffffffffc0203f52:	85a6                	mv	a1,s1
ffffffffc0203f54:	d48fe0ef          	jal	ra,ffffffffc020249c <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203f58:	048a0d63          	beq	s4,s0,ffffffffc0203fb2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203f5c:	0009b783          	ld	a5,0(s3)
ffffffffc0203f60:	8656                	mv	a2,s5
ffffffffc0203f62:	002c                	addi	a1,sp,8
ffffffffc0203f64:	7b9c                	ld	a5,48(a5)
ffffffffc0203f66:	854a                	mv	a0,s2
ffffffffc0203f68:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203f6a:	e12d                	bnez	a0,ffffffffc0203fcc <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203f6c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203f6e:	01893503          	ld	a0,24(s2)
ffffffffc0203f72:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203f74:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203f76:	85a6                	mv	a1,s1
ffffffffc0203f78:	fcbfc0ef          	jal	ra,ffffffffc0200f42 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203f7c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203f7e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203f80:	8b85                	andi	a5,a5,1
ffffffffc0203f82:	cfb9                	beqz	a5,ffffffffc0203fe0 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203f84:	65a2                	ld	a1,8(sp)
ffffffffc0203f86:	7d9c                	ld	a5,56(a1)
ffffffffc0203f88:	83b1                	srli	a5,a5,0xc
ffffffffc0203f8a:	0785                	addi	a5,a5,1
ffffffffc0203f8c:	00879513          	slli	a0,a5,0x8
ffffffffc0203f90:	357000ef          	jal	ra,ffffffffc0204ae6 <swapfs_write>
ffffffffc0203f94:	d949                	beqz	a0,ffffffffc0203f26 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203f96:	855e                	mv	a0,s7
ffffffffc0203f98:	934fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203f9c:	0009b783          	ld	a5,0(s3)
ffffffffc0203fa0:	6622                	ld	a2,8(sp)
ffffffffc0203fa2:	4681                	li	a3,0
ffffffffc0203fa4:	739c                	ld	a5,32(a5)
ffffffffc0203fa6:	85a6                	mv	a1,s1
ffffffffc0203fa8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203faa:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203fac:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203fae:	fa8a17e3          	bne	s4,s0,ffffffffc0203f5c <swap_out+0x70>
}
ffffffffc0203fb2:	60e6                	ld	ra,88(sp)
ffffffffc0203fb4:	8522                	mv	a0,s0
ffffffffc0203fb6:	6446                	ld	s0,80(sp)
ffffffffc0203fb8:	64a6                	ld	s1,72(sp)
ffffffffc0203fba:	6906                	ld	s2,64(sp)
ffffffffc0203fbc:	79e2                	ld	s3,56(sp)
ffffffffc0203fbe:	7a42                	ld	s4,48(sp)
ffffffffc0203fc0:	7aa2                	ld	s5,40(sp)
ffffffffc0203fc2:	7b02                	ld	s6,32(sp)
ffffffffc0203fc4:	6be2                	ld	s7,24(sp)
ffffffffc0203fc6:	6c42                	ld	s8,16(sp)
ffffffffc0203fc8:	6125                	addi	sp,sp,96
ffffffffc0203fca:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203fcc:	85a2                	mv	a1,s0
ffffffffc0203fce:	00004517          	auipc	a0,0x4
ffffffffc0203fd2:	d1250513          	addi	a0,a0,-750 # ffffffffc0207ce0 <commands+0x1628>
ffffffffc0203fd6:	8f6fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc0203fda:	bfe1                	j	ffffffffc0203fb2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203fdc:	4401                	li	s0,0
ffffffffc0203fde:	bfd1                	j	ffffffffc0203fb2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203fe0:	00004697          	auipc	a3,0x4
ffffffffc0203fe4:	d3068693          	addi	a3,a3,-720 # ffffffffc0207d10 <commands+0x1658>
ffffffffc0203fe8:	00003617          	auipc	a2,0x3
ffffffffc0203fec:	ae060613          	addi	a2,a2,-1312 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0203ff0:	06800593          	li	a1,104
ffffffffc0203ff4:	00004517          	auipc	a0,0x4
ffffffffc0203ff8:	a6450513          	addi	a0,a0,-1436 # ffffffffc0207a58 <commands+0x13a0>
ffffffffc0203ffc:	a0cfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204000 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0204000:	000ab797          	auipc	a5,0xab
ffffffffc0204004:	8a878793          	addi	a5,a5,-1880 # ffffffffc02ae8a8 <free_area>
ffffffffc0204008:	e79c                	sd	a5,8(a5)
ffffffffc020400a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020400c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0204010:	8082                	ret

ffffffffc0204012 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0204012:	000ab517          	auipc	a0,0xab
ffffffffc0204016:	8a656503          	lwu	a0,-1882(a0) # ffffffffc02ae8b8 <free_area+0x10>
ffffffffc020401a:	8082                	ret

ffffffffc020401c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc020401c:	715d                	addi	sp,sp,-80
ffffffffc020401e:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0204020:	000ab417          	auipc	s0,0xab
ffffffffc0204024:	88840413          	addi	s0,s0,-1912 # ffffffffc02ae8a8 <free_area>
ffffffffc0204028:	641c                	ld	a5,8(s0)
ffffffffc020402a:	e486                	sd	ra,72(sp)
ffffffffc020402c:	fc26                	sd	s1,56(sp)
ffffffffc020402e:	f84a                	sd	s2,48(sp)
ffffffffc0204030:	f44e                	sd	s3,40(sp)
ffffffffc0204032:	f052                	sd	s4,32(sp)
ffffffffc0204034:	ec56                	sd	s5,24(sp)
ffffffffc0204036:	e85a                	sd	s6,16(sp)
ffffffffc0204038:	e45e                	sd	s7,8(sp)
ffffffffc020403a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020403c:	2a878d63          	beq	a5,s0,ffffffffc02042f6 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0204040:	4481                	li	s1,0
ffffffffc0204042:	4901                	li	s2,0
ffffffffc0204044:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0204048:	8b09                	andi	a4,a4,2
ffffffffc020404a:	2a070a63          	beqz	a4,ffffffffc02042fe <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc020404e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0204052:	679c                	ld	a5,8(a5)
ffffffffc0204054:	2905                	addiw	s2,s2,1
ffffffffc0204056:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204058:	fe8796e3          	bne	a5,s0,ffffffffc0204044 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc020405c:	89a6                	mv	s3,s1
ffffffffc020405e:	eabfc0ef          	jal	ra,ffffffffc0200f08 <nr_free_pages>
ffffffffc0204062:	6f351e63          	bne	a0,s3,ffffffffc020475e <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0204066:	4505                	li	a0,1
ffffffffc0204068:	dcffc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc020406c:	8aaa                	mv	s5,a0
ffffffffc020406e:	42050863          	beqz	a0,ffffffffc020449e <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204072:	4505                	li	a0,1
ffffffffc0204074:	dc3fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0204078:	89aa                	mv	s3,a0
ffffffffc020407a:	70050263          	beqz	a0,ffffffffc020477e <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020407e:	4505                	li	a0,1
ffffffffc0204080:	db7fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0204084:	8a2a                	mv	s4,a0
ffffffffc0204086:	48050c63          	beqz	a0,ffffffffc020451e <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020408a:	293a8a63          	beq	s5,s3,ffffffffc020431e <default_check+0x302>
ffffffffc020408e:	28aa8863          	beq	s5,a0,ffffffffc020431e <default_check+0x302>
ffffffffc0204092:	28a98663          	beq	s3,a0,ffffffffc020431e <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0204096:	000aa783          	lw	a5,0(s5)
ffffffffc020409a:	2a079263          	bnez	a5,ffffffffc020433e <default_check+0x322>
ffffffffc020409e:	0009a783          	lw	a5,0(s3)
ffffffffc02040a2:	28079e63          	bnez	a5,ffffffffc020433e <default_check+0x322>
ffffffffc02040a6:	411c                	lw	a5,0(a0)
ffffffffc02040a8:	28079b63          	bnez	a5,ffffffffc020433e <default_check+0x322>
    return page - pages + nbase;
ffffffffc02040ac:	000af797          	auipc	a5,0xaf
ffffffffc02040b0:	8547b783          	ld	a5,-1964(a5) # ffffffffc02b2900 <pages>
ffffffffc02040b4:	40fa8733          	sub	a4,s5,a5
ffffffffc02040b8:	00005617          	auipc	a2,0x5
ffffffffc02040bc:	9b863603          	ld	a2,-1608(a2) # ffffffffc0208a70 <nbase>
ffffffffc02040c0:	8719                	srai	a4,a4,0x6
ffffffffc02040c2:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02040c4:	000af697          	auipc	a3,0xaf
ffffffffc02040c8:	8346b683          	ld	a3,-1996(a3) # ffffffffc02b28f8 <npage>
ffffffffc02040cc:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02040ce:	0732                	slli	a4,a4,0xc
ffffffffc02040d0:	28d77763          	bgeu	a4,a3,ffffffffc020435e <default_check+0x342>
    return page - pages + nbase;
ffffffffc02040d4:	40f98733          	sub	a4,s3,a5
ffffffffc02040d8:	8719                	srai	a4,a4,0x6
ffffffffc02040da:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02040dc:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02040de:	4cd77063          	bgeu	a4,a3,ffffffffc020459e <default_check+0x582>
    return page - pages + nbase;
ffffffffc02040e2:	40f507b3          	sub	a5,a0,a5
ffffffffc02040e6:	8799                	srai	a5,a5,0x6
ffffffffc02040e8:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02040ea:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02040ec:	30d7f963          	bgeu	a5,a3,ffffffffc02043fe <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc02040f0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02040f2:	00043c03          	ld	s8,0(s0)
ffffffffc02040f6:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02040fa:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02040fe:	e400                	sd	s0,8(s0)
ffffffffc0204100:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0204102:	000aa797          	auipc	a5,0xaa
ffffffffc0204106:	7a07ab23          	sw	zero,1974(a5) # ffffffffc02ae8b8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc020410a:	d2dfc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc020410e:	2c051863          	bnez	a0,ffffffffc02043de <default_check+0x3c2>
    free_page(p0);
ffffffffc0204112:	4585                	li	a1,1
ffffffffc0204114:	8556                	mv	a0,s5
ffffffffc0204116:	db3fc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    free_page(p1);
ffffffffc020411a:	4585                	li	a1,1
ffffffffc020411c:	854e                	mv	a0,s3
ffffffffc020411e:	dabfc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    free_page(p2);
ffffffffc0204122:	4585                	li	a1,1
ffffffffc0204124:	8552                	mv	a0,s4
ffffffffc0204126:	da3fc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    assert(nr_free == 3);
ffffffffc020412a:	4818                	lw	a4,16(s0)
ffffffffc020412c:	478d                	li	a5,3
ffffffffc020412e:	28f71863          	bne	a4,a5,ffffffffc02043be <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0204132:	4505                	li	a0,1
ffffffffc0204134:	d03fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0204138:	89aa                	mv	s3,a0
ffffffffc020413a:	26050263          	beqz	a0,ffffffffc020439e <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020413e:	4505                	li	a0,1
ffffffffc0204140:	cf7fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0204144:	8aaa                	mv	s5,a0
ffffffffc0204146:	3a050c63          	beqz	a0,ffffffffc02044fe <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020414a:	4505                	li	a0,1
ffffffffc020414c:	cebfc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0204150:	8a2a                	mv	s4,a0
ffffffffc0204152:	38050663          	beqz	a0,ffffffffc02044de <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0204156:	4505                	li	a0,1
ffffffffc0204158:	cdffc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc020415c:	36051163          	bnez	a0,ffffffffc02044be <default_check+0x4a2>
    free_page(p0);
ffffffffc0204160:	4585                	li	a1,1
ffffffffc0204162:	854e                	mv	a0,s3
ffffffffc0204164:	d65fc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0204168:	641c                	ld	a5,8(s0)
ffffffffc020416a:	20878a63          	beq	a5,s0,ffffffffc020437e <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc020416e:	4505                	li	a0,1
ffffffffc0204170:	cc7fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0204174:	30a99563          	bne	s3,a0,ffffffffc020447e <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0204178:	4505                	li	a0,1
ffffffffc020417a:	cbdfc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc020417e:	2e051063          	bnez	a0,ffffffffc020445e <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0204182:	481c                	lw	a5,16(s0)
ffffffffc0204184:	2a079d63          	bnez	a5,ffffffffc020443e <default_check+0x422>
    free_page(p);
ffffffffc0204188:	854e                	mv	a0,s3
ffffffffc020418a:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020418c:	01843023          	sd	s8,0(s0)
ffffffffc0204190:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0204194:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0204198:	d31fc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    free_page(p1);
ffffffffc020419c:	4585                	li	a1,1
ffffffffc020419e:	8556                	mv	a0,s5
ffffffffc02041a0:	d29fc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    free_page(p2);
ffffffffc02041a4:	4585                	li	a1,1
ffffffffc02041a6:	8552                	mv	a0,s4
ffffffffc02041a8:	d21fc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02041ac:	4515                	li	a0,5
ffffffffc02041ae:	c89fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc02041b2:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02041b4:	26050563          	beqz	a0,ffffffffc020441e <default_check+0x402>
ffffffffc02041b8:	651c                	ld	a5,8(a0)
ffffffffc02041ba:	8385                	srli	a5,a5,0x1
ffffffffc02041bc:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc02041be:	54079063          	bnez	a5,ffffffffc02046fe <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02041c2:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02041c4:	00043b03          	ld	s6,0(s0)
ffffffffc02041c8:	00843a83          	ld	s5,8(s0)
ffffffffc02041cc:	e000                	sd	s0,0(s0)
ffffffffc02041ce:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02041d0:	c67fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc02041d4:	50051563          	bnez	a0,ffffffffc02046de <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02041d8:	08098a13          	addi	s4,s3,128
ffffffffc02041dc:	8552                	mv	a0,s4
ffffffffc02041de:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02041e0:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02041e4:	000aa797          	auipc	a5,0xaa
ffffffffc02041e8:	6c07aa23          	sw	zero,1748(a5) # ffffffffc02ae8b8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02041ec:	cddfc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02041f0:	4511                	li	a0,4
ffffffffc02041f2:	c45fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc02041f6:	4c051463          	bnez	a0,ffffffffc02046be <default_check+0x6a2>
ffffffffc02041fa:	0889b783          	ld	a5,136(s3)
ffffffffc02041fe:	8385                	srli	a5,a5,0x1
ffffffffc0204200:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0204202:	48078e63          	beqz	a5,ffffffffc020469e <default_check+0x682>
ffffffffc0204206:	0909a703          	lw	a4,144(s3)
ffffffffc020420a:	478d                	li	a5,3
ffffffffc020420c:	48f71963          	bne	a4,a5,ffffffffc020469e <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0204210:	450d                	li	a0,3
ffffffffc0204212:	c25fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0204216:	8c2a                	mv	s8,a0
ffffffffc0204218:	46050363          	beqz	a0,ffffffffc020467e <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc020421c:	4505                	li	a0,1
ffffffffc020421e:	c19fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0204222:	42051e63          	bnez	a0,ffffffffc020465e <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0204226:	418a1c63          	bne	s4,s8,ffffffffc020463e <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020422a:	4585                	li	a1,1
ffffffffc020422c:	854e                	mv	a0,s3
ffffffffc020422e:	c9bfc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    free_pages(p1, 3);
ffffffffc0204232:	458d                	li	a1,3
ffffffffc0204234:	8552                	mv	a0,s4
ffffffffc0204236:	c93fc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
ffffffffc020423a:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc020423e:	04098c13          	addi	s8,s3,64
ffffffffc0204242:	8385                	srli	a5,a5,0x1
ffffffffc0204244:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0204246:	3c078c63          	beqz	a5,ffffffffc020461e <default_check+0x602>
ffffffffc020424a:	0109a703          	lw	a4,16(s3)
ffffffffc020424e:	4785                	li	a5,1
ffffffffc0204250:	3cf71763          	bne	a4,a5,ffffffffc020461e <default_check+0x602>
ffffffffc0204254:	008a3783          	ld	a5,8(s4)
ffffffffc0204258:	8385                	srli	a5,a5,0x1
ffffffffc020425a:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020425c:	3a078163          	beqz	a5,ffffffffc02045fe <default_check+0x5e2>
ffffffffc0204260:	010a2703          	lw	a4,16(s4)
ffffffffc0204264:	478d                	li	a5,3
ffffffffc0204266:	38f71c63          	bne	a4,a5,ffffffffc02045fe <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020426a:	4505                	li	a0,1
ffffffffc020426c:	bcbfc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0204270:	36a99763          	bne	s3,a0,ffffffffc02045de <default_check+0x5c2>
    free_page(p0);
ffffffffc0204274:	4585                	li	a1,1
ffffffffc0204276:	c53fc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020427a:	4509                	li	a0,2
ffffffffc020427c:	bbbfc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0204280:	32aa1f63          	bne	s4,a0,ffffffffc02045be <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0204284:	4589                	li	a1,2
ffffffffc0204286:	c43fc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    free_page(p2);
ffffffffc020428a:	4585                	li	a1,1
ffffffffc020428c:	8562                	mv	a0,s8
ffffffffc020428e:	c3bfc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0204292:	4515                	li	a0,5
ffffffffc0204294:	ba3fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0204298:	89aa                	mv	s3,a0
ffffffffc020429a:	48050263          	beqz	a0,ffffffffc020471e <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc020429e:	4505                	li	a0,1
ffffffffc02042a0:	b97fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc02042a4:	2c051d63          	bnez	a0,ffffffffc020457e <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02042a8:	481c                	lw	a5,16(s0)
ffffffffc02042aa:	2a079a63          	bnez	a5,ffffffffc020455e <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02042ae:	4595                	li	a1,5
ffffffffc02042b0:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02042b2:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02042b6:	01643023          	sd	s6,0(s0)
ffffffffc02042ba:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02042be:	c0bfc0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    return listelm->next;
ffffffffc02042c2:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02042c4:	00878963          	beq	a5,s0,ffffffffc02042d6 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02042c8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02042cc:	679c                	ld	a5,8(a5)
ffffffffc02042ce:	397d                	addiw	s2,s2,-1
ffffffffc02042d0:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02042d2:	fe879be3          	bne	a5,s0,ffffffffc02042c8 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02042d6:	26091463          	bnez	s2,ffffffffc020453e <default_check+0x522>
    assert(total == 0);
ffffffffc02042da:	46049263          	bnez	s1,ffffffffc020473e <default_check+0x722>
}
ffffffffc02042de:	60a6                	ld	ra,72(sp)
ffffffffc02042e0:	6406                	ld	s0,64(sp)
ffffffffc02042e2:	74e2                	ld	s1,56(sp)
ffffffffc02042e4:	7942                	ld	s2,48(sp)
ffffffffc02042e6:	79a2                	ld	s3,40(sp)
ffffffffc02042e8:	7a02                	ld	s4,32(sp)
ffffffffc02042ea:	6ae2                	ld	s5,24(sp)
ffffffffc02042ec:	6b42                	ld	s6,16(sp)
ffffffffc02042ee:	6ba2                	ld	s7,8(sp)
ffffffffc02042f0:	6c02                	ld	s8,0(sp)
ffffffffc02042f2:	6161                	addi	sp,sp,80
ffffffffc02042f4:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02042f6:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02042f8:	4481                	li	s1,0
ffffffffc02042fa:	4901                	li	s2,0
ffffffffc02042fc:	b38d                	j	ffffffffc020405e <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02042fe:	00003697          	auipc	a3,0x3
ffffffffc0204302:	78268693          	addi	a3,a3,1922 # ffffffffc0207a80 <commands+0x13c8>
ffffffffc0204306:	00002617          	auipc	a2,0x2
ffffffffc020430a:	7c260613          	addi	a2,a2,1986 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020430e:	0f000593          	li	a1,240
ffffffffc0204312:	00004517          	auipc	a0,0x4
ffffffffc0204316:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020431a:	eeffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020431e:	00004697          	auipc	a3,0x4
ffffffffc0204322:	ada68693          	addi	a3,a3,-1318 # ffffffffc0207df8 <commands+0x1740>
ffffffffc0204326:	00002617          	auipc	a2,0x2
ffffffffc020432a:	7a260613          	addi	a2,a2,1954 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020432e:	0bd00593          	li	a1,189
ffffffffc0204332:	00004517          	auipc	a0,0x4
ffffffffc0204336:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020433a:	ecffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020433e:	00004697          	auipc	a3,0x4
ffffffffc0204342:	ae268693          	addi	a3,a3,-1310 # ffffffffc0207e20 <commands+0x1768>
ffffffffc0204346:	00002617          	auipc	a2,0x2
ffffffffc020434a:	78260613          	addi	a2,a2,1922 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020434e:	0be00593          	li	a1,190
ffffffffc0204352:	00004517          	auipc	a0,0x4
ffffffffc0204356:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020435a:	eaffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020435e:	00004697          	auipc	a3,0x4
ffffffffc0204362:	b0268693          	addi	a3,a3,-1278 # ffffffffc0207e60 <commands+0x17a8>
ffffffffc0204366:	00002617          	auipc	a2,0x2
ffffffffc020436a:	76260613          	addi	a2,a2,1890 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020436e:	0c000593          	li	a1,192
ffffffffc0204372:	00004517          	auipc	a0,0x4
ffffffffc0204376:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020437a:	e8ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020437e:	00004697          	auipc	a3,0x4
ffffffffc0204382:	b6a68693          	addi	a3,a3,-1174 # ffffffffc0207ee8 <commands+0x1830>
ffffffffc0204386:	00002617          	auipc	a2,0x2
ffffffffc020438a:	74260613          	addi	a2,a2,1858 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020438e:	0d900593          	li	a1,217
ffffffffc0204392:	00004517          	auipc	a0,0x4
ffffffffc0204396:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020439a:	e6ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020439e:	00004697          	auipc	a3,0x4
ffffffffc02043a2:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0207d98 <commands+0x16e0>
ffffffffc02043a6:	00002617          	auipc	a2,0x2
ffffffffc02043aa:	72260613          	addi	a2,a2,1826 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02043ae:	0d200593          	li	a1,210
ffffffffc02043b2:	00004517          	auipc	a0,0x4
ffffffffc02043b6:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc02043ba:	e4ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 3);
ffffffffc02043be:	00004697          	auipc	a3,0x4
ffffffffc02043c2:	b1a68693          	addi	a3,a3,-1254 # ffffffffc0207ed8 <commands+0x1820>
ffffffffc02043c6:	00002617          	auipc	a2,0x2
ffffffffc02043ca:	70260613          	addi	a2,a2,1794 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02043ce:	0d000593          	li	a1,208
ffffffffc02043d2:	00004517          	auipc	a0,0x4
ffffffffc02043d6:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc02043da:	e2ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02043de:	00004697          	auipc	a3,0x4
ffffffffc02043e2:	ae268693          	addi	a3,a3,-1310 # ffffffffc0207ec0 <commands+0x1808>
ffffffffc02043e6:	00002617          	auipc	a2,0x2
ffffffffc02043ea:	6e260613          	addi	a2,a2,1762 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02043ee:	0cb00593          	li	a1,203
ffffffffc02043f2:	00004517          	auipc	a0,0x4
ffffffffc02043f6:	98e50513          	addi	a0,a0,-1650 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc02043fa:	e0ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02043fe:	00004697          	auipc	a3,0x4
ffffffffc0204402:	aa268693          	addi	a3,a3,-1374 # ffffffffc0207ea0 <commands+0x17e8>
ffffffffc0204406:	00002617          	auipc	a2,0x2
ffffffffc020440a:	6c260613          	addi	a2,a2,1730 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020440e:	0c200593          	li	a1,194
ffffffffc0204412:	00004517          	auipc	a0,0x4
ffffffffc0204416:	96e50513          	addi	a0,a0,-1682 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020441a:	deffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != NULL);
ffffffffc020441e:	00004697          	auipc	a3,0x4
ffffffffc0204422:	b0268693          	addi	a3,a3,-1278 # ffffffffc0207f20 <commands+0x1868>
ffffffffc0204426:	00002617          	auipc	a2,0x2
ffffffffc020442a:	6a260613          	addi	a2,a2,1698 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020442e:	0f800593          	li	a1,248
ffffffffc0204432:	00004517          	auipc	a0,0x4
ffffffffc0204436:	94e50513          	addi	a0,a0,-1714 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020443a:	dcffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc020443e:	00003697          	auipc	a3,0x3
ffffffffc0204442:	7e268693          	addi	a3,a3,2018 # ffffffffc0207c20 <commands+0x1568>
ffffffffc0204446:	00002617          	auipc	a2,0x2
ffffffffc020444a:	68260613          	addi	a2,a2,1666 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020444e:	0df00593          	li	a1,223
ffffffffc0204452:	00004517          	auipc	a0,0x4
ffffffffc0204456:	92e50513          	addi	a0,a0,-1746 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020445a:	daffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020445e:	00004697          	auipc	a3,0x4
ffffffffc0204462:	a6268693          	addi	a3,a3,-1438 # ffffffffc0207ec0 <commands+0x1808>
ffffffffc0204466:	00002617          	auipc	a2,0x2
ffffffffc020446a:	66260613          	addi	a2,a2,1634 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020446e:	0dd00593          	li	a1,221
ffffffffc0204472:	00004517          	auipc	a0,0x4
ffffffffc0204476:	90e50513          	addi	a0,a0,-1778 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020447a:	d8ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020447e:	00004697          	auipc	a3,0x4
ffffffffc0204482:	a8268693          	addi	a3,a3,-1406 # ffffffffc0207f00 <commands+0x1848>
ffffffffc0204486:	00002617          	auipc	a2,0x2
ffffffffc020448a:	64260613          	addi	a2,a2,1602 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020448e:	0dc00593          	li	a1,220
ffffffffc0204492:	00004517          	auipc	a0,0x4
ffffffffc0204496:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020449a:	d6ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020449e:	00004697          	auipc	a3,0x4
ffffffffc02044a2:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0207d98 <commands+0x16e0>
ffffffffc02044a6:	00002617          	auipc	a2,0x2
ffffffffc02044aa:	62260613          	addi	a2,a2,1570 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02044ae:	0b900593          	li	a1,185
ffffffffc02044b2:	00004517          	auipc	a0,0x4
ffffffffc02044b6:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc02044ba:	d4ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02044be:	00004697          	auipc	a3,0x4
ffffffffc02044c2:	a0268693          	addi	a3,a3,-1534 # ffffffffc0207ec0 <commands+0x1808>
ffffffffc02044c6:	00002617          	auipc	a2,0x2
ffffffffc02044ca:	60260613          	addi	a2,a2,1538 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02044ce:	0d600593          	li	a1,214
ffffffffc02044d2:	00004517          	auipc	a0,0x4
ffffffffc02044d6:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc02044da:	d2ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02044de:	00004697          	auipc	a3,0x4
ffffffffc02044e2:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0207dd8 <commands+0x1720>
ffffffffc02044e6:	00002617          	auipc	a2,0x2
ffffffffc02044ea:	5e260613          	addi	a2,a2,1506 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02044ee:	0d400593          	li	a1,212
ffffffffc02044f2:	00004517          	auipc	a0,0x4
ffffffffc02044f6:	88e50513          	addi	a0,a0,-1906 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc02044fa:	d0ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02044fe:	00004697          	auipc	a3,0x4
ffffffffc0204502:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0207db8 <commands+0x1700>
ffffffffc0204506:	00002617          	auipc	a2,0x2
ffffffffc020450a:	5c260613          	addi	a2,a2,1474 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020450e:	0d300593          	li	a1,211
ffffffffc0204512:	00004517          	auipc	a0,0x4
ffffffffc0204516:	86e50513          	addi	a0,a0,-1938 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020451a:	ceffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020451e:	00004697          	auipc	a3,0x4
ffffffffc0204522:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0207dd8 <commands+0x1720>
ffffffffc0204526:	00002617          	auipc	a2,0x2
ffffffffc020452a:	5a260613          	addi	a2,a2,1442 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020452e:	0bb00593          	li	a1,187
ffffffffc0204532:	00004517          	auipc	a0,0x4
ffffffffc0204536:	84e50513          	addi	a0,a0,-1970 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020453a:	ccffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(count == 0);
ffffffffc020453e:	00004697          	auipc	a3,0x4
ffffffffc0204542:	b3268693          	addi	a3,a3,-1230 # ffffffffc0208070 <commands+0x19b8>
ffffffffc0204546:	00002617          	auipc	a2,0x2
ffffffffc020454a:	58260613          	addi	a2,a2,1410 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020454e:	12500593          	li	a1,293
ffffffffc0204552:	00004517          	auipc	a0,0x4
ffffffffc0204556:	82e50513          	addi	a0,a0,-2002 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020455a:	caffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc020455e:	00003697          	auipc	a3,0x3
ffffffffc0204562:	6c268693          	addi	a3,a3,1730 # ffffffffc0207c20 <commands+0x1568>
ffffffffc0204566:	00002617          	auipc	a2,0x2
ffffffffc020456a:	56260613          	addi	a2,a2,1378 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020456e:	11a00593          	li	a1,282
ffffffffc0204572:	00004517          	auipc	a0,0x4
ffffffffc0204576:	80e50513          	addi	a0,a0,-2034 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020457a:	c8ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020457e:	00004697          	auipc	a3,0x4
ffffffffc0204582:	94268693          	addi	a3,a3,-1726 # ffffffffc0207ec0 <commands+0x1808>
ffffffffc0204586:	00002617          	auipc	a2,0x2
ffffffffc020458a:	54260613          	addi	a2,a2,1346 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020458e:	11800593          	li	a1,280
ffffffffc0204592:	00003517          	auipc	a0,0x3
ffffffffc0204596:	7ee50513          	addi	a0,a0,2030 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020459a:	c6ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020459e:	00004697          	auipc	a3,0x4
ffffffffc02045a2:	8e268693          	addi	a3,a3,-1822 # ffffffffc0207e80 <commands+0x17c8>
ffffffffc02045a6:	00002617          	auipc	a2,0x2
ffffffffc02045aa:	52260613          	addi	a2,a2,1314 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02045ae:	0c100593          	li	a1,193
ffffffffc02045b2:	00003517          	auipc	a0,0x3
ffffffffc02045b6:	7ce50513          	addi	a0,a0,1998 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc02045ba:	c4ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02045be:	00004697          	auipc	a3,0x4
ffffffffc02045c2:	a7268693          	addi	a3,a3,-1422 # ffffffffc0208030 <commands+0x1978>
ffffffffc02045c6:	00002617          	auipc	a2,0x2
ffffffffc02045ca:	50260613          	addi	a2,a2,1282 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02045ce:	11200593          	li	a1,274
ffffffffc02045d2:	00003517          	auipc	a0,0x3
ffffffffc02045d6:	7ae50513          	addi	a0,a0,1966 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc02045da:	c2ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02045de:	00004697          	auipc	a3,0x4
ffffffffc02045e2:	a3268693          	addi	a3,a3,-1486 # ffffffffc0208010 <commands+0x1958>
ffffffffc02045e6:	00002617          	auipc	a2,0x2
ffffffffc02045ea:	4e260613          	addi	a2,a2,1250 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02045ee:	11000593          	li	a1,272
ffffffffc02045f2:	00003517          	auipc	a0,0x3
ffffffffc02045f6:	78e50513          	addi	a0,a0,1934 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc02045fa:	c0ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02045fe:	00004697          	auipc	a3,0x4
ffffffffc0204602:	9ea68693          	addi	a3,a3,-1558 # ffffffffc0207fe8 <commands+0x1930>
ffffffffc0204606:	00002617          	auipc	a2,0x2
ffffffffc020460a:	4c260613          	addi	a2,a2,1218 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020460e:	10e00593          	li	a1,270
ffffffffc0204612:	00003517          	auipc	a0,0x3
ffffffffc0204616:	76e50513          	addi	a0,a0,1902 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020461a:	beffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020461e:	00004697          	auipc	a3,0x4
ffffffffc0204622:	9a268693          	addi	a3,a3,-1630 # ffffffffc0207fc0 <commands+0x1908>
ffffffffc0204626:	00002617          	auipc	a2,0x2
ffffffffc020462a:	4a260613          	addi	a2,a2,1186 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020462e:	10d00593          	li	a1,269
ffffffffc0204632:	00003517          	auipc	a0,0x3
ffffffffc0204636:	74e50513          	addi	a0,a0,1870 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020463a:	bcffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020463e:	00004697          	auipc	a3,0x4
ffffffffc0204642:	97268693          	addi	a3,a3,-1678 # ffffffffc0207fb0 <commands+0x18f8>
ffffffffc0204646:	00002617          	auipc	a2,0x2
ffffffffc020464a:	48260613          	addi	a2,a2,1154 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020464e:	10800593          	li	a1,264
ffffffffc0204652:	00003517          	auipc	a0,0x3
ffffffffc0204656:	72e50513          	addi	a0,a0,1838 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020465a:	baffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020465e:	00004697          	auipc	a3,0x4
ffffffffc0204662:	86268693          	addi	a3,a3,-1950 # ffffffffc0207ec0 <commands+0x1808>
ffffffffc0204666:	00002617          	auipc	a2,0x2
ffffffffc020466a:	46260613          	addi	a2,a2,1122 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020466e:	10700593          	li	a1,263
ffffffffc0204672:	00003517          	auipc	a0,0x3
ffffffffc0204676:	70e50513          	addi	a0,a0,1806 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020467a:	b8ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020467e:	00004697          	auipc	a3,0x4
ffffffffc0204682:	91268693          	addi	a3,a3,-1774 # ffffffffc0207f90 <commands+0x18d8>
ffffffffc0204686:	00002617          	auipc	a2,0x2
ffffffffc020468a:	44260613          	addi	a2,a2,1090 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020468e:	10600593          	li	a1,262
ffffffffc0204692:	00003517          	auipc	a0,0x3
ffffffffc0204696:	6ee50513          	addi	a0,a0,1774 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020469a:	b6ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020469e:	00004697          	auipc	a3,0x4
ffffffffc02046a2:	8c268693          	addi	a3,a3,-1854 # ffffffffc0207f60 <commands+0x18a8>
ffffffffc02046a6:	00002617          	auipc	a2,0x2
ffffffffc02046aa:	42260613          	addi	a2,a2,1058 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02046ae:	10500593          	li	a1,261
ffffffffc02046b2:	00003517          	auipc	a0,0x3
ffffffffc02046b6:	6ce50513          	addi	a0,a0,1742 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc02046ba:	b4ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02046be:	00004697          	auipc	a3,0x4
ffffffffc02046c2:	88a68693          	addi	a3,a3,-1910 # ffffffffc0207f48 <commands+0x1890>
ffffffffc02046c6:	00002617          	auipc	a2,0x2
ffffffffc02046ca:	40260613          	addi	a2,a2,1026 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02046ce:	10400593          	li	a1,260
ffffffffc02046d2:	00003517          	auipc	a0,0x3
ffffffffc02046d6:	6ae50513          	addi	a0,a0,1710 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc02046da:	b2ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02046de:	00003697          	auipc	a3,0x3
ffffffffc02046e2:	7e268693          	addi	a3,a3,2018 # ffffffffc0207ec0 <commands+0x1808>
ffffffffc02046e6:	00002617          	auipc	a2,0x2
ffffffffc02046ea:	3e260613          	addi	a2,a2,994 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02046ee:	0fe00593          	li	a1,254
ffffffffc02046f2:	00003517          	auipc	a0,0x3
ffffffffc02046f6:	68e50513          	addi	a0,a0,1678 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc02046fa:	b0ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!PageProperty(p0));
ffffffffc02046fe:	00004697          	auipc	a3,0x4
ffffffffc0204702:	83268693          	addi	a3,a3,-1998 # ffffffffc0207f30 <commands+0x1878>
ffffffffc0204706:	00002617          	auipc	a2,0x2
ffffffffc020470a:	3c260613          	addi	a2,a2,962 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020470e:	0f900593          	li	a1,249
ffffffffc0204712:	00003517          	auipc	a0,0x3
ffffffffc0204716:	66e50513          	addi	a0,a0,1646 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020471a:	aeffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020471e:	00004697          	auipc	a3,0x4
ffffffffc0204722:	93268693          	addi	a3,a3,-1742 # ffffffffc0208050 <commands+0x1998>
ffffffffc0204726:	00002617          	auipc	a2,0x2
ffffffffc020472a:	3a260613          	addi	a2,a2,930 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020472e:	11700593          	li	a1,279
ffffffffc0204732:	00003517          	auipc	a0,0x3
ffffffffc0204736:	64e50513          	addi	a0,a0,1614 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020473a:	acffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == 0);
ffffffffc020473e:	00004697          	auipc	a3,0x4
ffffffffc0204742:	94268693          	addi	a3,a3,-1726 # ffffffffc0208080 <commands+0x19c8>
ffffffffc0204746:	00002617          	auipc	a2,0x2
ffffffffc020474a:	38260613          	addi	a2,a2,898 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020474e:	12600593          	li	a1,294
ffffffffc0204752:	00003517          	auipc	a0,0x3
ffffffffc0204756:	62e50513          	addi	a0,a0,1582 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020475a:	aaffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == nr_free_pages());
ffffffffc020475e:	00003697          	auipc	a3,0x3
ffffffffc0204762:	33268693          	addi	a3,a3,818 # ffffffffc0207a90 <commands+0x13d8>
ffffffffc0204766:	00002617          	auipc	a2,0x2
ffffffffc020476a:	36260613          	addi	a2,a2,866 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020476e:	0f300593          	li	a1,243
ffffffffc0204772:	00003517          	auipc	a0,0x3
ffffffffc0204776:	60e50513          	addi	a0,a0,1550 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020477a:	a8ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020477e:	00003697          	auipc	a3,0x3
ffffffffc0204782:	63a68693          	addi	a3,a3,1594 # ffffffffc0207db8 <commands+0x1700>
ffffffffc0204786:	00002617          	auipc	a2,0x2
ffffffffc020478a:	34260613          	addi	a2,a2,834 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020478e:	0ba00593          	li	a1,186
ffffffffc0204792:	00003517          	auipc	a0,0x3
ffffffffc0204796:	5ee50513          	addi	a0,a0,1518 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc020479a:	a6ffb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020479e <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020479e:	1141                	addi	sp,sp,-16
ffffffffc02047a0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02047a2:	14058463          	beqz	a1,ffffffffc02048ea <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc02047a6:	00659693          	slli	a3,a1,0x6
ffffffffc02047aa:	96aa                	add	a3,a3,a0
ffffffffc02047ac:	87aa                	mv	a5,a0
ffffffffc02047ae:	02d50263          	beq	a0,a3,ffffffffc02047d2 <default_free_pages+0x34>
ffffffffc02047b2:	6798                	ld	a4,8(a5)
ffffffffc02047b4:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02047b6:	10071a63          	bnez	a4,ffffffffc02048ca <default_free_pages+0x12c>
ffffffffc02047ba:	6798                	ld	a4,8(a5)
ffffffffc02047bc:	8b09                	andi	a4,a4,2
ffffffffc02047be:	10071663          	bnez	a4,ffffffffc02048ca <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02047c2:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02047c6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02047ca:	04078793          	addi	a5,a5,64
ffffffffc02047ce:	fed792e3          	bne	a5,a3,ffffffffc02047b2 <default_free_pages+0x14>
    base->property = n;
ffffffffc02047d2:	2581                	sext.w	a1,a1
ffffffffc02047d4:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02047d6:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02047da:	4789                	li	a5,2
ffffffffc02047dc:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02047e0:	000aa697          	auipc	a3,0xaa
ffffffffc02047e4:	0c868693          	addi	a3,a3,200 # ffffffffc02ae8a8 <free_area>
ffffffffc02047e8:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02047ea:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02047ec:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02047f0:	9db9                	addw	a1,a1,a4
ffffffffc02047f2:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02047f4:	0ad78463          	beq	a5,a3,ffffffffc020489c <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc02047f8:	fe878713          	addi	a4,a5,-24
ffffffffc02047fc:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0204800:	4581                	li	a1,0
            if (base < page) {
ffffffffc0204802:	00e56a63          	bltu	a0,a4,ffffffffc0204816 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0204806:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204808:	04d70c63          	beq	a4,a3,ffffffffc0204860 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc020480c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020480e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204812:	fee57ae3          	bgeu	a0,a4,ffffffffc0204806 <default_free_pages+0x68>
ffffffffc0204816:	c199                	beqz	a1,ffffffffc020481c <default_free_pages+0x7e>
ffffffffc0204818:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020481c:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020481e:	e390                	sd	a2,0(a5)
ffffffffc0204820:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0204822:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204824:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0204826:	00d70d63          	beq	a4,a3,ffffffffc0204840 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc020482a:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc020482e:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0204832:	02059813          	slli	a6,a1,0x20
ffffffffc0204836:	01a85793          	srli	a5,a6,0x1a
ffffffffc020483a:	97b2                	add	a5,a5,a2
ffffffffc020483c:	02f50c63          	beq	a0,a5,ffffffffc0204874 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0204840:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0204842:	00d78c63          	beq	a5,a3,ffffffffc020485a <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0204846:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0204848:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc020484c:	02061593          	slli	a1,a2,0x20
ffffffffc0204850:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0204854:	972a                	add	a4,a4,a0
ffffffffc0204856:	04e68a63          	beq	a3,a4,ffffffffc02048aa <default_free_pages+0x10c>
}
ffffffffc020485a:	60a2                	ld	ra,8(sp)
ffffffffc020485c:	0141                	addi	sp,sp,16
ffffffffc020485e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204860:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204862:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0204864:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204866:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204868:	02d70763          	beq	a4,a3,ffffffffc0204896 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc020486c:	8832                	mv	a6,a2
ffffffffc020486e:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0204870:	87ba                	mv	a5,a4
ffffffffc0204872:	bf71                	j	ffffffffc020480e <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0204874:	491c                	lw	a5,16(a0)
ffffffffc0204876:	9dbd                	addw	a1,a1,a5
ffffffffc0204878:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020487c:	57f5                	li	a5,-3
ffffffffc020487e:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204882:	01853803          	ld	a6,24(a0)
ffffffffc0204886:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0204888:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc020488a:	00b83423          	sd	a1,8(a6) # fffffffffff80008 <end+0x3fccd6a4>
    return listelm->next;
ffffffffc020488e:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0204890:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0204894:	b77d                	j	ffffffffc0204842 <default_free_pages+0xa4>
ffffffffc0204896:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204898:	873e                	mv	a4,a5
ffffffffc020489a:	bf41                	j	ffffffffc020482a <default_free_pages+0x8c>
}
ffffffffc020489c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020489e:	e390                	sd	a2,0(a5)
ffffffffc02048a0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02048a2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02048a4:	ed1c                	sd	a5,24(a0)
ffffffffc02048a6:	0141                	addi	sp,sp,16
ffffffffc02048a8:	8082                	ret
            base->property += p->property;
ffffffffc02048aa:	ff87a703          	lw	a4,-8(a5)
ffffffffc02048ae:	ff078693          	addi	a3,a5,-16
ffffffffc02048b2:	9e39                	addw	a2,a2,a4
ffffffffc02048b4:	c910                	sw	a2,16(a0)
ffffffffc02048b6:	5775                	li	a4,-3
ffffffffc02048b8:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02048bc:	6398                	ld	a4,0(a5)
ffffffffc02048be:	679c                	ld	a5,8(a5)
}
ffffffffc02048c0:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02048c2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02048c4:	e398                	sd	a4,0(a5)
ffffffffc02048c6:	0141                	addi	sp,sp,16
ffffffffc02048c8:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02048ca:	00003697          	auipc	a3,0x3
ffffffffc02048ce:	7ce68693          	addi	a3,a3,1998 # ffffffffc0208098 <commands+0x19e0>
ffffffffc02048d2:	00002617          	auipc	a2,0x2
ffffffffc02048d6:	1f660613          	addi	a2,a2,502 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02048da:	08300593          	li	a1,131
ffffffffc02048de:	00003517          	auipc	a0,0x3
ffffffffc02048e2:	4a250513          	addi	a0,a0,1186 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc02048e6:	923fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc02048ea:	00003697          	auipc	a3,0x3
ffffffffc02048ee:	7a668693          	addi	a3,a3,1958 # ffffffffc0208090 <commands+0x19d8>
ffffffffc02048f2:	00002617          	auipc	a2,0x2
ffffffffc02048f6:	1d660613          	addi	a2,a2,470 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02048fa:	08000593          	li	a1,128
ffffffffc02048fe:	00003517          	auipc	a0,0x3
ffffffffc0204902:	48250513          	addi	a0,a0,1154 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc0204906:	903fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020490a <default_alloc_pages>:
    assert(n > 0);
ffffffffc020490a:	c941                	beqz	a0,ffffffffc020499a <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc020490c:	000aa597          	auipc	a1,0xaa
ffffffffc0204910:	f9c58593          	addi	a1,a1,-100 # ffffffffc02ae8a8 <free_area>
ffffffffc0204914:	0105a803          	lw	a6,16(a1)
ffffffffc0204918:	872a                	mv	a4,a0
ffffffffc020491a:	02081793          	slli	a5,a6,0x20
ffffffffc020491e:	9381                	srli	a5,a5,0x20
ffffffffc0204920:	00a7ee63          	bltu	a5,a0,ffffffffc020493c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0204924:	87ae                	mv	a5,a1
ffffffffc0204926:	a801                	j	ffffffffc0204936 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0204928:	ff87a683          	lw	a3,-8(a5)
ffffffffc020492c:	02069613          	slli	a2,a3,0x20
ffffffffc0204930:	9201                	srli	a2,a2,0x20
ffffffffc0204932:	00e67763          	bgeu	a2,a4,ffffffffc0204940 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0204936:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204938:	feb798e3          	bne	a5,a1,ffffffffc0204928 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020493c:	4501                	li	a0,0
}
ffffffffc020493e:	8082                	ret
    return listelm->prev;
ffffffffc0204940:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204944:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0204948:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc020494c:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0204950:	0068b423          	sd	t1,8(a7) # 1008 <_binary_obj___user_faultread_out_size-0x8bb8>
    next->prev = prev;
ffffffffc0204954:	01133023          	sd	a7,0(t1) # 80000 <_binary_obj___user_exit_out_size+0x74ed0>
        if (page->property > n) {
ffffffffc0204958:	02c77863          	bgeu	a4,a2,ffffffffc0204988 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc020495c:	071a                	slli	a4,a4,0x6
ffffffffc020495e:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0204960:	41c686bb          	subw	a3,a3,t3
ffffffffc0204964:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204966:	00870613          	addi	a2,a4,8
ffffffffc020496a:	4689                	li	a3,2
ffffffffc020496c:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204970:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0204974:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0204978:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020497c:	e290                	sd	a2,0(a3)
ffffffffc020497e:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0204982:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0204984:	01173c23          	sd	a7,24(a4)
ffffffffc0204988:	41c8083b          	subw	a6,a6,t3
ffffffffc020498c:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204990:	5775                	li	a4,-3
ffffffffc0204992:	17c1                	addi	a5,a5,-16
ffffffffc0204994:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0204998:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020499a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020499c:	00003697          	auipc	a3,0x3
ffffffffc02049a0:	6f468693          	addi	a3,a3,1780 # ffffffffc0208090 <commands+0x19d8>
ffffffffc02049a4:	00002617          	auipc	a2,0x2
ffffffffc02049a8:	12460613          	addi	a2,a2,292 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02049ac:	06200593          	li	a1,98
ffffffffc02049b0:	00003517          	auipc	a0,0x3
ffffffffc02049b4:	3d050513          	addi	a0,a0,976 # ffffffffc0207d80 <commands+0x16c8>
default_alloc_pages(size_t n) {
ffffffffc02049b8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02049ba:	84ffb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02049be <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02049be:	1141                	addi	sp,sp,-16
ffffffffc02049c0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02049c2:	c5f1                	beqz	a1,ffffffffc0204a8e <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc02049c4:	00659693          	slli	a3,a1,0x6
ffffffffc02049c8:	96aa                	add	a3,a3,a0
ffffffffc02049ca:	87aa                	mv	a5,a0
ffffffffc02049cc:	00d50f63          	beq	a0,a3,ffffffffc02049ea <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02049d0:	6798                	ld	a4,8(a5)
ffffffffc02049d2:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc02049d4:	cf49                	beqz	a4,ffffffffc0204a6e <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02049d6:	0007a823          	sw	zero,16(a5)
ffffffffc02049da:	0007b423          	sd	zero,8(a5)
ffffffffc02049de:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02049e2:	04078793          	addi	a5,a5,64
ffffffffc02049e6:	fed795e3          	bne	a5,a3,ffffffffc02049d0 <default_init_memmap+0x12>
    base->property = n;
ffffffffc02049ea:	2581                	sext.w	a1,a1
ffffffffc02049ec:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02049ee:	4789                	li	a5,2
ffffffffc02049f0:	00850713          	addi	a4,a0,8
ffffffffc02049f4:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02049f8:	000aa697          	auipc	a3,0xaa
ffffffffc02049fc:	eb068693          	addi	a3,a3,-336 # ffffffffc02ae8a8 <free_area>
ffffffffc0204a00:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204a02:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0204a04:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0204a08:	9db9                	addw	a1,a1,a4
ffffffffc0204a0a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0204a0c:	04d78a63          	beq	a5,a3,ffffffffc0204a60 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0204a10:	fe878713          	addi	a4,a5,-24
ffffffffc0204a14:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0204a18:	4581                	li	a1,0
            if (base < page) {
ffffffffc0204a1a:	00e56a63          	bltu	a0,a4,ffffffffc0204a2e <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0204a1e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204a20:	02d70263          	beq	a4,a3,ffffffffc0204a44 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0204a24:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204a26:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204a2a:	fee57ae3          	bgeu	a0,a4,ffffffffc0204a1e <default_init_memmap+0x60>
ffffffffc0204a2e:	c199                	beqz	a1,ffffffffc0204a34 <default_init_memmap+0x76>
ffffffffc0204a30:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204a34:	6398                	ld	a4,0(a5)
}
ffffffffc0204a36:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0204a38:	e390                	sd	a2,0(a5)
ffffffffc0204a3a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0204a3c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204a3e:	ed18                	sd	a4,24(a0)
ffffffffc0204a40:	0141                	addi	sp,sp,16
ffffffffc0204a42:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204a44:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204a46:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0204a48:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204a4a:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204a4c:	00d70663          	beq	a4,a3,ffffffffc0204a58 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0204a50:	8832                	mv	a6,a2
ffffffffc0204a52:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0204a54:	87ba                	mv	a5,a4
ffffffffc0204a56:	bfc1                	j	ffffffffc0204a26 <default_init_memmap+0x68>
}
ffffffffc0204a58:	60a2                	ld	ra,8(sp)
ffffffffc0204a5a:	e290                	sd	a2,0(a3)
ffffffffc0204a5c:	0141                	addi	sp,sp,16
ffffffffc0204a5e:	8082                	ret
ffffffffc0204a60:	60a2                	ld	ra,8(sp)
ffffffffc0204a62:	e390                	sd	a2,0(a5)
ffffffffc0204a64:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204a66:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204a68:	ed1c                	sd	a5,24(a0)
ffffffffc0204a6a:	0141                	addi	sp,sp,16
ffffffffc0204a6c:	8082                	ret
        assert(PageReserved(p));
ffffffffc0204a6e:	00003697          	auipc	a3,0x3
ffffffffc0204a72:	65268693          	addi	a3,a3,1618 # ffffffffc02080c0 <commands+0x1a08>
ffffffffc0204a76:	00002617          	auipc	a2,0x2
ffffffffc0204a7a:	05260613          	addi	a2,a2,82 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0204a7e:	04900593          	li	a1,73
ffffffffc0204a82:	00003517          	auipc	a0,0x3
ffffffffc0204a86:	2fe50513          	addi	a0,a0,766 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc0204a8a:	f7efb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc0204a8e:	00003697          	auipc	a3,0x3
ffffffffc0204a92:	60268693          	addi	a3,a3,1538 # ffffffffc0208090 <commands+0x19d8>
ffffffffc0204a96:	00002617          	auipc	a2,0x2
ffffffffc0204a9a:	03260613          	addi	a2,a2,50 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0204a9e:	04600593          	li	a1,70
ffffffffc0204aa2:	00003517          	auipc	a0,0x3
ffffffffc0204aa6:	2de50513          	addi	a0,a0,734 # ffffffffc0207d80 <commands+0x16c8>
ffffffffc0204aaa:	f5efb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204aae <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204aae:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204ab0:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204ab2:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204ab4:	a75fb0ef          	jal	ra,ffffffffc0200528 <ide_device_valid>
ffffffffc0204ab8:	cd01                	beqz	a0,ffffffffc0204ad0 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204aba:	4505                	li	a0,1
ffffffffc0204abc:	a73fb0ef          	jal	ra,ffffffffc020052e <ide_device_size>
}
ffffffffc0204ac0:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204ac2:	810d                	srli	a0,a0,0x3
ffffffffc0204ac4:	000ae797          	auipc	a5,0xae
ffffffffc0204ac8:	e6a7b623          	sd	a0,-404(a5) # ffffffffc02b2930 <max_swap_offset>
}
ffffffffc0204acc:	0141                	addi	sp,sp,16
ffffffffc0204ace:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204ad0:	00003617          	auipc	a2,0x3
ffffffffc0204ad4:	65060613          	addi	a2,a2,1616 # ffffffffc0208120 <default_pmm_manager+0x38>
ffffffffc0204ad8:	45b5                	li	a1,13
ffffffffc0204ada:	00003517          	auipc	a0,0x3
ffffffffc0204ade:	66650513          	addi	a0,a0,1638 # ffffffffc0208140 <default_pmm_manager+0x58>
ffffffffc0204ae2:	f26fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204ae6 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204ae6:	1141                	addi	sp,sp,-16
ffffffffc0204ae8:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204aea:	00855793          	srli	a5,a0,0x8
ffffffffc0204aee:	cbb1                	beqz	a5,ffffffffc0204b42 <swapfs_write+0x5c>
ffffffffc0204af0:	000ae717          	auipc	a4,0xae
ffffffffc0204af4:	e4073703          	ld	a4,-448(a4) # ffffffffc02b2930 <max_swap_offset>
ffffffffc0204af8:	04e7f563          	bgeu	a5,a4,ffffffffc0204b42 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204afc:	000ae617          	auipc	a2,0xae
ffffffffc0204b00:	e0463603          	ld	a2,-508(a2) # ffffffffc02b2900 <pages>
ffffffffc0204b04:	8d91                	sub	a1,a1,a2
ffffffffc0204b06:	4065d613          	srai	a2,a1,0x6
ffffffffc0204b0a:	00004717          	auipc	a4,0x4
ffffffffc0204b0e:	f6673703          	ld	a4,-154(a4) # ffffffffc0208a70 <nbase>
ffffffffc0204b12:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204b14:	00c61713          	slli	a4,a2,0xc
ffffffffc0204b18:	8331                	srli	a4,a4,0xc
ffffffffc0204b1a:	000ae697          	auipc	a3,0xae
ffffffffc0204b1e:	dde6b683          	ld	a3,-546(a3) # ffffffffc02b28f8 <npage>
ffffffffc0204b22:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b26:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204b28:	02d77963          	bgeu	a4,a3,ffffffffc0204b5a <swapfs_write+0x74>
}
ffffffffc0204b2c:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b2e:	000ae797          	auipc	a5,0xae
ffffffffc0204b32:	de27b783          	ld	a5,-542(a5) # ffffffffc02b2910 <va_pa_offset>
ffffffffc0204b36:	46a1                	li	a3,8
ffffffffc0204b38:	963e                	add	a2,a2,a5
ffffffffc0204b3a:	4505                	li	a0,1
}
ffffffffc0204b3c:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b3e:	9f7fb06f          	j	ffffffffc0200534 <ide_write_secs>
ffffffffc0204b42:	86aa                	mv	a3,a0
ffffffffc0204b44:	00003617          	auipc	a2,0x3
ffffffffc0204b48:	61460613          	addi	a2,a2,1556 # ffffffffc0208158 <default_pmm_manager+0x70>
ffffffffc0204b4c:	45e5                	li	a1,25
ffffffffc0204b4e:	00003517          	auipc	a0,0x3
ffffffffc0204b52:	5f250513          	addi	a0,a0,1522 # ffffffffc0208140 <default_pmm_manager+0x58>
ffffffffc0204b56:	eb2fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204b5a:	86b2                	mv	a3,a2
ffffffffc0204b5c:	06900593          	li	a1,105
ffffffffc0204b60:	00002617          	auipc	a2,0x2
ffffffffc0204b64:	2b060613          	addi	a2,a2,688 # ffffffffc0206e10 <commands+0x758>
ffffffffc0204b68:	00002517          	auipc	a0,0x2
ffffffffc0204b6c:	27050513          	addi	a0,a0,624 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0204b70:	e98fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204b74 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204b74:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204b76:	9402                	jalr	s0

	jal do_exit
ffffffffc0204b78:	632000ef          	jal	ra,ffffffffc02051aa <do_exit>

ffffffffc0204b7c <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204b7c:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204b80:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204b84:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204b86:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204b88:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204b8c:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204b90:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204b94:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204b98:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204b9c:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204ba0:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204ba4:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204ba8:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204bac:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204bb0:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204bb4:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204bb8:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204bba:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204bbc:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204bc0:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204bc4:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204bc8:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204bcc:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204bd0:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204bd4:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204bd8:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204bdc:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204be0:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204be4:	8082                	ret

ffffffffc0204be6 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204be6:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204be8:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204bec:	e022                	sd	s0,0(sp)
ffffffffc0204bee:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204bf0:	9d9fe0ef          	jal	ra,ffffffffc02035c8 <kmalloc>
ffffffffc0204bf4:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204bf6:	c521                	beqz	a0,ffffffffc0204c3e <alloc_proc+0x58>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->state = PROC_UNINIT;
ffffffffc0204bf8:	57fd                	li	a5,-1
ffffffffc0204bfa:	1782                	slli	a5,a5,0x20
ffffffffc0204bfc:	e11c                	sd	a5,0(a0)
    proc->runs = 0;  
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204bfe:	07000613          	li	a2,112
ffffffffc0204c02:	4581                	li	a1,0
    proc->runs = 0;  
ffffffffc0204c04:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0204c08:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0204c0c:	00053c23          	sd	zero,24(a0)
    proc->parent = NULL;
ffffffffc0204c10:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc0204c14:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204c18:	03050513          	addi	a0,a0,48
ffffffffc0204c1c:	3c2010ef          	jal	ra,ffffffffc0205fde <memset>
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
ffffffffc0204c20:	000ae797          	auipc	a5,0xae
ffffffffc0204c24:	cc87b783          	ld	a5,-824(a5) # ffffffffc02b28e8 <boot_cr3>
    proc->tf = NULL;
ffffffffc0204c28:	0a043023          	sd	zero,160(s0)
    proc->cr3 = boot_cr3;
ffffffffc0204c2c:	f45c                	sd	a5,168(s0)
    proc->flags = 0;
ffffffffc0204c2e:	0a042823          	sw	zero,176(s0)
    memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204c32:	463d                	li	a2,15
ffffffffc0204c34:	4581                	li	a1,0
ffffffffc0204c36:	0b440513          	addi	a0,s0,180
ffffffffc0204c3a:	3a4010ef          	jal	ra,ffffffffc0205fde <memset>
    }
    return proc;
}
ffffffffc0204c3e:	60a2                	ld	ra,8(sp)
ffffffffc0204c40:	8522                	mv	a0,s0
ffffffffc0204c42:	6402                	ld	s0,0(sp)
ffffffffc0204c44:	0141                	addi	sp,sp,16
ffffffffc0204c46:	8082                	ret

ffffffffc0204c48 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204c48:	000ae797          	auipc	a5,0xae
ffffffffc0204c4c:	d007b783          	ld	a5,-768(a5) # ffffffffc02b2948 <current>
ffffffffc0204c50:	73c8                	ld	a0,160(a5)
ffffffffc0204c52:	900fc06f          	j	ffffffffc0200d52 <forkrets>

ffffffffc0204c56 <user_main>:
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
ffffffffc0204c56:	000ae797          	auipc	a5,0xae
ffffffffc0204c5a:	cf27b783          	ld	a5,-782(a5) # ffffffffc02b2948 <current>
ffffffffc0204c5e:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204c60:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE(exit);
ffffffffc0204c62:	00003617          	auipc	a2,0x3
ffffffffc0204c66:	51660613          	addi	a2,a2,1302 # ffffffffc0208178 <default_pmm_manager+0x90>
ffffffffc0204c6a:	00003517          	auipc	a0,0x3
ffffffffc0204c6e:	51650513          	addi	a0,a0,1302 # ffffffffc0208180 <default_pmm_manager+0x98>
user_main(void *arg) {
ffffffffc0204c72:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE(exit);
ffffffffc0204c74:	c58fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0204c78:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204c7c:	4b878793          	addi	a5,a5,1208 # b130 <_binary_obj___user_exit_out_size>
ffffffffc0204c80:	e43e                	sd	a5,8(sp)
ffffffffc0204c82:	00003517          	auipc	a0,0x3
ffffffffc0204c86:	4f650513          	addi	a0,a0,1270 # ffffffffc0208178 <default_pmm_manager+0x90>
ffffffffc0204c8a:	0003a797          	auipc	a5,0x3a
ffffffffc0204c8e:	41678793          	addi	a5,a5,1046 # ffffffffc023f0a0 <_binary_obj___user_exit_out_start>
ffffffffc0204c92:	f03e                	sd	a5,32(sp)
ffffffffc0204c94:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204c96:	e802                	sd	zero,16(sp)
ffffffffc0204c98:	2ca010ef          	jal	ra,ffffffffc0205f62 <strlen>
ffffffffc0204c9c:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204c9e:	4511                	li	a0,4
ffffffffc0204ca0:	55a2                	lw	a1,40(sp)
ffffffffc0204ca2:	4662                	lw	a2,24(sp)
ffffffffc0204ca4:	5682                	lw	a3,32(sp)
ffffffffc0204ca6:	4722                	lw	a4,8(sp)
ffffffffc0204ca8:	48a9                	li	a7,10
ffffffffc0204caa:	9002                	ebreak
ffffffffc0204cac:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204cae:	65c2                	ld	a1,16(sp)
ffffffffc0204cb0:	00003517          	auipc	a0,0x3
ffffffffc0204cb4:	4f850513          	addi	a0,a0,1272 # ffffffffc02081a8 <default_pmm_manager+0xc0>
ffffffffc0204cb8:	c14fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
#endif
    panic("user_main execve failed.\n");
ffffffffc0204cbc:	00003617          	auipc	a2,0x3
ffffffffc0204cc0:	4fc60613          	addi	a2,a2,1276 # ffffffffc02081b8 <default_pmm_manager+0xd0>
ffffffffc0204cc4:	34900593          	li	a1,841
ffffffffc0204cc8:	00003517          	auipc	a0,0x3
ffffffffc0204ccc:	51050513          	addi	a0,a0,1296 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc0204cd0:	d38fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204cd4 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204cd4:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204cd6:	1141                	addi	sp,sp,-16
ffffffffc0204cd8:	e406                	sd	ra,8(sp)
ffffffffc0204cda:	c02007b7          	lui	a5,0xc0200
ffffffffc0204cde:	02f6ee63          	bltu	a3,a5,ffffffffc0204d1a <put_pgdir+0x46>
ffffffffc0204ce2:	000ae517          	auipc	a0,0xae
ffffffffc0204ce6:	c2e53503          	ld	a0,-978(a0) # ffffffffc02b2910 <va_pa_offset>
ffffffffc0204cea:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204cec:	82b1                	srli	a3,a3,0xc
ffffffffc0204cee:	000ae797          	auipc	a5,0xae
ffffffffc0204cf2:	c0a7b783          	ld	a5,-1014(a5) # ffffffffc02b28f8 <npage>
ffffffffc0204cf6:	02f6fe63          	bgeu	a3,a5,ffffffffc0204d32 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204cfa:	00004517          	auipc	a0,0x4
ffffffffc0204cfe:	d7653503          	ld	a0,-650(a0) # ffffffffc0208a70 <nbase>
}
ffffffffc0204d02:	60a2                	ld	ra,8(sp)
ffffffffc0204d04:	8e89                	sub	a3,a3,a0
ffffffffc0204d06:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204d08:	000ae517          	auipc	a0,0xae
ffffffffc0204d0c:	bf853503          	ld	a0,-1032(a0) # ffffffffc02b2900 <pages>
ffffffffc0204d10:	4585                	li	a1,1
ffffffffc0204d12:	9536                	add	a0,a0,a3
}
ffffffffc0204d14:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204d16:	9b2fc06f          	j	ffffffffc0200ec8 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204d1a:	00002617          	auipc	a2,0x2
ffffffffc0204d1e:	1ce60613          	addi	a2,a2,462 # ffffffffc0206ee8 <commands+0x830>
ffffffffc0204d22:	06e00593          	li	a1,110
ffffffffc0204d26:	00002517          	auipc	a0,0x2
ffffffffc0204d2a:	0b250513          	addi	a0,a0,178 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0204d2e:	cdafb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204d32:	00002617          	auipc	a2,0x2
ffffffffc0204d36:	08660613          	addi	a2,a2,134 # ffffffffc0206db8 <commands+0x700>
ffffffffc0204d3a:	06200593          	li	a1,98
ffffffffc0204d3e:	00002517          	auipc	a0,0x2
ffffffffc0204d42:	09a50513          	addi	a0,a0,154 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0204d46:	cc2fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204d4a <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204d4a:	7179                	addi	sp,sp,-48
ffffffffc0204d4c:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204d4e:	000ae917          	auipc	s2,0xae
ffffffffc0204d52:	bfa90913          	addi	s2,s2,-1030 # ffffffffc02b2948 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204d56:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204d58:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204d5c:	f406                	sd	ra,40(sp)
ffffffffc0204d5e:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204d60:	02a48863          	beq	s1,a0,ffffffffc0204d90 <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204d64:	100027f3          	csrr	a5,sstatus
ffffffffc0204d68:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204d6a:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204d6c:	ef9d                	bnez	a5,ffffffffc0204daa <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204d6e:	755c                	ld	a5,168(a0)
ffffffffc0204d70:	577d                	li	a4,-1
ffffffffc0204d72:	177e                	slli	a4,a4,0x3f
ffffffffc0204d74:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0204d76:	00a93023          	sd	a0,0(s2)
ffffffffc0204d7a:	8fd9                	or	a5,a5,a4
ffffffffc0204d7c:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204d80:	03050593          	addi	a1,a0,48
ffffffffc0204d84:	03048513          	addi	a0,s1,48
ffffffffc0204d88:	df5ff0ef          	jal	ra,ffffffffc0204b7c <switch_to>
    if (flag) {
ffffffffc0204d8c:	00099863          	bnez	s3,ffffffffc0204d9c <proc_run+0x52>
}
ffffffffc0204d90:	70a2                	ld	ra,40(sp)
ffffffffc0204d92:	7482                	ld	s1,32(sp)
ffffffffc0204d94:	6962                	ld	s2,24(sp)
ffffffffc0204d96:	69c2                	ld	s3,16(sp)
ffffffffc0204d98:	6145                	addi	sp,sp,48
ffffffffc0204d9a:	8082                	ret
ffffffffc0204d9c:	70a2                	ld	ra,40(sp)
ffffffffc0204d9e:	7482                	ld	s1,32(sp)
ffffffffc0204da0:	6962                	ld	s2,24(sp)
ffffffffc0204da2:	69c2                	ld	s3,16(sp)
ffffffffc0204da4:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204da6:	879fb06f          	j	ffffffffc020061e <intr_enable>
ffffffffc0204daa:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204dac:	879fb0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc0204db0:	6522                	ld	a0,8(sp)
ffffffffc0204db2:	4985                	li	s3,1
ffffffffc0204db4:	bf6d                	j	ffffffffc0204d6e <proc_run+0x24>

ffffffffc0204db6 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204db6:	7159                	addi	sp,sp,-112
ffffffffc0204db8:	eca6                	sd	s1,88(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204dba:	000ae497          	auipc	s1,0xae
ffffffffc0204dbe:	ba648493          	addi	s1,s1,-1114 # ffffffffc02b2960 <nr_process>
ffffffffc0204dc2:	4098                	lw	a4,0(s1)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204dc4:	f486                	sd	ra,104(sp)
ffffffffc0204dc6:	f0a2                	sd	s0,96(sp)
ffffffffc0204dc8:	e8ca                	sd	s2,80(sp)
ffffffffc0204dca:	e4ce                	sd	s3,72(sp)
ffffffffc0204dcc:	e0d2                	sd	s4,64(sp)
ffffffffc0204dce:	fc56                	sd	s5,56(sp)
ffffffffc0204dd0:	f85a                	sd	s6,48(sp)
ffffffffc0204dd2:	f45e                	sd	s7,40(sp)
ffffffffc0204dd4:	f062                	sd	s8,32(sp)
ffffffffc0204dd6:	ec66                	sd	s9,24(sp)
ffffffffc0204dd8:	e86a                	sd	s10,16(sp)
ffffffffc0204dda:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204ddc:	6785                	lui	a5,0x1
ffffffffc0204dde:	2ef75a63          	bge	a4,a5,ffffffffc02050d2 <do_fork+0x31c>
ffffffffc0204de2:	8a2a                	mv	s4,a0
ffffffffc0204de4:	892e                	mv	s2,a1
ffffffffc0204de6:	8432                	mv	s0,a2
   proc = alloc_proc();
ffffffffc0204de8:	dffff0ef          	jal	ra,ffffffffc0204be6 <alloc_proc>
ffffffffc0204dec:	89aa                	mv	s3,a0
    if (proc == NULL)
ffffffffc0204dee:	2e050763          	beqz	a0,ffffffffc02050dc <do_fork+0x326>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204df2:	4509                	li	a0,2
ffffffffc0204df4:	842fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
    if (page != NULL) {
ffffffffc0204df8:	28050763          	beqz	a0,ffffffffc0205086 <do_fork+0x2d0>
    return page - pages + nbase;
ffffffffc0204dfc:	000aed97          	auipc	s11,0xae
ffffffffc0204e00:	b04d8d93          	addi	s11,s11,-1276 # ffffffffc02b2900 <pages>
ffffffffc0204e04:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc0204e08:	000aed17          	auipc	s10,0xae
ffffffffc0204e0c:	af0d0d13          	addi	s10,s10,-1296 # ffffffffc02b28f8 <npage>
    return page - pages + nbase;
ffffffffc0204e10:	00004c97          	auipc	s9,0x4
ffffffffc0204e14:	c60cbc83          	ld	s9,-928(s9) # ffffffffc0208a70 <nbase>
ffffffffc0204e18:	40d506b3          	sub	a3,a0,a3
ffffffffc0204e1c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204e1e:	5c7d                	li	s8,-1
ffffffffc0204e20:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0204e24:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0204e26:	00cc5c13          	srli	s8,s8,0xc
ffffffffc0204e2a:	0186f733          	and	a4,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e2e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e30:	2cf77563          	bgeu	a4,a5,ffffffffc02050fa <do_fork+0x344>
ffffffffc0204e34:	000aea97          	auipc	s5,0xae
ffffffffc0204e38:	adca8a93          	addi	s5,s5,-1316 # ffffffffc02b2910 <va_pa_offset>
ffffffffc0204e3c:	000ab783          	ld	a5,0(s5)
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204e40:	000ae717          	auipc	a4,0xae
ffffffffc0204e44:	b0873703          	ld	a4,-1272(a4) # ffffffffc02b2948 <current>
ffffffffc0204e48:	02873b83          	ld	s7,40(a4)
ffffffffc0204e4c:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204e4e:	00d9b823          	sd	a3,16(s3)
    if (oldmm == NULL) {
ffffffffc0204e52:	020b8a63          	beqz	s7,ffffffffc0204e86 <do_fork+0xd0>
    if (clone_flags & CLONE_VM) {
ffffffffc0204e56:	100a7a13          	andi	s4,s4,256
ffffffffc0204e5a:	180a0563          	beqz	s4,ffffffffc0204fe4 <do_fork+0x22e>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204e5e:	030ba703          	lw	a4,48(s7)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204e62:	018bb783          	ld	a5,24(s7)
ffffffffc0204e66:	c02006b7          	lui	a3,0xc0200
ffffffffc0204e6a:	2705                	addiw	a4,a4,1
ffffffffc0204e6c:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc0204e70:	0379b423          	sd	s7,40(s3)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204e74:	26d7e663          	bltu	a5,a3,ffffffffc02050e0 <do_fork+0x32a>
ffffffffc0204e78:	000ab703          	ld	a4,0(s5)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204e7c:	0109b683          	ld	a3,16(s3)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204e80:	8f99                	sub	a5,a5,a4
ffffffffc0204e82:	0af9b423          	sd	a5,168(s3)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204e86:	6789                	lui	a5,0x2
ffffffffc0204e88:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7ce0>
ffffffffc0204e8c:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204e8e:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204e90:	0ad9b023          	sd	a3,160(s3)
    *(proc->tf) = *tf;
ffffffffc0204e94:	87b6                	mv	a5,a3
ffffffffc0204e96:	12040893          	addi	a7,s0,288
ffffffffc0204e9a:	00063803          	ld	a6,0(a2)
ffffffffc0204e9e:	6608                	ld	a0,8(a2)
ffffffffc0204ea0:	6a0c                	ld	a1,16(a2)
ffffffffc0204ea2:	6e18                	ld	a4,24(a2)
ffffffffc0204ea4:	0107b023          	sd	a6,0(a5)
ffffffffc0204ea8:	e788                	sd	a0,8(a5)
ffffffffc0204eaa:	eb8c                	sd	a1,16(a5)
ffffffffc0204eac:	ef98                	sd	a4,24(a5)
ffffffffc0204eae:	02060613          	addi	a2,a2,32
ffffffffc0204eb2:	02078793          	addi	a5,a5,32
ffffffffc0204eb6:	ff1612e3          	bne	a2,a7,ffffffffc0204e9a <do_fork+0xe4>
    proc->tf->gpr.a0 = 0;
ffffffffc0204eba:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204ebe:	12090163          	beqz	s2,ffffffffc0204fe0 <do_fork+0x22a>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204ec2:	000a2517          	auipc	a0,0xa2
ffffffffc0204ec6:	53e50513          	addi	a0,a0,1342 # ffffffffc02a7400 <last_pid.1>
ffffffffc0204eca:	411c                	lw	a5,0(a0)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204ecc:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204ed0:	00000717          	auipc	a4,0x0
ffffffffc0204ed4:	d7870713          	addi	a4,a4,-648 # ffffffffc0204c48 <forkret>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204ed8:	0017891b          	addiw	s2,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204edc:	02e9b823          	sd	a4,48(s3)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204ee0:	02d9bc23          	sd	a3,56(s3)
    if (++ last_pid >= MAX_PID) {
ffffffffc0204ee4:	01252023          	sw	s2,0(a0)
ffffffffc0204ee8:	6789                	lui	a5,0x2
ffffffffc0204eea:	08f95663          	bge	s2,a5,ffffffffc0204f76 <do_fork+0x1c0>
    if (last_pid >= next_safe) {
ffffffffc0204eee:	000a2897          	auipc	a7,0xa2
ffffffffc0204ef2:	51688893          	addi	a7,a7,1302 # ffffffffc02a7404 <next_safe.0>
ffffffffc0204ef6:	0008a783          	lw	a5,0(a7)
ffffffffc0204efa:	000ae417          	auipc	s0,0xae
ffffffffc0204efe:	9c640413          	addi	s0,s0,-1594 # ffffffffc02b28c0 <proc_list>
ffffffffc0204f02:	08f95163          	bge	s2,a5,ffffffffc0204f84 <do_fork+0x1ce>
    nr_process++;
ffffffffc0204f06:	409c                	lw	a5,0(s1)
    proc->pid = pid;
ffffffffc0204f08:	0129a223          	sw	s2,4(s3)
    list_add(hash_list + pid_hashfn(pid), &(proc->hash_link));
ffffffffc0204f0c:	45a9                	li	a1,10
    nr_process++;
ffffffffc0204f0e:	2785                	addiw	a5,a5,1
    list_add(hash_list + pid_hashfn(pid), &(proc->hash_link));
ffffffffc0204f10:	0009051b          	sext.w	a0,s2
    nr_process++;
ffffffffc0204f14:	c09c                	sw	a5,0(s1)
    list_add(hash_list + pid_hashfn(pid), &(proc->hash_link));
ffffffffc0204f16:	4e0010ef          	jal	ra,ffffffffc02063f6 <hash32>
ffffffffc0204f1a:	02051793          	slli	a5,a0,0x20
ffffffffc0204f1e:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204f22:	000aa797          	auipc	a5,0xaa
ffffffffc0204f26:	99e78793          	addi	a5,a5,-1634 # ffffffffc02ae8c0 <hash_list>
ffffffffc0204f2a:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204f2c:	6514                	ld	a3,8(a0)
ffffffffc0204f2e:	0d898793          	addi	a5,s3,216
ffffffffc0204f32:	6418                	ld	a4,8(s0)
    prev->next = next->prev = elm;
ffffffffc0204f34:	e29c                	sd	a5,0(a3)
ffffffffc0204f36:	e51c                	sd	a5,8(a0)
    elm->prev = prev;
ffffffffc0204f38:	0ca9bc23          	sd	a0,216(s3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204f3c:	0c898793          	addi	a5,s3,200
    elm->next = next;
ffffffffc0204f40:	0ed9b023          	sd	a3,224(s3)
    prev->next = next->prev = elm;
ffffffffc0204f44:	e31c                	sd	a5,0(a4)
    elm->next = next;
ffffffffc0204f46:	0ce9b823          	sd	a4,208(s3)
    elm->prev = prev;
ffffffffc0204f4a:	0c89b423          	sd	s0,200(s3)
    wakeup_proc(proc);
ffffffffc0204f4e:	854e                	mv	a0,s3
    prev->next = next->prev = elm;
ffffffffc0204f50:	e41c                	sd	a5,8(s0)
ffffffffc0204f52:	625000ef          	jal	ra,ffffffffc0205d76 <wakeup_proc>
}
ffffffffc0204f56:	70a6                	ld	ra,104(sp)
ffffffffc0204f58:	7406                	ld	s0,96(sp)
ffffffffc0204f5a:	64e6                	ld	s1,88(sp)
ffffffffc0204f5c:	69a6                	ld	s3,72(sp)
ffffffffc0204f5e:	6a06                	ld	s4,64(sp)
ffffffffc0204f60:	7ae2                	ld	s5,56(sp)
ffffffffc0204f62:	7b42                	ld	s6,48(sp)
ffffffffc0204f64:	7ba2                	ld	s7,40(sp)
ffffffffc0204f66:	7c02                	ld	s8,32(sp)
ffffffffc0204f68:	6ce2                	ld	s9,24(sp)
ffffffffc0204f6a:	6d42                	ld	s10,16(sp)
ffffffffc0204f6c:	6da2                	ld	s11,8(sp)
ffffffffc0204f6e:	854a                	mv	a0,s2
ffffffffc0204f70:	6946                	ld	s2,80(sp)
ffffffffc0204f72:	6165                	addi	sp,sp,112
ffffffffc0204f74:	8082                	ret
        last_pid = 1;
ffffffffc0204f76:	4785                	li	a5,1
ffffffffc0204f78:	c11c                	sw	a5,0(a0)
        goto inside;
ffffffffc0204f7a:	4905                	li	s2,1
ffffffffc0204f7c:	000a2897          	auipc	a7,0xa2
ffffffffc0204f80:	48888893          	addi	a7,a7,1160 # ffffffffc02a7404 <next_safe.0>
    return listelm->next;
ffffffffc0204f84:	000ae417          	auipc	s0,0xae
ffffffffc0204f88:	93c40413          	addi	s0,s0,-1732 # ffffffffc02b28c0 <proc_list>
ffffffffc0204f8c:	00843303          	ld	t1,8(s0)
        next_safe = MAX_PID;
ffffffffc0204f90:	6789                	lui	a5,0x2
ffffffffc0204f92:	00f8a023          	sw	a5,0(a7)
ffffffffc0204f96:	86ca                	mv	a3,s2
ffffffffc0204f98:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc0204f9a:	6e09                	lui	t3,0x2
ffffffffc0204f9c:	0e830163          	beq	t1,s0,ffffffffc020507e <do_fork+0x2c8>
ffffffffc0204fa0:	882e                	mv	a6,a1
ffffffffc0204fa2:	879a                	mv	a5,t1
ffffffffc0204fa4:	6609                	lui	a2,0x2
ffffffffc0204fa6:	a811                	j	ffffffffc0204fba <do_fork+0x204>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0204fa8:	00e6d663          	bge	a3,a4,ffffffffc0204fb4 <do_fork+0x1fe>
ffffffffc0204fac:	00c75463          	bge	a4,a2,ffffffffc0204fb4 <do_fork+0x1fe>
ffffffffc0204fb0:	863a                	mv	a2,a4
ffffffffc0204fb2:	4805                	li	a6,1
ffffffffc0204fb4:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204fb6:	00878d63          	beq	a5,s0,ffffffffc0204fd0 <do_fork+0x21a>
            if (proc->pid == last_pid) {
ffffffffc0204fba:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c84>
ffffffffc0204fbe:	fed715e3          	bne	a4,a3,ffffffffc0204fa8 <do_fork+0x1f2>
                if (++ last_pid >= next_safe) {
ffffffffc0204fc2:	2685                	addiw	a3,a3,1
ffffffffc0204fc4:	0ac6d863          	bge	a3,a2,ffffffffc0205074 <do_fork+0x2be>
ffffffffc0204fc8:	679c                	ld	a5,8(a5)
ffffffffc0204fca:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc0204fcc:	fe8797e3          	bne	a5,s0,ffffffffc0204fba <do_fork+0x204>
ffffffffc0204fd0:	c199                	beqz	a1,ffffffffc0204fd6 <do_fork+0x220>
ffffffffc0204fd2:	c114                	sw	a3,0(a0)
ffffffffc0204fd4:	8936                	mv	s2,a3
ffffffffc0204fd6:	f20808e3          	beqz	a6,ffffffffc0204f06 <do_fork+0x150>
ffffffffc0204fda:	00c8a023          	sw	a2,0(a7)
ffffffffc0204fde:	b725                	j	ffffffffc0204f06 <do_fork+0x150>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204fe0:	8936                	mv	s2,a3
ffffffffc0204fe2:	b5c5                	j	ffffffffc0204ec2 <do_fork+0x10c>
    if ((mm = mm_create()) == NULL) {
ffffffffc0204fe4:	98bfd0ef          	jal	ra,ffffffffc020296e <mm_create>
ffffffffc0204fe8:	8b2a                	mv	s6,a0
ffffffffc0204fea:	c151                	beqz	a0,ffffffffc020506e <do_fork+0x2b8>
    if ((page = alloc_page()) == NULL) {
ffffffffc0204fec:	4505                	li	a0,1
ffffffffc0204fee:	e49fb0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0204ff2:	c93d                	beqz	a0,ffffffffc0205068 <do_fork+0x2b2>
    return page - pages + nbase;
ffffffffc0204ff4:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc0204ff8:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0204ffc:	40d506b3          	sub	a3,a0,a3
ffffffffc0205000:	8699                	srai	a3,a3,0x6
ffffffffc0205002:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0205004:	0186fc33          	and	s8,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc0205008:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020500a:	0efc7863          	bgeu	s8,a5,ffffffffc02050fa <do_fork+0x344>
ffffffffc020500e:	000aba03          	ld	s4,0(s5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205012:	6605                	lui	a2,0x1
ffffffffc0205014:	000ae597          	auipc	a1,0xae
ffffffffc0205018:	8dc5b583          	ld	a1,-1828(a1) # ffffffffc02b28f0 <boot_pgdir>
ffffffffc020501c:	9a36                	add	s4,s4,a3
ffffffffc020501e:	8552                	mv	a0,s4
ffffffffc0205020:	7d1000ef          	jal	ra,ffffffffc0205ff0 <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205024:	038b8c13          	addi	s8,s7,56
    mm->pgdir = pgdir;
ffffffffc0205028:	014b3c23          	sd	s4,24(s6)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020502c:	4785                	li	a5,1
ffffffffc020502e:	40fc37af          	amoor.d	a5,a5,(s8)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0205032:	8b85                	andi	a5,a5,1
ffffffffc0205034:	4a05                	li	s4,1
ffffffffc0205036:	c799                	beqz	a5,ffffffffc0205044 <do_fork+0x28e>
        schedule();
ffffffffc0205038:	5bf000ef          	jal	ra,ffffffffc0205df6 <schedule>
ffffffffc020503c:	414c37af          	amoor.d	a5,s4,(s8)
    while (!try_lock(lock)) {
ffffffffc0205040:	8b85                	andi	a5,a5,1
ffffffffc0205042:	fbfd                	bnez	a5,ffffffffc0205038 <do_fork+0x282>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205044:	85de                	mv	a1,s7
ffffffffc0205046:	855a                	mv	a0,s6
ffffffffc0205048:	baffd0ef          	jal	ra,ffffffffc0202bf6 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020504c:	57f9                	li	a5,-2
ffffffffc020504e:	60fc37af          	amoand.d	a5,a5,(s8)
ffffffffc0205052:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205054:	cfdd                	beqz	a5,ffffffffc0205112 <do_fork+0x35c>
good_mm:
ffffffffc0205056:	8bda                	mv	s7,s6
    if (ret != 0) {
ffffffffc0205058:	e00503e3          	beqz	a0,ffffffffc0204e5e <do_fork+0xa8>
    exit_mmap(mm);
ffffffffc020505c:	855a                	mv	a0,s6
ffffffffc020505e:	c33fd0ef          	jal	ra,ffffffffc0202c90 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205062:	855a                	mv	a0,s6
ffffffffc0205064:	c71ff0ef          	jal	ra,ffffffffc0204cd4 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205068:	855a                	mv	a0,s6
ffffffffc020506a:	a8bfd0ef          	jal	ra,ffffffffc0202af4 <mm_destroy>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020506e:	0109b683          	ld	a3,16(s3)
ffffffffc0205072:	bd11                	j	ffffffffc0204e86 <do_fork+0xd0>
                    if (last_pid >= MAX_PID) {
ffffffffc0205074:	01c6c363          	blt	a3,t3,ffffffffc020507a <do_fork+0x2c4>
                        last_pid = 1;
ffffffffc0205078:	4685                	li	a3,1
                    goto repeat;
ffffffffc020507a:	4585                	li	a1,1
ffffffffc020507c:	b705                	j	ffffffffc0204f9c <do_fork+0x1e6>
ffffffffc020507e:	cda1                	beqz	a1,ffffffffc02050d6 <do_fork+0x320>
ffffffffc0205080:	c114                	sw	a3,0(a0)
    return last_pid;
ffffffffc0205082:	8936                	mv	s2,a3
ffffffffc0205084:	b549                	j	ffffffffc0204f06 <do_fork+0x150>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205086:	0109b683          	ld	a3,16(s3)
    return pa2page(PADDR(kva));
ffffffffc020508a:	c02007b7          	lui	a5,0xc0200
ffffffffc020508e:	0af6ea63          	bltu	a3,a5,ffffffffc0205142 <do_fork+0x38c>
ffffffffc0205092:	000ae797          	auipc	a5,0xae
ffffffffc0205096:	87e7b783          	ld	a5,-1922(a5) # ffffffffc02b2910 <va_pa_offset>
ffffffffc020509a:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc020509e:	83b1                	srli	a5,a5,0xc
ffffffffc02050a0:	000ae717          	auipc	a4,0xae
ffffffffc02050a4:	85873703          	ld	a4,-1960(a4) # ffffffffc02b28f8 <npage>
ffffffffc02050a8:	08e7f163          	bgeu	a5,a4,ffffffffc020512a <do_fork+0x374>
    return &pages[PPN(pa) - nbase];
ffffffffc02050ac:	00004717          	auipc	a4,0x4
ffffffffc02050b0:	9c473703          	ld	a4,-1596(a4) # ffffffffc0208a70 <nbase>
ffffffffc02050b4:	8f99                	sub	a5,a5,a4
ffffffffc02050b6:	079a                	slli	a5,a5,0x6
ffffffffc02050b8:	000ae517          	auipc	a0,0xae
ffffffffc02050bc:	84853503          	ld	a0,-1976(a0) # ffffffffc02b2900 <pages>
ffffffffc02050c0:	953e                	add	a0,a0,a5
ffffffffc02050c2:	4589                	li	a1,2
ffffffffc02050c4:	e05fb0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    kfree(proc);
ffffffffc02050c8:	854e                	mv	a0,s3
ffffffffc02050ca:	daefe0ef          	jal	ra,ffffffffc0203678 <kfree>
    ret = setup_kstack(proc);
ffffffffc02050ce:	5971                	li	s2,-4
    goto fork_out;
ffffffffc02050d0:	b559                	j	ffffffffc0204f56 <do_fork+0x1a0>
    int ret = -E_NO_FREE_PROC;
ffffffffc02050d2:	596d                	li	s2,-5
ffffffffc02050d4:	b549                	j	ffffffffc0204f56 <do_fork+0x1a0>
    return last_pid;
ffffffffc02050d6:	00052903          	lw	s2,0(a0)
ffffffffc02050da:	b535                	j	ffffffffc0204f06 <do_fork+0x150>
    ret = -E_NO_MEM;
ffffffffc02050dc:	5971                	li	s2,-4
    return ret;
ffffffffc02050de:	bda5                	j	ffffffffc0204f56 <do_fork+0x1a0>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02050e0:	86be                	mv	a3,a5
ffffffffc02050e2:	00002617          	auipc	a2,0x2
ffffffffc02050e6:	e0660613          	addi	a2,a2,-506 # ffffffffc0206ee8 <commands+0x830>
ffffffffc02050ea:	16100593          	li	a1,353
ffffffffc02050ee:	00003517          	auipc	a0,0x3
ffffffffc02050f2:	0ea50513          	addi	a0,a0,234 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc02050f6:	912fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc02050fa:	00002617          	auipc	a2,0x2
ffffffffc02050fe:	d1660613          	addi	a2,a2,-746 # ffffffffc0206e10 <commands+0x758>
ffffffffc0205102:	06900593          	li	a1,105
ffffffffc0205106:	00002517          	auipc	a0,0x2
ffffffffc020510a:	cd250513          	addi	a0,a0,-814 # ffffffffc0206dd8 <commands+0x720>
ffffffffc020510e:	8fafb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("Unlock failed.\n");
ffffffffc0205112:	00003617          	auipc	a2,0x3
ffffffffc0205116:	0de60613          	addi	a2,a2,222 # ffffffffc02081f0 <default_pmm_manager+0x108>
ffffffffc020511a:	03100593          	li	a1,49
ffffffffc020511e:	00003517          	auipc	a0,0x3
ffffffffc0205122:	0e250513          	addi	a0,a0,226 # ffffffffc0208200 <default_pmm_manager+0x118>
ffffffffc0205126:	8e2fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020512a:	00002617          	auipc	a2,0x2
ffffffffc020512e:	c8e60613          	addi	a2,a2,-882 # ffffffffc0206db8 <commands+0x700>
ffffffffc0205132:	06200593          	li	a1,98
ffffffffc0205136:	00002517          	auipc	a0,0x2
ffffffffc020513a:	ca250513          	addi	a0,a0,-862 # ffffffffc0206dd8 <commands+0x720>
ffffffffc020513e:	8cafb0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205142:	00002617          	auipc	a2,0x2
ffffffffc0205146:	da660613          	addi	a2,a2,-602 # ffffffffc0206ee8 <commands+0x830>
ffffffffc020514a:	06e00593          	li	a1,110
ffffffffc020514e:	00002517          	auipc	a0,0x2
ffffffffc0205152:	c8a50513          	addi	a0,a0,-886 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0205156:	8b2fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020515a <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020515a:	7129                	addi	sp,sp,-320
ffffffffc020515c:	fa22                	sd	s0,304(sp)
ffffffffc020515e:	f626                	sd	s1,296(sp)
ffffffffc0205160:	f24a                	sd	s2,288(sp)
ffffffffc0205162:	84ae                	mv	s1,a1
ffffffffc0205164:	892a                	mv	s2,a0
ffffffffc0205166:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205168:	4581                	li	a1,0
ffffffffc020516a:	12000613          	li	a2,288
ffffffffc020516e:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205170:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205172:	66d000ef          	jal	ra,ffffffffc0205fde <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205176:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205178:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020517a:	100027f3          	csrr	a5,sstatus
ffffffffc020517e:	edd7f793          	andi	a5,a5,-291
ffffffffc0205182:	1207e793          	ori	a5,a5,288
ffffffffc0205186:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205188:	860a                	mv	a2,sp
ffffffffc020518a:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020518e:	00000797          	auipc	a5,0x0
ffffffffc0205192:	9e678793          	addi	a5,a5,-1562 # ffffffffc0204b74 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205196:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205198:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020519a:	c1dff0ef          	jal	ra,ffffffffc0204db6 <do_fork>
}
ffffffffc020519e:	70f2                	ld	ra,312(sp)
ffffffffc02051a0:	7452                	ld	s0,304(sp)
ffffffffc02051a2:	74b2                	ld	s1,296(sp)
ffffffffc02051a4:	7912                	ld	s2,288(sp)
ffffffffc02051a6:	6131                	addi	sp,sp,320
ffffffffc02051a8:	8082                	ret

ffffffffc02051aa <do_exit>:
do_exit(int error_code) {
ffffffffc02051aa:	7179                	addi	sp,sp,-48
ffffffffc02051ac:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc02051ae:	000ad417          	auipc	s0,0xad
ffffffffc02051b2:	79a40413          	addi	s0,s0,1946 # ffffffffc02b2948 <current>
ffffffffc02051b6:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc02051b8:	f406                	sd	ra,40(sp)
ffffffffc02051ba:	ec26                	sd	s1,24(sp)
ffffffffc02051bc:	e84a                	sd	s2,16(sp)
ffffffffc02051be:	e44e                	sd	s3,8(sp)
ffffffffc02051c0:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc02051c2:	000ad717          	auipc	a4,0xad
ffffffffc02051c6:	78e73703          	ld	a4,1934(a4) # ffffffffc02b2950 <idleproc>
ffffffffc02051ca:	0ce78c63          	beq	a5,a4,ffffffffc02052a2 <do_exit+0xf8>
    if (current == initproc) {
ffffffffc02051ce:	000ad497          	auipc	s1,0xad
ffffffffc02051d2:	78a48493          	addi	s1,s1,1930 # ffffffffc02b2958 <initproc>
ffffffffc02051d6:	6098                	ld	a4,0(s1)
ffffffffc02051d8:	0ee78b63          	beq	a5,a4,ffffffffc02052ce <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc02051dc:	0287b983          	ld	s3,40(a5)
ffffffffc02051e0:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc02051e2:	02098663          	beqz	s3,ffffffffc020520e <do_exit+0x64>
ffffffffc02051e6:	000ad797          	auipc	a5,0xad
ffffffffc02051ea:	7027b783          	ld	a5,1794(a5) # ffffffffc02b28e8 <boot_cr3>
ffffffffc02051ee:	577d                	li	a4,-1
ffffffffc02051f0:	177e                	slli	a4,a4,0x3f
ffffffffc02051f2:	83b1                	srli	a5,a5,0xc
ffffffffc02051f4:	8fd9                	or	a5,a5,a4
ffffffffc02051f6:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02051fa:	0309a783          	lw	a5,48(s3)
ffffffffc02051fe:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205202:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205206:	cb55                	beqz	a4,ffffffffc02052ba <do_exit+0x110>
        current->mm = NULL;
ffffffffc0205208:	601c                	ld	a5,0(s0)
ffffffffc020520a:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020520e:	601c                	ld	a5,0(s0)
ffffffffc0205210:	470d                	li	a4,3
ffffffffc0205212:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205214:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205218:	100027f3          	csrr	a5,sstatus
ffffffffc020521c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020521e:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205220:	e3f9                	bnez	a5,ffffffffc02052e6 <do_exit+0x13c>
        proc = current->parent;
ffffffffc0205222:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205224:	800007b7          	lui	a5,0x80000
ffffffffc0205228:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020522a:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020522c:	0ec52703          	lw	a4,236(a0)
ffffffffc0205230:	0af70f63          	beq	a4,a5,ffffffffc02052ee <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc0205234:	6018                	ld	a4,0(s0)
ffffffffc0205236:	7b7c                	ld	a5,240(a4)
ffffffffc0205238:	c3a1                	beqz	a5,ffffffffc0205278 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020523a:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020523e:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205240:	0985                	addi	s3,s3,1
ffffffffc0205242:	a021                	j	ffffffffc020524a <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc0205244:	6018                	ld	a4,0(s0)
ffffffffc0205246:	7b7c                	ld	a5,240(a4)
ffffffffc0205248:	cb85                	beqz	a5,ffffffffc0205278 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc020524a:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fd0>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020524e:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0205250:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205252:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205254:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205258:	10e7b023          	sd	a4,256(a5)
ffffffffc020525c:	c311                	beqz	a4,ffffffffc0205260 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc020525e:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205260:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205262:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205264:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205266:	fd271fe3          	bne	a4,s2,ffffffffc0205244 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020526a:	0ec52783          	lw	a5,236(a0)
ffffffffc020526e:	fd379be3          	bne	a5,s3,ffffffffc0205244 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205272:	305000ef          	jal	ra,ffffffffc0205d76 <wakeup_proc>
ffffffffc0205276:	b7f9                	j	ffffffffc0205244 <do_exit+0x9a>
    if (flag) {
ffffffffc0205278:	020a1263          	bnez	s4,ffffffffc020529c <do_exit+0xf2>
    schedule();
ffffffffc020527c:	37b000ef          	jal	ra,ffffffffc0205df6 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205280:	601c                	ld	a5,0(s0)
ffffffffc0205282:	00003617          	auipc	a2,0x3
ffffffffc0205286:	fb660613          	addi	a2,a2,-74 # ffffffffc0208238 <default_pmm_manager+0x150>
ffffffffc020528a:	20000593          	li	a1,512
ffffffffc020528e:	43d4                	lw	a3,4(a5)
ffffffffc0205290:	00003517          	auipc	a0,0x3
ffffffffc0205294:	f4850513          	addi	a0,a0,-184 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc0205298:	f71fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_enable();
ffffffffc020529c:	b82fb0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc02052a0:	bff1                	j	ffffffffc020527c <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc02052a2:	00003617          	auipc	a2,0x3
ffffffffc02052a6:	f7660613          	addi	a2,a2,-138 # ffffffffc0208218 <default_pmm_manager+0x130>
ffffffffc02052aa:	1d400593          	li	a1,468
ffffffffc02052ae:	00003517          	auipc	a0,0x3
ffffffffc02052b2:	f2a50513          	addi	a0,a0,-214 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc02052b6:	f53fa0ef          	jal	ra,ffffffffc0200208 <__panic>
            exit_mmap(mm);
ffffffffc02052ba:	854e                	mv	a0,s3
ffffffffc02052bc:	9d5fd0ef          	jal	ra,ffffffffc0202c90 <exit_mmap>
            put_pgdir(mm);
ffffffffc02052c0:	854e                	mv	a0,s3
ffffffffc02052c2:	a13ff0ef          	jal	ra,ffffffffc0204cd4 <put_pgdir>
            mm_destroy(mm);
ffffffffc02052c6:	854e                	mv	a0,s3
ffffffffc02052c8:	82dfd0ef          	jal	ra,ffffffffc0202af4 <mm_destroy>
ffffffffc02052cc:	bf35                	j	ffffffffc0205208 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02052ce:	00003617          	auipc	a2,0x3
ffffffffc02052d2:	f5a60613          	addi	a2,a2,-166 # ffffffffc0208228 <default_pmm_manager+0x140>
ffffffffc02052d6:	1d700593          	li	a1,471
ffffffffc02052da:	00003517          	auipc	a0,0x3
ffffffffc02052de:	efe50513          	addi	a0,a0,-258 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc02052e2:	f27fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_disable();
ffffffffc02052e6:	b3efb0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc02052ea:	4a05                	li	s4,1
ffffffffc02052ec:	bf1d                	j	ffffffffc0205222 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc02052ee:	289000ef          	jal	ra,ffffffffc0205d76 <wakeup_proc>
ffffffffc02052f2:	b789                	j	ffffffffc0205234 <do_exit+0x8a>

ffffffffc02052f4 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc02052f4:	715d                	addi	sp,sp,-80
ffffffffc02052f6:	f84a                	sd	s2,48(sp)
ffffffffc02052f8:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc02052fa:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc02052fe:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc0205300:	fc26                	sd	s1,56(sp)
ffffffffc0205302:	f052                	sd	s4,32(sp)
ffffffffc0205304:	ec56                	sd	s5,24(sp)
ffffffffc0205306:	e85a                	sd	s6,16(sp)
ffffffffc0205308:	e45e                	sd	s7,8(sp)
ffffffffc020530a:	e486                	sd	ra,72(sp)
ffffffffc020530c:	e0a2                	sd	s0,64(sp)
ffffffffc020530e:	84aa                	mv	s1,a0
ffffffffc0205310:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0205312:	000adb97          	auipc	s7,0xad
ffffffffc0205316:	636b8b93          	addi	s7,s7,1590 # ffffffffc02b2948 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc020531a:	00050b1b          	sext.w	s6,a0
ffffffffc020531e:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0205322:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0205324:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc0205326:	ccbd                	beqz	s1,ffffffffc02053a4 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205328:	0359e863          	bltu	s3,s5,ffffffffc0205358 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020532c:	45a9                	li	a1,10
ffffffffc020532e:	855a                	mv	a0,s6
ffffffffc0205330:	0c6010ef          	jal	ra,ffffffffc02063f6 <hash32>
ffffffffc0205334:	02051793          	slli	a5,a0,0x20
ffffffffc0205338:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020533c:	000a9797          	auipc	a5,0xa9
ffffffffc0205340:	58478793          	addi	a5,a5,1412 # ffffffffc02ae8c0 <hash_list>
ffffffffc0205344:	953e                	add	a0,a0,a5
ffffffffc0205346:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205348:	a029                	j	ffffffffc0205352 <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc020534a:	f2c42783          	lw	a5,-212(s0)
ffffffffc020534e:	02978163          	beq	a5,s1,ffffffffc0205370 <do_wait.part.0+0x7c>
ffffffffc0205352:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc0205354:	fe851be3          	bne	a0,s0,ffffffffc020534a <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc0205358:	5579                	li	a0,-2
}
ffffffffc020535a:	60a6                	ld	ra,72(sp)
ffffffffc020535c:	6406                	ld	s0,64(sp)
ffffffffc020535e:	74e2                	ld	s1,56(sp)
ffffffffc0205360:	7942                	ld	s2,48(sp)
ffffffffc0205362:	79a2                	ld	s3,40(sp)
ffffffffc0205364:	7a02                	ld	s4,32(sp)
ffffffffc0205366:	6ae2                	ld	s5,24(sp)
ffffffffc0205368:	6b42                	ld	s6,16(sp)
ffffffffc020536a:	6ba2                	ld	s7,8(sp)
ffffffffc020536c:	6161                	addi	sp,sp,80
ffffffffc020536e:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc0205370:	000bb683          	ld	a3,0(s7)
ffffffffc0205374:	f4843783          	ld	a5,-184(s0)
ffffffffc0205378:	fed790e3          	bne	a5,a3,ffffffffc0205358 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020537c:	f2842703          	lw	a4,-216(s0)
ffffffffc0205380:	478d                	li	a5,3
ffffffffc0205382:	0ef70b63          	beq	a4,a5,ffffffffc0205478 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0205386:	4785                	li	a5,1
ffffffffc0205388:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc020538a:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc020538e:	269000ef          	jal	ra,ffffffffc0205df6 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205392:	000bb783          	ld	a5,0(s7)
ffffffffc0205396:	0b07a783          	lw	a5,176(a5)
ffffffffc020539a:	8b85                	andi	a5,a5,1
ffffffffc020539c:	d7c9                	beqz	a5,ffffffffc0205326 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc020539e:	555d                	li	a0,-9
ffffffffc02053a0:	e0bff0ef          	jal	ra,ffffffffc02051aa <do_exit>
        proc = current->cptr;
ffffffffc02053a4:	000bb683          	ld	a3,0(s7)
ffffffffc02053a8:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02053aa:	d45d                	beqz	s0,ffffffffc0205358 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02053ac:	470d                	li	a4,3
ffffffffc02053ae:	a021                	j	ffffffffc02053b6 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02053b0:	10043403          	ld	s0,256(s0)
ffffffffc02053b4:	d869                	beqz	s0,ffffffffc0205386 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02053b6:	401c                	lw	a5,0(s0)
ffffffffc02053b8:	fee79ce3          	bne	a5,a4,ffffffffc02053b0 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc02053bc:	000ad797          	auipc	a5,0xad
ffffffffc02053c0:	5947b783          	ld	a5,1428(a5) # ffffffffc02b2950 <idleproc>
ffffffffc02053c4:	0c878963          	beq	a5,s0,ffffffffc0205496 <do_wait.part.0+0x1a2>
ffffffffc02053c8:	000ad797          	auipc	a5,0xad
ffffffffc02053cc:	5907b783          	ld	a5,1424(a5) # ffffffffc02b2958 <initproc>
ffffffffc02053d0:	0cf40363          	beq	s0,a5,ffffffffc0205496 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc02053d4:	000a0663          	beqz	s4,ffffffffc02053e0 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc02053d8:	0e842783          	lw	a5,232(s0)
ffffffffc02053dc:	00fa2023          	sw	a5,0(s4)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053e0:	100027f3          	csrr	a5,sstatus
ffffffffc02053e4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02053e6:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053e8:	e7c1                	bnez	a5,ffffffffc0205470 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02053ea:	6c70                	ld	a2,216(s0)
ffffffffc02053ec:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02053ee:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc02053f2:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02053f4:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02053f6:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02053f8:	6470                	ld	a2,200(s0)
ffffffffc02053fa:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02053fc:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02053fe:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc0205400:	c319                	beqz	a4,ffffffffc0205406 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0205402:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc0205404:	7c7c                	ld	a5,248(s0)
ffffffffc0205406:	c3b5                	beqz	a5,ffffffffc020546a <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0205408:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc020540c:	000ad717          	auipc	a4,0xad
ffffffffc0205410:	55470713          	addi	a4,a4,1364 # ffffffffc02b2960 <nr_process>
ffffffffc0205414:	431c                	lw	a5,0(a4)
ffffffffc0205416:	37fd                	addiw	a5,a5,-1
ffffffffc0205418:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc020541a:	e5a9                	bnez	a1,ffffffffc0205464 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020541c:	6814                	ld	a3,16(s0)
ffffffffc020541e:	c02007b7          	lui	a5,0xc0200
ffffffffc0205422:	04f6ee63          	bltu	a3,a5,ffffffffc020547e <do_wait.part.0+0x18a>
ffffffffc0205426:	000ad797          	auipc	a5,0xad
ffffffffc020542a:	4ea7b783          	ld	a5,1258(a5) # ffffffffc02b2910 <va_pa_offset>
ffffffffc020542e:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205430:	82b1                	srli	a3,a3,0xc
ffffffffc0205432:	000ad797          	auipc	a5,0xad
ffffffffc0205436:	4c67b783          	ld	a5,1222(a5) # ffffffffc02b28f8 <npage>
ffffffffc020543a:	06f6fa63          	bgeu	a3,a5,ffffffffc02054ae <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc020543e:	00003517          	auipc	a0,0x3
ffffffffc0205442:	63253503          	ld	a0,1586(a0) # ffffffffc0208a70 <nbase>
ffffffffc0205446:	8e89                	sub	a3,a3,a0
ffffffffc0205448:	069a                	slli	a3,a3,0x6
ffffffffc020544a:	000ad517          	auipc	a0,0xad
ffffffffc020544e:	4b653503          	ld	a0,1206(a0) # ffffffffc02b2900 <pages>
ffffffffc0205452:	9536                	add	a0,a0,a3
ffffffffc0205454:	4589                	li	a1,2
ffffffffc0205456:	a73fb0ef          	jal	ra,ffffffffc0200ec8 <free_pages>
    kfree(proc);
ffffffffc020545a:	8522                	mv	a0,s0
ffffffffc020545c:	a1cfe0ef          	jal	ra,ffffffffc0203678 <kfree>
    return 0;
ffffffffc0205460:	4501                	li	a0,0
ffffffffc0205462:	bde5                	j	ffffffffc020535a <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0205464:	9bafb0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0205468:	bf55                	j	ffffffffc020541c <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc020546a:	701c                	ld	a5,32(s0)
ffffffffc020546c:	fbf8                	sd	a4,240(a5)
ffffffffc020546e:	bf79                	j	ffffffffc020540c <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0205470:	9b4fb0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc0205474:	4585                	li	a1,1
ffffffffc0205476:	bf95                	j	ffffffffc02053ea <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205478:	f2840413          	addi	s0,s0,-216
ffffffffc020547c:	b781                	j	ffffffffc02053bc <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc020547e:	00002617          	auipc	a2,0x2
ffffffffc0205482:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0206ee8 <commands+0x830>
ffffffffc0205486:	06e00593          	li	a1,110
ffffffffc020548a:	00002517          	auipc	a0,0x2
ffffffffc020548e:	94e50513          	addi	a0,a0,-1714 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0205492:	d77fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0205496:	00003617          	auipc	a2,0x3
ffffffffc020549a:	dc260613          	addi	a2,a2,-574 # ffffffffc0208258 <default_pmm_manager+0x170>
ffffffffc020549e:	2f700593          	li	a1,759
ffffffffc02054a2:	00003517          	auipc	a0,0x3
ffffffffc02054a6:	d3650513          	addi	a0,a0,-714 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc02054aa:	d5ffa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02054ae:	00002617          	auipc	a2,0x2
ffffffffc02054b2:	90a60613          	addi	a2,a2,-1782 # ffffffffc0206db8 <commands+0x700>
ffffffffc02054b6:	06200593          	li	a1,98
ffffffffc02054ba:	00002517          	auipc	a0,0x2
ffffffffc02054be:	91e50513          	addi	a0,a0,-1762 # ffffffffc0206dd8 <commands+0x720>
ffffffffc02054c2:	d47fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02054c6 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02054c6:	1141                	addi	sp,sp,-16
ffffffffc02054c8:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02054ca:	a3ffb0ef          	jal	ra,ffffffffc0200f08 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02054ce:	8f6fe0ef          	jal	ra,ffffffffc02035c4 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02054d2:	4601                	li	a2,0
ffffffffc02054d4:	4581                	li	a1,0
ffffffffc02054d6:	fffff517          	auipc	a0,0xfffff
ffffffffc02054da:	78050513          	addi	a0,a0,1920 # ffffffffc0204c56 <user_main>
ffffffffc02054de:	c7dff0ef          	jal	ra,ffffffffc020515a <kernel_thread>
    if (pid <= 0) {
ffffffffc02054e2:	00a04563          	bgtz	a0,ffffffffc02054ec <init_main+0x26>
ffffffffc02054e6:	a071                	j	ffffffffc0205572 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02054e8:	10f000ef          	jal	ra,ffffffffc0205df6 <schedule>
    if (code_store != NULL) {
ffffffffc02054ec:	4581                	li	a1,0
ffffffffc02054ee:	4501                	li	a0,0
ffffffffc02054f0:	e05ff0ef          	jal	ra,ffffffffc02052f4 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc02054f4:	d975                	beqz	a0,ffffffffc02054e8 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02054f6:	00003517          	auipc	a0,0x3
ffffffffc02054fa:	da250513          	addi	a0,a0,-606 # ffffffffc0208298 <default_pmm_manager+0x1b0>
ffffffffc02054fe:	bcffa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205502:	000ad797          	auipc	a5,0xad
ffffffffc0205506:	4567b783          	ld	a5,1110(a5) # ffffffffc02b2958 <initproc>
ffffffffc020550a:	7bf8                	ld	a4,240(a5)
ffffffffc020550c:	e339                	bnez	a4,ffffffffc0205552 <init_main+0x8c>
ffffffffc020550e:	7ff8                	ld	a4,248(a5)
ffffffffc0205510:	e329                	bnez	a4,ffffffffc0205552 <init_main+0x8c>
ffffffffc0205512:	1007b703          	ld	a4,256(a5)
ffffffffc0205516:	ef15                	bnez	a4,ffffffffc0205552 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0205518:	000ad697          	auipc	a3,0xad
ffffffffc020551c:	4486a683          	lw	a3,1096(a3) # ffffffffc02b2960 <nr_process>
ffffffffc0205520:	4709                	li	a4,2
ffffffffc0205522:	0ae69463          	bne	a3,a4,ffffffffc02055ca <init_main+0x104>
    return listelm->next;
ffffffffc0205526:	000ad697          	auipc	a3,0xad
ffffffffc020552a:	39a68693          	addi	a3,a3,922 # ffffffffc02b28c0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020552e:	6698                	ld	a4,8(a3)
ffffffffc0205530:	0c878793          	addi	a5,a5,200
ffffffffc0205534:	06f71b63          	bne	a4,a5,ffffffffc02055aa <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205538:	629c                	ld	a5,0(a3)
ffffffffc020553a:	04f71863          	bne	a4,a5,ffffffffc020558a <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc020553e:	00003517          	auipc	a0,0x3
ffffffffc0205542:	e4250513          	addi	a0,a0,-446 # ffffffffc0208380 <default_pmm_manager+0x298>
ffffffffc0205546:	b87fa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc020554a:	60a2                	ld	ra,8(sp)
ffffffffc020554c:	4501                	li	a0,0
ffffffffc020554e:	0141                	addi	sp,sp,16
ffffffffc0205550:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205552:	00003697          	auipc	a3,0x3
ffffffffc0205556:	d6e68693          	addi	a3,a3,-658 # ffffffffc02082c0 <default_pmm_manager+0x1d8>
ffffffffc020555a:	00001617          	auipc	a2,0x1
ffffffffc020555e:	56e60613          	addi	a2,a2,1390 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0205562:	35c00593          	li	a1,860
ffffffffc0205566:	00003517          	auipc	a0,0x3
ffffffffc020556a:	c7250513          	addi	a0,a0,-910 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc020556e:	c9bfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("create user_main failed.\n");
ffffffffc0205572:	00003617          	auipc	a2,0x3
ffffffffc0205576:	d0660613          	addi	a2,a2,-762 # ffffffffc0208278 <default_pmm_manager+0x190>
ffffffffc020557a:	35400593          	li	a1,852
ffffffffc020557e:	00003517          	auipc	a0,0x3
ffffffffc0205582:	c5a50513          	addi	a0,a0,-934 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc0205586:	c83fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020558a:	00003697          	auipc	a3,0x3
ffffffffc020558e:	dc668693          	addi	a3,a3,-570 # ffffffffc0208350 <default_pmm_manager+0x268>
ffffffffc0205592:	00001617          	auipc	a2,0x1
ffffffffc0205596:	53660613          	addi	a2,a2,1334 # ffffffffc0206ac8 <commands+0x410>
ffffffffc020559a:	35f00593          	li	a1,863
ffffffffc020559e:	00003517          	auipc	a0,0x3
ffffffffc02055a2:	c3a50513          	addi	a0,a0,-966 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc02055a6:	c63fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02055aa:	00003697          	auipc	a3,0x3
ffffffffc02055ae:	d7668693          	addi	a3,a3,-650 # ffffffffc0208320 <default_pmm_manager+0x238>
ffffffffc02055b2:	00001617          	auipc	a2,0x1
ffffffffc02055b6:	51660613          	addi	a2,a2,1302 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02055ba:	35e00593          	li	a1,862
ffffffffc02055be:	00003517          	auipc	a0,0x3
ffffffffc02055c2:	c1a50513          	addi	a0,a0,-998 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc02055c6:	c43fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_process == 2);
ffffffffc02055ca:	00003697          	auipc	a3,0x3
ffffffffc02055ce:	d4668693          	addi	a3,a3,-698 # ffffffffc0208310 <default_pmm_manager+0x228>
ffffffffc02055d2:	00001617          	auipc	a2,0x1
ffffffffc02055d6:	4f660613          	addi	a2,a2,1270 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02055da:	35d00593          	li	a1,861
ffffffffc02055de:	00003517          	auipc	a0,0x3
ffffffffc02055e2:	bfa50513          	addi	a0,a0,-1030 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc02055e6:	c23fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02055ea <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02055ea:	7171                	addi	sp,sp,-176
ffffffffc02055ec:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02055ee:	000add97          	auipc	s11,0xad
ffffffffc02055f2:	35ad8d93          	addi	s11,s11,858 # ffffffffc02b2948 <current>
ffffffffc02055f6:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02055fa:	e54e                	sd	s3,136(sp)
ffffffffc02055fc:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02055fe:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205602:	e94a                	sd	s2,144(sp)
ffffffffc0205604:	f4de                	sd	s7,104(sp)
ffffffffc0205606:	892a                	mv	s2,a0
ffffffffc0205608:	8bb2                	mv	s7,a2
ffffffffc020560a:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020560c:	862e                	mv	a2,a1
ffffffffc020560e:	4681                	li	a3,0
ffffffffc0205610:	85aa                	mv	a1,a0
ffffffffc0205612:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205614:	f506                	sd	ra,168(sp)
ffffffffc0205616:	f122                	sd	s0,160(sp)
ffffffffc0205618:	e152                	sd	s4,128(sp)
ffffffffc020561a:	fcd6                	sd	s5,120(sp)
ffffffffc020561c:	f8da                	sd	s6,112(sp)
ffffffffc020561e:	f0e2                	sd	s8,96(sp)
ffffffffc0205620:	ece6                	sd	s9,88(sp)
ffffffffc0205622:	e8ea                	sd	s10,80(sp)
ffffffffc0205624:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205626:	cddfd0ef          	jal	ra,ffffffffc0203302 <user_mem_check>
ffffffffc020562a:	40050863          	beqz	a0,ffffffffc0205a3a <do_execve+0x450>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020562e:	4641                	li	a2,16
ffffffffc0205630:	4581                	li	a1,0
ffffffffc0205632:	1808                	addi	a0,sp,48
ffffffffc0205634:	1ab000ef          	jal	ra,ffffffffc0205fde <memset>
    memcpy(local_name, name, len);
ffffffffc0205638:	47bd                	li	a5,15
ffffffffc020563a:	8626                	mv	a2,s1
ffffffffc020563c:	1e97e063          	bltu	a5,s1,ffffffffc020581c <do_execve+0x232>
ffffffffc0205640:	85ca                	mv	a1,s2
ffffffffc0205642:	1808                	addi	a0,sp,48
ffffffffc0205644:	1ad000ef          	jal	ra,ffffffffc0205ff0 <memcpy>
    if (mm != NULL) {
ffffffffc0205648:	1e098163          	beqz	s3,ffffffffc020582a <do_execve+0x240>
        cputs("mm != NULL");
ffffffffc020564c:	00002517          	auipc	a0,0x2
ffffffffc0205650:	06450513          	addi	a0,a0,100 # ffffffffc02076b0 <commands+0xff8>
ffffffffc0205654:	ab1fa0ef          	jal	ra,ffffffffc0200104 <cputs>
ffffffffc0205658:	000ad797          	auipc	a5,0xad
ffffffffc020565c:	2907b783          	ld	a5,656(a5) # ffffffffc02b28e8 <boot_cr3>
ffffffffc0205660:	577d                	li	a4,-1
ffffffffc0205662:	177e                	slli	a4,a4,0x3f
ffffffffc0205664:	83b1                	srli	a5,a5,0xc
ffffffffc0205666:	8fd9                	or	a5,a5,a4
ffffffffc0205668:	18079073          	csrw	satp,a5
ffffffffc020566c:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b90>
ffffffffc0205670:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205674:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205678:	2c070263          	beqz	a4,ffffffffc020593c <do_execve+0x352>
        current->mm = NULL;
ffffffffc020567c:	000db783          	ld	a5,0(s11)
ffffffffc0205680:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205684:	aeafd0ef          	jal	ra,ffffffffc020296e <mm_create>
ffffffffc0205688:	84aa                	mv	s1,a0
ffffffffc020568a:	1c050b63          	beqz	a0,ffffffffc0205860 <do_execve+0x276>
    if ((page = alloc_page()) == NULL) {
ffffffffc020568e:	4505                	li	a0,1
ffffffffc0205690:	fa6fb0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0205694:	3a050763          	beqz	a0,ffffffffc0205a42 <do_execve+0x458>
    return page - pages + nbase;
ffffffffc0205698:	000adc97          	auipc	s9,0xad
ffffffffc020569c:	268c8c93          	addi	s9,s9,616 # ffffffffc02b2900 <pages>
ffffffffc02056a0:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc02056a4:	000adc17          	auipc	s8,0xad
ffffffffc02056a8:	254c0c13          	addi	s8,s8,596 # ffffffffc02b28f8 <npage>
    return page - pages + nbase;
ffffffffc02056ac:	00003717          	auipc	a4,0x3
ffffffffc02056b0:	3c473703          	ld	a4,964(a4) # ffffffffc0208a70 <nbase>
ffffffffc02056b4:	40d506b3          	sub	a3,a0,a3
ffffffffc02056b8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02056ba:	5afd                	li	s5,-1
ffffffffc02056bc:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc02056c0:	96ba                	add	a3,a3,a4
ffffffffc02056c2:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc02056c4:	00cad713          	srli	a4,s5,0xc
ffffffffc02056c8:	ec3a                	sd	a4,24(sp)
ffffffffc02056ca:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02056cc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02056ce:	36f77e63          	bgeu	a4,a5,ffffffffc0205a4a <do_execve+0x460>
ffffffffc02056d2:	000adb17          	auipc	s6,0xad
ffffffffc02056d6:	23eb0b13          	addi	s6,s6,574 # ffffffffc02b2910 <va_pa_offset>
ffffffffc02056da:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02056de:	6605                	lui	a2,0x1
ffffffffc02056e0:	000ad597          	auipc	a1,0xad
ffffffffc02056e4:	2105b583          	ld	a1,528(a1) # ffffffffc02b28f0 <boot_pgdir>
ffffffffc02056e8:	9936                	add	s2,s2,a3
ffffffffc02056ea:	854a                	mv	a0,s2
ffffffffc02056ec:	105000ef          	jal	ra,ffffffffc0205ff0 <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02056f0:	7782                	ld	a5,32(sp)
ffffffffc02056f2:	4398                	lw	a4,0(a5)
ffffffffc02056f4:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc02056f8:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02056fc:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b944f>
ffffffffc0205700:	14f71663          	bne	a4,a5,ffffffffc020584c <do_execve+0x262>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205704:	7682                	ld	a3,32(sp)
ffffffffc0205706:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020570a:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020570e:	00371793          	slli	a5,a4,0x3
ffffffffc0205712:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205714:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205716:	078e                	slli	a5,a5,0x3
ffffffffc0205718:	97ce                	add	a5,a5,s3
ffffffffc020571a:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc020571c:	00f9fc63          	bgeu	s3,a5,ffffffffc0205734 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205720:	0009a783          	lw	a5,0(s3)
ffffffffc0205724:	4705                	li	a4,1
ffffffffc0205726:	12e78f63          	beq	a5,a4,ffffffffc0205864 <do_execve+0x27a>
    for (; ph < ph_end; ph ++) {
ffffffffc020572a:	77a2                	ld	a5,40(sp)
ffffffffc020572c:	03898993          	addi	s3,s3,56
ffffffffc0205730:	fef9e8e3          	bltu	s3,a5,ffffffffc0205720 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205734:	4701                	li	a4,0
ffffffffc0205736:	46ad                	li	a3,11
ffffffffc0205738:	00100637          	lui	a2,0x100
ffffffffc020573c:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205740:	8526                	mv	a0,s1
ffffffffc0205742:	c04fd0ef          	jal	ra,ffffffffc0202b46 <mm_map>
ffffffffc0205746:	8a2a                	mv	s4,a0
ffffffffc0205748:	1e051063          	bnez	a0,ffffffffc0205928 <do_execve+0x33e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc020574c:	6c88                	ld	a0,24(s1)
ffffffffc020574e:	467d                	li	a2,31
ffffffffc0205750:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205754:	d4ffc0ef          	jal	ra,ffffffffc02024a2 <pgdir_alloc_page>
ffffffffc0205758:	38050163          	beqz	a0,ffffffffc0205ada <do_execve+0x4f0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc020575c:	6c88                	ld	a0,24(s1)
ffffffffc020575e:	467d                	li	a2,31
ffffffffc0205760:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205764:	d3ffc0ef          	jal	ra,ffffffffc02024a2 <pgdir_alloc_page>
ffffffffc0205768:	34050963          	beqz	a0,ffffffffc0205aba <do_execve+0x4d0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc020576c:	6c88                	ld	a0,24(s1)
ffffffffc020576e:	467d                	li	a2,31
ffffffffc0205770:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205774:	d2ffc0ef          	jal	ra,ffffffffc02024a2 <pgdir_alloc_page>
ffffffffc0205778:	32050163          	beqz	a0,ffffffffc0205a9a <do_execve+0x4b0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc020577c:	6c88                	ld	a0,24(s1)
ffffffffc020577e:	467d                	li	a2,31
ffffffffc0205780:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205784:	d1ffc0ef          	jal	ra,ffffffffc02024a2 <pgdir_alloc_page>
ffffffffc0205788:	2e050963          	beqz	a0,ffffffffc0205a7a <do_execve+0x490>
    mm->mm_count += 1;
ffffffffc020578c:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc020578e:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205792:	6c94                	ld	a3,24(s1)
ffffffffc0205794:	2785                	addiw	a5,a5,1
ffffffffc0205796:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205798:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc020579a:	c02007b7          	lui	a5,0xc0200
ffffffffc020579e:	2cf6e263          	bltu	a3,a5,ffffffffc0205a62 <do_execve+0x478>
ffffffffc02057a2:	000b3783          	ld	a5,0(s6)
ffffffffc02057a6:	577d                	li	a4,-1
ffffffffc02057a8:	177e                	slli	a4,a4,0x3f
ffffffffc02057aa:	8e9d                	sub	a3,a3,a5
ffffffffc02057ac:	00c6d793          	srli	a5,a3,0xc
ffffffffc02057b0:	f654                	sd	a3,168(a2)
ffffffffc02057b2:	8fd9                	or	a5,a5,a4
ffffffffc02057b4:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02057b8:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02057ba:	4581                	li	a1,0
ffffffffc02057bc:	12000613          	li	a2,288
ffffffffc02057c0:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc02057c2:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02057c6:	019000ef          	jal	ra,ffffffffc0205fde <memset>
    tf->epc = elf->e_entry;//设置系统调用中断返回后执行的程序入口为elf头中设置的e_entry
ffffffffc02057ca:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02057cc:	000db483          	ld	s1,0(s11)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);//设置sstatus寄存器清零SSTATUS_SPP位和SSTATUS_SPIE位
ffffffffc02057d0:	edf97913          	andi	s2,s2,-289
    tf->epc = elf->e_entry;//设置系统调用中断返回后执行的程序入口为elf头中设置的e_entry
ffffffffc02057d4:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;//设置用户态的栈顶指针  
ffffffffc02057d6:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02057d8:	0b448493          	addi	s1,s1,180
    tf->gpr.sp = USTACKTOP;//设置用户态的栈顶指针  
ffffffffc02057dc:	07fe                	slli	a5,a5,0x1f
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02057de:	4641                	li	a2,16
ffffffffc02057e0:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;//设置用户态的栈顶指针  
ffffffffc02057e2:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;//设置系统调用中断返回后执行的程序入口为elf头中设置的e_entry
ffffffffc02057e4:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);//设置sstatus寄存器清零SSTATUS_SPP位和SSTATUS_SPIE位
ffffffffc02057e8:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02057ec:	8526                	mv	a0,s1
ffffffffc02057ee:	7f0000ef          	jal	ra,ffffffffc0205fde <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02057f2:	463d                	li	a2,15
ffffffffc02057f4:	180c                	addi	a1,sp,48
ffffffffc02057f6:	8526                	mv	a0,s1
ffffffffc02057f8:	7f8000ef          	jal	ra,ffffffffc0205ff0 <memcpy>
}
ffffffffc02057fc:	70aa                	ld	ra,168(sp)
ffffffffc02057fe:	740a                	ld	s0,160(sp)
ffffffffc0205800:	64ea                	ld	s1,152(sp)
ffffffffc0205802:	694a                	ld	s2,144(sp)
ffffffffc0205804:	69aa                	ld	s3,136(sp)
ffffffffc0205806:	7ae6                	ld	s5,120(sp)
ffffffffc0205808:	7b46                	ld	s6,112(sp)
ffffffffc020580a:	7ba6                	ld	s7,104(sp)
ffffffffc020580c:	7c06                	ld	s8,96(sp)
ffffffffc020580e:	6ce6                	ld	s9,88(sp)
ffffffffc0205810:	6d46                	ld	s10,80(sp)
ffffffffc0205812:	6da6                	ld	s11,72(sp)
ffffffffc0205814:	8552                	mv	a0,s4
ffffffffc0205816:	6a0a                	ld	s4,128(sp)
ffffffffc0205818:	614d                	addi	sp,sp,176
ffffffffc020581a:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc020581c:	463d                	li	a2,15
ffffffffc020581e:	85ca                	mv	a1,s2
ffffffffc0205820:	1808                	addi	a0,sp,48
ffffffffc0205822:	7ce000ef          	jal	ra,ffffffffc0205ff0 <memcpy>
    if (mm != NULL) {
ffffffffc0205826:	e20993e3          	bnez	s3,ffffffffc020564c <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc020582a:	000db783          	ld	a5,0(s11)
ffffffffc020582e:	779c                	ld	a5,40(a5)
ffffffffc0205830:	e4078ae3          	beqz	a5,ffffffffc0205684 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205834:	00003617          	auipc	a2,0x3
ffffffffc0205838:	b6c60613          	addi	a2,a2,-1172 # ffffffffc02083a0 <default_pmm_manager+0x2b8>
ffffffffc020583c:	20a00593          	li	a1,522
ffffffffc0205840:	00003517          	auipc	a0,0x3
ffffffffc0205844:	99850513          	addi	a0,a0,-1640 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc0205848:	9c1fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    put_pgdir(mm);
ffffffffc020584c:	8526                	mv	a0,s1
ffffffffc020584e:	c86ff0ef          	jal	ra,ffffffffc0204cd4 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205852:	8526                	mv	a0,s1
ffffffffc0205854:	aa0fd0ef          	jal	ra,ffffffffc0202af4 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205858:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc020585a:	8552                	mv	a0,s4
ffffffffc020585c:	94fff0ef          	jal	ra,ffffffffc02051aa <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205860:	5a71                	li	s4,-4
ffffffffc0205862:	bfe5                	j	ffffffffc020585a <do_execve+0x270>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205864:	0289b603          	ld	a2,40(s3)
ffffffffc0205868:	0209b783          	ld	a5,32(s3)
ffffffffc020586c:	1cf66d63          	bltu	a2,a5,ffffffffc0205a46 <do_execve+0x45c>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205870:	0049a783          	lw	a5,4(s3)
ffffffffc0205874:	0017f693          	andi	a3,a5,1
ffffffffc0205878:	c291                	beqz	a3,ffffffffc020587c <do_execve+0x292>
ffffffffc020587a:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc020587c:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205880:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205882:	e779                	bnez	a4,ffffffffc0205950 <do_execve+0x366>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205884:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205886:	c781                	beqz	a5,ffffffffc020588e <do_execve+0x2a4>
ffffffffc0205888:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc020588c:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc020588e:	0026f793          	andi	a5,a3,2
ffffffffc0205892:	e3f1                	bnez	a5,ffffffffc0205956 <do_execve+0x36c>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205894:	0046f793          	andi	a5,a3,4
ffffffffc0205898:	c399                	beqz	a5,ffffffffc020589e <do_execve+0x2b4>
ffffffffc020589a:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc020589e:	0109b583          	ld	a1,16(s3)
ffffffffc02058a2:	4701                	li	a4,0
ffffffffc02058a4:	8526                	mv	a0,s1
ffffffffc02058a6:	aa0fd0ef          	jal	ra,ffffffffc0202b46 <mm_map>
ffffffffc02058aa:	8a2a                	mv	s4,a0
ffffffffc02058ac:	ed35                	bnez	a0,ffffffffc0205928 <do_execve+0x33e>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02058ae:	0109bb83          	ld	s7,16(s3)
ffffffffc02058b2:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc02058b4:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc02058b8:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02058bc:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc02058c0:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc02058c2:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc02058c4:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc02058c6:	054be963          	bltu	s7,s4,ffffffffc0205918 <do_execve+0x32e>
ffffffffc02058ca:	aa95                	j	ffffffffc0205a3e <do_execve+0x454>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02058cc:	6785                	lui	a5,0x1
ffffffffc02058ce:	415b8533          	sub	a0,s7,s5
ffffffffc02058d2:	9abe                	add	s5,s5,a5
ffffffffc02058d4:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc02058d8:	015a7463          	bgeu	s4,s5,ffffffffc02058e0 <do_execve+0x2f6>
                size -= la - end;
ffffffffc02058dc:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc02058e0:	000cb683          	ld	a3,0(s9)
ffffffffc02058e4:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc02058e6:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc02058ea:	40d406b3          	sub	a3,s0,a3
ffffffffc02058ee:	8699                	srai	a3,a3,0x6
ffffffffc02058f0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02058f2:	67e2                	ld	a5,24(sp)
ffffffffc02058f4:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02058f8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02058fa:	14b87863          	bgeu	a6,a1,ffffffffc0205a4a <do_execve+0x460>
ffffffffc02058fe:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205902:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205904:	9bb2                	add	s7,s7,a2
ffffffffc0205906:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205908:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc020590a:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc020590c:	6e4000ef          	jal	ra,ffffffffc0205ff0 <memcpy>
            start += size, from += size;
ffffffffc0205910:	6622                	ld	a2,8(sp)
ffffffffc0205912:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205914:	054bf363          	bgeu	s7,s4,ffffffffc020595a <do_execve+0x370>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205918:	6c88                	ld	a0,24(s1)
ffffffffc020591a:	866a                	mv	a2,s10
ffffffffc020591c:	85d6                	mv	a1,s5
ffffffffc020591e:	b85fc0ef          	jal	ra,ffffffffc02024a2 <pgdir_alloc_page>
ffffffffc0205922:	842a                	mv	s0,a0
ffffffffc0205924:	f545                	bnez	a0,ffffffffc02058cc <do_execve+0x2e2>
        ret = -E_NO_MEM;
ffffffffc0205926:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205928:	8526                	mv	a0,s1
ffffffffc020592a:	b66fd0ef          	jal	ra,ffffffffc0202c90 <exit_mmap>
    put_pgdir(mm);
ffffffffc020592e:	8526                	mv	a0,s1
ffffffffc0205930:	ba4ff0ef          	jal	ra,ffffffffc0204cd4 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205934:	8526                	mv	a0,s1
ffffffffc0205936:	9befd0ef          	jal	ra,ffffffffc0202af4 <mm_destroy>
    return ret;
ffffffffc020593a:	b705                	j	ffffffffc020585a <do_execve+0x270>
            exit_mmap(mm);
ffffffffc020593c:	854e                	mv	a0,s3
ffffffffc020593e:	b52fd0ef          	jal	ra,ffffffffc0202c90 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205942:	854e                	mv	a0,s3
ffffffffc0205944:	b90ff0ef          	jal	ra,ffffffffc0204cd4 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205948:	854e                	mv	a0,s3
ffffffffc020594a:	9aafd0ef          	jal	ra,ffffffffc0202af4 <mm_destroy>
ffffffffc020594e:	b33d                	j	ffffffffc020567c <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205950:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205954:	fb95                	bnez	a5,ffffffffc0205888 <do_execve+0x29e>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205956:	4d5d                	li	s10,23
ffffffffc0205958:	bf35                	j	ffffffffc0205894 <do_execve+0x2aa>
        end = ph->p_va + ph->p_memsz;
ffffffffc020595a:	0109b683          	ld	a3,16(s3)
ffffffffc020595e:	0289b903          	ld	s2,40(s3)
ffffffffc0205962:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205964:	075bfd63          	bgeu	s7,s5,ffffffffc02059de <do_execve+0x3f4>
            if (start == end) {
ffffffffc0205968:	dd7901e3          	beq	s2,s7,ffffffffc020572a <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc020596c:	6785                	lui	a5,0x1
ffffffffc020596e:	00fb8533          	add	a0,s7,a5
ffffffffc0205972:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205976:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc020597a:	0b597d63          	bgeu	s2,s5,ffffffffc0205a34 <do_execve+0x44a>
    return page - pages + nbase;
ffffffffc020597e:	000cb683          	ld	a3,0(s9)
ffffffffc0205982:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205984:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205988:	40d406b3          	sub	a3,s0,a3
ffffffffc020598c:	8699                	srai	a3,a3,0x6
ffffffffc020598e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205990:	67e2                	ld	a5,24(sp)
ffffffffc0205992:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205996:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205998:	0ac5f963          	bgeu	a1,a2,ffffffffc0205a4a <do_execve+0x460>
ffffffffc020599c:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc02059a0:	8652                	mv	a2,s4
ffffffffc02059a2:	4581                	li	a1,0
ffffffffc02059a4:	96c2                	add	a3,a3,a6
ffffffffc02059a6:	9536                	add	a0,a0,a3
ffffffffc02059a8:	636000ef          	jal	ra,ffffffffc0205fde <memset>
            start += size;
ffffffffc02059ac:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc02059b0:	03597463          	bgeu	s2,s5,ffffffffc02059d8 <do_execve+0x3ee>
ffffffffc02059b4:	d6e90be3          	beq	s2,a4,ffffffffc020572a <do_execve+0x140>
ffffffffc02059b8:	00003697          	auipc	a3,0x3
ffffffffc02059bc:	a1068693          	addi	a3,a3,-1520 # ffffffffc02083c8 <default_pmm_manager+0x2e0>
ffffffffc02059c0:	00001617          	auipc	a2,0x1
ffffffffc02059c4:	10860613          	addi	a2,a2,264 # ffffffffc0206ac8 <commands+0x410>
ffffffffc02059c8:	25f00593          	li	a1,607
ffffffffc02059cc:	00003517          	auipc	a0,0x3
ffffffffc02059d0:	80c50513          	addi	a0,a0,-2036 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc02059d4:	835fa0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02059d8:	ff5710e3          	bne	a4,s5,ffffffffc02059b8 <do_execve+0x3ce>
ffffffffc02059dc:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc02059de:	d52bf6e3          	bgeu	s7,s2,ffffffffc020572a <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc02059e2:	6c88                	ld	a0,24(s1)
ffffffffc02059e4:	866a                	mv	a2,s10
ffffffffc02059e6:	85d6                	mv	a1,s5
ffffffffc02059e8:	abbfc0ef          	jal	ra,ffffffffc02024a2 <pgdir_alloc_page>
ffffffffc02059ec:	842a                	mv	s0,a0
ffffffffc02059ee:	dd05                	beqz	a0,ffffffffc0205926 <do_execve+0x33c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02059f0:	6785                	lui	a5,0x1
ffffffffc02059f2:	415b8533          	sub	a0,s7,s5
ffffffffc02059f6:	9abe                	add	s5,s5,a5
ffffffffc02059f8:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc02059fc:	01597463          	bgeu	s2,s5,ffffffffc0205a04 <do_execve+0x41a>
                size -= la - end;
ffffffffc0205a00:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205a04:	000cb683          	ld	a3,0(s9)
ffffffffc0205a08:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205a0a:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205a0e:	40d406b3          	sub	a3,s0,a3
ffffffffc0205a12:	8699                	srai	a3,a3,0x6
ffffffffc0205a14:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205a16:	67e2                	ld	a5,24(sp)
ffffffffc0205a18:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205a1c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a1e:	02b87663          	bgeu	a6,a1,ffffffffc0205a4a <do_execve+0x460>
ffffffffc0205a22:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205a26:	4581                	li	a1,0
            start += size;
ffffffffc0205a28:	9bb2                	add	s7,s7,a2
ffffffffc0205a2a:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205a2c:	9536                	add	a0,a0,a3
ffffffffc0205a2e:	5b0000ef          	jal	ra,ffffffffc0205fde <memset>
ffffffffc0205a32:	b775                	j	ffffffffc02059de <do_execve+0x3f4>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205a34:	417a8a33          	sub	s4,s5,s7
ffffffffc0205a38:	b799                	j	ffffffffc020597e <do_execve+0x394>
        return -E_INVAL;
ffffffffc0205a3a:	5a75                	li	s4,-3
ffffffffc0205a3c:	b3c1                	j	ffffffffc02057fc <do_execve+0x212>
        while (start < end) {
ffffffffc0205a3e:	86de                	mv	a3,s7
ffffffffc0205a40:	bf39                	j	ffffffffc020595e <do_execve+0x374>
    int ret = -E_NO_MEM;
ffffffffc0205a42:	5a71                	li	s4,-4
ffffffffc0205a44:	bdc5                	j	ffffffffc0205934 <do_execve+0x34a>
            ret = -E_INVAL_ELF;
ffffffffc0205a46:	5a61                	li	s4,-8
ffffffffc0205a48:	b5c5                	j	ffffffffc0205928 <do_execve+0x33e>
ffffffffc0205a4a:	00001617          	auipc	a2,0x1
ffffffffc0205a4e:	3c660613          	addi	a2,a2,966 # ffffffffc0206e10 <commands+0x758>
ffffffffc0205a52:	06900593          	li	a1,105
ffffffffc0205a56:	00001517          	auipc	a0,0x1
ffffffffc0205a5a:	38250513          	addi	a0,a0,898 # ffffffffc0206dd8 <commands+0x720>
ffffffffc0205a5e:	faafa0ef          	jal	ra,ffffffffc0200208 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a62:	00001617          	auipc	a2,0x1
ffffffffc0205a66:	48660613          	addi	a2,a2,1158 # ffffffffc0206ee8 <commands+0x830>
ffffffffc0205a6a:	27a00593          	li	a1,634
ffffffffc0205a6e:	00002517          	auipc	a0,0x2
ffffffffc0205a72:	76a50513          	addi	a0,a0,1898 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc0205a76:	f92fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a7a:	00003697          	auipc	a3,0x3
ffffffffc0205a7e:	a6668693          	addi	a3,a3,-1434 # ffffffffc02084e0 <default_pmm_manager+0x3f8>
ffffffffc0205a82:	00001617          	auipc	a2,0x1
ffffffffc0205a86:	04660613          	addi	a2,a2,70 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0205a8a:	27500593          	li	a1,629
ffffffffc0205a8e:	00002517          	auipc	a0,0x2
ffffffffc0205a92:	74a50513          	addi	a0,a0,1866 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc0205a96:	f72fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a9a:	00003697          	auipc	a3,0x3
ffffffffc0205a9e:	9fe68693          	addi	a3,a3,-1538 # ffffffffc0208498 <default_pmm_manager+0x3b0>
ffffffffc0205aa2:	00001617          	auipc	a2,0x1
ffffffffc0205aa6:	02660613          	addi	a2,a2,38 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0205aaa:	27400593          	li	a1,628
ffffffffc0205aae:	00002517          	auipc	a0,0x2
ffffffffc0205ab2:	72a50513          	addi	a0,a0,1834 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc0205ab6:	f52fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205aba:	00003697          	auipc	a3,0x3
ffffffffc0205abe:	99668693          	addi	a3,a3,-1642 # ffffffffc0208450 <default_pmm_manager+0x368>
ffffffffc0205ac2:	00001617          	auipc	a2,0x1
ffffffffc0205ac6:	00660613          	addi	a2,a2,6 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0205aca:	27300593          	li	a1,627
ffffffffc0205ace:	00002517          	auipc	a0,0x2
ffffffffc0205ad2:	70a50513          	addi	a0,a0,1802 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc0205ad6:	f32fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205ada:	00003697          	auipc	a3,0x3
ffffffffc0205ade:	92e68693          	addi	a3,a3,-1746 # ffffffffc0208408 <default_pmm_manager+0x320>
ffffffffc0205ae2:	00001617          	auipc	a2,0x1
ffffffffc0205ae6:	fe660613          	addi	a2,a2,-26 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0205aea:	27200593          	li	a1,626
ffffffffc0205aee:	00002517          	auipc	a0,0x2
ffffffffc0205af2:	6ea50513          	addi	a0,a0,1770 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc0205af6:	f12fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205afa <do_yield>:
    current->need_resched = 1;
ffffffffc0205afa:	000ad797          	auipc	a5,0xad
ffffffffc0205afe:	e4e7b783          	ld	a5,-434(a5) # ffffffffc02b2948 <current>
ffffffffc0205b02:	4705                	li	a4,1
ffffffffc0205b04:	ef98                	sd	a4,24(a5)
}
ffffffffc0205b06:	4501                	li	a0,0
ffffffffc0205b08:	8082                	ret

ffffffffc0205b0a <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205b0a:	1101                	addi	sp,sp,-32
ffffffffc0205b0c:	e822                	sd	s0,16(sp)
ffffffffc0205b0e:	e426                	sd	s1,8(sp)
ffffffffc0205b10:	ec06                	sd	ra,24(sp)
ffffffffc0205b12:	842e                	mv	s0,a1
ffffffffc0205b14:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205b16:	c999                	beqz	a1,ffffffffc0205b2c <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205b18:	000ad797          	auipc	a5,0xad
ffffffffc0205b1c:	e307b783          	ld	a5,-464(a5) # ffffffffc02b2948 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205b20:	7788                	ld	a0,40(a5)
ffffffffc0205b22:	4685                	li	a3,1
ffffffffc0205b24:	4611                	li	a2,4
ffffffffc0205b26:	fdcfd0ef          	jal	ra,ffffffffc0203302 <user_mem_check>
ffffffffc0205b2a:	c909                	beqz	a0,ffffffffc0205b3c <do_wait+0x32>
ffffffffc0205b2c:	85a2                	mv	a1,s0
}
ffffffffc0205b2e:	6442                	ld	s0,16(sp)
ffffffffc0205b30:	60e2                	ld	ra,24(sp)
ffffffffc0205b32:	8526                	mv	a0,s1
ffffffffc0205b34:	64a2                	ld	s1,8(sp)
ffffffffc0205b36:	6105                	addi	sp,sp,32
ffffffffc0205b38:	fbcff06f          	j	ffffffffc02052f4 <do_wait.part.0>
ffffffffc0205b3c:	60e2                	ld	ra,24(sp)
ffffffffc0205b3e:	6442                	ld	s0,16(sp)
ffffffffc0205b40:	64a2                	ld	s1,8(sp)
ffffffffc0205b42:	5575                	li	a0,-3
ffffffffc0205b44:	6105                	addi	sp,sp,32
ffffffffc0205b46:	8082                	ret

ffffffffc0205b48 <do_kill>:
do_kill(int pid) {
ffffffffc0205b48:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205b4a:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205b4c:	e406                	sd	ra,8(sp)
ffffffffc0205b4e:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205b50:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205b54:	17f9                	addi	a5,a5,-2
ffffffffc0205b56:	02e7e963          	bltu	a5,a4,ffffffffc0205b88 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205b5a:	842a                	mv	s0,a0
ffffffffc0205b5c:	45a9                	li	a1,10
ffffffffc0205b5e:	2501                	sext.w	a0,a0
ffffffffc0205b60:	097000ef          	jal	ra,ffffffffc02063f6 <hash32>
ffffffffc0205b64:	02051793          	slli	a5,a0,0x20
ffffffffc0205b68:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205b6c:	000a9797          	auipc	a5,0xa9
ffffffffc0205b70:	d5478793          	addi	a5,a5,-684 # ffffffffc02ae8c0 <hash_list>
ffffffffc0205b74:	953e                	add	a0,a0,a5
ffffffffc0205b76:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205b78:	a029                	j	ffffffffc0205b82 <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205b7a:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205b7e:	00870b63          	beq	a4,s0,ffffffffc0205b94 <do_kill+0x4c>
ffffffffc0205b82:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205b84:	fef51be3          	bne	a0,a5,ffffffffc0205b7a <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205b88:	5475                	li	s0,-3
}
ffffffffc0205b8a:	60a2                	ld	ra,8(sp)
ffffffffc0205b8c:	8522                	mv	a0,s0
ffffffffc0205b8e:	6402                	ld	s0,0(sp)
ffffffffc0205b90:	0141                	addi	sp,sp,16
ffffffffc0205b92:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205b94:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205b98:	00177693          	andi	a3,a4,1
ffffffffc0205b9c:	e295                	bnez	a3,ffffffffc0205bc0 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205b9e:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205ba0:	00176713          	ori	a4,a4,1
ffffffffc0205ba4:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205ba8:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205baa:	fe06d0e3          	bgez	a3,ffffffffc0205b8a <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205bae:	f2878513          	addi	a0,a5,-216
ffffffffc0205bb2:	1c4000ef          	jal	ra,ffffffffc0205d76 <wakeup_proc>
}
ffffffffc0205bb6:	60a2                	ld	ra,8(sp)
ffffffffc0205bb8:	8522                	mv	a0,s0
ffffffffc0205bba:	6402                	ld	s0,0(sp)
ffffffffc0205bbc:	0141                	addi	sp,sp,16
ffffffffc0205bbe:	8082                	ret
        return -E_KILLED;
ffffffffc0205bc0:	545d                	li	s0,-9
ffffffffc0205bc2:	b7e1                	j	ffffffffc0205b8a <do_kill+0x42>

ffffffffc0205bc4 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205bc4:	1101                	addi	sp,sp,-32
ffffffffc0205bc6:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205bc8:	000ad797          	auipc	a5,0xad
ffffffffc0205bcc:	cf878793          	addi	a5,a5,-776 # ffffffffc02b28c0 <proc_list>
ffffffffc0205bd0:	ec06                	sd	ra,24(sp)
ffffffffc0205bd2:	e822                	sd	s0,16(sp)
ffffffffc0205bd4:	e04a                	sd	s2,0(sp)
ffffffffc0205bd6:	000a9497          	auipc	s1,0xa9
ffffffffc0205bda:	cea48493          	addi	s1,s1,-790 # ffffffffc02ae8c0 <hash_list>
ffffffffc0205bde:	e79c                	sd	a5,8(a5)
ffffffffc0205be0:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205be2:	000ad717          	auipc	a4,0xad
ffffffffc0205be6:	cde70713          	addi	a4,a4,-802 # ffffffffc02b28c0 <proc_list>
ffffffffc0205bea:	87a6                	mv	a5,s1
ffffffffc0205bec:	e79c                	sd	a5,8(a5)
ffffffffc0205bee:	e39c                	sd	a5,0(a5)
ffffffffc0205bf0:	07c1                	addi	a5,a5,16
ffffffffc0205bf2:	fef71de3          	bne	a4,a5,ffffffffc0205bec <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205bf6:	ff1fe0ef          	jal	ra,ffffffffc0204be6 <alloc_proc>
ffffffffc0205bfa:	000ad917          	auipc	s2,0xad
ffffffffc0205bfe:	d5690913          	addi	s2,s2,-682 # ffffffffc02b2950 <idleproc>
ffffffffc0205c02:	00a93023          	sd	a0,0(s2)
ffffffffc0205c06:	0e050f63          	beqz	a0,ffffffffc0205d04 <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205c0a:	4789                	li	a5,2
ffffffffc0205c0c:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205c0e:	00003797          	auipc	a5,0x3
ffffffffc0205c12:	3f278793          	addi	a5,a5,1010 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205c16:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205c1a:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205c1c:	4785                	li	a5,1
ffffffffc0205c1e:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205c20:	4641                	li	a2,16
ffffffffc0205c22:	4581                	li	a1,0
ffffffffc0205c24:	8522                	mv	a0,s0
ffffffffc0205c26:	3b8000ef          	jal	ra,ffffffffc0205fde <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205c2a:	463d                	li	a2,15
ffffffffc0205c2c:	00003597          	auipc	a1,0x3
ffffffffc0205c30:	91458593          	addi	a1,a1,-1772 # ffffffffc0208540 <default_pmm_manager+0x458>
ffffffffc0205c34:	8522                	mv	a0,s0
ffffffffc0205c36:	3ba000ef          	jal	ra,ffffffffc0205ff0 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205c3a:	000ad717          	auipc	a4,0xad
ffffffffc0205c3e:	d2670713          	addi	a4,a4,-730 # ffffffffc02b2960 <nr_process>
ffffffffc0205c42:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205c44:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205c48:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205c4a:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205c4c:	4581                	li	a1,0
ffffffffc0205c4e:	00000517          	auipc	a0,0x0
ffffffffc0205c52:	87850513          	addi	a0,a0,-1928 # ffffffffc02054c6 <init_main>
    nr_process ++;
ffffffffc0205c56:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205c58:	000ad797          	auipc	a5,0xad
ffffffffc0205c5c:	ced7b823          	sd	a3,-784(a5) # ffffffffc02b2948 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205c60:	cfaff0ef          	jal	ra,ffffffffc020515a <kernel_thread>
ffffffffc0205c64:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205c66:	08a05363          	blez	a0,ffffffffc0205cec <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205c6a:	6789                	lui	a5,0x2
ffffffffc0205c6c:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205c70:	17f9                	addi	a5,a5,-2
ffffffffc0205c72:	2501                	sext.w	a0,a0
ffffffffc0205c74:	02e7e363          	bltu	a5,a4,ffffffffc0205c9a <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205c78:	45a9                	li	a1,10
ffffffffc0205c7a:	77c000ef          	jal	ra,ffffffffc02063f6 <hash32>
ffffffffc0205c7e:	02051793          	slli	a5,a0,0x20
ffffffffc0205c82:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205c86:	96a6                	add	a3,a3,s1
ffffffffc0205c88:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205c8a:	a029                	j	ffffffffc0205c94 <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205c8c:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c94>
ffffffffc0205c90:	04870b63          	beq	a4,s0,ffffffffc0205ce6 <proc_init+0x122>
    return listelm->next;
ffffffffc0205c94:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205c96:	fef69be3          	bne	a3,a5,ffffffffc0205c8c <proc_init+0xc8>
    return NULL;
ffffffffc0205c9a:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205c9c:	0b478493          	addi	s1,a5,180
ffffffffc0205ca0:	4641                	li	a2,16
ffffffffc0205ca2:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205ca4:	000ad417          	auipc	s0,0xad
ffffffffc0205ca8:	cb440413          	addi	s0,s0,-844 # ffffffffc02b2958 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205cac:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205cae:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205cb0:	32e000ef          	jal	ra,ffffffffc0205fde <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205cb4:	463d                	li	a2,15
ffffffffc0205cb6:	00003597          	auipc	a1,0x3
ffffffffc0205cba:	8b258593          	addi	a1,a1,-1870 # ffffffffc0208568 <default_pmm_manager+0x480>
ffffffffc0205cbe:	8526                	mv	a0,s1
ffffffffc0205cc0:	330000ef          	jal	ra,ffffffffc0205ff0 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205cc4:	00093783          	ld	a5,0(s2)
ffffffffc0205cc8:	cbb5                	beqz	a5,ffffffffc0205d3c <proc_init+0x178>
ffffffffc0205cca:	43dc                	lw	a5,4(a5)
ffffffffc0205ccc:	eba5                	bnez	a5,ffffffffc0205d3c <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205cce:	601c                	ld	a5,0(s0)
ffffffffc0205cd0:	c7b1                	beqz	a5,ffffffffc0205d1c <proc_init+0x158>
ffffffffc0205cd2:	43d8                	lw	a4,4(a5)
ffffffffc0205cd4:	4785                	li	a5,1
ffffffffc0205cd6:	04f71363          	bne	a4,a5,ffffffffc0205d1c <proc_init+0x158>
}
ffffffffc0205cda:	60e2                	ld	ra,24(sp)
ffffffffc0205cdc:	6442                	ld	s0,16(sp)
ffffffffc0205cde:	64a2                	ld	s1,8(sp)
ffffffffc0205ce0:	6902                	ld	s2,0(sp)
ffffffffc0205ce2:	6105                	addi	sp,sp,32
ffffffffc0205ce4:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205ce6:	f2878793          	addi	a5,a5,-216
ffffffffc0205cea:	bf4d                	j	ffffffffc0205c9c <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205cec:	00003617          	auipc	a2,0x3
ffffffffc0205cf0:	85c60613          	addi	a2,a2,-1956 # ffffffffc0208548 <default_pmm_manager+0x460>
ffffffffc0205cf4:	37f00593          	li	a1,895
ffffffffc0205cf8:	00002517          	auipc	a0,0x2
ffffffffc0205cfc:	4e050513          	addi	a0,a0,1248 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc0205d00:	d08fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205d04:	00003617          	auipc	a2,0x3
ffffffffc0205d08:	82460613          	addi	a2,a2,-2012 # ffffffffc0208528 <default_pmm_manager+0x440>
ffffffffc0205d0c:	37100593          	li	a1,881
ffffffffc0205d10:	00002517          	auipc	a0,0x2
ffffffffc0205d14:	4c850513          	addi	a0,a0,1224 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc0205d18:	cf0fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205d1c:	00003697          	auipc	a3,0x3
ffffffffc0205d20:	87c68693          	addi	a3,a3,-1924 # ffffffffc0208598 <default_pmm_manager+0x4b0>
ffffffffc0205d24:	00001617          	auipc	a2,0x1
ffffffffc0205d28:	da460613          	addi	a2,a2,-604 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0205d2c:	38600593          	li	a1,902
ffffffffc0205d30:	00002517          	auipc	a0,0x2
ffffffffc0205d34:	4a850513          	addi	a0,a0,1192 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc0205d38:	cd0fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205d3c:	00003697          	auipc	a3,0x3
ffffffffc0205d40:	83468693          	addi	a3,a3,-1996 # ffffffffc0208570 <default_pmm_manager+0x488>
ffffffffc0205d44:	00001617          	auipc	a2,0x1
ffffffffc0205d48:	d8460613          	addi	a2,a2,-636 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0205d4c:	38500593          	li	a1,901
ffffffffc0205d50:	00002517          	auipc	a0,0x2
ffffffffc0205d54:	48850513          	addi	a0,a0,1160 # ffffffffc02081d8 <default_pmm_manager+0xf0>
ffffffffc0205d58:	cb0fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205d5c <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205d5c:	1141                	addi	sp,sp,-16
ffffffffc0205d5e:	e022                	sd	s0,0(sp)
ffffffffc0205d60:	e406                	sd	ra,8(sp)
ffffffffc0205d62:	000ad417          	auipc	s0,0xad
ffffffffc0205d66:	be640413          	addi	s0,s0,-1050 # ffffffffc02b2948 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205d6a:	6018                	ld	a4,0(s0)
ffffffffc0205d6c:	6f1c                	ld	a5,24(a4)
ffffffffc0205d6e:	dffd                	beqz	a5,ffffffffc0205d6c <cpu_idle+0x10>
            schedule();
ffffffffc0205d70:	086000ef          	jal	ra,ffffffffc0205df6 <schedule>
ffffffffc0205d74:	bfdd                	j	ffffffffc0205d6a <cpu_idle+0xe>

ffffffffc0205d76 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205d76:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205d78:	1101                	addi	sp,sp,-32
ffffffffc0205d7a:	ec06                	sd	ra,24(sp)
ffffffffc0205d7c:	e822                	sd	s0,16(sp)
ffffffffc0205d7e:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205d80:	478d                	li	a5,3
ffffffffc0205d82:	04f70b63          	beq	a4,a5,ffffffffc0205dd8 <wakeup_proc+0x62>
ffffffffc0205d86:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205d88:	100027f3          	csrr	a5,sstatus
ffffffffc0205d8c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205d8e:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205d90:	ef9d                	bnez	a5,ffffffffc0205dce <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205d92:	4789                	li	a5,2
ffffffffc0205d94:	02f70163          	beq	a4,a5,ffffffffc0205db6 <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc0205d98:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205d9a:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc0205d9e:	e491                	bnez	s1,ffffffffc0205daa <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205da0:	60e2                	ld	ra,24(sp)
ffffffffc0205da2:	6442                	ld	s0,16(sp)
ffffffffc0205da4:	64a2                	ld	s1,8(sp)
ffffffffc0205da6:	6105                	addi	sp,sp,32
ffffffffc0205da8:	8082                	ret
ffffffffc0205daa:	6442                	ld	s0,16(sp)
ffffffffc0205dac:	60e2                	ld	ra,24(sp)
ffffffffc0205dae:	64a2                	ld	s1,8(sp)
ffffffffc0205db0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205db2:	86dfa06f          	j	ffffffffc020061e <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205db6:	00003617          	auipc	a2,0x3
ffffffffc0205dba:	84260613          	addi	a2,a2,-1982 # ffffffffc02085f8 <default_pmm_manager+0x510>
ffffffffc0205dbe:	45c9                	li	a1,18
ffffffffc0205dc0:	00003517          	auipc	a0,0x3
ffffffffc0205dc4:	82050513          	addi	a0,a0,-2016 # ffffffffc02085e0 <default_pmm_manager+0x4f8>
ffffffffc0205dc8:	ca8fa0ef          	jal	ra,ffffffffc0200270 <__warn>
ffffffffc0205dcc:	bfc9                	j	ffffffffc0205d9e <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205dce:	857fa0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205dd2:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205dd4:	4485                	li	s1,1
ffffffffc0205dd6:	bf75                	j	ffffffffc0205d92 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205dd8:	00002697          	auipc	a3,0x2
ffffffffc0205ddc:	7e868693          	addi	a3,a3,2024 # ffffffffc02085c0 <default_pmm_manager+0x4d8>
ffffffffc0205de0:	00001617          	auipc	a2,0x1
ffffffffc0205de4:	ce860613          	addi	a2,a2,-792 # ffffffffc0206ac8 <commands+0x410>
ffffffffc0205de8:	45a5                	li	a1,9
ffffffffc0205dea:	00002517          	auipc	a0,0x2
ffffffffc0205dee:	7f650513          	addi	a0,a0,2038 # ffffffffc02085e0 <default_pmm_manager+0x4f8>
ffffffffc0205df2:	c16fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205df6 <schedule>:

void
schedule(void) {
ffffffffc0205df6:	1141                	addi	sp,sp,-16
ffffffffc0205df8:	e406                	sd	ra,8(sp)
ffffffffc0205dfa:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205dfc:	100027f3          	csrr	a5,sstatus
ffffffffc0205e00:	8b89                	andi	a5,a5,2
ffffffffc0205e02:	4401                	li	s0,0
ffffffffc0205e04:	efbd                	bnez	a5,ffffffffc0205e82 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205e06:	000ad897          	auipc	a7,0xad
ffffffffc0205e0a:	b428b883          	ld	a7,-1214(a7) # ffffffffc02b2948 <current>
ffffffffc0205e0e:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205e12:	000ad517          	auipc	a0,0xad
ffffffffc0205e16:	b3e53503          	ld	a0,-1218(a0) # ffffffffc02b2950 <idleproc>
ffffffffc0205e1a:	04a88e63          	beq	a7,a0,ffffffffc0205e76 <schedule+0x80>
ffffffffc0205e1e:	0c888693          	addi	a3,a7,200
ffffffffc0205e22:	000ad617          	auipc	a2,0xad
ffffffffc0205e26:	a9e60613          	addi	a2,a2,-1378 # ffffffffc02b28c0 <proc_list>
        le = last;
ffffffffc0205e2a:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205e2c:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205e2e:	4809                	li	a6,2
ffffffffc0205e30:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205e32:	00c78863          	beq	a5,a2,ffffffffc0205e42 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205e36:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205e3a:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205e3e:	03070163          	beq	a4,a6,ffffffffc0205e60 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205e42:	fef697e3          	bne	a3,a5,ffffffffc0205e30 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205e46:	ed89                	bnez	a1,ffffffffc0205e60 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205e48:	451c                	lw	a5,8(a0)
ffffffffc0205e4a:	2785                	addiw	a5,a5,1
ffffffffc0205e4c:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205e4e:	00a88463          	beq	a7,a0,ffffffffc0205e56 <schedule+0x60>
            proc_run(next);
ffffffffc0205e52:	ef9fe0ef          	jal	ra,ffffffffc0204d4a <proc_run>
    if (flag) {
ffffffffc0205e56:	e819                	bnez	s0,ffffffffc0205e6c <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205e58:	60a2                	ld	ra,8(sp)
ffffffffc0205e5a:	6402                	ld	s0,0(sp)
ffffffffc0205e5c:	0141                	addi	sp,sp,16
ffffffffc0205e5e:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205e60:	4198                	lw	a4,0(a1)
ffffffffc0205e62:	4789                	li	a5,2
ffffffffc0205e64:	fef712e3          	bne	a4,a5,ffffffffc0205e48 <schedule+0x52>
ffffffffc0205e68:	852e                	mv	a0,a1
ffffffffc0205e6a:	bff9                	j	ffffffffc0205e48 <schedule+0x52>
}
ffffffffc0205e6c:	6402                	ld	s0,0(sp)
ffffffffc0205e6e:	60a2                	ld	ra,8(sp)
ffffffffc0205e70:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205e72:	facfa06f          	j	ffffffffc020061e <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205e76:	000ad617          	auipc	a2,0xad
ffffffffc0205e7a:	a4a60613          	addi	a2,a2,-1462 # ffffffffc02b28c0 <proc_list>
ffffffffc0205e7e:	86b2                	mv	a3,a2
ffffffffc0205e80:	b76d                	j	ffffffffc0205e2a <schedule+0x34>
        intr_disable();
ffffffffc0205e82:	fa2fa0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc0205e86:	4405                	li	s0,1
ffffffffc0205e88:	bfbd                	j	ffffffffc0205e06 <schedule+0x10>

ffffffffc0205e8a <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205e8a:	000ad797          	auipc	a5,0xad
ffffffffc0205e8e:	abe7b783          	ld	a5,-1346(a5) # ffffffffc02b2948 <current>
}
ffffffffc0205e92:	43c8                	lw	a0,4(a5)
ffffffffc0205e94:	8082                	ret

ffffffffc0205e96 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205e96:	4501                	li	a0,0
ffffffffc0205e98:	8082                	ret

ffffffffc0205e9a <sys_putc>:
    cputchar(c);
ffffffffc0205e9a:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205e9c:	1141                	addi	sp,sp,-16
ffffffffc0205e9e:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205ea0:	a62fa0ef          	jal	ra,ffffffffc0200102 <cputchar>
}
ffffffffc0205ea4:	60a2                	ld	ra,8(sp)
ffffffffc0205ea6:	4501                	li	a0,0
ffffffffc0205ea8:	0141                	addi	sp,sp,16
ffffffffc0205eaa:	8082                	ret

ffffffffc0205eac <sys_kill>:
    return do_kill(pid);
ffffffffc0205eac:	4108                	lw	a0,0(a0)
ffffffffc0205eae:	c9bff06f          	j	ffffffffc0205b48 <do_kill>

ffffffffc0205eb2 <sys_yield>:
    return do_yield();
ffffffffc0205eb2:	c49ff06f          	j	ffffffffc0205afa <do_yield>

ffffffffc0205eb6 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205eb6:	6d14                	ld	a3,24(a0)
ffffffffc0205eb8:	6910                	ld	a2,16(a0)
ffffffffc0205eba:	650c                	ld	a1,8(a0)
ffffffffc0205ebc:	6108                	ld	a0,0(a0)
ffffffffc0205ebe:	f2cff06f          	j	ffffffffc02055ea <do_execve>

ffffffffc0205ec2 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205ec2:	650c                	ld	a1,8(a0)
ffffffffc0205ec4:	4108                	lw	a0,0(a0)
ffffffffc0205ec6:	c45ff06f          	j	ffffffffc0205b0a <do_wait>

ffffffffc0205eca <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205eca:	000ad797          	auipc	a5,0xad
ffffffffc0205ece:	a7e7b783          	ld	a5,-1410(a5) # ffffffffc02b2948 <current>
ffffffffc0205ed2:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205ed4:	4501                	li	a0,0
ffffffffc0205ed6:	6a0c                	ld	a1,16(a2)
ffffffffc0205ed8:	edffe06f          	j	ffffffffc0204db6 <do_fork>

ffffffffc0205edc <sys_exit>:
    return do_exit(error_code);
ffffffffc0205edc:	4108                	lw	a0,0(a0)
ffffffffc0205ede:	accff06f          	j	ffffffffc02051aa <do_exit>

ffffffffc0205ee2 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205ee2:	715d                	addi	sp,sp,-80
ffffffffc0205ee4:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205ee6:	000ad497          	auipc	s1,0xad
ffffffffc0205eea:	a6248493          	addi	s1,s1,-1438 # ffffffffc02b2948 <current>
ffffffffc0205eee:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0205ef0:	e0a2                	sd	s0,64(sp)
ffffffffc0205ef2:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205ef4:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0205ef6:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205ef8:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0205efa:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205efe:	0327ee63          	bltu	a5,s2,ffffffffc0205f3a <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0205f02:	00391713          	slli	a4,s2,0x3
ffffffffc0205f06:	00002797          	auipc	a5,0x2
ffffffffc0205f0a:	75a78793          	addi	a5,a5,1882 # ffffffffc0208660 <syscalls>
ffffffffc0205f0e:	97ba                	add	a5,a5,a4
ffffffffc0205f10:	639c                	ld	a5,0(a5)
ffffffffc0205f12:	c785                	beqz	a5,ffffffffc0205f3a <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0205f14:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0205f16:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0205f18:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0205f1a:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0205f1c:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0205f1e:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0205f20:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0205f22:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0205f24:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0205f26:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205f28:	0028                	addi	a0,sp,8
ffffffffc0205f2a:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205f2c:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205f2e:	e828                	sd	a0,80(s0)
}
ffffffffc0205f30:	6406                	ld	s0,64(sp)
ffffffffc0205f32:	74e2                	ld	s1,56(sp)
ffffffffc0205f34:	7942                	ld	s2,48(sp)
ffffffffc0205f36:	6161                	addi	sp,sp,80
ffffffffc0205f38:	8082                	ret
    print_trapframe(tf);
ffffffffc0205f3a:	8522                	mv	a0,s0
ffffffffc0205f3c:	8d7fa0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205f40:	609c                	ld	a5,0(s1)
ffffffffc0205f42:	86ca                	mv	a3,s2
ffffffffc0205f44:	00002617          	auipc	a2,0x2
ffffffffc0205f48:	6d460613          	addi	a2,a2,1748 # ffffffffc0208618 <default_pmm_manager+0x530>
ffffffffc0205f4c:	43d8                	lw	a4,4(a5)
ffffffffc0205f4e:	06200593          	li	a1,98
ffffffffc0205f52:	0b478793          	addi	a5,a5,180
ffffffffc0205f56:	00002517          	auipc	a0,0x2
ffffffffc0205f5a:	6f250513          	addi	a0,a0,1778 # ffffffffc0208648 <default_pmm_manager+0x560>
ffffffffc0205f5e:	aaafa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205f62 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205f62:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0205f66:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0205f68:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0205f6a:	cb81                	beqz	a5,ffffffffc0205f7a <strlen+0x18>
        cnt ++;
ffffffffc0205f6c:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0205f6e:	00a707b3          	add	a5,a4,a0
ffffffffc0205f72:	0007c783          	lbu	a5,0(a5)
ffffffffc0205f76:	fbfd                	bnez	a5,ffffffffc0205f6c <strlen+0xa>
ffffffffc0205f78:	8082                	ret
    }
    return cnt;
}
ffffffffc0205f7a:	8082                	ret

ffffffffc0205f7c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0205f7c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205f7e:	e589                	bnez	a1,ffffffffc0205f88 <strnlen+0xc>
ffffffffc0205f80:	a811                	j	ffffffffc0205f94 <strnlen+0x18>
        cnt ++;
ffffffffc0205f82:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205f84:	00f58863          	beq	a1,a5,ffffffffc0205f94 <strnlen+0x18>
ffffffffc0205f88:	00f50733          	add	a4,a0,a5
ffffffffc0205f8c:	00074703          	lbu	a4,0(a4)
ffffffffc0205f90:	fb6d                	bnez	a4,ffffffffc0205f82 <strnlen+0x6>
ffffffffc0205f92:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205f94:	852e                	mv	a0,a1
ffffffffc0205f96:	8082                	ret

ffffffffc0205f98 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205f98:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205f9a:	0005c703          	lbu	a4,0(a1)
ffffffffc0205f9e:	0785                	addi	a5,a5,1
ffffffffc0205fa0:	0585                	addi	a1,a1,1
ffffffffc0205fa2:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205fa6:	fb75                	bnez	a4,ffffffffc0205f9a <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205fa8:	8082                	ret

ffffffffc0205faa <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205faa:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205fae:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205fb2:	cb89                	beqz	a5,ffffffffc0205fc4 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0205fb4:	0505                	addi	a0,a0,1
ffffffffc0205fb6:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205fb8:	fee789e3          	beq	a5,a4,ffffffffc0205faa <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205fbc:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0205fc0:	9d19                	subw	a0,a0,a4
ffffffffc0205fc2:	8082                	ret
ffffffffc0205fc4:	4501                	li	a0,0
ffffffffc0205fc6:	bfed                	j	ffffffffc0205fc0 <strcmp+0x16>

ffffffffc0205fc8 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0205fc8:	00054783          	lbu	a5,0(a0)
ffffffffc0205fcc:	c799                	beqz	a5,ffffffffc0205fda <strchr+0x12>
        if (*s == c) {
ffffffffc0205fce:	00f58763          	beq	a1,a5,ffffffffc0205fdc <strchr+0x14>
    while (*s != '\0') {
ffffffffc0205fd2:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0205fd6:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0205fd8:	fbfd                	bnez	a5,ffffffffc0205fce <strchr+0x6>
    }
    return NULL;
ffffffffc0205fda:	4501                	li	a0,0
}
ffffffffc0205fdc:	8082                	ret

ffffffffc0205fde <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0205fde:	ca01                	beqz	a2,ffffffffc0205fee <memset+0x10>
ffffffffc0205fe0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0205fe2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0205fe4:	0785                	addi	a5,a5,1
ffffffffc0205fe6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0205fea:	fec79de3          	bne	a5,a2,ffffffffc0205fe4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205fee:	8082                	ret

ffffffffc0205ff0 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205ff0:	ca19                	beqz	a2,ffffffffc0206006 <memcpy+0x16>
ffffffffc0205ff2:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0205ff4:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0205ff6:	0005c703          	lbu	a4,0(a1)
ffffffffc0205ffa:	0585                	addi	a1,a1,1
ffffffffc0205ffc:	0785                	addi	a5,a5,1
ffffffffc0205ffe:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206002:	fec59ae3          	bne	a1,a2,ffffffffc0205ff6 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206006:	8082                	ret

ffffffffc0206008 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206008:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020600c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020600e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206012:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206014:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206018:	f022                	sd	s0,32(sp)
ffffffffc020601a:	ec26                	sd	s1,24(sp)
ffffffffc020601c:	e84a                	sd	s2,16(sp)
ffffffffc020601e:	f406                	sd	ra,40(sp)
ffffffffc0206020:	e44e                	sd	s3,8(sp)
ffffffffc0206022:	84aa                	mv	s1,a0
ffffffffc0206024:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206026:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020602a:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020602c:	03067e63          	bgeu	a2,a6,ffffffffc0206068 <printnum+0x60>
ffffffffc0206030:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0206032:	00805763          	blez	s0,ffffffffc0206040 <printnum+0x38>
ffffffffc0206036:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206038:	85ca                	mv	a1,s2
ffffffffc020603a:	854e                	mv	a0,s3
ffffffffc020603c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020603e:	fc65                	bnez	s0,ffffffffc0206036 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206040:	1a02                	slli	s4,s4,0x20
ffffffffc0206042:	00002797          	auipc	a5,0x2
ffffffffc0206046:	71e78793          	addi	a5,a5,1822 # ffffffffc0208760 <syscalls+0x100>
ffffffffc020604a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020604e:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0206050:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206052:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206056:	70a2                	ld	ra,40(sp)
ffffffffc0206058:	69a2                	ld	s3,8(sp)
ffffffffc020605a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020605c:	85ca                	mv	a1,s2
ffffffffc020605e:	87a6                	mv	a5,s1
}
ffffffffc0206060:	6942                	ld	s2,16(sp)
ffffffffc0206062:	64e2                	ld	s1,24(sp)
ffffffffc0206064:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206066:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206068:	03065633          	divu	a2,a2,a6
ffffffffc020606c:	8722                	mv	a4,s0
ffffffffc020606e:	f9bff0ef          	jal	ra,ffffffffc0206008 <printnum>
ffffffffc0206072:	b7f9                	j	ffffffffc0206040 <printnum+0x38>

ffffffffc0206074 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206074:	7119                	addi	sp,sp,-128
ffffffffc0206076:	f4a6                	sd	s1,104(sp)
ffffffffc0206078:	f0ca                	sd	s2,96(sp)
ffffffffc020607a:	ecce                	sd	s3,88(sp)
ffffffffc020607c:	e8d2                	sd	s4,80(sp)
ffffffffc020607e:	e4d6                	sd	s5,72(sp)
ffffffffc0206080:	e0da                	sd	s6,64(sp)
ffffffffc0206082:	fc5e                	sd	s7,56(sp)
ffffffffc0206084:	f06a                	sd	s10,32(sp)
ffffffffc0206086:	fc86                	sd	ra,120(sp)
ffffffffc0206088:	f8a2                	sd	s0,112(sp)
ffffffffc020608a:	f862                	sd	s8,48(sp)
ffffffffc020608c:	f466                	sd	s9,40(sp)
ffffffffc020608e:	ec6e                	sd	s11,24(sp)
ffffffffc0206090:	892a                	mv	s2,a0
ffffffffc0206092:	84ae                	mv	s1,a1
ffffffffc0206094:	8d32                	mv	s10,a2
ffffffffc0206096:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206098:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020609c:	5b7d                	li	s6,-1
ffffffffc020609e:	00002a97          	auipc	s5,0x2
ffffffffc02060a2:	6eea8a93          	addi	s5,s5,1774 # ffffffffc020878c <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02060a6:	00003b97          	auipc	s7,0x3
ffffffffc02060aa:	902b8b93          	addi	s7,s7,-1790 # ffffffffc02089a8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02060ae:	000d4503          	lbu	a0,0(s10)
ffffffffc02060b2:	001d0413          	addi	s0,s10,1
ffffffffc02060b6:	01350a63          	beq	a0,s3,ffffffffc02060ca <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02060ba:	c121                	beqz	a0,ffffffffc02060fa <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02060bc:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02060be:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02060c0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02060c2:	fff44503          	lbu	a0,-1(s0)
ffffffffc02060c6:	ff351ae3          	bne	a0,s3,ffffffffc02060ba <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02060ca:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02060ce:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02060d2:	4c81                	li	s9,0
ffffffffc02060d4:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02060d6:	5c7d                	li	s8,-1
ffffffffc02060d8:	5dfd                	li	s11,-1
ffffffffc02060da:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02060de:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02060e0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02060e4:	0ff5f593          	zext.b	a1,a1
ffffffffc02060e8:	00140d13          	addi	s10,s0,1
ffffffffc02060ec:	04b56263          	bltu	a0,a1,ffffffffc0206130 <vprintfmt+0xbc>
ffffffffc02060f0:	058a                	slli	a1,a1,0x2
ffffffffc02060f2:	95d6                	add	a1,a1,s5
ffffffffc02060f4:	4194                	lw	a3,0(a1)
ffffffffc02060f6:	96d6                	add	a3,a3,s5
ffffffffc02060f8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02060fa:	70e6                	ld	ra,120(sp)
ffffffffc02060fc:	7446                	ld	s0,112(sp)
ffffffffc02060fe:	74a6                	ld	s1,104(sp)
ffffffffc0206100:	7906                	ld	s2,96(sp)
ffffffffc0206102:	69e6                	ld	s3,88(sp)
ffffffffc0206104:	6a46                	ld	s4,80(sp)
ffffffffc0206106:	6aa6                	ld	s5,72(sp)
ffffffffc0206108:	6b06                	ld	s6,64(sp)
ffffffffc020610a:	7be2                	ld	s7,56(sp)
ffffffffc020610c:	7c42                	ld	s8,48(sp)
ffffffffc020610e:	7ca2                	ld	s9,40(sp)
ffffffffc0206110:	7d02                	ld	s10,32(sp)
ffffffffc0206112:	6de2                	ld	s11,24(sp)
ffffffffc0206114:	6109                	addi	sp,sp,128
ffffffffc0206116:	8082                	ret
            padc = '0';
ffffffffc0206118:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020611a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020611e:	846a                	mv	s0,s10
ffffffffc0206120:	00140d13          	addi	s10,s0,1
ffffffffc0206124:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0206128:	0ff5f593          	zext.b	a1,a1
ffffffffc020612c:	fcb572e3          	bgeu	a0,a1,ffffffffc02060f0 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0206130:	85a6                	mv	a1,s1
ffffffffc0206132:	02500513          	li	a0,37
ffffffffc0206136:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206138:	fff44783          	lbu	a5,-1(s0)
ffffffffc020613c:	8d22                	mv	s10,s0
ffffffffc020613e:	f73788e3          	beq	a5,s3,ffffffffc02060ae <vprintfmt+0x3a>
ffffffffc0206142:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0206146:	1d7d                	addi	s10,s10,-1
ffffffffc0206148:	ff379de3          	bne	a5,s3,ffffffffc0206142 <vprintfmt+0xce>
ffffffffc020614c:	b78d                	j	ffffffffc02060ae <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020614e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0206152:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206156:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206158:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020615c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206160:	02d86463          	bltu	a6,a3,ffffffffc0206188 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0206164:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206168:	002c169b          	slliw	a3,s8,0x2
ffffffffc020616c:	0186873b          	addw	a4,a3,s8
ffffffffc0206170:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206174:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0206176:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020617a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020617c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0206180:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206184:	fed870e3          	bgeu	a6,a3,ffffffffc0206164 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0206188:	f40ddce3          	bgez	s11,ffffffffc02060e0 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020618c:	8de2                	mv	s11,s8
ffffffffc020618e:	5c7d                	li	s8,-1
ffffffffc0206190:	bf81                	j	ffffffffc02060e0 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0206192:	fffdc693          	not	a3,s11
ffffffffc0206196:	96fd                	srai	a3,a3,0x3f
ffffffffc0206198:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020619c:	00144603          	lbu	a2,1(s0)
ffffffffc02061a0:	2d81                	sext.w	s11,s11
ffffffffc02061a2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02061a4:	bf35                	j	ffffffffc02060e0 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02061a6:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061aa:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02061ae:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061b0:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02061b2:	bfd9                	j	ffffffffc0206188 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02061b4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02061b6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02061ba:	01174463          	blt	a4,a7,ffffffffc02061c2 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02061be:	1a088e63          	beqz	a7,ffffffffc020637a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02061c2:	000a3603          	ld	a2,0(s4)
ffffffffc02061c6:	46c1                	li	a3,16
ffffffffc02061c8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02061ca:	2781                	sext.w	a5,a5
ffffffffc02061cc:	876e                	mv	a4,s11
ffffffffc02061ce:	85a6                	mv	a1,s1
ffffffffc02061d0:	854a                	mv	a0,s2
ffffffffc02061d2:	e37ff0ef          	jal	ra,ffffffffc0206008 <printnum>
            break;
ffffffffc02061d6:	bde1                	j	ffffffffc02060ae <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02061d8:	000a2503          	lw	a0,0(s4)
ffffffffc02061dc:	85a6                	mv	a1,s1
ffffffffc02061de:	0a21                	addi	s4,s4,8
ffffffffc02061e0:	9902                	jalr	s2
            break;
ffffffffc02061e2:	b5f1                	j	ffffffffc02060ae <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02061e4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02061e6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02061ea:	01174463          	blt	a4,a7,ffffffffc02061f2 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02061ee:	18088163          	beqz	a7,ffffffffc0206370 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02061f2:	000a3603          	ld	a2,0(s4)
ffffffffc02061f6:	46a9                	li	a3,10
ffffffffc02061f8:	8a2e                	mv	s4,a1
ffffffffc02061fa:	bfc1                	j	ffffffffc02061ca <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061fc:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206200:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206202:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206204:	bdf1                	j	ffffffffc02060e0 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0206206:	85a6                	mv	a1,s1
ffffffffc0206208:	02500513          	li	a0,37
ffffffffc020620c:	9902                	jalr	s2
            break;
ffffffffc020620e:	b545                	j	ffffffffc02060ae <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206210:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0206214:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206216:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206218:	b5e1                	j	ffffffffc02060e0 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020621a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020621c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206220:	01174463          	blt	a4,a7,ffffffffc0206228 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0206224:	14088163          	beqz	a7,ffffffffc0206366 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0206228:	000a3603          	ld	a2,0(s4)
ffffffffc020622c:	46a1                	li	a3,8
ffffffffc020622e:	8a2e                	mv	s4,a1
ffffffffc0206230:	bf69                	j	ffffffffc02061ca <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0206232:	03000513          	li	a0,48
ffffffffc0206236:	85a6                	mv	a1,s1
ffffffffc0206238:	e03e                	sd	a5,0(sp)
ffffffffc020623a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020623c:	85a6                	mv	a1,s1
ffffffffc020623e:	07800513          	li	a0,120
ffffffffc0206242:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206244:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0206246:	6782                	ld	a5,0(sp)
ffffffffc0206248:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020624a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020624e:	bfb5                	j	ffffffffc02061ca <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206250:	000a3403          	ld	s0,0(s4)
ffffffffc0206254:	008a0713          	addi	a4,s4,8
ffffffffc0206258:	e03a                	sd	a4,0(sp)
ffffffffc020625a:	14040263          	beqz	s0,ffffffffc020639e <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020625e:	0fb05763          	blez	s11,ffffffffc020634c <vprintfmt+0x2d8>
ffffffffc0206262:	02d00693          	li	a3,45
ffffffffc0206266:	0cd79163          	bne	a5,a3,ffffffffc0206328 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020626a:	00044783          	lbu	a5,0(s0)
ffffffffc020626e:	0007851b          	sext.w	a0,a5
ffffffffc0206272:	cf85                	beqz	a5,ffffffffc02062aa <vprintfmt+0x236>
ffffffffc0206274:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206278:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020627c:	000c4563          	bltz	s8,ffffffffc0206286 <vprintfmt+0x212>
ffffffffc0206280:	3c7d                	addiw	s8,s8,-1
ffffffffc0206282:	036c0263          	beq	s8,s6,ffffffffc02062a6 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0206286:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206288:	0e0c8e63          	beqz	s9,ffffffffc0206384 <vprintfmt+0x310>
ffffffffc020628c:	3781                	addiw	a5,a5,-32
ffffffffc020628e:	0ef47b63          	bgeu	s0,a5,ffffffffc0206384 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0206292:	03f00513          	li	a0,63
ffffffffc0206296:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206298:	000a4783          	lbu	a5,0(s4)
ffffffffc020629c:	3dfd                	addiw	s11,s11,-1
ffffffffc020629e:	0a05                	addi	s4,s4,1
ffffffffc02062a0:	0007851b          	sext.w	a0,a5
ffffffffc02062a4:	ffe1                	bnez	a5,ffffffffc020627c <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02062a6:	01b05963          	blez	s11,ffffffffc02062b8 <vprintfmt+0x244>
ffffffffc02062aa:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02062ac:	85a6                	mv	a1,s1
ffffffffc02062ae:	02000513          	li	a0,32
ffffffffc02062b2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02062b4:	fe0d9be3          	bnez	s11,ffffffffc02062aa <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02062b8:	6a02                	ld	s4,0(sp)
ffffffffc02062ba:	bbd5                	j	ffffffffc02060ae <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02062bc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02062be:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02062c2:	01174463          	blt	a4,a7,ffffffffc02062ca <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02062c6:	08088d63          	beqz	a7,ffffffffc0206360 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02062ca:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02062ce:	0a044d63          	bltz	s0,ffffffffc0206388 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02062d2:	8622                	mv	a2,s0
ffffffffc02062d4:	8a66                	mv	s4,s9
ffffffffc02062d6:	46a9                	li	a3,10
ffffffffc02062d8:	bdcd                	j	ffffffffc02061ca <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02062da:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062de:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02062e0:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02062e2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02062e6:	8fb5                	xor	a5,a5,a3
ffffffffc02062e8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062ec:	02d74163          	blt	a4,a3,ffffffffc020630e <vprintfmt+0x29a>
ffffffffc02062f0:	00369793          	slli	a5,a3,0x3
ffffffffc02062f4:	97de                	add	a5,a5,s7
ffffffffc02062f6:	639c                	ld	a5,0(a5)
ffffffffc02062f8:	cb99                	beqz	a5,ffffffffc020630e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02062fa:	86be                	mv	a3,a5
ffffffffc02062fc:	00000617          	auipc	a2,0x0
ffffffffc0206300:	13c60613          	addi	a2,a2,316 # ffffffffc0206438 <etext+0x2c>
ffffffffc0206304:	85a6                	mv	a1,s1
ffffffffc0206306:	854a                	mv	a0,s2
ffffffffc0206308:	0ce000ef          	jal	ra,ffffffffc02063d6 <printfmt>
ffffffffc020630c:	b34d                	j	ffffffffc02060ae <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020630e:	00002617          	auipc	a2,0x2
ffffffffc0206312:	47260613          	addi	a2,a2,1138 # ffffffffc0208780 <syscalls+0x120>
ffffffffc0206316:	85a6                	mv	a1,s1
ffffffffc0206318:	854a                	mv	a0,s2
ffffffffc020631a:	0bc000ef          	jal	ra,ffffffffc02063d6 <printfmt>
ffffffffc020631e:	bb41                	j	ffffffffc02060ae <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206320:	00002417          	auipc	s0,0x2
ffffffffc0206324:	45840413          	addi	s0,s0,1112 # ffffffffc0208778 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206328:	85e2                	mv	a1,s8
ffffffffc020632a:	8522                	mv	a0,s0
ffffffffc020632c:	e43e                	sd	a5,8(sp)
ffffffffc020632e:	c4fff0ef          	jal	ra,ffffffffc0205f7c <strnlen>
ffffffffc0206332:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206336:	01b05b63          	blez	s11,ffffffffc020634c <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020633a:	67a2                	ld	a5,8(sp)
ffffffffc020633c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206340:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206342:	85a6                	mv	a1,s1
ffffffffc0206344:	8552                	mv	a0,s4
ffffffffc0206346:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206348:	fe0d9ce3          	bnez	s11,ffffffffc0206340 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020634c:	00044783          	lbu	a5,0(s0)
ffffffffc0206350:	00140a13          	addi	s4,s0,1
ffffffffc0206354:	0007851b          	sext.w	a0,a5
ffffffffc0206358:	d3a5                	beqz	a5,ffffffffc02062b8 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020635a:	05e00413          	li	s0,94
ffffffffc020635e:	bf39                	j	ffffffffc020627c <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0206360:	000a2403          	lw	s0,0(s4)
ffffffffc0206364:	b7ad                	j	ffffffffc02062ce <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0206366:	000a6603          	lwu	a2,0(s4)
ffffffffc020636a:	46a1                	li	a3,8
ffffffffc020636c:	8a2e                	mv	s4,a1
ffffffffc020636e:	bdb1                	j	ffffffffc02061ca <vprintfmt+0x156>
ffffffffc0206370:	000a6603          	lwu	a2,0(s4)
ffffffffc0206374:	46a9                	li	a3,10
ffffffffc0206376:	8a2e                	mv	s4,a1
ffffffffc0206378:	bd89                	j	ffffffffc02061ca <vprintfmt+0x156>
ffffffffc020637a:	000a6603          	lwu	a2,0(s4)
ffffffffc020637e:	46c1                	li	a3,16
ffffffffc0206380:	8a2e                	mv	s4,a1
ffffffffc0206382:	b5a1                	j	ffffffffc02061ca <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0206384:	9902                	jalr	s2
ffffffffc0206386:	bf09                	j	ffffffffc0206298 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0206388:	85a6                	mv	a1,s1
ffffffffc020638a:	02d00513          	li	a0,45
ffffffffc020638e:	e03e                	sd	a5,0(sp)
ffffffffc0206390:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0206392:	6782                	ld	a5,0(sp)
ffffffffc0206394:	8a66                	mv	s4,s9
ffffffffc0206396:	40800633          	neg	a2,s0
ffffffffc020639a:	46a9                	li	a3,10
ffffffffc020639c:	b53d                	j	ffffffffc02061ca <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020639e:	03b05163          	blez	s11,ffffffffc02063c0 <vprintfmt+0x34c>
ffffffffc02063a2:	02d00693          	li	a3,45
ffffffffc02063a6:	f6d79de3          	bne	a5,a3,ffffffffc0206320 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02063aa:	00002417          	auipc	s0,0x2
ffffffffc02063ae:	3ce40413          	addi	s0,s0,974 # ffffffffc0208778 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02063b2:	02800793          	li	a5,40
ffffffffc02063b6:	02800513          	li	a0,40
ffffffffc02063ba:	00140a13          	addi	s4,s0,1
ffffffffc02063be:	bd6d                	j	ffffffffc0206278 <vprintfmt+0x204>
ffffffffc02063c0:	00002a17          	auipc	s4,0x2
ffffffffc02063c4:	3b9a0a13          	addi	s4,s4,953 # ffffffffc0208779 <syscalls+0x119>
ffffffffc02063c8:	02800513          	li	a0,40
ffffffffc02063cc:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02063d0:	05e00413          	li	s0,94
ffffffffc02063d4:	b565                	j	ffffffffc020627c <vprintfmt+0x208>

ffffffffc02063d6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02063d6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02063d8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02063dc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02063de:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02063e0:	ec06                	sd	ra,24(sp)
ffffffffc02063e2:	f83a                	sd	a4,48(sp)
ffffffffc02063e4:	fc3e                	sd	a5,56(sp)
ffffffffc02063e6:	e0c2                	sd	a6,64(sp)
ffffffffc02063e8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02063ea:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02063ec:	c89ff0ef          	jal	ra,ffffffffc0206074 <vprintfmt>
}
ffffffffc02063f0:	60e2                	ld	ra,24(sp)
ffffffffc02063f2:	6161                	addi	sp,sp,80
ffffffffc02063f4:	8082                	ret

ffffffffc02063f6 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02063f6:	9e3707b7          	lui	a5,0x9e370
ffffffffc02063fa:	2785                	addiw	a5,a5,1
ffffffffc02063fc:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0206400:	02000793          	li	a5,32
ffffffffc0206404:	9f8d                	subw	a5,a5,a1
}
ffffffffc0206406:	00f5553b          	srlw	a0,a0,a5
ffffffffc020640a:	8082                	ret
