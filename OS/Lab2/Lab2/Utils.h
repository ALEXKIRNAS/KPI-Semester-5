#pragma once
#include <random>
#include <algorithm>
#include <vector>

using namespace std;

struct tasks {
	// Constraints:
	// {timeOfExec} > 0
	// {taskEndTime} > 0

	float taskEndTime; // in terms of most powerful CPU
	float timeOfExec; // in terms of most powerful CPU
};

vector<unsigned short> generateCPUs(unsigned int numberOfCPUs);
vector<tasks> generateTasks(unsigned int numberOfTasks);
vector<tasks> mergeTasks(vector<tasks> tasksToMerge, unsigned int outputNumberOfTasks);
vector<vector<float>> generateScheduleMatrix(vector<tasks> taskList, vector<unsigned short> CPUs);
float enumulateSchedulerWork(unsigned int numberOfTasks, unsigned int numberOfCPUs);

// ----
vector<tasks> sortTasks(vector<tasks> taskList);
vector<unsigned short> sortCPUs(vector<unsigned short> CPUs);

// ----
void printScheduleMatrix(vector<vector<float>> matrix);
void printTaskList(vector<tasks> taskList);
void printCPUs(vector<unsigned short> CPUs);
