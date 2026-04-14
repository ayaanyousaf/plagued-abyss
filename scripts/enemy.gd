extends CharacterBody2D

const SPEED = 60.0
const STOP_DISTANCE = 20.0 # closest the enemy can get to player (no complete overlap)

@onready var attack_range: Area2D = $AttackRange
@onready var attack_cooldown: Timer = $AttackCooldown

@onready var hit_SFX: AudioStreamPlayer2D = $HitSFX
@onready var kill_SFX: AudioStreamPlayer2D = $KillSFX

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

# Point system signals
signal hit(points)
signal died(points)

var hp = 2
var player: CharacterBody2D = null
var player_in_range = false # checks if player is in attack range
var can_attack = true # tracks if attack cooldown is active or not
var is_attacking = false
var is_dead = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null: 
		return
		
	nav_agent.target_position = player.global_position
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player > STOP_DISTANCE: 
		var next_path_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		velocity = direction * SPEED
	else: 
		velocity = Vector2.ZERO

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
	if is_dead: 
		return 
		
	hp -= amount
	
	if hp <= 0:
		is_dead = true
		died.emit(60) # reward player 50 points for kill + 10 for last hit
		kill_SFX.play()
		
		$CollisionShape2D.set_deferred("disabled", true)
		$AttackRange.monitoring = false
		$AttackRange.monitorable = false
		
		set_physics_process(false)
		visible = false
		
		await kill_SFX.finished # wait for SFX to finish
		queue_free()
	else: 
		hit.emit(10) # give player 10 points for a successful hit
		hit_SFX.play()

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
