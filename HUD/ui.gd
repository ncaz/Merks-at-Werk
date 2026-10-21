extends CanvasLayer

var max_scroll_size: int = 0
var news_scroll_speed: int = 200

@export var ticker_message: String
var ticker_increment: int = 1

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

	#Increases the timer every second
	$TimerText.text = "Timer: " + str(int(Globals.field_time_left))

func resume_game():
	get_tree().paused = false
	hide()
