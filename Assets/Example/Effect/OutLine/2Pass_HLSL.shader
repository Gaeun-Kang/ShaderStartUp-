Shader "Unlit/2Pass_HLSL"
{

	Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _OutlineThickness("Outline Thickness", Float) = 0.01
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
    }

    SubShader
    {
        Tags {"RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" }
        Pass // First Pass: Outline (inverted normals, front face culled)
        {
            Name "Outline"
            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            float _OutlineThickness;
            float4 _OutlineColor;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 offset = IN.normalOS * _OutlineThickness;
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz + offset);
                OUT.positionHCS = TransformWorldToHClip(positionWS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                return _OutlineColor;
            }
            ENDHLSL
        }

        Pass // Second Pass: Main texture
        {
            Name "MainTex"
            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

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

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                return half4(1.0 - col.rgb, col.a); // »ö ¹ÝÀü
            }
            ENDHLSL
        }
    }

}
