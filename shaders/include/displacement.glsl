#if !defined DISPLACEMENT
#define DISPLACEMENT

#include "/include/global.glsl"

// 使用前需要声明变量
// uniform float frameTimeCounter // run time, seconds, 0s-3600s
struct Wave
{
    vec3 waveOffset;
    vec3 waveNormal;
};

const int WAVE_NUM = 6;
const float WAVE_STEEPNESS = 0.8;
const float WAVE_AMPLITUDE = 1;
const float WAVE_LENGTH = 1;
const float WIND_SPEED = 1;
const int WIND_DIR = 0;
Wave new_gerstner_wave(vec2 coord, float amp, float wavelength, float speed, int windDir, float t)
{
    Wave o;
    float w = 2 * pi / (wavelength * WAVE_LENGTH);
    float A = amp * WAVE_AMPLITUDE;
    float WA = w * A;
    float Q = WAVE_STEEPNESS / (WA * WAVE_NUM);
    float dirRad = radians(float((windDir + WIND_DIR) % 360));
    vec2 D = normalize(vec2(sin(dirRad), cos(dirRad)));
    float cus = w * dot(D, coord) + t * sqrt(9.8 * w) * speed * WIND_SPEED;
    float sinC = sin(cus);
    float cosC = cos(cus);
    o.waveOffset.xz = Q * A * D.xy * cosC;
    o.waveOffset.y = A * sinC / WAVE_NUM;
    o.waveNormal.xz = -D.xy * WA * cosC;
    o.waveNormal.y = -Q * WA * sinC;
    return o;
}
vec3 water_displacement(vec3 world_pos)
{
    float Amplitude[WAVE_NUM];
    float WaveLen[WAVE_NUM];
    float WindSpeed[WAVE_NUM];
    int WindDir[WAVE_NUM];

    Amplitude[0] = 1.8;
    Amplitude[1] = 0.8;
    Amplitude[2] = 0.5;
    Amplitude[3] = 0.3;
    Amplitude[4] = 0.1;
    Amplitude[5] = 0.08;
    WaveLen[0] = 0.541;
    WaveLen[1] = 0.7;
    WaveLen[2] = 0.2;
    WaveLen[3] = 0.3;
    WaveLen[4] = 0.08;
    WaveLen[5] = 0.03;
    WindSpeed[0] = 0.305;
    WindSpeed[1] = 0.5;
    WindSpeed[2] = 0.34;
    WindSpeed[3] = 0.12;
    WindSpeed[4] = 0.74;
    WindSpeed[5] = 0.11;
    WindDir[0] = 11;
    WindDir[1] = 90;
    WindDir[2] = 167;
    WindDir[3] = 300;
    WindDir[4] = 10;
    WindDir[5] = 180;
    vec3 waveOffset = vec3(0.0, 0.0, 0.0);
    vec3 waveNormal = vec3(0.0, 0.0, 0.0);

    for (int i = 0; i < WAVE_NUM; i++)
    {
        Wave wave =
            new_gerstner_wave(world_pos.xy, Amplitude[i], WaveLen[i], WindSpeed[i], WindDir[i], frameTimeCounter);
        waveOffset += wave.waveOffset;
        waveNormal += wave.waveNormal;
    }
    vec3 final_wave_worldpos_offset = waveOffset * 0.05 - 0.025;
    return final_wave_worldpos_offset;
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