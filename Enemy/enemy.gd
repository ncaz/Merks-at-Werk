extends CharacterBody2D

@export var does_despawn: bool = false
@export var explosion_scene: PackedScene

@export var axis = Vector2.ZERO

@export var health = 1
@export var speed: float = 0.0

@export_category("Homing")
@export var homing: bool = false
@export var rot_speed: float = 4.0

# Ramping (Enemy Takes Time To Reach Full Speed)
@export_category("Speed Ramping")
@export var ramping_speed = true
@onready var max_speed = speed
var current_speed: float = 0.0
## Float multiplied by delta to get weight used for lerping. Increase for faster ramping, decrease for slower ramping.
@export var ramp_weight: float = 1.0

@export_category("Drops")
@export var drop_scene: PackedScene
@export_range(0.0, 1.0) var drop_chance: float = 0.0

@export_category("Scoring")
@export var score: int = 50

func _ready() -> void:
	if !homing:
		rotation = axis.angle()
	if does_despawn:
		$DespawnTimer.start()
		
func _physics_process(delta: float) -> void:
	
	if ramping_speed:
		current_speed = lerp(current_speed, max_speed, delta * ramp_weight)
		speed = current_speed
		
	if speed != 0:
		
		if homing:
			
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

			# Turn toward the player using the shortest wrapped direction.
			if not to_player.is_zero_approx():
				var target_angle = to_player.angle()
				rotation = rotate_toward(rotation, target_angle, rot_speed * delta)
				axis = to_player.normalized()
		if axis != Vector2.ZERO:
			velocity = speed * axis
			
		var collision = move_and_collide(velocity * delta)
		if collision:
			var collider = collision.get_collider()
			if collider.is_in_group("player"):
				collider.hit(0)
				explode()
	
func hit(damage=1):
	if health <= 0:
		return
	HitAnim.hit_flash(get_sprite())
	health -= damage
	if health <= 0:
		Globals.score += score
		drop_powerup()
		explode()


func drop_powerup():
	if drop_scene == null or randf() >= drop_chance:
		return
	var drop = drop_scene.instantiate()
	drop.global_position = global_position
	get_tree().current_scene.add_child(drop)
		
func explode():
	set_physics_process(false)
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)
	queue_free()
	
func get_sprite():
	return $Sprite
	
func get_sprites():
	return $Mecha.get_children()
	
func _on_despawn_timer_timeout() -> void:
	explode()
