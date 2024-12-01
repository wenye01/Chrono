#if !defined SPACE_TRANSFORM
#define SPACE_TRANSFORM

#include "/include/mathematics.glsl"
// 使用前需要定义
// mat4 gbufferModelView;
// mat4 gbufferModelViewInverse;
// mat4 gbufferProjectionInverse;

vec4 project(mat4 m, vec3 pos)
{
    return vec4(m[0].x, m[1].y, m[2].zw) * pos.xyzz + m[3];
}

vec3 project_and_divide(mat4 m, vec3 pos)
{
    vec4 homogenous = project(m, pos);
    return homogenous.xyz / homogenous.w;
}

vec3 screen2view(vec3 screen_pos)
{
    vec3 ndc_pos = screen_pos * 2.f - 1.f;
    return project_and_divide(gbufferProjectionInverse, ndc_pos);
}

vec3 view2screen(vec3 view_pos)
{
    vec3 ndc_pos = project_and_divide(gbufferModelViewInverse, view_pos);
    return ndc_pos * 0.5 + 0.5;
}

// feetPlayerPos
vec3 view2scene(vec3 view_pos)
{
    return transform(gbufferModelViewInverse, view_pos);
}

vec3 scene2view(vec3 scene_pos)
{
    return transform(gbufferModelView, scene_pos);
}

vec4 diagonal(mat4 m)
{
    return vec4(m[0].x, m[1].y, m[2].z, m[3].w);
}

vec3 project_ortho(mat4 m, vec3 pos)
{
    return diagonal(m).xyz * pos + m[3].xyz;
}

#endif
