Shader "Unlit/Bubble"
{
 Properties
    {
        _NoiseTex("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 1
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Cube ("Reflection Cubemap", Cube) =""{}
    }

    SubShader
    {
        
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        Pass
        {
            
            Tags { "LightMode"="UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURECUBE(_Cube); SAMPLER(sampler_Cube);
            TEXTURE2D(_NoiseTex); SAMPLER(sampler_NoiseTex);

            float _Glossiness;
            float _Metallic;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;   
                float3 worldPos : TEXCOORD0;       
                float3 viewDir : TEXCOORD1;        
                float3 normalWS : TEXCOORD2;
             
            };
  

            // Add Noise to Vertex Shader (Bubble animation) 
            float getAddPos(float pos, int offset)
            {
                float speed = 0.1 + offset * 0.25; // offset에 따라 속도 차이
                return sin(pos * 10 + _Time.y * speed) * 0.02; // 시간 기반 변형
            }

            // 버텍스 셰이더
            Varyings vert(Attributes IN)
            {
                Varyings o;

                float3 pos = IN.positionOS.xyz;

               // Add Vertex Animation
               pos.x += getAddPos(pos.x, 0);
               pos.y += getAddPos(pos.y, 1);
               pos.z += getAddPos(pos.z, 2);

                // 오브젝트 공간 → 월드 공간으로 변환
                float3 worldPos = TransformObjectToWorld(pos);
                float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos); // 뷰 방향 계산

                o.positionCS = TransformWorldToHClip(worldPos); 
                o.worldPos = worldPos;
                o.viewDir = viewDir;
                o.normalWS = TransformObjectToWorldNormal(IN.normalOS); 

                return o;
            }

         
            float4 frag(Varyings IN) : SV_Target
            {
               float3 reflectDir = reflect(-IN.viewDir, IN.normalWS);


               //noise Mask used for Masking 
               //float2 uv = sin(IN.worldPos.xy * 0.3 + _Time.x * 0.03);
               float2 uv = IN.worldPos.xy * 0.1 + float2(_Time.y * 0.1, 0.0);
               float noiseMask = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, 1).b;
               
               // based on Time & WorldPosition
               float3 baseCol = sin(_Time.w + IN.worldPos * 10.0) * 0.3 + 0.9;

               // rim based on Camera vector
               float rim = dot(IN.normalWS, IN.viewDir);
               float alpha = pow(saturate(1 - rim), 1);

               //reflect CUBEMAP
               float3 reflectCUBE = reflect(-normalize(IN.viewDir), normalize(IN.normalWS));
               float3 reflection = SAMPLE_TEXTURECUBE(_Cube, sampler_Cube, reflectCUBE).rgb;
               float3 reflectCol = lerp(baseCol, reflection, 0.5);

               //Final Color
                float3 noiseColor = lerp(noiseMask, baseCol, 0.9);
                float3 finalColor = lerp(noiseMask,reflectCol, 1);
                
                //return float4(reflectCol,alpha);
                return float4(finalColor * noiseColor, alpha);
                

            }

            ENDHLSL
        }
    }
}
