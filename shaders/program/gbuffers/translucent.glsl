#if defined vert

attribute vec3 mc_Entity;

uniform mat4 gbufferModelView;
uniform mat4 gbufferPorjection;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform vec3 cameraPosition;

uniform float frameTimeCounter;

#include "/include/global.glsl"
#include "/include/space_transform.glsl"
#include "/include/displacement.glsl"

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

    // ftransform，中途在worldpos做顶点动画
    vec3 point_pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    point_pos = view2scene(point_pos);

    point_pos = point_pos + cameraPosition;         // world pos
    point_pos += animate(point_pos, material_mask); // animate pos
    point_pos = point_pos - cameraPosition;

    point_pos = scene2view(point_pos);
    vec4 clip_pos = gl_ProjectionMatrix * vec4(point_pos, 1.f); // clip pos, gbufferProjection会出错

    gl_Position = clip_pos;
}
#endif
//-----------------------------------------------------------------

//-----------------------------------------------------------------
#if defined frag

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

    gbuffer_data_0 = vec4(encode_unit_vector(normal), // xy: normal
                          pack_unorm_2x8(lmcoord),    // z: lmcoord
                          material_mask);             //  w: material_mask
}
#endif