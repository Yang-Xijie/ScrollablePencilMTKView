// ShaderDefinitions.h

#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h

#include <simd/simd.h>

typedef vector_float2 MetalPosition2;
typedef vector_float4 MetalPosition4;
typedef vector_float4 MetalRGBA;

struct TransfromConfig {
    vector_float2 documentSize;
    vector_float2 scrollViewContentSize;
    vector_float2 scrollViewContentOffset;
    vector_float2 renderViewFrameSize;
    float scrollViewZoomScale;
};

#endif /* ShaderDefinitions_h */
