Shader "Unlit/Cusotm Light"
{

    //CustomLight = Lambert Light
    //0. It needs Ndot : Dot normal Vector & Light Vector 
    //1. Get Normal & Light Direction
    //3. Dot : Normal & Light 
    Properties
    {
        _BaseMap("BaseMap",2D) = "white"{}
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass 
        {
            Name "ForwardLit" 

            //Now we can use normal without UniversalForward
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE 
            #pragma multi_compile_fragment _ _SHADOWS_SOFT 

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
                float3 normalOS     : NORMAL; 
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float3 positionWS   : TEXCOORD1;  
                float3 normalWS     : NORMAL;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                OUT.normalWS = TransformObjectToWorld(IN.normalOS); 
                return OUT; 
            }

            half4 frag(Varyings IN) : SV_Target
            {
                
                float4 shadowCoord = TransformWorldToShadowCoord(IN.positionWS);
                Light light = GetMainLight(shadowCoord); 
                
                float3 lightDir = normalize(light.direction);
                float3 normalWS = normalize(IN.normalWS);
                
            //Texture-Lambert-Ambient 
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, TRANSFORM_TEX(IN.uv, _BaseMap));
               
                float NdotL = saturate(dot(lightDir,normalWS)); 

                float3 Ambient = SampleSH(normalWS); 
                
                float4 finalColor = 1;
                finalColor.rgb = (NdotL * light.shadowAttenuation * color.rgb) + (Ambient * color.rgb);
                finalColor.a = color.a;

                return finalColor; 
            }
            ENDHLSL
        }
        
        //Shadow Pass

        Pass 
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}  

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Front

            HLSLPROGRAM

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        //Depth Pass
        Pass 
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"} 

            ZWrite On
            ColorMask 0
            Cull Front

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }

}

