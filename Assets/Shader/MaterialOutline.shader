Shader "Unlit/MaterialOutline"
{
    Properties
    {
        _Color ("Color", Color) = (0,0,0,1)
        _FresnelPower ("Frensnel Power", float) = 1
        _AlphaCuttOff ("Alpha Cutt Off", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Back

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            
            float hash( float n )
            {
                return frac(sin(n)*43758.5453);
            }

            float noise( float3 x )
            {
                // The noise function returns a value in the range -1.0f -> 1.0f

                float3 p = floor(x);
                float3 f = frac(x);

                f       = f*f*(3.0-2.0*f);
                float n = p.x + p.y*57.0 + 113.0*p.z;

                return lerp(lerp(lerp( hash(n+0.0), hash(n+1.0),f.x),
                            lerp( hash(n+57.0), hash(n+58.0),f.x),f.y),
                        lerp(lerp( hash(n+113.0), hash(n+114.0),f.x),
                            lerp( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
            }

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
                float3 viewDir : TEXCOORD2;
                float4 vertex_World : TEXCOORD3;
                UNITY_FOG_COORDS(1)
            };

            float4 _Color;
            float _FresnelPower;
            float _AlphaCuttOff;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.vertex_World = v.vertex;
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.uv = o.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float frensnelAmount = saturate(1 -dot(i.normal, i.viewDir));
                frensnelAmount = pow(frensnelAmount, _FresnelPower);

                // sample the texture
                fixed4 col = _Color;
                // apply fog
                if (frensnelAmount > _AlphaCuttOff)
                {
                    col.w = 1;
                }
                else
                {
                    col.w = 0;
                }
                col.xyz = noise(float3(i.vertex_World.x,0,i.vertex_World.z));
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            
            ENDCG
        }
    }
}
