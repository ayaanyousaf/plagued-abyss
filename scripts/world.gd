extends Node2D

signal player_died(final_wave)
signal player_hp_updated(hp, max_hp)
signal wave_started(wave)
signal score_updated(score)

@onready var player = $Player
@onready var enemies = $Enemies
@onready var wave_spawner = $WaveSpawner

var current_wave = 1 # Initialize wave
var waiting_for_next_wave = false

var score = 0

func _ready() -> void:
	score = 0 # reset score 
	score_updated.emit(score)
	
	player.died.connect(_on_player_died) # World checks if player died 
	player.hp_updated.connect(_on_player_hp_updated)
	start_wave()

func _process(delta: float) -> void: 
	if waiting_for_next_wave: 
		return
		
	wave_spawner.spawn_until_max()
	
	# Go to the next wave if all enemies have spawned and died
	if wave_spawner.spawned_enemies >= wave_spawner.total_enemies and enemies.get_child_count() == 0: 
		waiting_for_next_wave = true
		start_next_wave()
	
func start_wave(): 
	wave_started.emit(current_wave)
	wave_spawner.spawn_wave(current_wave)
	
# Starts the next wave and updates wave counter
func start_next_wave(): 
	await get_tree().create_timer(10.0).timeout # delay before next wave starts
	current_wave += 1
	waiting_for_next_wave = false
	start_wave()
	
func connect_enemy_signals(enemy): 
	enemy.hit.connect(_on_enemy_hit)
	enemy.died.connect(_on_enemy_died)

func _on_player_died() -> void:
	player_died.emit(current_wave) # World forwards signal telling main that player died

func _on_player_hp_updated(hp: int, max_hp: int) -> void: 
	player_hp_updated.emit(hp, max_hp)
	
func _on_enemy_hit(points: int) -> void: 
	score += points # update score when enemy gets hit
	score_updated.emit(score)
	
func _on_enemy_died(points: int) -> void: 
	score += points # update score when enemy dies
	score_updated.emit(score)
	
func can_afford(cost: int) -> bool: 
	return score >= cost
	
func spend_points(amount: int) -> bool: 
	if score < amount: 
		return false
		
	score -= amount
	score_updated.emit(score)
	return true
	
