extends GPUParticles3D

func _ready() -> void:
	# Partikel beim Spawnen sofort abfeuern
	emitting = true
	
	# Sobald der One-Shot Effekt fertig ist, wird diese Szene automatisch geloescht
	# Das verhindert, dass das Spiel im Speicher mit alten Partikeln volllaeuft
	finished.connect(queue_free)
