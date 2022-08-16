module helper.structures;

import bindbc.opengl;

// Holds RGBA opengl data
struct RGBA {
    GLclampf r = 0;
    GLclampf b = 0;
    GLclampf g = 0;
    GLclampf a = 0;
    this(float r, float g, float b, float a) {
        this.r = r;
        this.b = b;
        this.g = g;
        this.a = a;
    }
}

struct Vector2I {
    int x = 0;
    int y = 0;
    this(int x, int y){
        this.x = x;
        this.y = y;
    }
}