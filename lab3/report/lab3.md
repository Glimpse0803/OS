# Lab 3 实验报告
## 练习1：理解基于FIFO的页面替换算法
>描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了kern/mm/swap_fifo.c文件中，这点请同学们注意）
>
>至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数

我们按照一个页面被换入到被换出的过程来分析函数都做了什么。


**1.do_pg_fault（在vmm.c中）：**

它是用于根据错误地址和错误代码判断访问是否合法从而处理页错误异常的（整个处理缺页异常的开始），如果合法则分配页面或从磁盘加载相应页面到内存中，并建立物理地址与逻辑地址的映射，同时管理页面的可交换性。



**2.find_vma（在vmm.c中，在处理缺页异常的开始被调用，即do_pg_fault）:**

（在处理缺页异常的开始被调用，即do_pg_fault）这个函数用于查找包含产生异常的地址addr的虚拟内存区域（VMA），如果找到则将其缓存至mmap_cache以加速后续查找。  

**3.get_pte（在pmm.c中，在do_pg_fault中被调用）：**

这个函数用于获取指定线性地址la（即产生异常的地址处）的页表项（PTE），并返回其对应的内核虚拟地址；如果页表项不存在（包括一级、二级页目录项）并且create为真，则分配新页面为页表来存储映射关系。

**4.pgdir_alloc_page（在pmm.c中，在do_pg_fault中被调用）：**

它用于分配一个新页面，并将其映射到给定线性地址la（即产生异常的地址处）的页目录pgdir中；如果页面置换功能已初始化，它会将页面标记为可置换。


**5.alloc_page& alloc_pages（在pmm.h & pmm.c中，在get_pte、pgdir_alloc_page中被调用）：**

这两个函数都用于分配页面。其中alloc_page通过调用alloc_pages(1)分配一个页面，而alloc_pages则尝试分配n个页面，并在页面不足且swap功能启用时执行页面交换以释放空间（调用swap_out）。



**6.swap_out（在swap.c中，在alloc_pages中被调用）：**

swap_out函数用于将指定数量（n）的页面从内存换出到磁盘交换区。它选择需要置换的页面，将页面内容写入磁盘后释放内存，并更新页表以反映换出的状态。



**7.swap_out_victim&_fifo_swap_out_victim（在swap.c、swap_fifo.c中，在swap_out中被调用）:**

我们以FIFO页面替换算法为例来讲解swap_out_victim都干了什么。

_fifo_swap_out_victim函数用于选择并移除最近最早插入（FIFO）的页面作为换出页面，并将其地址赋给ptr_page。

**8.swapfs_write（在swapfs.c中，在swap_out中被调用）：**

swapfs_write函数将页面数据写入交换文件系统中的指定位置。调用ide_write_secs函数，将页面内容写入交换设备的目标扇区。

**9.map_swappable&_fifo_map_swappable（在swap.c、swap_fifo.c中，在swap_out中被调用）:**

我们以FIFO页面替换算法为例来讲解map_swappable都干了什么。

fifo_map_swappable函数将页面映射为可交换状态，并将其添加到FIFO（先进先出）页面替换队列中,将页面放置在FIFO链表的尾部，记录了页面的到达顺序，从而在将来实现FIFO页面替换策略。

**10.free_page（在pmm.c中，在swap_out中被调用）:**

free_pages函数用于释放一块连续的内存，大小为n * PAGESIZE，调用pmm_manager的free_pages方法来实现具体的内存释放操作。

**11.tlb_invalidate（在pmm.c中，在swap_out中被调用）:**

tlb_invalidate函数用于刷新TLB，使当前处理器所使用的页表条目无效，确保对页面表的更改被正确反映在处理器的翻译后备缓冲区（TLB）中。该函数通过调用flush_tlb()来清除TLB的所有条目。

**12.swap_in（在swap.c中，在do_pg_fault中被调用）：**

swap_in函数用于将指定虚拟地址（addr）对应的页面从磁盘交换区加载回内存，并将其关联到ptr_result指向的页面结构。


**13.swapfs_read（在swapfs.c中，在swap_in中被调用）：**

swapfs_read函数从交换设备读取指定的交换条目并将其内容存储到给定的页面中(使用`ide_read_secs`函数从交换设备读取数据)。该函数通过读取与交换条目对应的物理地址块，将数据加载回内存。

**14.page_insert（在pmm.c中，在do_pg_fault中被调用）：**

page_insert函数将指定的物理页面插入到页目录中，映射到给定的线性地址，并设置相应的权限。它确保正确处理引用计数和现有页面的替换，同时更新TLB以保持内存访问的有效性。

**15.swap_map_swappable（在swap.c中，在do_pg_fault中被调用）:**

调用map_swappable函数。实现map_swapppable函数的功能。

 **16.assert：**
 
 assert用于检查给定条件是否为真。如果条件为假（即返回值为0），程序会抛出一个错误并终止执行。

  
## 练习二：深入理解不同分页模式的工作原理(思考题)

`get_pte()`函数(位于`kern/mm/pmm.c`)用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。

- `get_pte()`函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。
- 目前`get_pte()`函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？


### 问题一

**(1)get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。**

首先我们先对`get_pte()`函数中这两段形式类似的代码进行分析：

第一段代码：
```C
pde_t *pdep1 = &pgdir[PDX1(la)];
//pgdir是根页目录表
//PDX(la) = 虚拟地址la的一级页目录项索引。
//pdep1指向线性地址la的一级页目录表项
if (!(*pdep1 & PTE_V)) {// 如果一级页目录表项不存在或无效
    struct Page *page;//分配一个新的物理页
    if (!create || (page = alloc_page()) == NULL) {
        // 如果不需要创建或者分配页面失败
        return NULL;//返回NULL
    }
    set_page_ref(page, 1);//将页面的引用次数置一
    uintptr_t pa = page2pa(page);//获取由此page管理的内存的物理地址
    memset(KADDR(pa), 0, PGSIZE);//将对应的物理地址指向的内存区域清零
    *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);//创建页表项，初始化为指向这个物理页的地址，标记为用户可访问(PTE_U)和有效(PTE_V)
}
```
第二段代码：

```C
pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
//PDE_ADDR(*pdep1)将页表项里存储的地址取出
//KADDR(PDE_ADDR(*pdep1))将物理地址转换为内核虚拟地址
//PDX0(la)= 虚拟地址la的二级页目录项索引
//((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)]是二级页目录表项
if (!(*pdep0 & PTE_V)) {// 如果二级页目录表项不存在或无效
    struct Page *page;//分配一个新的物理页
    if (!create || (page = alloc_page()) == NULL) {
       // 如果不需要创建或者分配页面失败
        return NULL;//返回NULL
    }
    set_page_ref(page, 1);//将页面的引用次数置一
    uintptr_t pa = page2pa(page);//获取由此page管理的内存的物理地址
    memset(KADDR(pa), 0, PGSIZE);//将对应的物理地址指向的内存区域清零
    *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);//创建页表项，初始化为指向这个物理页的地址，标记为用户可访问(PTE_U)和有效(PTE_V)
}
```
这两段代码的作用是：

