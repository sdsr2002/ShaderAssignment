Shader "Unlit/CelShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Albedo("Albedo", Color) = (1,1,1,1)
        _MinValue("MinValue", Range(0,1)) = 0.1
        _Shades("Shades", Range(1,20)) = 3
    }

    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            float4 _Albedo;

            float _MinValue;
            float _Shades;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            // float3 CalculateCelShading(Light l, v2f i){
            //     float diffuse = saturate(dot(i.worldNormal, l.direction));

            //     return l.color * diffuse;
            // }

            fixed4 frag (v2f i) : SV_Target
            {

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float cosineAngle = dot(normalize(i.worldNormal), normalize(_WorldSpaceLightPos0.xyz));

                cosineAngle = max(cosineAngle, _MinValue);

                cosineAngle = floor(cosineAngle * _Shades) / _Shades;
                cosineAngle = max(cosineAngle, _MinValue);
                cosineAngle = saturate(cosineAngle);
                
                col = _Albedo;
                
                col.xyz *= cosineAngle;// fixed4(cosineAngle,cosineAngle,cosineAngle,1);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
