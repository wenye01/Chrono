#version 330 compatibility

in vec3 vaPosition;
in vec2 vaUV0;

uniform vec3 chunkOffset;
uniform vec3 cameraPostion;

uniform mat4 modelViewMatrix;
uniform mat4 porjectionMatrix;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

void main()
{
    // texcoord = vaUV0;

    vec3 worldVertexPosition =
        cameraPostion + (gbufferModelViewInverse * modelViewMatrix * vec4(vaPosition + chunkOffset, 1.f)).xyz;

    float distanceFromCamera = distance(worldVertexPosition, cameraPostion);

    gl_Position = gbufferProjection * modelViewMatrix * vec4(vaPosition + chunkOffset - 0.01 * distanceFromCamera, 1.f);

    // gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;
}