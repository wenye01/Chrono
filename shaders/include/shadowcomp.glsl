#if !defined SHADOWCOMP
#define SHADOWCOMP

#include "/include/global.glsl"
#include "/include/space_transform.glsl"
#include "/include/distort.glsl"

// 使用前需要声明变量
// uniform sampler2DShadow shadowtex1;
// uniform mat4 shadowModelView;
// uniform mat4 shadowProjection;

float shadow_basic(vec3 shadow_screen_pos)
{
    return texture(shadowtex1, shadow_screen_pos.xy).r;
}

vec3 get_shadow_bias(vec3 scene_pos, vec3 normal, float NoL)
{
    // Shadow bias without peter-panning
    vec3 bias = 0.25 * normal * clamp(0.12 + 0.01 * length(scene_pos), 0.f, 1.f) * (2.0 - clamp01(NoL), 0.f, 1.f);

    return bias;
}

float calculatorShadow(vec3 scene_pos, vec3 normal)
{
    float NoL = dot(normal, light_dir);
    if (NoL < 1e-3)
    {
        return 0.f;
    }

    vec3 bias = get_shadow_bias(scene_pos, normal, NoL);
    vec3 shadow_view_pos = transform(shadowModelView, scene_pos + bias);
    vec3 shadow_clip_pos = project_ortho(shadowProjection, shadow_view_pos);
    vec3 shadow_screen_pos = distort(shadow_clip_pos) * 0.5 + 0.5;

    float depth = shadow_basic(shadow_screen_pos);

    return step(shadow_screen_pos.z, depth);
}

#endif
