module window.window;

import std.stdio;
import bindbc.glfw;
import bindbc.opengl;
import helper.structures;

// Starts off as a null pointer
GLFWwindow* window;
Vector2I size;

nothrow
static extern(C) void myframeBufferSizeCallback(GLFWwindow* theWindow, int x, int y) {
    glViewport(0,0,x,y);
}

// Stores and gives context to the C window
void setWindowPointer(GLFWwindow* newWindow) {
    window = newWindow;    

    glfwGetWindowSize(window,&size.x, &size.y);

    //writeln(tst);

    glfwMakeContextCurrent(window);

    glfwSetFramebufferSizeCallback(window, &myframeBufferSizeCallback);
}

// Internally handles interfacing to C
bool gameWindowShouldClose() {
    return glfwWindowShouldClose(window) != 0;
}

void gameSwapBuffers() {
    glfwSwapBuffers(window);
}

Vector2I getWindowSize() {
    return size;
}


void gameClearWindow() {

    RGBA color = RGBA(0,0,0,0);

    glClearColor(
        color.r,
        color.b,
        color.g,
        color.a
    );

    glClear(GL_COLOR_BUFFER_BIT);    
}

void gameDestroyWindow() {
    glfwDestroyWindow(window);
}