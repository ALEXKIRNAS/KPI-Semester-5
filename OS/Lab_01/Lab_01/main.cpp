#include "MemoryAllocator.h"

#define SYSTEM_POLL_SIZE_BYTES 1048576 // 2^20 = 1 Mb
#define DEBUG

MemoryAllocator GLOBAL_MEMORY_ALLOCATOR = MemoryAllocator(SYSTEM_POLL_SIZE_BYTES);

void* mem_alloc(size_t size) {
	return GLOBAL_MEMORY_ALLOCATOR.allocate(size);
}

void *mem_realloc(void *addr, size_t size) {
	return GLOBAL_MEMORY_ALLOCATOR.reallocate(addr, size);
}

void mem_free(void *addr) {
	return GLOBAL_MEMORY_ALLOCATOR.deallocate(addr);
}


