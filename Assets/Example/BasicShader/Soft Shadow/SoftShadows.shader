Shader "Unlit/SoftShadows"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags {  "RenderPipeline"="UniversalPipeline"  "RenderType"="Opaque" "Queue"="Geometry+0"}

        Pass
        {
       
            Name "Universal Forward"
            Tags 
            { 
                "LightMode" = "UniversalForward"
            }
            Cull Back
            ZTest LEqual

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma vertex vert
            #pragma fragment frag

            //Lighting.hlsl include Shadow.hlsl
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
             // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile_fog

            // Shadow
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            //CBUFFER
            CBUFFER_START(UnityPerMaterial)

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            half4 _MainTex_ST;

            CBUFFER_END

            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID 
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float fogCoord  : TEXCOORD1;
                float3 normal : NORMAL;               
                float4 shadowCoord : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings vert(Attributes v)
            {
                Varyings o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v,o);
                
                //Transform Materix
                //UnityObjectToClipPos -> TransformObjectToHClip
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = TransformObjectToWorldNormal(v.normal);

                //Fog
                //ComputeFogFactor() is Include in Core.hlsl 
                //It work with Clipspace's near/far and sort z position 0-1
                o.fogCoord = ComputeFogFactor(o.vertex.z);

                //ShadowCoord 
                //VertexInput Struct : WS, VS,CS,NDC 
                

                //#ifdef _MAIN_LIGHT_SHADOWS
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                o.shadowCoord = GetShadowCoord(vertexInput);

                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);    
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
            
                //Get Shadow 
                Light mainLight = GetMainLight(i.shadowCoord);

                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                //Dot normal and Light
                float NdotL = saturate(dot(_MainLightPosition.xyz, i.normal));
                
                //Get Ambient from Lighting.hlsl-SampleSH
                half3 ambient = SampleSH(i.normal);

                //ShadowAttenuation * NdotL : Shadow 
                col.rgb *= NdotL * _MainLightColor.rgb * mainLight.shadowAttenuation *  mainLight.distanceAttenuation + ambient;
                col.rgb = MixFog(col.rgb, i.fogCoord);
                return col;

            }
            ENDHLSL
        }

        //Shadow Pass
        Pass
        {
            Name "ShadowCaster"

            Tags{"LightMode" = "ShadowCaster"}

            Cull Back

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

           // GPU Instancing
            #pragma multi_compile_instancing
          
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            

            CBUFFER_START(UnityPerMaterial)
            CBUFFER_END

            struct VertexInput
            {          
                float4 vertex : POSITION;
                float4 normal : NORMAL;

                UNITY_VERTEX_INPUT_INSTANCE_ID  
            };
          
            struct VertexOutput
            {          
                float4 vertex : SV_POSITION;
          
                UNITY_VERTEX_INPUT_INSTANCE_ID          
                UNITY_VERTEX_OUTPUT_STEREO
  
            };

            VertexOutput ShadowPassVertex(VertexInput v)
            {
               VertexOutput o;
               UNITY_SETUP_INSTANCE_ID(v);
               UNITY_TRANSFER_INSTANCE_ID(v, o);
            // UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);                             
           
              float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
              float3 normalWS   = TransformObjectToWorldNormal(v.normal.xyz);
         
              float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _MainLightPosition.xyz));
              
              o.vertex = positionCS;
             
              return o;
            }

            half4 ShadowPassFragment(VertexOutput i) : SV_TARGET
            {  
                UNITY_SETUP_INSTANCE_ID(i);
         //     UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                return 0;
            }

            ENDHLSL
        }
    }
}
