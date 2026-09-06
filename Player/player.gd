extends CharacterBody2D

const SPEED = 200
const MAX_SPEED = 300
const VELOCITY_DELTA = 50
const ACCELERATION = 7200
const FRICTION = 5400

# Weapon Stats
var bullet_damage = 1
var attack_cooldown = 0.3
var shoot_behind = true
var bullet_volley_count = 5
var bullet_volley_spread = 15
var homing_degrees = 5
var homing_dist = 150
var max_range = 500
var bullet_speed = 800


var Bullet = preload("res://Player/playerbullet.tscn")

@onready var input_axis = Vector2.ZERO
@onready var axis = Vector2.UP
@onready var SpawnPos = $SpawnPos
@onready var current_acceleration = 0

var shooting_enabled = true

@export var health: int = 5

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	move_default(delta)
	rotate_default(delta)
	move_and_slide()
	
	global_position = Vector2(clamp(global_position.x, -640, 640), clamp(global_position.y, -360, 360))
	Globals.player_position = global_position
	
func move_default(delta: float):
	input_axis = get_input_axis()
	if input_axis != Vector2.ZERO:
		current_acceleration = ACCELERATION
		axis = input_axis
	if snap_to_tenths(axis) == -snap_to_tenths(velocity.normalized()):
		current_acceleration = ACCELERATION - FRICTION
	var accel = axis * current_acceleration * delta
	velocity += accel
	velocity = velocity.limit_length(MAX_SPEED)

func rotate_default(delta: float):
	rotation_degrees = rad_to_deg(atan2(axis.y, axis.x))

func get_input_axis():
	return Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))

func apply_friction(amount: float):
	if velocity.length() > amount:
		velocity -= amount * velocity.normalized()
	else:
		velocity = Vector2.ZERO

func _on_ShootSpeed_timeout():
	shooting_enabled = true

func _process(delta: float):
	if Input.is_action_pressed("Shoot") and shooting_enabled:
		shoot()


	

func shoot():	
	var new_rotation_offset = 0 - bullet_volley_spread * (bullet_volley_count- 1)/2
	for i in range(bullet_volley_count):
		var bullet = Bullet.instantiate()
		bullet.damage = bullet_damage
		bullet.homing_degrees = homing_degrees
		bullet.max_homing_dist = homing_dist * homing_dist # squared dist
		bullet.max_range = max_range
		bullet.SPEED = bullet_speed
		bullet.transform = SpawnPos.global_transform
		bullet.rotation += deg_to_rad(new_rotation_offset)
		new_rotation_offset += bullet_volley_spread
		get_tree().current_scene.add_child(bullet)
	
	if shoot_behind:
		new_rotation_offset = 0 - bullet_volley_spread * (bullet_volley_count- 1)/2
		for i in range(bullet_volley_count):
			var bullet = Bullet.instantiate()
			bullet.damage = bullet_damage
			bullet.homing_degrees = homing_degrees
			bullet.max_homing_dist = homing_dist * homing_dist # squared dist
			bullet.max_range = max_range
			bullet.SPEED = bullet_speed
			bullet.transform = SpawnPos.global_transform
			bullet.rotation += deg_to_rad(new_rotation_offset)
			bullet.transform.x = - bullet.transform.x
			new_rotation_offset += bullet_volley_spread
			get_tree().current_scene.add_child(bullet)
		
	
	$ShootSpeed.start(attack_cooldown)
	shooting_enabled = false
	
func player_hit(damage):
	health -= damage
	if health <= 0:
		explode()
		
func explode():
	# Play animation
	queue_free()

func snap_to_tenths(vector: Vector2):
	# Rounds components of vector to tenths place
	return vector.snapped(Vector2(0.1,0.1))
