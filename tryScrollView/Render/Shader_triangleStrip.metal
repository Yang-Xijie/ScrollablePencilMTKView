#include <metal_stdlib>
#include "ShaderDefinitions.h"
using namespace metal;

struct VertexOut {
	float4 pos[[position]];
};

/// draw triangleStrips with a single color
vertex VertexOut
vertexShader_drawTriangleStripWithSingleColor(
	const device Vertex *vertexArray[[buffer(0)]],
	const device TransfromConfig *transformConfigArray[[buffer(1)]],
	unsigned int vid[[vertex_id]]) {

	// MARK: take data out from the buffer

	Vertex in = vertexArray[vid];
	TransfromConfig info = *transformConfigArray;

	// MARK: change document coordinate to renderView norm-coordinate

	float x_t = info.renderViewFrameSize[0] * info.scrollViewZoomScale / 2.0;
	float x = (in.pos.x / info.documentSize[0] * info.scrollViewContentSize[0] - info.scrollViewContentOffset[0] - x_t) / x_t;
	float y_t = info.renderViewFrameSize[1] * info.scrollViewZoomScale / 2.0;
	float y = -1.0 * (in.pos.y / info.documentSize[1] * info.scrollViewContentSize[1] - info.scrollViewContentOffset[1] - y_t) / y_t; // note minus

	// MARK: return

	VertexOut out;
	out.pos = float4(x, y, 0, 1);
	return out;
}

fragment float4
fragmentShader_drawTriangleStripWithSingleColor(
	const device float4 *color[[buffer(0)]]) {
	return *color;
}
