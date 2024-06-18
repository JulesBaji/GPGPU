#include "naive_viewtestCPU.hpp"

void DDA(const Point &A, const Point &B, std::vector<Point> &pixelsRasterisation)
{
    // Initialisation
    float x = A.x, y = A.y;
    const int dx = B.x - A.x, dy = B.y - A.y;
    const int D = std::max(abs(dx), abs(dy));
    const float incx = static_cast<float>(dx) / static_cast<float>(D);
    const float incy = static_cast<float>(dy) / static_cast<float>(D);

    // Tracage (On evite le premier et dernier point )
    for(int i = 0; i < D - 1; i++)
    {
        x += incx;
        y += incy;
        pixelsRasterisation.push_back(Point(x, y));
    }
}

void naive_viewtestCPU(const los::Heightmap &hm, const Point &c, los::Heightmap &resultatsCPU )
{
    for(int i = 0; i < hm.getHeight(); i++) 
    {
        for(int j = 0; j < hm.getWidth(); j++) 
        {
            // Point courant
            Point pCourant(j,i);

            // On vérifie que le point courant soit différent du point donné
            if ( pCourant!=c )
            {

                std::vector<Point> pixelsRasterisation;
                bool visible = true;

                DDA(c, pCourant, pixelsRasterisation);

                // Calcul de angle(c, p)
                const uint8_t hPCourant = hm.getPixel(pCourant.x, pCourant.y);
                const uint8_t hC = hm.getPixel(c.x, c.y);
                const float angleCPCourant = atan2f(hPCourant - hC, sqrtf(float((pCourant.x - c.x)*(pCourant.x - c.x) 
                    + (pCourant.y - c.y)*(pCourant.y - c.y))));

                // Pour chaque point rasterisé avec DDA entre le centre et le point courant
                for( Point pRast : pixelsRasterisation )
                {
                    // On calcule angle(c, p(i,j))
                    const uint8_t hPRast = hm.getPixel(pRast.x, pRast.y);
                    const float angleCPRast = atan2f(hPRast - hC, sqrtf(float((pRast.x - c.x)*(pRast.x - c.x) + (pRast.y - c.y)*(pRast.y - c.y))));
                    
                    // Vérification angle(c,p) < angle(c,p(i,j))
                    if ( angleCPRast >= angleCPCourant)
                    {
                        visible = false;
                        break;
                    }
                }
                if (visible == true) 
                { 
                    // Inversion de l'axe des y pour une comparaison plus exacte : l'axe des ordonnées de 1.input.ppm est inversé
                    int inversionY2D = hm.getHeight() - 1 - pCourant.y;
                    resultatsCPU.setPixel(pCourant.x, inversionY2D, 255u);
                    // resultatsCPU.setPixel(pCourant.x, pCourant.y, 255u);
                } 
            } 
        }
    }  
}