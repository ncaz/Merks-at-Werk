class_name DestructiblePart
extends Area2D

signal destroyed

@export var max_health: float = 3.0
@export var start_texture: Texture2D
@export var destroyed_texture: Texture2D

var current_health: float


func is_destroyed() -> bool:
	return current_health <= 0


func _ready():
	current_health = max_health
	$Sprite2D.texture = start_texture


func enemy_hit(damage: float):
	if is_destroyed():
		return

	current_health -= damage
	if is_destroyed():
		destroy_part()

func enable_part():
	$CollisionShape2D.set_deferred("disabled", false)

func disable_part():
	$CollisionShape2D.set_deferred("disabled", true)


func destroy_part():
	current_health = 0

	$Sprite2D.texture = destroyed_texture

	destroyed.emit()
