Shader "Unlit/ColorShader"
{
   //Change Color at Inspector
    Properties
    {
        _R("R", Range(0,1)) = 0
        _G("G", Range(0,1)) = 0
        _B("B", Range(0,1)) = 0

        _Emission("Emission", Range(-1,1)) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


            //Setting C Buffer 
            //Now this shader use SRP Batcher 
            CBUFFER_START(UnityPerMaterial)
            float _R;
            float _G;
            float _B;

            float _Emission;
            CBUFFER_END 

            struct Attributes
            {
                float4 positionOS   : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag() : SV_Target
            {
                float4 ColorRange;
                ColorRange.rgb = float3(_R,_G,_B);
                ColorRange.rgb += _Emission;
                ColorRange.a = 1;

                return ColorRange;
            }
            ENDHLSL
        }
    }


}
