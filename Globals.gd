extends Node

var field_time_left = 0
var player_position = Vector2(0, 0)

var map_bounds: Rect2
var map_size: Vector2

var score: int = 0
var owned_ids: Array[StringName] = []
var dollars: int = 0