1. 获取指定线性地址（la）对应的二级页表项（PDE）的指针。
2. 检查这个二级页表项是否有效（即是否存在于内存中）。
3. 如果二级页表项无效或者不存在，则执行以下操作：
    - 尝试分配一个新的物理页，并设置相应的标志位。
    - 如果分配成功，则初始化这个物理页，并设置相应的页表项，使得虚拟地址映射到这个新的物理页上。


SV39中的虚拟地址结构如下：

| VPN[2] | VPN[1] | VPN[0] | PGOFF |
| :----: | :----: | :----: | :---: |
|   9    |   9    |   9    |  12   |

物理地址如下：

| PPN[2] | PPN[1] | PPN[0] | PGOFF |
| :----: | :----: | :----: | :---: |
|   26   |   9    |   9    |  12   |

其页表项结构如下：

| PPN[2] | PPN[1] | PPN[0] | 保留位 |  D   |  A   |  G   |  U   |  X   |  W   |  R   |  V   |
| :----: | :----: | :----: | :----: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: |
|   26   |   9    |   9    |   2    |  1   |  1   |  1   |  1   |  1   |  1   |  1   |  1   |

SV48与SV39很类似，主要区别如下：

- 虚拟地址位数：SV39使用39位虚拟地址，而Sv48使用48位虚拟地址。
- 页表级别：SV39有两级页表（一级和二级页目录），而Sv48有三级页表（一级、二级和三级页目录）。
- 地址空间大小：由于虚拟地址位数不同，SV39支持的虚拟地址空间大小为512GB，而Sv48支持的虚拟地址空间大小为256TB。

这两种配置为不同的应用场景提供了灵活性，例如，对于需要大量虚拟地址空间的系统，Sv48是一个更好的选择。而对于不需要如此大地址空间的系统，SV39则可能更加高效。

SV48结构如下：


| VPN[3] | VPN[2] | VPN[1] | VPN[0] | PGOFF |
| :----: | :----: | :----: | :----: | :---: |
|   9    |   9    |   9    |   9    |  12   |

物理地址如下：

| PPN[3] | PPN[2] | PPN[1] | PPN[0] | PGOFF |
| :----: | :----: | :----: | :----: | :---: |
|   17   |   9    |   9    |   9    |  12   |

页表项如下：

| PPN[3] | PPN[2] | PPN[1] | PPN[0] | 保留位 |  D   |  A   |  G   |  U   |  X   |  W   |  R   |  V   |
| :----: | :----: | :----: | :----: | :----: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: |
|   17   |   9    |   9    |   9    |   2    |  1   |  1   |  1   |  1   |  1   |  1   |  1   |  1   |

在虚拟地址与物理地址互转时，他们都是**相同的逻辑进行映射**：

以SV39为例：

首先从satp寄存器得到PGD的物理地址，结合VPN找到PMD；找到PMD后，再结合VPN[1]找到PTE，然后结合VPN[0]得到VA在PTE索引中的值，从而得到物理地址。

物理地址计算如下：

~~~c
Physical Address = (PTE.PPN << 12) | VA.Page Offset

~~~
最后在PTE中取出PPN[2]、PPN[1]和PPN[0]，再和虚拟地址的低12位offset相加，得到最终的物理地址。
计算方式如下：

~~~c
Physical Address = (PPN[2]:PPN[1]:PPN[0] << 12) | VA.offset
~~~
在**页表结构上也使用同样的存储方式**：

每一个页表项是8KiB，一个页的大小为4KB，因此一个根目录表中能够存放512个一级页表的页表项，而512个页表项恰好可以由9位的PPN索引。一个一级页表的页目录表中能够存放512个二级页表项，一个二级页表的页目录表中能够存放512个三级页表项。一级页目录表与二级页目录表的结构几乎相同，因此代码的逻辑结构也基本相同。

SV48在逻辑上与SV39的页表映射相类似，代码结构也相同。除此之外还有对应五级页表的Sv57也与之类似。

Sv32适用于32位系统，因此地址结构略微有些变化。

Sv32的虚拟地址结构如下：

| VPN[1] | VPN[0] | PGOFF |
| :----: | :----: | :---: |
|   10   |   10   |  12   |

物理地址如下：

| PPN[1] | PPN[0] | PGOFF |
| :----: | :----: | :---: |
|   12   |   10   |  12   |

其页表项结构如下：

| PPN[1] | PPN[0] | 保留位 |  D   |  A   |  G   |  U   |  X   |  W   |  R   |  V   |
| :----: | :----: | :----: | :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: |
|   12   |   10   |   2    |  1   |  1   |  1   |  1   |  1   |  1   |  1   |  1   |

在Sv32中，支持4GiB的虚址空间，这些空间被划分为2^10 个4KiB大小的基页。页表项的大小为4B，那么一个页中能够存放1024个页表项，刚好可以由10位PPN索引。在Sv32中变化为10位索引的两级页面查找，但由于Sv32中的页表的大小和每个页的大小也是完全相同的，因此在逻辑上仍然与Sv39和Sv48类似。

### 问题二

**(2)目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？**

当两个功能合并在同一个函数中时，如果查找一个页表项时包含此pte的页表不存在，那么这函数就会自动地为页表分配一页并返回，只有在分配失败时函数返回才是错误的。

我们假设拆开后的新函数为 `pte_find()` `pte_new()` 。
- `pte_find()`用于找到一个页表项，若找到了就返回页表项的地址；失败则返回null；

在我们的程序中，有三处调用了`get_pte()`函数。
- 在`do_pgfault`中，我们需要获取页面错误地址对应的页表项；
- 在`swap_out`中，我们需要获取被换出页面的页表项；
- 在`swap_in`需要获取我们为即将调入的数据所分配的页面的页表项。

在这三处中，我们调用`get_pte()`函数的目的都是希望得到一个页表项的地址，无论是找到已经存在的或者是操作系统为其重新创建的，而不是仅仅调用`pte_find()`函数后返回NULL值后不做任何处理。


`pte_fine()`函数在查找过程中会遇到许多失败，失败的情况主要有：

页表项查找与创建的分离：
`pte_find`函数： 此函数负责查找给定虚拟地址对应的页表项。它需要遍历多级页表结构（例如在Sv32中是两级），以找到最终的页表项。

错误情况： 
- 在查找过程中，可能会遇到以下错误情况：
第一级页表项（PDE，Page Directory Entry）不存在。
- 第二级页表项（PTE，Page Table Entry）不存在。

错误处理：
- 当pte_find函数遇到错误时，它需要返回一个指示错误类型的值。根据这个返回值，调用者需要决定下一步的操作：
- 如果第一级页表项不存在， 则需要调用pte_new函数来创建一个新的第一级页表项，并更新页全局目录（PGD）以指向这个新的页表。
- 如果第二级页表项不存在， 则需要在已经存在的第一级页表项指向的页表中创建一个新的页表项。

