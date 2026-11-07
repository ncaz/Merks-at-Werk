extends Control

signal buy_pressed(ability: PowerupMove)

var ability: PowerupMove

@onready var name_label = $NameLabel
@onready var cost_label = $CostLabel
@onready var desc_label = $DescLabel
@onready var icon = $Icon
@onready var buy_button = $BuyButton


func _ready() -> void:
	buy_button.pressed.connect(_on_buy_button_pressed)


func setup(data: PowerupMove) -> void:
	ability = data
	name_label.text = data.display_name
	desc_label.text = data.description
	cost_label.text = str(data.cost)
	icon.texture = data.icon


func set_state(owned: bool, affordable: bool) -> void:
	buy_button.disabled = owned or not affordable
	modulate = Color(1, 1, 1, 0.5) if owned else Color.WHITE


func _on_buy_button_pressed() -> void:
	buy_pressed.emit(ability)
