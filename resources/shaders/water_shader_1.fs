#ifdef GL_ES
precision highp float;
#endif

#if __VERSION__ >= 140

in vec4 Color0;
in vec2 TexCoord0;
in float OutBloomAmount;
in vec2 OutRatio;
out vec4 fragColor;

#else

varying vec4 Color0;
varying vec2 TexCoord0;
#define fragColor gl_FragColor
#define texture texture2D

#endif

uniform sampler2D Texture0;
const float distIntensity = 0.004; // distortion intensity
const float colorThreshold = 0.1;
const vec3 targetColor = vec3(91.0/255.0, 110.0/255.0, 225.0/255.0);

void main(void)
{
	vec2 texcoord = vec2(TexCoord0);
	vec4 texColor = texture(Texture0, texcoord);
    float colorDistance = length(texColor.rgb - targetColor);
    if (colorDistance < colorThreshold)
    {
        // 创建新的颜色
        float brightness = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));

        // 如果亮度低于某个阈值，则将 Alpha 值设置为 0
        float alpha = brightness < 0.01 ? 0.0 : 1.0;

        float OutTime = Color0.a * 629 - 1;

        vec2 uv = TexCoord0;
        vec3 dist;
        dist.x = abs(sin(uv.x * 100.0 + OutTime * 0.01) + sin(uv.y * 30.0) * cos(uv.y * 120.0)) * distIntensity;
        dist.y = abs(cos(uv.y * 150.0 + OutTime * 0.01) + cos(uv.x * 150.0) * sin(uv.y * 75.0)) * distIntensity;
        dist.z = (distIntensity - length(dist.xy)) * 0.1;

        // 纹理采样并应用扰动
        vec4 color = texture(Texture0, TexCoord0 + dist.xy);

        // 处理边缘情况
        if (color.a == 0.0) {
            color = texture(Texture0, TexCoord0);
        }

        float sinwave = sin(- OutTime * 0.01);
        // 反射和颜色调整
        vec3 lightsource = vec3(0.5, 0.5, 5.0); // 假设光源位置
        vec3 diff = lightsource - vec3(TexCoord0, 0.0);
        float dtp = dot(normalize(dist), normalize(diff));

        // 主要反射
        color.rgb *= 0.7 + dtp * 0.3;

        // 调整颜色
        color.rgb *= 0.75; // 去饱和
        color.b += 0.2; // 增加蓝色
        color.g += 0.1; // 增加绿色

        color.rgb *= 1.0 + sinwave * 0.1;
        // 限制颜色范围
        color.rgb = clamp(color.rgb, vec3(0.0), vec3(1.0));

        // 混合原始颜色和处理后的颜色
        color.rgb = mix(texture(Texture0, TexCoord0).rgb, color.rgb, 0.5);
        texColor = color;
    }
    // 输出最终颜色
    fragColor = texColor;
}
