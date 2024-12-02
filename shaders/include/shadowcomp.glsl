#if !defined SHADOWCOMP
#define SHADOWCOMP

#include "/include/global.glsl"
#include "/include/space_transform.glsl"
#include "/include/distort.glsl"

// 使用前需要声明变量
// uniform sampler2DShadow shadowtex1;
// uniform mat4 shadowModelView;
// uniform mat4 shadowProjection;

const int PCF_NUM_SAMPLES = 8; // 减少采样点数量
const float PCF_RADIUS = 5;    // 采样半径
const vec2 poissonDisk[PCF_NUM_SAMPLES] =
    vec2[](vec2(0, 1), vec2(1, 0), vec2(0, -1), vec2(-1, 0), vec2(0.7071067811865476, 0.7071067811865476),
           vec2(-0.7071067811865476, 0.7071067811865476), vec2(0.7071067811865476, -0.7071067811865476),
           vec2(-0.7071067811865476, -0.7071067811865476));
float randomRotation(in vec2 coord)
{
    return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453);
}

mat2 rotate(float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return mat2(c, -s, s, c);
}

float PCF(vec3 shadow_screen_pos, float radius)
{
    const vec2 texelSize = vec2(1.0 / 8192.0); // 8192x8192 作为配置加入，不要写死
    float visibility = 0.0;
    float angle = randomRotation(shadow_screen_pos.xy) * 2.0 * 3.141592653589793; // 计算随机旋转角度
    mat2 rot = rotate(angle);                                                     // 生成旋转矩阵

    for (int n = 0; n < PCF_NUM_SAMPLES; ++n)
    {
        vec2 sampleCoord = poissonDisk[n] * texelSize * radius;
        sampleCoord = rot * sampleCoord; // 应用旋转
        sampleCoord += shadow_screen_pos.xy;
        float closestDepth = texture2D(shadowtex1, sampleCoord).r;
        visibility += step(shadow_screen_pos.z, closestDepth);
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

    float depth = shadow_basic(shadow_screen_pos);
    float shadow = step(shadow_screen_pos.z, depth);
    return PCF(shadow_screen_pos, PCF_RADIUS);
}

#endif
