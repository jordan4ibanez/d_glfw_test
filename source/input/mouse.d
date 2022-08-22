module input.mouse;

import vector_2d;
import std.stdio;

Vector2d position = Vector2d(0,0);

void mouseCallback(Vector2d newPosition) {
    writeln("mouse is at: ", newPosition);
    position = newPosition;
}