#include "/include/global.glsl"

#if defined vert

out vec2 texcoord;
out vec4 glcolor;
out vec2 sky_uv;

void main()
{
    gl_Position = ftransform();

    sky_uv = mat2(gl_TextureMatrix[0]) * gl_MultiTexCoord0.xy + gl_TextureMatrix[0][3].xy;
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glcolor = gl_Color;
}

#endif
//-----------------------------------------------------------------

//-----------------------------------------------------------------
#if defined frag

uniform sampler2D gtexture;

uniform int renderStage; // https://optifine.readthedocs.io/shaders_dev/preprocessor.html#j-render-stages

uniform float alphaTestRef = 0.1;

in vec2 sky_uv;
in vec2 texcoord;
in vec4 glcolor;

/* clang-format off */
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 scene_color;
/* clang-format on */

// 原版天空
void main()
{
    vec2 offset;
    switch (renderStage)
    {
    case MC_RENDER_STAGE_CUSTOM_SKY:
        scene_color.a = 4.0 / 255.0;
        scene_color.rgb = texture(gtexture, sky_uv).rgb;
        break;
    case MC_RENDER_STAGE_SUN:
#ifdef VANILLA_SUN
        scene_color.a = 255.0 / 255.0;
        offset = sky_uv * 2.0f - 1.0f;
        if (max_of(abs(offset)) > 0.25)
        {
            discard;
        }
        scene_color.rgb = texture(gtexture, sky_uv).rgb;
#endif
        break;
    case MC_RENDER_STAGE_MOON:
#ifdef VANILLA_MOON
        scene_color.a = 255.0 / 255.0;
        offset = fract(vec2(4.0, 2.0) * sky_uv);
        offset = offset * 2.0f - 1.0f;
        if (max_of(abs(offset)) > 0.25)
            discard;

        scene_color.rgb = texture(gtexture, sky_uv).rgb;

        break;
#endif
        break;
    case MC_RENDER_STAGE_STARS:
        break;
    default:
        discard;
    }
}

#endif