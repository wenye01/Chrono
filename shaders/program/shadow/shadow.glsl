
#if defined vert

#include "/include/distort.glsl"

out vec2 texcoord;

void main()
{
    texcoord = gl_MultiTexCoord0.xy;

    gl_Position = ftransform();
    gl_Position.xyz = distort(gl_Position.xyz);
}

#endif
//---------------------------------------------------------

//---------------------------------------------------------

#if defined frag

uniform sampler2D tex;
in vec2 texcoord;

/* clang-format off */
/* DRAWBUFFERS:0 */
layout(location = 0) out vec3 outColor0;
/* clang-format on */

void main()
{
    vec4 colorData = texture(tex, texcoord);
    if (colorData.a < 0.1f)
    {
        discard;
    }
    // outColor0 = colorData;
}
#endif