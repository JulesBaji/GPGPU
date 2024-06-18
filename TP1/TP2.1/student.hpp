#ifndef __STUDENT_HPP__
#define __STUDENT_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"
#include "utils/chronoGPU.hpp"

__device__ __constant__ float convMat[11*11];

__global__ void kernelComputeSepia( const uchar *const in, uchar *const out, const int width, const int height, const int tailleMatrice );

float convGPU( const PPMBitmap &in, PPMBitmap &out, const float *const matrice,
	const int tailleMatrice );

#endif // __STUDENT_HPP__
