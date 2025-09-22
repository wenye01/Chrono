#if !defined GLOBAL
#define GLOBAL

#include "/setting.glsl"
#include "/include/mathematics.glsl"

// 最大值最小值
float max_of(vec2 v)
{
    return max(v.x, v.y);
}

float min_of(vec2 v)
{
    return min(v.x, v.y);
}

float min_of(vec3 v)
{
    return min(v.x, min(v.y, v.z));
}

// 线性插值
float linear_step(float edge0, float edge1, float x)
{
    return clamp01((x - edge0) / (edge1 - edge0));
}

// 三次插值
float cubic_smooth(float x)
{
    return sqr(x) * (3.0 - 2.0 * x);
}

// 脉冲函数，中心点center，宽度width
float pulse(float x, float center, float width)
{
    x = abs(x - center) / width;
    return x > 1.0 ? 0.0 : 1.0 - cubic_smooth(x);
}

#endif