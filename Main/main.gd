extends Node2D

@onready var World = $World

var level_1_bgm = preload("res://Assets/Music/Track01_Gameplay.mp3")
func _ready() -> void:
	$Player.connect("flash_job", $CanvasLayer/UI.flash_job)

func _process(_delta: float) -> void:

	for copy in $CopiedEntities.get_children():
		copy.queue_free()
		
	for entity in get_tree().get_nodes_in_group("looping_entity"):
			
		if !is_instance_valid(entity):
			return
			
		#if "speed" in entity and entity.speed != 0:
		entity.global_position = Vector2(
			wrapf(entity.global_position.x,
				Globals.map_bounds.position.x,
				Globals.map_bounds.end.x),
			wrapf(entity.global_position.y,
				Globals.map_bounds.position.y,
				Globals.map_bounds.end.y)
		)				
		if not entity.is_in_group("player") and entity.get_parent() != $CopiedEntities:
			var displacement: Vector2 = entity.global_position - Globals.player_position

			var x_offset: float = 0.0
			var y_offset: float = 0.0

			if displacement.x > Globals.map_bounds.size.x / 2.0:
				x_offset = -Globals.map_bounds.size.x
			elif displacement.x < -Globals.map_bounds.size.x / 2.0:
				x_offset = Globals.map_bounds.size.x

			if displacement.y > Globals.map_bounds.size.y / 2.0:
				y_offset = -Globals.map_bounds.size.y
			elif displacement.y < -Globals.map_bounds.size.y / 2.0:
				y_offset = Globals.map_bounds.size.y

			if x_offset != 0.0:
				create_sprite_copy(entity, Vector2(x_offset, 0))
			if y_offset != 0.0:
				create_sprite_copy(entity, Vector2(0, y_offset))
			if x_offset != 0.0 and y_offset != 0.0:
				create_sprite_copy(entity, Vector2(x_offset, y_offset))

func create_sprite_copy(entity: Node2D, offset: Vector2) -> void:
	
	var source_sprites: Array
	if "get_sprite" in entity:
		source_sprites.append(entity.get_sprite())
	elif "get_sprites" in entity:
		source_sprites.append_array(entity.get_sprites())
		
	for source_sprite in source_sprites:
		var sprite_copy: Sprite2D = source_sprite.duplicate()
		$CopiedEntities.add_child(sprite_copy)
		sprite_copy.global_transform = source_sprite.global_transform
		sprite_copy.global_position += offset

	#var source_sprite: Sprite2D = entity.get_sprite()
	#var sprite_copy: Sprite2D = source_sprite.duplicate()

	#$CopiedEntities.add_child(sprite_copy)
	#sprite_copy.global_transform = source_sprite.global_transform
	
	# Move copy to corresponding side of map.
	#sprite_copy.global_position += offset
