class_name BaseField
extends Node2D

@export var spawn_position : Vector2 = Vector2.ZERO
@export var bonus_points  : int = 40
@export var timer_enabled : bool = true
@export var max_time : int = 60

@export var missile_scene : PackedScene = preload("res://Enemy/missile_enemy.tscn")

@onready var field_timer: Node = $FieldTimer
@onready var spawn_timer: Node = $SpawnTimer

@onready var player = get_tree().get_first_node_in_group("player")
@onready var stations = $Stations

signal field_clear

var map_size: Vector2

func _ready():
	player.global_position = spawn_position
	Globals.player_position = spawn_position
	if timer_enabled:
		print("start field timer")
		field_timer.wait_time = max_time
		field_timer.start()
	
	# Get map size and bounds using tile map.
	var tile_map = $ParallaxBackground/Parallax2D/TileMapLayer
	
	map_size = Vector2(tile_map.get_used_rect().size) * Vector2(tile_map.tile_set.tile_size) * tile_map.scale
	get_parent().map_size = map_size
	$ParallaxBackground/Parallax2D.repeat_size = map_size
	$ParallaxBackground/Parallax2D.repeat_times = 3
	$ParallaxBackground/Parallax2D.scroll_offset = spawn_position
	var start = tile_map.to_global(tile_map.map_to_local(tile_map.get_used_rect().position))
	var end = tile_map.to_global(tile_map.map_to_local(tile_map.get_used_rect().end))
	
	var map_bounds = Rect2(start, end - start)
	
	Globals.map_size = map_size
	Globals.map_bounds = map_bounds
	$ParallaxBackground/Parallax2D.scroll_offset = spawn_position
	
	for s in stations.get_children():
		s.destroyed.connect(_check_all_stations_destroyed)
	
	print("map bounds = ", Globals.map_bounds)
	print("map size = ", Globals.map_size)
	print("spawn position = ", spawn_position)

	print("Station count: ", get_tree().get_node_count_in_group("station"), ", Destroyed count: ", get_tree().get_node_count_in_group("destroyed"))

func _process(_delta: float) -> void:
	if timer_enabled:
		Globals.field_time_left = field_timer.time_left


func _on_spawn_timer_timeout() -> void:
	var missile = missile_scene.instantiate()
	var screen_size = DisplayServer.screen_get_size()
	var edge_pos : Vector2 = screen_size * 3 / 2
	var location = randi() % 4
	match location:
		0:
			edge_pos.x = randi_range(-edge_pos.x, edge_pos.x)
			edge_pos.y = -edge_pos.y #top edge
		1:
			edge_pos.x = randi_range(-edge_pos.x, edge_pos.x)
			edge_pos.y = edge_pos.y #bottom edge
		2:
			edge_pos.x = -edge_pos.x #left edge
			edge_pos.y = randi_range(-edge_pos.y, edge_pos.y)
		3:
			edge_pos.x = edge_pos.x #right edge
			edge_pos.y = randi_range(-edge_pos.y, edge_pos.y)
	missile.global_position = get_viewport().get_camera_2d().global_position + edge_pos
	missile.axis = (Globals.player_position - missile.global_position).normalized()
	missile.look_at(Globals.player_position)
	add_child(missile)
	print("Booyakasha! gp = ", missile.global_position, ", edge = ", edge_pos)
	spawn_timer.start()


func _check_all_stations_destroyed():
	print("Station count: ", get_tree().get_node_count_in_group("station"), ", Destroyed count: ", get_tree().get_node_count_in_group("destroyed"))
	if (
		get_tree().get_node_count_in_group("station")
		== get_tree().get_node_count_in_group("destroyed")
		):
		print("Field complete!")
		await get_tree().create_timer(2.5).timeout
		field_clear.emit()

"""This function can be overriden per field.
For example, Level 1, Field 1 automatically ends after 30 seconds."""
#normally bad things should happen if the timer clears
# before the player completes the level
func _on_field_timer_timeout() -> void:
	print("We've been tracked! Hurry!")
	await get_tree().create_timer(3).timeout
	print("Oh !&@#...")
	while spawn_timer.wait_time > 1:
		spawn_timer.wait_time -= 1
		await get_tree().create_timer(5).timeout
	print("spawn_timer.wait_time = {0}".format([spawn_timer.wait_time]))
