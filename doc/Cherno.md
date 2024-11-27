# 项目配置

通常的optifine着色器结构为：

< shader name || Shader.zip>

|--------LICENSE

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

## 环境配置以及调试方式

使用Visual Studio Code作为编程环境，下载GLSL Lint，Shader language support for VS Code，Clang-Format三个扩展，下载 []glsl参考编译器](https://github.com/KhronosGroup/glslang/releases)，下载[]clang-format](https://llvm.org/builds/)，打开VSC的setting.json文件，添加以下配置

```json
{
    "glsllint.glslangValidatorPath": "glslangValidator.exe的相对路径或绝对路径",
    "files.associations": {
        "*.vsh": "glsl",
        "*.fsh": "glsl",
        "*.gsh": "glsl",
        "*.csh": "glsl"
    },
    "glsllint.additionalStageAssociations": {
        ".glsl": "vert",
        ".vsh": "vert",
        ".fsh": "frag",
        ".gsh": "geom",
        ".csh": "comp"
    },
    "clang-format.executable": "clang-format.exe的相对路径或绝对路径",
    "editor.formatOnType": true,
    "editor.formatOnSave": true,
}
```

optifine支持#include预编译指令，但标准glsl语法并不支持，所以着色器代码#include部分会报错，可以忽略。

optifine使用`F3+R`可以快捷重新加载

#### 配置RenderDoc调试：

以PCL2作为启动器，选择某一版本导出启动脚本
![alt text](pcl2_bat.png)

得到如下.bat文件
![alt text](lanuch_bat.png)（gb2312编码）

根据启动脚本在RnderDoc的Lanuch Application中添加参数：

Executable Path:  **jave.exe路径**
Working Directory:  **.minecraft文件夹**
Command-line Arguments:  **jave.exe路径后面所有参数**

### 编写注意事项

内置变量，函数，宏等参考以下文档

[Shaders - Development - OptiDocs](https://optifine.readthedocs.io/shaders_dev.html) OptiFine

[The OpenGL Shading Language](https://registry.khronos.org/OpenGL/specs/gl/GLSLangSpec.1.20.pdf) GLSL

由于optifine会自动读取.vch和.fsh文件中的`#ifdef`和`#ifndef`，将其处理为`#define`形式的配置单，所以在不希望形成配置的地方使用`#if defined`替代


