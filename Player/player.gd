extends CharacterBody2D

const SPEED = 200
const MAX_SPEED = 300
const VELOCITY_DELTA = 50
const ACCELERATION = 7200
const REVERSING_ACCELERATION = -3600
const FRICTION = 7200

var bullet_damage = 1

var Bullet = preload("res://Player/playerbullet.tscn")

@onready var input_axis = Vector2.ZERO
@onready var axis = Vector2.UP
@onready var reversing = false
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
	elif input_axis == -axis:
		reversing = true
	if reversing:
		current_acceleration = REVERSING_ACCELERATION
		if axis == 0:
			pass
	else:
		current_acceleration = ACCELERATION
	
	apply_movement(axis * current_acceleration * delta)	
func rotate_default(delta: float):
	rotation_degrees = rad_to_deg(atan2(axis.y, axis.x))
func get_input_axis():
	return Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))

func apply_movement(accel: Vector2):
	velocity += accel
	velocity = velocity.limit_length(MAX_SPEED)

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
	var bullet = Bullet.instantiate()
	bullet.damage = bullet_damage
	bullet.transform = SpawnPos.global_transform
	get_tree().current_scene.add_child(bullet)

	var bullet_behind = Bullet.instantiate()
	bullet.damage = bullet_damage
	bullet_behind.transform = SpawnPos.global_transform
	bullet_behind.transform.x = -bullet_behind.transform.x
	get_tree().current_scene.add_child(bullet_behind)

	$ShootSpeed.start()
	shooting_enabled = false
	
func player_hit(damage):
	health -= damage
	if health <= 0:
		explode()
		
func explode():
	# Play animation
	queue_free()
