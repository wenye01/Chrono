#if !defined SHADOWCOMP
#define SHADOWCOMP

#include "/include/global.glsl"
#include "/include/space_transform.glsl"
#include "/include/distort.glsl"

// 使用前需要声明变量
// uniform sampler2DShadow shadowtex1;
// uniform mat4 shadowModelView;
// uniform mat4 shadowProjection;

const int PCF_NUM_SAMPLES = 16; // 减少采样点数量
const float PCF_RADIUS = 5;     // 采样半径
const vec2 poissonDisk[PCF_NUM_SAMPLES] =
    vec2[](vec2(-0.94201624, -0.39906216), vec2(0.94558609, -0.76890725), vec2(-0.094184101, -0.92938870),
           vec2(0.34495938, 0.29387760), vec2(-0.91588581, 0.45771432), vec2(-0.81544232, -0.87912464),
           vec2(-0.38277543, 0.27676841), vec2(0.97484398, 0.75648379), vec2(0.44323325, -0.97511554),
           vec2(0.53742981, -0.47373420), vec2(-0.26496911, -0.41893023), vec2(0.79197514, 0.19090188),
           vec2(-0.24188840, 0.99706507), vec2(-0.81409955, 0.91437590), vec2(0.19984126, 0.78641367),
           vec2(0.14383161, -0.14100790));

float PCF(vec3 shadow_screen_pos, float radius)
{
    const vec2 texelSize = vec2(1.0 / 8192.0); // 8192x8192
    float visibility = 0.0;
    for (int n = 0; n < PCF_NUM_SAMPLES; ++n)
    {
        vec2 sampleCoord = poissonDisk[n] * texelSize * radius + shadow_screen_pos.xy;
        float closestDepth = texture2D(shadowtex1, sampleCoord).r;
        visibility += step(shadow_screen_pos.z - 0.001, closestDepth);
    }
    return visibility / float(PCF_NUM_SAMPLES);
}

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

    // float depth = shadow_basic(shadow_screen_pos);
    // float shadow = step(shadow_screen_pos.z, depth) * PCF(shadow_screen_pos, PCF_RADIUS);
    return PCF(shadow_screen_pos, PCF_RADIUS);
}

#endif
