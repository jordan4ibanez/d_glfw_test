module input.mouse;

import std.stdio;
import vector_2d;
import vector_3d;

import Window = window.window;
import Camera = camera.camera;

private Vector2d oldPosition = Vector2d(0,0);
private Vector2d position    = Vector2d(0,0);
private Vector2d vector      = Vector2d(0,0);

private double sensitivity   = 0.001;

private bool locked = false;

void mouseCallback(Vector2d newPosition) {
    writeln("mouse is at: ", newPosition);
    writeln("the mouse vector is: ", vector);

    if (locked) {
        vector = Vector2d(
            newPosition.x,
            newPosition.y
        );
        Camera.moveRotation(Vector3d(
            vector.x * sensitivity,
            vector.y * sensitivity,
            0
        ));

        Window.setMousePosition(0,0);
    }

    position = newPosition;
    oldPosition = newPosition;
}

void lockMouse(bool newLockMode) {
    if (newLockMode) {
        if (!locked) {
            Window.lockMouse();
            locked = true;
        } // Don't send out another callback to C
    } else {
        if (locked) {
            Window.unlockMouse();
            locked = false;
        } // Don't send out another callback to C
    }
}

// this is debug, remove this
void debugLockMouse() {
    bool newLockMode = !locked;
    if (newLockMode) {
        if (!locked) {
            Window.lockMouse();
            locked = true;
        } // Don't send out another callback to C
    } else {
        if (locked) {
            Window.unlockMouse();
            locked = false;
        } // Don't send out another callback to C
    }
}