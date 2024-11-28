#if !defined GLOBAL
#define GLOBAL

#define clamp01(x) clamp(x, 0.0, 1.0) // free on operation output

float max_of(vec2 v)
{
    return max(v.x, v.y);
}

float linear_step(float edge0, float edge1, float x)
{
    return clamp01((x - edge0) / (edge1 - edge0));
}

#endif