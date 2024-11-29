#version 330 compatibility

// 后处理阶段进行
// uniform sampler2D gtexture;

// uniform float alphaTestRef = 0.1;

// in vec2 texcoord;
// in vec4 glcolor;

// /* RENDERTARGETS: 0 */
// layout(location = 0) out vec4 color;

// void main()
// {
//     color = texture(gtexture, texcoord) * glcolor;
//     if (color.a < alphaTestRef)
//     {
//         discard;
//     }
// }
void main()
{
    discard;
}