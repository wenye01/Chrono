#if !defined LIGHTING
#define LIGHTING

#include "/include/global.glsl"
#include "/include/shadowcomp.glsl"

vec3 ambient_light(vec2 light_level)
{
    return vec3(light_level.x + light_level.y) * 0.4;
}

vec3 diffuse_light(vec3 normal, vec3 light_dir, vec2 light_level, uint material_mask)
{
    float Lambert = max(0.0, dot(normal, light_dir));
    float diff = Lambert * light_level.y;
    return vec3(1.f) * Lambert;
}

vec3 specular_light(vec3 normal, vec3 view_dir, vec3 light_dir, vec2 light_level, uint material_mask)
{
    vec3 half = normalize(light_dir + view_dir);
    float alpha = dot(normal, half);
    float power = 8.0;
    if (material_mask == 1.0)
    {
        power = 64.0;
    }
    float spec = pow(max(0.0, alpha), power) * light_level.y;
    return vec3(1.0) * spec;
}

vec4 lighting(vec3 world_pos, vec3 normal, vec3 view_dir, vec3 light_dir, vec2 light_level, uint material_mask)
{
    vec3 light = vec3(0.0);
    float shadow = calculator_shadow(world_pos, normal);

    light += ambient_light(light_level);
    light += diffuse_light(normal, light_dir, light_level, material_mask) * shadow;
    light += specular_light(normal, -view_dir, light_dir, light_level, material_mask) * shadow;

    return vec4(light, 1.f);
}
#endif