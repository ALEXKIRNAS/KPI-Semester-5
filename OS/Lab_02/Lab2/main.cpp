#include "Utils.h"
#include <stdlib.h>

int main(void) {
	unsigned int CPUs, jobs;
	printf("Enter number of CPUs and jobs: ");
	scanf("%d%d", &CPUs, &jobs);

	printf("Total penalty sum: %f MHz\n", enumulateSchedulerWork(jobs, CPUs));
	system("pause");
}
