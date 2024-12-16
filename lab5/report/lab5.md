# LAB5实验报告

## 练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不需要编码）
>请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题：
>
>- 请分析fork/exec/wait/exit的执行流程。重点关注哪些操作是在用户态完成，哪些是在内核态完成？内核态与用户态程序是如何交错执行的？内核态执行结果是如何返回给用户程序的？
>
>- 请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）


### 函数分析&执行流程

#### fork函数

>**用户态：fork() -> sys_fork() -> syscall(SYS_fork) -> ecall -> 内核态**
 
 ```c
 int fork(void) {
    return sys_fork();
}
```
```c
int sys_fork(void) {
    return syscall(SYS_fork);
}
```
```c
#define SYS_fork            2
```
---
>**内核态：syscall() -> sys_fork() -> do_fork(0, stack, tf)**
```c
void
syscall(void) {
    struct trapframe *tf = current->tf;
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
        if (syscalls[num] != NULL) {
            arg[0] = tf->gpr.a1;
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            tf->gpr.a0 = syscalls[num](arg);
            return ;
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
static int (*syscalls[])(uint64_t arg[]) = {
    [SYS_exit]              sys_exit,
    [SYS_fork]              sys_fork,
    [SYS_wait]              sys_wait,
    [SYS_exec]              sys_exec,
    [SYS_yield]             sys_yield,
    [SYS_kill]              sys_kill,
    [SYS_getpid]            sys_getpid,
    [SYS_putc]              sys_putc,
    [SYS_pgdir]             sys_pgdir,
};
```
```c

static int
sys_fork(uint64_t arg[]) {
    struct trapframe *tf = current->tf;
    uintptr_t stack = tf->gpr.sp;
    return do_fork(0, stack, tf);
}
```
```c
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe* tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct* proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;

    if ((proc = alloc_proc()) == NULL)
    {
        goto fork_out;
    }
    proc->parent = current;
    assert(current->wait_state == 0);
    if (setup_kstack(proc) != 0)
    {
        goto bad_fork_cleanup_proc;
    }
    ;
    if (copy_mm(clone_flags, proc) != 0)
    {
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc, stack, tf);
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        int pid = get_pid();
        proc->pid = pid;
        hash_proc(proc);
        set_links(proc);
    }
    local_intr_restore(intr_flag);
    wakeup_proc(proc);
    ret = proc->pid;

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```



---

 >**`fork` 的执行流程**

1. **检查进程数限制**：
   - 检查当前系统是否已达到允许的最大进程数量 (`nr_process >= MAX_PROCESS`)。
   - 如果达到限制，直接跳转到 `fork_out`，返回 `-E_NO_FREE_PROC`，表示进程无法创建。

2. **分配进程控制块（`proc_struct`）**：
   - 调用 `alloc_proc()` 创建并初始化一个新的 `proc_struct`，即为子进程分配内核数据结构。
   - 如果分配失败，跳转到 `fork_out`，返回 `-E_NO_MEM`。

3. **设置父子关系**：
   - 将当前进程（`current`）设为子进程的父进程 (`proc->parent = current`)。
   - 确保父进程的 `wait_state` 状态为 0，表示父进程未阻塞等待子进程结束。

4. **分配内核栈**：
   - 调用 `setup_kstack(proc)` 为子进程分配一个独立的内核栈（kernel stack）。
   - 如果分配失败，跳转到 `bad_fork_cleanup_proc`，释放已分配的 `proc_struct`。

5. **复制内存空间**：
   - 调用 `copy_mm(clone_flags, proc)`，根据 `clone_flags` 来共享（`CLONE_VM`）或复制（独立地址空间）父进程的内存描述符（`mm_struct`）。
   - 如果失败，跳转到 `bad_fork_cleanup_kstack`，释放内核栈。

6. **设置子进程上下文（Trapframe 和 Kernel Context）**：
   - 调用 `copy_thread(proc, stack, tf)`，将父进程的用户态寄存器上下文 (`trapframe`) 复制到子进程中，并设置内核态的入口和内核栈。

7. **分配进程 ID 并插入调度结构**：
   - 分配唯一的进程 ID (`pid = get_pid()`)，并将子进程插入进程哈希表（`hash_proc(proc)`）和链表（`proc_list`）。
   - 调用 `set_links(proc)` 建立父子关系和进程链表关系。

