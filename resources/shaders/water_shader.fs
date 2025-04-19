#ifndef GL_ES
#  define lowp
#  define mediump
#endif
#define fragColor gl_FragColor
#define texture texture2D

varying mediump vec4 Color0;
varying mediump vec2 TexCoord0;
varying lowp vec4 ColorizeOut;
varying lowp vec3 ColorOffsetOut;
varying lowp vec2 TextureSizeOut;
varying lowp float PixelationAmountOut;
varying lowp vec3 ClipPlaneOut;

uniform sampler2D Texture0;
const float distIntensity = 0.004; // distortion intensity
const float colorThreshold = 0.1;
const vec3 targetColor = vec3(91.0/255.0, 110.0/255.0, 225.0/255.0);
const vec3 targetColor2 = vec3(61.0/255.0, 150.0/255.0, 205.0/255.0);
const vec2 CurrentDir0 = vec2(0.0,0.0);
const vec3 ColorMul0 = vec3(1.0,1.0,1.0);

vec2 waterGradientRadial(vec2 uv, float time, vec2 origin, float amp, float freq, float speed, float exponent)
{
	//vec2 pos = (uv - origin) * vec2(0.7, 1.0);
	//vec2 pos = (uv - origin) * vec2(1.0, 0.7);
	vec2 pos = (uv - origin);
	vec2 d = -normalize(pos);
	return vec2(
		exponent * d.x * amp * pow(0.5 * (sin(dot(d, pos) * freq + time * speed) + 1.0), exponent - 1.0)
			* cos(dot(d, pos) * freq + time * speed),
		exponent * d.y * amp * pow(0.5 * (sin(dot(d, pos) * freq + time * speed) + 1.0), exponent - 1.0)
			* cos(dot(d, pos) * freq + time * speed)
	);
}

vec2 waterGradientLinear(vec2 uv, float time, vec2 dir, float amp, float freq, float speed, float exponent)
{
	vec2 pos = uv * vec2(1.8, 1.0);
	vec2 spd = speed * vec2(1.0, 1.4);
	return vec2(
		exponent * dir.x * amp * pow(0.5 * (sin(dot(dir, pos) * freq + time * spd.x) + 1.0), exponent - 1.0)
			* cos(dot(dir, pos) * freq + time * spd.x),
		exponent * dir.y * amp * pow(0.5 * (sin(dot(dir, pos) * freq + time * spd.y) + 1.0), exponent - 1.0)
			* cos(dot(dir, pos) * freq + time * spd.y)
	);
}

