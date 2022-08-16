module opengl.shaders;

import bindbc.opengl;
import std.stdio;

private uint mainShaderProgram;

uint getMainShaderProgram(){
    return mainShaderProgram;
}

// Automates shader compilation
private uint compileShader(string sourceCode, uint shaderType) { 

    uint shader;
    shader = glCreateShader(shaderType);

    char* shaderCodePointer = sourceCode.dup.ptr;
    const(char*)* shaderCodeConstantPointer = &shaderCodePointer;
    glShaderSource(shader, 1, shaderCodeConstantPointer, null);
    glCompileShader(shader);

    int success;
    // Default value is SPACE instead of garbage
    char[512] infoLog = (' ');
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);

    // Log info in terminal, freeze the program to prevent erroneous behavior
    if (!success) {
        int sizeOfInfoLog = cast(int)infoLog.sizeof;
        glGetShaderInfoLog(shader, 512, &sizeOfInfoLog, infoLog.ptr);
        writeln(infoLog);

        writeln("FREEZING PROGRAM TO ALLOW DIAGNOSTICS!");

        while(true) {
            
        }
    }

    // Match the correct debug info name
    string infoName = "?Other Shader?";
    if (shaderType == GL_VERTEX_SHADER) {
        infoName = "GL Vertex Shader";
    } else if (shaderType == GL_FRAGMENT_SHADER) {
        infoName = "GL Fragment Shader";
    }

    writeln("Successfully compiled ", infoName, " with ID: ", shader);

    return shader;
}


uint createGLShaderProgram(string vertexShaderCode, string fragmentShaderCode) {

    uint vertexShader = compileShader(vertexShaderCode, GL_VERTEX_SHADER);
    uint fragmentShader = compileShader(fragmentShaderCode, GL_FRAGMENT_SHADER);

    uint shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);

    glLinkProgram(shaderProgram);

    int success;
    // Default value is SPACE instead of garbage
    char[512] infoLog = (' ');
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);

    if (!success) {
        int sizeOfInfoLog = cast(int)infoLog.sizeof;
        glGetProgramInfoLog(shaderProgram, 512, &sizeOfInfoLog, infoLog.ptr);
        writeln(infoLog);

        writeln("FREEZING PROGRAM TO ALLOW DIAGNOSTICS!");

        while(true) {
            
        }
    }

    writeln("GL Shader Program with ID ", shaderProgram, " successfully linked!");

    writeln("REMEMBER TO MAKE THIS FUNCTION VOID!! ~~~~~~~~~~~~~~~~~~~");

    return shaderProgram;
}