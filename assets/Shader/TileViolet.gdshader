shader_type canvas_item;

uniform sampler2D texture_albedo;
uniform sampler2D texture_bg;

uniform vec2 tile_scale = vec2(1, 1); // Adjust for tiling
uniform float repeat_limit = 0.5; // Maximum UV range (0.5 means wrap in 0-0.5)

void fragment() {
    vec2 uv_scaled = UV * tile_scale;
    vec2 uv_repeat = fract(uv_scaled) * repeat_limit; // Limit repetition to 0-0.5 range
    uv_repeat += fract(TIME) * repeat_limit;
	vec4 repeat_texture = texture(texture_albedo, uv_repeat);
	vec4 bg_texture = texture(TEXTURE, UV);
	COLOR = mix(bg_texture, repeat_texture, 0.7);
}