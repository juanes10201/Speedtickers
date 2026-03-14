//https://godotshaders.com/shader/water-2d-distortion-4-x/
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_enable, filter_nearest;

group_uniforms water;
uniform sampler2D waterNoise : repeat_enable, filter_nearest;
uniform sampler2D waterDistortionNoise : repeat_enable, filter_nearest;
uniform vec4 waterColor : source_color = vec4(0.117, 0.27, 0.58, 1);
uniform float colorCorection : hint_range(0.0, 1.0, 0.01) = 0.35;

group_uniforms water_waves;
uniform float distortionForce : hint_range(0.00, .1, 0.001) = .01;
uniform float WDBrightness : hint_range(0, 3, 0.05) = 1.5;
uniform float WDFreq : hint_range(0.2, .9, 0.05) = 0.6;
uniform float WDSize : hint_range(0.6, 1.2, 0.05) = .9;
uniform float WDSpeed : hint_range(1, 20, 0.05) = 4;
uniform vec2 tiling = vec2(1);
uniform vec2 offSetSpeed = vec2(.1);

group_uniforms surface_waves;
uniform float surfaceLevel : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform float surfaceFade : hint_range(0.0, 0.5, 0.01) = 0.05;
uniform float surfaceWaveAmplitude : hint_range(0.0, 0.05, 0.001) = 0.015;
uniform float surfaceWaveFrequency : hint_range(1.0, 30.0, 0.5) = 14.0;
uniform float surfaceWaveSpeed : hint_range(0.0, 10.0, 0.1) = 2.0;

group_uniforms BG_distortion;
uniform float backGroundDirX : hint_range(-0.1, 0.1) = 0.01;
uniform float backGroundDirY : hint_range(-0.1, 0.1) = 0.01;

group_uniforms surface_border;
uniform float borderWaveAmplitude : hint_range(0.0,0.2,0.001) = 0.05;
uniform float borderWaveFrequency : hint_range(1.0,40.0,0.5) = 12.0;
uniform float borderWaveSpeed : hint_range(0.0,10.0,0.1) = 2.0;
uniform float borderHeight : hint_range(0.0,1.0,0.01) = 0.15;

void fragment() {

	vec4 color = vec4(waterColor.rgb , 1);

	vec2 noiseUV = UV * tiling + offSetSpeed * TIME;
	float noiseValue = texture(waterDistortionNoise, noiseUV).r;

	vec2 waterUV = UV * tiling;

	waterUV.x += offSetSpeed.x * TIME;
	waterUV.y += cos(TIME * min(1., offSetSpeed.y)) * 0.01;

	// ----- SURFACE MASK USING SCREEN SPACE -----
	float worldY = SCREEN_UV.y;
	float surfaceMask = 1.0 - smoothstep(surfaceLevel, surfaceLevel + surfaceFade, worldY);

	// ----- MINI SURFACE WAVES -----
	float wave1 = sin(SCREEN_UV.x * surfaceWaveFrequency + TIME * surfaceWaveSpeed);
	float wave2 = sin(SCREEN_UV.x * surfaceWaveFrequency * 0.5 + TIME * surfaceWaveSpeed * 0.7);

	float surfaceWave = (wave1 + wave2) * 0.5;

	// vertical ripple
	waterUV.y += surfaceWave * surfaceWaveAmplitude * surfaceMask;

	// horizontal movement (slightly weaker)
	waterUV.x += cos(SCREEN_UV.x * surfaceWaveFrequency + TIME * surfaceWaveSpeed) 
	* surfaceWaveAmplitude * 0.5 * surfaceMask;

	// ----- NORMAL WATER DISTORTION -----
	waterUV += noiseValue * distortionForce * WDSpeed;

	vec4 noiseColor = texture(waterNoise, waterUV);
	float intensity = smoothstep(WDFreq, WDSize, noiseColor.r);

	color.rgb += intensity * vec3(WDBrightness);

	vec2 backGroundUV = SCREEN_UV;
	backGroundUV.x += noiseValue * backGroundDirX;
	backGroundUV.y += noiseValue * backGroundDirY;
	
	// ----- WAVY SURFACE BORDER -----

	float borderWave =
	sin(SCREEN_UV.x * borderWaveFrequency + TIME * borderWaveSpeed) +
	sin(SCREEN_UV.x * borderWaveFrequency * 0.6 + TIME * borderWaveSpeed * 0.7);

	borderWave *= 0.5;

	float surfaceLine = borderHeight + borderWave * borderWaveAmplitude;

	// cut alpha above the wave
	float alphaMask = step(UV.y, surfaceLine);

	color.a *= alphaMask;
	
	color = mix(texture(SCREEN_TEXTURE, backGroundUV), color, 0.2);

	COLOR = mix(color, waterColor, colorCorection);
}