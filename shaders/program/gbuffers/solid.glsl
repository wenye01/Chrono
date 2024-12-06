#if defined vert

attribute vec3 mc_Entity;

uniform mat4 gbufferModelViewInverse;

flat out float material_mask;
flat out vec3 normal;

out vec2 texcoord;
out vec2 lmcoord;
out vec4 glcolor;

void main()
{
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;
    material_mask = mc_Entity.x - 10000.0;
    normal = mat3(gbufferModelViewInverse) * normalize(gl_NormalMatrix * gl_Normal);

    gl_Position = ftransform();
}
#endif
//-----------------------------------------------------------------

//-----------------------------------------------------------------
#if defined frag

#include "/include/global.glsl"
#include "/include/pack.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;

flat in float material_mask;
flat in vec3 normal;

in vec2 texcoord;
in vec2 lmcoord;
in vec4 glcolor;
/* clang-format off */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 gbuffer_data_0; // colortex1 in deferred/composite
/* DRAWBUFFERS:01 */
/* clang-format on */

void main()
{
    color = texture(gtexture, texcoord) * glcolor;
    if (color.a < 0.1)
    {
        discard;
    }
    gbuffer_data_0 = vec4(encode_unit_vector(normal),                   // xy: normal
                          pack_unorm_2x8(lmcoord),                      // z: lmcoord
                          clamp(material_mask * rcp(255.f), 0.f, 1.f)); //  w: material_mask
}
#endif