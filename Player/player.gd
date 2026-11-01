extends CharacterBody2D

var speed = 200
const MAX_SPEED = 300
const MAX_DODGE_SPEED = 600
const VELOCITY_DELTA = 50
const ACCELERATION = 7200
const DODGE_ACCELERATION = 14400
const DODGE_DURATION = 0.25
const DODGE_COOLDOWN_DURATION = 0.5
const FRICTION = 5400
const EXIT_ACCELERATION = 1200.0
const EXIT_CAMERA_SPEED = 3.0

@export var shot_pattern: ShotPattern
@export var back_shot_pattern: ShotPattern
@export var upgrade_tiers: Array[ShotPattern] = []
var weapon_tier: int = 0

signal weapon_changed(pattern: ShotPattern)
var bullet_hell_mode := false

@onready var input_axis = Vector2.ZERO
@onready var axis = Vector2.UP
@onready var SpawnPos = $SpawnPos
@onready var SpawnPosBehind = $SpawnPosBehind
@onready var current_acceleration = 0
@onready var dodge: Dodge = null
@onready var dodge_cooldown: float = 0.0
var shooting_enabled = true
var controls_enabled: bool = true
var exiting: bool = false

@export var health: int = 5

var flashbang_dist: int = 500
const flying_friend = preload("res://Powerups/flying_friend.tscn")
var is_above_level: bool = false

signal flash_job

class Dodge:
	var remaining_duration: float
	var axis: Vector2


	func _init(p_remaining_duration: float, p_axis: Vector2) -> void:
		remaining_duration = p_remaining_duration
		axis = p_axis


	func decay(delta: float) -> Dodge:
		self.remaining_duration -= delta
		if self.remaining_duration <= 0:
			return null
		return self


	func is_accelerating() -> bool:
		return self.remaining_duration / DODGE_DURATION > 0.5


func _ready() -> void:
	weapon_tier = maxi(upgrade_tiers.find(shot_pattern), 0)


func _physics_process(delta: float) -> void:
	if bullet_hell_mode:
		move_bullet_hell(delta)
		move_and_slide()
		Globals.player_position = global_position
		return
	
	check_powerups()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	move(delta)
	rotate_default(delta)
	move_and_slide()
	
	Globals.player_position = global_position
	
	debug_action()
	
func is_orthogonal(axis_1: Vector2, axis_2: Vector2) -> bool:
	return is_zero_approx(axis_1.dot(axis_2))
	
func move(delta: float):
	if exiting:
		move_exit(delta)
		return
	dodge_cooldown = max(0, dodge_cooldown - delta)
	if dodge != null:
		move_dodge(delta)
	else:
		move_default(delta)


func move_dodge(delta: float):
	if dodge.is_accelerating():
		var accel = dodge.axis * DODGE_ACCELERATION * delta
		velocity += accel
	else:
		var vel_mult = clamp(1 - delta / 0.15, 0.0, 1.0)
		velocity *= vel_mult
	velocity = velocity.limit_length(MAX_DODGE_SPEED)
	dodge = dodge.decay(delta)


func move_exit(delta: float):
	dodge = null
	axis = Vector2.UP
	velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
	velocity.y = minf(velocity.y, 0.0) - EXIT_ACCELERATION * delta


func move_default(delta: float):
	input_axis = get_input_axis()

	if input_axis != Vector2.ZERO:
		if get_dodge_pressed():
			if is_orthogonal(axis, input_axis) and dodge_cooldown == 0:
				dodge = Dodge.new(DODGE_DURATION, input_axis)
				dodge_cooldown = DODGE_COOLDOWN_DURATION
		else:
			axis = input_axis
			current_acceleration = ACCELERATION
	if snap_to_tenths(axis) == -snap_to_tenths(velocity.normalized()):
		current_acceleration = ACCELERATION - FRICTION
	var accel = axis * current_acceleration * delta
	velocity += accel
	velocity = velocity.limit_length(MAX_SPEED)

