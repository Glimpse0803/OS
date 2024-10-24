#ifndef __KERN_TRAP_TRAP_H__
#define __KERN_TRAP_TRAP_H__

#include <defs.h>

struct pushregs {
    uintptr_t zero;  // Hard-wired zero
    uintptr_t ra;    // Return address
    uintptr_t sp;    // Stack pointer
    uintptr_t gp;    // Global pointer
    uintptr_t tp;    // Thread pointer
    uintptr_t t0;    // Temporary
    uintptr_t t1;    // Temporary
    uintptr_t t2;    // Temporary
    uintptr_t s0;    // Saved register/frame pointer
    uintptr_t s1;    // Saved register
    uintptr_t a0;    // Function argument/return value
    uintptr_t a1;    // Function argument/return value
    uintptr_t a2;    // Function argument
    uintptr_t a3;    // Function argument
    uintptr_t a4;    // Function argument
    uintptr_t a5;    // Function argument
    uintptr_t a6;    // Function argument
    uintptr_t a7;    // Function argument
    uintptr_t s2;    // Saved register
    uintptr_t s3;    // Saved register
    uintptr_t s4;    // Saved register
    uintptr_t s5;    // Saved register
    uintptr_t s6;    // Saved register
    uintptr_t s7;    // Saved register
    uintptr_t s8;    // Saved register
    uintptr_t s9;    // Saved register
    uintptr_t s10;   // Saved register
    uintptr_t s11;   // Saved register
    uintptr_t t3;    // Temporary
    uintptr_t t4;    // Temporary
    uintptr_t t5;    // Temporary
    uintptr_t t6;    // Temporary
};

// 栈帧结构体
struct trapframe {
    struct pushregs gpr; // 保存通用寄存器的值
    uintptr_t status;    // 保存处理器状态寄存器的值,这个寄存器包含了有关中断使能、运行模式等状态的信息
    uintptr_t epc;       // 代表程序计数器的值。它指向发生中断或异常时的下一条指令的地址，这样在中断处理完毕后可以从正确的位置继续执行。
    uintptr_t badvaddr;  // 保存导致异常的地址,当访问无效内存地址或权限不足时，这个字段记录下尝试访问的地址，以便进行调试或错误处理。
    uintptr_t cause;     // 存储导致中断或异常的原因。这通常是一个标志位，指示具体的中断类型或异常类型，例如系统调用、外部中断等。
};

void trap(struct trapframe *tf);
void idt_init(void);
void print_trapframe(struct trapframe *tf);
void print_regs(struct pushregs* gpr);
bool trap_in_kernel(struct trapframe *tf);

#endif /* !__KERN_TRAP_TRAP_H__ */
