using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class DepthMapFeature : ScriptableRendererFeature
{

    class DepthMapPass : ScriptableRenderPass
    {

        private Material _material;
        private Mesh _mesh;

        public DepthMapPass(Material material, Mesh mesh)
        {
            _material = material;
            _mesh = mesh;
        }

        //Exctue() : custom Method 
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(name: "DepthMapPass");
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
            Debug.Log(message: "The Execute() method runs.");
        }
    }

        private DepthMapPass _depthMapPass;
        public Material material;
        public Mesh mesh;  

        public override void Create()
        {
            _depthMapPass = new DepthMapPass(material,mesh);

    }

        public override void AddRenderPasses(ScriptableRenderer renderer,ref RenderingData renderingData)
        {
            if (material != null && mesh != null)
            {

                renderer.EnqueuePass(_depthMapPass);
            }

        }
    }

