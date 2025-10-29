
out vec4 basic_color;

void main()
{
    gl_Position = ftransform();
    basic_color = gl_Color;
}