func check_powerups():
	if get_flashbang_pressed():
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy.global_position.distance_to(global_position) < flashbang_dist:
				if "spin_out" in enemy:
					enemy.spin_out()
					flash_job.emit()
	if Input.is_action_just_pressed("Friendship"):
		fly_above_level()
		return
		print("FUFHRRFHIRFNIFRUIRF")
		var friend = flying_friend.instantiate()
		friend.global_position = global_position
		get_parent().add_child(friend)

func rotate_default(_delta: float):
	rotation_degrees = rad_to_deg(atan2(axis.y, axis.x))


func get_dodge_pressed() -> bool:
	return Input.is_action_pressed("Dodge")

func get_flashbang_pressed() -> bool:
	return Input.is_action_just_pressed("Use Flashbang")

func get_input_axis():
	return Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))


func apply_friction(amount: float):
	if velocity.length() > amount:
		velocity -= amount * velocity.normalized()
	else:
		velocity = Vector2.ZERO


func _process(_delta: float):
	if controls_enabled and Input.is_action_pressed("Shoot") and shooting_enabled:
		shoot()


func _on_ShootSpeed_timeout():
	shooting_enabled = true


func shoot():
	# print("player: axis.angle() = ", rad_to_deg(axis.angle()))
	var active_pattern: ShotPattern = shot_pattern if shot_pattern else back_shot_pattern
	if active_pattern == null:
		return
	if shot_pattern:
		shot_pattern.fire(SpawnPos.global_position,
			rad_to_deg(axis.angle()),
			get_tree().current_scene
		)
	if back_shot_pattern:
		back_shot_pattern.fire(
			SpawnPosBehind.global_position,
			rad_to_deg((-axis).angle()),
			get_tree().current_scene,
		)
	$ShootSpeed.start(active_pattern.firing_rate)
	shooting_enabled = false


func upgrade_weapon() -> void:
	if upgrade_tiers.is_empty():
		return
	weapon_tier = mini(weapon_tier + 1, upgrade_tiers.size() - 1)
	set_shot_pattern(upgrade_tiers[weapon_tier])


func set_shot_pattern(pattern: ShotPattern) -> void:
	if pattern == null:
		return
	shot_pattern = pattern
	var tier := upgrade_tiers.find(pattern)
	if tier != -1:
		weapon_tier = tier
	weapon_changed.emit(pattern)


func start_exit() -> void:
	exiting = true
	controls_enabled = false
	remove_from_group("looping_entity")
	var cam := get_viewport().get_camera_2d()
	if cam:
		cam.position_smoothing_enabled = true
		cam.position_smoothing_speed = EXIT_CAMERA_SPEED


func finish_exit() -> void:
	exiting = false
	velocity = Vector2.ZERO
	add_to_group("looping_entity")
	var cam := get_viewport().get_camera_2d()
	if cam:
		cam.position_smoothing_enabled = false
		cam.reset_smoothing()
	controls_enabled = true


func hit(damage):
	if exiting:
		return
	HitAnim.hit_flash(self, 0.3, 0.0)
	health -= damage
	if health <= 0:
		explode()

func explode():
	# Play animation
	pass
	#queue_free()


func debug_action():
	if Input.is_action_just_pressed("Debug"):
		print("player gp=", global_position, ", local gp =", position)

func snap_to_tenths(vector: Vector2):

	return vector.snapped(Vector2(0.1, 0.1))
func move_bullet_hell(delta: float) -> void:
	dodge = null
	axis = Vector2.UP                     
	var input : Vector2 = get_input_axis()
	velocity = input.normalized() * speed  
	rotate_default(delta)                 

func fly_above_level():
	$HitBox.disabled = true
	z_index = 1
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(5.0, 5.0), 1.0)
	$HangAboveTimer.start()

func _on_hang_above_timer_timeout() -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 1.0)
	$HitBox.disabled = false
	z_index = 0
