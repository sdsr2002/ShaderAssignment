Shader "Kevinpack/Unlit/Shield"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tint ("Tint", Color) = (1,1,1,1)
        _FresnelPower ("Fresnel Power", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        ZWrite Off
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                UNITY_FOG_COORDS(1)
                float3 viewDir :TEXCOORD2;
                float3 normal : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Tint;

            float _FresnelPower;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float fresnelAmount = saturate(1 - dot(i.normal, i.viewDir));
                fresnelAmount = pow(fresnelAmount, _FresnelPower);
                    
                i.uv.y += sin(_Time.y * 0.1) * 0.5;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog

                col.w = (col.x + col.y + col.z) / 3;
                //return fixed4(lerp(half4(1, 1, 1), half4(0, 0, 0)), lerp(half4(1, 1, 1), half4(0, 0, 0)), lerp(half4(1, 1, 1), half4(0, 0, 0)), 1);
                

                col.xyz *= _Tint.xyz;
                if (col.w < 0.9) {
                    col.w = 0.4;
                    col.xyz = _Tint.xyz;
                }

                //return float4(fresnelAmount.xxx,0.5);
                //return fresnelAmount.xxx;

                col.xyz += _Tint * fresnelAmount;


                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
