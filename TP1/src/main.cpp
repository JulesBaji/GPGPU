#include "mdbr/renderer.hpp"
#include "mdbr/window.hpp"
#include <exception>
#include <iostream>

int main( int /* argc */, char ** /* argv */ )
{
	try
	{
		mdbr::Window window { 1280u, 720u };
		while ( window.update() ) {}
	}
	catch ( const std::exception & e )
	{
		std::cerr << e.what() << std::endl;
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}
