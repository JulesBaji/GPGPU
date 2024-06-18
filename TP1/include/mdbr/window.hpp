#ifndef MDBR_WINDOW_HPP
#define MDBR_WINDOW_HPP

#include "mdbr/renderer.hpp"
#include <SDL.h>

namespace mdbr
{
	class Window
	{
	  public:
		Window( uint32_t width, uint32_t height );

		Window( const Window & )			 = delete;
		Window & operator=( const Window & ) = delete;

		Window( Window && );
		Window & operator=( Window && );

		~Window();

		uint32_t getWidth() const { return m_width; }
		uint32_t getHeight() const { return m_height; }

		SDL_Window * getHandle() { return m_window; }

		bool update();

	  private:
		uint32_t m_width;
		uint32_t m_height;

		SDL_Window *	m_window	= nullptr;
		SDL_GLContext	m_glContext = nullptr;
		SDL_DisplayMode m_displayMode;

		Renderer				m_renderer;
		MandelbrotConfiguration m_configuration {};
		bool					m_gpuCompute = true;
	};
} // namespace mdbr

#endif // MDBR_WINDOW_HPP
