module input.mouse;

import vector_2d;
import std.stdio;

void mouseCallback(Vector2d newPosition) {
    writeln("mouse is at: ", newPosition);
}