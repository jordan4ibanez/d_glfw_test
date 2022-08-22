module input.mouse;

import vector_2d;
import std.stdio;

import Window = window.window;

private Vector2d oldPosition = Vector2d(0,0);
private Vector2d position    = Vector2d(0,0);
private Vector2d vector      = Vector2d(0,0);

private bool locked = false;

void mouseCallback(Vector2d newPosition) {
    writeln("mouse is at: ", newPosition);
    vector = Vector2d(
        newPosition.x - oldPosition.x,
        oldPosition.y - newPosition.y
    );
    writeln("the mouse vector is: ", vector);
    position = newPosition;
    oldPosition = newPosition;
}

void lockMouse(bool newLockMode) {
    if (newLockMode) {
        if (!locked) {
            Window.glfwLockMouse();
            locked = true;
        } // Don't send out another callback to C
    } else {
        if (locked) {
            Window.glfwUnlockMouse();
            locked = false;
        } // Don't send out another callback to C
    }
}

// this is debug, remove this
void debugLockMouse() {
    bool newLockMode = !locked;
    if (newLockMode) {
        if (!locked) {
            Window.glfwLockMouse();
            locked = true;
        } // Don't send out another callback to C
    } else {
        if (locked) {
            Window.glfwUnlockMouse();
            locked = false;
        } // Don't send out another callback to C
    }
}