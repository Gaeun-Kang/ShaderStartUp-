// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Skybox/Cubemap" {
Properties
    {
        _Tint ("Tint Color", Color) = (.5, .5, .5, .5)
        [Gamma] _Exposure ("Exposure", Range(0, 8)) = 1.0
        _Rotation ("Rotation", Range(0, 360)) = 0
        [NoScaleOffset] _Tex ("Cubemap (HDR)", Cube) = "grey" {}
    }

    SubShader
    {
        Tags { "Queue"="Geometry+225" "RenderType"="Background" "PreviewType"="Skybox" }
        Cull Off ZWrite Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
                samplerCUBE _Tex;
                half4 _Tex_HDR;
                half4 _Tint;
                half _Exposure;
                float _Rotation;
            CBUFFER_END

             //Define UNITY_PI 
            #ifndef UNITY_PI
            #define UNITY_PI 3.14159265359
            #endif

            struct appdata_t
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 texcoord : TEXCOORD0;
                float fogCoord : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float3 RotateAroundYInDegrees(float3 vertex, float degrees)
            {
                float alpha = degrees * UNITY_PI / 180.0;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return float3(mul(m, vertex.xz), vertex.y).xzy;
            }

            v2f vert(appdata_t v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f, o);

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                float3 rotated = RotateAroundYInDegrees(v.vertex.xyz, _Rotation);
                o.vertex = TransformObjectToHClip(rotated);
                o.texcoord = v.vertex.xyz;

                // 항상 일정한 안개 값
                float fogDensity = unity_FogParams.x;
              //o.fogCoord = ComputeFogFactor(o.vertex.x);
          //  o.fogCoord *= fogDensity;
            o.fogCoord = ComputeFogFactor(o.vertex.z) * fogDensity;

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                half4 tex = texCUBE(_Tex, i.texcoord);
                half3 color = DecodeHDREnvironment(tex, _Tex_HDR);

                 //unity_ColorSpaceDouble.rgb
                color = color * _Tint.rgb * half4(4.59479380, 4.59479380, 4.59479380, 2.0).rgb; 
                color *= _Exposure;

                color = MixFog(color, i.fogCoord);

                return half4(color, 1);
            }
            ENDHLSL
        }
    }

    Fallback Off

}
