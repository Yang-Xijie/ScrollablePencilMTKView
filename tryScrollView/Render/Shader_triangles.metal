#include <metal_stdlib>
#include "ShaderDefinitions.h"
using namespace metal;

struct VertexOut {
	float4 pos[[position]];
	float4 color;  // use the color of the first vertex in fragment process // check `5.4 Sampling and Interpolation Attributes`
};

/// draw triangles each with a single color
vertex VertexOut
vertexShader_drawTrianglesWithSingleColor(
	const device Vertex *vertexArray[[buffer(0)]],
	const device Color *colorArray[[buffer(1)]],
	const device TransfromConfig *transformConfig[[buffer(2)]],
	unsigned int vid[[vertex_id]],
    unsigned int iid[[instance_id]]) {

	// MARK: take data out from the buffer

	Vertex in = vertexArray[vid + iid * 3];
	TransfromConfig info = *transformConfig;

	// MARK: change document coordinate to renderView norm-coordinate

	float x_t = info.renderViewFrameSize[0] * info.scrollViewZoomScale / 2.0;
	float x = (in.pos.x / info.documentSize[0] * info.scrollViewContentSize[0] - info.scrollViewContentOffset[0] - x_t) / x_t;
	float y_t = info.renderViewFrameSize[1] * info.scrollViewZoomScale / 2.0;
	float y = -1.0 * (in.pos.y / info.documentSize[1] * info.scrollViewContentSize[1] - info.scrollViewContentOffset[1] - y_t) / y_t; // note minus

	// MARK: return

	VertexOut out;
	out.pos = float4(x, y, 0, 1);
	out.color = colorArray[iid].color; // three vertices own the same color
	return out;
}

fragment float4
fragmentShader_drawTrianglesWithSingleColor(VertexOut fragData[[stage_in]]) {
    return fragData.color;
}
