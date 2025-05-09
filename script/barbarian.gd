extends CharacterBody3D

enum State {IDLE, CHASING, ATTACKING, HIT, DEAD}

# Configuración del enemigo
@export var speed: float = 3.0
@export var detection_range: float = 10.0
@export var rotation_speed: float = 5.0
@export var health: int = 3

# Referencias
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

var current_state: State = State.IDLE
var attack_cooldown: bool = false

func _ready():
	animation_player.play("Idle")

func _physics_process(delta):
	if !player or current_state == State.DEAD:
		return
	
	match current_state:
		State.IDLE, State.CHASING:
			handle_movement(delta)
			check_attack_range()
		State.HIT, State.DEAD:
			velocity = Vector3.ZERO
	
	# Aplicar gravedad
	if !is_on_floor():
		velocity.y -= 9.8 * delta
	
	move_and_slide()

func handle_movement(delta):
	var direction: Vector3 = (player.global_position - global_position).normalized()
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player < detection_range:
		current_state = State.CHASING
		velocity = Vector3(direction.x * speed, velocity.y, direction.z * speed)
		
		# Rotación suave
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)
		
		play_animation("Walking_A")
	else:
		current_state = State.IDLE
		velocity = Vector3.ZERO
		play_animation("Idle")

func check_attack_range():
	var distance = global_position.distance_to(player.global_position)
	if distance < 2.0 and !attack_cooldown and current_state != State.HIT:
		attack()

func play_animation(anim_name: String):
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)

func attack():
	current_state = State.ATTACKING
	attack_cooldown = true
	animation_player.stop()
	animation_player.play("1H_Melee_Attack_Chop")
	await animation_player.animation_finished
	if current_state != State.DEAD:
		current_state = State.CHASING
	attack_cooldown = false

func apply_damage(damage: int) -> void:
	if current_state == State.DEAD:
		return
	
	health -= damage
	print("Salud restante: ", health)
	
	animation_player.stop()
	current_state = State.HIT
	animation_player.play("Hit_B")
	
	if health <= 0:
		handle_death()
	else:
		await animation_player.animation_finished
		if current_state != State.DEAD:
			current_state = State.CHASING

func handle_death():
	current_state = State.DEAD
	animation_player.stop()
	animation_player.play("Death_A")
	await animation_player.animation_finished
	queue_free()

func _on_axe_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and current_state == State.ATTACKING:
		Global.player_hp -= 1

func _on_detection_area_body_entered(body: Node3D):
	if body.is_in_group("player") and current_state != State.DEAD:
		current_state = State.CHASING

func _on_detection_area_body_exited(body: Node3D):
	if body.is_in_group("player"):
		current_state = State.IDLE

func _on_animation_finished(anim_name: String):
	match anim_name:
		"Hit_B":
			if health > 0:
				current_state = State.CHASING
		"Death_A":
			queue_free()
