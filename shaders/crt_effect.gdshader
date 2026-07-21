shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// Wie dick/eng die Streifen sind — höherer Wert = mehr, dünnere Streifen
uniform float scanline_count : hint_range(50.0, 800.0, 1.0) = 6000.0;
// Wie stark die Streifen abdunkeln — 0 = unsichtbar, 1 = komplett schwarz
uniform float scanline_intensity : hint_range(0.0, 1.0, 0.01) = 0.000006;
// Optional: Farbe statt reiner Abdunklung (Standard: neutrales Schwarz)
uniform vec3 scanline_color : source_color = vec3(0.0, 0.0, 0.0);
// Falls du willst, dass die Streifen sich langsam nach unten bewegen
// (klassischer Röhrenbildschirm-Effekt) — 0 = komplett statisch
uniform float scroll_speed : hint_range(0.0, 5.0, 0.01) = 0.03;

void fragment() {
	vec4 screen = texture(screen_texture, SCREEN_UV);
	float line_pos = SCREEN_UV.y * scanline_count + TIME * scroll_speed;
	float pattern = sin(line_pos * 3.14159) * 0.5 + 0.5;
	vec3 color = mix(screen.rgb, scanline_color, (1.0 - pattern) * scanline_intensity);
	COLOR = vec4(color, screen.a); // preserve original alpha instead of forcing 1.0
}