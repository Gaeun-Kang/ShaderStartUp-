Shader "Unlit/Clip Space Outline_HLSL"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (0, 0, 0, 1)
        _OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineSize ("Outline Size", Range(0,0.1)) = 0.003
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        HLSLINCLUDE

        // ============================================================
        // Properties
        // ============================================================
        float4 _Color;
        float4 _OutlineColor;
        float _OutlineSize;

        // Unity 기본 유니폼들
        float4x4 unity_ObjectToWorld;
        float4x4 unity_WorldToObject;
        float4x4 unity_MatrixVP;
        float4x4 UNITY_MATRIX_MV;
        float4x4 UNITY_MATRIX_IT_MV;
        float4x4 UNITY_MATRIX_VP;

        float4 _WorldSpaceLightPos0; // 메인 라이트

        // ============================================================
        // Helpers
        // ============================================================
        float4 ObjectToClipPos(float3 positionOS)
        {
            float4 posWS = mul(unity_ObjectToWorld, float4(positionOS, 1.0));
            return mul(unity_MatrixVP, posWS);
        }

        float3 ObjectToWorldNormal(float3 normalOS)
        {
            return normalize(mul((float3x3)unity_WorldToObject, normalOS));
        }

        // ============================================================
        // Structs
        // ============================================================
        struct appdata
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
        };

        struct v2f
        {
            float4 pos : SV_POSITION;
            float3 normal : TEXCOORD1;
        };
        ENDHLSL

        // ============================================================
        // First Pass (Lit base)
        // ============================================================
        Pass
        {
            Name "BASE"

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = ObjectToClipPos(v.vertex.xyz);
                o.normal = ObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = saturate(dot(normalize(i.normal), L));
                return NdotL * _Color;
            }
            ENDHLSL
        }

        // ============================================================
        // Second Pass (Outline)
        // ============================================================
        Pass
        {
            Name "OUTLINE"
            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct v2f2
            {
                float4 pos : SV_POSITION;
            };

            v2f2 vert(appdata v)
            {
                v2f2 o;

                // MVP 좌표
                float4 pos = ObjectToClipPos(v.vertex.xyz);

                // 노멀 → 뷰공간
                float3 normVS = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);

                // View -> Projection (간단히 xy만 사용)
                float2 offset = normVS.xy;

                // 클립 공간 좌표 보정
                pos.xy += offset * pos.w * _OutlineSize;

                o.pos = pos;
                return o;
            }

            float4 frag(v2f2 i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDHLSL
        }
    }
}
