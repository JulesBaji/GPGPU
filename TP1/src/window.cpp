#include "mdbr/window.hpp"
#include "backends/imgui_impl_opengl3.h"
#include "mdbr/renderer.hpp"
#include <GL/gl3w.h>
#include <backends/imgui_impl_sdl.h>
#include <iostream>
#include <stdexcept>
#include <string>

namespace mdbr
{
	static void APIENTRY debugMessageCallback( const GLenum	  p_source,
											   const GLenum	  p_type,
											   const GLuint	  p_id,
											   const GLenum	  p_severity,
											   const GLsizei  p_length,
											   const GLchar * p_msg,
											   const void *	  p_data )
	{
		if ( p_severity == GL_DEBUG_SEVERITY_NOTIFICATION )
			return;

		std::string source;
		std::string type;
		std::string severity;

		switch ( p_source )
		{
		case GL_DEBUG_SOURCE_API: source = "API"; break;
		case GL_DEBUG_SOURCE_WINDOW_SYSTEM: source = "WINDOW SYSTEM"; break;
		case GL_DEBUG_SOURCE_SHADER_COMPILER: source = "SHADER COMPILER"; break;
		case GL_DEBUG_SOURCE_THIRD_PARTY: source = "THIRD PARTY"; break;
		case GL_DEBUG_SOURCE_APPLICATION: source = "APPLICATION"; break;
		case GL_DEBUG_SOURCE_OTHER: source = "UNKNOWN"; break;
		default: source = "UNKNOWN"; break;
		}

		switch ( p_type )
		{
		case GL_DEBUG_TYPE_ERROR: type = "ERROR"; break;
		case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR: type = "DEPRECATED BEHAVIOR"; break;
		case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR: type = "UDEFINED BEHAVIOR"; break;
		case GL_DEBUG_TYPE_PORTABILITY: type = "PORTABILITY"; break;
		case GL_DEBUG_TYPE_PERFORMANCE: type = "PERFORMANCE"; break;
		case GL_DEBUG_TYPE_OTHER: type = "OTHER"; break;
		case GL_DEBUG_TYPE_MARKER: type = "MARKER"; break;
		default: type = "UNKNOWN"; break;
		}

		switch ( p_severity )
		{
		case GL_DEBUG_SEVERITY_HIGH: severity = "HIGH"; break;
		case GL_DEBUG_SEVERITY_MEDIUM: severity = "MEDIUM"; break;
		case GL_DEBUG_SEVERITY_LOW: severity = "LOW"; break;
		case GL_DEBUG_SEVERITY_NOTIFICATION: severity = "NOTIFICATION"; break;
		default: severity = "UNKNOWN"; break;
		}

		std::cout << "[OPENGL] [ " + severity + "] [ " + type + "] " + source + " : " + p_msg + "\n";
	}

	Window::Window( uint32_t width, uint32_t height ) : m_width( width ), m_height( height )
	{
		if ( SDL_Init( SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_GAMECONTROLLER ) != 0 )
			throw std::runtime_error( SDL_GetError() );

		SDL_GL_SetAttribute( SDL_GL_CONTEXT_FLAGS, 0 );
		SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE );
		SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 4 );
		SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 5 );
		SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );
		SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE, 24 );
		SDL_GL_SetAttribute( SDL_GL_STENCIL_SIZE, 8 );

		SDL_GetCurrentDisplayMode( 0, &m_displayMode );

		m_window = SDL_CreateWindow(
			"Mandebrot renderer",
			SDL_WINDOWPOS_CENTERED,
			SDL_WINDOWPOS_CENTERED,
			m_width,
			m_height,
			SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI );

		if ( !m_window )
			throw std::runtime_error( SDL_GetError() );

		m_glContext = SDL_GL_CreateContext( m_window );
		if ( !m_glContext )
			throw std::runtime_error( SDL_GetError() );

		SDL_GL_MakeCurrent( m_window, m_glContext );

		if ( gl3wInit() )
			throw std::runtime_error( "gl3wInit() failed" );

		if ( !gl3wIsSupported( 4, 5 ) )
			throw std::runtime_error( "OpenGL version not supported" );

#ifndef NDEBUG
		glEnable( GL_DEBUG_OUTPUT );
		glDebugMessageCallback( debugMessageCallback, NULL );
