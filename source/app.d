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

void main() {


    if (gameInitializeGLFWComponents("blah")) {
        return;
    }

    if(gameInitializeOpenGL()) {
        return;
    }

    float[] vertices = [
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        0.0f,  0.5f, 0.0f
    ];
    uint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, cast(long)vertices.length, vertices.ptr, GL_STATIC_DRAW);
    
    string vertexShaderCode = "
    #version 330 core
    layout (location = 0) in vec3 aPos;

    void main()
    {
        gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    }";

    string fragmentShaderCode = "
    #version 330 core
    out vec4 FragColor;

    void main()
    {
        FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
    }";

    createGLShaderProgram("main", vertexShaderCode, fragmentShaderCode);


    writeln("INITIAL LOADED GL VERSION: ", getInitialOpenGLVersion());
    writeln("FORWARD COMPATIBILITY VERSION: ", to!string(glGetString(GL_VERSION)));

    while(!gameWindowShouldClose()) {

        gameClearWindow();

        // Rendering goes here

        gameSwapBuffers();

        glfwPollEvents();
    }

    deleteShaders();
    gameDestroyWindow();
    
}
