Shader "KevinPack/Unlit/OutlineHighPoly"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _OutValue("Outline Value", range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent+1"}
        LOD 100
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

            float4 _Color;
            float _Thickness;
            float _OutValue;

            float4 outline(float4 vetexPos, float outvalue)
            {
                float4x4 scale = float4x4
                    (
                        1 + outvalue, 0, 0, 0,
                        0, 1 + outvalue, 0, 0,
                        0, 0, 1 + outvalue, 0,
                        0, 0, 0, 1 + outvalue
                        );

                return mul(scale, vetexPos);
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                UNITY_FOG_COORDS(1)
                float4 screenSpace : TEXCOORD2;
                float3 normal : TEXCOORD3;
                float depth : TEXCOORD4;
            };

            v2f vert(appdata v)
            {
                v2f o;

                float4 vertexPos = outline(v.normal.xyzw * _OutValue, _OutValue);
                o.vertex = UnityObjectToClipPos(vertexPos + v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return float4(i.depth, i.depth, i.depth, 1.0);
                // sample the texture
                //return fixed4(abs(i.normal.xyz),1);
                fixed4 col = _Color;

                //// apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                //return float4(normalize(i.worldPos.xyz),1);
                return col; //col;
            }
            ENDCG
        }
    }
}
