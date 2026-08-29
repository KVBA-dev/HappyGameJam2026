/* 
Rainbow outline by @Farfalk and @ThePadDev, July 2021

Apply to canvas items with transparent backgrounds.
Check that there is sufficient transparent background space for the outline!

CC0 License (but citation is welcome <3)
*/

#define PI 3.14159265

shader_type canvas_item;

uniform float uv_size = 1.0;
uniform float sin_frequency : hint_range(0.1, 2.0) = 0.5;  // frequency of the rainbow
uniform float light_offset : hint_range(0.0, 1.0) = 0.5;   // this offsets all color channels; if set to 0 only red green and blue colors will be shown.
instance uniform float alpha = 1.0;

void fragment() {
	vec2 uv = UV * uv_size - vec2((uv_size - 1.0) / 2.0);
	float outline = texture(TEXTURE, uv).a * (1.0 - texture(TEXTURE, uv).r);
	
	float pulse_r = sin(2.0 * PI * TIME * sin_frequency + uv.x + uv.y);
	float pulse_g = sin(2.0 * PI * TIME * sin_frequency + uv.x + uv.y + radians(120.0));
	float pulse_b = sin(2.0 * PI * TIME * sin_frequency + uv.x + uv.y + radians(240.0));
	
	vec4 color = vec4(pulse_r, pulse_g, pulse_b, 1.0);
	color += vec4(0.5);
	color.a = min(alpha, outline);
	
	COLOR = color;
}