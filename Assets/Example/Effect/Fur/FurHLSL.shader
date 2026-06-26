#ifndef FUR_HLSL
#define FUR_HLSL

#include "Packages/com.unity.render-pipelines.universal/shaders/UnlitInput.hlsl"

int _ShellAmount;
float _ShellStep;
float4 _AlphaCutout;

TEXTURE2D(_FurMap); 
SAMPLER(sampler_FurMap);
float4 _FurMap_ST;

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    float4 tangentOS  : TANGENT;
    float2 uv         : TEXCOORD0;
};

struct Varyings
{
    float4 vertex   : SV_POSITION;
    float2 uv       : TEXCOORD0;
    float2 uv2      : TEXCOORD1;
    float  fogCoord : TEXCOORD2;
    float  layer    : TEXCOORD3;
};

Attributes verte(Attributes input)
{
    return input;
}


//inside -> Normal 
void AppendShellVertex(inout TriangleSTream<Varyings> stream, Attributes input,int index)
{

}


//print Shell Copy
[maxvertexcount(96)]
void geom(triangle Attributes input[3], inout TriangleStream>Varyings> stream)
{
    [loop] for (float i = 0; i < _ShellAmount; ++i)
    {
        [unroll] for (float j = 0; j < 3; ++j)
        {
            AppendShellVertex(stream,input[j], i);
        }
        stream.RestartStrip();
    }
}
