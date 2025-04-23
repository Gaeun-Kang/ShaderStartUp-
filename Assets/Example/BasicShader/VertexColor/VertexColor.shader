Shader "Custom/VertexColor"
{
    
    Properties
    {
        _BaseMap("BaseMap",2D) = "white"{}
        _BaseMap2("BaseMap2",2D) = "white"{}
        _BaseMap3("BaseMap3",2D) = "white"{}
        _BaseMap4("BaseMap4",2D) = "white"{}

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

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
                float4 color : COLOR; //GET VERTEX Color
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float4 color : COLOR; //print vertex Color
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                OUT.color = IN.color;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, TRANSFORM_TEX(IN.uv, _BaseMap));
                half4 vcolor = IN.color; 
                return color * vcolor;
            }
            ENDHLSL
        }
    }

}
