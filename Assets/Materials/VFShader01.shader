Shader "Unlit/VFShader01"
{
	Properties
	{
		_MainTex ("Base texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 500

		Pass
		{
			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float normal : NORMAL;
             	float3 wpos : TEXCOORD1;
				float3 lpos: TEXCOORD2;
				float2 uv : TEXCOORD0;
				uint vertexId : SV_VertexID;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			// http://nn-hokuson.hatenablog.com/entry/2017/01/27/195659#%E3%83%91%E3%83%BC%E3%83%AA%E3%83%B3%E3%83%8E%E3%82%A4%E3%82%BA
			fixed2 random2(fixed2 st)
			{
				st = fixed2( dot(st,fixed2(127.1,311.7)),
							dot(st,fixed2(269.5,183.3)) );
				return -1.0 + 2.0*frac(sin(st)*43758.5453123);
			}

			float perlinNoise(fixed2 st) 
			{
				fixed2 p = floor(st);
				fixed2 f = frac(st);
				fixed2 u = f*f*(3.0-2.0*f);

				float v00 = random2(p+fixed2(0,0));
				float v10 = random2(p+fixed2(1,0));
				float v01 = random2(p+fixed2(0,1));
				float v11 = random2(p+fixed2(1,1));

				return lerp( lerp( dot( v00, f - fixed2(0,0) ), dot( v10, f - fixed2(1,0) ), u.x ),
							lerp( dot( v01, f - fixed2(0,1) ), dot( v11, f - fixed2(1,1) ), u.x ), 
							u.y)+0.5f;
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				v.vertex += v.normal * perlinNoise(_Time);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				// UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}

			ENDCG
		}
	}
}
