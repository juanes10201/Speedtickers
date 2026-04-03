shader_type canvas_item;

// Base texture
uniform sampler2D tex : hint_default_black;

// Amount of hue shift (0.0 to 1.0, where 1.0 = 360° rotation)
uniform float hue_shift = 0.1;

// Converts RGB to HSV color space
vec3 rgb_to_hsv(vec3 color_rgb) {
    vec4 k = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(color_rgb.bg, k.wz), vec4(color_rgb.gb, k.xy), step(color_rgb.b, color_rgb.g));
    vec4 q = mix(vec4(p.xyw, color_rgb.r), vec4(color_rgb.r, p.yzx), step(p.x, color_rgb.r));

    float d = q.x - min(q.w, q.y);
    float e = 1e-10;

    return vec3(
        abs(q.z + (q.w - q.y) / (6.0 * d + e)),
        d / (q.x + e),
        q.x
    );
}

// Converts HSV back to RGB
vec3 hsv_to_rgb(vec3 color_hsv) {
    vec3 rgb = clamp(
        abs(mod(color_hsv.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0,
        0.0,
        1.0
    );
    return color_hsv.z * mix(vec3(1.0), rgb, color_hsv.y);
}

// Applies hue shifting via HSV conversion
vec4 apply_hue_shift(vec2 uv_coords, sampler2D texture_input, float shift_amount) {
    vec4 base_color = texture(texture_input, uv_coords);
    vec3 hsv = rgb_to_hsv(base_color.rgb);
    hsv.x = mod(hsv.x + shift_amount, 1.0); // wrap hue in [0,1]
    vec3 shifted_rgb = hsv_to_rgb(hsv);
    return vec4(shifted_rgb, base_color.a);
}

void fragment() {
    COLOR = apply_hue_shift(UV, tex, hue_shift);
}
