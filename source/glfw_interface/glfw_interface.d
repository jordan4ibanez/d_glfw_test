module glfw_interface.glfw_interface;

import bindbc.glfw;
import std.stdio;
import loader = bindbc.loader.sharedlib;
import std.conv;
import window.window;

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
        writeln("---------- DIRECT DEBUG ERROR ---------------");
        // Log the direct error info
        foreach(info; loader.errors) {
            string error = to!string(info.error);
            string message = to!string(info.message);
            writeln("(ERROR LOADING): ", error, "\n(DEBUG INFO): ", message);
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


bool gameInitializeGLFWComponents() {

    // Something fails to load
    if (gameLoadGLFW()) {
        return true;
    }

    // Something scary fails to load
    if (!glfwInit()) {
        return true;
    }

    // Nice 720p window, why not?
    GLFWwindow* window = glfwCreateWindow(1280, 720, "blah", null, null);

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