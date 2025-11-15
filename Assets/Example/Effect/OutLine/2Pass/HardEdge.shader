Shader "Custom/HardEdge"
{
    Properties
    {
        _OutlineColor("Outline Color", Color) = (1,0,0,1)
        _OutlineThickness("Outline Thickness", Float) = 0.01

    }

  SubShader
  {

    Pass 
    {
              Tags { "RenderType" = "Opaque" "RenderPiepeline" = "UniversalPipeline" }
              Cull Front

                HLSLPROGRAM
                #pragma vertex v
                #pragma fragment f 
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

                struct Attributes
                {
                    float4 positionOS   : POSITION;
                    float3 normalOS     : NORMAL;
                };

                struct Varyings
                {
                    float4 positionHCS  : SV_POSITION;
                };

                CBUFFER_START(UnityPerMaterial)
                float4 _OutlineColor;
                float  _OutlineThickness;
                CBUFFER_END

                Varyings v(Attributes IN)
                {

                   Varyings OUT;
                   float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                   float3 normalWS = TransformObjectToWorldNormal(IN.normalOS.xyz);
                   positionWS += normalWS * _OutlineThickness  * 0.01;
                   OUT.positionHCS = TransformWorldToHClip(positionWS);

                    return OUT;
                }

                half4 f(Varyings IN) : SV_Target
                {
                    return _OutlineColor;
                }
        ENDHLSL
            }

          }
        }
           


