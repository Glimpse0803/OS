
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
ffffffffc0200036:	ff650513          	addi	a0,a0,-10 # ffffffffc0206028 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	45660613          	addi	a2,a2,1110 # ffffffffc0206490 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	756010ef          	jal	ra,ffffffffc02017a0 <memset>
    cons_init();  // init the console
ffffffffc020004e:	404000ef          	jal	ra,ffffffffc0200452 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	c5650513          	addi	a0,a0,-938 # ffffffffc0201ca8 <etext+0x4>
ffffffffc020005a:	098000ef          	jal	ra,ffffffffc02000f2 <cputs>

    print_kerninfo();
ffffffffc020005e:	140000ef          	jal	ra,ffffffffc020019e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	40a000ef          	jal	ra,ffffffffc020046c <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	05b000ef          	jal	ra,ffffffffc02008c0 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	402000ef          	jal	ra,ffffffffc020046c <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	3a2000ef          	jal	ra,ffffffffc0200410 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3ee000ef          	jal	ra,ffffffffc0200460 <intr_enable>


    slub_init();
ffffffffc0200076:	582010ef          	jal	ra,ffffffffc02015f8 <slub_init>
    slub_check();
ffffffffc020007a:	5de010ef          	jal	ra,ffffffffc0201658 <slub_check>
    /* do nothing */
    while (1)
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
ffffffffc02000ae:	770010ef          	jal	ra,ffffffffc020181e <vprintfmt>
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
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
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
ffffffffc02000e4:	73a010ef          	jal	ra,ffffffffc020181e <vprintfmt>
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

ffffffffc02000f2 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000f2:	1101                	addi	sp,sp,-32
ffffffffc02000f4:	e822                	sd	s0,16(sp)
ffffffffc02000f6:	ec06                	sd	ra,24(sp)
ffffffffc02000f8:	e426                	sd	s1,8(sp)
ffffffffc02000fa:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000fc:	00054503          	lbu	a0,0(a0)
ffffffffc0200100:	c51d                	beqz	a0,ffffffffc020012e <cputs+0x3c>
ffffffffc0200102:	0405                	addi	s0,s0,1
ffffffffc0200104:	4485                	li	s1,1
ffffffffc0200106:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200108:	34c000ef          	jal	ra,ffffffffc0200454 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	00044503          	lbu	a0,0(s0)
ffffffffc0200110:	008487bb          	addw	a5,s1,s0
ffffffffc0200114:	0405                	addi	s0,s0,1
ffffffffc0200116:	f96d                	bnez	a0,ffffffffc0200108 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200118:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020011c:	4529                	li	a0,10
ffffffffc020011e:	336000ef          	jal	ra,ffffffffc0200454 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200122:	60e2                	ld	ra,24(sp)
ffffffffc0200124:	8522                	mv	a0,s0
ffffffffc0200126:	6442                	ld	s0,16(sp)
ffffffffc0200128:	64a2                	ld	s1,8(sp)
ffffffffc020012a:	6105                	addi	sp,sp,32
ffffffffc020012c:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012e:	4405                	li	s0,1
ffffffffc0200130:	b7f5                	j	ffffffffc020011c <cputs+0x2a>

ffffffffc0200132 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200132:	1141                	addi	sp,sp,-16
ffffffffc0200134:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200136:	326000ef          	jal	ra,ffffffffc020045c <cons_getc>
ffffffffc020013a:	dd75                	beqz	a0,ffffffffc0200136 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020013c:	60a2                	ld	ra,8(sp)
ffffffffc020013e:	0141                	addi	sp,sp,16
ffffffffc0200140:	8082                	ret

ffffffffc0200142 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200142:	00006317          	auipc	t1,0x6
ffffffffc0200146:	2fe30313          	addi	t1,t1,766 # ffffffffc0206440 <is_panic>
ffffffffc020014a:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020014e:	715d                	addi	sp,sp,-80
ffffffffc0200150:	ec06                	sd	ra,24(sp)
ffffffffc0200152:	e822                	sd	s0,16(sp)
ffffffffc0200154:	f436                	sd	a3,40(sp)
ffffffffc0200156:	f83a                	sd	a4,48(sp)
ffffffffc0200158:	fc3e                	sd	a5,56(sp)
ffffffffc020015a:	e0c2                	sd	a6,64(sp)
ffffffffc020015c:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020015e:	020e1a63          	bnez	t3,ffffffffc0200192 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200162:	4785                	li	a5,1
ffffffffc0200164:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200168:	8432                	mv	s0,a2
ffffffffc020016a:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016c:	862e                	mv	a2,a1
ffffffffc020016e:	85aa                	mv	a1,a0
ffffffffc0200170:	00002517          	auipc	a0,0x2
ffffffffc0200174:	b5850513          	addi	a0,a0,-1192 # ffffffffc0201cc8 <etext+0x24>
    va_start(ap, fmt);
ffffffffc0200178:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020017a:	f41ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc020017e:	65a2                	ld	a1,8(sp)
ffffffffc0200180:	8522                	mv	a0,s0
ffffffffc0200182:	f19ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc0200186:	00002517          	auipc	a0,0x2
ffffffffc020018a:	c2a50513          	addi	a0,a0,-982 # ffffffffc0201db0 <etext+0x10c>
ffffffffc020018e:	f2dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200192:	2d4000ef          	jal	ra,ffffffffc0200466 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200196:	4501                	li	a0,0
ffffffffc0200198:	130000ef          	jal	ra,ffffffffc02002c8 <kmonitor>
    while (1) {
ffffffffc020019c:	bfed                	j	ffffffffc0200196 <__panic+0x54>

ffffffffc020019e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020019e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001a0:	00002517          	auipc	a0,0x2
ffffffffc02001a4:	b4850513          	addi	a0,a0,-1208 # ffffffffc0201ce8 <etext+0x44>
void print_kerninfo(void) {
ffffffffc02001a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001aa:	f11ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001ae:	00000597          	auipc	a1,0x0
ffffffffc02001b2:	e8458593          	addi	a1,a1,-380 # ffffffffc0200032 <kern_init>
ffffffffc02001b6:	00002517          	auipc	a0,0x2
ffffffffc02001ba:	b5250513          	addi	a0,a0,-1198 # ffffffffc0201d08 <etext+0x64>
ffffffffc02001be:	efdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001c2:	00002597          	auipc	a1,0x2
ffffffffc02001c6:	ae258593          	addi	a1,a1,-1310 # ffffffffc0201ca4 <etext>
ffffffffc02001ca:	00002517          	auipc	a0,0x2
ffffffffc02001ce:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0201d28 <etext+0x84>
ffffffffc02001d2:	ee9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001d6:	00006597          	auipc	a1,0x6
ffffffffc02001da:	e5258593          	addi	a1,a1,-430 # ffffffffc0206028 <free_area>
ffffffffc02001de:	00002517          	auipc	a0,0x2
ffffffffc02001e2:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0201d48 <etext+0xa4>
ffffffffc02001e6:	ed5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001ea:	00006597          	auipc	a1,0x6
ffffffffc02001ee:	2a658593          	addi	a1,a1,678 # ffffffffc0206490 <end>
ffffffffc02001f2:	00002517          	auipc	a0,0x2
ffffffffc02001f6:	b7650513          	addi	a0,a0,-1162 # ffffffffc0201d68 <etext+0xc4>
ffffffffc02001fa:	ec1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001fe:	00006597          	auipc	a1,0x6
ffffffffc0200202:	69158593          	addi	a1,a1,1681 # ffffffffc020688f <end+0x3ff>
ffffffffc0200206:	00000797          	auipc	a5,0x0
ffffffffc020020a:	e2c78793          	addi	a5,a5,-468 # ffffffffc0200032 <kern_init>
ffffffffc020020e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200212:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200216:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200218:	3ff5f593          	andi	a1,a1,1023
ffffffffc020021c:	95be                	add	a1,a1,a5
ffffffffc020021e:	85a9                	srai	a1,a1,0xa
ffffffffc0200220:	00002517          	auipc	a0,0x2
ffffffffc0200224:	b6850513          	addi	a0,a0,-1176 # ffffffffc0201d88 <etext+0xe4>
}
ffffffffc0200228:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020022a:	bd41                	j	ffffffffc02000ba <cprintf>

ffffffffc020022c <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020022c:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc020022e:	00002617          	auipc	a2,0x2
ffffffffc0200232:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0201db8 <etext+0x114>
ffffffffc0200236:	04e00593          	li	a1,78
ffffffffc020023a:	00002517          	auipc	a0,0x2
ffffffffc020023e:	b9650513          	addi	a0,a0,-1130 # ffffffffc0201dd0 <etext+0x12c>
void print_stackframe(void) {
ffffffffc0200242:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200244:	effff0ef          	jal	ra,ffffffffc0200142 <__panic>

ffffffffc0200248 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200248:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020024a:	00002617          	auipc	a2,0x2
ffffffffc020024e:	b9e60613          	addi	a2,a2,-1122 # ffffffffc0201de8 <etext+0x144>
ffffffffc0200252:	00002597          	auipc	a1,0x2
ffffffffc0200256:	bb658593          	addi	a1,a1,-1098 # ffffffffc0201e08 <etext+0x164>
ffffffffc020025a:	00002517          	auipc	a0,0x2
ffffffffc020025e:	bb650513          	addi	a0,a0,-1098 # ffffffffc0201e10 <etext+0x16c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200262:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200264:	e57ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200268:	00002617          	auipc	a2,0x2
ffffffffc020026c:	bb860613          	addi	a2,a2,-1096 # ffffffffc0201e20 <etext+0x17c>
ffffffffc0200270:	00002597          	auipc	a1,0x2
ffffffffc0200274:	bd858593          	addi	a1,a1,-1064 # ffffffffc0201e48 <etext+0x1a4>
ffffffffc0200278:	00002517          	auipc	a0,0x2
ffffffffc020027c:	b9850513          	addi	a0,a0,-1128 # ffffffffc0201e10 <etext+0x16c>
ffffffffc0200280:	e3bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200284:	00002617          	auipc	a2,0x2
ffffffffc0200288:	bd460613          	addi	a2,a2,-1068 # ffffffffc0201e58 <etext+0x1b4>
ffffffffc020028c:	00002597          	auipc	a1,0x2
ffffffffc0200290:	bec58593          	addi	a1,a1,-1044 # ffffffffc0201e78 <etext+0x1d4>
ffffffffc0200294:	00002517          	auipc	a0,0x2
ffffffffc0200298:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0201e10 <etext+0x16c>
ffffffffc020029c:	e1fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc02002a0:	60a2                	ld	ra,8(sp)
ffffffffc02002a2:	4501                	li	a0,0
ffffffffc02002a4:	0141                	addi	sp,sp,16
ffffffffc02002a6:	8082                	ret

ffffffffc02002a8 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002a8:	1141                	addi	sp,sp,-16
ffffffffc02002aa:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002ac:	ef3ff0ef          	jal	ra,ffffffffc020019e <print_kerninfo>
    return 0;
}
ffffffffc02002b0:	60a2                	ld	ra,8(sp)
ffffffffc02002b2:	4501                	li	a0,0
ffffffffc02002b4:	0141                	addi	sp,sp,16
ffffffffc02002b6:	8082                	ret

ffffffffc02002b8 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b8:	1141                	addi	sp,sp,-16
ffffffffc02002ba:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002bc:	f71ff0ef          	jal	ra,ffffffffc020022c <print_stackframe>
    return 0;
}
ffffffffc02002c0:	60a2                	ld	ra,8(sp)
ffffffffc02002c2:	4501                	li	a0,0
ffffffffc02002c4:	0141                	addi	sp,sp,16
ffffffffc02002c6:	8082                	ret

ffffffffc02002c8 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002c8:	7115                	addi	sp,sp,-224
ffffffffc02002ca:	ed5e                	sd	s7,152(sp)
ffffffffc02002cc:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ce:	00002517          	auipc	a0,0x2
ffffffffc02002d2:	bba50513          	addi	a0,a0,-1094 # ffffffffc0201e88 <etext+0x1e4>
kmonitor(struct trapframe *tf) {
ffffffffc02002d6:	ed86                	sd	ra,216(sp)
ffffffffc02002d8:	e9a2                	sd	s0,208(sp)
ffffffffc02002da:	e5a6                	sd	s1,200(sp)
ffffffffc02002dc:	e1ca                	sd	s2,192(sp)
ffffffffc02002de:	fd4e                	sd	s3,184(sp)
ffffffffc02002e0:	f952                	sd	s4,176(sp)
ffffffffc02002e2:	f556                	sd	s5,168(sp)
ffffffffc02002e4:	f15a                	sd	s6,160(sp)
ffffffffc02002e6:	e962                	sd	s8,144(sp)
ffffffffc02002e8:	e566                	sd	s9,136(sp)
ffffffffc02002ea:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ec:	dcfff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002f0:	00002517          	auipc	a0,0x2
ffffffffc02002f4:	bc050513          	addi	a0,a0,-1088 # ffffffffc0201eb0 <etext+0x20c>
ffffffffc02002f8:	dc3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002fc:	000b8563          	beqz	s7,ffffffffc0200306 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200300:	855e                	mv	a0,s7
ffffffffc0200302:	348000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc0200306:	00002c17          	auipc	s8,0x2
ffffffffc020030a:	c1ac0c13          	addi	s8,s8,-998 # ffffffffc0201f20 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020030e:	00002917          	auipc	s2,0x2
ffffffffc0200312:	bca90913          	addi	s2,s2,-1078 # ffffffffc0201ed8 <etext+0x234>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200316:	00002497          	auipc	s1,0x2
ffffffffc020031a:	bca48493          	addi	s1,s1,-1078 # ffffffffc0201ee0 <etext+0x23c>
        if (argc == MAXARGS - 1) {
ffffffffc020031e:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200320:	00002b17          	auipc	s6,0x2
ffffffffc0200324:	bc8b0b13          	addi	s6,s6,-1080 # ffffffffc0201ee8 <etext+0x244>
        argv[argc ++] = buf;
ffffffffc0200328:	00002a17          	auipc	s4,0x2
ffffffffc020032c:	ae0a0a13          	addi	s4,s4,-1312 # ffffffffc0201e08 <etext+0x164>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200330:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200332:	854a                	mv	a0,s2
ffffffffc0200334:	06d010ef          	jal	ra,ffffffffc0201ba0 <readline>
ffffffffc0200338:	842a                	mv	s0,a0
ffffffffc020033a:	dd65                	beqz	a0,ffffffffc0200332 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020033c:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200340:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200342:	e1bd                	bnez	a1,ffffffffc02003a8 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200344:	fe0c87e3          	beqz	s9,ffffffffc0200332 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200348:	6582                	ld	a1,0(sp)
ffffffffc020034a:	00002d17          	auipc	s10,0x2
ffffffffc020034e:	bd6d0d13          	addi	s10,s10,-1066 # ffffffffc0201f20 <commands>
        argv[argc ++] = buf;
ffffffffc0200352:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200354:	4401                	li	s0,0
ffffffffc0200356:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200358:	414010ef          	jal	ra,ffffffffc020176c <strcmp>
ffffffffc020035c:	c919                	beqz	a0,ffffffffc0200372 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020035e:	2405                	addiw	s0,s0,1
ffffffffc0200360:	0b540063          	beq	s0,s5,ffffffffc0200400 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200364:	000d3503          	ld	a0,0(s10)
ffffffffc0200368:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020036a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020036c:	400010ef          	jal	ra,ffffffffc020176c <strcmp>
ffffffffc0200370:	f57d                	bnez	a0,ffffffffc020035e <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200372:	00141793          	slli	a5,s0,0x1
ffffffffc0200376:	97a2                	add	a5,a5,s0
ffffffffc0200378:	078e                	slli	a5,a5,0x3
ffffffffc020037a:	97e2                	add	a5,a5,s8
ffffffffc020037c:	6b9c                	ld	a5,16(a5)
ffffffffc020037e:	865e                	mv	a2,s7
ffffffffc0200380:	002c                	addi	a1,sp,8
ffffffffc0200382:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200386:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200388:	fa0555e3          	bgez	a0,ffffffffc0200332 <kmonitor+0x6a>
}
ffffffffc020038c:	60ee                	ld	ra,216(sp)
ffffffffc020038e:	644e                	ld	s0,208(sp)
ffffffffc0200390:	64ae                	ld	s1,200(sp)
ffffffffc0200392:	690e                	ld	s2,192(sp)
ffffffffc0200394:	79ea                	ld	s3,184(sp)
ffffffffc0200396:	7a4a                	ld	s4,176(sp)
ffffffffc0200398:	7aaa                	ld	s5,168(sp)
ffffffffc020039a:	7b0a                	ld	s6,160(sp)
ffffffffc020039c:	6bea                	ld	s7,152(sp)
ffffffffc020039e:	6c4a                	ld	s8,144(sp)
ffffffffc02003a0:	6caa                	ld	s9,136(sp)
ffffffffc02003a2:	6d0a                	ld	s10,128(sp)
ffffffffc02003a4:	612d                	addi	sp,sp,224
ffffffffc02003a6:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a8:	8526                	mv	a0,s1
ffffffffc02003aa:	3e0010ef          	jal	ra,ffffffffc020178a <strchr>
ffffffffc02003ae:	c901                	beqz	a0,ffffffffc02003be <kmonitor+0xf6>
ffffffffc02003b0:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003b4:	00040023          	sb	zero,0(s0)
ffffffffc02003b8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ba:	d5c9                	beqz	a1,ffffffffc0200344 <kmonitor+0x7c>
ffffffffc02003bc:	b7f5                	j	ffffffffc02003a8 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02003be:	00044783          	lbu	a5,0(s0)
ffffffffc02003c2:	d3c9                	beqz	a5,ffffffffc0200344 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02003c4:	033c8963          	beq	s9,s3,ffffffffc02003f6 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02003c8:	003c9793          	slli	a5,s9,0x3
ffffffffc02003cc:	0118                	addi	a4,sp,128
ffffffffc02003ce:	97ba                	add	a5,a5,a4
ffffffffc02003d0:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d4:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003d8:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003da:	e591                	bnez	a1,ffffffffc02003e6 <kmonitor+0x11e>
ffffffffc02003dc:	b7b5                	j	ffffffffc0200348 <kmonitor+0x80>
ffffffffc02003de:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003e2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003e4:	d1a5                	beqz	a1,ffffffffc0200344 <kmonitor+0x7c>
ffffffffc02003e6:	8526                	mv	a0,s1
ffffffffc02003e8:	3a2010ef          	jal	ra,ffffffffc020178a <strchr>
ffffffffc02003ec:	d96d                	beqz	a0,ffffffffc02003de <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ee:	00044583          	lbu	a1,0(s0)
ffffffffc02003f2:	d9a9                	beqz	a1,ffffffffc0200344 <kmonitor+0x7c>
ffffffffc02003f4:	bf55                	j	ffffffffc02003a8 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003f6:	45c1                	li	a1,16
ffffffffc02003f8:	855a                	mv	a0,s6
ffffffffc02003fa:	cc1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02003fe:	b7e9                	j	ffffffffc02003c8 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200400:	6582                	ld	a1,0(sp)
ffffffffc0200402:	00002517          	auipc	a0,0x2
ffffffffc0200406:	b0650513          	addi	a0,a0,-1274 # ffffffffc0201f08 <etext+0x264>
ffffffffc020040a:	cb1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc020040e:	b715                	j	ffffffffc0200332 <kmonitor+0x6a>

ffffffffc0200410 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200410:	1141                	addi	sp,sp,-16
ffffffffc0200412:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200414:	02000793          	li	a5,32
ffffffffc0200418:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020041c:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200420:	67e1                	lui	a5,0x18
ffffffffc0200422:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200426:	953e                	add	a0,a0,a5
ffffffffc0200428:	047010ef          	jal	ra,ffffffffc0201c6e <sbi_set_timer>
}
ffffffffc020042c:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042e:	00006797          	auipc	a5,0x6
ffffffffc0200432:	0007bd23          	sd	zero,26(a5) # ffffffffc0206448 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200436:	00002517          	auipc	a0,0x2
ffffffffc020043a:	b3250513          	addi	a0,a0,-1230 # ffffffffc0201f68 <commands+0x48>
}
ffffffffc020043e:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200440:	b9ad                	j	ffffffffc02000ba <cprintf>

