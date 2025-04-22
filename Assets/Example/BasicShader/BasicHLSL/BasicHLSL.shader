Shader "Example/BasicHLSL"
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

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv :TEXCOORD0; //uv
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv : TEXCOORD0; //uv 
            };

            //Texture + Sampler 
            TEXTURE2D(_MainMap);
            SAMPLER(sampler_MainMap);

            //write varialbe and wrap with CBuffer 
            CBUFFER_START(UnityPerMaterial)
            float4 _MainMap_ST;
            float4 _BaseColor; 
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainMap); //uvoutput
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainMap, sampler_MainMap, IN.uv);
                color *= _BaseColor; //It will be Work like Multiply 
                //Invert
                //color = 1 - color;
                
                //Basic Gray Scale  
                //average of RGB (R+G+B) / 3
                //color = (color.r + color. g + color.b)/3;
                
                //Gray Scale : luminance
                //(R*0.3 + G*0.59 +B*0.11)


                return color;
            }
            ENDHLSL
        }
    }
}
