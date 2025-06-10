using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ScreenTintRenderFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public Material material;
    }

    class ScreenTintPass : ScriptableRenderPass
    {
        private Material _material;

        //Temporary Render Target Handle (For blit save)
        private RenderTargetHandle _tempHandle;

        //Set Material Render order 
        public ScreenTintPass(Material material)
        {
            
            _material = material;
            //AfterRenderingTransparents
            renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
            _tempHandle.Init("_TemporaryColorTexture");
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            //RenderTextureDescriptor : Struct of Making Render Texture 
            RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.depthBufferBits = 0;

            //Make Temporary Render Texture 
            //GetTemporaryRT get _tempHandle.id
            //it means _tempHandle is Render Target
            cmd.GetTemporaryRT(_tempHandle.id, descriptor, FilterMode.Bilinear);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (_material == null)
                return;

            CommandBuffer cmd = CommandBufferPool.Get("ScreenTintEffect");


            // Get Custom Effect Parameter From Value
            // Need to Custom VolumeComponent Script
            var volume = VolumeManager.instance.stack.GetComponent<CustomPostScreenTint>();
            if (volume == null || !volume.IsActive())
            {
                CommandBufferPool.Release(cmd);
                return;
            }

            //Send Color& Intensity Parameter to Material
            _material.SetColor("_OverlayColor", volume.TintColor.value);
            _material.SetFloat("_Intensity", volume.TintIntensity.value);

            //Get Current Camera's Render Target For explicit RT
            var source = renderingData.cameraData.renderer.cameraColorTarget;

            // source -> temp texture
            cmd.Blit(source, _tempHandle.Identifier(), _material);
            //temp texture -> Blit with source
            cmd.Blit(_tempHandle.Identifier(), source);

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        //Return temp texture
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(_tempHandle.id);
        }
    }

    public Settings settings = new Settings();
    private ScreenTintPass _pass;

    public override void Create()
    {
        //Dont forget set Material!!!
        if (settings.material == null)
        {
            Debug.LogError("Material not assigned to ScreenTintRenderFeature");
            return;
        }

        _pass = new ScreenTintPass(settings.material);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (settings.material != null)
        {
            renderer.EnqueuePass(_pass);
        }
    }
}
