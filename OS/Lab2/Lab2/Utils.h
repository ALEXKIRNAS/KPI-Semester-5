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
vector<vector<pair<unsigned int, tasks> > > mergeTasks(vector<tasks> tasksToMerge, unsigned int outputNumberOfTasks);
vector<vector<float>> generateScheduleMatrix(vector<vector<pair<unsigned int, tasks> > > taskList, vector<float> CPUs);
float enumulateSchedulerWork(unsigned int numberOfTasks, unsigned int numberOfCPUs);

// ----
vector<pair<unsigned int, tasks> >  sortTasks(vector<pair<unsigned int, tasks> > taskList);
vector<unsigned short> sortCPUs(vector<unsigned short> CPUs);
