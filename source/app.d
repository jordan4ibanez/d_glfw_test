import std.stdio;

import bindbc.glfw;
import bindbc.opengl;
import helper.log;
import opengl.gl_interface;
import std.string: toStringz;
import std.conv: to;
import delta_time;
import matrix_4d;
import std.conv: to;
import vector_3d;
import mesh.mesh;
import mesh.texture;
import OpenAL = openal.al_interface;

import Math = math;
import loader = bindbc.loader.sharedlib;
import Camera = camera.camera;
import Window = window.window;
import opengl.shaders;

void main() {

    // Window acts as a static class handler for GLFW & game window
    if (Window.initializeGLFWComponents("Crafter Engine 0.0.0")) {
        return;
    }

    // GL init is purely functional
    if(initializeOpenGL()) {
        return;
    }

    // OpenAL acts like a static class handler for all of OpenAL Soft
    if (OpenAL.initializeOpenAL()){
        return;
    }

    bool testMe = true;

    if (testMe) {
        return;
    }
    

    createShaderProgram(
        "main",
        "shaders/vertex.vs",
        "shaders/fragment.fs",
        [
            "cameraMatrix",
            "objectMatrix",
            "textureSampler",
            "light"
        ]
    );   

    newTexture("textures/debug.png");

    float[] vertices = [
        -0.5f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
         0.5f, -0.5f, 0.0f,
         0.5f,  0.5f, 0.0f,
    ];
    int[] indices = [
        0, 1, 3, 3, 1, 2,
    ];
    float[] textureCoordinates = [
        0, 0,
        0, 1,
        1, 1,
        1, 0
    ];
    // Very fancy
    float[] colors = [
        0.5f, 0.0f, 0.0f,
        0.0f, 0.5f, 0.0f,
        0.0f, 0.0f, 0.5f,
        0.0f, 0.5f, 0.5f,
    ];

    writeln("INITIAL LOADED GL VERSION: ", getInitialOpenGLVersion());
    writeln("FORWARD COMPATIBILITY VERSION: ", to!string(glGetString(GL_VERSION)));

    glfwSwapInterval(1);

    double clock = 0.0;

    int fpsCounter = 1;

    setMaxDeltaFPS(10);

    // An "alive" mesh
    // Mesh thisMesh = Mesh(vertices, indices, textureCoordinates);

    GLenum glErrorInfo = 0;

    Mesh thisMesh = Mesh(vertices, indices, textureCoordinates, colors, "textures/debug.png");

    while(!Window.shouldClose()) {

        // Game load simulation
        /*
        int q = 0;
        for (int i = 0; i < 1_000_000; i++) {
            q += q + 1 * 2;
        }
        */

        calculateDelta();

        double delta = getDelta();

        Camera.setClearColor(1,1,1);

        clock += delta;

        fpsCounter++;

        if (clock >= 1) {
            // writeln("FPS: ", fpsCounter);
            clock = 0;
            fpsCounter = 0;
        }

        Camera.clear();        

        Camera.clearDepthBuffer();

        // Rendering goes here
        glUseProgram(getShader("main").shaderProgram);

        Camera.testCameraHackRemoveThis();

        // This is only to be called ONCE, unless switching to ortholinear view
        Camera.updateCameraMatrix();

        // Finally the mesh will be rendered, GLSL will automatically
        // Move the fragments into the correct position based on the matrices
        thisMesh.render(Vector3d(0,0,0),Vector3d(0,0,0), 1, 1);
        

        Window.swapBuffers();

        glErrorInfo = glGetError();


        if (glErrorInfo != 0) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN MAIN LOOP");
            writeln("FREEZING PROGRAM TO ALLOW DIAGNOSTICS!");

            while(true) {
                
            }
        }

        glfwPollEvents();
    }

    deleteShaders();
    Window.destroy();
    
}