在出现上述错误后，要利用`pte_new()`函数创建页表项。pte_new函数负责以下任务：
- 分配物理内存以创建新的页表；
- 在相应的页表中创建一个新的页表项。
- 设置页表项的权限、标志位等。


其次，我们要判断拆开后的复杂性。

拆分`pte_find()`和`pte_new()`函数后，处理流程的复杂性主要体现在以下几个方面：

- 错误判断： 调需要根据`pte_find`的返回值来判断是哪一级页表项缺失，并做出相应的处理。
- 多次调用： 在一些情况下，可能需要先创建第一级页表项，然后再次调用pte_find来查找或创建第二级页表项；
- 状态管理： 需要管理页表项的创建状态，确保在多级页表结构中正确地创建和更新页表项；
- 内存分配： 需要处理物理内存的分配，确保不会出现内存泄漏或冲突；

结论：
虽然拆分pte_find和pte_new函数可以提高代码的清晰度和模块化，但它也引入了更复杂的错误处理和流程控制。
在本次实验中，如果一个虚拟地址对应的二级页表和三级页表都不存在，将会频繁地调用这些函数，这会增加调用指令产生的成本。

在简易页面置换算法中，不拆分函数会减少调用时的开销。


因此，在我们实现的建议页面算法中，没有必要拆分这个函数。
接下来我们对比一下这两种的策略。

1. 合并查找和分配的优缺点：

- 优点：

    - 简化逻辑： 将查找和分配操作合并到一个函数中可以简化某些操作，因为它们通常是连续发生的。例如，在处理缺页异常时，需要查找PTE，如果未找到，则需要分配一个新的页表项。

    - 减少函数调用： 减少函数调用的次数可能会提高效率，因为每次函数调用都可能带来一定的开销。

- 缺点：

    - 单一职责原则： 软件工程中的单一职责原则建议每个函数或模块应该只负责一件事情。合并查找和分配违反了这一原则，可能导致函数复杂度增加。

    - 代码可维护性： 当一个函数承担多个职责时，它可能更难以理解和维护。如果将来需要修改查找逻辑或分配逻辑，可能会相互影响。

    - 灵活性降低： 如果其他部分的代码只需要单独的查找或分配功能，使用合并的函数可能会导致不必要的操作，降低代码的灵活性。

2. 是否拆分功能：

    - 如果get_pte()函数只在处理缺页异常时使用，并且缺页异常处理流程总是需要查找和分配，那么合并可能是合理的。
    - 如果get_pte()函数在其他上下文中也被使用，而这些上下文只需要查找而不需要分配，那么拆分函数可能更合适；
    - 应当注意的时，我们还要比对调用的次数，出现缺页异常的频繁程度来确定是否拆分函数功能。



在实际设计中，拆分功能的设计更符合单一职责原则，提高了代码的可读性、可维护性和灵活性。同时，它也使得单元测试更加容易，因为每个函数都可以独立测试。

而在我们实现的算法中，我认为没有必要拆分功能。


## 练习3：给未被映射的地址映射上物理页
>  补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限 的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制结构所指定的页表，而不是内核的页表。
>
>请在实验报告中简要说明你的设计实现过程。请回答如下问题：
>
>**1.请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。**
>
>**2.如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？**



#### 函数功能

`do_pgfault` 是一个处理缺页异常的函数。它在进程尝试访问未映射的内存地址时被调用。该函数首先检查该地址是否在进程的虚拟内存区域（VMA）中，然后决定是分配新页面、从磁盘加载页面还是返回错误。

#### 代码实现及详细注释

```c
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;  // 初始化返回值为无效地址错误
    // 尝试找到包含 addr 的 VMA（虚拟内存区域）
    struct vma_struct *vma = find_vma(mm, addr);

    pgfault_num++;  // 增加缺页错误计数

    // 检查 addr 是否在 mm 的 VMA 范围内
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and can not find it in vma\n", addr); // 地址无效且未找到对应的 VMA
        goto failed; // 跳转到失败处理
    }

    /* 
     * 如果 (写入已存在的地址) 或 
     *    (写入不存在的地址且该地址可写) 或 
     *    (读取不存在的地址且该地址可读) 
     * 则继续处理 
     */
    uint32_t perm = PTE_U; // 默认权限为用户可读
    if (vma->vm_flags & VM_WRITE) { // 检查 VMA 是否可写
        perm |= READ_WRITE; // 如果可写，添加写权限
    }
    addr = ROUNDDOWN(addr, PGSIZE); // 将地址向下对齐到页面大小边界

    ret = -E_NO_MEM; // 初始化返回值为内存不足错误

    pte_t *ptep = NULL;  // 页面表项指针

    // 尝试找到一个 PTE，如果页面表（PT）不存在，则创建一个
    // 注意第三个参数 '1' 表示创建页面表
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
        cprintf("get_pte in do_pgfault failed\n"); // 获取 PTE 失败
        goto failed; // 跳转到失败处理
    }

    if (*ptep == 0) { // 如果物理地址不存在，则分配页面并将逻辑地址映射到物理地址
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n"); // 页面分配失败
            goto failed; // 跳转到失败处理
        }
    } else {
        /* LAB3 EXERCISE 3: YOUR CODE
         * 现在我们认为 pte 是一个交换条目
         * 应该从磁盘加载数据并放入物理地址的页面中
         * 并将物理地址与逻辑地址映射，触发交换管理器记录该页面的访问情况
         */
        if (swap_init_ok) { // 检查交换初始化是否成功
            struct Page *page = NULL; // 声明页面指针
            // (1) 根据 mm 和 addr，尝试加载正确的磁盘页面内容
            swap_in(mm, addr, &page); // 从磁盘加载页面内容到内存

            // (2) 根据 mm、addr 和 page，建立物理地址与逻辑地址的映射
            page_insert(mm->pgdir, page, addr, perm); // 将页面插入页表

            // (3) 使页面可交换
            swap_map_swappable(mm, addr, page, 1); // 记录页面为可交换
            page->pra_vaddr = addr; // 设置页面的虚拟地址
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep); // 如果未初始化交换
            goto failed; // 跳转到失败处理
        }
    }

    ret = 0; // 设置返回值为成功
failed:
    return ret; // 返回结果
}
```
接下来，对我们补充的代码做出注释。


**swap_in函数**

```c
swap_in(mm, addr, &page);
```

