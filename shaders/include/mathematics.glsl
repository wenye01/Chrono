#if !defined MATHEMATICS
#define MATHEMATICS

#define clamp01(x) clamp(x, 0.0, 1.0) // free on operation output
#define rcp(x) (1.f / x)              //

float rcp_length(vec2 v)
{
    return inversesqrt(dot(v, v));
}
float length_squared(vec2 v)
{
    return dot(v, v);
}
float length_squared(vec3 v)
{
    return dot(v, v);
}
const float pi = 3.1415926535897932384626433832795;

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

// Faster alternative to acos
// Source:
// https://seblagarde.wordpress.com/2014/12/01/inverse-trigonometric-functions-gpu-optimization-for-amd-gcn-architecture/#more-3316
// Max relative error: 3.9 * 10^-4
// Max absolute error: 6.1 * 10^-4
// Polynomial degree: 2
float fast_acos(float x)
{
    const float C0 = 1.57018;
    const float C1 = -0.201877;
    const float C2 = 0.0464619;

    float res = (C2 * abs(x) + C1) * abs(x) + C0; // p(x)
    res *= sqrt(1.0 - abs(x));

    return x >= 0 ? res : pi - res; // Undo range reduction
}

#endif