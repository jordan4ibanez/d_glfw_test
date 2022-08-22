module input.keyboard;

import std.stdio;
import bindbc.glfw;
import std.conv: to;
import window.window;
import input.mouse;

// Automate keyboard input across the entire board
// Do this when not half awake
//bool[int] keyboardInput;

private bool left = false;
private bool right = false;
private bool forward = false;
private bool back = false;

bool quickSwitch(int input) {
    return input > 0;
}

void keyCallback(int key, int scancode, int action, int mods){
    //keyboardInput[key] = action > 0;
    switch(key) {
        case GLFW_KEY_D:{
            left = quickSwitch(action);
            break;
        }
        case GLFW_KEY_A:{
            right = quickSwitch(action);
            break;
        }
        case GLFW_KEY_W:{
            forward = quickSwitch(action);
            break;
        }
        case GLFW_KEY_S: {
            back = quickSwitch(action);
            break;
        }
        case GLFW_KEY_ESCAPE: {
            closeWindow();
            break;
        }
        case GLFW_KEY_LEFT_SHIFT: {
            if (action == GLFW_PRESS) {
                debugLockMouse();
            }
            break;
        }
        default:{
            writeln("YOU HIT THE WRONG BUTTON");
        }
    }
}

bool getLeft() {
    return left;
}
bool getRight() {
    return right;
}
bool getForward() {
    return forward;
}
bool getBack() {
    return back;
}