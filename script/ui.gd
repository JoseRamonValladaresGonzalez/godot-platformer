extends CanvasLayer

@onready var player_coins: Label = $VBoxContainer/Player_coins
@onready var player_hp: Label = $VBoxContainer/Player_hp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_coins.text = "Coins = "+ str(Global.Player_coin)
	player_hp.text = "hp = " + str(Global.player_hp) + "/4"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player_coins.text = "Coins = "+ str(Global.Player_coin)
	player_hp.text = "hp = " + str(Global.player_hp) + "/4"
