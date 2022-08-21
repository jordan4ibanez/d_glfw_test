module opengl.shaders;

import bindbc.opengl;
import std.stdio;

private GameShader[string] container;

struct GameShader {
    string name;
    uint vertexShader = 0;
    uint fragmentShader = 0;
    uint shaderProgram = 0;

    uint[string] uniforms;

    void createUniform(string uniformName) {
        GLint location = glGetUniformLocation(this.shaderProgram, uniformName.dup.ptr);
        writeln("uniform ", uniformName, " is at id ", location);
        // Do not allow out of bounds
        assert(location >= 0);
        uniforms[uniformName] = location;
    }

    uint getUniform(string uniformName) {
        return uniforms[uniformName];
    }

    this(string name, uint vertexShader, uint fragmentShader, uint shaderProgram) {
        this.name = name;
        this.vertexShader = vertexShader;
        this.fragmentShader = fragmentShader;
        this.shaderProgram = shaderProgram;
    }
}

GameShader getShaderProgram(string name){
    return container[name];
}

// Automates shader compilation
private uint compileShader(string name, string sourceCode, uint shaderType) { 

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
        string infoName = "?Other Shader?";
        if (shaderType == GL_VERTEX_SHADER) {
            infoName = "GL Vertex Shader";
        } else if (shaderType == GL_FRAGMENT_SHADER) {
            infoName = "GL Fragment Shader";
        }

        writeln("ERROR IN SHADER ", name, " ", infoName);

        glGetShaderInfoLog(shader, 512, null, infoLog.ptr);
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


void createGLShaderProgram(string shaderName, string vertexShaderCode, string fragmentShaderCode) {

    uint vertexShader = compileShader(shaderName, vertexShaderCode, GL_VERTEX_SHADER);
    uint fragmentShader = compileShader(shaderName, fragmentShaderCode, GL_FRAGMENT_SHADER);

    uint shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);

    glLinkProgram(shaderProgram);

    int success;
    // Default value is SPACE instead of garbage
    char[512] infoLog = (' ');
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);

    if (!success) {
        glGetProgramInfoLog(shaderProgram, 512, null, infoLog.ptr);
        writeln(infoLog);

        writeln("FREEZING PROGRAM TO ALLOW DIAGNOSTICS!");

        while(true) {
            
        }
    }

    writeln("GL Shader Program with ID ", shaderProgram, " successfully linked!");

    GameShader thisShader = GameShader(shaderName,vertexShader,fragmentShader, shaderProgram);
    container[shaderName] = thisShader;
}

void deleteShaders() {
    foreach (GameShader thisShader; container) {

        // Detach shaders from program
        glDetachShader(thisShader.shaderProgram, thisShader.vertexShader);
        glDetachShader(thisShader.shaderProgram, thisShader.fragmentShader);

        // Delete shaders
        glDeleteShader(thisShader.vertexShader);
        glDeleteShader(thisShader.fragmentShader);

        // Delete the program
        glDeleteProgram(thisShader.shaderProgram);

        writeln("deleted: ", thisShader.name);

        // Remove the program from game memory
        container.remove(thisShader.name);
    }
}