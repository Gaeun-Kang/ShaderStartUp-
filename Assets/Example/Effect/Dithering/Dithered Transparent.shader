Shader "Unlit/Dithered Transparent"
//Dithered Shader 

{
    Properties 
    {
        _Color ("Color", Color) = (1,1,1,0.7)
        _MainTex ("Main Texture", 2D) = "white" {}
        _DitherScale("Dither Scale", Float) = 10
        [NoScaleOffset] _DitherTex ("Dither Texture", 2D) = "white" {}
        _FadeDistance("Fade Start Distance", Float) = 5.0
    }

    SubShader
    {
        Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass
        {            
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Dither Functions.cginc"
            #pragma vertex vert
            #pragma fragment frag

            uniform fixed4 _LightColor0;
            float4 _Color;
            float4 _MainTex_ST;
            sampler2D _MainTex;
            float _DitherScale;
            sampler2D _DitherTex;
            float _FadeDistance;

            struct v2f
            {
                float4 pos      : SV_POSITION;
                float4 col      : COLOR;
                float2 uv       : TEXCOORD0;
                float4 spos     : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldPos = worldPos.xyz;

                float3 normalDirection = normalize(mul(unity_ObjectToWorld, v.normal).xyz);
                float4 AmbientLight = UNITY_LIGHTMODEL_AMBIENT;
                float4 LightDirection = normalize(_WorldSpaceLightPos0);
                float4 DiffuseLight = saturate(dot(LightDirection, -normalDirection))*_LightColor0;
               
                o.col = float4(AmbientLight + DiffuseLight);
                o.spos = ComputeScreenPos(o.pos);

                return o;
            }

            float4 frag(v2f i) : COLOR
            { 
                //camera : MainCameraPosition 
                float3 camPos = _WorldSpaceCameraPos;
                float dist = distance(i.worldPos, camPos);

                // 0 : close, 1 : far 
                float fade = saturate(dist / _FadeDistance);
               
                //Alpha minvalue : 0
                //float rawAlpha = _Color.a * fade;

                //Alpha minvalue : 0.2
                float rawAlpha = lerp(0.2, _Color.a,fade);

                float4 texColor = tex2D(_MainTex, i.uv);
                float4 col = _Color * texColor;
                col.a = rawAlpha;

                // fade < 1일 때만 디더링 적용
                if (fade < 1.0)
                {
                    ditherClip(i.spos.xy / i.spos.w, col.a, _DitherTex, _DitherScale);
                }
                else
                {
                    // 완전히 불투명하므로 clip을 하지 않고 원래 색 그대로 반환
                    col.a = 1.0; // 필요시 원래 알파
                }

                return col * i.col;
            }

            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType" = "ShadowCaster" }
        UsePass "Hidden/Dithered Transparent/Shadow/SHADOW"
    }
}
