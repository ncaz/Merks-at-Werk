class_name PowerupMove
extends Resource

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var cost: int
@export var icon: Texture2D
@export_enum("moves", "powerup") var category: String = "moves"

# Called when the player buys/equips this. Override in subclasses.
func apply(player: Node) -> void:
	pass
