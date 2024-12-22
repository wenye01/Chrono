#if !defined RANDOM
#define RANDOM

#include "/include/global.glsl"

// 声明noisetex

float blue_noise(float seed)
{
    return fract(texelFetch2D(noisetex, ivec2(gl_FragCoord.xy) % 512 + ivec2(seed), 0).a + rcp(1.6180339887) * seed);
}

vec4 blue_noise(vec2 texcoord)
{
    return texelFetch2D(noisetex, ivec2(texcoord), 0).rgba;
}

vec2 r2_noise(float seed)
{
    vec2 alpha = vec2(0.75487765, 0.56984026);
    return fract(alpha * gl_FragCoord.xy + rcp(1.3247179572) * seed);
}

#endif