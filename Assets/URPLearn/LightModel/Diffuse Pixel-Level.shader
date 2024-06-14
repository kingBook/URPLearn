Shader "Unity Shaders Book/Chapter 6/Diffuse Pixel-Level" {
    Properties {
        _BaseColor ("BaseColor", Color) = (1, 1, 1, 1)
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

            half4 _BaseColor;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normal:NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 worldNormal:TEXCOORD0;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.worldNormal = TransformObjectToWorldNormal(input.normal);

                return output;
            }

            half4 frag(Varyings input): SV_Target
            {
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                float3 worldLight = normalize(_MainLightPosition.xyz);
                //float3 worldLight = normalize(GetMainLight().direction);

                half3 lightColor = _MainLightColor.rgb;
                //half3 lightColor = GetMainLight().color;

                half3 diffuse = lightColor * _BaseColor.rgb * saturate(dot(input.worldNormal, worldLight));
                // 也可以直接使用LightingLambert方法
                //half3 diffuse = _BaseColor.rgb * LightingLambert(lightColor, worldLight, input.worldNormal);

                half3 color = ambient + diffuse;
                return half4(color, 1.0);
            }
            ENDHLSL
        }
    }
}