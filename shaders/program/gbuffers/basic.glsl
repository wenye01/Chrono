
#if defined vert

out vec4 color;

void main()
{
    gl_Position = ftransform();
    color = gl_Color;
}

#endif
//-----------------------------------------------------------------

//-----------------------------------------------------------------
#if defined frag

in vec4 color;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 scene_color;

void main()
{
    scene_color = color;
}

#endif