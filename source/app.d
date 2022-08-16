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

    float[] vertices = [
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f,
        0.0f,   0.5f, 0.0f
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
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    glDisable(GL_CULL_FACE);

    // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
    // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
    glBindVertexArray(0); 

    writeln("INITIAL LOADED GL VERSION: ", getInitialOpenGLVersion());
    writeln("FORWARD COMPATIBILITY VERSION: ", to!string(glGetString(GL_VERSION)));

    while(!gameWindowShouldClose()) {        

        gameClearWindow();

        // Rendering goes here
        glUseProgram(getShaderProgram("main"));
        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);

        gameSwapBuffers();

        glfwPollEvents();
    }

    deleteShaders();
    gameDestroyWindow();
    
}
