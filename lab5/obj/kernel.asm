
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
ffffffffc020004a:	0f4060ef          	jal	ra,ffffffffc020613e <memset>
    cons_init();                // init the console
ffffffffc020004e:	580000ef          	jal	ra,ffffffffc02005ce <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	51e58593          	addi	a1,a1,1310 # ffffffffc0206570 <etext+0x4>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	53650513          	addi	a0,a0,1334 # ffffffffc0206590 <etext+0x24>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	24e000ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	68c010ef          	jal	ra,ffffffffc02016f6 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5d2000ef          	jal	ra,ffffffffc0200640 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5dc000ef          	jal	ra,ffffffffc020064e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	4c5020ef          	jal	ra,ffffffffc0202d3a <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	4ab050ef          	jal	ra,ffffffffc0205d24 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4a8000ef          	jal	ra,ffffffffc0200526 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	764030ef          	jal	ra,ffffffffc02037e6 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4f6000ef          	jal	ra,ffffffffc020057c <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b8000ef          	jal	ra,ffffffffc0200642 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	62f050ef          	jal	ra,ffffffffc0205ebc <cpu_idle>

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
ffffffffc020009a:	536000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
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
ffffffffc02000c0:	114060ef          	jal	ra,ffffffffc02061d4 <vprintfmt>
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
ffffffffc02000f6:	0de060ef          	jal	ra,ffffffffc02061d4 <vprintfmt>
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
ffffffffc0200102:	a1f9                	j	ffffffffc02005d0 <cons_putc>

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
ffffffffc020011a:	4b6000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020011e:	00044503          	lbu	a0,0(s0)
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	f96d                	bnez	a0,ffffffffc020011a <cputs+0x16>
    (*cnt) ++;
ffffffffc020012a:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020012e:	4529                	li	a0,10
ffffffffc0200130:	4a0000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
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
ffffffffc0200148:	4bc000ef          	jal	ra,ffffffffc0200604 <cons_getc>
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
ffffffffc020016e:	42e50513          	addi	a0,a0,1070 # ffffffffc0206598 <etext+0x2c>
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
ffffffffc020023a:	36a50513          	addi	a0,a0,874 # ffffffffc02065a0 <etext+0x34>
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
ffffffffc0200250:	13c50513          	addi	a0,a0,316 # ffffffffc0207388 <commands+0xb70>
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
ffffffffc0200264:	3e4000ef          	jal	ra,ffffffffc0200648 <intr_disable>
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
ffffffffc0200284:	34050513          	addi	a0,a0,832 # ffffffffc02065c0 <etext+0x54>
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
ffffffffc02002a4:	0e850513          	addi	a0,a0,232 # ffffffffc0207388 <commands+0xb70>
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
ffffffffc02002ba:	32a50513          	addi	a0,a0,810 # ffffffffc02065e0 <etext+0x74>
void print_kerninfo(void) {
ffffffffc02002be:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002c0:	e0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002c4:	00000597          	auipc	a1,0x0
ffffffffc02002c8:	d6e58593          	addi	a1,a1,-658 # ffffffffc0200032 <kern_init>
ffffffffc02002cc:	00006517          	auipc	a0,0x6
ffffffffc02002d0:	33450513          	addi	a0,a0,820 # ffffffffc0206600 <etext+0x94>
ffffffffc02002d4:	df9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002d8:	00006597          	auipc	a1,0x6
ffffffffc02002dc:	29458593          	addi	a1,a1,660 # ffffffffc020656c <etext>
ffffffffc02002e0:	00006517          	auipc	a0,0x6
ffffffffc02002e4:	34050513          	addi	a0,a0,832 # ffffffffc0206620 <etext+0xb4>
ffffffffc02002e8:	de5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002ec:	000a7597          	auipc	a1,0xa7
ffffffffc02002f0:	11c58593          	addi	a1,a1,284 # ffffffffc02a7408 <buf>
ffffffffc02002f4:	00006517          	auipc	a0,0x6
ffffffffc02002f8:	34c50513          	addi	a0,a0,844 # ffffffffc0206640 <etext+0xd4>
ffffffffc02002fc:	dd1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200300:	000b2597          	auipc	a1,0xb2
ffffffffc0200304:	66458593          	addi	a1,a1,1636 # ffffffffc02b2964 <end>
ffffffffc0200308:	00006517          	auipc	a0,0x6
ffffffffc020030c:	35850513          	addi	a0,a0,856 # ffffffffc0206660 <etext+0xf4>
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
ffffffffc020033a:	34a50513          	addi	a0,a0,842 # ffffffffc0206680 <etext+0x114>
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
ffffffffc0200348:	36c60613          	addi	a2,a2,876 # ffffffffc02066b0 <etext+0x144>
ffffffffc020034c:	04d00593          	li	a1,77
ffffffffc0200350:	00006517          	auipc	a0,0x6
ffffffffc0200354:	37850513          	addi	a0,a0,888 # ffffffffc02066c8 <etext+0x15c>
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
ffffffffc0200364:	38060613          	addi	a2,a2,896 # ffffffffc02066e0 <etext+0x174>
ffffffffc0200368:	00006597          	auipc	a1,0x6
ffffffffc020036c:	39858593          	addi	a1,a1,920 # ffffffffc0206700 <etext+0x194>
ffffffffc0200370:	00006517          	auipc	a0,0x6
ffffffffc0200374:	39850513          	addi	a0,a0,920 # ffffffffc0206708 <etext+0x19c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200378:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020037a:	d53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020037e:	00006617          	auipc	a2,0x6
ffffffffc0200382:	39a60613          	addi	a2,a2,922 # ffffffffc0206718 <etext+0x1ac>
ffffffffc0200386:	00006597          	auipc	a1,0x6
ffffffffc020038a:	3ba58593          	addi	a1,a1,954 # ffffffffc0206740 <etext+0x1d4>
ffffffffc020038e:	00006517          	auipc	a0,0x6
ffffffffc0200392:	37a50513          	addi	a0,a0,890 # ffffffffc0206708 <etext+0x19c>
ffffffffc0200396:	d37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020039a:	00006617          	auipc	a2,0x6
ffffffffc020039e:	3b660613          	addi	a2,a2,950 # ffffffffc0206750 <etext+0x1e4>
ffffffffc02003a2:	00006597          	auipc	a1,0x6
ffffffffc02003a6:	3ce58593          	addi	a1,a1,974 # ffffffffc0206770 <etext+0x204>
ffffffffc02003aa:	00006517          	auipc	a0,0x6
ffffffffc02003ae:	35e50513          	addi	a0,a0,862 # ffffffffc0206708 <etext+0x19c>
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
ffffffffc02003e8:	39c50513          	addi	a0,a0,924 # ffffffffc0206780 <etext+0x214>
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
ffffffffc020040a:	3a250513          	addi	a0,a0,930 # ffffffffc02067a8 <etext+0x23c>
ffffffffc020040e:	cbfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200412:	000b8563          	beqz	s7,ffffffffc020041c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200416:	855e                	mv	a0,s7
ffffffffc0200418:	41e000ef          	jal	ra,ffffffffc0200836 <print_trapframe>
ffffffffc020041c:	00006c17          	auipc	s8,0x6
ffffffffc0200420:	3fcc0c13          	addi	s8,s8,1020 # ffffffffc0206818 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200424:	00006917          	auipc	s2,0x6
ffffffffc0200428:	3ac90913          	addi	s2,s2,940 # ffffffffc02067d0 <etext+0x264>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042c:	00006497          	auipc	s1,0x6
ffffffffc0200430:	3ac48493          	addi	s1,s1,940 # ffffffffc02067d8 <etext+0x26c>
        if (argc == MAXARGS - 1) {
ffffffffc0200434:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	00006b17          	auipc	s6,0x6
ffffffffc020043a:	3aab0b13          	addi	s6,s6,938 # ffffffffc02067e0 <etext+0x274>
        argv[argc ++] = buf;
ffffffffc020043e:	00006a17          	auipc	s4,0x6
ffffffffc0200442:	2c2a0a13          	addi	s4,s4,706 # ffffffffc0206700 <etext+0x194>
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
ffffffffc0200464:	3b8d0d13          	addi	s10,s10,952 # ffffffffc0206818 <commands>
        argv[argc ++] = buf;
ffffffffc0200468:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020046a:	4401                	li	s0,0
ffffffffc020046c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020046e:	49d050ef          	jal	ra,ffffffffc020610a <strcmp>
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
ffffffffc0200482:	489050ef          	jal	ra,ffffffffc020610a <strcmp>
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
ffffffffc02004c0:	469050ef          	jal	ra,ffffffffc0206128 <strchr>
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
ffffffffc02004fe:	42b050ef          	jal	ra,ffffffffc0206128 <strchr>
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
ffffffffc020051c:	2e850513          	addi	a0,a0,744 # ffffffffc0206800 <etext+0x294>
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

ffffffffc0200534 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200534:	000a7797          	auipc	a5,0xa7
ffffffffc0200538:	2d478793          	addi	a5,a5,724 # ffffffffc02a7808 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc020053c:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200540:	1141                	addi	sp,sp,-16
ffffffffc0200542:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200544:	95be                	add	a1,a1,a5
ffffffffc0200546:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020054a:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020054c:	405050ef          	jal	ra,ffffffffc0206150 <memcpy>
    return 0;
}
ffffffffc0200550:	60a2                	ld	ra,8(sp)
ffffffffc0200552:	4501                	li	a0,0
ffffffffc0200554:	0141                	addi	sp,sp,16
ffffffffc0200556:	8082                	ret

ffffffffc0200558 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200558:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020055c:	000a7517          	auipc	a0,0xa7
ffffffffc0200560:	2ac50513          	addi	a0,a0,684 # ffffffffc02a7808 <ide>
                   size_t nsecs) {
ffffffffc0200564:	1141                	addi	sp,sp,-16
ffffffffc0200566:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200568:	953e                	add	a0,a0,a5
ffffffffc020056a:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020056e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200570:	3e1050ef          	jal	ra,ffffffffc0206150 <memcpy>
    return 0;
}
ffffffffc0200574:	60a2                	ld	ra,8(sp)
ffffffffc0200576:	4501                	li	a0,0
ffffffffc0200578:	0141                	addi	sp,sp,16
ffffffffc020057a:	8082                	ret

ffffffffc020057c <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020057c:	67e1                	lui	a5,0x18
ffffffffc020057e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd570>
ffffffffc0200582:	000b2717          	auipc	a4,0xb2
ffffffffc0200586:	34f73f23          	sd	a5,862(a4) # ffffffffc02b28e0 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020058a:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020058e:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200590:	953e                	add	a0,a0,a5
ffffffffc0200592:	4601                	li	a2,0
ffffffffc0200594:	4881                	li	a7,0
ffffffffc0200596:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020059a:	02000793          	li	a5,32
ffffffffc020059e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02005a2:	00006517          	auipc	a0,0x6
ffffffffc02005a6:	2be50513          	addi	a0,a0,702 # ffffffffc0206860 <commands+0x48>
    ticks = 0;
ffffffffc02005aa:	000b2797          	auipc	a5,0xb2
ffffffffc02005ae:	3207b723          	sd	zero,814(a5) # ffffffffc02b28d8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005b2:	be29                	j	ffffffffc02000cc <cprintf>

ffffffffc02005b4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005b4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005b8:	000b2797          	auipc	a5,0xb2
ffffffffc02005bc:	3287b783          	ld	a5,808(a5) # ffffffffc02b28e0 <timebase>
ffffffffc02005c0:	953e                	add	a0,a0,a5
ffffffffc02005c2:	4581                	li	a1,0
ffffffffc02005c4:	4601                	li	a2,0
ffffffffc02005c6:	4881                	li	a7,0
ffffffffc02005c8:	00000073          	ecall
ffffffffc02005cc:	8082                	ret

ffffffffc02005ce <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005d0:	100027f3          	csrr	a5,sstatus
ffffffffc02005d4:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005d6:	0ff57513          	zext.b	a0,a0
ffffffffc02005da:	e799                	bnez	a5,ffffffffc02005e8 <cons_putc+0x18>
ffffffffc02005dc:	4581                	li	a1,0
ffffffffc02005de:	4601                	li	a2,0
ffffffffc02005e0:	4885                	li	a7,1
ffffffffc02005e2:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005e6:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005e8:	1101                	addi	sp,sp,-32
ffffffffc02005ea:	ec06                	sd	ra,24(sp)
ffffffffc02005ec:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005ee:	05a000ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02005f2:	6522                	ld	a0,8(sp)
ffffffffc02005f4:	4581                	li	a1,0
ffffffffc02005f6:	4601                	li	a2,0
ffffffffc02005f8:	4885                	li	a7,1
ffffffffc02005fa:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005fe:	60e2                	ld	ra,24(sp)
ffffffffc0200600:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200602:	a081                	j	ffffffffc0200642 <intr_enable>

ffffffffc0200604 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200604:	100027f3          	csrr	a5,sstatus
ffffffffc0200608:	8b89                	andi	a5,a5,2
ffffffffc020060a:	eb89                	bnez	a5,ffffffffc020061c <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020060c:	4501                	li	a0,0
ffffffffc020060e:	4581                	li	a1,0
ffffffffc0200610:	4601                	li	a2,0
ffffffffc0200612:	4889                	li	a7,2
ffffffffc0200614:	00000073          	ecall
ffffffffc0200618:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020061a:	8082                	ret
int cons_getc(void) {
ffffffffc020061c:	1101                	addi	sp,sp,-32
ffffffffc020061e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200620:	028000ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0200624:	4501                	li	a0,0
ffffffffc0200626:	4581                	li	a1,0
ffffffffc0200628:	4601                	li	a2,0
ffffffffc020062a:	4889                	li	a7,2
ffffffffc020062c:	00000073          	ecall
ffffffffc0200630:	2501                	sext.w	a0,a0
ffffffffc0200632:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200634:	00e000ef          	jal	ra,ffffffffc0200642 <intr_enable>
}
ffffffffc0200638:	60e2                	ld	ra,24(sp)
ffffffffc020063a:	6522                	ld	a0,8(sp)
ffffffffc020063c:	6105                	addi	sp,sp,32
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200640:	8082                	ret

ffffffffc0200642 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200642:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200646:	8082                	ret

ffffffffc0200648 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200648:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020064c:	8082                	ret

ffffffffc020064e <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020064e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200652:	00000797          	auipc	a5,0x0
ffffffffc0200656:	65a78793          	addi	a5,a5,1626 # ffffffffc0200cac <__alltraps>
ffffffffc020065a:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020065e:	000407b7          	lui	a5,0x40
ffffffffc0200662:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200666:	8082                	ret

ffffffffc0200668 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200668:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020066a:	1141                	addi	sp,sp,-16
ffffffffc020066c:	e022                	sd	s0,0(sp)
ffffffffc020066e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200670:	00006517          	auipc	a0,0x6
ffffffffc0200674:	21050513          	addi	a0,a0,528 # ffffffffc0206880 <commands+0x68>
void print_regs(struct pushregs* gpr) {
ffffffffc0200678:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067a:	a53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067e:	640c                	ld	a1,8(s0)
ffffffffc0200680:	00006517          	auipc	a0,0x6
ffffffffc0200684:	21850513          	addi	a0,a0,536 # ffffffffc0206898 <commands+0x80>
ffffffffc0200688:	a45ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020068c:	680c                	ld	a1,16(s0)
ffffffffc020068e:	00006517          	auipc	a0,0x6
ffffffffc0200692:	22250513          	addi	a0,a0,546 # ffffffffc02068b0 <commands+0x98>
ffffffffc0200696:	a37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069a:	6c0c                	ld	a1,24(s0)
ffffffffc020069c:	00006517          	auipc	a0,0x6
ffffffffc02006a0:	22c50513          	addi	a0,a0,556 # ffffffffc02068c8 <commands+0xb0>
ffffffffc02006a4:	a29ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a8:	700c                	ld	a1,32(s0)
ffffffffc02006aa:	00006517          	auipc	a0,0x6
ffffffffc02006ae:	23650513          	addi	a0,a0,566 # ffffffffc02068e0 <commands+0xc8>
ffffffffc02006b2:	a1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b6:	740c                	ld	a1,40(s0)
ffffffffc02006b8:	00006517          	auipc	a0,0x6
ffffffffc02006bc:	24050513          	addi	a0,a0,576 # ffffffffc02068f8 <commands+0xe0>
ffffffffc02006c0:	a0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c4:	780c                	ld	a1,48(s0)
ffffffffc02006c6:	00006517          	auipc	a0,0x6
ffffffffc02006ca:	24a50513          	addi	a0,a0,586 # ffffffffc0206910 <commands+0xf8>
ffffffffc02006ce:	9ffff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d2:	7c0c                	ld	a1,56(s0)
ffffffffc02006d4:	00006517          	auipc	a0,0x6
ffffffffc02006d8:	25450513          	addi	a0,a0,596 # ffffffffc0206928 <commands+0x110>
ffffffffc02006dc:	9f1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e0:	602c                	ld	a1,64(s0)
ffffffffc02006e2:	00006517          	auipc	a0,0x6
ffffffffc02006e6:	25e50513          	addi	a0,a0,606 # ffffffffc0206940 <commands+0x128>
ffffffffc02006ea:	9e3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ee:	642c                	ld	a1,72(s0)
ffffffffc02006f0:	00006517          	auipc	a0,0x6
ffffffffc02006f4:	26850513          	addi	a0,a0,616 # ffffffffc0206958 <commands+0x140>
ffffffffc02006f8:	9d5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006fc:	682c                	ld	a1,80(s0)
ffffffffc02006fe:	00006517          	auipc	a0,0x6
ffffffffc0200702:	27250513          	addi	a0,a0,626 # ffffffffc0206970 <commands+0x158>
ffffffffc0200706:	9c7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070a:	6c2c                	ld	a1,88(s0)
ffffffffc020070c:	00006517          	auipc	a0,0x6
ffffffffc0200710:	27c50513          	addi	a0,a0,636 # ffffffffc0206988 <commands+0x170>
ffffffffc0200714:	9b9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200718:	702c                	ld	a1,96(s0)
ffffffffc020071a:	00006517          	auipc	a0,0x6
ffffffffc020071e:	28650513          	addi	a0,a0,646 # ffffffffc02069a0 <commands+0x188>
ffffffffc0200722:	9abff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200726:	742c                	ld	a1,104(s0)
ffffffffc0200728:	00006517          	auipc	a0,0x6
ffffffffc020072c:	29050513          	addi	a0,a0,656 # ffffffffc02069b8 <commands+0x1a0>
ffffffffc0200730:	99dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200734:	782c                	ld	a1,112(s0)
ffffffffc0200736:	00006517          	auipc	a0,0x6
ffffffffc020073a:	29a50513          	addi	a0,a0,666 # ffffffffc02069d0 <commands+0x1b8>
ffffffffc020073e:	98fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200742:	7c2c                	ld	a1,120(s0)
ffffffffc0200744:	00006517          	auipc	a0,0x6
ffffffffc0200748:	2a450513          	addi	a0,a0,676 # ffffffffc02069e8 <commands+0x1d0>
ffffffffc020074c:	981ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200750:	604c                	ld	a1,128(s0)
ffffffffc0200752:	00006517          	auipc	a0,0x6
ffffffffc0200756:	2ae50513          	addi	a0,a0,686 # ffffffffc0206a00 <commands+0x1e8>
ffffffffc020075a:	973ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075e:	644c                	ld	a1,136(s0)
ffffffffc0200760:	00006517          	auipc	a0,0x6
ffffffffc0200764:	2b850513          	addi	a0,a0,696 # ffffffffc0206a18 <commands+0x200>
ffffffffc0200768:	965ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020076c:	684c                	ld	a1,144(s0)
ffffffffc020076e:	00006517          	auipc	a0,0x6
ffffffffc0200772:	2c250513          	addi	a0,a0,706 # ffffffffc0206a30 <commands+0x218>
ffffffffc0200776:	957ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077a:	6c4c                	ld	a1,152(s0)
ffffffffc020077c:	00006517          	auipc	a0,0x6
ffffffffc0200780:	2cc50513          	addi	a0,a0,716 # ffffffffc0206a48 <commands+0x230>
ffffffffc0200784:	949ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200788:	704c                	ld	a1,160(s0)
ffffffffc020078a:	00006517          	auipc	a0,0x6
ffffffffc020078e:	2d650513          	addi	a0,a0,726 # ffffffffc0206a60 <commands+0x248>
ffffffffc0200792:	93bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200796:	744c                	ld	a1,168(s0)
ffffffffc0200798:	00006517          	auipc	a0,0x6
ffffffffc020079c:	2e050513          	addi	a0,a0,736 # ffffffffc0206a78 <commands+0x260>
ffffffffc02007a0:	92dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a4:	784c                	ld	a1,176(s0)
ffffffffc02007a6:	00006517          	auipc	a0,0x6
ffffffffc02007aa:	2ea50513          	addi	a0,a0,746 # ffffffffc0206a90 <commands+0x278>
ffffffffc02007ae:	91fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b2:	7c4c                	ld	a1,184(s0)
ffffffffc02007b4:	00006517          	auipc	a0,0x6
ffffffffc02007b8:	2f450513          	addi	a0,a0,756 # ffffffffc0206aa8 <commands+0x290>
ffffffffc02007bc:	911ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c0:	606c                	ld	a1,192(s0)
ffffffffc02007c2:	00006517          	auipc	a0,0x6
ffffffffc02007c6:	2fe50513          	addi	a0,a0,766 # ffffffffc0206ac0 <commands+0x2a8>
ffffffffc02007ca:	903ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ce:	646c                	ld	a1,200(s0)
ffffffffc02007d0:	00006517          	auipc	a0,0x6
ffffffffc02007d4:	30850513          	addi	a0,a0,776 # ffffffffc0206ad8 <commands+0x2c0>
ffffffffc02007d8:	8f5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007dc:	686c                	ld	a1,208(s0)
ffffffffc02007de:	00006517          	auipc	a0,0x6
ffffffffc02007e2:	31250513          	addi	a0,a0,786 # ffffffffc0206af0 <commands+0x2d8>
ffffffffc02007e6:	8e7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ea:	6c6c                	ld	a1,216(s0)
ffffffffc02007ec:	00006517          	auipc	a0,0x6
ffffffffc02007f0:	31c50513          	addi	a0,a0,796 # ffffffffc0206b08 <commands+0x2f0>
ffffffffc02007f4:	8d9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f8:	706c                	ld	a1,224(s0)
ffffffffc02007fa:	00006517          	auipc	a0,0x6
ffffffffc02007fe:	32650513          	addi	a0,a0,806 # ffffffffc0206b20 <commands+0x308>
ffffffffc0200802:	8cbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200806:	746c                	ld	a1,232(s0)
ffffffffc0200808:	00006517          	auipc	a0,0x6
ffffffffc020080c:	33050513          	addi	a0,a0,816 # ffffffffc0206b38 <commands+0x320>
ffffffffc0200810:	8bdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200814:	786c                	ld	a1,240(s0)
ffffffffc0200816:	00006517          	auipc	a0,0x6
ffffffffc020081a:	33a50513          	addi	a0,a0,826 # ffffffffc0206b50 <commands+0x338>
ffffffffc020081e:	8afff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200824:	6402                	ld	s0,0(sp)
ffffffffc0200826:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200828:	00006517          	auipc	a0,0x6
ffffffffc020082c:	34050513          	addi	a0,a0,832 # ffffffffc0206b68 <commands+0x350>
}
ffffffffc0200830:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200832:	89bff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200836 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200836:	1141                	addi	sp,sp,-16
ffffffffc0200838:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020083a:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc020083c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020083e:	00006517          	auipc	a0,0x6
ffffffffc0200842:	34250513          	addi	a0,a0,834 # ffffffffc0206b80 <commands+0x368>
print_trapframe(struct trapframe *tf) {
ffffffffc0200846:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200848:	885ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    print_regs(&tf->gpr);
ffffffffc020084c:	8522                	mv	a0,s0
ffffffffc020084e:	e1bff0ef          	jal	ra,ffffffffc0200668 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200852:	10043583          	ld	a1,256(s0)
ffffffffc0200856:	00006517          	auipc	a0,0x6
ffffffffc020085a:	34250513          	addi	a0,a0,834 # ffffffffc0206b98 <commands+0x380>
ffffffffc020085e:	86fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200862:	10843583          	ld	a1,264(s0)
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	34a50513          	addi	a0,a0,842 # ffffffffc0206bb0 <commands+0x398>
ffffffffc020086e:	85fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200872:	11043583          	ld	a1,272(s0)
ffffffffc0200876:	00006517          	auipc	a0,0x6
ffffffffc020087a:	35250513          	addi	a0,a0,850 # ffffffffc0206bc8 <commands+0x3b0>
ffffffffc020087e:	84fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200882:	11843583          	ld	a1,280(s0)
}
ffffffffc0200886:	6402                	ld	s0,0(sp)
ffffffffc0200888:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	34e50513          	addi	a0,a0,846 # ffffffffc0206bd8 <commands+0x3c0>
}
ffffffffc0200892:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200894:	839ff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200898 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200898:	1101                	addi	sp,sp,-32
ffffffffc020089a:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc020089c:	000b2497          	auipc	s1,0xb2
ffffffffc02008a0:	07c48493          	addi	s1,s1,124 # ffffffffc02b2918 <check_mm_struct>
ffffffffc02008a4:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a6:	e822                	sd	s0,16(sp)
ffffffffc02008a8:	ec06                	sd	ra,24(sp)
ffffffffc02008aa:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008ac:	cbad                	beqz	a5,ffffffffc020091e <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ae:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008b2:	11053583          	ld	a1,272(a0)
ffffffffc02008b6:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ba:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008be:	c7b1                	beqz	a5,ffffffffc020090a <pgfault_handler+0x72>
ffffffffc02008c0:	11843703          	ld	a4,280(s0)
ffffffffc02008c4:	47bd                	li	a5,15
ffffffffc02008c6:	05700693          	li	a3,87
ffffffffc02008ca:	00f70463          	beq	a4,a5,ffffffffc02008d2 <pgfault_handler+0x3a>
ffffffffc02008ce:	05200693          	li	a3,82
ffffffffc02008d2:	00006517          	auipc	a0,0x6
ffffffffc02008d6:	31e50513          	addi	a0,a0,798 # ffffffffc0206bf0 <commands+0x3d8>
ffffffffc02008da:	ff2ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008de:	6088                	ld	a0,0(s1)
ffffffffc02008e0:	cd1d                	beqz	a0,ffffffffc020091e <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008e2:	000b2717          	auipc	a4,0xb2
ffffffffc02008e6:	06673703          	ld	a4,102(a4) # ffffffffc02b2948 <current>
ffffffffc02008ea:	000b2797          	auipc	a5,0xb2
ffffffffc02008ee:	0667b783          	ld	a5,102(a5) # ffffffffc02b2950 <idleproc>
ffffffffc02008f2:	04f71663          	bne	a4,a5,ffffffffc020093e <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f6:	11043603          	ld	a2,272(s0)
ffffffffc02008fa:	11843583          	ld	a1,280(s0)
}
ffffffffc02008fe:	6442                	ld	s0,16(sp)
ffffffffc0200900:	60e2                	ld	ra,24(sp)
ffffffffc0200902:	64a2                	ld	s1,8(sp)
ffffffffc0200904:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200906:	1750206f          	j	ffffffffc020327a <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020090a:	11843703          	ld	a4,280(s0)
ffffffffc020090e:	47bd                	li	a5,15
ffffffffc0200910:	05500613          	li	a2,85
ffffffffc0200914:	05700693          	li	a3,87
ffffffffc0200918:	faf71be3          	bne	a4,a5,ffffffffc02008ce <pgfault_handler+0x36>
ffffffffc020091c:	bf5d                	j	ffffffffc02008d2 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020091e:	000b2797          	auipc	a5,0xb2
ffffffffc0200922:	02a7b783          	ld	a5,42(a5) # ffffffffc02b2948 <current>
ffffffffc0200926:	cf85                	beqz	a5,ffffffffc020095e <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200928:	11043603          	ld	a2,272(s0)
ffffffffc020092c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200930:	6442                	ld	s0,16(sp)
ffffffffc0200932:	60e2                	ld	ra,24(sp)
ffffffffc0200934:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200936:	7788                	ld	a0,40(a5)
}
ffffffffc0200938:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020093a:	1410206f          	j	ffffffffc020327a <do_pgfault>
        assert(current == idleproc);
ffffffffc020093e:	00006697          	auipc	a3,0x6
ffffffffc0200942:	2d268693          	addi	a3,a3,722 # ffffffffc0206c10 <commands+0x3f8>
ffffffffc0200946:	00006617          	auipc	a2,0x6
ffffffffc020094a:	2e260613          	addi	a2,a2,738 # ffffffffc0206c28 <commands+0x410>
ffffffffc020094e:	06b00593          	li	a1,107
ffffffffc0200952:	00006517          	auipc	a0,0x6
ffffffffc0200956:	2ee50513          	addi	a0,a0,750 # ffffffffc0206c40 <commands+0x428>
ffffffffc020095a:	8afff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc020095e:	8522                	mv	a0,s0
ffffffffc0200960:	ed7ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200964:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200968:	11043583          	ld	a1,272(s0)
ffffffffc020096c:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200970:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200974:	e399                	bnez	a5,ffffffffc020097a <pgfault_handler+0xe2>
ffffffffc0200976:	05500613          	li	a2,85
ffffffffc020097a:	11843703          	ld	a4,280(s0)
ffffffffc020097e:	47bd                	li	a5,15
ffffffffc0200980:	02f70663          	beq	a4,a5,ffffffffc02009ac <pgfault_handler+0x114>
ffffffffc0200984:	05200693          	li	a3,82
ffffffffc0200988:	00006517          	auipc	a0,0x6
ffffffffc020098c:	26850513          	addi	a0,a0,616 # ffffffffc0206bf0 <commands+0x3d8>
ffffffffc0200990:	f3cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200994:	00006617          	auipc	a2,0x6
ffffffffc0200998:	2c460613          	addi	a2,a2,708 # ffffffffc0206c58 <commands+0x440>
ffffffffc020099c:	07200593          	li	a1,114
ffffffffc02009a0:	00006517          	auipc	a0,0x6
ffffffffc02009a4:	2a050513          	addi	a0,a0,672 # ffffffffc0206c40 <commands+0x428>
ffffffffc02009a8:	861ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009ac:	05700693          	li	a3,87
ffffffffc02009b0:	bfe1                	j	ffffffffc0200988 <pgfault_handler+0xf0>

ffffffffc02009b2 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009b2:	11853783          	ld	a5,280(a0)
ffffffffc02009b6:	472d                	li	a4,11
ffffffffc02009b8:	0786                	slli	a5,a5,0x1
ffffffffc02009ba:	8385                	srli	a5,a5,0x1
ffffffffc02009bc:	08f76363          	bltu	a4,a5,ffffffffc0200a42 <interrupt_handler+0x90>
ffffffffc02009c0:	00006717          	auipc	a4,0x6
ffffffffc02009c4:	35070713          	addi	a4,a4,848 # ffffffffc0206d10 <commands+0x4f8>
ffffffffc02009c8:	078a                	slli	a5,a5,0x2
ffffffffc02009ca:	97ba                	add	a5,a5,a4
ffffffffc02009cc:	439c                	lw	a5,0(a5)
ffffffffc02009ce:	97ba                	add	a5,a5,a4
ffffffffc02009d0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009d2:	00006517          	auipc	a0,0x6
ffffffffc02009d6:	2fe50513          	addi	a0,a0,766 # ffffffffc0206cd0 <commands+0x4b8>
ffffffffc02009da:	ef2ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009de:	00006517          	auipc	a0,0x6
ffffffffc02009e2:	2d250513          	addi	a0,a0,722 # ffffffffc0206cb0 <commands+0x498>
ffffffffc02009e6:	ee6ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009ea:	00006517          	auipc	a0,0x6
ffffffffc02009ee:	28650513          	addi	a0,a0,646 # ffffffffc0206c70 <commands+0x458>
ffffffffc02009f2:	edaff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009f6:	00006517          	auipc	a0,0x6
ffffffffc02009fa:	29a50513          	addi	a0,a0,666 # ffffffffc0206c90 <commands+0x478>
ffffffffc02009fe:	eceff06f          	j	ffffffffc02000cc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a02:	1141                	addi	sp,sp,-16
ffffffffc0200a04:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200a06:	bafff0ef          	jal	ra,ffffffffc02005b4 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a0a:	000b2697          	auipc	a3,0xb2
ffffffffc0200a0e:	ece68693          	addi	a3,a3,-306 # ffffffffc02b28d8 <ticks>
ffffffffc0200a12:	629c                	ld	a5,0(a3)
ffffffffc0200a14:	06400713          	li	a4,100
ffffffffc0200a18:	0785                	addi	a5,a5,1
ffffffffc0200a1a:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a1e:	e29c                	sd	a5,0(a3)
ffffffffc0200a20:	eb01                	bnez	a4,ffffffffc0200a30 <interrupt_handler+0x7e>
ffffffffc0200a22:	000b2797          	auipc	a5,0xb2
ffffffffc0200a26:	f267b783          	ld	a5,-218(a5) # ffffffffc02b2948 <current>
ffffffffc0200a2a:	c399                	beqz	a5,ffffffffc0200a30 <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a2c:	4705                	li	a4,1
ffffffffc0200a2e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a30:	60a2                	ld	ra,8(sp)
ffffffffc0200a32:	0141                	addi	sp,sp,16
ffffffffc0200a34:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a36:	00006517          	auipc	a0,0x6
ffffffffc0200a3a:	2ba50513          	addi	a0,a0,698 # ffffffffc0206cf0 <commands+0x4d8>
ffffffffc0200a3e:	e8eff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc0200a42:	bbd5                	j	ffffffffc0200836 <print_trapframe>

ffffffffc0200a44 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a44:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a48:	1101                	addi	sp,sp,-32
ffffffffc0200a4a:	e822                	sd	s0,16(sp)
ffffffffc0200a4c:	ec06                	sd	ra,24(sp)
ffffffffc0200a4e:	e426                	sd	s1,8(sp)
ffffffffc0200a50:	473d                	li	a4,15
ffffffffc0200a52:	842a                	mv	s0,a0
ffffffffc0200a54:	18f76563          	bltu	a4,a5,ffffffffc0200bde <exception_handler+0x19a>
ffffffffc0200a58:	00006717          	auipc	a4,0x6
ffffffffc0200a5c:	48070713          	addi	a4,a4,1152 # ffffffffc0206ed8 <commands+0x6c0>
ffffffffc0200a60:	078a                	slli	a5,a5,0x2
ffffffffc0200a62:	97ba                	add	a5,a5,a4
ffffffffc0200a64:	439c                	lw	a5,0(a5)
ffffffffc0200a66:	97ba                	add	a5,a5,a4
ffffffffc0200a68:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a6a:	00006517          	auipc	a0,0x6
ffffffffc0200a6e:	3c650513          	addi	a0,a0,966 # ffffffffc0206e30 <commands+0x618>
ffffffffc0200a72:	e5aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            tf->epc += 4;
ffffffffc0200a76:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a7a:	60e2                	ld	ra,24(sp)
ffffffffc0200a7c:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a7e:	0791                	addi	a5,a5,4
ffffffffc0200a80:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a84:	6442                	ld	s0,16(sp)
ffffffffc0200a86:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a88:	5ba0506f          	j	ffffffffc0206042 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8c:	00006517          	auipc	a0,0x6
ffffffffc0200a90:	3c450513          	addi	a0,a0,964 # ffffffffc0206e50 <commands+0x638>
}
ffffffffc0200a94:	6442                	ld	s0,16(sp)
ffffffffc0200a96:	60e2                	ld	ra,24(sp)
ffffffffc0200a98:	64a2                	ld	s1,8(sp)
ffffffffc0200a9a:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a9c:	e30ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aa0:	00006517          	auipc	a0,0x6
ffffffffc0200aa4:	3d050513          	addi	a0,a0,976 # ffffffffc0206e70 <commands+0x658>
ffffffffc0200aa8:	b7f5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aaa:	00006517          	auipc	a0,0x6
ffffffffc0200aae:	3e650513          	addi	a0,a0,998 # ffffffffc0206e90 <commands+0x678>
ffffffffc0200ab2:	b7cd                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ab4:	00006517          	auipc	a0,0x6
ffffffffc0200ab8:	3f450513          	addi	a0,a0,1012 # ffffffffc0206ea8 <commands+0x690>
ffffffffc0200abc:	e10ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ac0:	8522                	mv	a0,s0
ffffffffc0200ac2:	dd7ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200ac6:	84aa                	mv	s1,a0
ffffffffc0200ac8:	12051d63          	bnez	a0,ffffffffc0200c02 <exception_handler+0x1be>
}
ffffffffc0200acc:	60e2                	ld	ra,24(sp)
ffffffffc0200ace:	6442                	ld	s0,16(sp)
ffffffffc0200ad0:	64a2                	ld	s1,8(sp)
ffffffffc0200ad2:	6105                	addi	sp,sp,32
ffffffffc0200ad4:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ad6:	00006517          	auipc	a0,0x6
ffffffffc0200ada:	3ea50513          	addi	a0,a0,1002 # ffffffffc0206ec0 <commands+0x6a8>
ffffffffc0200ade:	deeff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae2:	8522                	mv	a0,s0
ffffffffc0200ae4:	db5ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200ae8:	84aa                	mv	s1,a0
ffffffffc0200aea:	d16d                	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200aec:	8522                	mv	a0,s0
ffffffffc0200aee:	d49ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af2:	86a6                	mv	a3,s1
ffffffffc0200af4:	00006617          	auipc	a2,0x6
ffffffffc0200af8:	2ec60613          	addi	a2,a2,748 # ffffffffc0206de0 <commands+0x5c8>
ffffffffc0200afc:	0f800593          	li	a1,248
ffffffffc0200b00:	00006517          	auipc	a0,0x6
ffffffffc0200b04:	14050513          	addi	a0,a0,320 # ffffffffc0206c40 <commands+0x428>
ffffffffc0200b08:	f00ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b0c:	00006517          	auipc	a0,0x6
ffffffffc0200b10:	23450513          	addi	a0,a0,564 # ffffffffc0206d40 <commands+0x528>
ffffffffc0200b14:	b741                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b16:	00006517          	auipc	a0,0x6
ffffffffc0200b1a:	24a50513          	addi	a0,a0,586 # ffffffffc0206d60 <commands+0x548>
ffffffffc0200b1e:	bf9d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b20:	00006517          	auipc	a0,0x6
ffffffffc0200b24:	26050513          	addi	a0,a0,608 # ffffffffc0206d80 <commands+0x568>
ffffffffc0200b28:	b7b5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b2a:	00006517          	auipc	a0,0x6
ffffffffc0200b2e:	26e50513          	addi	a0,a0,622 # ffffffffc0206d98 <commands+0x580>
ffffffffc0200b32:	d9aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b36:	6458                	ld	a4,136(s0)
ffffffffc0200b38:	47a9                	li	a5,10
ffffffffc0200b3a:	f8f719e3          	bne	a4,a5,ffffffffc0200acc <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b3e:	10843783          	ld	a5,264(s0)
ffffffffc0200b42:	0791                	addi	a5,a5,4
ffffffffc0200b44:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b48:	4fa050ef          	jal	ra,ffffffffc0206042 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4c:	000b2797          	auipc	a5,0xb2
ffffffffc0200b50:	dfc7b783          	ld	a5,-516(a5) # ffffffffc02b2948 <current>
ffffffffc0200b54:	6b9c                	ld	a5,16(a5)
ffffffffc0200b56:	8522                	mv	a0,s0
}
ffffffffc0200b58:	6442                	ld	s0,16(sp)
ffffffffc0200b5a:	60e2                	ld	ra,24(sp)
ffffffffc0200b5c:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b5e:	6589                	lui	a1,0x2
ffffffffc0200b60:	95be                	add	a1,a1,a5
}
ffffffffc0200b62:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b64:	ac19                	j	ffffffffc0200d7a <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b66:	00006517          	auipc	a0,0x6
ffffffffc0200b6a:	24250513          	addi	a0,a0,578 # ffffffffc0206da8 <commands+0x590>
ffffffffc0200b6e:	b71d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b70:	00006517          	auipc	a0,0x6
ffffffffc0200b74:	25850513          	addi	a0,a0,600 # ffffffffc0206dc8 <commands+0x5b0>
ffffffffc0200b78:	d54ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b7c:	8522                	mv	a0,s0
ffffffffc0200b7e:	d1bff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200b82:	84aa                	mv	s1,a0
ffffffffc0200b84:	d521                	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b86:	8522                	mv	a0,s0
ffffffffc0200b88:	cafff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b8c:	86a6                	mv	a3,s1
ffffffffc0200b8e:	00006617          	auipc	a2,0x6
ffffffffc0200b92:	25260613          	addi	a2,a2,594 # ffffffffc0206de0 <commands+0x5c8>
ffffffffc0200b96:	0cd00593          	li	a1,205
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	0a650513          	addi	a0,a0,166 # ffffffffc0206c40 <commands+0x428>
ffffffffc0200ba2:	e66ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200ba6:	00006517          	auipc	a0,0x6
ffffffffc0200baa:	27250513          	addi	a0,a0,626 # ffffffffc0206e18 <commands+0x600>
ffffffffc0200bae:	d1eff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb2:	8522                	mv	a0,s0
ffffffffc0200bb4:	ce5ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200bb8:	84aa                	mv	s1,a0
ffffffffc0200bba:	f00509e3          	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bbe:	8522                	mv	a0,s0
ffffffffc0200bc0:	c77ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bc4:	86a6                	mv	a3,s1
ffffffffc0200bc6:	00006617          	auipc	a2,0x6
ffffffffc0200bca:	21a60613          	addi	a2,a2,538 # ffffffffc0206de0 <commands+0x5c8>
ffffffffc0200bce:	0d700593          	li	a1,215
ffffffffc0200bd2:	00006517          	auipc	a0,0x6
ffffffffc0200bd6:	06e50513          	addi	a0,a0,110 # ffffffffc0206c40 <commands+0x428>
ffffffffc0200bda:	e2eff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc0200bde:	8522                	mv	a0,s0
}
ffffffffc0200be0:	6442                	ld	s0,16(sp)
ffffffffc0200be2:	60e2                	ld	ra,24(sp)
ffffffffc0200be4:	64a2                	ld	s1,8(sp)
ffffffffc0200be6:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200be8:	b1b9                	j	ffffffffc0200836 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bea:	00006617          	auipc	a2,0x6
ffffffffc0200bee:	21660613          	addi	a2,a2,534 # ffffffffc0206e00 <commands+0x5e8>
ffffffffc0200bf2:	0d100593          	li	a1,209
ffffffffc0200bf6:	00006517          	auipc	a0,0x6
ffffffffc0200bfa:	04a50513          	addi	a0,a0,74 # ffffffffc0206c40 <commands+0x428>
ffffffffc0200bfe:	e0aff0ef          	jal	ra,ffffffffc0200208 <__panic>
                print_trapframe(tf);
ffffffffc0200c02:	8522                	mv	a0,s0
ffffffffc0200c04:	c33ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c08:	86a6                	mv	a3,s1
ffffffffc0200c0a:	00006617          	auipc	a2,0x6
ffffffffc0200c0e:	1d660613          	addi	a2,a2,470 # ffffffffc0206de0 <commands+0x5c8>
ffffffffc0200c12:	0f100593          	li	a1,241
ffffffffc0200c16:	00006517          	auipc	a0,0x6
ffffffffc0200c1a:	02a50513          	addi	a0,a0,42 # ffffffffc0206c40 <commands+0x428>
ffffffffc0200c1e:	deaff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200c22 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c22:	1101                	addi	sp,sp,-32
ffffffffc0200c24:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c26:	000b2417          	auipc	s0,0xb2
ffffffffc0200c2a:	d2240413          	addi	s0,s0,-734 # ffffffffc02b2948 <current>
ffffffffc0200c2e:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c30:	ec06                	sd	ra,24(sp)
ffffffffc0200c32:	e426                	sd	s1,8(sp)
ffffffffc0200c34:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c36:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c3a:	cf1d                	beqz	a4,ffffffffc0200c78 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c3c:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c40:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c44:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c46:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c4a:	0206c463          	bltz	a3,ffffffffc0200c72 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c4e:	df7ff0ef          	jal	ra,ffffffffc0200a44 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c52:	601c                	ld	a5,0(s0)
ffffffffc0200c54:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c58:	e499                	bnez	s1,ffffffffc0200c66 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c5a:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c5e:	8b05                	andi	a4,a4,1
ffffffffc0200c60:	e329                	bnez	a4,ffffffffc0200ca2 <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c62:	6f9c                	ld	a5,24(a5)
ffffffffc0200c64:	eb85                	bnez	a5,ffffffffc0200c94 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c66:	60e2                	ld	ra,24(sp)
ffffffffc0200c68:	6442                	ld	s0,16(sp)
ffffffffc0200c6a:	64a2                	ld	s1,8(sp)
ffffffffc0200c6c:	6902                	ld	s2,0(sp)
ffffffffc0200c6e:	6105                	addi	sp,sp,32
ffffffffc0200c70:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c72:	d41ff0ef          	jal	ra,ffffffffc02009b2 <interrupt_handler>
ffffffffc0200c76:	bff1                	j	ffffffffc0200c52 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c78:	0006c863          	bltz	a3,ffffffffc0200c88 <trap+0x66>
}
ffffffffc0200c7c:	6442                	ld	s0,16(sp)
ffffffffc0200c7e:	60e2                	ld	ra,24(sp)
ffffffffc0200c80:	64a2                	ld	s1,8(sp)
ffffffffc0200c82:	6902                	ld	s2,0(sp)
ffffffffc0200c84:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c86:	bb7d                	j	ffffffffc0200a44 <exception_handler>
}
ffffffffc0200c88:	6442                	ld	s0,16(sp)
ffffffffc0200c8a:	60e2                	ld	ra,24(sp)
ffffffffc0200c8c:	64a2                	ld	s1,8(sp)
ffffffffc0200c8e:	6902                	ld	s2,0(sp)
ffffffffc0200c90:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c92:	b305                	j	ffffffffc02009b2 <interrupt_handler>
}
ffffffffc0200c94:	6442                	ld	s0,16(sp)
ffffffffc0200c96:	60e2                	ld	ra,24(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c9e:	2b80506f          	j	ffffffffc0205f56 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ca2:	555d                	li	a0,-9
ffffffffc0200ca4:	666040ef          	jal	ra,ffffffffc020530a <do_exit>
            if (current->need_resched) {
ffffffffc0200ca8:	601c                	ld	a5,0(s0)
ffffffffc0200caa:	bf65                	j	ffffffffc0200c62 <trap+0x40>

ffffffffc0200cac <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cac:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cb0:	00011463          	bnez	sp,ffffffffc0200cb8 <__alltraps+0xc>
ffffffffc0200cb4:	14002173          	csrr	sp,sscratch
ffffffffc0200cb8:	712d                	addi	sp,sp,-288
ffffffffc0200cba:	e002                	sd	zero,0(sp)
ffffffffc0200cbc:	e406                	sd	ra,8(sp)
ffffffffc0200cbe:	ec0e                	sd	gp,24(sp)
ffffffffc0200cc0:	f012                	sd	tp,32(sp)
ffffffffc0200cc2:	f416                	sd	t0,40(sp)
ffffffffc0200cc4:	f81a                	sd	t1,48(sp)
ffffffffc0200cc6:	fc1e                	sd	t2,56(sp)
ffffffffc0200cc8:	e0a2                	sd	s0,64(sp)
ffffffffc0200cca:	e4a6                	sd	s1,72(sp)
ffffffffc0200ccc:	e8aa                	sd	a0,80(sp)
ffffffffc0200cce:	ecae                	sd	a1,88(sp)
ffffffffc0200cd0:	f0b2                	sd	a2,96(sp)
ffffffffc0200cd2:	f4b6                	sd	a3,104(sp)
ffffffffc0200cd4:	f8ba                	sd	a4,112(sp)
ffffffffc0200cd6:	fcbe                	sd	a5,120(sp)
ffffffffc0200cd8:	e142                	sd	a6,128(sp)
ffffffffc0200cda:	e546                	sd	a7,136(sp)
ffffffffc0200cdc:	e94a                	sd	s2,144(sp)
ffffffffc0200cde:	ed4e                	sd	s3,152(sp)
ffffffffc0200ce0:	f152                	sd	s4,160(sp)
ffffffffc0200ce2:	f556                	sd	s5,168(sp)
ffffffffc0200ce4:	f95a                	sd	s6,176(sp)
ffffffffc0200ce6:	fd5e                	sd	s7,184(sp)
ffffffffc0200ce8:	e1e2                	sd	s8,192(sp)
ffffffffc0200cea:	e5e6                	sd	s9,200(sp)
ffffffffc0200cec:	e9ea                	sd	s10,208(sp)
ffffffffc0200cee:	edee                	sd	s11,216(sp)
ffffffffc0200cf0:	f1f2                	sd	t3,224(sp)
ffffffffc0200cf2:	f5f6                	sd	t4,232(sp)
ffffffffc0200cf4:	f9fa                	sd	t5,240(sp)
ffffffffc0200cf6:	fdfe                	sd	t6,248(sp)
ffffffffc0200cf8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cfc:	100024f3          	csrr	s1,sstatus
ffffffffc0200d00:	14102973          	csrr	s2,sepc
ffffffffc0200d04:	143029f3          	csrr	s3,stval
ffffffffc0200d08:	14202a73          	csrr	s4,scause
ffffffffc0200d0c:	e822                	sd	s0,16(sp)
ffffffffc0200d0e:	e226                	sd	s1,256(sp)
ffffffffc0200d10:	e64a                	sd	s2,264(sp)
ffffffffc0200d12:	ea4e                	sd	s3,272(sp)
ffffffffc0200d14:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d16:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d18:	f0bff0ef          	jal	ra,ffffffffc0200c22 <trap>

ffffffffc0200d1c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d1c:	6492                	ld	s1,256(sp)
ffffffffc0200d1e:	6932                	ld	s2,264(sp)
ffffffffc0200d20:	1004f413          	andi	s0,s1,256
ffffffffc0200d24:	e401                	bnez	s0,ffffffffc0200d2c <__trapret+0x10>
ffffffffc0200d26:	1200                	addi	s0,sp,288
ffffffffc0200d28:	14041073          	csrw	sscratch,s0
ffffffffc0200d2c:	10049073          	csrw	sstatus,s1
ffffffffc0200d30:	14191073          	csrw	sepc,s2
ffffffffc0200d34:	60a2                	ld	ra,8(sp)
ffffffffc0200d36:	61e2                	ld	gp,24(sp)
ffffffffc0200d38:	7202                	ld	tp,32(sp)
ffffffffc0200d3a:	72a2                	ld	t0,40(sp)
ffffffffc0200d3c:	7342                	ld	t1,48(sp)
ffffffffc0200d3e:	73e2                	ld	t2,56(sp)
ffffffffc0200d40:	6406                	ld	s0,64(sp)
ffffffffc0200d42:	64a6                	ld	s1,72(sp)
ffffffffc0200d44:	6546                	ld	a0,80(sp)
ffffffffc0200d46:	65e6                	ld	a1,88(sp)
ffffffffc0200d48:	7606                	ld	a2,96(sp)
ffffffffc0200d4a:	76a6                	ld	a3,104(sp)
ffffffffc0200d4c:	7746                	ld	a4,112(sp)
ffffffffc0200d4e:	77e6                	ld	a5,120(sp)
ffffffffc0200d50:	680a                	ld	a6,128(sp)
ffffffffc0200d52:	68aa                	ld	a7,136(sp)
ffffffffc0200d54:	694a                	ld	s2,144(sp)
ffffffffc0200d56:	69ea                	ld	s3,152(sp)
ffffffffc0200d58:	7a0a                	ld	s4,160(sp)
ffffffffc0200d5a:	7aaa                	ld	s5,168(sp)
ffffffffc0200d5c:	7b4a                	ld	s6,176(sp)
ffffffffc0200d5e:	7bea                	ld	s7,184(sp)
ffffffffc0200d60:	6c0e                	ld	s8,192(sp)
ffffffffc0200d62:	6cae                	ld	s9,200(sp)
ffffffffc0200d64:	6d4e                	ld	s10,208(sp)
ffffffffc0200d66:	6dee                	ld	s11,216(sp)
ffffffffc0200d68:	7e0e                	ld	t3,224(sp)
ffffffffc0200d6a:	7eae                	ld	t4,232(sp)
ffffffffc0200d6c:	7f4e                	ld	t5,240(sp)
ffffffffc0200d6e:	7fee                	ld	t6,248(sp)
ffffffffc0200d70:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d72:	10200073          	sret

ffffffffc0200d76 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d76:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d78:	b755                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200d7a <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d7a:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7ce0>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d7e:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d82:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d86:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d8a:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d8e:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d92:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d96:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d9a:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d9e:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200da0:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200da2:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200da4:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200da6:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200da8:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200daa:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dac:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dae:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200db0:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200db2:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200db4:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200db6:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200db8:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dba:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dbc:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dbe:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200dc0:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dc2:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200dc4:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dc6:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dc8:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dca:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200dcc:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dce:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dd0:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dd2:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200dd4:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dd6:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dd8:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dda:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200ddc:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dde:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200de0:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200de2:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200de4:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200de6:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200de8:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dea:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dec:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dee:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200df0:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200df2:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200df4:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200df6:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200df8:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dfa:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200dfc:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200dfe:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e00:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e02:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e04:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e06:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e08:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e0a:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e0c:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e0e:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e10:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e12:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e14:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e16:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e18:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e1a:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e1c:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e1e:	812e                	mv	sp,a1
ffffffffc0200e20:	bdf5                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200e22 <pa2page.part.0>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200e22:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200e24:	00006617          	auipc	a2,0x6
ffffffffc0200e28:	0f460613          	addi	a2,a2,244 # ffffffffc0206f18 <commands+0x700>
ffffffffc0200e2c:	06200593          	li	a1,98
ffffffffc0200e30:	00006517          	auipc	a0,0x6
ffffffffc0200e34:	10850513          	addi	a0,a0,264 # ffffffffc0206f38 <commands+0x720>
pa2page(uintptr_t pa) {
ffffffffc0200e38:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200e3a:	bceff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200e3e <pte2page.part.0>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
ffffffffc0200e3e:	1141                	addi	sp,sp,-16
    if (!(pte & PTE_V)) {
        panic("pte2page called with invalid pte");
ffffffffc0200e40:	00006617          	auipc	a2,0x6
ffffffffc0200e44:	10860613          	addi	a2,a2,264 # ffffffffc0206f48 <commands+0x730>
ffffffffc0200e48:	07400593          	li	a1,116
ffffffffc0200e4c:	00006517          	auipc	a0,0x6
ffffffffc0200e50:	0ec50513          	addi	a0,a0,236 # ffffffffc0206f38 <commands+0x720>
pte2page(pte_t pte) {
ffffffffc0200e54:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0200e56:	bb2ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200e5a <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200e5a:	7139                	addi	sp,sp,-64
ffffffffc0200e5c:	f426                	sd	s1,40(sp)
ffffffffc0200e5e:	f04a                	sd	s2,32(sp)
ffffffffc0200e60:	ec4e                	sd	s3,24(sp)
ffffffffc0200e62:	e852                	sd	s4,16(sp)
ffffffffc0200e64:	e456                	sd	s5,8(sp)
ffffffffc0200e66:	e05a                	sd	s6,0(sp)
ffffffffc0200e68:	fc06                	sd	ra,56(sp)
ffffffffc0200e6a:	f822                	sd	s0,48(sp)
ffffffffc0200e6c:	84aa                	mv	s1,a0
ffffffffc0200e6e:	000b2917          	auipc	s2,0xb2
ffffffffc0200e72:	a9a90913          	addi	s2,s2,-1382 # ffffffffc02b2908 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e76:	4a05                	li	s4,1
ffffffffc0200e78:	000b2a97          	auipc	s5,0xb2
ffffffffc0200e7c:	ac8a8a93          	addi	s5,s5,-1336 # ffffffffc02b2940 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e80:	0005099b          	sext.w	s3,a0
ffffffffc0200e84:	000b2b17          	auipc	s6,0xb2
ffffffffc0200e88:	a94b0b13          	addi	s6,s6,-1388 # ffffffffc02b2918 <check_mm_struct>
ffffffffc0200e8c:	a01d                	j	ffffffffc0200eb2 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200e8e:	00093783          	ld	a5,0(s2)
ffffffffc0200e92:	6f9c                	ld	a5,24(a5)
ffffffffc0200e94:	9782                	jalr	a5
ffffffffc0200e96:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e98:	4601                	li	a2,0
ffffffffc0200e9a:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e9c:	ec0d                	bnez	s0,ffffffffc0200ed6 <alloc_pages+0x7c>
ffffffffc0200e9e:	029a6c63          	bltu	s4,s1,ffffffffc0200ed6 <alloc_pages+0x7c>
ffffffffc0200ea2:	000aa783          	lw	a5,0(s5)
ffffffffc0200ea6:	2781                	sext.w	a5,a5
ffffffffc0200ea8:	c79d                	beqz	a5,ffffffffc0200ed6 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200eaa:	000b3503          	ld	a0,0(s6)
ffffffffc0200eae:	096030ef          	jal	ra,ffffffffc0203f44 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200eb2:	100027f3          	csrr	a5,sstatus
ffffffffc0200eb6:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200eb8:	8526                	mv	a0,s1
ffffffffc0200eba:	dbf1                	beqz	a5,ffffffffc0200e8e <alloc_pages+0x34>
        intr_disable();
ffffffffc0200ebc:	f8cff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0200ec0:	00093783          	ld	a5,0(s2)
ffffffffc0200ec4:	8526                	mv	a0,s1
ffffffffc0200ec6:	6f9c                	ld	a5,24(a5)
ffffffffc0200ec8:	9782                	jalr	a5
ffffffffc0200eca:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200ecc:	f76ff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ed0:	4601                	li	a2,0
ffffffffc0200ed2:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200ed4:	d469                	beqz	s0,ffffffffc0200e9e <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200ed6:	70e2                	ld	ra,56(sp)
ffffffffc0200ed8:	8522                	mv	a0,s0
ffffffffc0200eda:	7442                	ld	s0,48(sp)
ffffffffc0200edc:	74a2                	ld	s1,40(sp)
ffffffffc0200ede:	7902                	ld	s2,32(sp)
ffffffffc0200ee0:	69e2                	ld	s3,24(sp)
ffffffffc0200ee2:	6a42                	ld	s4,16(sp)
ffffffffc0200ee4:	6aa2                	ld	s5,8(sp)
ffffffffc0200ee6:	6b02                	ld	s6,0(sp)
ffffffffc0200ee8:	6121                	addi	sp,sp,64
ffffffffc0200eea:	8082                	ret

ffffffffc0200eec <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200eec:	100027f3          	csrr	a5,sstatus
ffffffffc0200ef0:	8b89                	andi	a5,a5,2
ffffffffc0200ef2:	e799                	bnez	a5,ffffffffc0200f00 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200ef4:	000b2797          	auipc	a5,0xb2
ffffffffc0200ef8:	a147b783          	ld	a5,-1516(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc0200efc:	739c                	ld	a5,32(a5)
ffffffffc0200efe:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200f00:	1101                	addi	sp,sp,-32
ffffffffc0200f02:	ec06                	sd	ra,24(sp)
ffffffffc0200f04:	e822                	sd	s0,16(sp)
ffffffffc0200f06:	e426                	sd	s1,8(sp)
ffffffffc0200f08:	842a                	mv	s0,a0
ffffffffc0200f0a:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200f0c:	f3cff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200f10:	000b2797          	auipc	a5,0xb2
ffffffffc0200f14:	9f87b783          	ld	a5,-1544(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc0200f18:	739c                	ld	a5,32(a5)
ffffffffc0200f1a:	85a6                	mv	a1,s1
ffffffffc0200f1c:	8522                	mv	a0,s0
ffffffffc0200f1e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200f20:	6442                	ld	s0,16(sp)
ffffffffc0200f22:	60e2                	ld	ra,24(sp)
ffffffffc0200f24:	64a2                	ld	s1,8(sp)
ffffffffc0200f26:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f28:	f1aff06f          	j	ffffffffc0200642 <intr_enable>

ffffffffc0200f2c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f2c:	100027f3          	csrr	a5,sstatus
ffffffffc0200f30:	8b89                	andi	a5,a5,2
ffffffffc0200f32:	e799                	bnez	a5,ffffffffc0200f40 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f34:	000b2797          	auipc	a5,0xb2
ffffffffc0200f38:	9d47b783          	ld	a5,-1580(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc0200f3c:	779c                	ld	a5,40(a5)
ffffffffc0200f3e:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200f40:	1141                	addi	sp,sp,-16
ffffffffc0200f42:	e406                	sd	ra,8(sp)
ffffffffc0200f44:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200f46:	f02ff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f4a:	000b2797          	auipc	a5,0xb2
ffffffffc0200f4e:	9be7b783          	ld	a5,-1602(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc0200f52:	779c                	ld	a5,40(a5)
ffffffffc0200f54:	9782                	jalr	a5
ffffffffc0200f56:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200f58:	eeaff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200f5c:	60a2                	ld	ra,8(sp)
ffffffffc0200f5e:	8522                	mv	a0,s0
ffffffffc0200f60:	6402                	ld	s0,0(sp)
ffffffffc0200f62:	0141                	addi	sp,sp,16
ffffffffc0200f64:	8082                	ret

ffffffffc0200f66 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f66:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0200f6a:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f6e:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f70:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f72:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f74:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f78:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f7a:	f04a                	sd	s2,32(sp)
ffffffffc0200f7c:	ec4e                	sd	s3,24(sp)
ffffffffc0200f7e:	e852                	sd	s4,16(sp)
ffffffffc0200f80:	fc06                	sd	ra,56(sp)
ffffffffc0200f82:	f822                	sd	s0,48(sp)
ffffffffc0200f84:	e456                	sd	s5,8(sp)
ffffffffc0200f86:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f88:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f8c:	892e                	mv	s2,a1
ffffffffc0200f8e:	89b2                	mv	s3,a2
ffffffffc0200f90:	000b2a17          	auipc	s4,0xb2
ffffffffc0200f94:	968a0a13          	addi	s4,s4,-1688 # ffffffffc02b28f8 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f98:	e7b5                	bnez	a5,ffffffffc0201004 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200f9a:	12060b63          	beqz	a2,ffffffffc02010d0 <get_pte+0x16a>
ffffffffc0200f9e:	4505                	li	a0,1
ffffffffc0200fa0:	ebbff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0200fa4:	842a                	mv	s0,a0
ffffffffc0200fa6:	12050563          	beqz	a0,ffffffffc02010d0 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200faa:	000b2b17          	auipc	s6,0xb2
ffffffffc0200fae:	956b0b13          	addi	s6,s6,-1706 # ffffffffc02b2900 <pages>
ffffffffc0200fb2:	000b3503          	ld	a0,0(s6)
ffffffffc0200fb6:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200fba:	000b2a17          	auipc	s4,0xb2
ffffffffc0200fbe:	93ea0a13          	addi	s4,s4,-1730 # ffffffffc02b28f8 <npage>
ffffffffc0200fc2:	40a40533          	sub	a0,s0,a0
ffffffffc0200fc6:	8519                	srai	a0,a0,0x6
ffffffffc0200fc8:	9556                	add	a0,a0,s5
ffffffffc0200fca:	000a3703          	ld	a4,0(s4)
ffffffffc0200fce:	00c51793          	slli	a5,a0,0xc
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200fd2:	4685                	li	a3,1
ffffffffc0200fd4:	c014                	sw	a3,0(s0)
ffffffffc0200fd6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fd8:	0532                	slli	a0,a0,0xc
ffffffffc0200fda:	14e7f263          	bgeu	a5,a4,ffffffffc020111e <get_pte+0x1b8>
ffffffffc0200fde:	000b2797          	auipc	a5,0xb2
ffffffffc0200fe2:	9327b783          	ld	a5,-1742(a5) # ffffffffc02b2910 <va_pa_offset>
ffffffffc0200fe6:	6605                	lui	a2,0x1
ffffffffc0200fe8:	4581                	li	a1,0
ffffffffc0200fea:	953e                	add	a0,a0,a5
ffffffffc0200fec:	152050ef          	jal	ra,ffffffffc020613e <memset>
    return page - pages + nbase;
ffffffffc0200ff0:	000b3683          	ld	a3,0(s6)
ffffffffc0200ff4:	40d406b3          	sub	a3,s0,a3
ffffffffc0200ff8:	8699                	srai	a3,a3,0x6
ffffffffc0200ffa:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200ffc:	06aa                	slli	a3,a3,0xa
ffffffffc0200ffe:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201002:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201004:	77fd                	lui	a5,0xfffff
ffffffffc0201006:	068a                	slli	a3,a3,0x2
ffffffffc0201008:	000a3703          	ld	a4,0(s4)
ffffffffc020100c:	8efd                	and	a3,a3,a5
ffffffffc020100e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201012:	0ce7f163          	bgeu	a5,a4,ffffffffc02010d4 <get_pte+0x16e>
ffffffffc0201016:	000b2a97          	auipc	s5,0xb2
ffffffffc020101a:	8faa8a93          	addi	s5,s5,-1798 # ffffffffc02b2910 <va_pa_offset>
ffffffffc020101e:	000ab403          	ld	s0,0(s5)
ffffffffc0201022:	01595793          	srli	a5,s2,0x15
ffffffffc0201026:	1ff7f793          	andi	a5,a5,511
ffffffffc020102a:	96a2                	add	a3,a3,s0
ffffffffc020102c:	00379413          	slli	s0,a5,0x3
ffffffffc0201030:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201032:	6014                	ld	a3,0(s0)
ffffffffc0201034:	0016f793          	andi	a5,a3,1
ffffffffc0201038:	e3ad                	bnez	a5,ffffffffc020109a <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc020103a:	08098b63          	beqz	s3,ffffffffc02010d0 <get_pte+0x16a>
ffffffffc020103e:	4505                	li	a0,1
ffffffffc0201040:	e1bff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0201044:	84aa                	mv	s1,a0
ffffffffc0201046:	c549                	beqz	a0,ffffffffc02010d0 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201048:	000b2b17          	auipc	s6,0xb2
ffffffffc020104c:	8b8b0b13          	addi	s6,s6,-1864 # ffffffffc02b2900 <pages>
ffffffffc0201050:	000b3503          	ld	a0,0(s6)
ffffffffc0201054:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201058:	000a3703          	ld	a4,0(s4)
ffffffffc020105c:	40a48533          	sub	a0,s1,a0
ffffffffc0201060:	8519                	srai	a0,a0,0x6
ffffffffc0201062:	954e                	add	a0,a0,s3
ffffffffc0201064:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201068:	4685                	li	a3,1
ffffffffc020106a:	c094                	sw	a3,0(s1)
ffffffffc020106c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020106e:	0532                	slli	a0,a0,0xc
ffffffffc0201070:	08e7fa63          	bgeu	a5,a4,ffffffffc0201104 <get_pte+0x19e>
ffffffffc0201074:	000ab783          	ld	a5,0(s5)
ffffffffc0201078:	6605                	lui	a2,0x1
ffffffffc020107a:	4581                	li	a1,0
ffffffffc020107c:	953e                	add	a0,a0,a5
ffffffffc020107e:	0c0050ef          	jal	ra,ffffffffc020613e <memset>
    return page - pages + nbase;
ffffffffc0201082:	000b3683          	ld	a3,0(s6)
ffffffffc0201086:	40d486b3          	sub	a3,s1,a3
ffffffffc020108a:	8699                	srai	a3,a3,0x6
ffffffffc020108c:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020108e:	06aa                	slli	a3,a3,0xa
ffffffffc0201090:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201094:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201096:	000a3703          	ld	a4,0(s4)
ffffffffc020109a:	068a                	slli	a3,a3,0x2
ffffffffc020109c:	757d                	lui	a0,0xfffff
ffffffffc020109e:	8ee9                	and	a3,a3,a0
ffffffffc02010a0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02010a4:	04e7f463          	bgeu	a5,a4,ffffffffc02010ec <get_pte+0x186>
ffffffffc02010a8:	000ab503          	ld	a0,0(s5)
ffffffffc02010ac:	00c95913          	srli	s2,s2,0xc
ffffffffc02010b0:	1ff97913          	andi	s2,s2,511
ffffffffc02010b4:	96aa                	add	a3,a3,a0
ffffffffc02010b6:	00391513          	slli	a0,s2,0x3
ffffffffc02010ba:	9536                	add	a0,a0,a3
}
ffffffffc02010bc:	70e2                	ld	ra,56(sp)
ffffffffc02010be:	7442                	ld	s0,48(sp)
ffffffffc02010c0:	74a2                	ld	s1,40(sp)
ffffffffc02010c2:	7902                	ld	s2,32(sp)
ffffffffc02010c4:	69e2                	ld	s3,24(sp)
ffffffffc02010c6:	6a42                	ld	s4,16(sp)
ffffffffc02010c8:	6aa2                	ld	s5,8(sp)
ffffffffc02010ca:	6b02                	ld	s6,0(sp)
ffffffffc02010cc:	6121                	addi	sp,sp,64
ffffffffc02010ce:	8082                	ret
            return NULL;
ffffffffc02010d0:	4501                	li	a0,0
ffffffffc02010d2:	b7ed                	j	ffffffffc02010bc <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02010d4:	00006617          	auipc	a2,0x6
ffffffffc02010d8:	e9c60613          	addi	a2,a2,-356 # ffffffffc0206f70 <commands+0x758>
ffffffffc02010dc:	0e300593          	li	a1,227
ffffffffc02010e0:	00006517          	auipc	a0,0x6
ffffffffc02010e4:	eb850513          	addi	a0,a0,-328 # ffffffffc0206f98 <commands+0x780>
ffffffffc02010e8:	920ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02010ec:	00006617          	auipc	a2,0x6
ffffffffc02010f0:	e8460613          	addi	a2,a2,-380 # ffffffffc0206f70 <commands+0x758>
ffffffffc02010f4:	0ee00593          	li	a1,238
ffffffffc02010f8:	00006517          	auipc	a0,0x6
ffffffffc02010fc:	ea050513          	addi	a0,a0,-352 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201100:	908ff0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201104:	86aa                	mv	a3,a0
ffffffffc0201106:	00006617          	auipc	a2,0x6
ffffffffc020110a:	e6a60613          	addi	a2,a2,-406 # ffffffffc0206f70 <commands+0x758>
ffffffffc020110e:	0eb00593          	li	a1,235
ffffffffc0201112:	00006517          	auipc	a0,0x6
ffffffffc0201116:	e8650513          	addi	a0,a0,-378 # ffffffffc0206f98 <commands+0x780>
ffffffffc020111a:	8eeff0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020111e:	86aa                	mv	a3,a0
ffffffffc0201120:	00006617          	auipc	a2,0x6
ffffffffc0201124:	e5060613          	addi	a2,a2,-432 # ffffffffc0206f70 <commands+0x758>
ffffffffc0201128:	0df00593          	li	a1,223
ffffffffc020112c:	00006517          	auipc	a0,0x6
ffffffffc0201130:	e6c50513          	addi	a0,a0,-404 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201134:	8d4ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201138 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201138:	1141                	addi	sp,sp,-16
ffffffffc020113a:	e022                	sd	s0,0(sp)
ffffffffc020113c:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020113e:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201140:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201142:	e25ff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201146:	c011                	beqz	s0,ffffffffc020114a <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201148:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020114a:	c511                	beqz	a0,ffffffffc0201156 <get_page+0x1e>
ffffffffc020114c:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020114e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201150:	0017f713          	andi	a4,a5,1
ffffffffc0201154:	e709                	bnez	a4,ffffffffc020115e <get_page+0x26>
}
ffffffffc0201156:	60a2                	ld	ra,8(sp)
ffffffffc0201158:	6402                	ld	s0,0(sp)
ffffffffc020115a:	0141                	addi	sp,sp,16
ffffffffc020115c:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020115e:	078a                	slli	a5,a5,0x2
ffffffffc0201160:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201162:	000b1717          	auipc	a4,0xb1
ffffffffc0201166:	79673703          	ld	a4,1942(a4) # ffffffffc02b28f8 <npage>
ffffffffc020116a:	00e7ff63          	bgeu	a5,a4,ffffffffc0201188 <get_page+0x50>
ffffffffc020116e:	60a2                	ld	ra,8(sp)
ffffffffc0201170:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201172:	fff80537          	lui	a0,0xfff80
ffffffffc0201176:	97aa                	add	a5,a5,a0
ffffffffc0201178:	079a                	slli	a5,a5,0x6
ffffffffc020117a:	000b1517          	auipc	a0,0xb1
ffffffffc020117e:	78653503          	ld	a0,1926(a0) # ffffffffc02b2900 <pages>
ffffffffc0201182:	953e                	add	a0,a0,a5
ffffffffc0201184:	0141                	addi	sp,sp,16
ffffffffc0201186:	8082                	ret
ffffffffc0201188:	c9bff0ef          	jal	ra,ffffffffc0200e22 <pa2page.part.0>

ffffffffc020118c <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020118c:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020118e:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201192:	f486                	sd	ra,104(sp)
ffffffffc0201194:	f0a2                	sd	s0,96(sp)
ffffffffc0201196:	eca6                	sd	s1,88(sp)
ffffffffc0201198:	e8ca                	sd	s2,80(sp)
ffffffffc020119a:	e4ce                	sd	s3,72(sp)
ffffffffc020119c:	e0d2                	sd	s4,64(sp)
ffffffffc020119e:	fc56                	sd	s5,56(sp)
ffffffffc02011a0:	f85a                	sd	s6,48(sp)
ffffffffc02011a2:	f45e                	sd	s7,40(sp)
ffffffffc02011a4:	f062                	sd	s8,32(sp)
ffffffffc02011a6:	ec66                	sd	s9,24(sp)
ffffffffc02011a8:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02011aa:	17d2                	slli	a5,a5,0x34
ffffffffc02011ac:	e3ed                	bnez	a5,ffffffffc020128e <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc02011ae:	002007b7          	lui	a5,0x200
ffffffffc02011b2:	842e                	mv	s0,a1
ffffffffc02011b4:	0ef5ed63          	bltu	a1,a5,ffffffffc02012ae <unmap_range+0x122>
ffffffffc02011b8:	8932                	mv	s2,a2
ffffffffc02011ba:	0ec5fa63          	bgeu	a1,a2,ffffffffc02012ae <unmap_range+0x122>
ffffffffc02011be:	4785                	li	a5,1
ffffffffc02011c0:	07fe                	slli	a5,a5,0x1f
ffffffffc02011c2:	0ec7e663          	bltu	a5,a2,ffffffffc02012ae <unmap_range+0x122>
ffffffffc02011c6:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02011c8:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02011ca:	000b1c97          	auipc	s9,0xb1
ffffffffc02011ce:	72ec8c93          	addi	s9,s9,1838 # ffffffffc02b28f8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02011d2:	000b1c17          	auipc	s8,0xb1
ffffffffc02011d6:	72ec0c13          	addi	s8,s8,1838 # ffffffffc02b2900 <pages>
ffffffffc02011da:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc02011de:	000b1d17          	auipc	s10,0xb1
ffffffffc02011e2:	72ad0d13          	addi	s10,s10,1834 # ffffffffc02b2908 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02011e6:	00200b37          	lui	s6,0x200
ffffffffc02011ea:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02011ee:	4601                	li	a2,0
ffffffffc02011f0:	85a2                	mv	a1,s0
ffffffffc02011f2:	854e                	mv	a0,s3
ffffffffc02011f4:	d73ff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc02011f8:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02011fa:	cd29                	beqz	a0,ffffffffc0201254 <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc02011fc:	611c                	ld	a5,0(a0)
ffffffffc02011fe:	e395                	bnez	a5,ffffffffc0201222 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0201200:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0201202:	ff2466e3          	bltu	s0,s2,ffffffffc02011ee <unmap_range+0x62>
}
ffffffffc0201206:	70a6                	ld	ra,104(sp)
ffffffffc0201208:	7406                	ld	s0,96(sp)
ffffffffc020120a:	64e6                	ld	s1,88(sp)
ffffffffc020120c:	6946                	ld	s2,80(sp)
ffffffffc020120e:	69a6                	ld	s3,72(sp)
ffffffffc0201210:	6a06                	ld	s4,64(sp)
ffffffffc0201212:	7ae2                	ld	s5,56(sp)
ffffffffc0201214:	7b42                	ld	s6,48(sp)
ffffffffc0201216:	7ba2                	ld	s7,40(sp)
ffffffffc0201218:	7c02                	ld	s8,32(sp)
ffffffffc020121a:	6ce2                	ld	s9,24(sp)
ffffffffc020121c:	6d42                	ld	s10,16(sp)
ffffffffc020121e:	6165                	addi	sp,sp,112
ffffffffc0201220:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201222:	0017f713          	andi	a4,a5,1
ffffffffc0201226:	df69                	beqz	a4,ffffffffc0201200 <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc0201228:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020122c:	078a                	slli	a5,a5,0x2
ffffffffc020122e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201230:	08e7ff63          	bgeu	a5,a4,ffffffffc02012ce <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0201234:	000c3503          	ld	a0,0(s8)
ffffffffc0201238:	97de                	add	a5,a5,s7
ffffffffc020123a:	079a                	slli	a5,a5,0x6
ffffffffc020123c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020123e:	411c                	lw	a5,0(a0)
ffffffffc0201240:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201244:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201246:	cf11                	beqz	a4,ffffffffc0201262 <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201248:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020124c:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0201250:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0201252:	bf45                	j	ffffffffc0201202 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201254:	945a                	add	s0,s0,s6
ffffffffc0201256:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc020125a:	d455                	beqz	s0,ffffffffc0201206 <unmap_range+0x7a>
ffffffffc020125c:	f92469e3          	bltu	s0,s2,ffffffffc02011ee <unmap_range+0x62>
ffffffffc0201260:	b75d                	j	ffffffffc0201206 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201262:	100027f3          	csrr	a5,sstatus
ffffffffc0201266:	8b89                	andi	a5,a5,2
ffffffffc0201268:	e799                	bnez	a5,ffffffffc0201276 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc020126a:	000d3783          	ld	a5,0(s10)
ffffffffc020126e:	4585                	li	a1,1
ffffffffc0201270:	739c                	ld	a5,32(a5)
ffffffffc0201272:	9782                	jalr	a5
    if (flag) {
ffffffffc0201274:	bfd1                	j	ffffffffc0201248 <unmap_range+0xbc>
ffffffffc0201276:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201278:	bd0ff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc020127c:	000d3783          	ld	a5,0(s10)
ffffffffc0201280:	6522                	ld	a0,8(sp)
ffffffffc0201282:	4585                	li	a1,1
ffffffffc0201284:	739c                	ld	a5,32(a5)
ffffffffc0201286:	9782                	jalr	a5
        intr_enable();
ffffffffc0201288:	bbaff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020128c:	bf75                	j	ffffffffc0201248 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020128e:	00006697          	auipc	a3,0x6
ffffffffc0201292:	d1a68693          	addi	a3,a3,-742 # ffffffffc0206fa8 <commands+0x790>
ffffffffc0201296:	00006617          	auipc	a2,0x6
ffffffffc020129a:	99260613          	addi	a2,a2,-1646 # ffffffffc0206c28 <commands+0x410>
ffffffffc020129e:	10f00593          	li	a1,271
ffffffffc02012a2:	00006517          	auipc	a0,0x6
ffffffffc02012a6:	cf650513          	addi	a0,a0,-778 # ffffffffc0206f98 <commands+0x780>
ffffffffc02012aa:	f5ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02012ae:	00006697          	auipc	a3,0x6
ffffffffc02012b2:	d2a68693          	addi	a3,a3,-726 # ffffffffc0206fd8 <commands+0x7c0>
ffffffffc02012b6:	00006617          	auipc	a2,0x6
ffffffffc02012ba:	97260613          	addi	a2,a2,-1678 # ffffffffc0206c28 <commands+0x410>
ffffffffc02012be:	11000593          	li	a1,272
ffffffffc02012c2:	00006517          	auipc	a0,0x6
ffffffffc02012c6:	cd650513          	addi	a0,a0,-810 # ffffffffc0206f98 <commands+0x780>
ffffffffc02012ca:	f3ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02012ce:	b55ff0ef          	jal	ra,ffffffffc0200e22 <pa2page.part.0>

ffffffffc02012d2 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02012d2:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012d4:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02012d8:	fc86                	sd	ra,120(sp)
ffffffffc02012da:	f8a2                	sd	s0,112(sp)
ffffffffc02012dc:	f4a6                	sd	s1,104(sp)
ffffffffc02012de:	f0ca                	sd	s2,96(sp)
ffffffffc02012e0:	ecce                	sd	s3,88(sp)
ffffffffc02012e2:	e8d2                	sd	s4,80(sp)
ffffffffc02012e4:	e4d6                	sd	s5,72(sp)
ffffffffc02012e6:	e0da                	sd	s6,64(sp)
ffffffffc02012e8:	fc5e                	sd	s7,56(sp)
ffffffffc02012ea:	f862                	sd	s8,48(sp)
ffffffffc02012ec:	f466                	sd	s9,40(sp)
ffffffffc02012ee:	f06a                	sd	s10,32(sp)
ffffffffc02012f0:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012f2:	17d2                	slli	a5,a5,0x34
ffffffffc02012f4:	20079a63          	bnez	a5,ffffffffc0201508 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc02012f8:	002007b7          	lui	a5,0x200
ffffffffc02012fc:	24f5e463          	bltu	a1,a5,ffffffffc0201544 <exit_range+0x272>
ffffffffc0201300:	8ab2                	mv	s5,a2
ffffffffc0201302:	24c5f163          	bgeu	a1,a2,ffffffffc0201544 <exit_range+0x272>
ffffffffc0201306:	4785                	li	a5,1
ffffffffc0201308:	07fe                	slli	a5,a5,0x1f
ffffffffc020130a:	22c7ed63          	bltu	a5,a2,ffffffffc0201544 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020130e:	c00009b7          	lui	s3,0xc0000
ffffffffc0201312:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0201316:	ffe00937          	lui	s2,0xffe00
ffffffffc020131a:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc020131e:	5cfd                	li	s9,-1
ffffffffc0201320:	8c2a                	mv	s8,a0
ffffffffc0201322:	0125f933          	and	s2,a1,s2
ffffffffc0201326:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc0201328:	000b1d17          	auipc	s10,0xb1
ffffffffc020132c:	5d0d0d13          	addi	s10,s10,1488 # ffffffffc02b28f8 <npage>
    return KADDR(page2pa(page));
ffffffffc0201330:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0201334:	000b1717          	auipc	a4,0xb1
ffffffffc0201338:	5cc70713          	addi	a4,a4,1484 # ffffffffc02b2900 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc020133c:	000b1d97          	auipc	s11,0xb1
ffffffffc0201340:	5ccd8d93          	addi	s11,s11,1484 # ffffffffc02b2908 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0201344:	c0000437          	lui	s0,0xc0000
ffffffffc0201348:	944e                	add	s0,s0,s3
ffffffffc020134a:	8079                	srli	s0,s0,0x1e
ffffffffc020134c:	1ff47413          	andi	s0,s0,511
ffffffffc0201350:	040e                	slli	s0,s0,0x3
ffffffffc0201352:	9462                	add	s0,s0,s8
ffffffffc0201354:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed0>
        if (pde1&PTE_V){
ffffffffc0201358:	001a7793          	andi	a5,s4,1
ffffffffc020135c:	eb99                	bnez	a5,ffffffffc0201372 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc020135e:	12098463          	beqz	s3,ffffffffc0201486 <exit_range+0x1b4>
ffffffffc0201362:	400007b7          	lui	a5,0x40000
ffffffffc0201366:	97ce                	add	a5,a5,s3
ffffffffc0201368:	894e                	mv	s2,s3
ffffffffc020136a:	1159fe63          	bgeu	s3,s5,ffffffffc0201486 <exit_range+0x1b4>
ffffffffc020136e:	89be                	mv	s3,a5
ffffffffc0201370:	bfd1                	j	ffffffffc0201344 <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc0201372:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201376:	0a0a                	slli	s4,s4,0x2
ffffffffc0201378:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc020137c:	1cfa7263          	bgeu	s4,a5,ffffffffc0201540 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201380:	fff80637          	lui	a2,0xfff80
ffffffffc0201384:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0201386:	000806b7          	lui	a3,0x80
ffffffffc020138a:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc020138c:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0201390:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201392:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201394:	18f5fa63          	bgeu	a1,a5,ffffffffc0201528 <exit_range+0x256>
ffffffffc0201398:	000b1817          	auipc	a6,0xb1
ffffffffc020139c:	57880813          	addi	a6,a6,1400 # ffffffffc02b2910 <va_pa_offset>
ffffffffc02013a0:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc02013a4:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc02013a6:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc02013aa:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc02013ac:	00080337          	lui	t1,0x80
ffffffffc02013b0:	6885                	lui	a7,0x1
ffffffffc02013b2:	a819                	j	ffffffffc02013c8 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc02013b4:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc02013b6:	002007b7          	lui	a5,0x200
ffffffffc02013ba:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02013bc:	08090c63          	beqz	s2,ffffffffc0201454 <exit_range+0x182>
ffffffffc02013c0:	09397a63          	bgeu	s2,s3,ffffffffc0201454 <exit_range+0x182>
ffffffffc02013c4:	0f597063          	bgeu	s2,s5,ffffffffc02014a4 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02013c8:	01595493          	srli	s1,s2,0x15
ffffffffc02013cc:	1ff4f493          	andi	s1,s1,511
ffffffffc02013d0:	048e                	slli	s1,s1,0x3
ffffffffc02013d2:	94da                	add	s1,s1,s6
ffffffffc02013d4:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc02013d6:	0017f693          	andi	a3,a5,1
ffffffffc02013da:	dee9                	beqz	a3,ffffffffc02013b4 <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc02013dc:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02013e0:	078a                	slli	a5,a5,0x2
ffffffffc02013e2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02013e4:	14b7fe63          	bgeu	a5,a1,ffffffffc0201540 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02013e8:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc02013ea:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc02013ee:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02013f2:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02013f6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02013f8:	12bef863          	bgeu	t4,a1,ffffffffc0201528 <exit_range+0x256>
ffffffffc02013fc:	00083783          	ld	a5,0(a6)
ffffffffc0201400:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0201402:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc0201406:	629c                	ld	a5,0(a3)
ffffffffc0201408:	8b85                	andi	a5,a5,1
ffffffffc020140a:	f7d5                	bnez	a5,ffffffffc02013b6 <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc020140c:	06a1                	addi	a3,a3,8
ffffffffc020140e:	fed59ce3          	bne	a1,a3,ffffffffc0201406 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0201412:	631c                	ld	a5,0(a4)
ffffffffc0201414:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201416:	100027f3          	csrr	a5,sstatus
ffffffffc020141a:	8b89                	andi	a5,a5,2
ffffffffc020141c:	e7d9                	bnez	a5,ffffffffc02014aa <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc020141e:	000db783          	ld	a5,0(s11)
ffffffffc0201422:	4585                	li	a1,1
ffffffffc0201424:	e032                	sd	a2,0(sp)
ffffffffc0201426:	739c                	ld	a5,32(a5)
ffffffffc0201428:	9782                	jalr	a5
    if (flag) {
ffffffffc020142a:	6602                	ld	a2,0(sp)
ffffffffc020142c:	000b1817          	auipc	a6,0xb1
ffffffffc0201430:	4e480813          	addi	a6,a6,1252 # ffffffffc02b2910 <va_pa_offset>
ffffffffc0201434:	fff80e37          	lui	t3,0xfff80
ffffffffc0201438:	00080337          	lui	t1,0x80
ffffffffc020143c:	6885                	lui	a7,0x1
ffffffffc020143e:	000b1717          	auipc	a4,0xb1
ffffffffc0201442:	4c270713          	addi	a4,a4,1218 # ffffffffc02b2900 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0201446:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc020144a:	002007b7          	lui	a5,0x200
ffffffffc020144e:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0201450:	f60918e3          	bnez	s2,ffffffffc02013c0 <exit_range+0xee>
            if (free_pd0) {
ffffffffc0201454:	f00b85e3          	beqz	s7,ffffffffc020135e <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc0201458:	000d3783          	ld	a5,0(s10)
ffffffffc020145c:	0efa7263          	bgeu	s4,a5,ffffffffc0201540 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201460:	6308                	ld	a0,0(a4)
ffffffffc0201462:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201464:	100027f3          	csrr	a5,sstatus
ffffffffc0201468:	8b89                	andi	a5,a5,2
ffffffffc020146a:	efad                	bnez	a5,ffffffffc02014e4 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc020146c:	000db783          	ld	a5,0(s11)
ffffffffc0201470:	4585                	li	a1,1
ffffffffc0201472:	739c                	ld	a5,32(a5)
ffffffffc0201474:	9782                	jalr	a5
ffffffffc0201476:	000b1717          	auipc	a4,0xb1
ffffffffc020147a:	48a70713          	addi	a4,a4,1162 # ffffffffc02b2900 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020147e:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0201482:	ee0990e3          	bnez	s3,ffffffffc0201362 <exit_range+0x90>
}
ffffffffc0201486:	70e6                	ld	ra,120(sp)
ffffffffc0201488:	7446                	ld	s0,112(sp)
ffffffffc020148a:	74a6                	ld	s1,104(sp)
ffffffffc020148c:	7906                	ld	s2,96(sp)
ffffffffc020148e:	69e6                	ld	s3,88(sp)
ffffffffc0201490:	6a46                	ld	s4,80(sp)
ffffffffc0201492:	6aa6                	ld	s5,72(sp)
ffffffffc0201494:	6b06                	ld	s6,64(sp)
ffffffffc0201496:	7be2                	ld	s7,56(sp)
ffffffffc0201498:	7c42                	ld	s8,48(sp)
ffffffffc020149a:	7ca2                	ld	s9,40(sp)
ffffffffc020149c:	7d02                	ld	s10,32(sp)
ffffffffc020149e:	6de2                	ld	s11,24(sp)
ffffffffc02014a0:	6109                	addi	sp,sp,128
ffffffffc02014a2:	8082                	ret
            if (free_pd0) {
ffffffffc02014a4:	ea0b8fe3          	beqz	s7,ffffffffc0201362 <exit_range+0x90>
ffffffffc02014a8:	bf45                	j	ffffffffc0201458 <exit_range+0x186>
ffffffffc02014aa:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc02014ac:	e42a                	sd	a0,8(sp)
ffffffffc02014ae:	99aff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02014b2:	000db783          	ld	a5,0(s11)
ffffffffc02014b6:	6522                	ld	a0,8(sp)
ffffffffc02014b8:	4585                	li	a1,1
ffffffffc02014ba:	739c                	ld	a5,32(a5)
ffffffffc02014bc:	9782                	jalr	a5
        intr_enable();
ffffffffc02014be:	984ff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02014c2:	6602                	ld	a2,0(sp)
ffffffffc02014c4:	000b1717          	auipc	a4,0xb1
ffffffffc02014c8:	43c70713          	addi	a4,a4,1084 # ffffffffc02b2900 <pages>
ffffffffc02014cc:	6885                	lui	a7,0x1
ffffffffc02014ce:	00080337          	lui	t1,0x80
ffffffffc02014d2:	fff80e37          	lui	t3,0xfff80
ffffffffc02014d6:	000b1817          	auipc	a6,0xb1
ffffffffc02014da:	43a80813          	addi	a6,a6,1082 # ffffffffc02b2910 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02014de:	0004b023          	sd	zero,0(s1)
ffffffffc02014e2:	b7a5                	j	ffffffffc020144a <exit_range+0x178>
ffffffffc02014e4:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc02014e6:	962ff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02014ea:	000db783          	ld	a5,0(s11)
ffffffffc02014ee:	6502                	ld	a0,0(sp)
ffffffffc02014f0:	4585                	li	a1,1
ffffffffc02014f2:	739c                	ld	a5,32(a5)
ffffffffc02014f4:	9782                	jalr	a5
        intr_enable();
ffffffffc02014f6:	94cff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02014fa:	000b1717          	auipc	a4,0xb1
ffffffffc02014fe:	40670713          	addi	a4,a4,1030 # ffffffffc02b2900 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0201502:	00043023          	sd	zero,0(s0)
ffffffffc0201506:	bfb5                	j	ffffffffc0201482 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201508:	00006697          	auipc	a3,0x6
ffffffffc020150c:	aa068693          	addi	a3,a3,-1376 # ffffffffc0206fa8 <commands+0x790>
ffffffffc0201510:	00005617          	auipc	a2,0x5
ffffffffc0201514:	71860613          	addi	a2,a2,1816 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201518:	12000593          	li	a1,288
ffffffffc020151c:	00006517          	auipc	a0,0x6
ffffffffc0201520:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201524:	ce5fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201528:	00006617          	auipc	a2,0x6
ffffffffc020152c:	a4860613          	addi	a2,a2,-1464 # ffffffffc0206f70 <commands+0x758>
ffffffffc0201530:	06900593          	li	a1,105
ffffffffc0201534:	00006517          	auipc	a0,0x6
ffffffffc0201538:	a0450513          	addi	a0,a0,-1532 # ffffffffc0206f38 <commands+0x720>
ffffffffc020153c:	ccdfe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201540:	8e3ff0ef          	jal	ra,ffffffffc0200e22 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0201544:	00006697          	auipc	a3,0x6
ffffffffc0201548:	a9468693          	addi	a3,a3,-1388 # ffffffffc0206fd8 <commands+0x7c0>
ffffffffc020154c:	00005617          	auipc	a2,0x5
ffffffffc0201550:	6dc60613          	addi	a2,a2,1756 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201554:	12100593          	li	a1,289
ffffffffc0201558:	00006517          	auipc	a0,0x6
ffffffffc020155c:	a4050513          	addi	a0,a0,-1472 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201560:	ca9fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201564 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201564:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201566:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201568:	ec26                	sd	s1,24(sp)
ffffffffc020156a:	f406                	sd	ra,40(sp)
ffffffffc020156c:	f022                	sd	s0,32(sp)
ffffffffc020156e:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201570:	9f7ff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
    if (ptep != NULL) {
ffffffffc0201574:	c511                	beqz	a0,ffffffffc0201580 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201576:	611c                	ld	a5,0(a0)
ffffffffc0201578:	842a                	mv	s0,a0
ffffffffc020157a:	0017f713          	andi	a4,a5,1
ffffffffc020157e:	e711                	bnez	a4,ffffffffc020158a <page_remove+0x26>
}
ffffffffc0201580:	70a2                	ld	ra,40(sp)
ffffffffc0201582:	7402                	ld	s0,32(sp)
ffffffffc0201584:	64e2                	ld	s1,24(sp)
ffffffffc0201586:	6145                	addi	sp,sp,48
ffffffffc0201588:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020158a:	078a                	slli	a5,a5,0x2
ffffffffc020158c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020158e:	000b1717          	auipc	a4,0xb1
ffffffffc0201592:	36a73703          	ld	a4,874(a4) # ffffffffc02b28f8 <npage>
ffffffffc0201596:	06e7f363          	bgeu	a5,a4,ffffffffc02015fc <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc020159a:	fff80537          	lui	a0,0xfff80
ffffffffc020159e:	97aa                	add	a5,a5,a0
ffffffffc02015a0:	079a                	slli	a5,a5,0x6
ffffffffc02015a2:	000b1517          	auipc	a0,0xb1
ffffffffc02015a6:	35e53503          	ld	a0,862(a0) # ffffffffc02b2900 <pages>
ffffffffc02015aa:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02015ac:	411c                	lw	a5,0(a0)
ffffffffc02015ae:	fff7871b          	addiw	a4,a5,-1
ffffffffc02015b2:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02015b4:	cb11                	beqz	a4,ffffffffc02015c8 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02015b6:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02015ba:	12048073          	sfence.vma	s1
}
ffffffffc02015be:	70a2                	ld	ra,40(sp)
ffffffffc02015c0:	7402                	ld	s0,32(sp)
ffffffffc02015c2:	64e2                	ld	s1,24(sp)
ffffffffc02015c4:	6145                	addi	sp,sp,48
ffffffffc02015c6:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02015c8:	100027f3          	csrr	a5,sstatus
ffffffffc02015cc:	8b89                	andi	a5,a5,2
ffffffffc02015ce:	eb89                	bnez	a5,ffffffffc02015e0 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc02015d0:	000b1797          	auipc	a5,0xb1
ffffffffc02015d4:	3387b783          	ld	a5,824(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc02015d8:	739c                	ld	a5,32(a5)
ffffffffc02015da:	4585                	li	a1,1
ffffffffc02015dc:	9782                	jalr	a5
    if (flag) {
ffffffffc02015de:	bfe1                	j	ffffffffc02015b6 <page_remove+0x52>
        intr_disable();
ffffffffc02015e0:	e42a                	sd	a0,8(sp)
ffffffffc02015e2:	866ff0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02015e6:	000b1797          	auipc	a5,0xb1
ffffffffc02015ea:	3227b783          	ld	a5,802(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc02015ee:	739c                	ld	a5,32(a5)
ffffffffc02015f0:	6522                	ld	a0,8(sp)
ffffffffc02015f2:	4585                	li	a1,1
ffffffffc02015f4:	9782                	jalr	a5
        intr_enable();
ffffffffc02015f6:	84cff0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02015fa:	bf75                	j	ffffffffc02015b6 <page_remove+0x52>
ffffffffc02015fc:	827ff0ef          	jal	ra,ffffffffc0200e22 <pa2page.part.0>

ffffffffc0201600 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201600:	7139                	addi	sp,sp,-64
ffffffffc0201602:	e852                	sd	s4,16(sp)
ffffffffc0201604:	8a32                	mv	s4,a2
ffffffffc0201606:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201608:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020160a:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020160c:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020160e:	f426                	sd	s1,40(sp)
ffffffffc0201610:	fc06                	sd	ra,56(sp)
ffffffffc0201612:	f04a                	sd	s2,32(sp)
ffffffffc0201614:	ec4e                	sd	s3,24(sp)
ffffffffc0201616:	e456                	sd	s5,8(sp)
ffffffffc0201618:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020161a:	94dff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
    if (ptep == NULL) {
ffffffffc020161e:	c961                	beqz	a0,ffffffffc02016ee <page_insert+0xee>
    page->ref += 1;
ffffffffc0201620:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201622:	611c                	ld	a5,0(a0)
ffffffffc0201624:	89aa                	mv	s3,a0
ffffffffc0201626:	0016871b          	addiw	a4,a3,1
ffffffffc020162a:	c018                	sw	a4,0(s0)
ffffffffc020162c:	0017f713          	andi	a4,a5,1
ffffffffc0201630:	ef05                	bnez	a4,ffffffffc0201668 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0201632:	000b1717          	auipc	a4,0xb1
ffffffffc0201636:	2ce73703          	ld	a4,718(a4) # ffffffffc02b2900 <pages>
ffffffffc020163a:	8c19                	sub	s0,s0,a4
ffffffffc020163c:	000807b7          	lui	a5,0x80
ffffffffc0201640:	8419                	srai	s0,s0,0x6
ffffffffc0201642:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201644:	042a                	slli	s0,s0,0xa
ffffffffc0201646:	8cc1                	or	s1,s1,s0
ffffffffc0201648:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020164c:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201650:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0201654:	4501                	li	a0,0
}
ffffffffc0201656:	70e2                	ld	ra,56(sp)
ffffffffc0201658:	7442                	ld	s0,48(sp)
ffffffffc020165a:	74a2                	ld	s1,40(sp)
ffffffffc020165c:	7902                	ld	s2,32(sp)
ffffffffc020165e:	69e2                	ld	s3,24(sp)
ffffffffc0201660:	6a42                	ld	s4,16(sp)
ffffffffc0201662:	6aa2                	ld	s5,8(sp)
ffffffffc0201664:	6121                	addi	sp,sp,64
ffffffffc0201666:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201668:	078a                	slli	a5,a5,0x2
ffffffffc020166a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020166c:	000b1717          	auipc	a4,0xb1
ffffffffc0201670:	28c73703          	ld	a4,652(a4) # ffffffffc02b28f8 <npage>
ffffffffc0201674:	06e7ff63          	bgeu	a5,a4,ffffffffc02016f2 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0201678:	000b1a97          	auipc	s5,0xb1
ffffffffc020167c:	288a8a93          	addi	s5,s5,648 # ffffffffc02b2900 <pages>
ffffffffc0201680:	000ab703          	ld	a4,0(s5)
ffffffffc0201684:	fff80937          	lui	s2,0xfff80
ffffffffc0201688:	993e                	add	s2,s2,a5
ffffffffc020168a:	091a                	slli	s2,s2,0x6
ffffffffc020168c:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc020168e:	01240c63          	beq	s0,s2,ffffffffc02016a6 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0201692:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd69c>
ffffffffc0201696:	fff7869b          	addiw	a3,a5,-1
ffffffffc020169a:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc020169e:	c691                	beqz	a3,ffffffffc02016aa <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02016a0:	120a0073          	sfence.vma	s4
}
ffffffffc02016a4:	bf59                	j	ffffffffc020163a <page_insert+0x3a>
ffffffffc02016a6:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02016a8:	bf49                	j	ffffffffc020163a <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016aa:	100027f3          	csrr	a5,sstatus
ffffffffc02016ae:	8b89                	andi	a5,a5,2
ffffffffc02016b0:	ef91                	bnez	a5,ffffffffc02016cc <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc02016b2:	000b1797          	auipc	a5,0xb1
ffffffffc02016b6:	2567b783          	ld	a5,598(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc02016ba:	739c                	ld	a5,32(a5)
ffffffffc02016bc:	4585                	li	a1,1
ffffffffc02016be:	854a                	mv	a0,s2
ffffffffc02016c0:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02016c2:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02016c6:	120a0073          	sfence.vma	s4
ffffffffc02016ca:	bf85                	j	ffffffffc020163a <page_insert+0x3a>
        intr_disable();
ffffffffc02016cc:	f7dfe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02016d0:	000b1797          	auipc	a5,0xb1
ffffffffc02016d4:	2387b783          	ld	a5,568(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc02016d8:	739c                	ld	a5,32(a5)
ffffffffc02016da:	4585                	li	a1,1
ffffffffc02016dc:	854a                	mv	a0,s2
ffffffffc02016de:	9782                	jalr	a5
        intr_enable();
ffffffffc02016e0:	f63fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02016e4:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02016e8:	120a0073          	sfence.vma	s4
ffffffffc02016ec:	b7b9                	j	ffffffffc020163a <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02016ee:	5571                	li	a0,-4
ffffffffc02016f0:	b79d                	j	ffffffffc0201656 <page_insert+0x56>
ffffffffc02016f2:	f30ff0ef          	jal	ra,ffffffffc0200e22 <pa2page.part.0>

ffffffffc02016f6 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02016f6:	00007797          	auipc	a5,0x7
ffffffffc02016fa:	ba278793          	addi	a5,a5,-1118 # ffffffffc0208298 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02016fe:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201700:	711d                	addi	sp,sp,-96
ffffffffc0201702:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201704:	00006517          	auipc	a0,0x6
ffffffffc0201708:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0206ff0 <commands+0x7d8>
    pmm_manager = &default_pmm_manager;
ffffffffc020170c:	000b1b97          	auipc	s7,0xb1
ffffffffc0201710:	1fcb8b93          	addi	s7,s7,508 # ffffffffc02b2908 <pmm_manager>
void pmm_init(void) {
ffffffffc0201714:	ec86                	sd	ra,88(sp)
ffffffffc0201716:	e4a6                	sd	s1,72(sp)
ffffffffc0201718:	fc4e                	sd	s3,56(sp)
ffffffffc020171a:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020171c:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201720:	e8a2                	sd	s0,80(sp)
ffffffffc0201722:	e0ca                	sd	s2,64(sp)
ffffffffc0201724:	f852                	sd	s4,48(sp)
ffffffffc0201726:	f456                	sd	s5,40(sp)
ffffffffc0201728:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020172a:	9a3fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc020172e:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201732:	000b1997          	auipc	s3,0xb1
ffffffffc0201736:	1de98993          	addi	s3,s3,478 # ffffffffc02b2910 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc020173a:	000b1497          	auipc	s1,0xb1
ffffffffc020173e:	1be48493          	addi	s1,s1,446 # ffffffffc02b28f8 <npage>
    pmm_manager->init();
ffffffffc0201742:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201744:	000b1b17          	auipc	s6,0xb1
ffffffffc0201748:	1bcb0b13          	addi	s6,s6,444 # ffffffffc02b2900 <pages>
    pmm_manager->init();
ffffffffc020174c:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020174e:	57f5                	li	a5,-3
ffffffffc0201750:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201752:	00006517          	auipc	a0,0x6
ffffffffc0201756:	8b650513          	addi	a0,a0,-1866 # ffffffffc0207008 <commands+0x7f0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020175a:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc020175e:	96ffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201762:	46c5                	li	a3,17
ffffffffc0201764:	06ee                	slli	a3,a3,0x1b
ffffffffc0201766:	40100613          	li	a2,1025
ffffffffc020176a:	07e005b7          	lui	a1,0x7e00
ffffffffc020176e:	16fd                	addi	a3,a3,-1
ffffffffc0201770:	0656                	slli	a2,a2,0x15
ffffffffc0201772:	00006517          	auipc	a0,0x6
ffffffffc0201776:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0207020 <commands+0x808>
ffffffffc020177a:	953fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020177e:	777d                	lui	a4,0xfffff
ffffffffc0201780:	000b2797          	auipc	a5,0xb2
ffffffffc0201784:	1e378793          	addi	a5,a5,483 # ffffffffc02b3963 <end+0xfff>
ffffffffc0201788:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020178a:	00088737          	lui	a4,0x88
ffffffffc020178e:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201790:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201794:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201796:	4585                	li	a1,1
ffffffffc0201798:	fff80837          	lui	a6,0xfff80
ffffffffc020179c:	a019                	j	ffffffffc02017a2 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc020179e:	000b3783          	ld	a5,0(s6)
ffffffffc02017a2:	00671693          	slli	a3,a4,0x6
ffffffffc02017a6:	97b6                	add	a5,a5,a3
ffffffffc02017a8:	07a1                	addi	a5,a5,8
ffffffffc02017aa:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02017ae:	6090                	ld	a2,0(s1)
ffffffffc02017b0:	0705                	addi	a4,a4,1
ffffffffc02017b2:	010607b3          	add	a5,a2,a6
ffffffffc02017b6:	fef764e3          	bltu	a4,a5,ffffffffc020179e <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02017ba:	000b3503          	ld	a0,0(s6)
ffffffffc02017be:	079a                	slli	a5,a5,0x6
ffffffffc02017c0:	c0200737          	lui	a4,0xc0200
ffffffffc02017c4:	00f506b3          	add	a3,a0,a5
ffffffffc02017c8:	60e6e563          	bltu	a3,a4,ffffffffc0201dd2 <pmm_init+0x6dc>
ffffffffc02017cc:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02017d0:	4745                	li	a4,17
ffffffffc02017d2:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02017d4:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02017d6:	4ae6e563          	bltu	a3,a4,ffffffffc0201c80 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02017da:	00006517          	auipc	a0,0x6
ffffffffc02017de:	89650513          	addi	a0,a0,-1898 # ffffffffc0207070 <commands+0x858>
ffffffffc02017e2:	8ebfe0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02017e6:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02017ea:	000b1917          	auipc	s2,0xb1
ffffffffc02017ee:	10690913          	addi	s2,s2,262 # ffffffffc02b28f0 <boot_pgdir>
    pmm_manager->check();
ffffffffc02017f2:	7b9c                	ld	a5,48(a5)
ffffffffc02017f4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02017f6:	00006517          	auipc	a0,0x6
ffffffffc02017fa:	89250513          	addi	a0,a0,-1902 # ffffffffc0207088 <commands+0x870>
ffffffffc02017fe:	8cffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201802:	00009697          	auipc	a3,0x9
ffffffffc0201806:	7fe68693          	addi	a3,a3,2046 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc020180a:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020180e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201812:	5cf6ec63          	bltu	a3,a5,ffffffffc0201dea <pmm_init+0x6f4>
ffffffffc0201816:	0009b783          	ld	a5,0(s3)
ffffffffc020181a:	8e9d                	sub	a3,a3,a5
ffffffffc020181c:	000b1797          	auipc	a5,0xb1
ffffffffc0201820:	0cd7b623          	sd	a3,204(a5) # ffffffffc02b28e8 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201824:	100027f3          	csrr	a5,sstatus
ffffffffc0201828:	8b89                	andi	a5,a5,2
ffffffffc020182a:	48079263          	bnez	a5,ffffffffc0201cae <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc020182e:	000bb783          	ld	a5,0(s7)
ffffffffc0201832:	779c                	ld	a5,40(a5)
ffffffffc0201834:	9782                	jalr	a5
ffffffffc0201836:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201838:	6098                	ld	a4,0(s1)
ffffffffc020183a:	c80007b7          	lui	a5,0xc8000
ffffffffc020183e:	83b1                	srli	a5,a5,0xc
ffffffffc0201840:	5ee7e163          	bltu	a5,a4,ffffffffc0201e22 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201844:	00093503          	ld	a0,0(s2)
ffffffffc0201848:	5a050d63          	beqz	a0,ffffffffc0201e02 <pmm_init+0x70c>
ffffffffc020184c:	03451793          	slli	a5,a0,0x34
ffffffffc0201850:	5a079963          	bnez	a5,ffffffffc0201e02 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201854:	4601                	li	a2,0
ffffffffc0201856:	4581                	li	a1,0
ffffffffc0201858:	8e1ff0ef          	jal	ra,ffffffffc0201138 <get_page>
ffffffffc020185c:	62051563          	bnez	a0,ffffffffc0201e86 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201860:	4505                	li	a0,1
ffffffffc0201862:	df8ff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0201866:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201868:	00093503          	ld	a0,0(s2)
ffffffffc020186c:	4681                	li	a3,0
ffffffffc020186e:	4601                	li	a2,0
ffffffffc0201870:	85d2                	mv	a1,s4
ffffffffc0201872:	d8fff0ef          	jal	ra,ffffffffc0201600 <page_insert>
ffffffffc0201876:	5e051863          	bnez	a0,ffffffffc0201e66 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020187a:	00093503          	ld	a0,0(s2)
ffffffffc020187e:	4601                	li	a2,0
ffffffffc0201880:	4581                	li	a1,0
ffffffffc0201882:	ee4ff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc0201886:	5c050063          	beqz	a0,ffffffffc0201e46 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc020188a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020188c:	0017f713          	andi	a4,a5,1
ffffffffc0201890:	5a070963          	beqz	a4,ffffffffc0201e42 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0201894:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201896:	078a                	slli	a5,a5,0x2
ffffffffc0201898:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020189a:	52e7fa63          	bgeu	a5,a4,ffffffffc0201dce <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020189e:	000b3683          	ld	a3,0(s6)
ffffffffc02018a2:	fff80637          	lui	a2,0xfff80
ffffffffc02018a6:	97b2                	add	a5,a5,a2
ffffffffc02018a8:	079a                	slli	a5,a5,0x6
ffffffffc02018aa:	97b6                	add	a5,a5,a3
ffffffffc02018ac:	10fa16e3          	bne	s4,a5,ffffffffc02021b8 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc02018b0:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc02018b4:	4785                	li	a5,1
ffffffffc02018b6:	12f69de3          	bne	a3,a5,ffffffffc02021f0 <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02018ba:	00093503          	ld	a0,0(s2)
ffffffffc02018be:	77fd                	lui	a5,0xfffff
ffffffffc02018c0:	6114                	ld	a3,0(a0)
ffffffffc02018c2:	068a                	slli	a3,a3,0x2
ffffffffc02018c4:	8efd                	and	a3,a3,a5
ffffffffc02018c6:	00c6d613          	srli	a2,a3,0xc
ffffffffc02018ca:	10e677e3          	bgeu	a2,a4,ffffffffc02021d8 <pmm_init+0xae2>
ffffffffc02018ce:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02018d2:	96e2                	add	a3,a3,s8
ffffffffc02018d4:	0006ba83          	ld	s5,0(a3)
ffffffffc02018d8:	0a8a                	slli	s5,s5,0x2
ffffffffc02018da:	00fafab3          	and	s5,s5,a5
ffffffffc02018de:	00cad793          	srli	a5,s5,0xc
ffffffffc02018e2:	62e7f263          	bgeu	a5,a4,ffffffffc0201f06 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02018e6:	4601                	li	a2,0
ffffffffc02018e8:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02018ea:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02018ec:	e7aff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02018f0:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02018f2:	5f551a63          	bne	a0,s5,ffffffffc0201ee6 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc02018f6:	4505                	li	a0,1
ffffffffc02018f8:	d62ff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02018fc:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02018fe:	00093503          	ld	a0,0(s2)
ffffffffc0201902:	46d1                	li	a3,20
ffffffffc0201904:	6605                	lui	a2,0x1
ffffffffc0201906:	85d6                	mv	a1,s5
ffffffffc0201908:	cf9ff0ef          	jal	ra,ffffffffc0201600 <page_insert>
ffffffffc020190c:	58051d63          	bnez	a0,ffffffffc0201ea6 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201910:	00093503          	ld	a0,0(s2)
ffffffffc0201914:	4601                	li	a2,0
ffffffffc0201916:	6585                	lui	a1,0x1
ffffffffc0201918:	e4eff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc020191c:	0e050ae3          	beqz	a0,ffffffffc0202210 <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc0201920:	611c                	ld	a5,0(a0)
ffffffffc0201922:	0107f713          	andi	a4,a5,16
ffffffffc0201926:	6e070d63          	beqz	a4,ffffffffc0202020 <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc020192a:	8b91                	andi	a5,a5,4
ffffffffc020192c:	6a078a63          	beqz	a5,ffffffffc0201fe0 <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201930:	00093503          	ld	a0,0(s2)
ffffffffc0201934:	611c                	ld	a5,0(a0)
ffffffffc0201936:	8bc1                	andi	a5,a5,16
ffffffffc0201938:	68078463          	beqz	a5,ffffffffc0201fc0 <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc020193c:	000aa703          	lw	a4,0(s5)
ffffffffc0201940:	4785                	li	a5,1
ffffffffc0201942:	58f71263          	bne	a4,a5,ffffffffc0201ec6 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201946:	4681                	li	a3,0
ffffffffc0201948:	6605                	lui	a2,0x1
ffffffffc020194a:	85d2                	mv	a1,s4
ffffffffc020194c:	cb5ff0ef          	jal	ra,ffffffffc0201600 <page_insert>
ffffffffc0201950:	62051863          	bnez	a0,ffffffffc0201f80 <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc0201954:	000a2703          	lw	a4,0(s4)
ffffffffc0201958:	4789                	li	a5,2
ffffffffc020195a:	60f71363          	bne	a4,a5,ffffffffc0201f60 <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc020195e:	000aa783          	lw	a5,0(s5)
ffffffffc0201962:	5c079f63          	bnez	a5,ffffffffc0201f40 <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201966:	00093503          	ld	a0,0(s2)
ffffffffc020196a:	4601                	li	a2,0
ffffffffc020196c:	6585                	lui	a1,0x1
ffffffffc020196e:	df8ff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc0201972:	5a050763          	beqz	a0,ffffffffc0201f20 <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc0201976:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201978:	00177793          	andi	a5,a4,1
ffffffffc020197c:	4c078363          	beqz	a5,ffffffffc0201e42 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0201980:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201982:	00271793          	slli	a5,a4,0x2
ffffffffc0201986:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201988:	44d7f363          	bgeu	a5,a3,ffffffffc0201dce <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020198c:	000b3683          	ld	a3,0(s6)
ffffffffc0201990:	fff80637          	lui	a2,0xfff80
ffffffffc0201994:	97b2                	add	a5,a5,a2
ffffffffc0201996:	079a                	slli	a5,a5,0x6
ffffffffc0201998:	97b6                	add	a5,a5,a3
ffffffffc020199a:	6efa1363          	bne	s4,a5,ffffffffc0202080 <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc020199e:	8b41                	andi	a4,a4,16
ffffffffc02019a0:	6c071063          	bnez	a4,ffffffffc0202060 <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc02019a4:	00093503          	ld	a0,0(s2)
ffffffffc02019a8:	4581                	li	a1,0
ffffffffc02019aa:	bbbff0ef          	jal	ra,ffffffffc0201564 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02019ae:	000a2703          	lw	a4,0(s4)
ffffffffc02019b2:	4785                	li	a5,1
ffffffffc02019b4:	68f71663          	bne	a4,a5,ffffffffc0202040 <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc02019b8:	000aa783          	lw	a5,0(s5)
ffffffffc02019bc:	74079e63          	bnez	a5,ffffffffc0202118 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02019c0:	00093503          	ld	a0,0(s2)
ffffffffc02019c4:	6585                	lui	a1,0x1
ffffffffc02019c6:	b9fff0ef          	jal	ra,ffffffffc0201564 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02019ca:	000a2783          	lw	a5,0(s4)
ffffffffc02019ce:	72079563          	bnez	a5,ffffffffc02020f8 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc02019d2:	000aa783          	lw	a5,0(s5)
ffffffffc02019d6:	70079163          	bnez	a5,ffffffffc02020d8 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02019da:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02019de:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02019e0:	000a3683          	ld	a3,0(s4)
ffffffffc02019e4:	068a                	slli	a3,a3,0x2
ffffffffc02019e6:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019e8:	3ee6f363          	bgeu	a3,a4,ffffffffc0201dce <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02019ec:	fff807b7          	lui	a5,0xfff80
ffffffffc02019f0:	000b3503          	ld	a0,0(s6)
ffffffffc02019f4:	96be                	add	a3,a3,a5
ffffffffc02019f6:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc02019f8:	00d507b3          	add	a5,a0,a3
ffffffffc02019fc:	4390                	lw	a2,0(a5)
ffffffffc02019fe:	4785                	li	a5,1
ffffffffc0201a00:	6af61c63          	bne	a2,a5,ffffffffc02020b8 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc0201a04:	8699                	srai	a3,a3,0x6
ffffffffc0201a06:	000805b7          	lui	a1,0x80
ffffffffc0201a0a:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0201a0c:	00c69613          	slli	a2,a3,0xc
ffffffffc0201a10:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201a12:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201a14:	68e67663          	bgeu	a2,a4,ffffffffc02020a0 <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201a18:	0009b603          	ld	a2,0(s3)
ffffffffc0201a1c:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc0201a1e:	629c                	ld	a5,0(a3)
ffffffffc0201a20:	078a                	slli	a5,a5,0x2
ffffffffc0201a22:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a24:	3ae7f563          	bgeu	a5,a4,ffffffffc0201dce <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a28:	8f8d                	sub	a5,a5,a1
ffffffffc0201a2a:	079a                	slli	a5,a5,0x6
ffffffffc0201a2c:	953e                	add	a0,a0,a5
ffffffffc0201a2e:	100027f3          	csrr	a5,sstatus
ffffffffc0201a32:	8b89                	andi	a5,a5,2
ffffffffc0201a34:	2c079763          	bnez	a5,ffffffffc0201d02 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc0201a38:	000bb783          	ld	a5,0(s7)
ffffffffc0201a3c:	4585                	li	a1,1
ffffffffc0201a3e:	739c                	ld	a5,32(a5)
ffffffffc0201a40:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201a42:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201a46:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201a48:	078a                	slli	a5,a5,0x2
ffffffffc0201a4a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a4c:	38e7f163          	bgeu	a5,a4,ffffffffc0201dce <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a50:	000b3503          	ld	a0,0(s6)
ffffffffc0201a54:	fff80737          	lui	a4,0xfff80
ffffffffc0201a58:	97ba                	add	a5,a5,a4
ffffffffc0201a5a:	079a                	slli	a5,a5,0x6
ffffffffc0201a5c:	953e                	add	a0,a0,a5
ffffffffc0201a5e:	100027f3          	csrr	a5,sstatus
ffffffffc0201a62:	8b89                	andi	a5,a5,2
ffffffffc0201a64:	28079363          	bnez	a5,ffffffffc0201cea <pmm_init+0x5f4>
ffffffffc0201a68:	000bb783          	ld	a5,0(s7)
ffffffffc0201a6c:	4585                	li	a1,1
ffffffffc0201a6e:	739c                	ld	a5,32(a5)
ffffffffc0201a70:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201a72:	00093783          	ld	a5,0(s2)
ffffffffc0201a76:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd69c>
  asm volatile("sfence.vma");
ffffffffc0201a7a:	12000073          	sfence.vma
ffffffffc0201a7e:	100027f3          	csrr	a5,sstatus
ffffffffc0201a82:	8b89                	andi	a5,a5,2
ffffffffc0201a84:	24079963          	bnez	a5,ffffffffc0201cd6 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201a88:	000bb783          	ld	a5,0(s7)
ffffffffc0201a8c:	779c                	ld	a5,40(a5)
ffffffffc0201a8e:	9782                	jalr	a5
ffffffffc0201a90:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201a92:	71441363          	bne	s0,s4,ffffffffc0202198 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201a96:	00006517          	auipc	a0,0x6
ffffffffc0201a9a:	8da50513          	addi	a0,a0,-1830 # ffffffffc0207370 <commands+0xb58>
ffffffffc0201a9e:	e2efe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201aa2:	100027f3          	csrr	a5,sstatus
ffffffffc0201aa6:	8b89                	andi	a5,a5,2
ffffffffc0201aa8:	20079d63          	bnez	a5,ffffffffc0201cc2 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201aac:	000bb783          	ld	a5,0(s7)
ffffffffc0201ab0:	779c                	ld	a5,40(a5)
ffffffffc0201ab2:	9782                	jalr	a5
ffffffffc0201ab4:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ab6:	6098                	ld	a4,0(s1)
ffffffffc0201ab8:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201abc:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201abe:	00c71793          	slli	a5,a4,0xc
ffffffffc0201ac2:	6a05                	lui	s4,0x1
ffffffffc0201ac4:	02f47c63          	bgeu	s0,a5,ffffffffc0201afc <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ac8:	00c45793          	srli	a5,s0,0xc
ffffffffc0201acc:	00093503          	ld	a0,0(s2)
ffffffffc0201ad0:	2ee7f263          	bgeu	a5,a4,ffffffffc0201db4 <pmm_init+0x6be>
ffffffffc0201ad4:	0009b583          	ld	a1,0(s3)
ffffffffc0201ad8:	4601                	li	a2,0
ffffffffc0201ada:	95a2                	add	a1,a1,s0
ffffffffc0201adc:	c8aff0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc0201ae0:	2a050a63          	beqz	a0,ffffffffc0201d94 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ae4:	611c                	ld	a5,0(a0)
ffffffffc0201ae6:	078a                	slli	a5,a5,0x2
ffffffffc0201ae8:	0157f7b3          	and	a5,a5,s5
ffffffffc0201aec:	28879463          	bne	a5,s0,ffffffffc0201d74 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201af0:	6098                	ld	a4,0(s1)
ffffffffc0201af2:	9452                	add	s0,s0,s4
ffffffffc0201af4:	00c71793          	slli	a5,a4,0xc
ffffffffc0201af8:	fcf468e3          	bltu	s0,a5,ffffffffc0201ac8 <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201afc:	00093783          	ld	a5,0(s2)
ffffffffc0201b00:	639c                	ld	a5,0(a5)
ffffffffc0201b02:	66079b63          	bnez	a5,ffffffffc0202178 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0201b06:	4505                	li	a0,1
ffffffffc0201b08:	b52ff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0201b0c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201b0e:	00093503          	ld	a0,0(s2)
ffffffffc0201b12:	4699                	li	a3,6
ffffffffc0201b14:	10000613          	li	a2,256
ffffffffc0201b18:	85d6                	mv	a1,s5
ffffffffc0201b1a:	ae7ff0ef          	jal	ra,ffffffffc0201600 <page_insert>
ffffffffc0201b1e:	62051d63          	bnez	a0,ffffffffc0202158 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc0201b22:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c69c>
ffffffffc0201b26:	4785                	li	a5,1
ffffffffc0201b28:	60f71863          	bne	a4,a5,ffffffffc0202138 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201b2c:	00093503          	ld	a0,0(s2)
ffffffffc0201b30:	6405                	lui	s0,0x1
ffffffffc0201b32:	4699                	li	a3,6
ffffffffc0201b34:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ac0>
ffffffffc0201b38:	85d6                	mv	a1,s5
ffffffffc0201b3a:	ac7ff0ef          	jal	ra,ffffffffc0201600 <page_insert>
ffffffffc0201b3e:	46051163          	bnez	a0,ffffffffc0201fa0 <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc0201b42:	000aa703          	lw	a4,0(s5)
ffffffffc0201b46:	4789                	li	a5,2
ffffffffc0201b48:	72f71463          	bne	a4,a5,ffffffffc0202270 <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201b4c:	00006597          	auipc	a1,0x6
ffffffffc0201b50:	95c58593          	addi	a1,a1,-1700 # ffffffffc02074a8 <commands+0xc90>
ffffffffc0201b54:	10000513          	li	a0,256
ffffffffc0201b58:	5a0040ef          	jal	ra,ffffffffc02060f8 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201b5c:	10040593          	addi	a1,s0,256
ffffffffc0201b60:	10000513          	li	a0,256
ffffffffc0201b64:	5a6040ef          	jal	ra,ffffffffc020610a <strcmp>
ffffffffc0201b68:	6e051463          	bnez	a0,ffffffffc0202250 <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc0201b6c:	000b3683          	ld	a3,0(s6)
ffffffffc0201b70:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201b74:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0201b76:	40da86b3          	sub	a3,s5,a3
ffffffffc0201b7a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201b7c:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201b7e:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201b80:	8031                	srli	s0,s0,0xc
ffffffffc0201b82:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b86:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201b88:	50f77c63          	bgeu	a4,a5,ffffffffc02020a0 <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201b8c:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201b90:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201b94:	96be                	add	a3,a3,a5
ffffffffc0201b96:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201b9a:	528040ef          	jal	ra,ffffffffc02060c2 <strlen>
ffffffffc0201b9e:	68051963          	bnez	a0,ffffffffc0202230 <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201ba2:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201ba6:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ba8:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0201bac:	068a                	slli	a3,a3,0x2
ffffffffc0201bae:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201bb0:	20f6ff63          	bgeu	a3,a5,ffffffffc0201dce <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0201bb4:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201bb6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201bb8:	4ef47463          	bgeu	s0,a5,ffffffffc02020a0 <pmm_init+0x9aa>
ffffffffc0201bbc:	0009b403          	ld	s0,0(s3)
ffffffffc0201bc0:	9436                	add	s0,s0,a3
ffffffffc0201bc2:	100027f3          	csrr	a5,sstatus
ffffffffc0201bc6:	8b89                	andi	a5,a5,2
ffffffffc0201bc8:	18079b63          	bnez	a5,ffffffffc0201d5e <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0201bcc:	000bb783          	ld	a5,0(s7)
ffffffffc0201bd0:	4585                	li	a1,1
ffffffffc0201bd2:	8556                	mv	a0,s5
ffffffffc0201bd4:	739c                	ld	a5,32(a5)
ffffffffc0201bd6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201bd8:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201bda:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201bdc:	078a                	slli	a5,a5,0x2
ffffffffc0201bde:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201be0:	1ee7f763          	bgeu	a5,a4,ffffffffc0201dce <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201be4:	000b3503          	ld	a0,0(s6)
ffffffffc0201be8:	fff80737          	lui	a4,0xfff80
ffffffffc0201bec:	97ba                	add	a5,a5,a4
ffffffffc0201bee:	079a                	slli	a5,a5,0x6
ffffffffc0201bf0:	953e                	add	a0,a0,a5
ffffffffc0201bf2:	100027f3          	csrr	a5,sstatus
ffffffffc0201bf6:	8b89                	andi	a5,a5,2
ffffffffc0201bf8:	14079763          	bnez	a5,ffffffffc0201d46 <pmm_init+0x650>
ffffffffc0201bfc:	000bb783          	ld	a5,0(s7)
ffffffffc0201c00:	4585                	li	a1,1
ffffffffc0201c02:	739c                	ld	a5,32(a5)
ffffffffc0201c04:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c06:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201c0a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c0c:	078a                	slli	a5,a5,0x2
ffffffffc0201c0e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c10:	1ae7ff63          	bgeu	a5,a4,ffffffffc0201dce <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c14:	000b3503          	ld	a0,0(s6)
ffffffffc0201c18:	fff80737          	lui	a4,0xfff80
ffffffffc0201c1c:	97ba                	add	a5,a5,a4
ffffffffc0201c1e:	079a                	slli	a5,a5,0x6
ffffffffc0201c20:	953e                	add	a0,a0,a5
ffffffffc0201c22:	100027f3          	csrr	a5,sstatus
ffffffffc0201c26:	8b89                	andi	a5,a5,2
ffffffffc0201c28:	10079363          	bnez	a5,ffffffffc0201d2e <pmm_init+0x638>
ffffffffc0201c2c:	000bb783          	ld	a5,0(s7)
ffffffffc0201c30:	4585                	li	a1,1
ffffffffc0201c32:	739c                	ld	a5,32(a5)
ffffffffc0201c34:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201c36:	00093783          	ld	a5,0(s2)
ffffffffc0201c3a:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0201c3e:	12000073          	sfence.vma
ffffffffc0201c42:	100027f3          	csrr	a5,sstatus
ffffffffc0201c46:	8b89                	andi	a5,a5,2
ffffffffc0201c48:	0c079963          	bnez	a5,ffffffffc0201d1a <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c4c:	000bb783          	ld	a5,0(s7)
ffffffffc0201c50:	779c                	ld	a5,40(a5)
ffffffffc0201c52:	9782                	jalr	a5
ffffffffc0201c54:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201c56:	3a8c1563          	bne	s8,s0,ffffffffc0202000 <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201c5a:	00006517          	auipc	a0,0x6
ffffffffc0201c5e:	8c650513          	addi	a0,a0,-1850 # ffffffffc0207520 <commands+0xd08>
ffffffffc0201c62:	c6afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0201c66:	6446                	ld	s0,80(sp)
ffffffffc0201c68:	60e6                	ld	ra,88(sp)
ffffffffc0201c6a:	64a6                	ld	s1,72(sp)
ffffffffc0201c6c:	6906                	ld	s2,64(sp)
ffffffffc0201c6e:	79e2                	ld	s3,56(sp)
ffffffffc0201c70:	7a42                	ld	s4,48(sp)
ffffffffc0201c72:	7aa2                	ld	s5,40(sp)
ffffffffc0201c74:	7b02                	ld	s6,32(sp)
ffffffffc0201c76:	6be2                	ld	s7,24(sp)
ffffffffc0201c78:	6c42                	ld	s8,16(sp)
ffffffffc0201c7a:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0201c7c:	1810106f          	j	ffffffffc02035fc <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201c80:	6785                	lui	a5,0x1
ffffffffc0201c82:	17fd                	addi	a5,a5,-1
ffffffffc0201c84:	96be                	add	a3,a3,a5
ffffffffc0201c86:	77fd                	lui	a5,0xfffff
ffffffffc0201c88:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0201c8a:	00c7d693          	srli	a3,a5,0xc
ffffffffc0201c8e:	14c6f063          	bgeu	a3,a2,ffffffffc0201dce <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0201c92:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0201c96:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201c98:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0201c9c:	6a10                	ld	a2,16(a2)
ffffffffc0201c9e:	069a                	slli	a3,a3,0x6
ffffffffc0201ca0:	00c7d593          	srli	a1,a5,0xc
ffffffffc0201ca4:	9536                	add	a0,a0,a3
ffffffffc0201ca6:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201ca8:	0009b583          	ld	a1,0(s3)
}
ffffffffc0201cac:	b63d                	j	ffffffffc02017da <pmm_init+0xe4>
        intr_disable();
ffffffffc0201cae:	99bfe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201cb2:	000bb783          	ld	a5,0(s7)
ffffffffc0201cb6:	779c                	ld	a5,40(a5)
ffffffffc0201cb8:	9782                	jalr	a5
ffffffffc0201cba:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201cbc:	987fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201cc0:	bea5                	j	ffffffffc0201838 <pmm_init+0x142>
        intr_disable();
ffffffffc0201cc2:	987fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201cc6:	000bb783          	ld	a5,0(s7)
ffffffffc0201cca:	779c                	ld	a5,40(a5)
ffffffffc0201ccc:	9782                	jalr	a5
ffffffffc0201cce:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0201cd0:	973fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201cd4:	b3cd                	j	ffffffffc0201ab6 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0201cd6:	973fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201cda:	000bb783          	ld	a5,0(s7)
ffffffffc0201cde:	779c                	ld	a5,40(a5)
ffffffffc0201ce0:	9782                	jalr	a5
ffffffffc0201ce2:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0201ce4:	95ffe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201ce8:	b36d                	j	ffffffffc0201a92 <pmm_init+0x39c>
ffffffffc0201cea:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201cec:	95dfe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201cf0:	000bb783          	ld	a5,0(s7)
ffffffffc0201cf4:	6522                	ld	a0,8(sp)
ffffffffc0201cf6:	4585                	li	a1,1
ffffffffc0201cf8:	739c                	ld	a5,32(a5)
ffffffffc0201cfa:	9782                	jalr	a5
        intr_enable();
ffffffffc0201cfc:	947fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d00:	bb8d                	j	ffffffffc0201a72 <pmm_init+0x37c>
ffffffffc0201d02:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201d04:	945fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201d08:	000bb783          	ld	a5,0(s7)
ffffffffc0201d0c:	6522                	ld	a0,8(sp)
ffffffffc0201d0e:	4585                	li	a1,1
ffffffffc0201d10:	739c                	ld	a5,32(a5)
ffffffffc0201d12:	9782                	jalr	a5
        intr_enable();
ffffffffc0201d14:	92ffe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d18:	b32d                	j	ffffffffc0201a42 <pmm_init+0x34c>
        intr_disable();
ffffffffc0201d1a:	92ffe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201d1e:	000bb783          	ld	a5,0(s7)
ffffffffc0201d22:	779c                	ld	a5,40(a5)
ffffffffc0201d24:	9782                	jalr	a5
ffffffffc0201d26:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d28:	91bfe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d2c:	b72d                	j	ffffffffc0201c56 <pmm_init+0x560>
ffffffffc0201d2e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201d30:	919fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201d34:	000bb783          	ld	a5,0(s7)
ffffffffc0201d38:	6522                	ld	a0,8(sp)
ffffffffc0201d3a:	4585                	li	a1,1
ffffffffc0201d3c:	739c                	ld	a5,32(a5)
ffffffffc0201d3e:	9782                	jalr	a5
        intr_enable();
ffffffffc0201d40:	903fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d44:	bdcd                	j	ffffffffc0201c36 <pmm_init+0x540>
ffffffffc0201d46:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201d48:	901fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201d4c:	000bb783          	ld	a5,0(s7)
ffffffffc0201d50:	6522                	ld	a0,8(sp)
ffffffffc0201d52:	4585                	li	a1,1
ffffffffc0201d54:	739c                	ld	a5,32(a5)
ffffffffc0201d56:	9782                	jalr	a5
        intr_enable();
ffffffffc0201d58:	8ebfe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d5c:	b56d                	j	ffffffffc0201c06 <pmm_init+0x510>
        intr_disable();
ffffffffc0201d5e:	8ebfe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0201d62:	000bb783          	ld	a5,0(s7)
ffffffffc0201d66:	4585                	li	a1,1
ffffffffc0201d68:	8556                	mv	a0,s5
ffffffffc0201d6a:	739c                	ld	a5,32(a5)
ffffffffc0201d6c:	9782                	jalr	a5
        intr_enable();
ffffffffc0201d6e:	8d5fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201d72:	b59d                	j	ffffffffc0201bd8 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201d74:	00005697          	auipc	a3,0x5
ffffffffc0201d78:	65c68693          	addi	a3,a3,1628 # ffffffffc02073d0 <commands+0xbb8>
ffffffffc0201d7c:	00005617          	auipc	a2,0x5
ffffffffc0201d80:	eac60613          	addi	a2,a2,-340 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201d84:	22700593          	li	a1,551
ffffffffc0201d88:	00005517          	auipc	a0,0x5
ffffffffc0201d8c:	21050513          	addi	a0,a0,528 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201d90:	c78fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201d94:	00005697          	auipc	a3,0x5
ffffffffc0201d98:	5fc68693          	addi	a3,a3,1532 # ffffffffc0207390 <commands+0xb78>
ffffffffc0201d9c:	00005617          	auipc	a2,0x5
ffffffffc0201da0:	e8c60613          	addi	a2,a2,-372 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201da4:	22600593          	li	a1,550
ffffffffc0201da8:	00005517          	auipc	a0,0x5
ffffffffc0201dac:	1f050513          	addi	a0,a0,496 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201db0:	c58fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201db4:	86a2                	mv	a3,s0
ffffffffc0201db6:	00005617          	auipc	a2,0x5
ffffffffc0201dba:	1ba60613          	addi	a2,a2,442 # ffffffffc0206f70 <commands+0x758>
ffffffffc0201dbe:	22600593          	li	a1,550
ffffffffc0201dc2:	00005517          	auipc	a0,0x5
ffffffffc0201dc6:	1d650513          	addi	a0,a0,470 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201dca:	c3efe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201dce:	854ff0ef          	jal	ra,ffffffffc0200e22 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201dd2:	00005617          	auipc	a2,0x5
ffffffffc0201dd6:	27660613          	addi	a2,a2,630 # ffffffffc0207048 <commands+0x830>
ffffffffc0201dda:	07f00593          	li	a1,127
ffffffffc0201dde:	00005517          	auipc	a0,0x5
ffffffffc0201de2:	1ba50513          	addi	a0,a0,442 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201de6:	c22fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201dea:	00005617          	auipc	a2,0x5
ffffffffc0201dee:	25e60613          	addi	a2,a2,606 # ffffffffc0207048 <commands+0x830>
ffffffffc0201df2:	0c100593          	li	a1,193
ffffffffc0201df6:	00005517          	auipc	a0,0x5
ffffffffc0201dfa:	1a250513          	addi	a0,a0,418 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201dfe:	c0afe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201e02:	00005697          	auipc	a3,0x5
ffffffffc0201e06:	2c668693          	addi	a3,a3,710 # ffffffffc02070c8 <commands+0x8b0>
ffffffffc0201e0a:	00005617          	auipc	a2,0x5
ffffffffc0201e0e:	e1e60613          	addi	a2,a2,-482 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201e12:	1ea00593          	li	a1,490
ffffffffc0201e16:	00005517          	auipc	a0,0x5
ffffffffc0201e1a:	18250513          	addi	a0,a0,386 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201e1e:	beafe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201e22:	00005697          	auipc	a3,0x5
ffffffffc0201e26:	28668693          	addi	a3,a3,646 # ffffffffc02070a8 <commands+0x890>
ffffffffc0201e2a:	00005617          	auipc	a2,0x5
ffffffffc0201e2e:	dfe60613          	addi	a2,a2,-514 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201e32:	1e900593          	li	a1,489
ffffffffc0201e36:	00005517          	auipc	a0,0x5
ffffffffc0201e3a:	16250513          	addi	a0,a0,354 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201e3e:	bcafe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201e42:	ffdfe0ef          	jal	ra,ffffffffc0200e3e <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201e46:	00005697          	auipc	a3,0x5
ffffffffc0201e4a:	31268693          	addi	a3,a3,786 # ffffffffc0207158 <commands+0x940>
ffffffffc0201e4e:	00005617          	auipc	a2,0x5
ffffffffc0201e52:	dda60613          	addi	a2,a2,-550 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201e56:	1f200593          	li	a1,498
ffffffffc0201e5a:	00005517          	auipc	a0,0x5
ffffffffc0201e5e:	13e50513          	addi	a0,a0,318 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201e62:	ba6fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201e66:	00005697          	auipc	a3,0x5
ffffffffc0201e6a:	2c268693          	addi	a3,a3,706 # ffffffffc0207128 <commands+0x910>
ffffffffc0201e6e:	00005617          	auipc	a2,0x5
ffffffffc0201e72:	dba60613          	addi	a2,a2,-582 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201e76:	1ef00593          	li	a1,495
ffffffffc0201e7a:	00005517          	auipc	a0,0x5
ffffffffc0201e7e:	11e50513          	addi	a0,a0,286 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201e82:	b86fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201e86:	00005697          	auipc	a3,0x5
ffffffffc0201e8a:	27a68693          	addi	a3,a3,634 # ffffffffc0207100 <commands+0x8e8>
ffffffffc0201e8e:	00005617          	auipc	a2,0x5
ffffffffc0201e92:	d9a60613          	addi	a2,a2,-614 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201e96:	1eb00593          	li	a1,491
ffffffffc0201e9a:	00005517          	auipc	a0,0x5
ffffffffc0201e9e:	0fe50513          	addi	a0,a0,254 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201ea2:	b66fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201ea6:	00005697          	auipc	a3,0x5
ffffffffc0201eaa:	33a68693          	addi	a3,a3,826 # ffffffffc02071e0 <commands+0x9c8>
ffffffffc0201eae:	00005617          	auipc	a2,0x5
ffffffffc0201eb2:	d7a60613          	addi	a2,a2,-646 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201eb6:	1fb00593          	li	a1,507
ffffffffc0201eba:	00005517          	auipc	a0,0x5
ffffffffc0201ebe:	0de50513          	addi	a0,a0,222 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201ec2:	b46fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201ec6:	00005697          	auipc	a3,0x5
ffffffffc0201eca:	3ba68693          	addi	a3,a3,954 # ffffffffc0207280 <commands+0xa68>
ffffffffc0201ece:	00005617          	auipc	a2,0x5
ffffffffc0201ed2:	d5a60613          	addi	a2,a2,-678 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201ed6:	20000593          	li	a1,512
ffffffffc0201eda:	00005517          	auipc	a0,0x5
ffffffffc0201ede:	0be50513          	addi	a0,a0,190 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201ee2:	b26fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201ee6:	00005697          	auipc	a3,0x5
ffffffffc0201eea:	2d268693          	addi	a3,a3,722 # ffffffffc02071b8 <commands+0x9a0>
ffffffffc0201eee:	00005617          	auipc	a2,0x5
ffffffffc0201ef2:	d3a60613          	addi	a2,a2,-710 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201ef6:	1f800593          	li	a1,504
ffffffffc0201efa:	00005517          	auipc	a0,0x5
ffffffffc0201efe:	09e50513          	addi	a0,a0,158 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201f02:	b06fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201f06:	86d6                	mv	a3,s5
ffffffffc0201f08:	00005617          	auipc	a2,0x5
ffffffffc0201f0c:	06860613          	addi	a2,a2,104 # ffffffffc0206f70 <commands+0x758>
ffffffffc0201f10:	1f700593          	li	a1,503
ffffffffc0201f14:	00005517          	auipc	a0,0x5
ffffffffc0201f18:	08450513          	addi	a0,a0,132 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201f1c:	aecfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201f20:	00005697          	auipc	a3,0x5
ffffffffc0201f24:	2f868693          	addi	a3,a3,760 # ffffffffc0207218 <commands+0xa00>
ffffffffc0201f28:	00005617          	auipc	a2,0x5
ffffffffc0201f2c:	d0060613          	addi	a2,a2,-768 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201f30:	20500593          	li	a1,517
ffffffffc0201f34:	00005517          	auipc	a0,0x5
ffffffffc0201f38:	06450513          	addi	a0,a0,100 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201f3c:	accfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201f40:	00005697          	auipc	a3,0x5
ffffffffc0201f44:	3a068693          	addi	a3,a3,928 # ffffffffc02072e0 <commands+0xac8>
ffffffffc0201f48:	00005617          	auipc	a2,0x5
ffffffffc0201f4c:	ce060613          	addi	a2,a2,-800 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201f50:	20400593          	li	a1,516
ffffffffc0201f54:	00005517          	auipc	a0,0x5
ffffffffc0201f58:	04450513          	addi	a0,a0,68 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201f5c:	aacfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201f60:	00005697          	auipc	a3,0x5
ffffffffc0201f64:	36868693          	addi	a3,a3,872 # ffffffffc02072c8 <commands+0xab0>
ffffffffc0201f68:	00005617          	auipc	a2,0x5
ffffffffc0201f6c:	cc060613          	addi	a2,a2,-832 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201f70:	20300593          	li	a1,515
ffffffffc0201f74:	00005517          	auipc	a0,0x5
ffffffffc0201f78:	02450513          	addi	a0,a0,36 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201f7c:	a8cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201f80:	00005697          	auipc	a3,0x5
ffffffffc0201f84:	31868693          	addi	a3,a3,792 # ffffffffc0207298 <commands+0xa80>
ffffffffc0201f88:	00005617          	auipc	a2,0x5
ffffffffc0201f8c:	ca060613          	addi	a2,a2,-864 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201f90:	20200593          	li	a1,514
ffffffffc0201f94:	00005517          	auipc	a0,0x5
ffffffffc0201f98:	00450513          	addi	a0,a0,4 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201f9c:	a6cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201fa0:	00005697          	auipc	a3,0x5
ffffffffc0201fa4:	4b068693          	addi	a3,a3,1200 # ffffffffc0207450 <commands+0xc38>
ffffffffc0201fa8:	00005617          	auipc	a2,0x5
ffffffffc0201fac:	c8060613          	addi	a2,a2,-896 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201fb0:	23100593          	li	a1,561
ffffffffc0201fb4:	00005517          	auipc	a0,0x5
ffffffffc0201fb8:	fe450513          	addi	a0,a0,-28 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201fbc:	a4cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201fc0:	00005697          	auipc	a3,0x5
ffffffffc0201fc4:	2a868693          	addi	a3,a3,680 # ffffffffc0207268 <commands+0xa50>
ffffffffc0201fc8:	00005617          	auipc	a2,0x5
ffffffffc0201fcc:	c6060613          	addi	a2,a2,-928 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201fd0:	1ff00593          	li	a1,511
ffffffffc0201fd4:	00005517          	auipc	a0,0x5
ffffffffc0201fd8:	fc450513          	addi	a0,a0,-60 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201fdc:	a2cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201fe0:	00005697          	auipc	a3,0x5
ffffffffc0201fe4:	27868693          	addi	a3,a3,632 # ffffffffc0207258 <commands+0xa40>
ffffffffc0201fe8:	00005617          	auipc	a2,0x5
ffffffffc0201fec:	c4060613          	addi	a2,a2,-960 # ffffffffc0206c28 <commands+0x410>
ffffffffc0201ff0:	1fe00593          	li	a1,510
ffffffffc0201ff4:	00005517          	auipc	a0,0x5
ffffffffc0201ff8:	fa450513          	addi	a0,a0,-92 # ffffffffc0206f98 <commands+0x780>
ffffffffc0201ffc:	a0cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202000:	00005697          	auipc	a3,0x5
ffffffffc0202004:	35068693          	addi	a3,a3,848 # ffffffffc0207350 <commands+0xb38>
ffffffffc0202008:	00005617          	auipc	a2,0x5
ffffffffc020200c:	c2060613          	addi	a2,a2,-992 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202010:	24200593          	li	a1,578
ffffffffc0202014:	00005517          	auipc	a0,0x5
ffffffffc0202018:	f8450513          	addi	a0,a0,-124 # ffffffffc0206f98 <commands+0x780>
ffffffffc020201c:	9ecfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202020:	00005697          	auipc	a3,0x5
ffffffffc0202024:	22868693          	addi	a3,a3,552 # ffffffffc0207248 <commands+0xa30>
ffffffffc0202028:	00005617          	auipc	a2,0x5
ffffffffc020202c:	c0060613          	addi	a2,a2,-1024 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202030:	1fd00593          	li	a1,509
ffffffffc0202034:	00005517          	auipc	a0,0x5
ffffffffc0202038:	f6450513          	addi	a0,a0,-156 # ffffffffc0206f98 <commands+0x780>
ffffffffc020203c:	9ccfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202040:	00005697          	auipc	a3,0x5
ffffffffc0202044:	16068693          	addi	a3,a3,352 # ffffffffc02071a0 <commands+0x988>
ffffffffc0202048:	00005617          	auipc	a2,0x5
ffffffffc020204c:	be060613          	addi	a2,a2,-1056 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202050:	20a00593          	li	a1,522
ffffffffc0202054:	00005517          	auipc	a0,0x5
ffffffffc0202058:	f4450513          	addi	a0,a0,-188 # ffffffffc0206f98 <commands+0x780>
ffffffffc020205c:	9acfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202060:	00005697          	auipc	a3,0x5
ffffffffc0202064:	29868693          	addi	a3,a3,664 # ffffffffc02072f8 <commands+0xae0>
ffffffffc0202068:	00005617          	auipc	a2,0x5
ffffffffc020206c:	bc060613          	addi	a2,a2,-1088 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202070:	20700593          	li	a1,519
ffffffffc0202074:	00005517          	auipc	a0,0x5
ffffffffc0202078:	f2450513          	addi	a0,a0,-220 # ffffffffc0206f98 <commands+0x780>
ffffffffc020207c:	98cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202080:	00005697          	auipc	a3,0x5
ffffffffc0202084:	10868693          	addi	a3,a3,264 # ffffffffc0207188 <commands+0x970>
ffffffffc0202088:	00005617          	auipc	a2,0x5
ffffffffc020208c:	ba060613          	addi	a2,a2,-1120 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202090:	20600593          	li	a1,518
ffffffffc0202094:	00005517          	auipc	a0,0x5
ffffffffc0202098:	f0450513          	addi	a0,a0,-252 # ffffffffc0206f98 <commands+0x780>
ffffffffc020209c:	96cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc02020a0:	00005617          	auipc	a2,0x5
ffffffffc02020a4:	ed060613          	addi	a2,a2,-304 # ffffffffc0206f70 <commands+0x758>
ffffffffc02020a8:	06900593          	li	a1,105
ffffffffc02020ac:	00005517          	auipc	a0,0x5
ffffffffc02020b0:	e8c50513          	addi	a0,a0,-372 # ffffffffc0206f38 <commands+0x720>
ffffffffc02020b4:	954fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02020b8:	00005697          	auipc	a3,0x5
ffffffffc02020bc:	27068693          	addi	a3,a3,624 # ffffffffc0207328 <commands+0xb10>
ffffffffc02020c0:	00005617          	auipc	a2,0x5
ffffffffc02020c4:	b6860613          	addi	a2,a2,-1176 # ffffffffc0206c28 <commands+0x410>
ffffffffc02020c8:	21100593          	li	a1,529
ffffffffc02020cc:	00005517          	auipc	a0,0x5
ffffffffc02020d0:	ecc50513          	addi	a0,a0,-308 # ffffffffc0206f98 <commands+0x780>
ffffffffc02020d4:	934fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02020d8:	00005697          	auipc	a3,0x5
ffffffffc02020dc:	20868693          	addi	a3,a3,520 # ffffffffc02072e0 <commands+0xac8>
ffffffffc02020e0:	00005617          	auipc	a2,0x5
ffffffffc02020e4:	b4860613          	addi	a2,a2,-1208 # ffffffffc0206c28 <commands+0x410>
ffffffffc02020e8:	20f00593          	li	a1,527
ffffffffc02020ec:	00005517          	auipc	a0,0x5
ffffffffc02020f0:	eac50513          	addi	a0,a0,-340 # ffffffffc0206f98 <commands+0x780>
ffffffffc02020f4:	914fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02020f8:	00005697          	auipc	a3,0x5
ffffffffc02020fc:	21868693          	addi	a3,a3,536 # ffffffffc0207310 <commands+0xaf8>
ffffffffc0202100:	00005617          	auipc	a2,0x5
ffffffffc0202104:	b2860613          	addi	a2,a2,-1240 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202108:	20e00593          	li	a1,526
ffffffffc020210c:	00005517          	auipc	a0,0x5
ffffffffc0202110:	e8c50513          	addi	a0,a0,-372 # ffffffffc0206f98 <commands+0x780>
ffffffffc0202114:	8f4fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202118:	00005697          	auipc	a3,0x5
ffffffffc020211c:	1c868693          	addi	a3,a3,456 # ffffffffc02072e0 <commands+0xac8>
ffffffffc0202120:	00005617          	auipc	a2,0x5
ffffffffc0202124:	b0860613          	addi	a2,a2,-1272 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202128:	20b00593          	li	a1,523
ffffffffc020212c:	00005517          	auipc	a0,0x5
ffffffffc0202130:	e6c50513          	addi	a0,a0,-404 # ffffffffc0206f98 <commands+0x780>
ffffffffc0202134:	8d4fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202138:	00005697          	auipc	a3,0x5
ffffffffc020213c:	30068693          	addi	a3,a3,768 # ffffffffc0207438 <commands+0xc20>
ffffffffc0202140:	00005617          	auipc	a2,0x5
ffffffffc0202144:	ae860613          	addi	a2,a2,-1304 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202148:	23000593          	li	a1,560
ffffffffc020214c:	00005517          	auipc	a0,0x5
ffffffffc0202150:	e4c50513          	addi	a0,a0,-436 # ffffffffc0206f98 <commands+0x780>
ffffffffc0202154:	8b4fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202158:	00005697          	auipc	a3,0x5
ffffffffc020215c:	2a868693          	addi	a3,a3,680 # ffffffffc0207400 <commands+0xbe8>
ffffffffc0202160:	00005617          	auipc	a2,0x5
ffffffffc0202164:	ac860613          	addi	a2,a2,-1336 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202168:	22f00593          	li	a1,559
ffffffffc020216c:	00005517          	auipc	a0,0x5
ffffffffc0202170:	e2c50513          	addi	a0,a0,-468 # ffffffffc0206f98 <commands+0x780>
ffffffffc0202174:	894fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202178:	00005697          	auipc	a3,0x5
ffffffffc020217c:	27068693          	addi	a3,a3,624 # ffffffffc02073e8 <commands+0xbd0>
ffffffffc0202180:	00005617          	auipc	a2,0x5
ffffffffc0202184:	aa860613          	addi	a2,a2,-1368 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202188:	22b00593          	li	a1,555
ffffffffc020218c:	00005517          	auipc	a0,0x5
ffffffffc0202190:	e0c50513          	addi	a0,a0,-500 # ffffffffc0206f98 <commands+0x780>
ffffffffc0202194:	874fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202198:	00005697          	auipc	a3,0x5
ffffffffc020219c:	1b868693          	addi	a3,a3,440 # ffffffffc0207350 <commands+0xb38>
ffffffffc02021a0:	00005617          	auipc	a2,0x5
ffffffffc02021a4:	a8860613          	addi	a2,a2,-1400 # ffffffffc0206c28 <commands+0x410>
ffffffffc02021a8:	21900593          	li	a1,537
ffffffffc02021ac:	00005517          	auipc	a0,0x5
ffffffffc02021b0:	dec50513          	addi	a0,a0,-532 # ffffffffc0206f98 <commands+0x780>
ffffffffc02021b4:	854fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02021b8:	00005697          	auipc	a3,0x5
ffffffffc02021bc:	fd068693          	addi	a3,a3,-48 # ffffffffc0207188 <commands+0x970>
ffffffffc02021c0:	00005617          	auipc	a2,0x5
ffffffffc02021c4:	a6860613          	addi	a2,a2,-1432 # ffffffffc0206c28 <commands+0x410>
ffffffffc02021c8:	1f300593          	li	a1,499
ffffffffc02021cc:	00005517          	auipc	a0,0x5
ffffffffc02021d0:	dcc50513          	addi	a0,a0,-564 # ffffffffc0206f98 <commands+0x780>
ffffffffc02021d4:	834fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02021d8:	00005617          	auipc	a2,0x5
ffffffffc02021dc:	d9860613          	addi	a2,a2,-616 # ffffffffc0206f70 <commands+0x758>
ffffffffc02021e0:	1f600593          	li	a1,502
ffffffffc02021e4:	00005517          	auipc	a0,0x5
ffffffffc02021e8:	db450513          	addi	a0,a0,-588 # ffffffffc0206f98 <commands+0x780>
ffffffffc02021ec:	81cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02021f0:	00005697          	auipc	a3,0x5
ffffffffc02021f4:	fb068693          	addi	a3,a3,-80 # ffffffffc02071a0 <commands+0x988>
ffffffffc02021f8:	00005617          	auipc	a2,0x5
ffffffffc02021fc:	a3060613          	addi	a2,a2,-1488 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202200:	1f400593          	li	a1,500
ffffffffc0202204:	00005517          	auipc	a0,0x5
ffffffffc0202208:	d9450513          	addi	a0,a0,-620 # ffffffffc0206f98 <commands+0x780>
ffffffffc020220c:	ffdfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202210:	00005697          	auipc	a3,0x5
ffffffffc0202214:	00868693          	addi	a3,a3,8 # ffffffffc0207218 <commands+0xa00>
ffffffffc0202218:	00005617          	auipc	a2,0x5
ffffffffc020221c:	a1060613          	addi	a2,a2,-1520 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202220:	1fc00593          	li	a1,508
ffffffffc0202224:	00005517          	auipc	a0,0x5
ffffffffc0202228:	d7450513          	addi	a0,a0,-652 # ffffffffc0206f98 <commands+0x780>
ffffffffc020222c:	fddfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202230:	00005697          	auipc	a3,0x5
ffffffffc0202234:	2c868693          	addi	a3,a3,712 # ffffffffc02074f8 <commands+0xce0>
ffffffffc0202238:	00005617          	auipc	a2,0x5
ffffffffc020223c:	9f060613          	addi	a2,a2,-1552 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202240:	23900593          	li	a1,569
ffffffffc0202244:	00005517          	auipc	a0,0x5
ffffffffc0202248:	d5450513          	addi	a0,a0,-684 # ffffffffc0206f98 <commands+0x780>
ffffffffc020224c:	fbdfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202250:	00005697          	auipc	a3,0x5
ffffffffc0202254:	27068693          	addi	a3,a3,624 # ffffffffc02074c0 <commands+0xca8>
ffffffffc0202258:	00005617          	auipc	a2,0x5
ffffffffc020225c:	9d060613          	addi	a2,a2,-1584 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202260:	23600593          	li	a1,566
ffffffffc0202264:	00005517          	auipc	a0,0x5
ffffffffc0202268:	d3450513          	addi	a0,a0,-716 # ffffffffc0206f98 <commands+0x780>
ffffffffc020226c:	f9dfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202270:	00005697          	auipc	a3,0x5
ffffffffc0202274:	22068693          	addi	a3,a3,544 # ffffffffc0207490 <commands+0xc78>
ffffffffc0202278:	00005617          	auipc	a2,0x5
ffffffffc020227c:	9b060613          	addi	a2,a2,-1616 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202280:	23200593          	li	a1,562
ffffffffc0202284:	00005517          	auipc	a0,0x5
ffffffffc0202288:	d1450513          	addi	a0,a0,-748 # ffffffffc0206f98 <commands+0x780>
ffffffffc020228c:	f7dfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202290 <copy_range>:
               bool share) {
ffffffffc0202290:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202292:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc0202296:	f486                	sd	ra,104(sp)
ffffffffc0202298:	f0a2                	sd	s0,96(sp)
ffffffffc020229a:	eca6                	sd	s1,88(sp)
ffffffffc020229c:	e8ca                	sd	s2,80(sp)
ffffffffc020229e:	e4ce                	sd	s3,72(sp)
ffffffffc02022a0:	e0d2                	sd	s4,64(sp)
ffffffffc02022a2:	fc56                	sd	s5,56(sp)
ffffffffc02022a4:	f85a                	sd	s6,48(sp)
ffffffffc02022a6:	f45e                	sd	s7,40(sp)
ffffffffc02022a8:	f062                	sd	s8,32(sp)
ffffffffc02022aa:	ec66                	sd	s9,24(sp)
ffffffffc02022ac:	e86a                	sd	s10,16(sp)
ffffffffc02022ae:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022b0:	17d2                	slli	a5,a5,0x34
ffffffffc02022b2:	1e079763          	bnez	a5,ffffffffc02024a0 <copy_range+0x210>
    assert(USER_ACCESS(start, end));
ffffffffc02022b6:	002007b7          	lui	a5,0x200
ffffffffc02022ba:	8432                	mv	s0,a2
ffffffffc02022bc:	16f66a63          	bltu	a2,a5,ffffffffc0202430 <copy_range+0x1a0>
ffffffffc02022c0:	8936                	mv	s2,a3
ffffffffc02022c2:	16d67763          	bgeu	a2,a3,ffffffffc0202430 <copy_range+0x1a0>
ffffffffc02022c6:	4785                	li	a5,1
ffffffffc02022c8:	07fe                	slli	a5,a5,0x1f
ffffffffc02022ca:	16d7e363          	bltu	a5,a3,ffffffffc0202430 <copy_range+0x1a0>
ffffffffc02022ce:	5b7d                	li	s6,-1
ffffffffc02022d0:	8aaa                	mv	s5,a0
ffffffffc02022d2:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc02022d4:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02022d6:	000b0c97          	auipc	s9,0xb0
ffffffffc02022da:	622c8c93          	addi	s9,s9,1570 # ffffffffc02b28f8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02022de:	000b0c17          	auipc	s8,0xb0
ffffffffc02022e2:	622c0c13          	addi	s8,s8,1570 # ffffffffc02b2900 <pages>
    return page - pages + nbase;
ffffffffc02022e6:	00080bb7          	lui	s7,0x80
    return KADDR(page2pa(page));
ffffffffc02022ea:	00cb5b13          	srli	s6,s6,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02022ee:	4601                	li	a2,0
ffffffffc02022f0:	85a2                	mv	a1,s0
ffffffffc02022f2:	854e                	mv	a0,s3
ffffffffc02022f4:	c73fe0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc02022f8:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02022fa:	c175                	beqz	a0,ffffffffc02023de <copy_range+0x14e>
        if (*ptep & PTE_V) {
ffffffffc02022fc:	611c                	ld	a5,0(a0)
ffffffffc02022fe:	8b85                	andi	a5,a5,1
ffffffffc0202300:	e785                	bnez	a5,ffffffffc0202328 <copy_range+0x98>
        start += PGSIZE;
ffffffffc0202302:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202304:	ff2465e3          	bltu	s0,s2,ffffffffc02022ee <copy_range+0x5e>
    return 0;
ffffffffc0202308:	4501                	li	a0,0
}
ffffffffc020230a:	70a6                	ld	ra,104(sp)
ffffffffc020230c:	7406                	ld	s0,96(sp)
ffffffffc020230e:	64e6                	ld	s1,88(sp)
ffffffffc0202310:	6946                	ld	s2,80(sp)
ffffffffc0202312:	69a6                	ld	s3,72(sp)
ffffffffc0202314:	6a06                	ld	s4,64(sp)
ffffffffc0202316:	7ae2                	ld	s5,56(sp)
ffffffffc0202318:	7b42                	ld	s6,48(sp)
ffffffffc020231a:	7ba2                	ld	s7,40(sp)
ffffffffc020231c:	7c02                	ld	s8,32(sp)
ffffffffc020231e:	6ce2                	ld	s9,24(sp)
ffffffffc0202320:	6d42                	ld	s10,16(sp)
ffffffffc0202322:	6da2                	ld	s11,8(sp)
ffffffffc0202324:	6165                	addi	sp,sp,112
ffffffffc0202326:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0202328:	4605                	li	a2,1
ffffffffc020232a:	85a2                	mv	a1,s0
ffffffffc020232c:	8556                	mv	a0,s5
ffffffffc020232e:	c39fe0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc0202332:	c161                	beqz	a0,ffffffffc02023f2 <copy_range+0x162>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0202334:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V)) {
ffffffffc0202336:	0017f713          	andi	a4,a5,1
ffffffffc020233a:	01f7f493          	andi	s1,a5,31
ffffffffc020233e:	14070563          	beqz	a4,ffffffffc0202488 <copy_range+0x1f8>
    if (PPN(pa) >= npage) {
ffffffffc0202342:	000cb683          	ld	a3,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202346:	078a                	slli	a5,a5,0x2
ffffffffc0202348:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020234c:	12d77263          	bgeu	a4,a3,ffffffffc0202470 <copy_range+0x1e0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202350:	000c3783          	ld	a5,0(s8)
ffffffffc0202354:	fff806b7          	lui	a3,0xfff80
ffffffffc0202358:	9736                	add	a4,a4,a3
ffffffffc020235a:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc020235c:	4505                	li	a0,1
ffffffffc020235e:	00e78db3          	add	s11,a5,a4
ffffffffc0202362:	af9fe0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0202366:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc0202368:	0a0d8463          	beqz	s11,ffffffffc0202410 <copy_range+0x180>
            assert(npage != NULL);
ffffffffc020236c:	c175                	beqz	a0,ffffffffc0202450 <copy_range+0x1c0>
    return page - pages + nbase;
ffffffffc020236e:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc0202372:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0202376:	40ed86b3          	sub	a3,s11,a4
ffffffffc020237a:	8699                	srai	a3,a3,0x6
ffffffffc020237c:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc020237e:	0166f7b3          	and	a5,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202382:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202384:	06c7fa63          	bgeu	a5,a2,ffffffffc02023f8 <copy_range+0x168>
    return page - pages + nbase;
ffffffffc0202388:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc020238c:	000b0717          	auipc	a4,0xb0
ffffffffc0202390:	58470713          	addi	a4,a4,1412 # ffffffffc02b2910 <va_pa_offset>
ffffffffc0202394:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc0202396:	8799                	srai	a5,a5,0x6
ffffffffc0202398:	97de                	add	a5,a5,s7
    return KADDR(page2pa(page));
ffffffffc020239a:	0167f733          	and	a4,a5,s6
ffffffffc020239e:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02023a2:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02023a4:	04c77963          	bgeu	a4,a2,ffffffffc02023f6 <copy_range+0x166>
            memcpy(kva_dst, kva_src, PGSIZE); 
ffffffffc02023a8:	6605                	lui	a2,0x1
ffffffffc02023aa:	953e                	add	a0,a0,a5
ffffffffc02023ac:	5a5030ef          	jal	ra,ffffffffc0206150 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02023b0:	86a6                	mv	a3,s1
ffffffffc02023b2:	8622                	mv	a2,s0
ffffffffc02023b4:	85ea                	mv	a1,s10
ffffffffc02023b6:	8556                	mv	a0,s5
ffffffffc02023b8:	a48ff0ef          	jal	ra,ffffffffc0201600 <page_insert>
            assert(ret == 0);
ffffffffc02023bc:	d139                	beqz	a0,ffffffffc0202302 <copy_range+0x72>
ffffffffc02023be:	00005697          	auipc	a3,0x5
ffffffffc02023c2:	1a268693          	addi	a3,a3,418 # ffffffffc0207560 <commands+0xd48>
ffffffffc02023c6:	00005617          	auipc	a2,0x5
ffffffffc02023ca:	86260613          	addi	a2,a2,-1950 # ffffffffc0206c28 <commands+0x410>
ffffffffc02023ce:	18b00593          	li	a1,395
ffffffffc02023d2:	00005517          	auipc	a0,0x5
ffffffffc02023d6:	bc650513          	addi	a0,a0,-1082 # ffffffffc0206f98 <commands+0x780>
ffffffffc02023da:	e2ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02023de:	00200637          	lui	a2,0x200
ffffffffc02023e2:	9432                	add	s0,s0,a2
ffffffffc02023e4:	ffe00637          	lui	a2,0xffe00
ffffffffc02023e8:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc02023ea:	dc19                	beqz	s0,ffffffffc0202308 <copy_range+0x78>
ffffffffc02023ec:	f12461e3          	bltu	s0,s2,ffffffffc02022ee <copy_range+0x5e>
ffffffffc02023f0:	bf21                	j	ffffffffc0202308 <copy_range+0x78>
                return -E_NO_MEM;
ffffffffc02023f2:	5571                	li	a0,-4
ffffffffc02023f4:	bf19                	j	ffffffffc020230a <copy_range+0x7a>
ffffffffc02023f6:	86be                	mv	a3,a5
ffffffffc02023f8:	00005617          	auipc	a2,0x5
ffffffffc02023fc:	b7860613          	addi	a2,a2,-1160 # ffffffffc0206f70 <commands+0x758>
ffffffffc0202400:	06900593          	li	a1,105
ffffffffc0202404:	00005517          	auipc	a0,0x5
ffffffffc0202408:	b3450513          	addi	a0,a0,-1228 # ffffffffc0206f38 <commands+0x720>
ffffffffc020240c:	dfdfd0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(page != NULL);
ffffffffc0202410:	00005697          	auipc	a3,0x5
ffffffffc0202414:	13068693          	addi	a3,a3,304 # ffffffffc0207540 <commands+0xd28>
ffffffffc0202418:	00005617          	auipc	a2,0x5
ffffffffc020241c:	81060613          	addi	a2,a2,-2032 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202420:	17200593          	li	a1,370
ffffffffc0202424:	00005517          	auipc	a0,0x5
ffffffffc0202428:	b7450513          	addi	a0,a0,-1164 # ffffffffc0206f98 <commands+0x780>
ffffffffc020242c:	dddfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202430:	00005697          	auipc	a3,0x5
ffffffffc0202434:	ba868693          	addi	a3,a3,-1112 # ffffffffc0206fd8 <commands+0x7c0>
ffffffffc0202438:	00004617          	auipc	a2,0x4
ffffffffc020243c:	7f060613          	addi	a2,a2,2032 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202440:	15e00593          	li	a1,350
ffffffffc0202444:	00005517          	auipc	a0,0x5
ffffffffc0202448:	b5450513          	addi	a0,a0,-1196 # ffffffffc0206f98 <commands+0x780>
ffffffffc020244c:	dbdfd0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(npage != NULL);
ffffffffc0202450:	00005697          	auipc	a3,0x5
ffffffffc0202454:	10068693          	addi	a3,a3,256 # ffffffffc0207550 <commands+0xd38>
ffffffffc0202458:	00004617          	auipc	a2,0x4
ffffffffc020245c:	7d060613          	addi	a2,a2,2000 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202460:	17300593          	li	a1,371
ffffffffc0202464:	00005517          	auipc	a0,0x5
ffffffffc0202468:	b3450513          	addi	a0,a0,-1228 # ffffffffc0206f98 <commands+0x780>
ffffffffc020246c:	d9dfd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202470:	00005617          	auipc	a2,0x5
ffffffffc0202474:	aa860613          	addi	a2,a2,-1368 # ffffffffc0206f18 <commands+0x700>
ffffffffc0202478:	06200593          	li	a1,98
ffffffffc020247c:	00005517          	auipc	a0,0x5
ffffffffc0202480:	abc50513          	addi	a0,a0,-1348 # ffffffffc0206f38 <commands+0x720>
ffffffffc0202484:	d85fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202488:	00005617          	auipc	a2,0x5
ffffffffc020248c:	ac060613          	addi	a2,a2,-1344 # ffffffffc0206f48 <commands+0x730>
ffffffffc0202490:	07400593          	li	a1,116
ffffffffc0202494:	00005517          	auipc	a0,0x5
ffffffffc0202498:	aa450513          	addi	a0,a0,-1372 # ffffffffc0206f38 <commands+0x720>
ffffffffc020249c:	d6dfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02024a0:	00005697          	auipc	a3,0x5
ffffffffc02024a4:	b0868693          	addi	a3,a3,-1272 # ffffffffc0206fa8 <commands+0x790>
ffffffffc02024a8:	00004617          	auipc	a2,0x4
ffffffffc02024ac:	78060613          	addi	a2,a2,1920 # ffffffffc0206c28 <commands+0x410>
ffffffffc02024b0:	15d00593          	li	a1,349
ffffffffc02024b4:	00005517          	auipc	a0,0x5
ffffffffc02024b8:	ae450513          	addi	a0,a0,-1308 # ffffffffc0206f98 <commands+0x780>
ffffffffc02024bc:	d4dfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02024c0 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02024c0:	12058073          	sfence.vma	a1
}
ffffffffc02024c4:	8082                	ret

ffffffffc02024c6 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02024c6:	7179                	addi	sp,sp,-48
ffffffffc02024c8:	e84a                	sd	s2,16(sp)
ffffffffc02024ca:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02024cc:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02024ce:	f022                	sd	s0,32(sp)
ffffffffc02024d0:	ec26                	sd	s1,24(sp)
ffffffffc02024d2:	e44e                	sd	s3,8(sp)
ffffffffc02024d4:	f406                	sd	ra,40(sp)
ffffffffc02024d6:	84ae                	mv	s1,a1
ffffffffc02024d8:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02024da:	981fe0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02024de:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02024e0:	cd05                	beqz	a0,ffffffffc0202518 <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02024e2:	85aa                	mv	a1,a0
ffffffffc02024e4:	86ce                	mv	a3,s3
ffffffffc02024e6:	8626                	mv	a2,s1
ffffffffc02024e8:	854a                	mv	a0,s2
ffffffffc02024ea:	916ff0ef          	jal	ra,ffffffffc0201600 <page_insert>
ffffffffc02024ee:	ed0d                	bnez	a0,ffffffffc0202528 <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc02024f0:	000b0797          	auipc	a5,0xb0
ffffffffc02024f4:	4507a783          	lw	a5,1104(a5) # ffffffffc02b2940 <swap_init_ok>
ffffffffc02024f8:	c385                	beqz	a5,ffffffffc0202518 <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc02024fa:	000b0517          	auipc	a0,0xb0
ffffffffc02024fe:	41e53503          	ld	a0,1054(a0) # ffffffffc02b2918 <check_mm_struct>
ffffffffc0202502:	c919                	beqz	a0,ffffffffc0202518 <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202504:	4681                	li	a3,0
ffffffffc0202506:	8622                	mv	a2,s0
ffffffffc0202508:	85a6                	mv	a1,s1
ffffffffc020250a:	22f010ef          	jal	ra,ffffffffc0203f38 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc020250e:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0202510:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0202512:	4785                	li	a5,1
ffffffffc0202514:	04f71663          	bne	a4,a5,ffffffffc0202560 <pgdir_alloc_page+0x9a>
}
ffffffffc0202518:	70a2                	ld	ra,40(sp)
ffffffffc020251a:	8522                	mv	a0,s0
ffffffffc020251c:	7402                	ld	s0,32(sp)
ffffffffc020251e:	64e2                	ld	s1,24(sp)
ffffffffc0202520:	6942                	ld	s2,16(sp)
ffffffffc0202522:	69a2                	ld	s3,8(sp)
ffffffffc0202524:	6145                	addi	sp,sp,48
ffffffffc0202526:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202528:	100027f3          	csrr	a5,sstatus
ffffffffc020252c:	8b89                	andi	a5,a5,2
ffffffffc020252e:	eb99                	bnez	a5,ffffffffc0202544 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc0202530:	000b0797          	auipc	a5,0xb0
ffffffffc0202534:	3d87b783          	ld	a5,984(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc0202538:	739c                	ld	a5,32(a5)
ffffffffc020253a:	8522                	mv	a0,s0
ffffffffc020253c:	4585                	li	a1,1
ffffffffc020253e:	9782                	jalr	a5
            return NULL;
ffffffffc0202540:	4401                	li	s0,0
ffffffffc0202542:	bfd9                	j	ffffffffc0202518 <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0202544:	904fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202548:	000b0797          	auipc	a5,0xb0
ffffffffc020254c:	3c07b783          	ld	a5,960(a5) # ffffffffc02b2908 <pmm_manager>
ffffffffc0202550:	739c                	ld	a5,32(a5)
ffffffffc0202552:	8522                	mv	a0,s0
ffffffffc0202554:	4585                	li	a1,1
ffffffffc0202556:	9782                	jalr	a5
            return NULL;
ffffffffc0202558:	4401                	li	s0,0
        intr_enable();
ffffffffc020255a:	8e8fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020255e:	bf6d                	j	ffffffffc0202518 <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc0202560:	00005697          	auipc	a3,0x5
ffffffffc0202564:	01068693          	addi	a3,a3,16 # ffffffffc0207570 <commands+0xd58>
ffffffffc0202568:	00004617          	auipc	a2,0x4
ffffffffc020256c:	6c060613          	addi	a2,a2,1728 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202570:	1ca00593          	li	a1,458
ffffffffc0202574:	00005517          	auipc	a0,0x5
ffffffffc0202578:	a2450513          	addi	a0,a0,-1500 # ffffffffc0206f98 <commands+0x780>
ffffffffc020257c:	c8dfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202580 <_fifo_init_mm>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0202580:	000ac797          	auipc	a5,0xac
ffffffffc0202584:	28878793          	addi	a5,a5,648 # ffffffffc02ae808 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0202588:	f51c                	sd	a5,40(a0)
ffffffffc020258a:	e79c                	sd	a5,8(a5)
ffffffffc020258c:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc020258e:	4501                	li	a0,0
ffffffffc0202590:	8082                	ret

ffffffffc0202592 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0202592:	4501                	li	a0,0
ffffffffc0202594:	8082                	ret

ffffffffc0202596 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0202596:	4501                	li	a0,0
ffffffffc0202598:	8082                	ret

ffffffffc020259a <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020259a:	4501                	li	a0,0
ffffffffc020259c:	8082                	ret

ffffffffc020259e <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc020259e:	711d                	addi	sp,sp,-96
ffffffffc02025a0:	fc4e                	sd	s3,56(sp)
ffffffffc02025a2:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02025a4:	00005517          	auipc	a0,0x5
ffffffffc02025a8:	fe450513          	addi	a0,a0,-28 # ffffffffc0207588 <commands+0xd70>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02025ac:	698d                	lui	s3,0x3
ffffffffc02025ae:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02025b0:	e0ca                	sd	s2,64(sp)
ffffffffc02025b2:	ec86                	sd	ra,88(sp)
ffffffffc02025b4:	e8a2                	sd	s0,80(sp)
ffffffffc02025b6:	e4a6                	sd	s1,72(sp)
ffffffffc02025b8:	f456                	sd	s5,40(sp)
ffffffffc02025ba:	f05a                	sd	s6,32(sp)
ffffffffc02025bc:	ec5e                	sd	s7,24(sp)
ffffffffc02025be:	e862                	sd	s8,16(sp)
ffffffffc02025c0:	e466                	sd	s9,8(sp)
ffffffffc02025c2:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02025c4:	b09fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02025c8:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bc0>
    assert(pgfault_num==4);
ffffffffc02025cc:	000b0917          	auipc	s2,0xb0
ffffffffc02025d0:	35492903          	lw	s2,852(s2) # ffffffffc02b2920 <pgfault_num>
ffffffffc02025d4:	4791                	li	a5,4
ffffffffc02025d6:	14f91e63          	bne	s2,a5,ffffffffc0202732 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02025da:	00005517          	auipc	a0,0x5
ffffffffc02025de:	ffe50513          	addi	a0,a0,-2 # ffffffffc02075d8 <commands+0xdc0>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02025e2:	6a85                	lui	s5,0x1
ffffffffc02025e4:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02025e6:	ae7fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02025ea:	000b0417          	auipc	s0,0xb0
ffffffffc02025ee:	33640413          	addi	s0,s0,822 # ffffffffc02b2920 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02025f2:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
    assert(pgfault_num==4);
ffffffffc02025f6:	4004                	lw	s1,0(s0)
ffffffffc02025f8:	2481                	sext.w	s1,s1
ffffffffc02025fa:	2b249c63          	bne	s1,s2,ffffffffc02028b2 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02025fe:	00005517          	auipc	a0,0x5
ffffffffc0202602:	00250513          	addi	a0,a0,2 # ffffffffc0207600 <commands+0xde8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202606:	6b91                	lui	s7,0x4
ffffffffc0202608:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020260a:	ac3fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020260e:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bc0>
    assert(pgfault_num==4);
ffffffffc0202612:	00042903          	lw	s2,0(s0)
ffffffffc0202616:	2901                	sext.w	s2,s2
ffffffffc0202618:	26991d63          	bne	s2,s1,ffffffffc0202892 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020261c:	00005517          	auipc	a0,0x5
ffffffffc0202620:	00c50513          	addi	a0,a0,12 # ffffffffc0207628 <commands+0xe10>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202624:	6c89                	lui	s9,0x2
ffffffffc0202626:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202628:	aa5fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020262c:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bc0>
    assert(pgfault_num==4);
ffffffffc0202630:	401c                	lw	a5,0(s0)
ffffffffc0202632:	2781                	sext.w	a5,a5
ffffffffc0202634:	23279f63          	bne	a5,s2,ffffffffc0202872 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0202638:	00005517          	auipc	a0,0x5
ffffffffc020263c:	01850513          	addi	a0,a0,24 # ffffffffc0207650 <commands+0xe38>
ffffffffc0202640:	a8dfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202644:	6795                	lui	a5,0x5
ffffffffc0202646:	4739                	li	a4,14
ffffffffc0202648:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bc0>
    assert(pgfault_num==5);
ffffffffc020264c:	4004                	lw	s1,0(s0)
ffffffffc020264e:	4795                	li	a5,5
ffffffffc0202650:	2481                	sext.w	s1,s1
ffffffffc0202652:	20f49063          	bne	s1,a5,ffffffffc0202852 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202656:	00005517          	auipc	a0,0x5
ffffffffc020265a:	fd250513          	addi	a0,a0,-46 # ffffffffc0207628 <commands+0xe10>
ffffffffc020265e:	a6ffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202662:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0202666:	401c                	lw	a5,0(s0)
ffffffffc0202668:	2781                	sext.w	a5,a5
ffffffffc020266a:	1c979463          	bne	a5,s1,ffffffffc0202832 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020266e:	00005517          	auipc	a0,0x5
ffffffffc0202672:	f6a50513          	addi	a0,a0,-150 # ffffffffc02075d8 <commands+0xdc0>
ffffffffc0202676:	a57fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020267a:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc020267e:	401c                	lw	a5,0(s0)
ffffffffc0202680:	4719                	li	a4,6
ffffffffc0202682:	2781                	sext.w	a5,a5
ffffffffc0202684:	18e79763          	bne	a5,a4,ffffffffc0202812 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202688:	00005517          	auipc	a0,0x5
ffffffffc020268c:	fa050513          	addi	a0,a0,-96 # ffffffffc0207628 <commands+0xe10>
ffffffffc0202690:	a3dfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202694:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0202698:	401c                	lw	a5,0(s0)
ffffffffc020269a:	471d                	li	a4,7
ffffffffc020269c:	2781                	sext.w	a5,a5
ffffffffc020269e:	14e79a63          	bne	a5,a4,ffffffffc02027f2 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02026a2:	00005517          	auipc	a0,0x5
ffffffffc02026a6:	ee650513          	addi	a0,a0,-282 # ffffffffc0207588 <commands+0xd70>
ffffffffc02026aa:	a23fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02026ae:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02026b2:	401c                	lw	a5,0(s0)
ffffffffc02026b4:	4721                	li	a4,8
ffffffffc02026b6:	2781                	sext.w	a5,a5
ffffffffc02026b8:	10e79d63          	bne	a5,a4,ffffffffc02027d2 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02026bc:	00005517          	auipc	a0,0x5
ffffffffc02026c0:	f4450513          	addi	a0,a0,-188 # ffffffffc0207600 <commands+0xde8>
ffffffffc02026c4:	a09fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02026c8:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02026cc:	401c                	lw	a5,0(s0)
ffffffffc02026ce:	4725                	li	a4,9
ffffffffc02026d0:	2781                	sext.w	a5,a5
ffffffffc02026d2:	0ee79063          	bne	a5,a4,ffffffffc02027b2 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02026d6:	00005517          	auipc	a0,0x5
ffffffffc02026da:	f7a50513          	addi	a0,a0,-134 # ffffffffc0207650 <commands+0xe38>
ffffffffc02026de:	9effd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02026e2:	6795                	lui	a5,0x5
ffffffffc02026e4:	4739                	li	a4,14
ffffffffc02026e6:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bc0>
    assert(pgfault_num==10);
ffffffffc02026ea:	4004                	lw	s1,0(s0)
ffffffffc02026ec:	47a9                	li	a5,10
ffffffffc02026ee:	2481                	sext.w	s1,s1
ffffffffc02026f0:	0af49163          	bne	s1,a5,ffffffffc0202792 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02026f4:	00005517          	auipc	a0,0x5
ffffffffc02026f8:	ee450513          	addi	a0,a0,-284 # ffffffffc02075d8 <commands+0xdc0>
ffffffffc02026fc:	9d1fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202700:	6785                	lui	a5,0x1
ffffffffc0202702:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0202706:	06979663          	bne	a5,s1,ffffffffc0202772 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc020270a:	401c                	lw	a5,0(s0)
ffffffffc020270c:	472d                	li	a4,11
ffffffffc020270e:	2781                	sext.w	a5,a5
ffffffffc0202710:	04e79163          	bne	a5,a4,ffffffffc0202752 <_fifo_check_swap+0x1b4>
}
ffffffffc0202714:	60e6                	ld	ra,88(sp)
ffffffffc0202716:	6446                	ld	s0,80(sp)
ffffffffc0202718:	64a6                	ld	s1,72(sp)
ffffffffc020271a:	6906                	ld	s2,64(sp)
ffffffffc020271c:	79e2                	ld	s3,56(sp)
ffffffffc020271e:	7a42                	ld	s4,48(sp)
ffffffffc0202720:	7aa2                	ld	s5,40(sp)
ffffffffc0202722:	7b02                	ld	s6,32(sp)
ffffffffc0202724:	6be2                	ld	s7,24(sp)
ffffffffc0202726:	6c42                	ld	s8,16(sp)
ffffffffc0202728:	6ca2                	ld	s9,8(sp)
ffffffffc020272a:	6d02                	ld	s10,0(sp)
ffffffffc020272c:	4501                	li	a0,0
ffffffffc020272e:	6125                	addi	sp,sp,96
ffffffffc0202730:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0202732:	00005697          	auipc	a3,0x5
ffffffffc0202736:	e7e68693          	addi	a3,a3,-386 # ffffffffc02075b0 <commands+0xd98>
ffffffffc020273a:	00004617          	auipc	a2,0x4
ffffffffc020273e:	4ee60613          	addi	a2,a2,1262 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202742:	05500593          	li	a1,85
ffffffffc0202746:	00005517          	auipc	a0,0x5
ffffffffc020274a:	e7a50513          	addi	a0,a0,-390 # ffffffffc02075c0 <commands+0xda8>
ffffffffc020274e:	abbfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==11);
ffffffffc0202752:	00005697          	auipc	a3,0x5
ffffffffc0202756:	fae68693          	addi	a3,a3,-82 # ffffffffc0207700 <commands+0xee8>
ffffffffc020275a:	00004617          	auipc	a2,0x4
ffffffffc020275e:	4ce60613          	addi	a2,a2,1230 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202762:	07700593          	li	a1,119
ffffffffc0202766:	00005517          	auipc	a0,0x5
ffffffffc020276a:	e5a50513          	addi	a0,a0,-422 # ffffffffc02075c0 <commands+0xda8>
ffffffffc020276e:	a9bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202772:	00005697          	auipc	a3,0x5
ffffffffc0202776:	f6668693          	addi	a3,a3,-154 # ffffffffc02076d8 <commands+0xec0>
ffffffffc020277a:	00004617          	auipc	a2,0x4
ffffffffc020277e:	4ae60613          	addi	a2,a2,1198 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202782:	07500593          	li	a1,117
ffffffffc0202786:	00005517          	auipc	a0,0x5
ffffffffc020278a:	e3a50513          	addi	a0,a0,-454 # ffffffffc02075c0 <commands+0xda8>
ffffffffc020278e:	a7bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==10);
ffffffffc0202792:	00005697          	auipc	a3,0x5
ffffffffc0202796:	f3668693          	addi	a3,a3,-202 # ffffffffc02076c8 <commands+0xeb0>
ffffffffc020279a:	00004617          	auipc	a2,0x4
ffffffffc020279e:	48e60613          	addi	a2,a2,1166 # ffffffffc0206c28 <commands+0x410>
ffffffffc02027a2:	07300593          	li	a1,115
ffffffffc02027a6:	00005517          	auipc	a0,0x5
ffffffffc02027aa:	e1a50513          	addi	a0,a0,-486 # ffffffffc02075c0 <commands+0xda8>
ffffffffc02027ae:	a5bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==9);
ffffffffc02027b2:	00005697          	auipc	a3,0x5
ffffffffc02027b6:	f0668693          	addi	a3,a3,-250 # ffffffffc02076b8 <commands+0xea0>
ffffffffc02027ba:	00004617          	auipc	a2,0x4
ffffffffc02027be:	46e60613          	addi	a2,a2,1134 # ffffffffc0206c28 <commands+0x410>
ffffffffc02027c2:	07000593          	li	a1,112
ffffffffc02027c6:	00005517          	auipc	a0,0x5
ffffffffc02027ca:	dfa50513          	addi	a0,a0,-518 # ffffffffc02075c0 <commands+0xda8>
ffffffffc02027ce:	a3bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==8);
ffffffffc02027d2:	00005697          	auipc	a3,0x5
ffffffffc02027d6:	ed668693          	addi	a3,a3,-298 # ffffffffc02076a8 <commands+0xe90>
ffffffffc02027da:	00004617          	auipc	a2,0x4
ffffffffc02027de:	44e60613          	addi	a2,a2,1102 # ffffffffc0206c28 <commands+0x410>
ffffffffc02027e2:	06d00593          	li	a1,109
ffffffffc02027e6:	00005517          	auipc	a0,0x5
ffffffffc02027ea:	dda50513          	addi	a0,a0,-550 # ffffffffc02075c0 <commands+0xda8>
ffffffffc02027ee:	a1bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==7);
ffffffffc02027f2:	00005697          	auipc	a3,0x5
ffffffffc02027f6:	ea668693          	addi	a3,a3,-346 # ffffffffc0207698 <commands+0xe80>
ffffffffc02027fa:	00004617          	auipc	a2,0x4
ffffffffc02027fe:	42e60613          	addi	a2,a2,1070 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202802:	06a00593          	li	a1,106
ffffffffc0202806:	00005517          	auipc	a0,0x5
ffffffffc020280a:	dba50513          	addi	a0,a0,-582 # ffffffffc02075c0 <commands+0xda8>
ffffffffc020280e:	9fbfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==6);
ffffffffc0202812:	00005697          	auipc	a3,0x5
ffffffffc0202816:	e7668693          	addi	a3,a3,-394 # ffffffffc0207688 <commands+0xe70>
ffffffffc020281a:	00004617          	auipc	a2,0x4
ffffffffc020281e:	40e60613          	addi	a2,a2,1038 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202822:	06700593          	li	a1,103
ffffffffc0202826:	00005517          	auipc	a0,0x5
ffffffffc020282a:	d9a50513          	addi	a0,a0,-614 # ffffffffc02075c0 <commands+0xda8>
ffffffffc020282e:	9dbfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0202832:	00005697          	auipc	a3,0x5
ffffffffc0202836:	e4668693          	addi	a3,a3,-442 # ffffffffc0207678 <commands+0xe60>
ffffffffc020283a:	00004617          	auipc	a2,0x4
ffffffffc020283e:	3ee60613          	addi	a2,a2,1006 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202842:	06400593          	li	a1,100
ffffffffc0202846:	00005517          	auipc	a0,0x5
ffffffffc020284a:	d7a50513          	addi	a0,a0,-646 # ffffffffc02075c0 <commands+0xda8>
ffffffffc020284e:	9bbfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0202852:	00005697          	auipc	a3,0x5
ffffffffc0202856:	e2668693          	addi	a3,a3,-474 # ffffffffc0207678 <commands+0xe60>
ffffffffc020285a:	00004617          	auipc	a2,0x4
ffffffffc020285e:	3ce60613          	addi	a2,a2,974 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202862:	06100593          	li	a1,97
ffffffffc0202866:	00005517          	auipc	a0,0x5
ffffffffc020286a:	d5a50513          	addi	a0,a0,-678 # ffffffffc02075c0 <commands+0xda8>
ffffffffc020286e:	99bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0202872:	00005697          	auipc	a3,0x5
ffffffffc0202876:	d3e68693          	addi	a3,a3,-706 # ffffffffc02075b0 <commands+0xd98>
ffffffffc020287a:	00004617          	auipc	a2,0x4
ffffffffc020287e:	3ae60613          	addi	a2,a2,942 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202882:	05e00593          	li	a1,94
ffffffffc0202886:	00005517          	auipc	a0,0x5
ffffffffc020288a:	d3a50513          	addi	a0,a0,-710 # ffffffffc02075c0 <commands+0xda8>
ffffffffc020288e:	97bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0202892:	00005697          	auipc	a3,0x5
ffffffffc0202896:	d1e68693          	addi	a3,a3,-738 # ffffffffc02075b0 <commands+0xd98>
ffffffffc020289a:	00004617          	auipc	a2,0x4
ffffffffc020289e:	38e60613          	addi	a2,a2,910 # ffffffffc0206c28 <commands+0x410>
ffffffffc02028a2:	05b00593          	li	a1,91
ffffffffc02028a6:	00005517          	auipc	a0,0x5
ffffffffc02028aa:	d1a50513          	addi	a0,a0,-742 # ffffffffc02075c0 <commands+0xda8>
ffffffffc02028ae:	95bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc02028b2:	00005697          	auipc	a3,0x5
ffffffffc02028b6:	cfe68693          	addi	a3,a3,-770 # ffffffffc02075b0 <commands+0xd98>
ffffffffc02028ba:	00004617          	auipc	a2,0x4
ffffffffc02028be:	36e60613          	addi	a2,a2,878 # ffffffffc0206c28 <commands+0x410>
ffffffffc02028c2:	05800593          	li	a1,88
ffffffffc02028c6:	00005517          	auipc	a0,0x5
ffffffffc02028ca:	cfa50513          	addi	a0,a0,-774 # ffffffffc02075c0 <commands+0xda8>
ffffffffc02028ce:	93bfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02028d2 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02028d2:	7518                	ld	a4,40(a0)
{
ffffffffc02028d4:	1141                	addi	sp,sp,-16
ffffffffc02028d6:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02028d8:	c731                	beqz	a4,ffffffffc0202924 <_fifo_swap_out_victim+0x52>
     assert(in_tick==0);
ffffffffc02028da:	e60d                	bnez	a2,ffffffffc0202904 <_fifo_swap_out_victim+0x32>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02028dc:	671c                	ld	a5,8(a4)
    if (entry != head) {
ffffffffc02028de:	00f70d63          	beq	a4,a5,ffffffffc02028f8 <_fifo_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02028e2:	6394                	ld	a3,0(a5)
ffffffffc02028e4:	6798                	ld	a4,8(a5)
}
ffffffffc02028e6:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc02028e8:	fd878793          	addi	a5,a5,-40
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02028ec:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02028ee:	e314                	sd	a3,0(a4)
ffffffffc02028f0:	e19c                	sd	a5,0(a1)
}
ffffffffc02028f2:	4501                	li	a0,0
ffffffffc02028f4:	0141                	addi	sp,sp,16
ffffffffc02028f6:	8082                	ret
ffffffffc02028f8:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc02028fa:	0005b023          	sd	zero,0(a1)
}
ffffffffc02028fe:	4501                	li	a0,0
ffffffffc0202900:	0141                	addi	sp,sp,16
ffffffffc0202902:	8082                	ret
     assert(in_tick==0);
ffffffffc0202904:	00005697          	auipc	a3,0x5
ffffffffc0202908:	e1c68693          	addi	a3,a3,-484 # ffffffffc0207720 <commands+0xf08>
ffffffffc020290c:	00004617          	auipc	a2,0x4
ffffffffc0202910:	31c60613          	addi	a2,a2,796 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202914:	04200593          	li	a1,66
ffffffffc0202918:	00005517          	auipc	a0,0x5
ffffffffc020291c:	ca850513          	addi	a0,a0,-856 # ffffffffc02075c0 <commands+0xda8>
ffffffffc0202920:	8e9fd0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(head != NULL);
ffffffffc0202924:	00005697          	auipc	a3,0x5
ffffffffc0202928:	dec68693          	addi	a3,a3,-532 # ffffffffc0207710 <commands+0xef8>
ffffffffc020292c:	00004617          	auipc	a2,0x4
ffffffffc0202930:	2fc60613          	addi	a2,a2,764 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202934:	04100593          	li	a1,65
ffffffffc0202938:	00005517          	auipc	a0,0x5
ffffffffc020293c:	c8850513          	addi	a0,a0,-888 # ffffffffc02075c0 <commands+0xda8>
ffffffffc0202940:	8c9fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202944 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202944:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0202946:	cb91                	beqz	a5,ffffffffc020295a <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202948:	6394                	ld	a3,0(a5)
ffffffffc020294a:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc020294e:	e398                	sd	a4,0(a5)
ffffffffc0202950:	e698                	sd	a4,8(a3)
}
ffffffffc0202952:	4501                	li	a0,0
    elm->next = next;
ffffffffc0202954:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0202956:	f614                	sd	a3,40(a2)
ffffffffc0202958:	8082                	ret
{
ffffffffc020295a:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc020295c:	00005697          	auipc	a3,0x5
ffffffffc0202960:	dd468693          	addi	a3,a3,-556 # ffffffffc0207730 <commands+0xf18>
ffffffffc0202964:	00004617          	auipc	a2,0x4
ffffffffc0202968:	2c460613          	addi	a2,a2,708 # ffffffffc0206c28 <commands+0x410>
ffffffffc020296c:	03200593          	li	a1,50
ffffffffc0202970:	00005517          	auipc	a0,0x5
ffffffffc0202974:	c5050513          	addi	a0,a0,-944 # ffffffffc02075c0 <commands+0xda8>
{
ffffffffc0202978:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020297a:	88ffd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020297e <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020297e:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0202980:	00005697          	auipc	a3,0x5
ffffffffc0202984:	de868693          	addi	a3,a3,-536 # ffffffffc0207768 <commands+0xf50>
ffffffffc0202988:	00004617          	auipc	a2,0x4
ffffffffc020298c:	2a060613          	addi	a2,a2,672 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202990:	06d00593          	li	a1,109
ffffffffc0202994:	00005517          	auipc	a0,0x5
ffffffffc0202998:	df450513          	addi	a0,a0,-524 # ffffffffc0207788 <commands+0xf70>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020299c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020299e:	86bfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02029a2 <mm_create>:
mm_create(void) {
ffffffffc02029a2:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02029a4:	04000513          	li	a0,64
mm_create(void) {
ffffffffc02029a8:	e022                	sd	s0,0(sp)
ffffffffc02029aa:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02029ac:	475000ef          	jal	ra,ffffffffc0203620 <kmalloc>
ffffffffc02029b0:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02029b2:	c505                	beqz	a0,ffffffffc02029da <mm_create+0x38>
    elm->prev = elm->next = elm;
ffffffffc02029b4:	e408                	sd	a0,8(s0)
ffffffffc02029b6:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02029b8:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02029bc:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02029c0:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02029c4:	000b0797          	auipc	a5,0xb0
ffffffffc02029c8:	f7c7a783          	lw	a5,-132(a5) # ffffffffc02b2940 <swap_init_ok>
ffffffffc02029cc:	ef81                	bnez	a5,ffffffffc02029e4 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc02029ce:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02029d2:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02029d6:	02043c23          	sd	zero,56(s0)
}
ffffffffc02029da:	60a2                	ld	ra,8(sp)
ffffffffc02029dc:	8522                	mv	a0,s0
ffffffffc02029de:	6402                	ld	s0,0(sp)
ffffffffc02029e0:	0141                	addi	sp,sp,16
ffffffffc02029e2:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02029e4:	548010ef          	jal	ra,ffffffffc0203f2c <swap_init_mm>
ffffffffc02029e8:	b7ed                	j	ffffffffc02029d2 <mm_create+0x30>

ffffffffc02029ea <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02029ea:	1101                	addi	sp,sp,-32
ffffffffc02029ec:	e04a                	sd	s2,0(sp)
ffffffffc02029ee:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02029f0:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02029f4:	e822                	sd	s0,16(sp)
ffffffffc02029f6:	e426                	sd	s1,8(sp)
ffffffffc02029f8:	ec06                	sd	ra,24(sp)
ffffffffc02029fa:	84ae                	mv	s1,a1
ffffffffc02029fc:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02029fe:	423000ef          	jal	ra,ffffffffc0203620 <kmalloc>
    if (vma != NULL) {
ffffffffc0202a02:	c509                	beqz	a0,ffffffffc0202a0c <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0202a04:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202a08:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202a0a:	cd00                	sw	s0,24(a0)
}
ffffffffc0202a0c:	60e2                	ld	ra,24(sp)
ffffffffc0202a0e:	6442                	ld	s0,16(sp)
ffffffffc0202a10:	64a2                	ld	s1,8(sp)
ffffffffc0202a12:	6902                	ld	s2,0(sp)
ffffffffc0202a14:	6105                	addi	sp,sp,32
ffffffffc0202a16:	8082                	ret

ffffffffc0202a18 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0202a18:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0202a1a:	c505                	beqz	a0,ffffffffc0202a42 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0202a1c:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202a1e:	c501                	beqz	a0,ffffffffc0202a26 <find_vma+0xe>
ffffffffc0202a20:	651c                	ld	a5,8(a0)
ffffffffc0202a22:	02f5f263          	bgeu	a1,a5,ffffffffc0202a46 <find_vma+0x2e>
    return listelm->next;
ffffffffc0202a26:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0202a28:	00f68d63          	beq	a3,a5,ffffffffc0202a42 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0202a2c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202a30:	00e5e663          	bltu	a1,a4,ffffffffc0202a3c <find_vma+0x24>
ffffffffc0202a34:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202a38:	00e5ec63          	bltu	a1,a4,ffffffffc0202a50 <find_vma+0x38>
ffffffffc0202a3c:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0202a3e:	fef697e3          	bne	a3,a5,ffffffffc0202a2c <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0202a42:	4501                	li	a0,0
}
ffffffffc0202a44:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202a46:	691c                	ld	a5,16(a0)
ffffffffc0202a48:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0202a26 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0202a4c:	ea88                	sd	a0,16(a3)
ffffffffc0202a4e:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0202a50:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0202a54:	ea88                	sd	a0,16(a3)
ffffffffc0202a56:	8082                	ret

ffffffffc0202a58 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202a58:	6590                	ld	a2,8(a1)
ffffffffc0202a5a:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0202a5e:	1141                	addi	sp,sp,-16
ffffffffc0202a60:	e406                	sd	ra,8(sp)
ffffffffc0202a62:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202a64:	01066763          	bltu	a2,a6,ffffffffc0202a72 <insert_vma_struct+0x1a>
ffffffffc0202a68:	a085                	j	ffffffffc0202ac8 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0202a6a:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202a6e:	04e66863          	bltu	a2,a4,ffffffffc0202abe <insert_vma_struct+0x66>
ffffffffc0202a72:	86be                	mv	a3,a5
ffffffffc0202a74:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0202a76:	fef51ae3          	bne	a0,a5,ffffffffc0202a6a <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0202a7a:	02a68463          	beq	a3,a0,ffffffffc0202aa2 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0202a7e:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202a82:	fe86b883          	ld	a7,-24(a3)
ffffffffc0202a86:	08e8f163          	bgeu	a7,a4,ffffffffc0202b08 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202a8a:	04e66f63          	bltu	a2,a4,ffffffffc0202ae8 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0202a8e:	00f50a63          	beq	a0,a5,ffffffffc0202aa2 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0202a92:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202a96:	05076963          	bltu	a4,a6,ffffffffc0202ae8 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0202a9a:	ff07b603          	ld	a2,-16(a5)
ffffffffc0202a9e:	02c77363          	bgeu	a4,a2,ffffffffc0202ac4 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0202aa2:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0202aa4:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0202aa6:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0202aaa:	e390                	sd	a2,0(a5)
ffffffffc0202aac:	e690                	sd	a2,8(a3)
}
ffffffffc0202aae:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0202ab0:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0202ab2:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0202ab4:	0017079b          	addiw	a5,a4,1
ffffffffc0202ab8:	d11c                	sw	a5,32(a0)
}
ffffffffc0202aba:	0141                	addi	sp,sp,16
ffffffffc0202abc:	8082                	ret
    if (le_prev != list) {
ffffffffc0202abe:	fca690e3          	bne	a3,a0,ffffffffc0202a7e <insert_vma_struct+0x26>
ffffffffc0202ac2:	bfd1                	j	ffffffffc0202a96 <insert_vma_struct+0x3e>
ffffffffc0202ac4:	ebbff0ef          	jal	ra,ffffffffc020297e <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202ac8:	00005697          	auipc	a3,0x5
ffffffffc0202acc:	cd068693          	addi	a3,a3,-816 # ffffffffc0207798 <commands+0xf80>
ffffffffc0202ad0:	00004617          	auipc	a2,0x4
ffffffffc0202ad4:	15860613          	addi	a2,a2,344 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202ad8:	07400593          	li	a1,116
ffffffffc0202adc:	00005517          	auipc	a0,0x5
ffffffffc0202ae0:	cac50513          	addi	a0,a0,-852 # ffffffffc0207788 <commands+0xf70>
ffffffffc0202ae4:	f24fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202ae8:	00005697          	auipc	a3,0x5
ffffffffc0202aec:	cf068693          	addi	a3,a3,-784 # ffffffffc02077d8 <commands+0xfc0>
ffffffffc0202af0:	00004617          	auipc	a2,0x4
ffffffffc0202af4:	13860613          	addi	a2,a2,312 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202af8:	06c00593          	li	a1,108
ffffffffc0202afc:	00005517          	auipc	a0,0x5
ffffffffc0202b00:	c8c50513          	addi	a0,a0,-884 # ffffffffc0207788 <commands+0xf70>
ffffffffc0202b04:	f04fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202b08:	00005697          	auipc	a3,0x5
ffffffffc0202b0c:	cb068693          	addi	a3,a3,-848 # ffffffffc02077b8 <commands+0xfa0>
ffffffffc0202b10:	00004617          	auipc	a2,0x4
ffffffffc0202b14:	11860613          	addi	a2,a2,280 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202b18:	06b00593          	li	a1,107
ffffffffc0202b1c:	00005517          	auipc	a0,0x5
ffffffffc0202b20:	c6c50513          	addi	a0,a0,-916 # ffffffffc0207788 <commands+0xf70>
ffffffffc0202b24:	ee4fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202b28 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0202b28:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0202b2a:	1141                	addi	sp,sp,-16
ffffffffc0202b2c:	e406                	sd	ra,8(sp)
ffffffffc0202b2e:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0202b30:	e78d                	bnez	a5,ffffffffc0202b5a <mm_destroy+0x32>
ffffffffc0202b32:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0202b34:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0202b36:	00a40c63          	beq	s0,a0,ffffffffc0202b4e <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202b3a:	6118                	ld	a4,0(a0)
ffffffffc0202b3c:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0202b3e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0202b40:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202b42:	e398                	sd	a4,0(a5)
ffffffffc0202b44:	38d000ef          	jal	ra,ffffffffc02036d0 <kfree>
    return listelm->next;
ffffffffc0202b48:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0202b4a:	fea418e3          	bne	s0,a0,ffffffffc0202b3a <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0202b4e:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0202b50:	6402                	ld	s0,0(sp)
ffffffffc0202b52:	60a2                	ld	ra,8(sp)
ffffffffc0202b54:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0202b56:	37b0006f          	j	ffffffffc02036d0 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0202b5a:	00005697          	auipc	a3,0x5
ffffffffc0202b5e:	c9e68693          	addi	a3,a3,-866 # ffffffffc02077f8 <commands+0xfe0>
ffffffffc0202b62:	00004617          	auipc	a2,0x4
ffffffffc0202b66:	0c660613          	addi	a2,a2,198 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202b6a:	09400593          	li	a1,148
ffffffffc0202b6e:	00005517          	auipc	a0,0x5
ffffffffc0202b72:	c1a50513          	addi	a0,a0,-998 # ffffffffc0207788 <commands+0xf70>
ffffffffc0202b76:	e92fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202b7a <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc0202b7a:	7139                	addi	sp,sp,-64
ffffffffc0202b7c:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202b7e:	6405                	lui	s0,0x1
ffffffffc0202b80:	147d                	addi	s0,s0,-1
ffffffffc0202b82:	77fd                	lui	a5,0xfffff
ffffffffc0202b84:	9622                	add	a2,a2,s0
ffffffffc0202b86:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc0202b88:	f426                	sd	s1,40(sp)
ffffffffc0202b8a:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202b8c:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc0202b90:	f04a                	sd	s2,32(sp)
ffffffffc0202b92:	ec4e                	sd	s3,24(sp)
ffffffffc0202b94:	e852                	sd	s4,16(sp)
ffffffffc0202b96:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc0202b98:	002005b7          	lui	a1,0x200
ffffffffc0202b9c:	00f67433          	and	s0,a2,a5
ffffffffc0202ba0:	06b4e363          	bltu	s1,a1,ffffffffc0202c06 <mm_map+0x8c>
ffffffffc0202ba4:	0684f163          	bgeu	s1,s0,ffffffffc0202c06 <mm_map+0x8c>
ffffffffc0202ba8:	4785                	li	a5,1
ffffffffc0202baa:	07fe                	slli	a5,a5,0x1f
ffffffffc0202bac:	0487ed63          	bltu	a5,s0,ffffffffc0202c06 <mm_map+0x8c>
ffffffffc0202bb0:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0202bb2:	cd21                	beqz	a0,ffffffffc0202c0a <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0202bb4:	85a6                	mv	a1,s1
ffffffffc0202bb6:	8ab6                	mv	s5,a3
ffffffffc0202bb8:	8a3a                	mv	s4,a4
ffffffffc0202bba:	e5fff0ef          	jal	ra,ffffffffc0202a18 <find_vma>
ffffffffc0202bbe:	c501                	beqz	a0,ffffffffc0202bc6 <mm_map+0x4c>
ffffffffc0202bc0:	651c                	ld	a5,8(a0)
ffffffffc0202bc2:	0487e263          	bltu	a5,s0,ffffffffc0202c06 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202bc6:	03000513          	li	a0,48
ffffffffc0202bca:	257000ef          	jal	ra,ffffffffc0203620 <kmalloc>
ffffffffc0202bce:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0202bd0:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0202bd2:	02090163          	beqz	s2,ffffffffc0202bf4 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0202bd6:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0202bd8:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0202bdc:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0202be0:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0202be4:	85ca                	mv	a1,s2
ffffffffc0202be6:	e73ff0ef          	jal	ra,ffffffffc0202a58 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0202bea:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0202bec:	000a0463          	beqz	s4,ffffffffc0202bf4 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0202bf0:	012a3023          	sd	s2,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>

out:
    return ret;
}
ffffffffc0202bf4:	70e2                	ld	ra,56(sp)
ffffffffc0202bf6:	7442                	ld	s0,48(sp)
ffffffffc0202bf8:	74a2                	ld	s1,40(sp)
ffffffffc0202bfa:	7902                	ld	s2,32(sp)
ffffffffc0202bfc:	69e2                	ld	s3,24(sp)
ffffffffc0202bfe:	6a42                	ld	s4,16(sp)
ffffffffc0202c00:	6aa2                	ld	s5,8(sp)
ffffffffc0202c02:	6121                	addi	sp,sp,64
ffffffffc0202c04:	8082                	ret
        return -E_INVAL;
ffffffffc0202c06:	5575                	li	a0,-3
ffffffffc0202c08:	b7f5                	j	ffffffffc0202bf4 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0202c0a:	00005697          	auipc	a3,0x5
ffffffffc0202c0e:	c0668693          	addi	a3,a3,-1018 # ffffffffc0207810 <commands+0xff8>
ffffffffc0202c12:	00004617          	auipc	a2,0x4
ffffffffc0202c16:	01660613          	addi	a2,a2,22 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202c1a:	0a700593          	li	a1,167
ffffffffc0202c1e:	00005517          	auipc	a0,0x5
ffffffffc0202c22:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0207788 <commands+0xf70>
ffffffffc0202c26:	de2fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202c2a <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0202c2a:	7139                	addi	sp,sp,-64
ffffffffc0202c2c:	fc06                	sd	ra,56(sp)
ffffffffc0202c2e:	f822                	sd	s0,48(sp)
ffffffffc0202c30:	f426                	sd	s1,40(sp)
ffffffffc0202c32:	f04a                	sd	s2,32(sp)
ffffffffc0202c34:	ec4e                	sd	s3,24(sp)
ffffffffc0202c36:	e852                	sd	s4,16(sp)
ffffffffc0202c38:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0202c3a:	c52d                	beqz	a0,ffffffffc0202ca4 <dup_mmap+0x7a>
ffffffffc0202c3c:	892a                	mv	s2,a0
ffffffffc0202c3e:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0202c40:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0202c42:	e595                	bnez	a1,ffffffffc0202c6e <dup_mmap+0x44>
ffffffffc0202c44:	a085                	j	ffffffffc0202ca4 <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0202c46:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0202c48:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ed8>
        vma->vm_end = vm_end;
ffffffffc0202c4c:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0202c50:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0202c54:	e05ff0ef          	jal	ra,ffffffffc0202a58 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0202c58:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bd0>
ffffffffc0202c5c:	fe843603          	ld	a2,-24(s0)
ffffffffc0202c60:	6c8c                	ld	a1,24(s1)
ffffffffc0202c62:	01893503          	ld	a0,24(s2)
ffffffffc0202c66:	4701                	li	a4,0
ffffffffc0202c68:	e28ff0ef          	jal	ra,ffffffffc0202290 <copy_range>
ffffffffc0202c6c:	e105                	bnez	a0,ffffffffc0202c8c <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0202c6e:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0202c70:	02848863          	beq	s1,s0,ffffffffc0202ca0 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202c74:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0202c78:	fe843a83          	ld	s5,-24(s0)
ffffffffc0202c7c:	ff043a03          	ld	s4,-16(s0)
ffffffffc0202c80:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202c84:	19d000ef          	jal	ra,ffffffffc0203620 <kmalloc>
ffffffffc0202c88:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc0202c8a:	fd55                	bnez	a0,ffffffffc0202c46 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0202c8c:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0202c8e:	70e2                	ld	ra,56(sp)
ffffffffc0202c90:	7442                	ld	s0,48(sp)
ffffffffc0202c92:	74a2                	ld	s1,40(sp)
ffffffffc0202c94:	7902                	ld	s2,32(sp)
ffffffffc0202c96:	69e2                	ld	s3,24(sp)
ffffffffc0202c98:	6a42                	ld	s4,16(sp)
ffffffffc0202c9a:	6aa2                	ld	s5,8(sp)
ffffffffc0202c9c:	6121                	addi	sp,sp,64
ffffffffc0202c9e:	8082                	ret
    return 0;
ffffffffc0202ca0:	4501                	li	a0,0
ffffffffc0202ca2:	b7f5                	j	ffffffffc0202c8e <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0202ca4:	00005697          	auipc	a3,0x5
ffffffffc0202ca8:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0207820 <commands+0x1008>
ffffffffc0202cac:	00004617          	auipc	a2,0x4
ffffffffc0202cb0:	f7c60613          	addi	a2,a2,-132 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202cb4:	0c000593          	li	a1,192
ffffffffc0202cb8:	00005517          	auipc	a0,0x5
ffffffffc0202cbc:	ad050513          	addi	a0,a0,-1328 # ffffffffc0207788 <commands+0xf70>
ffffffffc0202cc0:	d48fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202cc4 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0202cc4:	1101                	addi	sp,sp,-32
ffffffffc0202cc6:	ec06                	sd	ra,24(sp)
ffffffffc0202cc8:	e822                	sd	s0,16(sp)
ffffffffc0202cca:	e426                	sd	s1,8(sp)
ffffffffc0202ccc:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202cce:	c531                	beqz	a0,ffffffffc0202d1a <exit_mmap+0x56>
ffffffffc0202cd0:	591c                	lw	a5,48(a0)
ffffffffc0202cd2:	84aa                	mv	s1,a0
ffffffffc0202cd4:	e3b9                	bnez	a5,ffffffffc0202d1a <exit_mmap+0x56>
    return listelm->next;
ffffffffc0202cd6:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0202cd8:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0202cdc:	02850663          	beq	a0,s0,ffffffffc0202d08 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202ce0:	ff043603          	ld	a2,-16(s0)
ffffffffc0202ce4:	fe843583          	ld	a1,-24(s0)
ffffffffc0202ce8:	854a                	mv	a0,s2
ffffffffc0202cea:	ca2fe0ef          	jal	ra,ffffffffc020118c <unmap_range>
ffffffffc0202cee:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202cf0:	fe8498e3          	bne	s1,s0,ffffffffc0202ce0 <exit_mmap+0x1c>
ffffffffc0202cf4:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0202cf6:	00848c63          	beq	s1,s0,ffffffffc0202d0e <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202cfa:	ff043603          	ld	a2,-16(s0)
ffffffffc0202cfe:	fe843583          	ld	a1,-24(s0)
ffffffffc0202d02:	854a                	mv	a0,s2
ffffffffc0202d04:	dcefe0ef          	jal	ra,ffffffffc02012d2 <exit_range>
ffffffffc0202d08:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202d0a:	fe8498e3          	bne	s1,s0,ffffffffc0202cfa <exit_mmap+0x36>
    }
}
ffffffffc0202d0e:	60e2                	ld	ra,24(sp)
ffffffffc0202d10:	6442                	ld	s0,16(sp)
ffffffffc0202d12:	64a2                	ld	s1,8(sp)
ffffffffc0202d14:	6902                	ld	s2,0(sp)
ffffffffc0202d16:	6105                	addi	sp,sp,32
ffffffffc0202d18:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202d1a:	00005697          	auipc	a3,0x5
ffffffffc0202d1e:	b2668693          	addi	a3,a3,-1242 # ffffffffc0207840 <commands+0x1028>
ffffffffc0202d22:	00004617          	auipc	a2,0x4
ffffffffc0202d26:	f0660613          	addi	a2,a2,-250 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202d2a:	0d600593          	li	a1,214
ffffffffc0202d2e:	00005517          	auipc	a0,0x5
ffffffffc0202d32:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0207788 <commands+0xf70>
ffffffffc0202d36:	cd2fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202d3a <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0202d3a:	7139                	addi	sp,sp,-64
ffffffffc0202d3c:	f822                	sd	s0,48(sp)
ffffffffc0202d3e:	f426                	sd	s1,40(sp)
ffffffffc0202d40:	fc06                	sd	ra,56(sp)
ffffffffc0202d42:	f04a                	sd	s2,32(sp)
ffffffffc0202d44:	ec4e                	sd	s3,24(sp)
ffffffffc0202d46:	e852                	sd	s4,16(sp)
ffffffffc0202d48:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0202d4a:	c59ff0ef          	jal	ra,ffffffffc02029a2 <mm_create>
    assert(mm != NULL);
ffffffffc0202d4e:	84aa                	mv	s1,a0
ffffffffc0202d50:	03200413          	li	s0,50
ffffffffc0202d54:	e919                	bnez	a0,ffffffffc0202d6a <vmm_init+0x30>
ffffffffc0202d56:	a991                	j	ffffffffc02031aa <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc0202d58:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202d5a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202d5c:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0202d60:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202d62:	8526                	mv	a0,s1
ffffffffc0202d64:	cf5ff0ef          	jal	ra,ffffffffc0202a58 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0202d68:	c80d                	beqz	s0,ffffffffc0202d9a <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202d6a:	03000513          	li	a0,48
ffffffffc0202d6e:	0b3000ef          	jal	ra,ffffffffc0203620 <kmalloc>
ffffffffc0202d72:	85aa                	mv	a1,a0
ffffffffc0202d74:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0202d78:	f165                	bnez	a0,ffffffffc0202d58 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0202d7a:	00005697          	auipc	a3,0x5
ffffffffc0202d7e:	cfe68693          	addi	a3,a3,-770 # ffffffffc0207a78 <commands+0x1260>
ffffffffc0202d82:	00004617          	auipc	a2,0x4
ffffffffc0202d86:	ea660613          	addi	a2,a2,-346 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202d8a:	11300593          	li	a1,275
ffffffffc0202d8e:	00005517          	auipc	a0,0x5
ffffffffc0202d92:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0207788 <commands+0xf70>
ffffffffc0202d96:	c72fd0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0202d9a:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202d9e:	1f900913          	li	s2,505
ffffffffc0202da2:	a819                	j	ffffffffc0202db8 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0202da4:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202da6:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202da8:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202dac:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202dae:	8526                	mv	a0,s1
ffffffffc0202db0:	ca9ff0ef          	jal	ra,ffffffffc0202a58 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202db4:	03240a63          	beq	s0,s2,ffffffffc0202de8 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202db8:	03000513          	li	a0,48
ffffffffc0202dbc:	065000ef          	jal	ra,ffffffffc0203620 <kmalloc>
ffffffffc0202dc0:	85aa                	mv	a1,a0
ffffffffc0202dc2:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0202dc6:	fd79                	bnez	a0,ffffffffc0202da4 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0202dc8:	00005697          	auipc	a3,0x5
ffffffffc0202dcc:	cb068693          	addi	a3,a3,-848 # ffffffffc0207a78 <commands+0x1260>
ffffffffc0202dd0:	00004617          	auipc	a2,0x4
ffffffffc0202dd4:	e5860613          	addi	a2,a2,-424 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202dd8:	11900593          	li	a1,281
ffffffffc0202ddc:	00005517          	auipc	a0,0x5
ffffffffc0202de0:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0207788 <commands+0xf70>
ffffffffc0202de4:	c24fd0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0202de8:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc0202dea:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc0202dec:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0202df0:	2cf48d63          	beq	s1,a5,ffffffffc02030ca <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202df4:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c684>
ffffffffc0202df8:	ffe70613          	addi	a2,a4,-2
ffffffffc0202dfc:	24d61763          	bne	a2,a3,ffffffffc020304a <vmm_init+0x310>
ffffffffc0202e00:	ff07b683          	ld	a3,-16(a5)
ffffffffc0202e04:	24e69363          	bne	a3,a4,ffffffffc020304a <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc0202e08:	0715                	addi	a4,a4,5
ffffffffc0202e0a:	679c                	ld	a5,8(a5)
ffffffffc0202e0c:	feb712e3          	bne	a4,a1,ffffffffc0202df0 <vmm_init+0xb6>
ffffffffc0202e10:	4a1d                	li	s4,7
ffffffffc0202e12:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202e14:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202e18:	85a2                	mv	a1,s0
ffffffffc0202e1a:	8526                	mv	a0,s1
ffffffffc0202e1c:	bfdff0ef          	jal	ra,ffffffffc0202a18 <find_vma>
ffffffffc0202e20:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0202e22:	30050463          	beqz	a0,ffffffffc020312a <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0202e26:	00140593          	addi	a1,s0,1
ffffffffc0202e2a:	8526                	mv	a0,s1
ffffffffc0202e2c:	bedff0ef          	jal	ra,ffffffffc0202a18 <find_vma>
ffffffffc0202e30:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0202e32:	2c050c63          	beqz	a0,ffffffffc020310a <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0202e36:	85d2                	mv	a1,s4
ffffffffc0202e38:	8526                	mv	a0,s1
ffffffffc0202e3a:	bdfff0ef          	jal	ra,ffffffffc0202a18 <find_vma>
        assert(vma3 == NULL);
ffffffffc0202e3e:	2a051663          	bnez	a0,ffffffffc02030ea <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0202e42:	00340593          	addi	a1,s0,3
ffffffffc0202e46:	8526                	mv	a0,s1
ffffffffc0202e48:	bd1ff0ef          	jal	ra,ffffffffc0202a18 <find_vma>
        assert(vma4 == NULL);
ffffffffc0202e4c:	30051f63          	bnez	a0,ffffffffc020316a <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0202e50:	00440593          	addi	a1,s0,4
ffffffffc0202e54:	8526                	mv	a0,s1
ffffffffc0202e56:	bc3ff0ef          	jal	ra,ffffffffc0202a18 <find_vma>
        assert(vma5 == NULL);
ffffffffc0202e5a:	2e051863          	bnez	a0,ffffffffc020314a <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202e5e:	00893783          	ld	a5,8(s2)
ffffffffc0202e62:	20879463          	bne	a5,s0,ffffffffc020306a <vmm_init+0x330>
ffffffffc0202e66:	01093783          	ld	a5,16(s2)
ffffffffc0202e6a:	20fa1063          	bne	s4,a5,ffffffffc020306a <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202e6e:	0089b783          	ld	a5,8(s3)
ffffffffc0202e72:	20879c63          	bne	a5,s0,ffffffffc020308a <vmm_init+0x350>
ffffffffc0202e76:	0109b783          	ld	a5,16(s3)
ffffffffc0202e7a:	20fa1863          	bne	s4,a5,ffffffffc020308a <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202e7e:	0415                	addi	s0,s0,5
ffffffffc0202e80:	0a15                	addi	s4,s4,5
ffffffffc0202e82:	f9541be3          	bne	s0,s5,ffffffffc0202e18 <vmm_init+0xde>
ffffffffc0202e86:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0202e88:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0202e8a:	85a2                	mv	a1,s0
ffffffffc0202e8c:	8526                	mv	a0,s1
ffffffffc0202e8e:	b8bff0ef          	jal	ra,ffffffffc0202a18 <find_vma>
ffffffffc0202e92:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0202e96:	c90d                	beqz	a0,ffffffffc0202ec8 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0202e98:	6914                	ld	a3,16(a0)
ffffffffc0202e9a:	6510                	ld	a2,8(a0)
ffffffffc0202e9c:	00005517          	auipc	a0,0x5
ffffffffc0202ea0:	ac450513          	addi	a0,a0,-1340 # ffffffffc0207960 <commands+0x1148>
ffffffffc0202ea4:	a28fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0202ea8:	00005697          	auipc	a3,0x5
ffffffffc0202eac:	ae068693          	addi	a3,a3,-1312 # ffffffffc0207988 <commands+0x1170>
ffffffffc0202eb0:	00004617          	auipc	a2,0x4
ffffffffc0202eb4:	d7860613          	addi	a2,a2,-648 # ffffffffc0206c28 <commands+0x410>
ffffffffc0202eb8:	13b00593          	li	a1,315
ffffffffc0202ebc:	00005517          	auipc	a0,0x5
ffffffffc0202ec0:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0207788 <commands+0xf70>
ffffffffc0202ec4:	b44fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0202ec8:	147d                	addi	s0,s0,-1
ffffffffc0202eca:	fd2410e3          	bne	s0,s2,ffffffffc0202e8a <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0202ece:	8526                	mv	a0,s1
ffffffffc0202ed0:	c59ff0ef          	jal	ra,ffffffffc0202b28 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0202ed4:	00005517          	auipc	a0,0x5
ffffffffc0202ed8:	acc50513          	addi	a0,a0,-1332 # ffffffffc02079a0 <commands+0x1188>
ffffffffc0202edc:	9f0fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202ee0:	84cfe0ef          	jal	ra,ffffffffc0200f2c <nr_free_pages>
ffffffffc0202ee4:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc0202ee6:	abdff0ef          	jal	ra,ffffffffc02029a2 <mm_create>
ffffffffc0202eea:	000b0797          	auipc	a5,0xb0
ffffffffc0202eee:	a2a7b723          	sd	a0,-1490(a5) # ffffffffc02b2918 <check_mm_struct>
ffffffffc0202ef2:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc0202ef4:	28050b63          	beqz	a0,ffffffffc020318a <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202ef8:	000b0497          	auipc	s1,0xb0
ffffffffc0202efc:	9f84b483          	ld	s1,-1544(s1) # ffffffffc02b28f0 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0202f00:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202f02:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0202f04:	2e079f63          	bnez	a5,ffffffffc0203202 <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202f08:	03000513          	li	a0,48
ffffffffc0202f0c:	714000ef          	jal	ra,ffffffffc0203620 <kmalloc>
ffffffffc0202f10:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0202f12:	18050c63          	beqz	a0,ffffffffc02030aa <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc0202f16:	002007b7          	lui	a5,0x200
ffffffffc0202f1a:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0202f1e:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0202f20:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0202f22:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0202f26:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0202f28:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0202f2c:	b2dff0ef          	jal	ra,ffffffffc0202a58 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0202f30:	10000593          	li	a1,256
ffffffffc0202f34:	8522                	mv	a0,s0
ffffffffc0202f36:	ae3ff0ef          	jal	ra,ffffffffc0202a18 <find_vma>
ffffffffc0202f3a:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc0202f3e:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0202f42:	2ea99063          	bne	s3,a0,ffffffffc0203222 <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc0202f46:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ed0>
    for (i = 0; i < 100; i ++) {
ffffffffc0202f4a:	0785                	addi	a5,a5,1
ffffffffc0202f4c:	fee79de3          	bne	a5,a4,ffffffffc0202f46 <vmm_init+0x20c>
        sum += i;
ffffffffc0202f50:	6705                	lui	a4,0x1
ffffffffc0202f52:	10000793          	li	a5,256
ffffffffc0202f56:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x886a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0202f5a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0202f5e:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0202f62:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0202f64:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0202f66:	fec79ce3          	bne	a5,a2,ffffffffc0202f5e <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc0202f6a:	2e071863          	bnez	a4,ffffffffc020325a <vmm_init+0x520>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f6e:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0202f70:	000b0a97          	auipc	s5,0xb0
ffffffffc0202f74:	988a8a93          	addi	s5,s5,-1656 # ffffffffc02b28f8 <npage>
ffffffffc0202f78:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f7c:	078a                	slli	a5,a5,0x2
ffffffffc0202f7e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f80:	2cc7f163          	bgeu	a5,a2,ffffffffc0203242 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f84:	00006a17          	auipc	s4,0x6
ffffffffc0202f88:	c9ca3a03          	ld	s4,-868(s4) # ffffffffc0208c20 <nbase>
ffffffffc0202f8c:	414787b3          	sub	a5,a5,s4
ffffffffc0202f90:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0202f92:	8799                	srai	a5,a5,0x6
ffffffffc0202f94:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0202f96:	00c79713          	slli	a4,a5,0xc
ffffffffc0202f9a:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202f9c:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202fa0:	24c77563          	bgeu	a4,a2,ffffffffc02031ea <vmm_init+0x4b0>
ffffffffc0202fa4:	000b0997          	auipc	s3,0xb0
ffffffffc0202fa8:	96c9b983          	ld	s3,-1684(s3) # ffffffffc02b2910 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0202fac:	4581                	li	a1,0
ffffffffc0202fae:	8526                	mv	a0,s1
ffffffffc0202fb0:	99b6                	add	s3,s3,a3
ffffffffc0202fb2:	db2fe0ef          	jal	ra,ffffffffc0201564 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fb6:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202fba:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fbe:	078a                	slli	a5,a5,0x2
ffffffffc0202fc0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202fc2:	28e7f063          	bgeu	a5,a4,ffffffffc0203242 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fc6:	000b0997          	auipc	s3,0xb0
ffffffffc0202fca:	93a98993          	addi	s3,s3,-1734 # ffffffffc02b2900 <pages>
ffffffffc0202fce:	0009b503          	ld	a0,0(s3)
ffffffffc0202fd2:	414787b3          	sub	a5,a5,s4
ffffffffc0202fd6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202fd8:	953e                	add	a0,a0,a5
ffffffffc0202fda:	4585                	li	a1,1
ffffffffc0202fdc:	f11fd0ef          	jal	ra,ffffffffc0200eec <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fe0:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0202fe2:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fe6:	078a                	slli	a5,a5,0x2
ffffffffc0202fe8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202fea:	24e7fc63          	bgeu	a5,a4,ffffffffc0203242 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fee:	0009b503          	ld	a0,0(s3)
ffffffffc0202ff2:	414787b3          	sub	a5,a5,s4
ffffffffc0202ff6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202ff8:	4585                	li	a1,1
ffffffffc0202ffa:	953e                	add	a0,a0,a5
ffffffffc0202ffc:	ef1fd0ef          	jal	ra,ffffffffc0200eec <free_pages>
    pgdir[0] = 0;
ffffffffc0203000:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc0203004:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0203008:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc020300a:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc020300e:	b1bff0ef          	jal	ra,ffffffffc0202b28 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0203012:	000b0797          	auipc	a5,0xb0
ffffffffc0203016:	9007b323          	sd	zero,-1786(a5) # ffffffffc02b2918 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020301a:	f13fd0ef          	jal	ra,ffffffffc0200f2c <nr_free_pages>
ffffffffc020301e:	1aa91663          	bne	s2,a0,ffffffffc02031ca <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203022:	00005517          	auipc	a0,0x5
ffffffffc0203026:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0207a40 <commands+0x1228>
ffffffffc020302a:	8a2fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc020302e:	7442                	ld	s0,48(sp)
ffffffffc0203030:	70e2                	ld	ra,56(sp)
ffffffffc0203032:	74a2                	ld	s1,40(sp)
ffffffffc0203034:	7902                	ld	s2,32(sp)
ffffffffc0203036:	69e2                	ld	s3,24(sp)
ffffffffc0203038:	6a42                	ld	s4,16(sp)
ffffffffc020303a:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020303c:	00005517          	auipc	a0,0x5
ffffffffc0203040:	a2450513          	addi	a0,a0,-1500 # ffffffffc0207a60 <commands+0x1248>
}
ffffffffc0203044:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203046:	886fd06f          	j	ffffffffc02000cc <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020304a:	00005697          	auipc	a3,0x5
ffffffffc020304e:	82e68693          	addi	a3,a3,-2002 # ffffffffc0207878 <commands+0x1060>
ffffffffc0203052:	00004617          	auipc	a2,0x4
ffffffffc0203056:	bd660613          	addi	a2,a2,-1066 # ffffffffc0206c28 <commands+0x410>
ffffffffc020305a:	12200593          	li	a1,290
ffffffffc020305e:	00004517          	auipc	a0,0x4
ffffffffc0203062:	72a50513          	addi	a0,a0,1834 # ffffffffc0207788 <commands+0xf70>
ffffffffc0203066:	9a2fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020306a:	00005697          	auipc	a3,0x5
ffffffffc020306e:	89668693          	addi	a3,a3,-1898 # ffffffffc0207900 <commands+0x10e8>
ffffffffc0203072:	00004617          	auipc	a2,0x4
ffffffffc0203076:	bb660613          	addi	a2,a2,-1098 # ffffffffc0206c28 <commands+0x410>
ffffffffc020307a:	13200593          	li	a1,306
ffffffffc020307e:	00004517          	auipc	a0,0x4
ffffffffc0203082:	70a50513          	addi	a0,a0,1802 # ffffffffc0207788 <commands+0xf70>
ffffffffc0203086:	982fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020308a:	00005697          	auipc	a3,0x5
ffffffffc020308e:	8a668693          	addi	a3,a3,-1882 # ffffffffc0207930 <commands+0x1118>
ffffffffc0203092:	00004617          	auipc	a2,0x4
ffffffffc0203096:	b9660613          	addi	a2,a2,-1130 # ffffffffc0206c28 <commands+0x410>
ffffffffc020309a:	13300593          	li	a1,307
ffffffffc020309e:	00004517          	auipc	a0,0x4
ffffffffc02030a2:	6ea50513          	addi	a0,a0,1770 # ffffffffc0207788 <commands+0xf70>
ffffffffc02030a6:	962fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(vma != NULL);
ffffffffc02030aa:	00005697          	auipc	a3,0x5
ffffffffc02030ae:	9ce68693          	addi	a3,a3,-1586 # ffffffffc0207a78 <commands+0x1260>
ffffffffc02030b2:	00004617          	auipc	a2,0x4
ffffffffc02030b6:	b7660613          	addi	a2,a2,-1162 # ffffffffc0206c28 <commands+0x410>
ffffffffc02030ba:	15200593          	li	a1,338
ffffffffc02030be:	00004517          	auipc	a0,0x4
ffffffffc02030c2:	6ca50513          	addi	a0,a0,1738 # ffffffffc0207788 <commands+0xf70>
ffffffffc02030c6:	942fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02030ca:	00004697          	auipc	a3,0x4
ffffffffc02030ce:	79668693          	addi	a3,a3,1942 # ffffffffc0207860 <commands+0x1048>
ffffffffc02030d2:	00004617          	auipc	a2,0x4
ffffffffc02030d6:	b5660613          	addi	a2,a2,-1194 # ffffffffc0206c28 <commands+0x410>
ffffffffc02030da:	12000593          	li	a1,288
ffffffffc02030de:	00004517          	auipc	a0,0x4
ffffffffc02030e2:	6aa50513          	addi	a0,a0,1706 # ffffffffc0207788 <commands+0xf70>
ffffffffc02030e6:	922fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma3 == NULL);
ffffffffc02030ea:	00004697          	auipc	a3,0x4
ffffffffc02030ee:	7e668693          	addi	a3,a3,2022 # ffffffffc02078d0 <commands+0x10b8>
ffffffffc02030f2:	00004617          	auipc	a2,0x4
ffffffffc02030f6:	b3660613          	addi	a2,a2,-1226 # ffffffffc0206c28 <commands+0x410>
ffffffffc02030fa:	12c00593          	li	a1,300
ffffffffc02030fe:	00004517          	auipc	a0,0x4
ffffffffc0203102:	68a50513          	addi	a0,a0,1674 # ffffffffc0207788 <commands+0xf70>
ffffffffc0203106:	902fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2 != NULL);
ffffffffc020310a:	00004697          	auipc	a3,0x4
ffffffffc020310e:	7b668693          	addi	a3,a3,1974 # ffffffffc02078c0 <commands+0x10a8>
ffffffffc0203112:	00004617          	auipc	a2,0x4
ffffffffc0203116:	b1660613          	addi	a2,a2,-1258 # ffffffffc0206c28 <commands+0x410>
ffffffffc020311a:	12a00593          	li	a1,298
ffffffffc020311e:	00004517          	auipc	a0,0x4
ffffffffc0203122:	66a50513          	addi	a0,a0,1642 # ffffffffc0207788 <commands+0xf70>
ffffffffc0203126:	8e2fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1 != NULL);
ffffffffc020312a:	00004697          	auipc	a3,0x4
ffffffffc020312e:	78668693          	addi	a3,a3,1926 # ffffffffc02078b0 <commands+0x1098>
ffffffffc0203132:	00004617          	auipc	a2,0x4
ffffffffc0203136:	af660613          	addi	a2,a2,-1290 # ffffffffc0206c28 <commands+0x410>
ffffffffc020313a:	12800593          	li	a1,296
ffffffffc020313e:	00004517          	auipc	a0,0x4
ffffffffc0203142:	64a50513          	addi	a0,a0,1610 # ffffffffc0207788 <commands+0xf70>
ffffffffc0203146:	8c2fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma5 == NULL);
ffffffffc020314a:	00004697          	auipc	a3,0x4
ffffffffc020314e:	7a668693          	addi	a3,a3,1958 # ffffffffc02078f0 <commands+0x10d8>
ffffffffc0203152:	00004617          	auipc	a2,0x4
ffffffffc0203156:	ad660613          	addi	a2,a2,-1322 # ffffffffc0206c28 <commands+0x410>
ffffffffc020315a:	13000593          	li	a1,304
ffffffffc020315e:	00004517          	auipc	a0,0x4
ffffffffc0203162:	62a50513          	addi	a0,a0,1578 # ffffffffc0207788 <commands+0xf70>
ffffffffc0203166:	8a2fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma4 == NULL);
ffffffffc020316a:	00004697          	auipc	a3,0x4
ffffffffc020316e:	77668693          	addi	a3,a3,1910 # ffffffffc02078e0 <commands+0x10c8>
ffffffffc0203172:	00004617          	auipc	a2,0x4
ffffffffc0203176:	ab660613          	addi	a2,a2,-1354 # ffffffffc0206c28 <commands+0x410>
ffffffffc020317a:	12e00593          	li	a1,302
ffffffffc020317e:	00004517          	auipc	a0,0x4
ffffffffc0203182:	60a50513          	addi	a0,a0,1546 # ffffffffc0207788 <commands+0xf70>
ffffffffc0203186:	882fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020318a:	00005697          	auipc	a3,0x5
ffffffffc020318e:	83668693          	addi	a3,a3,-1994 # ffffffffc02079c0 <commands+0x11a8>
ffffffffc0203192:	00004617          	auipc	a2,0x4
ffffffffc0203196:	a9660613          	addi	a2,a2,-1386 # ffffffffc0206c28 <commands+0x410>
ffffffffc020319a:	14b00593          	li	a1,331
ffffffffc020319e:	00004517          	auipc	a0,0x4
ffffffffc02031a2:	5ea50513          	addi	a0,a0,1514 # ffffffffc0207788 <commands+0xf70>
ffffffffc02031a6:	862fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(mm != NULL);
ffffffffc02031aa:	00004697          	auipc	a3,0x4
ffffffffc02031ae:	66668693          	addi	a3,a3,1638 # ffffffffc0207810 <commands+0xff8>
ffffffffc02031b2:	00004617          	auipc	a2,0x4
ffffffffc02031b6:	a7660613          	addi	a2,a2,-1418 # ffffffffc0206c28 <commands+0x410>
ffffffffc02031ba:	10c00593          	li	a1,268
ffffffffc02031be:	00004517          	auipc	a0,0x4
ffffffffc02031c2:	5ca50513          	addi	a0,a0,1482 # ffffffffc0207788 <commands+0xf70>
ffffffffc02031c6:	842fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02031ca:	00005697          	auipc	a3,0x5
ffffffffc02031ce:	84e68693          	addi	a3,a3,-1970 # ffffffffc0207a18 <commands+0x1200>
ffffffffc02031d2:	00004617          	auipc	a2,0x4
ffffffffc02031d6:	a5660613          	addi	a2,a2,-1450 # ffffffffc0206c28 <commands+0x410>
ffffffffc02031da:	17000593          	li	a1,368
ffffffffc02031de:	00004517          	auipc	a0,0x4
ffffffffc02031e2:	5aa50513          	addi	a0,a0,1450 # ffffffffc0207788 <commands+0xf70>
ffffffffc02031e6:	822fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc02031ea:	00004617          	auipc	a2,0x4
ffffffffc02031ee:	d8660613          	addi	a2,a2,-634 # ffffffffc0206f70 <commands+0x758>
ffffffffc02031f2:	06900593          	li	a1,105
ffffffffc02031f6:	00004517          	auipc	a0,0x4
ffffffffc02031fa:	d4250513          	addi	a0,a0,-702 # ffffffffc0206f38 <commands+0x720>
ffffffffc02031fe:	80afd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203202:	00004697          	auipc	a3,0x4
ffffffffc0203206:	7d668693          	addi	a3,a3,2006 # ffffffffc02079d8 <commands+0x11c0>
ffffffffc020320a:	00004617          	auipc	a2,0x4
ffffffffc020320e:	a1e60613          	addi	a2,a2,-1506 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203212:	14f00593          	li	a1,335
ffffffffc0203216:	00004517          	auipc	a0,0x4
ffffffffc020321a:	57250513          	addi	a0,a0,1394 # ffffffffc0207788 <commands+0xf70>
ffffffffc020321e:	febfc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203222:	00004697          	auipc	a3,0x4
ffffffffc0203226:	7c668693          	addi	a3,a3,1990 # ffffffffc02079e8 <commands+0x11d0>
ffffffffc020322a:	00004617          	auipc	a2,0x4
ffffffffc020322e:	9fe60613          	addi	a2,a2,-1538 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203232:	15700593          	li	a1,343
ffffffffc0203236:	00004517          	auipc	a0,0x4
ffffffffc020323a:	55250513          	addi	a0,a0,1362 # ffffffffc0207788 <commands+0xf70>
ffffffffc020323e:	fcbfc0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203242:	00004617          	auipc	a2,0x4
ffffffffc0203246:	cd660613          	addi	a2,a2,-810 # ffffffffc0206f18 <commands+0x700>
ffffffffc020324a:	06200593          	li	a1,98
ffffffffc020324e:	00004517          	auipc	a0,0x4
ffffffffc0203252:	cea50513          	addi	a0,a0,-790 # ffffffffc0206f38 <commands+0x720>
ffffffffc0203256:	fb3fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(sum == 0);
ffffffffc020325a:	00004697          	auipc	a3,0x4
ffffffffc020325e:	7ae68693          	addi	a3,a3,1966 # ffffffffc0207a08 <commands+0x11f0>
ffffffffc0203262:	00004617          	auipc	a2,0x4
ffffffffc0203266:	9c660613          	addi	a2,a2,-1594 # ffffffffc0206c28 <commands+0x410>
ffffffffc020326a:	16300593          	li	a1,355
ffffffffc020326e:	00004517          	auipc	a0,0x4
ffffffffc0203272:	51a50513          	addi	a0,a0,1306 # ffffffffc0207788 <commands+0xf70>
ffffffffc0203276:	f93fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020327a <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020327a:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020327c:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020327e:	f022                	sd	s0,32(sp)
ffffffffc0203280:	ec26                	sd	s1,24(sp)
ffffffffc0203282:	f406                	sd	ra,40(sp)
ffffffffc0203284:	e84a                	sd	s2,16(sp)
ffffffffc0203286:	8432                	mv	s0,a2
ffffffffc0203288:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020328a:	f8eff0ef          	jal	ra,ffffffffc0202a18 <find_vma>

    pgfault_num++;
ffffffffc020328e:	000af797          	auipc	a5,0xaf
ffffffffc0203292:	6927a783          	lw	a5,1682(a5) # ffffffffc02b2920 <pgfault_num>
ffffffffc0203296:	2785                	addiw	a5,a5,1
ffffffffc0203298:	000af717          	auipc	a4,0xaf
ffffffffc020329c:	68f72423          	sw	a5,1672(a4) # ffffffffc02b2920 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02032a0:	c541                	beqz	a0,ffffffffc0203328 <do_pgfault+0xae>
ffffffffc02032a2:	651c                	ld	a5,8(a0)
ffffffffc02032a4:	08f46263          	bltu	s0,a5,ffffffffc0203328 <do_pgfault+0xae>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02032a8:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02032aa:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02032ac:	8b89                	andi	a5,a5,2
ffffffffc02032ae:	ebb9                	bnez	a5,ffffffffc0203304 <do_pgfault+0x8a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02032b0:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02032b2:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02032b4:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02032b6:	4605                	li	a2,1
ffffffffc02032b8:	85a2                	mv	a1,s0
ffffffffc02032ba:	cadfd0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc02032be:	c551                	beqz	a0,ffffffffc020334a <do_pgfault+0xd0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02032c0:	610c                	ld	a1,0(a0)
ffffffffc02032c2:	c1b9                	beqz	a1,ffffffffc0203308 <do_pgfault+0x8e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02032c4:	000af797          	auipc	a5,0xaf
ffffffffc02032c8:	67c7a783          	lw	a5,1660(a5) # ffffffffc02b2940 <swap_init_ok>
ffffffffc02032cc:	c7bd                	beqz	a5,ffffffffc020333a <do_pgfault+0xc0>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm,addr,&page);
ffffffffc02032ce:	85a2                	mv	a1,s0
ffffffffc02032d0:	0030                	addi	a2,sp,8
ffffffffc02032d2:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02032d4:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc02032d6:	583000ef          	jal	ra,ffffffffc0204058 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc02032da:	65a2                	ld	a1,8(sp)
ffffffffc02032dc:	6c88                	ld	a0,24(s1)
ffffffffc02032de:	86ca                	mv	a3,s2
ffffffffc02032e0:	8622                	mv	a2,s0
ffffffffc02032e2:	b1efe0ef          	jal	ra,ffffffffc0201600 <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc02032e6:	6622                	ld	a2,8(sp)
ffffffffc02032e8:	4685                	li	a3,1
ffffffffc02032ea:	85a2                	mv	a1,s0
ffffffffc02032ec:	8526                	mv	a0,s1
ffffffffc02032ee:	44b000ef          	jal	ra,ffffffffc0203f38 <swap_map_swappable>

            page->pra_vaddr = addr;
ffffffffc02032f2:	67a2                	ld	a5,8(sp)
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc02032f4:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc02032f6:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc02032f8:	70a2                	ld	ra,40(sp)
ffffffffc02032fa:	7402                	ld	s0,32(sp)
ffffffffc02032fc:	64e2                	ld	s1,24(sp)
ffffffffc02032fe:	6942                	ld	s2,16(sp)
ffffffffc0203300:	6145                	addi	sp,sp,48
ffffffffc0203302:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0203304:	495d                	li	s2,23
ffffffffc0203306:	b76d                	j	ffffffffc02032b0 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203308:	6c88                	ld	a0,24(s1)
ffffffffc020330a:	864a                	mv	a2,s2
ffffffffc020330c:	85a2                	mv	a1,s0
ffffffffc020330e:	9b8ff0ef          	jal	ra,ffffffffc02024c6 <pgdir_alloc_page>
ffffffffc0203312:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0203314:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203316:	f3ed                	bnez	a5,ffffffffc02032f8 <do_pgfault+0x7e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203318:	00004517          	auipc	a0,0x4
ffffffffc020331c:	7c050513          	addi	a0,a0,1984 # ffffffffc0207ad8 <commands+0x12c0>
ffffffffc0203320:	dadfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203324:	5571                	li	a0,-4
            goto failed;
ffffffffc0203326:	bfc9                	j	ffffffffc02032f8 <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203328:	85a2                	mv	a1,s0
ffffffffc020332a:	00004517          	auipc	a0,0x4
ffffffffc020332e:	75e50513          	addi	a0,a0,1886 # ffffffffc0207a88 <commands+0x1270>
ffffffffc0203332:	d9bfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc0203336:	5575                	li	a0,-3
        goto failed;
ffffffffc0203338:	b7c1                	j	ffffffffc02032f8 <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc020333a:	00004517          	auipc	a0,0x4
ffffffffc020333e:	7c650513          	addi	a0,a0,1990 # ffffffffc0207b00 <commands+0x12e8>
ffffffffc0203342:	d8bfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203346:	5571                	li	a0,-4
            goto failed;
ffffffffc0203348:	bf45                	j	ffffffffc02032f8 <do_pgfault+0x7e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc020334a:	00004517          	auipc	a0,0x4
ffffffffc020334e:	76e50513          	addi	a0,a0,1902 # ffffffffc0207ab8 <commands+0x12a0>
ffffffffc0203352:	d7bfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203356:	5571                	li	a0,-4
        goto failed;
ffffffffc0203358:	b745                	j	ffffffffc02032f8 <do_pgfault+0x7e>

ffffffffc020335a <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc020335a:	7179                	addi	sp,sp,-48
ffffffffc020335c:	f022                	sd	s0,32(sp)
ffffffffc020335e:	f406                	sd	ra,40(sp)
ffffffffc0203360:	ec26                	sd	s1,24(sp)
ffffffffc0203362:	e84a                	sd	s2,16(sp)
ffffffffc0203364:	e44e                	sd	s3,8(sp)
ffffffffc0203366:	e052                	sd	s4,0(sp)
ffffffffc0203368:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc020336a:	c135                	beqz	a0,ffffffffc02033ce <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc020336c:	002007b7          	lui	a5,0x200
ffffffffc0203370:	04f5e663          	bltu	a1,a5,ffffffffc02033bc <user_mem_check+0x62>
ffffffffc0203374:	00c584b3          	add	s1,a1,a2
ffffffffc0203378:	0495f263          	bgeu	a1,s1,ffffffffc02033bc <user_mem_check+0x62>
ffffffffc020337c:	4785                	li	a5,1
ffffffffc020337e:	07fe                	slli	a5,a5,0x1f
ffffffffc0203380:	0297ee63          	bltu	a5,s1,ffffffffc02033bc <user_mem_check+0x62>
ffffffffc0203384:	892a                	mv	s2,a0
ffffffffc0203386:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0203388:	6a05                	lui	s4,0x1
ffffffffc020338a:	a821                	j	ffffffffc02033a2 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc020338c:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0203390:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0203392:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0203394:	c685                	beqz	a3,ffffffffc02033bc <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0203396:	c399                	beqz	a5,ffffffffc020339c <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0203398:	02e46263          	bltu	s0,a4,ffffffffc02033bc <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc020339c:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc020339e:	04947663          	bgeu	s0,s1,ffffffffc02033ea <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc02033a2:	85a2                	mv	a1,s0
ffffffffc02033a4:	854a                	mv	a0,s2
ffffffffc02033a6:	e72ff0ef          	jal	ra,ffffffffc0202a18 <find_vma>
ffffffffc02033aa:	c909                	beqz	a0,ffffffffc02033bc <user_mem_check+0x62>
ffffffffc02033ac:	6518                	ld	a4,8(a0)
ffffffffc02033ae:	00e46763          	bltu	s0,a4,ffffffffc02033bc <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02033b2:	4d1c                	lw	a5,24(a0)
ffffffffc02033b4:	fc099ce3          	bnez	s3,ffffffffc020338c <user_mem_check+0x32>
ffffffffc02033b8:	8b85                	andi	a5,a5,1
ffffffffc02033ba:	f3ed                	bnez	a5,ffffffffc020339c <user_mem_check+0x42>
            return 0;
ffffffffc02033bc:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc02033be:	70a2                	ld	ra,40(sp)
ffffffffc02033c0:	7402                	ld	s0,32(sp)
ffffffffc02033c2:	64e2                	ld	s1,24(sp)
ffffffffc02033c4:	6942                	ld	s2,16(sp)
ffffffffc02033c6:	69a2                	ld	s3,8(sp)
ffffffffc02033c8:	6a02                	ld	s4,0(sp)
ffffffffc02033ca:	6145                	addi	sp,sp,48
ffffffffc02033cc:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc02033ce:	c02007b7          	lui	a5,0xc0200
ffffffffc02033d2:	4501                	li	a0,0
ffffffffc02033d4:	fef5e5e3          	bltu	a1,a5,ffffffffc02033be <user_mem_check+0x64>
ffffffffc02033d8:	962e                	add	a2,a2,a1
ffffffffc02033da:	fec5f2e3          	bgeu	a1,a2,ffffffffc02033be <user_mem_check+0x64>
ffffffffc02033de:	c8000537          	lui	a0,0xc8000
ffffffffc02033e2:	0505                	addi	a0,a0,1
ffffffffc02033e4:	00a63533          	sltu	a0,a2,a0
ffffffffc02033e8:	bfd9                	j	ffffffffc02033be <user_mem_check+0x64>
        return 1;
ffffffffc02033ea:	4505                	li	a0,1
ffffffffc02033ec:	bfc9                	j	ffffffffc02033be <user_mem_check+0x64>

ffffffffc02033ee <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02033ee:	c94d                	beqz	a0,ffffffffc02034a0 <slob_free+0xb2>
{
ffffffffc02033f0:	1141                	addi	sp,sp,-16
ffffffffc02033f2:	e022                	sd	s0,0(sp)
ffffffffc02033f4:	e406                	sd	ra,8(sp)
ffffffffc02033f6:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02033f8:	e9c1                	bnez	a1,ffffffffc0203488 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033fa:	100027f3          	csrr	a5,sstatus
ffffffffc02033fe:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203400:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203402:	ebd9                	bnez	a5,ffffffffc0203498 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203404:	000a4617          	auipc	a2,0xa4
ffffffffc0203408:	ff460613          	addi	a2,a2,-12 # ffffffffc02a73f8 <slobfree>
ffffffffc020340c:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020340e:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203410:	679c                	ld	a5,8(a5)
ffffffffc0203412:	02877a63          	bgeu	a4,s0,ffffffffc0203446 <slob_free+0x58>
ffffffffc0203416:	00f46463          	bltu	s0,a5,ffffffffc020341e <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020341a:	fef76ae3          	bltu	a4,a5,ffffffffc020340e <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc020341e:	400c                	lw	a1,0(s0)
ffffffffc0203420:	00459693          	slli	a3,a1,0x4
ffffffffc0203424:	96a2                	add	a3,a3,s0
ffffffffc0203426:	02d78a63          	beq	a5,a3,ffffffffc020345a <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc020342a:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc020342c:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc020342e:	00469793          	slli	a5,a3,0x4
ffffffffc0203432:	97ba                	add	a5,a5,a4
ffffffffc0203434:	02f40e63          	beq	s0,a5,ffffffffc0203470 <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0203438:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc020343a:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc020343c:	e129                	bnez	a0,ffffffffc020347e <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc020343e:	60a2                	ld	ra,8(sp)
ffffffffc0203440:	6402                	ld	s0,0(sp)
ffffffffc0203442:	0141                	addi	sp,sp,16
ffffffffc0203444:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203446:	fcf764e3          	bltu	a4,a5,ffffffffc020340e <slob_free+0x20>
ffffffffc020344a:	fcf472e3          	bgeu	s0,a5,ffffffffc020340e <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc020344e:	400c                	lw	a1,0(s0)
ffffffffc0203450:	00459693          	slli	a3,a1,0x4
ffffffffc0203454:	96a2                	add	a3,a3,s0
ffffffffc0203456:	fcd79ae3          	bne	a5,a3,ffffffffc020342a <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc020345a:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020345c:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc020345e:	9db5                	addw	a1,a1,a3
ffffffffc0203460:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0203462:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0203464:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0203466:	00469793          	slli	a5,a3,0x4
ffffffffc020346a:	97ba                	add	a5,a5,a4
ffffffffc020346c:	fcf416e3          	bne	s0,a5,ffffffffc0203438 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0203470:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0203472:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0203474:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0203476:	9ebd                	addw	a3,a3,a5
ffffffffc0203478:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc020347a:	e70c                	sd	a1,8(a4)
ffffffffc020347c:	d169                	beqz	a0,ffffffffc020343e <slob_free+0x50>
}
ffffffffc020347e:	6402                	ld	s0,0(sp)
ffffffffc0203480:	60a2                	ld	ra,8(sp)
ffffffffc0203482:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0203484:	9befd06f          	j	ffffffffc0200642 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0203488:	25bd                	addiw	a1,a1,15
ffffffffc020348a:	8191                	srli	a1,a1,0x4
ffffffffc020348c:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020348e:	100027f3          	csrr	a5,sstatus
ffffffffc0203492:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203494:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203496:	d7bd                	beqz	a5,ffffffffc0203404 <slob_free+0x16>
        intr_disable();
ffffffffc0203498:	9b0fd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc020349c:	4505                	li	a0,1
ffffffffc020349e:	b79d                	j	ffffffffc0203404 <slob_free+0x16>
ffffffffc02034a0:	8082                	ret

ffffffffc02034a2 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02034a2:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02034a4:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02034a6:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02034aa:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02034ac:	9affd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
  if(!page)
ffffffffc02034b0:	c91d                	beqz	a0,ffffffffc02034e6 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc02034b2:	000af697          	auipc	a3,0xaf
ffffffffc02034b6:	44e6b683          	ld	a3,1102(a3) # ffffffffc02b2900 <pages>
ffffffffc02034ba:	8d15                	sub	a0,a0,a3
ffffffffc02034bc:	8519                	srai	a0,a0,0x6
ffffffffc02034be:	00005697          	auipc	a3,0x5
ffffffffc02034c2:	7626b683          	ld	a3,1890(a3) # ffffffffc0208c20 <nbase>
ffffffffc02034c6:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02034c8:	00c51793          	slli	a5,a0,0xc
ffffffffc02034cc:	83b1                	srli	a5,a5,0xc
ffffffffc02034ce:	000af717          	auipc	a4,0xaf
ffffffffc02034d2:	42a73703          	ld	a4,1066(a4) # ffffffffc02b28f8 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02034d6:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02034d8:	00e7fa63          	bgeu	a5,a4,ffffffffc02034ec <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02034dc:	000af697          	auipc	a3,0xaf
ffffffffc02034e0:	4346b683          	ld	a3,1076(a3) # ffffffffc02b2910 <va_pa_offset>
ffffffffc02034e4:	9536                	add	a0,a0,a3
}
ffffffffc02034e6:	60a2                	ld	ra,8(sp)
ffffffffc02034e8:	0141                	addi	sp,sp,16
ffffffffc02034ea:	8082                	ret
ffffffffc02034ec:	86aa                	mv	a3,a0
ffffffffc02034ee:	00004617          	auipc	a2,0x4
ffffffffc02034f2:	a8260613          	addi	a2,a2,-1406 # ffffffffc0206f70 <commands+0x758>
ffffffffc02034f6:	06900593          	li	a1,105
ffffffffc02034fa:	00004517          	auipc	a0,0x4
ffffffffc02034fe:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0206f38 <commands+0x720>
ffffffffc0203502:	d07fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203506 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0203506:	1101                	addi	sp,sp,-32
ffffffffc0203508:	ec06                	sd	ra,24(sp)
ffffffffc020350a:	e822                	sd	s0,16(sp)
ffffffffc020350c:	e426                	sd	s1,8(sp)
ffffffffc020350e:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0203510:	01050713          	addi	a4,a0,16
ffffffffc0203514:	6785                	lui	a5,0x1
ffffffffc0203516:	0cf77363          	bgeu	a4,a5,ffffffffc02035dc <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc020351a:	00f50493          	addi	s1,a0,15
ffffffffc020351e:	8091                	srli	s1,s1,0x4
ffffffffc0203520:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203522:	10002673          	csrr	a2,sstatus
ffffffffc0203526:	8a09                	andi	a2,a2,2
ffffffffc0203528:	e25d                	bnez	a2,ffffffffc02035ce <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc020352a:	000a4917          	auipc	s2,0xa4
ffffffffc020352e:	ece90913          	addi	s2,s2,-306 # ffffffffc02a73f8 <slobfree>
ffffffffc0203532:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203536:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203538:	4398                	lw	a4,0(a5)
ffffffffc020353a:	08975e63          	bge	a4,s1,ffffffffc02035d6 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc020353e:	00f68b63          	beq	a3,a5,ffffffffc0203554 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203542:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203544:	4018                	lw	a4,0(s0)
ffffffffc0203546:	02975a63          	bge	a4,s1,ffffffffc020357a <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc020354a:	00093683          	ld	a3,0(s2)
ffffffffc020354e:	87a2                	mv	a5,s0
ffffffffc0203550:	fef699e3          	bne	a3,a5,ffffffffc0203542 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0203554:	ee31                	bnez	a2,ffffffffc02035b0 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0203556:	4501                	li	a0,0
ffffffffc0203558:	f4bff0ef          	jal	ra,ffffffffc02034a2 <__slob_get_free_pages.constprop.0>
ffffffffc020355c:	842a                	mv	s0,a0
			if (!cur)
ffffffffc020355e:	cd05                	beqz	a0,ffffffffc0203596 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0203560:	6585                	lui	a1,0x1
ffffffffc0203562:	e8dff0ef          	jal	ra,ffffffffc02033ee <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203566:	10002673          	csrr	a2,sstatus
ffffffffc020356a:	8a09                	andi	a2,a2,2
ffffffffc020356c:	ee05                	bnez	a2,ffffffffc02035a4 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc020356e:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203572:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203574:	4018                	lw	a4,0(s0)
ffffffffc0203576:	fc974ae3          	blt	a4,s1,ffffffffc020354a <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc020357a:	04e48763          	beq	s1,a4,ffffffffc02035c8 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc020357e:	00449693          	slli	a3,s1,0x4
ffffffffc0203582:	96a2                	add	a3,a3,s0
ffffffffc0203584:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0203586:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0203588:	9f05                	subw	a4,a4,s1
ffffffffc020358a:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc020358c:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc020358e:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0203590:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0203594:	e20d                	bnez	a2,ffffffffc02035b6 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0203596:	60e2                	ld	ra,24(sp)
ffffffffc0203598:	8522                	mv	a0,s0
ffffffffc020359a:	6442                	ld	s0,16(sp)
ffffffffc020359c:	64a2                	ld	s1,8(sp)
ffffffffc020359e:	6902                	ld	s2,0(sp)
ffffffffc02035a0:	6105                	addi	sp,sp,32
ffffffffc02035a2:	8082                	ret
        intr_disable();
ffffffffc02035a4:	8a4fd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
			cur = slobfree;
ffffffffc02035a8:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc02035ac:	4605                	li	a2,1
ffffffffc02035ae:	b7d1                	j	ffffffffc0203572 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc02035b0:	892fd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02035b4:	b74d                	j	ffffffffc0203556 <slob_alloc.constprop.0+0x50>
ffffffffc02035b6:	88cfd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
}
ffffffffc02035ba:	60e2                	ld	ra,24(sp)
ffffffffc02035bc:	8522                	mv	a0,s0
ffffffffc02035be:	6442                	ld	s0,16(sp)
ffffffffc02035c0:	64a2                	ld	s1,8(sp)
ffffffffc02035c2:	6902                	ld	s2,0(sp)
ffffffffc02035c4:	6105                	addi	sp,sp,32
ffffffffc02035c6:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02035c8:	6418                	ld	a4,8(s0)
ffffffffc02035ca:	e798                	sd	a4,8(a5)
ffffffffc02035cc:	b7d1                	j	ffffffffc0203590 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc02035ce:	87afd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02035d2:	4605                	li	a2,1
ffffffffc02035d4:	bf99                	j	ffffffffc020352a <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02035d6:	843e                	mv	s0,a5
ffffffffc02035d8:	87b6                	mv	a5,a3
ffffffffc02035da:	b745                	j	ffffffffc020357a <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02035dc:	00004697          	auipc	a3,0x4
ffffffffc02035e0:	54c68693          	addi	a3,a3,1356 # ffffffffc0207b28 <commands+0x1310>
ffffffffc02035e4:	00003617          	auipc	a2,0x3
ffffffffc02035e8:	64460613          	addi	a2,a2,1604 # ffffffffc0206c28 <commands+0x410>
ffffffffc02035ec:	06400593          	li	a1,100
ffffffffc02035f0:	00004517          	auipc	a0,0x4
ffffffffc02035f4:	55850513          	addi	a0,a0,1368 # ffffffffc0207b48 <commands+0x1330>
ffffffffc02035f8:	c11fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02035fc <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02035fc:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02035fe:	00004517          	auipc	a0,0x4
ffffffffc0203602:	56250513          	addi	a0,a0,1378 # ffffffffc0207b60 <commands+0x1348>
kmalloc_init(void) {
ffffffffc0203606:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0203608:	ac5fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc020360c:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc020360e:	00004517          	auipc	a0,0x4
ffffffffc0203612:	56a50513          	addi	a0,a0,1386 # ffffffffc0207b78 <commands+0x1360>
}
ffffffffc0203616:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0203618:	ab5fc06f          	j	ffffffffc02000cc <cprintf>

ffffffffc020361c <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc020361c:	4501                	li	a0,0
ffffffffc020361e:	8082                	ret

ffffffffc0203620 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0203620:	1101                	addi	sp,sp,-32
ffffffffc0203622:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203624:	6905                	lui	s2,0x1
{
ffffffffc0203626:	e822                	sd	s0,16(sp)
ffffffffc0203628:	ec06                	sd	ra,24(sp)
ffffffffc020362a:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020362c:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bd1>
{
ffffffffc0203630:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203632:	04a7f963          	bgeu	a5,a0,ffffffffc0203684 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0203636:	4561                	li	a0,24
ffffffffc0203638:	ecfff0ef          	jal	ra,ffffffffc0203506 <slob_alloc.constprop.0>
ffffffffc020363c:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc020363e:	c929                	beqz	a0,ffffffffc0203690 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0203640:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0203644:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0203646:	00f95763          	bge	s2,a5,ffffffffc0203654 <kmalloc+0x34>
ffffffffc020364a:	6705                	lui	a4,0x1
ffffffffc020364c:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc020364e:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0203650:	fef74ee3          	blt	a4,a5,ffffffffc020364c <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0203654:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0203656:	e4dff0ef          	jal	ra,ffffffffc02034a2 <__slob_get_free_pages.constprop.0>
ffffffffc020365a:	e488                	sd	a0,8(s1)
ffffffffc020365c:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc020365e:	c525                	beqz	a0,ffffffffc02036c6 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203660:	100027f3          	csrr	a5,sstatus
ffffffffc0203664:	8b89                	andi	a5,a5,2
ffffffffc0203666:	ef8d                	bnez	a5,ffffffffc02036a0 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0203668:	000af797          	auipc	a5,0xaf
ffffffffc020366c:	2c078793          	addi	a5,a5,704 # ffffffffc02b2928 <bigblocks>
ffffffffc0203670:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0203672:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0203674:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0203676:	60e2                	ld	ra,24(sp)
ffffffffc0203678:	8522                	mv	a0,s0
ffffffffc020367a:	6442                	ld	s0,16(sp)
ffffffffc020367c:	64a2                	ld	s1,8(sp)
ffffffffc020367e:	6902                	ld	s2,0(sp)
ffffffffc0203680:	6105                	addi	sp,sp,32
ffffffffc0203682:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0203684:	0541                	addi	a0,a0,16
ffffffffc0203686:	e81ff0ef          	jal	ra,ffffffffc0203506 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc020368a:	01050413          	addi	s0,a0,16
ffffffffc020368e:	f565                	bnez	a0,ffffffffc0203676 <kmalloc+0x56>
ffffffffc0203690:	4401                	li	s0,0
}
ffffffffc0203692:	60e2                	ld	ra,24(sp)
ffffffffc0203694:	8522                	mv	a0,s0
ffffffffc0203696:	6442                	ld	s0,16(sp)
ffffffffc0203698:	64a2                	ld	s1,8(sp)
ffffffffc020369a:	6902                	ld	s2,0(sp)
ffffffffc020369c:	6105                	addi	sp,sp,32
ffffffffc020369e:	8082                	ret
        intr_disable();
ffffffffc02036a0:	fa9fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		bb->next = bigblocks;
ffffffffc02036a4:	000af797          	auipc	a5,0xaf
ffffffffc02036a8:	28478793          	addi	a5,a5,644 # ffffffffc02b2928 <bigblocks>
ffffffffc02036ac:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc02036ae:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc02036b0:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc02036b2:	f91fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
		return bb->pages;
ffffffffc02036b6:	6480                	ld	s0,8(s1)
}
ffffffffc02036b8:	60e2                	ld	ra,24(sp)
ffffffffc02036ba:	64a2                	ld	s1,8(sp)
ffffffffc02036bc:	8522                	mv	a0,s0
ffffffffc02036be:	6442                	ld	s0,16(sp)
ffffffffc02036c0:	6902                	ld	s2,0(sp)
ffffffffc02036c2:	6105                	addi	sp,sp,32
ffffffffc02036c4:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc02036c6:	45e1                	li	a1,24
ffffffffc02036c8:	8526                	mv	a0,s1
ffffffffc02036ca:	d25ff0ef          	jal	ra,ffffffffc02033ee <slob_free>
  return __kmalloc(size, 0);
ffffffffc02036ce:	b765                	j	ffffffffc0203676 <kmalloc+0x56>

ffffffffc02036d0 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc02036d0:	c179                	beqz	a0,ffffffffc0203796 <kfree+0xc6>
{
ffffffffc02036d2:	1101                	addi	sp,sp,-32
ffffffffc02036d4:	e822                	sd	s0,16(sp)
ffffffffc02036d6:	ec06                	sd	ra,24(sp)
ffffffffc02036d8:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc02036da:	03451793          	slli	a5,a0,0x34
ffffffffc02036de:	842a                	mv	s0,a0
ffffffffc02036e0:	e7c1                	bnez	a5,ffffffffc0203768 <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02036e2:	100027f3          	csrr	a5,sstatus
ffffffffc02036e6:	8b89                	andi	a5,a5,2
ffffffffc02036e8:	ebc9                	bnez	a5,ffffffffc020377a <kfree+0xaa>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02036ea:	000af797          	auipc	a5,0xaf
ffffffffc02036ee:	23e7b783          	ld	a5,574(a5) # ffffffffc02b2928 <bigblocks>
    return 0;
ffffffffc02036f2:	4601                	li	a2,0
ffffffffc02036f4:	cbb5                	beqz	a5,ffffffffc0203768 <kfree+0x98>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc02036f6:	000af697          	auipc	a3,0xaf
ffffffffc02036fa:	23268693          	addi	a3,a3,562 # ffffffffc02b2928 <bigblocks>
ffffffffc02036fe:	a021                	j	ffffffffc0203706 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203700:	01048693          	addi	a3,s1,16
ffffffffc0203704:	c3ad                	beqz	a5,ffffffffc0203766 <kfree+0x96>
			if (bb->pages == block) {
ffffffffc0203706:	6798                	ld	a4,8(a5)
ffffffffc0203708:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc020370a:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc020370c:	fe871ae3          	bne	a4,s0,ffffffffc0203700 <kfree+0x30>
				*last = bb->next;
ffffffffc0203710:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0203712:	ee3d                	bnez	a2,ffffffffc0203790 <kfree+0xc0>
    return pa2page(PADDR(kva));
ffffffffc0203714:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0203718:	4098                	lw	a4,0(s1)
ffffffffc020371a:	08f46b63          	bltu	s0,a5,ffffffffc02037b0 <kfree+0xe0>
ffffffffc020371e:	000af697          	auipc	a3,0xaf
ffffffffc0203722:	1f26b683          	ld	a3,498(a3) # ffffffffc02b2910 <va_pa_offset>
ffffffffc0203726:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0203728:	8031                	srli	s0,s0,0xc
ffffffffc020372a:	000af797          	auipc	a5,0xaf
ffffffffc020372e:	1ce7b783          	ld	a5,462(a5) # ffffffffc02b28f8 <npage>
ffffffffc0203732:	06f47363          	bgeu	s0,a5,ffffffffc0203798 <kfree+0xc8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203736:	00005517          	auipc	a0,0x5
ffffffffc020373a:	4ea53503          	ld	a0,1258(a0) # ffffffffc0208c20 <nbase>
ffffffffc020373e:	8c09                	sub	s0,s0,a0
ffffffffc0203740:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0203742:	000af517          	auipc	a0,0xaf
ffffffffc0203746:	1be53503          	ld	a0,446(a0) # ffffffffc02b2900 <pages>
ffffffffc020374a:	4585                	li	a1,1
ffffffffc020374c:	9522                	add	a0,a0,s0
ffffffffc020374e:	00e595bb          	sllw	a1,a1,a4
ffffffffc0203752:	f9afd0ef          	jal	ra,ffffffffc0200eec <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0203756:	6442                	ld	s0,16(sp)
ffffffffc0203758:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020375a:	8526                	mv	a0,s1
}
ffffffffc020375c:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020375e:	45e1                	li	a1,24
}
ffffffffc0203760:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203762:	c8dff06f          	j	ffffffffc02033ee <slob_free>
ffffffffc0203766:	e215                	bnez	a2,ffffffffc020378a <kfree+0xba>
ffffffffc0203768:	ff040513          	addi	a0,s0,-16
}
ffffffffc020376c:	6442                	ld	s0,16(sp)
ffffffffc020376e:	60e2                	ld	ra,24(sp)
ffffffffc0203770:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203772:	4581                	li	a1,0
}
ffffffffc0203774:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203776:	c79ff06f          	j	ffffffffc02033ee <slob_free>
        intr_disable();
ffffffffc020377a:	ecffc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020377e:	000af797          	auipc	a5,0xaf
ffffffffc0203782:	1aa7b783          	ld	a5,426(a5) # ffffffffc02b2928 <bigblocks>
        return 1;
ffffffffc0203786:	4605                	li	a2,1
ffffffffc0203788:	f7bd                	bnez	a5,ffffffffc02036f6 <kfree+0x26>
        intr_enable();
ffffffffc020378a:	eb9fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020378e:	bfe9                	j	ffffffffc0203768 <kfree+0x98>
ffffffffc0203790:	eb3fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203794:	b741                	j	ffffffffc0203714 <kfree+0x44>
ffffffffc0203796:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0203798:	00003617          	auipc	a2,0x3
ffffffffc020379c:	78060613          	addi	a2,a2,1920 # ffffffffc0206f18 <commands+0x700>
ffffffffc02037a0:	06200593          	li	a1,98
ffffffffc02037a4:	00003517          	auipc	a0,0x3
ffffffffc02037a8:	79450513          	addi	a0,a0,1940 # ffffffffc0206f38 <commands+0x720>
ffffffffc02037ac:	a5dfc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02037b0:	86a2                	mv	a3,s0
ffffffffc02037b2:	00004617          	auipc	a2,0x4
ffffffffc02037b6:	89660613          	addi	a2,a2,-1898 # ffffffffc0207048 <commands+0x830>
ffffffffc02037ba:	06e00593          	li	a1,110
ffffffffc02037be:	00003517          	auipc	a0,0x3
ffffffffc02037c2:	77a50513          	addi	a0,a0,1914 # ffffffffc0206f38 <commands+0x720>
ffffffffc02037c6:	a43fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02037ca <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02037ca:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02037cc:	00003617          	auipc	a2,0x3
ffffffffc02037d0:	74c60613          	addi	a2,a2,1868 # ffffffffc0206f18 <commands+0x700>
ffffffffc02037d4:	06200593          	li	a1,98
ffffffffc02037d8:	00003517          	auipc	a0,0x3
ffffffffc02037dc:	76050513          	addi	a0,a0,1888 # ffffffffc0206f38 <commands+0x720>
pa2page(uintptr_t pa) {
ffffffffc02037e0:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02037e2:	a27fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02037e6 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02037e6:	7135                	addi	sp,sp,-160
ffffffffc02037e8:	ed06                	sd	ra,152(sp)
ffffffffc02037ea:	e922                	sd	s0,144(sp)
ffffffffc02037ec:	e526                	sd	s1,136(sp)
ffffffffc02037ee:	e14a                	sd	s2,128(sp)
ffffffffc02037f0:	fcce                	sd	s3,120(sp)
ffffffffc02037f2:	f8d2                	sd	s4,112(sp)
ffffffffc02037f4:	f4d6                	sd	s5,104(sp)
ffffffffc02037f6:	f0da                	sd	s6,96(sp)
ffffffffc02037f8:	ecde                	sd	s7,88(sp)
ffffffffc02037fa:	e8e2                	sd	s8,80(sp)
ffffffffc02037fc:	e4e6                	sd	s9,72(sp)
ffffffffc02037fe:	e0ea                	sd	s10,64(sp)
ffffffffc0203800:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0203802:	37e010ef          	jal	ra,ffffffffc0204b80 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0203806:	000af697          	auipc	a3,0xaf
ffffffffc020380a:	12a6b683          	ld	a3,298(a3) # ffffffffc02b2930 <max_swap_offset>
ffffffffc020380e:	010007b7          	lui	a5,0x1000
ffffffffc0203812:	ff968713          	addi	a4,a3,-7
ffffffffc0203816:	17e1                	addi	a5,a5,-8
ffffffffc0203818:	42e7e663          	bltu	a5,a4,ffffffffc0203c44 <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc020381c:	000a4797          	auipc	a5,0xa4
ffffffffc0203820:	b8c78793          	addi	a5,a5,-1140 # ffffffffc02a73a8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0203824:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0203826:	000afb97          	auipc	s7,0xaf
ffffffffc020382a:	112b8b93          	addi	s7,s7,274 # ffffffffc02b2938 <sm>
ffffffffc020382e:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc0203832:	9702                	jalr	a4
ffffffffc0203834:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc0203836:	c10d                	beqz	a0,ffffffffc0203858 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0203838:	60ea                	ld	ra,152(sp)
ffffffffc020383a:	644a                	ld	s0,144(sp)
ffffffffc020383c:	64aa                	ld	s1,136(sp)
ffffffffc020383e:	79e6                	ld	s3,120(sp)
ffffffffc0203840:	7a46                	ld	s4,112(sp)
ffffffffc0203842:	7aa6                	ld	s5,104(sp)
ffffffffc0203844:	7b06                	ld	s6,96(sp)
ffffffffc0203846:	6be6                	ld	s7,88(sp)
ffffffffc0203848:	6c46                	ld	s8,80(sp)
ffffffffc020384a:	6ca6                	ld	s9,72(sp)
ffffffffc020384c:	6d06                	ld	s10,64(sp)
ffffffffc020384e:	7de2                	ld	s11,56(sp)
ffffffffc0203850:	854a                	mv	a0,s2
ffffffffc0203852:	690a                	ld	s2,128(sp)
ffffffffc0203854:	610d                	addi	sp,sp,160
ffffffffc0203856:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203858:	000bb783          	ld	a5,0(s7)
ffffffffc020385c:	00004517          	auipc	a0,0x4
ffffffffc0203860:	36c50513          	addi	a0,a0,876 # ffffffffc0207bc8 <commands+0x13b0>
ffffffffc0203864:	000ab417          	auipc	s0,0xab
ffffffffc0203868:	04440413          	addi	s0,s0,68 # ffffffffc02ae8a8 <free_area>
ffffffffc020386c:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020386e:	4785                	li	a5,1
ffffffffc0203870:	000af717          	auipc	a4,0xaf
ffffffffc0203874:	0cf72823          	sw	a5,208(a4) # ffffffffc02b2940 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203878:	855fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020387c:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc020387e:	4d01                	li	s10,0
ffffffffc0203880:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203882:	34878163          	beq	a5,s0,ffffffffc0203bc4 <swap_init+0x3de>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203886:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020388a:	8b09                	andi	a4,a4,2
ffffffffc020388c:	32070e63          	beqz	a4,ffffffffc0203bc8 <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc0203890:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203894:	679c                	ld	a5,8(a5)
ffffffffc0203896:	2d85                	addiw	s11,s11,1
ffffffffc0203898:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc020389c:	fe8795e3          	bne	a5,s0,ffffffffc0203886 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc02038a0:	84ea                	mv	s1,s10
ffffffffc02038a2:	e8afd0ef          	jal	ra,ffffffffc0200f2c <nr_free_pages>
ffffffffc02038a6:	42951763          	bne	a0,s1,ffffffffc0203cd4 <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02038aa:	866a                	mv	a2,s10
ffffffffc02038ac:	85ee                	mv	a1,s11
ffffffffc02038ae:	00004517          	auipc	a0,0x4
ffffffffc02038b2:	36250513          	addi	a0,a0,866 # ffffffffc0207c10 <commands+0x13f8>
ffffffffc02038b6:	817fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02038ba:	8e8ff0ef          	jal	ra,ffffffffc02029a2 <mm_create>
ffffffffc02038be:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02038c0:	46050a63          	beqz	a0,ffffffffc0203d34 <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02038c4:	000af797          	auipc	a5,0xaf
ffffffffc02038c8:	05478793          	addi	a5,a5,84 # ffffffffc02b2918 <check_mm_struct>
ffffffffc02038cc:	6398                	ld	a4,0(a5)
ffffffffc02038ce:	3e071363          	bnez	a4,ffffffffc0203cb4 <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02038d2:	000af717          	auipc	a4,0xaf
ffffffffc02038d6:	01e70713          	addi	a4,a4,30 # ffffffffc02b28f0 <boot_pgdir>
ffffffffc02038da:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc02038de:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc02038e0:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02038e4:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02038e8:	42079663          	bnez	a5,ffffffffc0203d14 <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02038ec:	6599                	lui	a1,0x6
ffffffffc02038ee:	460d                	li	a2,3
ffffffffc02038f0:	6505                	lui	a0,0x1
ffffffffc02038f2:	8f8ff0ef          	jal	ra,ffffffffc02029ea <vma_create>
ffffffffc02038f6:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02038f8:	52050a63          	beqz	a0,ffffffffc0203e2c <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc02038fc:	8556                	mv	a0,s5
ffffffffc02038fe:	95aff0ef          	jal	ra,ffffffffc0202a58 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0203902:	00004517          	auipc	a0,0x4
ffffffffc0203906:	34e50513          	addi	a0,a0,846 # ffffffffc0207c50 <commands+0x1438>
ffffffffc020390a:	fc2fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc020390e:	018ab503          	ld	a0,24(s5)
ffffffffc0203912:	4605                	li	a2,1
ffffffffc0203914:	6585                	lui	a1,0x1
ffffffffc0203916:	e50fd0ef          	jal	ra,ffffffffc0200f66 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc020391a:	4c050963          	beqz	a0,ffffffffc0203dec <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020391e:	00004517          	auipc	a0,0x4
ffffffffc0203922:	38250513          	addi	a0,a0,898 # ffffffffc0207ca0 <commands+0x1488>
ffffffffc0203926:	000ab497          	auipc	s1,0xab
ffffffffc020392a:	f1248493          	addi	s1,s1,-238 # ffffffffc02ae838 <check_rp>
ffffffffc020392e:	f9efc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203932:	000ab997          	auipc	s3,0xab
ffffffffc0203936:	f2698993          	addi	s3,s3,-218 # ffffffffc02ae858 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020393a:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc020393c:	4505                	li	a0,1
ffffffffc020393e:	d1cfd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0203942:	00aa3023          	sd	a0,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
          assert(check_rp[i] != NULL );
ffffffffc0203946:	2c050f63          	beqz	a0,ffffffffc0203c24 <swap_init+0x43e>
ffffffffc020394a:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc020394c:	8b89                	andi	a5,a5,2
ffffffffc020394e:	34079363          	bnez	a5,ffffffffc0203c94 <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203952:	0a21                	addi	s4,s4,8
ffffffffc0203954:	ff3a14e3          	bne	s4,s3,ffffffffc020393c <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203958:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc020395a:	000aba17          	auipc	s4,0xab
ffffffffc020395e:	edea0a13          	addi	s4,s4,-290 # ffffffffc02ae838 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0203962:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0203964:	ec3e                	sd	a5,24(sp)
ffffffffc0203966:	641c                	ld	a5,8(s0)
ffffffffc0203968:	e400                	sd	s0,8(s0)
ffffffffc020396a:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc020396c:	481c                	lw	a5,16(s0)
ffffffffc020396e:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0203970:	000ab797          	auipc	a5,0xab
ffffffffc0203974:	f407a423          	sw	zero,-184(a5) # ffffffffc02ae8b8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203978:	000a3503          	ld	a0,0(s4)
ffffffffc020397c:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020397e:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0203980:	d6cfd0ef          	jal	ra,ffffffffc0200eec <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203984:	ff3a1ae3          	bne	s4,s3,ffffffffc0203978 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203988:	01042a03          	lw	s4,16(s0)
ffffffffc020398c:	4791                	li	a5,4
ffffffffc020398e:	42fa1f63          	bne	s4,a5,ffffffffc0203dcc <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0203992:	00004517          	auipc	a0,0x4
ffffffffc0203996:	39650513          	addi	a0,a0,918 # ffffffffc0207d28 <commands+0x1510>
ffffffffc020399a:	f32fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020399e:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02039a0:	000af797          	auipc	a5,0xaf
ffffffffc02039a4:	f807a023          	sw	zero,-128(a5) # ffffffffc02b2920 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02039a8:	4629                	li	a2,10
ffffffffc02039aa:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
     assert(pgfault_num==1);
ffffffffc02039ae:	000af697          	auipc	a3,0xaf
ffffffffc02039b2:	f726a683          	lw	a3,-142(a3) # ffffffffc02b2920 <pgfault_num>
ffffffffc02039b6:	4585                	li	a1,1
ffffffffc02039b8:	000af797          	auipc	a5,0xaf
ffffffffc02039bc:	f6878793          	addi	a5,a5,-152 # ffffffffc02b2920 <pgfault_num>
ffffffffc02039c0:	54b69663          	bne	a3,a1,ffffffffc0203f0c <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02039c4:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc02039c8:	4398                	lw	a4,0(a5)
ffffffffc02039ca:	2701                	sext.w	a4,a4
ffffffffc02039cc:	3ed71063          	bne	a4,a3,ffffffffc0203dac <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02039d0:	6689                	lui	a3,0x2
ffffffffc02039d2:	462d                	li	a2,11
ffffffffc02039d4:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bc0>
     assert(pgfault_num==2);
ffffffffc02039d8:	4398                	lw	a4,0(a5)
ffffffffc02039da:	4589                	li	a1,2
ffffffffc02039dc:	2701                	sext.w	a4,a4
ffffffffc02039de:	4ab71763          	bne	a4,a1,ffffffffc0203e8c <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02039e2:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02039e6:	4394                	lw	a3,0(a5)
ffffffffc02039e8:	2681                	sext.w	a3,a3
ffffffffc02039ea:	4ce69163          	bne	a3,a4,ffffffffc0203eac <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02039ee:	668d                	lui	a3,0x3
ffffffffc02039f0:	4631                	li	a2,12
ffffffffc02039f2:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bc0>
     assert(pgfault_num==3);
ffffffffc02039f6:	4398                	lw	a4,0(a5)
ffffffffc02039f8:	458d                	li	a1,3
ffffffffc02039fa:	2701                	sext.w	a4,a4
ffffffffc02039fc:	4cb71863          	bne	a4,a1,ffffffffc0203ecc <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203a00:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0203a04:	4394                	lw	a3,0(a5)
ffffffffc0203a06:	2681                	sext.w	a3,a3
ffffffffc0203a08:	4ee69263          	bne	a3,a4,ffffffffc0203eec <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203a0c:	6691                	lui	a3,0x4
ffffffffc0203a0e:	4635                	li	a2,13
ffffffffc0203a10:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bc0>
     assert(pgfault_num==4);
ffffffffc0203a14:	4398                	lw	a4,0(a5)
ffffffffc0203a16:	2701                	sext.w	a4,a4
ffffffffc0203a18:	43471a63          	bne	a4,s4,ffffffffc0203e4c <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0203a1c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203a20:	439c                	lw	a5,0(a5)
ffffffffc0203a22:	2781                	sext.w	a5,a5
ffffffffc0203a24:	44e79463          	bne	a5,a4,ffffffffc0203e6c <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0203a28:	481c                	lw	a5,16(s0)
ffffffffc0203a2a:	2c079563          	bnez	a5,ffffffffc0203cf4 <swap_init+0x50e>
ffffffffc0203a2e:	000ab797          	auipc	a5,0xab
ffffffffc0203a32:	e2a78793          	addi	a5,a5,-470 # ffffffffc02ae858 <swap_in_seq_no>
ffffffffc0203a36:	000ab717          	auipc	a4,0xab
ffffffffc0203a3a:	e4a70713          	addi	a4,a4,-438 # ffffffffc02ae880 <swap_out_seq_no>
ffffffffc0203a3e:	000ab617          	auipc	a2,0xab
ffffffffc0203a42:	e4260613          	addi	a2,a2,-446 # ffffffffc02ae880 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0203a46:	56fd                	li	a3,-1
ffffffffc0203a48:	c394                	sw	a3,0(a5)
ffffffffc0203a4a:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203a4c:	0791                	addi	a5,a5,4
ffffffffc0203a4e:	0711                	addi	a4,a4,4
ffffffffc0203a50:	fec79ce3          	bne	a5,a2,ffffffffc0203a48 <swap_init+0x262>
ffffffffc0203a54:	000ab717          	auipc	a4,0xab
ffffffffc0203a58:	dc470713          	addi	a4,a4,-572 # ffffffffc02ae818 <check_ptep>
ffffffffc0203a5c:	000ab697          	auipc	a3,0xab
ffffffffc0203a60:	ddc68693          	addi	a3,a3,-548 # ffffffffc02ae838 <check_rp>
ffffffffc0203a64:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203a66:	000afc17          	auipc	s8,0xaf
ffffffffc0203a6a:	e92c0c13          	addi	s8,s8,-366 # ffffffffc02b28f8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a6e:	000afc97          	auipc	s9,0xaf
ffffffffc0203a72:	e92c8c93          	addi	s9,s9,-366 # ffffffffc02b2900 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203a76:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203a7a:	4601                	li	a2,0
ffffffffc0203a7c:	855a                	mv	a0,s6
ffffffffc0203a7e:	e836                	sd	a3,16(sp)
ffffffffc0203a80:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0203a82:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203a84:	ce2fd0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc0203a88:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203a8a:	65a2                	ld	a1,8(sp)
ffffffffc0203a8c:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203a8e:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0203a90:	1c050663          	beqz	a0,ffffffffc0203c5c <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203a94:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203a96:	0017f613          	andi	a2,a5,1
ffffffffc0203a9a:	1e060163          	beqz	a2,ffffffffc0203c7c <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0203a9e:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203aa2:	078a                	slli	a5,a5,0x2
ffffffffc0203aa4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203aa6:	14c7f363          	bgeu	a5,a2,ffffffffc0203bec <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0203aaa:	00005617          	auipc	a2,0x5
ffffffffc0203aae:	17660613          	addi	a2,a2,374 # ffffffffc0208c20 <nbase>
ffffffffc0203ab2:	00063a03          	ld	s4,0(a2)
ffffffffc0203ab6:	000cb603          	ld	a2,0(s9)
ffffffffc0203aba:	6288                	ld	a0,0(a3)
ffffffffc0203abc:	414787b3          	sub	a5,a5,s4
ffffffffc0203ac0:	079a                	slli	a5,a5,0x6
ffffffffc0203ac2:	97b2                	add	a5,a5,a2
ffffffffc0203ac4:	14f51063          	bne	a0,a5,ffffffffc0203c04 <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203ac8:	6785                	lui	a5,0x1
ffffffffc0203aca:	95be                	add	a1,a1,a5
ffffffffc0203acc:	6795                	lui	a5,0x5
ffffffffc0203ace:	0721                	addi	a4,a4,8
ffffffffc0203ad0:	06a1                	addi	a3,a3,8
ffffffffc0203ad2:	faf592e3          	bne	a1,a5,ffffffffc0203a76 <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0203ad6:	00004517          	auipc	a0,0x4
ffffffffc0203ada:	2fa50513          	addi	a0,a0,762 # ffffffffc0207dd0 <commands+0x15b8>
ffffffffc0203ade:	deefc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc0203ae2:	000bb783          	ld	a5,0(s7)
ffffffffc0203ae6:	7f9c                	ld	a5,56(a5)
ffffffffc0203ae8:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203aea:	32051163          	bnez	a0,ffffffffc0203e0c <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc0203aee:	77a2                	ld	a5,40(sp)
ffffffffc0203af0:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0203af2:	67e2                	ld	a5,24(sp)
ffffffffc0203af4:	e01c                	sd	a5,0(s0)
ffffffffc0203af6:	7782                	ld	a5,32(sp)
ffffffffc0203af8:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203afa:	6088                	ld	a0,0(s1)
ffffffffc0203afc:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203afe:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0203b00:	becfd0ef          	jal	ra,ffffffffc0200eec <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203b04:	ff349be3          	bne	s1,s3,ffffffffc0203afa <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203b08:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc0203b0c:	8556                	mv	a0,s5
ffffffffc0203b0e:	81aff0ef          	jal	ra,ffffffffc0202b28 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203b12:	000af797          	auipc	a5,0xaf
ffffffffc0203b16:	dde78793          	addi	a5,a5,-546 # ffffffffc02b28f0 <boot_pgdir>
ffffffffc0203b1a:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203b1c:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc0203b20:	000af697          	auipc	a3,0xaf
ffffffffc0203b24:	de06bc23          	sd	zero,-520(a3) # ffffffffc02b2918 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b28:	639c                	ld	a5,0(a5)
ffffffffc0203b2a:	078a                	slli	a5,a5,0x2
ffffffffc0203b2c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b2e:	0ae7fd63          	bgeu	a5,a4,ffffffffc0203be8 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b32:	414786b3          	sub	a3,a5,s4
ffffffffc0203b36:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203b38:	8699                	srai	a3,a3,0x6
ffffffffc0203b3a:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203b3c:	00c69793          	slli	a5,a3,0xc
ffffffffc0203b40:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0203b42:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b46:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203b48:	22e7f663          	bgeu	a5,a4,ffffffffc0203d74 <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc0203b4c:	000af797          	auipc	a5,0xaf
ffffffffc0203b50:	dc47b783          	ld	a5,-572(a5) # ffffffffc02b2910 <va_pa_offset>
ffffffffc0203b54:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b56:	629c                	ld	a5,0(a3)
ffffffffc0203b58:	078a                	slli	a5,a5,0x2
ffffffffc0203b5a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b5c:	08e7f663          	bgeu	a5,a4,ffffffffc0203be8 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b60:	414787b3          	sub	a5,a5,s4
ffffffffc0203b64:	079a                	slli	a5,a5,0x6
ffffffffc0203b66:	953e                	add	a0,a0,a5
ffffffffc0203b68:	4585                	li	a1,1
ffffffffc0203b6a:	b82fd0ef          	jal	ra,ffffffffc0200eec <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b6e:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203b72:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b76:	078a                	slli	a5,a5,0x2
ffffffffc0203b78:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b7a:	06e7f763          	bgeu	a5,a4,ffffffffc0203be8 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b7e:	000cb503          	ld	a0,0(s9)
ffffffffc0203b82:	414787b3          	sub	a5,a5,s4
ffffffffc0203b86:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203b88:	4585                	li	a1,1
ffffffffc0203b8a:	953e                	add	a0,a0,a5
ffffffffc0203b8c:	b60fd0ef          	jal	ra,ffffffffc0200eec <free_pages>
     pgdir[0] = 0;
ffffffffc0203b90:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203b94:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203b98:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203b9a:	00878a63          	beq	a5,s0,ffffffffc0203bae <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203b9e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203ba2:	679c                	ld	a5,8(a5)
ffffffffc0203ba4:	3dfd                	addiw	s11,s11,-1
ffffffffc0203ba6:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203baa:	fe879ae3          	bne	a5,s0,ffffffffc0203b9e <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc0203bae:	1c0d9f63          	bnez	s11,ffffffffc0203d8c <swap_init+0x5a6>
     assert(total==0);
ffffffffc0203bb2:	1a0d1163          	bnez	s10,ffffffffc0203d54 <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203bb6:	00004517          	auipc	a0,0x4
ffffffffc0203bba:	26a50513          	addi	a0,a0,618 # ffffffffc0207e20 <commands+0x1608>
ffffffffc0203bbe:	d0efc0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0203bc2:	b99d                	j	ffffffffc0203838 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203bc4:	4481                	li	s1,0
ffffffffc0203bc6:	b9f1                	j	ffffffffc02038a2 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0203bc8:	00004697          	auipc	a3,0x4
ffffffffc0203bcc:	01868693          	addi	a3,a3,24 # ffffffffc0207be0 <commands+0x13c8>
ffffffffc0203bd0:	00003617          	auipc	a2,0x3
ffffffffc0203bd4:	05860613          	addi	a2,a2,88 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203bd8:	0bc00593          	li	a1,188
ffffffffc0203bdc:	00004517          	auipc	a0,0x4
ffffffffc0203be0:	fdc50513          	addi	a0,a0,-36 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203be4:	e24fc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0203be8:	be3ff0ef          	jal	ra,ffffffffc02037ca <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0203bec:	00003617          	auipc	a2,0x3
ffffffffc0203bf0:	32c60613          	addi	a2,a2,812 # ffffffffc0206f18 <commands+0x700>
ffffffffc0203bf4:	06200593          	li	a1,98
ffffffffc0203bf8:	00003517          	auipc	a0,0x3
ffffffffc0203bfc:	34050513          	addi	a0,a0,832 # ffffffffc0206f38 <commands+0x720>
ffffffffc0203c00:	e08fc0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203c04:	00004697          	auipc	a3,0x4
ffffffffc0203c08:	1a468693          	addi	a3,a3,420 # ffffffffc0207da8 <commands+0x1590>
ffffffffc0203c0c:	00003617          	auipc	a2,0x3
ffffffffc0203c10:	01c60613          	addi	a2,a2,28 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203c14:	0fc00593          	li	a1,252
ffffffffc0203c18:	00004517          	auipc	a0,0x4
ffffffffc0203c1c:	fa050513          	addi	a0,a0,-96 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203c20:	de8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203c24:	00004697          	auipc	a3,0x4
ffffffffc0203c28:	0a468693          	addi	a3,a3,164 # ffffffffc0207cc8 <commands+0x14b0>
ffffffffc0203c2c:	00003617          	auipc	a2,0x3
ffffffffc0203c30:	ffc60613          	addi	a2,a2,-4 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203c34:	0dc00593          	li	a1,220
ffffffffc0203c38:	00004517          	auipc	a0,0x4
ffffffffc0203c3c:	f8050513          	addi	a0,a0,-128 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203c40:	dc8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203c44:	00004617          	auipc	a2,0x4
ffffffffc0203c48:	f5460613          	addi	a2,a2,-172 # ffffffffc0207b98 <commands+0x1380>
ffffffffc0203c4c:	02800593          	li	a1,40
ffffffffc0203c50:	00004517          	auipc	a0,0x4
ffffffffc0203c54:	f6850513          	addi	a0,a0,-152 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203c58:	db0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203c5c:	00004697          	auipc	a3,0x4
ffffffffc0203c60:	13468693          	addi	a3,a3,308 # ffffffffc0207d90 <commands+0x1578>
ffffffffc0203c64:	00003617          	auipc	a2,0x3
ffffffffc0203c68:	fc460613          	addi	a2,a2,-60 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203c6c:	0fb00593          	li	a1,251
ffffffffc0203c70:	00004517          	auipc	a0,0x4
ffffffffc0203c74:	f4850513          	addi	a0,a0,-184 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203c78:	d90fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203c7c:	00003617          	auipc	a2,0x3
ffffffffc0203c80:	2cc60613          	addi	a2,a2,716 # ffffffffc0206f48 <commands+0x730>
ffffffffc0203c84:	07400593          	li	a1,116
ffffffffc0203c88:	00003517          	auipc	a0,0x3
ffffffffc0203c8c:	2b050513          	addi	a0,a0,688 # ffffffffc0206f38 <commands+0x720>
ffffffffc0203c90:	d78fc0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203c94:	00004697          	auipc	a3,0x4
ffffffffc0203c98:	04c68693          	addi	a3,a3,76 # ffffffffc0207ce0 <commands+0x14c8>
ffffffffc0203c9c:	00003617          	auipc	a2,0x3
ffffffffc0203ca0:	f8c60613          	addi	a2,a2,-116 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203ca4:	0dd00593          	li	a1,221
ffffffffc0203ca8:	00004517          	auipc	a0,0x4
ffffffffc0203cac:	f1050513          	addi	a0,a0,-240 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203cb0:	d58fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203cb4:	00004697          	auipc	a3,0x4
ffffffffc0203cb8:	f8468693          	addi	a3,a3,-124 # ffffffffc0207c38 <commands+0x1420>
ffffffffc0203cbc:	00003617          	auipc	a2,0x3
ffffffffc0203cc0:	f6c60613          	addi	a2,a2,-148 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203cc4:	0c700593          	li	a1,199
ffffffffc0203cc8:	00004517          	auipc	a0,0x4
ffffffffc0203ccc:	ef050513          	addi	a0,a0,-272 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203cd0:	d38fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203cd4:	00004697          	auipc	a3,0x4
ffffffffc0203cd8:	f1c68693          	addi	a3,a3,-228 # ffffffffc0207bf0 <commands+0x13d8>
ffffffffc0203cdc:	00003617          	auipc	a2,0x3
ffffffffc0203ce0:	f4c60613          	addi	a2,a2,-180 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203ce4:	0bf00593          	li	a1,191
ffffffffc0203ce8:	00004517          	auipc	a0,0x4
ffffffffc0203cec:	ed050513          	addi	a0,a0,-304 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203cf0:	d18fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert( nr_free == 0);         
ffffffffc0203cf4:	00004697          	auipc	a3,0x4
ffffffffc0203cf8:	08c68693          	addi	a3,a3,140 # ffffffffc0207d80 <commands+0x1568>
ffffffffc0203cfc:	00003617          	auipc	a2,0x3
ffffffffc0203d00:	f2c60613          	addi	a2,a2,-212 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203d04:	0f300593          	li	a1,243
ffffffffc0203d08:	00004517          	auipc	a0,0x4
ffffffffc0203d0c:	eb050513          	addi	a0,a0,-336 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203d10:	cf8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203d14:	00004697          	auipc	a3,0x4
ffffffffc0203d18:	cc468693          	addi	a3,a3,-828 # ffffffffc02079d8 <commands+0x11c0>
ffffffffc0203d1c:	00003617          	auipc	a2,0x3
ffffffffc0203d20:	f0c60613          	addi	a2,a2,-244 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203d24:	0cc00593          	li	a1,204
ffffffffc0203d28:	00004517          	auipc	a0,0x4
ffffffffc0203d2c:	e9050513          	addi	a0,a0,-368 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203d30:	cd8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(mm != NULL);
ffffffffc0203d34:	00004697          	auipc	a3,0x4
ffffffffc0203d38:	adc68693          	addi	a3,a3,-1316 # ffffffffc0207810 <commands+0xff8>
ffffffffc0203d3c:	00003617          	auipc	a2,0x3
ffffffffc0203d40:	eec60613          	addi	a2,a2,-276 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203d44:	0c400593          	li	a1,196
ffffffffc0203d48:	00004517          	auipc	a0,0x4
ffffffffc0203d4c:	e7050513          	addi	a0,a0,-400 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203d50:	cb8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total==0);
ffffffffc0203d54:	00004697          	auipc	a3,0x4
ffffffffc0203d58:	0bc68693          	addi	a3,a3,188 # ffffffffc0207e10 <commands+0x15f8>
ffffffffc0203d5c:	00003617          	auipc	a2,0x3
ffffffffc0203d60:	ecc60613          	addi	a2,a2,-308 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203d64:	11e00593          	li	a1,286
ffffffffc0203d68:	00004517          	auipc	a0,0x4
ffffffffc0203d6c:	e5050513          	addi	a0,a0,-432 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203d70:	c98fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203d74:	00003617          	auipc	a2,0x3
ffffffffc0203d78:	1fc60613          	addi	a2,a2,508 # ffffffffc0206f70 <commands+0x758>
ffffffffc0203d7c:	06900593          	li	a1,105
ffffffffc0203d80:	00003517          	auipc	a0,0x3
ffffffffc0203d84:	1b850513          	addi	a0,a0,440 # ffffffffc0206f38 <commands+0x720>
ffffffffc0203d88:	c80fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(count==0);
ffffffffc0203d8c:	00004697          	auipc	a3,0x4
ffffffffc0203d90:	07468693          	addi	a3,a3,116 # ffffffffc0207e00 <commands+0x15e8>
ffffffffc0203d94:	00003617          	auipc	a2,0x3
ffffffffc0203d98:	e9460613          	addi	a2,a2,-364 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203d9c:	11d00593          	li	a1,285
ffffffffc0203da0:	00004517          	auipc	a0,0x4
ffffffffc0203da4:	e1850513          	addi	a0,a0,-488 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203da8:	c60fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0203dac:	00004697          	auipc	a3,0x4
ffffffffc0203db0:	fa468693          	addi	a3,a3,-92 # ffffffffc0207d50 <commands+0x1538>
ffffffffc0203db4:	00003617          	auipc	a2,0x3
ffffffffc0203db8:	e7460613          	addi	a2,a2,-396 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203dbc:	09500593          	li	a1,149
ffffffffc0203dc0:	00004517          	auipc	a0,0x4
ffffffffc0203dc4:	df850513          	addi	a0,a0,-520 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203dc8:	c40fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203dcc:	00004697          	auipc	a3,0x4
ffffffffc0203dd0:	f3468693          	addi	a3,a3,-204 # ffffffffc0207d00 <commands+0x14e8>
ffffffffc0203dd4:	00003617          	auipc	a2,0x3
ffffffffc0203dd8:	e5460613          	addi	a2,a2,-428 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203ddc:	0ea00593          	li	a1,234
ffffffffc0203de0:	00004517          	auipc	a0,0x4
ffffffffc0203de4:	dd850513          	addi	a0,a0,-552 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203de8:	c20fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203dec:	00004697          	auipc	a3,0x4
ffffffffc0203df0:	e9c68693          	addi	a3,a3,-356 # ffffffffc0207c88 <commands+0x1470>
ffffffffc0203df4:	00003617          	auipc	a2,0x3
ffffffffc0203df8:	e3460613          	addi	a2,a2,-460 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203dfc:	0d700593          	li	a1,215
ffffffffc0203e00:	00004517          	auipc	a0,0x4
ffffffffc0203e04:	db850513          	addi	a0,a0,-584 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203e08:	c00fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(ret==0);
ffffffffc0203e0c:	00004697          	auipc	a3,0x4
ffffffffc0203e10:	fec68693          	addi	a3,a3,-20 # ffffffffc0207df8 <commands+0x15e0>
ffffffffc0203e14:	00003617          	auipc	a2,0x3
ffffffffc0203e18:	e1460613          	addi	a2,a2,-492 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203e1c:	10200593          	li	a1,258
ffffffffc0203e20:	00004517          	auipc	a0,0x4
ffffffffc0203e24:	d9850513          	addi	a0,a0,-616 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203e28:	be0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(vma != NULL);
ffffffffc0203e2c:	00004697          	auipc	a3,0x4
ffffffffc0203e30:	c4c68693          	addi	a3,a3,-948 # ffffffffc0207a78 <commands+0x1260>
ffffffffc0203e34:	00003617          	auipc	a2,0x3
ffffffffc0203e38:	df460613          	addi	a2,a2,-524 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203e3c:	0cf00593          	li	a1,207
ffffffffc0203e40:	00004517          	auipc	a0,0x4
ffffffffc0203e44:	d7850513          	addi	a0,a0,-648 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203e48:	bc0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0203e4c:	00003697          	auipc	a3,0x3
ffffffffc0203e50:	76468693          	addi	a3,a3,1892 # ffffffffc02075b0 <commands+0xd98>
ffffffffc0203e54:	00003617          	auipc	a2,0x3
ffffffffc0203e58:	dd460613          	addi	a2,a2,-556 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203e5c:	09f00593          	li	a1,159
ffffffffc0203e60:	00004517          	auipc	a0,0x4
ffffffffc0203e64:	d5850513          	addi	a0,a0,-680 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203e68:	ba0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0203e6c:	00003697          	auipc	a3,0x3
ffffffffc0203e70:	74468693          	addi	a3,a3,1860 # ffffffffc02075b0 <commands+0xd98>
ffffffffc0203e74:	00003617          	auipc	a2,0x3
ffffffffc0203e78:	db460613          	addi	a2,a2,-588 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203e7c:	0a100593          	li	a1,161
ffffffffc0203e80:	00004517          	auipc	a0,0x4
ffffffffc0203e84:	d3850513          	addi	a0,a0,-712 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203e88:	b80fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0203e8c:	00004697          	auipc	a3,0x4
ffffffffc0203e90:	ed468693          	addi	a3,a3,-300 # ffffffffc0207d60 <commands+0x1548>
ffffffffc0203e94:	00003617          	auipc	a2,0x3
ffffffffc0203e98:	d9460613          	addi	a2,a2,-620 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203e9c:	09700593          	li	a1,151
ffffffffc0203ea0:	00004517          	auipc	a0,0x4
ffffffffc0203ea4:	d1850513          	addi	a0,a0,-744 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203ea8:	b60fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0203eac:	00004697          	auipc	a3,0x4
ffffffffc0203eb0:	eb468693          	addi	a3,a3,-332 # ffffffffc0207d60 <commands+0x1548>
ffffffffc0203eb4:	00003617          	auipc	a2,0x3
ffffffffc0203eb8:	d7460613          	addi	a2,a2,-652 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203ebc:	09900593          	li	a1,153
ffffffffc0203ec0:	00004517          	auipc	a0,0x4
ffffffffc0203ec4:	cf850513          	addi	a0,a0,-776 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203ec8:	b40fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0203ecc:	00004697          	auipc	a3,0x4
ffffffffc0203ed0:	ea468693          	addi	a3,a3,-348 # ffffffffc0207d70 <commands+0x1558>
ffffffffc0203ed4:	00003617          	auipc	a2,0x3
ffffffffc0203ed8:	d5460613          	addi	a2,a2,-684 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203edc:	09b00593          	li	a1,155
ffffffffc0203ee0:	00004517          	auipc	a0,0x4
ffffffffc0203ee4:	cd850513          	addi	a0,a0,-808 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203ee8:	b20fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0203eec:	00004697          	auipc	a3,0x4
ffffffffc0203ef0:	e8468693          	addi	a3,a3,-380 # ffffffffc0207d70 <commands+0x1558>
ffffffffc0203ef4:	00003617          	auipc	a2,0x3
ffffffffc0203ef8:	d3460613          	addi	a2,a2,-716 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203efc:	09d00593          	li	a1,157
ffffffffc0203f00:	00004517          	auipc	a0,0x4
ffffffffc0203f04:	cb850513          	addi	a0,a0,-840 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203f08:	b00fc0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0203f0c:	00004697          	auipc	a3,0x4
ffffffffc0203f10:	e4468693          	addi	a3,a3,-444 # ffffffffc0207d50 <commands+0x1538>
ffffffffc0203f14:	00003617          	auipc	a2,0x3
ffffffffc0203f18:	d1460613          	addi	a2,a2,-748 # ffffffffc0206c28 <commands+0x410>
ffffffffc0203f1c:	09300593          	li	a1,147
ffffffffc0203f20:	00004517          	auipc	a0,0x4
ffffffffc0203f24:	c9850513          	addi	a0,a0,-872 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0203f28:	ae0fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203f2c <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203f2c:	000af797          	auipc	a5,0xaf
ffffffffc0203f30:	a0c7b783          	ld	a5,-1524(a5) # ffffffffc02b2938 <sm>
ffffffffc0203f34:	6b9c                	ld	a5,16(a5)
ffffffffc0203f36:	8782                	jr	a5

ffffffffc0203f38 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203f38:	000af797          	auipc	a5,0xaf
ffffffffc0203f3c:	a007b783          	ld	a5,-1536(a5) # ffffffffc02b2938 <sm>
ffffffffc0203f40:	739c                	ld	a5,32(a5)
ffffffffc0203f42:	8782                	jr	a5

ffffffffc0203f44 <swap_out>:
{
ffffffffc0203f44:	711d                	addi	sp,sp,-96
ffffffffc0203f46:	ec86                	sd	ra,88(sp)
ffffffffc0203f48:	e8a2                	sd	s0,80(sp)
ffffffffc0203f4a:	e4a6                	sd	s1,72(sp)
ffffffffc0203f4c:	e0ca                	sd	s2,64(sp)
ffffffffc0203f4e:	fc4e                	sd	s3,56(sp)
ffffffffc0203f50:	f852                	sd	s4,48(sp)
ffffffffc0203f52:	f456                	sd	s5,40(sp)
ffffffffc0203f54:	f05a                	sd	s6,32(sp)
ffffffffc0203f56:	ec5e                	sd	s7,24(sp)
ffffffffc0203f58:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203f5a:	cde9                	beqz	a1,ffffffffc0204034 <swap_out+0xf0>
ffffffffc0203f5c:	8a2e                	mv	s4,a1
ffffffffc0203f5e:	892a                	mv	s2,a0
ffffffffc0203f60:	8ab2                	mv	s5,a2
ffffffffc0203f62:	4401                	li	s0,0
ffffffffc0203f64:	000af997          	auipc	s3,0xaf
ffffffffc0203f68:	9d498993          	addi	s3,s3,-1580 # ffffffffc02b2938 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203f6c:	00004b17          	auipc	s6,0x4
ffffffffc0203f70:	f34b0b13          	addi	s6,s6,-204 # ffffffffc0207ea0 <commands+0x1688>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203f74:	00004b97          	auipc	s7,0x4
ffffffffc0203f78:	f14b8b93          	addi	s7,s7,-236 # ffffffffc0207e88 <commands+0x1670>
ffffffffc0203f7c:	a825                	j	ffffffffc0203fb4 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203f7e:	67a2                	ld	a5,8(sp)
ffffffffc0203f80:	8626                	mv	a2,s1
ffffffffc0203f82:	85a2                	mv	a1,s0
ffffffffc0203f84:	7f94                	ld	a3,56(a5)
ffffffffc0203f86:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203f88:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203f8a:	82b1                	srli	a3,a3,0xc
ffffffffc0203f8c:	0685                	addi	a3,a3,1
ffffffffc0203f8e:	93efc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203f92:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203f94:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203f96:	7d1c                	ld	a5,56(a0)
ffffffffc0203f98:	83b1                	srli	a5,a5,0xc
ffffffffc0203f9a:	0785                	addi	a5,a5,1
ffffffffc0203f9c:	07a2                	slli	a5,a5,0x8
ffffffffc0203f9e:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203fa2:	f4bfc0ef          	jal	ra,ffffffffc0200eec <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203fa6:	01893503          	ld	a0,24(s2)
ffffffffc0203faa:	85a6                	mv	a1,s1
ffffffffc0203fac:	d14fe0ef          	jal	ra,ffffffffc02024c0 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203fb0:	048a0d63          	beq	s4,s0,ffffffffc020400a <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203fb4:	0009b783          	ld	a5,0(s3)
ffffffffc0203fb8:	8656                	mv	a2,s5
ffffffffc0203fba:	002c                	addi	a1,sp,8
ffffffffc0203fbc:	7b9c                	ld	a5,48(a5)
ffffffffc0203fbe:	854a                	mv	a0,s2
ffffffffc0203fc0:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203fc2:	e12d                	bnez	a0,ffffffffc0204024 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203fc4:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203fc6:	01893503          	ld	a0,24(s2)
ffffffffc0203fca:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203fcc:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203fce:	85a6                	mv	a1,s1
ffffffffc0203fd0:	f97fc0ef          	jal	ra,ffffffffc0200f66 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203fd4:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203fd6:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203fd8:	8b85                	andi	a5,a5,1
ffffffffc0203fda:	cfb9                	beqz	a5,ffffffffc0204038 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203fdc:	65a2                	ld	a1,8(sp)
ffffffffc0203fde:	7d9c                	ld	a5,56(a1)
ffffffffc0203fe0:	83b1                	srli	a5,a5,0xc
ffffffffc0203fe2:	0785                	addi	a5,a5,1
ffffffffc0203fe4:	00879513          	slli	a0,a5,0x8
ffffffffc0203fe8:	45f000ef          	jal	ra,ffffffffc0204c46 <swapfs_write>
ffffffffc0203fec:	d949                	beqz	a0,ffffffffc0203f7e <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203fee:	855e                	mv	a0,s7
ffffffffc0203ff0:	8dcfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203ff4:	0009b783          	ld	a5,0(s3)
ffffffffc0203ff8:	6622                	ld	a2,8(sp)
ffffffffc0203ffa:	4681                	li	a3,0
ffffffffc0203ffc:	739c                	ld	a5,32(a5)
ffffffffc0203ffe:	85a6                	mv	a1,s1
ffffffffc0204000:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0204002:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0204004:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0204006:	fa8a17e3          	bne	s4,s0,ffffffffc0203fb4 <swap_out+0x70>
}
ffffffffc020400a:	60e6                	ld	ra,88(sp)
ffffffffc020400c:	8522                	mv	a0,s0
ffffffffc020400e:	6446                	ld	s0,80(sp)
ffffffffc0204010:	64a6                	ld	s1,72(sp)
ffffffffc0204012:	6906                	ld	s2,64(sp)
ffffffffc0204014:	79e2                	ld	s3,56(sp)
ffffffffc0204016:	7a42                	ld	s4,48(sp)
ffffffffc0204018:	7aa2                	ld	s5,40(sp)
ffffffffc020401a:	7b02                	ld	s6,32(sp)
ffffffffc020401c:	6be2                	ld	s7,24(sp)
ffffffffc020401e:	6c42                	ld	s8,16(sp)
ffffffffc0204020:	6125                	addi	sp,sp,96
ffffffffc0204022:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0204024:	85a2                	mv	a1,s0
ffffffffc0204026:	00004517          	auipc	a0,0x4
ffffffffc020402a:	e1a50513          	addi	a0,a0,-486 # ffffffffc0207e40 <commands+0x1628>
ffffffffc020402e:	89efc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc0204032:	bfe1                	j	ffffffffc020400a <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0204034:	4401                	li	s0,0
ffffffffc0204036:	bfd1                	j	ffffffffc020400a <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0204038:	00004697          	auipc	a3,0x4
ffffffffc020403c:	e3868693          	addi	a3,a3,-456 # ffffffffc0207e70 <commands+0x1658>
ffffffffc0204040:	00003617          	auipc	a2,0x3
ffffffffc0204044:	be860613          	addi	a2,a2,-1048 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204048:	06800593          	li	a1,104
ffffffffc020404c:	00004517          	auipc	a0,0x4
ffffffffc0204050:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc0204054:	9b4fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204058 <swap_in>:
{
ffffffffc0204058:	7179                	addi	sp,sp,-48
ffffffffc020405a:	e84a                	sd	s2,16(sp)
ffffffffc020405c:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc020405e:	4505                	li	a0,1
{
ffffffffc0204060:	ec26                	sd	s1,24(sp)
ffffffffc0204062:	e44e                	sd	s3,8(sp)
ffffffffc0204064:	f406                	sd	ra,40(sp)
ffffffffc0204066:	f022                	sd	s0,32(sp)
ffffffffc0204068:	84ae                	mv	s1,a1
ffffffffc020406a:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc020406c:	deffc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
     assert(result!=NULL);
ffffffffc0204070:	c129                	beqz	a0,ffffffffc02040b2 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0204072:	842a                	mv	s0,a0
ffffffffc0204074:	01893503          	ld	a0,24(s2)
ffffffffc0204078:	4601                	li	a2,0
ffffffffc020407a:	85a6                	mv	a1,s1
ffffffffc020407c:	eebfc0ef          	jal	ra,ffffffffc0200f66 <get_pte>
ffffffffc0204080:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0204082:	6108                	ld	a0,0(a0)
ffffffffc0204084:	85a2                	mv	a1,s0
ffffffffc0204086:	333000ef          	jal	ra,ffffffffc0204bb8 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc020408a:	00093583          	ld	a1,0(s2)
ffffffffc020408e:	8626                	mv	a2,s1
ffffffffc0204090:	00004517          	auipc	a0,0x4
ffffffffc0204094:	e6050513          	addi	a0,a0,-416 # ffffffffc0207ef0 <commands+0x16d8>
ffffffffc0204098:	81a1                	srli	a1,a1,0x8
ffffffffc020409a:	832fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc020409e:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc02040a0:	0089b023          	sd	s0,0(s3)
}
ffffffffc02040a4:	7402                	ld	s0,32(sp)
ffffffffc02040a6:	64e2                	ld	s1,24(sp)
ffffffffc02040a8:	6942                	ld	s2,16(sp)
ffffffffc02040aa:	69a2                	ld	s3,8(sp)
ffffffffc02040ac:	4501                	li	a0,0
ffffffffc02040ae:	6145                	addi	sp,sp,48
ffffffffc02040b0:	8082                	ret
     assert(result!=NULL);
ffffffffc02040b2:	00004697          	auipc	a3,0x4
ffffffffc02040b6:	e2e68693          	addi	a3,a3,-466 # ffffffffc0207ee0 <commands+0x16c8>
ffffffffc02040ba:	00003617          	auipc	a2,0x3
ffffffffc02040be:	b6e60613          	addi	a2,a2,-1170 # ffffffffc0206c28 <commands+0x410>
ffffffffc02040c2:	07e00593          	li	a1,126
ffffffffc02040c6:	00004517          	auipc	a0,0x4
ffffffffc02040ca:	af250513          	addi	a0,a0,-1294 # ffffffffc0207bb8 <commands+0x13a0>
ffffffffc02040ce:	93afc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02040d2 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc02040d2:	000aa797          	auipc	a5,0xaa
ffffffffc02040d6:	7d678793          	addi	a5,a5,2006 # ffffffffc02ae8a8 <free_area>
ffffffffc02040da:	e79c                	sd	a5,8(a5)
ffffffffc02040dc:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02040de:	0007a823          	sw	zero,16(a5)
}
ffffffffc02040e2:	8082                	ret

ffffffffc02040e4 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02040e4:	000aa517          	auipc	a0,0xaa
ffffffffc02040e8:	7d456503          	lwu	a0,2004(a0) # ffffffffc02ae8b8 <free_area+0x10>
ffffffffc02040ec:	8082                	ret

ffffffffc02040ee <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc02040ee:	715d                	addi	sp,sp,-80
ffffffffc02040f0:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc02040f2:	000aa417          	auipc	s0,0xaa
ffffffffc02040f6:	7b640413          	addi	s0,s0,1974 # ffffffffc02ae8a8 <free_area>
ffffffffc02040fa:	641c                	ld	a5,8(s0)
ffffffffc02040fc:	e486                	sd	ra,72(sp)
ffffffffc02040fe:	fc26                	sd	s1,56(sp)
ffffffffc0204100:	f84a                	sd	s2,48(sp)
ffffffffc0204102:	f44e                	sd	s3,40(sp)
ffffffffc0204104:	f052                	sd	s4,32(sp)
ffffffffc0204106:	ec56                	sd	s5,24(sp)
ffffffffc0204108:	e85a                	sd	s6,16(sp)
ffffffffc020410a:	e45e                	sd	s7,8(sp)
ffffffffc020410c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020410e:	2a878d63          	beq	a5,s0,ffffffffc02043c8 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0204112:	4481                	li	s1,0
ffffffffc0204114:	4901                	li	s2,0
ffffffffc0204116:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020411a:	8b09                	andi	a4,a4,2
ffffffffc020411c:	2a070a63          	beqz	a4,ffffffffc02043d0 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0204120:	ff87a703          	lw	a4,-8(a5)
ffffffffc0204124:	679c                	ld	a5,8(a5)
ffffffffc0204126:	2905                	addiw	s2,s2,1
ffffffffc0204128:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020412a:	fe8796e3          	bne	a5,s0,ffffffffc0204116 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc020412e:	89a6                	mv	s3,s1
ffffffffc0204130:	dfdfc0ef          	jal	ra,ffffffffc0200f2c <nr_free_pages>
ffffffffc0204134:	6f351e63          	bne	a0,s3,ffffffffc0204830 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0204138:	4505                	li	a0,1
ffffffffc020413a:	d21fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020413e:	8aaa                	mv	s5,a0
ffffffffc0204140:	42050863          	beqz	a0,ffffffffc0204570 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204144:	4505                	li	a0,1
ffffffffc0204146:	d15fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020414a:	89aa                	mv	s3,a0
ffffffffc020414c:	70050263          	beqz	a0,ffffffffc0204850 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204150:	4505                	li	a0,1
ffffffffc0204152:	d09fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204156:	8a2a                	mv	s4,a0
ffffffffc0204158:	48050c63          	beqz	a0,ffffffffc02045f0 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020415c:	293a8a63          	beq	s5,s3,ffffffffc02043f0 <default_check+0x302>
ffffffffc0204160:	28aa8863          	beq	s5,a0,ffffffffc02043f0 <default_check+0x302>
ffffffffc0204164:	28a98663          	beq	s3,a0,ffffffffc02043f0 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0204168:	000aa783          	lw	a5,0(s5)
ffffffffc020416c:	2a079263          	bnez	a5,ffffffffc0204410 <default_check+0x322>
ffffffffc0204170:	0009a783          	lw	a5,0(s3)
ffffffffc0204174:	28079e63          	bnez	a5,ffffffffc0204410 <default_check+0x322>
ffffffffc0204178:	411c                	lw	a5,0(a0)
ffffffffc020417a:	28079b63          	bnez	a5,ffffffffc0204410 <default_check+0x322>
    return page - pages + nbase;
ffffffffc020417e:	000ae797          	auipc	a5,0xae
ffffffffc0204182:	7827b783          	ld	a5,1922(a5) # ffffffffc02b2900 <pages>
ffffffffc0204186:	40fa8733          	sub	a4,s5,a5
ffffffffc020418a:	00005617          	auipc	a2,0x5
ffffffffc020418e:	a9663603          	ld	a2,-1386(a2) # ffffffffc0208c20 <nbase>
ffffffffc0204192:	8719                	srai	a4,a4,0x6
ffffffffc0204194:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0204196:	000ae697          	auipc	a3,0xae
ffffffffc020419a:	7626b683          	ld	a3,1890(a3) # ffffffffc02b28f8 <npage>
ffffffffc020419e:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02041a0:	0732                	slli	a4,a4,0xc
ffffffffc02041a2:	28d77763          	bgeu	a4,a3,ffffffffc0204430 <default_check+0x342>
    return page - pages + nbase;
ffffffffc02041a6:	40f98733          	sub	a4,s3,a5
ffffffffc02041aa:	8719                	srai	a4,a4,0x6
ffffffffc02041ac:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02041ae:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02041b0:	4cd77063          	bgeu	a4,a3,ffffffffc0204670 <default_check+0x582>
    return page - pages + nbase;
ffffffffc02041b4:	40f507b3          	sub	a5,a0,a5
ffffffffc02041b8:	8799                	srai	a5,a5,0x6
ffffffffc02041ba:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02041bc:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02041be:	30d7f963          	bgeu	a5,a3,ffffffffc02044d0 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc02041c2:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02041c4:	00043c03          	ld	s8,0(s0)
ffffffffc02041c8:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02041cc:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02041d0:	e400                	sd	s0,8(s0)
ffffffffc02041d2:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02041d4:	000aa797          	auipc	a5,0xaa
ffffffffc02041d8:	6e07a223          	sw	zero,1764(a5) # ffffffffc02ae8b8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02041dc:	c7ffc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02041e0:	2c051863          	bnez	a0,ffffffffc02044b0 <default_check+0x3c2>
    free_page(p0);
ffffffffc02041e4:	4585                	li	a1,1
ffffffffc02041e6:	8556                	mv	a0,s5
ffffffffc02041e8:	d05fc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    free_page(p1);
ffffffffc02041ec:	4585                	li	a1,1
ffffffffc02041ee:	854e                	mv	a0,s3
ffffffffc02041f0:	cfdfc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    free_page(p2);
ffffffffc02041f4:	4585                	li	a1,1
ffffffffc02041f6:	8552                	mv	a0,s4
ffffffffc02041f8:	cf5fc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    assert(nr_free == 3);
ffffffffc02041fc:	4818                	lw	a4,16(s0)
ffffffffc02041fe:	478d                	li	a5,3
ffffffffc0204200:	28f71863          	bne	a4,a5,ffffffffc0204490 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0204204:	4505                	li	a0,1
ffffffffc0204206:	c55fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020420a:	89aa                	mv	s3,a0
ffffffffc020420c:	26050263          	beqz	a0,ffffffffc0204470 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204210:	4505                	li	a0,1
ffffffffc0204212:	c49fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204216:	8aaa                	mv	s5,a0
ffffffffc0204218:	3a050c63          	beqz	a0,ffffffffc02045d0 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020421c:	4505                	li	a0,1
ffffffffc020421e:	c3dfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204222:	8a2a                	mv	s4,a0
ffffffffc0204224:	38050663          	beqz	a0,ffffffffc02045b0 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0204228:	4505                	li	a0,1
ffffffffc020422a:	c31fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020422e:	36051163          	bnez	a0,ffffffffc0204590 <default_check+0x4a2>
    free_page(p0);
ffffffffc0204232:	4585                	li	a1,1
ffffffffc0204234:	854e                	mv	a0,s3
ffffffffc0204236:	cb7fc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020423a:	641c                	ld	a5,8(s0)
ffffffffc020423c:	20878a63          	beq	a5,s0,ffffffffc0204450 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0204240:	4505                	li	a0,1
ffffffffc0204242:	c19fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204246:	30a99563          	bne	s3,a0,ffffffffc0204550 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc020424a:	4505                	li	a0,1
ffffffffc020424c:	c0ffc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204250:	2e051063          	bnez	a0,ffffffffc0204530 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0204254:	481c                	lw	a5,16(s0)
ffffffffc0204256:	2a079d63          	bnez	a5,ffffffffc0204510 <default_check+0x422>
    free_page(p);
ffffffffc020425a:	854e                	mv	a0,s3
ffffffffc020425c:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020425e:	01843023          	sd	s8,0(s0)
ffffffffc0204262:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0204266:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc020426a:	c83fc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    free_page(p1);
ffffffffc020426e:	4585                	li	a1,1
ffffffffc0204270:	8556                	mv	a0,s5
ffffffffc0204272:	c7bfc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    free_page(p2);
ffffffffc0204276:	4585                	li	a1,1
ffffffffc0204278:	8552                	mv	a0,s4
ffffffffc020427a:	c73fc0ef          	jal	ra,ffffffffc0200eec <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020427e:	4515                	li	a0,5
ffffffffc0204280:	bdbfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204284:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0204286:	26050563          	beqz	a0,ffffffffc02044f0 <default_check+0x402>
ffffffffc020428a:	651c                	ld	a5,8(a0)
ffffffffc020428c:	8385                	srli	a5,a5,0x1
ffffffffc020428e:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0204290:	54079063          	bnez	a5,ffffffffc02047d0 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0204294:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0204296:	00043b03          	ld	s6,0(s0)
ffffffffc020429a:	00843a83          	ld	s5,8(s0)
ffffffffc020429e:	e000                	sd	s0,0(s0)
ffffffffc02042a0:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02042a2:	bb9fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02042a6:	50051563          	bnez	a0,ffffffffc02047b0 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02042aa:	08098a13          	addi	s4,s3,128
ffffffffc02042ae:	8552                	mv	a0,s4
ffffffffc02042b0:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02042b2:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02042b6:	000aa797          	auipc	a5,0xaa
ffffffffc02042ba:	6007a123          	sw	zero,1538(a5) # ffffffffc02ae8b8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02042be:	c2ffc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02042c2:	4511                	li	a0,4
ffffffffc02042c4:	b97fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02042c8:	4c051463          	bnez	a0,ffffffffc0204790 <default_check+0x6a2>
ffffffffc02042cc:	0889b783          	ld	a5,136(s3)
ffffffffc02042d0:	8385                	srli	a5,a5,0x1
ffffffffc02042d2:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02042d4:	48078e63          	beqz	a5,ffffffffc0204770 <default_check+0x682>
ffffffffc02042d8:	0909a703          	lw	a4,144(s3)
ffffffffc02042dc:	478d                	li	a5,3
ffffffffc02042de:	48f71963          	bne	a4,a5,ffffffffc0204770 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02042e2:	450d                	li	a0,3
ffffffffc02042e4:	b77fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02042e8:	8c2a                	mv	s8,a0
ffffffffc02042ea:	46050363          	beqz	a0,ffffffffc0204750 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc02042ee:	4505                	li	a0,1
ffffffffc02042f0:	b6bfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02042f4:	42051e63          	bnez	a0,ffffffffc0204730 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc02042f8:	418a1c63          	bne	s4,s8,ffffffffc0204710 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02042fc:	4585                	li	a1,1
ffffffffc02042fe:	854e                	mv	a0,s3
ffffffffc0204300:	bedfc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    free_pages(p1, 3);
ffffffffc0204304:	458d                	li	a1,3
ffffffffc0204306:	8552                	mv	a0,s4
ffffffffc0204308:	be5fc0ef          	jal	ra,ffffffffc0200eec <free_pages>
ffffffffc020430c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0204310:	04098c13          	addi	s8,s3,64
ffffffffc0204314:	8385                	srli	a5,a5,0x1
ffffffffc0204316:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0204318:	3c078c63          	beqz	a5,ffffffffc02046f0 <default_check+0x602>
ffffffffc020431c:	0109a703          	lw	a4,16(s3)
ffffffffc0204320:	4785                	li	a5,1
ffffffffc0204322:	3cf71763          	bne	a4,a5,ffffffffc02046f0 <default_check+0x602>
ffffffffc0204326:	008a3783          	ld	a5,8(s4)
ffffffffc020432a:	8385                	srli	a5,a5,0x1
ffffffffc020432c:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020432e:	3a078163          	beqz	a5,ffffffffc02046d0 <default_check+0x5e2>
ffffffffc0204332:	010a2703          	lw	a4,16(s4)
ffffffffc0204336:	478d                	li	a5,3
ffffffffc0204338:	38f71c63          	bne	a4,a5,ffffffffc02046d0 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020433c:	4505                	li	a0,1
ffffffffc020433e:	b1dfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204342:	36a99763          	bne	s3,a0,ffffffffc02046b0 <default_check+0x5c2>
    free_page(p0);
ffffffffc0204346:	4585                	li	a1,1
ffffffffc0204348:	ba5fc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020434c:	4509                	li	a0,2
ffffffffc020434e:	b0dfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204352:	32aa1f63          	bne	s4,a0,ffffffffc0204690 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0204356:	4589                	li	a1,2
ffffffffc0204358:	b95fc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    free_page(p2);
ffffffffc020435c:	4585                	li	a1,1
ffffffffc020435e:	8562                	mv	a0,s8
ffffffffc0204360:	b8dfc0ef          	jal	ra,ffffffffc0200eec <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0204364:	4515                	li	a0,5
ffffffffc0204366:	af5fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020436a:	89aa                	mv	s3,a0
ffffffffc020436c:	48050263          	beqz	a0,ffffffffc02047f0 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0204370:	4505                	li	a0,1
ffffffffc0204372:	ae9fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204376:	2c051d63          	bnez	a0,ffffffffc0204650 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc020437a:	481c                	lw	a5,16(s0)
ffffffffc020437c:	2a079a63          	bnez	a5,ffffffffc0204630 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0204380:	4595                	li	a1,5
ffffffffc0204382:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0204384:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0204388:	01643023          	sd	s6,0(s0)
ffffffffc020438c:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0204390:	b5dfc0ef          	jal	ra,ffffffffc0200eec <free_pages>
    return listelm->next;
ffffffffc0204394:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204396:	00878963          	beq	a5,s0,ffffffffc02043a8 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020439a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020439e:	679c                	ld	a5,8(a5)
ffffffffc02043a0:	397d                	addiw	s2,s2,-1
ffffffffc02043a2:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02043a4:	fe879be3          	bne	a5,s0,ffffffffc020439a <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02043a8:	26091463          	bnez	s2,ffffffffc0204610 <default_check+0x522>
    assert(total == 0);
ffffffffc02043ac:	46049263          	bnez	s1,ffffffffc0204810 <default_check+0x722>
}
ffffffffc02043b0:	60a6                	ld	ra,72(sp)
ffffffffc02043b2:	6406                	ld	s0,64(sp)
ffffffffc02043b4:	74e2                	ld	s1,56(sp)
ffffffffc02043b6:	7942                	ld	s2,48(sp)
ffffffffc02043b8:	79a2                	ld	s3,40(sp)
ffffffffc02043ba:	7a02                	ld	s4,32(sp)
ffffffffc02043bc:	6ae2                	ld	s5,24(sp)
ffffffffc02043be:	6b42                	ld	s6,16(sp)
ffffffffc02043c0:	6ba2                	ld	s7,8(sp)
ffffffffc02043c2:	6c02                	ld	s8,0(sp)
ffffffffc02043c4:	6161                	addi	sp,sp,80
ffffffffc02043c6:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02043c8:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02043ca:	4481                	li	s1,0
ffffffffc02043cc:	4901                	li	s2,0
ffffffffc02043ce:	b38d                	j	ffffffffc0204130 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02043d0:	00004697          	auipc	a3,0x4
ffffffffc02043d4:	81068693          	addi	a3,a3,-2032 # ffffffffc0207be0 <commands+0x13c8>
ffffffffc02043d8:	00003617          	auipc	a2,0x3
ffffffffc02043dc:	85060613          	addi	a2,a2,-1968 # ffffffffc0206c28 <commands+0x410>
ffffffffc02043e0:	0f000593          	li	a1,240
ffffffffc02043e4:	00004517          	auipc	a0,0x4
ffffffffc02043e8:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02043ec:	e1dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02043f0:	00004697          	auipc	a3,0x4
ffffffffc02043f4:	bb868693          	addi	a3,a3,-1096 # ffffffffc0207fa8 <commands+0x1790>
ffffffffc02043f8:	00003617          	auipc	a2,0x3
ffffffffc02043fc:	83060613          	addi	a2,a2,-2000 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204400:	0bd00593          	li	a1,189
ffffffffc0204404:	00004517          	auipc	a0,0x4
ffffffffc0204408:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020440c:	dfdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0204410:	00004697          	auipc	a3,0x4
ffffffffc0204414:	bc068693          	addi	a3,a3,-1088 # ffffffffc0207fd0 <commands+0x17b8>
ffffffffc0204418:	00003617          	auipc	a2,0x3
ffffffffc020441c:	81060613          	addi	a2,a2,-2032 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204420:	0be00593          	li	a1,190
ffffffffc0204424:	00004517          	auipc	a0,0x4
ffffffffc0204428:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020442c:	dddfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0204430:	00004697          	auipc	a3,0x4
ffffffffc0204434:	be068693          	addi	a3,a3,-1056 # ffffffffc0208010 <commands+0x17f8>
ffffffffc0204438:	00002617          	auipc	a2,0x2
ffffffffc020443c:	7f060613          	addi	a2,a2,2032 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204440:	0c000593          	li	a1,192
ffffffffc0204444:	00004517          	auipc	a0,0x4
ffffffffc0204448:	aec50513          	addi	a0,a0,-1300 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020444c:	dbdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0204450:	00004697          	auipc	a3,0x4
ffffffffc0204454:	c4868693          	addi	a3,a3,-952 # ffffffffc0208098 <commands+0x1880>
ffffffffc0204458:	00002617          	auipc	a2,0x2
ffffffffc020445c:	7d060613          	addi	a2,a2,2000 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204460:	0d900593          	li	a1,217
ffffffffc0204464:	00004517          	auipc	a0,0x4
ffffffffc0204468:	acc50513          	addi	a0,a0,-1332 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020446c:	d9dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0204470:	00004697          	auipc	a3,0x4
ffffffffc0204474:	ad868693          	addi	a3,a3,-1320 # ffffffffc0207f48 <commands+0x1730>
ffffffffc0204478:	00002617          	auipc	a2,0x2
ffffffffc020447c:	7b060613          	addi	a2,a2,1968 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204480:	0d200593          	li	a1,210
ffffffffc0204484:	00004517          	auipc	a0,0x4
ffffffffc0204488:	aac50513          	addi	a0,a0,-1364 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020448c:	d7dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 3);
ffffffffc0204490:	00004697          	auipc	a3,0x4
ffffffffc0204494:	bf868693          	addi	a3,a3,-1032 # ffffffffc0208088 <commands+0x1870>
ffffffffc0204498:	00002617          	auipc	a2,0x2
ffffffffc020449c:	79060613          	addi	a2,a2,1936 # ffffffffc0206c28 <commands+0x410>
ffffffffc02044a0:	0d000593          	li	a1,208
ffffffffc02044a4:	00004517          	auipc	a0,0x4
ffffffffc02044a8:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02044ac:	d5dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02044b0:	00004697          	auipc	a3,0x4
ffffffffc02044b4:	bc068693          	addi	a3,a3,-1088 # ffffffffc0208070 <commands+0x1858>
ffffffffc02044b8:	00002617          	auipc	a2,0x2
ffffffffc02044bc:	77060613          	addi	a2,a2,1904 # ffffffffc0206c28 <commands+0x410>
ffffffffc02044c0:	0cb00593          	li	a1,203
ffffffffc02044c4:	00004517          	auipc	a0,0x4
ffffffffc02044c8:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02044cc:	d3dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02044d0:	00004697          	auipc	a3,0x4
ffffffffc02044d4:	b8068693          	addi	a3,a3,-1152 # ffffffffc0208050 <commands+0x1838>
ffffffffc02044d8:	00002617          	auipc	a2,0x2
ffffffffc02044dc:	75060613          	addi	a2,a2,1872 # ffffffffc0206c28 <commands+0x410>
ffffffffc02044e0:	0c200593          	li	a1,194
ffffffffc02044e4:	00004517          	auipc	a0,0x4
ffffffffc02044e8:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02044ec:	d1dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != NULL);
ffffffffc02044f0:	00004697          	auipc	a3,0x4
ffffffffc02044f4:	be068693          	addi	a3,a3,-1056 # ffffffffc02080d0 <commands+0x18b8>
ffffffffc02044f8:	00002617          	auipc	a2,0x2
ffffffffc02044fc:	73060613          	addi	a2,a2,1840 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204500:	0f800593          	li	a1,248
ffffffffc0204504:	00004517          	auipc	a0,0x4
ffffffffc0204508:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020450c:	cfdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0204510:	00004697          	auipc	a3,0x4
ffffffffc0204514:	87068693          	addi	a3,a3,-1936 # ffffffffc0207d80 <commands+0x1568>
ffffffffc0204518:	00002617          	auipc	a2,0x2
ffffffffc020451c:	71060613          	addi	a2,a2,1808 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204520:	0df00593          	li	a1,223
ffffffffc0204524:	00004517          	auipc	a0,0x4
ffffffffc0204528:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020452c:	cddfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204530:	00004697          	auipc	a3,0x4
ffffffffc0204534:	b4068693          	addi	a3,a3,-1216 # ffffffffc0208070 <commands+0x1858>
ffffffffc0204538:	00002617          	auipc	a2,0x2
ffffffffc020453c:	6f060613          	addi	a2,a2,1776 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204540:	0dd00593          	li	a1,221
ffffffffc0204544:	00004517          	auipc	a0,0x4
ffffffffc0204548:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020454c:	cbdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0204550:	00004697          	auipc	a3,0x4
ffffffffc0204554:	b6068693          	addi	a3,a3,-1184 # ffffffffc02080b0 <commands+0x1898>
ffffffffc0204558:	00002617          	auipc	a2,0x2
ffffffffc020455c:	6d060613          	addi	a2,a2,1744 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204560:	0dc00593          	li	a1,220
ffffffffc0204564:	00004517          	auipc	a0,0x4
ffffffffc0204568:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020456c:	c9dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0204570:	00004697          	auipc	a3,0x4
ffffffffc0204574:	9d868693          	addi	a3,a3,-1576 # ffffffffc0207f48 <commands+0x1730>
ffffffffc0204578:	00002617          	auipc	a2,0x2
ffffffffc020457c:	6b060613          	addi	a2,a2,1712 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204580:	0b900593          	li	a1,185
ffffffffc0204584:	00004517          	auipc	a0,0x4
ffffffffc0204588:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020458c:	c7dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204590:	00004697          	auipc	a3,0x4
ffffffffc0204594:	ae068693          	addi	a3,a3,-1312 # ffffffffc0208070 <commands+0x1858>
ffffffffc0204598:	00002617          	auipc	a2,0x2
ffffffffc020459c:	69060613          	addi	a2,a2,1680 # ffffffffc0206c28 <commands+0x410>
ffffffffc02045a0:	0d600593          	li	a1,214
ffffffffc02045a4:	00004517          	auipc	a0,0x4
ffffffffc02045a8:	98c50513          	addi	a0,a0,-1652 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02045ac:	c5dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02045b0:	00004697          	auipc	a3,0x4
ffffffffc02045b4:	9d868693          	addi	a3,a3,-1576 # ffffffffc0207f88 <commands+0x1770>
ffffffffc02045b8:	00002617          	auipc	a2,0x2
ffffffffc02045bc:	67060613          	addi	a2,a2,1648 # ffffffffc0206c28 <commands+0x410>
ffffffffc02045c0:	0d400593          	li	a1,212
ffffffffc02045c4:	00004517          	auipc	a0,0x4
ffffffffc02045c8:	96c50513          	addi	a0,a0,-1684 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02045cc:	c3dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02045d0:	00004697          	auipc	a3,0x4
ffffffffc02045d4:	99868693          	addi	a3,a3,-1640 # ffffffffc0207f68 <commands+0x1750>
ffffffffc02045d8:	00002617          	auipc	a2,0x2
ffffffffc02045dc:	65060613          	addi	a2,a2,1616 # ffffffffc0206c28 <commands+0x410>
ffffffffc02045e0:	0d300593          	li	a1,211
ffffffffc02045e4:	00004517          	auipc	a0,0x4
ffffffffc02045e8:	94c50513          	addi	a0,a0,-1716 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02045ec:	c1dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02045f0:	00004697          	auipc	a3,0x4
ffffffffc02045f4:	99868693          	addi	a3,a3,-1640 # ffffffffc0207f88 <commands+0x1770>
ffffffffc02045f8:	00002617          	auipc	a2,0x2
ffffffffc02045fc:	63060613          	addi	a2,a2,1584 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204600:	0bb00593          	li	a1,187
ffffffffc0204604:	00004517          	auipc	a0,0x4
ffffffffc0204608:	92c50513          	addi	a0,a0,-1748 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020460c:	bfdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(count == 0);
ffffffffc0204610:	00004697          	auipc	a3,0x4
ffffffffc0204614:	c1068693          	addi	a3,a3,-1008 # ffffffffc0208220 <commands+0x1a08>
ffffffffc0204618:	00002617          	auipc	a2,0x2
ffffffffc020461c:	61060613          	addi	a2,a2,1552 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204620:	12500593          	li	a1,293
ffffffffc0204624:	00004517          	auipc	a0,0x4
ffffffffc0204628:	90c50513          	addi	a0,a0,-1780 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020462c:	bddfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0204630:	00003697          	auipc	a3,0x3
ffffffffc0204634:	75068693          	addi	a3,a3,1872 # ffffffffc0207d80 <commands+0x1568>
ffffffffc0204638:	00002617          	auipc	a2,0x2
ffffffffc020463c:	5f060613          	addi	a2,a2,1520 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204640:	11a00593          	li	a1,282
ffffffffc0204644:	00004517          	auipc	a0,0x4
ffffffffc0204648:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020464c:	bbdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204650:	00004697          	auipc	a3,0x4
ffffffffc0204654:	a2068693          	addi	a3,a3,-1504 # ffffffffc0208070 <commands+0x1858>
ffffffffc0204658:	00002617          	auipc	a2,0x2
ffffffffc020465c:	5d060613          	addi	a2,a2,1488 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204660:	11800593          	li	a1,280
ffffffffc0204664:	00004517          	auipc	a0,0x4
ffffffffc0204668:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020466c:	b9dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0204670:	00004697          	auipc	a3,0x4
ffffffffc0204674:	9c068693          	addi	a3,a3,-1600 # ffffffffc0208030 <commands+0x1818>
ffffffffc0204678:	00002617          	auipc	a2,0x2
ffffffffc020467c:	5b060613          	addi	a2,a2,1456 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204680:	0c100593          	li	a1,193
ffffffffc0204684:	00004517          	auipc	a0,0x4
ffffffffc0204688:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020468c:	b7dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0204690:	00004697          	auipc	a3,0x4
ffffffffc0204694:	b5068693          	addi	a3,a3,-1200 # ffffffffc02081e0 <commands+0x19c8>
ffffffffc0204698:	00002617          	auipc	a2,0x2
ffffffffc020469c:	59060613          	addi	a2,a2,1424 # ffffffffc0206c28 <commands+0x410>
ffffffffc02046a0:	11200593          	li	a1,274
ffffffffc02046a4:	00004517          	auipc	a0,0x4
ffffffffc02046a8:	88c50513          	addi	a0,a0,-1908 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02046ac:	b5dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02046b0:	00004697          	auipc	a3,0x4
ffffffffc02046b4:	b1068693          	addi	a3,a3,-1264 # ffffffffc02081c0 <commands+0x19a8>
ffffffffc02046b8:	00002617          	auipc	a2,0x2
ffffffffc02046bc:	57060613          	addi	a2,a2,1392 # ffffffffc0206c28 <commands+0x410>
ffffffffc02046c0:	11000593          	li	a1,272
ffffffffc02046c4:	00004517          	auipc	a0,0x4
ffffffffc02046c8:	86c50513          	addi	a0,a0,-1940 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02046cc:	b3dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02046d0:	00004697          	auipc	a3,0x4
ffffffffc02046d4:	ac868693          	addi	a3,a3,-1336 # ffffffffc0208198 <commands+0x1980>
ffffffffc02046d8:	00002617          	auipc	a2,0x2
ffffffffc02046dc:	55060613          	addi	a2,a2,1360 # ffffffffc0206c28 <commands+0x410>
ffffffffc02046e0:	10e00593          	li	a1,270
ffffffffc02046e4:	00004517          	auipc	a0,0x4
ffffffffc02046e8:	84c50513          	addi	a0,a0,-1972 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02046ec:	b1dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02046f0:	00004697          	auipc	a3,0x4
ffffffffc02046f4:	a8068693          	addi	a3,a3,-1408 # ffffffffc0208170 <commands+0x1958>
ffffffffc02046f8:	00002617          	auipc	a2,0x2
ffffffffc02046fc:	53060613          	addi	a2,a2,1328 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204700:	10d00593          	li	a1,269
ffffffffc0204704:	00004517          	auipc	a0,0x4
ffffffffc0204708:	82c50513          	addi	a0,a0,-2004 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020470c:	afdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0204710:	00004697          	auipc	a3,0x4
ffffffffc0204714:	a5068693          	addi	a3,a3,-1456 # ffffffffc0208160 <commands+0x1948>
ffffffffc0204718:	00002617          	auipc	a2,0x2
ffffffffc020471c:	51060613          	addi	a2,a2,1296 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204720:	10800593          	li	a1,264
ffffffffc0204724:	00004517          	auipc	a0,0x4
ffffffffc0204728:	80c50513          	addi	a0,a0,-2036 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020472c:	addfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204730:	00004697          	auipc	a3,0x4
ffffffffc0204734:	94068693          	addi	a3,a3,-1728 # ffffffffc0208070 <commands+0x1858>
ffffffffc0204738:	00002617          	auipc	a2,0x2
ffffffffc020473c:	4f060613          	addi	a2,a2,1264 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204740:	10700593          	li	a1,263
ffffffffc0204744:	00003517          	auipc	a0,0x3
ffffffffc0204748:	7ec50513          	addi	a0,a0,2028 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020474c:	abdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0204750:	00004697          	auipc	a3,0x4
ffffffffc0204754:	9f068693          	addi	a3,a3,-1552 # ffffffffc0208140 <commands+0x1928>
ffffffffc0204758:	00002617          	auipc	a2,0x2
ffffffffc020475c:	4d060613          	addi	a2,a2,1232 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204760:	10600593          	li	a1,262
ffffffffc0204764:	00003517          	auipc	a0,0x3
ffffffffc0204768:	7cc50513          	addi	a0,a0,1996 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020476c:	a9dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0204770:	00004697          	auipc	a3,0x4
ffffffffc0204774:	9a068693          	addi	a3,a3,-1632 # ffffffffc0208110 <commands+0x18f8>
ffffffffc0204778:	00002617          	auipc	a2,0x2
ffffffffc020477c:	4b060613          	addi	a2,a2,1200 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204780:	10500593          	li	a1,261
ffffffffc0204784:	00003517          	auipc	a0,0x3
ffffffffc0204788:	7ac50513          	addi	a0,a0,1964 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020478c:	a7dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0204790:	00004697          	auipc	a3,0x4
ffffffffc0204794:	96868693          	addi	a3,a3,-1688 # ffffffffc02080f8 <commands+0x18e0>
ffffffffc0204798:	00002617          	auipc	a2,0x2
ffffffffc020479c:	49060613          	addi	a2,a2,1168 # ffffffffc0206c28 <commands+0x410>
ffffffffc02047a0:	10400593          	li	a1,260
ffffffffc02047a4:	00003517          	auipc	a0,0x3
ffffffffc02047a8:	78c50513          	addi	a0,a0,1932 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02047ac:	a5dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02047b0:	00004697          	auipc	a3,0x4
ffffffffc02047b4:	8c068693          	addi	a3,a3,-1856 # ffffffffc0208070 <commands+0x1858>
ffffffffc02047b8:	00002617          	auipc	a2,0x2
ffffffffc02047bc:	47060613          	addi	a2,a2,1136 # ffffffffc0206c28 <commands+0x410>
ffffffffc02047c0:	0fe00593          	li	a1,254
ffffffffc02047c4:	00003517          	auipc	a0,0x3
ffffffffc02047c8:	76c50513          	addi	a0,a0,1900 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02047cc:	a3dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!PageProperty(p0));
ffffffffc02047d0:	00004697          	auipc	a3,0x4
ffffffffc02047d4:	91068693          	addi	a3,a3,-1776 # ffffffffc02080e0 <commands+0x18c8>
ffffffffc02047d8:	00002617          	auipc	a2,0x2
ffffffffc02047dc:	45060613          	addi	a2,a2,1104 # ffffffffc0206c28 <commands+0x410>
ffffffffc02047e0:	0f900593          	li	a1,249
ffffffffc02047e4:	00003517          	auipc	a0,0x3
ffffffffc02047e8:	74c50513          	addi	a0,a0,1868 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02047ec:	a1dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02047f0:	00004697          	auipc	a3,0x4
ffffffffc02047f4:	a1068693          	addi	a3,a3,-1520 # ffffffffc0208200 <commands+0x19e8>
ffffffffc02047f8:	00002617          	auipc	a2,0x2
ffffffffc02047fc:	43060613          	addi	a2,a2,1072 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204800:	11700593          	li	a1,279
ffffffffc0204804:	00003517          	auipc	a0,0x3
ffffffffc0204808:	72c50513          	addi	a0,a0,1836 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020480c:	9fdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == 0);
ffffffffc0204810:	00004697          	auipc	a3,0x4
ffffffffc0204814:	a2068693          	addi	a3,a3,-1504 # ffffffffc0208230 <commands+0x1a18>
ffffffffc0204818:	00002617          	auipc	a2,0x2
ffffffffc020481c:	41060613          	addi	a2,a2,1040 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204820:	12600593          	li	a1,294
ffffffffc0204824:	00003517          	auipc	a0,0x3
ffffffffc0204828:	70c50513          	addi	a0,a0,1804 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020482c:	9ddfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == nr_free_pages());
ffffffffc0204830:	00003697          	auipc	a3,0x3
ffffffffc0204834:	3c068693          	addi	a3,a3,960 # ffffffffc0207bf0 <commands+0x13d8>
ffffffffc0204838:	00002617          	auipc	a2,0x2
ffffffffc020483c:	3f060613          	addi	a2,a2,1008 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204840:	0f300593          	li	a1,243
ffffffffc0204844:	00003517          	auipc	a0,0x3
ffffffffc0204848:	6ec50513          	addi	a0,a0,1772 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020484c:	9bdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204850:	00003697          	auipc	a3,0x3
ffffffffc0204854:	71868693          	addi	a3,a3,1816 # ffffffffc0207f68 <commands+0x1750>
ffffffffc0204858:	00002617          	auipc	a2,0x2
ffffffffc020485c:	3d060613          	addi	a2,a2,976 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204860:	0ba00593          	li	a1,186
ffffffffc0204864:	00003517          	auipc	a0,0x3
ffffffffc0204868:	6cc50513          	addi	a0,a0,1740 # ffffffffc0207f30 <commands+0x1718>
ffffffffc020486c:	99dfb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204870 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0204870:	1141                	addi	sp,sp,-16
ffffffffc0204872:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204874:	14058463          	beqz	a1,ffffffffc02049bc <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0204878:	00659693          	slli	a3,a1,0x6
ffffffffc020487c:	96aa                	add	a3,a3,a0
ffffffffc020487e:	87aa                	mv	a5,a0
ffffffffc0204880:	02d50263          	beq	a0,a3,ffffffffc02048a4 <default_free_pages+0x34>
ffffffffc0204884:	6798                	ld	a4,8(a5)
ffffffffc0204886:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0204888:	10071a63          	bnez	a4,ffffffffc020499c <default_free_pages+0x12c>
ffffffffc020488c:	6798                	ld	a4,8(a5)
ffffffffc020488e:	8b09                	andi	a4,a4,2
ffffffffc0204890:	10071663          	bnez	a4,ffffffffc020499c <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0204894:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0204898:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020489c:	04078793          	addi	a5,a5,64
ffffffffc02048a0:	fed792e3          	bne	a5,a3,ffffffffc0204884 <default_free_pages+0x14>
    base->property = n;
ffffffffc02048a4:	2581                	sext.w	a1,a1
ffffffffc02048a6:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02048a8:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02048ac:	4789                	li	a5,2
ffffffffc02048ae:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02048b2:	000aa697          	auipc	a3,0xaa
ffffffffc02048b6:	ff668693          	addi	a3,a3,-10 # ffffffffc02ae8a8 <free_area>
ffffffffc02048ba:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02048bc:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02048be:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02048c2:	9db9                	addw	a1,a1,a4
ffffffffc02048c4:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02048c6:	0ad78463          	beq	a5,a3,ffffffffc020496e <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc02048ca:	fe878713          	addi	a4,a5,-24
ffffffffc02048ce:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02048d2:	4581                	li	a1,0
            if (base < page) {
ffffffffc02048d4:	00e56a63          	bltu	a0,a4,ffffffffc02048e8 <default_free_pages+0x78>
    return listelm->next;
ffffffffc02048d8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02048da:	04d70c63          	beq	a4,a3,ffffffffc0204932 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc02048de:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02048e0:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02048e4:	fee57ae3          	bgeu	a0,a4,ffffffffc02048d8 <default_free_pages+0x68>
ffffffffc02048e8:	c199                	beqz	a1,ffffffffc02048ee <default_free_pages+0x7e>
ffffffffc02048ea:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02048ee:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02048f0:	e390                	sd	a2,0(a5)
ffffffffc02048f2:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02048f4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02048f6:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc02048f8:	00d70d63          	beq	a4,a3,ffffffffc0204912 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc02048fc:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0204900:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0204904:	02059813          	slli	a6,a1,0x20
ffffffffc0204908:	01a85793          	srli	a5,a6,0x1a
ffffffffc020490c:	97b2                	add	a5,a5,a2
ffffffffc020490e:	02f50c63          	beq	a0,a5,ffffffffc0204946 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0204912:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0204914:	00d78c63          	beq	a5,a3,ffffffffc020492c <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0204918:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020491a:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc020491e:	02061593          	slli	a1,a2,0x20
ffffffffc0204922:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0204926:	972a                	add	a4,a4,a0
ffffffffc0204928:	04e68a63          	beq	a3,a4,ffffffffc020497c <default_free_pages+0x10c>
}
ffffffffc020492c:	60a2                	ld	ra,8(sp)
ffffffffc020492e:	0141                	addi	sp,sp,16
ffffffffc0204930:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204932:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204934:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0204936:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204938:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020493a:	02d70763          	beq	a4,a3,ffffffffc0204968 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc020493e:	8832                	mv	a6,a2
ffffffffc0204940:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0204942:	87ba                	mv	a5,a4
ffffffffc0204944:	bf71                	j	ffffffffc02048e0 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0204946:	491c                	lw	a5,16(a0)
ffffffffc0204948:	9dbd                	addw	a1,a1,a5
ffffffffc020494a:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020494e:	57f5                	li	a5,-3
ffffffffc0204950:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204954:	01853803          	ld	a6,24(a0)
ffffffffc0204958:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc020495a:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc020495c:	00b83423          	sd	a1,8(a6) # fffffffffff80008 <end+0x3fccd6a4>
    return listelm->next;
ffffffffc0204960:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0204962:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0204966:	b77d                	j	ffffffffc0204914 <default_free_pages+0xa4>
ffffffffc0204968:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020496a:	873e                	mv	a4,a5
ffffffffc020496c:	bf41                	j	ffffffffc02048fc <default_free_pages+0x8c>
}
ffffffffc020496e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0204970:	e390                	sd	a2,0(a5)
ffffffffc0204972:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204974:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204976:	ed1c                	sd	a5,24(a0)
ffffffffc0204978:	0141                	addi	sp,sp,16
ffffffffc020497a:	8082                	ret
            base->property += p->property;
ffffffffc020497c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0204980:	ff078693          	addi	a3,a5,-16
ffffffffc0204984:	9e39                	addw	a2,a2,a4
ffffffffc0204986:	c910                	sw	a2,16(a0)
ffffffffc0204988:	5775                	li	a4,-3
ffffffffc020498a:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020498e:	6398                	ld	a4,0(a5)
ffffffffc0204990:	679c                	ld	a5,8(a5)
}
ffffffffc0204992:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0204994:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204996:	e398                	sd	a4,0(a5)
ffffffffc0204998:	0141                	addi	sp,sp,16
ffffffffc020499a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020499c:	00004697          	auipc	a3,0x4
ffffffffc02049a0:	8ac68693          	addi	a3,a3,-1876 # ffffffffc0208248 <commands+0x1a30>
ffffffffc02049a4:	00002617          	auipc	a2,0x2
ffffffffc02049a8:	28460613          	addi	a2,a2,644 # ffffffffc0206c28 <commands+0x410>
ffffffffc02049ac:	08300593          	li	a1,131
ffffffffc02049b0:	00003517          	auipc	a0,0x3
ffffffffc02049b4:	58050513          	addi	a0,a0,1408 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02049b8:	851fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc02049bc:	00004697          	auipc	a3,0x4
ffffffffc02049c0:	88468693          	addi	a3,a3,-1916 # ffffffffc0208240 <commands+0x1a28>
ffffffffc02049c4:	00002617          	auipc	a2,0x2
ffffffffc02049c8:	26460613          	addi	a2,a2,612 # ffffffffc0206c28 <commands+0x410>
ffffffffc02049cc:	08000593          	li	a1,128
ffffffffc02049d0:	00003517          	auipc	a0,0x3
ffffffffc02049d4:	56050513          	addi	a0,a0,1376 # ffffffffc0207f30 <commands+0x1718>
ffffffffc02049d8:	831fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02049dc <default_alloc_pages>:
    assert(n > 0);
ffffffffc02049dc:	c941                	beqz	a0,ffffffffc0204a6c <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc02049de:	000aa597          	auipc	a1,0xaa
ffffffffc02049e2:	eca58593          	addi	a1,a1,-310 # ffffffffc02ae8a8 <free_area>
ffffffffc02049e6:	0105a803          	lw	a6,16(a1)
ffffffffc02049ea:	872a                	mv	a4,a0
ffffffffc02049ec:	02081793          	slli	a5,a6,0x20
ffffffffc02049f0:	9381                	srli	a5,a5,0x20
ffffffffc02049f2:	00a7ee63          	bltu	a5,a0,ffffffffc0204a0e <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02049f6:	87ae                	mv	a5,a1
ffffffffc02049f8:	a801                	j	ffffffffc0204a08 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02049fa:	ff87a683          	lw	a3,-8(a5)
ffffffffc02049fe:	02069613          	slli	a2,a3,0x20
ffffffffc0204a02:	9201                	srli	a2,a2,0x20
ffffffffc0204a04:	00e67763          	bgeu	a2,a4,ffffffffc0204a12 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0204a08:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204a0a:	feb798e3          	bne	a5,a1,ffffffffc02049fa <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0204a0e:	4501                	li	a0,0
}
ffffffffc0204a10:	8082                	ret
    return listelm->prev;
ffffffffc0204a12:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204a16:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0204a1a:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0204a1e:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0204a22:	0068b423          	sd	t1,8(a7) # 1008 <_binary_obj___user_faultread_out_size-0x8bb8>
    next->prev = prev;
ffffffffc0204a26:	01133023          	sd	a7,0(t1) # 80000 <_binary_obj___user_exit_out_size+0x74ed0>
        if (page->property > n) {
ffffffffc0204a2a:	02c77863          	bgeu	a4,a2,ffffffffc0204a5a <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0204a2e:	071a                	slli	a4,a4,0x6
ffffffffc0204a30:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0204a32:	41c686bb          	subw	a3,a3,t3
ffffffffc0204a36:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204a38:	00870613          	addi	a2,a4,8
ffffffffc0204a3c:	4689                	li	a3,2
ffffffffc0204a3e:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204a42:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0204a46:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0204a4a:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0204a4e:	e290                	sd	a2,0(a3)
ffffffffc0204a50:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0204a54:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0204a56:	01173c23          	sd	a7,24(a4)
ffffffffc0204a5a:	41c8083b          	subw	a6,a6,t3
ffffffffc0204a5e:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204a62:	5775                	li	a4,-3
ffffffffc0204a64:	17c1                	addi	a5,a5,-16
ffffffffc0204a66:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0204a6a:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0204a6c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0204a6e:	00003697          	auipc	a3,0x3
ffffffffc0204a72:	7d268693          	addi	a3,a3,2002 # ffffffffc0208240 <commands+0x1a28>
ffffffffc0204a76:	00002617          	auipc	a2,0x2
ffffffffc0204a7a:	1b260613          	addi	a2,a2,434 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204a7e:	06200593          	li	a1,98
ffffffffc0204a82:	00003517          	auipc	a0,0x3
ffffffffc0204a86:	4ae50513          	addi	a0,a0,1198 # ffffffffc0207f30 <commands+0x1718>
default_alloc_pages(size_t n) {
ffffffffc0204a8a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204a8c:	f7cfb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204a90 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0204a90:	1141                	addi	sp,sp,-16
ffffffffc0204a92:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204a94:	c5f1                	beqz	a1,ffffffffc0204b60 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0204a96:	00659693          	slli	a3,a1,0x6
ffffffffc0204a9a:	96aa                	add	a3,a3,a0
ffffffffc0204a9c:	87aa                	mv	a5,a0
ffffffffc0204a9e:	00d50f63          	beq	a0,a3,ffffffffc0204abc <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0204aa2:	6798                	ld	a4,8(a5)
ffffffffc0204aa4:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0204aa6:	cf49                	beqz	a4,ffffffffc0204b40 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0204aa8:	0007a823          	sw	zero,16(a5)
ffffffffc0204aac:	0007b423          	sd	zero,8(a5)
ffffffffc0204ab0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0204ab4:	04078793          	addi	a5,a5,64
ffffffffc0204ab8:	fed795e3          	bne	a5,a3,ffffffffc0204aa2 <default_init_memmap+0x12>
    base->property = n;
ffffffffc0204abc:	2581                	sext.w	a1,a1
ffffffffc0204abe:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204ac0:	4789                	li	a5,2
ffffffffc0204ac2:	00850713          	addi	a4,a0,8
ffffffffc0204ac6:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0204aca:	000aa697          	auipc	a3,0xaa
ffffffffc0204ace:	dde68693          	addi	a3,a3,-546 # ffffffffc02ae8a8 <free_area>
ffffffffc0204ad2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204ad4:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0204ad6:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0204ada:	9db9                	addw	a1,a1,a4
ffffffffc0204adc:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0204ade:	04d78a63          	beq	a5,a3,ffffffffc0204b32 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0204ae2:	fe878713          	addi	a4,a5,-24
ffffffffc0204ae6:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0204aea:	4581                	li	a1,0
            if (base < page) {
ffffffffc0204aec:	00e56a63          	bltu	a0,a4,ffffffffc0204b00 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0204af0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204af2:	02d70263          	beq	a4,a3,ffffffffc0204b16 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0204af6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204af8:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204afc:	fee57ae3          	bgeu	a0,a4,ffffffffc0204af0 <default_init_memmap+0x60>
ffffffffc0204b00:	c199                	beqz	a1,ffffffffc0204b06 <default_init_memmap+0x76>
ffffffffc0204b02:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204b06:	6398                	ld	a4,0(a5)
}
ffffffffc0204b08:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0204b0a:	e390                	sd	a2,0(a5)
ffffffffc0204b0c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0204b0e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204b10:	ed18                	sd	a4,24(a0)
ffffffffc0204b12:	0141                	addi	sp,sp,16
ffffffffc0204b14:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204b16:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204b18:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0204b1a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204b1c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204b1e:	00d70663          	beq	a4,a3,ffffffffc0204b2a <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0204b22:	8832                	mv	a6,a2
ffffffffc0204b24:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0204b26:	87ba                	mv	a5,a4
ffffffffc0204b28:	bfc1                	j	ffffffffc0204af8 <default_init_memmap+0x68>
}
ffffffffc0204b2a:	60a2                	ld	ra,8(sp)
ffffffffc0204b2c:	e290                	sd	a2,0(a3)
ffffffffc0204b2e:	0141                	addi	sp,sp,16
ffffffffc0204b30:	8082                	ret
ffffffffc0204b32:	60a2                	ld	ra,8(sp)
ffffffffc0204b34:	e390                	sd	a2,0(a5)
ffffffffc0204b36:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204b38:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204b3a:	ed1c                	sd	a5,24(a0)
ffffffffc0204b3c:	0141                	addi	sp,sp,16
ffffffffc0204b3e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0204b40:	00003697          	auipc	a3,0x3
ffffffffc0204b44:	73068693          	addi	a3,a3,1840 # ffffffffc0208270 <commands+0x1a58>
ffffffffc0204b48:	00002617          	auipc	a2,0x2
ffffffffc0204b4c:	0e060613          	addi	a2,a2,224 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204b50:	04900593          	li	a1,73
ffffffffc0204b54:	00003517          	auipc	a0,0x3
ffffffffc0204b58:	3dc50513          	addi	a0,a0,988 # ffffffffc0207f30 <commands+0x1718>
ffffffffc0204b5c:	eacfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc0204b60:	00003697          	auipc	a3,0x3
ffffffffc0204b64:	6e068693          	addi	a3,a3,1760 # ffffffffc0208240 <commands+0x1a28>
ffffffffc0204b68:	00002617          	auipc	a2,0x2
ffffffffc0204b6c:	0c060613          	addi	a2,a2,192 # ffffffffc0206c28 <commands+0x410>
ffffffffc0204b70:	04600593          	li	a1,70
ffffffffc0204b74:	00003517          	auipc	a0,0x3
ffffffffc0204b78:	3bc50513          	addi	a0,a0,956 # ffffffffc0207f30 <commands+0x1718>
ffffffffc0204b7c:	e8cfb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204b80 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b80:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b82:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b84:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b86:	9a3fb0ef          	jal	ra,ffffffffc0200528 <ide_device_valid>
ffffffffc0204b8a:	cd01                	beqz	a0,ffffffffc0204ba2 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b8c:	4505                	li	a0,1
ffffffffc0204b8e:	9a1fb0ef          	jal	ra,ffffffffc020052e <ide_device_size>
}
ffffffffc0204b92:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b94:	810d                	srli	a0,a0,0x3
ffffffffc0204b96:	000ae797          	auipc	a5,0xae
ffffffffc0204b9a:	d8a7bd23          	sd	a0,-614(a5) # ffffffffc02b2930 <max_swap_offset>
}
ffffffffc0204b9e:	0141                	addi	sp,sp,16
ffffffffc0204ba0:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204ba2:	00003617          	auipc	a2,0x3
ffffffffc0204ba6:	72e60613          	addi	a2,a2,1838 # ffffffffc02082d0 <default_pmm_manager+0x38>
ffffffffc0204baa:	45b5                	li	a1,13
ffffffffc0204bac:	00003517          	auipc	a0,0x3
ffffffffc0204bb0:	74450513          	addi	a0,a0,1860 # ffffffffc02082f0 <default_pmm_manager+0x58>
ffffffffc0204bb4:	e54fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204bb8 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204bb8:	1141                	addi	sp,sp,-16
ffffffffc0204bba:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bbc:	00855793          	srli	a5,a0,0x8
ffffffffc0204bc0:	cbb1                	beqz	a5,ffffffffc0204c14 <swapfs_read+0x5c>
ffffffffc0204bc2:	000ae717          	auipc	a4,0xae
ffffffffc0204bc6:	d6e73703          	ld	a4,-658(a4) # ffffffffc02b2930 <max_swap_offset>
ffffffffc0204bca:	04e7f563          	bgeu	a5,a4,ffffffffc0204c14 <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204bce:	000ae617          	auipc	a2,0xae
ffffffffc0204bd2:	d3263603          	ld	a2,-718(a2) # ffffffffc02b2900 <pages>
ffffffffc0204bd6:	8d91                	sub	a1,a1,a2
ffffffffc0204bd8:	4065d613          	srai	a2,a1,0x6
ffffffffc0204bdc:	00004717          	auipc	a4,0x4
ffffffffc0204be0:	04473703          	ld	a4,68(a4) # ffffffffc0208c20 <nbase>
ffffffffc0204be4:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204be6:	00c61713          	slli	a4,a2,0xc
ffffffffc0204bea:	8331                	srli	a4,a4,0xc
ffffffffc0204bec:	000ae697          	auipc	a3,0xae
ffffffffc0204bf0:	d0c6b683          	ld	a3,-756(a3) # ffffffffc02b28f8 <npage>
ffffffffc0204bf4:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bf8:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204bfa:	02d77963          	bgeu	a4,a3,ffffffffc0204c2c <swapfs_read+0x74>
}
ffffffffc0204bfe:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c00:	000ae797          	auipc	a5,0xae
ffffffffc0204c04:	d107b783          	ld	a5,-752(a5) # ffffffffc02b2910 <va_pa_offset>
ffffffffc0204c08:	46a1                	li	a3,8
ffffffffc0204c0a:	963e                	add	a2,a2,a5
ffffffffc0204c0c:	4505                	li	a0,1
}
ffffffffc0204c0e:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c10:	925fb06f          	j	ffffffffc0200534 <ide_read_secs>
ffffffffc0204c14:	86aa                	mv	a3,a0
ffffffffc0204c16:	00003617          	auipc	a2,0x3
ffffffffc0204c1a:	6f260613          	addi	a2,a2,1778 # ffffffffc0208308 <default_pmm_manager+0x70>
ffffffffc0204c1e:	45d1                	li	a1,20
ffffffffc0204c20:	00003517          	auipc	a0,0x3
ffffffffc0204c24:	6d050513          	addi	a0,a0,1744 # ffffffffc02082f0 <default_pmm_manager+0x58>
ffffffffc0204c28:	de0fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204c2c:	86b2                	mv	a3,a2
ffffffffc0204c2e:	06900593          	li	a1,105
ffffffffc0204c32:	00002617          	auipc	a2,0x2
ffffffffc0204c36:	33e60613          	addi	a2,a2,830 # ffffffffc0206f70 <commands+0x758>
ffffffffc0204c3a:	00002517          	auipc	a0,0x2
ffffffffc0204c3e:	2fe50513          	addi	a0,a0,766 # ffffffffc0206f38 <commands+0x720>
ffffffffc0204c42:	dc6fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204c46 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204c46:	1141                	addi	sp,sp,-16
ffffffffc0204c48:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c4a:	00855793          	srli	a5,a0,0x8
ffffffffc0204c4e:	cbb1                	beqz	a5,ffffffffc0204ca2 <swapfs_write+0x5c>
ffffffffc0204c50:	000ae717          	auipc	a4,0xae
ffffffffc0204c54:	ce073703          	ld	a4,-800(a4) # ffffffffc02b2930 <max_swap_offset>
ffffffffc0204c58:	04e7f563          	bgeu	a5,a4,ffffffffc0204ca2 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204c5c:	000ae617          	auipc	a2,0xae
ffffffffc0204c60:	ca463603          	ld	a2,-860(a2) # ffffffffc02b2900 <pages>
ffffffffc0204c64:	8d91                	sub	a1,a1,a2
ffffffffc0204c66:	4065d613          	srai	a2,a1,0x6
ffffffffc0204c6a:	00004717          	auipc	a4,0x4
ffffffffc0204c6e:	fb673703          	ld	a4,-74(a4) # ffffffffc0208c20 <nbase>
ffffffffc0204c72:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204c74:	00c61713          	slli	a4,a2,0xc
ffffffffc0204c78:	8331                	srli	a4,a4,0xc
ffffffffc0204c7a:	000ae697          	auipc	a3,0xae
ffffffffc0204c7e:	c7e6b683          	ld	a3,-898(a3) # ffffffffc02b28f8 <npage>
ffffffffc0204c82:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c86:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c88:	02d77963          	bgeu	a4,a3,ffffffffc0204cba <swapfs_write+0x74>
}
ffffffffc0204c8c:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c8e:	000ae797          	auipc	a5,0xae
ffffffffc0204c92:	c827b783          	ld	a5,-894(a5) # ffffffffc02b2910 <va_pa_offset>
ffffffffc0204c96:	46a1                	li	a3,8
ffffffffc0204c98:	963e                	add	a2,a2,a5
ffffffffc0204c9a:	4505                	li	a0,1
}
ffffffffc0204c9c:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c9e:	8bbfb06f          	j	ffffffffc0200558 <ide_write_secs>
ffffffffc0204ca2:	86aa                	mv	a3,a0
ffffffffc0204ca4:	00003617          	auipc	a2,0x3
ffffffffc0204ca8:	66460613          	addi	a2,a2,1636 # ffffffffc0208308 <default_pmm_manager+0x70>
ffffffffc0204cac:	45e5                	li	a1,25
ffffffffc0204cae:	00003517          	auipc	a0,0x3
ffffffffc0204cb2:	64250513          	addi	a0,a0,1602 # ffffffffc02082f0 <default_pmm_manager+0x58>
ffffffffc0204cb6:	d52fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204cba:	86b2                	mv	a3,a2
ffffffffc0204cbc:	06900593          	li	a1,105
ffffffffc0204cc0:	00002617          	auipc	a2,0x2
ffffffffc0204cc4:	2b060613          	addi	a2,a2,688 # ffffffffc0206f70 <commands+0x758>
ffffffffc0204cc8:	00002517          	auipc	a0,0x2
ffffffffc0204ccc:	27050513          	addi	a0,a0,624 # ffffffffc0206f38 <commands+0x720>
ffffffffc0204cd0:	d38fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204cd4 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204cd4:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204cd6:	9402                	jalr	s0

	jal do_exit
ffffffffc0204cd8:	632000ef          	jal	ra,ffffffffc020530a <do_exit>

ffffffffc0204cdc <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204cdc:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204ce0:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204ce4:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204ce6:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204ce8:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204cec:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204cf0:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204cf4:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204cf8:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204cfc:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204d00:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204d04:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204d08:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204d0c:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204d10:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204d14:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204d18:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204d1a:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204d1c:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204d20:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204d24:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204d28:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204d2c:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204d30:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204d34:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204d38:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204d3c:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204d40:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204d44:	8082                	ret

ffffffffc0204d46 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204d46:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d48:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204d4c:	e022                	sd	s0,0(sp)
ffffffffc0204d4e:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d50:	8d1fe0ef          	jal	ra,ffffffffc0203620 <kmalloc>
ffffffffc0204d54:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204d56:	c521                	beqz	a0,ffffffffc0204d9e <alloc_proc+0x58>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->state = PROC_UNINIT;
ffffffffc0204d58:	57fd                	li	a5,-1
ffffffffc0204d5a:	1782                	slli	a5,a5,0x20
ffffffffc0204d5c:	e11c                	sd	a5,0(a0)
    proc->runs = 0;  
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204d5e:	07000613          	li	a2,112
ffffffffc0204d62:	4581                	li	a1,0
    proc->runs = 0;  
ffffffffc0204d64:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0204d68:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0204d6c:	00053c23          	sd	zero,24(a0)
    proc->parent = NULL;
ffffffffc0204d70:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc0204d74:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204d78:	03050513          	addi	a0,a0,48
ffffffffc0204d7c:	3c2010ef          	jal	ra,ffffffffc020613e <memset>
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
ffffffffc0204d80:	000ae797          	auipc	a5,0xae
ffffffffc0204d84:	b687b783          	ld	a5,-1176(a5) # ffffffffc02b28e8 <boot_cr3>
    proc->tf = NULL;
ffffffffc0204d88:	0a043023          	sd	zero,160(s0)
    proc->cr3 = boot_cr3;
ffffffffc0204d8c:	f45c                	sd	a5,168(s0)
    proc->flags = 0;
ffffffffc0204d8e:	0a042823          	sw	zero,176(s0)
    memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204d92:	463d                	li	a2,15
ffffffffc0204d94:	4581                	li	a1,0
ffffffffc0204d96:	0b440513          	addi	a0,s0,180
ffffffffc0204d9a:	3a4010ef          	jal	ra,ffffffffc020613e <memset>
    }
    return proc;
}
ffffffffc0204d9e:	60a2                	ld	ra,8(sp)
ffffffffc0204da0:	8522                	mv	a0,s0
ffffffffc0204da2:	6402                	ld	s0,0(sp)
ffffffffc0204da4:	0141                	addi	sp,sp,16
ffffffffc0204da6:	8082                	ret

ffffffffc0204da8 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204da8:	000ae797          	auipc	a5,0xae
ffffffffc0204dac:	ba07b783          	ld	a5,-1120(a5) # ffffffffc02b2948 <current>
ffffffffc0204db0:	73c8                	ld	a0,160(a5)
ffffffffc0204db2:	fc5fb06f          	j	ffffffffc0200d76 <forkrets>

ffffffffc0204db6 <user_main>:
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
ffffffffc0204db6:	000ae797          	auipc	a5,0xae
ffffffffc0204dba:	b927b783          	ld	a5,-1134(a5) # ffffffffc02b2948 <current>
ffffffffc0204dbe:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204dc0:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE(exit);
ffffffffc0204dc2:	00003617          	auipc	a2,0x3
ffffffffc0204dc6:	56660613          	addi	a2,a2,1382 # ffffffffc0208328 <default_pmm_manager+0x90>
ffffffffc0204dca:	00003517          	auipc	a0,0x3
ffffffffc0204dce:	56650513          	addi	a0,a0,1382 # ffffffffc0208330 <default_pmm_manager+0x98>
user_main(void *arg) {
ffffffffc0204dd2:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE(exit);
ffffffffc0204dd4:	af8fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0204dd8:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204ddc:	35878793          	addi	a5,a5,856 # b130 <_binary_obj___user_exit_out_size>
ffffffffc0204de0:	e43e                	sd	a5,8(sp)
ffffffffc0204de2:	00003517          	auipc	a0,0x3
ffffffffc0204de6:	54650513          	addi	a0,a0,1350 # ffffffffc0208328 <default_pmm_manager+0x90>
ffffffffc0204dea:	0003a797          	auipc	a5,0x3a
ffffffffc0204dee:	2b678793          	addi	a5,a5,694 # ffffffffc023f0a0 <_binary_obj___user_exit_out_start>
ffffffffc0204df2:	f03e                	sd	a5,32(sp)
ffffffffc0204df4:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204df6:	e802                	sd	zero,16(sp)
ffffffffc0204df8:	2ca010ef          	jal	ra,ffffffffc02060c2 <strlen>
ffffffffc0204dfc:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204dfe:	4511                	li	a0,4
ffffffffc0204e00:	55a2                	lw	a1,40(sp)
ffffffffc0204e02:	4662                	lw	a2,24(sp)
ffffffffc0204e04:	5682                	lw	a3,32(sp)
ffffffffc0204e06:	4722                	lw	a4,8(sp)
ffffffffc0204e08:	48a9                	li	a7,10
ffffffffc0204e0a:	9002                	ebreak
ffffffffc0204e0c:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204e0e:	65c2                	ld	a1,16(sp)
ffffffffc0204e10:	00003517          	auipc	a0,0x3
ffffffffc0204e14:	54850513          	addi	a0,a0,1352 # ffffffffc0208358 <default_pmm_manager+0xc0>
ffffffffc0204e18:	ab4fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
#endif
    panic("user_main execve failed.\n");
ffffffffc0204e1c:	00003617          	auipc	a2,0x3
ffffffffc0204e20:	54c60613          	addi	a2,a2,1356 # ffffffffc0208368 <default_pmm_manager+0xd0>
ffffffffc0204e24:	34900593          	li	a1,841
ffffffffc0204e28:	00003517          	auipc	a0,0x3
ffffffffc0204e2c:	56050513          	addi	a0,a0,1376 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0204e30:	bd8fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204e34 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204e34:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204e36:	1141                	addi	sp,sp,-16
ffffffffc0204e38:	e406                	sd	ra,8(sp)
ffffffffc0204e3a:	c02007b7          	lui	a5,0xc0200
ffffffffc0204e3e:	02f6ee63          	bltu	a3,a5,ffffffffc0204e7a <put_pgdir+0x46>
ffffffffc0204e42:	000ae517          	auipc	a0,0xae
ffffffffc0204e46:	ace53503          	ld	a0,-1330(a0) # ffffffffc02b2910 <va_pa_offset>
ffffffffc0204e4a:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204e4c:	82b1                	srli	a3,a3,0xc
ffffffffc0204e4e:	000ae797          	auipc	a5,0xae
ffffffffc0204e52:	aaa7b783          	ld	a5,-1366(a5) # ffffffffc02b28f8 <npage>
ffffffffc0204e56:	02f6fe63          	bgeu	a3,a5,ffffffffc0204e92 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204e5a:	00004517          	auipc	a0,0x4
ffffffffc0204e5e:	dc653503          	ld	a0,-570(a0) # ffffffffc0208c20 <nbase>
}
ffffffffc0204e62:	60a2                	ld	ra,8(sp)
ffffffffc0204e64:	8e89                	sub	a3,a3,a0
ffffffffc0204e66:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e68:	000ae517          	auipc	a0,0xae
ffffffffc0204e6c:	a9853503          	ld	a0,-1384(a0) # ffffffffc02b2900 <pages>
ffffffffc0204e70:	4585                	li	a1,1
ffffffffc0204e72:	9536                	add	a0,a0,a3
}
ffffffffc0204e74:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e76:	876fc06f          	j	ffffffffc0200eec <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e7a:	00002617          	auipc	a2,0x2
ffffffffc0204e7e:	1ce60613          	addi	a2,a2,462 # ffffffffc0207048 <commands+0x830>
ffffffffc0204e82:	06e00593          	li	a1,110
ffffffffc0204e86:	00002517          	auipc	a0,0x2
ffffffffc0204e8a:	0b250513          	addi	a0,a0,178 # ffffffffc0206f38 <commands+0x720>
ffffffffc0204e8e:	b7afb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e92:	00002617          	auipc	a2,0x2
ffffffffc0204e96:	08660613          	addi	a2,a2,134 # ffffffffc0206f18 <commands+0x700>
ffffffffc0204e9a:	06200593          	li	a1,98
ffffffffc0204e9e:	00002517          	auipc	a0,0x2
ffffffffc0204ea2:	09a50513          	addi	a0,a0,154 # ffffffffc0206f38 <commands+0x720>
ffffffffc0204ea6:	b62fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204eaa <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204eaa:	7179                	addi	sp,sp,-48
ffffffffc0204eac:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204eae:	000ae917          	auipc	s2,0xae
ffffffffc0204eb2:	a9a90913          	addi	s2,s2,-1382 # ffffffffc02b2948 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204eb6:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204eb8:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204ebc:	f406                	sd	ra,40(sp)
ffffffffc0204ebe:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204ec0:	02a48863          	beq	s1,a0,ffffffffc0204ef0 <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ec4:	100027f3          	csrr	a5,sstatus
ffffffffc0204ec8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204eca:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ecc:	ef9d                	bnez	a5,ffffffffc0204f0a <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204ece:	755c                	ld	a5,168(a0)
ffffffffc0204ed0:	577d                	li	a4,-1
ffffffffc0204ed2:	177e                	slli	a4,a4,0x3f
ffffffffc0204ed4:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0204ed6:	00a93023          	sd	a0,0(s2)
ffffffffc0204eda:	8fd9                	or	a5,a5,a4
ffffffffc0204edc:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204ee0:	03050593          	addi	a1,a0,48
ffffffffc0204ee4:	03048513          	addi	a0,s1,48
ffffffffc0204ee8:	df5ff0ef          	jal	ra,ffffffffc0204cdc <switch_to>
    if (flag) {
ffffffffc0204eec:	00099863          	bnez	s3,ffffffffc0204efc <proc_run+0x52>
}
ffffffffc0204ef0:	70a2                	ld	ra,40(sp)
ffffffffc0204ef2:	7482                	ld	s1,32(sp)
ffffffffc0204ef4:	6962                	ld	s2,24(sp)
ffffffffc0204ef6:	69c2                	ld	s3,16(sp)
ffffffffc0204ef8:	6145                	addi	sp,sp,48
ffffffffc0204efa:	8082                	ret
ffffffffc0204efc:	70a2                	ld	ra,40(sp)
ffffffffc0204efe:	7482                	ld	s1,32(sp)
ffffffffc0204f00:	6962                	ld	s2,24(sp)
ffffffffc0204f02:	69c2                	ld	s3,16(sp)
ffffffffc0204f04:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204f06:	f3cfb06f          	j	ffffffffc0200642 <intr_enable>
ffffffffc0204f0a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204f0c:	f3cfb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0204f10:	6522                	ld	a0,8(sp)
ffffffffc0204f12:	4985                	li	s3,1
ffffffffc0204f14:	bf6d                	j	ffffffffc0204ece <proc_run+0x24>

ffffffffc0204f16 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f16:	7159                	addi	sp,sp,-112
ffffffffc0204f18:	eca6                	sd	s1,88(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f1a:	000ae497          	auipc	s1,0xae
ffffffffc0204f1e:	a4648493          	addi	s1,s1,-1466 # ffffffffc02b2960 <nr_process>
ffffffffc0204f22:	4098                	lw	a4,0(s1)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f24:	f486                	sd	ra,104(sp)
ffffffffc0204f26:	f0a2                	sd	s0,96(sp)
ffffffffc0204f28:	e8ca                	sd	s2,80(sp)
ffffffffc0204f2a:	e4ce                	sd	s3,72(sp)
ffffffffc0204f2c:	e0d2                	sd	s4,64(sp)
ffffffffc0204f2e:	fc56                	sd	s5,56(sp)
ffffffffc0204f30:	f85a                	sd	s6,48(sp)
ffffffffc0204f32:	f45e                	sd	s7,40(sp)
ffffffffc0204f34:	f062                	sd	s8,32(sp)
ffffffffc0204f36:	ec66                	sd	s9,24(sp)
ffffffffc0204f38:	e86a                	sd	s10,16(sp)
ffffffffc0204f3a:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f3c:	6785                	lui	a5,0x1
ffffffffc0204f3e:	2ef75a63          	bge	a4,a5,ffffffffc0205232 <do_fork+0x31c>
ffffffffc0204f42:	8a2a                	mv	s4,a0
ffffffffc0204f44:	892e                	mv	s2,a1
ffffffffc0204f46:	8432                	mv	s0,a2
   proc = alloc_proc();
ffffffffc0204f48:	dffff0ef          	jal	ra,ffffffffc0204d46 <alloc_proc>
ffffffffc0204f4c:	89aa                	mv	s3,a0
    if (proc == NULL)
ffffffffc0204f4e:	2e050763          	beqz	a0,ffffffffc020523c <do_fork+0x326>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204f52:	4509                	li	a0,2
ffffffffc0204f54:	f07fb0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
    if (page != NULL) {
ffffffffc0204f58:	28050763          	beqz	a0,ffffffffc02051e6 <do_fork+0x2d0>
    return page - pages + nbase;
ffffffffc0204f5c:	000aed97          	auipc	s11,0xae
ffffffffc0204f60:	9a4d8d93          	addi	s11,s11,-1628 # ffffffffc02b2900 <pages>
ffffffffc0204f64:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc0204f68:	000aed17          	auipc	s10,0xae
ffffffffc0204f6c:	990d0d13          	addi	s10,s10,-1648 # ffffffffc02b28f8 <npage>
    return page - pages + nbase;
ffffffffc0204f70:	00004c97          	auipc	s9,0x4
ffffffffc0204f74:	cb0cbc83          	ld	s9,-848(s9) # ffffffffc0208c20 <nbase>
ffffffffc0204f78:	40d506b3          	sub	a3,a0,a3
ffffffffc0204f7c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204f7e:	5c7d                	li	s8,-1
ffffffffc0204f80:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0204f84:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0204f86:	00cc5c13          	srli	s8,s8,0xc
ffffffffc0204f8a:	0186f733          	and	a4,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc0204f8e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204f90:	2cf77563          	bgeu	a4,a5,ffffffffc020525a <do_fork+0x344>
ffffffffc0204f94:	000aea97          	auipc	s5,0xae
ffffffffc0204f98:	97ca8a93          	addi	s5,s5,-1668 # ffffffffc02b2910 <va_pa_offset>
ffffffffc0204f9c:	000ab783          	ld	a5,0(s5)
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204fa0:	000ae717          	auipc	a4,0xae
ffffffffc0204fa4:	9a873703          	ld	a4,-1624(a4) # ffffffffc02b2948 <current>
ffffffffc0204fa8:	02873b83          	ld	s7,40(a4)
ffffffffc0204fac:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204fae:	00d9b823          	sd	a3,16(s3)
    if (oldmm == NULL) {
ffffffffc0204fb2:	020b8a63          	beqz	s7,ffffffffc0204fe6 <do_fork+0xd0>
    if (clone_flags & CLONE_VM) {
ffffffffc0204fb6:	100a7a13          	andi	s4,s4,256
ffffffffc0204fba:	180a0563          	beqz	s4,ffffffffc0205144 <do_fork+0x22e>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204fbe:	030ba703          	lw	a4,48(s7)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204fc2:	018bb783          	ld	a5,24(s7)
ffffffffc0204fc6:	c02006b7          	lui	a3,0xc0200
ffffffffc0204fca:	2705                	addiw	a4,a4,1
ffffffffc0204fcc:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc0204fd0:	0379b423          	sd	s7,40(s3)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204fd4:	26d7e663          	bltu	a5,a3,ffffffffc0205240 <do_fork+0x32a>
ffffffffc0204fd8:	000ab703          	ld	a4,0(s5)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204fdc:	0109b683          	ld	a3,16(s3)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204fe0:	8f99                	sub	a5,a5,a4
ffffffffc0204fe2:	0af9b423          	sd	a5,168(s3)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204fe6:	6789                	lui	a5,0x2
ffffffffc0204fe8:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7ce0>
ffffffffc0204fec:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204fee:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204ff0:	0ad9b023          	sd	a3,160(s3)
    *(proc->tf) = *tf;
ffffffffc0204ff4:	87b6                	mv	a5,a3
ffffffffc0204ff6:	12040893          	addi	a7,s0,288
ffffffffc0204ffa:	00063803          	ld	a6,0(a2)
ffffffffc0204ffe:	6608                	ld	a0,8(a2)
ffffffffc0205000:	6a0c                	ld	a1,16(a2)
ffffffffc0205002:	6e18                	ld	a4,24(a2)
ffffffffc0205004:	0107b023          	sd	a6,0(a5)
ffffffffc0205008:	e788                	sd	a0,8(a5)
ffffffffc020500a:	eb8c                	sd	a1,16(a5)
ffffffffc020500c:	ef98                	sd	a4,24(a5)
ffffffffc020500e:	02060613          	addi	a2,a2,32
ffffffffc0205012:	02078793          	addi	a5,a5,32
ffffffffc0205016:	ff1612e3          	bne	a2,a7,ffffffffc0204ffa <do_fork+0xe4>
    proc->tf->gpr.a0 = 0;
ffffffffc020501a:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020501e:	12090163          	beqz	s2,ffffffffc0205140 <do_fork+0x22a>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205022:	000a2517          	auipc	a0,0xa2
ffffffffc0205026:	3de50513          	addi	a0,a0,990 # ffffffffc02a7400 <last_pid.1>
ffffffffc020502a:	411c                	lw	a5,0(a0)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020502c:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205030:	00000717          	auipc	a4,0x0
ffffffffc0205034:	d7870713          	addi	a4,a4,-648 # ffffffffc0204da8 <forkret>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205038:	0017891b          	addiw	s2,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020503c:	02e9b823          	sd	a4,48(s3)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205040:	02d9bc23          	sd	a3,56(s3)
    if (++ last_pid >= MAX_PID) {
ffffffffc0205044:	01252023          	sw	s2,0(a0)
ffffffffc0205048:	6789                	lui	a5,0x2
ffffffffc020504a:	08f95663          	bge	s2,a5,ffffffffc02050d6 <do_fork+0x1c0>
    if (last_pid >= next_safe) {
ffffffffc020504e:	000a2897          	auipc	a7,0xa2
ffffffffc0205052:	3b688893          	addi	a7,a7,950 # ffffffffc02a7404 <next_safe.0>
ffffffffc0205056:	0008a783          	lw	a5,0(a7)
ffffffffc020505a:	000ae417          	auipc	s0,0xae
ffffffffc020505e:	86640413          	addi	s0,s0,-1946 # ffffffffc02b28c0 <proc_list>
ffffffffc0205062:	08f95163          	bge	s2,a5,ffffffffc02050e4 <do_fork+0x1ce>
    nr_process++;
ffffffffc0205066:	409c                	lw	a5,0(s1)
    proc->pid = pid;
ffffffffc0205068:	0129a223          	sw	s2,4(s3)
    list_add(hash_list + pid_hashfn(pid), &(proc->hash_link));
ffffffffc020506c:	45a9                	li	a1,10
    nr_process++;
ffffffffc020506e:	2785                	addiw	a5,a5,1
    list_add(hash_list + pid_hashfn(pid), &(proc->hash_link));
ffffffffc0205070:	0009051b          	sext.w	a0,s2
    nr_process++;
ffffffffc0205074:	c09c                	sw	a5,0(s1)
    list_add(hash_list + pid_hashfn(pid), &(proc->hash_link));
ffffffffc0205076:	4e0010ef          	jal	ra,ffffffffc0206556 <hash32>
ffffffffc020507a:	02051793          	slli	a5,a0,0x20
ffffffffc020507e:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205082:	000aa797          	auipc	a5,0xaa
ffffffffc0205086:	83e78793          	addi	a5,a5,-1986 # ffffffffc02ae8c0 <hash_list>
ffffffffc020508a:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020508c:	6514                	ld	a3,8(a0)
ffffffffc020508e:	0d898793          	addi	a5,s3,216
ffffffffc0205092:	6418                	ld	a4,8(s0)
    prev->next = next->prev = elm;
ffffffffc0205094:	e29c                	sd	a5,0(a3)
ffffffffc0205096:	e51c                	sd	a5,8(a0)
    elm->prev = prev;
ffffffffc0205098:	0ca9bc23          	sd	a0,216(s3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc020509c:	0c898793          	addi	a5,s3,200
    elm->next = next;
ffffffffc02050a0:	0ed9b023          	sd	a3,224(s3)
    prev->next = next->prev = elm;
ffffffffc02050a4:	e31c                	sd	a5,0(a4)
    elm->next = next;
ffffffffc02050a6:	0ce9b823          	sd	a4,208(s3)
    elm->prev = prev;
ffffffffc02050aa:	0c89b423          	sd	s0,200(s3)
    wakeup_proc(proc);
ffffffffc02050ae:	854e                	mv	a0,s3
    prev->next = next->prev = elm;
ffffffffc02050b0:	e41c                	sd	a5,8(s0)
ffffffffc02050b2:	625000ef          	jal	ra,ffffffffc0205ed6 <wakeup_proc>
}
ffffffffc02050b6:	70a6                	ld	ra,104(sp)
ffffffffc02050b8:	7406                	ld	s0,96(sp)
ffffffffc02050ba:	64e6                	ld	s1,88(sp)
ffffffffc02050bc:	69a6                	ld	s3,72(sp)
ffffffffc02050be:	6a06                	ld	s4,64(sp)
ffffffffc02050c0:	7ae2                	ld	s5,56(sp)
ffffffffc02050c2:	7b42                	ld	s6,48(sp)
ffffffffc02050c4:	7ba2                	ld	s7,40(sp)
ffffffffc02050c6:	7c02                	ld	s8,32(sp)
ffffffffc02050c8:	6ce2                	ld	s9,24(sp)
ffffffffc02050ca:	6d42                	ld	s10,16(sp)
ffffffffc02050cc:	6da2                	ld	s11,8(sp)
ffffffffc02050ce:	854a                	mv	a0,s2
ffffffffc02050d0:	6946                	ld	s2,80(sp)
ffffffffc02050d2:	6165                	addi	sp,sp,112
ffffffffc02050d4:	8082                	ret
        last_pid = 1;
ffffffffc02050d6:	4785                	li	a5,1
ffffffffc02050d8:	c11c                	sw	a5,0(a0)
        goto inside;
ffffffffc02050da:	4905                	li	s2,1
ffffffffc02050dc:	000a2897          	auipc	a7,0xa2
ffffffffc02050e0:	32888893          	addi	a7,a7,808 # ffffffffc02a7404 <next_safe.0>
    return listelm->next;
ffffffffc02050e4:	000ad417          	auipc	s0,0xad
ffffffffc02050e8:	7dc40413          	addi	s0,s0,2012 # ffffffffc02b28c0 <proc_list>
ffffffffc02050ec:	00843303          	ld	t1,8(s0)
        next_safe = MAX_PID;
ffffffffc02050f0:	6789                	lui	a5,0x2
ffffffffc02050f2:	00f8a023          	sw	a5,0(a7)
ffffffffc02050f6:	86ca                	mv	a3,s2
ffffffffc02050f8:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc02050fa:	6e09                	lui	t3,0x2
ffffffffc02050fc:	0e830163          	beq	t1,s0,ffffffffc02051de <do_fork+0x2c8>
ffffffffc0205100:	882e                	mv	a6,a1
ffffffffc0205102:	879a                	mv	a5,t1
ffffffffc0205104:	6609                	lui	a2,0x2
ffffffffc0205106:	a811                	j	ffffffffc020511a <do_fork+0x204>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205108:	00e6d663          	bge	a3,a4,ffffffffc0205114 <do_fork+0x1fe>
ffffffffc020510c:	00c75463          	bge	a4,a2,ffffffffc0205114 <do_fork+0x1fe>
ffffffffc0205110:	863a                	mv	a2,a4
ffffffffc0205112:	4805                	li	a6,1
ffffffffc0205114:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205116:	00878d63          	beq	a5,s0,ffffffffc0205130 <do_fork+0x21a>
            if (proc->pid == last_pid) {
ffffffffc020511a:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c84>
ffffffffc020511e:	fed715e3          	bne	a4,a3,ffffffffc0205108 <do_fork+0x1f2>
                if (++ last_pid >= next_safe) {
ffffffffc0205122:	2685                	addiw	a3,a3,1
ffffffffc0205124:	0ac6d863          	bge	a3,a2,ffffffffc02051d4 <do_fork+0x2be>
ffffffffc0205128:	679c                	ld	a5,8(a5)
ffffffffc020512a:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc020512c:	fe8797e3          	bne	a5,s0,ffffffffc020511a <do_fork+0x204>
ffffffffc0205130:	c199                	beqz	a1,ffffffffc0205136 <do_fork+0x220>
ffffffffc0205132:	c114                	sw	a3,0(a0)
ffffffffc0205134:	8936                	mv	s2,a3
ffffffffc0205136:	f20808e3          	beqz	a6,ffffffffc0205066 <do_fork+0x150>
ffffffffc020513a:	00c8a023          	sw	a2,0(a7)
ffffffffc020513e:	b725                	j	ffffffffc0205066 <do_fork+0x150>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205140:	8936                	mv	s2,a3
ffffffffc0205142:	b5c5                	j	ffffffffc0205022 <do_fork+0x10c>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205144:	85ffd0ef          	jal	ra,ffffffffc02029a2 <mm_create>
ffffffffc0205148:	8b2a                	mv	s6,a0
ffffffffc020514a:	c151                	beqz	a0,ffffffffc02051ce <do_fork+0x2b8>
    if ((page = alloc_page()) == NULL) {
ffffffffc020514c:	4505                	li	a0,1
ffffffffc020514e:	d0dfb0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0205152:	c93d                	beqz	a0,ffffffffc02051c8 <do_fork+0x2b2>
    return page - pages + nbase;
ffffffffc0205154:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc0205158:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc020515c:	40d506b3          	sub	a3,a0,a3
ffffffffc0205160:	8699                	srai	a3,a3,0x6
ffffffffc0205162:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0205164:	0186fc33          	and	s8,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc0205168:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020516a:	0efc7863          	bgeu	s8,a5,ffffffffc020525a <do_fork+0x344>
ffffffffc020516e:	000aba03          	ld	s4,0(s5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205172:	6605                	lui	a2,0x1
ffffffffc0205174:	000ad597          	auipc	a1,0xad
ffffffffc0205178:	77c5b583          	ld	a1,1916(a1) # ffffffffc02b28f0 <boot_pgdir>
ffffffffc020517c:	9a36                	add	s4,s4,a3
ffffffffc020517e:	8552                	mv	a0,s4
ffffffffc0205180:	7d1000ef          	jal	ra,ffffffffc0206150 <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205184:	038b8c13          	addi	s8,s7,56
    mm->pgdir = pgdir;
ffffffffc0205188:	014b3c23          	sd	s4,24(s6)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020518c:	4785                	li	a5,1
ffffffffc020518e:	40fc37af          	amoor.d	a5,a5,(s8)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0205192:	8b85                	andi	a5,a5,1
ffffffffc0205194:	4a05                	li	s4,1
ffffffffc0205196:	c799                	beqz	a5,ffffffffc02051a4 <do_fork+0x28e>
        schedule();
ffffffffc0205198:	5bf000ef          	jal	ra,ffffffffc0205f56 <schedule>
ffffffffc020519c:	414c37af          	amoor.d	a5,s4,(s8)
    while (!try_lock(lock)) {
ffffffffc02051a0:	8b85                	andi	a5,a5,1
ffffffffc02051a2:	fbfd                	bnez	a5,ffffffffc0205198 <do_fork+0x282>
        ret = dup_mmap(mm, oldmm);
ffffffffc02051a4:	85de                	mv	a1,s7
ffffffffc02051a6:	855a                	mv	a0,s6
ffffffffc02051a8:	a83fd0ef          	jal	ra,ffffffffc0202c2a <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02051ac:	57f9                	li	a5,-2
ffffffffc02051ae:	60fc37af          	amoand.d	a5,a5,(s8)
ffffffffc02051b2:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02051b4:	cfdd                	beqz	a5,ffffffffc0205272 <do_fork+0x35c>
good_mm:
ffffffffc02051b6:	8bda                	mv	s7,s6
    if (ret != 0) {
ffffffffc02051b8:	e00503e3          	beqz	a0,ffffffffc0204fbe <do_fork+0xa8>
    exit_mmap(mm);
ffffffffc02051bc:	855a                	mv	a0,s6
ffffffffc02051be:	b07fd0ef          	jal	ra,ffffffffc0202cc4 <exit_mmap>
    put_pgdir(mm);
ffffffffc02051c2:	855a                	mv	a0,s6
ffffffffc02051c4:	c71ff0ef          	jal	ra,ffffffffc0204e34 <put_pgdir>
    mm_destroy(mm);
ffffffffc02051c8:	855a                	mv	a0,s6
ffffffffc02051ca:	95ffd0ef          	jal	ra,ffffffffc0202b28 <mm_destroy>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02051ce:	0109b683          	ld	a3,16(s3)
ffffffffc02051d2:	bd11                	j	ffffffffc0204fe6 <do_fork+0xd0>
                    if (last_pid >= MAX_PID) {
ffffffffc02051d4:	01c6c363          	blt	a3,t3,ffffffffc02051da <do_fork+0x2c4>
                        last_pid = 1;
ffffffffc02051d8:	4685                	li	a3,1
                    goto repeat;
ffffffffc02051da:	4585                	li	a1,1
ffffffffc02051dc:	b705                	j	ffffffffc02050fc <do_fork+0x1e6>
ffffffffc02051de:	cda1                	beqz	a1,ffffffffc0205236 <do_fork+0x320>
ffffffffc02051e0:	c114                	sw	a3,0(a0)
    return last_pid;
ffffffffc02051e2:	8936                	mv	s2,a3
ffffffffc02051e4:	b549                	j	ffffffffc0205066 <do_fork+0x150>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02051e6:	0109b683          	ld	a3,16(s3)
    return pa2page(PADDR(kva));
ffffffffc02051ea:	c02007b7          	lui	a5,0xc0200
ffffffffc02051ee:	0af6ea63          	bltu	a3,a5,ffffffffc02052a2 <do_fork+0x38c>
ffffffffc02051f2:	000ad797          	auipc	a5,0xad
ffffffffc02051f6:	71e7b783          	ld	a5,1822(a5) # ffffffffc02b2910 <va_pa_offset>
ffffffffc02051fa:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02051fe:	83b1                	srli	a5,a5,0xc
ffffffffc0205200:	000ad717          	auipc	a4,0xad
ffffffffc0205204:	6f873703          	ld	a4,1784(a4) # ffffffffc02b28f8 <npage>
ffffffffc0205208:	08e7f163          	bgeu	a5,a4,ffffffffc020528a <do_fork+0x374>
    return &pages[PPN(pa) - nbase];
ffffffffc020520c:	00004717          	auipc	a4,0x4
ffffffffc0205210:	a1473703          	ld	a4,-1516(a4) # ffffffffc0208c20 <nbase>
ffffffffc0205214:	8f99                	sub	a5,a5,a4
ffffffffc0205216:	079a                	slli	a5,a5,0x6
ffffffffc0205218:	000ad517          	auipc	a0,0xad
ffffffffc020521c:	6e853503          	ld	a0,1768(a0) # ffffffffc02b2900 <pages>
ffffffffc0205220:	953e                	add	a0,a0,a5
ffffffffc0205222:	4589                	li	a1,2
ffffffffc0205224:	cc9fb0ef          	jal	ra,ffffffffc0200eec <free_pages>
    kfree(proc);
ffffffffc0205228:	854e                	mv	a0,s3
ffffffffc020522a:	ca6fe0ef          	jal	ra,ffffffffc02036d0 <kfree>
    ret = setup_kstack(proc);
ffffffffc020522e:	5971                	li	s2,-4
    goto fork_out;
ffffffffc0205230:	b559                	j	ffffffffc02050b6 <do_fork+0x1a0>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205232:	596d                	li	s2,-5
ffffffffc0205234:	b549                	j	ffffffffc02050b6 <do_fork+0x1a0>
    return last_pid;
ffffffffc0205236:	00052903          	lw	s2,0(a0)
ffffffffc020523a:	b535                	j	ffffffffc0205066 <do_fork+0x150>
    ret = -E_NO_MEM;
ffffffffc020523c:	5971                	li	s2,-4
    return ret;
ffffffffc020523e:	bda5                	j	ffffffffc02050b6 <do_fork+0x1a0>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205240:	86be                	mv	a3,a5
ffffffffc0205242:	00002617          	auipc	a2,0x2
ffffffffc0205246:	e0660613          	addi	a2,a2,-506 # ffffffffc0207048 <commands+0x830>
ffffffffc020524a:	16100593          	li	a1,353
ffffffffc020524e:	00003517          	auipc	a0,0x3
ffffffffc0205252:	13a50513          	addi	a0,a0,314 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205256:	fb3fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc020525a:	00002617          	auipc	a2,0x2
ffffffffc020525e:	d1660613          	addi	a2,a2,-746 # ffffffffc0206f70 <commands+0x758>
ffffffffc0205262:	06900593          	li	a1,105
ffffffffc0205266:	00002517          	auipc	a0,0x2
ffffffffc020526a:	cd250513          	addi	a0,a0,-814 # ffffffffc0206f38 <commands+0x720>
ffffffffc020526e:	f9bfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("Unlock failed.\n");
ffffffffc0205272:	00003617          	auipc	a2,0x3
ffffffffc0205276:	12e60613          	addi	a2,a2,302 # ffffffffc02083a0 <default_pmm_manager+0x108>
ffffffffc020527a:	03100593          	li	a1,49
ffffffffc020527e:	00003517          	auipc	a0,0x3
ffffffffc0205282:	13250513          	addi	a0,a0,306 # ffffffffc02083b0 <default_pmm_manager+0x118>
ffffffffc0205286:	f83fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020528a:	00002617          	auipc	a2,0x2
ffffffffc020528e:	c8e60613          	addi	a2,a2,-882 # ffffffffc0206f18 <commands+0x700>
ffffffffc0205292:	06200593          	li	a1,98
ffffffffc0205296:	00002517          	auipc	a0,0x2
ffffffffc020529a:	ca250513          	addi	a0,a0,-862 # ffffffffc0206f38 <commands+0x720>
ffffffffc020529e:	f6bfa0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02052a2:	00002617          	auipc	a2,0x2
ffffffffc02052a6:	da660613          	addi	a2,a2,-602 # ffffffffc0207048 <commands+0x830>
ffffffffc02052aa:	06e00593          	li	a1,110
ffffffffc02052ae:	00002517          	auipc	a0,0x2
ffffffffc02052b2:	c8a50513          	addi	a0,a0,-886 # ffffffffc0206f38 <commands+0x720>
ffffffffc02052b6:	f53fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02052ba <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02052ba:	7129                	addi	sp,sp,-320
ffffffffc02052bc:	fa22                	sd	s0,304(sp)
ffffffffc02052be:	f626                	sd	s1,296(sp)
ffffffffc02052c0:	f24a                	sd	s2,288(sp)
ffffffffc02052c2:	84ae                	mv	s1,a1
ffffffffc02052c4:	892a                	mv	s2,a0
ffffffffc02052c6:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02052c8:	4581                	li	a1,0
ffffffffc02052ca:	12000613          	li	a2,288
ffffffffc02052ce:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02052d0:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02052d2:	66d000ef          	jal	ra,ffffffffc020613e <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02052d6:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02052d8:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02052da:	100027f3          	csrr	a5,sstatus
ffffffffc02052de:	edd7f793          	andi	a5,a5,-291
ffffffffc02052e2:	1207e793          	ori	a5,a5,288
ffffffffc02052e6:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02052e8:	860a                	mv	a2,sp
ffffffffc02052ea:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02052ee:	00000797          	auipc	a5,0x0
ffffffffc02052f2:	9e678793          	addi	a5,a5,-1562 # ffffffffc0204cd4 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02052f6:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02052f8:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02052fa:	c1dff0ef          	jal	ra,ffffffffc0204f16 <do_fork>
}
ffffffffc02052fe:	70f2                	ld	ra,312(sp)
ffffffffc0205300:	7452                	ld	s0,304(sp)
ffffffffc0205302:	74b2                	ld	s1,296(sp)
ffffffffc0205304:	7912                	ld	s2,288(sp)
ffffffffc0205306:	6131                	addi	sp,sp,320
ffffffffc0205308:	8082                	ret

ffffffffc020530a <do_exit>:
do_exit(int error_code) {
ffffffffc020530a:	7179                	addi	sp,sp,-48
ffffffffc020530c:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc020530e:	000ad417          	auipc	s0,0xad
ffffffffc0205312:	63a40413          	addi	s0,s0,1594 # ffffffffc02b2948 <current>
ffffffffc0205316:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc0205318:	f406                	sd	ra,40(sp)
ffffffffc020531a:	ec26                	sd	s1,24(sp)
ffffffffc020531c:	e84a                	sd	s2,16(sp)
ffffffffc020531e:	e44e                	sd	s3,8(sp)
ffffffffc0205320:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205322:	000ad717          	auipc	a4,0xad
ffffffffc0205326:	62e73703          	ld	a4,1582(a4) # ffffffffc02b2950 <idleproc>
ffffffffc020532a:	0ce78c63          	beq	a5,a4,ffffffffc0205402 <do_exit+0xf8>
    if (current == initproc) {
ffffffffc020532e:	000ad497          	auipc	s1,0xad
ffffffffc0205332:	62a48493          	addi	s1,s1,1578 # ffffffffc02b2958 <initproc>
ffffffffc0205336:	6098                	ld	a4,0(s1)
ffffffffc0205338:	0ee78b63          	beq	a5,a4,ffffffffc020542e <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc020533c:	0287b983          	ld	s3,40(a5)
ffffffffc0205340:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc0205342:	02098663          	beqz	s3,ffffffffc020536e <do_exit+0x64>
ffffffffc0205346:	000ad797          	auipc	a5,0xad
ffffffffc020534a:	5a27b783          	ld	a5,1442(a5) # ffffffffc02b28e8 <boot_cr3>
ffffffffc020534e:	577d                	li	a4,-1
ffffffffc0205350:	177e                	slli	a4,a4,0x3f
ffffffffc0205352:	83b1                	srli	a5,a5,0xc
ffffffffc0205354:	8fd9                	or	a5,a5,a4
ffffffffc0205356:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020535a:	0309a783          	lw	a5,48(s3)
ffffffffc020535e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205362:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205366:	cb55                	beqz	a4,ffffffffc020541a <do_exit+0x110>
        current->mm = NULL;
ffffffffc0205368:	601c                	ld	a5,0(s0)
ffffffffc020536a:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020536e:	601c                	ld	a5,0(s0)
ffffffffc0205370:	470d                	li	a4,3
ffffffffc0205372:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205374:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205378:	100027f3          	csrr	a5,sstatus
ffffffffc020537c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020537e:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205380:	e3f9                	bnez	a5,ffffffffc0205446 <do_exit+0x13c>
        proc = current->parent;
ffffffffc0205382:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205384:	800007b7          	lui	a5,0x80000
ffffffffc0205388:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020538a:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020538c:	0ec52703          	lw	a4,236(a0)
ffffffffc0205390:	0af70f63          	beq	a4,a5,ffffffffc020544e <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc0205394:	6018                	ld	a4,0(s0)
ffffffffc0205396:	7b7c                	ld	a5,240(a4)
ffffffffc0205398:	c3a1                	beqz	a5,ffffffffc02053d8 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020539a:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020539e:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02053a0:	0985                	addi	s3,s3,1
ffffffffc02053a2:	a021                	j	ffffffffc02053aa <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc02053a4:	6018                	ld	a4,0(s0)
ffffffffc02053a6:	7b7c                	ld	a5,240(a4)
ffffffffc02053a8:	cb85                	beqz	a5,ffffffffc02053d8 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc02053aa:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fd0>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02053ae:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc02053b0:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02053b2:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02053b4:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02053b8:	10e7b023          	sd	a4,256(a5)
ffffffffc02053bc:	c311                	beqz	a4,ffffffffc02053c0 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc02053be:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02053c0:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02053c2:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02053c4:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02053c6:	fd271fe3          	bne	a4,s2,ffffffffc02053a4 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02053ca:	0ec52783          	lw	a5,236(a0)
ffffffffc02053ce:	fd379be3          	bne	a5,s3,ffffffffc02053a4 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02053d2:	305000ef          	jal	ra,ffffffffc0205ed6 <wakeup_proc>
ffffffffc02053d6:	b7f9                	j	ffffffffc02053a4 <do_exit+0x9a>
    if (flag) {
ffffffffc02053d8:	020a1263          	bnez	s4,ffffffffc02053fc <do_exit+0xf2>
    schedule();
ffffffffc02053dc:	37b000ef          	jal	ra,ffffffffc0205f56 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02053e0:	601c                	ld	a5,0(s0)
ffffffffc02053e2:	00003617          	auipc	a2,0x3
ffffffffc02053e6:	00660613          	addi	a2,a2,6 # ffffffffc02083e8 <default_pmm_manager+0x150>
ffffffffc02053ea:	20000593          	li	a1,512
ffffffffc02053ee:	43d4                	lw	a3,4(a5)
ffffffffc02053f0:	00003517          	auipc	a0,0x3
ffffffffc02053f4:	f9850513          	addi	a0,a0,-104 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc02053f8:	e11fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_enable();
ffffffffc02053fc:	a46fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0205400:	bff1                	j	ffffffffc02053dc <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc0205402:	00003617          	auipc	a2,0x3
ffffffffc0205406:	fc660613          	addi	a2,a2,-58 # ffffffffc02083c8 <default_pmm_manager+0x130>
ffffffffc020540a:	1d400593          	li	a1,468
ffffffffc020540e:	00003517          	auipc	a0,0x3
ffffffffc0205412:	f7a50513          	addi	a0,a0,-134 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205416:	df3fa0ef          	jal	ra,ffffffffc0200208 <__panic>
            exit_mmap(mm);
ffffffffc020541a:	854e                	mv	a0,s3
ffffffffc020541c:	8a9fd0ef          	jal	ra,ffffffffc0202cc4 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205420:	854e                	mv	a0,s3
ffffffffc0205422:	a13ff0ef          	jal	ra,ffffffffc0204e34 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205426:	854e                	mv	a0,s3
ffffffffc0205428:	f00fd0ef          	jal	ra,ffffffffc0202b28 <mm_destroy>
ffffffffc020542c:	bf35                	j	ffffffffc0205368 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc020542e:	00003617          	auipc	a2,0x3
ffffffffc0205432:	faa60613          	addi	a2,a2,-86 # ffffffffc02083d8 <default_pmm_manager+0x140>
ffffffffc0205436:	1d700593          	li	a1,471
ffffffffc020543a:	00003517          	auipc	a0,0x3
ffffffffc020543e:	f4e50513          	addi	a0,a0,-178 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205442:	dc7fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_disable();
ffffffffc0205446:	a02fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc020544a:	4a05                	li	s4,1
ffffffffc020544c:	bf1d                	j	ffffffffc0205382 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc020544e:	289000ef          	jal	ra,ffffffffc0205ed6 <wakeup_proc>
ffffffffc0205452:	b789                	j	ffffffffc0205394 <do_exit+0x8a>

ffffffffc0205454 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc0205454:	715d                	addi	sp,sp,-80
ffffffffc0205456:	f84a                	sd	s2,48(sp)
ffffffffc0205458:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc020545a:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc020545e:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc0205460:	fc26                	sd	s1,56(sp)
ffffffffc0205462:	f052                	sd	s4,32(sp)
ffffffffc0205464:	ec56                	sd	s5,24(sp)
ffffffffc0205466:	e85a                	sd	s6,16(sp)
ffffffffc0205468:	e45e                	sd	s7,8(sp)
ffffffffc020546a:	e486                	sd	ra,72(sp)
ffffffffc020546c:	e0a2                	sd	s0,64(sp)
ffffffffc020546e:	84aa                	mv	s1,a0
ffffffffc0205470:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0205472:	000adb97          	auipc	s7,0xad
ffffffffc0205476:	4d6b8b93          	addi	s7,s7,1238 # ffffffffc02b2948 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc020547a:	00050b1b          	sext.w	s6,a0
ffffffffc020547e:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0205482:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0205484:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc0205486:	ccbd                	beqz	s1,ffffffffc0205504 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205488:	0359e863          	bltu	s3,s5,ffffffffc02054b8 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020548c:	45a9                	li	a1,10
ffffffffc020548e:	855a                	mv	a0,s6
ffffffffc0205490:	0c6010ef          	jal	ra,ffffffffc0206556 <hash32>
ffffffffc0205494:	02051793          	slli	a5,a0,0x20
ffffffffc0205498:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020549c:	000a9797          	auipc	a5,0xa9
ffffffffc02054a0:	42478793          	addi	a5,a5,1060 # ffffffffc02ae8c0 <hash_list>
ffffffffc02054a4:	953e                	add	a0,a0,a5
ffffffffc02054a6:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc02054a8:	a029                	j	ffffffffc02054b2 <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc02054aa:	f2c42783          	lw	a5,-212(s0)
ffffffffc02054ae:	02978163          	beq	a5,s1,ffffffffc02054d0 <do_wait.part.0+0x7c>
ffffffffc02054b2:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc02054b4:	fe851be3          	bne	a0,s0,ffffffffc02054aa <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc02054b8:	5579                	li	a0,-2
}
ffffffffc02054ba:	60a6                	ld	ra,72(sp)
ffffffffc02054bc:	6406                	ld	s0,64(sp)
ffffffffc02054be:	74e2                	ld	s1,56(sp)
ffffffffc02054c0:	7942                	ld	s2,48(sp)
ffffffffc02054c2:	79a2                	ld	s3,40(sp)
ffffffffc02054c4:	7a02                	ld	s4,32(sp)
ffffffffc02054c6:	6ae2                	ld	s5,24(sp)
ffffffffc02054c8:	6b42                	ld	s6,16(sp)
ffffffffc02054ca:	6ba2                	ld	s7,8(sp)
ffffffffc02054cc:	6161                	addi	sp,sp,80
ffffffffc02054ce:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc02054d0:	000bb683          	ld	a3,0(s7)
ffffffffc02054d4:	f4843783          	ld	a5,-184(s0)
ffffffffc02054d8:	fed790e3          	bne	a5,a3,ffffffffc02054b8 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054dc:	f2842703          	lw	a4,-216(s0)
ffffffffc02054e0:	478d                	li	a5,3
ffffffffc02054e2:	0ef70b63          	beq	a4,a5,ffffffffc02055d8 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc02054e6:	4785                	li	a5,1
ffffffffc02054e8:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc02054ea:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc02054ee:	269000ef          	jal	ra,ffffffffc0205f56 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc02054f2:	000bb783          	ld	a5,0(s7)
ffffffffc02054f6:	0b07a783          	lw	a5,176(a5)
ffffffffc02054fa:	8b85                	andi	a5,a5,1
ffffffffc02054fc:	d7c9                	beqz	a5,ffffffffc0205486 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc02054fe:	555d                	li	a0,-9
ffffffffc0205500:	e0bff0ef          	jal	ra,ffffffffc020530a <do_exit>
        proc = current->cptr;
ffffffffc0205504:	000bb683          	ld	a3,0(s7)
ffffffffc0205508:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020550a:	d45d                	beqz	s0,ffffffffc02054b8 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020550c:	470d                	li	a4,3
ffffffffc020550e:	a021                	j	ffffffffc0205516 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205510:	10043403          	ld	s0,256(s0)
ffffffffc0205514:	d869                	beqz	s0,ffffffffc02054e6 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205516:	401c                	lw	a5,0(s0)
ffffffffc0205518:	fee79ce3          	bne	a5,a4,ffffffffc0205510 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc020551c:	000ad797          	auipc	a5,0xad
ffffffffc0205520:	4347b783          	ld	a5,1076(a5) # ffffffffc02b2950 <idleproc>
ffffffffc0205524:	0c878963          	beq	a5,s0,ffffffffc02055f6 <do_wait.part.0+0x1a2>
ffffffffc0205528:	000ad797          	auipc	a5,0xad
ffffffffc020552c:	4307b783          	ld	a5,1072(a5) # ffffffffc02b2958 <initproc>
ffffffffc0205530:	0cf40363          	beq	s0,a5,ffffffffc02055f6 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc0205534:	000a0663          	beqz	s4,ffffffffc0205540 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0205538:	0e842783          	lw	a5,232(s0)
ffffffffc020553c:	00fa2023          	sw	a5,0(s4)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205540:	100027f3          	csrr	a5,sstatus
ffffffffc0205544:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205546:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205548:	e7c1                	bnez	a5,ffffffffc02055d0 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020554a:	6c70                	ld	a2,216(s0)
ffffffffc020554c:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc020554e:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0205552:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205554:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205556:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205558:	6470                	ld	a2,200(s0)
ffffffffc020555a:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc020555c:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020555e:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc0205560:	c319                	beqz	a4,ffffffffc0205566 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0205562:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc0205564:	7c7c                	ld	a5,248(s0)
ffffffffc0205566:	c3b5                	beqz	a5,ffffffffc02055ca <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0205568:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc020556c:	000ad717          	auipc	a4,0xad
ffffffffc0205570:	3f470713          	addi	a4,a4,1012 # ffffffffc02b2960 <nr_process>
ffffffffc0205574:	431c                	lw	a5,0(a4)
ffffffffc0205576:	37fd                	addiw	a5,a5,-1
ffffffffc0205578:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc020557a:	e5a9                	bnez	a1,ffffffffc02055c4 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020557c:	6814                	ld	a3,16(s0)
ffffffffc020557e:	c02007b7          	lui	a5,0xc0200
ffffffffc0205582:	04f6ee63          	bltu	a3,a5,ffffffffc02055de <do_wait.part.0+0x18a>
ffffffffc0205586:	000ad797          	auipc	a5,0xad
ffffffffc020558a:	38a7b783          	ld	a5,906(a5) # ffffffffc02b2910 <va_pa_offset>
ffffffffc020558e:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205590:	82b1                	srli	a3,a3,0xc
ffffffffc0205592:	000ad797          	auipc	a5,0xad
ffffffffc0205596:	3667b783          	ld	a5,870(a5) # ffffffffc02b28f8 <npage>
ffffffffc020559a:	06f6fa63          	bgeu	a3,a5,ffffffffc020560e <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc020559e:	00003517          	auipc	a0,0x3
ffffffffc02055a2:	68253503          	ld	a0,1666(a0) # ffffffffc0208c20 <nbase>
ffffffffc02055a6:	8e89                	sub	a3,a3,a0
ffffffffc02055a8:	069a                	slli	a3,a3,0x6
ffffffffc02055aa:	000ad517          	auipc	a0,0xad
ffffffffc02055ae:	35653503          	ld	a0,854(a0) # ffffffffc02b2900 <pages>
ffffffffc02055b2:	9536                	add	a0,a0,a3
ffffffffc02055b4:	4589                	li	a1,2
ffffffffc02055b6:	937fb0ef          	jal	ra,ffffffffc0200eec <free_pages>
    kfree(proc);
ffffffffc02055ba:	8522                	mv	a0,s0
ffffffffc02055bc:	914fe0ef          	jal	ra,ffffffffc02036d0 <kfree>
    return 0;
ffffffffc02055c0:	4501                	li	a0,0
ffffffffc02055c2:	bde5                	j	ffffffffc02054ba <do_wait.part.0+0x66>
        intr_enable();
ffffffffc02055c4:	87efb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02055c8:	bf55                	j	ffffffffc020557c <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc02055ca:	701c                	ld	a5,32(s0)
ffffffffc02055cc:	fbf8                	sd	a4,240(a5)
ffffffffc02055ce:	bf79                	j	ffffffffc020556c <do_wait.part.0+0x118>
        intr_disable();
ffffffffc02055d0:	878fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02055d4:	4585                	li	a1,1
ffffffffc02055d6:	bf95                	j	ffffffffc020554a <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02055d8:	f2840413          	addi	s0,s0,-216
ffffffffc02055dc:	b781                	j	ffffffffc020551c <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc02055de:	00002617          	auipc	a2,0x2
ffffffffc02055e2:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0207048 <commands+0x830>
ffffffffc02055e6:	06e00593          	li	a1,110
ffffffffc02055ea:	00002517          	auipc	a0,0x2
ffffffffc02055ee:	94e50513          	addi	a0,a0,-1714 # ffffffffc0206f38 <commands+0x720>
ffffffffc02055f2:	c17fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc02055f6:	00003617          	auipc	a2,0x3
ffffffffc02055fa:	e1260613          	addi	a2,a2,-494 # ffffffffc0208408 <default_pmm_manager+0x170>
ffffffffc02055fe:	2f700593          	li	a1,759
ffffffffc0205602:	00003517          	auipc	a0,0x3
ffffffffc0205606:	d8650513          	addi	a0,a0,-634 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc020560a:	bfffa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020560e:	00002617          	auipc	a2,0x2
ffffffffc0205612:	90a60613          	addi	a2,a2,-1782 # ffffffffc0206f18 <commands+0x700>
ffffffffc0205616:	06200593          	li	a1,98
ffffffffc020561a:	00002517          	auipc	a0,0x2
ffffffffc020561e:	91e50513          	addi	a0,a0,-1762 # ffffffffc0206f38 <commands+0x720>
ffffffffc0205622:	be7fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205626 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205626:	1141                	addi	sp,sp,-16
ffffffffc0205628:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020562a:	903fb0ef          	jal	ra,ffffffffc0200f2c <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc020562e:	feffd0ef          	jal	ra,ffffffffc020361c <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205632:	4601                	li	a2,0
ffffffffc0205634:	4581                	li	a1,0
ffffffffc0205636:	fffff517          	auipc	a0,0xfffff
ffffffffc020563a:	78050513          	addi	a0,a0,1920 # ffffffffc0204db6 <user_main>
ffffffffc020563e:	c7dff0ef          	jal	ra,ffffffffc02052ba <kernel_thread>
    if (pid <= 0) {
ffffffffc0205642:	00a04563          	bgtz	a0,ffffffffc020564c <init_main+0x26>
ffffffffc0205646:	a071                	j	ffffffffc02056d2 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205648:	10f000ef          	jal	ra,ffffffffc0205f56 <schedule>
    if (code_store != NULL) {
ffffffffc020564c:	4581                	li	a1,0
ffffffffc020564e:	4501                	li	a0,0
ffffffffc0205650:	e05ff0ef          	jal	ra,ffffffffc0205454 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205654:	d975                	beqz	a0,ffffffffc0205648 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205656:	00003517          	auipc	a0,0x3
ffffffffc020565a:	df250513          	addi	a0,a0,-526 # ffffffffc0208448 <default_pmm_manager+0x1b0>
ffffffffc020565e:	a6ffa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205662:	000ad797          	auipc	a5,0xad
ffffffffc0205666:	2f67b783          	ld	a5,758(a5) # ffffffffc02b2958 <initproc>
ffffffffc020566a:	7bf8                	ld	a4,240(a5)
ffffffffc020566c:	e339                	bnez	a4,ffffffffc02056b2 <init_main+0x8c>
ffffffffc020566e:	7ff8                	ld	a4,248(a5)
ffffffffc0205670:	e329                	bnez	a4,ffffffffc02056b2 <init_main+0x8c>
ffffffffc0205672:	1007b703          	ld	a4,256(a5)
ffffffffc0205676:	ef15                	bnez	a4,ffffffffc02056b2 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0205678:	000ad697          	auipc	a3,0xad
ffffffffc020567c:	2e86a683          	lw	a3,744(a3) # ffffffffc02b2960 <nr_process>
ffffffffc0205680:	4709                	li	a4,2
ffffffffc0205682:	0ae69463          	bne	a3,a4,ffffffffc020572a <init_main+0x104>
    return listelm->next;
ffffffffc0205686:	000ad697          	auipc	a3,0xad
ffffffffc020568a:	23a68693          	addi	a3,a3,570 # ffffffffc02b28c0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020568e:	6698                	ld	a4,8(a3)
ffffffffc0205690:	0c878793          	addi	a5,a5,200
ffffffffc0205694:	06f71b63          	bne	a4,a5,ffffffffc020570a <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205698:	629c                	ld	a5,0(a3)
ffffffffc020569a:	04f71863          	bne	a4,a5,ffffffffc02056ea <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc020569e:	00003517          	auipc	a0,0x3
ffffffffc02056a2:	e9250513          	addi	a0,a0,-366 # ffffffffc0208530 <default_pmm_manager+0x298>
ffffffffc02056a6:	a27fa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc02056aa:	60a2                	ld	ra,8(sp)
ffffffffc02056ac:	4501                	li	a0,0
ffffffffc02056ae:	0141                	addi	sp,sp,16
ffffffffc02056b0:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02056b2:	00003697          	auipc	a3,0x3
ffffffffc02056b6:	dbe68693          	addi	a3,a3,-578 # ffffffffc0208470 <default_pmm_manager+0x1d8>
ffffffffc02056ba:	00001617          	auipc	a2,0x1
ffffffffc02056be:	56e60613          	addi	a2,a2,1390 # ffffffffc0206c28 <commands+0x410>
ffffffffc02056c2:	35c00593          	li	a1,860
ffffffffc02056c6:	00003517          	auipc	a0,0x3
ffffffffc02056ca:	cc250513          	addi	a0,a0,-830 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc02056ce:	b3bfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("create user_main failed.\n");
ffffffffc02056d2:	00003617          	auipc	a2,0x3
ffffffffc02056d6:	d5660613          	addi	a2,a2,-682 # ffffffffc0208428 <default_pmm_manager+0x190>
ffffffffc02056da:	35400593          	li	a1,852
ffffffffc02056de:	00003517          	auipc	a0,0x3
ffffffffc02056e2:	caa50513          	addi	a0,a0,-854 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc02056e6:	b23fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02056ea:	00003697          	auipc	a3,0x3
ffffffffc02056ee:	e1668693          	addi	a3,a3,-490 # ffffffffc0208500 <default_pmm_manager+0x268>
ffffffffc02056f2:	00001617          	auipc	a2,0x1
ffffffffc02056f6:	53660613          	addi	a2,a2,1334 # ffffffffc0206c28 <commands+0x410>
ffffffffc02056fa:	35f00593          	li	a1,863
ffffffffc02056fe:	00003517          	auipc	a0,0x3
ffffffffc0205702:	c8a50513          	addi	a0,a0,-886 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205706:	b03fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020570a:	00003697          	auipc	a3,0x3
ffffffffc020570e:	dc668693          	addi	a3,a3,-570 # ffffffffc02084d0 <default_pmm_manager+0x238>
ffffffffc0205712:	00001617          	auipc	a2,0x1
ffffffffc0205716:	51660613          	addi	a2,a2,1302 # ffffffffc0206c28 <commands+0x410>
ffffffffc020571a:	35e00593          	li	a1,862
ffffffffc020571e:	00003517          	auipc	a0,0x3
ffffffffc0205722:	c6a50513          	addi	a0,a0,-918 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205726:	ae3fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_process == 2);
ffffffffc020572a:	00003697          	auipc	a3,0x3
ffffffffc020572e:	d9668693          	addi	a3,a3,-618 # ffffffffc02084c0 <default_pmm_manager+0x228>
ffffffffc0205732:	00001617          	auipc	a2,0x1
ffffffffc0205736:	4f660613          	addi	a2,a2,1270 # ffffffffc0206c28 <commands+0x410>
ffffffffc020573a:	35d00593          	li	a1,861
ffffffffc020573e:	00003517          	auipc	a0,0x3
ffffffffc0205742:	c4a50513          	addi	a0,a0,-950 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205746:	ac3fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020574a <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020574a:	7171                	addi	sp,sp,-176
ffffffffc020574c:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020574e:	000add97          	auipc	s11,0xad
ffffffffc0205752:	1fad8d93          	addi	s11,s11,506 # ffffffffc02b2948 <current>
ffffffffc0205756:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020575a:	e54e                	sd	s3,136(sp)
ffffffffc020575c:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020575e:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205762:	e94a                	sd	s2,144(sp)
ffffffffc0205764:	f4de                	sd	s7,104(sp)
ffffffffc0205766:	892a                	mv	s2,a0
ffffffffc0205768:	8bb2                	mv	s7,a2
ffffffffc020576a:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020576c:	862e                	mv	a2,a1
ffffffffc020576e:	4681                	li	a3,0
ffffffffc0205770:	85aa                	mv	a1,a0
ffffffffc0205772:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205774:	f506                	sd	ra,168(sp)
ffffffffc0205776:	f122                	sd	s0,160(sp)
ffffffffc0205778:	e152                	sd	s4,128(sp)
ffffffffc020577a:	fcd6                	sd	s5,120(sp)
ffffffffc020577c:	f8da                	sd	s6,112(sp)
ffffffffc020577e:	f0e2                	sd	s8,96(sp)
ffffffffc0205780:	ece6                	sd	s9,88(sp)
ffffffffc0205782:	e8ea                	sd	s10,80(sp)
ffffffffc0205784:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205786:	bd5fd0ef          	jal	ra,ffffffffc020335a <user_mem_check>
ffffffffc020578a:	40050863          	beqz	a0,ffffffffc0205b9a <do_execve+0x450>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020578e:	4641                	li	a2,16
ffffffffc0205790:	4581                	li	a1,0
ffffffffc0205792:	1808                	addi	a0,sp,48
ffffffffc0205794:	1ab000ef          	jal	ra,ffffffffc020613e <memset>
    memcpy(local_name, name, len);
ffffffffc0205798:	47bd                	li	a5,15
ffffffffc020579a:	8626                	mv	a2,s1
ffffffffc020579c:	1e97e063          	bltu	a5,s1,ffffffffc020597c <do_execve+0x232>
ffffffffc02057a0:	85ca                	mv	a1,s2
ffffffffc02057a2:	1808                	addi	a0,sp,48
ffffffffc02057a4:	1ad000ef          	jal	ra,ffffffffc0206150 <memcpy>
    if (mm != NULL) {
ffffffffc02057a8:	1e098163          	beqz	s3,ffffffffc020598a <do_execve+0x240>
        cputs("mm != NULL");
ffffffffc02057ac:	00002517          	auipc	a0,0x2
ffffffffc02057b0:	06450513          	addi	a0,a0,100 # ffffffffc0207810 <commands+0xff8>
ffffffffc02057b4:	951fa0ef          	jal	ra,ffffffffc0200104 <cputs>
ffffffffc02057b8:	000ad797          	auipc	a5,0xad
ffffffffc02057bc:	1307b783          	ld	a5,304(a5) # ffffffffc02b28e8 <boot_cr3>
ffffffffc02057c0:	577d                	li	a4,-1
ffffffffc02057c2:	177e                	slli	a4,a4,0x3f
ffffffffc02057c4:	83b1                	srli	a5,a5,0xc
ffffffffc02057c6:	8fd9                	or	a5,a5,a4
ffffffffc02057c8:	18079073          	csrw	satp,a5
ffffffffc02057cc:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b90>
ffffffffc02057d0:	fff7871b          	addiw	a4,a5,-1
ffffffffc02057d4:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc02057d8:	2c070263          	beqz	a4,ffffffffc0205a9c <do_execve+0x352>
        current->mm = NULL;
ffffffffc02057dc:	000db783          	ld	a5,0(s11)
ffffffffc02057e0:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02057e4:	9befd0ef          	jal	ra,ffffffffc02029a2 <mm_create>
ffffffffc02057e8:	84aa                	mv	s1,a0
ffffffffc02057ea:	1c050b63          	beqz	a0,ffffffffc02059c0 <do_execve+0x276>
    if ((page = alloc_page()) == NULL) {
ffffffffc02057ee:	4505                	li	a0,1
ffffffffc02057f0:	e6afb0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02057f4:	3a050763          	beqz	a0,ffffffffc0205ba2 <do_execve+0x458>
    return page - pages + nbase;
ffffffffc02057f8:	000adc97          	auipc	s9,0xad
ffffffffc02057fc:	108c8c93          	addi	s9,s9,264 # ffffffffc02b2900 <pages>
ffffffffc0205800:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0205804:	000adc17          	auipc	s8,0xad
ffffffffc0205808:	0f4c0c13          	addi	s8,s8,244 # ffffffffc02b28f8 <npage>
    return page - pages + nbase;
ffffffffc020580c:	00003717          	auipc	a4,0x3
ffffffffc0205810:	41473703          	ld	a4,1044(a4) # ffffffffc0208c20 <nbase>
ffffffffc0205814:	40d506b3          	sub	a3,a0,a3
ffffffffc0205818:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020581a:	5afd                	li	s5,-1
ffffffffc020581c:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0205820:	96ba                	add	a3,a3,a4
ffffffffc0205822:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205824:	00cad713          	srli	a4,s5,0xc
ffffffffc0205828:	ec3a                	sd	a4,24(sp)
ffffffffc020582a:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020582c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020582e:	36f77e63          	bgeu	a4,a5,ffffffffc0205baa <do_execve+0x460>
ffffffffc0205832:	000adb17          	auipc	s6,0xad
ffffffffc0205836:	0deb0b13          	addi	s6,s6,222 # ffffffffc02b2910 <va_pa_offset>
ffffffffc020583a:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc020583e:	6605                	lui	a2,0x1
ffffffffc0205840:	000ad597          	auipc	a1,0xad
ffffffffc0205844:	0b05b583          	ld	a1,176(a1) # ffffffffc02b28f0 <boot_pgdir>
ffffffffc0205848:	9936                	add	s2,s2,a3
ffffffffc020584a:	854a                	mv	a0,s2
ffffffffc020584c:	105000ef          	jal	ra,ffffffffc0206150 <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205850:	7782                	ld	a5,32(sp)
ffffffffc0205852:	4398                	lw	a4,0(a5)
ffffffffc0205854:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0205858:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc020585c:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b944f>
ffffffffc0205860:	14f71663          	bne	a4,a5,ffffffffc02059ac <do_execve+0x262>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205864:	7682                	ld	a3,32(sp)
ffffffffc0205866:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020586a:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020586e:	00371793          	slli	a5,a4,0x3
ffffffffc0205872:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205874:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205876:	078e                	slli	a5,a5,0x3
ffffffffc0205878:	97ce                	add	a5,a5,s3
ffffffffc020587a:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc020587c:	00f9fc63          	bgeu	s3,a5,ffffffffc0205894 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205880:	0009a783          	lw	a5,0(s3)
ffffffffc0205884:	4705                	li	a4,1
ffffffffc0205886:	12e78f63          	beq	a5,a4,ffffffffc02059c4 <do_execve+0x27a>
    for (; ph < ph_end; ph ++) {
ffffffffc020588a:	77a2                	ld	a5,40(sp)
ffffffffc020588c:	03898993          	addi	s3,s3,56
ffffffffc0205890:	fef9e8e3          	bltu	s3,a5,ffffffffc0205880 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205894:	4701                	li	a4,0
ffffffffc0205896:	46ad                	li	a3,11
ffffffffc0205898:	00100637          	lui	a2,0x100
ffffffffc020589c:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02058a0:	8526                	mv	a0,s1
ffffffffc02058a2:	ad8fd0ef          	jal	ra,ffffffffc0202b7a <mm_map>
ffffffffc02058a6:	8a2a                	mv	s4,a0
ffffffffc02058a8:	1e051063          	bnez	a0,ffffffffc0205a88 <do_execve+0x33e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02058ac:	6c88                	ld	a0,24(s1)
ffffffffc02058ae:	467d                	li	a2,31
ffffffffc02058b0:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02058b4:	c13fc0ef          	jal	ra,ffffffffc02024c6 <pgdir_alloc_page>
ffffffffc02058b8:	38050163          	beqz	a0,ffffffffc0205c3a <do_execve+0x4f0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02058bc:	6c88                	ld	a0,24(s1)
ffffffffc02058be:	467d                	li	a2,31
ffffffffc02058c0:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02058c4:	c03fc0ef          	jal	ra,ffffffffc02024c6 <pgdir_alloc_page>
ffffffffc02058c8:	34050963          	beqz	a0,ffffffffc0205c1a <do_execve+0x4d0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02058cc:	6c88                	ld	a0,24(s1)
ffffffffc02058ce:	467d                	li	a2,31
ffffffffc02058d0:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02058d4:	bf3fc0ef          	jal	ra,ffffffffc02024c6 <pgdir_alloc_page>
ffffffffc02058d8:	32050163          	beqz	a0,ffffffffc0205bfa <do_execve+0x4b0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02058dc:	6c88                	ld	a0,24(s1)
ffffffffc02058de:	467d                	li	a2,31
ffffffffc02058e0:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02058e4:	be3fc0ef          	jal	ra,ffffffffc02024c6 <pgdir_alloc_page>
ffffffffc02058e8:	2e050963          	beqz	a0,ffffffffc0205bda <do_execve+0x490>
    mm->mm_count += 1;
ffffffffc02058ec:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc02058ee:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02058f2:	6c94                	ld	a3,24(s1)
ffffffffc02058f4:	2785                	addiw	a5,a5,1
ffffffffc02058f6:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc02058f8:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02058fa:	c02007b7          	lui	a5,0xc0200
ffffffffc02058fe:	2cf6e263          	bltu	a3,a5,ffffffffc0205bc2 <do_execve+0x478>
ffffffffc0205902:	000b3783          	ld	a5,0(s6)
ffffffffc0205906:	577d                	li	a4,-1
ffffffffc0205908:	177e                	slli	a4,a4,0x3f
ffffffffc020590a:	8e9d                	sub	a3,a3,a5
ffffffffc020590c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205910:	f654                	sd	a3,168(a2)
ffffffffc0205912:	8fd9                	or	a5,a5,a4
ffffffffc0205914:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205918:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc020591a:	4581                	li	a1,0
ffffffffc020591c:	12000613          	li	a2,288
ffffffffc0205920:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205922:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205926:	019000ef          	jal	ra,ffffffffc020613e <memset>
    tf->epc = elf->e_entry;//设置系统调用中断返回后执行的程序入口为elf头中设置的e_entry
ffffffffc020592a:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020592c:	000db483          	ld	s1,0(s11)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);//设置sstatus寄存器清零SSTATUS_SPP位和SSTATUS_SPIE位
ffffffffc0205930:	edf97913          	andi	s2,s2,-289
    tf->epc = elf->e_entry;//设置系统调用中断返回后执行的程序入口为elf头中设置的e_entry
ffffffffc0205934:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;//设置用户态的栈顶指针  
ffffffffc0205936:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205938:	0b448493          	addi	s1,s1,180
    tf->gpr.sp = USTACKTOP;//设置用户态的栈顶指针  
ffffffffc020593c:	07fe                	slli	a5,a5,0x1f
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020593e:	4641                	li	a2,16
ffffffffc0205940:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;//设置用户态的栈顶指针  
ffffffffc0205942:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;//设置系统调用中断返回后执行的程序入口为elf头中设置的e_entry
ffffffffc0205944:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);//设置sstatus寄存器清零SSTATUS_SPP位和SSTATUS_SPIE位
ffffffffc0205948:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020594c:	8526                	mv	a0,s1
ffffffffc020594e:	7f0000ef          	jal	ra,ffffffffc020613e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205952:	463d                	li	a2,15
ffffffffc0205954:	180c                	addi	a1,sp,48
ffffffffc0205956:	8526                	mv	a0,s1
ffffffffc0205958:	7f8000ef          	jal	ra,ffffffffc0206150 <memcpy>
}
ffffffffc020595c:	70aa                	ld	ra,168(sp)
ffffffffc020595e:	740a                	ld	s0,160(sp)
ffffffffc0205960:	64ea                	ld	s1,152(sp)
ffffffffc0205962:	694a                	ld	s2,144(sp)
ffffffffc0205964:	69aa                	ld	s3,136(sp)
ffffffffc0205966:	7ae6                	ld	s5,120(sp)
ffffffffc0205968:	7b46                	ld	s6,112(sp)
ffffffffc020596a:	7ba6                	ld	s7,104(sp)
ffffffffc020596c:	7c06                	ld	s8,96(sp)
ffffffffc020596e:	6ce6                	ld	s9,88(sp)
ffffffffc0205970:	6d46                	ld	s10,80(sp)
ffffffffc0205972:	6da6                	ld	s11,72(sp)
ffffffffc0205974:	8552                	mv	a0,s4
ffffffffc0205976:	6a0a                	ld	s4,128(sp)
ffffffffc0205978:	614d                	addi	sp,sp,176
ffffffffc020597a:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc020597c:	463d                	li	a2,15
ffffffffc020597e:	85ca                	mv	a1,s2
ffffffffc0205980:	1808                	addi	a0,sp,48
ffffffffc0205982:	7ce000ef          	jal	ra,ffffffffc0206150 <memcpy>
    if (mm != NULL) {
ffffffffc0205986:	e20993e3          	bnez	s3,ffffffffc02057ac <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc020598a:	000db783          	ld	a5,0(s11)
ffffffffc020598e:	779c                	ld	a5,40(a5)
ffffffffc0205990:	e4078ae3          	beqz	a5,ffffffffc02057e4 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205994:	00003617          	auipc	a2,0x3
ffffffffc0205998:	bbc60613          	addi	a2,a2,-1092 # ffffffffc0208550 <default_pmm_manager+0x2b8>
ffffffffc020599c:	20a00593          	li	a1,522
ffffffffc02059a0:	00003517          	auipc	a0,0x3
ffffffffc02059a4:	9e850513          	addi	a0,a0,-1560 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc02059a8:	861fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    put_pgdir(mm);
ffffffffc02059ac:	8526                	mv	a0,s1
ffffffffc02059ae:	c86ff0ef          	jal	ra,ffffffffc0204e34 <put_pgdir>
    mm_destroy(mm);
ffffffffc02059b2:	8526                	mv	a0,s1
ffffffffc02059b4:	974fd0ef          	jal	ra,ffffffffc0202b28 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02059b8:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc02059ba:	8552                	mv	a0,s4
ffffffffc02059bc:	94fff0ef          	jal	ra,ffffffffc020530a <do_exit>
    int ret = -E_NO_MEM;
ffffffffc02059c0:	5a71                	li	s4,-4
ffffffffc02059c2:	bfe5                	j	ffffffffc02059ba <do_execve+0x270>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc02059c4:	0289b603          	ld	a2,40(s3)
ffffffffc02059c8:	0209b783          	ld	a5,32(s3)
ffffffffc02059cc:	1cf66d63          	bltu	a2,a5,ffffffffc0205ba6 <do_execve+0x45c>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc02059d0:	0049a783          	lw	a5,4(s3)
ffffffffc02059d4:	0017f693          	andi	a3,a5,1
ffffffffc02059d8:	c291                	beqz	a3,ffffffffc02059dc <do_execve+0x292>
ffffffffc02059da:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02059dc:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02059e0:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02059e2:	e779                	bnez	a4,ffffffffc0205ab0 <do_execve+0x366>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc02059e4:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02059e6:	c781                	beqz	a5,ffffffffc02059ee <do_execve+0x2a4>
ffffffffc02059e8:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc02059ec:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc02059ee:	0026f793          	andi	a5,a3,2
ffffffffc02059f2:	e3f1                	bnez	a5,ffffffffc0205ab6 <do_execve+0x36c>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc02059f4:	0046f793          	andi	a5,a3,4
ffffffffc02059f8:	c399                	beqz	a5,ffffffffc02059fe <do_execve+0x2b4>
ffffffffc02059fa:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc02059fe:	0109b583          	ld	a1,16(s3)
ffffffffc0205a02:	4701                	li	a4,0
ffffffffc0205a04:	8526                	mv	a0,s1
ffffffffc0205a06:	974fd0ef          	jal	ra,ffffffffc0202b7a <mm_map>
ffffffffc0205a0a:	8a2a                	mv	s4,a0
ffffffffc0205a0c:	ed35                	bnez	a0,ffffffffc0205a88 <do_execve+0x33e>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a0e:	0109bb83          	ld	s7,16(s3)
ffffffffc0205a12:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a14:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a18:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a1c:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a20:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a22:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a24:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205a26:	054be963          	bltu	s7,s4,ffffffffc0205a78 <do_execve+0x32e>
ffffffffc0205a2a:	aa95                	j	ffffffffc0205b9e <do_execve+0x454>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205a2c:	6785                	lui	a5,0x1
ffffffffc0205a2e:	415b8533          	sub	a0,s7,s5
ffffffffc0205a32:	9abe                	add	s5,s5,a5
ffffffffc0205a34:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205a38:	015a7463          	bgeu	s4,s5,ffffffffc0205a40 <do_execve+0x2f6>
                size -= la - end;
ffffffffc0205a3c:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0205a40:	000cb683          	ld	a3,0(s9)
ffffffffc0205a44:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205a46:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205a4a:	40d406b3          	sub	a3,s0,a3
ffffffffc0205a4e:	8699                	srai	a3,a3,0x6
ffffffffc0205a50:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205a52:	67e2                	ld	a5,24(sp)
ffffffffc0205a54:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205a58:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a5a:	14b87863          	bgeu	a6,a1,ffffffffc0205baa <do_execve+0x460>
ffffffffc0205a5e:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205a62:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205a64:	9bb2                	add	s7,s7,a2
ffffffffc0205a66:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205a68:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205a6a:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205a6c:	6e4000ef          	jal	ra,ffffffffc0206150 <memcpy>
            start += size, from += size;
ffffffffc0205a70:	6622                	ld	a2,8(sp)
ffffffffc0205a72:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205a74:	054bf363          	bgeu	s7,s4,ffffffffc0205aba <do_execve+0x370>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205a78:	6c88                	ld	a0,24(s1)
ffffffffc0205a7a:	866a                	mv	a2,s10
ffffffffc0205a7c:	85d6                	mv	a1,s5
ffffffffc0205a7e:	a49fc0ef          	jal	ra,ffffffffc02024c6 <pgdir_alloc_page>
ffffffffc0205a82:	842a                	mv	s0,a0
ffffffffc0205a84:	f545                	bnez	a0,ffffffffc0205a2c <do_execve+0x2e2>
        ret = -E_NO_MEM;
ffffffffc0205a86:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205a88:	8526                	mv	a0,s1
ffffffffc0205a8a:	a3afd0ef          	jal	ra,ffffffffc0202cc4 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205a8e:	8526                	mv	a0,s1
ffffffffc0205a90:	ba4ff0ef          	jal	ra,ffffffffc0204e34 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205a94:	8526                	mv	a0,s1
ffffffffc0205a96:	892fd0ef          	jal	ra,ffffffffc0202b28 <mm_destroy>
    return ret;
ffffffffc0205a9a:	b705                	j	ffffffffc02059ba <do_execve+0x270>
            exit_mmap(mm);
ffffffffc0205a9c:	854e                	mv	a0,s3
ffffffffc0205a9e:	a26fd0ef          	jal	ra,ffffffffc0202cc4 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205aa2:	854e                	mv	a0,s3
ffffffffc0205aa4:	b90ff0ef          	jal	ra,ffffffffc0204e34 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205aa8:	854e                	mv	a0,s3
ffffffffc0205aaa:	87efd0ef          	jal	ra,ffffffffc0202b28 <mm_destroy>
ffffffffc0205aae:	b33d                	j	ffffffffc02057dc <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205ab0:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205ab4:	fb95                	bnez	a5,ffffffffc02059e8 <do_execve+0x29e>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205ab6:	4d5d                	li	s10,23
ffffffffc0205ab8:	bf35                	j	ffffffffc02059f4 <do_execve+0x2aa>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205aba:	0109b683          	ld	a3,16(s3)
ffffffffc0205abe:	0289b903          	ld	s2,40(s3)
ffffffffc0205ac2:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205ac4:	075bfd63          	bgeu	s7,s5,ffffffffc0205b3e <do_execve+0x3f4>
            if (start == end) {
ffffffffc0205ac8:	dd7901e3          	beq	s2,s7,ffffffffc020588a <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205acc:	6785                	lui	a5,0x1
ffffffffc0205ace:	00fb8533          	add	a0,s7,a5
ffffffffc0205ad2:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205ad6:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205ada:	0b597d63          	bgeu	s2,s5,ffffffffc0205b94 <do_execve+0x44a>
    return page - pages + nbase;
ffffffffc0205ade:	000cb683          	ld	a3,0(s9)
ffffffffc0205ae2:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205ae4:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205ae8:	40d406b3          	sub	a3,s0,a3
ffffffffc0205aec:	8699                	srai	a3,a3,0x6
ffffffffc0205aee:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205af0:	67e2                	ld	a5,24(sp)
ffffffffc0205af2:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205af6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205af8:	0ac5f963          	bgeu	a1,a2,ffffffffc0205baa <do_execve+0x460>
ffffffffc0205afc:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205b00:	8652                	mv	a2,s4
ffffffffc0205b02:	4581                	li	a1,0
ffffffffc0205b04:	96c2                	add	a3,a3,a6
ffffffffc0205b06:	9536                	add	a0,a0,a3
ffffffffc0205b08:	636000ef          	jal	ra,ffffffffc020613e <memset>
            start += size;
ffffffffc0205b0c:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205b10:	03597463          	bgeu	s2,s5,ffffffffc0205b38 <do_execve+0x3ee>
ffffffffc0205b14:	d6e90be3          	beq	s2,a4,ffffffffc020588a <do_execve+0x140>
ffffffffc0205b18:	00003697          	auipc	a3,0x3
ffffffffc0205b1c:	a6068693          	addi	a3,a3,-1440 # ffffffffc0208578 <default_pmm_manager+0x2e0>
ffffffffc0205b20:	00001617          	auipc	a2,0x1
ffffffffc0205b24:	10860613          	addi	a2,a2,264 # ffffffffc0206c28 <commands+0x410>
ffffffffc0205b28:	25f00593          	li	a1,607
ffffffffc0205b2c:	00003517          	auipc	a0,0x3
ffffffffc0205b30:	85c50513          	addi	a0,a0,-1956 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205b34:	ed4fa0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0205b38:	ff5710e3          	bne	a4,s5,ffffffffc0205b18 <do_execve+0x3ce>
ffffffffc0205b3c:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205b3e:	d52bf6e3          	bgeu	s7,s2,ffffffffc020588a <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b42:	6c88                	ld	a0,24(s1)
ffffffffc0205b44:	866a                	mv	a2,s10
ffffffffc0205b46:	85d6                	mv	a1,s5
ffffffffc0205b48:	97ffc0ef          	jal	ra,ffffffffc02024c6 <pgdir_alloc_page>
ffffffffc0205b4c:	842a                	mv	s0,a0
ffffffffc0205b4e:	dd05                	beqz	a0,ffffffffc0205a86 <do_execve+0x33c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205b50:	6785                	lui	a5,0x1
ffffffffc0205b52:	415b8533          	sub	a0,s7,s5
ffffffffc0205b56:	9abe                	add	s5,s5,a5
ffffffffc0205b58:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205b5c:	01597463          	bgeu	s2,s5,ffffffffc0205b64 <do_execve+0x41a>
                size -= la - end;
ffffffffc0205b60:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205b64:	000cb683          	ld	a3,0(s9)
ffffffffc0205b68:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205b6a:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205b6e:	40d406b3          	sub	a3,s0,a3
ffffffffc0205b72:	8699                	srai	a3,a3,0x6
ffffffffc0205b74:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205b76:	67e2                	ld	a5,24(sp)
ffffffffc0205b78:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b7c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b7e:	02b87663          	bgeu	a6,a1,ffffffffc0205baa <do_execve+0x460>
ffffffffc0205b82:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205b86:	4581                	li	a1,0
            start += size;
ffffffffc0205b88:	9bb2                	add	s7,s7,a2
ffffffffc0205b8a:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205b8c:	9536                	add	a0,a0,a3
ffffffffc0205b8e:	5b0000ef          	jal	ra,ffffffffc020613e <memset>
ffffffffc0205b92:	b775                	j	ffffffffc0205b3e <do_execve+0x3f4>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b94:	417a8a33          	sub	s4,s5,s7
ffffffffc0205b98:	b799                	j	ffffffffc0205ade <do_execve+0x394>
        return -E_INVAL;
ffffffffc0205b9a:	5a75                	li	s4,-3
ffffffffc0205b9c:	b3c1                	j	ffffffffc020595c <do_execve+0x212>
        while (start < end) {
ffffffffc0205b9e:	86de                	mv	a3,s7
ffffffffc0205ba0:	bf39                	j	ffffffffc0205abe <do_execve+0x374>
    int ret = -E_NO_MEM;
ffffffffc0205ba2:	5a71                	li	s4,-4
ffffffffc0205ba4:	bdc5                	j	ffffffffc0205a94 <do_execve+0x34a>
            ret = -E_INVAL_ELF;
ffffffffc0205ba6:	5a61                	li	s4,-8
ffffffffc0205ba8:	b5c5                	j	ffffffffc0205a88 <do_execve+0x33e>
ffffffffc0205baa:	00001617          	auipc	a2,0x1
ffffffffc0205bae:	3c660613          	addi	a2,a2,966 # ffffffffc0206f70 <commands+0x758>
ffffffffc0205bb2:	06900593          	li	a1,105
ffffffffc0205bb6:	00001517          	auipc	a0,0x1
ffffffffc0205bba:	38250513          	addi	a0,a0,898 # ffffffffc0206f38 <commands+0x720>
ffffffffc0205bbe:	e4afa0ef          	jal	ra,ffffffffc0200208 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205bc2:	00001617          	auipc	a2,0x1
ffffffffc0205bc6:	48660613          	addi	a2,a2,1158 # ffffffffc0207048 <commands+0x830>
ffffffffc0205bca:	27a00593          	li	a1,634
ffffffffc0205bce:	00002517          	auipc	a0,0x2
ffffffffc0205bd2:	7ba50513          	addi	a0,a0,1978 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205bd6:	e32fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205bda:	00003697          	auipc	a3,0x3
ffffffffc0205bde:	ab668693          	addi	a3,a3,-1354 # ffffffffc0208690 <default_pmm_manager+0x3f8>
ffffffffc0205be2:	00001617          	auipc	a2,0x1
ffffffffc0205be6:	04660613          	addi	a2,a2,70 # ffffffffc0206c28 <commands+0x410>
ffffffffc0205bea:	27500593          	li	a1,629
ffffffffc0205bee:	00002517          	auipc	a0,0x2
ffffffffc0205bf2:	79a50513          	addi	a0,a0,1946 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205bf6:	e12fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205bfa:	00003697          	auipc	a3,0x3
ffffffffc0205bfe:	a4e68693          	addi	a3,a3,-1458 # ffffffffc0208648 <default_pmm_manager+0x3b0>
ffffffffc0205c02:	00001617          	auipc	a2,0x1
ffffffffc0205c06:	02660613          	addi	a2,a2,38 # ffffffffc0206c28 <commands+0x410>
ffffffffc0205c0a:	27400593          	li	a1,628
ffffffffc0205c0e:	00002517          	auipc	a0,0x2
ffffffffc0205c12:	77a50513          	addi	a0,a0,1914 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205c16:	df2fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c1a:	00003697          	auipc	a3,0x3
ffffffffc0205c1e:	9e668693          	addi	a3,a3,-1562 # ffffffffc0208600 <default_pmm_manager+0x368>
ffffffffc0205c22:	00001617          	auipc	a2,0x1
ffffffffc0205c26:	00660613          	addi	a2,a2,6 # ffffffffc0206c28 <commands+0x410>
ffffffffc0205c2a:	27300593          	li	a1,627
ffffffffc0205c2e:	00002517          	auipc	a0,0x2
ffffffffc0205c32:	75a50513          	addi	a0,a0,1882 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205c36:	dd2fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205c3a:	00003697          	auipc	a3,0x3
ffffffffc0205c3e:	97e68693          	addi	a3,a3,-1666 # ffffffffc02085b8 <default_pmm_manager+0x320>
ffffffffc0205c42:	00001617          	auipc	a2,0x1
ffffffffc0205c46:	fe660613          	addi	a2,a2,-26 # ffffffffc0206c28 <commands+0x410>
ffffffffc0205c4a:	27200593          	li	a1,626
ffffffffc0205c4e:	00002517          	auipc	a0,0x2
ffffffffc0205c52:	73a50513          	addi	a0,a0,1850 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205c56:	db2fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205c5a <do_yield>:
    current->need_resched = 1;
ffffffffc0205c5a:	000ad797          	auipc	a5,0xad
ffffffffc0205c5e:	cee7b783          	ld	a5,-786(a5) # ffffffffc02b2948 <current>
ffffffffc0205c62:	4705                	li	a4,1
ffffffffc0205c64:	ef98                	sd	a4,24(a5)
}
ffffffffc0205c66:	4501                	li	a0,0
ffffffffc0205c68:	8082                	ret

ffffffffc0205c6a <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205c6a:	1101                	addi	sp,sp,-32
ffffffffc0205c6c:	e822                	sd	s0,16(sp)
ffffffffc0205c6e:	e426                	sd	s1,8(sp)
ffffffffc0205c70:	ec06                	sd	ra,24(sp)
ffffffffc0205c72:	842e                	mv	s0,a1
ffffffffc0205c74:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205c76:	c999                	beqz	a1,ffffffffc0205c8c <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205c78:	000ad797          	auipc	a5,0xad
ffffffffc0205c7c:	cd07b783          	ld	a5,-816(a5) # ffffffffc02b2948 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205c80:	7788                	ld	a0,40(a5)
ffffffffc0205c82:	4685                	li	a3,1
ffffffffc0205c84:	4611                	li	a2,4
ffffffffc0205c86:	ed4fd0ef          	jal	ra,ffffffffc020335a <user_mem_check>
ffffffffc0205c8a:	c909                	beqz	a0,ffffffffc0205c9c <do_wait+0x32>
ffffffffc0205c8c:	85a2                	mv	a1,s0
}
ffffffffc0205c8e:	6442                	ld	s0,16(sp)
ffffffffc0205c90:	60e2                	ld	ra,24(sp)
ffffffffc0205c92:	8526                	mv	a0,s1
ffffffffc0205c94:	64a2                	ld	s1,8(sp)
ffffffffc0205c96:	6105                	addi	sp,sp,32
ffffffffc0205c98:	fbcff06f          	j	ffffffffc0205454 <do_wait.part.0>
ffffffffc0205c9c:	60e2                	ld	ra,24(sp)
ffffffffc0205c9e:	6442                	ld	s0,16(sp)
ffffffffc0205ca0:	64a2                	ld	s1,8(sp)
ffffffffc0205ca2:	5575                	li	a0,-3
ffffffffc0205ca4:	6105                	addi	sp,sp,32
ffffffffc0205ca6:	8082                	ret

ffffffffc0205ca8 <do_kill>:
do_kill(int pid) {
ffffffffc0205ca8:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205caa:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205cac:	e406                	sd	ra,8(sp)
ffffffffc0205cae:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205cb0:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205cb4:	17f9                	addi	a5,a5,-2
ffffffffc0205cb6:	02e7e963          	bltu	a5,a4,ffffffffc0205ce8 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205cba:	842a                	mv	s0,a0
ffffffffc0205cbc:	45a9                	li	a1,10
ffffffffc0205cbe:	2501                	sext.w	a0,a0
ffffffffc0205cc0:	097000ef          	jal	ra,ffffffffc0206556 <hash32>
ffffffffc0205cc4:	02051793          	slli	a5,a0,0x20
ffffffffc0205cc8:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205ccc:	000a9797          	auipc	a5,0xa9
ffffffffc0205cd0:	bf478793          	addi	a5,a5,-1036 # ffffffffc02ae8c0 <hash_list>
ffffffffc0205cd4:	953e                	add	a0,a0,a5
ffffffffc0205cd6:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205cd8:	a029                	j	ffffffffc0205ce2 <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205cda:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205cde:	00870b63          	beq	a4,s0,ffffffffc0205cf4 <do_kill+0x4c>
ffffffffc0205ce2:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205ce4:	fef51be3          	bne	a0,a5,ffffffffc0205cda <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205ce8:	5475                	li	s0,-3
}
ffffffffc0205cea:	60a2                	ld	ra,8(sp)
ffffffffc0205cec:	8522                	mv	a0,s0
ffffffffc0205cee:	6402                	ld	s0,0(sp)
ffffffffc0205cf0:	0141                	addi	sp,sp,16
ffffffffc0205cf2:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205cf4:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205cf8:	00177693          	andi	a3,a4,1
ffffffffc0205cfc:	e295                	bnez	a3,ffffffffc0205d20 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205cfe:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205d00:	00176713          	ori	a4,a4,1
ffffffffc0205d04:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205d08:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d0a:	fe06d0e3          	bgez	a3,ffffffffc0205cea <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205d0e:	f2878513          	addi	a0,a5,-216
ffffffffc0205d12:	1c4000ef          	jal	ra,ffffffffc0205ed6 <wakeup_proc>
}
ffffffffc0205d16:	60a2                	ld	ra,8(sp)
ffffffffc0205d18:	8522                	mv	a0,s0
ffffffffc0205d1a:	6402                	ld	s0,0(sp)
ffffffffc0205d1c:	0141                	addi	sp,sp,16
ffffffffc0205d1e:	8082                	ret
        return -E_KILLED;
ffffffffc0205d20:	545d                	li	s0,-9
ffffffffc0205d22:	b7e1                	j	ffffffffc0205cea <do_kill+0x42>

ffffffffc0205d24 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205d24:	1101                	addi	sp,sp,-32
ffffffffc0205d26:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205d28:	000ad797          	auipc	a5,0xad
ffffffffc0205d2c:	b9878793          	addi	a5,a5,-1128 # ffffffffc02b28c0 <proc_list>
ffffffffc0205d30:	ec06                	sd	ra,24(sp)
ffffffffc0205d32:	e822                	sd	s0,16(sp)
ffffffffc0205d34:	e04a                	sd	s2,0(sp)
ffffffffc0205d36:	000a9497          	auipc	s1,0xa9
ffffffffc0205d3a:	b8a48493          	addi	s1,s1,-1142 # ffffffffc02ae8c0 <hash_list>
ffffffffc0205d3e:	e79c                	sd	a5,8(a5)
ffffffffc0205d40:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205d42:	000ad717          	auipc	a4,0xad
ffffffffc0205d46:	b7e70713          	addi	a4,a4,-1154 # ffffffffc02b28c0 <proc_list>
ffffffffc0205d4a:	87a6                	mv	a5,s1
ffffffffc0205d4c:	e79c                	sd	a5,8(a5)
ffffffffc0205d4e:	e39c                	sd	a5,0(a5)
ffffffffc0205d50:	07c1                	addi	a5,a5,16
ffffffffc0205d52:	fef71de3          	bne	a4,a5,ffffffffc0205d4c <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205d56:	ff1fe0ef          	jal	ra,ffffffffc0204d46 <alloc_proc>
ffffffffc0205d5a:	000ad917          	auipc	s2,0xad
ffffffffc0205d5e:	bf690913          	addi	s2,s2,-1034 # ffffffffc02b2950 <idleproc>
ffffffffc0205d62:	00a93023          	sd	a0,0(s2)
ffffffffc0205d66:	0e050f63          	beqz	a0,ffffffffc0205e64 <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205d6a:	4789                	li	a5,2
ffffffffc0205d6c:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205d6e:	00003797          	auipc	a5,0x3
ffffffffc0205d72:	29278793          	addi	a5,a5,658 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205d76:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205d7a:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205d7c:	4785                	li	a5,1
ffffffffc0205d7e:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205d80:	4641                	li	a2,16
ffffffffc0205d82:	4581                	li	a1,0
ffffffffc0205d84:	8522                	mv	a0,s0
ffffffffc0205d86:	3b8000ef          	jal	ra,ffffffffc020613e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205d8a:	463d                	li	a2,15
ffffffffc0205d8c:	00003597          	auipc	a1,0x3
ffffffffc0205d90:	96458593          	addi	a1,a1,-1692 # ffffffffc02086f0 <default_pmm_manager+0x458>
ffffffffc0205d94:	8522                	mv	a0,s0
ffffffffc0205d96:	3ba000ef          	jal	ra,ffffffffc0206150 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205d9a:	000ad717          	auipc	a4,0xad
ffffffffc0205d9e:	bc670713          	addi	a4,a4,-1082 # ffffffffc02b2960 <nr_process>
ffffffffc0205da2:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205da4:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205da8:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205daa:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205dac:	4581                	li	a1,0
ffffffffc0205dae:	00000517          	auipc	a0,0x0
ffffffffc0205db2:	87850513          	addi	a0,a0,-1928 # ffffffffc0205626 <init_main>
    nr_process ++;
ffffffffc0205db6:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205db8:	000ad797          	auipc	a5,0xad
ffffffffc0205dbc:	b8d7b823          	sd	a3,-1136(a5) # ffffffffc02b2948 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205dc0:	cfaff0ef          	jal	ra,ffffffffc02052ba <kernel_thread>
ffffffffc0205dc4:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205dc6:	08a05363          	blez	a0,ffffffffc0205e4c <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205dca:	6789                	lui	a5,0x2
ffffffffc0205dcc:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205dd0:	17f9                	addi	a5,a5,-2
ffffffffc0205dd2:	2501                	sext.w	a0,a0
ffffffffc0205dd4:	02e7e363          	bltu	a5,a4,ffffffffc0205dfa <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205dd8:	45a9                	li	a1,10
ffffffffc0205dda:	77c000ef          	jal	ra,ffffffffc0206556 <hash32>
ffffffffc0205dde:	02051793          	slli	a5,a0,0x20
ffffffffc0205de2:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205de6:	96a6                	add	a3,a3,s1
ffffffffc0205de8:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205dea:	a029                	j	ffffffffc0205df4 <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205dec:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c94>
ffffffffc0205df0:	04870b63          	beq	a4,s0,ffffffffc0205e46 <proc_init+0x122>
    return listelm->next;
ffffffffc0205df4:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205df6:	fef69be3          	bne	a3,a5,ffffffffc0205dec <proc_init+0xc8>
    return NULL;
ffffffffc0205dfa:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205dfc:	0b478493          	addi	s1,a5,180
ffffffffc0205e00:	4641                	li	a2,16
ffffffffc0205e02:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e04:	000ad417          	auipc	s0,0xad
ffffffffc0205e08:	b5440413          	addi	s0,s0,-1196 # ffffffffc02b2958 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e0c:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205e0e:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e10:	32e000ef          	jal	ra,ffffffffc020613e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205e14:	463d                	li	a2,15
ffffffffc0205e16:	00003597          	auipc	a1,0x3
ffffffffc0205e1a:	90258593          	addi	a1,a1,-1790 # ffffffffc0208718 <default_pmm_manager+0x480>
ffffffffc0205e1e:	8526                	mv	a0,s1
ffffffffc0205e20:	330000ef          	jal	ra,ffffffffc0206150 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e24:	00093783          	ld	a5,0(s2)
ffffffffc0205e28:	cbb5                	beqz	a5,ffffffffc0205e9c <proc_init+0x178>
ffffffffc0205e2a:	43dc                	lw	a5,4(a5)
ffffffffc0205e2c:	eba5                	bnez	a5,ffffffffc0205e9c <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e2e:	601c                	ld	a5,0(s0)
ffffffffc0205e30:	c7b1                	beqz	a5,ffffffffc0205e7c <proc_init+0x158>
ffffffffc0205e32:	43d8                	lw	a4,4(a5)
ffffffffc0205e34:	4785                	li	a5,1
ffffffffc0205e36:	04f71363          	bne	a4,a5,ffffffffc0205e7c <proc_init+0x158>
}
ffffffffc0205e3a:	60e2                	ld	ra,24(sp)
ffffffffc0205e3c:	6442                	ld	s0,16(sp)
ffffffffc0205e3e:	64a2                	ld	s1,8(sp)
ffffffffc0205e40:	6902                	ld	s2,0(sp)
ffffffffc0205e42:	6105                	addi	sp,sp,32
ffffffffc0205e44:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205e46:	f2878793          	addi	a5,a5,-216
ffffffffc0205e4a:	bf4d                	j	ffffffffc0205dfc <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205e4c:	00003617          	auipc	a2,0x3
ffffffffc0205e50:	8ac60613          	addi	a2,a2,-1876 # ffffffffc02086f8 <default_pmm_manager+0x460>
ffffffffc0205e54:	37f00593          	li	a1,895
ffffffffc0205e58:	00002517          	auipc	a0,0x2
ffffffffc0205e5c:	53050513          	addi	a0,a0,1328 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205e60:	ba8fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205e64:	00003617          	auipc	a2,0x3
ffffffffc0205e68:	87460613          	addi	a2,a2,-1932 # ffffffffc02086d8 <default_pmm_manager+0x440>
ffffffffc0205e6c:	37100593          	li	a1,881
ffffffffc0205e70:	00002517          	auipc	a0,0x2
ffffffffc0205e74:	51850513          	addi	a0,a0,1304 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205e78:	b90fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e7c:	00003697          	auipc	a3,0x3
ffffffffc0205e80:	8cc68693          	addi	a3,a3,-1844 # ffffffffc0208748 <default_pmm_manager+0x4b0>
ffffffffc0205e84:	00001617          	auipc	a2,0x1
ffffffffc0205e88:	da460613          	addi	a2,a2,-604 # ffffffffc0206c28 <commands+0x410>
ffffffffc0205e8c:	38600593          	li	a1,902
ffffffffc0205e90:	00002517          	auipc	a0,0x2
ffffffffc0205e94:	4f850513          	addi	a0,a0,1272 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205e98:	b70fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e9c:	00003697          	auipc	a3,0x3
ffffffffc0205ea0:	88468693          	addi	a3,a3,-1916 # ffffffffc0208720 <default_pmm_manager+0x488>
ffffffffc0205ea4:	00001617          	auipc	a2,0x1
ffffffffc0205ea8:	d8460613          	addi	a2,a2,-636 # ffffffffc0206c28 <commands+0x410>
ffffffffc0205eac:	38500593          	li	a1,901
ffffffffc0205eb0:	00002517          	auipc	a0,0x2
ffffffffc0205eb4:	4d850513          	addi	a0,a0,1240 # ffffffffc0208388 <default_pmm_manager+0xf0>
ffffffffc0205eb8:	b50fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205ebc <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205ebc:	1141                	addi	sp,sp,-16
ffffffffc0205ebe:	e022                	sd	s0,0(sp)
ffffffffc0205ec0:	e406                	sd	ra,8(sp)
ffffffffc0205ec2:	000ad417          	auipc	s0,0xad
ffffffffc0205ec6:	a8640413          	addi	s0,s0,-1402 # ffffffffc02b2948 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205eca:	6018                	ld	a4,0(s0)
ffffffffc0205ecc:	6f1c                	ld	a5,24(a4)
ffffffffc0205ece:	dffd                	beqz	a5,ffffffffc0205ecc <cpu_idle+0x10>
            schedule();
ffffffffc0205ed0:	086000ef          	jal	ra,ffffffffc0205f56 <schedule>
ffffffffc0205ed4:	bfdd                	j	ffffffffc0205eca <cpu_idle+0xe>

ffffffffc0205ed6 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205ed6:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205ed8:	1101                	addi	sp,sp,-32
ffffffffc0205eda:	ec06                	sd	ra,24(sp)
ffffffffc0205edc:	e822                	sd	s0,16(sp)
ffffffffc0205ede:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205ee0:	478d                	li	a5,3
ffffffffc0205ee2:	04f70b63          	beq	a4,a5,ffffffffc0205f38 <wakeup_proc+0x62>
ffffffffc0205ee6:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205ee8:	100027f3          	csrr	a5,sstatus
ffffffffc0205eec:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205eee:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205ef0:	ef9d                	bnez	a5,ffffffffc0205f2e <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205ef2:	4789                	li	a5,2
ffffffffc0205ef4:	02f70163          	beq	a4,a5,ffffffffc0205f16 <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc0205ef8:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205efa:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc0205efe:	e491                	bnez	s1,ffffffffc0205f0a <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f00:	60e2                	ld	ra,24(sp)
ffffffffc0205f02:	6442                	ld	s0,16(sp)
ffffffffc0205f04:	64a2                	ld	s1,8(sp)
ffffffffc0205f06:	6105                	addi	sp,sp,32
ffffffffc0205f08:	8082                	ret
ffffffffc0205f0a:	6442                	ld	s0,16(sp)
ffffffffc0205f0c:	60e2                	ld	ra,24(sp)
ffffffffc0205f0e:	64a2                	ld	s1,8(sp)
ffffffffc0205f10:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205f12:	f30fa06f          	j	ffffffffc0200642 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205f16:	00003617          	auipc	a2,0x3
ffffffffc0205f1a:	89260613          	addi	a2,a2,-1902 # ffffffffc02087a8 <default_pmm_manager+0x510>
ffffffffc0205f1e:	45c9                	li	a1,18
ffffffffc0205f20:	00003517          	auipc	a0,0x3
ffffffffc0205f24:	87050513          	addi	a0,a0,-1936 # ffffffffc0208790 <default_pmm_manager+0x4f8>
ffffffffc0205f28:	b48fa0ef          	jal	ra,ffffffffc0200270 <__warn>
ffffffffc0205f2c:	bfc9                	j	ffffffffc0205efe <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205f2e:	f1afa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f32:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205f34:	4485                	li	s1,1
ffffffffc0205f36:	bf75                	j	ffffffffc0205ef2 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f38:	00003697          	auipc	a3,0x3
ffffffffc0205f3c:	83868693          	addi	a3,a3,-1992 # ffffffffc0208770 <default_pmm_manager+0x4d8>
ffffffffc0205f40:	00001617          	auipc	a2,0x1
ffffffffc0205f44:	ce860613          	addi	a2,a2,-792 # ffffffffc0206c28 <commands+0x410>
ffffffffc0205f48:	45a5                	li	a1,9
ffffffffc0205f4a:	00003517          	auipc	a0,0x3
ffffffffc0205f4e:	84650513          	addi	a0,a0,-1978 # ffffffffc0208790 <default_pmm_manager+0x4f8>
ffffffffc0205f52:	ab6fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205f56 <schedule>:

void
schedule(void) {
ffffffffc0205f56:	1141                	addi	sp,sp,-16
ffffffffc0205f58:	e406                	sd	ra,8(sp)
ffffffffc0205f5a:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f5c:	100027f3          	csrr	a5,sstatus
ffffffffc0205f60:	8b89                	andi	a5,a5,2
ffffffffc0205f62:	4401                	li	s0,0
ffffffffc0205f64:	efbd                	bnez	a5,ffffffffc0205fe2 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205f66:	000ad897          	auipc	a7,0xad
ffffffffc0205f6a:	9e28b883          	ld	a7,-1566(a7) # ffffffffc02b2948 <current>
ffffffffc0205f6e:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205f72:	000ad517          	auipc	a0,0xad
ffffffffc0205f76:	9de53503          	ld	a0,-1570(a0) # ffffffffc02b2950 <idleproc>
ffffffffc0205f7a:	04a88e63          	beq	a7,a0,ffffffffc0205fd6 <schedule+0x80>
ffffffffc0205f7e:	0c888693          	addi	a3,a7,200
ffffffffc0205f82:	000ad617          	auipc	a2,0xad
ffffffffc0205f86:	93e60613          	addi	a2,a2,-1730 # ffffffffc02b28c0 <proc_list>
        le = last;
ffffffffc0205f8a:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205f8c:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205f8e:	4809                	li	a6,2
ffffffffc0205f90:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205f92:	00c78863          	beq	a5,a2,ffffffffc0205fa2 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205f96:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205f9a:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205f9e:	03070163          	beq	a4,a6,ffffffffc0205fc0 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205fa2:	fef697e3          	bne	a3,a5,ffffffffc0205f90 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205fa6:	ed89                	bnez	a1,ffffffffc0205fc0 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205fa8:	451c                	lw	a5,8(a0)
ffffffffc0205faa:	2785                	addiw	a5,a5,1
ffffffffc0205fac:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205fae:	00a88463          	beq	a7,a0,ffffffffc0205fb6 <schedule+0x60>
            proc_run(next);
ffffffffc0205fb2:	ef9fe0ef          	jal	ra,ffffffffc0204eaa <proc_run>
    if (flag) {
ffffffffc0205fb6:	e819                	bnez	s0,ffffffffc0205fcc <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205fb8:	60a2                	ld	ra,8(sp)
ffffffffc0205fba:	6402                	ld	s0,0(sp)
ffffffffc0205fbc:	0141                	addi	sp,sp,16
ffffffffc0205fbe:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205fc0:	4198                	lw	a4,0(a1)
ffffffffc0205fc2:	4789                	li	a5,2
ffffffffc0205fc4:	fef712e3          	bne	a4,a5,ffffffffc0205fa8 <schedule+0x52>
ffffffffc0205fc8:	852e                	mv	a0,a1
ffffffffc0205fca:	bff9                	j	ffffffffc0205fa8 <schedule+0x52>
}
ffffffffc0205fcc:	6402                	ld	s0,0(sp)
ffffffffc0205fce:	60a2                	ld	ra,8(sp)
ffffffffc0205fd0:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205fd2:	e70fa06f          	j	ffffffffc0200642 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fd6:	000ad617          	auipc	a2,0xad
ffffffffc0205fda:	8ea60613          	addi	a2,a2,-1814 # ffffffffc02b28c0 <proc_list>
ffffffffc0205fde:	86b2                	mv	a3,a2
ffffffffc0205fe0:	b76d                	j	ffffffffc0205f8a <schedule+0x34>
        intr_disable();
ffffffffc0205fe2:	e66fa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0205fe6:	4405                	li	s0,1
ffffffffc0205fe8:	bfbd                	j	ffffffffc0205f66 <schedule+0x10>

ffffffffc0205fea <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205fea:	000ad797          	auipc	a5,0xad
ffffffffc0205fee:	95e7b783          	ld	a5,-1698(a5) # ffffffffc02b2948 <current>
}
ffffffffc0205ff2:	43c8                	lw	a0,4(a5)
ffffffffc0205ff4:	8082                	ret

ffffffffc0205ff6 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205ff6:	4501                	li	a0,0
ffffffffc0205ff8:	8082                	ret

ffffffffc0205ffa <sys_putc>:
    cputchar(c);
ffffffffc0205ffa:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205ffc:	1141                	addi	sp,sp,-16
ffffffffc0205ffe:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0206000:	902fa0ef          	jal	ra,ffffffffc0200102 <cputchar>
}
ffffffffc0206004:	60a2                	ld	ra,8(sp)
ffffffffc0206006:	4501                	li	a0,0
ffffffffc0206008:	0141                	addi	sp,sp,16
ffffffffc020600a:	8082                	ret

ffffffffc020600c <sys_kill>:
    return do_kill(pid);
ffffffffc020600c:	4108                	lw	a0,0(a0)
ffffffffc020600e:	c9bff06f          	j	ffffffffc0205ca8 <do_kill>

ffffffffc0206012 <sys_yield>:
    return do_yield();
ffffffffc0206012:	c49ff06f          	j	ffffffffc0205c5a <do_yield>

ffffffffc0206016 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206016:	6d14                	ld	a3,24(a0)
ffffffffc0206018:	6910                	ld	a2,16(a0)
ffffffffc020601a:	650c                	ld	a1,8(a0)
ffffffffc020601c:	6108                	ld	a0,0(a0)
ffffffffc020601e:	f2cff06f          	j	ffffffffc020574a <do_execve>

ffffffffc0206022 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0206022:	650c                	ld	a1,8(a0)
ffffffffc0206024:	4108                	lw	a0,0(a0)
ffffffffc0206026:	c45ff06f          	j	ffffffffc0205c6a <do_wait>

ffffffffc020602a <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020602a:	000ad797          	auipc	a5,0xad
ffffffffc020602e:	91e7b783          	ld	a5,-1762(a5) # ffffffffc02b2948 <current>
ffffffffc0206032:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206034:	4501                	li	a0,0
ffffffffc0206036:	6a0c                	ld	a1,16(a2)
ffffffffc0206038:	edffe06f          	j	ffffffffc0204f16 <do_fork>

ffffffffc020603c <sys_exit>:
    return do_exit(error_code);
ffffffffc020603c:	4108                	lw	a0,0(a0)
ffffffffc020603e:	accff06f          	j	ffffffffc020530a <do_exit>

ffffffffc0206042 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0206042:	715d                	addi	sp,sp,-80
ffffffffc0206044:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206046:	000ad497          	auipc	s1,0xad
ffffffffc020604a:	90248493          	addi	s1,s1,-1790 # ffffffffc02b2948 <current>
ffffffffc020604e:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0206050:	e0a2                	sd	s0,64(sp)
ffffffffc0206052:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206054:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0206056:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206058:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc020605a:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020605e:	0327ee63          	bltu	a5,s2,ffffffffc020609a <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0206062:	00391713          	slli	a4,s2,0x3
ffffffffc0206066:	00002797          	auipc	a5,0x2
ffffffffc020606a:	7aa78793          	addi	a5,a5,1962 # ffffffffc0208810 <syscalls>
ffffffffc020606e:	97ba                	add	a5,a5,a4
ffffffffc0206070:	639c                	ld	a5,0(a5)
ffffffffc0206072:	c785                	beqz	a5,ffffffffc020609a <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0206074:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0206076:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0206078:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc020607a:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc020607c:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc020607e:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0206080:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0206082:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0206084:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0206086:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206088:	0028                	addi	a0,sp,8
ffffffffc020608a:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc020608c:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020608e:	e828                	sd	a0,80(s0)
}
ffffffffc0206090:	6406                	ld	s0,64(sp)
ffffffffc0206092:	74e2                	ld	s1,56(sp)
ffffffffc0206094:	7942                	ld	s2,48(sp)
ffffffffc0206096:	6161                	addi	sp,sp,80
ffffffffc0206098:	8082                	ret
    print_trapframe(tf);
ffffffffc020609a:	8522                	mv	a0,s0
ffffffffc020609c:	f9afa0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02060a0:	609c                	ld	a5,0(s1)
ffffffffc02060a2:	86ca                	mv	a3,s2
ffffffffc02060a4:	00002617          	auipc	a2,0x2
ffffffffc02060a8:	72460613          	addi	a2,a2,1828 # ffffffffc02087c8 <default_pmm_manager+0x530>
ffffffffc02060ac:	43d8                	lw	a4,4(a5)
ffffffffc02060ae:	06200593          	li	a1,98
ffffffffc02060b2:	0b478793          	addi	a5,a5,180
ffffffffc02060b6:	00002517          	auipc	a0,0x2
ffffffffc02060ba:	74250513          	addi	a0,a0,1858 # ffffffffc02087f8 <default_pmm_manager+0x560>
ffffffffc02060be:	94afa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02060c2 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02060c2:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02060c6:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02060c8:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02060ca:	cb81                	beqz	a5,ffffffffc02060da <strlen+0x18>
        cnt ++;
ffffffffc02060cc:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02060ce:	00a707b3          	add	a5,a4,a0
ffffffffc02060d2:	0007c783          	lbu	a5,0(a5)
ffffffffc02060d6:	fbfd                	bnez	a5,ffffffffc02060cc <strlen+0xa>
ffffffffc02060d8:	8082                	ret
    }
    return cnt;
}
ffffffffc02060da:	8082                	ret

ffffffffc02060dc <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02060dc:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02060de:	e589                	bnez	a1,ffffffffc02060e8 <strnlen+0xc>
ffffffffc02060e0:	a811                	j	ffffffffc02060f4 <strnlen+0x18>
        cnt ++;
ffffffffc02060e2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02060e4:	00f58863          	beq	a1,a5,ffffffffc02060f4 <strnlen+0x18>
ffffffffc02060e8:	00f50733          	add	a4,a0,a5
ffffffffc02060ec:	00074703          	lbu	a4,0(a4)
ffffffffc02060f0:	fb6d                	bnez	a4,ffffffffc02060e2 <strnlen+0x6>
ffffffffc02060f2:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02060f4:	852e                	mv	a0,a1
ffffffffc02060f6:	8082                	ret

ffffffffc02060f8 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02060f8:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02060fa:	0005c703          	lbu	a4,0(a1)
ffffffffc02060fe:	0785                	addi	a5,a5,1
ffffffffc0206100:	0585                	addi	a1,a1,1
ffffffffc0206102:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206106:	fb75                	bnez	a4,ffffffffc02060fa <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206108:	8082                	ret

ffffffffc020610a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020610a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020610e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206112:	cb89                	beqz	a5,ffffffffc0206124 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0206114:	0505                	addi	a0,a0,1
ffffffffc0206116:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206118:	fee789e3          	beq	a5,a4,ffffffffc020610a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020611c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206120:	9d19                	subw	a0,a0,a4
ffffffffc0206122:	8082                	ret
ffffffffc0206124:	4501                	li	a0,0
ffffffffc0206126:	bfed                	j	ffffffffc0206120 <strcmp+0x16>

ffffffffc0206128 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206128:	00054783          	lbu	a5,0(a0)
ffffffffc020612c:	c799                	beqz	a5,ffffffffc020613a <strchr+0x12>
        if (*s == c) {
ffffffffc020612e:	00f58763          	beq	a1,a5,ffffffffc020613c <strchr+0x14>
    while (*s != '\0') {
ffffffffc0206132:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0206136:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206138:	fbfd                	bnez	a5,ffffffffc020612e <strchr+0x6>
    }
    return NULL;
ffffffffc020613a:	4501                	li	a0,0
}
ffffffffc020613c:	8082                	ret

ffffffffc020613e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020613e:	ca01                	beqz	a2,ffffffffc020614e <memset+0x10>
ffffffffc0206140:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206142:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0206144:	0785                	addi	a5,a5,1
ffffffffc0206146:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020614a:	fec79de3          	bne	a5,a2,ffffffffc0206144 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020614e:	8082                	ret

ffffffffc0206150 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0206150:	ca19                	beqz	a2,ffffffffc0206166 <memcpy+0x16>
ffffffffc0206152:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0206154:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206156:	0005c703          	lbu	a4,0(a1)
ffffffffc020615a:	0585                	addi	a1,a1,1
ffffffffc020615c:	0785                	addi	a5,a5,1
ffffffffc020615e:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206162:	fec59ae3          	bne	a1,a2,ffffffffc0206156 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206166:	8082                	ret

ffffffffc0206168 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206168:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020616c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020616e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206172:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206174:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206178:	f022                	sd	s0,32(sp)
ffffffffc020617a:	ec26                	sd	s1,24(sp)
ffffffffc020617c:	e84a                	sd	s2,16(sp)
ffffffffc020617e:	f406                	sd	ra,40(sp)
ffffffffc0206180:	e44e                	sd	s3,8(sp)
ffffffffc0206182:	84aa                	mv	s1,a0
ffffffffc0206184:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206186:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020618a:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020618c:	03067e63          	bgeu	a2,a6,ffffffffc02061c8 <printnum+0x60>
ffffffffc0206190:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0206192:	00805763          	blez	s0,ffffffffc02061a0 <printnum+0x38>
ffffffffc0206196:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206198:	85ca                	mv	a1,s2
ffffffffc020619a:	854e                	mv	a0,s3
ffffffffc020619c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020619e:	fc65                	bnez	s0,ffffffffc0206196 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061a0:	1a02                	slli	s4,s4,0x20
ffffffffc02061a2:	00002797          	auipc	a5,0x2
ffffffffc02061a6:	76e78793          	addi	a5,a5,1902 # ffffffffc0208910 <syscalls+0x100>
ffffffffc02061aa:	020a5a13          	srli	s4,s4,0x20
ffffffffc02061ae:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02061b0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061b2:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02061b6:	70a2                	ld	ra,40(sp)
ffffffffc02061b8:	69a2                	ld	s3,8(sp)
ffffffffc02061ba:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061bc:	85ca                	mv	a1,s2
ffffffffc02061be:	87a6                	mv	a5,s1
}
ffffffffc02061c0:	6942                	ld	s2,16(sp)
ffffffffc02061c2:	64e2                	ld	s1,24(sp)
ffffffffc02061c4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061c6:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02061c8:	03065633          	divu	a2,a2,a6
ffffffffc02061cc:	8722                	mv	a4,s0
ffffffffc02061ce:	f9bff0ef          	jal	ra,ffffffffc0206168 <printnum>
ffffffffc02061d2:	b7f9                	j	ffffffffc02061a0 <printnum+0x38>

ffffffffc02061d4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02061d4:	7119                	addi	sp,sp,-128
ffffffffc02061d6:	f4a6                	sd	s1,104(sp)
ffffffffc02061d8:	f0ca                	sd	s2,96(sp)
ffffffffc02061da:	ecce                	sd	s3,88(sp)
ffffffffc02061dc:	e8d2                	sd	s4,80(sp)
ffffffffc02061de:	e4d6                	sd	s5,72(sp)
ffffffffc02061e0:	e0da                	sd	s6,64(sp)
ffffffffc02061e2:	fc5e                	sd	s7,56(sp)
ffffffffc02061e4:	f06a                	sd	s10,32(sp)
ffffffffc02061e6:	fc86                	sd	ra,120(sp)
ffffffffc02061e8:	f8a2                	sd	s0,112(sp)
ffffffffc02061ea:	f862                	sd	s8,48(sp)
ffffffffc02061ec:	f466                	sd	s9,40(sp)
ffffffffc02061ee:	ec6e                	sd	s11,24(sp)
ffffffffc02061f0:	892a                	mv	s2,a0
ffffffffc02061f2:	84ae                	mv	s1,a1
ffffffffc02061f4:	8d32                	mv	s10,a2
ffffffffc02061f6:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02061f8:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02061fc:	5b7d                	li	s6,-1
ffffffffc02061fe:	00002a97          	auipc	s5,0x2
ffffffffc0206202:	73ea8a93          	addi	s5,s5,1854 # ffffffffc020893c <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206206:	00003b97          	auipc	s7,0x3
ffffffffc020620a:	952b8b93          	addi	s7,s7,-1710 # ffffffffc0208b58 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020620e:	000d4503          	lbu	a0,0(s10)
ffffffffc0206212:	001d0413          	addi	s0,s10,1
ffffffffc0206216:	01350a63          	beq	a0,s3,ffffffffc020622a <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020621a:	c121                	beqz	a0,ffffffffc020625a <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020621c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020621e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0206220:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206222:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206226:	ff351ae3          	bne	a0,s3,ffffffffc020621a <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020622a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020622e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0206232:	4c81                	li	s9,0
ffffffffc0206234:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0206236:	5c7d                	li	s8,-1
ffffffffc0206238:	5dfd                	li	s11,-1
ffffffffc020623a:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020623e:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206240:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0206244:	0ff5f593          	zext.b	a1,a1
ffffffffc0206248:	00140d13          	addi	s10,s0,1
ffffffffc020624c:	04b56263          	bltu	a0,a1,ffffffffc0206290 <vprintfmt+0xbc>
ffffffffc0206250:	058a                	slli	a1,a1,0x2
ffffffffc0206252:	95d6                	add	a1,a1,s5
ffffffffc0206254:	4194                	lw	a3,0(a1)
ffffffffc0206256:	96d6                	add	a3,a3,s5
ffffffffc0206258:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020625a:	70e6                	ld	ra,120(sp)
ffffffffc020625c:	7446                	ld	s0,112(sp)
ffffffffc020625e:	74a6                	ld	s1,104(sp)
ffffffffc0206260:	7906                	ld	s2,96(sp)
ffffffffc0206262:	69e6                	ld	s3,88(sp)
ffffffffc0206264:	6a46                	ld	s4,80(sp)
ffffffffc0206266:	6aa6                	ld	s5,72(sp)
ffffffffc0206268:	6b06                	ld	s6,64(sp)
ffffffffc020626a:	7be2                	ld	s7,56(sp)
ffffffffc020626c:	7c42                	ld	s8,48(sp)
ffffffffc020626e:	7ca2                	ld	s9,40(sp)
ffffffffc0206270:	7d02                	ld	s10,32(sp)
ffffffffc0206272:	6de2                	ld	s11,24(sp)
ffffffffc0206274:	6109                	addi	sp,sp,128
ffffffffc0206276:	8082                	ret
            padc = '0';
ffffffffc0206278:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020627a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020627e:	846a                	mv	s0,s10
ffffffffc0206280:	00140d13          	addi	s10,s0,1
ffffffffc0206284:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0206288:	0ff5f593          	zext.b	a1,a1
ffffffffc020628c:	fcb572e3          	bgeu	a0,a1,ffffffffc0206250 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0206290:	85a6                	mv	a1,s1
ffffffffc0206292:	02500513          	li	a0,37
ffffffffc0206296:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206298:	fff44783          	lbu	a5,-1(s0)
ffffffffc020629c:	8d22                	mv	s10,s0
ffffffffc020629e:	f73788e3          	beq	a5,s3,ffffffffc020620e <vprintfmt+0x3a>
ffffffffc02062a2:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02062a6:	1d7d                	addi	s10,s10,-1
ffffffffc02062a8:	ff379de3          	bne	a5,s3,ffffffffc02062a2 <vprintfmt+0xce>
ffffffffc02062ac:	b78d                	j	ffffffffc020620e <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02062ae:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02062b2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062b6:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02062b8:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02062bc:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02062c0:	02d86463          	bltu	a6,a3,ffffffffc02062e8 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02062c4:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02062c8:	002c169b          	slliw	a3,s8,0x2
ffffffffc02062cc:	0186873b          	addw	a4,a3,s8
ffffffffc02062d0:	0017171b          	slliw	a4,a4,0x1
ffffffffc02062d4:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02062d6:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02062da:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02062dc:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02062e0:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02062e4:	fed870e3          	bgeu	a6,a3,ffffffffc02062c4 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02062e8:	f40ddce3          	bgez	s11,ffffffffc0206240 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02062ec:	8de2                	mv	s11,s8
ffffffffc02062ee:	5c7d                	li	s8,-1
ffffffffc02062f0:	bf81                	j	ffffffffc0206240 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02062f2:	fffdc693          	not	a3,s11
ffffffffc02062f6:	96fd                	srai	a3,a3,0x3f
ffffffffc02062f8:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062fc:	00144603          	lbu	a2,1(s0)
ffffffffc0206300:	2d81                	sext.w	s11,s11
ffffffffc0206302:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206304:	bf35                	j	ffffffffc0206240 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0206306:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020630a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020630e:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206310:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0206312:	bfd9                	j	ffffffffc02062e8 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0206314:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206316:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020631a:	01174463          	blt	a4,a7,ffffffffc0206322 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020631e:	1a088e63          	beqz	a7,ffffffffc02064da <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0206322:	000a3603          	ld	a2,0(s4)
ffffffffc0206326:	46c1                	li	a3,16
ffffffffc0206328:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020632a:	2781                	sext.w	a5,a5
ffffffffc020632c:	876e                	mv	a4,s11
ffffffffc020632e:	85a6                	mv	a1,s1
ffffffffc0206330:	854a                	mv	a0,s2
ffffffffc0206332:	e37ff0ef          	jal	ra,ffffffffc0206168 <printnum>
            break;
ffffffffc0206336:	bde1                	j	ffffffffc020620e <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0206338:	000a2503          	lw	a0,0(s4)
ffffffffc020633c:	85a6                	mv	a1,s1
ffffffffc020633e:	0a21                	addi	s4,s4,8
ffffffffc0206340:	9902                	jalr	s2
            break;
ffffffffc0206342:	b5f1                	j	ffffffffc020620e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206344:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206346:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020634a:	01174463          	blt	a4,a7,ffffffffc0206352 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020634e:	18088163          	beqz	a7,ffffffffc02064d0 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0206352:	000a3603          	ld	a2,0(s4)
ffffffffc0206356:	46a9                	li	a3,10
ffffffffc0206358:	8a2e                	mv	s4,a1
ffffffffc020635a:	bfc1                	j	ffffffffc020632a <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020635c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206360:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206362:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206364:	bdf1                	j	ffffffffc0206240 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0206366:	85a6                	mv	a1,s1
ffffffffc0206368:	02500513          	li	a0,37
ffffffffc020636c:	9902                	jalr	s2
            break;
ffffffffc020636e:	b545                	j	ffffffffc020620e <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206370:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0206374:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206376:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206378:	b5e1                	j	ffffffffc0206240 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020637a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020637c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206380:	01174463          	blt	a4,a7,ffffffffc0206388 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0206384:	14088163          	beqz	a7,ffffffffc02064c6 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0206388:	000a3603          	ld	a2,0(s4)
ffffffffc020638c:	46a1                	li	a3,8
ffffffffc020638e:	8a2e                	mv	s4,a1
ffffffffc0206390:	bf69                	j	ffffffffc020632a <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0206392:	03000513          	li	a0,48
ffffffffc0206396:	85a6                	mv	a1,s1
ffffffffc0206398:	e03e                	sd	a5,0(sp)
ffffffffc020639a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020639c:	85a6                	mv	a1,s1
ffffffffc020639e:	07800513          	li	a0,120
ffffffffc02063a2:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02063a4:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02063a6:	6782                	ld	a5,0(sp)
ffffffffc02063a8:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02063aa:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02063ae:	bfb5                	j	ffffffffc020632a <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02063b0:	000a3403          	ld	s0,0(s4)
ffffffffc02063b4:	008a0713          	addi	a4,s4,8
ffffffffc02063b8:	e03a                	sd	a4,0(sp)
ffffffffc02063ba:	14040263          	beqz	s0,ffffffffc02064fe <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02063be:	0fb05763          	blez	s11,ffffffffc02064ac <vprintfmt+0x2d8>
ffffffffc02063c2:	02d00693          	li	a3,45
ffffffffc02063c6:	0cd79163          	bne	a5,a3,ffffffffc0206488 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02063ca:	00044783          	lbu	a5,0(s0)
ffffffffc02063ce:	0007851b          	sext.w	a0,a5
ffffffffc02063d2:	cf85                	beqz	a5,ffffffffc020640a <vprintfmt+0x236>
ffffffffc02063d4:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02063d8:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02063dc:	000c4563          	bltz	s8,ffffffffc02063e6 <vprintfmt+0x212>
ffffffffc02063e0:	3c7d                	addiw	s8,s8,-1
ffffffffc02063e2:	036c0263          	beq	s8,s6,ffffffffc0206406 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02063e6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02063e8:	0e0c8e63          	beqz	s9,ffffffffc02064e4 <vprintfmt+0x310>
ffffffffc02063ec:	3781                	addiw	a5,a5,-32
ffffffffc02063ee:	0ef47b63          	bgeu	s0,a5,ffffffffc02064e4 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02063f2:	03f00513          	li	a0,63
ffffffffc02063f6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02063f8:	000a4783          	lbu	a5,0(s4)
ffffffffc02063fc:	3dfd                	addiw	s11,s11,-1
ffffffffc02063fe:	0a05                	addi	s4,s4,1
ffffffffc0206400:	0007851b          	sext.w	a0,a5
ffffffffc0206404:	ffe1                	bnez	a5,ffffffffc02063dc <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0206406:	01b05963          	blez	s11,ffffffffc0206418 <vprintfmt+0x244>
ffffffffc020640a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020640c:	85a6                	mv	a1,s1
ffffffffc020640e:	02000513          	li	a0,32
ffffffffc0206412:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206414:	fe0d9be3          	bnez	s11,ffffffffc020640a <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206418:	6a02                	ld	s4,0(sp)
ffffffffc020641a:	bbd5                	j	ffffffffc020620e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020641c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020641e:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0206422:	01174463          	blt	a4,a7,ffffffffc020642a <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0206426:	08088d63          	beqz	a7,ffffffffc02064c0 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020642a:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020642e:	0a044d63          	bltz	s0,ffffffffc02064e8 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0206432:	8622                	mv	a2,s0
ffffffffc0206434:	8a66                	mv	s4,s9
ffffffffc0206436:	46a9                	li	a3,10
ffffffffc0206438:	bdcd                	j	ffffffffc020632a <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020643a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020643e:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206440:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0206442:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206446:	8fb5                	xor	a5,a5,a3
ffffffffc0206448:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020644c:	02d74163          	blt	a4,a3,ffffffffc020646e <vprintfmt+0x29a>
ffffffffc0206450:	00369793          	slli	a5,a3,0x3
ffffffffc0206454:	97de                	add	a5,a5,s7
ffffffffc0206456:	639c                	ld	a5,0(a5)
ffffffffc0206458:	cb99                	beqz	a5,ffffffffc020646e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020645a:	86be                	mv	a3,a5
ffffffffc020645c:	00000617          	auipc	a2,0x0
ffffffffc0206460:	13c60613          	addi	a2,a2,316 # ffffffffc0206598 <etext+0x2c>
ffffffffc0206464:	85a6                	mv	a1,s1
ffffffffc0206466:	854a                	mv	a0,s2
ffffffffc0206468:	0ce000ef          	jal	ra,ffffffffc0206536 <printfmt>
ffffffffc020646c:	b34d                	j	ffffffffc020620e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020646e:	00002617          	auipc	a2,0x2
ffffffffc0206472:	4c260613          	addi	a2,a2,1218 # ffffffffc0208930 <syscalls+0x120>
ffffffffc0206476:	85a6                	mv	a1,s1
ffffffffc0206478:	854a                	mv	a0,s2
ffffffffc020647a:	0bc000ef          	jal	ra,ffffffffc0206536 <printfmt>
ffffffffc020647e:	bb41                	j	ffffffffc020620e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206480:	00002417          	auipc	s0,0x2
ffffffffc0206484:	4a840413          	addi	s0,s0,1192 # ffffffffc0208928 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206488:	85e2                	mv	a1,s8
ffffffffc020648a:	8522                	mv	a0,s0
ffffffffc020648c:	e43e                	sd	a5,8(sp)
ffffffffc020648e:	c4fff0ef          	jal	ra,ffffffffc02060dc <strnlen>
ffffffffc0206492:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206496:	01b05b63          	blez	s11,ffffffffc02064ac <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020649a:	67a2                	ld	a5,8(sp)
ffffffffc020649c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064a0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02064a2:	85a6                	mv	a1,s1
ffffffffc02064a4:	8552                	mv	a0,s4
ffffffffc02064a6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064a8:	fe0d9ce3          	bnez	s11,ffffffffc02064a0 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064ac:	00044783          	lbu	a5,0(s0)
ffffffffc02064b0:	00140a13          	addi	s4,s0,1
ffffffffc02064b4:	0007851b          	sext.w	a0,a5
ffffffffc02064b8:	d3a5                	beqz	a5,ffffffffc0206418 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02064ba:	05e00413          	li	s0,94
ffffffffc02064be:	bf39                	j	ffffffffc02063dc <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02064c0:	000a2403          	lw	s0,0(s4)
ffffffffc02064c4:	b7ad                	j	ffffffffc020642e <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02064c6:	000a6603          	lwu	a2,0(s4)
ffffffffc02064ca:	46a1                	li	a3,8
ffffffffc02064cc:	8a2e                	mv	s4,a1
ffffffffc02064ce:	bdb1                	j	ffffffffc020632a <vprintfmt+0x156>
ffffffffc02064d0:	000a6603          	lwu	a2,0(s4)
ffffffffc02064d4:	46a9                	li	a3,10
ffffffffc02064d6:	8a2e                	mv	s4,a1
ffffffffc02064d8:	bd89                	j	ffffffffc020632a <vprintfmt+0x156>
ffffffffc02064da:	000a6603          	lwu	a2,0(s4)
ffffffffc02064de:	46c1                	li	a3,16
ffffffffc02064e0:	8a2e                	mv	s4,a1
ffffffffc02064e2:	b5a1                	j	ffffffffc020632a <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02064e4:	9902                	jalr	s2
ffffffffc02064e6:	bf09                	j	ffffffffc02063f8 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02064e8:	85a6                	mv	a1,s1
ffffffffc02064ea:	02d00513          	li	a0,45
ffffffffc02064ee:	e03e                	sd	a5,0(sp)
ffffffffc02064f0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02064f2:	6782                	ld	a5,0(sp)
ffffffffc02064f4:	8a66                	mv	s4,s9
ffffffffc02064f6:	40800633          	neg	a2,s0
ffffffffc02064fa:	46a9                	li	a3,10
ffffffffc02064fc:	b53d                	j	ffffffffc020632a <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02064fe:	03b05163          	blez	s11,ffffffffc0206520 <vprintfmt+0x34c>
ffffffffc0206502:	02d00693          	li	a3,45
ffffffffc0206506:	f6d79de3          	bne	a5,a3,ffffffffc0206480 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020650a:	00002417          	auipc	s0,0x2
ffffffffc020650e:	41e40413          	addi	s0,s0,1054 # ffffffffc0208928 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206512:	02800793          	li	a5,40
ffffffffc0206516:	02800513          	li	a0,40
ffffffffc020651a:	00140a13          	addi	s4,s0,1
ffffffffc020651e:	bd6d                	j	ffffffffc02063d8 <vprintfmt+0x204>
ffffffffc0206520:	00002a17          	auipc	s4,0x2
ffffffffc0206524:	409a0a13          	addi	s4,s4,1033 # ffffffffc0208929 <syscalls+0x119>
ffffffffc0206528:	02800513          	li	a0,40
ffffffffc020652c:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206530:	05e00413          	li	s0,94
ffffffffc0206534:	b565                	j	ffffffffc02063dc <vprintfmt+0x208>

ffffffffc0206536 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206536:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206538:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020653c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020653e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206540:	ec06                	sd	ra,24(sp)
ffffffffc0206542:	f83a                	sd	a4,48(sp)
ffffffffc0206544:	fc3e                	sd	a5,56(sp)
ffffffffc0206546:	e0c2                	sd	a6,64(sp)
ffffffffc0206548:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020654a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020654c:	c89ff0ef          	jal	ra,ffffffffc02061d4 <vprintfmt>
}
ffffffffc0206550:	60e2                	ld	ra,24(sp)
ffffffffc0206552:	6161                	addi	sp,sp,80
ffffffffc0206554:	8082                	ret

ffffffffc0206556 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0206556:	9e3707b7          	lui	a5,0x9e370
ffffffffc020655a:	2785                	addiw	a5,a5,1
ffffffffc020655c:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0206560:	02000793          	li	a5,32
ffffffffc0206564:	9f8d                	subw	a5,a5,a1
}
ffffffffc0206566:	00f5553b          	srlw	a0,a0,a5
ffffffffc020656a:	8082                	ret
