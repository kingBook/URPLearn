Shader "Unity Shaders Book/Chapter 7/Single Texture" {
    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }

    SubShader {
        Tags {
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalPipeline"
        }

        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)

            half4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _Specular;
            float _Gloss;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normal:NORMAL;
                float4 texcoord : TEXCOORD0;
            };


            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.worldNormal = TransformObjectToWorldNormal(input.normal);
                output.worldPos = TransformObjectToWorld(input.positionOS.xyz);

                output.uv = input.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                // 或者调用内置函数
                //output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);

                return output;
            }

            half4 frag(Varyings input): SV_Target
            {
                half3 worldNormal = normalize(input.worldNormal);

                Light mainLight = GetMainLight();
                half3 worldLightDir = normalize(TransformObjectToWorldDir(mainLight.direction));
                

                // Use the texture to sample the diffuse color
                half3 albedo = tex2D(_MainTex, input.uv).rgb * _Color.rgb;

                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                half3 diffuse = mainLight.color * albedo * max(0, dot(worldNormal, worldLightDir));

                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - input.worldPos);
                half3 halfDir = normalize(worldLightDir + viewDir);
                half3 specular = mainLight.color * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                return half4(ambient + diffuse + specular, 1.0);
            }
            ENDHLSL
        }
    }
}