#if !defined AMBIENT_OCCLUSION
#define AMBIENT_OCCLUSION

#include "/include/global.glsl"
#include "/include/space_transform.glsl"

#define GTAO_SLICES 2
#define GTAO_SETPS 3
#define GTAO_RADIUS 2.0

// from photon
float integrate_arc(vec2 h, float n, float cos_n)
{
    vec2 tmp = cos_n + 2.0 * h * sin(n) - cos(2.0 * h - n);
    return 0.25 * (tmp.x + tmp.y);
}

float elevation_angle(vec3 slice_dir, vec3 view_dir, vec3 view_pos, vec3 screen_pos)
{
    float step_size = GTAO_RADIUS / float(GTAO_SETPS); // 采样步长

    vec2 ray_step = (view2screen(view_pos + slice_dir * step_size) - screen_pos).xy; // ray march step
    vec2 ray_pos = screen_pos.xy + ray_step;

    float max_cos = -1.0;
    for (int i = 0; i < GTAO_SETPS; ++i)
    {
        float depth = texelFetch(depthtex1, ivec2(clamp(ray_pos, 0.f, 1.f) * vec2(viewWidth, viewHeight) - 0.5), 0).x;

        if (depth == 1.0 || depth < 0.56 || depth == screen_pos.z)
        {
            continue;
        }
        vec3 diff_vec = screen2view(vec3(ray_pos, depth)) - screen_pos;
        float cos_view_sample = dot(view_dir, diff_vec);
        max_cos = max(max_cos, cos_view_sample);
    }
    return fast_acos(clamp(max_cos, -1.0, 1.0));
}

float ambient_occlusion(vec3 screen_pos, vec3 view_pos, vec3 view_normal, vec3 dither)
{
    vec3 view_dir = normalize(-view_pos);
    vec3 view_right = normalize(cross(vec3(0.0, 1.0, 0.0), view_dir));
    vec3 view_up = cross(view_dir, view_right);

    mat3 view_matrix = mat3(view_right, view_up, view_dir); // 转换到view空间

    for (int i = 0; i < GTAO_SLICES; ++i)
    {
        float step_angle = float(i) * pi / float(GTAO_SLICES);
        vec3 slice_dir = vec3(cos(step_angle), sin(step_angle), 0.0);
        vec3 slice_view_dir = view_matrix * slice_dir;

        vec3 ortho_dir = slice_dir - dot(slice_dir, view_dir) * view_dir;
        vec3 axis = cross(slice_dir, view_dir);
        vec3 projected_normal = view_normal - axis * dot(view_normal, axis);

        float len_sq = dot(projected_normal, projected_normal);
        float norm = inversesqrt(len_sq);

        float sgn_gamma = sign(dot(ortho_dir, projected_normal));
        float cos_gamma = clamp01(dot(projected_normal, view_dir) * norm);
        float gamma = sgn_gamma * fast_acos(cos_gamma);

        vec2 angle;
        angle.x = elevation_angle(slice_view_dir, view_dir, view_pos, screen_pos);
        angle.y = elevation_angle(-slice_view_dir, view_dir, view_pos, screen_pos);
        angle = gamma + clamp(vec2(-1.0, 1.0) * angle - gamma, -pi * 0.5, pi * 0.5);

        ao += integrate_arc(angle, gamma, cos_gamma) * len_sq * norm;
    }
    ao *= rcp(float(GTAO_SLICES));

    return ao;
}

#endif