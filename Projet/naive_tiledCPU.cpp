#include "naive_tiledCPU.hpp"

void naive_tiledCPU(const los::Heightmap &hm, los::Heightmap &result, const uint32_t ppm_tiled_size, const uint32_t width, const uint32_t height, 
    const uint32_t tile_size_width, const uint32_t tile_size_height) {

    for (uint32_t tile_y = 0; tile_y < ppm_tiled_size; tile_y++) {
        for (uint32_t tile_x = 0; tile_x < ppm_tiled_size; tile_x++) {

            uint8_t max_height = 0;

            uint32_t start_y = tile_y * tile_size_height;
            uint32_t end_y = std::min(start_y + tile_size_height, height);
            uint32_t start_x = tile_x * tile_size_width;
            uint32_t end_x = std::min(start_x + tile_size_width, width);

            for (uint32_t y = start_y; y < end_y; y++) {
                for (uint32_t x = start_x; x < end_x; x++) {
                    uint8_t height_val = hm.getPixel(x, y);
                    max_height = std::max(max_height, height_val);
                }
            }
            result.setPixel(tile_x, tile_y, max_height);
        }
    }
    save_ppm_image(result, "result_cpu.ppm");
}