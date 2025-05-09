extends RigidBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var required_key: String = "basic_key"  # ID de la llave requerida
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var is_locked: bool = true
var player_near: bool = false


func _input(event):
	if event.is_action_pressed("interact") && player_near:
		try_open()

func try_open():
	var player = get_tree().get_first_node_in_group("player")
	if player && is_locked:
		if player.inventory.has(required_key):
			player.inventory.erase(required_key)
			unlock()
			print("Puerta abierta!")
		else:
			print("Necesitas la llave correcta")

func unlock():
	is_locked = false
	animation_player.play("Open2")
	freeze = true
	collision_shape_3d.disabled = true

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player_near = true

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
