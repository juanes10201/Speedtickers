 shader_type canvas_item;


 uniform sampler2D texture_albedo;
 uniform vec2 tile_size;
 uniform float speed = 0.5;

 void fragment() {
  vec2 tiled_uv = UV * tile_size;
  vec2 offset = vec2(TIME * speed);
  vec2 scrolled_uv = tiled_uv + offset;
  vec2 final_uv = fract(scrolled_uv + 1e-5);
  COLOR = texture(TEXTURE, final_uv);
}