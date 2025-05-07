extends Node3D

@onready var spawn_point: Marker3D = $Spawn_point

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.player_hp == 0:
		get_tree().change_scene_to_file("res://level/death_screen.tscn")


func _on_void_body_entered(body: Node3D) -> void:
	body.global_transform.origin = spawn_point.global_transform.origin
