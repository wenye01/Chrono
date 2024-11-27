#version 330 compatibility

#define vert
//#include "/program/gbuffers/skytextured.glsl"
out vec2 texcoord;
out vec4 glcolor;
void main()
{
    gl_Position = ftransform();

    texcoord = vec2(gl_MultiTexCoord0);

    glcolor = gl_Color;
}