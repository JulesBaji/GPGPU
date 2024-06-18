#ifndef MDBR_RENDERER_HPP
#define MDBR_RENDERER_HPP

#include "cuda/buffer.cuh"
#include "mdbr/mandelbrot/mandelbrot.hpp"
#include <vector>

namespace mdbr
{
	class Window;
	class Renderer
	{
	  public:
		Renderer() = default;
		Renderer( Window * );

		Renderer( const Renderer & )			 = delete;
		Renderer & operator=( const Renderer & ) = delete;

		Renderer( Renderer && ) noexcept;
		Renderer & operator=( Renderer && ) noexcept;

		~Renderer();

		void resize( uint32_t width, uint32_t height );
		void draw( MandelbrotConfiguration configuration, bool gpuCompute = true );

	  private:
		void initGL();

		Window * m_window;

		uint32_t m_width;
		uint32_t m_height;

		std::vector<uchar4> m_hostData;
		CuGlBuffer			m_buffer;
		GLuint				m_fbo		 = GL_INVALID_VALUE;
		GLuint				m_fboTexture = GL_INVALID_VALUE;
		GLuint				m_quadVAO	 = GL_INVALID_VALUE;
		GLuint				m_quadVBO	 = GL_INVALID_VALUE;
	};
} // namespace mdbr

#endif // MDBR_RENDERER_HPP
