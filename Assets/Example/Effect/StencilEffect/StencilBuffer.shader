Shader "Unlit/StencilBuffer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [IntRange] _StencilID("Stencil ID", Range(0,255)) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque"  "Opaque"  = "Geometry" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
  
            Zwrite off
            ColorMask 0 //only masking 
            cull front // use only front 

            Stencil
                {
                    Ref [_StencilID]

                    comp always

                    Pass replace 

                }
           
        }
    }
}
