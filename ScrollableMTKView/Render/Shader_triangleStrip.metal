#include <metal_stdlib>
#include "ShaderDefinitions.h"
using namespace metal;

struct VertexOut {
	MetalPosition4 position[[position]];
	MetalRGBA color;
};

/// draw triangleStrips with a single color
vertex VertexOut
vertexShader_drawTriangleStripWithSingleColor(
	const device VertexIn *vertexArray[[buffer(0)]],
	constant TransfromConfig *transformConfigArray[[buffer(1)]],
	unsigned int vid[[vertex_id]]) {

	// MARK: get data from buffers

	VertexIn in = vertexArray[vid];
	TransfromConfig info = *transformConfigArray;

	// MARK: change document coordinate to renderView norm-coordinate

	float x_t = info.renderViewFrameSize[0] * info.scrollViewZoomScale / 2.0;
	float x = (in.position[0] / info.documentSize[0] * info.scrollViewContentSize[0] - info.scrollViewContentOffset[0] - x_t) / x_t;
	float y_t = info.renderViewFrameSize[1] * info.scrollViewZoomScale / 2.0;
	float y = -1.0 * (in.position[1] / info.documentSize[1] * info.scrollViewContentSize[1] - info.scrollViewContentOffset[1] - y_t) / y_t; // note minus

	// MARK: return

	VertexOut out = VertexOut();
	out.position = MetalPosition4(x, y, 0, 1);
	out.color = { in.r / 256.0, in.g / 256.0, in.b / 256.0, in.alpha };
	return out;
}

// check `5.2.3.4 Fragment Function Input Attributes`
fragment MetalRGBA
fragmentShader_drawTriangleStripWithSingleColor(
	VertexOut in[[stage_in]]) {
	return in.color;
}
