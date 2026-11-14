extends Control

signal purchased

@export var id: StringName
@export var title: String
@export var base_cost: int = 50
@export var cost_step: int = 50

@onready var name_label = $NameLabel
@onready var cost_label = $CostLabel
@onready var squares = $HBoxContainer
@onready var buy_button = $BuyButton


func _ready() -> void:
	buy_button.pressed.connect(_on_buy_button_pressed)
	refresh()


func get_level() -> int:
	return Globals.upgrade_levels.get(id, 0)


func get_cost() -> int:
	return base_cost + cost_step * get_level()


func refresh() -> void:
	var level = get_level()
	var cost = get_cost()
	var max_level = squares.get_child_count()
	var maxed = level >= max_level
	name_label.text = title
	cost_label.text = "MAX" if maxed else str(cost)
	buy_button.disabled = maxed or Globals.dollars < cost
	for i in max_level:
		squares.get_child(i).modulate = Color(1, 1, 1, 1.0 if i < level else 0.3)


func _on_buy_button_pressed() -> void:
	var cost = get_cost()
	if get_level() >= squares.get_child_count() or Globals.dollars < cost:
		return
	Globals.dollars -= cost
	Globals.upgrade_levels[id] = get_level() + 1
	refresh()
	purchased.emit()
