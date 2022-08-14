// Gradient Shader for arbitrary gradient stops, three gradient types and rotation
// For the details please visit: https://mtldoc.com/metal/2022/08/04/shaders-explained-gradients.html

#include <metal_stdlib>
using namespace metal;

// MARK: - Gradient Texture

struct GradientTextureVertex {
    float4 position [[ position ]];
    float4 color;
};

[[ vertex ]]
GradientTextureVertex gradientTextureVertex(constant float* positions [[ buffer(0) ]],
                                            constant float4* colors [[ buffer(1) ]],
                                            const ushort vid [[ vertex_id ]]) {
    return {
        .position = float4(fma(positions[vid], 2.0f, -1.0f), 0.0f, 0.0f, 1.0f),
        .color = colors[vid]
    };
}

[[ fragment ]]
float4 gradientTextureFragment(GradientTextureVertex in [[ stage_in ]]) {
    return in.color;
}

// MARK: - Gradient

enum GradientType: uchar {
    kLinear,
    kRadial,
    kAngular
};

struct GradientVertex {
    float4 position [[ position ]];
    float2 uv;
};

constant float2 positions[4] {
    { -1.0f,  1.0f },
    { -1.0f, -1.0f },
    {  1.0f,  1.0f },
    {  1.0f, -1.0f }
};

constant float2 uvs[4] {
    { 0.0f, 0.0f },
    { 0.0f, 1.0f },
    { 1.0f, 0.0f },
    { 1.0f, 1.0f }
};

constant float PI = 3.1415926f;

[[ vertex ]]
GradientVertex gradientVertex(constant float2x2& rotationTransform [[ buffer(0) ]],
                              const ushort vid [[ vertex_id ]]) {
    return {
        .position = float4(positions[vid], 0.0f, 1.0f),
        .uv = (uvs[vid] - float2(0.5f)) * rotationTransform + float2(0.5f)
    };
}

[[ fragment ]]
float4 gradientFragment(GradientVertex in [[ stage_in ]],
                        texture2d<float, access::sample> gradientTexture [[ texture(0) ]],
                        constant GradientType& gradientType [[ buffer(0) ]]) {
    constexpr sampler s(filter::linear, coord::normalized, address::clamp_to_edge);

    float2 texCoords;
    switch (gradientType) {
        case kLinear:
            texCoords = in.uv;
            break;
        case kRadial:
            texCoords = length(in.uv - float2(0.5f)) * 2.0f;
            break;
        case kAngular:
            const float2 offsetUV = in.uv - float2(0.5f);
            const float angle = atan2(offsetUV.y, offsetUV.x);
            texCoords = float2(fma(angle / PI, 0.5f, 0.5f), 0.0f);
            break;
    }

    return gradientTexture.sample(s, texCoords);
}
