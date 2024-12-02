#if !defined DISPLACEMENT
#define DISPLACEMENT

#include "/include/global.glsl"

vec3 water_displacement(vec3 world_pos)
{
    return vec3(0.0, 0.0, 0.0);
}

vec3 animate(vec3 world_pos, float block_mask)
{
    vec3 displacement = vec3(0.f);
    if (block_mask == 1.0)
    {
        displacement = water_displacement(world_pos);
    }

    return displacement;
}

#endif