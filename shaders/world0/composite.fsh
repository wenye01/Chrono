#version 400 compatibility

#define frag

uniform sampler2D colortex0;

in vec2 texcoord;

void main()
{
    gl_FragColor = texture(colortex0, texcoord);
}
