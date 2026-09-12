extends CharacterBody2D

var state = "demo"
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

func _ready() -> void:
	if !homing:
		rotation = axis.angle()
		
func _physics_process(delta: float) -> void:
	if state == "demo":
		pass
		
	if ramping_speed:
		current_speed = lerp(current_speed, max_speed, delta * ramp_weight)
		speed = current_speed
		#print(speed)
		
	if speed != 0:
		
		if homing:
			axis = global_position.direction_to(Globals.player_position)
			var target_angle = axis.angle()
		
			rotation = rotate_toward(rotation, target_angle, rot_speed * delta)
			axis = Vector2.RIGHT.rotated(rotation)
		
		if axis != Vector2.ZERO:
			velocity = speed * axis
			
		var collision = move_and_collide(velocity * delta)
		if collision:
			var collider = collision.get_collider()
			if collider.is_in_group("player"):
				collider.player_hit(0)
				explode()
	
func enemy_hit(damage=1):
	health -= damage
	if health <= 0:
		explode()
		
func explode():
	# Some explosion animation.
	queue_free()
