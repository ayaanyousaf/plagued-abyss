extends Node2D

signal player_died

@onready var player = $Player
@onready var enemies = $Enemies
@onready var wave_spawner = $WaveSpawner

var current_wave = 1 # Initialize wave

func _ready() -> void:
	player.died.connect(_on_player_died) # World checks if player died 
	start_wave()

func _process(delta: float) -> void: 
	if enemies.get_child_count() == 0: 
		start_next_wave()
	
func start_wave(): 
	wave_spawner.spawn_wave(current_wave)
	
# Starts the next wave and updates wave counter
func start_next_wave(): 
	current_wave += 1
	wave_spawner.spawn_wave(current_wave)

func _on_player_died() -> void:
	player_died.emit() # World forwards signal telling main that player died
