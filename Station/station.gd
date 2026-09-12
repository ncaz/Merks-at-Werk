extends Node2D

@export var missile_scene: PackedScene
@export var bullet_scene: PackedScene

var is_destroyed = false

func _get_weaks() -> Array[DestructiblePart]:
	
	return get_children().filter(
		func(child):
			return child.is_in_group("weak"),
	)


func _ready():
	$Core.destroyed.connect(destroy_station)

	for child in _get_weaks():
		child.destroyed.connect(_check_weaks_destroyed)


func _check_weaks_destroyed():
	print("checking weaks")
	if _get_weaks().all(
		func(weak):
			return weak.is_destroyed(),
	):
		destroy_station()
		
func destroy_station():
	if is_destroyed:
		return
	is_destroyed = true
	print("station destroyed")
	$Core.destroy_part()
	$Core.disable_part()
	for weak in _get_weaks():
		weak.destroy_part()
		weak.disable_part()
		
func _on_missle_spawn_timer_timeout() -> void:
	if is_destroyed:
		return
	print("shooting missle")
	if missile_scene == null:
		return

	var missile = missile_scene.instantiate()
	
	print(missile)

	missile.global_position = $MissileSpawnPoint.global_position

	get_tree().current_scene.add_child(missile)


func _on_bullet_timer_timeout() -> void:
	
	if bullet_scene == null:
		return
		
	var lowest_dist = INF
	var closest_weak = null
	
	for weak in _get_weaks():
		if !weak.is_destroyed():
			
			var dist = weak.global_position.distance_to(Globals.player_position)
			if dist < lowest_dist:
				lowest_dist = dist
				closest_weak = weak
	
	if closest_weak:
		var bullet = bullet_scene.instantiate()
			
		bullet.global_position = closest_weak.global_position
		bullet.axis = (Globals.player_position - bullet.global_position).normalized()
			
		get_tree().current_scene.add_child(bullet)
			
