#ifndef __STUDENT_HPP__
#define __STUDENT_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"
#include "utils/chronoGPU.hpp"

__global__ void kernelComputeConv( const int *const dev_Data, int *const dev_Histogramme, const int size, 
	const int distributionSize);

float calcHistogrammeGPU( const int *data, int *histogramme, const int size, const int distributionSize);

#endif // __STUDENT_HPP__
