#ifndef MDBR_STUDENT_HPP
#define MDBR_STUDENT_HPP

#include "mdbr/mandelbrot/mandelbrot.hpp"
#include <cuda/std/complex>

namespace mdbr
{
	using DeviceComplex = cuda::std::complex<float>;

	__device__ float mandelbrotGPU( const DeviceComplex & c, const int maxIteration );
	__global__ void	 renderMandelbrotGPU( MandelbrotConfiguration configuration, uchar4 * const pixels );
} // namespace mdbr

#endif // MDBR_STUDENT_HPP
