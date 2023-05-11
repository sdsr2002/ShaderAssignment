Shader "KevinPack/Unlit/Fire"
{
    Properties
    {
        _Tint ("Color Tint", Color) = (1,1,1,1)
        _AlphaMinMax ("Alpha [Min, Max]", vector) = (1,1,0,0)
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
        _PerlinTex ("Perlin Mask Texture", 2D) = "white" {}
        _powertest ("P", float) = 5
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        Zwrite Off
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uvMask : TEXCOORD1;
                float2 uvPerlinMask : TEXCOORD2;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            float4 _Tint;

            float4 _AlphaMinMax;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _MaskTex;
            float4 _MaskTex_ST;

            sampler2D _PerlinTex;
            float4 _PerlinTex_ST;

            float _powertest;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvMask = TRANSFORM_TEX(v.uv, _MaskTex);
                o.uvPerlinMask = TRANSFORM_TEX(v.uv, _PerlinTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv - float2(0,_Time.y * _AlphaMinMax.w));

                i.uvPerlinMask.y -= _Time.y * _AlphaMinMax.z;

                // i.uvMask.x -= sin(_Time.y * _AlphaMinMax.z) * i.uv.y * 0.1;
                // i.uvMask.x = saturate(i.uvMask.x);
                // i.uvMask.y = saturate(i.uvMask.y);

                fixed4 maskcolor = tex2D(_MaskTex, i.uvMask);
                fixed4 perlinColor = tex2D(_PerlinTex, i.uvPerlinMask);

                // apply fog
                float mask = (maskcolor.x + maskcolor.y + maskcolor.z) / 3;
                float maskPerlin = (perlinColor.x + perlinColor.y + perlinColor.z) / 3;
                maskPerlin = clamp(maskPerlin, _AlphaMinMax.x, _AlphaMinMax.y);
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                col.w = saturate(mask * maskPerlin);
                col.xyz *= _powertest;
                return col * _Tint;
            }
            ENDCG
        }
    }
}