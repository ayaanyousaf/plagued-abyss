extends Node2D

@export var world_scene: PackedScene
@onready var world_container = $WorldContainer

@onready var menu_UI = $UI/Menu
@onready var controls_overlay = $UI/Menu/ControlsOverlay
@onready var game_UI = $UI/Game
@onready var gameover_UI = $UI/GameOver
@onready var game_over_message = $UI/GameOver/GameOverMessage

@onready var wave_label = $UI/Game/Wave
@onready var hp_bar = $UI/Game/HealthBar
@onready var score_label = $UI/Game/Score

@onready var menu_music: AudioStreamPlayer = $MenuMusic
@onready var gameplay_music: AudioStreamPlayer = $GameMusic

# Define game states
enum GameState {
	MENU,
	PLAY,
	GAME_OVER
}

var current_state = GameState.MENU # state is MENU on launch
var current_world: Node2D = null # initialize game world

func _ready() -> void:
	change_state(GameState.MENU)

# Handles "Play" button press in main menu
func _on_play_pressed() -> void:
	print("PLAY BUTTON CLICKED")
	start_game()

# Starts a new game with a fresh world
func start_game(): 
	clear_world()

	current_world = world_scene.instantiate()
	world_container.add_child(current_world)
	
	# Connect signals from world (wave count, player death, score updates)
	current_world.player_died.connect(_on_player_died)
	current_world.wave_started.connect(_on_wave_started)
	current_world.player_hp_updated.connect(_on_player_hp_updated)
	current_world.score_updated.connect(_on_score_updated)
	
	change_state(GameState.PLAY)

func end_game(final_wave): 
	clear_world()
	change_state(GameState.GAME_OVER)
	
	game_over_message.text = "You survived " + str(final_wave) + " waves" 
	
	if Input.is_action_just_pressed("continue"): 
		change_state(GameState.MENU)

# Resets world state
func clear_world() -> void: 
	print("WORLD CLEARED")
	
	score_label.text = "0"
	
	hp_bar.max_value = 3
	hp_bar.value = 3
	
	if current_world != null: 
		current_world.queue_free()
		current_world = null 

# Updates global game state
func change_state(state):
	current_state = state
	
	menu_UI.visible = (state == GameState.MENU)
	game_UI.visible = (state == GameState.PLAY)
	gameover_UI.visible = (state == GameState.GAME_OVER)
	
	# Play appropriate music depending on game state
	if state == GameState.MENU: 
		if not menu_music.playing: 
			menu_music.play()
		gameplay_music.stop()
	
	if state == GameState.PLAY: 
		if not gameplay_music.playing: 
			gameplay_music.play()
		menu_music.stop()
		
	if state == GameState.GAME_OVER: 
		gameplay_music.stop()
		menu_music.stop()
	
# Handles "Exit" button press in main menu
func _on_exit_pressed() -> void:
	print("Exit pressed")
	get_tree().quit()

# Handles "Controls" button press in main menu
func _on_controls_pressed() -> void:
	print("Controls pressed")
	controls_overlay.visible = true

func _on_close_controls_pressed() -> void:
	controls_overlay.visible = false
	
func _on_player_died(final_wave: int) -> void: 
	end_game(final_wave)

func _on_player_hp_updated(hp: int, max_hp: int) -> void: 
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	
func _on_score_updated(score: int) -> void: 
	score_label.text = str(score)
	
func _on_wave_started(wave: int) -> void: 
	wave_label.text = "Wave " + str(wave)

func _unhandled_input(event: InputEvent) -> void:
	if current_state == GameState.GAME_OVER and event.is_action_pressed("continue"):
		change_state(GameState.MENU)
