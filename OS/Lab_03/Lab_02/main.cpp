#include "Application.h"
#include "MemoryManager.h"
#include <cstdio>
#include <time.h>

const int N_PAGES = 32;
const int N_APPLICATIONS = 16;
const double LOCAL_READ_PROBABILITY = 0.9;
const double READ_PROBABILITY = 0.5;
char buf[80];

int main(void) {
	srand(time(0));

	MemoryManager mem_manager = MemoryManager(N_PAGES, page_size_hack);
	Application* applications[N_APPLICATIONS];

	for (int i = 0; i < N_APPLICATIONS; i++) {
		size_t mem_work_size = (rand() % 10 + 1) * page_size_hack;
		size_t id = mem_manager.start_application(mem_work_size);
		applications[i] = new Application(id, mem_work_size, 
										  LOCAL_READ_PROBABILITY,
										  READ_PROBABILITY);
	}

	while (true) {
		size_t app_id = rand() % N_APPLICATIONS;
		size_t page_id = applications[app_id]->emulate_work();
		mem_manager.get_by_virtual_address(app_id, page_id);
		printf("Continue (y/n)\n");
		scanf("%s", buf);
		if (buf[0] == 'n') {
			break;
		}
	}
}
