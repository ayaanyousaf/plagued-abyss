extends Node2D

@export var world_scene: PackedScene
@onready var world_container = $WorldContainer

@onready var menu_UI = $UI/Menu
@onready var controls_overlay = $UI/Menu/ControlsOverlay
@onready var game_UI = $UI/Game
@onready var gameover_UI = $UI/GameOver

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
	
func start_game(): 
	clear_world()

	current_world = world_scene.instantiate()
	world_container.add_child(current_world)
	
	# Connect signal from world (change state if player dies)
	current_world.player_died.connect(_on_player_died)
	
	change_state(GameState.PLAY)

func end_game(): 
	clear_world()
	change_state(GameState.GAME_OVER)
	
	if Input.is_action_just_pressed("continue"): 
		change_state(GameState.MENU)

# Resets world state
func clear_world() -> void: 
	print("WORLD CLEARED")
	if current_world != null: 
		current_world.queue_free()
		current_world = null 

# Updates global game state
func change_state(state):
	current_state = state
	
	menu_UI.visible = (state == GameState.MENU)
	game_UI.visible = (state == GameState.PLAY)
	gameover_UI.visible = (state == GameState.GAME_OVER)
	
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
	
func _on_player_died() -> void: 
	end_game()

func _unhandled_input(event: InputEvent) -> void:
	if current_state == GameState.GAME_OVER and event.is_action_pressed("continue"):
		change_state(GameState.MENU)
