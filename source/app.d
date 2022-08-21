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

    uniform mat4 projectionMatrix;
    uniform mat4 worldMatrix;

    void main()
    {
        gl_Position = projectionMatrix * worldMatrix * vec4(position, 1.0);
    }";

    string fragmentShaderCode = "
    #version 410 core

    out vec4 FragColor;

    void main()
    {
        FragColor = vec4(1.0, 0.5, 0.2, 1.0);
    }";

    createGLShaderProgram(
        "main",
        vertexShaderCode,
        fragmentShaderCode,
        [
            "projectionMatrix",
            "worldMatrix"
        ]
    );

    float[] vertices = [
        -0.5f,  0.5f, -0.0f,
        -0.5f, -0.5f, -0.0f,
         0.5f,  0.5f, -0.0f,
         0.5f,  0.5f, -0.0f,
        -0.5f, -0.5f, -0.0f,
         0.5f, -0.5f, -0.0f,
    ];

    Mesh testMesh = Mesh(vertices);

    writeln("INITIAL LOADED GL VERSION: ", getInitialOpenGLVersion());
    writeln("FORWARD COMPATIBILITY VERSION: ", to!string(glGetString(GL_VERSION)));

    glfwSwapInterval(1);

    double clock = 0.0;

    int fpsCounter = 1;

    float scaler = 0.0;
    bool up = true;

    while(!gameWindowShouldClose()) {

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

        updateCameraProjectionMatrix();

        Matrix4d test2 = getWorldMatrix(Vector3d(0,0,-1),Vector3d(0,scaler,0), 1.0);
        float[16] floatBuffer2 = test2.getFloatArray();
        // writeln(floatBuffer2);

        glUniformMatrix4fv(getShader("main").getUniform("worldMatrix"),1, GL_FALSE, floatBuffer2.ptr);

        GLenum glErrorInfo = glGetError();


        if (glErrorInfo != 0) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN SHADER ", "main");
            writeln("FREEZING PROGRAM TO ALLOW DIAGNOSTICS!");

            while(false) {
                
            }
        }

        
        testMesh.render();

        gameSwapBuffers();

        glfwPollEvents();
    }

    deleteShaders();
    gameDestroyWindow();
    
}
