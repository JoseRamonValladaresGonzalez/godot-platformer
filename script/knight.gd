extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5
const GRAVITY := 9.8
const COYOTE_TIME := 0.2

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_controller: Node3D = $Camera_controller
@onready var attack_hitbox: Area3D = $"Rig/Skeleton3D/2H_Sword/Area3D"  # Asumiendo que el Area3D está dentro de la espada

var is_attacking := false
var coyote_timer: float = 0.0
var double_jump: bool = true

var overlapping_landing_zones: Array = []
var was_in_air: bool = false

func enter_landing_zone(zone: Area3D):
	overlapping_landing_zones.append(zone)

func exit_landing_zone(zone: Area3D):
	overlapping_landing_zones.erase(zone)


func _ready():
	# Conectar la señal para manejar el fin de la animación
	animation_player.animation_finished.connect(_on_animation_finished)
	
	# Desactivar el hitbox al inicio
	attack_hitbox.collision_layer = 0
	attack_hitbox.collision_mask = 0
	# Conectar la señal de colisión para el hitbox de la espada

func _on_animation_finished(anim_name: String) -> void:
	# Cuando termine la animación de ataque, desactivar el estado de ataque
	if anim_name == "1H_Melee_Attack_Slice_Horizontal":
		is_attacking = false
		attack_hitbox.collision_layer = 0  # Desactivar el hitbox después de atacar
		attack_hitbox.collision_mask = 0
		print("Fin del ataque")

func _physics_process(delta: float) -> void:
	# Suaviza el seguimiento de la cámara
	camera_controller.position = camera_controller.position.lerp(position, 0.15)

	# Gravedad y coyote time
	if not is_on_floor():
		velocity.y -= GRAVITY * delta  # Mantener la gravedad aunque esté atacando
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME
		double_jump = true


	if Input.is_action_just_pressed("cam_left"):
		$Camera_controller.rotate_y(deg_to_rad(-30))
	if Input.is_action_just_pressed("cam_right"):
		$Camera_controller.rotate_y(deg_to_rad(30))


	# Saltar
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() or coyote_timer > 0.0:
			velocity.y = JUMP_VELOCITY
			coyote_timer = 0.0
		elif double_jump:
			velocity.y = JUMP_VELOCITY
			double_jump = false

	# Evitar movimiento mientras se está atacando
	if is_attacking:
		# Detener completamente el movimiento horizontal
		velocity.x = 0
		velocity.z = 0
		# Aseguramos que el nodo sigue cayendo por la gravedad
		move_and_slide()  # Mantenemos el movimiento en el eje Y
		return  # Salir del proceso para no ejecutar más código de movimiento

	# Movimiento absoluto (independiente de la rotación del personaje)
	var input_direction := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_direction.z -= 1
	if Input.is_action_pressed("move_back"):
		input_direction.z += 1
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1

	input_direction = input_direction.normalized()

	# Movimiento
	if input_direction != Vector3.ZERO:
		velocity.x = input_direction.x * SPEED
		velocity.z = input_direction.z * SPEED

		# Rotar personaje hacia dirección de movimiento
		var angle := atan2(input_direction.x, input_direction.z)
		rotation.y = angle

		# Reproducir animación de caminar
		if animation_player.current_animation != "Walking_A":
			animation_player.play("Walking_A")
	else:
		velocity.x = 0
		velocity.z = 0

		# Reproducir animación de idle
		if animation_player.current_animation != "Idle":
			animation_player.play("Idle")

	# ATAQUE
	if Input.is_action_just_pressed("attack") and not is_attacking:
		print("¡Atacando!")  # Verifica si la acción de ataque se detecta
		is_attacking = true
		attack_hitbox.collision_layer = 1  # Activar el hitbox para detectar colisiones (capa de colisión)
		attack_hitbox.collision_mask = 1  # Asegúrate de que el hitbox interactúe con los enemigos
		animation_player.play("1H_Melee_Attack_Slice_Horizontal")

	var just_landed: bool = false
	if not is_on_floor():
		was_in_air = true
	else:
		if was_in_air:
			just_landed = true
			was_in_air = false
	
	# Activar zonas al aterrizar
	if just_landed and not overlapping_landing_zones.is_empty():
		for zone in overlapping_landing_zones:
			zone.activate_effect()

	# No ejecutar el movimiento si estás atacando
	move_and_slide()

# Cuando el área de la espada colisiona con un cuerpo (en este caso un enemigo)
func _on_area_3d_body_entered(body: Node3D) -> void:
	# Aquí detectamos si el cuerpo que entra es un enemigo
	if body.is_in_group("enemies"):  # Asegúrate de que los enemigos estén en el grupo "enemies"
		body.apply_damage(1)  
