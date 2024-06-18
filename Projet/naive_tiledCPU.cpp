#include "naive_tiledCPU.hpp"
#include <fstream>


void naive_tiledCPU(const los::Heightmap &hm, los::Heightmap &result) {
    const uint32_t tile_size = 1; // Taille de tuile arbitraire, à ajuster
    const uint32_t width = hm.getWidth();
    const uint32_t height = hm.getHeight();
    
    for (uint32_t tile_y = 0; tile_y < height; tile_y += tile_size) {
        for (uint32_t tile_x = 0; tile_x < width; tile_x += tile_size) {
            uint8_t max_height = 0;
            
            for (uint32_t y = tile_y; y < std::min(tile_y + tile_size, height); ++y) {
                for (uint32_t x = tile_x; x < std::min(tile_x + tile_size, width); ++x) {
                    uint8_t height_val = hm.getPixel(x, y);
                    max_height = std::max(max_height, height_val);
                }
            }

            for (uint32_t y = tile_y; y < std::min(tile_y + tile_size, height); ++y) {
                for (uint32_t x = tile_x; x < std::min(tile_x + tile_size, width); ++x) {
                    result.setPixel(x, y, max_height);
                }
            }
        }
    }
    save_ppm_image(result, "result_cpu.ppm");
    
}

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

    for (uint32_t y = 0; y < height; ++y) {
        for (uint32_t x = 0; x < width; ++x) {
            uint8_t pixel_value = result.getPixel(x, y);
            ppm_file.write(reinterpret_cast<const char*>(&pixel_value), sizeof(uint8_t));
            ppm_file.write(reinterpret_cast<const char*>(&pixel_value), sizeof(uint8_t));
            ppm_file.write(reinterpret_cast<const char*>(&pixel_value), sizeof(uint8_t));
        }
    }

    ppm_file.close();
    }