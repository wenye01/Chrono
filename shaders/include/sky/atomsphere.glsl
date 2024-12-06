#if !defined ATOMSPHERE
#define ATOMSPHERE

#include "/include/global.glsl"
#include "/include/light/light_color.glsl"

const float earth_radius = 6361e3;                          // 米
const float atmosphere_inner_radius = earth_radius - 1e3;   // 米
const float atmosphere_outer_radius = earth_radius + 110e3; // 米

const float earth_radius_sq = earth_radius * earth_radius;
const float atmosphere_thickness = atmosphere_outer_radius - atmosphere_inner_radius; // 大气层厚度
const float atmosphere_inner_radius_sq = atmosphere_inner_radius * atmosphere_inner_radius;
const float atmosphere_outer_radius_sq = atmosphere_outer_radius * atmosphere_outer_radius;

const float air_mie_g = 0.77; // Anisotropy parameter for Henyey-Greenstein phase function
const float min_mu_s = -0.35;
const float isotropic_phase = 0.25 / 3.1415926;

const ivec3 scattering_res = ivec3(/* nu */ 16, /* mu */ 64, /* mu_s */ 32);

float pow1d5(float x)
{
    return x * sqrt(x);
}

// [0,1] 映射到 [0.5/res, 1-0.5/res]
float get_uv_from_unit_range(float values, const int res)
{
    return values * (1.0 - 1.0 / float(res)) + (0.5 / float(res));
}

vec2 intersect_sphere(float mu, float r, float sphere_radius)
{
    float discriminant = r * r * (mu * mu - 1.0) + sqr(sphere_radius);

    if (discriminant < 0.0)
        return vec2(-1.0);

    discriminant = sqrt(discriminant);
    return -r * mu + vec2(-discriminant, discriminant);
}

float henyey_greenstein_phase(float nu, float g)
{
    float gg = g * g;

    return (isotropic_phase - isotropic_phase * gg) / pow1d5(1.0 + gg - 2.0 * g * nu);
}

vec3 atmosphere_scatter_uv(float nu, float mu, float mu_s)
{
    // Improved mapping for nu from Spectrum by Zombye

    float half_range_nu = sqrt((1.0 - mu * mu) * (1.0 - mu_s * mu_s));
    float nu_min = mu * mu_s - half_range_nu;
    float nu_max = mu * mu_s + half_range_nu;

    float u_nu = (nu_min == nu_max) ? nu_min : (nu - nu_min) / (nu_max - nu_min);
    u_nu = get_uv_from_unit_range(u_nu, scattering_res.x);

    // Stretch the sky near the horizon upwards (to make it easier to admire the sunset without zooming in)

    if (mu > 0.0)
        mu *= sqrt(sqrt(mu));

    // Mapping for mu

    const float r = earth_radius; // distance to the planet centre
    const float H =
        sqrt(atmosphere_outer_radius_sq -
             atmosphere_inner_radius_sq); // distance to the atmosphere upper limit for a horizontal ray at ground level
    const float rho =
        sqrt(max(earth_radius * earth_radius - atmosphere_inner_radius_sq, 0.f)); // distance to the horizon

    // Discriminant of the quadratic equation for the intersections of the ray (r, mu) with the
    // ground
    float rmu = r * mu;
    float discriminant = rmu * rmu - r * r + atmosphere_inner_radius_sq;

    float u_mu;
    if (mu < 0.0 && discriminant >= 0.0)
    { // Ray (r, mu) intersects ground
        // Distance to the ground for the ray (r, mu) and its minimum and maximum values over all mu
        float d = -rmu - sqrt(max(discriminant, 0.f));
        float d_min = r - atmosphere_inner_radius;
        float d_max = rho;

        u_mu = d_max == d_min ? 0.0 : (d - d_min) / (d_max - d_min);
        u_mu = get_uv_from_unit_range(u_mu, scattering_res.y / 2);
        u_mu = 0.5 - 0.5 * u_mu;
    }
    else
    {
        // Distance to exit the atmosphere outer limit for the ray (r, mu) and its minimum and
        // maximum values over all mu
        float d = -rmu + sqrt(discriminant + H * H);
        float d_min = atmosphere_outer_radius - r;
        float d_max = rho + H;

        u_mu = (d - d_min) / (d_max - d_min);
        u_mu = get_uv_from_unit_range(u_mu, scattering_res.y / 2);
        u_mu = 0.5 + 0.5 * u_mu;
    }

    // Mapping for mu_s

    // Distance to the atmosphere outer limit for the ray (atmosphere_inner_radius, mu_s)
    float d = intersect_sphere(mu_s, atmosphere_inner_radius, atmosphere_outer_radius).y;
    float d_min = atmosphere_thickness;
    float d_max = H;
    float a = (d - d_min) / (d_max - d_min);

    // Distance to the atmosphere upper limit for the ray (atmosphere_inner_radius, min_mu_s)
    float D = intersect_sphere(min_mu_s, atmosphere_inner_radius, atmosphere_outer_radius).y;
    float A = (D - d_min) / (d_max - d_min);

    // An ad-hoc function equal to 0 for mu_s = min_mu_s (because then d = D and thus a = A, equal
    // to 1 for mu_s = 1 (because then d = d_min and thus a = 0), and with a large slope around
    // mu_s = 0, to get more texture samples near the horizon
    float u_mu_s = get_uv_from_unit_range(max(1.0 - a / A, 0.f) / (1.0 + a), scattering_res.z);

    return vec3(u_nu, u_mu, u_mu_s);
}

