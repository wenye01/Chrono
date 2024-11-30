
#ifdef vert

in vec3 vaPosition;

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

/* RENDERTARGETS: 01 */
layout(location = 0) out vec3 scene_color;
layout(location = 1) out vec4 gbuffer_data_0;

void main()
{
    scene_color = color.xyz;
}

#endif