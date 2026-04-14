extends CharacterBody2D

const SPEED = 50.0
const STOP_DISTANCE = 20.0 # closest the enemy can get to player (no complete overlap)

@onready var attack_range: Area2D = $AttackRange
@onready var attack_cooldown: Timer = $AttackCooldown

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

# Point system signals
signal hit(points)
signal died(points)

var hp = 2
var player: CharacterBody2D = null
var player_in_range = false # checks if player is in attack range
var can_attack = true # tracks if attack cooldown is active or not
var is_attacking = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null: 
		return
		
	var to_player_vector = player.global_position - global_position
	var to_player_distance = to_player_vector.length()
	
	if to_player_distance > STOP_DISTANCE: 
		var direction = to_player_vector.normalized()
		velocity = direction * SPEED
	else: 
		velocity = Vector2.ZERO # stop the enemy when it reaches (hits) player

	move_and_slide()
	look_at(player.global_position)
	
	# Attack player if in range
	if player_in_range and can_attack and not is_attacking: 
		attack()
		return
	
	# Switch between idle and move animations without interrupting attack animation
	if not is_attacking: 
		if velocity.length() > 0.1: 
			if animation.animation != "Move": 
				animation.play("Move")
		else: 
			if animation.animation != "Idle": 
				animation.play("Idle")
	
# Performs an attack on the player 
func attack(): 
	if player == null: 
		return
		
	is_attacking = true
	velocity = Vector2.ZERO
	animation.play("Attack")
		
	can_attack = false 
	player.take_damage(1)
	attack_cooldown.start()

# Computes amount of damage taken by the enemy
func take_damage(amount): 
	hit.emit(10) # give player 10 points for a successful hit
	
	hp -= amount
	if hp <= 0: 
		died.emit(50) # give player 50 points for a successful kill
		queue_free()

# Detects if player entered attack range
func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"): 
		player_in_range = true
		
# Detects if player exited attack range
func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"): 
		player_in_range = false
		

func _on_attack_cooldown_timeout() -> void:
	can_attack = true

# Checks if the current animation has finished
func _on_animated_sprite_2d_animation_finished() -> void:
	if animation.animation == "Attack": 
		is_attacking = false
