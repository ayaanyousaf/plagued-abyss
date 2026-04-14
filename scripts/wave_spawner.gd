extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_radius = 500.0

@onready var player = $"../Player"
@onready var enemies = $"../Enemies"

var spawned_enemies: int = 0 # total enemies spawned so far
var total_enemies: int = 0 # total number of enemies for the wave
var max_enemies_alive: int = 0 # max number of enemies that can be in the game at once
var spawning: bool = false # tracks if a wave is in progress

func spawn_wave(wave: int): 
	spawned_enemies = 0
	total_enemies = wave * 3 + 4
	
	max_enemies_alive = min(10 + wave, 30)
	spawning = true
	
	spawn_until_max()

func spawn_until_max(): 
	while spawned_enemies < total_enemies and enemies.get_child_count() < max_enemies_alive:
		spawn_enemy()

# Spawns a single enemy
func spawn_enemy(): 
	var enemy = enemy_scene.instantiate()
	enemy.global_position = get_enemy_position()
	enemies.add_child(enemy)
	
	# When a new enemy is spawned, connect its signals to world to update score
	var world = get_parent()
	world.connect_enemy_signals(enemy)
	
	spawned_enemies += 1

func get_enemy_position(): 
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	
	return player.global_position + offset
