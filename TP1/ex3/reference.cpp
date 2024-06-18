// DO NOT MODIFY THIS FILE !!!

#include "reference.hpp"
#include "utils/chronoCPU.hpp"

float sepiaCPU( const PPMBitmap &in, PPMBitmap &out ) 
{
	const int width		= in.getWidth();
	const int height	= in.getHeight();

	ChronoCPU chr;
	chr.start();
	
	for ( int j = 0; j < height; ++j ) 
	{
		for ( int i = 0; i < width; ++i ) 
		{
			const RGBcol &pixelIn = in.getPixel( i, j );
			RGBcol pixelOut;	
			pixelOut._r = static_cast<uchar>( std::min<float>( 255.f, ( pixelIn._r * .393f + pixelIn._g * .769f + pixelIn._b * .189f ) ) );
			pixelOut._g = static_cast<uchar>( std::min<float>( 255.f, ( pixelIn._r * .349f + pixelIn._g * .686f + pixelIn._b * .168f ) ) );
			pixelOut._b = static_cast<uchar>( std::min<float>( 255.f, ( pixelIn._r * .272f + pixelIn._g * .534f + pixelIn._b * .131f ) ) );
			out.setPixel( i, j, pixelOut ); 
		}
	}
	
	chr.stop();

	return chr.elapsedTime();
}