module mesh.mesh;

import std.stdio;
import bindbc.opengl;
import bindbc.glfw;
import mesh.texture;
import opengl.shaders;
import vector_3d;

import Camera = camera.camera;

private immutable bool debugNow = false;

struct Mesh {

    private bool exists = false;

    GLuint vao = 0; // Vertex array object - Main object
    GLuint pbo = 0; // Positions vertex buffer object
    GLuint tbo = 0; // Texture positions vertex buffer object
    GLuint ibo = 0; // Indices vertex buffer object
    GLuint cbo = 0; // Colors vertex buffer object
    GLuint indexCount = 0;
    
    // Holds the texture id
    GLuint textureID = 0;

    this(float[] vertices, int[] indices, float[] textureCoordinates, float[] colors, string textureName) {

        this.textureID = getTexture(textureName);

        // Existence lock
        this.exists = true;

        // Don't bother if not divisible by 3 (x,y,z)
        assert(indices.length % 3 == 0 && indices.length >= 3);
        this.indexCount = cast(GLuint)(indices.length);

        // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
        glGenVertexArrays(1, &this.vao);
        glBindVertexArray(this.vao);
    

        // Positions VBO

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

        // Colors VBO

        glGenBuffers(1, &this.cbo);
        glBindBuffer(GL_ARRAY_BUFFER, this.cbo);

        glBufferData(
            GL_ARRAY_BUFFER,
            colors.length * float.sizeof,
            colors.ptr,
            GL_STATIC_DRAW
        );

        glVertexAttribPointer(
            2,
            3,
            GL_FLOAT,
            GL_FALSE,
            0,
            cast(const(void)*)0
        );
        glEnableVertexAttribArray(2); 


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
        
        // Unbind vao just in case
        glBindVertexArray(0);

        GLuint glErrorInfo = glGetError();

        if (glErrorInfo != 0) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN A MESH CONSTRUCTOR");
            writeln("FREEZING PROGRAM TO ALLOW DIAGNOSTICS!");

            while(true) {
                
            }
        }

        if (debugNow) {
            writeln("Mesh ", this.vao, " has been successfully created");
        }       
    }

    void cleanUp() {

        // Don't bother the gpu with garbage data
        if (!this.exists) {
            if (debugNow) {
                writeln("sorry, I cannot clear gpu memory, I don't exist in gpu memory");
            }
            return;
        }
        
        // Delete the positions vbo
        glDeleteBuffers(1, &this.pbo);

        assert (glIsBuffer(this.pbo) == GL_FALSE);
    
        // Delete the texture coordinates vbo
        glDeleteBuffers(1, &this.tbo);

        assert (glIsBuffer(this.tbo) == GL_FALSE);

        // Delete the colors vbo
        glDeleteBuffers(1, &this.cbo);

        assert (glIsBuffer(this.cbo) == GL_FALSE);

        // Delete the indices vbo
        glDeleteBuffers(1, &this.ibo);

        assert (glIsBuffer(this.ibo) == GL_FALSE);

        // Delete the vao
        glDeleteVertexArrays(1, &this.vao);

        assert(glIsVertexArray(this.vao) == GL_FALSE);

        

        GLenum glErrorInfo = glGetError();

        if (glErrorInfo != 0) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN A MESH DESTRUCTOR");
            writeln("FREEZING PROGRAM TO ALLOW DIAGNOSTICS!");

            while(true) {
                
            }
        }

        if (debugNow) {
            writeln("Mesh ", this.vao, " has been successfully deleted from gpu memory");
        }
    }

    void render(Vector3d offset, Vector3d rotation, float scale, float light) {

        // Don't bother the gpu with garbage data
        if (!this.exists) {
            if (debugNow) {
                writeln("sorry, I cannot render, I don't exist in gpu memory");
            }
            return;
        }

        getShader("main").setUniformI("textureSampler", 0);
        getShader("main").setUniformF("light", light);

        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, this.textureID);

        Camera.setObjectMatrix(offset, rotation, scale);

        glBindVertexArray(this.vao);
        // glDrawArrays(GL_TRIANGLES, 0, this.indexCount);
        glDrawElements(GL_TRIANGLES, this.indexCount, GL_UNSIGNED_INT, cast(const(void)*)0);
        
        GLuint glErrorInfo = glGetError();

        if (glErrorInfo != 0) {
            writeln("GL ERROR: ", glErrorInfo);
            writeln("ERROR IN A MESH RENDER");
            writeln("FREEZING PROGRAM TO ALLOW DIAGNOSTICS!");

            while(true) {
                
            }
        }
        if (debugNow) {
            writeln("Mesh ", this.vao, " has rendered successfully ");
        }
    }
}