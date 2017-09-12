#include "MemoryAllocator.h"

#define SYSTEM_POLL_SIZE_BYTES 1048576 // 2^20 = 1 Mb

MemoryAllocator GLOBAL_MEMORY_ALLOCATOR = MemoryAllocator(SYSTEM_POLL_SIZE_BYTES);

//-------------------------------------------------
// Labwork functionality

void* mem_alloc(size_t size) {
	return GLOBAL_MEMORY_ALLOCATOR.allocate(size);
}

void *mem_realloc(void *addr, size_t size) {
	return GLOBAL_MEMORY_ALLOCATOR.reallocate(addr, size);
}

void mem_free(void *addr) {
	return GLOBAL_MEMORY_ALLOCATOR.deallocate(addr);
}

//---------------------------------------------------
// Tests coverage
// Warning: for more debug information enable DEBUG flag in MemoryAllocator.cpp

bool test_alloc() {
	void* pool = nullptr;
	pool = mem_alloc(SYSTEM_POLL_SIZE_BYTES + 1);

	if (pool != nullptr) {
		return false;
	}

	pool = mem_alloc(sizeof(ALIGIN_TYPE));
	ALIGIN_TYPE* value = new (pool) (ALIGIN_TYPE)(1);

	if (*value != (ALIGIN_TYPE)(1)) {
		return false;
	}

	pool = mem_alloc(sizeof(short) * 100);
	short* arr = new (pool) short[100];

	for (int i = 0; i < 100; i++) {
		arr[i] = (short) i;
	}

	return true;
}


bool test_dealloc() {

	void * pool = nullptr;
	mem_free(pool);

	pool = mem_alloc(sizeof(short) * 100);
	short* arr = new (pool) short[100];

	for (int i = 0; i < 100; i++) {
		arr[i] = (short)i;
	}
	
	mem_free(pool);

	return true;
}


bool test_performance() {

	void* arr[10];
	for (int i = 0; i < 10; i++) {
		if (i % 2) {
			arr[i] = mem_alloc(sizeof(short) * 10);
		} else {
			arr[i] = mem_alloc(sizeof(short) * 20);
		}
	}

	for (int i = 0; i < 10; i++) {
		if (i % 2) {
			mem_free(arr[i]);
		}
	}

	mem_free(arr[0]);

	void* pool = mem_alloc(sizeof(short) * 10);
	mem_free(pool);
	pool = mem_alloc(sizeof(short) * 20);
	mem_free(pool);

	for (int i = 0; i < 10; i++) {
		mem_free(arr[i]);
	}

	return true;
}

//---------------------------------------------------

int main(void) {
	printf("Start testing....\n");
	printf("Allocation test.... %s\n", (test_alloc() ? "Ok" : "Failed"));
	printf("Deallocation test.... %s\n", (test_dealloc() ? "Ok" : "Failed"));
	printf("Complex performance test.... %s\n", (test_performance() ? "Ok" : "Failed"));
	printf("Dumping info...\n");
	GLOBAL_MEMORY_ALLOCATOR.mem_dump();
	printf("Ending programm....");
	system("pause");
}
