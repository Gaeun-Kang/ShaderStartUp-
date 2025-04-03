Shader "Custom/HologramShader"

//HowtoMakeHologramEffect
//Based On Rim Light

{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {} 
        _Color("Color",Range(0,1))= 0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" } //Make Transparent 

        CGPROGRAM
        #pragma surface surf Lambert noambient alpha:fade // No need to get Environment Light

        sampler2D _MainTex; 

        struct Input
        { 
            float2 uv_MainTex;
            float3 viewDir;
        };

        void surf (Input IN, inout SurfaceOutput o) 
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex
            o.Emission = _Color
            rim = pow(1-rim,3);
            o.Alpha = rim;
        }
        ENDCG
    }
    FallBack "Diffuse"
}