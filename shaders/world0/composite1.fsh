#version 330 compatibility

#define frag

uniform sampler2D colortex0;

in vec2 texcoord;

/* clang-format off */
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 scene_color;
/* clang-format on */

#include "/include/utility/color.glsl"

void main()
{
    ivec2 texelUV = ivec2(gl_FragCoord.xy);
    scene_color = texture(colortex0, texcoord);
    // scene_color.rgb = clamp(scene_color.rgb * working_to_display_color, 0.f, 1.f);
}