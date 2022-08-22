module mesh.mesh;

import std.stdio;
import bindbc.opengl;
import bindbc.glfw;

immutable bool debugNow = true;

struct Mesh {

    private bool exists = false;

    GLuint vao = 0; // Vertex array object - Main object
    GLuint pbo = 0; // Positions vertex buffer object
    GLuint tbo = 0; // Texture positions vertex buffer object
    GLuint ibo = 0; // Indices vertex buffer object
    // GLuint cbo = 0; // Colors vertex buffer object
    GLuint texture = 0;
    GLuint indexCount = 0;

    this(float[] vertices, int[] indices, float[] textureCoordinates) {

        if (debugNow) {
            writeln("I'M ALIVE, I'M BORN");
        }

        // Existence lock
        this.exists = true;

        // Don't bother if not divisible by 3 (x,y,z)
        assert(indices.length % 3 == 0 && indices.length >= 3);
        this.indexCount = cast(GLuint)(indices.length);

        // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
        glGenVertexArrays(1, &this.vao);
        glBindVertexArray(this.vao);
    

        // Positions VBO - Colors will use a similar VBO 

        glGenBuffers(1, &this.pbo);
        glBindBuffer(GL_ARRAY_BUFFER, this.pbo);

        glBufferData(
            GL_ARRAY_BUFFER,                // Target object
            vertices.length * float.sizeof, // How big the object is
            vertices.ptr,                   // The pointer to the data for the object
            GL_STATIC_DRAW                  // Which draw mode OpenGL will use
        );

        glVertexAttribPointer(
            0,           // Attribute 0 (matches the attribute in the glsl shader)
            3,           // Size (literal like 3 points)  
            GL_FLOAT,    // Type
            GL_FALSE,    // Normalized?
            0,           // Stride
            cast(void*)0 // Array buffer offset
        );
        glEnableVertexAttribArray(0);


        // Texture coordinates VBO
        glGenBuffers(1, &this.tbo);
        glBindBuffer(GL_ARRAY_BUFFER, this.tbo);

        glBufferData(
            GL_ARRAY_BUFFER,
            textureCoordinates.length * float.sizeof,
            textureCoordinates.ptr,
            GL_STATIC_DRAW
        );

        glVertexAttribPointer(
            1,
            2,
            GL_FLOAT,
            GL_FALSE,
            0,
            cast(const(void)*)0
        );
        glEnableVertexAttribArray(1); 


        // Indices VBO

        glGenBuffers(1, &this.ibo);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, this.ibo);

        glBufferData(
            GL_ELEMENT_ARRAY_BUFFER,     // Target object
            indices.length * int.sizeof, // size (bytes)
            indices.ptr,                 // the pointer to the data for the object
            GL_STATIC_DRAW               // The draw mode OpenGL will use
        );


        glBindBuffer(GL_ARRAY_BUFFER, 0);        
        // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
        // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
        glBindVertexArray(0);

        GLuint glErrorInfo = glGetError();

        if (glErrorInfo != 0) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN A MESH CONSTRUCTOR");
            writeln("FREEZING PROGRAM TO ALLOW DIAGNOSTICS!");

            while(true) {
                
            }
        }        
    }

    // Automatically clean up the mesh
    ~this() {

        // Don't bother the gpu with garbage data
        if (!this.exists) {
            if (debugNow) {
                writeln("sorry, I cannot clear gpu memory, I don't exist in gpu memory");
            }
            return;
        }

        // Might not need to bind here
        // It does not create a GL error though
        glBindVertexArray(this.vao);

        glDisableVertexAttribArray(0);

        // Delete the positions vbo
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &this.pbo);

        // Delete the texture coordinates vbo
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &this.tbo);

        // Delete the indices vbo
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &this.ibo);

        // Delete the vao
        glBindVertexArray(0);
        glDeleteVertexArrays(1, &this.vao);
        

        GLenum glErrorInfo = glGetError();

        if (glErrorInfo != 0) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN A MESH DESTRUCTOR");
            writeln("FREEZING PROGRAM TO ALLOW DIAGNOSTICS!");

            while(true) {
                
            }
        }

        if (debugNow) {
            writeln("OKAY I WAS DELETED SUCCESSFULLY");
        }
    }

    void render() {

        // Don't bother the gpu with garbage data
        if (!this.exists) {
            if (debugNow) {
                writeln("sorry, I cannot render, I don't exist in gpu memory");
            }
            return;
        }

        glBindVertexArray(this.vao);
        // glDrawArrays(GL_TRIANGLES, 0, this.indexCount);
        glDrawElements(GL_TRIANGLES, this.indexCount, GL_UNSIGNED_INT, cast(const(void)*)0);

        GLuint glErrorInfo = glGetError();

        if (glErrorInfo != 0) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN A MESH CONSTRUCTOR");
            writeln("FREEZING PROGRAM TO ALLOW DIAGNOSTICS!");

            while(true) {
                
            }
        }
        if (debugNow) {
            writeln("AYO I RENDERED RIGHT");
        }
    }
}

// A duplicate function that inverses the call in case
// it's ever easier to render it like that for some reason
void renderMesh(Mesh thisMesh) {
    thisMesh.render();
}