8. **唤醒子进程**：
   - 设置子进程状态为 `PROC_RUNNABLE`，使其可以被调度执行。
   - 最终将子进程的 `pid` 赋值给 `ret`，作为返回值。

9. **错误处理**：
   - 在内存分配失败的情况下，执行相应的清理代码，释放已经分配的资源（例如内核栈或 `proc_struct`）。

10. **返回结果**：
    - 成功时返回子进程的 `pid`。
    - 失败时返回相应的错误码（如 `-E_NO_FREE_PROC` 或 `-E_NO_MEM`）。

---

 >**内核态如何返回到用户程序？**

1. **子进程的内核态返回**：
   - 子进程创建完成后，其 `trapframe` 已经设置，包括程序计数器（`EIP` 或 `PC`）和栈指针（`ESP` 或 `SP`）等寄存器的用户态上下文。
   - 调用 `copy_thread` 时，子进程的返回值被设置为 0，这是 `fork` 系统调用在子进程中的返回值。

2. **父进程的内核态返回**：
   - 父进程调用 `do_fork` 并成功返回后，返回值是子进程的 `pid`。

3. **进程切换和返回用户态**：
   - 当内核完成 `do_fork` 后，内核通过调度程序（scheduler）决定是继续执行父进程还是切换到子进程。
   - 子进程第一次运行时，内核会加载 `trapframe`，并通过系统调用的返回路径返回用户态。

4. **`fork` 系统调用的用户态表现**：
   - 在用户态，`fork` 系统调用的返回值区分父子进程：
     - 父进程收到的返回值是子进程的 `pid`。
     - 子进程收到的返回值是 0。

---
#### exec函数

>**内核态：kernel_execve() -> ebreak -> syscall() -> sys_exec() -> do_execve()**

```c
static int kernel_execve(const char *name, unsigned char *binary, size_t size) {
    int64_t ret=0, len = strlen(name);
 //   ret = do_execve(name, len, binary, size);
    asm volatile(
        "li a0, %1\n"
        "lw a1, %2\n"
        "lw a2, %3\n"
        "lw a3, %4\n"
        "lw a4, %5\n"
    	"li a7, 10\n"
        "ebreak\n"
        "sw a0, %0\n"
        : "=m"(ret)
        : "i"(SYS_exec), "m"(name), "m"(len), "m"(binary), "m"(size)
        : "memory");
    cprintf("ret = %d\n", ret);
    return ret;
}
```
```c
static int sys_exec(uint64_t arg[]) {
    const char *name = (const char *)arg[0];
    size_t len = (size_t)arg[1];
    unsigned char *binary = (unsigned char *)arg[2];
    size_t size = (size_t)arg[3];
    return do_execve(name, len, binary, size);
}
```

```c
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
    struct mm_struct *mm = current->mm;
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
        return -E_INVAL;
    }
    if (len > PROC_NAME_LEN) {
        len = PROC_NAME_LEN;
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
    memcpy(local_name, name, len);

    if (mm != NULL) {
        cputs("mm != NULL");
        lcr3(boot_cr3);
        if (mm_count_dec(mm) == 0) {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
        goto execve_exit;
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
    panic("already exit: %e.\n", ret);
}
```

---

> **`exec` 的执行流程**

1. **检查参数有效性**：
   - 使用 `user_mem_check` 确保 `name` 是用户地址空间的合法内存区域，长度为 `len`，并且可以访问。
   - 如果检查失败，返回 `-E_INVAL`。

2. **截断和复制进程名称**：
   - 如果程序名称的长度超过最大允许值（`PROC_NAME_LEN`），截断到允许的最大长度。
   - 将程序名称从用户空间复制到内核栈上的局部缓冲区 `local_name`，以确保安全操作。

3. **释放当前进程的地址空间**：
   - 如果当前进程的内存管理结构（`mm_struct`）不为空，执行以下操作：
     - 使用 `lcr3(boot_cr3)` 切换到内核的页目录表（`boot_cr3`），以避免操作当前进程的页表时发生错误。
     - 调用 `mm_count_dec` 减少 `mm_struct` 的引用计数：
       - 如果引用计数降为 0，调用 `exit_mmap` 释放地址空间中的内存映射区域，调用 `put_pgdir` 释放页目录表，最后调用 `mm_destroy` 销毁整个 `mm_struct`。
     - 将当前进程的 `mm` 设置为 `NULL`。

