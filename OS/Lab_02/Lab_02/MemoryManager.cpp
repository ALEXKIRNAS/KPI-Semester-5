#include "MemoryManager.h"
#include "Logger.h"
#include <algorithm>
#include <sstream>
#include <iomanip>

using std::swap;
using std::stringstream;

/*  Create Memory manager 
 *  Args:
 *     - physical_pages_count: count of physical memory
 *	   - pages_size: size of each page
 */
MemoryManager::MemoryManager(size_t physical_pages_count, size_t pages_size) : _physical_pages_count(physical_pages_count),
																			   _pages_sizes(pages_size)
{	
	next_application_unique_id = 0;
	session_id = 0;
	clock_arrow_index = 0;
	clock_arrow_index = 0;
	used_physical_pages = 0;
	used_virtual_pages = 0;

	pages_queue = vector<PageDescriptor*>(physical_pages_count);
}


/*  Swap pages in swap and in physical memory
 *  Args:
 *		- swap_page: page that going to be loaded
 */
void MemoryManager::load_page_from_swap(PageDescriptor swap_page) {
	find_page_to_replace();

	stringstream  message;
	message << std::dec << "Page in 0x" << std::hex << pages_queue[clock_arrow_index]->address <<
		 "(index - " << pages_queue[clock_arrow_index]->address / _pages_sizes << ") upload  from memory to swap";
	LoggerSingelton.info(message.str().c_str());
	stringstream  message1;
	message1 << std::dec << "Page in 0x" << std::hex << swap_page.address << 
		"(index - " << pages_queue[clock_arrow_index]->address / _pages_sizes << ") load from swap to memory";
	LoggerSingelton.info(message1.str().c_str());

	swap(pages_queue[clock_arrow_index]->address, swap_page.address);
	pages_queue[clock_arrow_index]->loaded = false;
	swap_page.loaded = true;
	pages_queue[clock_arrow_index] = &swap_page;
	clock_arrow_index = (clock_arrow_index + 1) % (_physical_pages_count);
}

/*  Check is page loaded to memory
 *	Args:
 *		- application_id: application id
 *		- page_index: index of page for application
 */
bool MemoryManager::check_page(size_t application_id, size_t page_index) {
	return applications_virtual_pages_table[application_id][page_index].loaded;
}


/*  Find index of page to replace
 */
void MemoryManager::find_page_to_replace() {
	for (; clock_arrow_index < _physical_pages_count; clock_arrow_index++) {
		if (pages_queue[clock_arrow_index]->last_use_session_id < _time_to_live_of_operation) {
			return;
		}
	}

	for (clock_arrow_index = 0; clock_arrow_index < _physical_pages_count; clock_arrow_index++) {
		if (pages_queue[clock_arrow_index]->last_use_session_id < _time_to_live_of_operation) {
			return;
		}
	}
}

/*	Add one application for managing 
 *	Args:
 *		- memory_size : size of memory (in bytes) that needed for application
 */
size_t MemoryManager::start_application(size_t memory_size) {
	int new_pages_count = memory_size / _pages_sizes;
	if (memory_size % _pages_sizes) {
		new_pages_count += 1;
	}

	stringstream  message;
	message << std::dec << "Start application (id: " << next_application_unique_id << ") with new " <<
		new_pages_count << " pages";
	LoggerSingelton.info(message.str().c_str());

	applications_virtual_pages_table[next_application_unique_id] = vector <PageDescriptor>(new_pages_count);
	while (new_pages_count) {
		new_pages_count--;
		if (used_physical_pages < _physical_pages_count) {
			applications_virtual_pages_table[next_application_unique_id][new_pages_count].address = (used_physical_pages * _pages_sizes);
			applications_virtual_pages_table[next_application_unique_id][new_pages_count].loaded = true;
			pages_queue[used_physical_pages] = &applications_virtual_pages_table[next_application_unique_id][new_pages_count];
			used_physical_pages++;
		} else {
			applications_virtual_pages_table[next_application_unique_id][new_pages_count].address = (used_virtual_pages * _pages_sizes);
			applications_virtual_pages_table[next_application_unique_id][new_pages_count].loaded = false;
			used_virtual_pages++;
		}
		applications_virtual_pages_table[next_application_unique_id][new_pages_count].last_use_session_id = session_id;
	}
	
	session_id++;
	return next_application_unique_id++;
}

/*	Read specific page
 *	Args:
 *		- application_id : application id that send requests 
 *		- virtual_page_index : index of virual page that must be readed
 */
void MemoryManager::get_by_virtual_address(size_t application_id, size_t virtual_page_index) {
	stringstream  message;
	message << std::dec << "Application (id: " << application_id << ") requested page 0x" <<
		std::hex << (virtual_page_index * _pages_sizes) << "(index - " << virtual_page_index << ")";
	LoggerSingelton.info(message.str().c_str());

	stringstream  message1;
	if (check_page(application_id, virtual_page_index)) {
		message1 << std::dec << "Application`s (id: " << application_id << ") page 0x" <<
			std::hex << (virtual_page_index * _pages_sizes) << "(index - " << virtual_page_index << ") already in memory!";
		LoggerSingelton.info(message1.str().c_str());
	} else {
		message1 << std::dec << "Application`s (id: " << application_id << ") page 0x" <<
			std::hex << (virtual_page_index * _pages_sizes) << "(index - " << virtual_page_index << ") not in memory!";
		LoggerSingelton.info(message1.str().c_str());
		load_page_from_swap(applications_virtual_pages_table[application_id][virtual_page_index]);
	}

	applications_virtual_pages_table[application_id][virtual_page_index].last_use_session_id = session_id;
	session_id++;
}
