module mesh.mesh;

struct Mesh {
    bool exists = false;
    int vao = 0;
    int vbo = 0;
    int ebo = 0;
    int vertexCount = 0;
    int texture = 0;

    this(int vao, int vbo, int ebo, int vertexCount, int texture){
        this.exists = true;
        this.vao = vao;
        this.vbo = vbo;
        this.ebo = ebo;
        this.vertexCount = vertexCount;
        this.texture = texture;
    }
}