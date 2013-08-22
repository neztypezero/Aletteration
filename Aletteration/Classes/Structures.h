#ifndef STRUCTURES_H_FILE
#define STRUCTURES_H_FILE

#define LINE_Z 0.0f

#define NEZ_MATH_PI 3.141592653589793
#define RADIANS_60_DEGREES (NEZ_MATH_PI/3.0)
#define RADIANS_90_DEGREES (NEZ_MATH_PI/2.0)
#define RADIANS_180_DEGREES NEZ_MATH_PI
#define RADIANS_PER_DEGREE (180.0/NEZ_MATH_PI)

#define ADDR_OFFSET(b, a) ((const void*)((unsigned int)a-(unsigned int)b))

#define MATRIX_PALETTE_COUNT 36
#define MAX_BLEND_COUNT 4

typedef struct vec2 {
	float x, y;
} vec2;

typedef struct vec3 {
	float x, y, z;
} vec3;

typedef struct orientation3 {
	vec3 forward;
	vec3 up;
} orientation3;

typedef struct size3 {
	float w, h, d;
} size3;

typedef struct vec4 {
	float x, y, z, w;
} vec4;

typedef struct color4uc {
	unsigned char r, g, b, a;
} color4uc;

typedef struct color3f {
	float r, g, b;
} color3f;

typedef struct color4f {
	float r, g, b, a;
} color4f;

typedef struct rect4f {
	float x, y, w, h;
} rect4f;

typedef struct union4 {
	vec4 v4;
	color4f c4;
	vec3 v3;
	vec2 v2;
} union4;

typedef struct mat3 {
	vec3 x, y, z;
} mat3;

typedef struct mat4 {
	vec4 x, y, z, w;
} mat4;

typedef struct mat43rm {
	float xx, yx, zx, wx;
	float xy, yy, zy, wy;
	float xz, yz, zz, wz;
} mat43rm;

typedef struct TextureInfo {
	unsigned int name;
	unsigned int width;
	unsigned int height;
	unsigned int level;
} TextureInfo;

typedef struct Vertex2D {
	vec2 pos;
	vec2 uv;
} Vertex2D;

#define ENABLE_BIT_POS (1)
#define ENABLE_BIT_UV (2)
#define ENABLE_BIT_NORMAL (4)
#define ENABLE_BIT_INDEXARRAY (8)

typedef struct Vertex {
	vec3 pos;
	vec2 uv;
	vec3 normal;
	unsigned char indexArray[MAX_BLEND_COUNT];
} Vertex;

typedef struct VertexOffset {
	const void *pos;
	const void *uv;
	const void *normal;
	const void *indexArray;
} VertexOffset;

typedef struct VertexPC {
	vec3 pos;
	color4uc color;
} VertexPC;

typedef struct NezRange {
	int firstIndex;
	int indexCount;
} NezRange;

static vec2 ZERO2 = {0,0};
static vec3 ZERO3 = {0,0,0};
static vec4 ZERO4 = {0,0,0,0};

static size3 SIZE3ZERO = {0,0,0};

static inline vec2 getZero2() {
    return ZERO2;
}

static inline vec3 getZero3() {
    return ZERO3;
}

static inline vec4 getZero4() {
    return ZERO4;
}

static inline size3 getZeroSize3() {
    return SIZE3ZERO;
}

#endif