4. **加载新程序**：
   - 调用 `load_icode(binary, size)` 将新的程序加载到内存中。
   - 如果加载失败（返回非零值），跳转到 `execve_exit`，退出函数。

5. **设置进程名称**：
   - 调用 `set_proc_name` 将当前进程的名称设置为新加载的程序的名称。

---
#### wait函数

>**用户态：wait() -> sys_wait() -> syscall(SYS_wait) -> ecall -> 内核态**

```c
int wait(void) {
    return sys_wait(0, NULL);
}
```
```c
int sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, store);
}
```
```c
#define SYS_wait            3
```
---
>**内核态：syscall() -> sys_wait() -> do_wait()**

```c
static int sys_wait(uint64_t arg[]) {
    int pid = (int)arg[0];
    int *store = (int *)arg[1];
    return do_wait(pid, store);
}
```
```c
int do_wait(int pid, int *code_store) {
    struct mm_struct *mm = current->mm;
    if (code_store != NULL) {
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
            return -E_INVAL;
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    if (pid != 0) {
        proc = find_proc(pid);
        if (proc != NULL && proc->parent == current) {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    else {
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    if (haskid) {
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
        schedule();
        if (current->flags & PF_EXITING) {
            do_exit(-E_KILLED);
        }
        goto repeat;
    }
    return -E_BAD_PROC;

found:
    if (proc == idleproc || proc == initproc) {
        panic("wait idleproc or initproc.\n");
    }
    if (code_store != NULL) {
        *code_store = proc->exit_code;
    }
    local_intr_save(intr_flag);
    {
        unhash_proc(proc);
        remove_links(proc);
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}
```



---

> **`wait` 的执行流程**

1. **检查用户内存空间合法性**：
   - 如果 `code_store` 不为空，检查它是否是合法的用户空间地址，并具有写权限。
   - 如果检查失败，返回 `-E_INVAL` 表示无效参数。

2. **初始化变量**：
   - 设置 `haskid` 为 `0`，用于标识当前进程是否存在子进程。
   - 根据 `pid` 的值分两种情况处理：
     - **特定子进程**：查找指定的子进程。
     - **任意子进程**：遍历当前进程的所有子进程。

3. **查找目标子进程**：
   - **特定子进程**：
     - 调用 `find_proc(pid)` 查找进程控制块。
     - 确认子进程的父进程是否是当前进程（`proc->parent == current`）。
     - 如果该子进程的状态是 `PROC_ZOMBIE`（僵尸进程），跳转到 `found` 标签处理。
   - **任意子进程**：
     - 遍历当前进程的子进程链表，从 `current->cptr`（第一个子进程）开始，检查每个子进程的状态。
     - 如果找到僵尸进程，跳转到 `found` 标签处理。

4. **进入等待状态**：
   - 如果没有找到符合条件的子进程，但当前进程存在子进程（`haskid == 1`），则进入等待：
     - 将当前进程状态设置为 `PROC_SLEEPING`（睡眠态）。
     - 设置等待状态为 `WT_CHILD`，表示当前进程在等待子进程结束。
     - 调用 `schedule()` 让出 CPU。
   - 当被唤醒后，检查是否收到杀死信号（`current->flags & PF_EXITING`），如果是，则调用 `do_exit(-E_KILLED)` 退出。
   - 跳转到 `repeat` 重新开始查找子进程。

5. **清理子进程资源**（`found` 标签）：
   - 检查目标子进程是否是 `idleproc` 或 `initproc`，如果是，触发内核错误（`panic`）。
   - 如果 `code_store` 不为空，将子进程的退出码（`proc->exit_code`）写入到用户空间的 `code_store`。

6. **释放子进程资源**：
   - 禁止中断，调用以下函数清理资源：
     - `unhash_proc(proc)`：从进程哈希表中移除该子进程。
     - `remove_links(proc)`：从父子进程链表中移除该子进程。
   - 恢复中断。
   - 调用 `put_kstack(proc)` 释放子进程的内核栈。
   - 调用 `kfree(proc)` 释放子进程的内核数据结构。

7. **返回成功状态**：
   - 返回值为 0，表示成功等待到子进程并完成资源回收。

---

> **内核态如何返回到用户程序**

1. **进入内核态**：
   - 用户进程通过系统调用进入内核态，内核中调用 `do_wait` 函数处理。

