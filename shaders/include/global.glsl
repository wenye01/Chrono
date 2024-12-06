#if !defined GLOBAL
#define GLOBAL

#include "/setting.glsl"
#include "/include/mathematics.glsl"

const float pi = 3.1415926;

float max_of(vec2 v)
{
    return max(v.x, v.y);
}

float linear_step(float edge0, float edge1, float x)
{
    return clamp01((x - edge0) / (edge1 - edge0));
}

float cubic_smooth(float x)
{
    return sqr(x) * (3.0 - 2.0 * x);
}

float pulse(float x, float center, float width)
{
    x = abs(x - center) / width;
    return x > 1.0 ? 0.0 : 1.0 - cubic_smooth(x);
}

#endif