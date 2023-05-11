Shader "KevinPack/Unlit/HealthBar"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _health ("Health", Range(0,1)) = 1
        _healthFlashSpeed ("Health Flash Speed", Range(1,200)) = 100
        _healthFlashThreshold ("Health Flash Threshold", Range(0,1)) = 0.2
        _lostHealthAlpha ("Lost Health Alpha", Range(0,1)) = 1
        
        [Toggle] _Enable ("Flash Toggle", float) = 0

        _outlinethresshold ("Outline Thresshold", Range(0,1)) = 0.5
        _outlineThickness ("Outline Thickness", Range(0,1)) = 0.1

        [Enum(Off,0,Front,1,Back,2)] _Face("Face Culling",float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100

        Cull [_Face]

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma shader_feature _ENABLE_ON

            #include "UnityCG.cginc"
            
            float _health;
            float _healthFlashSpeed;
            float _healthFlashThreshold;
            float _lostHealthAlpha;
            float _outlinethresshold;
            float _outlineThickness;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 viewDir :TEXCOORD2;
                UNITY_FOG_COORDS(1)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //return fixed4(i.uv.x, i.uv.y,0,1);
                float a = i.uv.x <= _health;
                float b = 1-a;
                // sample the texture
                fixed4 col = tex2D(_MainTex, float2(_health, i.uv.y));
                fixed4 col2 = tex2D(_MainTex, float2(0.1, i.uv.y));
                #if _ENABLE_ON
                    float flashing = saturate(abs(sin(_Time * _healthFlashSpeed)*0.5)) + 1;
                #else
                    float flashing = 1;
                #endif
                float healthUnderThreshold = _healthFlashThreshold >= _health;
                float healthOverThreshold = _healthFlashThreshold < _health;
                

                col = 
                    a * healthUnderThreshold * flashing * col + // low health
                    healthOverThreshold * a * col +  // health
                    b * fixed4(col2.xyz* 0.5,_lostHealthAlpha); // health gone
                
                float2 uv = i.uv;
                uv.x *= 8;

                float2 closestLinePoint = float2( clamp(uv.x,0.5,7.5),0.5);
                float distanceToLine = distance(uv ,closestLinePoint);

                float outline = distanceToLine < _outlinethresshold;
                if (col.w != 0)
                col.w *= outline;

                float outlineIn = distanceToLine < _outlinethresshold - _outlineThickness;
                col.xyz *= outlineIn;
                if (outline == 1 && outlineIn == 0){
                    col.w = 1;
                }

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
