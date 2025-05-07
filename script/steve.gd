extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var double_jump = true

func _physics_process(delta: float) -> void:
	
	
	$Camera_controller.position = lerp($Camera_controller.position, position, 0.15)
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			double_jump = true  # Habilitas el segundo salto
		elif double_jump:
			velocity.y = JUMP_VELOCITY
			double_jump = false  # Lo usas y lo desactivas

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
