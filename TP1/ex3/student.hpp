#ifndef __STUDENT_HPP__
#define __STUDENT_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"

__global__ void kernelComputeSepia( const uchar *const in, uchar *const out, const int width, const int height );

float sepiaGPU( const PPMBitmap &in, PPMBitmap &out );

#endif // __STUDENT_HPP__