- **功能**：`swap_in` 从交换区（磁盘）中读取页面内容并加载到内存中。
- **参数**：
  - `mm`：类型为 `struct mm_struct *`，表示当前进程的内存管理结构，包含了进程的页表 `pgdir` 和 `sm_priv`。`pgdir` 用于定位页面对应的物理地址映射，而 `sm_priv` 是交换管理器私有数据，管理页面换入换出。通过它可以获取进程的页表和相关虚拟内存信息。
  - `addr`：类型为 `uintptr_t`，表示触发缺页异常的虚拟地址。`swap_in` 根据这个地址找到对应的交换条目，并将磁盘上的页面数据加载到物理内存中。
  - `&page`：类型为 `struct Page **`，用于返回加载到内存中的页面对象指针。`swap_in` 中分配了一个物理页面，将数据从磁盘加载到该页面中，然后通过 `&page` 返回。


**page_insert函数**

```c
page_insert(mm->pgdir, page, addr, perm); 

```

- **功能**：`page_insert` 将一个物理页面与指定的虚拟地址进行映射，并设置相应的权限。
- **参数**：
  - `mm->pgdir`：页目录指针，位于 `mm->pgdir` 中。它是页面表的根节点，通过它可以找到并修改与 `la` 对应的页表项，实现虚拟地址和物理地址的映射。
  - `page`：类型为 `struct Page *`，表示将要映射的物理页面结构体。`page_insert` 会将 `page` 映射到虚拟地址 `la`，并在页表项中增加 `page` 的引用计数。
  - `la`：类型为 `uintptr_t`，表示虚拟地址，是页面的逻辑地址。`page_insert` 将页面插入到页表中，使这个虚拟地址与 `page` 所对应的物理地址进行映射。
  - `perm`：类型为 `uint32_t`，表示权限标志。它定义了页面的访问权限（可读、可写、用户模式等），`page_insert` 会根据这些权限设置页表项中的标志位。

**swap_map_swappable函数**

```c
swap_map_swappable(mm, addr, page, 1); 
int swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
```

- **功能**：`swap_map_swappable` 将页面标记为“可交换”，即可以在内存和交换区之间进行交换。这个函数一般用于管理页面的访问记录，以便在需要时将其换出。
- **参数**：
  - `mm`：类型为 `struct mm_struct *`，表示当前进程的内存管理结构，包含了进程的页表 `pgdir` 和 `sm_priv`。`pgdir` 用于定位页面对应的物理地址映射，而 `sm_priv` 是交换管理器私有数据，管理页面换入换出。通过它可以获取进程的页表和相关虚拟内存信息。
  - `addr`：类型为 `uintptr_t`，表示页面的虚拟地址。`swap_map_swappable` 使用该地址标记页面 `page` 为可交换，并将其加入交换队列进行管理。
  - `page`：类型为 `struct Page *`，表示要标记为可交换的页面结构。`swap_map_swappable` 会将页面添加到交换管理器的可交换页面队列中，以便进行换入换出管理。
  - `1`：类型为 `int`，用于指定该页面是从交换区换入的，还是新创建的。`swap_in == 1` 表示页面从交换区读取后加载到了内存。



>#### 详细设计实现过程

1. **初始化和VMA查找**:
   - 初始化返回值为无效地址错误，增加缺页错误计数。
   - 调用 `find_vma` 函数检查 `addr` 是否在进程的虚拟内存区域内。如果不在，打印错误信息并跳转到失败处理。

2. **权限设置**:
   - 初始化权限为用户可读，检查 VMA 的标志位，如果是可写，则添加写权限。将地址向下对齐到页面大小边界。

3. **PTE查找**:
   - 调用 `get_pte` 函数尝试找到与 `addr` 相关联的页表项，如果不存在则创建一个。如果无法获取页表项，打印错误信息并跳转到失败处理。

4. **页面分配或交换处理**:
   - 检查 PTE 是否为0，如果是，则表示物理地址不存在，调用 `pgdir_alloc_page` 分配一个新的页面。
   - 如果 PTE 不为0，表示页面已经存在，但可能是一个交换条目。此时检查交换初始化是否成功：
     - 使用 `swap_in` 从磁盘加载页面内容到内存。
     - 使用 `page_insert` 将物理地址与逻辑地址映射。
     - 使用 `swap_map_swappable` 将页面标记为可交换，并设置页面的虚拟地址。


>#### 页目录项和页表项中组成部分对ucore实现页替换算法的潜在用处。

在 uCore 的页替换算法实现中（包括 `swap_in`、`swap_out`、`pgdir_alloc_page` 等函数），页目录项（PDE）和页表项（PTE）中的各组成部分起到了关键作用。它们记录了页面的状态和映射信息，便于管理页面的加载、替换和换出操作。

 **1. 有效位**
   - **作用**：有效位指示页面是否已加载到物理内存中。
   - **用法**：页替换算法通过检查有效位来判断页面是否需要从磁盘换入。在 `do_pgfault` 函数中，通过有效位可以确定是否需要调用 `pgdir_alloc_page` 分配新页面，或调用 `swap_in` 来换入页面。如果某个页面的有效位为 0 且有访问请求时，就会触发缺页异常，从而调用 `swap_in` 函数将该页面从磁盘加载到内存中。如下所示：
   ```c
       if (*ptep == 0) {
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } 
    else {

        if (swap_init_ok) {
            struct Page *page = NULL;
            swap_in(mm, addr, &page);
            ......}}
  ```

**2.权限位**
   - **作用**：权限位定义了页面的读、写、执行权限。
   - **用法**：权限位用于确保页面在被换入时分配正确的权限。当一个页面被重新加载到内存时，`page_insert` 函数会重新设置 PTE 中的权限位，以保证该页面的访问属性与对应的 VMA 权限相符。此外，在 `do_pgfault` 中，根据 VMA 的 `vm_flags` 来设置页面权限。对于需要写入权限的页面，将 PTE 设置为可写。如下所示：
```c
   ///page_insert:
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
///do_pgfault:
       if (vma->vm_flags & VM_WRITE) {
        perm |= (PTE_R | PTE_W);
    }

```

 **3.物理地址**
   - **作用**：存储页面在物理内存或磁盘中的实际地址。
   - **用法**：在页面被换入内存时，`swap_in` 函数将物理地址存入页表项中，从而建立虚拟地址和物理地址之间的映射关系。`page_insert` 函数使用该地址更新页表项。在 `pgdir_alloc_page` 中调用 `page_insert` 时，物理页框地址被设置在 PTE 中，确保虚拟地址 `la` 可以正确映射到物理页面。如下所示：
```c
///swap_in
 pte_t *ptep = get_pte(mm->pgdir, addr, 0);

///page_insert
pte_t *ptep = get_pte(pgdir, la, 1);

///pgdir_alloc_page

  if (page_insert(pgdir, page, la, perm) != 0) 
```

 **4.换出标记**
   - **作用**：记录页面在磁盘中的位置，用于需要换入的情况。
   - **用法**：当页面被换出时，在 `swap_out` 函数中，`swapfs_write` 将页面写入磁盘并更新页表项的换出标记，确保页面被正确换出，并保留换入所需的信息。换入时，`swap_in` 会根据该位置找到对应的磁盘数据并加载到内存。



>#### 如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

