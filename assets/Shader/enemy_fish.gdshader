shader_type canvas_item;

uniform float pixel_size : hint_range(0.0, 16.0) = 4.0;
uniform bool handle_edges = false;

varying vec2 p_world;

void vertex() {
	p_world = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 p_snapped = floor(p_world / pixel_size) * pixel_size + pixel_size / 2.0;
	vec2 delta = p_snapped - p_world;

	mat2 M_p = mat2(dFdx(p_world), dFdy(p_world));
	mat2 M_uv = mat2(dFdx(UV), dFdy(UV));
	mat2 J = M_uv * inverse(M_p);
	vec2 delta_uv = J * delta;

	vec2 uv = UV + delta_uv;
	vec4 color = texture(TEXTURE, uv);

	if (handle_edges) {
		float margin_x = (abs(J[0].x) + abs(J[1].x)) * pixel_size * 0.5;
		float margin_y = (abs(J[0].y) + abs(J[1].y)) * pixel_size * 0.5;
		if (uv.x < margin_x || uv.x > 1.0 - margin_x || uv.y < margin_y || uv.y > 1.0 - margin_y) {
			color.a = 0.0;
		} else {
			color.a = step(0.5, color.a);
		}
	} else {
		color.a = step(0.5, color.a);
	}

	COLOR = color;
}
