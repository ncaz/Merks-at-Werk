extends BaseField


func _ready():
	super()


func _process(_delta: float) -> void:
	super(_delta)


func _on_field_timer_timeout() -> void:
	super()

func _check_all_stations_destroyed():
	print("Station count: ", get_tree().get_node_count_in_group("station"), ", Destroyed count: ", get_tree().get_node_count_in_group("destroyed"))
	if (
		get_tree().get_node_count_in_group("station")
		== get_tree().get_node_count_in_group("destroyed")
		):
		print("Field complete!")
		await get_tree().create_timer(2.5).timeout
		get_tree().change_scene_to_file("res://Main/main.tscn")
