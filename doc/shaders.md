### gbuffer_basic:

基础的gbuffer渲染，gbuffer_line似乎也被包含进来，

### gbuffer_texture:

半透明物体处理

### gbuffer_skybasic:

为gbuffer_skytexture的下位替代，不处理

### gbuffer_skytextured:

天空计算，目前处理原版天空，新的天空在deferred阶段按照shader toy的方式重新算一个

### gbuffer_spidereyes:

蜘蛛眼睛的效果，这东西怎么还有单独的着色器

### gbuffer_beaconbeam:

信标光束

### gbuffer_armor_glint:

盔甲光芒

### gbuffer_clouds:

云

### gbuffer_textured_lit:

与gbuffer_texture没什么区别，可以不用

### gbuffer_entites:

实体的渲染

### gbuffer_hand:

玩家手的渲染

### gbuffer_hand_water:

手持半透明物体

### gbuffer_weather:

天气，雪天，雨天

### gbuffer_terrain:

不透明几何体，玻璃在里面，染色玻璃在water里

### gbuffer_block:

方块实体

### gbuffer_damageblock:

受伤？不透明块

### gbuffer_water:

半透明物体
