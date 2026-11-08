extends Area2D

var speed = 650.0
var rot_speed: float = 100.0
var axis: Vector2 = Vector2.ZERO
var to_target: Vector2

func _physics_process(delta: float) -> void:
	to_target = find_nearest_enemy_pos() - global_position
	# Choose the shortest direction across each wrapped boundary.
	to_target.x = wrapf(
		to_target.x,
		-Globals.map_size.x / 2.0,
		Globals.map_size.x / 2.0
	)
	to_target.y = wrapf(
		to_target.y,
		-Globals.map_size.y / 2.0,
		Globals.map_size.y / 2.0
	)
	# Turn toward the player using the shortest wrapped direction.
	if not to_target.is_zero_approx():
		var target_angle = to_target.angle()
		rotation = rotate_toward(rotation, target_angle, rot_speed * delta)
		axis = to_target.normalized()
	if axis != Vector2.ZERO:
		position += axis.normalized() * speed * delta

func find_nearest_enemy_pos():
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	var closest_position: Vector2
	if enemies.size() > 0:
		var lowest_dist = INF
		for enemy in enemies:
			var dist = global_position.distance_to(enemy.global_position)
			if dist < lowest_dist:
				lowest_dist = dist
				closest_position = enemy.global_position
	else:
		closest_position = Globals.player_position
		
	return closest_position

func _on_body_entered(body: Node2D) -> void:
	if "explode" in body:
		body.explode()
		
func _on_death_timer_timeout() -> void:
	queue_free()
