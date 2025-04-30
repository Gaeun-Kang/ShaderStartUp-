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
            #pragma vertex vert
            #pragma fragment frag


            //Gpu Instancing(Object Copy rendering in GPU)
            #pragma multi_compile_instancing
            //Unity Public Fog
            #pragma multi_compile_fog
            
            //Shadow : Main-CASCADE-Soft 
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            //Lighting.hlsl also has Shadows.hlsl 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 


            // UNITY_VERTEX_INPUT_INSTANCE_ID
            //
            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv : TEXCOORD0; 
                float FOGcOORD : TEXCOOR1;
                float3 normal : NORMAL;
                float4 shadowCoord : TEXCOOR2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
         
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
