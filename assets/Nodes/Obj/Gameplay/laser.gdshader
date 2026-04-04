//https://godotshaders.com/shader/extensible-color-palette/
shader_type canvas_item; 
render_mode blend_mix, unshaded;

uniform vec4 color0: source_color;
uniform vec4 color1: source_color;
uniform vec4 color2: source_color;
uniform vec4 color3: source_color;
uniform vec4 color4: source_color;
uniform vec4 color5: source_color;
uniform vec4 color6: source_color;
uniform vec4 color7: source_color;
uniform vec4 color8: source_color;

void fragment() {
	
	
// 1: Define the color list

	vec4 colors[] = {color0,color1,color2,color3,color4,color5,color6,color7,color8};

	

// 2: Grab the junk off of the screen

	vec3 scrn_uv = vec3(UV, 0.0);
	vec3 color_input;
	float alpa_input;
	{
		vec4 _tex_read = textureLod(TEXTURE, scrn_uv.xy, 0.0);
		color_input = _tex_read.rgb;
		alpa_input = _tex_read.a;
	}

// 3: Turn that junk into the superior "Grey"

	float grey_value;
	{
		vec3 c = color_input;
		float max1 = max(c.r, c.g);
		float max2 = max(max1, c.b);
		grey_value = max2;
	}

// 4: Multiply the superior "Grey" into the ultimate "Multiplied Grey"

	float multiplier = float(colors.length()-1);
	float multiplied_grey = grey_value * multiplier;

// 5: Round the ultimate "Multiplied Grey" to integer-like values; Achieve god-like "Rounded Multiplied Grey"

	float round_mult_grey = round(multiplied_grey);

// 6: Use the power of your new god to pick your output colors based on their color index.

	vec4 out_color = colors[int(round_mult_grey)];
	

// 7: Meet your new friends: the output colors.

	COLOR = out_color;
	COLOR.a = alpa_input;

// 8: Profit.

}