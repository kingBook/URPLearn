# URPLearn

此项目用于Unity通用渲染管线学习。

环境:

- Unity版本 2019.4.18f
- URP版本 7.5.2。

资源文件说明:

- 管线配置位于`Assets/Settings`
- 用例代码位于`Assets/URPLearn`，按照文件夹区分。有的用例会自带scene场景，其余的统一使用`Assets/Scenes/SampleScene`场景来预览
- 各种后处理的开关请看`Assets/Settings/ForwardRenderer`面板内，`PostProcessingFeature`中的`Effects`列表。点击选中每个Effect，控制其Active状态来进行开关。


# URP源码解读

- [基础概念](https://github.com/wlgys8/URPLearn/wiki/URP-Basic-Concept)
- [SRP](https://github.com/wlgys8/URPLearn/wiki/SRP-Custom)
    - [SRP-Culling](https://github.com/wlgys8/URPLearn/wiki/SRP-Culling)
- [URP](https://github.com/wlgys8/URPLearn/wiki/URP-Source)
    - [URP-ForwardRender](https://github.com/wlgys8/URPLearn/wiki/URP-ForwardRender)


# URP后处理造轮子

1. [扩展RendererFeatures](https://github.com/wlgys8/URPLearn/wiki/Custom-Renderer-Features)

2. [自定义PostProcessing](https://github.com/wlgys8/URPLearn/tree/master/Assets/URPLearn/CustomPostProcessing)

    2.1 [简单的ColorTint](https://github.com/wlgys8/URPLearn/tree/master/Assets/URPLearn/ColorTint)

    2.2 [Blur - 模糊效果](https://github.com/wlgys8/URPLearn/tree/master/Assets/URPLearn/Blur)

    2.3 [Bloom - 泛光特效](https://github.com/wlgys8/URPLearn/tree/master/Assets/URPLearn/Bloom)

    2.4 [SSAO - 屏幕空间环境光遮蔽](https://github.com/wlgys8/URPLearn/tree/master/Assets/URPLearn/SSAO)

    2.5 [DepthOfField - 景深](https://github.com/wlgys8/URPLearn/tree/master/Assets/URPLearn/DepthOfField)

3. [ScreenSpacePlanarReflectionFeature(屏幕空间平面反射)](https://github.com/wlgys8/URPLearn/tree/master/Assets/URPLearn/ScreenSpacePlanarReflection)

# GUP Instance功能

1. [GPU Instance绘制草植 - Grass Simulation](https://github.com/wlgys8/URPLearn/tree/master/Assets/URPLearn/GrassGPUInstances)

# 水体模拟

1. [浅水模拟 - Shallow Water Simulation](https://github.com/wlgys8/URPLearn/tree/master/Assets/URPLearn/Water)


# 扩展阅读

1. [HDR相关原理](https://github.com/wlgys8/URPLearn/wiki/HDR)
    - ToneMapping
    - 浮点纹理
2. [什么是Gamma矫正、线性色彩空间和sRGB](https://zhuanlan.zhihu.com/p/66558476)

    以上文章大致总结以下就是:
    - 早期显示器输出亮度与电压不是线性关系，而是`l = u^2.2`幂次关系。因此线性的色彩空间，经由显示器输出后，会变暗。
    - sRGB编码就是通过反向的曲线，先将线性色彩变亮,即`sRGB = linearRGB^0.45`。再经由显示器，就能完美还原了。

3. [什么是Color-LUT](https://zhuanlan.zhihu.com/p/43241990)

4. [ConstantBuffer](https://github.com/wlgys8/URPLearn/wiki/CBuffer)

5. [Uniform Scale](https://github.com/wlgys8/URPLearn/wiki/UniformScale)