vec3 atmosphere_scatter(vec3 ray_dir, vec3 light_dir)
{
    float cos_ray_light = dot(ray_dir, light_dir);
    float cos_ray_horizon = ray_dir.y;
    float cos_light_horizon = light_dir.y;

    vec3 uv = atmosphere_scatter_uv(cos_ray_light, cos_ray_horizon, cos_light_horizon);

    vec3 scattering;
    // Rayleigh + multiple scattering
    uv.x *= 0.5;
    scattering = texture(depthtex0, uv).rgb;

    // Single mie scattering
    uv.x += 0.5;
    scattering += texture(depthtex0, uv).rgb;

    return scattering;
}

vec3 atmosphere_scattering(vec3 ray_dir, vec3 sun_color, vec3 sun_dir, vec3 moon_color, vec3 moon_dir)
{
    // Calculate nu, mu, mu_s

    float mu = ray_dir.y;

    float nu_sun = dot(ray_dir, sun_dir);
    float nu_moon = dot(ray_dir, moon_dir);

    float mu_sun = sun_dir.y;
    float mu_moon = moon_dir.y;

    // Improved mapping for nu from Spectrum by Zombye

    float half_range_nu, nu_min, nu_max;

    half_range_nu = sqrt((1.0 - mu * mu) * (1.0 - mu_sun * mu_sun));
    nu_min = mu * mu_sun - half_range_nu;
    nu_max = mu * mu_sun + half_range_nu;

    float u_nu_sun = (nu_min == nu_max) ? nu_min : (nu_sun - nu_min) / (nu_max - nu_min);
    u_nu_sun = get_uv_from_unit_range(u_nu_sun, scattering_res.x);

    half_range_nu = sqrt((1.0 - mu * mu) * (1.0 - mu_moon * mu_moon));
    nu_min = mu * mu_moon - half_range_nu;
    nu_max = mu * mu_moon + half_range_nu;

    float u_nu_moon = (nu_min == nu_max) ? nu_min : (nu_moon - nu_min) / (nu_max - nu_min);
    u_nu_moon = get_uv_from_unit_range(u_nu_moon, scattering_res.x);

    // Stretch the sky near the horizon upwards (to make it easier to admire the sunset without zooming in)

    if (mu > 0.0)
        mu *= sqrt(sqrt(mu));

    // Mapping for mu

    const float r = earth_radius; // distance to the planet centre
    const float H =
        sqrt(atmosphere_outer_radius_sq -
             atmosphere_inner_radius_sq); // distance to the atmosphere upper limit for a horizontal ray at ground level
    const float rho =
        sqrt(max(earth_radius * earth_radius - atmosphere_inner_radius_sq, 0.f)); // distance to the horizon

    // Discriminant of the quadratic equation for the intersections of the ray (r, mu) with the
    // ground
    float rmu = r * mu;
    float discriminant = rmu * rmu - r * r + atmosphere_inner_radius_sq;

    float u_mu;
    if (mu < 0.0 && discriminant >= 0.0)
    { // Ray (r, mu) intersects ground
        // Distance to the ground for the ray (r, mu) and its minimum and maximum values over all mu
        float d = -rmu - sqrt(max(discriminant, 0.f));
        float d_min = r - atmosphere_inner_radius;
        float d_max = rho;

        u_mu = d_max == d_min ? 0.0 : (d - d_min) / (d_max - d_min);
        u_mu = get_uv_from_unit_range(u_mu, scattering_res.y / 2);
        u_mu = 0.5 - 0.5 * u_mu;
    }
    else
    {
        // Distance to exit the atmosphere outer limit for the ray (r, mu) and its minimum and
        // maximum values over all mu
        float d = -rmu + sqrt(discriminant + H * H);
        float d_min = atmosphere_outer_radius - r;
        float d_max = rho + H;

        u_mu = (d - d_min) / (d_max - d_min);
        u_mu = get_uv_from_unit_range(u_mu, scattering_res.y / 2);
        u_mu = 0.5 + 0.5 * u_mu;
    }

    // Mapping for mu_s

    float d, a;

    const float d_min = atmosphere_thickness;
    const float d_max = H;

    // Distance to the atmosphere upper limit for the ray (atmosphere_inner_radius, min_mu_s)
    float D = intersect_sphere(min_mu_s, atmosphere_inner_radius, atmosphere_outer_radius).y;
    float A = (D - d_min) / (d_max - d_min);

    // Distance to the atmosphere outer limit for the ray (atmosphere_inner_radius, mu_s)
    d = intersect_sphere(mu_sun, atmosphere_inner_radius, atmosphere_outer_radius).y;
    a = (d - d_min) / (d_max - d_min);

    // An ad-hoc function equal to 0 for mu_s = min_mu_s (because then d = D and thus a = A, equal
    // to 1 for mu_s = 1 (because then d = d_min and thus a = 0), and with a large slope around
    // mu_s = 0, to get more texture samples near the horizon
    float u_mu_sun = get_uv_from_unit_range(max(1.0 - a / A, 0.f) / (1.0 + a), scattering_res.z);

    d = intersect_sphere(mu_moon, atmosphere_inner_radius, atmosphere_outer_radius).y;
    a = (d - d_min) / (d_max - d_min);

    float u_mu_moon = get_uv_from_unit_range(max(1.0 - a / A, 0.f) / (1.0 + a), scattering_res.z);

    // Sample atmosphere LUT

    vec3 uv_sc = vec3(u_nu_sun * 0.5, u_mu, u_mu_sun);         // Rayleigh + multiple scattering, sunlight
    vec3 uv_sm = vec3(u_nu_sun * 0.5 + 0.5, u_mu, u_mu_sun);   // Mie scattering, sunlight
    vec3 uv_mc = vec3(u_nu_moon * 0.5, u_mu, u_mu_moon);       // Rayleigh + multiple scattering, moonlight
    vec3 uv_mm = vec3(u_nu_moon * 0.5 + 0.5, u_mu, u_mu_moon); // Mie scattering, moonlight

    vec3 scattering_sc = texture(depthtex0, uv_sc).rgb;
    vec3 scattering_sm = texture(depthtex0, uv_sm).rgb;
    vec3 scattering_mc = texture(depthtex0, uv_mc).rgb;
    vec3 scattering_mm = texture(depthtex0, uv_mm).rgb;

    float mie_phase_sun = henyey_greenstein_phase(nu_sun, air_mie_g);
    float mie_phase_moon = henyey_greenstein_phase(nu_moon, air_mie_g);

    return (scattering_sc + scattering_sm * mie_phase_sun) * sun_color +
           (scattering_mc + scattering_mm * mie_phase_moon) * moon_color;
}

#endif