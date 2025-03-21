shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    vec3 col = texture(screen_texture, SCREEN_UV).xyz;
    float brightness = dot(col, vec3(.1, 1, 1)); // Convert to grayscale
    COLOR = vec4(vec3(1.0), brightness); // White color with original brightness as alpha
}
