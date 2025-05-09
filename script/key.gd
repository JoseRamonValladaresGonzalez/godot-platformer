extends Area3D

@export var key_id: String = "basic_key"  # ID único para la llave

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_to_inventory(key_id)
		queue_free()
		print("Llave obtenida:", key_id)
