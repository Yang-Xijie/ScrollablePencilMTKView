// ShaderDefinitions.h

#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h

#include <simd/simd.h>

struct Vertex {
	vector_float2 pos;
};

struct Color {
    vector_float4 color;
};

struct TransfromConfig {
    vector_float2 documentSize;
    vector_float2 scrollViewContentSize;
    vector_float2 scrollViewContentOffset;
    vector_float2 renderViewFrameSize;
    float scrollViewZoomScale;
};

#endif /* ShaderDefinitions_h */
