Shader "Custom/Dekoboko" {
	Properties {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf Lambert vertex:vert
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };

		float heightFunction(in float2 fragCoord) {
			return pow(sin(fragCoord.x / 10.0 + _Time * 100) + sin(fragCoord.y / 10.0 + _Time * 100), 4.0);
		}

        void vert(inout appdata_full v, out Input o )
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
			float2 position = UnityObjectToClipPos(v.vertex);
            float amp = heightFunction(position); // 0.5*sin(_Time*100 + v.vertex.x * 100);
            v.vertex.xyz = float3(v.vertex.x, v.vertex.y + amp, v.vertex.z);            
        }

        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
