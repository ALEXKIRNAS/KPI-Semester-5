#include "MemoryAllocator.h"
#define DEBUG

#ifdef DEBUG
#include <iostream>
using std::cout;
#endif // DEBUG


MemoryAllocator::MemoryAllocator(size_t size) {
	if (size < sizeof(MemoryHeader)) {
		throw std::bad_alloc();
	}

	_memory_pool = new char[size];
	_allocated_memory = 0;
	_free_map[size].push_back((char *)_memory_pool);
	_sizes_map[_memory_pool] = size;
	MemoryHeader* loc_header = new (_memory_pool) MemoryHeader();
	loc_header->sheader.NextBlock = nullptr;
	loc_header->sheader.PrevBlock = nullptr;
	loc_header->sheader.isFree = true;

#ifdef DEBUG
	printf("Created pool for %d bytes\n", size);
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

	MemoryHeader* prev = ((MemoryHeader*)(location))->sheader.PrevBlock;
	MemoryHeader* next = ((MemoryHeader*)(location))->sheader.NextBlock;

	if ((iter->second).size() == 0) {
		_free_map.erase(iter);
	}

	auto size_iter = _sizes_map.find(location);
	size_t loc_size = size_iter->second;
	_sizes_map.erase(size_iter);

	size_t left_mem_size = loc_size - size;
	MemoryHeader* loc_header = new (location) MemoryHeader();

	loc_header->sheader.PrevBlock = prev;
	loc_header->sheader.NextBlock = next;
	loc_header->sheader.isFree = false;

	if (left_mem_size >= sizeof(MemoryHeader) + sizeof(ALIGIN_TYPE)) {
		char* next_block = location + size;
		MemoryHeader* next_header = new (next_block) MemoryHeader();
		next_header->sheader.PrevBlock = ((MemoryHeader*)(location));
		next_header->sheader.NextBlock = ((MemoryHeader*)(next));
		next_header->sheader.isFree = true;
		loc_header->sheader.NextBlock = next_header;
		_sizes_map[next_block] = left_mem_size;
		_free_map[left_mem_size].push_back(next_block);
	}
	else {
		size += left_mem_size;
	}

	_sizes_map[location] = size;
	_allocated_memory += size;

#ifdef DEBUG
	printf("Allocated %d in %p\n", size, location);
	std::cout << "Sizes map:\n";
	for (auto const &iter : _sizes_map) {
		printf("%p - %d\n", iter.first, iter.second);
	}

	std::cout << "Free map:\n";

	for (auto const &iter : _free_map) {
		cout << iter.first << " :";
		for (auto const &v_iter : iter.second) {
			printf(" %p", v_iter);
		}
		printf("\n");
	}
	system("pause");
#endif // !DEBUG

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

	if (_free_map[iter_size->second].size() == 0) {
		_free_map.erase(iter_size->second);
	}

	size_t second_size = iter_size->second;
	_sizes_map.erase(iter_size);

	iter_size = _sizes_map.find(first);
	for (auto iter_free = _free_map[iter_size->second].begin();
		iter_free < _free_map[iter_size->second].end();
		iter_free++) {

		if ((char *)first == *iter_free) {
			_free_map[iter_size->second].erase(iter_free);
			break;
		}
	}

	if (_free_map[iter_size->second].size() == 0) {
		_free_map.erase(iter_size->second);
	}

	_sizes_map[first] += second_size;
	_free_map[_sizes_map[first]].push_back((char *)first);

	first->sheader.NextBlock = second->sheader.NextBlock;
	if (first->sheader.NextBlock) {
		first->sheader.NextBlock->sheader.PrevBlock = first;
	}

	return;
}


void MemoryAllocator::deallocate(void* pointer) {
	char* loc_pointer = (char *)pointer;
	size_t loc_size;
	loc_pointer -= sizeof(MemoryHeader);

	if (_sizes_map.find(loc_pointer) == _sizes_map.end()) {
		return;
	}

	auto iter = _sizes_map.find(loc_pointer);
	loc_size = iter->second;
	if (((MemoryHeader *)(iter->first))->sheader.isFree) {
		return;
	}

	MemoryHeader* loc_header = (MemoryHeader*)loc_pointer;
	loc_header->sheader.isFree = true;
	_free_map[iter->second].push_back((char *)iter->first);

	if (loc_header->sheader.NextBlock && loc_header->sheader.NextBlock->sheader.isFree) {
		_merge(loc_header, loc_header->sheader.NextBlock);
	}

	if (loc_header->sheader.PrevBlock && loc_header->sheader.PrevBlock->sheader.isFree) {
		_merge(loc_header->sheader.PrevBlock, loc_header);
	}

#ifdef DEBUG
	printf("Deallocated %d in %p\n", loc_size, loc_pointer);
	std::cout << "Sizes map:\n";
	for (auto const &iter : _sizes_map) {
		printf("%p - %d\n", iter.first, iter.second);
	}

	std::cout << "Free map:\n";

	for (auto const &iter : _free_map) {
		cout << iter.first << " :";
		for (auto const &v_iter : iter.second) {
			printf(" %p", v_iter);
		}
		printf("\n");
	}
	system("pause");
#endif // !DEBUG
}


void* MemoryAllocator::reallocate(void* pointer, size_t size) {

	char* loc_pointer = (char *)pointer - sizeof(MemoryHeader);
	if (_sizes_map.find(loc_pointer) == _sizes_map.end()) {
		return nullptr;
	}

	void* new_memory = allocate(size);
	memcpy(new_memory, pointer, std::min(size, _sizes_map[loc_pointer]));
	deallocate(pointer);
}

void MemoryAllocator::mem_dump(void) {
	printf("Memory dump\nGlobal pool %p\n", _memory_pool);
	for (auto const &iter : _sizes_map) {
		printf("Location: %p - Size: %09d bytes - IsFree: %1d\n", iter.first, iter.second, ((MemoryHeader*)iter.first)->sheader.isFree);
	}
}
