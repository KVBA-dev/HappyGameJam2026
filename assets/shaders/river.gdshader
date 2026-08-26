shader_type canvas_item;

uniform vec4 edge_color : source_color;
uniform vec4 water_color : source_color;
uniform vec4 wave_color : source_color;

void vertex() {
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 river_uv = tex.rg;
	float alpha = tex.a;
	
	vec2 symmetric_uv = abs(river_uv * vec2(1, -2) + vec2(0, 1));
	symmetric_uv.y = 1.0 - symmetric_uv.y;	
	bool edge_mask = symmetric_uv.y > 0.4;

	vec2 wave_uv = fract(river_uv - TIME * vec2(1.0, 0.0));
	wave_uv.x = pow(wave_uv.x, 3.0);
	wave_uv.x = sin(wave_uv.x * PI);
	
	vec2 detail_uv = river_uv + TIME * vec2(0.0, 0.25);
	float noise = sin((detail_uv.y - detail_uv.x * 8.0) * 6.4) + sin(detail_uv.y * 1.6) + sin(detail_uv.y * 1.252);
	noise = sin(noise * 2.63);
	noise = noise * 0.5 + 0.5;
	noise = abs(noise * 2.0 - 1.0);
	noise = pow(noise, 10.5) * 0.5;
	
	vec4 base_color = mix(water_color, wave_color, noise);
	
	COLOR = edge_mask ? mix(base_color, wave_color, wave_uv.x) : mix(edge_color, water_color, wave_uv.x);
	//COLOR = vec4(vec3(noise), 0.0);
	COLOR.a = alpha;
}
