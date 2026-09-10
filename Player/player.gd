extends CharacterBody2D

const SPEED = 200
const MAX_SPEED = 300
const VELOCITY_DELTA = 50
const ACCELERATION = 7200
const FRICTION = 5400

# Weapon Stats

@export var Weapon = Resource

var Bullet = preload("res://Weapons/playerbullet.tscn")

@onready var input_axis = Vector2.ZERO
@onready var axis = Vector2.UP
@onready var SpawnPos = $SpawnPos
@onready var SpawnPosBehind = $SpawnPosBehind

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
	shoot_volley_spread()
	$ShootSpeed.start(Weapon.shot_cooldown)
	shooting_enabled = false
	return
	
	$ShootSpeed.start(Weapon.shot_cooldown)
	shooting_enabled = false



func shoot_volley_spread():
	var bullet: Object
	var bullet_behind: Object
	var count = Weapon.bullet_volley_count
	var spread = Weapon.bullet_volley_spread
	
	

	var new_rotation_offset = 0 - spread * (count- 1)/2
	var bullet_cache = Weapon.bullet_data.bullet_scene.instantiate()
	#bullet_cache.load_stats(Weapon.bullet_data)
	for i in range(count):
		bullet = bullet_cache.duplicate()
		bullet.load_stats(Weapon.bullet_data)
		bullet.transform = SpawnPos.global_transform
		bullet.rotation += deg_to_rad(new_rotation_offset)
		new_rotation_offset += spread
		get_tree().current_scene.add_child(bullet)
	
	if Weapon.shoot_behind:
		if Weapon.single_behind:
			new_rotation_offset = 0
			bullet_behind = bullet_cache.duplicate()
			bullet_behind.load_stats(Weapon.bullet_data)
			bullet_behind.transform = SpawnPosBehind.global_transform
			bullet_behind.rotation += deg_to_rad(new_rotation_offset)
			bullet_behind.transform.x = -bullet_behind.transform.x
			get_tree().current_scene.add_child(bullet_behind)
		else:
			new_rotation_offset = 0 - spread * (count- 1)/2
			for i in range(count):
				bullet_behind = bullet_cache.duplicate()
				bullet_behind.load_stats(Weapon.bullet_data)
				bullet_behind.transform = SpawnPosBehind.global_transform
				bullet_behind.rotation += deg_to_rad(new_rotation_offset)
				bullet_behind.transform.x = -bullet_behind.transform.x
				new_rotation_offset += spread
				get_tree().current_scene.add_child(bullet_behind)
	
func shoot_three_way():
	
	var bullet: Object
	var bullet_behind: Object
	
	for rot in [-45, 45]:
		
		bullet = Bullet.instantiate()

		bullet.homing_degrees = 0
		bullet.max_range = 2000
		bullet.transform = SpawnPos.global_transform
		bullet.rotation_degrees += rot
		get_tree().current_scene.add_child(bullet)
	
	if Weapon.shoot_behind:
		bullet_behind = Bullet.instantiate()
		bullet_behind.homing_degrees = 0
		bullet_behind.max_range = 2000
		bullet_behind.transform = SpawnPosBehind.global_transform
		bullet_behind.transform.x = -bullet_behind.transform.x
		get_tree().current_scene.add_child(bullet_behind)
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
