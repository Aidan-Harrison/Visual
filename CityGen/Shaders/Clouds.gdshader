shader_type spatial;
render_mode blend_mix;

uniform sampler2D skyTexture;
uniform vec2 tile_factor = vec2(7.0, 7.0);

void fragment() {
	vec3 color;
	vec2 tiled_uvs = UV * tile_factor;
	
	vec2 offset;
	offset.x = TIME * 0.01;
	offset.y = TIME * 0.005;
	color = texture(skyTexture, tiled_uvs + offset).rgb;
	ALBEDO = color;
	ALPHA = 0.7;
}
