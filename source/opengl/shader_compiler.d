module opengl.shader_compiler;

import bindbc.opengl;
import std.stdio;

// Automates shader compilation
uint compileShader(string sourceCode, uint shaderType) { 

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