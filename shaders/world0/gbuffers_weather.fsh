#version 400 compatibility

/* clang-format off */
layout(location = 0) out vec4 color;
//layout(location = 1) out vec4 gbuffer_data_0; // colortex1 in deferred/composite
///* DRAWBUFFERS:01 */
/* clang-format on */

void main()
{
    color = vec4(1.f);
}