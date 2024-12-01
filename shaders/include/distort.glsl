#if !defined DISTORT
#define DISTORT

#include "/include/global.glsl"

#define SHADOW_DEPTH_SCALE 0.2
#define SHADOW_DISTORTION 0.85

float quartic_length(vec2 v)
{
    return sqrt(sqrt(pow4(v.x) + pow4(v.y)));
}

float get_distortion_factor(vec2 shadow_clip_pos)
{
    return quartic_length(shadow_clip_pos) * SHADOW_DISTORTION + (1.0 - SHADOW_DISTORTION);
}

vec3 distort_shadow_space(vec3 shadow_clip_pos, float distortion_factor)
{
    return shadow_clip_pos * vec3(vec2(rcp(distortion_factor)), SHADOW_DEPTH_SCALE);
}

vec3 distort(vec3 shadow_clip_pos)
{
    float distortion_factor = get_distortion_factor(shadow_clip_pos.xy);
    return distort_shadow_space(shadow_clip_pos, distortion_factor);
}

vec3 undistort(vec3 shadow_clip_pos)
{
    shadow_clip_pos.xy *= (1.0 - SHADOW_DISTORTION) / (1.0 - quartic_length(shadow_clip_pos.xy));
    shadow_clip_pos.z *= rcp(SHADOW_DEPTH_SCALE);
    return shadow_clip_pos;
}

#endif