module window.window;

import std.stdio;
import bindbc.glfw;
import bindbc.opengl;
import vector_2i;
import vector_2d;
import vector_4d;
import vector_3d;
import helper.log;

import Keyboard = input.keyboard;
import loader = bindbc.loader.sharedlib;
import Mouse = input.mouse;

// Starts off as a null pointer
private GLFWwindow* window;
private Vector2i size;

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
    Keyboard.keyCallback(key,scancode,action,mods);
    } catch(Exception){}
}

nothrow
static extern(C) void externalcursorPositionCallback(GLFWwindow* window, double xpos, double ypos) {
    try {
        Mouse.mouseCallback(Vector2d(xpos, ypos));
    } catch(Exception){}
}

// Internally handles interfacing to C
bool shouldClose() {
    return glfwWindowShouldClose(window) != 0;
}

void swapBuffers() {
    glfwSwapBuffers(window);
}

Vector2i getSize() {
    return size;
}

void destroy() {
    glfwDestroyWindow(window);
}

double getAspectRatio() {
    return cast(double)size.x / cast(double)size.y;
}

void close() {
    glfwSetWindowShouldClose(window, true);
}

// Returns true if there was an error
private bool startGLFW() {

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


bool initializeGLFWComponents(string name) {

    // Something fails to load
    if (startGLFW()) {
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

    // Using 3.3 regardless so enable
    glfwSetInputMode(window, GLFW_RAW_MOUSE_MOTION, GLFW_TRUE);

    // No error :)
    return false;
}

void lockMouse() {
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
}

void unlockMouse() {
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
}

void setMousePosition(double x, double y) {
    glfwSetCursorPos(window, x, y);
}