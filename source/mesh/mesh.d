module mesh.mesh;

import std.stdio;
import bindbc.opengl;

struct Mesh {
    private bool exists = false;
    GLuint vao = 0;
    GLuint vbo = 0;
    GLuint ebo = 0;
    GLuint texture = 0;
    GLuint vertexCount = 0;

    this(float[] vertices) {

        // Existence lock
        this.exists = true;

        // Don't bother if not divisible by 3 (x,y,z)
        assert(vertices.length % 3 == 0 && vertices.length >= 3);
        this.vertexCount = cast(GLuint)(vertices.length / 3);


        glGenVertexArrays(1, &this.vao);
        glGenBuffers(1, &this.vbo);
        // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
        glBindVertexArray(this.vao);

        glBindBuffer(GL_ARRAY_BUFFER, this.vbo);
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

        // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
        glBindBuffer(GL_ARRAY_BUFFER, 1);

        // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
        // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
        glBindVertexArray(0);
    }

    void render() {
        glBindVertexArray(this.vao);
        glDrawArrays(GL_TRIANGLES, 0, this.vertexCount);
        writeln("REMEMBER TO ADD A DESTRUCTOR CLEAN UP!");
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