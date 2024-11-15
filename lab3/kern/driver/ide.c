#include <assert.h>
#include <defs.h>
#include <fs.h>
#include <ide.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}

// 定义最大 IDE 设备的数量为 2
#define MAX_IDE 2
// 定义磁盘的扇区数为 56
#define MAX_DISK_NSECS 56
// 定义内存数组作为模拟磁盘，SECTSIZE是每个扇区的大小，在fs.h里定义为512字节
static char ide[MAX_DISK_NSECS * SECTSIZE];

// 检查磁盘设备是否合法，看编号
bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }

// 获取磁盘设备大小（扇区数），ideno 是设备编号，但在这个函数中未使用，因为这里只模拟了一个磁盘。
size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }

// 从模拟磁盘中读取数据到指定的内存区域
// ideno：设备编号，这里没有实际使用，因为只有一个模拟磁盘。
// secno：要读取的第一个扇区编号。
// dst：目标内存地址，读取的数据将存储到这个地址。
// nsecs：要读取的扇区数量。
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    // 计算读取偏移
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}

// 将数据写入到模拟磁盘的指定扇区中
int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE; // 偏移
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
    return 0;
}
