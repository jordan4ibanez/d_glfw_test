module mesh.mesh;

import std.stdio;
import bindbc.opengl;
import bindbc.glfw;

struct Mesh {

    private bool exists = false;

    GLuint vao = 0; // Vertex array object - Main object
    GLuint pbo = 0; // Positions vertex buffer object
    GLuint ibo = 0; // Indices vertex buffer object
    GLuint cbo = 0; // Colors vertex buffer object
    GLuint texture = 0;
    GLuint vertexCount = 0;

    this(float[] vertices, int[] indices) {

        writeln("I'M ALIVE, I'M BORN");

        // Existence lock
        this.exists = true;

        // Don't bother if not divisible by 3 (x,y,z)
        assert(indices.length % 3 == 0 && indices.length >= 3);
        this.vertexCount = cast(GLuint)(indices.length);

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


        // Indices VBO

        glGenBuffers(1, &this.ibo);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, this.ibo);

        glBufferData(
            GL_ELEMENT_ARRAY_BUFFER,     // Target object
            indices.length * int.sizeof, // size (bytes)
            indices.ptr,                 // the pointer to the data for the object
            GL_STATIC_DRAW               // The draw mode OpenGL will use
        );

        GLuint glErrorInfo = glGetError();

        if (glErrorInfo != 0) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN A MESH CONSTRUCTOR");
            writeln("FREEZING PROGRAM TO ALLOW DIAGNOSTICS!");

            while(true) {
                
            }
        }


        glBindBuffer(GL_ARRAY_BUFFER, 0);
        // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
        // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
        glBindVertexArray(0);

        
    }

    // Automatically clean up the mesh
    ~this() {

        // Don't bother the gpu with garbage data
        if (!this.exists) {
            writeln("sorry, I cannot clear gpu memory, I don't exist in gpu memory");
            return;
        }

        glDisableVertexAttribArray(0);

        // Delete the positions vbo
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &this.pbo);

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

        writeln("OKAY I WAS DELETED SUCCESSFULLY");
    }

    void render() {

        // Don't bother the gpu with garbage data
        if (!this.exists) {
            writeln("sorry, I cannot render, I don't exist in gpu memory");
            return;
        }

        glBindVertexArray(this.vao);
        // glDrawArrays(GL_TRIANGLES, 0, this.vertexCount);
        glDrawElements(GL_TRIANGLES, this.vertexCount, GL_UNSIGNED_INT, cast(const(void)*)0);
    }
    /*
    void appendGLData(int vao, int vbo, int ebo, int vertexCount, int texture){
        this.exists = true;
        this.vao = vao;
        this.vbo = vbo;
        this.ebo = ebo;
        this.vertexCount = vertexCount;
        this.texture = texture;
    }
    */
}

// A duplicate function that inverses the call in case
// it's ever easier to render it like that for some reason
void renderMesh(Mesh thisMesh) {
    thisMesh.render();
}