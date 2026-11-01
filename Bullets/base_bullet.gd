class_name Bullet
extends Area2D

@export var speed = 800
@export var damage = 1

@onready var despawn_timer = $DespawnTimer

var axis = Vector2.UP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
# This function should be overridden for each bullet type
func _physics_process(delta: float) -> void:
	position += axis * speed * delta


func _on_body_entered(body: Node2D, target_method = 'hit') -> void:
	if body.has_method(target_method):
		print("HIT ", body)
		body.hit(damage)
		queue_free()


func _on_area_entered(area: Area2D, target_method = 'hit') -> void: #appears to be for Stations
	if area.has_method(target_method):
		print("HIT ", area)
		area.hit(damage)
		queue_free()



func get_sprite():
	return $Sprite2D


func _on_despawn_timer_timeout() -> void:
	print(name)
	queue_free()
