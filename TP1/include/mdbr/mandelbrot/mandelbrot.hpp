#ifndef MDBR_MANDELBROT_HPP
#define MDBR_MANDELBROT_HPP

#include <cstdint>

namespace mdbr
{
	struct MandelbrotConfiguration
	{
		uint32_t maxIteration;
		uint32_t width;
		uint32_t height;
		float	 zoom;
		float	 shiftX;
		float	 shiftY;
	};
} // namespace mdbr

#endif // MDBR_MANDELBROT_HPP
