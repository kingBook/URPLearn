Shader "Unity Shaders Book/Chapter 6/Specular Vertex-Level" {
    Properties {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
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

            half4 _Diffuse;
            half4 _Specular;
            float _Gloss;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normal:NORMAL;
            };


            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                half3 color:COLOR;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                half3 worldNormal = TransformObjectToWorldNormal(input.normal);
                Light mainLight = GetMainLight();

                half3 diffuse = mainLight.color * _Diffuse.rgb * saturate(dot(worldNormal, mainLight.direction));
                // 注意此处的光源方向默认是由顶点指向光源，因此需要取反
                half3 reflectDir = normalize(reflect(-mainLight.direction, worldNormal));
                half3 viewDir = normalize(GetCameraPositionWS() - TransformObjectToWorld(input.positionOS.xyz));

                half3 specular = mainLight.color * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                output.color = ambient + diffuse + specular;
                return output;
            }

            half4 frag(Varyings input): SV_Target
            {
                return half4(input.color, 1.0);
            }
            ENDHLSL
        }
    }
}