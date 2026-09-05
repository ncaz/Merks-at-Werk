extends Area2D

const SPEED = 800
var damage = 1

@onready var axis = Vector2.UP


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += transform.x * SPEED * delta


func _on_PlayerBullet_body_entered(body: Node2D) -> void:
	if body.has_method('enemy_hit'):
		body.enemy_hit(damage)
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("enemy_hit"):
		area.enemy_hit(damage)
		queue_free()
