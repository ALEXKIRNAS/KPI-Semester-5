/* Realization from: http://acm.mipt.ru/twiki/bin/view/Algorithms/HungarianAlgorithmCPP
 */

#pragma once

#include <vector>
#include <limits>
using namespace std;

typedef pair<float, float> PFloat;
typedef vector<float> VFloat;
typedef vector<VFloat> VVFloat;
typedef vector<PFloat> VPFloat;

const int inf = numeric_limits<int>::max();

/*
* Решает задачу о назначениях Венгерским методом.
* matrix: прямоугольная матрица из целых чисел (не обязательно положительных).
*         Высота матрицы должна быть не больше ширины.
* Возвращает: Список выбранных элементов, по одному из каждой строки матрицы.
*/
VPFloat hungarian(const VVFloat &matrix);
