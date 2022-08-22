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
import image;

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

    glfwSwapInterval(2);

    double clock = 0.0;

    int fpsCounter = 1;

    float scaler = 0.0;
    bool up = true;    

    setMaxDeltaFPS(10);


    // Test of images
    TrueColorImage myCoolImage = loadImageFromFile("textures/debug.png").getAsTrueColorImage();
    ubyte[] myCoolImageData = myCoolImage.imageData.bytes;

    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);    
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, myCoolImage.width(), myCoolImage.height(), 0, GL_RGBA, GL_UNSIGNED_BYTE, myCoolImageData.ptr);

        // Enable texture clamping to edge
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
    // Border color is nothing
    float[4] borderColor = [0,0,0,0];
    glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor.ptr);

    // Add in nearest neighbor texture filtering
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST/*_MIPMAP_NEAREST*/);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    // glGenerateMipmap(GL_TEXTURE_2D);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureID); 

    GLenum glErrorInfo = glGetError();

    if (glErrorInfo != 0) {
        writeln("GL ERROR: ", glErrorInfo);
        writeln("ERROR IN TEXTURE");
        writeln("FREEZING PROGRAM TO ALLOW DIAGNOSTICS!");

        while(true) {
                
        }
    }

    // An "alive" mesh
    // Mesh thisMesh = Mesh(vertices, indices, textureCoordinates);
    

    while(!gameWindowShouldClose()) {

        // Game load simulation
        int q = 0;
        for (int i = 0; i < 1_000_000; i++) {
            q += q + 1 * 2;
        }

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


        getShader("main").setUniform("textureSampler", 0);

        // An "alive" mesh
        Mesh thisMesh = Mesh(vertices, indices, textureCoordinates);
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
