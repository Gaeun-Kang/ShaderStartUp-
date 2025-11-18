Shader "Custom/SnowShader"
{
   Properties
   {
	   _NoiseMap("NMainMap", 2D) = "White"{}
	   _SnowColor("SnowColor",Color) = (1,1,1,1)
	   _SnowHeight("SnowHeight",Range(0,10))= 0
	   _SnowEmission("SnowEmission",Range(-1,1))= 0
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

			struct Vertinput
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv   :TEXCORD0;
                
            };

			struct Varyings
			{
				float4 positionHCS : SV_POSTION;
				float3 normalHCS : NORMAL;
				float2 uv : TEXCORDO0;
			};

			TEXTURE2D(_NoiseMap);
            SAMPLER(sampler_NoiseMap);

            CBUFFER_START(UnityMaterial)
			float4 _MainTex_ST;
			float _SnowHeight;
            float _SnowEmission;
            CBUFFER_END 

            Varyings vert(Vertinput IN)
            {
                Varyings OUT;
                
				float3 vertpos = TransformObjectToWorld(IN.positionOS.xyz);
				float3 vertnormal = TransformObjectToWorldNormal(IN.normalOS .xyz);
				vertpos += vertnormal * _SnowHeight;
				OUT.positionHCS = TransformWorldToHClip(vertpos);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Targe
            {
				float4 _SnowColor;
				_SnowColor.rgb += _SnowEmission;


				return _SnowColor;
            }
			ENDHLSL
		}
	}
}
