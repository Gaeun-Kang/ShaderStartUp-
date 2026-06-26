Shader "TY_Shader/JustSnow_URP"
{
    Properties
    {
        _MainTex        ("Albedo (RGB)", 2D)            = "white" {}
        _BumpMap        ("NormalMap", 2D)               = "bump" {}

        [Space(20)]
        _Disp           ("Displacement Texture", 2D)    = "black" {}
        _DisHeight      ("Displacement Height", Range(0,1)) = 0

        [Space(20)]
        _NoiseTex       ("NoiseTexture", 2D)            = "white" {}
        _Sparkle        ("SparkleTexture", 2D)          = "black" {}
        _Spower         ("SparklePower", Range(0,10))   = 1.5

        [Space(20)]
        _RimColor       ("RimColor", Color)             = (1,1,1,1)
        _RimPower       ("RimPower", Float)             = 0

        [Space(20)]
        _SnowColor      ("SnowColor", Color)            = (0,0,0,0)
        _ShadowColor    ("ShadowColor", Color)          = (0,0,0,0)

        [Space(50)]
        // URP에서 Tessellation은 커스텀 패키지나 셰이더 그래프가 필요합니다.
        // 여기서는 CPU-side에서 미리 분할된 메시를 가정하거나
        // 런타임 Tessellation 대신 높은 폴리곤 메시 사용을 권장합니다.
        // 아래 프로퍼티는 참고용으로 남겨둡니다.
        _Tess           ("Tessellation (참고용)", Range(1,32)) = 4
    }

    SubShader
    {
        Tags
        {
            "RenderType"        = "Opaque"
            "RenderPipeline"    = "UniversalPipeline"
            "Queue"             = "Geometry"
        }
        LOD 200

        // ─────────────────────────────────────────────
        // Pass 1 : ForwardLit  (메인 라이트 + 커스텀 스노우 라이팅)
        // ─────────────────────────────────────────────
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex      vert
            #pragma fragment    frag

            // URP 키워드
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            // ── 텍스처 & 샘플러 선언 ──────────────────
            TEXTURE2D(_MainTex);    SAMPLER(sampler_MainTex);
            TEXTURE2D(_BumpMap);    SAMPLER(sampler_BumpMap);
            TEXTURE2D(_Disp);       SAMPLER(sampler_Disp);
            TEXTURE2D(_NoiseTex);   SAMPLER(sampler_NoiseTex);
            TEXTURE2D(_Sparkle);    SAMPLER(sampler_Sparkle);

            // ── CBUFFER (SRP Batcher 대응) ─────────────
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _BumpMap_ST;
                float4 _Disp_ST;
                float4 _NoiseTex_ST;
                float4 _Sparkle_ST;

                float  _DisHeight;
                float  _Spower;
                float  _RimPower;

                float4 _RimColor;
                float4 _SnowColor;
                float4 _ShadowColor;
            CBUFFER_END

            // ── 버텍스 입력 / 출력 구조체 ───────────────
            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float4 tangentOS    : TANGENT;
                float2 uv           : TEXCOORD0;
                float2 uv2          : TEXCOORD1;    // _Sparkle UV용 (UV2 채널)
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv_Main      : TEXCOORD0;
                float2 uv_Bump      : TEXCOORD1;
                float2 uv_Sparkle   : TEXCOORD2;
                float4 screenPos    : TEXCOORD3;

                // 탄젠트 공간 → 월드 공간 변환 행렬 (노말맵용)
                float3 T            : TEXCOORD4;
                float3 B            : TEXCOORD5;
                float3 N            : TEXCOORD6;

                float3 positionWS   : TEXCOORD7;
                float4 shadowCoord  : TEXCOORD8;
                float  fogFactor    : TEXCOORD9;
            };

            // ── 버텍스 셰이더 ─────────────────────────
            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                // ── Displacement (버텍스 이동) ─────────
                // URP에서는 tex2Dlod 대신 SampleLevel 사용
                float disp = SAMPLE_TEXTURE2D_LOD(
                    _Disp, sampler_Disp,
                    IN.uv * _Disp_ST.xy + _Disp_ST.zw, 0).r;

                float3 displacedPosOS = IN.positionOS.xyz
                                      + IN.normalOS * disp * _DisHeight;

                VertexPositionInputs posInputs  =
                    GetVertexPositionInputs(displacedPosOS);
                VertexNormalInputs   normalInputs =
                    GetVertexNormalInputs(IN.normalOS, IN.tangentOS);

                OUT.positionHCS = posInputs.positionCS;
                OUT.positionWS  = posInputs.positionWS;

                OUT.uv_Main    = TRANSFORM_TEX(IN.uv,  _MainTex);
                OUT.uv_Bump    = TRANSFORM_TEX(IN.uv,  _BumpMap);
                // Sparkle은 UV2 채널 사용 (원본 uv_Sparkle 과 동일하게 UV1도 가능)
                OUT.uv_Sparkle = TRANSFORM_TEX(IN.uv2, _Sparkle);

                // 탄젠트 공간 기저 벡터
                OUT.T = normalInputs.tangentWS;
                OUT.B = normalInputs.bitangentWS;
                OUT.N = normalInputs.normalWS;

                // Screen Position (노이즈 텍스쳐 스크린 UV용)
                OUT.screenPos  = ComputeScreenPos(posInputs.positionCS);

                // 섀도우 좌표
                OUT.shadowCoord = GetShadowCoord(posInputs);

                // 포그
                OUT.fogFactor = ComputeFogFactor(posInputs.positionCS.z);

                return OUT;
            }

            // ── 커스텀 스노우 라이팅 함수 ─────────────
            // 원본 LightingSnowShader() 를 그대로 재현
            float3 SnowLighting(
                float3 normalWS,
                float3 lightDirWS,
                float3 viewDirWS,
                float3 lightColor,
                float  atten,
                float  noise,
                float  sparkleMask)
            {
                // Half-Lambert
                float NdotL       = dot(normalWS, lightDirWS);
                float halfLambert = NdotL * 0.7 + 0.3;

                // Rim Light
                float rim         = saturate(dot(normalWS, viewDirWS));
                float3 rimColor   = pow(1.0 - rim, _RimPower) * _RimColor.rgb;

                // Sparkle
                //   원본: s.Gloss = sparklemap.r  /  s.Specular = noise
                //   sparkle = Gloss * _Spower * ndotl * Specular
                float sparkle     = sparkleMask * _Spower * NdotL * noise;

                // 최종 합산 (원본과 동일한 공식)
                float3 col =
                    (_SnowColor.rgb * halfLambert * lightColor * atten)   // 베이스 + 하프람버트
                  + ((1.0 - halfLambert) * _ShadowColor.rgb)              // 그림자 컬러
                  + rimColor                                               // 림라이트
                  + sparkle;                                               // 반짝이

                return col;
            }

            // ── 프래그먼트 셰이더 ─────────────────────
            float4 frag(Varyings IN) : SV_Target
            {
                // ── 노말맵 ───────────────────────────
                float3 normalTS = UnpackNormal(
                    SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, IN.uv_Bump));

                // 탄젠트 → 월드 공간 변환
                float3x3 TBN      = float3x3(IN.T, IN.B, IN.N);
                float3 normalWS   = normalize(mul(normalTS, TBN));

                // ── 노이즈 텍스쳐 (스크린 UV 기반) ────
                float2 screenUV   = IN.screenPos.xy / IN.screenPos.w;
                float  noise      = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, screenUV).r;

                // ── 반짝이 텍스쳐 ─────────────────────
                float sparkleMask = SAMPLE_TEXTURE2D(_Sparkle, sampler_Sparkle, IN.uv_Sparkle).r;

                // ── 뷰 방향 ──────────────────────────
                float3 viewDirWS  = normalize(GetCameraPositionWS() - IN.positionWS);

                // ── 메인 라이트 ──────────────────────
                Light mainLight   = GetMainLight(IN.shadowCoord);
                float3 col = SnowLighting(
                    normalWS,
                    mainLight.direction,
                    viewDirWS,
                    mainLight.color,
                    mainLight.shadowAttenuation * mainLight.distanceAttenuation,
                    noise,
                    sparkleMask);

                // ── 추가 라이트 (선택적) ──────────────
                #ifdef _ADDITIONAL_LIGHTS
                uint lightCount = GetAdditionalLightsCount();
                for (uint i = 0; i < lightCount; i++)
                {
                    Light addLight = GetAdditionalLight(i, IN.positionWS);
                    col += SnowLighting(
                        normalWS,
                        addLight.direction,
                        viewDirWS,
                        addLight.color,
                        addLight.shadowAttenuation * addLight.distanceAttenuation,
                        noise,
                        sparkleMask);
                }
                #endif

                // ── 포그 적용 ─────────────────────────
                col = MixFog(col, IN.fogFactor);

                return float4(col, 1.0);
            }

            ENDHLSL
        }

        // ─────────────────────────────────────────────
        // Pass 2 : ShadowCaster  (그림자 캐스팅)
        // ─────────────────────────────────────────────
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex   vertShadow
            #pragma fragment fragShadow

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            TEXTURE2D(_Disp); SAMPLER(sampler_Disp);

            CBUFFER_START(UnityPerMaterial)
                float4 _Disp_ST;
                float  _DisHeight;
                // 나머지 프로퍼티 (ShadowCaster에서는 불필요하지만 CBUFFER 일치 필요)
                float4 _MainTex_ST;
                float4 _BumpMap_ST;
                float4 _NoiseTex_ST;
                float4 _Sparkle_ST;
                float  _Spower;
                float  _RimPower;
                float4 _RimColor;
                float4 _SnowColor;
                float4 _ShadowColor;
            CBUFFER_END

            struct AttributesShadow
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct VaryingsShadow
            {
                float4 positionHCS : SV_POSITION;
            };

            float3 _LightDirection;

            VaryingsShadow vertShadow(AttributesShadow IN)
            {
                VaryingsShadow OUT;

                // Displacement 적용 후 그림자 위치 계산
                float disp = SAMPLE_TEXTURE2D_LOD(
                    _Disp, sampler_Disp,
                    IN.uv * _Disp_ST.xy + _Disp_ST.zw, 0).r;

                float3 displacedPosOS = IN.positionOS.xyz
                                      + IN.normalOS * disp * _DisHeight;

                float3 positionWS = TransformObjectToWorld(displacedPosOS);
                float3 normalWS   = TransformObjectToWorldNormal(IN.normalOS);

                OUT.positionHCS = TransformWorldToHClip(
                    ApplyShadowBias(positionWS, normalWS, _LightDirection));

                return OUT;
            }

            float4 fragShadow(VaryingsShadow IN) : SV_Target
            {
                return 0;
            }

            ENDHLSL
        }

        // ─────────────────────────────────────────────
        // Pass 3 : DepthOnly  (뎁스 프리패스 / 카메라 뎁스 텍스쳐)
        // ─────────────────────────────────────────────
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask R

            HLSLPROGRAM
            #pragma vertex   vertDepth
            #pragma fragment fragDepth

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_Disp); SAMPLER(sampler_Disp);

            CBUFFER_START(UnityPerMaterial)
                float4 _Disp_ST;
                float  _DisHeight;
                float4 _MainTex_ST;
                float4 _BumpMap_ST;
                float4 _NoiseTex_ST;
                float4 _Sparkle_ST;
                float  _Spower;
                float  _RimPower;
                float4 _RimColor;
                float4 _SnowColor;
                float4 _ShadowColor;
            CBUFFER_END

            struct AttributesDepth
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct VaryingsDepth
            {
                float4 positionHCS : SV_POSITION;
            };

            VaryingsDepth vertDepth(AttributesDepth IN)
            {
                VaryingsDepth OUT;

                float disp = SAMPLE_TEXTURE2D_LOD(
                    _Disp, sampler_Disp,
                    IN.uv * _Disp_ST.xy + _Disp_ST.zw, 0).r;

                float3 displacedPosOS = IN.positionOS.xyz
                                      + IN.normalOS * disp * _DisHeight;

                OUT.positionHCS = TransformObjectToHClip(displacedPosOS);
                return OUT;
            }

            float fragDepth(VaryingsDepth IN) : SV_Target
            {
                return IN.positionHCS.z;
            }

            ENDHLSL
        }
    }

    FallBack "Universal Render Pipeline/Lit"
}
