using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(KevinsPostProcessOutlineRenderer), PostProcessEvent.BeforeStack, "KevinPack/Post Process Outline")]
public sealed class KevinsPostProcessOutline : PostProcessEffectSettings
{
    public IntParameter scale = new IntParameter { value = 1 };

}

public sealed class KevinsPostProcessOutlineRenderer : PostProcessEffectRenderer<KevinsPostProcessOutline>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("KevinPack/ViewOutlineShader"));
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);

        sheet.properties.SetFloat("_Scale", settings.scale);
    }
}