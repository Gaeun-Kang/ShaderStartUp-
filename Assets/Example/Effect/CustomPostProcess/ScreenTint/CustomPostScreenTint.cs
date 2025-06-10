using UnityEngine;
using System;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


//Menu
//It makes you can Add this Effect at 'Add Override'
//
[Serializable, VolumeComponentMenuForRenderPipeline
    ("CustomPostProcess/CustomPostScreenTint", typeof(UniversalRenderPipeline))]

public class CustomPostScreenTint : VolumeComponent, IPostProcessComponent
{

    public FloatParameter TintIntensity = new FloatParameter(1);
    public ColorParameter TintColor = new ColorParameter(Color.white);


    //fix IPostProcessComponent Error
    public bool IsActive() => true;
    public bool IsTileCompatible() => true;
}
