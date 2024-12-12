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
    vec3 half_vec = normalize(light_dir + view_dir);
    float alpha = dot(normal, half_vec);
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

vec4 lighting_brdf(vec3 world_pos, vec3 normal, vec3 view_dir, vec3 light_dir, uint material_mask,
                   vec2 light_level) 
{
    float shadow = calculator_shadow(world_pos, normal);
    // todo:阴影感觉不太对，light_dir没用，手部阴影奇怪
    // 定义粗糙度、金属度和反射率的默认值
    float roughness = 0.5;
    float metallic = 0.0;
    vec3 reflectance = vec3(0.04);

    view_dir = -view_dir;
    //light_dir = -light_dir;
    // 当 material_mask 为 1 时调整水的参数
    if (material_mask == 1.0)
    {
        roughness = 0.05;         // 较低的粗糙度以获得更平滑的表面
        reflectance = vec3(0.02); // 较高的反射率以模拟水
    }

    float alpha = pow(roughness, 2);

    vec3 H = normalize(light_dir + view_dir);

    // 向量点积
    float NdotV = clamp(dot(normal, view_dir), 0.001, 1.0);
    float NdotL = clamp(dot(normal, light_dir), 0.001, 1.0);
    float NdotH = clamp(dot(normal, H), 0.001, 1.0);
    float VdotH = clamp(dot(view_dir, H), 0.001, 1.0);

    // 菲涅耳效应
    vec3 F0 = reflectance;
    vec3 fresnelReflectance = F0 + (1.0 - F0) * pow(1.0 - VdotH, 5.0); // 施基克近似

    // phong漫反射
    vec3 rhoD = vec3(light_level.y,light_level.y,light_level.y);
    rhoD *= (vec3(1.0) - fresnelReflectance); // 能量守恒 - 不反射的部分添加到漫反射

    // rhoD *= (1-metallic); // 金属的漫反射为0

    // 几何衰减
    float k = alpha / 2;
    float geometry = (NdotL / (NdotL * (1 - k) + k)) * (NdotV / ((NdotV * (1 - k) + k)));

    // 微观凹凸分布
    float lowerTerm = pow(NdotH, 2) * (pow(alpha, 2) - 1.0) + 1.0;
    float normalDistributionFunctionGGX = pow(alpha, 2) / (3.14159 * pow(lowerTerm, 2));

    vec3 phongDiffuse = rhoD; //
    vec3 cookTorrance = (fresnelReflectance * normalDistributionFunctionGGX * geometry) / (4 * NdotL * NdotV);
    vec3 BRDF = (phongDiffuse + cookTorrance) * NdotL;

    vec3 diffFunction = BRDF * shadow;

    return vec4(diffFunction, 1.f);
}
#endif