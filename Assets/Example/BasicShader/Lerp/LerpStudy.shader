Shader "Unlit/LerpStudy"
{

    Properties
    {
        _BaseMap("BaseMap",2D) = "white"{}
        _SubMap("SubMap", 2D) = "white"{}
        //_LerpControl("LerpControl", Range(0,1)) = 0 /
        _LerpControl("LerpControlTexture",2D) = "white"{} //Texture mode
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
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            TEXTURE2D(_SubMap);
            TEXTURE2D(_LerpControlTex);

            SAMPLER(sampler_BaseMap);
            SAMPLER(sampler_SubMap);
            SAMPLER(sampler_LerpControlTex);


            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _SubMap_ST;
                float4 _LerpControlTex_ST;
                //float _LerpControl;

            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv; //uvoutput
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 TextureA = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap,IN.uv);
                half4 TextureB = SAMPLE_TEXTURE2D(_SubMap, sampler_SubMap, IN.uv);
                half4 LerpControlTex = SAMPLE_TEXTURE2D(_LerpControlTex, sampler_LerpControlTex, TRANSFORM_TEX(IN.uv, _LerpControlTex));
               
                half4 finalColor;
                finalColor = lerp(TextureA, TextureB, LerpControlTex.r);
                return finalColor;
            }
            ENDHLSL
        }
    }
}
