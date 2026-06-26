Shader "Unlit/Fur"
{

	Properties
	{
		_BaseMap("Base Map", 2D) ="white"{}
		_FurMap("Fur Map", 2D) = "White" {}
		[IntRange] _ShellAmount("Shell Amount", Range(1,100)) = 16
		_ShellStep("Shell Step", Range(0.0,0.01)) = 0.001
		_AlphaCutout("Alpha Cutout", Range(0.0, 1.0)) = 0.1
	} 

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"RenderPipeline" = "UniversalPipeline"
			
			//Ignore Prjoecter's image or shadow
			"IgnoreProjector" = "True" 
		}

		LOD 100
		ZWrite On
		Cull Back

		Pass
		{
			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore
			#pragma multi_compile_fog
			#include "Assets/Example/Effect/Fur/FurHLSL.shader"
			#pragma vertex vertex
			#pragma require geometry
			#pragma gemotery geom
			#pragma fragment frag
			ENDHLSL
		}

		Pass
		{
			Name "ShadowCaster"
			Tags {"LightMode" = "ShadowCaster"}


			ZWrite On
			ZTest LEqual
			ColorMask 001
			
			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5
			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment
			#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
			ENDHLSL
		}

	}
}