ffffffffc0200442 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200442:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200446:	67e1                	lui	a5,0x18
ffffffffc0200448:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020044c:	953e                	add	a0,a0,a5
ffffffffc020044e:	0210106f          	j	ffffffffc0201c6e <sbi_set_timer>

ffffffffc0200452 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200452:	8082                	ret

ffffffffc0200454 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200454:	0ff57513          	zext.b	a0,a0
ffffffffc0200458:	7fc0106f          	j	ffffffffc0201c54 <sbi_console_putchar>

ffffffffc020045c <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045c:	02d0106f          	j	ffffffffc0201c88 <sbi_console_getchar>

ffffffffc0200460 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200460:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200464:	8082                	ret

ffffffffc0200466 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200466:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020046a:	8082                	ret

ffffffffc020046c <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046c:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200470:	00000797          	auipc	a5,0x0
ffffffffc0200474:	2e478793          	addi	a5,a5,740 # ffffffffc0200754 <__alltraps>
ffffffffc0200478:	10579073          	csrw	stvec,a5
}
ffffffffc020047c:	8082                	ret

ffffffffc020047e <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200480:	1141                	addi	sp,sp,-16
ffffffffc0200482:	e022                	sd	s0,0(sp)
ffffffffc0200484:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200486:	00002517          	auipc	a0,0x2
ffffffffc020048a:	b0250513          	addi	a0,a0,-1278 # ffffffffc0201f88 <commands+0x68>
void print_regs(struct pushregs *gpr) {
ffffffffc020048e:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200490:	c2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200494:	640c                	ld	a1,8(s0)
ffffffffc0200496:	00002517          	auipc	a0,0x2
ffffffffc020049a:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0201fa0 <commands+0x80>
ffffffffc020049e:	c1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a2:	680c                	ld	a1,16(s0)
ffffffffc02004a4:	00002517          	auipc	a0,0x2
ffffffffc02004a8:	b1450513          	addi	a0,a0,-1260 # ffffffffc0201fb8 <commands+0x98>
ffffffffc02004ac:	c0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004b0:	6c0c                	ld	a1,24(s0)
ffffffffc02004b2:	00002517          	auipc	a0,0x2
ffffffffc02004b6:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0201fd0 <commands+0xb0>
ffffffffc02004ba:	c01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004be:	700c                	ld	a1,32(s0)
ffffffffc02004c0:	00002517          	auipc	a0,0x2
ffffffffc02004c4:	b2850513          	addi	a0,a0,-1240 # ffffffffc0201fe8 <commands+0xc8>
ffffffffc02004c8:	bf3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004cc:	740c                	ld	a1,40(s0)
ffffffffc02004ce:	00002517          	auipc	a0,0x2
ffffffffc02004d2:	b3250513          	addi	a0,a0,-1230 # ffffffffc0202000 <commands+0xe0>
ffffffffc02004d6:	be5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004da:	780c                	ld	a1,48(s0)
ffffffffc02004dc:	00002517          	auipc	a0,0x2
ffffffffc02004e0:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0202018 <commands+0xf8>
ffffffffc02004e4:	bd7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e8:	7c0c                	ld	a1,56(s0)
ffffffffc02004ea:	00002517          	auipc	a0,0x2
ffffffffc02004ee:	b4650513          	addi	a0,a0,-1210 # ffffffffc0202030 <commands+0x110>
ffffffffc02004f2:	bc9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f6:	602c                	ld	a1,64(s0)
ffffffffc02004f8:	00002517          	auipc	a0,0x2
ffffffffc02004fc:	b5050513          	addi	a0,a0,-1200 # ffffffffc0202048 <commands+0x128>
ffffffffc0200500:	bbbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200504:	642c                	ld	a1,72(s0)
ffffffffc0200506:	00002517          	auipc	a0,0x2
ffffffffc020050a:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0202060 <commands+0x140>
ffffffffc020050e:	badff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200512:	682c                	ld	a1,80(s0)
ffffffffc0200514:	00002517          	auipc	a0,0x2
ffffffffc0200518:	b6450513          	addi	a0,a0,-1180 # ffffffffc0202078 <commands+0x158>
ffffffffc020051c:	b9fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200520:	6c2c                	ld	a1,88(s0)
ffffffffc0200522:	00002517          	auipc	a0,0x2
ffffffffc0200526:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0202090 <commands+0x170>
ffffffffc020052a:	b91ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052e:	702c                	ld	a1,96(s0)
ffffffffc0200530:	00002517          	auipc	a0,0x2
ffffffffc0200534:	b7850513          	addi	a0,a0,-1160 # ffffffffc02020a8 <commands+0x188>
ffffffffc0200538:	b83ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053c:	742c                	ld	a1,104(s0)
ffffffffc020053e:	00002517          	auipc	a0,0x2
ffffffffc0200542:	b8250513          	addi	a0,a0,-1150 # ffffffffc02020c0 <commands+0x1a0>
ffffffffc0200546:	b75ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020054a:	782c                	ld	a1,112(s0)
ffffffffc020054c:	00002517          	auipc	a0,0x2
ffffffffc0200550:	b8c50513          	addi	a0,a0,-1140 # ffffffffc02020d8 <commands+0x1b8>
ffffffffc0200554:	b67ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200558:	7c2c                	ld	a1,120(s0)
ffffffffc020055a:	00002517          	auipc	a0,0x2
ffffffffc020055e:	b9650513          	addi	a0,a0,-1130 # ffffffffc02020f0 <commands+0x1d0>
ffffffffc0200562:	b59ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200566:	604c                	ld	a1,128(s0)
ffffffffc0200568:	00002517          	auipc	a0,0x2
ffffffffc020056c:	ba050513          	addi	a0,a0,-1120 # ffffffffc0202108 <commands+0x1e8>
ffffffffc0200570:	b4bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200574:	644c                	ld	a1,136(s0)
ffffffffc0200576:	00002517          	auipc	a0,0x2
ffffffffc020057a:	baa50513          	addi	a0,a0,-1110 # ffffffffc0202120 <commands+0x200>
ffffffffc020057e:	b3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200582:	684c                	ld	a1,144(s0)
ffffffffc0200584:	00002517          	auipc	a0,0x2
ffffffffc0200588:	bb450513          	addi	a0,a0,-1100 # ffffffffc0202138 <commands+0x218>
ffffffffc020058c:	b2fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200590:	6c4c                	ld	a1,152(s0)
ffffffffc0200592:	00002517          	auipc	a0,0x2
ffffffffc0200596:	bbe50513          	addi	a0,a0,-1090 # ffffffffc0202150 <commands+0x230>
ffffffffc020059a:	b21ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059e:	704c                	ld	a1,160(s0)
ffffffffc02005a0:	00002517          	auipc	a0,0x2
ffffffffc02005a4:	bc850513          	addi	a0,a0,-1080 # ffffffffc0202168 <commands+0x248>
ffffffffc02005a8:	b13ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005ac:	744c                	ld	a1,168(s0)
ffffffffc02005ae:	00002517          	auipc	a0,0x2
ffffffffc02005b2:	bd250513          	addi	a0,a0,-1070 # ffffffffc0202180 <commands+0x260>
ffffffffc02005b6:	b05ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005ba:	784c                	ld	a1,176(s0)
ffffffffc02005bc:	00002517          	auipc	a0,0x2
ffffffffc02005c0:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0202198 <commands+0x278>
ffffffffc02005c4:	af7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c8:	7c4c                	ld	a1,184(s0)
ffffffffc02005ca:	00002517          	auipc	a0,0x2
ffffffffc02005ce:	be650513          	addi	a0,a0,-1050 # ffffffffc02021b0 <commands+0x290>
ffffffffc02005d2:	ae9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d6:	606c                	ld	a1,192(s0)
ffffffffc02005d8:	00002517          	auipc	a0,0x2
ffffffffc02005dc:	bf050513          	addi	a0,a0,-1040 # ffffffffc02021c8 <commands+0x2a8>
ffffffffc02005e0:	adbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e4:	646c                	ld	a1,200(s0)
ffffffffc02005e6:	00002517          	auipc	a0,0x2
ffffffffc02005ea:	bfa50513          	addi	a0,a0,-1030 # ffffffffc02021e0 <commands+0x2c0>
ffffffffc02005ee:	acdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f2:	686c                	ld	a1,208(s0)
ffffffffc02005f4:	00002517          	auipc	a0,0x2
ffffffffc02005f8:	c0450513          	addi	a0,a0,-1020 # ffffffffc02021f8 <commands+0x2d8>
ffffffffc02005fc:	abfff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200600:	6c6c                	ld	a1,216(s0)
ffffffffc0200602:	00002517          	auipc	a0,0x2
ffffffffc0200606:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0202210 <commands+0x2f0>
ffffffffc020060a:	ab1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060e:	706c                	ld	a1,224(s0)
ffffffffc0200610:	00002517          	auipc	a0,0x2
ffffffffc0200614:	c1850513          	addi	a0,a0,-1000 # ffffffffc0202228 <commands+0x308>
ffffffffc0200618:	aa3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061c:	746c                	ld	a1,232(s0)
ffffffffc020061e:	00002517          	auipc	a0,0x2
ffffffffc0200622:	c2250513          	addi	a0,a0,-990 # ffffffffc0202240 <commands+0x320>
ffffffffc0200626:	a95ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020062a:	786c                	ld	a1,240(s0)
ffffffffc020062c:	00002517          	auipc	a0,0x2
ffffffffc0200630:	c2c50513          	addi	a0,a0,-980 # ffffffffc0202258 <commands+0x338>
ffffffffc0200634:	a87ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200638:	7c6c                	ld	a1,248(s0)
}
ffffffffc020063a:	6402                	ld	s0,0(sp)
ffffffffc020063c:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063e:	00002517          	auipc	a0,0x2
ffffffffc0200642:	c3250513          	addi	a0,a0,-974 # ffffffffc0202270 <commands+0x350>
}
ffffffffc0200646:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200648:	bc8d                	j	ffffffffc02000ba <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	c3650513          	addi	a0,a0,-970 # ffffffffc0202288 <commands+0x368>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1dff0ef          	jal	ra,ffffffffc020047e <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	c3650513          	addi	a0,a0,-970 # ffffffffc02022a0 <commands+0x380>
ffffffffc0200672:	a49ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	c3e50513          	addi	a0,a0,-962 # ffffffffc02022b8 <commands+0x398>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	c4650513          	addi	a0,a0,-954 # ffffffffc02022d0 <commands+0x3b0>
ffffffffc0200692:	a29ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	c4a50513          	addi	a0,a0,-950 # ffffffffc02022e8 <commands+0x3c8>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	bc09                	j	ffffffffc02000ba <cprintf>

ffffffffc02006aa <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006aa:	11853783          	ld	a5,280(a0)
ffffffffc02006ae:	472d                	li	a4,11
ffffffffc02006b0:	0786                	slli	a5,a5,0x1
ffffffffc02006b2:	8385                	srli	a5,a5,0x1
ffffffffc02006b4:	06f76c63          	bltu	a4,a5,ffffffffc020072c <interrupt_handler+0x82>
ffffffffc02006b8:	00002717          	auipc	a4,0x2
ffffffffc02006bc:	d1070713          	addi	a4,a4,-752 # ffffffffc02023c8 <commands+0x4a8>
ffffffffc02006c0:	078a                	slli	a5,a5,0x2
ffffffffc02006c2:	97ba                	add	a5,a5,a4
ffffffffc02006c4:	439c                	lw	a5,0(a5)
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ca:	00002517          	auipc	a0,0x2
ffffffffc02006ce:	c9650513          	addi	a0,a0,-874 # ffffffffc0202360 <commands+0x440>
ffffffffc02006d2:	b2e5                	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006d4:	00002517          	auipc	a0,0x2
ffffffffc02006d8:	c6c50513          	addi	a0,a0,-916 # ffffffffc0202340 <commands+0x420>
ffffffffc02006dc:	baf9                	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006de:	00002517          	auipc	a0,0x2
ffffffffc02006e2:	c2250513          	addi	a0,a0,-990 # ffffffffc0202300 <commands+0x3e0>
ffffffffc02006e6:	bad1                	j	ffffffffc02000ba <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e8:	00002517          	auipc	a0,0x2
ffffffffc02006ec:	c9850513          	addi	a0,a0,-872 # ffffffffc0202380 <commands+0x460>
ffffffffc02006f0:	b2e9                	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006f2:	1141                	addi	sp,sp,-16
ffffffffc02006f4:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006f6:	d4dff0ef          	jal	ra,ffffffffc0200442 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006fa:	00006697          	auipc	a3,0x6
ffffffffc02006fe:	d4e68693          	addi	a3,a3,-690 # ffffffffc0206448 <ticks>
ffffffffc0200702:	629c                	ld	a5,0(a3)
ffffffffc0200704:	06400713          	li	a4,100
ffffffffc0200708:	0785                	addi	a5,a5,1
ffffffffc020070a:	02e7f733          	remu	a4,a5,a4
ffffffffc020070e:	e29c                	sd	a5,0(a3)
ffffffffc0200710:	cf19                	beqz	a4,ffffffffc020072e <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200712:	60a2                	ld	ra,8(sp)
ffffffffc0200714:	0141                	addi	sp,sp,16
ffffffffc0200716:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200718:	00002517          	auipc	a0,0x2
ffffffffc020071c:	c9050513          	addi	a0,a0,-880 # ffffffffc02023a8 <commands+0x488>
ffffffffc0200720:	ba69                	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200722:	00002517          	auipc	a0,0x2
ffffffffc0200726:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0202320 <commands+0x400>
ffffffffc020072a:	ba41                	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc020072c:	bf39                	j	ffffffffc020064a <print_trapframe>
}
ffffffffc020072e:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200730:	06400593          	li	a1,100
ffffffffc0200734:	00002517          	auipc	a0,0x2
ffffffffc0200738:	c6450513          	addi	a0,a0,-924 # ffffffffc0202398 <commands+0x478>
}
ffffffffc020073c:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020073e:	bab5                	j	ffffffffc02000ba <cprintf>

