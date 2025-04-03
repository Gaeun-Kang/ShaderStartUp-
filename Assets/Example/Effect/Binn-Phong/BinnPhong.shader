Shader "Unlit/BinnPhong"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}

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

           sampler2D _MainTex;


            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv_MainTex;
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
             
            }
            ENDHLSL
        }
    }

}