2. **处理中断和睡眠**：
   - 如果父进程需要等待子进程，`do_wait` 会将父进程设置为 `PROC_SLEEPING`，调用 `schedule` 让出 CPU。
   - 当子进程状态改变（如退出并变为 `PROC_ZOMBIE`），内核会唤醒父进程，重新执行 `do_wait` 的逻辑。

3. **完成清理后返回用户态**：
   - 成功：`do_wait` 返回 0，表示等待完成，用户态 `wait` 系统调用返回值为成功状态。
   - 失败：返回负值错误码（如 `-E_BAD_PROC`），表示未找到子进程，用户态 `wait` 系统调用会返回相应的错误。

4. **用户态表现**：
   - 成功时，用户程序的 `waitpid` 会返回子进程的 PID 或成功状态。
   - 如果有指定的 `code_store`，则子进程的退出码会被写入到用户程序的指定位置。

---

#### exit函数

>**用户态：exit() -> sys_exit() -> syscall(SYS_exit) -> ecall -> 内核态**

```c
void exit(int error_code) {
    sys_exit(error_code);
    cprintf("BUG: exit failed.\n");
    while (1);
}
```

```c
int sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
}
```

```c
#define SYS_exit            1
```

---
>**内核态：syscall() -> sys_exit() -> do_exit()**
```c
static int sys_exit(uint64_t arg[]) {
    int error_code = (int)arg[0];
    return do_exit(error_code);
}

```
```c
int do_exit(int error_code) {
    if (current == idleproc) {
        panic("idleproc exit.\n");
    }
    if (current == initproc) {
        panic("initproc exit.\n");
    }
    struct mm_struct *mm = current->mm;
    if (mm != NULL) {
        lcr3(boot_cr3);
        if (mm_count_dec(mm) == 0) {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
    }
    current->state = PROC_ZOMBIE;
    current->exit_code = error_code;
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        proc = current->parent;
        if (proc->wait_state == WT_CHILD) {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL) {
            proc = current->cptr;
            current->cptr = proc->optr;
    
            proc->yptr = NULL;
            if ((proc->optr = initproc->cptr) != NULL) {
                initproc->cptr->yptr = proc;
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE) {
                if (initproc->wait_state == WT_CHILD) {
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    schedule();
    panic("do_exit will not return!! %d.\n", current->pid);
}
```


---

>**`do_exit` 的执行流程**

1. **禁止关键进程退出**：
   - 检查当前进程是否是 `idleproc`（空闲进程）或 `initproc`（初始进程），这两类进程不允许退出。
   - 如果尝试退出，触发内核恐慌（`panic`）。

2. **释放当前进程的内存资源**：
   - 如果当前进程的内存管理结构（`mm`）不为空：
     - 切换页表到 `boot_cr3`（内核页表）。
     - 调用以下函数释放进程的内存资源：
       - `exit_mmap(mm)`：释放进程的所有虚拟内存区域。
       - `put_pgdir(mm)`：释放页目录表。
       - `mm_destroy(mm)`：销毁内存管理结构。
     - 将 `current->mm` 设置为 `NULL`，表示该进程不再关联任何内存。

3. **设置进程状态为僵尸态**：
   - 将当前进程的状态设置为 `PROC_ZOMBIE`。
   - 保存退出码 `error_code` 到 `current->exit_code`，供父进程回收时使用。

4. **通知父进程**：
   - 保护关键区，禁止中断。
   - 获取当前进程的父进程指针 `current->parent`：
     - 如果父进程的等待状态是 `WT_CHILD`，调用 `wakeup_proc(proc)` 唤醒父进程，让其处理子进程的退出。

5. **重新分配子进程**：
   - 如果当前进程有子进程，将其所有子进程重新分配给 `initproc`：
     - 遍历当前进程的子进程链表。
     - 将每个子进程的父进程指针（`proc->parent`）修改为 `initproc`。
     - 调整子进程链表中的前后指针以完成迁移。
     - 如果某个子进程已经是僵尸态，并且 `initproc` 处于 `WT_CHILD` 状态，则唤醒 `initproc` 以处理这些子进程。

6. **调度器切换到其他进程**：
   - 恢复中断。
   - 调用 `schedule()` 切换到其他进程。
   - **注意**：由于当前进程状态已被设置为僵尸态，它将不再被调度执行。

7. **永不返回**：
   - 在退出逻辑的最后调用 `panic` 以防止程序返回，因为理论上 `do_exit` 不会返回到调用者。

---

> **内核态如何完成退出并返回给用户程序**

