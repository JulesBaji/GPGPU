#ifndef __REFERENCE_HPP__
#define __REFERENCE_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"

void convCPU(	uchar *const out, const uchar *const in, 
				const float *const kernelConv, 
				const int imgWidth, const int imgHeight,
				const int matWidth, const int matHeight );

#endif
