module mesh.texture;

struct Texture {
    bool exists = false;
    int textureIndex = 0;
    int width = 0;
    int height = 0;

    this(int textureIndex, int width, int height) {
        this.exists = true;
        this.textureIndex = textureIndex;
        this.width = width;
        this.height = height;
    }
}