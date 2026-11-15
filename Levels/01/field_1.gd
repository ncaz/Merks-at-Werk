extends BaseField


func _ready():
	super()


func _process(_delta: float) -> void:
	super(_delta)
	if Input.is_action_just_pressed("Skip"):
		field_clear.emit()


func _on_field_timer_timeout() -> void:
	print("Next level!!")
	field_clear.emit()
