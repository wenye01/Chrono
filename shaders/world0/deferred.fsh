#version 400 compatibility

#define frag
/* clang-format off */
/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 scene_color;
/* clang-format on */

uniform sampler2D colortex0;
in vec2 texcoord;

void main()
{
    scene_color = texture(colortex0, texcoord);
}