ffffffffc0200740 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200740:	11853783          	ld	a5,280(a0)
ffffffffc0200744:	0007c763          	bltz	a5,ffffffffc0200752 <trap+0x12>
    switch (tf->cause) {
ffffffffc0200748:	472d                	li	a4,11
ffffffffc020074a:	00f76363          	bltu	a4,a5,ffffffffc0200750 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc020074e:	8082                	ret
            print_trapframe(tf);
ffffffffc0200750:	bded                	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc0200752:	bfa1                	j	ffffffffc02006aa <interrupt_handler>

ffffffffc0200754 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200754:	14011073          	csrw	sscratch,sp
ffffffffc0200758:	712d                	addi	sp,sp,-288
ffffffffc020075a:	e002                	sd	zero,0(sp)
ffffffffc020075c:	e406                	sd	ra,8(sp)
ffffffffc020075e:	ec0e                	sd	gp,24(sp)
ffffffffc0200760:	f012                	sd	tp,32(sp)
ffffffffc0200762:	f416                	sd	t0,40(sp)
ffffffffc0200764:	f81a                	sd	t1,48(sp)
ffffffffc0200766:	fc1e                	sd	t2,56(sp)
ffffffffc0200768:	e0a2                	sd	s0,64(sp)
ffffffffc020076a:	e4a6                	sd	s1,72(sp)
ffffffffc020076c:	e8aa                	sd	a0,80(sp)
ffffffffc020076e:	ecae                	sd	a1,88(sp)
ffffffffc0200770:	f0b2                	sd	a2,96(sp)
ffffffffc0200772:	f4b6                	sd	a3,104(sp)
ffffffffc0200774:	f8ba                	sd	a4,112(sp)
ffffffffc0200776:	fcbe                	sd	a5,120(sp)
ffffffffc0200778:	e142                	sd	a6,128(sp)
ffffffffc020077a:	e546                	sd	a7,136(sp)
ffffffffc020077c:	e94a                	sd	s2,144(sp)
ffffffffc020077e:	ed4e                	sd	s3,152(sp)
ffffffffc0200780:	f152                	sd	s4,160(sp)
ffffffffc0200782:	f556                	sd	s5,168(sp)
ffffffffc0200784:	f95a                	sd	s6,176(sp)
ffffffffc0200786:	fd5e                	sd	s7,184(sp)
ffffffffc0200788:	e1e2                	sd	s8,192(sp)
ffffffffc020078a:	e5e6                	sd	s9,200(sp)
ffffffffc020078c:	e9ea                	sd	s10,208(sp)
ffffffffc020078e:	edee                	sd	s11,216(sp)
ffffffffc0200790:	f1f2                	sd	t3,224(sp)
ffffffffc0200792:	f5f6                	sd	t4,232(sp)
ffffffffc0200794:	f9fa                	sd	t5,240(sp)
ffffffffc0200796:	fdfe                	sd	t6,248(sp)
ffffffffc0200798:	14001473          	csrrw	s0,sscratch,zero
ffffffffc020079c:	100024f3          	csrr	s1,sstatus
ffffffffc02007a0:	14102973          	csrr	s2,sepc
ffffffffc02007a4:	143029f3          	csrr	s3,stval
ffffffffc02007a8:	14202a73          	csrr	s4,scause
ffffffffc02007ac:	e822                	sd	s0,16(sp)
ffffffffc02007ae:	e226                	sd	s1,256(sp)
ffffffffc02007b0:	e64a                	sd	s2,264(sp)
ffffffffc02007b2:	ea4e                	sd	s3,272(sp)
ffffffffc02007b4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007b6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b8:	f89ff0ef          	jal	ra,ffffffffc0200740 <trap>

ffffffffc02007bc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007bc:	6492                	ld	s1,256(sp)
ffffffffc02007be:	6932                	ld	s2,264(sp)
ffffffffc02007c0:	10049073          	csrw	sstatus,s1
ffffffffc02007c4:	14191073          	csrw	sepc,s2
ffffffffc02007c8:	60a2                	ld	ra,8(sp)
ffffffffc02007ca:	61e2                	ld	gp,24(sp)
ffffffffc02007cc:	7202                	ld	tp,32(sp)
ffffffffc02007ce:	72a2                	ld	t0,40(sp)
ffffffffc02007d0:	7342                	ld	t1,48(sp)
ffffffffc02007d2:	73e2                	ld	t2,56(sp)
ffffffffc02007d4:	6406                	ld	s0,64(sp)
ffffffffc02007d6:	64a6                	ld	s1,72(sp)
ffffffffc02007d8:	6546                	ld	a0,80(sp)
ffffffffc02007da:	65e6                	ld	a1,88(sp)
ffffffffc02007dc:	7606                	ld	a2,96(sp)
ffffffffc02007de:	76a6                	ld	a3,104(sp)
ffffffffc02007e0:	7746                	ld	a4,112(sp)
ffffffffc02007e2:	77e6                	ld	a5,120(sp)
ffffffffc02007e4:	680a                	ld	a6,128(sp)
ffffffffc02007e6:	68aa                	ld	a7,136(sp)
ffffffffc02007e8:	694a                	ld	s2,144(sp)
ffffffffc02007ea:	69ea                	ld	s3,152(sp)
ffffffffc02007ec:	7a0a                	ld	s4,160(sp)
ffffffffc02007ee:	7aaa                	ld	s5,168(sp)
ffffffffc02007f0:	7b4a                	ld	s6,176(sp)
ffffffffc02007f2:	7bea                	ld	s7,184(sp)
ffffffffc02007f4:	6c0e                	ld	s8,192(sp)
ffffffffc02007f6:	6cae                	ld	s9,200(sp)
ffffffffc02007f8:	6d4e                	ld	s10,208(sp)
ffffffffc02007fa:	6dee                	ld	s11,216(sp)
ffffffffc02007fc:	7e0e                	ld	t3,224(sp)
ffffffffc02007fe:	7eae                	ld	t4,232(sp)
ffffffffc0200800:	7f4e                	ld	t5,240(sp)
ffffffffc0200802:	7fee                	ld	t6,248(sp)
ffffffffc0200804:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200806:	10200073          	sret

ffffffffc020080a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020080a:	100027f3          	csrr	a5,sstatus
ffffffffc020080e:	8b89                	andi	a5,a5,2
ffffffffc0200810:	e799                	bnez	a5,ffffffffc020081e <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200812:	00006797          	auipc	a5,0x6
ffffffffc0200816:	c4e7b783          	ld	a5,-946(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc020081a:	6f9c                	ld	a5,24(a5)
ffffffffc020081c:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
ffffffffc0200822:	e022                	sd	s0,0(sp)
ffffffffc0200824:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200826:	c41ff0ef          	jal	ra,ffffffffc0200466 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020082a:	00006797          	auipc	a5,0x6
ffffffffc020082e:	c367b783          	ld	a5,-970(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0200832:	6f9c                	ld	a5,24(a5)
ffffffffc0200834:	8522                	mv	a0,s0
ffffffffc0200836:	9782                	jalr	a5
ffffffffc0200838:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020083a:	c27ff0ef          	jal	ra,ffffffffc0200460 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020083e:	60a2                	ld	ra,8(sp)
ffffffffc0200840:	8522                	mv	a0,s0
ffffffffc0200842:	6402                	ld	s0,0(sp)
ffffffffc0200844:	0141                	addi	sp,sp,16
ffffffffc0200846:	8082                	ret

ffffffffc0200848 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200848:	100027f3          	csrr	a5,sstatus
ffffffffc020084c:	8b89                	andi	a5,a5,2
ffffffffc020084e:	e799                	bnez	a5,ffffffffc020085c <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200850:	00006797          	auipc	a5,0x6
ffffffffc0200854:	c107b783          	ld	a5,-1008(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0200858:	739c                	ld	a5,32(a5)
ffffffffc020085a:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc020085c:	1101                	addi	sp,sp,-32
ffffffffc020085e:	ec06                	sd	ra,24(sp)
ffffffffc0200860:	e822                	sd	s0,16(sp)
ffffffffc0200862:	e426                	sd	s1,8(sp)
ffffffffc0200864:	842a                	mv	s0,a0
ffffffffc0200866:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200868:	bffff0ef          	jal	ra,ffffffffc0200466 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020086c:	00006797          	auipc	a5,0x6
ffffffffc0200870:	bf47b783          	ld	a5,-1036(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0200874:	739c                	ld	a5,32(a5)
ffffffffc0200876:	85a6                	mv	a1,s1
ffffffffc0200878:	8522                	mv	a0,s0
ffffffffc020087a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020087c:	6442                	ld	s0,16(sp)
ffffffffc020087e:	60e2                	ld	ra,24(sp)
ffffffffc0200880:	64a2                	ld	s1,8(sp)
ffffffffc0200882:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200884:	bef1                	j	ffffffffc0200460 <intr_enable>

ffffffffc0200886 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200886:	100027f3          	csrr	a5,sstatus
ffffffffc020088a:	8b89                	andi	a5,a5,2
ffffffffc020088c:	e799                	bnez	a5,ffffffffc020089a <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020088e:	00006797          	auipc	a5,0x6
ffffffffc0200892:	bd27b783          	ld	a5,-1070(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0200896:	779c                	ld	a5,40(a5)
ffffffffc0200898:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020089a:	1141                	addi	sp,sp,-16
ffffffffc020089c:	e406                	sd	ra,8(sp)
ffffffffc020089e:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02008a0:	bc7ff0ef          	jal	ra,ffffffffc0200466 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02008a4:	00006797          	auipc	a5,0x6
ffffffffc02008a8:	bbc7b783          	ld	a5,-1092(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc02008ac:	779c                	ld	a5,40(a5)
ffffffffc02008ae:	9782                	jalr	a5
ffffffffc02008b0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02008b2:	bafff0ef          	jal	ra,ffffffffc0200460 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02008b6:	60a2                	ld	ra,8(sp)
ffffffffc02008b8:	8522                	mv	a0,s0
ffffffffc02008ba:	6402                	ld	s0,0(sp)
ffffffffc02008bc:	0141                	addi	sp,sp,16
ffffffffc02008be:	8082                	ret

ffffffffc02008c0 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02008c0:	00002797          	auipc	a5,0x2
ffffffffc02008c4:	fa878793          	addi	a5,a5,-88 # ffffffffc0202868 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008c8:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02008ca:	1101                	addi	sp,sp,-32
ffffffffc02008cc:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008ce:	00002517          	auipc	a0,0x2
ffffffffc02008d2:	b2a50513          	addi	a0,a0,-1238 # ffffffffc02023f8 <commands+0x4d8>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02008d6:	00006497          	auipc	s1,0x6
ffffffffc02008da:	b8a48493          	addi	s1,s1,-1142 # ffffffffc0206460 <pmm_manager>
void pmm_init(void) {
ffffffffc02008de:	ec06                	sd	ra,24(sp)
ffffffffc02008e0:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02008e2:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008e4:	fd6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc02008e8:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;//硬编码 0xFFFFFFFF40000000(虚拟地址与物理地址间的偏移量)
ffffffffc02008ea:	00006417          	auipc	s0,0x6
ffffffffc02008ee:	b8e40413          	addi	s0,s0,-1138 # ffffffffc0206478 <va_pa_offset>
    pmm_manager->init();
ffffffffc02008f2:	679c                	ld	a5,8(a5)
ffffffffc02008f4:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;//硬编码 0xFFFFFFFF40000000(虚拟地址与物理地址间的偏移量)
ffffffffc02008f6:	57f5                	li	a5,-3
ffffffffc02008f8:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02008fa:	00002517          	auipc	a0,0x2
ffffffffc02008fe:	b1650513          	addi	a0,a0,-1258 # ffffffffc0202410 <commands+0x4f0>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;//硬编码 0xFFFFFFFF40000000(虚拟地址与物理地址间的偏移量)
ffffffffc0200902:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200904:	fb6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200908:	46c5                	li	a3,17
ffffffffc020090a:	06ee                	slli	a3,a3,0x1b
ffffffffc020090c:	40100613          	li	a2,1025
ffffffffc0200910:	16fd                	addi	a3,a3,-1
ffffffffc0200912:	07e005b7          	lui	a1,0x7e00
ffffffffc0200916:	0656                	slli	a2,a2,0x15
ffffffffc0200918:	00002517          	auipc	a0,0x2
ffffffffc020091c:	b1050513          	addi	a0,a0,-1264 # ffffffffc0202428 <commands+0x508>
ffffffffc0200920:	f9aff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200924:	777d                	lui	a4,0xfffff
ffffffffc0200926:	00007797          	auipc	a5,0x7
ffffffffc020092a:	b6978793          	addi	a5,a5,-1175 # ffffffffc020748f <end+0xfff>
ffffffffc020092e:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200930:	00006517          	auipc	a0,0x6
ffffffffc0200934:	b2050513          	addi	a0,a0,-1248 # ffffffffc0206450 <npage>
ffffffffc0200938:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020093c:	00006597          	auipc	a1,0x6
ffffffffc0200940:	b1c58593          	addi	a1,a1,-1252 # ffffffffc0206458 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200944:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200946:	e19c                	sd	a5,0(a1)
ffffffffc0200948:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020094a:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020094c:	4885                	li	a7,1
ffffffffc020094e:	fff80837          	lui	a6,0xfff80
ffffffffc0200952:	a011                	j	ffffffffc0200956 <pmm_init+0x96>
        SetPageReserved(pages + i); // 在kern/mm/memlayout.h定义的
ffffffffc0200954:	619c                	ld	a5,0(a1)
ffffffffc0200956:	97b6                	add	a5,a5,a3
ffffffffc0200958:	07a1                	addi	a5,a5,8
ffffffffc020095a:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020095e:	611c                	ld	a5,0(a0)
ffffffffc0200960:	0705                	addi	a4,a4,1
ffffffffc0200962:	02868693          	addi	a3,a3,40
ffffffffc0200966:	01078633          	add	a2,a5,a6
ffffffffc020096a:	fec765e3          	bltu	a4,a2,ffffffffc0200954 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020096e:	6190                	ld	a2,0(a1)
ffffffffc0200970:	00279713          	slli	a4,a5,0x2
ffffffffc0200974:	973e                	add	a4,a4,a5
ffffffffc0200976:	fec006b7          	lui	a3,0xfec00
ffffffffc020097a:	070e                	slli	a4,a4,0x3
ffffffffc020097c:	96b2                	add	a3,a3,a2
ffffffffc020097e:	96ba                	add	a3,a3,a4
ffffffffc0200980:	c0200737          	lui	a4,0xc0200
ffffffffc0200984:	08e6ef63          	bltu	a3,a4,ffffffffc0200a22 <pmm_init+0x162>
ffffffffc0200988:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc020098a:	45c5                	li	a1,17
ffffffffc020098c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020098e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200990:	04b6e863          	bltu	a3,a1,ffffffffc02009e0 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200994:	609c                	ld	a5,0(s1)
ffffffffc0200996:	7b9c                	ld	a5,48(a5)
ffffffffc0200998:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020099a:	00002517          	auipc	a0,0x2
ffffffffc020099e:	b2650513          	addi	a0,a0,-1242 # ffffffffc02024c0 <commands+0x5a0>
ffffffffc02009a2:	f18ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02009a6:	00004597          	auipc	a1,0x4
ffffffffc02009aa:	65a58593          	addi	a1,a1,1626 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02009ae:	00006797          	auipc	a5,0x6
ffffffffc02009b2:	acb7b123          	sd	a1,-1342(a5) # ffffffffc0206470 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02009b6:	c02007b7          	lui	a5,0xc0200
ffffffffc02009ba:	08f5e063          	bltu	a1,a5,ffffffffc0200a3a <pmm_init+0x17a>
ffffffffc02009be:	6010                	ld	a2,0(s0)
}
ffffffffc02009c0:	6442                	ld	s0,16(sp)
ffffffffc02009c2:	60e2                	ld	ra,24(sp)
ffffffffc02009c4:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02009c6:	40c58633          	sub	a2,a1,a2
ffffffffc02009ca:	00006797          	auipc	a5,0x6
ffffffffc02009ce:	a8c7bf23          	sd	a2,-1378(a5) # ffffffffc0206468 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009d2:	00002517          	auipc	a0,0x2
ffffffffc02009d6:	b0e50513          	addi	a0,a0,-1266 # ffffffffc02024e0 <commands+0x5c0>
}
ffffffffc02009da:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009dc:	edeff06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02009e0:	6705                	lui	a4,0x1
ffffffffc02009e2:	177d                	addi	a4,a4,-1
ffffffffc02009e4:	96ba                	add	a3,a3,a4
ffffffffc02009e6:	777d                	lui	a4,0xfffff
ffffffffc02009e8:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02009ea:	00c6d513          	srli	a0,a3,0xc
ffffffffc02009ee:	00f57e63          	bgeu	a0,a5,ffffffffc0200a0a <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02009f2:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02009f4:	982a                	add	a6,a6,a0
ffffffffc02009f6:	00281513          	slli	a0,a6,0x2
ffffffffc02009fa:	9542                	add	a0,a0,a6
ffffffffc02009fc:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02009fe:	8d95                	sub	a1,a1,a3
ffffffffc0200a00:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200a02:	81b1                	srli	a1,a1,0xc
ffffffffc0200a04:	9532                	add	a0,a0,a2
ffffffffc0200a06:	9782                	jalr	a5
}
ffffffffc0200a08:	b771                	j	ffffffffc0200994 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200a0a:	00002617          	auipc	a2,0x2
ffffffffc0200a0e:	a8660613          	addi	a2,a2,-1402 # ffffffffc0202490 <commands+0x570>
ffffffffc0200a12:	06f00593          	li	a1,111
ffffffffc0200a16:	00002517          	auipc	a0,0x2
ffffffffc0200a1a:	a9a50513          	addi	a0,a0,-1382 # ffffffffc02024b0 <commands+0x590>
ffffffffc0200a1e:	f24ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a22:	00002617          	auipc	a2,0x2
ffffffffc0200a26:	a3660613          	addi	a2,a2,-1482 # ffffffffc0202458 <commands+0x538>
ffffffffc0200a2a:	07700593          	li	a1,119
ffffffffc0200a2e:	00002517          	auipc	a0,0x2
ffffffffc0200a32:	a5250513          	addi	a0,a0,-1454 # ffffffffc0202480 <commands+0x560>
ffffffffc0200a36:	f0cff0ef          	jal	ra,ffffffffc0200142 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a3a:	86ae                	mv	a3,a1
ffffffffc0200a3c:	00002617          	auipc	a2,0x2
ffffffffc0200a40:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0202458 <commands+0x538>
ffffffffc0200a44:	09300593          	li	a1,147
ffffffffc0200a48:	00002517          	auipc	a0,0x2
ffffffffc0200a4c:	a3850513          	addi	a0,a0,-1480 # ffffffffc0202480 <commands+0x560>
ffffffffc0200a50:	ef2ff0ef          	jal	ra,ffffffffc0200142 <__panic>

ffffffffc0200a54 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200a54:	00005797          	auipc	a5,0x5
ffffffffc0200a58:	5d478793          	addi	a5,a5,1492 # ffffffffc0206028 <free_area>
ffffffffc0200a5c:	e79c                	sd	a5,8(a5)
ffffffffc0200a5e:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200a60:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200a64:	8082                	ret

ffffffffc0200a66 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200a66:	00005517          	auipc	a0,0x5
ffffffffc0200a6a:	5d256503          	lwu	a0,1490(a0) # ffffffffc0206038 <free_area+0x10>
ffffffffc0200a6e:	8082                	ret

ffffffffc0200a70 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200a70:	c14d                	beqz	a0,ffffffffc0200b12 <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc0200a72:	00005617          	auipc	a2,0x5
ffffffffc0200a76:	5b660613          	addi	a2,a2,1462 # ffffffffc0206028 <free_area>
ffffffffc0200a7a:	01062803          	lw	a6,16(a2)
ffffffffc0200a7e:	86aa                	mv	a3,a0
ffffffffc0200a80:	02081793          	slli	a5,a6,0x20
ffffffffc0200a84:	9381                	srli	a5,a5,0x20
ffffffffc0200a86:	08a7e463          	bltu	a5,a0,ffffffffc0200b0e <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200a8a:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc0200a8c:	0018059b          	addiw	a1,a6,1
ffffffffc0200a90:	1582                	slli	a1,a1,0x20
ffffffffc0200a92:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc0200a94:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a96:	06c78b63          	beq	a5,a2,ffffffffc0200b0c <best_fit_alloc_pages+0x9c>
        if (p->property >= n && p->property < min_size) {
ffffffffc0200a9a:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200a9e:	00d76763          	bltu	a4,a3,ffffffffc0200aac <best_fit_alloc_pages+0x3c>
ffffffffc0200aa2:	00b77563          	bgeu	a4,a1,ffffffffc0200aac <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200aa6:	fe878513          	addi	a0,a5,-24
ffffffffc0200aaa:	85ba                	mv	a1,a4
ffffffffc0200aac:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200aae:	fec796e3          	bne	a5,a2,ffffffffc0200a9a <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc0200ab2:	cd29                	beqz	a0,ffffffffc0200b0c <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ab4:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200ab6:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc0200ab8:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc0200aba:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200abe:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200ac0:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc0200ac2:	02059793          	slli	a5,a1,0x20
ffffffffc0200ac6:	9381                	srli	a5,a5,0x20
ffffffffc0200ac8:	02f6f863          	bgeu	a3,a5,ffffffffc0200af8 <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc0200acc:	00269793          	slli	a5,a3,0x2
ffffffffc0200ad0:	97b6                	add	a5,a5,a3
ffffffffc0200ad2:	078e                	slli	a5,a5,0x3
ffffffffc0200ad4:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc0200ad6:	411585bb          	subw	a1,a1,a7
ffffffffc0200ada:	cb8c                	sw	a1,16(a5)
ffffffffc0200adc:	4689                	li	a3,2
ffffffffc0200ade:	00878593          	addi	a1,a5,8
ffffffffc0200ae2:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ae6:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc0200ae8:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc0200aec:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc0200af0:	e28c                	sd	a1,0(a3)
ffffffffc0200af2:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0200af4:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc0200af6:	ef98                	sd	a4,24(a5)
ffffffffc0200af8:	4118083b          	subw	a6,a6,a7
ffffffffc0200afc:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200b00:	57f5                	li	a5,-3
ffffffffc0200b02:	00850713          	addi	a4,a0,8
ffffffffc0200b06:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200b0a:	8082                	ret
}
ffffffffc0200b0c:	8082                	ret
        return NULL;
ffffffffc0200b0e:	4501                	li	a0,0
ffffffffc0200b10:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200b12:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200b14:	00002697          	auipc	a3,0x2
ffffffffc0200b18:	a0c68693          	addi	a3,a3,-1524 # ffffffffc0202520 <commands+0x600>
ffffffffc0200b1c:	00002617          	auipc	a2,0x2
ffffffffc0200b20:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0202528 <commands+0x608>
ffffffffc0200b24:	06a00593          	li	a1,106
ffffffffc0200b28:	00002517          	auipc	a0,0x2
ffffffffc0200b2c:	a1850513          	addi	a0,a0,-1512 # ffffffffc0202540 <commands+0x620>
best_fit_alloc_pages(size_t n) {
ffffffffc0200b30:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200b32:	e10ff0ef          	jal	ra,ffffffffc0200142 <__panic>

ffffffffc0200b36 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200b36:	715d                	addi	sp,sp,-80
ffffffffc0200b38:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0200b3a:	00005417          	auipc	s0,0x5
ffffffffc0200b3e:	4ee40413          	addi	s0,s0,1262 # ffffffffc0206028 <free_area>
ffffffffc0200b42:	641c                	ld	a5,8(s0)
ffffffffc0200b44:	e486                	sd	ra,72(sp)
ffffffffc0200b46:	fc26                	sd	s1,56(sp)
ffffffffc0200b48:	f84a                	sd	s2,48(sp)
ffffffffc0200b4a:	f44e                	sd	s3,40(sp)
ffffffffc0200b4c:	f052                	sd	s4,32(sp)
ffffffffc0200b4e:	ec56                	sd	s5,24(sp)
ffffffffc0200b50:	e85a                	sd	s6,16(sp)
ffffffffc0200b52:	e45e                	sd	s7,8(sp)
ffffffffc0200b54:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b56:	26878b63          	beq	a5,s0,ffffffffc0200dcc <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc0200b5a:	4481                	li	s1,0
ffffffffc0200b5c:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b5e:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b62:	8b09                	andi	a4,a4,2
ffffffffc0200b64:	26070863          	beqz	a4,ffffffffc0200dd4 <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc0200b68:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b6c:	679c                	ld	a5,8(a5)
ffffffffc0200b6e:	2905                	addiw	s2,s2,1
ffffffffc0200b70:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b72:	fe8796e3          	bne	a5,s0,ffffffffc0200b5e <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200b76:	89a6                	mv	s3,s1
ffffffffc0200b78:	d0fff0ef          	jal	ra,ffffffffc0200886 <nr_free_pages>
ffffffffc0200b7c:	33351c63          	bne	a0,s3,ffffffffc0200eb4 <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b80:	4505                	li	a0,1
ffffffffc0200b82:	c89ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200b86:	8a2a                	mv	s4,a0
ffffffffc0200b88:	36050663          	beqz	a0,ffffffffc0200ef4 <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b8c:	4505                	li	a0,1
ffffffffc0200b8e:	c7dff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200b92:	89aa                	mv	s3,a0
ffffffffc0200b94:	34050063          	beqz	a0,ffffffffc0200ed4 <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b98:	4505                	li	a0,1
ffffffffc0200b9a:	c71ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200b9e:	8aaa                	mv	s5,a0
ffffffffc0200ba0:	2c050a63          	beqz	a0,ffffffffc0200e74 <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ba4:	253a0863          	beq	s4,s3,ffffffffc0200df4 <best_fit_check+0x2be>
ffffffffc0200ba8:	24aa0663          	beq	s4,a0,ffffffffc0200df4 <best_fit_check+0x2be>
ffffffffc0200bac:	24a98463          	beq	s3,a0,ffffffffc0200df4 <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200bb0:	000a2783          	lw	a5,0(s4)
ffffffffc0200bb4:	26079063          	bnez	a5,ffffffffc0200e14 <best_fit_check+0x2de>
ffffffffc0200bb8:	0009a783          	lw	a5,0(s3)
ffffffffc0200bbc:	24079c63          	bnez	a5,ffffffffc0200e14 <best_fit_check+0x2de>
ffffffffc0200bc0:	411c                	lw	a5,0(a0)
ffffffffc0200bc2:	24079963          	bnez	a5,ffffffffc0200e14 <best_fit_check+0x2de>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bc6:	00006797          	auipc	a5,0x6
ffffffffc0200bca:	8927b783          	ld	a5,-1902(a5) # ffffffffc0206458 <pages>
ffffffffc0200bce:	40fa0733          	sub	a4,s4,a5
ffffffffc0200bd2:	870d                	srai	a4,a4,0x3
ffffffffc0200bd4:	00002597          	auipc	a1,0x2
ffffffffc0200bd8:	f9c5b583          	ld	a1,-100(a1) # ffffffffc0202b70 <nbase+0x8>
ffffffffc0200bdc:	02b70733          	mul	a4,a4,a1
ffffffffc0200be0:	00002617          	auipc	a2,0x2
ffffffffc0200be4:	f8863603          	ld	a2,-120(a2) # ffffffffc0202b68 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200be8:	00006697          	auipc	a3,0x6
ffffffffc0200bec:	8686b683          	ld	a3,-1944(a3) # ffffffffc0206450 <npage>
ffffffffc0200bf0:	06b2                	slli	a3,a3,0xc
ffffffffc0200bf2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bf4:	0732                	slli	a4,a4,0xc
ffffffffc0200bf6:	22d77f63          	bgeu	a4,a3,ffffffffc0200e34 <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bfa:	40f98733          	sub	a4,s3,a5
ffffffffc0200bfe:	870d                	srai	a4,a4,0x3
ffffffffc0200c00:	02b70733          	mul	a4,a4,a1
ffffffffc0200c04:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c06:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c08:	3ed77663          	bgeu	a4,a3,ffffffffc0200ff4 <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c0c:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c10:	878d                	srai	a5,a5,0x3
ffffffffc0200c12:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c16:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c18:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c1a:	3ad7fd63          	bgeu	a5,a3,ffffffffc0200fd4 <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc0200c1e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c20:	00043c03          	ld	s8,0(s0)
ffffffffc0200c24:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c28:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200c2c:	e400                	sd	s0,8(s0)
ffffffffc0200c2e:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200c30:	00005797          	auipc	a5,0x5
ffffffffc0200c34:	4007a423          	sw	zero,1032(a5) # ffffffffc0206038 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c38:	bd3ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200c3c:	36051c63          	bnez	a0,ffffffffc0200fb4 <best_fit_check+0x47e>
    free_page(p0);
ffffffffc0200c40:	4585                	li	a1,1
ffffffffc0200c42:	8552                	mv	a0,s4
ffffffffc0200c44:	c05ff0ef          	jal	ra,ffffffffc0200848 <free_pages>
    free_page(p1);
ffffffffc0200c48:	4585                	li	a1,1
ffffffffc0200c4a:	854e                	mv	a0,s3
ffffffffc0200c4c:	bfdff0ef          	jal	ra,ffffffffc0200848 <free_pages>
    free_page(p2);
ffffffffc0200c50:	4585                	li	a1,1
ffffffffc0200c52:	8556                	mv	a0,s5
ffffffffc0200c54:	bf5ff0ef          	jal	ra,ffffffffc0200848 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c58:	4818                	lw	a4,16(s0)
ffffffffc0200c5a:	478d                	li	a5,3
ffffffffc0200c5c:	32f71c63          	bne	a4,a5,ffffffffc0200f94 <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c60:	4505                	li	a0,1
ffffffffc0200c62:	ba9ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200c66:	89aa                	mv	s3,a0
ffffffffc0200c68:	30050663          	beqz	a0,ffffffffc0200f74 <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c6c:	4505                	li	a0,1
ffffffffc0200c6e:	b9dff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200c72:	8aaa                	mv	s5,a0
ffffffffc0200c74:	2e050063          	beqz	a0,ffffffffc0200f54 <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c78:	4505                	li	a0,1
ffffffffc0200c7a:	b91ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200c7e:	8a2a                	mv	s4,a0
ffffffffc0200c80:	2a050a63          	beqz	a0,ffffffffc0200f34 <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc0200c84:	4505                	li	a0,1
ffffffffc0200c86:	b85ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200c8a:	28051563          	bnez	a0,ffffffffc0200f14 <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200c8e:	4585                	li	a1,1
ffffffffc0200c90:	854e                	mv	a0,s3
ffffffffc0200c92:	bb7ff0ef          	jal	ra,ffffffffc0200848 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c96:	641c                	ld	a5,8(s0)
ffffffffc0200c98:	1a878e63          	beq	a5,s0,ffffffffc0200e54 <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200c9c:	4505                	li	a0,1
ffffffffc0200c9e:	b6dff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200ca2:	52a99963          	bne	s3,a0,ffffffffc02011d4 <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc0200ca6:	4505                	li	a0,1
ffffffffc0200ca8:	b63ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200cac:	50051463          	bnez	a0,ffffffffc02011b4 <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200cb0:	481c                	lw	a5,16(s0)
ffffffffc0200cb2:	4e079163          	bnez	a5,ffffffffc0201194 <best_fit_check+0x65e>
    free_page(p);
ffffffffc0200cb6:	854e                	mv	a0,s3
ffffffffc0200cb8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200cba:	01843023          	sd	s8,0(s0)
ffffffffc0200cbe:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200cc2:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200cc6:	b83ff0ef          	jal	ra,ffffffffc0200848 <free_pages>
    free_page(p1);
ffffffffc0200cca:	4585                	li	a1,1
ffffffffc0200ccc:	8556                	mv	a0,s5
ffffffffc0200cce:	b7bff0ef          	jal	ra,ffffffffc0200848 <free_pages>
    free_page(p2);
ffffffffc0200cd2:	4585                	li	a1,1
ffffffffc0200cd4:	8552                	mv	a0,s4
ffffffffc0200cd6:	b73ff0ef          	jal	ra,ffffffffc0200848 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200cda:	4515                	li	a0,5
ffffffffc0200cdc:	b2fff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200ce0:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200ce2:	48050963          	beqz	a0,ffffffffc0201174 <best_fit_check+0x63e>
ffffffffc0200ce6:	651c                	ld	a5,8(a0)
ffffffffc0200ce8:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200cea:	8b85                	andi	a5,a5,1
ffffffffc0200cec:	46079463          	bnez	a5,ffffffffc0201154 <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200cf0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cf2:	00043a83          	ld	s5,0(s0)
ffffffffc0200cf6:	00843a03          	ld	s4,8(s0)
ffffffffc0200cfa:	e000                	sd	s0,0(s0)
ffffffffc0200cfc:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200cfe:	b0dff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200d02:	42051963          	bnez	a0,ffffffffc0201134 <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200d06:	4589                	li	a1,2
ffffffffc0200d08:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200d0c:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200d10:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200d14:	00005797          	auipc	a5,0x5
ffffffffc0200d18:	3207a223          	sw	zero,804(a5) # ffffffffc0206038 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200d1c:	b2dff0ef          	jal	ra,ffffffffc0200848 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200d20:	8562                	mv	a0,s8
ffffffffc0200d22:	4585                	li	a1,1
ffffffffc0200d24:	b25ff0ef          	jal	ra,ffffffffc0200848 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d28:	4511                	li	a0,4
ffffffffc0200d2a:	ae1ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200d2e:	3e051363          	bnez	a0,ffffffffc0201114 <best_fit_check+0x5de>
ffffffffc0200d32:	0309b783          	ld	a5,48(s3)
ffffffffc0200d36:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200d38:	8b85                	andi	a5,a5,1
ffffffffc0200d3a:	3a078d63          	beqz	a5,ffffffffc02010f4 <best_fit_check+0x5be>
ffffffffc0200d3e:	0389a703          	lw	a4,56(s3)
ffffffffc0200d42:	4789                	li	a5,2
ffffffffc0200d44:	3af71863          	bne	a4,a5,ffffffffc02010f4 <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200d48:	4505                	li	a0,1
ffffffffc0200d4a:	ac1ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200d4e:	8baa                	mv	s7,a0
ffffffffc0200d50:	38050263          	beqz	a0,ffffffffc02010d4 <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200d54:	4509                	li	a0,2
ffffffffc0200d56:	ab5ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200d5a:	34050d63          	beqz	a0,ffffffffc02010b4 <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0200d5e:	337c1b63          	bne	s8,s7,ffffffffc0201094 <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200d62:	854e                	mv	a0,s3
ffffffffc0200d64:	4595                	li	a1,5
ffffffffc0200d66:	ae3ff0ef          	jal	ra,ffffffffc0200848 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d6a:	4515                	li	a0,5
ffffffffc0200d6c:	a9fff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200d70:	89aa                	mv	s3,a0
ffffffffc0200d72:	30050163          	beqz	a0,ffffffffc0201074 <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0200d76:	4505                	li	a0,1
ffffffffc0200d78:	a93ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200d7c:	2c051c63          	bnez	a0,ffffffffc0201054 <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200d80:	481c                	lw	a5,16(s0)
ffffffffc0200d82:	2a079963          	bnez	a5,ffffffffc0201034 <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200d86:	4595                	li	a1,5
ffffffffc0200d88:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200d8a:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200d8e:	01543023          	sd	s5,0(s0)
ffffffffc0200d92:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200d96:	ab3ff0ef          	jal	ra,ffffffffc0200848 <free_pages>
    return listelm->next;
ffffffffc0200d9a:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d9c:	00878963          	beq	a5,s0,ffffffffc0200dae <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200da0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200da4:	679c                	ld	a5,8(a5)
ffffffffc0200da6:	397d                	addiw	s2,s2,-1
ffffffffc0200da8:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200daa:	fe879be3          	bne	a5,s0,ffffffffc0200da0 <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0200dae:	26091363          	bnez	s2,ffffffffc0201014 <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0200db2:	e0ed                	bnez	s1,ffffffffc0200e94 <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200db4:	60a6                	ld	ra,72(sp)
ffffffffc0200db6:	6406                	ld	s0,64(sp)
ffffffffc0200db8:	74e2                	ld	s1,56(sp)
ffffffffc0200dba:	7942                	ld	s2,48(sp)
ffffffffc0200dbc:	79a2                	ld	s3,40(sp)
ffffffffc0200dbe:	7a02                	ld	s4,32(sp)
ffffffffc0200dc0:	6ae2                	ld	s5,24(sp)
ffffffffc0200dc2:	6b42                	ld	s6,16(sp)
ffffffffc0200dc4:	6ba2                	ld	s7,8(sp)
ffffffffc0200dc6:	6c02                	ld	s8,0(sp)
ffffffffc0200dc8:	6161                	addi	sp,sp,80
ffffffffc0200dca:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dcc:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200dce:	4481                	li	s1,0
ffffffffc0200dd0:	4901                	li	s2,0
ffffffffc0200dd2:	b35d                	j	ffffffffc0200b78 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200dd4:	00001697          	auipc	a3,0x1
ffffffffc0200dd8:	78468693          	addi	a3,a3,1924 # ffffffffc0202558 <commands+0x638>
ffffffffc0200ddc:	00001617          	auipc	a2,0x1
ffffffffc0200de0:	74c60613          	addi	a2,a2,1868 # ffffffffc0202528 <commands+0x608>
ffffffffc0200de4:	10d00593          	li	a1,269
ffffffffc0200de8:	00001517          	auipc	a0,0x1
ffffffffc0200dec:	75850513          	addi	a0,a0,1880 # ffffffffc0202540 <commands+0x620>
ffffffffc0200df0:	b52ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200df4:	00001697          	auipc	a3,0x1
ffffffffc0200df8:	7f468693          	addi	a3,a3,2036 # ffffffffc02025e8 <commands+0x6c8>
ffffffffc0200dfc:	00001617          	auipc	a2,0x1
ffffffffc0200e00:	72c60613          	addi	a2,a2,1836 # ffffffffc0202528 <commands+0x608>
ffffffffc0200e04:	0d900593          	li	a1,217
ffffffffc0200e08:	00001517          	auipc	a0,0x1
ffffffffc0200e0c:	73850513          	addi	a0,a0,1848 # ffffffffc0202540 <commands+0x620>
ffffffffc0200e10:	b32ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e14:	00001697          	auipc	a3,0x1
ffffffffc0200e18:	7fc68693          	addi	a3,a3,2044 # ffffffffc0202610 <commands+0x6f0>
ffffffffc0200e1c:	00001617          	auipc	a2,0x1
ffffffffc0200e20:	70c60613          	addi	a2,a2,1804 # ffffffffc0202528 <commands+0x608>
ffffffffc0200e24:	0da00593          	li	a1,218
ffffffffc0200e28:	00001517          	auipc	a0,0x1
ffffffffc0200e2c:	71850513          	addi	a0,a0,1816 # ffffffffc0202540 <commands+0x620>
ffffffffc0200e30:	b12ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e34:	00002697          	auipc	a3,0x2
ffffffffc0200e38:	81c68693          	addi	a3,a3,-2020 # ffffffffc0202650 <commands+0x730>
ffffffffc0200e3c:	00001617          	auipc	a2,0x1
ffffffffc0200e40:	6ec60613          	addi	a2,a2,1772 # ffffffffc0202528 <commands+0x608>
ffffffffc0200e44:	0dc00593          	li	a1,220
ffffffffc0200e48:	00001517          	auipc	a0,0x1
ffffffffc0200e4c:	6f850513          	addi	a0,a0,1784 # ffffffffc0202540 <commands+0x620>
ffffffffc0200e50:	af2ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e54:	00002697          	auipc	a3,0x2
ffffffffc0200e58:	88468693          	addi	a3,a3,-1916 # ffffffffc02026d8 <commands+0x7b8>
ffffffffc0200e5c:	00001617          	auipc	a2,0x1
ffffffffc0200e60:	6cc60613          	addi	a2,a2,1740 # ffffffffc0202528 <commands+0x608>
ffffffffc0200e64:	0f500593          	li	a1,245
ffffffffc0200e68:	00001517          	auipc	a0,0x1
ffffffffc0200e6c:	6d850513          	addi	a0,a0,1752 # ffffffffc0202540 <commands+0x620>
ffffffffc0200e70:	ad2ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e74:	00001697          	auipc	a3,0x1
ffffffffc0200e78:	75468693          	addi	a3,a3,1876 # ffffffffc02025c8 <commands+0x6a8>
ffffffffc0200e7c:	00001617          	auipc	a2,0x1
ffffffffc0200e80:	6ac60613          	addi	a2,a2,1708 # ffffffffc0202528 <commands+0x608>
ffffffffc0200e84:	0d700593          	li	a1,215
ffffffffc0200e88:	00001517          	auipc	a0,0x1
ffffffffc0200e8c:	6b850513          	addi	a0,a0,1720 # ffffffffc0202540 <commands+0x620>
ffffffffc0200e90:	ab2ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(total == 0);
ffffffffc0200e94:	00002697          	auipc	a3,0x2
ffffffffc0200e98:	97468693          	addi	a3,a3,-1676 # ffffffffc0202808 <commands+0x8e8>
ffffffffc0200e9c:	00001617          	auipc	a2,0x1
ffffffffc0200ea0:	68c60613          	addi	a2,a2,1676 # ffffffffc0202528 <commands+0x608>
ffffffffc0200ea4:	14f00593          	li	a1,335
ffffffffc0200ea8:	00001517          	auipc	a0,0x1
ffffffffc0200eac:	69850513          	addi	a0,a0,1688 # ffffffffc0202540 <commands+0x620>
ffffffffc0200eb0:	a92ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(total == nr_free_pages());
ffffffffc0200eb4:	00001697          	auipc	a3,0x1
ffffffffc0200eb8:	6b468693          	addi	a3,a3,1716 # ffffffffc0202568 <commands+0x648>
ffffffffc0200ebc:	00001617          	auipc	a2,0x1
ffffffffc0200ec0:	66c60613          	addi	a2,a2,1644 # ffffffffc0202528 <commands+0x608>
ffffffffc0200ec4:	11000593          	li	a1,272
ffffffffc0200ec8:	00001517          	auipc	a0,0x1
ffffffffc0200ecc:	67850513          	addi	a0,a0,1656 # ffffffffc0202540 <commands+0x620>
ffffffffc0200ed0:	a72ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ed4:	00001697          	auipc	a3,0x1
ffffffffc0200ed8:	6d468693          	addi	a3,a3,1748 # ffffffffc02025a8 <commands+0x688>
ffffffffc0200edc:	00001617          	auipc	a2,0x1
ffffffffc0200ee0:	64c60613          	addi	a2,a2,1612 # ffffffffc0202528 <commands+0x608>
ffffffffc0200ee4:	0d600593          	li	a1,214
ffffffffc0200ee8:	00001517          	auipc	a0,0x1
ffffffffc0200eec:	65850513          	addi	a0,a0,1624 # ffffffffc0202540 <commands+0x620>
ffffffffc0200ef0:	a52ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ef4:	00001697          	auipc	a3,0x1
ffffffffc0200ef8:	69468693          	addi	a3,a3,1684 # ffffffffc0202588 <commands+0x668>
ffffffffc0200efc:	00001617          	auipc	a2,0x1
ffffffffc0200f00:	62c60613          	addi	a2,a2,1580 # ffffffffc0202528 <commands+0x608>
ffffffffc0200f04:	0d500593          	li	a1,213
ffffffffc0200f08:	00001517          	auipc	a0,0x1
ffffffffc0200f0c:	63850513          	addi	a0,a0,1592 # ffffffffc0202540 <commands+0x620>
ffffffffc0200f10:	a32ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f14:	00001697          	auipc	a3,0x1
ffffffffc0200f18:	79c68693          	addi	a3,a3,1948 # ffffffffc02026b0 <commands+0x790>
ffffffffc0200f1c:	00001617          	auipc	a2,0x1
ffffffffc0200f20:	60c60613          	addi	a2,a2,1548 # ffffffffc0202528 <commands+0x608>
ffffffffc0200f24:	0f200593          	li	a1,242
ffffffffc0200f28:	00001517          	auipc	a0,0x1
ffffffffc0200f2c:	61850513          	addi	a0,a0,1560 # ffffffffc0202540 <commands+0x620>
ffffffffc0200f30:	a12ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f34:	00001697          	auipc	a3,0x1
ffffffffc0200f38:	69468693          	addi	a3,a3,1684 # ffffffffc02025c8 <commands+0x6a8>
ffffffffc0200f3c:	00001617          	auipc	a2,0x1
ffffffffc0200f40:	5ec60613          	addi	a2,a2,1516 # ffffffffc0202528 <commands+0x608>
ffffffffc0200f44:	0f000593          	li	a1,240
ffffffffc0200f48:	00001517          	auipc	a0,0x1
ffffffffc0200f4c:	5f850513          	addi	a0,a0,1528 # ffffffffc0202540 <commands+0x620>
ffffffffc0200f50:	9f2ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f54:	00001697          	auipc	a3,0x1
ffffffffc0200f58:	65468693          	addi	a3,a3,1620 # ffffffffc02025a8 <commands+0x688>
ffffffffc0200f5c:	00001617          	auipc	a2,0x1
ffffffffc0200f60:	5cc60613          	addi	a2,a2,1484 # ffffffffc0202528 <commands+0x608>
ffffffffc0200f64:	0ef00593          	li	a1,239
ffffffffc0200f68:	00001517          	auipc	a0,0x1
ffffffffc0200f6c:	5d850513          	addi	a0,a0,1496 # ffffffffc0202540 <commands+0x620>
ffffffffc0200f70:	9d2ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f74:	00001697          	auipc	a3,0x1
ffffffffc0200f78:	61468693          	addi	a3,a3,1556 # ffffffffc0202588 <commands+0x668>
ffffffffc0200f7c:	00001617          	auipc	a2,0x1
ffffffffc0200f80:	5ac60613          	addi	a2,a2,1452 # ffffffffc0202528 <commands+0x608>
ffffffffc0200f84:	0ee00593          	li	a1,238
ffffffffc0200f88:	00001517          	auipc	a0,0x1
ffffffffc0200f8c:	5b850513          	addi	a0,a0,1464 # ffffffffc0202540 <commands+0x620>
ffffffffc0200f90:	9b2ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(nr_free == 3);
ffffffffc0200f94:	00001697          	auipc	a3,0x1
ffffffffc0200f98:	73468693          	addi	a3,a3,1844 # ffffffffc02026c8 <commands+0x7a8>
ffffffffc0200f9c:	00001617          	auipc	a2,0x1
ffffffffc0200fa0:	58c60613          	addi	a2,a2,1420 # ffffffffc0202528 <commands+0x608>
ffffffffc0200fa4:	0ec00593          	li	a1,236
ffffffffc0200fa8:	00001517          	auipc	a0,0x1
ffffffffc0200fac:	59850513          	addi	a0,a0,1432 # ffffffffc0202540 <commands+0x620>
ffffffffc0200fb0:	992ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fb4:	00001697          	auipc	a3,0x1
ffffffffc0200fb8:	6fc68693          	addi	a3,a3,1788 # ffffffffc02026b0 <commands+0x790>
ffffffffc0200fbc:	00001617          	auipc	a2,0x1
ffffffffc0200fc0:	56c60613          	addi	a2,a2,1388 # ffffffffc0202528 <commands+0x608>
ffffffffc0200fc4:	0e700593          	li	a1,231
ffffffffc0200fc8:	00001517          	auipc	a0,0x1
ffffffffc0200fcc:	57850513          	addi	a0,a0,1400 # ffffffffc0202540 <commands+0x620>
ffffffffc0200fd0:	972ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200fd4:	00001697          	auipc	a3,0x1
ffffffffc0200fd8:	6bc68693          	addi	a3,a3,1724 # ffffffffc0202690 <commands+0x770>
ffffffffc0200fdc:	00001617          	auipc	a2,0x1
ffffffffc0200fe0:	54c60613          	addi	a2,a2,1356 # ffffffffc0202528 <commands+0x608>
ffffffffc0200fe4:	0de00593          	li	a1,222
ffffffffc0200fe8:	00001517          	auipc	a0,0x1
ffffffffc0200fec:	55850513          	addi	a0,a0,1368 # ffffffffc0202540 <commands+0x620>
ffffffffc0200ff0:	952ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ff4:	00001697          	auipc	a3,0x1
ffffffffc0200ff8:	67c68693          	addi	a3,a3,1660 # ffffffffc0202670 <commands+0x750>
ffffffffc0200ffc:	00001617          	auipc	a2,0x1
ffffffffc0201000:	52c60613          	addi	a2,a2,1324 # ffffffffc0202528 <commands+0x608>
ffffffffc0201004:	0dd00593          	li	a1,221
ffffffffc0201008:	00001517          	auipc	a0,0x1
ffffffffc020100c:	53850513          	addi	a0,a0,1336 # ffffffffc0202540 <commands+0x620>
ffffffffc0201010:	932ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(count == 0);
ffffffffc0201014:	00001697          	auipc	a3,0x1
ffffffffc0201018:	7e468693          	addi	a3,a3,2020 # ffffffffc02027f8 <commands+0x8d8>
ffffffffc020101c:	00001617          	auipc	a2,0x1
ffffffffc0201020:	50c60613          	addi	a2,a2,1292 # ffffffffc0202528 <commands+0x608>
ffffffffc0201024:	14e00593          	li	a1,334
ffffffffc0201028:	00001517          	auipc	a0,0x1
ffffffffc020102c:	51850513          	addi	a0,a0,1304 # ffffffffc0202540 <commands+0x620>
ffffffffc0201030:	912ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(nr_free == 0);
ffffffffc0201034:	00001697          	auipc	a3,0x1
ffffffffc0201038:	6dc68693          	addi	a3,a3,1756 # ffffffffc0202710 <commands+0x7f0>
ffffffffc020103c:	00001617          	auipc	a2,0x1
ffffffffc0201040:	4ec60613          	addi	a2,a2,1260 # ffffffffc0202528 <commands+0x608>
ffffffffc0201044:	14300593          	li	a1,323
ffffffffc0201048:	00001517          	auipc	a0,0x1
ffffffffc020104c:	4f850513          	addi	a0,a0,1272 # ffffffffc0202540 <commands+0x620>
ffffffffc0201050:	8f2ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201054:	00001697          	auipc	a3,0x1
ffffffffc0201058:	65c68693          	addi	a3,a3,1628 # ffffffffc02026b0 <commands+0x790>
ffffffffc020105c:	00001617          	auipc	a2,0x1
ffffffffc0201060:	4cc60613          	addi	a2,a2,1228 # ffffffffc0202528 <commands+0x608>
ffffffffc0201064:	13d00593          	li	a1,317
ffffffffc0201068:	00001517          	auipc	a0,0x1
ffffffffc020106c:	4d850513          	addi	a0,a0,1240 # ffffffffc0202540 <commands+0x620>
ffffffffc0201070:	8d2ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201074:	00001697          	auipc	a3,0x1
ffffffffc0201078:	76468693          	addi	a3,a3,1892 # ffffffffc02027d8 <commands+0x8b8>
ffffffffc020107c:	00001617          	auipc	a2,0x1
ffffffffc0201080:	4ac60613          	addi	a2,a2,1196 # ffffffffc0202528 <commands+0x608>
ffffffffc0201084:	13c00593          	li	a1,316
ffffffffc0201088:	00001517          	auipc	a0,0x1
ffffffffc020108c:	4b850513          	addi	a0,a0,1208 # ffffffffc0202540 <commands+0x620>
ffffffffc0201090:	8b2ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(p0 + 4 == p1);
ffffffffc0201094:	00001697          	auipc	a3,0x1
ffffffffc0201098:	73468693          	addi	a3,a3,1844 # ffffffffc02027c8 <commands+0x8a8>
ffffffffc020109c:	00001617          	auipc	a2,0x1
ffffffffc02010a0:	48c60613          	addi	a2,a2,1164 # ffffffffc0202528 <commands+0x608>
ffffffffc02010a4:	13400593          	li	a1,308
ffffffffc02010a8:	00001517          	auipc	a0,0x1
ffffffffc02010ac:	49850513          	addi	a0,a0,1176 # ffffffffc0202540 <commands+0x620>
ffffffffc02010b0:	892ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc02010b4:	00001697          	auipc	a3,0x1
ffffffffc02010b8:	6fc68693          	addi	a3,a3,1788 # ffffffffc02027b0 <commands+0x890>
ffffffffc02010bc:	00001617          	auipc	a2,0x1
ffffffffc02010c0:	46c60613          	addi	a2,a2,1132 # ffffffffc0202528 <commands+0x608>
ffffffffc02010c4:	13300593          	li	a1,307
ffffffffc02010c8:	00001517          	auipc	a0,0x1
ffffffffc02010cc:	47850513          	addi	a0,a0,1144 # ffffffffc0202540 <commands+0x620>
ffffffffc02010d0:	872ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc02010d4:	00001697          	auipc	a3,0x1
ffffffffc02010d8:	6bc68693          	addi	a3,a3,1724 # ffffffffc0202790 <commands+0x870>
ffffffffc02010dc:	00001617          	auipc	a2,0x1
ffffffffc02010e0:	44c60613          	addi	a2,a2,1100 # ffffffffc0202528 <commands+0x608>
ffffffffc02010e4:	13200593          	li	a1,306
ffffffffc02010e8:	00001517          	auipc	a0,0x1
ffffffffc02010ec:	45850513          	addi	a0,a0,1112 # ffffffffc0202540 <commands+0x620>
ffffffffc02010f0:	852ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc02010f4:	00001697          	auipc	a3,0x1
ffffffffc02010f8:	66c68693          	addi	a3,a3,1644 # ffffffffc0202760 <commands+0x840>
ffffffffc02010fc:	00001617          	auipc	a2,0x1
ffffffffc0201100:	42c60613          	addi	a2,a2,1068 # ffffffffc0202528 <commands+0x608>
ffffffffc0201104:	13000593          	li	a1,304
ffffffffc0201108:	00001517          	auipc	a0,0x1
ffffffffc020110c:	43850513          	addi	a0,a0,1080 # ffffffffc0202540 <commands+0x620>
ffffffffc0201110:	832ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201114:	00001697          	auipc	a3,0x1
ffffffffc0201118:	63468693          	addi	a3,a3,1588 # ffffffffc0202748 <commands+0x828>
ffffffffc020111c:	00001617          	auipc	a2,0x1
ffffffffc0201120:	40c60613          	addi	a2,a2,1036 # ffffffffc0202528 <commands+0x608>
ffffffffc0201124:	12f00593          	li	a1,303
ffffffffc0201128:	00001517          	auipc	a0,0x1
ffffffffc020112c:	41850513          	addi	a0,a0,1048 # ffffffffc0202540 <commands+0x620>
ffffffffc0201130:	812ff0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201134:	00001697          	auipc	a3,0x1
ffffffffc0201138:	57c68693          	addi	a3,a3,1404 # ffffffffc02026b0 <commands+0x790>
ffffffffc020113c:	00001617          	auipc	a2,0x1
ffffffffc0201140:	3ec60613          	addi	a2,a2,1004 # ffffffffc0202528 <commands+0x608>
ffffffffc0201144:	12300593          	li	a1,291
ffffffffc0201148:	00001517          	auipc	a0,0x1
ffffffffc020114c:	3f850513          	addi	a0,a0,1016 # ffffffffc0202540 <commands+0x620>
ffffffffc0201150:	ff3fe0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201154:	00001697          	auipc	a3,0x1
ffffffffc0201158:	5dc68693          	addi	a3,a3,1500 # ffffffffc0202730 <commands+0x810>
ffffffffc020115c:	00001617          	auipc	a2,0x1
ffffffffc0201160:	3cc60613          	addi	a2,a2,972 # ffffffffc0202528 <commands+0x608>
ffffffffc0201164:	11a00593          	li	a1,282
ffffffffc0201168:	00001517          	auipc	a0,0x1
ffffffffc020116c:	3d850513          	addi	a0,a0,984 # ffffffffc0202540 <commands+0x620>
ffffffffc0201170:	fd3fe0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(p0 != NULL);
ffffffffc0201174:	00001697          	auipc	a3,0x1
ffffffffc0201178:	5ac68693          	addi	a3,a3,1452 # ffffffffc0202720 <commands+0x800>
ffffffffc020117c:	00001617          	auipc	a2,0x1
ffffffffc0201180:	3ac60613          	addi	a2,a2,940 # ffffffffc0202528 <commands+0x608>
ffffffffc0201184:	11900593          	li	a1,281
ffffffffc0201188:	00001517          	auipc	a0,0x1
ffffffffc020118c:	3b850513          	addi	a0,a0,952 # ffffffffc0202540 <commands+0x620>
ffffffffc0201190:	fb3fe0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(nr_free == 0);
ffffffffc0201194:	00001697          	auipc	a3,0x1
ffffffffc0201198:	57c68693          	addi	a3,a3,1404 # ffffffffc0202710 <commands+0x7f0>
ffffffffc020119c:	00001617          	auipc	a2,0x1
ffffffffc02011a0:	38c60613          	addi	a2,a2,908 # ffffffffc0202528 <commands+0x608>
ffffffffc02011a4:	0fb00593          	li	a1,251
ffffffffc02011a8:	00001517          	auipc	a0,0x1
ffffffffc02011ac:	39850513          	addi	a0,a0,920 # ffffffffc0202540 <commands+0x620>
ffffffffc02011b0:	f93fe0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011b4:	00001697          	auipc	a3,0x1
ffffffffc02011b8:	4fc68693          	addi	a3,a3,1276 # ffffffffc02026b0 <commands+0x790>
ffffffffc02011bc:	00001617          	auipc	a2,0x1
ffffffffc02011c0:	36c60613          	addi	a2,a2,876 # ffffffffc0202528 <commands+0x608>
ffffffffc02011c4:	0f900593          	li	a1,249
ffffffffc02011c8:	00001517          	auipc	a0,0x1
ffffffffc02011cc:	37850513          	addi	a0,a0,888 # ffffffffc0202540 <commands+0x620>
ffffffffc02011d0:	f73fe0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02011d4:	00001697          	auipc	a3,0x1
ffffffffc02011d8:	51c68693          	addi	a3,a3,1308 # ffffffffc02026f0 <commands+0x7d0>
ffffffffc02011dc:	00001617          	auipc	a2,0x1
ffffffffc02011e0:	34c60613          	addi	a2,a2,844 # ffffffffc0202528 <commands+0x608>
ffffffffc02011e4:	0f800593          	li	a1,248
ffffffffc02011e8:	00001517          	auipc	a0,0x1
ffffffffc02011ec:	35850513          	addi	a0,a0,856 # ffffffffc0202540 <commands+0x620>
ffffffffc02011f0:	f53fe0ef          	jal	ra,ffffffffc0200142 <__panic>

ffffffffc02011f4 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc02011f4:	1141                	addi	sp,sp,-16
ffffffffc02011f6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011f8:	14058a63          	beqz	a1,ffffffffc020134c <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc02011fc:	00259693          	slli	a3,a1,0x2
ffffffffc0201200:	96ae                	add	a3,a3,a1
ffffffffc0201202:	068e                	slli	a3,a3,0x3
ffffffffc0201204:	96aa                	add	a3,a3,a0
ffffffffc0201206:	87aa                	mv	a5,a0
ffffffffc0201208:	02d50263          	beq	a0,a3,ffffffffc020122c <best_fit_free_pages+0x38>
ffffffffc020120c:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020120e:	8b05                	andi	a4,a4,1
ffffffffc0201210:	10071e63          	bnez	a4,ffffffffc020132c <best_fit_free_pages+0x138>
ffffffffc0201214:	6798                	ld	a4,8(a5)
ffffffffc0201216:	8b09                	andi	a4,a4,2
ffffffffc0201218:	10071a63          	bnez	a4,ffffffffc020132c <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc020121c:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201220:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201224:	02878793          	addi	a5,a5,40
ffffffffc0201228:	fed792e3          	bne	a5,a3,ffffffffc020120c <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc020122c:	2581                	sext.w	a1,a1
ffffffffc020122e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201230:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201234:	4789                	li	a5,2
ffffffffc0201236:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020123a:	00005697          	auipc	a3,0x5
ffffffffc020123e:	dee68693          	addi	a3,a3,-530 # ffffffffc0206028 <free_area>
ffffffffc0201242:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201244:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201246:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020124a:	9db9                	addw	a1,a1,a4
ffffffffc020124c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020124e:	0ad78863          	beq	a5,a3,ffffffffc02012fe <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201252:	fe878713          	addi	a4,a5,-24
ffffffffc0201256:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020125a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020125c:	00e56a63          	bltu	a0,a4,ffffffffc0201270 <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc0201260:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201262:	06d70263          	beq	a4,a3,ffffffffc02012c6 <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201266:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201268:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020126c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201260 <best_fit_free_pages+0x6c>
ffffffffc0201270:	c199                	beqz	a1,ffffffffc0201276 <best_fit_free_pages+0x82>
ffffffffc0201272:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201276:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201278:	e390                	sd	a2,0(a5)
ffffffffc020127a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020127c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020127e:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201280:	02d70063          	beq	a4,a3,ffffffffc02012a0 <best_fit_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0201284:	ff872803          	lw	a6,-8(a4) # ffffffffffffeff8 <end+0x3fdf8b68>
        p = le2page(le, page_link);
ffffffffc0201288:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc020128c:	02081613          	slli	a2,a6,0x20
ffffffffc0201290:	9201                	srli	a2,a2,0x20
ffffffffc0201292:	00261793          	slli	a5,a2,0x2
ffffffffc0201296:	97b2                	add	a5,a5,a2
ffffffffc0201298:	078e                	slli	a5,a5,0x3
ffffffffc020129a:	97ae                	add	a5,a5,a1
ffffffffc020129c:	02f50f63          	beq	a0,a5,ffffffffc02012da <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc02012a0:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc02012a2:	00d70f63          	beq	a4,a3,ffffffffc02012c0 <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02012a6:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc02012a8:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc02012ac:	02059613          	slli	a2,a1,0x20
ffffffffc02012b0:	9201                	srli	a2,a2,0x20
ffffffffc02012b2:	00261793          	slli	a5,a2,0x2
ffffffffc02012b6:	97b2                	add	a5,a5,a2
ffffffffc02012b8:	078e                	slli	a5,a5,0x3
ffffffffc02012ba:	97aa                	add	a5,a5,a0
ffffffffc02012bc:	04f68863          	beq	a3,a5,ffffffffc020130c <best_fit_free_pages+0x118>
}
ffffffffc02012c0:	60a2                	ld	ra,8(sp)
ffffffffc02012c2:	0141                	addi	sp,sp,16
ffffffffc02012c4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02012c6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02012c8:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02012ca:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02012cc:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02012ce:	02d70563          	beq	a4,a3,ffffffffc02012f8 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02012d2:	8832                	mv	a6,a2
ffffffffc02012d4:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02012d6:	87ba                	mv	a5,a4
ffffffffc02012d8:	bf41                	j	ffffffffc0201268 <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc02012da:	491c                	lw	a5,16(a0)
ffffffffc02012dc:	0107883b          	addw	a6,a5,a6
ffffffffc02012e0:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02012e4:	57f5                	li	a5,-3
ffffffffc02012e6:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02012ea:	6d10                	ld	a2,24(a0)
ffffffffc02012ec:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc02012ee:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc02012f0:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02012f2:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02012f4:	e390                	sd	a2,0(a5)
ffffffffc02012f6:	b775                	j	ffffffffc02012a2 <best_fit_free_pages+0xae>
ffffffffc02012f8:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02012fa:	873e                	mv	a4,a5
ffffffffc02012fc:	b761                	j	ffffffffc0201284 <best_fit_free_pages+0x90>
}
ffffffffc02012fe:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201300:	e390                	sd	a2,0(a5)
ffffffffc0201302:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201304:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201306:	ed1c                	sd	a5,24(a0)
ffffffffc0201308:	0141                	addi	sp,sp,16
ffffffffc020130a:	8082                	ret
            base->property += p->property;
ffffffffc020130c:	ff872783          	lw	a5,-8(a4)
ffffffffc0201310:	ff070693          	addi	a3,a4,-16
ffffffffc0201314:	9dbd                	addw	a1,a1,a5
ffffffffc0201316:	c90c                	sw	a1,16(a0)
ffffffffc0201318:	57f5                	li	a5,-3
ffffffffc020131a:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020131e:	6314                	ld	a3,0(a4)
ffffffffc0201320:	671c                	ld	a5,8(a4)
}
ffffffffc0201322:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201324:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201326:	e394                	sd	a3,0(a5)
ffffffffc0201328:	0141                	addi	sp,sp,16
ffffffffc020132a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020132c:	00001697          	auipc	a3,0x1
ffffffffc0201330:	4ec68693          	addi	a3,a3,1260 # ffffffffc0202818 <commands+0x8f8>
ffffffffc0201334:	00001617          	auipc	a2,0x1
ffffffffc0201338:	1f460613          	addi	a2,a2,500 # ffffffffc0202528 <commands+0x608>
ffffffffc020133c:	09200593          	li	a1,146
ffffffffc0201340:	00001517          	auipc	a0,0x1
ffffffffc0201344:	20050513          	addi	a0,a0,512 # ffffffffc0202540 <commands+0x620>
ffffffffc0201348:	dfbfe0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(n > 0);
ffffffffc020134c:	00001697          	auipc	a3,0x1
ffffffffc0201350:	1d468693          	addi	a3,a3,468 # ffffffffc0202520 <commands+0x600>
ffffffffc0201354:	00001617          	auipc	a2,0x1
ffffffffc0201358:	1d460613          	addi	a2,a2,468 # ffffffffc0202528 <commands+0x608>
ffffffffc020135c:	08f00593          	li	a1,143
ffffffffc0201360:	00001517          	auipc	a0,0x1
ffffffffc0201364:	1e050513          	addi	a0,a0,480 # ffffffffc0202540 <commands+0x620>
ffffffffc0201368:	ddbfe0ef          	jal	ra,ffffffffc0200142 <__panic>

ffffffffc020136c <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020136c:	1141                	addi	sp,sp,-16
ffffffffc020136e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201370:	c9e1                	beqz	a1,ffffffffc0201440 <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201372:	00259693          	slli	a3,a1,0x2
ffffffffc0201376:	96ae                	add	a3,a3,a1
ffffffffc0201378:	068e                	slli	a3,a3,0x3
ffffffffc020137a:	96aa                	add	a3,a3,a0
ffffffffc020137c:	87aa                	mv	a5,a0
ffffffffc020137e:	00d50f63          	beq	a0,a3,ffffffffc020139c <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201382:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201384:	8b05                	andi	a4,a4,1
ffffffffc0201386:	cf49                	beqz	a4,ffffffffc0201420 <best_fit_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201388:	0007a823          	sw	zero,16(a5)
ffffffffc020138c:	0007b423          	sd	zero,8(a5)
ffffffffc0201390:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201394:	02878793          	addi	a5,a5,40
ffffffffc0201398:	fed795e3          	bne	a5,a3,ffffffffc0201382 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc020139c:	2581                	sext.w	a1,a1
ffffffffc020139e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02013a0:	4789                	li	a5,2
ffffffffc02013a2:	00850713          	addi	a4,a0,8
ffffffffc02013a6:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02013aa:	00005697          	auipc	a3,0x5
ffffffffc02013ae:	c7e68693          	addi	a3,a3,-898 # ffffffffc0206028 <free_area>
ffffffffc02013b2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02013b4:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02013b6:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02013ba:	9db9                	addw	a1,a1,a4
ffffffffc02013bc:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02013be:	04d78a63          	beq	a5,a3,ffffffffc0201412 <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc02013c2:	fe878713          	addi	a4,a5,-24
ffffffffc02013c6:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02013ca:	4581                	li	a1,0
            if (base < page) {
ffffffffc02013cc:	00e56a63          	bltu	a0,a4,ffffffffc02013e0 <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc02013d0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02013d2:	02d70263          	beq	a4,a3,ffffffffc02013f6 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02013d6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02013d8:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02013dc:	fee57ae3          	bgeu	a0,a4,ffffffffc02013d0 <best_fit_init_memmap+0x64>
ffffffffc02013e0:	c199                	beqz	a1,ffffffffc02013e6 <best_fit_init_memmap+0x7a>
ffffffffc02013e2:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013e6:	6398                	ld	a4,0(a5)
}
ffffffffc02013e8:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02013ea:	e390                	sd	a2,0(a5)
ffffffffc02013ec:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02013ee:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02013f0:	ed18                	sd	a4,24(a0)
ffffffffc02013f2:	0141                	addi	sp,sp,16
ffffffffc02013f4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02013f6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013f8:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02013fa:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02013fc:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013fe:	00d70663          	beq	a4,a3,ffffffffc020140a <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0201402:	8832                	mv	a6,a2
ffffffffc0201404:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201406:	87ba                	mv	a5,a4
ffffffffc0201408:	bfc1                	j	ffffffffc02013d8 <best_fit_init_memmap+0x6c>
}
ffffffffc020140a:	60a2                	ld	ra,8(sp)
ffffffffc020140c:	e290                	sd	a2,0(a3)
ffffffffc020140e:	0141                	addi	sp,sp,16
ffffffffc0201410:	8082                	ret
ffffffffc0201412:	60a2                	ld	ra,8(sp)
ffffffffc0201414:	e390                	sd	a2,0(a5)
ffffffffc0201416:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201418:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020141a:	ed1c                	sd	a5,24(a0)
ffffffffc020141c:	0141                	addi	sp,sp,16
ffffffffc020141e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201420:	00001697          	auipc	a3,0x1
ffffffffc0201424:	42068693          	addi	a3,a3,1056 # ffffffffc0202840 <commands+0x920>
ffffffffc0201428:	00001617          	auipc	a2,0x1
ffffffffc020142c:	10060613          	addi	a2,a2,256 # ffffffffc0202528 <commands+0x608>
ffffffffc0201430:	04a00593          	li	a1,74
ffffffffc0201434:	00001517          	auipc	a0,0x1
ffffffffc0201438:	10c50513          	addi	a0,a0,268 # ffffffffc0202540 <commands+0x620>
ffffffffc020143c:	d07fe0ef          	jal	ra,ffffffffc0200142 <__panic>
    assert(n > 0);
ffffffffc0201440:	00001697          	auipc	a3,0x1
ffffffffc0201444:	0e068693          	addi	a3,a3,224 # ffffffffc0202520 <commands+0x600>
ffffffffc0201448:	00001617          	auipc	a2,0x1
ffffffffc020144c:	0e060613          	addi	a2,a2,224 # ffffffffc0202528 <commands+0x608>
ffffffffc0201450:	04700593          	li	a1,71
ffffffffc0201454:	00001517          	auipc	a0,0x1
ffffffffc0201458:	0ec50513          	addi	a0,a0,236 # ffffffffc0202540 <commands+0x620>
ffffffffc020145c:	ce7fe0ef          	jal	ra,ffffffffc0200142 <__panic>

ffffffffc0201460 <slob_free>:

// slob_free 函数，将块释放回空闲链表
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	if (!block)
ffffffffc0201460:	cd1d                	beqz	a0,ffffffffc020149e <slob_free+0x3e>
		return;
	if (size)
ffffffffc0201462:	ed9d                	bnez	a1,ffffffffc02014a0 <slob_free+0x40>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	// 尝试与后续块合并
	if (b + b->units == cur->next) {
ffffffffc0201464:	4114                	lw	a3,0(a0)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201466:	00005597          	auipc	a1,0x5
ffffffffc020146a:	baa58593          	addi	a1,a1,-1110 # ffffffffc0206010 <slobfree>
ffffffffc020146e:	619c                	ld	a5,0(a1)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201470:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201472:	679c                	ld	a5,8(a5)
ffffffffc0201474:	02a77b63          	bgeu	a4,a0,ffffffffc02014aa <slob_free+0x4a>
ffffffffc0201478:	00f56463          	bltu	a0,a5,ffffffffc0201480 <slob_free+0x20>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020147c:	fef76ae3          	bltu	a4,a5,ffffffffc0201470 <slob_free+0x10>
	if (b + b->units == cur->next) {
ffffffffc0201480:	00469613          	slli	a2,a3,0x4
ffffffffc0201484:	962a                	add	a2,a2,a0
ffffffffc0201486:	02c78b63          	beq	a5,a2,ffffffffc02014bc <slob_free+0x5c>
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	// 尝试与前一个块合并
	if (cur + cur->units == b) {
ffffffffc020148a:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc020148c:	e51c                	sd	a5,8(a0)
	if (cur + cur->units == b) {
ffffffffc020148e:	00469793          	slli	a5,a3,0x4
ffffffffc0201492:	97ba                	add	a5,a5,a4
ffffffffc0201494:	02f50f63          	beq	a0,a5,ffffffffc02014d2 <slob_free+0x72>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201498:	e708                	sd	a0,8(a4)

	slobfree = cur; // 更新空闲链表头部
ffffffffc020149a:	e198                	sd	a4,0(a1)
ffffffffc020149c:	8082                	ret
}
ffffffffc020149e:	8082                	ret
		b->units = SLOB_UNITS(size); // 计算块的单位数
ffffffffc02014a0:	00f5869b          	addiw	a3,a1,15
ffffffffc02014a4:	8691                	srai	a3,a3,0x4
ffffffffc02014a6:	c114                	sw	a3,0(a0)
ffffffffc02014a8:	bf7d                	j	ffffffffc0201466 <slob_free+0x6>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02014aa:	fcf763e3          	bltu	a4,a5,ffffffffc0201470 <slob_free+0x10>
ffffffffc02014ae:	fcf571e3          	bgeu	a0,a5,ffffffffc0201470 <slob_free+0x10>
	if (b + b->units == cur->next) {
ffffffffc02014b2:	00469613          	slli	a2,a3,0x4
ffffffffc02014b6:	962a                	add	a2,a2,a0
ffffffffc02014b8:	fcc799e3          	bne	a5,a2,ffffffffc020148a <slob_free+0x2a>
		b->units += cur->next->units;
ffffffffc02014bc:	4390                	lw	a2,0(a5)
		b->next = cur->next->next;
ffffffffc02014be:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc02014c0:	9eb1                	addw	a3,a3,a2
ffffffffc02014c2:	c114                	sw	a3,0(a0)
	if (cur + cur->units == b) {
ffffffffc02014c4:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02014c6:	e51c                	sd	a5,8(a0)
	if (cur + cur->units == b) {
ffffffffc02014c8:	00469793          	slli	a5,a3,0x4
ffffffffc02014cc:	97ba                	add	a5,a5,a4
ffffffffc02014ce:	fcf515e3          	bne	a0,a5,ffffffffc0201498 <slob_free+0x38>
		cur->units += b->units;
ffffffffc02014d2:	411c                	lw	a5,0(a0)
		cur->next = b->next;
ffffffffc02014d4:	6510                	ld	a2,8(a0)
	slobfree = cur; // 更新空闲链表头部
ffffffffc02014d6:	e198                	sd	a4,0(a1)
		cur->units += b->units;
ffffffffc02014d8:	9ebd                	addw	a3,a3,a5
ffffffffc02014da:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc02014dc:	e710                	sd	a2,8(a4)
	slobfree = cur; // 更新空闲链表头部
ffffffffc02014de:	8082                	ret

ffffffffc02014e0 <slob_alloc>:
{
ffffffffc02014e0:	1101                	addi	sp,sp,-32
ffffffffc02014e2:	ec06                	sd	ra,24(sp)
ffffffffc02014e4:	e822                	sd	s0,16(sp)
ffffffffc02014e6:	e426                	sd	s1,8(sp)
ffffffffc02014e8:	e04a                	sd	s2,0(sp)
    assert(size < PGSIZE); // 确保请求的大小小于一页
ffffffffc02014ea:	6785                	lui	a5,0x1
ffffffffc02014ec:	08f57363          	bgeu	a0,a5,ffffffffc0201572 <slob_alloc+0x92>
	prev = slobfree;
ffffffffc02014f0:	00005417          	auipc	s0,0x5
ffffffffc02014f4:	b2040413          	addi	s0,s0,-1248 # ffffffffc0206010 <slobfree>
ffffffffc02014f8:	6010                	ld	a2,0(s0)
	int units = SLOB_UNITS(size); // 计算请求的单位数
ffffffffc02014fa:	053d                	addi	a0,a0,15
ffffffffc02014fc:	00455913          	srli	s2,a0,0x4
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201500:	6618                	ld	a4,8(a2)
	int units = SLOB_UNITS(size); // 计算请求的单位数
ffffffffc0201502:	0009049b          	sext.w	s1,s2
		if (cur->units >= units) { // 找到满足请求大小的空闲块
ffffffffc0201506:	4314                	lw	a3,0(a4)
ffffffffc0201508:	0696d263          	bge	a3,s1,ffffffffc020156c <slob_alloc+0x8c>
		if (cur == slobfree) { // 遍历完成一圈没有找到合适的块
ffffffffc020150c:	00e60a63          	beq	a2,a4,ffffffffc0201520 <slob_alloc+0x40>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201510:	671c                	ld	a5,8(a4)
		if (cur->units >= units) { // 找到满足请求大小的空闲块
ffffffffc0201512:	4394                	lw	a3,0(a5)
ffffffffc0201514:	0296d363          	bge	a3,s1,ffffffffc020153a <slob_alloc+0x5a>
		if (cur == slobfree) { // 遍历完成一圈没有找到合适的块
ffffffffc0201518:	6010                	ld	a2,0(s0)
ffffffffc020151a:	873e                	mv	a4,a5
ffffffffc020151c:	fee61ae3          	bne	a2,a4,ffffffffc0201510 <slob_alloc+0x30>
			cur = (slob_t *)alloc_pages(1); // 分配一页新的内存块
ffffffffc0201520:	4505                	li	a0,1
ffffffffc0201522:	ae8ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0201526:	87aa                	mv	a5,a0
			if (!cur) // 分配失败
ffffffffc0201528:	c51d                	beqz	a0,ffffffffc0201556 <slob_alloc+0x76>
			slob_free(cur, PGSIZE);
ffffffffc020152a:	6585                	lui	a1,0x1
ffffffffc020152c:	f35ff0ef          	jal	ra,ffffffffc0201460 <slob_free>
			cur = slobfree;
ffffffffc0201530:	6018                	ld	a4,0(s0)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201532:	671c                	ld	a5,8(a4)
		if (cur->units >= units) { // 找到满足请求大小的空闲块
ffffffffc0201534:	4394                	lw	a3,0(a5)
ffffffffc0201536:	fe96c1e3          	blt	a3,s1,ffffffffc0201518 <slob_alloc+0x38>
			if (cur->units == units) // 如果块的大小正好等于请求的大小
ffffffffc020153a:	02d48563          	beq	s1,a3,ffffffffc0201564 <slob_alloc+0x84>
				prev->next = cur + units;
ffffffffc020153e:	0912                	slli	s2,s2,0x4
ffffffffc0201540:	993e                	add	s2,s2,a5
ffffffffc0201542:	01273423          	sd	s2,8(a4)
				prev->next->next = cur->next;
ffffffffc0201546:	6790                	ld	a2,8(a5)
				prev->next->units = cur->units - units;
ffffffffc0201548:	9e85                	subw	a3,a3,s1
ffffffffc020154a:	00d92023          	sw	a3,0(s2)
				prev->next->next = cur->next;
ffffffffc020154e:	00c93423          	sd	a2,8(s2)
				cur->units = units;
ffffffffc0201552:	c384                	sw	s1,0(a5)
			slobfree = prev; // 更新slobfree指针
ffffffffc0201554:	e018                	sd	a4,0(s0)
}
ffffffffc0201556:	60e2                	ld	ra,24(sp)
ffffffffc0201558:	6442                	ld	s0,16(sp)
ffffffffc020155a:	64a2                	ld	s1,8(sp)
ffffffffc020155c:	6902                	ld	s2,0(sp)
ffffffffc020155e:	853e                	mv	a0,a5
ffffffffc0201560:	6105                	addi	sp,sp,32
ffffffffc0201562:	8082                	ret
				prev->next = cur->next;
ffffffffc0201564:	6794                	ld	a3,8(a5)
			slobfree = prev; // 更新slobfree指针
ffffffffc0201566:	e018                	sd	a4,0(s0)
				prev->next = cur->next;
ffffffffc0201568:	e714                	sd	a3,8(a4)
			return cur;
ffffffffc020156a:	b7f5                	j	ffffffffc0201556 <slob_alloc+0x76>
		if (cur->units >= units) { // 找到满足请求大小的空闲块
ffffffffc020156c:	87ba                	mv	a5,a4
ffffffffc020156e:	8732                	mv	a4,a2
ffffffffc0201570:	b7e9                	j	ffffffffc020153a <slob_alloc+0x5a>
    assert(size < PGSIZE); // 确保请求的大小小于一页
ffffffffc0201572:	00001697          	auipc	a3,0x1
ffffffffc0201576:	32e68693          	addi	a3,a3,814 # ffffffffc02028a0 <best_fit_pmm_manager+0x38>
ffffffffc020157a:	00001617          	auipc	a2,0x1
ffffffffc020157e:	fae60613          	addi	a2,a2,-82 # ffffffffc0202528 <commands+0x608>
ffffffffc0201582:	02b00593          	li	a1,43
ffffffffc0201586:	00001517          	auipc	a0,0x1
ffffffffc020158a:	32a50513          	addi	a0,a0,810 # ffffffffc02028b0 <best_fit_pmm_manager+0x48>
ffffffffc020158e:	bb5fe0ef          	jal	ra,ffffffffc0200142 <__panic>

ffffffffc0201592 <slub_alloc.part.0>:

// slub_alloc，面向用户的内存分配接口
void *slub_alloc(size_t size)
ffffffffc0201592:	1101                	addi	sp,sp,-32
ffffffffc0201594:	e822                	sd	s0,16(sp)
ffffffffc0201596:	842a                	mv	s0,a0
		m = slob_alloc(size + SLOB_UNIT); // 分配大小加上块头
		return m ? (void *)(m + 1) : 0; // 成功分配则返回块地址
	}

	// 分配大块
	bb = slob_alloc(sizeof(bigblock_t));
ffffffffc0201598:	4561                	li	a0,24
void *slub_alloc(size_t size)
ffffffffc020159a:	ec06                	sd	ra,24(sp)
ffffffffc020159c:	e426                	sd	s1,8(sp)
	bb = slob_alloc(sizeof(bigblock_t));
ffffffffc020159e:	f43ff0ef          	jal	ra,ffffffffc02014e0 <slob_alloc>
	if (!bb)
ffffffffc02015a2:	c915                	beqz	a0,ffffffffc02015d6 <slub_alloc.part.0+0x44>
		return 0;

	bb->order = ((size-1) >> PGSHIFT) + 1; // 计算order
ffffffffc02015a4:	fff40793          	addi	a5,s0,-1
ffffffffc02015a8:	83b1                	srli	a5,a5,0xc
ffffffffc02015aa:	84aa                	mv	s1,a0
ffffffffc02015ac:	0017851b          	addiw	a0,a5,1
ffffffffc02015b0:	c088                	sw	a0,0(s1)
	bb->pages = (void *)alloc_pages(bb->order); // 分配大块页
ffffffffc02015b2:	a58ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc02015b6:	e488                	sd	a0,8(s1)
ffffffffc02015b8:	842a                	mv	s0,a0

	if (bb->pages) {
ffffffffc02015ba:	c50d                	beqz	a0,ffffffffc02015e4 <slub_alloc.part.0+0x52>
		bb->next = bigblocks; // 插入链表
ffffffffc02015bc:	00005797          	auipc	a5,0x5
ffffffffc02015c0:	ec478793          	addi	a5,a5,-316 # ffffffffc0206480 <bigblocks>
ffffffffc02015c4:	6398                	ld	a4,0(a5)
		return bb->pages;
	}

	slob_free(bb, sizeof(bigblock_t)); // 如果分配失败，释放块
	return 0;
}
ffffffffc02015c6:	60e2                	ld	ra,24(sp)
ffffffffc02015c8:	8522                	mv	a0,s0
ffffffffc02015ca:	6442                	ld	s0,16(sp)
		bigblocks = bb;
ffffffffc02015cc:	e384                	sd	s1,0(a5)
		bb->next = bigblocks; // 插入链表
ffffffffc02015ce:	e898                	sd	a4,16(s1)
}
ffffffffc02015d0:	64a2                	ld	s1,8(sp)
ffffffffc02015d2:	6105                	addi	sp,sp,32
ffffffffc02015d4:	8082                	ret
		return 0;
ffffffffc02015d6:	4401                	li	s0,0
}
ffffffffc02015d8:	60e2                	ld	ra,24(sp)
ffffffffc02015da:	8522                	mv	a0,s0
ffffffffc02015dc:	6442                	ld	s0,16(sp)
ffffffffc02015de:	64a2                	ld	s1,8(sp)
ffffffffc02015e0:	6105                	addi	sp,sp,32
ffffffffc02015e2:	8082                	ret
	slob_free(bb, sizeof(bigblock_t)); // 如果分配失败，释放块
ffffffffc02015e4:	8526                	mv	a0,s1
ffffffffc02015e6:	45e1                	li	a1,24
ffffffffc02015e8:	e79ff0ef          	jal	ra,ffffffffc0201460 <slob_free>
}
ffffffffc02015ec:	60e2                	ld	ra,24(sp)
ffffffffc02015ee:	8522                	mv	a0,s0
ffffffffc02015f0:	6442                	ld	s0,16(sp)
ffffffffc02015f2:	64a2                	ld	s1,8(sp)
ffffffffc02015f4:	6105                	addi	sp,sp,32
ffffffffc02015f6:	8082                	ret

ffffffffc02015f8 <slub_init>:
    cprintf("slub_init() succeeded!\n");
ffffffffc02015f8:	00001517          	auipc	a0,0x1
ffffffffc02015fc:	2d050513          	addi	a0,a0,720 # ffffffffc02028c8 <best_fit_pmm_manager+0x60>
ffffffffc0201600:	abbfe06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0201604 <slub_free>:
// 释放分配的内存块
void slub_free(void *block)
{
	bigblock_t *bb, **last = &bigblocks;

	if (!block)
ffffffffc0201604:	c531                	beqz	a0,ffffffffc0201650 <slub_free+0x4c>
		return;

	// 检查是否为大块
	if (!((unsigned long)block & (PGSIZE-1))) {
ffffffffc0201606:	03451793          	slli	a5,a0,0x34
ffffffffc020160a:	e7a1                	bnez	a5,ffffffffc0201652 <slub_free+0x4e>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020160c:	00005697          	auipc	a3,0x5
ffffffffc0201610:	e7468693          	addi	a3,a3,-396 # ffffffffc0206480 <bigblocks>
ffffffffc0201614:	629c                	ld	a5,0(a3)
ffffffffc0201616:	cf95                	beqz	a5,ffffffffc0201652 <slub_free+0x4e>
{
ffffffffc0201618:	1141                	addi	sp,sp,-16
ffffffffc020161a:	e406                	sd	ra,8(sp)
ffffffffc020161c:	e022                	sd	s0,0(sp)
ffffffffc020161e:	a021                	j	ffffffffc0201626 <slub_free+0x22>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201620:	01040693          	addi	a3,s0,16
ffffffffc0201624:	c385                	beqz	a5,ffffffffc0201644 <slub_free+0x40>
			if (bb->pages == block) { // 如果找到对应大块
ffffffffc0201626:	6798                	ld	a4,8(a5)
ffffffffc0201628:	843e                	mv	s0,a5
				*last = bb->next;
ffffffffc020162a:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) { // 如果找到对应大块
ffffffffc020162c:	fea71ae3          	bne	a4,a0,ffffffffc0201620 <slub_free+0x1c>
				free_pages((struct Page *)block, bb->order); // 释放大块页
ffffffffc0201630:	400c                	lw	a1,0(s0)
				*last = bb->next;
ffffffffc0201632:	e29c                	sd	a5,0(a3)
				free_pages((struct Page *)block, bb->order); // 释放大块页
ffffffffc0201634:	a14ff0ef          	jal	ra,ffffffffc0200848 <free_pages>
				slob_free(bb, sizeof(bigblock_t)); // 释放块头
ffffffffc0201638:	8522                	mv	a0,s0
	}

	// 如果不是大块，则直接释放小块
	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc020163a:	6402                	ld	s0,0(sp)
ffffffffc020163c:	60a2                	ld	ra,8(sp)
				slob_free(bb, sizeof(bigblock_t)); // 释放块头
ffffffffc020163e:	45e1                	li	a1,24
}
ffffffffc0201640:	0141                	addi	sp,sp,16
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201642:	bd39                	j	ffffffffc0201460 <slob_free>
}
ffffffffc0201644:	6402                	ld	s0,0(sp)
ffffffffc0201646:	60a2                	ld	ra,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201648:	4581                	li	a1,0
ffffffffc020164a:	1541                	addi	a0,a0,-16
}
ffffffffc020164c:	0141                	addi	sp,sp,16
	slob_free((slob_t *)block - 1, 0);
ffffffffc020164e:	bd09                	j	ffffffffc0201460 <slob_free>
ffffffffc0201650:	8082                	ret
ffffffffc0201652:	4581                	li	a1,0
ffffffffc0201654:	1541                	addi	a0,a0,-16
ffffffffc0201656:	b529                	j	ffffffffc0201460 <slob_free>

ffffffffc0201658 <slub_check>:
    return len;
}

// 测试slub分配器行为的函数
void slub_check()
{
ffffffffc0201658:	1101                	addi	sp,sp,-32
    cprintf("slub check begin\n");
ffffffffc020165a:	00001517          	auipc	a0,0x1
ffffffffc020165e:	28650513          	addi	a0,a0,646 # ffffffffc02028e0 <best_fit_pmm_manager+0x78>
{
ffffffffc0201662:	e822                	sd	s0,16(sp)
ffffffffc0201664:	ec06                	sd	ra,24(sp)
ffffffffc0201666:	e426                	sd	s1,8(sp)
ffffffffc0201668:	e04a                	sd	s2,0(sp)
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020166a:	00005417          	auipc	s0,0x5
ffffffffc020166e:	9a640413          	addi	s0,s0,-1626 # ffffffffc0206010 <slobfree>
    cprintf("slub check begin\n");
ffffffffc0201672:	a49fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201676:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc0201678:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020167a:	671c                	ld	a5,8(a4)
ffffffffc020167c:	00f70663          	beq	a4,a5,ffffffffc0201688 <slub_check+0x30>
ffffffffc0201680:	679c                	ld	a5,8(a5)
        len++;
ffffffffc0201682:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201684:	fef71ee3          	bne	a4,a5,ffffffffc0201680 <slub_check+0x28>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc0201688:	00001517          	auipc	a0,0x1
ffffffffc020168c:	27050513          	addi	a0,a0,624 # ffffffffc02028f8 <best_fit_pmm_manager+0x90>
ffffffffc0201690:	a2bfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
	if (size < PGSIZE - SLOB_UNIT) {
ffffffffc0201694:	6505                	lui	a0,0x1
ffffffffc0201696:	efdff0ef          	jal	ra,ffffffffc0201592 <slub_alloc.part.0>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020169a:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc020169c:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020169e:	671c                	ld	a5,8(a4)
ffffffffc02016a0:	00f70663          	beq	a4,a5,ffffffffc02016ac <slub_check+0x54>
ffffffffc02016a4:	679c                	ld	a5,8(a5)
        len++;
ffffffffc02016a6:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02016a8:	fef71ee3          	bne	a4,a5,ffffffffc02016a4 <slub_check+0x4c>
    void* p1 = slub_alloc(4096);
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc02016ac:	00001517          	auipc	a0,0x1
ffffffffc02016b0:	24c50513          	addi	a0,a0,588 # ffffffffc02028f8 <best_fit_pmm_manager+0x90>
ffffffffc02016b4:	a07fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
		m = slob_alloc(size + SLOB_UNIT); // 分配大小加上块头
ffffffffc02016b8:	4549                	li	a0,18
ffffffffc02016ba:	e27ff0ef          	jal	ra,ffffffffc02014e0 <slob_alloc>
ffffffffc02016be:	892a                	mv	s2,a0
		return m ? (void *)(m + 1) : 0; // 成功分配则返回块地址
ffffffffc02016c0:	c119                	beqz	a0,ffffffffc02016c6 <slub_check+0x6e>
ffffffffc02016c2:	01050913          	addi	s2,a0,16
		m = slob_alloc(size + SLOB_UNIT); // 分配大小加上块头
ffffffffc02016c6:	4549                	li	a0,18
ffffffffc02016c8:	e19ff0ef          	jal	ra,ffffffffc02014e0 <slob_alloc>
ffffffffc02016cc:	84aa                	mv	s1,a0
		return m ? (void *)(m + 1) : 0; // 成功分配则返回块地址
ffffffffc02016ce:	c119                	beqz	a0,ffffffffc02016d4 <slub_check+0x7c>
ffffffffc02016d0:	01050493          	addi	s1,a0,16
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02016d4:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc02016d6:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02016d8:	671c                	ld	a5,8(a4)
ffffffffc02016da:	00f70663          	beq	a4,a5,ffffffffc02016e6 <slub_check+0x8e>
ffffffffc02016de:	679c                	ld	a5,8(a5)
        len++;
ffffffffc02016e0:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02016e2:	fef71ee3          	bne	a4,a5,ffffffffc02016de <slub_check+0x86>
    void* p2 = slub_alloc(2);
    void* p3 = slub_alloc(2);
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc02016e6:	00001517          	auipc	a0,0x1
ffffffffc02016ea:	21250513          	addi	a0,a0,530 # ffffffffc02028f8 <best_fit_pmm_manager+0x90>
ffffffffc02016ee:	9cdfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    slub_free(p2);
ffffffffc02016f2:	854a                	mv	a0,s2
ffffffffc02016f4:	f11ff0ef          	jal	ra,ffffffffc0201604 <slub_free>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02016f8:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc02016fa:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02016fc:	671c                	ld	a5,8(a4)
ffffffffc02016fe:	00f70663          	beq	a4,a5,ffffffffc020170a <slub_check+0xb2>
ffffffffc0201702:	679c                	ld	a5,8(a5)
        len++;
ffffffffc0201704:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201706:	fef71ee3          	bne	a4,a5,ffffffffc0201702 <slub_check+0xaa>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc020170a:	00001517          	auipc	a0,0x1
ffffffffc020170e:	1ee50513          	addi	a0,a0,494 # ffffffffc02028f8 <best_fit_pmm_manager+0x90>
ffffffffc0201712:	9a9fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    slub_free(p3);
ffffffffc0201716:	8526                	mv	a0,s1
ffffffffc0201718:	eedff0ef          	jal	ra,ffffffffc0201604 <slub_free>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020171c:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc020171e:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201720:	671c                	ld	a5,8(a4)
ffffffffc0201722:	00e78663          	beq	a5,a4,ffffffffc020172e <slub_check+0xd6>
ffffffffc0201726:	679c                	ld	a5,8(a5)
        len++;
ffffffffc0201728:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020172a:	fef71ee3          	bne	a4,a5,ffffffffc0201726 <slub_check+0xce>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc020172e:	00001517          	auipc	a0,0x1
ffffffffc0201732:	1ca50513          	addi	a0,a0,458 # ffffffffc02028f8 <best_fit_pmm_manager+0x90>
ffffffffc0201736:	985fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("slub check end\n");
}
ffffffffc020173a:	6442                	ld	s0,16(sp)
ffffffffc020173c:	60e2                	ld	ra,24(sp)
ffffffffc020173e:	64a2                	ld	s1,8(sp)
ffffffffc0201740:	6902                	ld	s2,0(sp)
    cprintf("slub check end\n");
ffffffffc0201742:	00001517          	auipc	a0,0x1
ffffffffc0201746:	1ce50513          	addi	a0,a0,462 # ffffffffc0202910 <best_fit_pmm_manager+0xa8>
}
ffffffffc020174a:	6105                	addi	sp,sp,32
    cprintf("slub check end\n");
ffffffffc020174c:	96ffe06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0201750 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201750:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201752:	e589                	bnez	a1,ffffffffc020175c <strnlen+0xc>
ffffffffc0201754:	a811                	j	ffffffffc0201768 <strnlen+0x18>
        cnt ++;
ffffffffc0201756:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201758:	00f58863          	beq	a1,a5,ffffffffc0201768 <strnlen+0x18>
ffffffffc020175c:	00f50733          	add	a4,a0,a5
ffffffffc0201760:	00074703          	lbu	a4,0(a4)
ffffffffc0201764:	fb6d                	bnez	a4,ffffffffc0201756 <strnlen+0x6>
ffffffffc0201766:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201768:	852e                	mv	a0,a1
ffffffffc020176a:	8082                	ret

ffffffffc020176c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020176c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201770:	0005c703          	lbu	a4,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201774:	cb89                	beqz	a5,ffffffffc0201786 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201776:	0505                	addi	a0,a0,1
ffffffffc0201778:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020177a:	fee789e3          	beq	a5,a4,ffffffffc020176c <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020177e:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201782:	9d19                	subw	a0,a0,a4
ffffffffc0201784:	8082                	ret
ffffffffc0201786:	4501                	li	a0,0
ffffffffc0201788:	bfed                	j	ffffffffc0201782 <strcmp+0x16>

ffffffffc020178a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020178a:	00054783          	lbu	a5,0(a0)
ffffffffc020178e:	c799                	beqz	a5,ffffffffc020179c <strchr+0x12>
        if (*s == c) {
ffffffffc0201790:	00f58763          	beq	a1,a5,ffffffffc020179e <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201794:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201798:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020179a:	fbfd                	bnez	a5,ffffffffc0201790 <strchr+0x6>
    }
    return NULL;
ffffffffc020179c:	4501                	li	a0,0
}
ffffffffc020179e:	8082                	ret

ffffffffc02017a0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02017a0:	ca01                	beqz	a2,ffffffffc02017b0 <memset+0x10>
ffffffffc02017a2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02017a4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02017a6:	0785                	addi	a5,a5,1
ffffffffc02017a8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02017ac:	fec79de3          	bne	a5,a2,ffffffffc02017a6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02017b0:	8082                	ret

ffffffffc02017b2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02017b2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02017b6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02017b8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02017bc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02017be:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02017c2:	f022                	sd	s0,32(sp)
ffffffffc02017c4:	ec26                	sd	s1,24(sp)
ffffffffc02017c6:	e84a                	sd	s2,16(sp)
ffffffffc02017c8:	f406                	sd	ra,40(sp)
ffffffffc02017ca:	e44e                	sd	s3,8(sp)
ffffffffc02017cc:	84aa                	mv	s1,a0
ffffffffc02017ce:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02017d0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02017d4:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02017d6:	03067e63          	bgeu	a2,a6,ffffffffc0201812 <printnum+0x60>
ffffffffc02017da:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02017dc:	00805763          	blez	s0,ffffffffc02017ea <printnum+0x38>
ffffffffc02017e0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02017e2:	85ca                	mv	a1,s2
ffffffffc02017e4:	854e                	mv	a0,s3
ffffffffc02017e6:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02017e8:	fc65                	bnez	s0,ffffffffc02017e0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02017ea:	1a02                	slli	s4,s4,0x20
ffffffffc02017ec:	00001797          	auipc	a5,0x1
ffffffffc02017f0:	13478793          	addi	a5,a5,308 # ffffffffc0202920 <best_fit_pmm_manager+0xb8>
ffffffffc02017f4:	020a5a13          	srli	s4,s4,0x20
ffffffffc02017f8:	9a3e                	add	s4,s4,a5
}
ffffffffc02017fa:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02017fc:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201800:	70a2                	ld	ra,40(sp)
ffffffffc0201802:	69a2                	ld	s3,8(sp)
ffffffffc0201804:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201806:	85ca                	mv	a1,s2
ffffffffc0201808:	87a6                	mv	a5,s1
}
ffffffffc020180a:	6942                	ld	s2,16(sp)
ffffffffc020180c:	64e2                	ld	s1,24(sp)
ffffffffc020180e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201810:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201812:	03065633          	divu	a2,a2,a6
ffffffffc0201816:	8722                	mv	a4,s0
ffffffffc0201818:	f9bff0ef          	jal	ra,ffffffffc02017b2 <printnum>
ffffffffc020181c:	b7f9                	j	ffffffffc02017ea <printnum+0x38>

ffffffffc020181e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020181e:	7119                	addi	sp,sp,-128
ffffffffc0201820:	f4a6                	sd	s1,104(sp)
ffffffffc0201822:	f0ca                	sd	s2,96(sp)
ffffffffc0201824:	ecce                	sd	s3,88(sp)
ffffffffc0201826:	e8d2                	sd	s4,80(sp)
ffffffffc0201828:	e4d6                	sd	s5,72(sp)
ffffffffc020182a:	e0da                	sd	s6,64(sp)
ffffffffc020182c:	fc5e                	sd	s7,56(sp)
ffffffffc020182e:	f06a                	sd	s10,32(sp)
ffffffffc0201830:	fc86                	sd	ra,120(sp)
ffffffffc0201832:	f8a2                	sd	s0,112(sp)
ffffffffc0201834:	f862                	sd	s8,48(sp)
ffffffffc0201836:	f466                	sd	s9,40(sp)
ffffffffc0201838:	ec6e                	sd	s11,24(sp)
ffffffffc020183a:	892a                	mv	s2,a0
ffffffffc020183c:	84ae                	mv	s1,a1
ffffffffc020183e:	8d32                	mv	s10,a2
ffffffffc0201840:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201842:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201846:	5b7d                	li	s6,-1
ffffffffc0201848:	00001a97          	auipc	s5,0x1
ffffffffc020184c:	10ca8a93          	addi	s5,s5,268 # ffffffffc0202954 <best_fit_pmm_manager+0xec>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201850:	00001b97          	auipc	s7,0x1
ffffffffc0201854:	2e0b8b93          	addi	s7,s7,736 # ffffffffc0202b30 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201858:	000d4503          	lbu	a0,0(s10)
ffffffffc020185c:	001d0413          	addi	s0,s10,1
ffffffffc0201860:	01350a63          	beq	a0,s3,ffffffffc0201874 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201864:	c121                	beqz	a0,ffffffffc02018a4 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201866:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201868:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020186a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020186c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201870:	ff351ae3          	bne	a0,s3,ffffffffc0201864 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201874:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201878:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020187c:	4c81                	li	s9,0
ffffffffc020187e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201880:	5c7d                	li	s8,-1
ffffffffc0201882:	5dfd                	li	s11,-1
ffffffffc0201884:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201888:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020188a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020188e:	0ff5f593          	zext.b	a1,a1
ffffffffc0201892:	00140d13          	addi	s10,s0,1
ffffffffc0201896:	04b56263          	bltu	a0,a1,ffffffffc02018da <vprintfmt+0xbc>
ffffffffc020189a:	058a                	slli	a1,a1,0x2
ffffffffc020189c:	95d6                	add	a1,a1,s5
ffffffffc020189e:	4194                	lw	a3,0(a1)
ffffffffc02018a0:	96d6                	add	a3,a3,s5
ffffffffc02018a2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02018a4:	70e6                	ld	ra,120(sp)
ffffffffc02018a6:	7446                	ld	s0,112(sp)
ffffffffc02018a8:	74a6                	ld	s1,104(sp)
ffffffffc02018aa:	7906                	ld	s2,96(sp)
ffffffffc02018ac:	69e6                	ld	s3,88(sp)
ffffffffc02018ae:	6a46                	ld	s4,80(sp)
ffffffffc02018b0:	6aa6                	ld	s5,72(sp)
ffffffffc02018b2:	6b06                	ld	s6,64(sp)
ffffffffc02018b4:	7be2                	ld	s7,56(sp)
ffffffffc02018b6:	7c42                	ld	s8,48(sp)
ffffffffc02018b8:	7ca2                	ld	s9,40(sp)
ffffffffc02018ba:	7d02                	ld	s10,32(sp)
ffffffffc02018bc:	6de2                	ld	s11,24(sp)
ffffffffc02018be:	6109                	addi	sp,sp,128
ffffffffc02018c0:	8082                	ret
            padc = '0';
ffffffffc02018c2:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02018c4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018c8:	846a                	mv	s0,s10
ffffffffc02018ca:	00140d13          	addi	s10,s0,1
ffffffffc02018ce:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02018d2:	0ff5f593          	zext.b	a1,a1
ffffffffc02018d6:	fcb572e3          	bgeu	a0,a1,ffffffffc020189a <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02018da:	85a6                	mv	a1,s1
ffffffffc02018dc:	02500513          	li	a0,37
ffffffffc02018e0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02018e2:	fff44783          	lbu	a5,-1(s0)
ffffffffc02018e6:	8d22                	mv	s10,s0
ffffffffc02018e8:	f73788e3          	beq	a5,s3,ffffffffc0201858 <vprintfmt+0x3a>
ffffffffc02018ec:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02018f0:	1d7d                	addi	s10,s10,-1
ffffffffc02018f2:	ff379de3          	bne	a5,s3,ffffffffc02018ec <vprintfmt+0xce>
ffffffffc02018f6:	b78d                	j	ffffffffc0201858 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02018f8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02018fc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201900:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201902:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201906:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020190a:	02d86463          	bltu	a6,a3,ffffffffc0201932 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020190e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201912:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201916:	0186873b          	addw	a4,a3,s8
ffffffffc020191a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020191e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201920:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201924:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201926:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020192a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020192e:	fed870e3          	bgeu	a6,a3,ffffffffc020190e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201932:	f40ddce3          	bgez	s11,ffffffffc020188a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201936:	8de2                	mv	s11,s8
ffffffffc0201938:	5c7d                	li	s8,-1
ffffffffc020193a:	bf81                	j	ffffffffc020188a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020193c:	fffdc693          	not	a3,s11
ffffffffc0201940:	96fd                	srai	a3,a3,0x3f
ffffffffc0201942:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201946:	00144603          	lbu	a2,1(s0)
ffffffffc020194a:	2d81                	sext.w	s11,s11
ffffffffc020194c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020194e:	bf35                	j	ffffffffc020188a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201950:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201954:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201958:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020195a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020195c:	bfd9                	j	ffffffffc0201932 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020195e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201960:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201964:	01174463          	blt	a4,a7,ffffffffc020196c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201968:	1a088e63          	beqz	a7,ffffffffc0201b24 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020196c:	000a3603          	ld	a2,0(s4)
ffffffffc0201970:	46c1                	li	a3,16
ffffffffc0201972:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201974:	2781                	sext.w	a5,a5
ffffffffc0201976:	876e                	mv	a4,s11
ffffffffc0201978:	85a6                	mv	a1,s1
ffffffffc020197a:	854a                	mv	a0,s2
ffffffffc020197c:	e37ff0ef          	jal	ra,ffffffffc02017b2 <printnum>
            break;
ffffffffc0201980:	bde1                	j	ffffffffc0201858 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201982:	000a2503          	lw	a0,0(s4)
ffffffffc0201986:	85a6                	mv	a1,s1
ffffffffc0201988:	0a21                	addi	s4,s4,8
ffffffffc020198a:	9902                	jalr	s2
            break;
ffffffffc020198c:	b5f1                	j	ffffffffc0201858 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020198e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201990:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201994:	01174463          	blt	a4,a7,ffffffffc020199c <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201998:	18088163          	beqz	a7,ffffffffc0201b1a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020199c:	000a3603          	ld	a2,0(s4)
ffffffffc02019a0:	46a9                	li	a3,10
ffffffffc02019a2:	8a2e                	mv	s4,a1
ffffffffc02019a4:	bfc1                	j	ffffffffc0201974 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02019a6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02019aa:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02019ac:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02019ae:	bdf1                	j	ffffffffc020188a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02019b0:	85a6                	mv	a1,s1
ffffffffc02019b2:	02500513          	li	a0,37
ffffffffc02019b6:	9902                	jalr	s2
            break;
ffffffffc02019b8:	b545                	j	ffffffffc0201858 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02019ba:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02019be:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02019c0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02019c2:	b5e1                	j	ffffffffc020188a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02019c4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02019c6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02019ca:	01174463          	blt	a4,a7,ffffffffc02019d2 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02019ce:	14088163          	beqz	a7,ffffffffc0201b10 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02019d2:	000a3603          	ld	a2,0(s4)
ffffffffc02019d6:	46a1                	li	a3,8
ffffffffc02019d8:	8a2e                	mv	s4,a1
ffffffffc02019da:	bf69                	j	ffffffffc0201974 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02019dc:	03000513          	li	a0,48
ffffffffc02019e0:	85a6                	mv	a1,s1
ffffffffc02019e2:	e03e                	sd	a5,0(sp)
ffffffffc02019e4:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02019e6:	85a6                	mv	a1,s1
ffffffffc02019e8:	07800513          	li	a0,120
ffffffffc02019ec:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02019ee:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02019f0:	6782                	ld	a5,0(sp)
ffffffffc02019f2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02019f4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02019f8:	bfb5                	j	ffffffffc0201974 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02019fa:	000a3403          	ld	s0,0(s4)
ffffffffc02019fe:	008a0713          	addi	a4,s4,8
ffffffffc0201a02:	e03a                	sd	a4,0(sp)
ffffffffc0201a04:	14040263          	beqz	s0,ffffffffc0201b48 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201a08:	0fb05763          	blez	s11,ffffffffc0201af6 <vprintfmt+0x2d8>
ffffffffc0201a0c:	02d00693          	li	a3,45
ffffffffc0201a10:	0cd79163          	bne	a5,a3,ffffffffc0201ad2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a14:	00044783          	lbu	a5,0(s0)
ffffffffc0201a18:	0007851b          	sext.w	a0,a5
ffffffffc0201a1c:	cf85                	beqz	a5,ffffffffc0201a54 <vprintfmt+0x236>
ffffffffc0201a1e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201a22:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a26:	000c4563          	bltz	s8,ffffffffc0201a30 <vprintfmt+0x212>
ffffffffc0201a2a:	3c7d                	addiw	s8,s8,-1
ffffffffc0201a2c:	036c0263          	beq	s8,s6,ffffffffc0201a50 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201a30:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201a32:	0e0c8e63          	beqz	s9,ffffffffc0201b2e <vprintfmt+0x310>
ffffffffc0201a36:	3781                	addiw	a5,a5,-32
ffffffffc0201a38:	0ef47b63          	bgeu	s0,a5,ffffffffc0201b2e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201a3c:	03f00513          	li	a0,63
ffffffffc0201a40:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a42:	000a4783          	lbu	a5,0(s4)
ffffffffc0201a46:	3dfd                	addiw	s11,s11,-1
ffffffffc0201a48:	0a05                	addi	s4,s4,1
ffffffffc0201a4a:	0007851b          	sext.w	a0,a5
ffffffffc0201a4e:	ffe1                	bnez	a5,ffffffffc0201a26 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201a50:	01b05963          	blez	s11,ffffffffc0201a62 <vprintfmt+0x244>
ffffffffc0201a54:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201a56:	85a6                	mv	a1,s1
ffffffffc0201a58:	02000513          	li	a0,32
ffffffffc0201a5c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201a5e:	fe0d9be3          	bnez	s11,ffffffffc0201a54 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201a62:	6a02                	ld	s4,0(sp)
ffffffffc0201a64:	bbd5                	j	ffffffffc0201858 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201a66:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201a68:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201a6c:	01174463          	blt	a4,a7,ffffffffc0201a74 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201a70:	08088d63          	beqz	a7,ffffffffc0201b0a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201a74:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201a78:	0a044d63          	bltz	s0,ffffffffc0201b32 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201a7c:	8622                	mv	a2,s0
ffffffffc0201a7e:	8a66                	mv	s4,s9
ffffffffc0201a80:	46a9                	li	a3,10
ffffffffc0201a82:	bdcd                	j	ffffffffc0201974 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201a84:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201a88:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201a8a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201a8c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201a90:	8fb5                	xor	a5,a5,a3
ffffffffc0201a92:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201a96:	02d74163          	blt	a4,a3,ffffffffc0201ab8 <vprintfmt+0x29a>
ffffffffc0201a9a:	00369793          	slli	a5,a3,0x3
ffffffffc0201a9e:	97de                	add	a5,a5,s7
ffffffffc0201aa0:	639c                	ld	a5,0(a5)
ffffffffc0201aa2:	cb99                	beqz	a5,ffffffffc0201ab8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201aa4:	86be                	mv	a3,a5
ffffffffc0201aa6:	00001617          	auipc	a2,0x1
ffffffffc0201aaa:	eaa60613          	addi	a2,a2,-342 # ffffffffc0202950 <best_fit_pmm_manager+0xe8>
ffffffffc0201aae:	85a6                	mv	a1,s1
ffffffffc0201ab0:	854a                	mv	a0,s2
ffffffffc0201ab2:	0ce000ef          	jal	ra,ffffffffc0201b80 <printfmt>
ffffffffc0201ab6:	b34d                	j	ffffffffc0201858 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201ab8:	00001617          	auipc	a2,0x1
ffffffffc0201abc:	e8860613          	addi	a2,a2,-376 # ffffffffc0202940 <best_fit_pmm_manager+0xd8>
ffffffffc0201ac0:	85a6                	mv	a1,s1
ffffffffc0201ac2:	854a                	mv	a0,s2
ffffffffc0201ac4:	0bc000ef          	jal	ra,ffffffffc0201b80 <printfmt>
ffffffffc0201ac8:	bb41                	j	ffffffffc0201858 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201aca:	00001417          	auipc	s0,0x1
ffffffffc0201ace:	e6e40413          	addi	s0,s0,-402 # ffffffffc0202938 <best_fit_pmm_manager+0xd0>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201ad2:	85e2                	mv	a1,s8
ffffffffc0201ad4:	8522                	mv	a0,s0
ffffffffc0201ad6:	e43e                	sd	a5,8(sp)
ffffffffc0201ad8:	c79ff0ef          	jal	ra,ffffffffc0201750 <strnlen>
ffffffffc0201adc:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201ae0:	01b05b63          	blez	s11,ffffffffc0201af6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201ae4:	67a2                	ld	a5,8(sp)
ffffffffc0201ae6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201aea:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201aec:	85a6                	mv	a1,s1
ffffffffc0201aee:	8552                	mv	a0,s4
ffffffffc0201af0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201af2:	fe0d9ce3          	bnez	s11,ffffffffc0201aea <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201af6:	00044783          	lbu	a5,0(s0)
ffffffffc0201afa:	00140a13          	addi	s4,s0,1
ffffffffc0201afe:	0007851b          	sext.w	a0,a5
ffffffffc0201b02:	d3a5                	beqz	a5,ffffffffc0201a62 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201b04:	05e00413          	li	s0,94
ffffffffc0201b08:	bf39                	j	ffffffffc0201a26 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201b0a:	000a2403          	lw	s0,0(s4)
ffffffffc0201b0e:	b7ad                	j	ffffffffc0201a78 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201b10:	000a6603          	lwu	a2,0(s4)
ffffffffc0201b14:	46a1                	li	a3,8
ffffffffc0201b16:	8a2e                	mv	s4,a1
ffffffffc0201b18:	bdb1                	j	ffffffffc0201974 <vprintfmt+0x156>
ffffffffc0201b1a:	000a6603          	lwu	a2,0(s4)
ffffffffc0201b1e:	46a9                	li	a3,10
ffffffffc0201b20:	8a2e                	mv	s4,a1
ffffffffc0201b22:	bd89                	j	ffffffffc0201974 <vprintfmt+0x156>
ffffffffc0201b24:	000a6603          	lwu	a2,0(s4)
ffffffffc0201b28:	46c1                	li	a3,16
ffffffffc0201b2a:	8a2e                	mv	s4,a1
ffffffffc0201b2c:	b5a1                	j	ffffffffc0201974 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201b2e:	9902                	jalr	s2
ffffffffc0201b30:	bf09                	j	ffffffffc0201a42 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201b32:	85a6                	mv	a1,s1
ffffffffc0201b34:	02d00513          	li	a0,45
ffffffffc0201b38:	e03e                	sd	a5,0(sp)
ffffffffc0201b3a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201b3c:	6782                	ld	a5,0(sp)
ffffffffc0201b3e:	8a66                	mv	s4,s9
ffffffffc0201b40:	40800633          	neg	a2,s0
ffffffffc0201b44:	46a9                	li	a3,10
ffffffffc0201b46:	b53d                	j	ffffffffc0201974 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201b48:	03b05163          	blez	s11,ffffffffc0201b6a <vprintfmt+0x34c>
ffffffffc0201b4c:	02d00693          	li	a3,45
ffffffffc0201b50:	f6d79de3          	bne	a5,a3,ffffffffc0201aca <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201b54:	00001417          	auipc	s0,0x1
ffffffffc0201b58:	de440413          	addi	s0,s0,-540 # ffffffffc0202938 <best_fit_pmm_manager+0xd0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b5c:	02800793          	li	a5,40
ffffffffc0201b60:	02800513          	li	a0,40
ffffffffc0201b64:	00140a13          	addi	s4,s0,1
ffffffffc0201b68:	bd6d                	j	ffffffffc0201a22 <vprintfmt+0x204>
ffffffffc0201b6a:	00001a17          	auipc	s4,0x1
ffffffffc0201b6e:	dcfa0a13          	addi	s4,s4,-561 # ffffffffc0202939 <best_fit_pmm_manager+0xd1>
ffffffffc0201b72:	02800513          	li	a0,40
ffffffffc0201b76:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201b7a:	05e00413          	li	s0,94
ffffffffc0201b7e:	b565                	j	ffffffffc0201a26 <vprintfmt+0x208>

ffffffffc0201b80 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201b80:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201b82:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201b86:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201b88:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201b8a:	ec06                	sd	ra,24(sp)
ffffffffc0201b8c:	f83a                	sd	a4,48(sp)
ffffffffc0201b8e:	fc3e                	sd	a5,56(sp)
ffffffffc0201b90:	e0c2                	sd	a6,64(sp)
ffffffffc0201b92:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201b94:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201b96:	c89ff0ef          	jal	ra,ffffffffc020181e <vprintfmt>
}
ffffffffc0201b9a:	60e2                	ld	ra,24(sp)
ffffffffc0201b9c:	6161                	addi	sp,sp,80
ffffffffc0201b9e:	8082                	ret

ffffffffc0201ba0 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201ba0:	715d                	addi	sp,sp,-80
ffffffffc0201ba2:	e486                	sd	ra,72(sp)
ffffffffc0201ba4:	e0a6                	sd	s1,64(sp)
ffffffffc0201ba6:	fc4a                	sd	s2,56(sp)
ffffffffc0201ba8:	f84e                	sd	s3,48(sp)
ffffffffc0201baa:	f452                	sd	s4,40(sp)
ffffffffc0201bac:	f056                	sd	s5,32(sp)
ffffffffc0201bae:	ec5a                	sd	s6,24(sp)
ffffffffc0201bb0:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201bb2:	c901                	beqz	a0,ffffffffc0201bc2 <readline+0x22>
ffffffffc0201bb4:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201bb6:	00001517          	auipc	a0,0x1
ffffffffc0201bba:	d9a50513          	addi	a0,a0,-614 # ffffffffc0202950 <best_fit_pmm_manager+0xe8>
ffffffffc0201bbe:	cfcfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc0201bc2:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201bc4:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201bc6:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201bc8:	4aa9                	li	s5,10
ffffffffc0201bca:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201bcc:	00004b97          	auipc	s7,0x4
ffffffffc0201bd0:	474b8b93          	addi	s7,s7,1140 # ffffffffc0206040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201bd4:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201bd8:	d5afe0ef          	jal	ra,ffffffffc0200132 <getchar>
        if (c < 0) {
ffffffffc0201bdc:	00054a63          	bltz	a0,ffffffffc0201bf0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201be0:	00a95a63          	bge	s2,a0,ffffffffc0201bf4 <readline+0x54>
ffffffffc0201be4:	029a5263          	bge	s4,s1,ffffffffc0201c08 <readline+0x68>
        c = getchar();
ffffffffc0201be8:	d4afe0ef          	jal	ra,ffffffffc0200132 <getchar>
        if (c < 0) {
ffffffffc0201bec:	fe055ae3          	bgez	a0,ffffffffc0201be0 <readline+0x40>
            return NULL;
ffffffffc0201bf0:	4501                	li	a0,0
ffffffffc0201bf2:	a091                	j	ffffffffc0201c36 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201bf4:	03351463          	bne	a0,s3,ffffffffc0201c1c <readline+0x7c>
ffffffffc0201bf8:	e8a9                	bnez	s1,ffffffffc0201c4a <readline+0xaa>
        c = getchar();
ffffffffc0201bfa:	d38fe0ef          	jal	ra,ffffffffc0200132 <getchar>
        if (c < 0) {
ffffffffc0201bfe:	fe0549e3          	bltz	a0,ffffffffc0201bf0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c02:	fea959e3          	bge	s2,a0,ffffffffc0201bf4 <readline+0x54>
ffffffffc0201c06:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201c08:	e42a                	sd	a0,8(sp)
ffffffffc0201c0a:	ce6fe0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc0201c0e:	6522                	ld	a0,8(sp)
ffffffffc0201c10:	009b87b3          	add	a5,s7,s1
ffffffffc0201c14:	2485                	addiw	s1,s1,1
ffffffffc0201c16:	00a78023          	sb	a0,0(a5)
ffffffffc0201c1a:	bf7d                	j	ffffffffc0201bd8 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201c1c:	01550463          	beq	a0,s5,ffffffffc0201c24 <readline+0x84>
ffffffffc0201c20:	fb651ce3          	bne	a0,s6,ffffffffc0201bd8 <readline+0x38>
            cputchar(c);
ffffffffc0201c24:	cccfe0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc0201c28:	00004517          	auipc	a0,0x4
ffffffffc0201c2c:	41850513          	addi	a0,a0,1048 # ffffffffc0206040 <buf>
ffffffffc0201c30:	94aa                	add	s1,s1,a0
ffffffffc0201c32:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201c36:	60a6                	ld	ra,72(sp)
ffffffffc0201c38:	6486                	ld	s1,64(sp)
ffffffffc0201c3a:	7962                	ld	s2,56(sp)
ffffffffc0201c3c:	79c2                	ld	s3,48(sp)
ffffffffc0201c3e:	7a22                	ld	s4,40(sp)
ffffffffc0201c40:	7a82                	ld	s5,32(sp)
ffffffffc0201c42:	6b62                	ld	s6,24(sp)
ffffffffc0201c44:	6bc2                	ld	s7,16(sp)
ffffffffc0201c46:	6161                	addi	sp,sp,80
ffffffffc0201c48:	8082                	ret
            cputchar(c);
ffffffffc0201c4a:	4521                	li	a0,8
ffffffffc0201c4c:	ca4fe0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc0201c50:	34fd                	addiw	s1,s1,-1
ffffffffc0201c52:	b759                	j	ffffffffc0201bd8 <readline+0x38>

ffffffffc0201c54 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201c54:	4781                	li	a5,0
ffffffffc0201c56:	00004717          	auipc	a4,0x4
ffffffffc0201c5a:	3ca73703          	ld	a4,970(a4) # ffffffffc0206020 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201c5e:	88ba                	mv	a7,a4
ffffffffc0201c60:	852a                	mv	a0,a0
ffffffffc0201c62:	85be                	mv	a1,a5
ffffffffc0201c64:	863e                	mv	a2,a5
ffffffffc0201c66:	00000073          	ecall
ffffffffc0201c6a:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201c6c:	8082                	ret

ffffffffc0201c6e <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201c6e:	4781                	li	a5,0
ffffffffc0201c70:	00005717          	auipc	a4,0x5
ffffffffc0201c74:	81873703          	ld	a4,-2024(a4) # ffffffffc0206488 <SBI_SET_TIMER>
ffffffffc0201c78:	88ba                	mv	a7,a4
ffffffffc0201c7a:	852a                	mv	a0,a0
ffffffffc0201c7c:	85be                	mv	a1,a5
ffffffffc0201c7e:	863e                	mv	a2,a5
ffffffffc0201c80:	00000073          	ecall
ffffffffc0201c84:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201c86:	8082                	ret

ffffffffc0201c88 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201c88:	4501                	li	a0,0
ffffffffc0201c8a:	00004797          	auipc	a5,0x4
ffffffffc0201c8e:	38e7b783          	ld	a5,910(a5) # ffffffffc0206018 <SBI_CONSOLE_GETCHAR>
ffffffffc0201c92:	88be                	mv	a7,a5
ffffffffc0201c94:	852a                	mv	a0,a0
ffffffffc0201c96:	85aa                	mv	a1,a0
ffffffffc0201c98:	862a                	mv	a2,a0
ffffffffc0201c9a:	00000073          	ecall
ffffffffc0201c9e:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201ca0:	2501                	sext.w	a0,a0
ffffffffc0201ca2:	8082                	ret
