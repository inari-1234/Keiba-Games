#include <metal_stdlib>
using namespace metal;

// Smooth, continuous displacement keeps the illustration intact at all joints.
[[ stitchable ]] float2 horseMotion(float2 p, float2 size, float time, float running) {
    float2 uv = p / max(size, float2(1.0));
    float frequency = mix(4.0, 13.0, running);
    float phase = time * frequency;
    float2 delta = float2(0.0);
    float legs = smoothstep(0.64, 0.95, uv.y);
    delta.y += legs * sin(phase + uv.x * 18.0) * mix(0.007, 0.018, running);
    delta.x += legs * cos(phase + uv.x * 18.0) * mix(0.004, 0.010, running);
    float tail = (1.0 - smoothstep(0.12, 0.29, uv.x)) * smoothstep(0.31, 0.55, uv.y) * (1.0 - smoothstep(0.84, 1.0, uv.y));
    delta.x += tail * sin(time * 3.2) * 0.012;
    float neck = smoothstep(0.52, 0.79, uv.x) * (1.0 - smoothstep(0.35, 0.62, uv.y));
    delta.y += neck * sin(time * 2.6) * 0.006;
    float ears = smoothstep(0.57, 0.68, uv.x) * (1.0 - smoothstep(0.2, 0.3, uv.y));
    delta.x += ears * sin(time * 4.5) * 0.005;
    float rider = smoothstep(0.16, 0.32, uv.x) * (1.0 - smoothstep(0.47, 0.63, uv.x)) * (1.0 - smoothstep(0.27, 0.48, uv.y));
    delta.y += rider * sin(phase + 0.4) * 0.004;
    return p + delta * size;
}
