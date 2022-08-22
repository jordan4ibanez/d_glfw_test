module camera.camera;

import std.stdio;
import matrix_4d;
import vector_3d;
import bindbc.opengl;
import vector_3d;
import delta_time;

import Keyboard = input.keyboard;
import Window = window.window;
import Math = math;
import opengl.shaders;

// There can only be one camera in the game, this is it

private double FOV = Math.toRadians(60.0);

// Never set this to 0 :P
private immutable double Z_NEAR = 0.00001;
private immutable double Z_FAR = 10_000.0;

private Vector3d clearColor = Vector3d(0,0,0);

private Matrix4d cameraMatrix = Matrix4d();
private Matrix4d objectMatrix = Matrix4d();

private Vector3d position = Vector3d(0,0,1);
private Vector3d rotation = Vector3d(0,0,0); 

private double aspectRatio = 0;

void updateAspectRatio() {
    aspectRatio = Window.getAspectRatio();
    // writeln("aspect ratio is: ", aspectRatio);
    cameraMatrix = Matrix4d().identity().perspective(FOV, aspectRatio, Z_NEAR, Z_FAR);
}

Matrix4d getCameraMatrix() {
    return cameraMatrix;
}

Matrix4d getObjectMatrix(Vector3d offset, Vector3d rotation, float scale) {

    // This is an extreme hack for testing remove this garbage
    Vector3d modifier = Vector3d(0,0,0);

    if(Keyboard.getForward()){
        modifier.z -= getDelta() * 10;
    } else if (Keyboard.getBack()) {
        modifier.z += getDelta() * 10;
    }

    if(Keyboard.getLeft()){
        modifier.x += getDelta() * 10;
    } else if (Keyboard.getRight()) {
        modifier.x -= getDelta() * 10;
    }

    movePosition(modifier);

    objectMatrix.identity().translate(offset).
        rotateX(Math.toRadians(rotation.x)).
        rotateY(Math.toRadians(rotation.y)).
        rotateZ(Math.toRadians(rotation.z)).
        scale(scale);
    return objectMatrix;
}

void updateCameraMatrix() {
    GameShader mainShader = getShader("main");
    Matrix4d stackWorkerMatrix = getCameraMatrix()
        .translate(-position.x, -position.y, -position.z)
        .rotate(rotation.x, 0,1,0)
        .rotate(rotation.y, 1,0,0);
    float[16] floatBuffer = stackWorkerMatrix.getFloatArray();
    glUniformMatrix4fv(mainShader.getUniform("cameraMatrix"),1, GL_FALSE, floatBuffer.ptr);
}

void clear() {
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

void movePosition(Vector3d positionModification) {
    position.x += positionModification.x;
    position.y += positionModification.y;
    position.z += positionModification.z;
}

void setPosition(Vector3d newCameraPosition){
    position = newCameraPosition;
}


void rotationLimiter(){
    // Pitch limiter
    if (rotation.x > 90) {
        rotation.x = 90;
    } else if (rotation.x < -90) {
        rotation.x = -90;
    }
    // Yaw overflower
    if (rotation.y > 180) {
        rotation.y -= 180.0;
    } else if (rotation.y < -180) {
        rotation.y += 180.0;
    }
}

void moveRotation(Vector3d rotationModification) {
    rotation.x += rotationModification.x;
    rotation.y += rotationModification.y;
    rotation.z += rotationModification.z;
    rotationLimiter();
}

void setRotation(Vector3d newRotation) {
    rotation = newRotation;
    rotationLimiter();
}