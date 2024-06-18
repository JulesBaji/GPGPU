#ifndef MDBR_BUFFER_CUH
#define MDBR_BUFFER_CUH

#include <cstdint>

#include "mdbr/cuda/common.cuh"
#include <GL/gl3w.h>
#include <cuda_gl_interop.h>

namespace mdbr
{
	class CuGlBuffer
	{
	  public:
		template<class Type>
		static CuGlBuffer Typed( const std::size_t count, bool zeroInit = false )
		{
			return CuGlBuffer( count * sizeof( Type ), zeroInit );
		}

		CuGlBuffer() = default;
		CuGlBuffer( const std::size_t size, bool zeroInit = false );

		CuGlBuffer( const CuGlBuffer & )			 = delete;
		CuGlBuffer & operator=( const CuGlBuffer & ) = delete;

		CuGlBuffer( CuGlBuffer && ) noexcept;
		CuGlBuffer & operator=( CuGlBuffer && ) noexcept;

		~CuGlBuffer();

		GLuint getId() { return m_bufferId;}

		template<class Type>
		Type * get()
		{
			if ( !m_ptr )
			{
				checkCudaErrors( cudaGraphicsMapResources( 1, &m_binding ) );
				checkCudaErrors(
					cudaGraphicsResourceGetMappedPointer( reinterpret_cast<void **>( &m_ptr ), nullptr, m_binding ) );
			}

			return reinterpret_cast<Type *>( m_ptr );
		}

		template<class Type>
		const Type * get() const
		{
			if ( !m_ptr )
			{
				checkCudaErrors( cudaGraphicsMapResources( 1, &m_binding ) );
				checkCudaErrors(
					cudaGraphicsResourceGetMappedPointer( reinterpret_cast<void **>( &m_ptr ), nullptr, m_binding ) );
			}

			return reinterpret_cast<const Type *>( m_ptr );
		}

		void invalid() const
		{
			if ( m_ptr )
			{
				m_ptr = nullptr;
				checkCudaErrors( cudaGraphicsUnmapResources( 1, &m_binding ) );
			}
		}

		template<class Type>
		std::size_t size() const
		{
			return m_size / sizeof( Type );
		}

		std::size_t size() const { return m_size; }

	  private:
		std::size_t		  m_size = 0;
		mutable uint8_t * m_ptr	 = nullptr;

		// GL interoperability
		GLuint						   m_bufferId	   = GL_INVALID_VALUE;
		uint32_t					   m_type		   = GL_INVALID_VALUE;
		mutable cudaGraphicsResource_t m_binding	   = nullptr;
		cudaGraphicsRegisterFlags	   m_registerFlags = cudaGraphicsRegisterFlagsNone;
	};
} // namespace mdbr

#endif // MDBR_BUFFER_CUH