1. **捕获新异常**：处理器会捕获新的页访问异常，并更新当前的异常状态。硬件将保存当前的处理器状态，例如程序计数器（PC）和相关的寄存器，以便在处理完异常后恢复。

2. **更新异常状态寄存器**：处理器会将新的异常信息（包括异常地址和异常原因）存储到指定的异常寄存器中。例如，`scause`和`stval`寄存器会分别记录异常原因和访问的虚拟地址。

3. **进入异常处理程序**：处理器根据新的异常类型和优先级跳转到相应的异常处理程序。通常，处理器会从`stvec`寄存器中读取异常处理程序的入口地址，然后跳转到该地址。即trap.c文件中的trap函数。根据异常原因，选择对应的异常处理函数，对于页访问异常应该是用pgfault_handler，再到do_pgfault处理缺页异常。

4. **递归处理缺页异常**：处理器会再次进入缺页异常处理程序。不过这次，操作系统的异常处理程序可能会检查当前的异常嵌套级别，以避免递归导致的栈溢出。若异常嵌套过多，系统可能会触发一个“内核恐慌”（kernel panic）或终止当前进程以保护系统稳定性。

5. **恢复上下文**：如果缺页例程能够成功处理所有缺页异常，它会恢复原始的上下文，并继续执行原来的代码。

>#### 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

有。

`Page` 数据结构用于管理物理内存页帧的状态信息，而页目录项和页表项则用于将虚拟地址映射到实际的物理地址。

`Page` 数组的每一个项（即每一个 `Page` 实例）代表一个物理页帧。当虚拟内存需要映射到物理页时，页表项会指向特定的物理地址，即一个物理页帧。此物理地址可以映射到 `Page` 数组的一个特定项，该项包含了与此物理页帧相关的各种状态信息。因此，页表项的物理地址部分可以间接映射到一个 `Page` 实例，通过页表项的地址可以找到 `Page` 数组中对应的项。

此外，在页表管理的过程中，`Page` 结构体内的 `ref` 反映了当前页帧的引用状态。而在页替换操作中，`pra_page_link`、`flags` 等字段则为替换算法提供了必要的信息。当需要换出页帧时，这些信息会帮助找到合适的页帧，并更新相应的页表项，使之指向新的页帧。


## 练习四：补充完成Clock页替换算法(需要编程)

> 通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法(mm/swap_clock.c)。(提示:要输出curr_ptr的值才能通过make grade)

>请在实验报告中简要说明你的设计实现过程。请回答如下问题：

>- 比较Clock页替换算法和FIFO算法的不同。


### clock页替换原理

clock页替换算法需要实现在发生缺页时，将最早访问过的页面换出到磁盘上。其替换原则为：

1. 将内存中的页面通过链接指针链接为一个双向循环链表，每装入一个页面，将其插入到链表的尾部，且将其访问位设置为1。
    -  **双向循环链表：** 内存中的每个页面都被插入到一个双向循环链表中。每个页面都有一个访问位（R位），用于标记页面最近是否被访问过。
    -  **页面装入：** 当一个新的页面被装入内存时，它被添加到链表的尾部，并且其访问位被设置为1，表示它最近被访问过。


2. 当需要淘汰页面时，只需要检查页的访问位。访问位为1，将其访问位置为0，暂不换出，继续检查下一个页面；访问位为0，选择此页换出。

-  **检查访问位：** 当发生缺页异常，需要替换一个页面时，算法开始遍历链表，检查每个页面的访问位。
   
   - 如果访问位为1，表示页面最近被访问过，因此有可能是活跃的。算法将访问位置为0，并继续检查下一个页面。
   - 如果访问位为0，表示页面在最近的扫描周期内没有被访问过，因此它是一个好的候选者来被换出。算法选择这个页面进行换出操作。

3. 若第一轮扫描中所有页面访问位都是1，则将这些页面的访问位置为0后再进行第二轮扫描。第二轮扫描一定会有访问位为0的页面，因此将其换出。所以clock页面替换算法淘汰页面最多会经过两轮扫描。

- **处理所有访问位为1的情况：** 在第一轮扫描中，如果所有页面的访问位都是1，那么算法将遍历整个链表，将所有页面的访问位都设置为0。
- **第二轮扫描：** 在这一轮中，由于之前将所有页面的访问位都设置为0，因此至少会有一个页面的访问位为0（因为在这段时间内，某些页面可能没有被访问）。算法在第二轮扫描中找到第一个访问位为0的页面，并将其换出。


**为什么最多两轮扫描**：
- 第一轮扫描可能会遇到所有页面的访问位都为1的情况，这是因为所有页面在最近一段时间内都被访问过。
- 将所有访问位置为0后，由于不可能所有页面都在没有进行任何访问的情况下立即再次被访问，因此在第二轮扫描中，一定能够找到一个访问位为0的页面。

**Clock页替换算法**通过一个简单的机制来尝试平衡页面替换的效率，它利用页面的访问位来决定哪个页面最不可能在近期被再次访问，从而将其换出。由于算法最多只需要两轮扫描就能找到替换的页面，因此它的实现相对简单且高效。

### 代码实现


1.利用` _clock_init_mm`进行初始化工作

在`_clock_init_mm`函数中需要初始化内存管理结构 `mm` 的时钟置换算法所需的数据结构：

```c
static int
_clock_init_mm(struct mm_struct *mm)
{     
     /*LAB3 EXERCISE 4: 2213459*/ 
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    list_init(&pra_list_head);
    curr_ptr = &pra_list_head;
    mm->sm_priv = &pra_list_head;
    return 0;
}
```
这个函数主要实现的功能是：

- 初始化链表头 `pra_list_head`，表示待置换的页面链表；
- 将全局指针 `curr_ptr` 设置为链表头 `pra_list_head`，用于跟踪链表中的当前位置；
- 将 `mm` 结构的私有成员指针 `sm_priv` 设为链表头 `pra_list_head`，以便用于后续页面操作和管理。

2.  `_clock_map_swappable`加入最近访问的可交换页面

`_clock_map_swappable`函数将最近访问的页面链接到 `pra_list_head` 队列的末尾，并将页面的 `visited` 标志置为1，表示该页面已被访问：


```c
static int
_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);

    assert(entry != NULL && curr_ptr != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 4: 2213459*/ 
    // link the most recent arrival page at the back of the pra_list_head qeueue.
    // 将页面page插入到页面链表pra_list_head的末尾
    // 将页面的visited标志置为1，表示该页面已被访问
    list_add_before(&pra_list_head, entry);
    page->visited = 1;
    return 0;
}
```


- 获取页面的 `pra_page_link` 指针 `entry`，该指针的作用是在链表中表示该页面；

- 使用`assert`断言确保 `entry` 和全局指针 `curr_ptr` 不为空。若为空程序则会中断；
- 之后使用了链表插入函数`list_add_before(&pra_list_head, entry)`,将entry插入到链表头的前一个，即插入链表的末尾；

