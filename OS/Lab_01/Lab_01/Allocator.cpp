#include <stdio.h>
#include <atlalloc.h>

typedef long int align; /* forces alignment on 32 bits */

union header { /* free block header */
	struct {
		union header *ptr; /* next free block */
		unsigned size; /* size of this free block */
	} s;
	align x; /* force alignment of blocks */
};

typedef union header header;static header base; /* empty list to get started */
static header *allocp = NULL; /* last allocated block */


char *alloc(nbytes) /* general-purpose storage allocator */
unsigned nbytes
{
	header *morecore();
	register header *p, *g;
	register int nunits;
	nunits = 1 + (nbytes + sizeof(header) - 1) / sizeof(header);
	if ((g = allocp) == NULL) { /* no free list yet */
		base.s.ptr = allocp = g = &base;
		base.s.size = 0;
	}
	for (p = g->s.ptr;; g = p, p = p->s.ptr) {
		if (p->s.size >= nunits) { /* big enough */
			if (p->s.size == nunits) /* exactly */
				g->s.ptr = p->s.ptr;
			else { /* allocate tail end */
				p->s.size -= nunits;
				p += p->s.size;
				p->s.size = nunits;
			}
			allocp = g;
			return ((char *)(p + 1));
		}
		if (p == allocp) /* wrapped around free list */
			if ((p = morecore(nunits)) == NULL)
				return (NULL); /* none left */
	}
}