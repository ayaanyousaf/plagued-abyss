extends Node2D

@export var enemy_scene: PackedScene
@export var unlocked: bool = true

@onready var player = $"../Player"
@onready var enemies = $"../Enemies"
@onready var spawn_points = $"../SpawnPoints"

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
	var possible_spawn_points = []
	var world = get_parent()
	
	for point in spawn_points.get_children(): 
		if not point is Marker2D: 
			continue
		
		var spawn_allowed = false
		for room in world.unlocked_rooms: 
			if point.is_in_group(room):
				spawn_allowed = true
				break
		
		if not spawn_allowed: 
			continue
			
		var distance = point.global_position.distance_to(player.global_position)
		
		if distance > 150 and distance < 500: 
			possible_spawn_points.append(point)
			
	if possible_spawn_points.is_empty():
		return Vector2.ZERO
	
	var chosen_spawn = possible_spawn_points[randi() % possible_spawn_points.size()]
	var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
	
	return chosen_spawn.global_position + offset
