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

    void main()
    {
        gl_Position = projectionMatrix * vec4(position, 1.0);
    }";

    string fragmentShaderCode = "
    #version 410 core
    out vec4 FragColor;

    void main()
    {
        FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
    }";

    createGLShaderProgram("main", vertexShaderCode, fragmentShaderCode);
    
    GameShader main = getShaderProgram("main");

    main.createUniform("projectionMatrix");

    float[] vertices = [
        -0.5f, -0.5f, -1.5f,
        0.5f,  -0.5f, -1.5f,
        0.0f,   0.5f, -1.5f
    ];    

    uint VBO, VAO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices.ptr, GL_STATIC_DRAW);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * float.sizeof, cast(void*)0);
    glEnableVertexAttribArray(0);

    // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
    glBindBuffer(GL_ARRAY_BUFFER, 1);

    glDisable(GL_CULL_FACE);

    // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
    // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
    glBindVertexArray(0); 

    writeln("INITIAL LOADED GL VERSION: ", getInitialOpenGLVersion());
    writeln("FORWARD COMPATIBILITY VERSION: ", to!string(glGetString(GL_VERSION)));

    glfwSwapInterval(0);

    double clock = 0.0;

    int fpsCounter = 1;

    while(!gameWindowShouldClose()) {

        Matrix4d test = getProjectionMatrix();
        glUniformMatrix4dv(main.getUniform("projectionMatrix"),1,false,cast(const(double)*)&test);

        // updateCamera();

        calculateDelta();

        clock += getDelta();

        fpsCounter++;

        if (clock >= 1) {
            // writeln("FPS: ", fpsCounter);
            clock = 0;
            fpsCounter = 0;
        }


        gameClearWindow();

        // Rendering goes here
        glUseProgram(getShaderProgram("main").shaderProgram);
        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);

        gameSwapBuffers();

        glfwPollEvents();
    }

    deleteShaders();
    gameDestroyWindow();
    
}
