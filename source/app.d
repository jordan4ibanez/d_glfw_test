import std.stdio;

import bindbc.glfw;
import bindbc.opengl;
import glfw_interface.glfw_interface;
import window.window;
import loader = bindbc.loader.sharedlib;
import helper.log;
import opengl.gl_interface;

void main() {


    if (gameInitializeGLFWComponents("blah")) {
        return;
    }

    if(gameInitializeOpenGL()) {
        return;
    }

    while(!gameWindowShouldClose()) {

        writeln(loadedOpenGLVersion());

        gameClearWindow();

        // Rendering goes here

        gameSwapBuffers();

        glfwPollEvents();
    }

    gameDestroyWindow();
    
}
