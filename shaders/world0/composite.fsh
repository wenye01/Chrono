#version 330 compatibility

#include "/include/distort.glsl"
#include "/include/global.glsl"
#include "/include/shadow/shadowcomp.glsl"

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform sampler2D colortex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowColor0;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main()
{
    ivec2 texelUV = ivec2(gl_FragCoord.xy);
    float depth = texture2D(depthtex0, texcoord).x;

    depth += 0.38 * float(depth < 0.56); // offset hand depth
    vec3 view_pos = vec3(texcoord.x * 2.f - 1.f, texcoord.y * 2.f - 1.f, depth * 2.f - 1.f);
    view_pos = project_and_divide(gbufferProjectionInverse, view_pos);
    vec3 scene_pos = (gbufferModelViewInverse * vec4(view_pos, 1.f)).xyz;

    vec3 differenceScreenX = dFdx(scene_pos);
    vec3 differenceScreenY = dFdy(scene_pos);
    vec3 viewSpaceGeoNormal = normalize(cross(differenceScreenX, differenceScreenY));
    vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * viewSpaceGeoNormal;

    scene_pos = scene_pos + worldGeoNormal * 0.03;
    vec3 shadowViewPos = (shadowModelView * vec4(scene_pos, 1.f)).xyz;
    vec3 shadowNDC = project_and_divide(shadowProjection, shadowViewPos);
    vec3 distortedNDC = vec3(distort(shadowNDC.xy), shadowNDC.z);
    vec3 shadowScreenPos = distortedNDC * 0.5 + 0.5;

    float current = shadowScreenPos.z;
    float shadow0 = texture(shadowtex0, shadowScreenPos.xy).r;
    float shadow1 = texture(shadowtex1, shadowScreenPos.xy).r;
    float shade = current > shadow0 ? 0.0 : 1.0;

    float shade0 = step(current - 0.0001, shadow0);
    float shade1 = step(current - 0.0001, shadow1);

    vec3 shadowColor = pow(texture(shadowColor0, shadowScreenPos.xy).rgb, vec3(2.2));

    color = texture(colortex0, texcoord) * (1 + shade) * 0.5;
}