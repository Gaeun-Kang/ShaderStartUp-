Shader "Unlit/2Pass"
{

    //2Pass
    //This one Draw path 'one more time' so it has high cost 
    //And This will not work well with Hard Edge 
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
 
    SubShader{

        Tags{"RenderType" = "Opaque"}
    
    cull front

    //1st pass
    CGPROGRAM
    #pragma surface surf Nolight Lambert vertex:vert noshadow noambient

    sampler2D _MainTex;


    //use vertex shader
    //vertex shader : coordinate Transformation 
    void vert(inout appdata_full v)
        {
            v.vertex.xyz += v.normal.xyz * 0.01;
        }

    struct Input{

        float4 color:COLOR;
        };
    
        void surf(Input IN, inout SurfaceOutput o)
        {
           
        }

        float4 LightingNolight (SurfaceOutput s , float3 lightDir, float atten){
            return float4(0,0,0,1);
            }
    ENDCG
    

    cull back 
    //2nd pass
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            // 예시로 색을 반전
            o.Albedo = 1 - c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }

    FallBack "Diffuse"

}
