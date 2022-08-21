module window.window;

import std.stdio;
import bindbc.glfw;
import bindbc.opengl;
import vector_2i;
import vector_4d;
import vector_3d;

// Starts off as a null pointer
GLFWwindow* window;
Vector2i size;

nothrow
static extern(C) void myframeBufferSizeCallback(GLFWwindow* theWindow, int x, int y) {
    size.x = x;
    size.y = y;
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

Vector2i getWindowSize() {
    return size;
}

void gameDestroyWindow() {
    glfwDestroyWindow(window);
}

double getAspectRatio() {
    return cast(double)size.x / cast(double)size.y;
}