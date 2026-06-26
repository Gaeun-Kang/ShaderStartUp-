Shader "Lit/Lambert Diffuse"
{
    Properties
    {
        _BaseMap("Base Map", 2D ) = "White" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

        Pass
        {

         Name "ForwardLit"
         Tags {"LightMode"="UniversalForward"}


         HLSLPROGRAM
         #pragma vertex vert 
         #pragma fragment frag 

         #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
         #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
         #pragma multi_compile _ _SHADOWS_SOFT


         #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
         #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

         struct Attributes 
         {
             float4 positionOS : POSITION;
             float2 uv : TEXCOORD0;
             float3 normalOS : NORMAL;
         };

         struct Varyings
        {
            float4 positionHCS : SV_POSITION;
            float2 uv :TEXCOORD0;
            float3 normal : TEXCOORD1;
            float3 positionWS : TEXCOORD2;
         };

         TEXTURE2D(_BaseMap);
         SAMPLER(sampler_BaseMap);

         CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
         CBUFFER_END

         Varyings vert(Attributes IN)
         {
             Varyings OUT;

             OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
             OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
             OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
             OUT.normal = TransformObjectToWorldNormal(IN.normalOS);
             return OUT;

         }

         half4 frag(Varyings IN) : SV_Target 
         {

           IN.normal = normalize(IN.normal);
            
           //월드 좌표 기반 ShadowCoord
           float4 shadowCoord = TransformWorldToShadowCoord(IN.positionWS);
    
   
           //_MainLightPosition.xyz 대신 바로 mainLight 사용해서 받아오기 
            Light mainLight = GetMainLight(shadowCoord);
    
            half3 lightDir = normalize(mainLight.direction);
            half3 lightColor = mainLight.color;
            half shadowAtten = mainLight.shadowAttenuation; // 그림자에 가려지면 0, 밝은 곳은 1

  
            half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
            color *= _BaseColor;
    
            float NdotL = saturate(dot(IN.normal, lightDir));
            half3 ambient = SampleSH(IN.normal);
    
            //ShadowAtten 추가 
            half3 lighting = (NdotL * shadowAtten) * lightColor + ambient;
    
            color.rgb *= lighting;

            return color;
         }
          ENDHLSL 
    }
   UsePass "Universal Render Pipeline/Lit/ShadowCaster"

  }

}