1. **从用户态进入内核态**：
   - 用户进程调用 `exit` 系统调用。
   - 内核进入 `do_exit` 函数处理退出逻辑。

2. **切换到僵尸态**：
   - 内核将进程状态设置为 `PROC_ZOMBIE`，并释放大部分资源（如内存、内核栈）。

3. **通知父进程**：
   - 唤醒父进程，让其通过 `wait` 系统调用回收子进程的资源。
   - 父进程通过 `wait` 获取子进程的退出码和状态。

4. **切换到其他进程**：
   - 调用 `schedule` 将 CPU 控制权交给其他可运行的进程。
   - 当前进程进入僵尸态后，直到被父进程回收才会被完全清除。

5. **退出的结果传递**：
   - 对于用户程序：
     - `exit` 系统调用通常不返回，表示进程退出。
     - 父进程可以通过 `wait` 或 `waitpid` 获取退出结果。

6. **僵尸态清理**：
   - 子进程的状态和退出码保存在其进程控制块中，直到父进程回收。
   - 只有在父进程调用 `wait` 回收子进程后，子进程的所有资源才会完全释放。

---

>**内核到用户程序的交互**

- 内核中 `do_exit` 负责进程退出及资源释放，退出后不直接返回用户态。
- 父进程通过 `wait` 获取子进程的退出码并完成回收。
- 整个过程由调度器 `schedule` 管理，确保 CPU 资源分配给其他进程。


### ucore中一个用户态进程的执行状态生命周期图

![alt text](1.jpg)


## 扩展练习 Challenge2
>说明该用户程序是何时被预先加载到内存中的？与我们常用操作系统的加载有何区别，原因是什么？




### **该用户程序的加载方式**


1. **用户程序的编译和链接**：
   - 用户程序在编译时会被链接到内核映像中，通常是通过在编译时静态链接的方式，这样用户程序就成了内核的一部分。
   - 编译时，用户程序的起始位置和大小已经在内核中定义，程序不会存在于外部存储设备上，而是直接包含在内核映像中。

2. **内核加载程序**：
   - 在 `user_main()` 函数中，调用 `KERNEL_EXECVE` 宏，并进一步调用 `kernel_execve()` 函数。
   - `kernel_execve()` 函数调用 `load_icode()` 函数将已经在内核映像中的用户程序加载到内存中的合适位置。
   - 这种方式通过内核进程直接将用户程序从内核空间加载到内存中，而不依赖于外部存储设备。

3. **执行用户程序**：
   - 加载完成后，内核会为用户程序创建进程结构体，设置相关上下文，并通过调度器将控制权交给用户程序开始执行。

---

### **与常用操作系统的区别**

| **特性**                | **该用户程序**                                      | **常用操作系统**                                 |
|-------------------------|-----------------------------------------------|-----------------------------------------------|
| **加载时机**            | 用户程序在编译时就与内核链接，内核初始化时加载到内存。  | 用户程序通常存储在磁盘等外部存储介质上，按需加载。 |
| **加载机制**            | 用户程序是内核映像的一部分，直接通过内核加载到内存。     | 用户程序在运行时从磁盘或其他存储介质加载到内存。 |
| **文件系统支持**        | 没有实现硬盘和文件系统，用户程序和内核共享内存。   | 常用操作系统实现了文件系统，可以访问磁盘并动态加载程序。 |
| **动态链接和加载**      | 无动态链接机制，用户程序已链接到内核映像中。             | 支持动态链接库和按需加载机制，程序可以动态链接和加载。 |

---

### **原因**

1.  uCore 并没有实现硬盘驱动、文件系统、虚拟内存等复杂功能。因此，用户程序和内核程序被静态地链接在一起，并在内核初始化时直接加载到内存中。这大大简化了内核的实现，避免了需要处理外部存储设备和文件系统的复杂性。

2. 在常用操作系统中，用户程序需要存储在外部存储设备上，并通过文件系统动态加载。这不仅涉及复杂的存储管理，还要求内核支持硬盘驱动、文件系统操作、磁盘调度等多个组件。uCore 将所有这些复杂的功能简化为一个固定的程序加载机制，这样可以减少对硬件的依赖。

3. uCore 没有实现硬盘和文件系统功能，用户程序无法从磁盘加载，因此将程序编译到内核中就成了唯一可行的方式。这样，在 uCore 的环境下，所有程序都可以在内存中运行，而不需要外部存储设备的支持。



