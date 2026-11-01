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
			
		if "speed" in entity and entity.speed != 0:
			if entity.global_position.x >= Globals.map_bounds.end[0]:
				entity.global_position.x -= Globals.map_size.x
			elif entity.global_position.x < Globals.map_bounds.position[0]:
				entity.global_position.x += Globals.map_size.x
			if entity.global_position.y >= Globals.map_bounds.end[1]:
				entity.global_position.y -= Globals.map_size.y
			elif entity.global_position.y < Globals.map_bounds.position[1]:
				entity.global_position.y += Globals.map_size.y
			
		if !entity.is_in_group("player") and entity.get_parent() != $CopiedEntities:
			
			if Globals.player_position.x >= 0:
				if entity.global_position.x <= 0:
					create_sprite_copy(entity, Vector2(World.map_size.x, 0))
			else:
				if entity.global_position.x > 0:
					create_sprite_copy(entity, Vector2(-World.map_size.x, 0))
						
			if Globals.player_position.y >= 0:
				if entity.global_position.y <= 0:
					create_sprite_copy(entity, Vector2(0, World.map_size.y))
			else:
				if entity.global_position.y > 0:
					create_sprite_copy(entity, Vector2(0, -World.map_size.y))

func create_sprite_copy(entity: Node2D, offset: Vector2) -> void:
	
	var source_sprites: Array
	if "get_sprites" in entity:
		source_sprites = entity.get_sprites()
	elif "get_sprites" in entity:
		source_sprites.append(entity.get_sprite())
		
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
