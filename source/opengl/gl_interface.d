module opengl.gl_interface;

import std.stdio;
import bindbc.glfw;
import loader = bindbc.loader.sharedlib;
import bindbc.opengl;
import helper.structures;
import helper.log;
import window.window;

bool gameInitializeOpenGL() {
    /*
     Compare the return value of loadGL with the global `glSupport` constant to determine if the version of GLFW
     configured at compile time is the version that was loaded.
    */
    GLSupport ret = loadOpenGL();

    // Minimum version is GL 3.3 (March 11, 2010)
    if(ret < GLSupport.gl33) {
        writeln("ERROR IN gl_interface.d");
        // Log the error info
        foreach(info; loader.errors) {
            /*
             A hypothetical logging function. Note that `info.error` and `info.message` are `const(char)*`, not
             `string`.
            */
            logCError(info.error, info.message);
        }

        // Optionally construct a user-friendly error message for the user
        string msg;
        if(ret == GLSupport.noLibrary) {
            msg = "This application requires the GLFW library.";
        }
        else if(ret == GLSupport.badLibrary) {
            msg = "The version of the GLFW library on your system is too low. Please upgrade.";
        }
        // GLSupport.noContext
        else {
            msg = "This program has encountered a graphics configuration error. Please report it to the developers.";
        }
        // A hypothetical message box function
        writeln(msg);
        return true;
    }

    bool test = isOpenGLLoaded();

    if (!test) {
        writeln("GL FAILED TO LOAD!!");
        return true;
    }

    Vector2I windowSize = getWindowSize();

    glViewport(0, 0, windowSize.x, windowSize.y);

    return false;
}