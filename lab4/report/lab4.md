# LAB4实验报告

## 练习2：为新创建的内核线程分配资源（需要编码）

> 创建一个内核线程需要分配和设置好很多资源。`kernel_thread`函数通过调用`do_fork`函数完成具体内核线程的创建工作。`do_kernel`函数会调用`alloc_proc`函数来分配并初始化一个进程控制块，但`alloc_proc`只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过`do_fork`实际创建新的内核线程。`do_fork`的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们实际需要`fork`的东西就是`stack`和`trapframe`。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在`kern/process/proc.c`中的`do_fork`函数中的处理过程。它的大致执行步骤包括：
>
> - 调用`alloc_proc`，首先获得一块用户信息块。
> - 为进程分配一个内核栈。
> - 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
> - 复制原进程上下文到新进程
> - 将新进程添加到进程列表
> - 唤醒新进程
> - 返回新进程号
>
> 请在实验报告中简要说明你的设计实现过程。请回答如下问题：
>
> - 请说明ucore是否做到给每个新`fork`的线程一个唯一的`id`？请说明你的分析和理由。

### 函数设计实现

根据指导书中给出的执行步骤，实现步骤如下：

1. 调用`alloc_proc`函数，分配并初始化进程控制块；主要工作是通过`kmalloc`函数获得`proc_struct`结构的一块内存块，并把`proc`进行初步初始化。如果没有成功，跳转至`fork_out`处做对应的出错处理。

   ```c
   proc = alloc_proc(); // 分配并初始化进程控制块
   if (proc == NULL)
   {
       goto fork_out;
   }
   ```

2. 调用`setup_kstack`函数，分配并初始化内核栈。主要工作是调用 `alloc_pages` 函数来分配指定大小的页面，然后将分配的页面的虚拟地址赋给进程的 `kstack` 字段，表示该页面是进程的内核栈。如果分配成功，函数返回0表示成功，否则返回错误码 -E_NO_MEM 表示内存不足。如果内存不足，跳转至`bad_fork_cleanup_kstack`处做对应的出错处理。

   ```c
   ret = setup_kstack(proc); // 分配并初始化内核栈
   if (ret == -E_NO_MEM)
   {
       goto bad_fork_cleanup_kstack;
   }
   ```

3. 调用`copy_mm`函数，根据`clone_flags`决定是复制还是共享内存管理系统。由于目前在实验四中只能创建内核线程，所以`copy_mm`中不执行任何操作。

   ```c
   copy_mm(clone_flags, proc);
   ```

4. 调用`copy_thread`函数设置进程的中断帧和上下文。

   ```c
   copy_thread(proc, stack, tf);
   ```

5. 调用`get_pid`函数，为新进程分配PID。

   ```c
   const int pid = get_pid();
   proc->pid = pid;
   ```

6. 把设置好的进程加入进程链表，计算PID哈希值并加入到对应的哈希表。

   ```c
   list_add(hash_list + pid_hashfn(pid), &(proc->hash_link));
   list_add(&proc_list, &(proc->list_link));
   ```

7. 调用`wakeup_pro`函数，将新建的进程设为就绪态。

   ```c
   wakeup_proc(proc);
   ```

8. 总进程数加1。

   ```c
   nr_process++;
   ```

9. 将返回值设为线程id。

   ```c
   ret = pid;
   ```

### 问题回答

> 请说明ucore是否做到给每个新`fork`的线程一个唯一的`id`？请说明你的分析和理由。

ucore调用`get_pid`函数，为每个新线程分配PID，而分析`get_pid`的实现可知，它会返回一个唯一的未被使用的PID。

`get_pid`函数的基本思想是遍历进程列表，在遍历时维护一个区间`[last_pid,next_safe)`，一直保证此区间内始终为未使用的PID。具体方法如下：


