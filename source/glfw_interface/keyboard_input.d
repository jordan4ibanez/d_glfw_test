module glfw_interface.keyboard_input;

import std.stdio;
import bindbc.glfw;

void keyCallback(GLFWwindow* window, int key, int scancode, int action, int mods){
    if (key == GLFW_KEY_E && action == GLFW_PRESS){
        writeln("fasdkljfasd");
    }

}