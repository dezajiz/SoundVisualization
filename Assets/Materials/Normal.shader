Shader "Unlit/Normal"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			fixed4 _Color;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			float heightFunction(in float2 fragCoord) {
				return pow(sin(fragCoord.x / 100.0 + _Time) + sin(fragCoord.y / 100.0 + _Time), 2.0);
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float height = heightFunction(i.vertex.xy);
				fixed3 color = fixed3(height, height, height);
				return fixed4(color, 1.0);
			}
			ENDCG
		}
	}
}
