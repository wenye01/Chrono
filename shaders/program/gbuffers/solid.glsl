#if defined vert

in vec2 vaUV0;
in vec3 vaPosition;
in vec4 vaColor;

uniform mat4 modelViewMatrix;
uniform mat4 porjectionMatrix;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 geoNormal;

void main()
{
    gl_Position = ftransform();
    texcoord = vaUV0;
    glcolor = vaColor.rgb;

    glcolor = gl_Color;
}
#endif
//-----------------------------------------------------------------

//-----------------------------------------------------------------
#if defined frag

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform vec4 entityColor;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main()
{
    color = texture(gtexture, texcoord) * glcolor;
    color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
    color *= texture(lightmap, lmcoord);
    if (color.a < alphaTestRef)
    {
        // discard;
    }
}
#endif