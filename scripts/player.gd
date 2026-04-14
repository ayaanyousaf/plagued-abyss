extends CharacterBody2D
@export var bullet_scene: PackedScene

signal died
signal hp_updated(hp, max_hp)

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_rate: Timer = $FireRate
@onready var regen_tick: Timer = $HealthRegenTick
@onready var regen_delay: Timer = $HealthRegenDelay

var move_speed = 180.0
var max_hp = 3
var hp = 3
var dmg = 1

var taken_damage = false
var can_shoot = true

var purchased_upgrades: Array[String] = []

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction = Vector2.ZERO
	
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	direction = direction.normalized()
	velocity = direction * move_speed
	
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
	
	bullet.damage = dmg # set bullet damage
	bullet.global_position = barrel.global_position
	
	bullet.direction = (mouse_position - barrel.global_position).normalized()
	get_parent().get_node("Bullets").add_child(bullet)
	
	fire_rate.start()

func take_damage(amount): 
	if taken_damage: 
		return 
		
	hp -= amount
	hp_updated.emit(hp, max_hp) # send hp signal to World scene
	print("Player HP:", hp) # log the players health (debug)
	
	taken_damage = true
	$DamageCooldown.start()
	
	# health regen timers
	regen_tick.stop()
	regen_delay.start()
	
	if hp <= 0: 
		die()

func die(): 
	print("Player died. Game over.")
	died.emit()
	queue_free()

func apply_upgrade(upgrade_type: String) -> bool: 
	if upgrade_type in purchased_upgrades:
		return false
		
	match upgrade_type: 
		"hp": 
			max_hp += 2 # increased hp upgrade
			hp = max_hp
			hp_updated.emit(hp, max_hp)
		"speed": 
			move_speed += 40 # increased movement speed
		"rapid_fire":
			fire_rate.wait_time = 0.1 # double fire rate
		"dmg": 
			dmg = 2
		_: 
			return false
			
	purchased_upgrades.append(upgrade_type)
	return true
			

func _on_damage_cooldown_timeout() -> void:
	taken_damage = false

func _on_fire_rate_timeout() -> void:
	can_shoot = true

func _on_health_regen_delay_timeout() -> void:
	if hp < max_hp: 
		regen_tick.start()

func _on_health_regen_tick_timeout() -> void:
	if hp < max_hp: 
		hp += 1
		hp_updated.emit(hp, max_hp)
		
	if hp >= max_hp: 
		regen_tick.stop()
