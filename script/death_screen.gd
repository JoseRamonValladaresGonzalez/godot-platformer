extends Control



func _on_button_pressed() -> void:
	Global.Player_coin = 0
	Global.player_hp = 4
	get_tree().change_scene_to_file("res://level/level_1.tscn")
