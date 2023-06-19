using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(KevinsPostProcessOutlineRenderer), PostProcessEvent.BeforeStack, "KevinPack/Post Process Outline")]
public sealed class KevinsPostProcessOutline : PostProcessEffectSettings
{

    public ColorParameter color = new ColorParameter { value = Color.white };

    public IntParameter scale = new IntParameter { value = 1 };

    public FloatParameter depthThreshold = new FloatParameter { value = 1.5f };

    [Range(0, 1)]
    public FloatParameter normalThreshold = new FloatParameter { value = 0.4f };
    [Range(0, 1)]
    public FloatParameter depthNormalThreshold = new FloatParameter { value = 0.5f };
    public FloatParameter depthNormalThresholdScale = new FloatParameter { value = 7 };
}

public sealed class KevinsPostProcessOutlineRenderer : PostProcessEffectRenderer<KevinsPostProcessOutline>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("KevinPack/ViewOutlineShader"));

        sheet.properties.SetColor("_Color", settings.color);

        sheet.properties.SetFloat("_Scale", settings.scale);
        sheet.properties.SetFloat("_DepthThreshold", settings.depthThreshold);

        sheet.properties.SetFloat("_NormalThreshold", settings.normalThreshold);
        sheet.properties.SetFloat("_DepthNormalThreshold", settings.depthNormalThreshold);
        sheet.properties.SetFloat("_DepthNormalThresholdScale", settings.depthNormalThresholdScale);

        Matrix4x4 clipToView = GL.GetGPUProjectionMatrix(context.camera.projectionMatrix, true).inverse;
        sheet.properties.SetMatrix("_ClipToView", clipToView);


        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);

    }
}