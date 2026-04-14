extends Area2D

@export var upgrade_type: String = "hp"
@export var cost: int = 1500
@export var hold_time: float = 1.5

@onready var hold_timer: Timer = $HoldTimer
@onready var prompt_label: Label = $Prompt
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var denied_SFX: AudioStreamPlayer2D = $DeniedSFX
@onready var ambience: AudioStreamPlayer2D = $PortalAmbience

var player_in_range = false
var player: CharacterBody2D = null
var world: Node2D = null
var is_holding_interact = false
var purchased = false

# Variables for portal ambience fading effect
var target_volume := -40.0
const FADE_SPEED := 5.0   # higher = faster fade
const FULL_VOLUME := -5.0
const LOW_VOLUME := -40.0

func _ready() -> void:
	world = get_parent()
	
	hold_timer.one_shot = true
	hold_timer.wait_time = hold_time
	
	prompt_label.visible = false
	progress_bar.visible = false
	progress_bar.min_value = 0.0
	progress_bar.max_value = hold_time
	progress_bar.value = 0.0
	
	ambience.volume_db = LOW_VOLUME
	ambience.play()

func _process(delta: float) -> void:
	# Fade ambient portal sounds
	ambience.volume_db = lerp(ambience.volume_db, target_volume, delta * FADE_SPEED)
	
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
	if body.is_in_group("player"):  # prompt player if they get close to upgrade
		player_in_range = true
		player = body
		
		target_volume = FULL_VOLUME
		
		var upgrade_name = ""
		match upgrade_type:
			"hp":
				upgrade_name = "Health"
			"speed":
				upgrade_name = "Speed"
			"rapid_fire":
				upgrade_name = "Fire Rate"
			"dmg":
				upgrade_name = "Damage"
			_:
				upgrade_name = upgrade_type
		
		if purchased:
			prompt_label.text = "Already owned"
		else:
			prompt_label.text = "Hold F to buy %s upgrade (%d)" % [upgrade_name, cost]
		
		prompt_label.visible = true
		
func _on_body_exited(body: Node2D) -> void:
	if body == player: 
		player_in_range = false
		player = null
		
		stop_hold()
		target_volume = LOW_VOLUME
		
		prompt_label.visible = false
		progress_bar.visible = false

# Attempts to purchase upgrade after player holds interact
func _on_hold_timer_timeout() -> void: 
	is_holding_interact = false
	progress_bar.value = 0.0
	progress_bar.visible = false
	
	if not world.can_afford(cost): 
		prompt_label.text = "Not enough points"
		denied_SFX.play()
		return
		
	var applied = player.apply_upgrade(upgrade_type)
	if not applied: 
		prompt_label.text = "Already owned"
		return
		
	var spent_points = world.spend_points(cost)
	if not spent_points: 
		return
	
	purchased = true
	
	prompt_label.text = "Purchased"
		
	
