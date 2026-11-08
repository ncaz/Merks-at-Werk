class_name BulletPowerup
extends PowerupMove
@export var pattern: ShotPattern
@export_enum("front", "back") var slot: String = "front"

func apply(player: Node) -> void:
	if slot == "front":
		player.set_shot_pattern(pattern)
	else:
		player.set_back_shot_pattern(pattern)
