#version 330 compatibility

#define vert

out vec2 texcoord;

void main()
{
    texcoord = gl_MultiTexCoord0.xy;
    gl_Position = vec4(gl_Vertex.xy * 2.0 - 1.0, 0.0, 1.0);
}