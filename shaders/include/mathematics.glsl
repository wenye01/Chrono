#if !defined MATHEMATICS
#define MATHEMATICS

#define clamp01(x) clamp(x, 0.0, 1.0) // free on operation output
#define rcp(x) (1.f / x)              //

float sqr(float x)
{
    return x * x;
}
vec2 sqr(vec2 v)
{
    return v * v;
}
vec3 sqr(vec3 v)
{
    return v * v;
}
vec4 sqr(vec4 v)
{
    return v * v;
}

float pow4(float x)
{
    return sqr(sqr(x));
}

vec3 transform(mat4 m, vec3 pos)
{
    return mat3(m) * pos + m[3].xyz;
}

#endif