#if !defined GLOBAL
#define GLOBAL

#include "/setting.glsl"
#include "/include/mathematics.glsl"

float max_of(vec2 v)
{
    return max(v.x, v.y);
}

float linear_step(float edge0, float edge1, float x)
{
    return clamp01((x - edge0) / (edge1 - edge0));
}

#endif