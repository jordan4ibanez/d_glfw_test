module window.window;

import std.stdio;
import bindbc.glfw;
import bindbc.opengl;
import vector_2i;
import vector_2d;
import vector_4d;
import vector_3d;
import input.keyboard;
import loader = bindbc.loader.sharedlib;
import helper.log;
import input.mouse;

// Starts off as a null pointer
GLFWwindow* window;
Vector2i size;

nothrow
static extern(C) void myframeBufferSizeCallback(GLFWwindow* theWindow, int x, int y) {
    size.x = x;
    size.y = y;
    glViewport(0,0,x,y);
}
nothrow
static extern(C) void externalKeyCallBack(GLFWwindow* window, int key, int scancode, int action, int mods){
    // This is the best hack ever, or the worst
    try {
    keyCallback(key,scancode,action,mods);
    } catch(Exception){}
}

nothrow
static extern(C) void externalcursorPositionCallback(GLFWwindow* window, double xpos, double ypos) {
    try {
        mouseCallback(Vector2d(xpos, ypos));
    } catch(Exception){}
}

// Internally handles interfacing to C
bool gameWindowShouldClose() {
    return glfwWindowShouldClose(window) != 0;
}

void gameSwapBuffers() {
    glfwSwapBuffers(window);
}

Vector2i getWindowSize() {
    return size;
}

void gameDestroyWindow() {
    glfwDestroyWindow(window);
}

double getAspectRatio() {
    return cast(double)size.x / cast(double)size.y;
}

void closeWindow() {
    glfwSetWindowShouldClose(window, true);
}

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

    // Minimum version is 4.1 (July 26, 2010)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    // Allow driver optimizations
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);

    // Nice 720p window, why not?
    window = glfwCreateWindow(1280, 720, name.ptr, null, null);

    // Something even scarier fails to load
    if (!window) {
        writeln("WINDOW FAILED TO OPEN!\n",
        "ABORTING!");
        glfwTerminate();
        return true;
    }

    glfwGetWindowSize(window,&size.x, &size.y);

    glfwMakeContextCurrent(window);

    glfwSetFramebufferSizeCallback(window, &myframeBufferSizeCallback);

    glfwSetKeyCallback(window, &externalKeyCallBack);

    glfwSetCursorPosCallback(window, &externalcursorPositionCallback);

    // No error :)
    return false;
}

void glfwLockMouse() {
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
}

void glfwUnlockMouse() {
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
}