#if !defined DISTORT
#define DISTORT

#define SHADOW_MAP_BIAS 0.75

vec2 distort(vec2 shadowTexturePosition)
{
    float distanceFromPlayer = length(shadowTexturePosition);
    vec2 distortedPosition = shadowTexturePosition / mix(1.0, distanceFromPlayer, 0.9);
    return distortedPosition;
}

#endif