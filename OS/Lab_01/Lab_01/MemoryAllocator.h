#pragma once
#include <map>
#include <vector>
#include <cstdio>
#include <algorithm>
#include "MemoryHeader.h"

using std::map;
using std::vector;

class MemoryAllocator {
private:
	size_t _allocated_memory;
	char* _memory_pool;
	map <void*, size_t> _sizes_map;
	map <size_t, vector<char *>> _free_map;

	void _merge(MemoryHeader* first, MemoryHeader* second);

public:
	MemoryAllocator(size_t size);
	void* allocate(size_t size);
	void deallocate(void* pointer);
	void* reallocate(void* pointer, size_t size);
	void mem_dump(void);
};
