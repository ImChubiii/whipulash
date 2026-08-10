extends GPUParticles3D

# ============================================================================
# HitSparkPrimary — wuchtiger, charakterfarbener Trefferfunke fuer
# Primaerangriffe (siehe primary_hitbox.gd _on_hit_landed_vfx()).
# ============================================================================
# Der Groessen-Schwund (voll -> 0 ueber die Lebenszeit) haengt am
# scale_curve des ParticleProcessMaterial. Dessen Punkte/Tangenten von Hand
# als [sub_resource type="Curve"] in der .tscn zu serialisieren ist
# fehleranfaellig und schlecht lesbar - der Aufbau hier im Code ist robuster
# und auf den ersten Blick verstaendlich (siehe stage_theme.gd fuer denselben
# "im Code statt in Resource-Dateien" Grundsatz im Projekt).

func _ready() -> void:
	var material: ParticleProcessMaterial = process_material as ParticleProcessMaterial
	if material == null:
		return

	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(1.0, 0.0))

	var curve_texture := CurveTexture.new()
	curve_texture.curve = curve

	material.scale_curve = curve_texture