- 最后将`visited`标准为1，表示页面已经被访问。


3. `_clock_swap_out_victim`选择要替换的页面

这个函数是clock页替换算法的核心，实现了选择最早未被访问的页面作为牺牲品被换出，代码如下：

```c
static int
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
     assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
    while (1) {
        /*LAB3 EXERCISE 4: 2213459*/ 
        // 编写代码
        // 遍历页面链表pra_list_head，查找最早未被访问的页面
        // 获取当前页面对应的Page结构指针
        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
        if(head==list_prev(head))
        {   
            *ptr_page = NULL;
            break;
        }
        if (curr_ptr == &pra_list_head)
        {
            curr_ptr = list_next(curr_ptr);
        }
        struct Page *page = le2page(curr_ptr, pra_page_link);

        if (page->visited == 0)
        {
            cprintf("curr_ptr %p\n", curr_ptr);
            list_del(curr_ptr);

            *ptr_page = page;

            break;
        }
        else
        {
            page->visited = 0;
        }
        curr_ptr = list_next(curr_ptr); 
    }
    return 0;
}
```


主要流程为：

1. 获取内存管理结构`mm` 的私有成员指针`head`。

```c
list_entry_t *head=(list_entry_t*) mm->sm_priv;
assert(head != NULL);
assert(in_tick==0);

```

- 它指向双向循环链表的头部。
- 使用断言确保 `head` 不为空，并且 `in_tick` 的值为0，表示不处于时钟中断状态。

2. 利用while循环寻找要替换的页面，设置`curr_ptr`指针进行遍历。
   - 如果页面链表为空，将` ptr_page` 设置为 NULL，表示没有要替换的页面;
```c

   if(head==list_prev(head))
    {   
        *ptr_page = NULL;
        break;
    }

```

   - 若遍历到链表头部，则从下一个页面继续遍历链表。
```c

  struct Page *page = le2page(curr_ptr, pra_page_link);

```

   - 若页面的访问位为0，即其最近没有被访问，则将该页面从页面链表中删除，并该页面指针赋值给`ptr_page`作为换出页面。
   - 若页面的访问位为1，即其最近被访问过，则将其访问位设为0。
```c
   if (page->visited == 0)
    {
        cprintf("curr_ptr %p\n", curr_ptr);
        list_del(curr_ptr);

        *ptr_page = page;

        break;
    }
    else
    {
        page->visited = 0;
    }

```
 
   - `curr_ptr = list_next(curr_ptr)`继续遍历下一个页面。

运行效果如下：

<img src=1.png  width=50% >

###  比较Clock页替换算法和FIFO算法的不同

Clock页替换算法和FIFO（先进先出）页替换算法都是用来决定在内存满时哪个页面应该被替换出内存的。以下是它们之间的主要不同点：

#### FIFO（先进先出）算法：
1. **原理**：
   - FIFO算法是最简单的页替换算法之一。
   - 它维护一个队列，新页面进入队列的尾部，当需要替换页面时，队列头部的页面被替换出去。
2. **实现**：
   - FIFO算法使用一个队列来跟踪页面的加载顺序。
   - 当一个页面需要被加载到内存时，它被添加到队列的末尾。
   - 当需要替换页面时，队列最前面的页面（即最早进入内存的页面）被替换。
3. **缺点**：
   - FIFO算法可能会遇到“Belady's Anomaly”，即增加分配的帧数反而会增加缺页中断的次数。
   - 它不考虑页面的使用频率，可能导致频繁使用的页面被替换。
#### Clock页替换算法：
1. **原理**：
   - Clock算法是一种改进的页替换算法，它使用一个环形结构来跟踪页面的使用情况。
   - 每个页面都有一个引用位（或访问位），用来指示页面最近是否被访问过。
2. **实现**：
   - Clock算法使用一个类似钟表的指针来遍历环形结构。
   - 当页面被访问时，它的引用位被设置为1。
   - 当需要替换页面时，算法检查当前指针指向的页面引用位：
     - 如果引用位为0，则该页面被替换，指针移动到下一个页面。
     - 如果引用位为1，则将该位设置为0，指针移动到下一个页面，继续检查。
3. **优点**：
   - Clock算法不会受到Belady's Anomaly的影响。
   - 它考虑了页面的使用情况，倾向于替换那些最近未被访问的页面。
**主要不同点**：

- **引用位的使用**：
  - Clock算法使用引用位来决定页面的替换，可以更智能地选择替换页面，避免频繁替换最近访问过的页面，而FIFO不考虑页面的使用频率。
- **结构**：
  - FIFO使用一个队列，而Clock使用一个双向链表。
- **性能**：
  - FIFO可能会替换掉频繁使用的页面，而Clock算法更倾向于替换那些未被访问的页面，这通常会导致更好的性能。
- **Belady's Anomaly**：
  - FIFO可能会遇到Belady's Anomaly，而Clock算法不会。
      - FIFO算法不考虑页面的访问频率，只考虑页面的加载时间。当增加帧数时，算法可能会保留更多的“老”页面，而这些页面可能不再被访问，同时替换掉了一些即将被访问的“新”页面。这种情况会导致一个不理想的页面替换序列，使得缺页中断次数增加。

      - Clock算法使用一个引用位（或访问位）来记录页面是否在最近被访问过。在替换页面时，它选择那些未被最近访问过的页面。

      - Clock算法考虑了页面的访问历史，不仅仅是页面的加载时间。当增加帧数时，Clock算法会保留更多最近被访问过的页面，这通常会减少缺页中断的次数，因为最近被访问过的页面很可能在不久的将来再次被访问。
- **复杂性**：
  - FIFO算法实现简单，而Clock算法相对复杂，因为它需要跟踪每个页面的引用位。

## 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）

>如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？


### 好处与优势

1. **查找效率提升**：
   - 一个大页页表意味着直接将虚拟地址映射到物理地址，这样只需一次页表查找，无需多级页表的逐级查询过程。尤其对于较大内存的操作系统而言，可以减少页表的查找时间，从而提升内存访问的性能。

2. **节省内存存储开销**：
   - 在一个大页页表中，由于页表不分层，可以减少多级页表的管理结构开销。当虚拟地址空间较小，且物理内存较大时，单级页表在内存中保存的页表项总数是相对固定的，所以在小规模的嵌入式系统中会显得更加简洁。

3. **简单性**：
   - 一个大页页表管理实现简单，不需要处理复杂的分层结构，方便页表的建立和维护。同时在地址转换逻辑和数据结构上都更加直接，降低了设计与管理的复杂度。
4. **减少TLB缺失**：
   - 由于大页涵盖的物理内存范围更大，TLB中的一个条目可以映射更大的内存范围，从而可能减少TLB缺失的次数。

### 坏处与风险

