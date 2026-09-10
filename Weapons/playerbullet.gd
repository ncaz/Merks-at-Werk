extends Area2D


var speed = 800
var damage = 1
var homing_degrees = 0

var max_range = 500
var current_range = 0

@onready var axis = Vector2.UP

func load_stats(data):

	homing_degrees = data.homing_degrees
	damage = data.damage
	
	speed = data.speed
	max_range = data.max_range

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if homing_degrees != 0:
		
		var enemies = get_tree().get_nodes_in_group("enemies")
		var closest_dist = 99999999999999999
		var closest_enemy = null
		
		# find nearest
		for enemy in enemies:
			var current_dist = self.global_position.distance_squared_to(enemy.global_position)

			if (current_dist < closest_dist):
				closest_dist = current_dist
				closest_enemy = enemy
		if (closest_enemy != null):
			var direction = closest_enemy.global_position - self.global_position
			var target_angle = direction.angle()
			rotation = rotate_toward(rotation, target_angle, homing_degrees * delta)
	position += transform.x * speed * delta
	current_range += speed * delta
	
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
