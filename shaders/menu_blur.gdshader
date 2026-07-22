shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

// "1" = kaum merklich, "10" = klar sichtbar aber noch dezent. Default bei 4
// für "nur ein bisschen" Unschärfe. WICHTIG: SCREEN_PIXEL_SIZE ist bei 1080p
// nur ca. 0.0005 groß — deshalb brauchen wir einen deutlich größeren
// Multiplikator (siehe RADIUS_SCALE) als man intuitiv erwarten würde, sonst
// verschiebt sich der Sample-Punkt nur um 1-2 Pixel und der Effekt ist
// de facto unsichtbar.
uniform float blur_amount : hint_range(0.0, 20.0) = 0.0;

const float RADIUS_SCALE = 8.0;

void fragment() {
	vec2 pixel_size = SCREEN_PIXEL_SIZE * blur_amount * RADIUS_SCALE;

	// 9-Tap-Box-Blur (Zentrum + 8 Nachbarn im Kreis) — deutlich weicher als
	// ein simpler Diagonal-Blur, bei weiterhin nur einem Pass.
	vec4 sum = vec4(0.0);
	sum += texture(screen_texture, SCREEN_UV + vec2(-pixel_size.x, -pixel_size.y));
	sum += texture(screen_texture, SCREEN_UV + vec2( 0.0,          -pixel_size.y));
	sum += texture(screen_texture, SCREEN_UV + vec2( pixel_size.x, -pixel_size.y));
	sum += texture(screen_texture, SCREEN_UV + vec2(-pixel_size.x,  0.0));
	sum += texture(screen_texture, SCREEN_UV + vec2( 0.0,           0.0)) * 2.0;
	sum += texture(screen_texture, SCREEN_UV + vec2( pixel_size.x,  0.0));
	sum += texture(screen_texture, SCREEN_UV + vec2(-pixel_size.x,  pixel_size.y));
	sum += texture(screen_texture, SCREEN_UV + vec2( 0.0,           pixel_size.y));
	sum += texture(screen_texture, SCREEN_UV + vec2( pixel_size.x,  pixel_size.y));
	sum /= 10.0;

	COLOR = sum;
}