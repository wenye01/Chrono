
#if defined vert

#include "/include/distort.glsl"

#define SHADOW_MAP_BIAS 0.75

out vec2 texcoord;
out vec3 color;

void main()
{
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    color = gl_Color.rgb;

    gl_Position = ftransform();
    gl_Position.xy = distort(gl_Position.xy);
}

#endif
//---------------------------------------------------------

//---------------------------------------------------------

#if defined frag

uniform sampler2D gtexture;

in vec2 texcoord;
in vec3 color;

/* clang-format off */
/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;
/* clang-format on */

void main()
{
    vec4 colorData = texture(gtexture, texcoord);
    if (colorData.a < 0.1f)
    {
        discard;
    }
    outColor0 = colorData;
}
#endif