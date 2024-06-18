#include "mdbr/cuda/buffer.cuh"
#include "mdbr/cuda/common.cuh"
#include <utility>

namespace mdbr
{
	CuGlBuffer::CuGlBuffer( const std::size_t size, bool zeroInit )
	{
		glGenBuffers( 1, &m_bufferId );
		glBindBuffer( GL_PIXEL_PACK_BUFFER, m_bufferId );
		glBufferData( GL_PIXEL_PACK_BUFFER, size, nullptr, GL_STREAM_DRAW );
		glBindBuffer( GL_PIXEL_PACK_BUFFER, 0u );
		checkCudaErrors( cudaGraphicsGLRegisterBuffer( &m_binding, m_bufferId, m_registerFlags ) );

		if ( zeroInit )
		{
			uint8_t * data = get<uint8_t>();
			checkCudaErrors( cudaMemset( data, 0, size ) );
		}
	}

	CuGlBuffer::CuGlBuffer( CuGlBuffer && other ) noexcept
	{
		std::swap( m_size, other.m_size );
		std::swap( m_ptr, other.m_ptr );

		std::swap( m_bufferId, other.m_bufferId );
		std::swap( m_type, other.m_type );
		std::swap( m_binding, other.m_binding );
		std::swap( m_registerFlags, other.m_registerFlags );
	}

	CuGlBuffer & CuGlBuffer::operator=( CuGlBuffer && other ) noexcept
	{
		std::swap( m_size, other.m_size );
		std::swap( m_ptr, other.m_ptr );

		std::swap( m_bufferId, other.m_bufferId );
		std::swap( m_type, other.m_type );
		std::swap( m_binding, other.m_binding );
		std::swap( m_registerFlags, other.m_registerFlags );

		return *this;
	}

	CuGlBuffer::~CuGlBuffer()
	{
		if ( glIsBuffer( m_bufferId ) )
		{
			if ( m_ptr )
			{
				m_ptr = nullptr;
				checkCudaErrors( cudaGraphicsUnmapResources( 1, &m_binding, 0 ) );
			}
			checkCudaErrors( cudaGraphicsUnregisterResource( m_binding ) );
			glDeleteBuffers( 1, &m_bufferId );
		}
	}
} // namespace mdbr
