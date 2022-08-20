module camera.camera;

import std.stdio;
import window.window;
import math;
import matrix_4d;

// There can only be one camera in the game, this is it

immutable double FOV = toRadians(60.0);

immutable double Z_NEAR = 0.00000;

immutable double Z_FAR = 10_000.;


Matrix4d projectionMatrix = Matrix4d();

double aspectRatio = 0;

void updateCamera() {
    aspectRatio = getAspectRatio();
    writeln("aspect ratio is: ", aspectRatio);
    projectionMatrix = Matrix4d().perspective(FOV, aspectRatio, Z_NEAR, Z_FAR);
}

Matrix4d getProjectionMatrix () {
    return projectionMatrix;
}