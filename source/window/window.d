module window.window;

import std.stdio;
import bindbc.glfw;

// Starts off as a null pointer
GLFWwindow* window;


// Stores and gives context to the C window
void setWindowPointer(GLFWwindow* newWindow) {
    window = newWindow;

    glfwMakeContextCurrent(window);
}

// Internally handles interfacing to C
bool gameWindowShouldClose() {
    return glfwWindowShouldClose(window) != 0;
}