extends RigidBody3D


var health := 3

# Método para aplicar daño
func apply_damage(damage: int) -> void:
	health -= damage
	print("El enemigo ha recibido daño. Salud restante: ", health)
	if health <= 0:
		queue_free()  # El enemigo se elimina cuando su salud llega a 0
