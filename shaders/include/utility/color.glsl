#if !defined COLOR
#define COLOR

#include "/include/global.glsl"

// 不同颜色空间rgb对应波长(nm)
#define primary_wavelengths_rec709 vec3(660.0, 550.0, 440.0)
#define primary_wavelengths_rec2020 vec3(660.0, 550.0, 440.0)
#define primary_wavelengths_blackbody vec3(630.0, 530.0, 465.0)

/* clang-format off */
// Rec. 709 (sRGB primaries)
const mat3 xyz_to_rec709 = mat3(
	 3.2406, -1.5372, -0.4986,
	-0.9689,  1.8758,  0.0415,
	 0.0557, -0.2040,  1.0570
);
const mat3 rec709_to_xyz = mat3(
	 0.4124,  0.3576,  0.1805,
	 0.2126,  0.7152,  0.0722,
	 0.0193,  0.1192,  0.9505
);

// Rec. 2020 (working color space)
const mat3 xyz_to_rec2020 = mat3(
	 1.7166084, -0.3556621, -0.2533601,
	-0.6666829,  1.6164776,  0.0157685,
	 0.0176422, -0.0427763,  0.94222867
);
const mat3 rec2020_to_xyz = mat3(
	 0.6369736, 0.1446172, 0.1688585,
	 0.2627066, 0.6779996, 0.0592938,
	 0.0000000, 0.0280728, 1.0608437
);
/* clang-format on */

const mat3 rec709_to_rec2020 = rec709_to_xyz * xyz_to_rec2020;
const mat3 rec2020_to_rec709 = rec2020_to_xyz * xyz_to_rec709;

#define from_srgb(x) (pow(x, vec3(2.2)) * rec709_to_rec2020)

#define display_to_working_color rec709_to_rec2020
#define working_to_display_color rec2020_to_rec709
#define rec709_to_working_color rec709_to_rec2020

// 黑体辐射 https://github.com/Jessie-LC/open-source-utility-code/tree/main
vec3 blackbody(in float t)
{
    const float h = 6.63e-16; // 普朗克常数
    const float c = 3.0e17;   // 光速
    const float k = 1.38e-5;  // 玻尔兹曼常数

    vec3 p1 = pow(primary_wavelengths_blackbody, vec3(5.0)) / (2.0 * h * c * c);
    vec3 p2 = exp((h * c) / (k * t) / primary_wavelengths_blackbody);

    vec3 rgb = p1 * p2 - p1;
    return min_of(rgb) / rgb;
}

#endif