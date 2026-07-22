shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
// 0 = Off, 1 = Protanopia, 2 = Deuteranopia, 3 = Tritanopia
uniform int colorblind_mode : hint_range(0, 3, 1) = 0;

// RGB -> LMS (Hunt-Pointer-Estevez, normalisiert)
const mat3 RGB_TO_LMS = mat3(
	vec3(17.8824, 3.45565, 0.02990),
	vec3(43.5161, 27.1554, 0.18430),
	vec3(4.11935, 3.86714, 1.46709)
);
const mat3 LMS_TO_RGB = mat3(
	vec3(0.08094, -0.01025, -0.00003),
	vec3(-0.13050, 0.05401, -0.00360),
	vec3(0.11672, -0.11361, 0.69217)
);

// Simuliert den fehlenden Zapfentyp direkt im LMS-Raum.
vec3 simulate_lms(vec3 lms, int mode) {
	vec3 result = lms;
	if (mode == 1) { // Protanopia: L-Zapfen fehlt
		result.x = 2.02344 * lms.y - 2.52581 * lms.z;
	} else if (mode == 2) { // Deuteranopia: M-Zapfen fehlt
		result.y = 0.49421 * lms.x + 1.24827 * lms.z;
	} else if (mode == 3) { // Tritanopia: S-Zapfen fehlt
		result.z = -0.395913 * lms.x + 0.801109 * lms.y;
	}
	return result;
}

void fragment() {
	vec4 screen = texture(screen_texture, SCREEN_UV);
	vec3 rgb = screen.rgb;

	// WICHTIG: kein früher "return" im fragment() erlaubt (Godot-Shader-
	// Sprache untersagt das). Stattdessen die komplette Berechnung immer
	// durchlaufen lassen und nur am Ende per mix() zwischen "unverändert"
	// und "korrigiert" wählen, je nachdem ob colorblind_mode == 0 ist.
	vec3 lms = RGB_TO_LMS * rgb;
	vec3 sim_rgb = LMS_TO_RGB * simulate_lms(lms, colorblind_mode);

	vec3 error = rgb - sim_rgb;
	vec3 correction = vec3(
		0.0,
		0.7 * error.r + error.g,
		0.7 * error.r + error.b
	);

	vec3 corrected_rgb = clamp(rgb + correction, 0.0, 1.0);

	// mode == 0 -> Faktor 0.0 -> Originalfarbe. mode > 0 -> Faktor 1.0 -> korrigiert.
	float apply_correction = step(0.5, float(colorblind_mode));
	vec3 final_rgb = mix(rgb, corrected_rgb, apply_correction);

	COLOR = vec4(final_rgb, screen.a);
}