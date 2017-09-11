#include "MemoryAllocator.h"

MemoryAllocator::MemoryAllocator(size_t size) {
	if (size < sizeof(MemoryHeader)) {
		throw std::bad_alloc();
	}

	_memory_pool = new char[size];
	_allocated_memory = 0;
	_free_map[size].push_back((char *)_memory_pool);
	_sizes_map[_memory_pool] = size;
	MemoryHeader* loc_header = new (_memory_pool) MemoryHeader();
	loc_header->header.NextBlock = nullptr;
	loc_header->header.PrevBlock = nullptr;
	loc_header->header.isFree = true;

#ifdef DEBUG
	printf("Created pool for %d bytes", size);
#endif // DEBUG
}


void* MemoryAllocator::allocate(size_t size) {
	size = (size / sizeof(ALIGIN_TYPE) + (size % sizeof(ALIGIN_TYPE) ? 1 : 0)) * sizeof(ALIGIN_TYPE);
	size += sizeof(MemoryHeader);

	auto iter = _free_map.lower_bound(size);

	if (iter == _free_map.end()) {
		return (void *) nullptr;
	}

	char* location = (iter->second).back();
	(iter->second).pop_back();

	MemoryHeader* prev = ((MemoryHeader*)(location))->header.PrevBlock;
	MemoryHeader* next = ((MemoryHeader*)(location))->header.NextBlock;

	if ((iter->second).size == 0) {
		_free_map.erase(iter);
	}

	auto size_iter = _sizes_map.find(location);
	size_t loc_size = size_iter->second;
	_sizes_map.erase(size_iter);

	size_t left_mem_size = loc_size - size;
	MemoryHeader* loc_header = new (location) MemoryHeader();

	loc_header->header.PrevBlock = prev;
	loc_header->header.NextBlock = next;
	loc_header->header.isFree = false;

	if (left_mem_size >= sizeof(MemoryHeader) + sizeof(ALIGIN_TYPE)) {
		char* next_block = location + size;
		MemoryHeader* next_header = new (next_block) MemoryHeader();
		next_header->header.PrevBlock = ((MemoryHeader*)(location));
		next_header->header.NextBlock = ((MemoryHeader*)(next));
		next_header->header.isFree = true;
		loc_header->header.NextBlock = next_header;
		_sizes_map[next_block] = left_mem_size;
	}
	else {
		size += left_mem_size;
	}

	_sizes_map[location] = size;
	_allocated_memory += size;

	return (void *)(location + sizeof(MemoryHeader));
}


void MemoryAllocator::_merge(MemoryHeader* first, MemoryHeader* second) {

	auto iter_size = _sizes_map.find(second);
	for (auto iter_free = _free_map[iter_size->second].begin();
		iter_free < _free_map[iter_size->second].end();
		iter_free++) {

		if ((char *)second == *iter_free) {
			_free_map[iter_size->second].erase(iter_free);
			break;
		}
	}

	if (_free_map[iter_size->second].size == 0) {
		_free_map.erase(iter_size->second);
	}

	_sizes_map.erase(iter_size);

	first->header.NextBlock = second->header.NextBlock;
	delete second;

	return;
}


void MemoryAllocator::deallocate(void* pointer) {
	char* loc_pointer = (char *)pointer;
	loc_pointer -= sizeof(MemoryHeader);

	if (_sizes_map.find(loc_pointer) == _sizes_map.end()) {
		return;
	}

	auto iter = _sizes_map.find(loc_pointer);
	_allocated_memory -= iter->second;
	_sizes_map.erase(iter);

	MemoryHeader* loc_header = (MemoryHeader*)loc_pointer;
	if (loc_header->header.NextBlock && loc_header->header.NextBlock->header.isFree) {
		auto next_iter = _sizes_map.find((char *)loc_header->header.NextBlock);
		_merge(loc_header, loc_header->header.NextBlock);
	}

	if (loc_header->header.PrevBlock && loc_header->header.PrevBlock->header.isFree) {
		auto next_iter = _sizes_map.find((char *)loc_header->header.NextBlock);
		_merge(loc_header->header.PrevBlock, loc_header);
	}
}


void* MemoryAllocator::reallocate(void* pointer, size_t size) {
	void* new_memory = allocate(size);
	memcpy(new_memory, pointer, size);
	deallocate(pointer);
}
