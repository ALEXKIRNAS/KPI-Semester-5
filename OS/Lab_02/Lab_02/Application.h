#pragma once
#include <random>
#include <cstdlib>

#define page_size_hack 128

class Application {
private:

	const double _local_read_probability;
	const double _read_probability;
	size_t application_id;
	size_t work_memory_size; // in bytes
	size_t last_readed_block;

public:

	Application(size_t application_id,
				size_t work_memory_size,
				double local_read_probability,
				double read_probability) : _local_read_probability(local_read_probability),
										   _read_probability(read_probability) {
		this->application_id = application_id;
		this->work_memory_size = work_memory_size;
		last_readed_block = 0;
	}

	size_t emulate_work() {
		double random_number = rand() * 1. / RAND_MAX;
		
		if (last_readed_block == 0 || random_number > _local_read_probability) {
			last_readed_block = size_t(work_memory_size * random_number / page_size_hack);
		} else {
			if (last_readed_block > 1 && last_readed_block < (work_memory_size / page_size_hack - 1)) {
				random_number -= 0.5;
			} else {
				random_number = 0;
			}

			if (random_number < -0.17) {
				last_readed_block -= 1;
			} else if (random_number > 0.17) {
				last_readed_block += 1;
			}
		}

		return last_readed_block;
	}
};