void main(void)
{
	vec2 texcoord = vec2(TexCoord0);
	vec4 texColor = texture(Texture0, texcoord);
    // 输出最终颜色
    fragColor = texColor;
    float colorDistance = length(texColor.rgb - targetColor);
    if (colorDistance < colorThreshold)
    {
        // 创建新的颜色
        float brightness = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));

        // 如果亮度低于某个阈值，则将 Alpha 值设置为 0
        float alpha = brightness < 0.01 ? 0.0 : 1.0;

        float Time0 = Color0.r * 7000.0 - 1.0;
        float modrate = 5.0;
        vec2 delta = Color0.gb * 30.0 / 4.0;
        //* vec2(26.0 / 128.0,26.0 / 512.0)
        Color0 = vec4(targetColor,0.1);
        texcoord.x = mod(texcoord.x, 26.0 / 128.0) * 32.0/26.0;
        texcoord.y = mod(texcoord.y, 26.0 / 512.0) * 128.0/26.0;

        vec3 v = vec3(0.0, 0.0, 1.0);
        vec3 l = normalize(vec3(-1.0, -1.0, -1.0));
        vec3 h = normalize(l-v);
        
        texcoord = (texcoord + delta) / modrate;
        // Pixelate
        vec2 pa = vec2(1.0+PixelationAmountOut, 1.0+PixelationAmountOut) / TextureSizeOut;
        vec2 tc = PixelationAmountOut > 0.0 ? texcoord - mod(texcoord, pa) + pa * 0.5 : texcoord;
        

        vec2 gradientSum =
        -	waterGradientRadial(tc, Time0, vec2(-0.1, 0.15), 0.12, 80.0, 0.05, 1.4)
        -	waterGradientRadial(tc, Time0, vec2(1.0, 0.3)  , 0.12, 290.0, 0.04, 1.4)
        -	waterGradientRadial(tc, Time0, vec2(0.5, -0.2) , 0.12, 120.0, 0.04, 1.4)
        -	waterGradientRadial(tc, Time0, vec2(0.3, 1.0)  , 0.12, 240.0, 0.04, 1.4);
        
        if(CurrentDir0.x != 0.0 || CurrentDir0.y != 0.0)
        {
            gradientSum *= 0.5;
            gradientSum -= waterGradientLinear(tc, Time0, -CurrentDir0, 0.3, 100.0, 0.3, 1.4);
            gradientSum -= waterGradientLinear(tc, Time0, vec2(CurrentDir0.y, CurrentDir0.x), 0.12, 600.0, 0.0, 1.0);
        }
        
        vec3 n = normalize(vec3(gradientSum, -1.0));
        
        vec3 ref = refract(v, n, 1.08);
        float fresnel = dot(v, n);
        
        float spec = 0.04 * step(0.005, pow(dot(n, h), 160.0));
        
        fresnel = (1.0 + fresnel) * 2.0;
        
        vec4 color = vec4(targetColor2,1);//texture(Texture0, TexCoord0);
        //vec4 color = texture2D(Texture0, TexCoord0 + 0.1 * ref.xy);
        //float colorDistance2 = length(color.rgb - targetColor);
        //if (color.a == 0.0 || colorDistance2 > 0) {
        //    color = vec4(targetColor,1);//texture(Texture0, TexCoord0);
        //}
        float depthFactor = 1.0 - clamp(length(gradientSum)*4.0, 0.0, 1.0);
        color.xyz = color.xyz * mix(vec3(1.0), vec3(0.7, 0.9, 1.2), depthFactor);

        gl_FragColor = vec4((mix(color.xyz/color.a, Color0.xyz, Color0.a - fresnel) + vec3(spec, spec, spec)) * ColorMul0 * color.a, color.a);
        gl_FragColor = vec4(gl_FragColor.rgb,alpha);
        // Color reduction
        gl_FragColor.rgb = mix(gl_FragColor.rgb, gl_FragColor.rgb - mod(gl_FragColor.rgb, 1.0/16.0), clamp(PixelationAmountOut, 0.0, 1.0));
        gl_FragColor.a = gl_FragColor.a * 0.3;

        

        /*
        float OutTime = Time0;

        vec2 uv = texcoord;
        vec3 dist;
        dist.x = abs(sin(uv.x * 100.0 + OutTime * 0.01) + sin(uv.y * 30.0) * cos(uv.y * 120.0)) * distIntensity;
        dist.y = abs(cos(uv.y * 150.0 + OutTime * 0.01) + cos(uv.x * 150.0) * sin(uv.y * 75.0)) * distIntensity;
        dist.z = (distIntensity - length(dist.xy)) * 0.1;

        float sinwave = sin(- OutTime * 0.01);
        // 反射和颜色调整
        vec3 lightsource = vec3(0.5, 0.5, 5.0); // 假设光源位置
        vec3 diff = lightsource - vec3(texcoord, 0.0);
        float dtp = dot(normalize(dist), normalize(diff));

        //注意这里的vec4
        vec4 color = gl_FragColor;
        // 主要反射
        color.rgb *= 0.7 + dtp * 0.3;

        // 调整颜色
        color.rgb *= 0.75; // 去饱和
        color.b += 0.2; // 增加蓝色
        color.g += 0.1; // 增加绿色

        color.rgb *= 1.0 + sinwave * 0.1;
        // 限制颜色范围
        color.rgb = clamp(color.rgb, vec3(0.0), vec3(1.0));

        gl_FragColor = color;
        */
    }
}
