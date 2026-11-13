class_name MechRigController
extends Node2D

@onready var head : Node2D = $Head2
@onready var left_arm : Node2D = $LeftArm2
@onready var right_arm : Node2D = $RightArm2
@onready var torso : Node2D = $Torso2
@onready var feet : Node2D = $Feet2

@export var target : Node2D
@export var head_turn_speed : float = 1.0*PI
@export var feet_turn_speed : float = 2.5*PI
@export var arm_turn_speed : float = 2.0*PI
@export var torso_turn_speed : float = 0.5*PI
var head_direction : Vector2
var torso_direction : Vector2
var left_arm_direction : Vector2
#var right_arm_direction : Vector2
var feet_direction : Vector2
@export var head_faces_target : bool = true
@export var arms_faces_target : bool = true
@export var front_direction : Vector2 = Vector2(0, -1)
var sprite_front_rotation : float
@export var force_matching_part_rotation : bool = true
var rotation_sign : int
@export var rotation_deadzone : float = 0.1
var held_rotation_sign : int
var rotation_change_duration : float = 0.0
var match_part_rotation : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_front_rotation = front_direction.angle()
	if sprite_front_rotation > PI:
		sprite_front_rotation -= PI

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_rotation = 0   
	var facing = get_parent().get("axis")
	if facing != null:
		head_direction = facing
		left_arm_direction = facing
		#right_arm_direction = facing
		feet_direction = facing
	torso_direction = facing
	if (target):
		if (head_faces_target):
			direct_head_towards_target()
		if (arms_faces_target):
			direct_arms_towards_target()
	#torso_direction = get_safe_torso_direction()
	rotate_parts_towards_directions(delta)
	held_rotation_sign = rotation_sign
		
func direct_head_towards_target():
	head_direction = target.global_position - global_position
func direct_arms_towards_target():
	left_arm_direction = target.global_position - global_position
	#right_arm_direction = target.global_position - global_position

func rotate_parts_towards_directions(delta):
	var previous_head_rotation = head.global_rotation
	rotate_part_towards(head, head_direction, delta * head_turn_speed)
	if (force_matching_part_rotation):
		var d_rotation = head.global_rotation - previous_head_rotation
		rotation_sign = d_rotation / abs(d_rotation)
		if held_rotation_sign == rotation_sign:
			rotation_change_duration = 0.0
			match_part_rotation = true
		else:
			rotation_change_duration += delta
			match_part_rotation = rotation_change_duration < rotation_deadzone
	rotate_part_towards(feet, feet_direction, delta * feet_turn_speed)
	rotate_part_towards(left_arm, left_arm_direction, delta * arm_turn_speed)
	#rotate_part_towards(right_arm, right_arm_direction, delta * arm_turn_speed)
	rotate_part_towards(torso, torso_direction, delta * torso_turn_speed)
	

func rotate_part_towards(part : Node2D, direction : Vector2, delta):
	var new_rotation = lerp_angle(
		part.global_rotation,
		direction.angle() - sprite_front_rotation,
		delta
	)
	if not match_part_rotation or part == head:
		part.global_rotation = new_rotation
	else:
		part.global_rotation += rotation_sign * abs(new_rotation-part.global_rotation)
	
func get_safe_torso_direction():
	return Vector2.from_angle((
		left_arm_direction.angle() +
		#right_arm_direction.angle() +
		head_direction.angle() +
		feet_direction.angle()
	)/3)
	
