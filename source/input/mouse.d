module input.mouse;

import vector_2d;
import std.stdio;

private Vector2d oldPosition = Vector2d(0,0);
private Vector2d position    = Vector2d(0,0);
private Vector2d vector      = Vector2d(0,0);

void mouseCallback(Vector2d newPosition) {
    writeln("mouse is at: ", newPosition);
    vector = Vector2d(
        oldPosition.x - newPosition.x,
        oldPosition.y - newPosition.y
    );
    writeln("the mouse vector is: ", vector);
    position = newPosition;
}