# 项目配置

通常的optifine着色器结构为：

< shader name || Shader.zip>

├--------LICENSE

|--------README

|--------shaders（具体着色器所在文件夹）

            |--------image/texture（纹理图片）

            |--------include/lib（通用着色器）

            |--------lang（语言/翻译文件）

            |--------program（着色器文件）

            |--------world0（主世界着色器）

            |--------world1（末地着色器）

            |--------world-1（下界着色器）

            |--------world< id >（mod维度着色器）

            |--------*.properties（光影，物品配置）

optifine可识别的着色器后缀名为.vsh(vertex shader)，.fsh(fragment shader)，.gsh(gerometry shader)，.csh(compute shader)，

除着色器文件外，doc文件夹内为本项目文档

.clang-format文件为代码格式配置，使用clang-format运行

package.bat文件打包项目为常用的.zip光影包
