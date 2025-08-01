   myshader      MatrixP                                                                                MatrixV                                                                                MatrixW                                                                                exampleVertexShader.vs�  uniform mat4 MatrixP;
uniform mat4 MatrixV;
uniform mat4 MatrixW;
attribute vec4 POS2D_UV;

varying float vPositionY; // 传递顶点的 Y 坐标

void main() {
    vec3 POSITION = vec3(POS2D_UV.xy, 0);
    float samplerIndex = floor(POS2D_UV.z / 2.0);
    vec3 TEXCOORD0 = vec3(POS2D_UV.z - 2.0 * samplerIndex, POS2D_UV.w, samplerIndex);

    mat4 mtxPVW = MatrixP * MatrixV * MatrixW;
    gl_Position = mtxPVW * vec4(POSITION.xyz, 1.0);

    vPositionY = POSITION.y; // 传递 Y 坐标
}    examplePixelShader.ps�  #ifdef GL_ES
precision mediump float;
#endif

uniform vec4 TIMEPARAMS;
varying float vPositionY; // 接收顶点的 Y 坐标

vec3 colorA = vec3(0, 0, 0);
vec3 colorB = vec3(1, 0, 0);

void main() {
    vec3 color = vec3(0.0);

    // 判断是否在上半部分
    if (vPositionY > 0.0) { // 假设 Y = 0 是实体的中线
        color = colorB;
    } else { // 下半部分
        color = colorA;
    }

    gl_FragColor = vec4(color, 1);
}                  