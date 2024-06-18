#include "mdbr/renderer.hpp"
#include "mdbr/mandelbrot/reference.hpp"
#include "mdbr/mandelbrot/student.hpp"
#include "mdbr/window.hpp"
#include <GL/gl3w.h>
#include <array>
#include <stdexcept>
#include <vector>

namespace mdbr
{
	Renderer::Renderer( Window * window ) :
		m_window( window ), m_width( m_window->getWidth() ), m_height( m_window->getHeight() )
	{
		resize( m_window->getWidth(), m_window->getHeight() );
	}

	Renderer::Renderer( Renderer && other ) noexcept
	{
		std::swap( m_window, other.m_window );
		std::swap( m_width, other.m_width );
		std::swap( m_height, other.m_height );

		std::swap( m_hostData, other.m_hostData );
		std::swap( m_buffer, other.m_buffer );
		std::swap( m_fbo, other.m_fbo );
		std::swap( m_fboTexture, other.m_fboTexture );
		std::swap( m_quadVAO, other.m_quadVAO );
		std::swap( m_quadVBO, other.m_quadVBO );
	}

	Renderer & Renderer::operator=( Renderer && other ) noexcept
	{
		std::swap( m_window, other.m_window );
		std::swap( m_width, other.m_width );
		std::swap( m_height, other.m_height );

		std::swap( m_hostData, other.m_hostData );
		std::swap( m_buffer, other.m_buffer );
		std::swap( m_fbo, other.m_fbo );
		std::swap( m_fboTexture, other.m_fboTexture );
		std::swap( m_quadVAO, other.m_quadVAO );
		std::swap( m_quadVBO, other.m_quadVBO );

		return *this;
	}

	Renderer::~Renderer()
	{
		glDeleteFramebuffers( 1, &m_fbo );
		glDeleteTextures( 1, &m_fboTexture );
	}

	void Renderer::resize( uint32_t width, uint32_t height )
	{
		m_width	 = width;
		m_height = height;

		initGL();
		m_buffer = CuGlBuffer::Typed<uchar4>( m_width * m_height );
		m_hostData.resize( m_width * m_height );
	}

	void Renderer::draw( MandelbrotConfiguration configuration, bool gpuCompute )
	{
		uchar4 * data = m_buffer.get<uchar4>();
		if ( gpuCompute )
		{
			// Remplacer la ligne suivant par l'appel au kernel correspondant à la génération de l'image.
			cudaMemset( data, 0, sizeof( uchar4 ) * m_width * m_height );
		}
		else
		{
			renderMandelbrotCPU( std::move( configuration ), m_hostData.data() );
			cudaMemcpy( data, m_hostData.data(), sizeof( uchar4 ) * m_width * m_height, cudaMemcpyHostToDevice );
		}

		m_buffer.invalid();

		glBindTexture( GL_TEXTURE_2D, m_fboTexture );
		glBindBuffer( GL_PIXEL_UNPACK_BUFFER, m_buffer.getId() );
		glTexSubImage2D( GL_TEXTURE_2D, 0, 0, 0, m_width, m_height, GL_RGBA, GL_UNSIGNED_BYTE, nullptr );
		glBindBuffer( GL_PIXEL_UNPACK_BUFFER, 0 );

		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
		glBindFramebuffer( GL_READ_FRAMEBUFFER, m_fbo );
		glBindFramebuffer( GL_DRAW_FRAMEBUFFER, 0 );
		glBlitFramebuffer( 0, 0, m_width, m_height, 0, 0, m_width, m_height, GL_COLOR_BUFFER_BIT, GL_NEAREST );
	}

	void Renderer::initGL()
	{
		constexpr std::array<GLfloat, 8> quadVertices = {
			-1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f, -1.0f,
		};

		// Setup plane VAO.
		glGenBuffers( 1, &m_quadVBO );
		glBindBuffer( GL_ARRAY_BUFFER, m_quadVBO );
		glBufferData( GL_ARRAY_BUFFER, quadVertices.size() * sizeof( GLfloat ), quadVertices.data(), GL_STATIC_DRAW );
		glGenVertexArrays( 1, &m_quadVAO );
		glBindVertexArray( m_quadVAO );
		glBindBuffer( GL_ARRAY_BUFFER, m_quadVBO );
		glEnableVertexAttribArray( 0 );
		glVertexAttribPointer( 0, 2, GL_FLOAT, GL_FALSE, 0, nullptr );
		glBindBuffer( GL_ARRAY_BUFFER, 0 );
		glBindVertexArray( 0 );

		glGenFramebuffers( 1, &m_fbo );
		glBindFramebuffer( GL_FRAMEBUFFER, m_fbo );

		glGenTextures( 1, &m_fboTexture );
		glBindTexture( GL_TEXTURE_2D, m_fboTexture );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 0 );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, 0 );
		glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA16F, m_width, m_height, 0, GL_RGBA, GL_FLOAT, nullptr );

		glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, m_fboTexture, 0 );
		glBindTexture( GL_TEXTURE_2D, 0 );
		glBindFramebuffer( GL_FRAMEBUFFER, 0 );

		const GLenum fboStatus = glCheckFramebufferStatus( GL_FRAMEBUFFER );
		if ( fboStatus != GL_FRAMEBUFFER_COMPLETE )
			throw std::runtime_error( "Framebuffer not complete: " + fboStatus );

		const GLenum glstatus = glGetError();
		if ( glstatus != GL_NO_ERROR )
			throw std::runtime_error( "Error in GL call: " + glstatus );
	}
} // namespace mdbr
