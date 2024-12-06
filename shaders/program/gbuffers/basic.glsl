
#if defined vert

out vec4 basic_color;

void main()
{
    gl_Position = ftransform();
    basic_color = gl_Color;
}

#endif
//-----------------------------------------------------------------

//-----------------------------------------------------------------
#if defined frag

#include "/include/pack.glsl"

in vec4 basic_color;

/* clang-format off */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 gbuffer_data_0; // colortex1 in deferred/composite
/* DRAWBUFFERS:01 */
/* clang-format on */

void main()
{
    color = basic_color;
    gbuffer_data_0 = vec4(encode_unit_vector(vec3(0.f, 1.f, 0.f)), 0.f, 0.f);
}

#endif