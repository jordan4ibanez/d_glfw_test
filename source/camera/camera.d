module camera.camera;

import std.stdio;
import window.window;
import math;
import matrix_4d;
import vector_3d;
import Math = math;
import bindbc.opengl;
import opengl.shaders;

// There can only be one camera in the game, this is it

immutable double FOV = toRadians(60.0);

immutable double Z_NEAR = 0.00000;

immutable double Z_FAR = 10_000.;


Matrix4d projectionMatrix = Matrix4d();
Matrix4d worldMatrix = Matrix4d();

double aspectRatio = 0;

void updateCamera() {
    aspectRatio = getAspectRatio();
    writeln("aspect ratio is: ", aspectRatio);
    projectionMatrix = Matrix4d().identity().perspective(FOV, aspectRatio, Z_NEAR, Z_FAR);
}

Matrix4d getProjectionMatrix () {
    return projectionMatrix;
}

Matrix4d getWorldMatrix(Vector3d offset, Vector3d rotation, float scale) {
    worldMatrix.identity().translate(offset).
        rotateX(Math.toRadians(rotation.x)).
        rotateY(Math.toRadians(rotation.y)).
        rotateZ(Math.toRadians(rotation.z)).
        scale(scale);
    return worldMatrix;
}

void updateCameraProjectionMatrix() {
    GameShader bloop = getShader("main");
    Matrix4d test = getProjectionMatrix();
    float[16] floatBuffer = test.getFloatArray();
    glUniformMatrix4fv(bloop.getUniform("projectionMatrix"),1, GL_FALSE, floatBuffer.ptr);
}