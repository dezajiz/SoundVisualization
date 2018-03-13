Shader "Unlit/Triangle"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Cell_Size ("Value", Range(0.01, 1.0)) = 0.01
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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Cell_Size;
			
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
				float CellWidth = _Cell_Size;
				float CellHeight = _Cell_Size;
				
				CellHeight = _Cell_Size * _ScreenParams.x / _ScreenParams.y;

				float x1 = floor(i.uv.x / CellWidth)*CellWidth;
				float x2 = clamp((ceil(i.uv.x / CellWidth)*CellWidth), 0.0, 1.0);

				float y1 = floor(i.uv.y / CellHeight)*CellHeight;
				float y2 = clamp((ceil(i.uv.y / CellHeight)*CellHeight), 0.0, 1.0);
				
				float x = (i.uv.x-x1) / CellWidth;
				float y = (i.uv.y-y1) / CellHeight;
				fixed4 avgClr = fixed4(0.0, 0.0, 0.0, 0.0);

				if ((x > y)&&(x < 1.0 - y))	{
					fixed4 avgL = tex2D(_MainTex, fixed2(x1, y1));
					fixed4 avgR = tex2D(_MainTex, fixed2(x2, y1));
					fixed4 avgC = tex2D(_MainTex, fixed2(x1+(CellWidth/2.0), y2+(CellHeight/2.0)));
					avgClr = (avgL+avgR+avgC) / 3.0;				
				}
				else if ((x < y)&&(x < 1.0 - y))	{
					fixed4 avgL = tex2D(_MainTex, fixed2(x1, y1));
					fixed4 avgR = tex2D(_MainTex, fixed2(x1, y2));
					fixed4 avgC = tex2D(_MainTex, fixed2(x1+(CellWidth/2.0), y2+(CellHeight/2.0)));
					avgClr = (avgL+avgR+avgC) / 3.0;
				}
				else if ((x > 1.0 - y)&&(x < y))	{
					fixed4 avgL = tex2D(_MainTex, fixed2(x1, y2));
					fixed4 avgR = tex2D(_MainTex, fixed2(x2, y2));
					fixed4 avgC = tex2D(_MainTex, fixed2(x1+(CellWidth/2.0), y2+(CellHeight/2.0)));
					avgClr = (avgL+avgR+avgC) / 3.0;
				}
				else	{
					fixed4 avgL = tex2D(_MainTex, fixed2(x2, y1));
					fixed4 avgR = tex2D(_MainTex, fixed2(x2, y2));
					fixed4 avgC = tex2D(_MainTex, fixed2(x1+(CellWidth/2.0), y2+(CellHeight/2.0)));
					avgClr = (avgL+avgR+avgC) / 3.0;
				}

				// avgClr = fixed4(_Cell_Size, 0.0, 0.0, 1.0);

				return avgClr;
			}
			ENDCG
		}
	}
}
