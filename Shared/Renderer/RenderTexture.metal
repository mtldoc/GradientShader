#include <metal_stdlib>
using namespace metal;

struct RenderVertex {
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

[[ vertex ]]
RenderVertex renderTextureVertex(ushort vid [[ vertex_id ]]) {
    return {
        .position = float4(positions[vid], 0.0f, 1.0f),
        .uv = uvs[vid]
    };
}

constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::nearest);

[[ fragment ]]
float4 renderTextureFragment(RenderVertex in [[ stage_in ]],
                             texture2d<float, access::sample> tex [[ texture(0) ]]) {
    return tex.sample(s, in.uv);
}
