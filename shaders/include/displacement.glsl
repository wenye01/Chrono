#if !defined DISPLACEMENT
#define DISPLACEMENT

#include "/include/global.glsl"

// 使用前需要声明变量
// uniform float frameTimeCounter // run time, seconds, 0s-3600s

float gerstner_wave(vec2 coord, vec2 wave_dir, float t, float noise, float wavelength)
{
    // Gerstner wave function from Belmu in #snippets, modified
    const float g = 9.8;

    float k = 2.0 * pi / wavelength;
    float w = sqrt(g * k);

    float x = w * t - k * (dot(wave_dir, coord) + noise);

    return sqr(sin(x) * 0.5 + 0.5);
}

vec3 water_displacement(vec3 world_pos)
{
    const float WATER_WAVE_FREQUENCY = 2.5;
    const float WATER_WAVE_SPEED_STILL = 1.0;

    const float wave_frequency = 0.3 * WATER_WAVE_FREQUENCY;
    const float wave_speed = 0.37 * WATER_WAVE_SPEED_STILL;
    const float wave_angle = 30.0 * (2 * pi / 360.f);
    const float wavelength = 1.0;
    const vec2 wave_dir = vec2(cos(wave_angle), sin(wave_angle));
    float wave = gerstner_wave(world_pos.xy * wave_frequency, wave_dir, frameTimeCounter * wave_speed, 0.0, wavelength);
    wave = wave * 0.05 - 0.025;
    return vec3(0.f, wave, 0.f);
}

vec3 animate(vec3 world_pos, float block_mask)
{
    vec3 displacement = vec3(0.f);
    if (block_mask == 1.0) // water
    {
        displacement = water_displacement(world_pos);
    }

    return displacement;
}

#endif