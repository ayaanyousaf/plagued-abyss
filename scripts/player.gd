extends CharacterBody2D

const SPEED = 300.0

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	var direction = Vector2.ZERO
	
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	direction = direction.normalized()
	velocity = direction * SPEED
	
	move_and_slide()
