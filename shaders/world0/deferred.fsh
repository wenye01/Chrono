#version 330 compatibility

#define frag

/* clang-format off */
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 scene_color;
/* clang-format on */

uniform sampler2D depthtex1;

uniform sampler2D colortex0;
uniform sampler2D colortex1;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

// uniform vec3 cameraPosition;
uniform vec3 light_dir;

#include "/include/pack.glsl"
#include "/include/sky/sky.glsl"
#include "/include/shadowcomp.glsl"

in vec2 texcoord;

const float hand_depth = 0.56;
void main()
{
    ivec2 texelUV = ivec2(gl_FragCoord.xy);

    float depth = texelFetch(depthtex1, texelUV, 0).x;
    vec4 gbuffer_data_0 = texelFetch(colortex1, texelUV, 0);

    // depth += 0.38 * float(depth < hand_depth); // 手部深度偏移

    vec3 view_pos = screen2view(vec3(texcoord, depth));
    vec3 scene_pos = view2scene(view_pos);
    vec3 world_dir = normalize(scene_pos - gbufferModelViewInverse[3].xyz); // 视线方向

    vec3 normal = decode_unit_vector(gbuffer_data_0.xy);

    float shadow = calculatorShadow(scene_pos, normal);

    if (depth == 1.0f)
    {
        scene_color = texture(colortex0, texcoord) + vec4(draw_sky(world_dir), 1.f);
    }
    else
    {
        scene_color = texture(colortex0, texcoord) * (shadow + 1) / 2;
    }
}
