module camera.camera;

import std.stdio;
import window.window;
import math;
import matrix_4d;
import vector_3d;
import Math = math;
import bindbc.opengl;
import opengl.shaders;
import vector_3d;
import glfw_interface.keyboard_input;
import delta_time;

// There can only be one camera in the game, this is it


double FOV = toRadians(60.0);

// Never set this to 0 :P
immutable double Z_NEAR = 0.00001;

immutable double Z_FAR = 10_000.;

Vector3d clearColor = Vector3d(0,0,0);

Matrix4d cameraMatrix = Matrix4d();
Matrix4d objectMatrix = Matrix4d();

Vector3d position = Vector3d(0,0,1);
Vector3d rotation = Vector3d(0,0,0);

double aspectRatio = 0;

void updateCamera() {
    aspectRatio = getAspectRatio();
    // writeln("aspect ratio is: ", aspectRatio);
    cameraMatrix = Matrix4d().identity().perspective(FOV, aspectRatio, Z_NEAR, Z_FAR);
}

Matrix4d getcameraMatrix () {
    return cameraMatrix;
}

Matrix4d getObjectMatrix(Vector3d offset, Vector3d rotation, float scale) {

    // This is an extreme hack for testing remove this garbage
    Vector3d modifier = Vector3d(0,0,0);

    if(forward){
        modifier.z -= getDelta() * 10;
    } else if (back) {
        modifier.z += getDelta() * 10;
    }

    if(left){
        modifier.x += getDelta() * 10;
    } else if (right) {
        modifier.x -= getDelta() * 10;
    }

    moveCameraPosition(modifier);

    objectMatrix.identity().translate(offset).
        rotateX(Math.toRadians(rotation.x)).
        rotateY(Math.toRadians(rotation.y)).
        rotateZ(Math.toRadians(rotation.z)).
        scale(scale);
    return objectMatrix;
}

void updateCameraMatrix() {
    // writeln("blah");
    GameShader bloop = getShader("main");
    Matrix4d test = getcameraMatrix().translate(-position.x, -position.y, -position.z);
    float[16] floatBuffer = test.getFloatArray();
    glUniformMatrix4fv(bloop.getUniform("cameraMatrix"),1, GL_FALSE, floatBuffer.ptr);
}

void gameClearWindow() {
    glClearColor(clearColor.x,clearColor.y,clearColor.z,1);
    glClear(GL_COLOR_BUFFER_BIT);
}

void setClearColor(double r, double g, double b) {
    clearColor = Vector3d(r,g,b);
}

void setFOV(double newFOV) {
    FOV = newFOV;
}

double getFOV() {
    return FOV;
}

void moveCameraPosition(Vector3d positionModification) {
    position.x += positionModification.x;
    position.y += positionModification.y;
    position.z += positionModification.z;
}

void setCameraPosition(Vector3d newCameraPosition){
    position = newCameraPosition;
}