Shader "Custom/FresenelOutlineshader"
{

    //FresenelOutlineshader
    //but It doesn't work with black color
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _FresnelPower("Fresnel Power", Float) = 5
        _FresnelColor("Fresnel Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Name "Unlit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
                float3 lightDirWS : TEXCOORD3;
            };

            // 텍스처 선언
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            float4 _BaseColor;
            float _FresnelPower;
            float4 _FresnelColor;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformWorldToHClip(worldPos);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.uv = IN.uv;

                OUT.viewDirWS = normalize(_WorldSpaceCameraPos - worldPos);

                // 단일 Directional Light
                OUT.lightDirWS = normalize(_MainLightPosition.xyz);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 normal = normalize(IN.normalWS);
                float3 lightDir = normalize(IN.lightDirWS);
                float3 viewDir = normalize(IN.viewDirWS);

                float NdotL = dot(normal, lightDir);
                float lightIntensity = (NdotL > 0.7) ? 1.0 : 0.3;

                // Fresnel (rim lighting)
                float rim = pow(1.0 - saturate(dot(normal, viewDir)), _FresnelPower);
                float3 fresnel = _FresnelColor.rgb * rim;

                float4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                float3 base = texColor.rgb * _BaseColor.rgb * lightIntensity;

                float3 finalColor = base + fresnel;

                return float4(finalColor, texColor.a);
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/InternalErrorShader"
}