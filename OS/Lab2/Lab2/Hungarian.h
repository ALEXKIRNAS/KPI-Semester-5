/* Realization from: http://acm.mipt.ru/twiki/bin/view/Algorithms/HungarianAlgorithmCPP
 */

#pragma once

#include <vector>
#include <limits>
using namespace std;

typedef pair<int, int> PInt;
typedef vector<float> VFloat;
typedef vector<VFloat> VVFloat;
typedef vector<PInt> VPFloat;

const int inf = numeric_limits<int>::max();

/*
* ������ ������ � ����������� ���������� �������.
* matrix: ������������� ������� �� ����� ����� (�� ����������� �������������).
*         ������ ������� ������ ���� �� ������ ������.
* ����������: ������ ��������� ���������, �� ������ �� ������ ������ �������.
*/
VPFloat hungarian(const VVFloat &matrix);
