#pragma once
#define ALIGIN_TYPE long int // 4 bytes

union MemoryHeader {
	struct Header{
		MemoryHeader* NextBlock;
		MemoryHeader* PrevBlock;
		bool isFree;
	} sheader;
	ALIGIN_TYPE aligin[sizeof(Header) / sizeof(ALIGIN_TYPE) + (sizeof(Header) % sizeof(ALIGIN_TYPE) ? 1 : 0)];
};
