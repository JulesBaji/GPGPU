#ifndef MDBR_CUDACOLOR_CUH
#define MDBR_CUDACOLOR_CUH

namespace mdbr
{
	inline __host__ __device__  uchar3 floatToRGB(const float& l) 
	{
		const float h = 360.f * l;
		const float hp = h / 60.f;

		uchar3 res;
		if (hp < 1.f) 
		{
			const float x = (1.f - fabsf(hp - 1.f));
			res.x = 0;
			res.y = static_cast<unsigned char>(255.f * x);
			res.z = 255;
		}
		else if (hp < 2.f) 
		{
			const float x = (1.f - fabsf(hp - 2.f));
			res.x = static_cast<unsigned char>(255.f * x);
			res.y = 0;
			res.z = 255;
		}
		else if (hp < 3.f) 
		{
			const float x = (1.f - fabsf(hp - 3.f));
			res.x = 255;
			res.y = 0;
			res.z = static_cast<unsigned char>(255.f * x);
		}
		else if (hp < 4.f) 
		{
			const float x = (1.f - fabsf(hp - 4.f));
			res.x = 255;
			res.y = static_cast<unsigned char>(255.f * x);
			res.z = 0;
		}
		else if (hp < 5.f) 
		{
			const float x = (1.f - fabsf(hp - 5.f));
			res.x = static_cast<unsigned char>(255.f * x);
			res.y = 255;
			res.z = 0;
		}
		else if (hp < 6.f) 
		{
			const float x = (1.f - fabsf(hp - 6.f));
			res.x = 0;
			res.y = 255;
			res.z = static_cast<unsigned char>(255.f * x);
		}
		else 
		{
			res.x = 0;
			res.y = 0;
			res.z = 0;
		}
		return res;
	}
}

#endif // MDBR_CUDACOLOR_CUH