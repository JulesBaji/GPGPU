// DO NOT MODIFY THIS FILE !!!

#ifndef MDBR_REFERENCE_HPP
#define MDBR_REFERENCE_HPP

#include "mdbr/mandelbrot/mandelbrot.hpp"
#include <complex>

namespace mdbr
{
	using Complex = std::complex<float>;

	float mandelbrotCPU( const Complex & c, const int maxIteration );
	void  renderMandelbrotCPU( MandelbrotConfiguration configuration, uchar4 * const pixels );
} // namespace mdbr

#endif // MDBR_REFERENCE_HPP
