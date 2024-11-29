#version 330 compatibility

// 后处理阶段进行
// out vec2 texcoord;
// out vec4 glcolor;

// void main()
// {
//     gl_Position = ftransform();
//     texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
//     glcolor = gl_Color;
// }

void main()
{
    gl_Position = vec4(-1.f);
}