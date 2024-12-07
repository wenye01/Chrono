#if !defined INCLUDE_SKY
#define INCLUDE_SKY

#include "/setting.glsl"

#include "/include/global.glsl"

float fast_acos(float x)
{
    const float pi = 3.1415926;
    const float C0 = 1.57018;
    const float C1 = -0.201877;
    const float C2 = 0.0464619;

    float res = (C2 * abs(x) + C1) * abs(x) + C0; // p(x)
    res *= sqrt(1.0 - abs(x));

    return x >= 0 ? res : pi - res; // Undo range reduction
}

vec3 draw_cloud()
{
    return vec3(0.f);
}

vec3 draw_star(vec3 ray_dir)
{
    return vec3(0.f);
}

vec3 draw_moon(vec3 ray_dir)
{
    return vec3(0.f);
}

const float sun_luminance = 15.0; // luminance of sun disk

vec3 pal(float t, vec3 a, vec3 b, vec3 c, vec3 d)
{
    return a + b * cos(2.0 * 3.1415 * (c * t + d));
}
vec3 spc(float n, float bright)
{
    return pal(n, vec3(bright), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67));
}

vec3 draw_sun(vec3 ray_dir, vec3 sun_color)
{
    float nu = dot(ray_dir, sun_dir);

    // Limb darkening model from http://www.physics.hmc.edu/faculty/esin/a101/limbdarkening.pdf
    const vec3 alpha = vec3(0.429, 0.522, 0.614);
    float center_to_edge = max(sun_angular_radius - fast_acos(nu), 0.f);
    vec3 limb_darkening = pow(vec3(1.0 - sqr(1.0 - center_to_edge)), 0.5 * alpha);

    return  sun_luminance * vec3(0.02)* step(0.0, center_to_edge) * limb_darkening;
}

vec3 draw_sky(vec3 ray_dir, vec3 atmosphere, vec3 sun_color)
{
    vec3 new_sky = vec3(0.f);

    new_sky += draw_star(ray_dir);
    new_sky += draw_moon(ray_dir);

#ifndef VANILLA_SUN
    new_sky += draw_sun(ray_dir, sun_color);
#endif
    new_sky += atmosphere;
    return new_sky;
}

#endif