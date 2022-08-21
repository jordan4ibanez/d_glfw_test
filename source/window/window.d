module window.window;

import std.stdio;
import bindbc.glfw;
import bindbc.opengl;
import vector_2i;
import vector_4d;
import vector_3d;
import glfw_interface.keyboard_input;

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
    // This is the best hack ever
    try {
    keyCallback(window,key,scancode,action,mods);
    } catch(Exception){}
}

// Stores and gives context to the C window
void setWindowPointer(GLFWwindow* newWindow) {
    window = newWindow;    

    glfwGetWindowSize(window,&size.x, &size.y);

    //writeln(tst);

    glfwMakeContextCurrent(window);

    glfwSetFramebufferSizeCallback(window, &myframeBufferSizeCallback);

    glfwSetKeyCallback(window, &externalKeyCallBack);
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