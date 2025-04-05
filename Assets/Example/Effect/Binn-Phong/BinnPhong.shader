Shader "URP/BlinnPhong"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("BumpMap", 2D) = "bump"{}
        _specCol("Specular Color", Color) = (1,1,1,1)
        _SpecPow("Specular Power", Range(10,200)) = 100
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_BumpMap); SAMPLER(sampler_BumpMap);

            float4 _specCol;
            float _SpecPow;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.viewDirWS = normalize(_WorldSpaceCameraPos - positionWS);
                float3 tangentWS = normalize(TransformObjectToWorldDir(IN.tangentOS.xyz));
                float3 bitangentWS = cross(OUT.normalWS, tangentWS) * IN.tangentOS.w;
                OUT.tangentWS = tangentWS;
                OUT.bitangentWS = bitangentWS;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, IN.uv));
                float3x3 TBN = float3x3(IN.tangentWS, IN.bitangentWS, IN.normalWS);
                float3 normalWS = normalize(mul(normalTS, TBN));

                float3 lightDirWS = normalize(_MainLightPosition.xyz);
                float3 lightColor = _MainLightColor.rgb;

                float ndotl = saturate(dot(normalWS, lightDirWS));
                float3 diffuse = ndotl * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv).rgb * lightColor;

                float3 viewDir = normalize(IN.viewDirWS);
                float3 halfDir = normalize(lightDirWS + viewDir);
                float spec = pow(saturate(dot(normalWS, halfDir)), _SpecPow);
                float3 specular = spec * _specCol.rgb * lightColor;

                return float4(diffuse + specular, 1.0);
            }
            ENDHLSL
        }
    }
}