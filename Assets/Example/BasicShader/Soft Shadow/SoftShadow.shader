Shader "Unlit/SoftShadow"
{
   Properties
    { 
        //TextureMap 
        _MainMap("MainMap", 2D) = "white"{}
        _BaseColor("BaseColor",Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry+0"}

        Pass
        {
            HLSLPROGRAM
            #pragma prefer_hlslcc gles 
            #pragma exclude_renders d3d11_9x
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            
            

            //Lighting.hlsl also has Shadows.hlsl 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 

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
            
            
            //write varialbe and wrap with CBuffer 
            CBUFFER_START(UnityPerMaterial)

            TEXTURE2D(_MainMap);
            SAMPLER(sampler_MainMap);
            half4 _MainTex_ST; 
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
    

                return color;
            }
            ENDHLSL
        }
}
