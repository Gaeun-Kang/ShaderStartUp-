Shader "Custom/ShaderAnimation"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white"{}
        _Speed("Speed", float) = 1
    }

    SubShader
    {
       Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" }
   
    Pass
    {
        HLSLPROGRAM
        #pragma vertex vert
        #pragma fragment frag 

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        struct Attributes
        {
            float4 positionOS : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct Varyings
        {
            float4 positionHCS : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityMaterial)
			 float4 _MainTex_ST;
             float _Speed;
             CBUFFER_END 

    
        Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(float2(IN.uv.x, IN.uv.y + _Time.y * _Speed), _MainTex);
                return OUT;
            }


        half4 frag(Varyings IN) : SV_Target
        {   
            half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
            return color;
        }
        ENDHLSL

        }
    }
}
