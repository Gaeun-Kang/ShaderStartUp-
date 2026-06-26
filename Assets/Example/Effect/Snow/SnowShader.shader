Shader "Custom/SnowShader"
{
   Properties
   {
	   //Base & Normal Map 
	   _BaseMap("Base Map", 2D) = "White"{}
	   _NoiseMap("Noise Map", 2D) = "White"{}
	   _NormalMap("NormalMap", 2D) = "Normal"{}

	   //Emssion & twinkle Effect 
	   _SnowEmission("SnowEmission",Range(-1,1))= 0
	   _SnowSparkle("SparkleTexture", 2D) = "balck"{}
	   _SparkleRange("SparkleRange", Range(0,10)) = 1.2


	   //Rim Effect for visual 
	   _RimColor("RimColor",Color) = (1,1,1,1)
	   _RimPow("RimPow",float) = 0

	   //Snow 
	   _SnowHeight("SnowHeight",Range(0,1))= 0
	   _Disp("Displacement Texture", 2D) = "black"{}
	   _SnowAngle("SnowAngle", Vector) = (0,1,0,0)
	   _SnowSize("SnowSize",Range(-1.1,1.1)) = 0

	}

	SubShader
	{
		Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
		LOD 200

		pass
		{
			HLSLPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			struct Vertinput
            {
                float4 positionOS : POSITION;
				float4 tangentOS : TANGENT;
                float3 normalOS : NORMAL;
				float2 uv   :TEXCOORD0;
                
            };

			struct Varyings
			{
				float4 positionHCS : SV_POSITION;
				float3 tangentWS : TANGENT;
				float3 normalWS : TEXCOORD1;
				float2 uv : TEXCOORD0;
			};

			TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

			TEXTURE2D(_NoiseMap);
            SAMPLER(sampler_NoiseMap);

			TEXTURE2D(_Disp);
            SAMPLER(sampler_Disp);

			TEXTURE2D(_Sparkle);
            SAMPLER(sampler_Sparkle);

			TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);


            CBUFFER_START(UnityPerMaterial)
			float4 _NoiseMap_ST;
			float4 _SnowAngle;
			float4 _ShadowColor;
			float4 _RimColor;
	
			float _RimPow;
			float _SparkleRange;
			float _SnowHeight;
			float _SnowSize;
            float _SnowEmission;
            CBUFFER_END 

           Varyings vert(Vertinput IN)
		{

			Varyings OUT;

			VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);

			float displacement = SAMPLE_TEXTURE2D_LOD(_Disp, sampler_Disp, IN.uv, 0).r;


			float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);
			float3 worldNormal = normalInput.normalWS;
			float3 snowDir = normalize(_SnowAngle.xyz);

			if(dot(worldNormal, snowDir) >= _SnowSize)

			{

			worldPos += worldNormal.xyz * _SnowHeight * displacement;

			}


			OUT.positionHCS = TransformWorldToHClip(worldPos);
			OUT.uv = TRANSFORM_TEX(IN.uv, _NoiseMap);


			// 구조체에서 필요한 float3 값만 추출해서 할당

			OUT.normalWS = worldNormal;
			OUT.tangentWS = normalInput.tangentWS; 

			return OUT;

			}

		half4 frag(Varyings IN) : SV_Target

			{

			//Lighting.hlsl 잊지말것! 
			//setting noraml & view basd on world position 
			Light light = GetMainLight();
			float3 normalWS = normalize(IN.normalWS);
			float3 viewDir = normalize(_WorldSpaceCameraPos - IN.positionHCS);
			

			//Screen Uv : from positionHCS
			float2 screenUV = IN.positionHCS.xy / _ScreenParams.xy;
		    float noise = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, screenUV).r;
			float3 sparkle = SAMPLE_TEXTURE2D(_Sparkle, sampler_Sparkle, IN.uv).rgb;


			float3 SnowAngle = normalize(_SnowAngle.xyz);
			float ndot = saturate( dot (normalWS, light.direction));
			float halfLambert = ndot * 0.7 + 0.3;

			//smoothstep + lerp version 

			float snowMask = smoothstep(_SnowSize - 0.05, _SnowSize + 0.05,dot(normalWS, SnowAngle));


			//Rim Effect

			float rim = pow(1.0-saturate(dot(normalWS,viewDir)), _RimPow);
			float4 rimColor = rim * _RimColor;

			//Main color
			half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);

			float3 snowColor = float3(0.9, 0.95, 1.0) + (noise * 0.1); 
		    float3 finalRGB = lerp(baseColor.rgb, snowColor, snowMask);
			
			//SparkleRange
			float sparkleEffect = sparkle.r * noise * snowMask;
			finalRGB += sparkleEffect * _SparkleRange; 


			finalRGB *= (halfLambert * light.color);
			finalRGB += rimColor.rgb * snowMask; 

			 return half4(finalRGB, 1.0);    
		 }
			ENDHLSL
		}
	}
}
