Shader "KevinPack/Unlit/Ghost"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tint ("Tint", Color) = (1,1,1,0)
        _FresnelPower ("Fresnel Power", float) = 5
        _Intensity ("Intensity", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "CanUseDepthTexture" = "True"}
        LOD 100
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 viewDir :TEXCOORD2;
                float4 screenSpace : TEXCOORD3;
                UNITY_FOG_COORDS(4)
            };

            sampler2D _MainTex;
            float4 _Tint;
            float4 _MainTex_ST;
            float _FresnelPower;
            float _Intensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.screenSpace = float4(0,0,0,0);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // return fixed4(i.normal.xxx,1);
                // sample the texture
                float frensnelAmount = saturate(1 -dot(i.normal, i.viewDir));

                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                frensnelAmount = pow(frensnelAmount, _FresnelPower);
                
                col.w *= clamp(frensnelAmount,0.05,1);
                col.w = frensnelAmount;
                col.xyz += _Tint * _Intensity;
                return col;
            }
            ENDCG
        }
    }
}
