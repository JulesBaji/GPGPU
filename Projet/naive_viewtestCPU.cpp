#include "naive_viewtestCPU.hpp"

void naive_viewtestCPU(const los::Heightmap &hm, const Point &c, los::Heightmap &resultatsCPU )
{
    const uint8_t zc = hm.getPixel(c.x, c.y);

    for(int y = 0; y < hm.getHeight(); y++) 
    {
        for(int x = 0; x < hm.getWidth(); x++) 
        {
            if ( x == c.x && y == c.y ) continue;
            
            const uint8_t zp = hm.getPixel(x, y);
            const float angle_cp = atan2f(zp - zc, sqrtf((x - c.x)*(x - c.x) + (y - c.y)*(y - c.y)));

            // DDA
            float x_DDA = c.x, y_DDA = c.y;
            const int dx = x - c.x, dy = y - c.y;
            const int D = std::max(abs(dx), abs(dy));
            const float incx = (float)dx / D;
            const float incy = (float)dy / D;

            // Tracé (On evite le premier et dernier point)
            bool visible = true;
            for(int i = 0; i < D - 1; i++)
            {
                x_DDA += incx;
                y_DDA += incy;
                
                const int zp_ij = hm.getPixel(x_DDA, y_DDA); 
                const float angle_cpij = atan2f(zp_ij - zc, sqrtf((x_DDA - c.x)*(x_DDA - c.x) + (y_DDA - c.y)*(y_DDA - c.y)));
                
                // angle(c,p) < angle(c,p(i,j)) ?
                if ( angle_cp < angle_cpij )
                {
                    visible = false;
                    break;
                }
            }
            if (visible) resultatsCPU.setPixel(x, y, 255u);
        }
    }  
}