extends Area2D

var SPEED = 800
var damage = 1
var homing_degrees = 0
var max_homing_dist = 0
var max_range = 500
var current_range = 0

@onready var axis = Vector2.UP


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if homing_degrees != 0:
		var enemies = get_tree().get_nodes_in_group("enemies")
		var closest_dist = 99999999
		var closest_enemy = null
		
		# find nearest
		for enemy in enemies:
			var current_dist = self.global_position.distance_squared_to(enemy.global_position)
			if ( current_dist < max_homing_dist and current_dist < closest_dist):
				closest_dist = current_dist
				closest_enemy = enemy
		
		if (closest_enemy != null):
			var direction = closest_enemy.global_position - self.global_position
			var target_angle = direction.angle()
			rotation = rotate_toward(rotation, target_angle, homing_degrees * delta)
	position += transform.x * SPEED * delta
	current_range += SPEED * delta
	
	if current_range > max_range:
		queue_free()


func _on_PlayerBullet_body_entered(body: Node2D) -> void:
	if body.has_method('enemy_hit'):
		body.enemy_hit(damage)
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("enemy_hit"):
		area.enemy_hit(damage)
		queue_free()
