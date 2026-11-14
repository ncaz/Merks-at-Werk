extends Node2D
var texture: Texture2D = preload("res://HUD/assets/arrow.png") #type: ignore



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw() -> void:
	

	var to_player: Vector2 = Globals.player_position - global_position
			# Choose the shortest direction across each wrapped boundary.
	to_player.x = wrapf(
		to_player.x,
		-Globals.map_size.x / 2.0,
		Globals.map_size.x / 2.0
	)
	to_player.y = wrapf(
		to_player.y,
		-Globals.map_size.y / 2.0,
		Globals.map_size.y / 2.0
	)
	
	
	
	var pos = Vector2(to_player.x, to_player.y)
	pos = Vector2(0,0)
	
	var angle = pos.angle_to_point(get_local_mouse_position())
	print(angle)
	draw_set_transform(pos, angle, Vector2(.05, .1))
	draw_texture(texture, -texture.get_size()/2)
	
	
func _process(delta: float) -> void:
	queue_redraw()
