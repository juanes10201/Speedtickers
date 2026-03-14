shader_type canvas_item;

uniform float threshold : hint_range(0.0, 1.0) = 0.5;
uniform float aa_strength : hint_range(0.0, 0.2) = 0.08;

void fragment() {
    float a = COLOR.a;

    float edge = fwidth(a) + aa_strength;

    COLOR.a = smoothstep(threshold - edge, threshold + edge, a);
}