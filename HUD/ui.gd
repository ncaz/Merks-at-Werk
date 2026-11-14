extends CanvasLayer

var max_scroll_size: int = 0
var news_scroll_speed: int = 200

@export var ticker_message: String
var ticker_increment: int = 1

var warning_texture: Texture2D = load("res://icon.svg")
var hurry_texture: Texture2D = load("res://Powerups/powerup.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = !get_tree().paused
		$PauseMenu.visible = !$PauseMenu.visible

	# Handle News Ticker
	if ticker_increment <= len(ticker_message):
		$"News Ticker2".text += ticker_message.substr(ticker_increment, 1)
		ticker_increment += 1
	else:
		ticker_increment = 0
	$ScoreText.text = "Score: " + str(Globals.score)
	$TimerText.text = "Time: " + str(int(Globals.field_time_left))
	
	if Input.is_action_just_pressed("Left"):
		flash_time_warning()
	if Input.is_action_just_pressed("Right"):
		flash_warning()

func resume_game():
	get_tree().paused = false
	hide()
	
func flash_job():
	if $"Flash Job/AnimationPlayer".is_playing():
		$"Flash Job/AnimationPlayer".stop()
	$"Flash Job/AnimationPlayer".play("Flash Job")

func flash_warning():
	
	if !$"Warning Symbol/AnimationPlayer".is_playing():
		$"Warning Symbol/HBoxContainer/TextureRect2".texture = warning_texture
		$"Warning Symbol/HBoxContainer/Label".text = "WARNING"
		$"Warning Symbol/AnimationPlayer".play("Warning")
	else:
		await $"Warning Symbol/AnimationPlayer".animation_finished
		flash_warning()
	
func flash_time_warning():
	if !$"Warning Symbol/AnimationPlayer".is_playing():
		$"Warning Symbol/HBoxContainer/TextureRect2".texture = hurry_texture
		$"Warning Symbol/HBoxContainer/Label".text = "HURRY YOUR ASS"
		$"Warning Symbol/AnimationPlayer".play("Warning")
	else:
		await $"Warning Symbol/AnimationPlayer".animation_finished
		flash_time_warning()
