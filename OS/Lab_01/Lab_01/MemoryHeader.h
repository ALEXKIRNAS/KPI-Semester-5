#pragma once
#define ALIGIN_TYPE long int // 4 bytes

union MemoryHeader {
	struct {
		MemoryHeader* NextBlock;
		MemoryHeader* PrevBlock;
		bool isFree;
	} header;
	ALIGIN_TYPE aligin[sizeof(header) / sizeof(ALIGIN_TYPE) + (sizeof(header) % sizeof(ALIGIN_TYPE) ? 1 : 0)];
};
