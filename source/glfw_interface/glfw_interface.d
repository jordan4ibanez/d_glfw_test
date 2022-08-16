module glfw_interface.glfw_interface;

import bindbc.glfw;
import bindbc.opengl;
import std.stdio;
import loader = bindbc.loader.sharedlib;
import window.window;
import helper.log;

// Returns true if there was an error
private bool gameLoadGLFW() {

    GLFWSupport returnedError;
    
    version(Windows) {
        returnedError = loadGLFW("libs/glfw3.dll");
    } else {
        // Linux,FreeBSD, OpenBSD, macOSX, haiku, etc
        returnedError = loadGLFW();
    }

    if(returnedError != glfwSupport) {
        writeln("ERROR IN glfw_interface.d");
        writeln("---------- DIRECT DEBUG ERROR ---------------");
        // Log the direct error info
        foreach(info; loader.errors) {
            logCError(info.error, info.message);
        }
        writeln("---------------------------------------------");
        writeln("------------ FUZZY SUGGESTION ---------------");
        // Log fuzzy error info with suggestion
        if(returnedError == GLFWSupport.noLibrary) {
            writeln("The GLFW shared library failed to load!\n",
            "Is GLFW installed correctly?\n\n",
            "ABORTING!");
        }
        else if(GLFWSupport.badLibrary) {
            writeln("One or more symbols failed to load.\n",
            "The likely cause is that the shared library is for a lower\n",
            "version than bindbc-glfw was configured to load (via GLFW_31, GLFW_32 etc.\n\n",
            "ABORTING!");
        }
        writeln("-------------------------");
        return true;
    }

    return false;
}


bool gameInitializeGLFWComponents(string name) {

    // Something fails to load
    if (gameLoadGLFW()) {
        return true;
    }

    // Something scary fails to load
    if (!glfwInit()) {
        return true;
    }

    // Minimum version is 3.2 (August 3 2009)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    // Allow driver optimizations
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);

    // Nice 720p window, why not?
    GLFWwindow* window = glfwCreateWindow(1280, 720, name.ptr, null, null);


    // Something even scarier fails to load
    if (!window) {
        writeln("WINDOW FAILED TO OPEN!\n",
        "ABORTING!");
        glfwTerminate();
        return true;
    }

    // Pass the window pointer to the game, it makes the context current
    setWindowPointer(window);

    // No error :)
    return false;
}