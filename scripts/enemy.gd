extends CharacterBody2D

const SPEED = 100.0
var player: CharacterBody2D = null
var hp = 2

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null: 
		return
		
	var to_player_vector = player.global_position - global_position
	var to_player_distance = to_player_vector.length()
	
	if to_player_distance > 10: 
		var direction = to_player_vector.normalized()
		velocity = direction * SPEED
	else: 
		velocity = Vector2.ZERO # stop the enemy when it reaches (hits) player

	move_and_slide()
	look_at(player.global_position)

# Function for enemy to take damage given an amount 
func take_damage(amount): 
	hp -= amount
	if hp <= 0: 
		queue_free()

# Function to detect if enemy has hit the player (enemy hitbox entered player hurtbox)
func _on_hit_box_area_entered(area: Area2D) -> void:
	var entered = area.get_parent()
	
	if entered.is_in_group("player"):
		entered.take_damage(1)
