#if !defined AMBIENT_OCCLUSION
#define AMBIENT_OCCLUSION

#include "/include/global.glsl"
#include "/include/space_transform.glsl"
#include "/include/utility/random.glsl"

#define SLICE_COUNT 8
#define RACIUS 0.2

uniform float viewWidth;
uniform float viewHeight;

vec3 ambient_occlusion(vec3 screen_pos, vec3 view_pos, vec3 view_normal)
{
    float ao = 0.0;

    vec3 tangent = view_normal.y == 1.0 ? vec3(1.0, 0.0, 0.0) : normalize(cross(vec3(0.0, 1.0, 0.0), view_normal));
    vec3 bitangent = normalize(cross(tangent, view_normal));
    mat3 tbn = mat3(tangent, bitangent, view_normal);

    // return (tbn * offset) * 0.5 + 0.5;
    for (int i = 0; i < SLICE_COUNT; ++i)
    {
        float slice_angle = 2 * pi * float(i) / SLICE_COUNT;
        vec3 offset = tbn * vec3(cos(slice_angle), sin(slice_angle), 0.f);

        vec3 sample_pos = view_pos + offset * RACIUS;
        vec3 screenOffset = view2screen(sample_pos);
        float depth = texelFetch(depthtex1, ivec2(screenOffset.xy * vec2(viewWidth, viewHeight)), 0).x;
        ao += (depth >= screenOffset.z ? 1.0 : 0.0);
    }
    ao = (ao / SLICE_COUNT);
    return vec3(ao);
}
#endif