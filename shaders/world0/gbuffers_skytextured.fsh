#version 330 compatibility

#define frag
//#include "/program/gbuffers/skytextured.glsl"
uniform sampler2D tex;
in vec4 glcolor;
in vec2 texcoord;
layout(location = 0) out vec4 color;

void main()
{

    vec4 albedo = texture(tex, texcoord);

    if (albedo.a < 0.1)
    {
        discard;
    }

    color = glcolor * albedo;
}