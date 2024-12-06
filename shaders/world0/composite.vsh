#version 330 compatibility

#define vert

out vec2 texcoord;

void main()
{
    texcoord = gl_MultiTexCoord0.xy;
    gl_Position = ftransform();
}