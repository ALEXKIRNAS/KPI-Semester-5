#pragma once
#include <vector>
#include <map>
#include <vector>
#include "PageDescriptor.h"

using std::vector;
using std::map;

class MemoryManager {
private:
	const static int _time_to_live_of_operation = 3;
	const size_t _physical_pages_count;
	const size_t _pages_sizes;

	size_t used_physical_pages;
	size_t used_virtual_pages;
	size_t next_application_unique_id;
	size_t session_id;
	size_t clock_arrow_index; // reliaze "clock method"

	vector<PageDescriptor*> pages_queue;
	map <size_t, vector<PageDescriptor>> applications_virtual_pages_table;

	void load_page_from_swap(PageDescriptor swap_page);
	bool check_page(size_t application_id, size_t page_index);
	void find_page_to_replace();

public:

	MemoryManager(size_t physical_pages_count, size_t pages_size);
	size_t start_application(size_t memory_size);
	void get_by_virtual_address(size_t application_id, size_t virtual_page_index);
};
