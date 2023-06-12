Shader "KevinPack/Unlit/OutlineObject"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Thickness ("Thickness", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100
        Cull front
        ZWrite Off

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
            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                float3 forward = mul((float3x3)unity_CameraToWorld, float3(0,0,1));
                o.vertex *= normalize(dot(v.normal, forward)) *_Thickness;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = _Color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                //return float4(normalize(i.worldPos.xyz),1);
                return fixed4(0,0,0,1); //col;
            }
            ENDCG
        }
    }
}
