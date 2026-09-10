extends Resource
class_name bulletData

@export var speed: int = 800
@export var damage: float = 1
@export var homing_degrees: float = 0
@export var max_range: int = 500



@export var bullet_scene: PackedScene = preload("res://Weapons/playerbullet.tscn")
