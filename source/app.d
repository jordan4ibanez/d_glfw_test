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

    createGLShaderProgram("main", vertexShaderCode, fragmentShaderCode);
    
    GameShader main = getShaderProgram("main");

    main.createUniform("projectionMatrix");
    main.createUniform("worldMatrix");

    float[] vertices = [
        -0.5f,  0.5f, -0.0f,
        -0.5f, -0.5f, -0.0f,
         0.5f,  0.5f, -0.0f,
         0.5f,  0.5f, -0.0f,
        -0.5f, -0.5f, -0.0f,
         0.5f, -0.5f, -0.0f,
    ];  

    uint VBO, VAO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices.ptr, GL_STATIC_DRAW);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, cast(void*)0);
    glEnableVertexAttribArray(0);

    // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
    glBindBuffer(GL_ARRAY_BUFFER, 1);

    glDisable(GL_CULL_FACE);

    // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
    // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
    glBindVertexArray(0); 

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
            if (scaler > 90) {
                up = false;
            }
        } else {
            scaler -= delta * 100;
            if (scaler < -90) {
                up = true;
            }
        }

        writeln("scaler: ", scaler);

        clock += delta;

        fpsCounter++;

        if (clock >= 1) {
            // writeln("FPS: ", fpsCounter);
            clock = 0;
            fpsCounter = 0;
        }
        gameClearWindow();

        // Rendering goes here
        glUseProgram(getShaderProgram("main").shaderProgram);

        Matrix4d test = getProjectionMatrix();
        float[16] floatBuffer = test.getFloatArray();
        glUniformMatrix4fv(main.getUniform("projectionMatrix"),1, GL_FALSE, floatBuffer.ptr);


        Matrix4d test2 = getWorldMatrix(Vector3d(0,0,-1),Vector3d(0,scaler,0), 1.0);
        float[16] floatBuffer2 = test2.getFloatArray();
        writeln(floatBuffer2);
        glUniformMatrix4fv(main.getUniform("worldMatrix"),1, GL_FALSE, floatBuffer2.ptr);

        GLenum glErrorInfo = glGetError();


        if (glErrorInfo != 0) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN SHADER ", main.name);
            writeln("FREEZING PROGRAM TO ALLOW DIAGNOSTICS!");

            while(false) {
                
            }
        }

        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 7);

        gameSwapBuffers();

        glfwPollEvents();
    }

    deleteShaders();
    gameDestroyWindow();
    
}
