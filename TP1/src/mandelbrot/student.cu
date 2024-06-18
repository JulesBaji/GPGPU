#include "mdbr/cuda/color.cuh"
#include "mdbr/mandelbrot/student.hpp"

namespace mdbr
{
	__device__ float MandelbrotGPU( const DeviceComplex & c, const int maxIteration )
	{
		DeviceComplex z = c;
		uint32_t	  n = 0;
		for ( ; n < maxIteration; ++n )
		{
			if ( cuda::std::abs( z ) >= 2.f )
				break;
			z = ( z * z ) + c;
		}
		return static_cast<float>( n ) / static_cast<float>( maxIteration );
	}

	__global__ void renderMandelbrotGPU( MandelbrotConfiguration configuration, uchar4 * const pixels )
	{
		//
	}
} // namespace mdbr
