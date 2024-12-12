#version 330 compatibility

#define frag

/* clang-format off */
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 scene_color;
/* clang-format on */

uniform sampler3D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D colortex0;
uniform sampler2D colortex1;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

uniform sampler2D noisetex;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

uniform float eyeAltitude;

// uniform vec3 cameraPosition;
uniform vec3 light_dir;
uniform vec3 sun_dir;
uniform vec3 moon_dir;

uniform float time_sunrise;
uniform float time_sunset;
uniform int frameCounter;

#include "/include/pack.glsl"
#include "/include/sky/sky.glsl"
#include "/include/light/lighting.glsl"
#include "/include/sky/atomsphere.glsl"
//#include "/include/sky/newatom.glsl"

in vec2 texcoord;

float blueNoise()
{
    return fract(texelFetch2D(noisetex, ivec2(gl_FragCoord.xy) % 256, 0).a); // + 1.0 / 1.6180339887 * frameCounter);
}

const float hand_depth = 0.56;
void main()
{
    ivec2 texelUV = ivec2(gl_FragCoord.xy);

    float depth = texelFetch(depthtex1, texelUV, 0).x;
    vec4 gbuffer_data_0 = texelFetch(colortex1, texelUV, 0);

    // depth += 0.38 * float(depth < hand_depth); // 手部深度偏移

    vec3 view_pos = screen2view(vec3(texcoord, depth));
    vec3 scene_pos = view2scene(view_pos);
    vec3 world_dir = normalize(scene_pos - gbufferModelViewInverse[3].xyz); // 视线方向

    vec3 sun_color = get_sun_exposure() * get_sun_tint();
    vec3 moon_color = get_moon_exposure() * get_moon_tint();

    vec3 atmosphere = atmosphere_scattering(world_dir, sun_color, sun_dir, moon_color, moon_dir);

    // atmosphere = pow(atmosphere, vec3(1.0 / 2.2));

    // decode
    vec3 normal = decode_unit_vector(gbuffer_data_0.xy);
    // x: 光源亮度, y: 天光亮度
    vec2 light_level = unpack_unorm_2x8(gbuffer_data_0.z);
    uint material_mask = uint(gbuffer_data_0.w * 255.f);

    if (depth == 1.0f)
    {
        scene_color = vec4(draw_sky(world_dir, atmosphere, sun_color), 1.f);
    }
    else
    {
        // scene_color = texture(colortex0, texcoord) *
        //               lighting(scene_pos, normal, world_dir, light_dir, light_level,
        //               material_mask);//这边是布林冯模型
        vec3 albedo = texture(colortex0, texcoord).rgb;
        scene_color = lighting_brdf(albedo, scene_pos, normal, -world_dir, light_dir, material_mask, light_level);
    }
    // scene_color = vec4(vec3(blueNoise()), 1.f);
}
