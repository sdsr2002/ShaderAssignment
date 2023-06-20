Shader "KevinPack/Unlit/Shield"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseMask ("Noise Mask", 2D) = "white" {}
        _NoiseScale ("Mask Scale", float) = 1
        _NoiseSpeed ("Mask Speed Y", float) = 0.1
        _NoiseSpeed2 ("Mask Speed X", float) = 0.1
        _Tint ("Tint", Color) = (1,1,1,1)
        _FresnelPower ("Fresnel Power", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Cull back
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
                float2 uv2 : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NoiseMask;
            float4 _NoiseMask_ST;

            float _NoiseScale;

            float _NoiseSpeed;
            float _NoiseSpeed2;

            float4 _Tint;

            float _FresnelPower;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.uv, _MainTex);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float fresnelAmount = saturate(1 - dot(i.normal, i.viewDir));
                fresnelAmount = pow(fresnelAmount, _FresnelPower);

                i.uv.y += sin(_Time.y * 0.1) * 0.5;
                i.uv2.y += _Time.y * _NoiseSpeed;
                i.uv2.x += _Time.y * _NoiseSpeed2;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 maskCol = tex2D(_NoiseMask, i.uv2 * _NoiseScale);
                float mask = saturate((maskCol.x + maskCol.y + maskCol.z) / 3);
                
                // apply fog
                //return fixed4(mask.xxx,1);
                col.w = (col.x + col.y + col.z) / 3;
                maskCol.w *= mask;
                //return col.wwww;
                //return fixed4(lerp(half4(1, 1, 1), half4(0, 0, 0)), lerp(half4(1, 1, 1), half4(0, 0, 0)), lerp(half4(1, 1, 1), half4(0, 0, 0)), 1);
                
                col.xyz *= _Tint.xyz;
                if (col.w < 0.9) {
                    col.w = 0.4;
                    col.xyz = _Tint.xyz;
                }
                col.w *= maskCol.w;

                //return float4(fresnelAmount.xxx,0.5);
                //return fresnelAmount.xxx;

                col.xyz *= _Tint;

                col.w += 0.5 + saturate(fresnelAmount);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
                return fixed4(col.xyz, mask);
            }
            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent+1"}
        Cull front
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
                float2 uv2 : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NoiseMask;
            float4 _NoiseMask_ST;

            float _NoiseScale;

            float _NoiseSpeed;
            float _NoiseSpeed2;

            float4 _Tint;

            float _FresnelPower;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.uv, _MainTex);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float fresnelAmount = saturate(1 - dot(i.normal, i.viewDir));
                fresnelAmount = pow(fresnelAmount, _FresnelPower);

                i.uv.y += sin(_Time.y * 0.1) * 0.5;
                i.uv2.y += _Time.y * _NoiseSpeed;
                i.uv2.x += _Time.y * _NoiseSpeed2;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 maskCol = tex2D(_NoiseMask, i.uv2 * _NoiseScale);
                float mask = saturate((maskCol.x + maskCol.y + maskCol.z) / 3);

                // apply fog
                //return fixed4(mask.xxx,1);
                col.w = (col.x + col.y + col.z) / 3;
                maskCol.w *= mask;
                //return col.wwww;
                //return fixed4(lerp(half4(1, 1, 1), half4(0, 0, 0)), lerp(half4(1, 1, 1), half4(0, 0, 0)), lerp(half4(1, 1, 1), half4(0, 0, 0)), 1);

                col.xyz *= _Tint.xyz;
                if (col.w < 0.9) {
                    col.w = 0.4;
                    col.xyz = _Tint.xyz;
                }
                col.w *= maskCol.w;

                //return float4(fresnelAmount.xxx,0.5);
                //return fresnelAmount.xxx;

                col.xyz *= _Tint;

                col.w += 0.5 + saturate(fresnelAmount);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
                return fixed4(col.xyz, mask);
            }
            ENDCG
        }
    }
}
