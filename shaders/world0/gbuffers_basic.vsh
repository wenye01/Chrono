#version 330 compatibility

out vec2 lmcoord;
out vec4 glcolor;

void main()
{
    gl_Position = ftransform();
    // lmcoord = vec2(0.f, 0.f);
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color; // 选中方框颜色，与line合并了
}