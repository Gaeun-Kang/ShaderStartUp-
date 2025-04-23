Shader "Unlit/Reflection"
{
    //Make Reflection with Cubemap
    //Reflection worrk by reflact bright or dark image, so it needs Emission
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Cube("Cubemap", Cube) ="" //cubemap 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
            CGPROGRAM
            #pragma surface surf Lambert noambient 
            
            sampler2D _MainTex;
            samplerCUBE _Cube; 

            struct Input
            {
                float2 uv_MainTex;
                float3 worldRefl; //get reflaction vector for uv 
            };

           void surf(Input IN, inout SurfaceOutput o)
           {
               fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
               float4 re = texCUBE (_Cube, IN.worldRefl); //calculate cubemap texture
               o.Albedo = 0; //Reflaction doesn't need to have Albedo(think aboout mirror. It doesn't have own color)
               o.Emission = re.rgb;
               o.Alpha = c.a;
            }
            ENDCG
        
    }
    FallBack "Diffuse"
}
