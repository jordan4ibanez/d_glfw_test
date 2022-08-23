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

import Math = math;
import loader = bindbc.loader.sharedlib;
import Camera = camera.camera;
import Window = window.window;
import opengl.shaders;

void main() {

    if (Window.initializeGLFWComponents("Crafter Engine 0.0.0")) {
        return;
    }

    // GL init is purely functional
    if(initializeOpenGL()) {
        return;
    }  
    
    string vertexShaderCode = "
    #version 410 core

    layout (location = 0) in vec3 position;
    layout (location = 1) in vec2 textureCoordinate;
    layout (location = 2) in vec3 color;

    out vec2 outputTextureCoordinate;
    out vec3 outputColor;

    uniform mat4 cameraMatrix;
    uniform mat4 objectMatrix;

    void main()
    {
        gl_Position = cameraMatrix * objectMatrix * vec4(position, 1.0);
        outputTextureCoordinate = textureCoordinate;
        outputColor = color;
    }";

    string fragmentShaderCode = "
    #version 410 core

    in vec2 outputTextureCoordinate;
    in vec3 outputColor;
    out vec4 fragColor;

    uniform sampler2D textureSampler;
    uniform float light;

    void main()
    {
        fragColor = texture(textureSampler, outputTextureCoordinate) * vec4(outputColor, 1.0) * light;
    }";

    createShaderProgram(
        "main",
        vertexShaderCode,
        fragmentShaderCode,
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

    float scaler = 0.0;
    bool up = true;    

    setMaxDeltaFPS(10);

    float rave = 0;
    bool raveUp = true;

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

        if (raveUp) {
            rave += delta / 2.0;
            if (rave > 1) {
                rave = 1.0;
                raveUp = false;
            }
        } else {
            rave -= delta / 2.0;
            if (rave < 0) {
                rave = 0.0;
                raveUp = true;
            }
        }

        if (up) {
            scaler += delta * 100;
            if (scaler > 45) {
                up = false;
            }
        } else {
            scaler -= delta * 100;
            if (scaler < -45) {
                up = true;
            }
        }

        double videoColor = Math.abs(rave - 1);

        Camera.setClearColor(videoColor,videoColor,videoColor);

        // writeln("scaler: ", scaler);

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
        for (int i = 0; i < 100; i++){
            thisMesh.render(Vector3d(i,0,i),Vector3d(0,0,0), rave, rave);
        }

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
