#include "Utils.h"
#include "Hungarian.h"
#include <stdio.h>

bool tasks_list_predicate(pair<unsigned int, tasks>& x, pair<unsigned int, tasks>& y) {
	if (x.second.timeOfExec < y.second.timeOfExec) {
		return true;
	}
	else {
		return false;
	}
}

float enumulateSchedulerWork(unsigned int numberOfTasks, unsigned int numberOfCPUs) {
	vector<unsigned short> CPUs =  generateCPUs(numberOfCPUs);
	CPUs = sortCPUs(CPUs);

	vector<float> relevantCPUs = vector<float>(CPUs.size());
	for (int i = 0, size = CPUs.size(); i < size; i++) {
		relevantCPUs[i] = CPUs[i] * 1. / CPUs[size - 1];
	}

	vector<tasks> task = generateTasks(numberOfTasks);
	vector<vector<pair<unsigned int, tasks> > > taskList = mergeTasks(task, numberOfCPUs);

	printf("Generated CPUs:\n");
	for (int i = 0; i < numberOfCPUs; i++) {
		printf("Id: %d - Speed: %d MHz\n", i, CPUs[i]);
	}

	printf("\nGenerated tasks:\n");
	float sum = 0;
	for (int i = 0; i < numberOfTasks; i++) {
		printf("Id: %d - Exec resources: %.3f MHz - Critical time: %.3f MHz\n", i, 
			task[i].timeOfExec * CPUs[CPUs.size() - 1], task[i].taskEndTime * CPUs[CPUs.size() - 1]);
		sum += task[i].timeOfExec * CPUs[CPUs.size() - 1];
	}
	printf("Total tasks on %.3f MHz time\n", sum);

	vector<vector<float>> matrix = generateScheduleMatrix(taskList, relevantCPUs);
	for (int i = 0, size_1 = matrix.size(); i < size_1; i++) {
		for (int z = i, size_2 = matrix[i].size(); z < size_2; z++) {
			if (matrix[i][z] >= 0) {
				matrix[i][z] = 0;
			} else {
				matrix[i][z] = -matrix[i][z];
			}

			matrix[z][i] = matrix[i][z];
		}
	}
	
	printf("\nExecution matrix:\n");
	for (int i = 0; i < numberOfCPUs; i++) {
		for (int z = 0; z < numberOfCPUs; z++) {
			printf("%10.3f ", -matrix[i][z]);
		}
		printf("\n");
	}

	vector<PInt> VPFloat = hungarian(matrix);
	float penalty = 0;
	matrix = generateScheduleMatrix(taskList, relevantCPUs);

	printf("\nResults matrix:\n");
	for (int i = 0; i < VPFloat.size(); i++) {
		for (int z = 0, size = taskList[VPFloat[i].first].size(); z < size; z++) {
			printf("Task %d to CPU %d\n", taskList[VPFloat[i].first][z].first, VPFloat[i].second);
			penalty += matrix[VPFloat[i].first][VPFloat[i].second];
		}
	}

	return -penalty;
}


vector<unsigned short> generateCPUs(unsigned int numberOfCPUs) {
	vector<unsigned short> CPUs = vector<unsigned short>(numberOfCPUs);

	for (int i = 0; i < numberOfCPUs; i++) {
		CPUs[i] = rand() % 30 + 5;
	}

	return CPUs;
}


vector<tasks> generateTasks(unsigned int numberOfTasks) {
	vector<tasks> task = vector<tasks>(numberOfTasks);

	for (int i = 0; i < numberOfTasks; i++) {
		task[i].timeOfExec = rand() * 1.0f / RAND_MAX * 30 + 0.1;
		task[i].taskEndTime = rand() * 1.0f / RAND_MAX * 30 + task[i].timeOfExec;
	}

	return task;
}


vector<vector<pair<unsigned int, tasks> > > mergeTasks(vector<tasks> tasksToMerge, unsigned int outputNumberOfTasks) {
	vector<vector<pair<unsigned int, tasks> > > merged_tasks = vector<vector<pair<unsigned int, tasks> > >(outputNumberOfTasks);
	float* cumsum = new float[outputNumberOfTasks];
	for (int i = 0; i < outputNumberOfTasks; i++) {
		cumsum[i] = 0.;
	}

	for (int i = 0, size = tasksToMerge.size(); i < size; i++) {
		int index_of_min = 0;
		for (int z = 1; z < outputNumberOfTasks; z++) {
			if (cumsum[z] < cumsum[index_of_min]) index_of_min = z;
		}

		cumsum[index_of_min] += tasksToMerge[i].timeOfExec;
		merged_tasks[index_of_min].push_back(std::make_pair(i, tasksToMerge[i]));
	}


	for (int i = 0; i < outputNumberOfTasks; i++) {
		merged_tasks[i] = sortTasks(merged_tasks[i]);
	}

	delete[] cumsum;
	return merged_tasks;
}


vector<vector<float>> generateScheduleMatrix(vector<vector<pair<unsigned int, tasks> > > taskList, vector<float> CPUs) {
	unsigned int n = CPUs.size();
	vector<vector<float>> matrix = vector< vector<float> >(n);
	for (int i = 0; i < n; i++) {
		matrix[i] = vector<float>(n);
	}

	for (int i = 0; i < n; i++) {
		for (int z = i; z < n; z++) {
			matrix[i][z] = 0;
			float curr_time = 0;
			for (int j = 0; j < taskList[i].size(); j++) {
				curr_time += taskList[i][j].second.timeOfExec / CPUs[z];
				if (curr_time > taskList[i][j].second.taskEndTime) {
					matrix[i][z] -= curr_time - taskList[i][j].second.taskEndTime;
				}
			}

			matrix[z][i] = matrix[i][z];
		}
	}

	return matrix;
}


vector<pair<unsigned int, tasks> >  sortTasks(vector<pair<unsigned int, tasks> > taskList) {
	std::sort(taskList.begin(), taskList.end(), tasks_list_predicate);
	return taskList;
}


vector<unsigned short> sortCPUs(vector<unsigned short> CPUs) {
	std::sort(CPUs.begin(), CPUs.end());
	return CPUs;
}
