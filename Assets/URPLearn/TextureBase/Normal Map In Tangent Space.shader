Shader "Unity Shaders Book/Chapter 7/Normal Map In Tangent Space" {
    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"

            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            half4 _Specular;
            float _Gloss;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normal:NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };


            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir: TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            // Unity doesn't support the 'inverse' function in native shader
            // so we write one by our own
            // Note: this function is just a demonstration, not too confident on the math or the speed
            // Reference: http://answers.unity3d.com/questions/218333/shader-inversefloat4x4-function.html
            float4x4 inverse(float4x4 input)
            {
                #define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))

                float4x4 cofactors = float4x4(
                    minor(_22_23_24, _32_33_34, _42_43_44),
                    -minor(_21_23_24, _31_33_34, _41_43_44),
                    minor(_21_22_24, _31_32_34, _41_42_44),
                    -minor(_21_22_23, _31_32_33, _41_42_43),

                    -minor(_12_13_14, _32_33_34, _42_43_44),
                    minor(_11_13_14, _31_33_34, _41_43_44),
                    -minor(_11_12_14, _31_32_34, _41_42_44),
                    minor(_11_12_13, _31_32_33, _41_42_43),

                    minor(_12_13_14, _22_23_24, _42_43_44),
                    -minor(_11_13_14, _21_23_24, _41_43_44),
                    minor(_11_12_14, _21_22_24, _41_42_44),
                    -minor(_11_12_13, _21_22_23, _41_42_43),

                    -minor(_12_13_14, _22_23_24, _32_33_34),
                    minor(_11_13_14, _21_23_24, _31_33_34),
                    -minor(_11_12_14, _21_22_24, _31_32_34),
                    minor(_11_12_13, _21_22_23, _31_32_33)
                );
                #undef minor
                return transpose(cofactors) / determinant(input);
            }

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);
                //也可以使用 TransformObjectToHClip 方法
                //output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

                output.uv.xy = input.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                output.uv.zw = input.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                // 或者调用内置函数
                //output.uv.xy = TRANSFORM_TEX(input.texcoord, _MainTex);
                //output.uv.zw = TRANSFORM_TEX(input.texcoord, _BumpMap);

                ///
				/// Note that the code below can handle both uniform and non-uniform scales
				///
                // Construct a matrix that transforms a point/vector from tangent space to world space
                float3 worldNormal = TransformObjectToWorldNormal(input.normal);
                float3 worldTangent = TransformObjectToWorldDir(input.tangent.xyz);
                float3 worldBinormal = cross(worldNormal, worldTangent) * input.tangent.w;

                /*
                float4x4 tangentToWorld = float4x4(worldTangent.x, worldBinormal.x, worldNormal.x, 0.0,
                                                   worldTangent.y, worldBinormal.y, worldNormal.y, 0.0,
                                                   worldTangent.z, worldBinormal.z, worldNormal.z, 0.0,
                                                   0.0, 0.0, 0.0, 1.0);
                // The matrix that transforms from world space to tangent space is inverse of tangentToWorld
                float3x3 worldToTangent = inverse(tangentToWorld);
                */

                //wToT = the inverse of tToW = the transpose of tToW as long as tToW is an orthogonal matrix.
                float3x3 worldToTangent = float3x3(worldTangent, worldBinormal, worldNormal);

                // Transform the light and view dir from world space to tangent space
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 worldLightPos = TransformObjectToWorld(_MainLightPosition.xyz);
                float3 worldLightDir = worldLightPos - positionWS;
                //Light mainLight = GetMainLight();
                //float3 worldLightDir = mainLight.direction;
                float3 worldSpaceViewDir = _WorldSpaceCameraPos.xyz - positionWS;
                output.lightDir = mul(worldToTangent, worldLightDir);
                output.viewDir = mul(worldToTangent, worldSpaceViewDir);

                ///
                /// Note that the code below can only handle uniform scales, not including non-uniform scales
                /// 

                // Compute the binormal
                //				float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) ) * v.tangent.w;
                //				// Construct a matrix which transform vectors from object space to tangent space
                //				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
                // Or just use the built-in macro
                //				TANGENT_SPACE_ROTATION;
                //				
                //				// Transform the light direction from object space to tangent space
                //				o.lightDir = mul(rotation, normalize(ObjSpaceLightDir(v.vertex))).xyz;
                //				// Transform the view direction from object space to tangent space
                //				o.viewDir = mul(rotation, normalize(ObjSpaceViewDir(v.vertex))).xyz;
                return output;
            }

            half4 frag(Varyings input): SV_Target
            {
                float3 tangentLightDir = normalize(input.lightDir);
                float3 tangentViewDir = normalize(input.viewDir);

                // Get the texel in the normal map
                float4 packedNormal = tex2D(_BumpMap, input.uv.zw);
                float3 tangentNormal;
                // If the texture is not marked as "Normal map"
                //				tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
                //				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                // Or mark the texture as "Normal map", and use the built-in funciton
                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                float3 albedo = tex2D(_MainTex, input.uv).rgb * _Color.rgb;

                
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                float3 diffuse = _MainLightColor.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                float3 halfDir = normalize(tangentLightDir + tangentViewDir);
                float3 specular = _MainLightColor.rgb * _Specular.rgb *
                    pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

                return float4(ambient + diffuse + specular, 1.0);
            }
            ENDHLSL
        }
    }
}