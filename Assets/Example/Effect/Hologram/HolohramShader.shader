Shader "URP/HologramShader"

//Make Hologram Shader
//With Rim Right + Alpha
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _R("R", Range(0,1)) = 0
        _G("G", Range(0,1)) = 0
        _B("B", Range(0,1)) = 0

        _Hologram("Hologram", Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha //https://docs.unity3d.com/kr/530/Manual/SL-Blend.html
            Zwrite Off //On Depth Buffer or not 
            Cull Back 

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            float _R;
            float _G;
            float _B;

            float _Hologram;


            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : NORMAL;
                float3 viewDirWS : TEXCOORD1;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.viewDirWS = normalize(_WorldSpaceCameraPos - TransformObjectToWorld(IN.positionOS.xyz));
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                half3 emission = float3(_R,_G,_B); // 초록빛 효과

                // Rim Light 효과
                float rim = 1.0 - saturate(dot(IN.normalWS, IN.viewDirWS));
                rim = pow(rim, 1); 
                emission.rgb = float3(_R,_G,_B);
                texColor.a = rim * _Hologram;

                return half4(texColor.rgb + emission * rim, texColor.a);
            }
            ENDHLSL
        }
    }
}