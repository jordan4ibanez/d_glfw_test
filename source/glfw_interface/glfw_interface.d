module glfw_interface.glfw_interface;

import bindbc.glfw;
import std.stdio;
import loader = bindbc.loader.sharedlib;
import std.conv;

// Returns true if there was an error
bool gameLoadGLFW() {

    GLFWSupport returnedError;
    
    version(Windows) {
        returnedError = loadGLFW("libs/glfw3.dll");
    } else {
        // Linux,FreeBSD, OpenBSD, macOSX, haiku, etc
        returnedError = loadGLFW("flool");
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