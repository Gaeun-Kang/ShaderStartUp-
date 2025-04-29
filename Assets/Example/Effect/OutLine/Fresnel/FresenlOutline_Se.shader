Shader "Unlit/FresenlOutline_Se"
{ 
    Properties
    {
        _OutlineColor ("Outline Color", Color) = (1,1,1,1)
        _OutlineThickness ("Outline Thickness", Float) = 0.02
        _FresnelPower ("Fresnel Power", Float) = 3.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            Name "OutlinePass"
            Cull Front
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 _OutlineColor;
            float _OutlineThickness;
            float _FresnelPower;

            struct appdata
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 viewDirWS : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                float3 posWS = TransformObjectToWorld(v.positionOS);
                float3 normalWS = TransformObjectToWorldNormal(v.normalOS);

                posWS += normalWS * _OutlineThickness;

                o.positionCS = TransformWorldToHClip(posWS);
                o.normalWS = normalize(normalWS);
                o.viewDirWS = normalize(_WorldSpaceCameraPos - posWS);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float fresnel = pow(1.0 - saturate(dot(i.normalWS, i.viewDirWS)), _FresnelPower);
                
                // 중심부는 아예 알파값 0으로 보내버리기
                if (fresnel < 0.01)
                    discard;

                return float4(_OutlineColor.rgb, fresnel * _OutlineColor.a);
            }

            ENDHLSL
        }
    }
    FallBack Off
}
