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
varying float OutBloomAmount;
varying vec2 OutRatio;
#define fragColor gl_FragColor
#define texture texture2D

#endif

uniform sampler2D Texture0;

void main(void)
{
	vec2 texcoord = vec2(TexCoord0);
	vec4 texColor = texture(Texture0, texcoord);

    float newAlpha = 4.0/3.0;
    
    // 创建新的颜色
    vec4 finalColor = vec4(texColor.rgb * newAlpha, texColor.a);
    
    // 输出最终颜色
    fragColor = finalColor;
}
