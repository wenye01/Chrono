#if !defined GLOBAL
#define GLOBAL

#define clamp01(x) clamp(x, 0.0, 1.0) // free on operation output
#define rcp(x) (1.f / x)              // 所有除法均使用rcp

float max_of(vec2 v)
{
    return max(v.x, v.y);
}

float linear_step(float edge0, float edge1, float x)
{
    return clamp01((x - edge0) / (edge1 - edge0));
}

vec4 project(mat4 m, vec3 pos)
{
    return vec4(m[0].x, m[1].y, m[2].zw) * pos.xyzz + m[3];
}

vec3 project_and_divide(mat4 m, vec3 pos)
{
    vec4 homogenous = project(m, pos);
    return homogenous.xyz / homogenous.w;
}
#endif