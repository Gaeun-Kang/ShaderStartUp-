Shader "Unlit/2Pass_Outline"
{
    //Change Color at Inspector
    Properties
    {
        _R("R", Range(0,1)) = 0
        _G("G", Range(0,1)) = 0
        _B("B", Range(0,1)) = 0
        _Emission("Emission", Range(-1,1)) = 0

        _OutlineColor("Outline Color", Color) = (1,0,0,1)
        _OutlineThickness("Outline Thickenss", Float) = 0.1
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

            CBUFFER_START(UnityPerMaterial)
            float _R;
            float _G;
            float _B;

            float _Emission;
            CBUFFER_END 

            struct Attributes
            {
                float4 positionOS   : POSITION;
   
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
                float4 ColorRange;
                ColorRange.rgb = float3(_R,_G,_B);
                ColorRange.rgb += _Emission;
                ColorRange.a = 1;

                return ColorRange;
            }
            ENDHLSL
        }

          Pass
        {
            Name "OutLine"
            Tags { "LightMode" = "OutLine" }
            Cull Front

            HLSLPROGRAM
            #pragma vertex v
            #pragma fragment f 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
            };

            sampler2D _MainTex;

            CBUFFER_START(UnityPerMaterial)
            float4 _OutlineColor;
            float  _OutlineThickness;
            CBUFFER_END

            Varyings v(Attributes IN)
            {

                //change vertex position to normal direction
                //normal direction : mesh space's 90 degree 


               Varyings OUT;
               float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
               float3 normalWS = TransformObjectToWorldNormal(IN.normalOS.xyz);
               positionWS += normalWS * _OutlineThickness  * 0.01;
               OUT.positionHCS = TransformWorldToHClip(positionWS);

                return OUT;
            }

            half4 f(Varyings IN) : SV_Target
            {

                //only return outline color 
                return _OutlineColor;
            }
    ENDHLSL
        }
    }

}
