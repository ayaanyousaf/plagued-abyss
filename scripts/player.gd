extends CharacterBody2D
@export var bullet_scene: PackedScene

const SPEED = 300.0

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction = Vector2.ZERO
	
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	direction = direction.normalized()
	velocity = direction * SPEED
	
	move_and_slide()
	
	# Face player towards mouse position at all times
	look_at(get_global_mouse_position())
	
	# Shoot logic
	if (Input.is_action_just_pressed("shoot")):
		shoot()
	

func shoot(): 
	var mouse_position = get_global_mouse_position()
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	
	bullet.direction = (mouse_position - global_position).normalized()
	get_tree().current_scene.add_child(bullet)
