# Optifine光影基础

### 前置知识

Optifine采用延迟渲染技术，请提前了解延迟渲染的基本原理。[LearnOpenGL参考资料](https://learnopengl-cn.github.io/05%20Advanced%20Lighting/08%20Deferred%20Shading/)

执行顺序如下：
**shadow  --->  shadowcomp  --->  prepare  --->  gbuffers  --->  deferred  ---> gbuffers(translucent) --->composite  --->  final**

[Optifine对于着色器的文档](https://optifine.readthedocs.io/shaders_dev/programs.html)

其中**shadow**着色器仅有一个
**shadowcomp，prepare，deferred，composite**依次从0到99，这些着色器是可选的并且依次按顺序从小到大依次执行
**gbuffers**着色器有固定的名称，类似前向着色器一样依次渲染不同的物体到texture中
**deferred和composite**着色器对gbuffers输出的纹理进行计算
最后经过**final**着色器输出到屏幕上

### 内置变量

除了glsl自身带有的以gl_开头的内置变量外，optifine还额外添加了许多内置变量，可以参考optifine的[文档](https://optifine.readthedocs.io/shaders_dev/uniforms.html)进行查询，主要包括了各种矩阵变换，主要物体坐标，物品ID，各种纹理等，使用时使用uniform进行声明
此外还可以自行添加额外的内置变量，这些变量将在着色器执行前提前计算。
在shaders.properties文件中，使用 `variable.<typename>.<name>`声明局部变量，可以使用optifine的内置变量进行计算，最后将值赋给`uniform.<typename>.<name>`，在着色器中声明 `uniform <typename> <name>` 即可使用该变量，变量的运算逻辑与glsl一致

### 着色器输出与内置纹理

由于延迟渲染架构，并且采用了MRT（多渲染目标）技术，所有着色器的输出都是纹理（帧缓冲），并且可以同时输出给多个纹理，纹理间的区分通过int类型的id实现
各着色器阶段可以使用的纹理不同，可以查询[optifine文档](https://optifine.readthedocs.io/shaders_dev/textures.html)
vertex着色器必须输出gl_Position，这是GLSL要求的，fragment着色器默认向该着色器阶段的0号缓冲输出数据，可以通过gl_FragData进行输出
如果想要向多个纹理进行输出，需要使用layout关键字进行声明输出的顺序，并且使用`/* DRAWBUFFERS:<id> */` 或者 `/* RENDERTARGETS: <id> */`声明输出的纹理对象，例如
`layout(location = 0) out vec4 color;`
`layout(location = 1) out vec4 gbuffer_data_0;`
`/* DRAWBUFFERS:01 */`
或者
`layout(location = 0) out vec3 min_color;`
`layout(location = 1) out vec3 max_color;`
`/* RENDERTARGETS: 67 */`
通常使用DRAWBUFFERS声明，该声明可以在layout前面也可以在后面，但**必须顶格，且中间空格不能省略，格式需要一模一样**，由于本项目使用了clang-format进行自动格式化，可能会导致其格式发生变换，可以在使用
`/* clang-format off */`
`your code`
`/* clang-format on */`
将其围住，避免自动格式化，同样**必须顶格，格式必须完全一致**

### 设置和翻译

optifine自动读取block.properties，entity.properties，item.properties，shaders.properties作为着色器的配置，其中shaders.properties是着色器的光影设置面板，其余则是方块ID
optifine中有内置变量mc_Entity记录当前所计算顶点的物品id，以此可以对不同的物品做不同的处理，在block.properties，entity.properties，item.properties中分别对不同的物品自定义不同的id，格式为`<block/entity/item>.<id> = name`，其中name为mc对物品的内置名称，id自定义，可以多个物品共同使用同一id，中间使用空格分隔，为避免自定义的id与内置id冲突，一般id会从10001开始计
shaders.properties控制选择光影时的光影设置面板，以及自定义纹理，自定义内置变量，lang文件夹中的.lang文件对shaders.propertie中的设置进行翻译以及文本对应。

# Cherno
本项目的框架如下

## world\<id\>
world\<id>文件夹下将放所有gbuffer_*，deferred，composite，final着色器文件，其中gbuffer_*着色器负责将需要的信息写入帧缓冲，通常有**几何、基础颜色，材质信息**，gbuffers_*系列着色器会有很多重复内容，将其抽取出来放在program/gbuffers目录下，用`#if defined vert`和`#if defined frag`来区分vsh或者fsh，一些较长的着色器则会单独写在一个glsl文件里，而非合并为一个。

### 杂项

1. lightmap为亮度贴图，类似于2DLUT图，使用vaUV2或gl_MultiTexCoord1经过计算后可以得到正确的采样值，其中x坐标代表光源亮度，y坐标表示天光亮度


