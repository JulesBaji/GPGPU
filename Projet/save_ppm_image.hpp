#ifndef __SAVE_PPM_IMAGE__
#define __SAVE_PPM_IMAGE__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"
#include <fstream>
#include <algorithm>

void save_ppm_image(const los::Heightmap &result, const std::string &filename);

#endif // __SAVE_PPM_IMAGE__
