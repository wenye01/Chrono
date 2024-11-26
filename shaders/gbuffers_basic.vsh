#version 460

out vec4 color;

void main() {
  gl_Position = ftransform();
  color = gl_Color;
}