Shader "Custom/Wave" {
	Properties {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Strength ("Strength", Range(0.0, 1.0)) = 0.5
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf Lambert vertex:vert
        #pragma target 3.0

        sampler2D _MainTex;
        float _Strength;

        struct Input {
            float2 uv_MainTex;
        };

        void vert(inout appdata_full v, out Input o )
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float amp = _Strength * sin(_Time * 100 + v.vertex.x * 100) * 100;
            fixed3 pos = v.vertex;
            pos += v.normal * amp * 0.1;
            v.vertex.xyz = pos;
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
