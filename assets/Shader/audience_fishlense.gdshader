shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float strength : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 centered = uv * 2.0 - 1.0;

    // Aspect ratio fix (Godot 3)
    float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
    centered.x *= aspect;

    float dist = length(centered);
    float falloff = smoothstep(0.0, 1.0, dist);

    // Opposite fisheye (pincushion)
    centered *= 1.0 - strength * falloff * dist * dist;

    centered.x /= aspect;

    vec2 distorted_uv = (centered + 1.0) * 0.5;

    // Slight zoom to hide edges
    distorted_uv = (distorted_uv - 0.5) * 0.96 + 0.5;

    COLOR = texture(SCREEN_TEXTURE, distorted_uv);
}