// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)
// Modified shaders copyright (c) 2023 Robert Rosborg. MIT license (see LICENSE)

Shader "Nature/Tree Creator Bark Crossfade"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        [PowerSlider(5.0)] _Shininess ("Shininess", Range (0.01, 1)) = 0.078125
        _MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}
        _BumpMap ("Normalmap", 2D) = "bump" {}
        _GlossMap ("Gloss (A)", 2D) = "black" {}

        // These are here only to provide default values
        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
        [HideInInspector] _TreeInstanceColor ("TreeInstanceColor", Vector) = (1,1,1,1)
        [HideInInspector] _TreeInstanceScale ("TreeInstanceScale", Vector) = (1,1,1,1)
        [HideInInspector] _SquashAmount ("Squash", Float) = 1
    }

    SubShader
    {
        Tags
        {
            "IgnoreProjector"="True"
            "RenderType"="TreeBark"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf BlinnPhong vertex:TreeVertBark nolightmap noforwardadd
        #pragma multi_compile __ LOD_FADE_CROSSFADE
        #include "UnityBuiltin3xTreeLibrary.cginc"

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _GlossMap;
        half _Shininess;

        struct Input
        {
            float2 uv_MainTex;
            fixed4 color : COLOR;
            float4 screenPos;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            #ifdef LOD_FADE_CROSSFADE
            float2 vpos = IN.screenPos.xy / IN.screenPos.w * _ScreenParams.xy;
            UnityApplyDitherCrossFade(vpos);
            #endif

            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb * IN.color.rgb * IN.color.a;
            o.Gloss = tex2D(_GlossMap, IN.uv_MainTex).a;
            o.Alpha = c.a;
            o.Specular = _Shininess;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
        }
        ENDCG

        // Pass to render object as a shadow caster
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #pragma multi_compile __ LOD_FADE_CROSSFADE
            #include "UnityCG.cginc"


            struct v2f
            {
                V2F_SHADOW_CASTER;
                UNITY_VERTEX_OUTPUT_STEREO
            };


            v2f vert(appdata_base v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }


            float4 frag(v2f i) : SV_Target
            {
                #ifdef LOD_FADE_CROSSFADE
                UnityApplyDitherCrossFade(i.pos.xy);
                #endif
                
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }

    Dependency "OptimizedShader" = "Hidden/Nature/Tree Creator Bark Crossfade Optimized"
    FallBack "Diffuse"
}