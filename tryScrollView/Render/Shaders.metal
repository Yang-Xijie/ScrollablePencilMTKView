// Shaders.metal

#include <metal_stdlib>
#include "ShaderDefinitions.h"
using namespace metal;

struct VertexOut {
	float4 color;
	float4 pos[[position]];
	float pointsize[[point_size]] = 100.0; // TODO: use msaa to 'soften' edges with a resolvetexture
};

/// return the position and color of each pixel in the triangle
///
/// the vertex shader will take the entire buffer (actually a pointer to it) and a vertex ID which indexes into this buffer as input
///
/// Vertex shaders which simply pass data through mostly unchanged to the rasterizer are a very common pattern, and are called pass-through vertex shaders.
vertex VertexOut vertexShader(
	const device Vertex *vertexArray[[buffer(0)]], // consistent with: `renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)`
    const device Color *colorArray[[buffer(1)]],
    unsigned int vid[[vertex_id]])
{
	Vertex in = vertexArray[vid];

	VertexOut out;
    out.color = colorArray[vid / 3].color;

	out.pos = float4(in.pos.x, in.pos.y, 0, 1);

	return out;
}

/// return the color of each pixel in the given triangle
///
/// `interpolated` is the returned result of `vertexShader` for each pixel
///
/// draw a smooth circle: https://stackoverflow.com/questions/59367916/ios-metal-jaggies-anit-aliasing
fragment float4 fragmentShader(
	VertexOut fragData[[stage_in]],
	float2 pointCoord[[point_coord]])
{
     return fragData.color;
}
