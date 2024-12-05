#if !defined PACK_GLSL
#define PACK_GLSL

vec2 sign_non_zero(vec2 v)
{
    return vec2(v.x >= 0.0 ? 1.0 : -1.0, v.y >= 0.0 ? 1.0 : -1.0);
}

// 将vec3 编码为vec2，减轻带宽压力
// http://jcgt.org/published/0003/02/01/
vec2 encode_unit_vector(vec3 v)
{
    // Project the sphere onto the octahedron, and then onto the xy plane
    vec2 p = v.xy * (1.0 / (abs(v.x) + abs(v.y) + abs(v.z)));

    // Reflect the folds of the lower hemisphere over the diagonals
    p = v.z <= 0.0 ? ((1.0 - abs(p.yx)) * sign_non_zero(p)) : p;

    // Scale to [0, 1]
    return 0.5 * p + 0.5;
}

vec3 decode_unit_vector(vec2 e)
{
    // Scale to [-1, 1]
    e = 2.0 * e - 1.0;

    // Extract Z component
    vec3 v = vec3(e.xy, 1.0 - abs(e.x) - abs(e.y));

    // Reflect the folds of the lower hemisphere over the diagonals
    if (v.z < 0)
        v.xy = (1.0 - abs(v.yx)) * sign_non_zero(v.xy);

    return normalize(v);
}

// https://github.com/Jessie-LC/open-source-utility-code/blob/main/advanced/packing.glsl

// 两个4位压缩到一个float
float pack_unorm_2x4(vec2 xy)
{
    return dot(floor(15.0 * xy + 0.5), vec2(1.0 / 255.0, 16.0 / 255.0));
}
float pack_unorm_2x4(float x, float y)
{
    return pack_unorm_2x4(vec2(x, y));
}

vec2 unpack_unorm_2x4(float pack)
{
    vec2 xy;
    xy.x = modf((255.0 / 16.0) * pack, xy.y);
    return xy * vec2(16.0 / 15.0, 1.0 / 15.0);
}
// 两个8位压缩到一个16位，精度有点差
float pack_unorm_2x8(vec2 v)
{
    return dot(floor(255.0 * v + 0.5), vec2(1.0 / 65535.0, 256.0 / 65535.0));
}
float pack_unorm_2x8(float x, float y)
{
    return pack_unorm_2x8(vec2(x, y));
}

vec2 unpack_unorm_2x8(float pack)
{
    vec2 xy;
    xy.x = modf((65535.0 / 256.0) * pack, xy.y);
    return xy * vec2(256.0 / 255.0, 1.0 / 255.0);
}

#endif