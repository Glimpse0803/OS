#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}

// 用于实现操作系统的进程调度
void schedule(void) {
    // 保存当前的中断状态（intr_flag）
    // 保存中断状态是为了保证调度过程的原子性，即调度期间不能被打断。
    bool intr_flag;
    list_entry_t *le, *last;

    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        // 将当前进程的 need_resched 标志置为 0，表示当前进程不需要再次调度。
        current->need_resched = 0;

        // 根据当前进程是否为空闲进程来决定 last 的位置。如果当前进程是空闲进程（idleproc），则 last 是 proc_list，
        // 即整个进程链表的头部。否则，last 指向当前进程在进程链表中的位置 (current->list_link)，这方便了链表的遍历。
        last = (current == idleproc) ? &proc_list : &(current->list_link);

        // 初始化链表游标 le 为 last，即当前进程的位置。
        le = last;

        // 这里开始遍历进程链表（proc_list），从当前进程的位置 le 开始查找下一个可运行的进程（PROC_RUNNABLE 状态）
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
                    break;
                }
            }
        } while (le != last);

        // 如果没有找到可运行的进程，就设置为空闲进程（idleproc）
        if (next == NULL || next->state != PROC_RUNNABLE) {
            next = idleproc;
        }
        next->runs ++;

        // 如果要调度的进程 next 不是当前进程 current，则调用 proc_run(next) 执行进程切换
        if (next != current) {
            proc_run(next);
        }
    }
    local_intr_restore(intr_flag);
}

