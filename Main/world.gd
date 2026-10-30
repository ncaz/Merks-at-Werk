extends Node

const EXIT_HOLD := 0.9
const BLACK_HOLD := 0.3
const WIN_SCREEN := preload("res://HUD/win_screen.tscn")

var levels : Array[String] = [
	"00",
	"01",
	"02",
]
var level_field_counts: Array[int] = [
	1,
	3,
	8,
]


var current_level
var current_level_index: int = 1
var current_field
var current_field_index: int = 0
var map_size : Vector2
var transitioning: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_level_index = 1
	load_field(1)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Debug") and current_field and not transitioning:
		current_field.field_clear.emit()


func load_level(index : int):
	if 0 <= index and index < levels.size():
		if current_field:
			current_field.queue_free()
		current_level_index = index
		current_field_index = 0
		load_field(current_field_index)


func load_field(index : int):
	if not has_field(index):
		push_warning("No field %d in level %d" % [index, current_level_index])
		return
	if current_field:
		current_field.queue_free()
	var path := field_path(index)
	current_field = load(path).instantiate()
	current_field_index = index
	print("%s loaded" % path)
	add_child(current_field)
	map_size = current_field.map_size
	current_field.field_clear.connect(next_field)


func next_field() -> void:
	if transitioning or is_demo_field():
		return
	transitioning = true
	var next_index := current_field_index + 1
	var has_next := has_field(next_index)
	var player = get_tree().get_first_node_in_group("player")
	var wipe: ScreenWipe = get_tree().get_first_node_in_group("screen_wipe")

	player.start_exit()
	await get_tree().create_timer(EXIT_HOLD).timeout
	if wipe:
		await wipe.cover()

	clear_leftovers()
	player.finish_exit()
	if has_next:
		load_field(next_index)
	else:
		show_win(player)

	await get_tree().create_timer(BLACK_HOLD).timeout
	if wipe:
		await wipe.reveal()
	transitioning = not has_next


func show_win(player: Node) -> void:
	if current_field:
		current_field.queue_free()
		current_field = null
	player.hide()
	player.set_process(false)
	player.set_physics_process(false)
	get_tree().current_scene.add_child(WIN_SCREEN.instantiate())


func clear_leftovers() -> void:
	for node in get_tree().get_nodes_in_group("looping_entity"):
		if not node.is_in_group("player"):
			node.queue_free()
	for node in get_tree().get_nodes_in_group("enemies"):
		node.queue_free()


func has_field(index: int) -> bool:
	if index == -1:
		return true
	if index < 0 or index > level_field_counts[current_level_index]:
		return false
	return ResourceLoader.exists(field_path(index))


func field_path(index: int) -> String:
	if index == -1:
		return "res://Levels/demo_field2.tscn"
	return get_field(index)


func get_level(index: int):
	return "res://Levels/%02d/" % [index]


func get_field(index: int):
	return get_level(current_level_index) + "field_%d.tscn" % [index]


func is_demo_field():
	return get_children()[0].name.contains("Demo")
