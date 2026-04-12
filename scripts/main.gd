extends Node2D

@onready var menu_UI = $UI/Menu
@onready var game_UI = $UI/Game
@onready var gameover_UI = $UI/GameOver

@onready var controls_overlay = $UI/Menu/ControlsOverlay

@onready var player = $Player
@onready var enemies = $Enemies

# Define game states
enum GameState {
	MENU,
	PLAY,
	GAME_OVER
}

var current_state = GameState.MENU # state is MENU on launch


func _ready() -> void:
	change_state(GameState.MENU)

# Handles "Play" button press in main menu
func _on_play_pressed() -> void:
	print("PLAY BUTTON CLICKED")
	start_game()
	
func start_game(): 
	change_state(GameState.PLAY)
	
func end_game(): 
	change_state(GameState.GAME_OVER)
	
# Update global game state
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
