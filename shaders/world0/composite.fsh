#version 330 compatibility

#include "/include/distort.glsl"
#include "/include/global.glsl"
#include "/include/shadow/shadowcomp.glsl"

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowColor0;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform vec3 cameraPosition;

uniform vec3 light_dir;

in vec2 texcoord;

vec2 unpack_unorm_2x8(float pack)
{
    vec2 xy;
    xy.x = modf((65535.0 / 256.0) * pack, xy.y);
    return xy * vec2(256.0 / 255.0, 1.0 / 255.0);
}
vec2 sign_non_zero(vec2 v)
{
    return vec2(v.x >= 0.0 ? 1.0 : -1.0, v.y >= 0.0 ? 1.0 : -1.0);
}
vec3 decode_unit_vector(vec2 e)
{
    // Scale to [-1, 1]
    e = 2.0 * e - 1.0;

    // Extract Z component
    vec3 v = vec3(e.xy, 1.0 - abs(e.x) - abs(e.y));

    // Reflect the folds of the lower hemisphere over the diagonals
    if (v.z < 0)
        v.xy = (1.0 - abs(v.yx)) * sign_non_zero(v.xy);

    return normalize(v);
}
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main()
{
    ivec2 texelUV = ivec2(gl_FragCoord.xy);
    float depth = texture2D(depthtex0, texcoord).x;

    depth += 0.38 * float(depth < 0.56); // offset hand depth
    vec3 view_pos = vec3(texcoord.x * 2.f - 1.f, texcoord.y * 2.f - 1.f, depth * 2.f - 1.f);
    view_pos = project_and_divide(gbufferProjectionInverse, view_pos);
    vec3 scene_pos = (gbufferModelViewInverse * vec4(view_pos, 1.f)).xyz;

    const float pixel_scale = 8192.f;
    scene_pos = scene_pos + cameraPosition;
    scene_pos = floor(scene_pos * pixel_scale + 0.01) / pixel_scale + (0.5 / pixel_scale);
    scene_pos = scene_pos - cameraPosition;

    scene_pos = scene_pos;
    vec3 shadowViewPos = (shadowModelView * vec4(scene_pos, 1.f)).xyz;
    vec3 shadowNDC = project_and_divide(shadowProjection, shadowViewPos);
    vec3 distortedNDC = vec3(distort(shadowNDC.xy), shadowNDC.z);
    vec3 shadowScreenPos = distortedNDC * 0.5 + 0.5;

    float shadow = texture(shadowtex1, shadowScreenPos.xy).x;

    float shadowFactor = 0.5f;
    float shade = step(shadow + 0.001, shadowScreenPos.z) * shadowFactor;

    if (NoL < 1e-3)
    {
        shade = 0.f;
    }

    color = texture(colortex0, texcoord) * (1 - shade / 2);
}