#if !defined LIGHT_COLOR
#define LIGHT_COLOR

#include "/include/global.glsl"

const mat3 rec709_to_xyz = mat3(
	 0.4124,  0.3576,  0.1805,
	 0.2126,  0.7152,  0.0722,
	 0.0193,  0.1192,  0.9505
);

// Rec. 2020 (working color space)
const mat3 xyz_to_rec2020 = mat3(
	 1.7166084, -0.3556621, -0.2533601,
	-0.6666829,  1.6164776,  0.0157685,
	 0.0176422, -0.0427763,  0.94222867
);

#define from_srgb(x) (pow(x, vec3(2.2)) * rec709_to_xyz*xyz_to_rec2020)

float get_sun_exposure()
{
    const float base_scale = 7.0 * 1.0;

    float blue_hour = linear_step(0.05, 1.0, exp(-190.0 * sqr(sun_dir.y + 0.09604)));

    float daytime_mul = 1.0 + 0.5 * (time_sunset + time_sunrise) + 40.0 * blue_hour;

    return base_scale * daytime_mul;
}

vec3 get_sun_tint()
{
    float blue_hour = linear_step(0.05, 1.0, exp(-190.0 * sqr(sun_dir.y + 0.09604)));

    vec3 morning_evening_tint = vec3(1.05, 0.84, 0.93) * 1.2;
    morning_evening_tint = mix(vec3(1.0), morning_evening_tint, sqr(pulse(sun_dir.y, 0.17, 0.40)));

    vec3 blue_hour_tint = vec3(1.0, 0.85, 0.95);
    blue_hour_tint = mix(vec3(1.0), blue_hour_tint, blue_hour);

    // User tint

    const vec3 tint_morning = from_srgb(vec3(1.0));
    const vec3 tint_noon = from_srgb(vec3(1.0));
    const vec3 tint_evening = from_srgb(vec3(1.0));

    vec3 user_tint = mix(tint_noon, tint_morning, time_sunrise);
    user_tint = mix(user_tint, tint_evening, time_sunset);

    return morning_evening_tint * blue_hour_tint * user_tint;
}

float get_moon_exposure()
{
    const float base_scale = 0.66 * 1.0;

    return base_scale * 1.0;
}

vec3 get_moon_tint()
{
    const vec3 base_tint = from_srgb(vec3(0.75, 0.83, 1.0)); // from_srgb(vec3(MOON_R, MOON_G, MOON_B));

    return base_tint;
}

#endif