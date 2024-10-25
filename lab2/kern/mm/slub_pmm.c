#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <assert.h>
#include <slub_pmm.h>
#include <pmm.h>
#include <stdio.h>

// 定义slob块结构体，用于管理小块内存
struct slob_block {
	int units; // 块大小（以SLOB_UNIT为单位）
	struct slob_block *next; // 指向下一个slob块
};
typedef struct slob_block slob_t;

#define SLOB_UNIT sizeof(slob_t) // 定义基本单位大小
#define SLOB_UNITS(size) (((size) + SLOB_UNIT - 1)/SLOB_UNIT) // 将大小转换为slob单位

// 大块结构体，用于分配较大页
struct bigblock {
	int order; // 大块的页数量（2^order）
	void *pages; // 指向实际分配的页
	struct bigblock *next; // 链表中的下一个大块
};
typedef struct bigblock bigblock_t;

// 定义slob的空闲链表
static slob_t arena = { .next = &arena, .units = 1 };// 初始的空闲slob块
static slob_t *slobfree = &arena;// 空闲slob块链表，设计为单向循环链表
static bigblock_t *bigblocks; // 存储所有分配的大块页,设计为单向链表

// 初始化 SLUB 分配器
void slub_init(void) {
    cprintf("slub_init() succeeded!\n");
}

// slob释放函数声明
static void slob_free(void *b, int size);

// slob分配函数，用于分配小于1页的块
static void *slob_alloc(size_t size)
{
    assert(size < PGSIZE); // 确保请求的大小小于一页

	slob_t *prev, *cur;
	int units = SLOB_UNITS(size); // 计算请求的单位数

	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
		if (cur->units >= units) { // 找到满足请求大小的空闲块

			if (cur->units == units) // 如果块的大小正好等于请求的大小
				prev->next = cur->next;
			else { // 如果块大于请求大小，分割块
				prev->next = cur + units;
				prev->next->units = cur->units - units;
				prev->next->next = cur->next;
				cur->units = units;
			}
			slobfree = prev; // 更新slobfree指针
			return cur;
		}
		if (cur == slobfree) { // 遍历完成一圈没有找到合适的块
			if (size == PGSIZE) // 如果请求大小等于一页，则无法分配
				return 0;
			cur = (slob_t *)alloc_pages(1); // 分配一页新的内存块
			if (!cur) // 分配失败
				return 0;
			slob_free(cur, PGSIZE);
			cur = slobfree;
		}
	}
}

// slob_free 函数，将块释放回空闲链表
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	if (!block)
		return;
	if (size)
		b->units = SLOB_UNITS(size); // 计算块的单位数

	// 在空闲链表中找到合适的位置插入
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	// 尝试与后续块合并
	if (b + b->units == cur->next) {
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	// 尝试与前一个块合并
	if (cur + cur->units == b) {
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;

	slobfree = cur; // 更新空闲链表头部
}

// slub_alloc，面向用户的内存分配接口
void *slub_alloc(size_t size)
{
	slob_t *m;
	bigblock_t *bb;

	// 小块分配
	if (size < PGSIZE - SLOB_UNIT) {
		m = slob_alloc(size + SLOB_UNIT); // 分配大小加上块头
		return m ? (void *)(m + 1) : 0; // 成功分配则返回块地址
	}

	// 分配大块
	bb = slob_alloc(sizeof(bigblock_t));
	if (!bb)
		return 0;

	bb->order = ((size-1) >> PGSHIFT) + 1; // 计算order
	bb->pages = (void *)alloc_pages(bb->order); // 分配大块页

	if (bb->pages) {
		bb->next = bigblocks; // 插入链表
		bigblocks = bb;
		return bb->pages;
	}

	slob_free(bb, sizeof(bigblock_t)); // 如果分配失败，释放块
	return 0;
}

// 释放分配的内存块
void slub_free(void *block)
{
	bigblock_t *bb, **last = &bigblocks;

	if (!block)
		return;

	// 检查是否为大块
	if (!((unsigned long)block & (PGSIZE-1))) {
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
			if (bb->pages == block) { // 如果找到对应大块
				*last = bb->next;
				free_pages((struct Page *)block, bb->order); // 释放大块页
				slob_free(bb, sizeof(bigblock_t)); // 释放块头
				return;
			}
		}
	}

	// 如果不是大块，则直接释放小块
	slob_free((slob_t *)block - 1, 0);
	return;
}

// 计算给定块的大小
unsigned int slub_size(const void *block)
{
	bigblock_t *bb;

	if (!block)
		return 0;

	// 检查是否为大块
	if (!((unsigned long)block & (PGSIZE-1))) {
		for (bb = bigblocks; bb; bb = bb->next)
			if (bb->pages == block) {
				return bb->order << PGSHIFT; // 返回页大小
			}
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT; // 否则返回小块大小
}

// 计算空闲slob块的数量
int slobfree_len()
{
    int len = 0;
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
        len++;
    return len;
}

// 测试slub分配器行为的函数
void slub_check()
{
    cprintf("slub check begin\n");
    cprintf("slobfree len: %d\n", slobfree_len());
    void* p1 = slub_alloc(4096);
    cprintf("slobfree len: %d\n", slobfree_len());
    void* p2 = slub_alloc(2);
    void* p3 = slub_alloc(2);
    cprintf("slobfree len: %d\n", slobfree_len());
    slub_free(p2);
    cprintf("slobfree len: %d\n", slobfree_len());
    slub_free(p3);
    cprintf("slobfree len: %d\n", slobfree_len());
    cprintf("slub check end\n");
}
