extends CharacterBody2D
@export var bullet_scene: PackedScene

signal died
signal hp_updated(hp)

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_rate: Timer = $FireRate

const SPEED = 180.0
var hp = 3
var taken_damage = false
var can_shoot = true


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
	
	# Switch between idle and move animations
	if direction != Vector2.ZERO: 
		animation.play("Move")
	else: 
		animation.play("Idle")
	
	# Shooting logic with fire rate timer
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
	
func shoot(): 
	can_shoot = false
	
	var mouse_position = get_global_mouse_position()
	var barrel = $Barrel
	var bullet = bullet_scene.instantiate()
	bullet.global_position = barrel.global_position
	
	bullet.direction = (mouse_position - barrel.global_position).normalized()
	get_parent().get_node("Bullets").add_child(bullet)
	
	fire_rate.start()

func take_damage(amount): 
	if taken_damage: 
		return 
		
	hp -= amount
	hp_updated.emit(hp) # send hp signal to World scene
	print("Player HP:", hp) # log the players health (debug)
	
	taken_damage = true
	$DamageCooldown.start()
	
	if hp <= 0: 
		die()

func die(): 
	print("Player died. Game over.")
	died.emit()
	queue_free()	

func _on_damage_cooldown_timeout() -> void:
	taken_damage = false

func _on_fire_rate_timeout() -> void:
	can_shoot = true
