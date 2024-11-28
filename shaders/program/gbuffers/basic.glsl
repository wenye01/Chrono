
#ifdef vert

in vec3 vaPosition;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main()
{
    gl_Position = vaPosition;
    color = gl_Color;
}

#endif
//-----------------------------------------------------------------

//-----------------------------------------------------------------
#ifdef frag

in vec4 color;

layout(location = 0) out vec3 scene_color;

void main()
{
    scene_color = color.xyz;
}

#endif