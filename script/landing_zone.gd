extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"): # Asegúrate de que el jugador está en el grupo "player"
		body.enter_landing_zone(self)


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.exit_landing_zone(self)

@export var chest_scene: PackedScene  # Asigna Chest.tscn en el inspector

var chest_spawned: bool = false

func activate_effect():
	if chest_scene != null and not chest_spawned and is_inside_tree():
		var chest_instance: Node3D = chest_scene.instantiate()
		# Añadir a la escena raíz y asignar posición global
		get_tree().root.add_child(chest_instance)
		chest_instance.global_position = global_position
		# Resetear rotación/scale si es necesario
		chest_instance.global_rotation = Vector3.ZERO
		chest_instance.scale = Vector3.ONE
		chest_instance.rise_from_ground()
		chest_spawned = true
