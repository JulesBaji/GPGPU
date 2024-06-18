// DO NOT MODIFY THIS FILE !!!

#include "mdbr/mandelbrot/reference.hpp"
#include "mdbr/cuda/color.cuh"

namespace mdbr
{
	float MandelbrotCPU( const Complex & c, const int maxIteration )
	{
		Complex z = c;
		int		n = 0;
		for ( ; n < maxIteration; ++n )
		{
			if ( std::abs( z ) >= 2.f )
				break;
			z = z * z + c;
		}
		return static_cast<float>( n ) / static_cast<float>( maxIteration );
	}

	void renderMandelbrotCPU( MandelbrotConfiguration configuration, uchar4 * const pixels )
	{
		const Complex center( -.7f + configuration.shiftX, configuration.shiftY );
		const Complex span( 2.7f / configuration.zoom,
							-( 4.f / 3.f ) * 2.7f * configuration.height / configuration.width / configuration.zoom );
		const Complex begin( center - ( span / 2.f ) );
		const Complex end( center + ( span / 2.f ) );

		for ( int x = 0; x < configuration.width; ++x )
		{
			for ( int y = 0; y < configuration.height; ++y )
			{
				const Complex c = begin
								  + Complex( x / configuration.zoom * span.real() / ( configuration.width + 1.f ),
											 y / configuration.zoom * span.imag() / ( configuration.height + 1.f ) );
				const float res = MandelbrotCPU( c, configuration.maxIteration );

				const int idPixel = x + y * configuration.width;

				if ( res >= 1.f )
				{
					pixels[ idPixel ].x = 0;
					pixels[ idPixel ].y = 0;
					pixels[ idPixel ].z = 0;
					pixels[ idPixel ].w = 255;
				}
				else
				{
					const float res2
						= logf( 1.f + res * configuration.maxIteration ) / logf( 1.f + configuration.maxIteration );
					const uchar3 rgb	= floatToRGB( res2 );
					pixels[ idPixel ].x = rgb.x;
					pixels[ idPixel ].y = rgb.y;
					pixels[ idPixel ].z = rgb.z;
					pixels[ idPixel ].w = 255;
				}
			}
		}
	}
} // namespace mdbr
