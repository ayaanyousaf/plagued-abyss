extends Area2D

@export var cost: int = 1000
@export var hold_time: float = 1.5
@export var room_to_unlock: String = ""

@onready var closed_sprite: Sprite2D = $ClosedSprite
@onready var open_sprite: Sprite2D = $OpenSprite
@onready var blocker: CollisionShape2D = $Blocker/CollisionShape2D

@onready var hold_timer: Timer = $HoldTimer
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var prompt_label: Label = $Prompt
@onready var denied_sfx: AudioStreamPlayer2D = $DeniedSFX
@onready var purchase_sfx: AudioStreamPlayer2D = $PurchaseSFX

var player_in_range = false
var player: CharacterBody2D = null
var world: Node2D = null
var is_holding_interact = false
var purchased = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world = get_parent()
	
	hold_timer.one_shot = true
	hold_timer.wait_time = hold_time
	
	prompt_label.visible = false
	
	progress_bar.visible = false
	progress_bar.min_value = 0.0
	progress_bar.max_value = hold_time
	progress_bar.value = 0.0
	
	closed_sprite.visible = true
	open_sprite.visible = false
	
func _process(delta: float) -> void:
	if purchased: 
		return
		
	if not player_in_range: 
		return
	
	if Input.is_action_just_pressed("interact"): 
		start_hold()
		
	if Input.is_action_pressed("interact") and is_holding_interact:
		progress_bar.value += delta
		progress_bar.value = min(progress_bar.value, hold_time)
	
	if Input.is_action_just_released("interact"): 
		stop_hold()
		
func start_hold(): 
	if player == null or world == null: 
		return
		
	if purchased:
		return
		
	is_holding_interact = true
	progress_bar.visible = true
	progress_bar.value = 0.0
	hold_timer.start()

func stop_hold(): 
	is_holding_interact = false
	hold_timer.stop()
	progress_bar.value = 0.0
	progress_bar.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		player = body
		
		if purchased:
			prompt_label.text = ""
		else:
			prompt_label.text = "Hold F to open door (%d)" % cost
		
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == player: 
		player_in_range = false
		player = null
		
		stop_hold()
		
		prompt_label.visible = false
		progress_bar.visible = false

func _on_hold_timer_timeout() -> void:
	is_holding_interact = false
	progress_bar.value = 0.0
	progress_bar.visible = false
	
	if not world.can_afford(cost): 
		prompt_label.text = "Not enough points"
		denied_sfx.play()
		return
				
	var spent_points = world.spend_points(cost)
	if not spent_points: 
		return
	
	purchased = true
	purchase_sfx.play()
	
	if room_to_unlock != "": 
		world.unlock_room(room_to_unlock)
	
	blocker.set_deferred("disabled", true)
	closed_sprite.visible = false
	open_sprite.visible = true
	