1. **占用更多内存**：
   - 一个大页页表需为整个虚拟地址空间建立映射表，即使大部分地址未被实际使用，也会占用内存存储完整页表。而分级页表可以按需分配，针对未使用的虚拟地址空间无需分配页表空间，节省了内存资源。

2. **不适合大地址空间**：
   - 在32位或64位系统中， 一个大页页表的大小会随着虚拟地址空间增加而成倍增长。当地址空间非常大时， 一个大页页表所需的内存将变得不切实际或导致内存耗尽，从而无法在现代高容量的内存环境下有效管理内存。

3. **内存碎片化风险**：
   -  一个大页页表通常需要一整块连续的内存用于保存页表内容。随着页表规模的增大，找到合适的连续内存区域变得困难，易导致内存碎片化，影响系统的内存利用率。

4. **缺乏细粒度控制**：
   - 分级页表可以通过不同的层次结构实现更细粒度的内存权限管理，但一个大页页表在这方面的灵活性不足。这可能导致对安全性和权限控制要求较高的系统中无法满足需要，存在潜在的安全风险。

## challenge 设计文档：实现不考虑实现开销和效率的LRU页替换算法

### 1. 项目背景

在现代操作系统中，内存管理是一个关键的功能，尤其是在物理内存有限的情况下，如何高效地管理内存页面的交换和置换是至关重要的。本设计文档介绍了基于 **LRU（最近最少使用）** 算法的页面置换管理器的实现，该管理器用于模拟虚拟内存中页面的置换，以确保当物理内存不够时，能够高效地将不常用的页面换出到交换区。

### 2. 设计目标

该系统的目标是实现一个基于 **LRU** 算法的页面置换机制。LRU 算法通过维护一个页面访问顺序的链表来确定哪些页面是最久未使用的，从而决定哪些页面应该被交换出去。具体目标包括：
- 实现一个能够管理页面交换的机制。
- 支持页面的**访问**、**添加**、**交换**和**删除**操作。
- 维护页面访问的顺序，选择最久未使用的页面进行置换。
- 在发生页面缺页异常时，将访问的页面标记为可读，并更新链表顺序。

### 3. 主要数据结构

#### 3.1 `list_entry_t` 链表结构
为了管理页面的置换，系统使用了一个链表结构来存储页面。每个链表节点代表一个页面，包含以下信息：
- **页面链表指针**：用于在链表中存储页面。
- **`pra_page_link`**：每个页面通过该链表链接到其他页面。

#### 3.2 `mm_struct` 结构体
`mm_struct` 代表每个进程的内存管理结构，其中包含指向页面置换链表的指针：
- **`sm_priv`**：指向管理页面的链表头（`pra_list_head`），该链表保存当前进程的可交换页面。

#### 3.3 `Page` 结构体
`Page` 结构体表示内存中的一页，包含如下字段：
- **`pra_page_link`**：用于链表中存储该页面。
- **`pra_vaddr`**：该页面的虚拟地址。
  
#### 3.4 `swap_manager` 结构体
`swap_manager` 结构体包含了所有页面置换操作的函数指针，用于实现页面置换管理，为LRU算法管理器的调用接口。具体函数包括：
- **`init`**：初始化置换管理器。
- **`init_mm`**：初始化每个进程的内存管理。
- **`tick_event`**：定时器事件，用于周期性地处理页面置换。
- **`map_swappable`**：标记某个页面为可交换的。
- **`swap_out_victim`**：选择被置换出去的页面。
- **`set_unswappable`**：设置某个页面为不可交换的。
- **`check_swap`**：检查页面置换状态。
  
### 4. 主要功能

#### 4.1 初始化和页面映射

- **`_lru_init_mm`**：该函数在进程的内存管理结构 `mm_struct` 中初始化一个空的链表 `pra_list_head`，并将 `mm_struct` 的 `sm_priv` 指向该链表。
```c
static int
_lru_init_mm(struct mm_struct *mm)
{     

    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
     return 0;
}
```
  
- **`_lru_map_swappable`**：该函数将指定的页面标记为可交换的页面，并将其添加到 `pra_list_head` 链表中。页面以链表条目的形式插入，表示它是可以被交换的。
```c
static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    list_add((list_entry_t*) mm->sm_priv,entry);
    return 0;
}
```

#### 4.2 页面置换

- **`_lru_swap_out_victim`**：该函数根据 LRU 算法选取一个页面进行置换。它通过遍历链表，从链表尾部选择最久未使用的页面（即链表的最后一个元素）。如果链表为空，则返回 `NULL`。
```c
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
        assert(head != NULL);
    assert(in_tick==0);
    list_entry_t* entry = list_prev(head);
    if (entry != head) {
        list_del(entry);
        *ptr_page = le2page(entry, pra_page_link);
    } else {
        *ptr_page = NULL;
    }
    return 0;
}
```

#### 4.3 页面访问和修改

- **`lru_pgfault`**：该函数处理页面故障（缺页异常）。如果发生缺页，首先将所有页面标记为不可读，然后将访问的页面设置为可读，并将该页面移动到链表的头部，表示该页面是最近访问的。之所以这样是因为在加入页面时，会将新加入的页面或刚刚访问的页插入到链表头部，这样每次换出页面时只需要将链表尾部的页面取出即可。
```c
int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
    cprintf("lru page fault at 0x%x\n", addr);
    // 设置所有页面不可读
    if(swap_init_ok) 
        unable_page_read(mm);
    // 将需要获得的页面设置为可读
    pte_t* ptep = NULL;
    ptep = get_pte(mm->pgdir, addr, 0);
    *ptep |= PTE_R;
    if(!swap_init_ok) 
        return 0;
    struct Page* page = pte2page(*ptep);
    // 将该页放在链表头部
    list_entry_t *head=(list_entry_t*) mm->sm_priv, *le = head;
    while ((le = list_prev(le)) != head)
    {
        struct Page* curr = le2page(le, pra_page_link);
        if(page == curr) {
            
            list_del(le);
            list_add(head, le);
            break;
        }
    }
    return 0;
}
```
  
- **`unable_page_read`**：该函数遍历链表中的所有页面，将它们标记为不可读，即清除页表中的 `PTE_R` 标志位。为了知道访问了哪个页面，可以在建立页表项时将每个页面的权限全部设置为不可读，这样在访问一个页面的时候会引发缺页异常，之后将该页放到链表头部，设置页面为可读。
```c
static int
unable_page_read(struct mm_struct *mm) {
    list_entry_t *head=(list_entry_t*) mm->sm_priv, *le = head;
    while ((le = list_prev(le)) != head)
    {
        struct Page* page = le2page(le, pra_page_link);
        pte_t* ptep = NULL;
        ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
        *ptep &= ~PTE_R;
    }
    return 0;
}
```

#### 4.4 调试功能

- **`print_mm_list`**：该函数用于打印链表 `pra_list_head` 中存储的页面信息，帮助开发人员调试和验证页面访问顺序。

