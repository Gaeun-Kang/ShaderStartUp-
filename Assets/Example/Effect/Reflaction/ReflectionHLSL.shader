Shader "Unlit/ReflectionHLSL"

//Lets covert to HLSL

{
    Properties //Properties No change 
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cube("Cubemap", Cube) = "" 
        _MaskMap("MaskMap",2D) = "white"{}
    }
    SubShader //Write RenderPipeline
    {
        Tags { "RenderType" = "Opaque"  "Opaque"  = "Geometry" "RenderPipeline" = "UniversalPipeline" }

        //I'll use HLSLPROGRAM and HLSL Function 
        //naming vertex, fragment and include core.hlsl 
        Pass
        {
           HLSLPROGRAM

           #pragma vertex vert
           #pragma fragment frag
           #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
           #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" //Add for use Directional Light info

           //Write Global variable & CBUFFER
           TEXTURE2D(_MainTex);
           SAMPLER(sampler_MainTex);

           TEXTURECUBE(_Cube);
           SAMPLER(sampler_Cube);

           TEXTURE2D(_MaskMap);
           SAMPLER(sampler_MaskMap);

           CBUFFER_START(UnityPerMaterial)
           float4 _MainTex_ST;
           float4 _MaskMap_ST;
           CBUFFER_END

           struct Attributes //VERTEX INPUT
           {
               float4 positionOS   : POSITION;
               float3 normalOS : NORMAL;
               float2 uv : TEXCOORD0; //Input one uv 
           };

           struct Varyings //VERTEX -> FRAGMENT
           {
               float4 positionHCS : SV_POSITION;
               float2 uvMain : TEXCOORD0; //but seperate Main- Mask UV 
               float2 uvMask : TEXCOORD1;
               float3 worldRefl : TEXCOORD2;
               float3 worldNormal : TEXCOORD3;
           };

           Varyings vert(Attributes IN) // //calculate reflect vector 
           {
               Varyings OUT;
               float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
               float3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
               float3 viewDir = normalize(_WorldSpaceCameraPos - positionWS); //camera vector

               OUT.worldRefl = reflect(-viewDir, normalWS); //Surface reflect vector 
               OUT.uvMain = TRANSFORM_TEX(IN.uv,_MainTex); //same uv, different texture
               OUT.uvMask = TRANSFORM_TEX(IN.uv,_MaskMap); 
               OUT.worldNormal = normalWS;
               OUT.positionHCS = TransformObjectToHClip(positionWS);
               return OUT; //Give data to fragment shader(frag)
           }

           half4 frag(Varyings IN) : SV_Target //decide final pixel color (=fragment shader)
           {
               half4 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uvMain); //color
               half3 reflColor = SAMPLE_TEXTURECUBE(_Cube, sampler_Cube, IN.worldRefl).rgb; //reflect
               half mask = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, IN.uvMask).a;

               Light mainLight = GetMainLight();
               float NdotL = saturate(dot(normalize(IN.worldNormal), mainLight.direction));
               reflColor *= mainLight.color.rgb * NdotL; //calculate Main Light RGB Color in ReflColor
               
               half3 finalColor = lerp(baseColor.a, reflColor, mask);

               return half4(finalColor, baseColor.a);
           }
           ENDHLSL
        }
    }
}