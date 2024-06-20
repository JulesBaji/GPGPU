#include "save_ppm_image.hpp"

void save_ppm_image(const los::Heightmap &result, const std::string &filename) {
    std::ofstream ppm_file(filename, std::ios::out | std::ios::binary);

    if (!ppm_file.is_open()) {
        std::cerr << "Error: Could not open file " << filename << " for writing." << std::endl;
        return;
    }

    const uint32_t width = result.getWidth();
    const uint32_t height = result.getHeight();

    ppm_file << "P6\n";
    ppm_file << width << " " << height << "\n";
    ppm_file << "255\n";

    for (int y = height - 1; y >= 0; --y) {
        for (uint32_t x = 0; x < width; ++x) {
            uint8_t pixel_value = result.getPixel(x, y);
            ppm_file.write(reinterpret_cast<const char*>(&pixel_value), sizeof(uint8_t));
            ppm_file.write(reinterpret_cast<const char*>(&pixel_value), sizeof(uint8_t));
            ppm_file.write(reinterpret_cast<const char*>(&pixel_value), sizeof(uint8_t));
        }
    }

    ppm_file.close();
}