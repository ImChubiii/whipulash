shader_type spatial;
// unshaded = flaches, ungefiltertes PS1-Licht statt moderner PBR-Beleuchtung.
// blend_mix erlaubt Transparenz. depth_draw_always erzwingt trotzdem
// normales Tiefenpuffer-Schreiben — sonst "verschwinden" Objekte scheinbar
// zufällig hinter anderen, weil transparente Objekte standardmäßig nicht
// in den Depth Buffer schreiben (führt zu Sortierungs-Chaos, wenn wie bei
// uns die meisten Sachen eigentlich voll undurchsichtig sind).
render_mode unshaded, cull_back, blend_mix, depth_draw_always;

// --- Einstellbare Werte im Godot-Inspector, sobald das Shader-Material ausgewählt ist ---
uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Wie grob das "Snap-Raster" ist. Kleinere Zahl = stärkerer Jitter-Effekt.
// 16-64 ist ein guter Startbereich zum Ausprobieren.
uniform float snap_resolution : hint_range(4.0, 128.0) = 32.0;

// Wie stark die Vertex-Positionen bei Bewegung "wackeln" (affine-Look-Approximation)
uniform float vertex_jitter_strength : hint_range(0.0, 1.0) = 0.5;

// NEU: Multiplikator für die Durchsichtigkeit, per Script veränderbar
// (z.B. für "wird durchsichtiger je weniger HP"). 1.0 = voll sichtbar.
uniform float alpha_multiplier : hint_range(0.0, 1.0) = 1.0;

// NEU: Hit-Flash — mischt die Albedo-Farbe Richtung flash_color, Stärke
// über flash_strength gesteuert (0 = kein Effekt, per Script animiert).
uniform vec4 flash_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float flash_strength : hint_range(0.0, 1.0) = 0.0;

// NEU: Welt-Raum-UV statt Mesh-UV (fuer Boden/Decke). Ein BoxMesh/PlaneMesh
// spannt seine UV normalerweise IMMER 0..1 ueber die gesamte Flaeche -
// dieselbe Schachbrett-Textur wuerde also in jedem unterschiedlich grossen
// Raum auf eine andere Kachelgroesse gestreckt/verzerrt. Mit world_space_uv
// haengt die UV stattdessen nur von der WELT-XZ-Position ab: die Kachel
// bleibt in jedem Raum exakt gleich gross, groessere Raeume zeigen einfach
// mehr Wiederholungen. Aus per Default, damit Waende/Tueren/Pfeiler (die
// dieselbe geteilte Material-Resource benutzen) weiterhin ihre normale
// Mesh-UV bekommen - siehe pit_floor.gd/room_instance.gd fuer die Stellen,
// die dies gezielt an einer DUPLIZIERTEN Material-Instanz einschalten.
uniform bool world_space_uv = false;
// 1 / Kachelgroesse in Weltunits. 1.0/24.0 = Textur wiederholt sich alle
// 24 Einheiten - im 48x48-Standardraum also genau 2x pro Achse (4x4
// sichtbare Schachbrettfelder bei einer 2x2-Textur).
uniform float world_uv_scale : hint_range(0.005, 1.0) = 0.0416667;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// Vertex in Clip-Space transformieren (wie es die GPU normalerweise am Ende macht)
	vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));

	// Die klassische PS1-"Vertex-Snapping"-Technik: Position auf ein grobes,
	// niedrig aufgelöstes Raster runden, BEVOR perspektivisch geteilt wird.
	// Das erzeugt das typische "Zittern" bei Kamerabewegung.
	vec3 snapped = clip_position.xyz / clip_position.w;
	vec2 grid = vec2(snap_resolution);
	snapped.xy = floor(snapped.xy * grid) / grid;
	snapped *= clip_position.w;

	// Zwischen Original und gesnapptem Vertex mischen, je nach gewünschter Stärke
	clip_position.xyz = mix(clip_position.xyz, snapped, vertex_jitter_strength);

	POSITION = clip_position;
}

void fragment() {
	// filter_nearest sorgt zusammen mit Import-Settings (siehe unten) für die
	// blockige, ungefilterte Textur-Optik statt weichgezeichneter moderner Texturen.
	vec2 tex_uv = world_space_uv ? world_position.xz * world_uv_scale : UV;
	vec4 tex_color = texture(albedo_texture, tex_uv);
	vec3 base_albedo = tex_color.rgb * albedo_color.rgb;
	ALBEDO = mix(base_albedo, flash_color.rgb, flash_strength);
	ALPHA = tex_color.a * albedo_color.a * alpha_multiplier;
}
