extends BaseField


func _ready():
	super()


func _process(_delta: float) -> void:
	super(_delta)


func _on_field_timer_timeout() -> void:
	print("Next level!!")
	field_clear.emit()
