Shader "Custom/BumpTriangle" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Cell_Size ("Value", Range(0.01, 1.0)) = 0.01
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		// でこぼこをつくるシェーダー 
		Pass {
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
				return pow(sin(fragCoord.x / 10.0 + _Time * 100) + sin(fragCoord.y / 10.0 + _Time * 100), 2.0);
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float height = heightFunction(i.vertex.xy);
				fixed3 color = fixed3(height, height, height);

				return fixed4(color, 1.0);
			}
			ENDCG
		}

		GrabPass{}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 lightDir : TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _GrabTexture;
			float4 _MainTex_ST;
            float4 _GrabTexture_ST;
			float _Cell_Size;
			half _Glossiness;
			half _Metallic;
			
			//接空間への変換行列を取得
            float4x4 InvTangentMatrix(float3 tan, float3 bin, float3 nor )
            {
 				float4x4 mat = float4x4(
                    float4(tan, 0),
                    float4(bin, 0),
                    float4(nor, 0),
                    float4(0, 0, 0, 1)
                );
                return transpose( mat );   // 転置
            }

			v2f vert (appdata_full i)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(i.vertex);
				o.uv = i.texcoord;

				// ローカル空間上での接空間ベクトルの方向を求める
                float3 n = normalize(i.normal);
                float3 t = i.tangent;
                float3 b = cross(n, t);

                // ワールド位置にあるライトをローカル空間へ変換する
                float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);

                // ローカルライトを接空間へ変換する（行列の掛ける順番に注意）
                o.lightDir = mul(localLight, InvTangentMatrix(t, b, n));
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 resolution = _ScreenParams;

				// ここからトライアングル

				float CellWidth = _Cell_Size;
				float CellHeight = _Cell_Size;
				
				CellHeight = _Cell_Size * resolution.x / resolution.y;

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


				// ここからバンプマッピング 
				fixed2 pos = i.uv;
				float _x = pos.x;
				float _y = pos.y;
				float minW = 1.0 / resolution.x;
				float minH = 1.0 / resolution.y;
				float RED   = 0.298912;
				float GREEN = 0.586611;
				float BLUE  = 0.114478;
				fixed3 monochromeScale = fixed3(RED, GREEN, BLUE);

				//今のフラグメント位置の上下左右の位置をもってきて
				fixed2 left = fixed2(_x - minW < 0.0 ? 1.0 : _x - minW , _y);
				fixed2 top = fixed2(_x, _y + minH > 1.0 ? 0.0 : _y + minH);
				fixed2 right = fixed2(_x + minW > 1.0 ? 0.0 : _x + minW, _y);
				fixed2 bottom = fixed2(_x, _y - minH < 0.0 ? 1.0 : _y - minH);

				//その位置の色をとって    
				fixed4 leftColor = tex2D(_GrabTexture, left);
				fixed4 topColor = tex2D(_GrabTexture, top);
				fixed4 rightColor = tex2D(_GrabTexture, right);
				fixed4 bottomColor = tex2D(_GrabTexture, bottom);

				//色の輝度をとって
				float nLeft = dot(leftColor, monochromeScale);
				float nTop = dot(topColor, monochromeScale);
				float nRight = dot(rightColor, monochromeScale);
				float nBottom = dot(bottomColor, monochromeScale);

				//上下・左右の差で
				float m = (nRight - nLeft) * 0.5;
				float o = (nBottom - nTop) * 0.5;

				//３次元ベクトルを求めて
				fixed3 dyx = fixed3(0.0,  m, 0.65);
				fixed3 dyz = fixed3(0.65, -o, 0.0);
				//外積を正規化
				fixed3 dest = normalize(cross(dyx, dyz));
				//各色に割り当てる
				fixed4 smpColor = fixed4((dest.z + 1.0) * 0.5, (dest.x + 1.0) * 0.5, (dest.y + 1.0) * 0.5, 1.0);

				fixed3 normal = fixed4(UnpackNormal(smpColor), 1);
                fixed3 lightvec = normalize(i.lightDir);
                float  diffuse = max(0, dot(normal, lightvec));

				//return smpColor;
				return avgClr * diffuse;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