- **`_lru_check_swap`**：该函数模拟多个页面的访问并打印每次访问后的链表状态，用于检查页面置换的正确性。通过写入特定的虚拟地址来模拟页面访问，并观察哪些页面被置换。测试样例如下：
```c
static int
_lru_check_swap(void) {
    print_mm_list();
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    print_mm_list();
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    print_mm_list();
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    print_mm_list();
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    print_mm_list();
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    print_mm_list();
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    print_mm_list();
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    print_mm_list();
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    print_mm_list();
    cprintf("write Virt Page d in lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    print_mm_list();
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    print_mm_list();
    cprintf("write Virt Page a in lru_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    print_mm_list();
    return 0;
}
```

在vmm.c的do_pgfault中添加如下代码：
```c
pte_t* temp = NULL;
temp = get_pte(mm->pgdir, addr, 0);
if(temp != NULL && (*temp & (PTE_V | PTE_R))) {
    return lru_pgfault(mm, error_code, addr);
}

uint32_t perm = PTE_U;
if (vma->vm_flags & VM_WRITE) {
    perm |= (PTE_R | PTE_W);
}

// 在为perm设置完权限之后，移除读权限
perm &= ~PTE_R;
```

### 5. 算法描述

#### LRU 算法的核心思想：
LRU 算法的核心思想是：每次访问一个页面时，将该页面移动到链表的头部；当物理内存不足时，选择链表尾部的页面进行置换（即最久未使用的页面）。因此，链表的操作（插入、删除和移动）至关重要。

- **链表的维护**：每个页面访问时，通过 **`lru_pgfault`** 函数将该页面移动到链表的头部，从而保证链表的顺序反映了页面的访问顺序。
- **页面置换**：当需要置换页面时，选择链表尾部的页面，表示该页面是最久未使用的。

### 6. 模块接口

该系统提供了一个 **`swap_manager`** 结构体 `swap_manager_lru`，将各个置换函数接口组合在一起，供操作系统调用：
```c
struct swap_manager swap_manager_lru =
{
    .name            = "lru swap manager",
    .init            = &_lru_init,
    .init_mm         = &_lru_init_mm,
    .tick_event      = &_lru_tick_event,
    .map_swappable   = &_lru_map_swappable,
    .set_unswappable = &_lru_set_unswappable,
    .swap_out_victim = &_lru_swap_out_victim,
    .check_swap      = &_lru_check_swap,
}
```

### 7. 代码关键思想总结

1. **如何知道谁是最近最少被使用的？**：将新加入的页面或刚刚访问的页插入到链表头部，这样每次换出页面时只需要将链表尾部的页面取出即可。
2. **如何知道访问了哪个页面？**：可以在建立页表项时将每个页面的权限全部设置为不可读，这样在访问一个页面的时候会引发缺页异常，之后将该页放到链表头部，设置页面为可读。

### 8. 扩展和优化

- **性能优化**：对于较大的内存系统，LRU 算法的链表操作可能会带来一定的性能负担。可以考虑使用双向链表来优化页面的插入和删除操作。
- **多进程支持**：当前的实现是针对单一进程的内存管理，如果需要支持多进程，可能需要对每个进程的页面置换进行独立管理。

### 9. 总结

本设计文档详细描述了一个基于 LRU 算法的页面置换管理器的实现，涵盖了数据结构设计、功能实现、算法描述等方面。该管理器通过链表维护页面访问顺序，实现了最久未使用页面的置换操作。

### 附录：运行结果
```
set up init env for check_swap over!
--------begin----------
vaddr: 0x4000
vaddr: 0x3000
vaddr: 0x2000
vaddr: 0x1000
---------end-----------
write Virt Page c in lru_check_swap
Store/AMO page fault
page fault at 0x00003000: K/W
lru page fault at 0x3000
--------begin----------
vaddr: 0x3000
vaddr: 0x4000
vaddr: 0x2000
vaddr: 0x1000
---------end-----------
write Virt Page a in lru_check_swap
Store/AMO page fault
page fault at 0x00001000: K/W
lru page fault at 0x1000
--------begin----------
vaddr: 0x1000
vaddr: 0x3000
vaddr: 0x4000
vaddr: 0x2000
---------end-----------
write Virt Page b in lru_check_swap
Store/AMO page fault
page fault at 0x00002000: K/W
lru page fault at 0x2000
--------begin----------
vaddr: 0x2000
vaddr: 0x1000
vaddr: 0x3000
vaddr: 0x4000
---------end-----------
write Virt Page e in lru_check_swap
Store/AMO page fault
page fault at 0x00005000: K/W
swap_out: i 0, store page in vaddr 0x4000 to disk swap entry 5
Store/AMO page fault
page fault at 0x00005000: K/W
lru page fault at 0x5000
--------begin----------
vaddr: 0x5000
vaddr: 0x2000
vaddr: 0x1000
vaddr: 0x3000
---------end-----------
write Virt Page b in lru_check_swap
Store/AMO page fault
page fault at 0x00002000: K/W
lru page fault at 0x2000
--------begin----------
vaddr: 0x2000
vaddr: 0x5000
vaddr: 0x1000
vaddr: 0x3000
---------end-----------
write Virt Page a in lru_check_swap
Store/AMO page fault
page fault at 0x00001000: K/W
lru page fault at 0x1000
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x5000
vaddr: 0x3000
---------end-----------
write Virt Page b in lru_check_swap
--------begin----------
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x5000
vaddr: 0x3000
---------end-----------
write Virt Page c in lru_check_swap
Store/AMO page fault
page fault at 0x00003000: K/W
lru page fault at 0x3000
--------begin----------
vaddr: 0x3000
vaddr: 0x1000
vaddr: 0x2000
vaddr: 0x5000
---------end-----------
write Virt Page d in lru_check_swap
Store/AMO page fault
page fault at 0x00004000: K/W
swap_out: i 0, store page in vaddr 0x5000 to disk swap entry 6
swap_in: load disk swap entry 5 with swap_page in vadr 0x4000
Store/AMO page fault
page fault at 0x00004000: K/W
lru page fault at 0x4000
--------begin----------
vaddr: 0x4000
vaddr: 0x3000
vaddr: 0x1000
vaddr: 0x2000
---------end-----------
write Virt Page e in lru_check_swap
Store/AMO page fault
page fault at 0x00005000: K/W
swap_out: i 0, store page in vaddr 0x2000 to disk swap entry 3
swap_in: load disk swap entry 6 with swap_page in vadr 0x5000
Store/AMO page fault
page fault at 0x00005000: K/W
lru page fault at 0x5000
--------begin----------
vaddr: 0x5000
vaddr: 0x4000
vaddr: 0x3000
vaddr: 0x1000
---------end-----------
write Virt Page a in lru_check_swap
Load page fault
page fault at 0x00001000: K/R
lru page fault at 0x1000
--------begin----------
vaddr: 0x1000
vaddr: 0x5000
vaddr: 0x4000
vaddr: 0x3000
---------end-----------
```

