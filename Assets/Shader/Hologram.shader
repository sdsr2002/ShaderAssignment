Shader "KevinPack/Unlit/Hologram"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale ("Texture Scale", float) = 1
        _Speed ("Texture Speed", float) = 1
        [Header(Color)]

        _Tint ("Tint", Color) = (1,1,1,0)
        _Intensity ("Intensity", float) = 1
        [Header(Fresnel)]

        _FresnelPower ("Fresnel Power", float) = 5
        _MinimumAlpha ("Min Alpha", Range(0,1)) = 0.1
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        ZWrite Off
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
                UNITY_FOG_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Scale;
            float _Speed;
            float _Intensity;

            float4 _Tint;
            float _FresnelPower;
            float _MinimumAlpha;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.uv = v.uv;//TRANSFORM_TEX(v.uv, _MainTex);
                o.uv -= _Time.y * _Speed;
                o.uv.y += o.vertex.y
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // return fixed4(i.normal.xxx,1);
                // sample the texture
                float frensnelAmount = saturate(1 -dot(i.normal, i.viewDir));
                float2 uvs = i.uv * _Scale;
                //uvs.y += _Time.x * 1;
                fixed4 col = tex2D(_MainTex, uvs);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                frensnelAmount = pow(frensnelAmount, _FresnelPower);
                col.w *= frensnelAmount;
                col.w = clamp(col.w,_MinimumAlpha,1);
                col.xyz += frensnelAmount.xxx;
                col += _Tint * _Intensity;
                col.xyzw = saturate(col.xyzw);
                return col;
            }
            ENDCG
        }
    }
}
