Shader "Unlit/StencilInside"
{
    Properties
    { 
        //TextureMap 
        _MainMap("MainMap", 2D) = "white"{}
        _BaseColor("BaseColor",Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Stencil{
            //if use Stencil it'll be 0 
            Ref 0
            //you can see contents with different value (In this cae, StencilBuffer. It has value 1)
            //if Reference != buffer value -> pass keep 
            comp NotEqual
            //keep buffer contents 
            Pass keep

            }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv :TEXCOORD0; 
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv : TEXCOORD0;  
            };

            TEXTURE2D(_MainMap);
            SAMPLER(sampler_MainMap);
         
            CBUFFER_START(UnityPerMaterial)
            float4 _MainMap_ST;
            float4 _BaseColor; 
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainMap);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainMap, sampler_MainMap, IN.uv);
                color *= _BaseColor; //It will be Work like Multiply 

                return color;
            }
            ENDHLSL
        }
    }
}