- 首次调用时初始化**静态变量**`last_pid`与`next_safe`为最大PID`MAX_PID`，之后的调用会保留上一次调用结束时的值，之后每次调用时`last_pid`的意义是上次分配的PID。
- 如果`++last_pid`小于`next_safe`，直接分配`last_pid`；
- 如果`last_pid`大于等于`MAX_PID`，超出范围了，将`last_pid`重置为1；
- 如果`last_pid`大于等于`MAX_PID`或者`last_pid`大于等于`MAX_PID`，将`next_safe`置为`MAX_PID`，扩张区间范围，在后面的遍历中限缩。接下来就遍历进程链表，获取每个进程的已分配的PID：
  - 如果发现有进程的PID等于`last_pid`，则表明冲突，则增加`last_pid`，就是将区间右移一个。这确保了没有一个进程的`pid`与`last_pid`重合；
  - 如果发现一个进程的PID大于`last_pid`且小于`next_safe`，则将这个进程的PID赋值给`next_safe`，即缩小`next_safe`的范围。这能够保证遍历到目前来说`[last_pid,next_safe)`之间没有已用的PID；
  - 如果在遍历中，`last_pid>=next_safe`，需要将`next_safe`扩张到`MAX_PID`，形成新区间并继续在后面的遍历中限缩。
    - 如果在遍历中，`last_pid`还超出了`MAX_PID`，则还需要将`last_pid`重置为1，继续在后面的遍历中限缩区间。

通过以上的处理，能够保证最终`[last_pid,next_safe)`区间范围内为可用PID。返回`last_pid`即为为新进程分配的唯一PID。
## 练习三
### 代码实现
根据文档的提示与说明，我们参考schedule函数里面的禁止和启用中断的过程，编写代码如下：
```c
void proc_run(struct proc_struct *proc) {
    if (proc != current) {
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
        local_intr_save(intr_flag);
        {
            current = proc;
            lcr3(next->cr3);
            switch_to(&(prev->context), &(next->context));
        }
        local_intr_restore(intr_flag);
    }
}
```
此函数基本思路是:
- 让 current指向 next内核线程initproc;
- 设置 CR3 寄存器的值为 next 内核线程 initproc 的页目录表起始地址 next->cr3，这实际上是完成进程间的页表切换;
- 由 switch_to函数完成具体的两个线程的执行现场切换，即切换各个寄存器，当switch_to 函数执行完“ret”指令后，就切换到initproc执行了。

值得注意的是，这里我们使用1oca1_intr_save()和1ocal_intr_restore()作用分别是屏蔽中断和打开中断，以免进程切换时其他进程再进行调度，保护进程切换不会被中断。

### 问题解答
在本实验中，创建且运行了2两个内核线程:
- idleproc : 第一个内核进程，完成内核中各个子系统的初始化，之后立即调度，执行其他进程。
- initproc : 用于完成实验的功能而调度的内核进程。

## 实验中的知识点
### 进程与线程的关系
我们平时编写的源代码，经过编译器编译就变成了可执行文件，我们管这一类文件叫做`程序`。而当一个程序被用户或操作系统启动，分配资源，装载进内存开始执行后，它就成为了一个`进程`。

进程与程序之间最大的不同在于`进程是一个“正在运行”的实体`，而`程序只是一个不动的文件`。进程包含程序的内容，也就是它的静态的代码部分，也包括一些在运行时在可以体现出来的信息，比如堆栈，寄存器等数据，这些组成了进程“正在运行"的特性。如果我们只关注于那些“正在运行”的部分，我们就从进程当中剥离出来了线程。

一个进程可以对应一个线程，也可以对应很多线程。这些线程之间往往具有相同的代码，共享一块内存，但是却有不同的CPU执行状态。相比于线程，进程更多的作为一个资源管理的实体(因为操作系统分配网络等资源时往往是基于进程的)，这样线程就作为可以被调度的最小单元，给了调度器更多的调度可能。

### 进程调度
上OS课时候宫老师提到过，调度的代价是很大的，其中一般涉及：
- 减少上下文切换涉及的寄存器数量
- 减少不必要的权限切换

一些理论上可以处理的方式包括：
- 纤程 Fiber, ucontext
- 协程 coroutine
- 发挥ULT快速切换的优势
- 在编程时提出对程序员的限制，要求他们妥善的设计代码
