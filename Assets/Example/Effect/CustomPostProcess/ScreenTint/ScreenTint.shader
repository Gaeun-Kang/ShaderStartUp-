Shader "CustomPostProcessing/ScreenTint"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}

        Pass
        {

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
          
             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

            sampler2D _MainTex;
            float4 _OverlayColor;
            float _Intensity;


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                //send texture position info 
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                //Tint effect just needs OverlayColor and Intensity
                float4 col = tex2D(_MainTex, i.uv) * _OverlayColor;
                col.rgb *= _Intensity;
                return col;
            }
            ENDHLSL
        }
    }
}
