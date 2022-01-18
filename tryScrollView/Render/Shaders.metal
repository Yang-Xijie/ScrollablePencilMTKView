#include <metal_stdlib>
#include "ShaderDefinitions.h"
using namespace metal;

struct VertexOut {
	float4 color;
	float4 pos[[position]];
};

vertex VertexOut vertexShader(
	const device Vertex *vertexArray[[buffer(0)]], // consistent with: `renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)`
	const device Color *colorArray[[buffer(1)]],
	const device TransfromConfig *transformConfigArray[[buffer(2)]],
	unsigned int vid[[vertex_id]]) {
	Vertex in = vertexArray[vid];
	TransfromConfig info = transformConfigArray[0];
	VertexOut out;

    // MARK: change document coordinate to renderView norm-coordinate
	float x_t = info.renderViewFrameSize[0] * info.scrollViewZoomScale / 2.0;
	float x = (in.pos.x / info.documentSize[0] * info.scrollViewContentSize[0] - info.scrollViewContentOffset[0] - x_t) / x_t;
	float y_t = info.renderViewFrameSize[1] * info.scrollViewZoomScale / 2.0;
	float y = -1.0 * (in.pos.y / info.documentSize[1] * info.scrollViewContentSize[1] - info.scrollViewContentOffset[1] - y_t) / y_t; // note minus
	out.pos = float4(x, y, 0, 1);

	out.color = colorArray[vid / 3].color; // three vertices own the same color
	return out;
}

fragment float4 fragmentShader(VertexOut fragData[[stage_in]]) {
	return fragData.color;
}
