#ifndef __NAIVE_VIEWTESTCPU_HPP__
#define __NAIVE_VIEWTESTCPU_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"
#include "cmath"
#include <iostream>
#include <vector>

void DDA(const Point &A, const Point &B, std::vector<Point> &pixelsRasterisation);
void naive_viewtestCPU(const los::Heightmap &hm, const Point &c, los::Heightmap &resultatsCPU);

#endif