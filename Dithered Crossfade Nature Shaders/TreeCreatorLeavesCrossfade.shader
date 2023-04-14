// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)
// Modified shaders copyright (c) 2023 Robert Rosborg. MIT license (see LICENSE)

Shader "Nature/Tree Creator Leaves Crossfade"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        [PowerSlider(5.0)] _Shininess ("Shininess", Range (0.01, 1)) = 0.078125
        _MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}
        _BumpMap ("Normalmap", 2D) = "bump" {}
        _GlossMap ("Gloss (A)", 2D) = "black" {}
        _TranslucencyMap ("Translucency (A)", 2D) = "white" {}
        _ShadowOffset ("Shadow Offset (A)", 2D) = "black" {}

        // These are here only to provide default values
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.3
        [HideInInspector] _TreeInstanceColor ("TreeInstanceColor", Vector) = (1,1,1,1)
        [HideInInspector] _TreeInstanceScale ("TreeInstanceScale", Vector) = (1,1,1,1)
        [HideInInspector] _SquashAmount ("Squash", Float) = 1
    }

    SubShader
    {
        Tags
        {
            "IgnoreProjector"="True"
            "RenderType"="TreeLeaf"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf TreeLeaf alphatest:_Cutoff vertex:TreeVertLeaf nolightmap noforwardadd
        #pragma multi_compile __ LOD_FADE_CROSSFADE
        #include "UnityBuiltin3xTreeLibrary.cginc"

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _GlossMap;
        sampler2D _TranslucencyMap;
        half _Shininess;

        struct Input
        {
            float2 uv_MainTex;
            fixed4 color : COLOR; // color.a = AO
            float4 screenPos;
        };

        void surf(Input IN, inout LeafSurfaceOutput o)
        {
            #ifdef LOD_FADE_CROSSFADE
            float2 vpos = IN.screenPos.xy / IN.screenPos.w * _ScreenParams.xy;
            UnityApplyDitherCrossFade(vpos);
            #endif

            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb * IN.color.rgb * IN.color.a;
            o.Translucency = tex2D(_TranslucencyMap, IN.uv_MainTex).rgb;
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
            #pragma vertex vert_surf
            #pragma fragment frag_surf
            #pragma multi_compile_shadowcaster
            #pragma multi_compile __ LOD_FADE_CROSSFADE
            #include "HLSLSupport.cginc"
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #define INTERNAL_DATA
            #define WorldReflectionVector(data,normal) data.worldRefl

            #include "UnityBuiltin3xTreeLibrary.cginc"

            sampler2D _MainTex;

            struct Input
            {
                float2 uv_MainTex;
            };

            struct v2f_surf
            {
                V2F_SHADOW_CASTER;
                float2 hip_pack0 : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float4 _MainTex_ST;

            v2f_surf vert_surf(appdata_full v)
            {
                v2f_surf o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                TreeVertLeaf(v);
                o.hip_pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            fixed _Cutoff;

            float4 frag_surf(v2f_surf IN) : SV_Target
            {
                half alpha = tex2D(_MainTex, IN.hip_pack0.xy).a;
                clip(alpha - _Cutoff);
                
                #ifdef LOD_FADE_CROSSFADE
                UnityApplyDitherCrossFade(IN.pos.xy);
                #endif

                SHADOW_CASTER_FRAGMENT(IN)
            }
            ENDCG
        }
    }

    Dependency "OptimizedShader" = "Hidden/Nature/Tree Creator Leaves Crossfade Optimized"
    FallBack "Diffuse"
}