#pragma once

struct PageDescriptor {
	bool loaded; // page loaded to memory or in swap
	size_t address; // page addresss in physical or virtual memory
	size_t last_use_session_id; 
};
