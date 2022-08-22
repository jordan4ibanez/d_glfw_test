import std.stdio;

import bindbc.glfw;
import bindbc.opengl;
import glfw_interface.glfw_interface;
import window.window;
import loader = bindbc.loader.sharedlib;
import helper.log;
import opengl.gl_interface;
import std.string: toStringz;
import std.conv: to;
import opengl.shaders;
import delta_time;
import camera.camera;
import matrix_4d;
import std.conv: to;
import vector_3d;
import Math = math;
import mesh.mesh;
import mesh.texture;

void main() {

    if (gameInitializeGLFWComponents("blah")) {
        return;
    }

    if(gameInitializeOpenGL()) {
        return;
    }  
    
    string vertexShaderCode = "
    #version 410 core

    layout (location = 0) in vec3 position;
    layout (location = 1) in vec2 textureCoordinate;

    out vec2 outputTextureCoordinate;

    uniform mat4 cameraMatrix;
    uniform mat4 objectMatrix;

    void main()
    {
        gl_Position = cameraMatrix * objectMatrix * vec4(position, 1.0);
        outputTextureCoordinate = textureCoordinate;
    }";

    string fragmentShaderCode = "
    #version 410 core

    in vec2 outputTextureCoordinate;
    out vec4 fragColor;

    uniform sampler2D textureSampler;

    void main()
    {
        fragColor = texture(textureSampler, outputTextureCoordinate);
    }";

    createGLShaderProgram(
        "main",
        vertexShaderCode,
        fragmentShaderCode,
        [
            "cameraMatrix",
            "objectMatrix",
            "textureSampler"
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

    writeln("INITIAL LOADED GL VERSION: ", getInitialOpenGLVersion());
    writeln("FORWARD COMPATIBILITY VERSION: ", to!string(glGetString(GL_VERSION)));

    glfwSwapInterval(1);

    double clock = 0.0;

    int fpsCounter = 1;

    float scaler = 0.0;
    bool up = true;    

    setMaxDeltaFPS(10);

    // An "alive" mesh
    // Mesh thisMesh = Mesh(vertices, indices, textureCoordinates);

    GLenum glErrorInfo = 0;

    while(!gameWindowShouldClose()) {

        // Game load simulation
        /*
        int q = 0;
        for (int i = 0; i < 1_000_000; i++) {
            q += q + 1 * 2;
        }
        */

        updateCamera();

        calculateDelta();

        double delta = getDelta();

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

        // writeln("scaler: ", scaler);

        clock += delta;

        fpsCounter++;

        if (clock >= 1) {
            // writeln("FPS: ", fpsCounter);
            clock = 0;
            fpsCounter = 0;
        }
        gameClearWindow();        

        // It is extremely important to clear the buffer bit!
        glClear(GL_DEPTH_BUFFER_BIT);

        // Rendering goes here
        glUseProgram(getShader("main").shaderProgram);

        updateCameraMatrix();

        Matrix4d test2 = getObjectMatrix(Vector3d(0,0,-1),Vector3d(0,scaler,0), 1.0);
        float[16] floatBuffer2 = test2.getFloatArray();
        // writeln(floatBuffer2);

        glUniformMatrix4fv(getShader("main").getUniform("objectMatrix"),1, GL_FALSE, floatBuffer2.ptr);

        // An "alive" mesh
        Mesh thisMesh = Mesh(vertices, indices, textureCoordinates, "textures/debug.png");
        thisMesh.render();

        // A "dead" mesh
        // Mesh ghostMesh = Mesh();
        // ghostMesh.render();

        gameSwapBuffers();

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
    gameDestroyWindow();
    
}
