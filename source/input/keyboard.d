module input.keyboard;

import std.stdio;
import bindbc.glfw;
import std.conv: to;
import window.window;

// Automate keyboard input across the entire board
// Do this when not half awake
//bool[int] keyboardInput;

bool left = false;
bool right = false;
bool forward = false;
bool back = false;

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
        default:{
            writeln("YOU HIT THE WRONG BUTTON");
        }
    }
}