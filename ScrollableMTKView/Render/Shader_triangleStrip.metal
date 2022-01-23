#include <metal_stdlib>
#include "ShaderDefinitions.h"
using namespace metal;

struct VertexOut {
	MetalPosition4 position[[position]];
	unsigned int instanceID;
};

/// draw triangleStrips with a single color
vertex VertexOut
vertexShader_drawTriangleStripWithSingleColor(
	const device MetalPosition2 *vertexArray[[buffer(0)]],
	const device TransfromConfig *transformConfigArray[[buffer(1)]],
	unsigned int vid[[vertex_id]],
	unsigned int iid[[instance_id]]) {

	// MARK: get data from buffers

	MetalPosition2 in = vertexArray[vid];
	TransfromConfig info = *transformConfigArray;

	// MARK: change document coordinate to renderView norm-coordinate

	float x_t = info.renderViewFrameSize[0] * info.scrollViewZoomScale / 2.0;
	float x = (in[0] / info.documentSize[0] * info.scrollViewContentSize[0] - info.scrollViewContentOffset[0] - x_t) / x_t;
	float y_t = info.renderViewFrameSize[1] * info.scrollViewZoomScale / 2.0;
	float y = -1.0 * (in[1] / info.documentSize[1] * info.scrollViewContentSize[1] - info.scrollViewContentOffset[1] - y_t) / y_t; // note minus

	// MARK: return

	VertexOut out = VertexOut();
	out.position = MetalPosition4(x, y, 0, 1);
	out.instanceID = iid;
	return out;
}

// check `5.2.3.4 Fragment Function Input Attributes`
fragment MetalRGBA
fragmentShader_drawTriangleStripWithSingleColor(
	const device MetalRGBA *color[[buffer(0)]],
    unsigned int pid[[primitive_id]]) {
    return color[pid];
}
