extends RigidBody3D


@onready var animation_player: AnimationPlayer = $AnimationPlayer

func rise_from_ground():
	freeze = true  # Congelar física
	animation_player.play("rise")
	await animation_player.animation_finished
	freeze = false  # Reactivar física