#endif // NDEBUG

		if ( !IMGUI_CHECKVERSION() )
		{
			throw std::runtime_error( "IMGUI_CHECKVERSION() failed" );
		}

		ImGui::CreateContext();

		// Setup controls.
		ImGuiIO & io = ImGui::GetIO();
		io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;

		// Style.
		ImGui::StyleColorsDark();
		ImGui::GetStyle().WindowRounding	= 0.f;
		ImGui::GetStyle().ChildRounding		= 0.f;
		ImGui::GetStyle().FrameRounding		= 0.f;
		ImGui::GetStyle().GrabRounding		= 0.f;
		ImGui::GetStyle().PopupRounding		= 0.f;
		ImGui::GetStyle().ScrollbarRounding = 0.f;
		ImGui::GetStyle().WindowBorderSize	= 0.f;
		ImGui::GetStyle().WindowPadding		= ImVec2( 0.f, 0.f );

		// Setup Platform/Renderer bindings.
		if ( ImGui_ImplSDL2_InitForOpenGL( m_window, m_glContext ) == false )
			throw std::runtime_error( "ImGui_ImplSDL2_InitForOpenGL failed" );

		if ( ImGui_ImplOpenGL3_Init( "#version 450" ) == false )
			throw std::runtime_error( "ImGui_ImplOpenGL3_Init failed" );

		SDL_GL_SetSwapInterval(0);
		m_renderer = Renderer( this );

		m_configuration.width		 = m_width;
		m_configuration.height		 = m_height;
		m_configuration.maxIteration = 16;
		m_configuration.zoom		 = 1.f;
	}

	Window::Window( Window && other )
	{
		std::swap( m_width, other.m_width );
		std::swap( m_height, other.m_height );
		std::swap( m_window, other.m_window );
		std::swap( m_glContext, other.m_glContext );
		std::swap( m_displayMode, other.m_displayMode );
		std::swap( m_renderer, other.m_renderer );
		std::swap( m_configuration, other.m_configuration );
	}

	Window & Window::operator=( Window && other )
	{
		std::swap( m_width, other.m_width );
		std::swap( m_height, other.m_height );
		std::swap( m_window, other.m_window );
		std::swap( m_glContext, other.m_glContext );
		std::swap( m_displayMode, other.m_displayMode );
		std::swap( m_renderer, other.m_renderer );
		std::swap( m_configuration, other.m_configuration );

		return *this;
	}

	Window::~Window()
	{
		ImGui_ImplOpenGL3_Shutdown();
		ImGui_ImplSDL2_Shutdown();

		if ( ImGui::GetCurrentContext() != nullptr )
		{
			ImGui::DestroyContext();
		}

		if ( m_glContext )
			SDL_GL_DeleteContext( m_glContext );

		if ( m_window )
			SDL_DestroyWindow( m_window );

		SDL_Quit();
	}

	bool Window::update()
	{
		ImGuiIO & io = ImGui::GetIO();

		bool	  running = true;
		SDL_Event windowEvent;
		while ( SDL_PollEvent( &windowEvent ) )
		{
			ImGui_ImplSDL2_ProcessEvent( &windowEvent );
			switch ( windowEvent.type )
			{
			case SDL_QUIT: running = false; break;
			case SDL_WINDOWEVENT:
				if ( windowEvent.window.event == SDL_WINDOWEVENT_SIZE_CHANGED )
				{
					m_width				   = windowEvent.window.data1;
					m_height			   = windowEvent.window.data2;
					m_configuration.width  = m_width;
					m_configuration.height = m_height;
					m_renderer.resize( m_width, m_height );
				}
				break;
			case SDL_MOUSEWHEEL:
				m_configuration.zoom += windowEvent.wheel.x / 100.f;
				m_configuration.zoom -= windowEvent.wheel.y / 100.f;
				break;
			}
		}

		const bool leftButtonDown = io.MouseDown[ 0 ];
		if ( leftButtonDown )
		{
			m_configuration.shiftX += io.MouseDelta.x / ( m_configuration.zoom * 100.f );
			m_configuration.shiftY += io.MouseDelta.y / ( m_configuration.zoom * 100.f );
		}

		// New frame.
		ImGui_ImplOpenGL3_NewFrame();
		ImGui_ImplSDL2_NewFrame( m_window );
		ImGui::NewFrame();

		// Configuration.
		const ImGuiViewport * viewport = ImGui::GetMainViewport();
		ImGui::SetNextWindowPos( viewport->Pos );
		ImGui::SetNextWindowSize( viewport->Size );
		ImGui::SetNextWindowBgAlpha( 0.0f );
		constexpr ImGuiWindowFlags windowFlags = ImGuiWindowFlags_MenuBar | ImGuiWindowFlags_NoTitleBar
												 | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize
												 | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoBringToFrontOnFocus
												 | ImGuiWindowFlags_NoNavFocus;

		bool isVisible = true;
		if ( ImGui::Begin( "Mandelbrot Renderer", &isVisible, windowFlags ) == false )
		{
			ImGui::End();
			return running;
		}

		if ( ImGui::BeginMainMenuBar() )
		{
			if ( ImGui::Button( "Reset" ) )
			{
				m_configuration				 = MandelbrotConfiguration {};
				m_configuration.width		 = m_width;
				m_configuration.height		 = m_height;
				m_configuration.maxIteration = 16;
				m_configuration.zoom		 = 1.f;
			}

			ImGui::PushItemWidth( 100 );
			int maxIteration = m_configuration.maxIteration;
			if ( ImGui::InputInt( "Max iteration", &maxIteration, 10 ) )
				m_configuration.maxIteration = maxIteration;

			ImGui::Checkbox( "Compute on the GPU", &m_gpuCompute );

			const ImGuiIO & io = ImGui::GetIO();
			ImGui::Text( "FPS: %.0f", io.Framerate );

			ImGui::EndMainMenuBar();
		}
		ImGui::End();
		ImGui::Render();

		SDL_GL_MakeCurrent( m_window, m_glContext );
		m_renderer.draw( m_configuration, m_gpuCompute );

		ImGui_ImplOpenGL3_RenderDrawData( ImGui::GetDrawData() );
		SDL_GL_SwapWindow( m_window );

		return running;
	}
} // namespace mdbr
