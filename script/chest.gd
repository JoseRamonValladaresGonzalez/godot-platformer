extends RigidBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func rise_from_ground() -> void:
	# Asegurar que el AnimationPlayer está listo
	if animation_player:
		animation_player.play("rise")
	else:
		push_error("AnimationPlayer no encontrado en el cofre")
