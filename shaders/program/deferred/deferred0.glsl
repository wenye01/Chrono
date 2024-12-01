#if defined vert

out vec2 texcoord;

void main()
{
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
#endif
//-----------------------------------------------------------------

//-----------------------------------------------------------------
#if defined frag


#include "/include/distort.glsl"
#include "/include/shadow/shadowcomp.glsl"
#include "/include/pack.glsl"
#include "/include/sky/sky.glsl"

/* clang-format off */
/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 scene_color;
/* clang-format on */

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D colortex0;
uniform sampler2D colortex1;

uniform sampler2D shadowtex1;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

uniform vec3 cameraPosition;
uniform vec3 light_dir;

in vec2 texcoord;
const float hand_depth = 0.56;
void main()
{
    ivec2 texelUV = ivec2(gl_FragCoord.xy);

    float depth = texelFetch(depthtex1, texelUV, 0).x;
    vec4 gbuffer_data_0 = texelFetch(colortex1, texelUV, 0);


    depth += 0.38 * float(depth < hand_depth);
    vec3 view_pos = vec3(texcoord.x * 2.f - 1.f, texcoord.y * 2.f - 1.f, depth * 2.f - 1.f);
    view_pos = project_and_divide(gbufferProjectionInverse, view_pos);

    vec3 normal = decode_unit_vector(gbuffer_data_0.xy);

    vec3 scene_pos = mat3(gbufferModelViewInverse) * view_pos + gbufferModelViewInverse[3].xyz;
    vec3 world_pos = scene_pos + cameraPosition;
    vec3 world_dir = normalize(scene_pos - gbufferModelViewInverse[3].xyz); // 视线方向

    float NoL = dot(normal, light_dir);
    if(NoL < 1e-3)
    {
        return vec3(0.f);
    }

    vec3 bias = get_shadow_bias(scene_pos, normal, NoL);

    float pixel_scale = 8192.f;
    scene_pos = scene_pos+cameraPosition;
    scene_pos = floor(scene_pos * pixel_scale+0.01) / pixel_scale+0.5/pixel_scale;
    scene_pos = scene_pos-cameraPosition;

    vec3 shadow_view = transform(shadowModelView,scene_pos+bias);
    vec3 shadow_clip = project_ortho(shadowProjection,shadow_view);
    vec3 shadow_screen =distort(shadow_clip)*0.5+0.5;

    float shadow = texture(shadowtex1, shadow_screen);

    if (depth == 1.0f)
    {
        scene_color = vec4(draw_sky(world_dir), 1.f);
    }
    else
    {
        scene_color = vec4(vec3(shadow),1.f);
    }
    
}

#endif