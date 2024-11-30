#include "/include/global.glsl"

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

#include "/include/sky/sky.glsl"

/* clang-format off */
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 scene_color;
/* clang-format on */

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D colortex0;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

in vec2 texcoord;
const float hand_depth = 0.56;
void main()
{
    ivec2 texelUV = ivec2(gl_FragCoord.xy);
    float depth = texelFetch(depthtex1, texelUV, 0).x;

    // depth += 0.38 * float(depth < hand_depth);
    vec3 view_pos = vec3(texcoord.x * 2.f - 1.f, texcoord.y * 2.f - 1.f, depth * 2.f - 1.f);
    view_pos = project_and_divide(gbufferProjectionInverse, view_pos);

    vec3 scene_pos = mat3(gbufferModelViewInverse) * view_pos + gbufferModelViewInverse[3].xyz;
    vec3 world_pos = scene_pos;                                             // + cameraPosition;
    vec3 world_dir = normalize(scene_pos - gbufferModelViewInverse[3].xyz); // 视线方向

    if (depth == 1.0f)
    {
        scene_color = vec4(draw_sky(world_dir), 1.f);
    }
    else
    {
        scene_color = texture(colortex0, texcoord);
    }
}

#endif